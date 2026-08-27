# Azure DevSecOps Platform

An Azure-based DevSecOps implementation that integrates infrastructure as code, CI/CD, application security, container security, secret management, and Kubernetes deployment into a single automated workflow.

## Project Overview

This project demonstrates an end-to-end DevSecOps pipeline using Azure, Terraform, Jenkins, SonarQube, Trivy, OWASP ZAP, Docker, Azure Container Registry (ACR), Azure Kubernetes Service (AKS), and Azure Key Vault.

The architecture is designed to avoid unnecessary long-lived Azure credentials in Jenkins. The Jenkins VM authenticates to Azure using a Managed Identity, while Azure RBAC controls access to Key Vault, AKS, and other required resources.

## High-Level Architecture

```text
Developer
   |
   | Git Push
   v
GitHub
   |
   v
Jenkins VM
(Managed Identity)
   |
   +---------------------> Azure Key Vault
   |                         |
   |                         +--> Secrets
   |
   +--> Terraform ----------> Azure Infrastructure
   |
   +--> SonarQube ----------> SAST / Quality Gate
   |
   +--> Docker Build
   |       |
   |       +--> Trivy ------> Container Vulnerability Scan
   |       |
   |       v
   |    Azure Container Registry
   |       |
   |       | AcrPull
   |       v
   |      AKS
   |       |
   |       v
   |   Application
   |       |
   |       v
   |   OWASP ZAP
   |       |
   |       v
   |   DAST Findings
   |
   +--> DefectDojo / Security Reporting
```

## Technology Stack

| Category | Technology |
|---|---|
| Cloud Platform | Microsoft Azure |
| Infrastructure as Code | Terraform |
| Source Control | GitHub |
| CI/CD | Jenkins |
| SAST | SonarQube |
| Container Security | Trivy |
| DAST | OWASP ZAP |
| Containers | Docker |
| Container Registry | Azure Container Registry |
| Kubernetes | Azure Kubernetes Service |
| Secret Management | Azure Key Vault |
| Identity | Azure Managed Identity |
| Authorization | Azure RBAC |
| Security Reporting | DefectDojo |
| Web/Reverse Proxy | Nginx |

## DevSecOps Pipeline

The pipeline follows this general flow:

1. Developer pushes application code to GitHub.
2. Jenkins checks out the source code.
3. SonarQube performs static code and security analysis.
4. Jenkins evaluates the SonarQube Quality Gate.
5. Docker builds the application image.
6. Trivy scans the image for known vulnerabilities.
7. Terraform provisions or updates required Azure infrastructure.
8. The Docker image is pushed to Azure Container Registry.
9. AKS pulls the image from ACR using its managed identity permissions.
10. Jenkins deploys the application to AKS.
11. OWASP ZAP performs dynamic security testing against the deployed application.
12. Security findings can be collected and managed through DefectDojo.

## Azure Managed Identity and RBAC

Managed Identity is a key security component of this implementation.

### Jenkins VM Managed Identity

The Jenkins VM uses an Azure Managed Identity to authenticate to Azure services without storing a long-lived Azure client secret in Jenkins.

The Jenkins VM identity has the following relevant role assignments:

- **Key Vault Secrets User** on the Azure Key Vault.
- **Azure Kubernetes Service Cluster User Role** on the AKS cluster.

These permissions allow Jenkins to retrieve required secrets from Key Vault and obtain the appropriate AKS user access needed for the deployment workflow.

### AKS Agent Pool Managed Identity

The Kubernetes agent-pool identity is assigned:

- **AcrPull** on the Azure Container Registry.

This allows AKS nodes to pull private container images from ACR without embedding registry credentials in Kubernetes manifests.

### RBAC Flow

```text
Jenkins VM Managed Identity
        |
        +---- Key Vault Secrets User ----> Azure Key Vault
        |
        +---- AKS Cluster User Role ----> AKS Cluster

AKS Agent Pool Managed Identity
        |
        +---- AcrPull -------------------> Azure Container Registry
```

This separates the permissions of the CI/CD system from the permissions required by the Kubernetes worker nodes.

## Azure Key Vault

Azure Key Vault is used as the centralized secret store for the CI/CD environment.

Secrets required by Jenkins are kept in Key Vault rather than being committed to GitHub or hard-coded in pipeline configuration.

Depending on the pipeline configuration, examples include:

- SonarQube authentication token
- DefectDojo API key
- Container registry credentials where required
- Other CI/CD secrets

Jenkins accesses these secrets through its VM Managed Identity and the **Key Vault Secrets User** role.

> **Important:** Never commit actual secret values, passwords, API keys, private keys, or tokens to this repository. Only document secret names or examples.

## Infrastructure as Code with Terraform

Terraform is used to provision and manage the Azure environment.

The infrastructure includes components such as:

- Azure networking
- Network security controls
- Virtual machines
- Azure Container Registry
- Azure Key Vault
- AKS / Kubernetes infrastructure
- Supporting security resources

Terraform makes the environment reproducible and allows infrastructure changes to be reviewed before deployment.

Terraform state should be stored in a secured remote backend and should never be committed to Git.

## Security Testing

### SonarQube — SAST

SonarQube is integrated into Jenkins to identify source-code security issues, vulnerabilities, bugs, and maintainability problems. The pipeline can stop progression when the configured Quality Gate fails.

### Trivy — Container Security

Trivy scans the generated container image for known vulnerabilities before deployment/promotion.

### OWASP ZAP — DAST

OWASP ZAP is used after deployment to test the running application dynamically for common web application security issues.

### DefectDojo — Findings Management

DefectDojo can be used to centralize and track findings generated by security tools in the pipeline, making it easier to manage remediation and security reporting.

## Repository Structure

A representative project structure is:

```text
Azure-devsecops/
├── README.md
├── Infra/
│   └── Terraform/
│       ├── backend.tf
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       ├── modules/
│       │   ├── acr/
│       │   ├── keyvault/
│       │   ├── networking/
│       │   ├── security/
│       │   └── vm/
│       └── bootstrap/
├── Jenkinsfile
├── Dockerfile
├── docker-compose.yml
└── Kubernetes/
    ├── deployment.yaml
    └── service.yaml
```

The exact directory names can change as the implementation evolves.

## Security Principles Used

- Managed Identity instead of long-lived Azure credentials where possible.
- Azure RBAC for authorization.
- Least-privilege access for Jenkins and AKS identities.
- Azure Key Vault for centralized secret management.
- ACR access through managed identity and `AcrPull`.
- Static security analysis before deployment.
- Container vulnerability scanning before deployment.
- Dynamic security testing after deployment.
- Terraform state kept outside source control.
- No real secrets committed to GitHub.
- Network access restricted according to the environment's security requirements.

## End-to-End Security Flow

```text
                 GitHub
                    |
                    v
              Jenkins Pipeline
                    |
       +------------+------------+
       |            |            |
       v            v            v
  Key Vault     SonarQube    Terraform
       |          SAST          |
       |            |           v
       |       Quality Gate   Azure Infra
       |            |
       +------------+------------+
                    |
                    v
              Docker Build
                    |
                    v
                  Trivy
                    |
                    v
                 ACR
                    |
                 AcrPull
                    |
                    v
                  AKS
                    |
                    v
             Application
                    |
                    v
               OWASP ZAP
                    |
                    v
             Security Findings
                    |
                    v
               DefectDojo
```

## Why Managed Identity?

Using Managed Identity avoids storing an Azure service-principal secret directly on the Jenkins VM or inside the Jenkins pipeline. Azure issues an identity token to the VM, and Azure RBAC determines what that identity can access.

The design also separates responsibilities:

- Jenkins identity accesses Key Vault and AKS according to its assigned roles.
- AKS agent-pool identity accesses ACR with `AcrPull`.

This provides a clearer security boundary and reduces credential-management overhead.

## Production Security Considerations

Before using this architecture in production, review:

- Key Vault RBAC scope and network restrictions.
- Exact scope of Jenkins role assignments.
- ACR `AcrPull` scope for the AKS identity.
- AKS Kubernetes RBAC.
- Terraform backend authentication and state protection.
- NSGs, firewall rules, private endpoints, and public exposure.
- SonarQube Quality Gate policy.
- Trivy vulnerability severity thresholds.
- OWASP ZAP scan scope and rules.
- Secret rotation and access auditing.
- Logging and monitoring for Azure resources and CI/CD infrastructure.

## Important Security Warning

Do not commit any of the following to this repository:

- Azure client secrets
- Service-principal credentials
- Key Vault secret values
- SonarQube tokens
- DefectDojo API keys
- Registry passwords
- Private keys
- Kubernetes admin credentials
- Terraform state containing sensitive values

Use Azure Key Vault, Managed Identity, RBAC, and secure CI/CD mechanisms instead.

## Project Objective

The objective of this project is to demonstrate practical DevSecOps on Azure by integrating infrastructure automation, identity and access management, secret management, source-code security, container security, Kubernetes deployment, and dynamic application security testing into the software delivery lifecycle.

## Author

**S. Leela Durga Prasad Sasubilli**

Azure DevSecOps / Cloud Security Project
