param(
    [string]$ProjectRoot
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($ProjectRoot)) {
    $ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
} else {
    $ProjectRoot = (Resolve-Path $ProjectRoot).Path
}

$distPath = Join-Path $ProjectRoot 'dist'

if (Test-Path $distPath) {
    Remove-Item -Path $distPath -Recurse -Force
}

New-Item -Path $distPath -ItemType Directory | Out-Null

$publishBlacklist = @(
    # Build/output and source asset work directories
    'dist',
    'temp',
    'tools',
    'animSource',
    'imageSource',
    'soundSource',
    'out',
    '.VSCodeCounter',

    # VCS/editor metadata
    '.git',
    '.github',
    '.vscode',
    '.vs',
    '.idea',

    # Root-level files not needed in release package
    '.gitignore',
    '.gitattributes',
    '*.code-workspace'
)

function Test-IsPublishBlacklisted {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    foreach ($pattern in $publishBlacklist) {
        if ($Name -like $pattern) {
            return $true
        }
    }

    return $false
}

function Copy-ReleasePath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RelativePath
    )

    $sourcePath = Join-Path $ProjectRoot $RelativePath
    if (-not (Test-Path $sourcePath)) {
        Write-Host "[skip] $RelativePath (not found)"
        return
    }

    $targetPath = Join-Path $distPath $RelativePath
    $targetParent = Split-Path -Parent $targetPath
    if ($targetParent -and -not (Test-Path $targetParent)) {
        New-Item -Path $targetParent -ItemType Directory -Force | Out-Null
    }

    Copy-Item -Path $sourcePath -Destination $targetPath -Recurse -Force
    Write-Host "[ok]   $RelativePath"
}

foreach ($entry in Get-ChildItem -Path $ProjectRoot -Force) {
    if (Test-IsPublishBlacklisted -Name $entry.Name) {
        Write-Host "[skip] $($entry.Name) (blacklisted)"
        continue
    }

    Copy-ReleasePath -RelativePath $entry.Name
}

function Set-ProductionModDependencies {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ModInfoPath
    )

    if (-not (Test-Path $ModInfoPath)) {
        throw "modinfo.lua not found: $ModInfoPath"
    }

    $modInfoRaw = Get-Content -Path $ModInfoPath -Raw

    $productionDependencies = @"
mod_dependencies = {
    { workshop = "workshop-3677284770"},
    -- {["DST-ArknightsItemPackage"] = false},
}
"@

    $pattern = '(?ms)^mod_dependencies\s*=\s*\{.*?^\}'
    if (-not [regex]::IsMatch($modInfoRaw, $pattern)) {
        throw "Failed to locate mod_dependencies block in $ModInfoPath"
    }

    $updated = [regex]::Replace($modInfoRaw, $pattern, $productionDependencies)

    Set-Content -Path $ModInfoPath -Value $updated -NoNewline
    Write-Host "[ok]   force production mod_dependencies in dist/modinfo.lua"
}

$distModInfoPath = Join-Path $distPath 'modinfo.lua'
Set-ProductionModDependencies -ModInfoPath $distModInfoPath

Write-Host "`n发布目录已生成: $distPath"
