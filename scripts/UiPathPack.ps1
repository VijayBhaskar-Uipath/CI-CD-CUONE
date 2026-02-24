param(
    [Parameter(Mandatory=$true)][string]$ProjectJsonPath,
    [Parameter(Mandatory=$true)][string]$destination_folder,
    [Parameter(Mandatory=$false)][string]$CliPackageName = 'UiPath.CLI.Windows',
    [Parameter(Mandatory=$false)][string]$CliPackageVersion = '24.12.9166.24491',
    [Parameter(Mandatory=$false)][string]$CliPackageSource = '',
    [Parameter(Mandatory=$false)][string]$CliPath = '',
    [Parameter(Mandatory=$false)][switch]$ForceInstallCli
)

param(
    [Parameter(Mandatory=$true)][string]$ProjectJsonPath,
    [Parameter(Mandatory=$true)][string]$destination_folder,
    [Parameter(Mandatory=$true)][string]$CliPath
)

function Log { param([string]$m) Write-Output "[UiPathPack] $m" }

Log "Starting pack (local CLI required)"

if (-not (Test-Path $ProjectJsonPath)) { Log "project.json not found at $ProjectJsonPath"; exit 2 }
if (-not (Test-Path $CliPath)) { Log "CliPath not found: $CliPath"; exit 3 }

try { $proj = Get-Content -Raw -Path $ProjectJsonPath | ConvertFrom-Json } catch { Log "Failed to parse project.json: $_"; exit 2 }

$name = $proj.name; $version = $proj.projectVersion
if (-not $name -or -not $version) { Log "Missing name or projectVersion in project.json"; exit 2 }

$packageName = "${name}.${version}.nupkg"
$projectRoot = Split-Path -Parent $ProjectJsonPath

Log "Project: $name v$version"

if (-not (Test-Path -Path $destination_folder)) { New-Item -ItemType Directory -Path $destination_folder -Force | Out-Null }

$tempDir = Join-Path $env:TEMP ("uipack_" + [guid]::NewGuid().ToString())
New-Item -ItemType Directory -Path $tempDir | Out-Null
Log "Copying project to temp: $tempDir"

# Simple copy, excluding common metadata
$exclude = @('.git','.github','package')
Get-ChildItem -Path $projectRoot -Force | Where-Object { $_.Name -notin $exclude } | ForEach-Object {
    $dest = Join-Path $tempDir $_.Name
    Copy-Item -Path $_.FullName -Destination $dest -Recurse -Force
}

Log "Running CLI: $CliPath package pack \"$ProjectJsonPath\" -o \"$destination_folder\" -v $version"
& $CliPath package pack "$ProjectJsonPath" -o "$destination_folder" -v $version
if ($LASTEXITCODE -ne 0) { Log "CLI pack failed with exit code $LASTEXITCODE"; Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue; exit $LASTEXITCODE }

Log "Pack completed; cleaning temp"
Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
Log "Done"
exit 0
        throw 'robocopy-not-found'
