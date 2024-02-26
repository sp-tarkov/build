# Build the Server project.

Param(
    [Parameter(Mandatory = $true)]
    [string] $RELEASE_TAG
)

Write-Output " » Building Server Project"

# Set directories
$DIR_ABS = (Get-Location).Path
$DIR = "$DIR_ABS\builds\Server"
$DIR_PROJECT = "$DIR\project"
$DIR_BUILD = "$DIR_PROJECT\build"

# Remove the build directory if it already exists
if (Test-Path -Path $DIR) {
    Write-Output " » Removing Previous Server Project Build Directory"
    Remove-Item -Recurse -Force $DIR
}

# Pull down the server project, at the tag, with no history
Write-Output " » Cloning Server Project"
$REPO = "https://dev.sp-tarkov.com/SPT-AKI/Server.git"
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
    $errorMessage = " » FAIL: Error executing git clone: $_"
    Write-Error $errorMessage
    exit 1 # Fail the build
}

# Create any necessary sub-directories
New-Item -Path $DIR_BUILD -ItemType Directory -Force

# Ensure we are in the correct directory
Set-Location $DIR

# Pull down the LFS files
git lfs fetch
git lfs pull

# Determine the build type based on the tag.
# The 'release' pattern matches tags like '1.2.3' or 'v1.2.3'.
# The 'bleeding' pattern matches tags like '1.2.3-BE' or 'v1.2.3-BE', case-insensitively.
# The 'debug' pattern will be used for any tag not matching these patterns.
$RELEASE_BUILD_REGEX = '^(v?\d+\.\d+\.\d+)$'
$BLEEDING_BUILD_REGEX = '^(v?\d+\.\d+\.\d+-BE)$'
if ($RELEASE_TAG -match $RELEASE_BUILD_REGEX) {
    $BUILD_TYPE = "release"
}
elseif ($RELEASE_TAG -match $BLEEDING_BUILD_REGEX) {
    $BUILD_TYPE = "bleeding"
}
else {
    $BUILD_TYPE = "debug"
}
Write-Output " » Build Type: $BUILD_TYPE"

Set-Location $DIR_PROJECT

Write-Output " » Installing Server Project Dependencies"
try {
    npm install
} catch {
    Write-Error " » npm install failed: $_"
    exit 1
}

Write-Output " » Running Server Project Build Task"
try {
    npm run build:$BUILD_TYPE
} catch {
    Write-Error " » npm run build failed: $_"
    exit 1
}

Write-Output "⚡ Server Project Built ⚡"
