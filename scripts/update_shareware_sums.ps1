Set-StrictMode -Off
$ErrorActionPreference = "Stop"

$root = "$PSScriptRoot\.."

Write-Host "Compressing shareware/windows/overtune3-windows-x64.zip..."
Compress-Archive -Path "$root\shareware\windows\overtune3-windows-x64" -DestinationPath "$root\shareware\windows\overtune3-windows-x64.zip" -Force

if (!(Test-Path "$root\dist")) { New-Item -ItemType Directory -Path "$root\dist" -Force | Out-Null }
if (!(Test-Path "$root\dist\release")) { New-Item -ItemType Directory -Path "$root\dist\release" -Force | Out-Null }

Copy-Item "$root\shareware\windows\overtune3-windows-x64.zip" "$root\dist\overtune3-windows-x64.zip" -Force
Copy-Item "$root\shareware\windows\overtune3-windows-x64.zip" "$root\dist\release\overtune3-windows-x64.zip" -Force

Set-Location "$root\shareware"

$sharewareFiles = @(
    "Installation_Guide.pdf",
    "windows/overtune3-windows-x64.zip",
    "docs/Installation_Guide.pdf",
    "docs/theory_and_math.pdf",
    "docs/tutorials_and_guides.pdf",
    "docs/contributors_and_wiki.pdf"
)

$results = [System.Collections.Generic.List[string]]::new()
foreach ($f in $sharewareFiles) {
    if (Test-Path $f) {
        $hash = (Get-FileHash -Path $f -Algorithm SHA256).Hash.ToLowerInvariant()
        $results.Add(("{0}  {1}" -f $hash, ($f -replace '\\', '/')))
    }
}
$results | Set-Content -Path "SHA256SUMS.txt" -Encoding ascii

# Update dist/release/SHA256SUMS.txt
$relFiles = Get-ChildItem -LiteralPath "$root\dist\release" -File | Where-Object { $_.Name -like '*.exe' -or $_.Name -like '*.zip' }
$relResults = [System.Collections.Generic.List[string]]::new()
foreach ($rf in $relFiles) {
    $hash = (Get-FileHash -Path $rf.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
    $relResults.Add(("{0}  {1}" -f $hash, $rf.Name))
}
$relResults | Set-Content -Path "$root\dist\release\SHA256SUMS.txt" -Encoding ascii

Write-Host "=== Shareware Checksums ==="
Get-Content "$root\shareware\SHA256SUMS.txt"
Write-Host "=== Dist Release Checksums ==="
Get-Content "$root\dist\release\SHA256SUMS.txt"
