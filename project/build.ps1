Write-Output " » Beginning SPT Build Process"

# Check for required environment variables
if ([string]::IsNullOrWhiteSpace($env:MODULE_DOMAIN)) {
    Write-Output " » FAIL: The MODULE_DOMAIN environment variable can not be empty."
    exit 1 # Fail the build
}
$MODULE_DOMAIN = $env:MODULE_DOMAIN

# TODO: This is dynamic, based on the incoming commit information.
$RELEASE_TAG = "3.8.0-BE"

# TODO: Validate that the tag exists in all three repositories before continuing the build.

#$BEPINEX_RELEASE = "https://github.com/BepInEx/BepInEx/releases/download/v5.4.21/BepInEx_x64_5.4.21.0.zip"

$OUTPUT_DIR = ".\output"

if (Test-Path -Path $OUTPUT_DIR) {
    Write-Output " » Removing Previous Output Directory"
    Remove-Item -Recurse -Force $OUTPUT_DIR
}

# Build the projects
pwsh .\project\build_server.ps1 $RELEASE_TAG
pwsh .\project\build_modules.ps1 $RELEASE_TAG $MODULE_DOMAIN
pwsh .\project\build_launcher.ps1 $RELEASE_TAG
