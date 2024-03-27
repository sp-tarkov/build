# SPT Build Project - CI/CD Overview

This document provides an overview of the Continuous Integration and Continuous Deployment (CI/CD) implemented for the `SPT-AKI` project. This framework is responsible for automating the compilation, building, and deployment phases across three critical repositories: [SPT-AKI/Server](https://dev.sp-tarkov.com/SPT-AKI/Server), [SPT-AKI/Modules](https://dev.sp-tarkov.com/SPT-AKI/Modules), and [SPT-AKI/Launcher](https://dev.sp-tarkov.com/SPT-AKI/Launcher). The process is orchestrated using Gitea Actions.

### CI/CD Build Process

This repository initiates the CI/CD build process by performing the following actions:

1. Verification of the existence of the specified tag across the three project repositories.
1. Cloning of the repositories at the specified tagged commits.
1. Compilation and building of each project according to predefined specifications.
1. Aggregation and compression of the build artifacts into a singular release file.
1. Distribution of the release file to designated web-accessible storage locations.
1. Dispatching notifications regarding the release to multiple sources.

## Project Repositories Configuration

Each of the three main repositories (Modules, Server, Launcher) are equipped with a `.gitea/workflows/build-trigger.yaml` file. This workflow file is essential for triggering a build within *this* Build repository upon the push of a tag to any of the project repositories. The `build-trigger.yaml` workflow encompasses the following steps:

1. Cloning of *this* Build repository.
1. Creation and checkout of a dedicated `trigger` branch within *this* Build repository.
1. Committing of a `.gitea/trigger` file into the `trigger` branch, embedding the tag name for traceability.
1. Forceful push of the `trigger` branch back to *this* origin `Build` repository to trigger the build process.

## Module Build Requirements

The build process for the Modules project necessitates access to a secured private repository. A link to this repository is saved as a Gitea environment secret, named `MODULE_DOMAIN`. The build process will fail if this secret is not defined.

## Building the Docker Images

Prior to the assembly and distribution of Docker images, it is crucial to increment the version number to a new, unreleased value. Additionally, authentication with Docker Desktop is required to enable image pushing capabilities.

```
# Command to build and push the spt-build-node Docker image to Docker Hub
docker build -t refringe/spt-build-node:1.0.8 -t refringe/spt-build-node:latest -f Dockerfile.node .
docker push refringe/spt-build-node --all-tags

# Command to build and push the spt-build-dotnet Docker image to Docker Hub
docker build -t refringe/spt-build-dotnet:1.0.1 -t refringe/spt-build-dotnet:latest -f Dockerfile.dotnet .
docker push refringe/spt-build-dotnet --all-tags
```

♥️
