# SPT Build Project - CI/CD Overview

This guide outlines the Continuous Integration (CI) and Continuous Deployment (CD) setup for the SPT-AKI project. It automates and streamlines processes across three key repositories: [SPT-AKI/Server](https://dev.sp-tarkov.com/SPT-AKI/Server), [SPT-AKI/Modules](https://dev.sp-tarkov.com/SPT-AKI/Modules), and [SPT-AKI/Launcher](https://dev.sp-tarkov.com/SPT-AKI/Launcher), utilizing Gitea Actions for efficient operations.

**Why Gitea Actions?** Gitea Actions integrates directly with our workflow, automating the compile, build, and deployment phases. This ensures every update is processed accurately and deployed swiftly, minimizing manual effort and error potential.

The following sections detail our CI/CD pipeline, highlighting how each update moves from development through to deployment, ensuring consistency and reliability in the build process.

## Understanding the CI/CD Pipeline

The CI/CD pipeline of the SPT-AKI project is engineered for tag-based release builds, navigating the complexity of synchronizing three distinct repositories. The pipeline operates through several key stages:

1. **Tag Verification**: Confirms the presence of a specific tag across all three project repositories.
2. **Repository Cloning**: Retrieves the repositories at their respective tagged states, ensuring that the build reflects the exact version intended for release.
3. **Builds**: Build each individual project, ensuring that all builds meet the required standards for integration.
4. **Aggregation**: Consolidates and compresses build artifacts into a single release package, preparing it for distribution.
5. **Distribution**: Uploads the release package to online storage locations, making it available for download.
6. **Notifications**: Sends automated alerts about the new release through multiple channels to inform project maintainers and users of the new build.

## Tagging Strategy and Build Types

The CI/CD pipeline of the SPT-AKI project uses specific tagging conventions to trigger different types of builds. This allows for a more nuanced approach to building and deploying code. Below is an explanation of the build types recognized by the workflow and the tagging required for each.

### Release Builds
- **Tagging Convention**: Semantic versioning (e.g., `v1.2.3` or `1.2.3`).
- **Description**: `release` builds are stable versions intended for distribution. They are tested, have limited support, and contain less debugging printed to the server console.
- **Use Case**: Suitable for production releases, signifying major updates or critical fixes.

### Bleeding Builds
- **Tagging Convention**: Semantic versioning followed by a `-BE`. (e.g., `1.2.3-BE`). These can also incldue a string after the `-BE` to signify a specific build identifier (e.g., `1.2.3-BE-Identifier`)
- **Description**: `bleeding` builds are cutting-edge versions that may include experimental updates. They're less stable than `release` builds but offer a glimpse into the latest developments.
- **Use Case**: For developers and testers looking for the latest features and willing to accept instability.

### BleedingMods Builds
- **Tagging Convention**: Follows the same format as `bleeding` builds, except the tag is `-BEM` (e.g., `1.2.3-BEM` or `1.2.3-BEM-Identifier`).
- **Description**: Similar to `bleeding` but with modifications enabled, `bleedingmods` builds include the latest changes so that mod developers can test and experiment with their mods.
- **Use Case**: Targeted at mod developers and users interested in testing the cutting edge of mod development.

### Debug Builds
- **Tagging Convention**: Any tag that does not match the above conventions.
- **Description**: `debug` builds are intended for internal use, featuring extensive logging and debugging information. Stability is not even an afterthought.
- **Use Case**: Development and troubleshooting, where detailed logs and error messages are essential for fixing bugs.

### Nightly Builds
- **Tagging Convention**: Scheduled triggers, not tag-based.
- **Description**: `nightly` builds are created automatically based on a schedule, usually daily. These builds reflect the most current development progress and are useful for continuous testing. Not stable. Not supported.
- **Use Case**: Ongoing testing and early detection of bugs or integration issues in the development phase.

## Project Repositories Configuration

Each of the three main repositories (Modules, Server, Launcher) are equipped with a `.gitea/workflows/build-trigger.yaml` file. This workflow file is essential for triggering a build within *this* Build repository upon the push of a tag to any of the project repositories. The `build-trigger.yaml` workflow encompasses the following steps:

1. Cloning of *this* Build repository.
1. Creation and checkout of a dedicated `trigger` branch within *this* Build repository.
1. Committing a `.gitea/trigger` file into the `trigger` branch, embedding the tag name used to start the build process.
1. Forceful push of the `trigger` branch back to *this* origin `Build` repository to trigger the build process.

## Module Build Requirements

The build process for the Modules project necessitates access to a secured private repository. A link to this repository is saved as a Gitea environment secret, named `MODULE_DOMAIN`. The build process will fail if this secret is not defined and the modules can not be downloaded.

## Building the Docker Images

Prior to the assembly and distribution of Docker images, it is crucial to increment the version number to a new, unreleased value. Additionally, authentication with Docker Desktop is required to enable image pushing capabilities.

```
# Command to build and push the spt-build-node Docker image to Docker Hub
docker build -t refringe/spt-build-node:1.1.1 -t refringe/spt-build-node:latest -f Dockerfile.node .
docker push refringe/spt-build-node --all-tags

# Command to build and push the spt-build-dotnet Docker image to Docker Hub
docker build -t refringe/spt-build-dotnet:1.0.1 -t refringe/spt-build-dotnet:latest -f Dockerfile.dotnet .
docker push refringe/spt-build-dotnet --all-tags
```
