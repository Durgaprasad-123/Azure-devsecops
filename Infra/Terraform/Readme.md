# Terraform Infrastructure

This directory contains the Terraform configuration used to provision the Azure DevSecOps environment.

## Layout

```text
Terraform/
├── bootstramp/       # Bootstrap resources/configuration
├── devsecops/        # Main Terraform root module
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
- Access to the target Azure subscription
- Permissions to create the resources defined by the modules

## Authenticate

```bash
az login
az account set --subscription "<SUBSCRIPTION_ID>"
az account show
```

For the Jenkins VM, Azure access is performed using Managed Identity rather than a long-lived Azure client secret.

## Initialize

Run Terraform from the appropriate root configuration, for example:

```bash
cd Infra/Terraform/devsecops
terraform init
```

If the remote backend configuration has changed, use:

```bash
terraform init --reconfigure
```

## Review and Apply

```bash
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

Review the plan before applying infrastructure changes.

## Destroy

Only when the complete environment is intentionally being removed:

```bash
terraform destroy
```

Always verify the selected subscription, resource group, backend, and plan before destructive operations.

## State

Terraform state may contain sensitive infrastructure information. Keep state in the secured remote backend and never commit `terraform.tfstate` or credentials to Git.

## RBAC Design

The deployed environment uses Azure Managed Identity and RBAC. The Jenkins VM identity is granted the permissions required for Key Vault and AKS operations, while the AKS agent-pool identity receives `AcrPull` on ACR.

## Troubleshooting

### Backend authentication failure

Verify Azure login/context, backend resource existence, and the identity's access to the storage account/container.

### Resource SKU unavailable

Check the selected Azure region and available VM SKUs before applying.

### Authorization failure

Check the effective role assignments for the identity at the required resource scope.

## Security

Do not place passwords, tokens, private keys, or other secret values in `.tf` files, `tfvars` committed to Git, or Terraform state stored in source control.