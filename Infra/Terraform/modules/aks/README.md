# Azure Kubernetes Service Module

Creates the AKS cluster used to run the application workloads.

## Purpose

AKS provides the Kubernetes runtime where the container image from ACR is deployed.

## Configuration

Review `variables.tf`, `main.tf`, and `outputs.tf`. Confirm the region, node/agent-pool configuration, networking, and identity settings before applying.

## Deployment

```bash
cd Infra/Terraform/devsecops
terraform plan
terraform apply
```

## Managed Identity and ACR

The AKS agent-pool identity is granted **AcrPull** on ACR. This is the identity used by the cluster nodes to retrieve private images.

## Jenkins Access

The Jenkins VM Managed Identity has the **Azure Kubernetes Service Cluster User Role** on the AKS cluster according to this project's RBAC design. Jenkins can then obtain the required user access for the deployment workflow.

## Verify

```bash
az aks show --resource-group "<RESOURCE_GROUP>" --name "<AKS_NAME>" -o table
az aks get-credentials --resource-group "<RESOURCE_GROUP>" --name "<AKS_NAME>"
kubectl get nodes
```

## Security

Use Kubernetes RBAC, private networking where appropriate, controlled API-server exposure, and least-privilege Azure RBAC. Do not commit kubeconfig files containing credentials.