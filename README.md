# SPT Build Project - CI/CD Overview

This guide outlines the Continuous Integration (CI) and Continuous Deployment (CD) setup for the SPT project. It automates and streamlines processes across three key repositories: [sp-tarkov/server](https://github.com/sp-tarkov/server), [sp-tarkov/modules](https://github.com/sp-tarkov/modules), and [sp-tarkov/launcher](https://github.com/sp-tarkov/launcher), utilizing GitHub Actions for efficient operations.

The following sections detail our CI/CD pipeline, highlighting how each update moves from development through to deployment, ensuring consistency and reliability in the build process.

## Understanding the CI/CD Pipeline

The CI/CD pipeline of the SPT project is engineered for tag-based release builds, navigating the complexity of synchronizing three distinct repositories. The pipeline operates through several key stages:

1. **Tag Verification**: Confirms the presence of a specific tag across all three project repositories.
2. **Repository Cloning**: Retrieves the repositories at their respective tagged states, ensuring that the build reflects the exact version intended for release.
3. **Builds**: Build each individual project, ensuring that all builds meet the required standards for integration.
4. **Aggregation**: Consolidates and compresses build artifacts into a single release package, preparing it for distribution.
5. **Distribution**: Uploads the release package to online storage locations, making it available for download.
6. **Notifications**: Sends automated alerts about the new release through multiple channels to inform project maintainers and users of the new build.

## Tagging Strategy and Build Types

The CI/CD pipeline of the SPT project uses specific tagging conventions to trigger different types of builds. This allows for a more nuanced approach to building and deploying code. Below is an explanation of the build types recognized by the workflow and the tagging required for each.

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

## Project Repositories Configuration

Each of the three main repositories (Modules, Server, and Launcher) are equipped with a `.gitea/workflows/build-trigger.yaml` file. This workflow file is essential for triggering a build within *this* Build repository upon the push of a tag to any of the project repositories. The `build-trigger.yaml` workflow pushes a repository-dispatch event.

## Module Build Requirements

The build process for the Modules project necessitates access to a secured private repository. A link to this repository is saved as a Gitea environment secret, named `MODULE_DOMAIN`. The build process will fail if this secret is not defined and the modules can not be downloaded.

## Building the Docker Images

Prior to the assembly and distribution of Docker images, it is crucial to increment the version number to a new, unreleased value. Additionally, authentication with Docker Desktop is required to enable image pushing capabilities.

```
# Command to build and push the spt-build-dotnet Docker image to Docker Hub
docker build -t refringe/spt-build-dotnet:2.0.2 -t refringe/spt-build-dotnet:latest -f Dockerfile.dotnet . --platform linux/amd64
docker push refringe/spt-build-dotnet --all-tags
```
