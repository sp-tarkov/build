Param(
    [Parameter(Mandatory = $true)]
    [string] $RELEASE_TAG
)

Write-Output " » Building Launcher"

# Set directories
$DIR_ABS = (Get-Location).Path
$DIR = "$DIR_ABS\Launcher"
$DIR_PROJECT = "$DIR\project"
$DIR_BUILD = "$DIR_PROJECT\build"

# Remove the output folder if it already exists
if (Test-Path -Path $DIR) {
    Write-Output " » Removing Previous Build Directory"
    Remove-Item -Recurse -Force $DIR
}

# Pull down the server project, at the tag, with no history
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

# Create the any necessary subdirectories
New-Item -Path $DIR_BUILD -ItemType Directory -Force

Set-Location $DIR_PROJECT

Write-Output " » Installing .NET Dependencies"
dotnet restore

Write-Output " » Running Build Task"
dotnet build

Write-Output "⚡ Launcher Built ⚡"
