#!/bin/bash

set -e

NAMESPACE="default"
MIN_REPLICAS=3
MAX_REPLICAS=6
MAX_CPU="4"
MAX_MEMORY="8Gi"

echo "🔍 Iniciando auditoria de configurações Kubernetes..."

DEPLOYMENTS=$(kubectl get deploy -n $NAMESPACE -o jsonpath='{.items[*].metadata.name}')

for DEPLOY in $DEPLOYMENTS; do
  echo "---------------------------------------------"
  echo "📦 Deployment: $DEPLOY"

  # =========================
  # Verificação de Réplicas
  # =========================
  REPLICAS=$(kubectl get deploy $DEPLOY -n $NAMESPACE -o jsonpath='{.spec.replicas}')

  if [[ $REPLICAS -lt $MIN_REPLICAS ]]; then
    echo "⚠️ Réplicas abaixo do mínimo ($REPLICAS). Ajustando para $MIN_REPLICAS."
    kubectl scale deploy $DEPLOY -n $NAMESPACE --replicas=$MIN_REPLICAS
  elif [[ $REPLICAS -gt $MAX_REPLICAS ]]; then
    echo "⚠️ Réplicas acima do máximo ($REPLICAS). Ajustando para $MAX_REPLICAS."
    kubectl scale deploy $DEPLOY -n $NAMESPACE --replicas=$MAX_REPLICAS
  else
    echo "✅ Réplicas dentro do padrão ($REPLICAS)."
  fi

  # =========================
  # Verificação de Recursos
  # =========================
  CONTAINERS=$(kubectl get deploy $DEPLOY -n $NAMESPACE -o jsonpath='{.spec.template.spec.containers[*].name}')

  for CONTAINER in $CONTAINERS; do
    CPU_LIMIT=$(kubectl get deploy $DEPLOY -n $NAMESPACE \
      -o jsonpath="{.spec.template.spec.containers[?(@.name=='$CONTAINER')].resources.limits.cpu}")

    MEM_LIMIT=$(kubectl get deploy $DEPLOY -n $NAMESPACE \
      -o jsonpath="{.spec.template.spec.containers[?(@.name=='$CONTAINER')].resources.limits.memory}")

    if [[ "$CPU_LIMIT" != "$MAX_CPU" || "$MEM_LIMIT" != "$MAX_MEMORY" ]]; then
      echo "⚠️ Ajustando recursos do container $CONTAINER"
      echo "   CPU: $CPU_LIMIT → $MAX_CPU"
      echo "   Memória: $MEM_LIMIT → $MAX_MEMORY"

      kubectl patch deploy $DEPLOY -n $NAMESPACE --type='json' -p="
      [
        {
          \"op\": \"replace\",
          \"path\": \"/spec/template/spec/containers/0/resources/limits/cpu\",
          \"value\": \"$MAX_CPU\"
        },
        {
          \"op\": \"replace\",
          \"path\": \"/spec/template/spec/containers/0/resources/limits/memory\",
          \"value\": \"$MAX_MEMORY\"
        }
      ]"
    else
      echo "✅ Recursos do container $CONTAINER estão dentro do padrão."
    fi
  done

done

echo "✅ Auditoria e correções Kubernetes finalizadas com sucesso."
