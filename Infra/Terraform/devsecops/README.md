# DevSecOps Terraform Root Module

This is the main Terraform root configuration for the Azure DevSecOps environment.

## Files

- `provider.tf` — Azure provider configuration.
- `backend.tf` — Terraform remote-state backend configuration.
- `main.tf` — root resources/module calls.
- `variables.tf` — input variables.
- `outputs.tf` — exported values.

## Prerequisites

```bash
az login
az account set --subscription "<SUBSCRIPTION_ID>"
terraform version
```

## Workflow

```bash
cd Infra/Terraform/devsecops
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

If the backend was recreated or changed:

```bash
terraform init --reconfigure
```

## Backend

The backend stores Terraform state remotely. Ensure the backend storage account, container, and access method exist before initialization. Never commit state files or backend credentials.

## Modules

The root configuration consumes modules for ACR, AKS, Key Vault, networking, security, and the VM.

## Identity/RBAC

The Jenkins VM Managed Identity is used for Azure operations and receives only the roles needed by the pipeline. AKS agent-pool identity receives `AcrPull` on ACR.

## Safe Operations

Always inspect `terraform plan` before `apply` or `destroy`. Confirm the subscription and resource group to avoid changing the wrong environment.