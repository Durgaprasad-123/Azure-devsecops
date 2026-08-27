# Infrastructure Installation Scripts

This folder contains host bootstrap scripts. The current `install.sh` prepares an Ubuntu host with common DevSecOps tooling.

## What the Script Installs

The script currently installs/configures:

- System updates
- Git and common utilities
- OpenJDK 21
- Docker Engine and Docker Compose plugin
- Trivy
- `/opt/devsecops` project directory
- SonarQube-related `vm.max_map_count` setting
- DefectDojo source checkout

## Run

Review the script before execution, then:

```bash
chmod +x install.sh
./install.sh
```

Some commands use `sudo`, so the executing account must have appropriate administrative privileges.

## DefectDojo Startup

After the script completes, follow the displayed instructions to enter the DefectDojo directory and start its Docker Compose deployment.

## Verification

```bash
java -version
git --version
docker --version
docker compose version
trivy --version
```

## Important Note

The script currently contains a Docker APT source configured with `Suites: jammy`. Verify the host distribution/repository compatibility before production use, especially if the VM is Ubuntu 24.04.

## Security

Review every downloaded script/source before execution. Do not put secrets, tokens, or passwords in installation scripts.