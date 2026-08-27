# Azure Key Vault Module

Provides centralized secret storage for the DevSecOps pipeline.

## Purpose

Secrets used by Jenkins are stored in Azure Key Vault instead of being hard-coded in source control.

## Configuration

Review `variables.tf`, `main.tf`, and `outputs.tf`. Configure the vault name, location, resource group, and security settings through Terraform variables.

## Deployment

```bash
cd Infra/Terraform/devsecops
terraform plan
terraform apply
```

## Jenkins Managed Identity

The Jenkins VM uses a Managed Identity. The identity is assigned **Key Vault Secrets User** at the Key Vault scope so Jenkins can retrieve secrets required by the pipeline.

## Secret Creation

Create secrets through Azure Key Vault rather than Git:

```bash
az keyvault secret set \
  --vault-name "<KEY_VAULT_NAME>" \
  --name "<SECRET_NAME>" \
  --value "<SECRET_VALUE>"
```

Do not put the real value in documentation or source code.

## Verification

```bash
az keyvault show --name "<KEY_VAULT_NAME>" -o table
az role assignment list --scope "<KEY_VAULT_RESOURCE_ID>" -o table
```

## Security

Use Azure RBAC, least privilege, network restrictions where appropriate, logging, and secret rotation. Never commit Key Vault secret values, tokens, passwords, or private keys.