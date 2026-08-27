# Virtual Machine Module

Creates the virtual machine used to host the Jenkins/DevSecOps tooling environment.

## Purpose

The VM provides the execution environment for Jenkins and supporting security/container tooling.

## Managed Identity

The Jenkins VM is configured with an Azure Managed Identity. Relevant RBAC assignments in this project include:

- **Key Vault Secrets User** on Azure Key Vault.
- **Azure Kubernetes Service Cluster User Role** on the AKS cluster.

This avoids storing a long-lived Azure service-principal secret on the Jenkins host for these operations.

## Configuration

Review `variables.tf` and `main.tf`. Configure VM size, network interface/subnet, image, administrator settings, and identity settings through variables.

## Deployment

```bash
cd Infra/Terraform/devsecops
terraform plan
terraform apply
```

## Bootstrap

After the VM is available, the installation script in `Infra/scripts/install.sh` can install the required host tooling.

## Verification

```bash
az vm show --resource-group "<RESOURCE_GROUP>" --name "<VM_NAME>" -o table
az vm identity show --resource-group "<RESOURCE_GROUP>" --name "<VM_NAME>"
```

## Security

Restrict SSH/management access, avoid unnecessary public exposure, keep OS packages updated, and do not store application secrets on disk.