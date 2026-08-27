# Kubernetes / AKS Deployment

This directory contains Kubernetes manifests used to deploy the application to Azure Kubernetes Service.

## Files

- `deployment.yaml` — application Deployment.
- `service.yaml` — Kubernetes Service exposing the application.

## Prerequisites

- Running AKS cluster
- `kubectl` installed
- Appropriate AKS access
- Container image available in ACR

## Connect to AKS

For Jenkins, the VM Managed Identity has the **Azure Kubernetes Service Cluster User Role** on the cluster according to the project RBAC design.

For an authorized interactive administrator:

```bash
az login
az account set --subscription "<SUBSCRIPTION_ID>"
az aks get-credentials --resource-group "<RESOURCE_GROUP>" --name "<AKS_NAME>"
kubectl get nodes
```

## Deploy

Review the image reference in `deployment.yaml`, then:

```bash
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
```

Verify:

```bash
kubectl get deployments
kubectl get pods
kubectl get services
```

## ACR Image Pull

The AKS agent-pool Managed Identity is assigned **AcrPull** on the Azure Container Registry. This allows nodes to pull private images without registry credentials in the manifest.

## Troubleshooting

### ImagePullBackOff

Check the image name/tag and verify the AKS agent-pool identity has `AcrPull` on the correct ACR.

### Unauthorized Kubernetes access

Verify the Jenkins Managed Identity has the expected AKS role and that Kubernetes RBAC permits the requested operation.

## Security

Do not commit kubeconfig files, registry passwords, tokens, or Kubernetes secrets containing real credentials. Use managed identities and external secret-management mechanisms where appropriate.