# Terraform Infrastructure

This directory contains the Terraform implementation for the Azure DevSecOps platform.

## Structure

```text
Terraform/
├── bootstramp/       # Bootstrap Terraform configuration
├── devsecops/        # Main/root Terraform configuration
└── modules/
    ├── acr/
    ├── aks/
    ├── keyvault/
    ├── networking/
    ├── security/
    └── vm/
```

## Prerequisites

- Azure subscription
- Azure CLI
- Terraform
- Permissions to create/manage the configured Azure resources

Authenticate with Azure:

```bash
az login
az account set --subscription "<SUBSCRIPTION_ID>"
az account show
```

## Main Workflow

```bash
cd Infra/Terraform/devsecops
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

If the remote backend configuration changed:

```bash
terraform init --reconfigure
```

## Modules

The root configuration uses reusable modules for ACR, AKS, Key Vault, networking, security, and the Jenkins VM.

## Identity and RBAC

The Jenkins VM authenticates to Azure using Managed Identity. The Jenkins identity is assigned **Key Vault Secrets User** on Key Vault and **Azure Kubernetes Service Cluster User Role** on AKS as required by the deployment workflow.

The AKS agent-pool Managed Identity is assigned **AcrPull** on ACR so nodes can pull private images.

## State

Use a secured remote backend for Terraform state. State can contain sensitive information and must not be committed to Git.

## Destruction

Only destroy the environment intentionally:

```bash
terraform plan -destroy
terraform destroy
```

Confirm the subscription, backend, and resource targets first.

## Troubleshooting

- Backend 403/404: verify backend resource existence and identity access.
- Azure authorization error: inspect RBAC assignment and scope.
- VM SKU error: verify SKU availability in the selected region.
- AKS creation error: verify supported VM size, quota, networking, and subscription limits.

## Security

Never commit credentials, Key Vault values, tokens, private keys, or Terraform state. Prefer Managed Identity and Azure RBAC.