param(
    [Parameter(Mandatory = $true)][string]$ProjectFile,
    [Parameter(Mandatory = $true)][string]$OutputFile
)

$projectText = [System.IO.File]::ReadAllText((Resolve-Path -LiteralPath $ProjectFile).Path)
$match = [regex]::Match($projectText, '(?m)^project\(FilterDesigner VERSION ([^\s]+) LANGUAGES CXX\)')
if (-not $match.Success) {
    exit 1
}

[System.IO.File]::WriteAllText($OutputFile, $match.Groups[1].Value)
