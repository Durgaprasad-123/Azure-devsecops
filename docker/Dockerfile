FROM jenkins/jenkins:lts-jdk21
USER root

# --- Docker CLI (talks to the host daemon via the mounted socket) ---
RUN apt-get update && apt-get install -y ca-certificates curl gnupg lsb-release && \
    install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    chmod a+r /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" \
      > /etc/apt/sources.list.d/docker.list && \
    apt-get update && apt-get install -y docker-ce-cli

# --- Trivy (runs natively now, no sibling container needed) ---
RUN curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh \
      | sh -s -- -b /usr/local/bin

# --- Azure CLI ---
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# --- kubectl (via the az aks extension) ---
RUN az aks install-cli
