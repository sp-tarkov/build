# SPT Build Project - CI/CD Process

This document outlines the Continuous Integration and Continuous Deployment (CI/CD) setup for the `SPT-AKI/Build` project, which automates the build and release process for three interconnected repositories: `SPT-AKI/Modules`, `SPT-AKI/Server`, and `SPT-AKI/Launcher`. The process is orchestrated using Drone CI with Gitea and relies on a Windows Docker runner to execute PowerShell scripts for building and packaging the projects.

## Project Repositories

Each of the three project repositories (`SPT-AKI/Modules`, `SPT-AKI/Server`, `SPT-AKI/Launcher`) requires a `.drone.yml` file configured to trigger a build in this `SPT-AKI/Build` repository using the Drone downstream plugin upon a new tag push (e.g., `v3.8.0`). The contents of the `.drone.yml` file can be found in `project-trigger.yml`. Note that the file must be present and named `.drone.yml` to trigger the build process.

### Build Process

This repository's `.drone.yml` initiates the CI/CD process by running a PowerShell script `build.ps1` on a Windows Docker runner. The PowerShell script performs the following actions:

1. Checks if the passed in tag exists in all three project repositories.
1. Clones the tagged commits of each repository.
1. Builds each project.
1. Combines and compresses the build files into a release file.
1. Copies the release file to a web-accessible location.
1. Release notifications (creates a Gitea release, sends a Discord notification, etc.)

## Drone Runner Configuration

Drone CI Runner Requirements:
- Windows Server 2022 Host
- Docker Community Edition (CE)

### Install Docker CE

Docker CE needs to be installed (not Docker Desktop). The following steps outline the installation process for Windows Server 2022:

To install Docker CE on Windows Server 2022, follow these steps:

1. Open `Windows Server Manager`
1. Select `Manage`
1. Select `Add Roles and Features`
1. Click `Next` on the `Before You Begin` page
1. Select `Role-based or feature-based installation`
1. Select the name of the server where the feature will be installed and click `Next`
1. Select `Hyper-V` and click `Next`
1. Select `Containers` and click `Next`
1. Click `Install` on the `Confirm installation selections` page
1. Click `Close` on the `Installation progress` page
1. Open a PowerShell terminal (as admin) and run the following commands to install Docker CE:

```powershell
# Download install script
Invoke-WebRequest  -UseBasicParsing "https://raw.githubusercontent.com/microsoft/Windows-Containers/Main/helpful_tools/Install-DockerCE/install-docker-ce.ps1"  -o install-docker-ce.ps1

# Run install script
.\install-docker-ce.ps1

# Test Docker installation
Get-Service Docker
```

### Run the Runner

Use the command below to start the Drone CI Runner. But first...
 - Replace the `DRONE_RPC_HOST` value with the host of the Drone server that should be connected to for builds.
 - Replace the `DRONE_RPC_SECRET` value with the Drone server secret.
 - Replace the `DRONE_RUNNER_NAME` value with a unique name for the runner.
 - Replace the `DRONE_UI_PASSWORD` value with a password to access the web runner UI.
 - Adjust `DRONE_RUNNER_CAPACITY` to the number of builds that should be allowed to run at once.

```powershell
docker run --detach --volume=//./pipe/docker_engine://./pipe/docker_engine --env=DRONE_RPC_PROTO=https --env=DRONE_RPC_HOST=example.com --env=DRONE_RPC_SECRET=secret --env=DRONE_RUNNER_CAPACITY=2 --env=DRONE_RUNNER_NAME=example --env=DRONE_UI_DISABLE=false --env=DRONE_UI_USERNAME=root --env=DRONE_UI_PASSWORD=password --publish=3000:3000 --restart=always --name=runner drone/drone-runner-docker:latest
```

## Module Requirements

To build the Modules project, a link to a private repository is required for the build process. The link is stored as a secret in the Drone CI/CD environment. The secret is named `MODULE_DOMAIN` and is used to download files from the private repository. It does not end with a slash.

## Building the Docker Images

Be sure to update the version number to the next available version before building and pushing the Docker images. you must be logged into Docker Desktop to push the images.

```
# Build and push the spt-build-server Docker image to the Docker Hub
docker build -t refringe/spt-build-server:0.0.0 -t refringe/spt-build-server:latest -f Dockerfile.server .
docker push refringe/spt-build-server --all-tags

# Build and push the spt-build-dotnet Docker image to the Docker Hub
docker build -t refringe/spt-build-dotnet:0.0.0 -t refringe/spt-build-dotnet:latest -f Dockerfile.dotnet .
docker push refringe/spt-build-dotnet --all-tags
```
