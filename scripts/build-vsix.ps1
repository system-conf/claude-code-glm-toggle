# Build a VSIX package from the extension source.
# Run from the project root: powershell -ExecutionPolicy Bypass -File scripts/build-vsix.ps1

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$build = Join-Path $env:TEMP "glm-toggle-vsix-build"
$vsix = Join-Path $root "glm-toggle-0.1.0.vsix"

# Verify source files exist
foreach ($f in @('package.json', 'extension.js', 'icon.svg')) {
    if (-not (Test-Path (Join-Path $root $f))) {
        Write-Host "ERROR: missing source file: $f" -ForegroundColor Red
        exit 1
    }
}

# Clean and recreate build dir
if (Test-Path $build) { Remove-Item -Recurse -Force $build }
New-Item -ItemType Directory -Path $build | Out-Null
New-Item -ItemType Directory -Path (Join-Path $build "extension") | Out-Null

# Copy extension files
Copy-Item (Join-Path $root "package.json")  (Join-Path $build "extension\package.json")
Copy-Item (Join-Path $root "extension.js")  (Join-Path $build "extension\extension.js")
Copy-Item (Join-Path $root "icon.svg")      (Join-Path $build "extension\icon.svg")
if (Test-Path (Join-Path $root "README.md")) {
    Copy-Item (Join-Path $root "README.md") (Join-Path $build "extension\README.md")
}
if (Test-Path (Join-Path $root "LICENSE")) {
    Copy-Item (Join-Path $root "LICENSE")   (Join-Path $build "extension\LICENSE")
}
if (Test-Path (Join-Path $root "CHANGELOG.md")) {
    Copy-Item (Join-Path $root "CHANGELOG.md") (Join-Path $build "extension\CHANGELOG.md")
}

# Write extension.vsixmanifest
$manifest = @'
<?xml version="1.0" encoding="utf-8"?>
<PackageManifest Version="2.0.0" xmlns="http://schemas.microsoft.com/developer/vsx-schema/2011" xmlns:d="http://schemas.microsoft.com/developer/vsx-schema-design/2011">
  <Metadata>
    <Identity Language="en-US" Id="glm-toggle" Version="0.1.0" Publisher="local" />
    <DisplayName>GLM Toggle</DisplayName>
    <Description xml:space="preserve">Toggle between GLM-5.1 (z.ai) and native Claude for Claude Code</Description>
    <Tags>claude,glm,toggle,ai</Tags>
    <Categories>Other</Categories>
    <GalleryFlags>Public</GalleryFlags>
    <Properties>
      <Property Id="Microsoft.VisualStudio.Code.Engine" Value="^1.70.0" />
      <Property Id="Microsoft.VisualStudio.Code.ExtensionDependencies" Value="" />
      <Property Id="Microsoft.VisualStudio.Code.ExtensionPack" Value="" />
      <Property Id="Microsoft.VisualStudio.Code.ExtensionKind" Value="ui,workspace" />
      <Property Id="Microsoft.VisualStudio.Code.LocalizedLanguages" Value="" />
    </Properties>
  </Metadata>
  <Installation>
    <InstallationTarget Id="Microsoft.VisualStudio.Code" />
  </Installation>
  <Dependencies />
  <Assets>
    <Asset Type="Microsoft.VisualStudio.Code.Manifest" Path="extension/package.json" Addressable="true" />
  </Assets>
</PackageManifest>
'@
[System.IO.File]::WriteAllText((Join-Path $build "extension.vsixmanifest"), $manifest, [System.Text.UTF8Encoding]::new($false))

# Write [Content_Types].xml
$contentTypes = @'
<?xml version="1.0" encoding="utf-8"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="json" ContentType="application/json" />
  <Default Extension="js" ContentType="application/javascript" />
  <Default Extension="svg" ContentType="image/svg+xml" />
  <Default Extension="md" ContentType="text/markdown" />
  <Default Extension="vsixmanifest" ContentType="text/xml" />
</Types>
'@
[System.IO.File]::WriteAllText((Join-Path $build "[Content_Types].xml"), $contentTypes, [System.Text.UTF8Encoding]::new($false))

# Zip then rename — Compress-Archive doesn't accept .vsix as a target extension
if (Test-Path $vsix) { Remove-Item -Force $vsix }
$tmpZip = Join-Path $env:TEMP "glm-toggle-build.zip"
if (Test-Path $tmpZip) { Remove-Item -Force $tmpZip }
Compress-Archive -Path (Join-Path $build "*") -DestinationPath $tmpZip -Force
Move-Item -Force $tmpZip $vsix

Write-Host "[OK] Built: $vsix" -ForegroundColor Green
Write-Host ""
Write-Host "Install with:" -ForegroundColor Cyan
Write-Host "  code --install-extension `"$vsix`" --force" -ForegroundColor Yellow
