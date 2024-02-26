# Build the Launcher project.

Param(
    [Parameter(Mandatory = $true)]
    [string] $RELEASE_TAG
)

Write-Output " » Building Launcher Project"

# Set directories
$DIR_ABS = (Get-Location).Path
$DIR = "$DIR_ABS\builds\Launcher"
$DIR_PROJECT = "$DIR\project"

# Remove the build directory if it already exists
if (Test-Path -Path $DIR) {
    Write-Output " » Removing Previous Launcher Project Build Directory"
    Remove-Item -Recurse -Force $DIR
}

# Pull down the launcher project, at the tag, with no history
Write-Output " » Cloning Launcher Project"
$REPO = "https://dev.sp-tarkov.com/SPT-AKI/Launcher.git"
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

# Create any necessary sub-directories
New-Item -Path $DIR_PROJECT -ItemType Directory -Force

Set-Location $DIR_PROJECT

try {
    $BUILD_RESULT = dotnet build --configuration release -m:1 *>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Output "Build output: $BUILD_RESULT"
        throw "dotnet build failed with exit code $LASTEXITCODE"
    }
    Write-Output $BUILD_RESULT
}
catch {
    Write-Error " » FAIL: Error executing dotnet build: $_"
    exit 1 # Fail the build
}

Write-Output "⚡ Launcher Project Built ⚡"
