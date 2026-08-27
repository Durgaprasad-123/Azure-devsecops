# Docker

This directory contains the container build and local DevSecOps service configuration.

## Files

- `Dockerfile` — application/container image build instructions.
- `docker-compose.yml` — multi-container service configuration.
- `nginx.conf` — Nginx configuration used by the Docker deployment.
- `.env` — environment-specific values; never put real secrets in Git.

## Build Image

From the directory containing the Dockerfile:

```bash
docker build -t <IMAGE_NAME>:<TAG> .
```

## Run Compose

```bash
docker compose up -d
```

Check status:

```bash
docker compose ps
```

View logs:

```bash
docker compose logs -f
```

## Security Scanning

Scan the built image with Trivy:

```bash
trivy image <IMAGE_NAME>:<TAG>
```

## ACR

For the CI/CD workflow, the image is promoted to Azure Container Registry. AKS agent nodes pull the image using their Managed Identity with `AcrPull` on ACR.

## Environment Variables

Use a local `.env` only for non-public configuration or development values. Secrets should preferably come from Azure Key Vault at runtime in the CI/CD environment.

## Security

Use minimal base images, pin trusted dependencies where practical, avoid running as root when possible, scan images before deployment, and never commit credentials.