# SPT Build

This repo builds and packages SPT releases. It has no app code of its own. It uses GitHub Actions to clone, build, and bundle three other repos into a single download:

- [sp-tarkov/server-csharp](https://github.com/sp-tarkov/server-csharp)
- [sp-tarkov/modules](https://github.com/sp-tarkov/modules)
- [sp-tarkov/launcher](https://github.com/sp-tarkov/launcher)

## How a build works

Builds are tied to a git tag. The same tag has to exist in all three repos, otherwise the build stops. From there the steps are:

1. **Check the tag** - make sure it exists in all three repos.
2. **Clone** - pull each repo at that tag, so the build matches the version being released.
3. **Build** - build each of the three projects.
4. **Bundle** - combine everything into one compressed release package.
5. **Upload** - send the package to the download mirrors.
6. **Announce** - post a notification about the new build.

## Build types

The tag decides what kind of build you get:

| Tag                     | Type                 | What it is                                                               |
| ----------------------- | -------------------- | ------------------------------------------------------------------------ |
| `1.2.3` or `v1.2.3`     | `release`            | Stable, tested build meant for everyone.                                 |
| `1.2.3-BE`              | `bleeding edge`      | Latest changes, less stable. For people testing core changes.            |
| `1.2.3-BEM`             | `bleeding edge mods` | Same as bleeding edge, but with mods enabled. For mod developer testing. |
| anything else           | `debug`              | Lots of logging, not stable. For development and troubleshooting.        |

You can add a label to the end of `-BE` and `-BEM` tags to mark a specific build, e.g. `1.2.3-BE-mylabel`.

## Running a build

Builds are started by hand from the GitHub Actions tab using **workflow_dispatch**. Enter the tag to build in the `buildTag` field. Pick the right workflow for the version:

- `build-4.0.yaml` - SPT 4.0.x
- `build-bento.yaml` - SPT 4.1.x and newer

## Modules secret

The modules build needs a file from a private repo. The link to it is stored in a secret named `MODULE_DOMAIN`. Without that secret the modules can't be downloaded and the build fails.

## Docker image (4.0.x only)

The 4.0.x builds run inside the `refringe/spt-build-dotnet` image, built from `Dockerfile.build-4.0` in this repo.

Before building a new image, bump the version number to something new.

```
# Build and push the spt-build-dotnet image to Docker Hub
docker build -t refringe/spt-build-dotnet:2.2.0 -t refringe/spt-build-dotnet:latest -f Dockerfile.build-4.0 . --platform linux/amd64
docker push refringe/spt-build-dotnet --all-tags
```
