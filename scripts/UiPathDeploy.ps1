param(
    [Parameter(Mandatory=$true)][string]$PackageFolder,
    [Parameter(Mandatory=$true)][string]$OrchUrl,
    [Parameter(Mandatory=$true)][string]$OrchTenant,
    [Parameter(Mandatory=$false)][string]$UserKey,
    [Parameter(Mandatory=$false)][string]$account_name
)

Write-Output "Publish script starting. Checking for NuGet publish configuration..."

$nugetFeed = $env:NUGET_FEED_URL
$nugetApiKey = $env:NUGET_API_KEY

if ($nugetFeed -and $nugetApiKey) {
    Write-Output "Pushing packages to NuGet feed: $nugetFeed"
    dotnet --info
    Get-ChildItem -Path $PackageFolder -Filter *.nupkg -File | ForEach-Object {
        $pkg = $_.FullName
        Write-Output "Pushing $pkg to $nugetFeed"
        dotnet nuget push $pkg --source $nugetFeed --api-key $nugetApiKey --skip-duplicate
        if ($LASTEXITCODE -ne 0) { Write-Error "dotnet nuget push failed for $pkg"; exit $LASTEXITCODE }
    }
    Write-Output "NuGet push complete."
    exit 0
}

Write-Output "NUGET_FEED_URL and/or NUGET_API_KEY not set."
Write-Output "This script supports publishing to a NuGet feed (recommended)."
Write-Output "To publish to UiPath Orchestrator directly you can either:"
Write-Output " - Provide a NuGet feed (set NUGET_FEED_URL and NUGET_API_KEY as repository secrets), or"
Write-Output " - Extend this script to implement Orchestrator API authentication and package upload (requires client credentials)."

exit 1
