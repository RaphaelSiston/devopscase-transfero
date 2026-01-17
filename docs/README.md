# 1. Visão Geral
# Este documento descreve a arquitetura, decisões técnicas e boas práticas adotadas no desenvolvimento do case técnico para a vaga de DevOps Engineer Pleno. O objetivo principal foi demonstrar a aplicação de conceitos modernos de CI/CD, segurança, qualidade de código, Kubernetes, observabilidade e auditoria, alinhados às práticas de mercado.


# 2. Arquitetura da Solução
# A solução foi estruturada com base nos seguintes pilares:

# - Azure DevOps: Orquestração de CI/CD, controle de pipelines e aprovações
# - SonarCloud: Análise de qualidade de código e Quality Gates
# - OWASP ZAP: Testes de segurança dinâmica (DAST)
# - Kubernetes: Orquestração de containers com políticas automáticas de correção
# - Azure Monitor / Observabilidade: Coleta de métricas, logs e alertas
# - Fluxo de alto nível:
# - Commit no repositório
# - Execução de pipeline CI
# - Validação de testes automatizados
# - Análise de qualidade de código (SonarCloud)
# - Testes de segurança dinâmica (DAST)
# - Deploy em ambiente de staging
# - Aprovação manual para produção
# - Deploy em produção
# - Geração de relatórios e auditoria


# 3. Pipeline CI/CD no Azure DevOps
# A pipeline foi construída em formato YAML, promovendo versionamento, reutilização e rastreabilidade.

# - 3.1 Estágios da Pipeline
# - Build: Compilação e validação inicial da aplicação
# - Tests: Execução de testes unitários, integração e carga
# - Quality: Análise de qualidade do código com SonarCloud
# - Security: Execução de testes DAST com OWASP ZAP
# - Deploy_Staging: Deploy automatizado em ambiente de homologação
# - Approval: Aprovação manual obrigatória
# - Deploy_Prod: Deploy controlado em produção
# - Essa separação garante isolamento de responsabilidades e facilita auditorias.


# 4. Governança de Qualidade de Código – SonarCloud
# O SonarCloud foi integrado à pipeline para aplicar Quality Gates, impedindo que código com problemas de qualidade chegue à produção.
# Métricas monitoradas:

# - Cobertura mínima de testes
# - Duplicação de código
# - Vulnerabilidades de segurança
# - Code Smells
# - Caso algum critério não seja atendido, a pipeline é automaticamente interrompida.
# - Relatórios de qualidade ficam disponíveis via dashboard do SonarCloud e vinculados à execução da pipeline no Azure DevOps.


# 5. Segurança – DAST com OWASP ZAP
# Foi implementada uma etapa de Dynamic Application Security Testing (DAST) utilizando o OWASP ZAP.
# Estratégia adotada:
# - Execução automatizada durante a pipeline
# - arredura de vulnerabilidades em aplicações web e APIs
# - Classificação por severidade
# - A pipeline é interrompida automaticamente caso sejam identificadas vulnerabilidades High ou Critical.
# - Os relatórios de segurança são gerados em formato HTML e publicados como artifacts no Azure DevOps, além de estarem prontos para integração com sistemas de alerta.


# 6. Kubernetes – Correções Automáticas e Governança

# 6.1 Escalabilidade com HPA
# Foi configurado o Horizontal Pod Autoscaler (HPA) com os seguintes limites:
# - Réplicas mínimas: 3
# - Réplicas máximas: 6
# - Escalabilidade baseada no uso de CPU
# - Essa abordagem garante alta disponibilidade e uso eficiente de recursos.

# 6.2 Limites de Recursos
# - Cada pod possui limites definidos de:

# - CPU: até 4 cores
# - Memória: até 8 GB
# - Esses limites evitam consumo excessivo e garantem estabilidade do cluster.

# 6.3 Script de Correção Automática (Policy as Code)
# - Foi desenvolvido um script automatizado responsável por:

# - Validar configurações de réplicas
# - Verificar limites de CPU e memória
# - Corrigir automaticamente qualquer configuração fora do padrão
# - Esse conceito reforça a prática de Policy as Code, reduzindo erros manuais e garantindo compliance contínuo.


# 7. Monitoramento, Métricas e Logs
# A solução prevê integração com Azure Monitor / Container Insights, permitindo:

# - Monitoramento de CPU, memória e número de réplicas
# - Coleta centralizada de logs de aplicações e cluster
# - Visualização via dashboards

# - Alertas configuráveis:

# - Uso excessivo de CPU ou memória
# - Réplicas fora do padrão definido
# - Falhas em pods ou serviços
# - Essa abordagem garante observabilidade desde o deploy, facilitando troubleshooting e resposta a incidentes.


# 8. Auditoria e Relatórios
# Cada execução da pipeline gera:

# - Relatório de conformidade de testes
# - Relatório de qualidade de código
# - Relatório de segurança (DAST)
# - Logs detalhados de correções automáticas
# - Esses dados permitem rastreabilidade completa e atendem requisitos de auditoria e compliance.


# 9. Considerações Finais
# Este case foi desenvolvido com foco em:

# - Automação
# - Segurança desde o início (Shift Left Security)
# - Qualidade contínua
# - Governança e auditoria
# - Boas práticas de DevOps e SRE
# - A arquitetura proposta é escalável, segura e alinhada aos padrões utilizados em ambientes corporativos modernos.