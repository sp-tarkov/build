# SPT Build Project - CI/CD Process

This document outlines the Continuous Integration and Continuous Deployment (CI/CD) setup for the `SPT-AKI/Build` project, which automates the build and release process for three interconnected repositories: `SPT-AKI/Modules`, `SPT-AKI/Server`, and `SPT-AKI/Launcher`. The process is orchestrated using Gitea Actions.

## Project Repositories

TODO: Update for Gitea

Each of the three project repositories (`SPT-AKI/Modules`, `SPT-AKI/Server`, `SPT-AKI/Launcher`) requires a `.drone.yml` file configured to trigger a build in this `SPT-AKI/Build` repository using the Drone downstream plugin upon a new tag push (e.g., `v3.8.0`). The contents of the `.drone.yml` file can be found in `project-trigger.yml`. Note that the file must be present and named `.drone.yml` to trigger the build process.

### Build Process

This repository initiates the CI/CD build process by performing the following actions:

1. Checks if the passed in tag exists in all three project repositories.
1. Clones the tagged commits of each repository.
1. Builds each project.
1. Combines and compresses the build files into a release file.
1. Copies the release file to a web-accessible location.
1. Release notifications (creates a Gitea release, sends a Discord notification, etc.)

## Gitea Runner Configuration

TODO: Update for Gitea

### Run the Runner

TODO: Update for Gitea

## Module Requirements

To build the Modules project, a link to a private repository is required for the build process. The link is stored as a secret in the Drone CI/CD environment. The secret is named `MODULE_DOMAIN` and is used to download files from the private repository. It does not end with a slash.

## Building the Docker Images

Be sure to update the version number to the next available version before building and pushing the Docker images. you must be logged into Docker Desktop to push the images.

```
# Build and push the spt-build-server Docker image to the Docker Hub
docker build -t refringe/spt-build-server:0.0.0 -t refringe/spt-build-server:latest -f Dockerfile.node .
docker push refringe/spt-build-server --all-tags

# Build and push the spt-build-dotnet Docker image to the Docker Hub
docker build -t refringe/spt-build-dotnet:0.0.0 -t refringe/spt-build-dotnet:latest -f Dockerfile.dotnet .
docker push refringe/spt-build-dotnet --all-tags
```
