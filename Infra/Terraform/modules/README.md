# Terraform Modules

Reusable Terraform modules for the Azure DevSecOps platform.

## Modules

- `acr/` — Azure Container Registry.
- `aks/` — Azure Kubernetes Service.
- `keyvault/` — Azure Key Vault.
- `networking/` — Azure network resources.
- `security/` — security-related Azure resources.
- `vm/` — virtual machine resources used by the platform.

## Usage

The root `devsecops` configuration calls these modules and supplies variables. Keep module inputs/outputs documented and avoid embedding environment secrets in module code.

## Design Principle

Modules should be reusable, predictable, and least-privilege. Identity and RBAC assignments should be explicit and scoped to the resources that require them.