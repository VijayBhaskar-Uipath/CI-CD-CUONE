# CI-CD-CUONE

## Packaging and CI

This repository contains a UiPath process. Two helper scripts are provided in the `scripts` folder to support the GitHub Actions workflow:

- `scripts/UiPathPack.ps1` — packages the project into a `.nupkg` using the `project.json` metadata.
- `scripts/UiPathDeploy.ps1` — publishes generated `.nupkg` files to a NuGet feed when `NUGET_FEED_URL` and `NUGET_API_KEY` are provided.

Example (locally):

```powershell
# Create package
.
\scripts\UiPathPack.ps1 .\project.json -destination_folder .\package

# Publish (requires NUGET_FEED_URL and NUGET_API_KEY environment variables)
.
\scripts\UiPathDeploy.ps1 .\package https://orchestrator.example.com TenantName -UserKey <key> -account_name <account>
```

CI note:

The repository includes a GitHub Actions workflow at `.github/workflows/Deploy.yml` that:
- builds the `.nupkg` using `UiPathPack.ps1` on Windows runners
- uploads the package as an artifact
- attempts to call `UiPathDeploy.ps1` during the publish job

Important: the workflow expects a local UiPath CLI binary to exist under `cli/tools/uipcli.exe` in the repository. The pack step calls `UiPathPack.ps1` with `-CliPath` pointing to that executable.

To publish packages in CI, set the following repository secrets or environment variables in your workflow or repository settings:

- `NUGET_FEED_URL` — NuGet feed URL (recommended), e.g. GitHub Packages or Azure Artifacts
- `NUGET_API_KEY` — API key for the NuGet feed

If you prefer publishing directly to UiPath Orchestrator, extend `scripts/UiPathDeploy.ps1` to implement the Orchestrator authentication flow and package upload.
