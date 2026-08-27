# Azure Container Registry Module

Creates/configures Azure Container Registry for storing application container images.

## Purpose

Jenkins builds and scans container images, then the approved image is pushed to ACR. AKS retrieves the image from ACR.

## Configuration

Review `variables.tf`, `main.tf`, and `outputs.tf`. Supply the resource group/location and registry settings from the root Terraform configuration.

## Deployment

From the root Terraform directory:

```bash
terraform init
terraform plan
terraform apply
```

## AKS Access

The AKS agent-pool Managed Identity is granted **AcrPull** on the registry. This allows Kubernetes nodes to pull private images without storing registry passwords in Kubernetes manifests.

## Verification

```bash
az acr list -o table
az acr repository list --name "<ACR_NAME>" -o table
```

## Security

Disable unnecessary anonymous/admin access. Scope `AcrPull` to the required registry and never commit registry passwords.