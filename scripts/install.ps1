#Requires -Version 5.1
<#
.SYNOPSIS
  Install Cursor Constitution into a project (interactive or with parameters).

.PARAMETER Source
  Path to the Cursor-Constitution clone. Default: parent folder of this script.

.PARAMETER Target
  Project folder to install into. Default: current directory (if safe), else asked.

.PARAMETER Locale
  Language pack: en or ru. If omitted, an interactive selector is shown.
#>
param(
    [string] $Source = '',
    [string] $Target = '',
    [string] $Locale = ''
)

$ErrorActionPreference = 'Stop'

function Test-IsConsole {
    try {
        return [Console]::IsInputRedirected -eq $false -and $Host.Name -match 'Console|Terminal|Visual Studio'
    } catch {
        return $false
    }
}

function Select-LocaleInteractive {
    $items = @(
        @{ Id = 'ru'; Label = 'ru  - Russian (docs + project-memory)' },
        @{ Id = 'en'; Label = 'en  - English (docs + project-memory)' }
    )
    $idx = 0
    $typed = ''

    if (-not (Test-IsConsole)) {
        Write-Host 'Select language: ru | en'
        while ($true) {
            $raw = (Read-Host 'Locale').Trim().ToLowerInvariant()
            if ($raw -in @('ru', 'en')) { return $raw }
            if ($raw -eq '1') { return 'ru' }
            if ($raw -eq '2') { return 'en' }
            Write-Host 'Please enter ru or en'
        }
    }

    Write-Host ''
    Write-Host 'Select language'
    Write-Host '  Up/Down + Enter  - move and confirm'
    Write-Host '  Or type ru / en and press Enter'
    Write-Host ''

    $draw = {
        for ($n = 0; $n -lt $items.Count; $n++) {
            $prefix = if ($n -eq $idx) { '> ' } else { '  ' }
            $line = "$prefix$($items[$n].Label)"
            if ($n -eq $idx) {
                Write-Host $line -ForegroundColor Cyan
            } else {
                Write-Host $line
            }
        }
        if ($typed.Length -gt 0) {
            Write-Host ("  typed: {0}_" -f $typed) -ForegroundColor DarkGray
        } else {
            Write-Host '  typed: (optional)_' -ForegroundColor DarkGray
        }
    }

    & $draw

    while ($true) {
        $key = [Console]::ReadKey($true)

        if ($key.Key -eq 'UpArrow') {
            $idx = ($idx - 1 + $items.Count) % $items.Count
            $typed = ''
        } elseif ($key.Key -eq 'DownArrow') {
            $idx = ($idx + 1) % $items.Count
            $typed = ''
        } elseif ($key.Key -eq 'Enter') {
            if ($typed -in @('ru', 'en')) { return $typed }
            if ($typed -eq '1') { return 'ru' }
            if ($typed -eq '2') { return 'en' }
            if ($typed.Length -eq 0) { return $items[$idx].Id }
            Write-Host ''
            Write-Host ("Unknown: {0} - use ru or en" -f $typed) -ForegroundColor Yellow
            $typed = ''
        } elseif ($key.Key -eq 'Backspace') {
            if ($typed.Length -gt 0) {
                $typed = $typed.Substring(0, $typed.Length - 1)
            }
        } elseif ($key.Key -eq 'Escape') {
            throw 'Install cancelled.'
        } elseif ($key.KeyChar -match '[a-zA-Z0-9]') {
            $typed += $key.KeyChar.ToString().ToLowerInvariant()
            if ($typed -in @('ru', 'en')) {
                # highlight matching row
                for ($n = 0; $n -lt $items.Count; $n++) {
                    if ($items[$n].Id -eq $typed) { $idx = $n; break }
                }
            }
        } else {
            continue
        }

        # redraw in place
        $lines = $items.Count + 1
        [Console]::SetCursorPosition(0, [Console]::CursorTop - $lines)
        & $draw
    }
}

# --- resolve Constitution source (this repo) ---
$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$defaultSource = (Resolve-Path (Join-Path $scriptDir '..')).Path

if ([string]::IsNullOrWhiteSpace($Source)) {
    $Source = $defaultSource
}

$src = (Resolve-Path $Source).Path
if (-not (Test-Path (Join-Path $src 'template\.cursor\rules'))) {
    throw "Not a Cursor-Constitution repo: $src"
}

# --- resolve target project ---
$cwd = (Get-Location).Path
$unsafeTargets = @($scriptDir, $src, (Join-Path $src 'scripts'), (Join-Path $src 'template'))

if ([string]::IsNullOrWhiteSpace($Target)) {
    if ($unsafeTargets -contains $cwd) {
        Write-Host ''
        Write-Host "Constitution source: $src"
        Write-Host 'Where should rules be installed? (path to YOUR project root)'
        $Target = (Read-Host 'Target project').Trim().Trim('"')
        if ([string]::IsNullOrWhiteSpace($Target)) {
            throw 'Target project path is required.'
        }
    } else {
        $Target = $cwd
        Write-Host "Install target (current folder): $Target"
        $confirm = Read-Host 'OK? [Y/n]'
        if ($confirm -match '^[Nn]') {
            $Target = (Read-Host 'Target project').Trim().Trim('"')
            if ([string]::IsNullOrWhiteSpace($Target)) {
                throw 'Target project path is required.'
            }
        }
    }
}

$Target = (Resolve-Path (New-Item -ItemType Directory -Force -Path $Target)).Path

# --- locale ---
if ([string]::IsNullOrWhiteSpace($Locale)) {
    $Locale = Select-LocaleInteractive
}

Write-Host ''
Write-Host "Language pack: $Locale"
Write-Host "Source:        $src"
Write-Host "Target:        $Target"
Write-Host ''

$rulesSrc = Join-Path $src 'template\.cursor\rules'
$docsSrc = Join-Path $src "docs\$Locale"
$memorySrc = Join-Path $docsSrc 'project-memory'

foreach ($p in @($rulesSrc, $docsSrc, $memorySrc)) {
    if (-not (Test-Path $p)) {
        throw "Missing required path: $p"
    }
}

Push-Location $Target
try {
    New-Item -ItemType Directory -Force -Path '.cursor\rules', 'docs', '.cursor\project-memory' | Out-Null

    Copy-Item -Recurse -Force (Join-Path $rulesSrc '*') '.cursor\rules\'

    Get-ChildItem $docsSrc -Force | Where-Object { $_.Name -ne 'project-memory' } | ForEach-Object {
        $dest = Join-Path 'docs' $_.Name
        if ($_.PSIsContainer) {
            Copy-Item -Recurse -Force $_.FullName $dest
        } else {
            Copy-Item -Force $_.FullName $dest
        }
    }

    Copy-Item -Recurse -Force (Join-Path $memorySrc '*') '.cursor\project-memory\'

    $comm = if ($Locale -eq 'ru') { 'Russian' } else { 'English' }
    $stackPath = '.cursor\rules\project\stack.mdc'
    if (-not (Test-Path $stackPath)) {
        throw "stack.mdc missing after copy: $stackPath"
    }

    $stack = Get-Content -Raw -Path $stackPath
    $stack = $stack -replace '(?m)^(- \*\*Communication language:\*\*).*$', "`$1 $comm"
    $stack = $stack -replace '(?m)^(- \*\*Docs locale:\*\*).*$', "`$1 $Locale (content unpacked into docs/)"
    $stack = $stack -replace '(?m)^(- \*\*UI / product copy:\*\*).*$', "`$1 same as communication (change in onboarding if needed)"
    $stack = $stack -replace '(?m)^(- Docs root:).*$', "`$1 docs"
    Set-Content -Path $stackPath -Value $stack -NoNewline

    Write-Host 'Installed.'
    Write-Host '  Rules:           .cursor/rules/          (English)'
    Write-Host ("  Docs:            docs/                   (from docs/{0} pack)" -f $Locale)
    Write-Host ("  Project memory:  .cursor/project-memory/ ({0})" -f $comm)
    Write-Host ("  stack.mdc:       Communication language={0}, Docs locale={1}, Docs root=docs" -f $comm, $Locale)
    Write-Host ''
    Write-Host 'Next: open the project in Cursor and run onboarding from .cursor/rules/onboarding.mdc'
} finally {
    Pop-Location
}
