Param(
    [Parameter(Mandatory = $true)]
    [string] $RELEASE_TAG
)

Write-Output " » Building Server"

# Set directorys
$DIR_ABS = (Get-Location).Path
$DIR = "$DIR_ABS\Server"
$DIR_PROJECT = "$DIR\project"
$DIR_BUILD = "$DIR_PROJECT\build"

# Remove the output folder if it already exists
if (Test-Path -Path $DIR) {
    Write-Output " » Removing Previous Build Directory"
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
    $errorMessage = " » FAIL: Error Executing git clone: $_"
    Write-Error $errorMessage
    exit 1 # Fail the build
}

# Create the any necessary subdirectories
New-Item -Path $DIR_BUILD -ItemType Directory -Force

# Ensure we are in the correct directory
Set-Location $DIR

# Pull down the LFS files
git lfs fetch
git lfs pull

# Set the build type based on whether the tag matches the release regex or not.
# A tag in the format of `1.2.3` will be considered a release build, while anything else will be considered debug.
$BUILD_TYPE_REGEX = '^(v?\d+\.\d+\.\d+)$'
if ($RELEASE_TAG -match $BUILD_TYPE_REGEX) {
    $BUILD_TYPE = "release"
}
else {
    $BUILD_TYPE = "debug"
}
Write-Output " » Build Type: $BUILD_TYPE"

Set-Location $DIR_PROJECT

Write-Output " » Installing NPM Dependencies"
try {
    npm install
} catch {
    Write-Error " » npm install failed: $_"
    exit 1
}

Write-Output " » Running Build Task"
try {
    npm run build:$BUILD_TYPE
} catch {
    Write-Error " » npm run build failed: $_"
    exit 1
}

Write-Output "⚡ Server Built ⚡"
