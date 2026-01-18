# scripts/validate_k8s.ps1
$ErrorActionPreference = "Stop"

Write-Host "🔎 Iniciando auditoria de configurações Kubernetes (offline / repo-only)..."

$minReplicas = 3
$maxReplicas = 6

# --- 1) Validar que os arquivos existem ---
$deploymentFile = "k8s\deployment.yaml"
$hpaFile        = "k8s\hpa.yaml"

if (!(Test-Path $deploymentFile)) { throw "Arquivo não encontrado: $deploymentFile" }
if (!(Test-Path $hpaFile))        { throw "Arquivo não encontrado: $hpaFile" }

# --- 2) Checar HPA: min/max replicas ---
$hpa = Get-Content $hpaFile -Raw

if ($hpa -notmatch "minReplicas:\s*$minReplicas") {
  throw "HPA inválido: esperado minReplicas: $minReplicas"
}

if ($hpa -notmatch "maxReplicas:\s*$maxReplicas") {
  throw "HPA inválido: esperado maxReplicas: $maxReplicas"
}

Write-Host "✅ HPA ok (min=$minReplicas / max=$maxReplicas)"

# --- 3) Checar Deployment: apiVersion/kind básicos ---
$dep = Get-Content $deploymentFile -Raw

if ($dep -notmatch "apiVersion:\s*apps\/v1") {
  throw "Deployment inválido: apiVersion deve ser apps/v1"
}
if ($dep -notmatch "kind:\s*Deployment") {
  throw "Deployment inválido: kind deve ser Deployment"
}

Write-Host "✅ Deployment ok (apiVersion/kind)"

Write-Host "🎉 Governance OK: manifests validados com sucesso."
