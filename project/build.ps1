## Orchestrate the build process for the SPT project

# Get the current directory
$DIR_ABS = (Get-Location).Path

# One art, please...
pwsh $DIR_ABS\project\header.ps1

# Function that pretends the date/time to the start of a log
function Write-Log {
    Param(
        [string]$Message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Output "[$timestamp] $Message"
}

Write-Log "✅ Beginning SPT Build Process"
Write-Output ""

# Check for the required MODULE_DOMAIN environment variable
$MODULE_DOMAIN = $env:MODULE_DOMAIN
$MODULE_DOMAIN_REGEX = '^(https?:\/\/)?([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}(\/)?$'
if ([string]::IsNullOrWhiteSpace($MODULE_DOMAIN) -or -not $MODULE_DOMAIN -match $MODULE_DOMAIN_REGEX -or $MODULE_DOMAIN.EndsWith("/")) {
    Write-Log " ❌ FAIL: The MODULE_DOMAIN environment variable is invalid."
    exit 1 # Fail the build
}

# TODO: Make dynamic, based on the commit information
$RELEASE_TAG = "3.8.0-BE"

# Validate that the tag exists in all three repositories before continuing the build.
$VALIDATE = Start-Process pwsh -ArgumentList "-File `"$DIR_ABS\project\tag_validate.ps1`" $RELEASE_TAG" -Wait -PassThru -NoNewWindow
if ($VALIDATE.ExitCode -ne 0) {
    exit $VALIDATE.ExitCode
}

# Build the Server project
$SERVER = Start-Process pwsh -ArgumentList "-File `"$DIR_ABS\project\build_server.ps1`" $RELEASE_TAG" -Wait -PassThru -NoNewWindow
if ($SERVER.ExitCode -ne 0) {
    exit $SERVER.ExitCode
}

# Build the Modules project
$MODULES = Start-Process pwsh -ArgumentList "-File `"$DIR_ABS\project\build_modules.ps1`" $RELEASE_TAG $MODULE_DOMAIN" -Wait -PassThru -NoNewWindow
if ($MODULES.ExitCode -ne 0) {
	exit $MODULES.ExitCode
}

# Build the Launcher project
$LAUNCHER = Start-Process pwsh -ArgumentList "-File `"$DIR_ABS\project\build_launcher.ps1`" $RELEASE_TAG" -Wait -PassThru -NoNewWindow
if ($LAUNCHER.ExitCode -ne 0) {
    exit $LAUNCHER.ExitCode
}

# Combine built and static files into the release directory
$COMBINE = Start-Process pwsh -ArgumentList "-File `"$DIR_ABS\project\combine.ps1`"" -Wait -PassThru -NoNewWindow
if ($COMBINE.ExitCode -ne 0) {
    exit $COMBINE.ExitCode
}

Write-Log "⚡ SPT Build Complete ⚡"
Write-Output ""
exit 0