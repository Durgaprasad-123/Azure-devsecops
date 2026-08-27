# CI/CD Pipeline

This directory contains documentation and pipeline-related material for the Jenkins-based DevSecOps workflow. The existing `pipeline.md` contains the detailed pipeline documentation.

## Pipeline Stages

```text
GitHub
  -> Jenkins
  -> Checkout
  -> SonarQube SAST
  -> Quality Gate
  -> Docker Build
  -> Trivy Scan
  -> Terraform
  -> ACR
  -> AKS Deployment
  -> OWASP ZAP DAST
  -> Security Reporting
```

## Jenkins Azure Identity

Jenkins runs on an Azure VM using Managed Identity. The Jenkins identity is assigned:

- **Key Vault Secrets User** for retrieving required secrets.
- **Azure Kubernetes Service Cluster User Role** for AKS access required by the deployment workflow.

The AKS agent-pool identity separately has **AcrPull** on ACR.

## Secret Management

Pipeline secrets should be stored in Azure Key Vault and retrieved at runtime. Do not commit tokens/passwords into Jenkinsfiles or this repository.

## Before Running

Verify Jenkins, SonarQube, Docker, Trivy, Terraform, Azure CLI, kubectl, Key Vault access, ACR access, and AKS permissions.

## Troubleshooting

Check Jenkins console output first. For Azure authorization failures, inspect the managed identity role assignments and their scopes. For SonarQube failures, verify the configured server/token and Quality Gate. For AKS image-pull failures, verify the agent-pool identity has `AcrPull` on the correct ACR.