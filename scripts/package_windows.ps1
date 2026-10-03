$ErrorActionPreference = 'Stop'

$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$projectFile = Join-Path $root 'CMakeLists.txt'
$projectText = [System.IO.File]::ReadAllText($projectFile)
$versionMatch = [regex]::Match($projectText, '(?m)^project\(FilterDesigner VERSION ([^\s]+) LANGUAGES CXX\)')
if (-not $versionMatch.Success) { throw 'Could not read the project version from CMakeLists.txt.' }
$version = $versionMatch.Groups[1].Value

$dist = Join-Path $root 'dist'
$release = Join-Path $dist 'release'
$staging = Join-Path $dist 'staging'
$packageName = 'overtune3-windows-x64'
$stage = Join-Path $staging $packageName
$portable = Join-Path $dist $packageName
$sourceBin = Join-Path $root 'build/windows-release/bin'
$zip = Join-Path $dist "$packageName.zip"
$releaseZip = Join-Path $release "$packageName.zip"

if (-not (Test-Path (Join-Path $sourceBin 'ot3.exe'))) {
    throw 'Release binary not found. Run build.bat before packaging.'
}
if (-not (Test-Path (Join-Path $sourceBin 'Qt6Core.dll'))) {
    throw 'Qt runtime is missing. Run build.bat to deploy the runtime before packaging.'
}

foreach ($path in @($stage, $portable, $release, $zip, (Join-Path $dist 'ot3-installer.exe'), (Join-Path $dist 'run.bat'))) {
    if (Test-Path -LiteralPath $path) { Remove-Item -LiteralPath $path -Recurse -Force }
}
New-Item -ItemType Directory -Path (Join-Path $stage 'bin'), (Join-Path $stage 'assets'), (Join-Path $stage 'docs') -Force | Out-Null

Copy-Item -Path (Join-Path $sourceBin '*') -Destination (Join-Path $stage 'bin') -Recurse -Force
Remove-Item -LiteralPath (Join-Path $stage 'bin/dsp_tests.exe') -Force -ErrorAction SilentlyContinue
if (-not (Test-Path (Join-Path $stage 'bin/FilterDesigner.exe'))) {
    Copy-Item (Join-Path $stage 'bin/ot3.exe') (Join-Path $stage 'bin/FilterDesigner.exe')
}

foreach ($asset in @('logo.png', 'logo.ico', 'banner.png')) {
    $assetPath = Join-Path $root "assets/$asset"
    if (Test-Path $assetPath) { Copy-Item $assetPath (Join-Path $stage 'assets') -Force }
}
foreach ($file in @('README.md')) {
    $filePath = Join-Path $root $file
    if (Test-Path $filePath) { Copy-Item $filePath $stage -Force }
}
foreach ($file in @('ai-integration.md', 'installation_guide.pdf')) {
    $source = if ($file -eq 'ai-integration.md') { Join-Path $root "docs/$file" } else { Join-Path $root "latex/$file" }
    if (Test-Path $source) { Copy-Item $source (Join-Path $stage 'docs') -Force }
}

Copy-Item (Join-Path $PSScriptRoot 'install_windows.ps1') $stage -Force
Set-Content -LiteralPath (Join-Path $stage 'version.txt') -Value $version -Encoding ASCII
@('@echo off', 'start "" "%~dp0bin\ot3.exe" %*') | Set-Content (Join-Path $stage 'run.bat') -Encoding ASCII
Copy-Item (Join-Path $stage 'run.bat') (Join-Path $stage 'ot3.bat') -Force
if (Test-Path (Join-Path $stage 'bin/ot3-installer.exe')) {
    Copy-Item (Join-Path $stage 'bin/ot3-installer.exe') $stage -Force
}

Copy-Item $stage $portable -Recurse -Force
Copy-Item (Join-Path $stage 'ot3-installer.exe') (Join-Path $dist 'ot3-installer.exe') -Force -ErrorAction SilentlyContinue
@('@echo off', 'start "" "%~dp0overtune3-windows-x64\bin\ot3.exe" %*') |
    Set-Content (Join-Path $dist 'run.bat') -Encoding ASCII
Compress-Archive -Path $stage -DestinationPath $zip -CompressionLevel Optimal -Force
New-Item -ItemType Directory -Path $release -Force | Out-Null
Copy-Item $zip $releaseZip -Force

if (Test-Path -LiteralPath $staging) { Remove-Item -LiteralPath $staging -Recurse -Force }

$makensis = Get-Command makensis.exe -ErrorAction SilentlyContinue
if ($makensis) {
    & $makensis.Source "/DAPP_VERSION=$version" (Join-Path $PSScriptRoot 'installer_windows.nsi')
    if ($LASTEXITCODE -ne 0) { throw 'NSIS failed to create the setup executable.' }
    $setup = Join-Path $dist 'Overtune3-Setup-x64.exe'
    if (Test-Path $setup) { Copy-Item $setup $release -Force }
}

$hashes = foreach ($file in Get-ChildItem -LiteralPath $release -File | Where-Object { $_.Extension -in @('.exe', '.zip') } | Sort-Object Name) {
    $stream = [System.IO.File]::OpenRead($file.FullName)
    try {
        $sha = [System.Security.Cryptography.SHA256]::Create()
        try { $hash = -join ($sha.ComputeHash($stream) | ForEach-Object { $_.ToString('x2') }) }
        finally { $sha.Dispose() }
    }
    finally { $stream.Dispose() }
    "$hash  $($file.Name)"
}
[System.IO.File]::WriteAllLines((Join-Path $release 'SHA256SUMS.txt'), [string[]]$hashes, [System.Text.Encoding]::ASCII)

Write-Host "Packaged Overtune $version for Windows x64."
Write-Host "Distribution: $portable"
Write-Host "Archive: $zip"
Write-Host "Release files: $release"
if (-not $makensis) { Write-Host 'NSIS not installed; setup executable skipped. The portable package includes the native installer.' }
