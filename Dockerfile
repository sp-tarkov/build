## This image is configured just as the drone runner image but expected to be run locally for
## rapid development and testing. It is not intended to be used in production.

# Start with the .NET 6.0 SDK Windows Server Core base image
FROM mcr.microsoft.com/dotnet/sdk:6.0-windowsservercore-ltsc2022

# Use PowerShell
SHELL ["powershell", "-Command"]

# Install Chocolatey package manager
RUN Set-ExecutionPolicy Bypass -Scope Process -Force; \
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; \
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Use Chocolatey to install Node.js and Git
RUN choco install nodejs --version=20.10.0 -y
RUN choco install git -y
RUN choco install 7zip -y

# Set the working directory to /Code
RUN mkdir -p /Code
WORKDIR /Code
