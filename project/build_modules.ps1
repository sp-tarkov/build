Param(
    [Parameter(Mandatory = $true)]
    [string] $RELEASE_TAG,

    [Parameter(Mandatory = $true)]
    [string] $MODULE_DOMAIN
)

Write-Output " » Building Modules"

# Set directorys
$DIR_ABS = (Get-Location).Path
$DIR = "$DIR_ABS\Modules"
$DIR_PROJECT = "$DIR\project"
$DIR_BUILD = "$DIR_PROJECT\build"
$DIR_MANAGED = "$DIR_PROJECT\Shared\Managed"

# Remove the output folder if it already exists
if (Test-Path -Path $DIR) {
    Write-Output " » Removing Previous Build Directory"
    Remove-Item -Recurse -Force $DIR
}

# Pull down the server project, at the tag, with no history
Write-Output " » Cloning Modules Project"
$REPO = "https://dev.sp-tarkov.com/SPT-AKI/Modules.git"
try {
    $processInfo = New-Object System.Diagnostics.ProcessStartInfo
    $processInfo.FileName = "git"
    $processInfo.Arguments = "clone $REPO --branch $RELEASE_TAG --depth 1 `"$DIR`""
    $processInfo.RedirectStandardError = $true
    $processInfo.RedirectStandardOutput = $true
    $processInfo.UseShellExecute = $false
    $processInfo.CreateNoWindow = $true

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $processInfo
    $process.Start() | Out-Null
    $process.WaitForExit()

    $stdout = $process.StandardOutput.ReadToEnd()
    $stderr = $process.StandardError.ReadToEnd()

    Write-Output $stdout
    if ($process.ExitCode -ne 0) {
        throw "git clone command failed with exit code $($process.ExitCode). Output: $stderr"
    }
}
catch {
    $errorMessage = " » FAIL: Error Executing git clone: $_"
    Write-Error $errorMessage
    exit 1 # Fail the build
}

# Create the any necessary subdirectories
New-Item -Path $DIR_BUILD -ItemType Directory -Force
New-Item -Path $DIR_MANAGED -ItemType Directory -Force

Set-Location $DIR

Write-Output " » Fetching Required Client Version"
$coreJsonPath = "$DIR_ABS\Server\project\build\Aki_Data\Server\configs\core.json"
if (-not (Test-Path -Path $coreJsonPath) -or (Get-Item -Path $coreJsonPath).Length -eq 0) {
    Write-Output " » FAIL: core.json does not exist or is empty."
    exit 1 # Fail the build
}
try {
    # Attempt to read and parse the core.json file
    $RELEASE_METADATA_RAW = Get-Content -Path $coreJsonPath -ErrorAction Stop
    $RELEASE_METADATA = $RELEASE_METADATA_RAW | ConvertFrom-Json -ErrorAction Stop
    $CLIENT_VERSION = $RELEASE_METADATA.compatibleTarkovVersion.Split('.') | Select-Object -Last 1

    # Check if the $CLIENT_VERSION is valid
    if ([string]::IsNullOrWhiteSpace($CLIENT_VERSION)) {
        throw "Invalid or missing 'compatibleTarkovVersion' in core.json."
    }
}
catch {
    Write-Error " » FAIL: Error fetching or parsing core.json: $_"
    exit 1 # Fail the build
}
Write-Output " » Client Version: $CLIENT_VERSION fetched successfully."

# Download the module files
Write-Output " » Downloading Client Modules"
$DOWNLOAD_PATH = "$DIR_MANAGED\$CLIENT_VERSION.zip"
$DOWNLOAD_URL = "$MODULE_DOMAIN/$CLIENT_VERSION.zip"
try {
    Invoke-WebRequest -Uri $DOWNLOAD_URL -OutFile $DOWNLOAD_PATH -UseBasicParsing -ErrorAction Stop
    if (-not (Test-Path -Path $DOWNLOAD_PATH) -or (Get-Item -Path $DOWNLOAD_PATH).Length -eq 0) {
        throw "The module download does not exist or is empty."
    }
}
catch {
    Write-Error " » FAIL: Unable to download the module. Error: $_"
    exit 1 # Fail the build
}
Write-Output " » Download successful: $DOWNLOAD_PATH"

Write-Output " » Extracting Client Modules"
try {
    Expand-Archive -Path $DOWNLOAD_PATH -DestinationPath $DIR_MANAGED -Force -ErrorAction Stop
    Write-Output " » Client Modules extracted to $DIR_MANAGED"
}
catch {
    Write-Error " » FAIL: Error extracting client modules: $_"
    exit 1 # Fail the build
}

# Delete the modules archive now that it's been uncompressed
try {
    Remove-Item -Path $DOWNLOAD_PATH -Force -ErrorAction Stop
    Write-Output " » Client Modules Archive Deleted"
}
catch {
    Write-Warning " » Failed to delete ZIP file: $_"
    exit 1 # Fail the build
}

Set-Location $DIR_PROJECT

Write-Output " » Installing .NET Dependencies"
try {
    $restoreResult = dotnet restore
    if ($LASTEXITCODE -ne 0) {
        throw "dotnet restore failed with exit code $LASTEXITCODE"
    }
    Write-Output $restoreResult
}
catch {
    Write-Error " » FAIL: Error executing dotnet restore: $_"
    exit 1 # Fail the build
}

Write-Output " » Running Build Task"
try {
    $buildResult = dotnet build
    if ($LASTEXITCODE -ne 0) {
        throw "dotnet build failed with exit code $LASTEXITCODE"
    }
    Write-Output $buildResult
}
catch {
    Write-Error " » FAIL: Error executing dotnet build: $_"
    exit 1 # Fail the build
}

Write-Output "⚡ Modules Built ⚡"
