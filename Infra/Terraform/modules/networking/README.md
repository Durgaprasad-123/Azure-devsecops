# Azure Networking Module

Creates the Azure networking resources required by the DevSecOps environment.

## Purpose

Provides the network foundation for the Jenkins VM and Azure workloads and applies network security controls.

## Configuration

Review `main.tf` and `outputs.tf` and configure address spaces, subnets, NSGs, and associations through the root module variables.

## Deployment

```bash
cd Infra/Terraform/devsecops
terraform plan
terraform apply
```

## Verification

```bash
az network vnet list -o table
az network nsg list -o table
az network vnet subnet list --resource-group "<RESOURCE_GROUP>" --vnet-name "<VNET_NAME>" -o table
```

## Security

Open only required ports. Avoid exposing management interfaces publicly where possible. Use NSGs, private endpoints, firewall controls, and subnet segmentation according to the deployment requirements.