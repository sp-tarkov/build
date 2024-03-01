# Use the .NET 6.0 SDK base image
FROM mcr.microsoft.com/dotnet/sdk:6.0

# Install necessary tools and dependencies (git, git-lfs, nodejs, 7-Zip, zstd)
RUN apt-get update && \
    apt-get install -y git git-lfs nodejs p7zip-full zstd && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set the working directory to /code
WORKDIR /code

# Add a non-root user for running the build
RUN useradd -m builder
USER builder
