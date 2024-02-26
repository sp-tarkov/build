## Take the built project files and combines them into a release folder.

Write-Output " » Combining Project Build Files"

# Set directories
$DIR_ABS = (Get-Location).Path
$DIR_OUTPUT = "$DIR_ABS\release\"
$ProjectPaths = @(
    "$DIR_ABS\builds\Server\project\build\",
    "$DIR_ABS\builds\Modules\project\build\",
    "$DIR_ABS\builds\Launcher\project\Build\"
)

# Remove the release directory if it already exists
if (Test-Path -Path $DIR_OUTPUT) {
    Write-Output " » Removing Previous release Directory"
    Remove-Item -Recurse -Force $DIR_OUTPUT
}

# Create new directory
New-Item -Path $DIR_OUTPUT -ItemType Directory -Force

# Function to copy project build files
function Copy-ProjectFiles {
    param (
        [string]$sourceDir
    )
    Get-ChildItem -Path $sourceDir -Recurse | ForEach-Object {
        $relativePath = $_.FullName.Substring($sourceDir.Length)
        $targetPath = Join-Path -Path $DIR_OUTPUT -ChildPath $relativePath

        if (-not $_.PSIsContainer) {
            $targetDir = Split-Path -Path $targetPath -Parent
            if (-not (Test-Path -Path $targetDir)) {
                New-Item -Path $targetDir -ItemType Directory -Force | Out-Null
            }
            if ($_.FullName -ne $targetPath) {
                Copy-Item -Path $_.FullName -Destination $targetPath -Force
            }
        }
    }
}

try {
    foreach ($path in $ProjectPaths) {
        Copy-ProjectFiles -sourceDir $path
    }
} catch {
    Write-Error "An error occurred: $_"
}

# Missing
#BepInEx\core\
#BepInEx\config\
#doorstop_config.ini
#winhttp.dll
#LICENCE-BEPINEX.txt
#LICENCE-ConfigurationManager.txt