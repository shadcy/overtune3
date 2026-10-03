# compile_docs.ps1 - Compiles all LaTeX PDFs and generates 170 DPI page images
Set-StrictMode -Off
$ErrorActionPreference = "Stop"

$latexDir = $PSScriptRoot
Set-Location $latexDir

$pdflatex = "C:\Users\Asus\miktex\miktex\bin\x64\pdflatex.exe"
$pdftoppm = "C:\Users\Asus\miktex\miktex\bin\x64\pdftoppm.exe"

$docs = @("installation_guide", "theory_and_math", "tutorials_and_guides", "contributors_and_wiki")

foreach ($d in $docs) {
    Write-Host "=== Compiling $d Pass 1 ==="
    & $pdflatex -interaction=nonstopmode "$d.tex" | Out-Null
    Write-Host "=== Compiling $d Pass 2 ==="
    & $pdflatex -interaction=nonstopmode "$d.tex" | Out-Null
    
    Write-Host "=== Rendering PNGs for $d ==="
    Get-ChildItem -Path . -Filter "$($d)_page-*.png" | Remove-Item -Force -ErrorAction SilentlyContinue
    & $pdftoppm -png -r 170 "$d.pdf" "$($d)_page"

    # Normalize single digit padding if any (e.g., page-01 -> page-1)
    Get-ChildItem -Path . -Filter "$($d)_page-*.png" | ForEach-Object {
        if ($_.Name -match "^$($d)_page-0+([0-9]+)\.png$") {
            $newName = "$($d)_page-$($Matches[1]).png"
            Rename-Item -Path $_.FullName -NewName $newName -Force
        }
    }
}

Write-Host "=== Syncing to app/latex ==="
Copy-Item -Path "*.pdf" -Destination "..\app\latex\" -Force
Get-ChildItem -Path "..\app\latex" -Filter "installation_guide_page-*.png" | Remove-Item -Force -ErrorAction SilentlyContinue
Copy-Item -Path "*_page-*.png" -Destination "..\app\latex\" -Force

Write-Host "=== Syncing to shareware ==="
Copy-Item -Path "installation_guide.pdf" -Destination "..\shareware\Installation_Guide.pdf" -Force
Copy-Item -Path "installation_guide.pdf" -Destination "..\shareware\docs\installation_guide.pdf" -Force
Copy-Item -Path "installation_guide.pdf" -Destination "..\shareware\docs\Overtune3_Installation_Guide.pdf" -Force
Copy-Item -Path "installation_guide.tex" -Destination "..\shareware\docs\installation_guide.tex" -Force

Write-Host "=== Syncing to dist/staging ==="
if (Test-Path "..\dist\staging\overtune3-windows-x64") {
    $stagingDocs = "..\dist\staging\overtune3-windows-x64\docs"
    if (!(Test-Path $stagingDocs)) { New-Item -ItemType Directory -Path $stagingDocs -Force | Out-Null }
    Copy-Item -Path "installation_guide.pdf" -Destination "$stagingDocs\Installation_Guide.pdf" -Force
}

Write-Host "=== All documentation compiled and synchronized successfully ==="
