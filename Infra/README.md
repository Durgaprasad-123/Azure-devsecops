# Azure Infrastructure

This directory contains the infrastructure automation used by the Azure DevSecOps project.

## Components

- `Terraform/` — Infrastructure as Code and reusable Azure modules.
- `scripts/` — host/bootstrap installation scripts.

## Deployment Flow

```text
Terraform
   |
   +--> Networking / NSGs
   +--> Jenkins VM
   +--> Azure Key Vault
   +--> ACR
   +--> AKS
   +--> Security resources
```

## Prerequisites

Install Azure CLI and Terraform, then authenticate:

```bash
az login
az account set --subscription "<SUBSCRIPTION_ID>"
az account show
```

## Recommended Order

1. Review Terraform variables and backend configuration.
2. Provision foundational networking/security resources.
3. Provision Key Vault and configure RBAC.
4. Provision ACR and AKS.
5. Provision/configure the Jenkins VM.
6. Run the bootstrap script where required.
7. Configure CI/CD and application deployment.

## Identity Model

The Jenkins VM uses Azure Managed Identity. Its identity is assigned **Key Vault Secrets User** on Key Vault and **Azure Kubernetes Service Cluster User Role** on the AKS cluster according to the project configuration.

The AKS agent-pool identity is assigned **AcrPull** on ACR so Kubernetes nodes can retrieve private images without registry passwords in manifests.

## Security

Use least-privilege RBAC, restrict network exposure, keep Terraform state out of Git, and never commit secrets.