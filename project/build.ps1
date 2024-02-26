## Orchestrate the build process for the SPT project

Write-Output " » Beginning SPT Build Process"

# Check for the required MODULE_DOMAIN environment variable
$MODULE_DOMAIN = $env:MODULE_DOMAIN
$MODULE_DOMAIN_REGEX = '^(https?:\/\/)?([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}(\/)?$'
if ([string]::IsNullOrWhiteSpace($MODULE_DOMAIN) -or -not $MODULE_DOMAIN -match $MODULE_DOMAIN_REGEX -or $MODULE_DOMAIN.EndsWith("/")) {
    Write-Output " » FAIL: The MODULE_DOMAIN environment variable is invalid."
    exit 1 # Fail the build
}

# TODO: Make dynamic, based on the commit information
$RELEASE_TAG = "3.8.0-BE"

# Get the current directory
$DIR_ABS = (Get-Location).Path

# TODO: Validate that the tag exists in all three repositories before continuing the build.
pwsh $DIR_ABS\project\validate_tag.ps1 $RELEASE_TAG

# Build the projects
pwsh $DIR_ABS\project\build_server.ps1 $RELEASE_TAG
pwsh $DIR_ABS\project\build_modules.ps1 $RELEASE_TAG $MODULE_DOMAIN
pwsh $DIR_ABS\project\build_launcher.ps1 $RELEASE_TAG

# Combine the built files into the output directory
pwsh $DIR_ABS\project\combine_builds.ps1
