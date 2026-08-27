# Azure Security Module

Contains Terraform resources used to apply security controls around the DevSecOps environment.

## Purpose

Centralizes security-related Azure configuration such as network/security-group controls and supporting security resources defined by this module.

## Workflow

```bash
cd Infra/Terraform/devsecops
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

## Review Before Apply

Check NSG rules, source/destination ranges, exposed ports, identity assignments, and resource scopes before applying changes.

## Security Principles

- Least privilege
- Minimal network exposure
- Explicit RBAC scopes
- No secrets in Terraform source
- Review every firewall/NSG change

## Verification

Use Azure Portal or Azure CLI to inspect the effective network and role configuration after deployment.