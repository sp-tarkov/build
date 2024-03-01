# Use the .NET 6.0 SDK base image
FROM mcr.microsoft.com/dotnet/sdk:6.0

# Install necessary tools and dependencies
# - wget (for downloading NVM)
# - git & git-lfs
RUN apt-get update && \
    apt-get install -y wget git git-lfs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install NVM and use Node v20.10.0 by default
ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION v20.10.0
RUN mkdir -p $NVM_DIR && \
    wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash && \
    . $NVM_DIR/nvm.sh && \
    nvm install $NODE_VERSION && \
    nvm use $NODE_VERSION && \
    nvm alias default $NODE_VERSION

# Ensure node and npm are available in the PATH
ENV PATH $NVM_DIR/versions/node/$(nvm version)/bin:$PATH

# Set the working directory to /code
WORKDIR /code

# Add a non-root user for running the build
RUN useradd -m builder
USER builder
