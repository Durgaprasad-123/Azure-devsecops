# Terraform Bootstrap

This folder contains bootstrap Terraform configuration used to prepare prerequisite infrastructure/configuration for the DevSecOps environment.

## Prerequisites

```bash
az login
az account set --subscription "<SUBSCRIPTION_ID>"
terraform version
```

## Configure

Review `main.tf` before execution. Replace placeholder values with environment-specific values and do not commit secrets.

## Run

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

## Verify

After apply, verify the resources created by Terraform in Azure Portal or Azure CLI.

```bash
az resource list --resource-group "<RESOURCE_GROUP>" -o table
```

## Security

Use RBAC/Managed Identity where supported. Do not place passwords, API keys, or private keys in Terraform source.