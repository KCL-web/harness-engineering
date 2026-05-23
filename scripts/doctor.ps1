#Requires -Version 5.1
<#
.SYNOPSIS
    Valida o ambiente local do harness-engineering.
.DESCRIPTION
    Checa dependências, junction de skills e config de MCP.
    Mostra comando de instalação para cada item faltante.
#>

$ErrorActionPreference = 'SilentlyContinue'
$anyMissing = $false

function Check-Cmd {
    param([string]$Name, [string]$Cmd, [string]$Install)
    if (Get-Command $Cmd -ErrorAction SilentlyContinue) {
        Write-Host "  [OK]    $Name" -ForegroundColor Green
        return $true
    }
    Write-Host "  [FALTA] $Name" -ForegroundColor Red
    if ($Install) { Write-Host "          $Install" -ForegroundColor Yellow }
    $script:anyMissing = $true
    return $false
}

Write-Host '=== Harness Doctor ===' -ForegroundColor Cyan

Write-Host ''
Write-Host 'Dependências base:' -ForegroundColor Yellow
Check-Cmd 'git'             'git'    'winget install --id Git.Git'             | Out-Null
Check-Cmd 'gh (GitHub CLI)' 'gh'     'winget install --id GitHub.cli'          | Out-Null
Check-Cmd 'python 3.9+'     'python' 'winget install --id Python.Python.3.12'  | Out-Null
Check-Cmd 'uv (Astral)'     'uv'     'winget install --id astral-sh.uv'        | Out-Null
Check-Cmd 'node'            'node'   'winget install --id OpenJS.NodeJS'       | Out-Null

# RTK: roda `rtk --version` para reportar versao.
if (Get-Command rtk -ErrorAction SilentlyContinue) {
    $rtkVer = (& rtk --version 2>$null)
    if (-not $rtkVer) { $rtkVer = 'versao desconhecida' }
    Write-Host "  [OK]    rtk ($rtkVer)" -ForegroundColor Green
} else {
    Write-Host "  [FALTA] rtk (Rust Token Killer)" -ForegroundColor Red
    Write-Host "          cargo install --git https://github.com/rtk-ai/rtk" -ForegroundColor Yellow
    Write-Host "          ou baixe rtk-x86_64-pc-windows-msvc.zip em https://github.com/rtk-ai/rtk/releases" -ForegroundColor Yellow
    $anyMissing = $true
}

Write-Host ''
Write-Host 'MCP servers:' -ForegroundColor Yellow
Check-Cmd 'mempalace' 'mempalace' 'uv tool install mempalace' | Out-Null

Write-Host ''
Write-Host 'Skills junction:' -ForegroundColor Yellow
$skillsLink = Join-Path $env:USERPROFILE '.claude\skills\harness'
if (Test-Path $skillsLink) {
    Write-Host "  [OK]    $skillsLink" -ForegroundColor Green
} else {
    Write-Host "  [FALTA] junction ~/.claude/skills/harness" -ForegroundColor Red
    Write-Host '          Rode: .\scripts\setup.ps1' -ForegroundColor Yellow
    $anyMissing = $true
}

Write-Host ''
Write-Host 'Claude MCP config:' -ForegroundColor Yellow
$mcpFile = Join-Path $env:USERPROFILE '.claude\mcp.json'
if (Test-Path $mcpFile) {
    Write-Host "  [OK]    $mcpFile" -ForegroundColor Green
} else {
    Write-Host "  [FALTA] $mcpFile" -ForegroundColor Red
    Write-Host '          Rode: .\scripts\setup.ps1' -ForegroundColor Yellow
    $anyMissing = $true
}

Write-Host ''
if ($anyMissing) {
    Write-Host 'Doctor: itens faltando. Rode .\scripts\setup.ps1 para corrigir.' -ForegroundColor Yellow
    exit 1
} else {
    Write-Host 'Doctor: tudo OK.' -ForegroundColor Green
}
