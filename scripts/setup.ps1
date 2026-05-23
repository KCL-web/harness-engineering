#Requires -Version 5.1
<#
.SYNOPSIS
    Setup do harness-engineering em uma nova maquina (Windows).
.DESCRIPTION
    Roda uma vez por maquina. Idempotente.
      1. Valida dependencias (git, gh, python, uv).
      2. Cria junction de skills/ -> ~/.claude/skills/harness/.
      3. Instala RTK (Rust Token Killer).
      4. Instala MCP servers (mempalace; openspace na Fase 5).
      5. Configura ~/.claude/mcp.json com mempalace.
      6. Roda doctor.ps1 no fim.
.PARAMETER SkipMcp
    Pula instalacao dos MCP servers. Util em CI ou ambientes restritos.
.PARAMETER Force
    Recria a junction mesmo se ja existir.
#>
param(
    [switch]$SkipMcp,
    [switch]$Force
)

# Stop para cmdlets, mas precisamos tratar native commands manualmente
# (uv escreve mensagens em stderr que nao sao erros — nao redirecionamos).
$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$claudeDir = Join-Path $env:USERPROFILE '.claude'
$claudeSkillsDir = Join-Path $claudeDir 'skills'
$skillsTarget = Join-Path $claudeSkillsDir 'harness'
$repoSkills = Join-Path $repoRoot 'skills'

Write-Host '=== Harness Engineering Setup ===' -ForegroundColor Cyan
Write-Host "Repo:   $repoRoot"
Write-Host "Target: $skillsTarget"

# --- 1. Validar dependencias ------------------------------------------------
Write-Host ''
Write-Host '[1/5] Validando dependencias...' -ForegroundColor Yellow
$missing = New-Object System.Collections.Generic.List[string]
if (-not (Get-Command git -ErrorAction SilentlyContinue)) { $missing.Add('git') }
if (-not (Get-Command gh  -ErrorAction SilentlyContinue)) { $missing.Add('gh (GitHub CLI)') }
if (-not $SkipMcp) {
    if (-not (Get-Command python -ErrorAction SilentlyContinue)) { $missing.Add('python 3.9+') }
    if (-not (Get-Command uv     -ErrorAction SilentlyContinue)) { $missing.Add('uv (Astral)') }
}
if ($missing.Count -gt 0) {
    Write-Host ('  Faltam: {0}' -f ($missing -join ', ')) -ForegroundColor Red
    Write-Host '  Rode .\scripts\doctor.ps1 para instrucoes de instalacao.' -ForegroundColor Yellow
    exit 1
}
Write-Host '  Tudo certo.' -ForegroundColor Green

# --- 2. Junction skills/ -> ~/.claude/skills/harness/ -----------------------
Write-Host ''
Write-Host '[2/5] Linkando skills em ~/.claude/skills/harness...' -ForegroundColor Yellow
if (-not (Test-Path $claudeDir))       { New-Item -ItemType Directory -Path $claudeDir       | Out-Null }
if (-not (Test-Path $claudeSkillsDir)) { New-Item -ItemType Directory -Path $claudeSkillsDir | Out-Null }

if (Test-Path $skillsTarget) {
    if ($Force) {
        Write-Host '  -Force: removendo junction existente.' -ForegroundColor Yellow
        cmd /c rmdir "$skillsTarget" | Out-Null
    } else {
        Write-Host "  Junction ja existe. Use -Force para recriar." -ForegroundColor Yellow
    }
}
if (-not (Test-Path $skillsTarget)) {
    cmd /c mklink /J "$skillsTarget" "$repoSkills" | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Host '  Falha ao criar junction.' -ForegroundColor Red
        exit 1
    }
}
Write-Host "  $skillsTarget -> $repoSkills" -ForegroundColor Green

# --- 3. RTK (Rust Token Killer) --------------------------------------------
Write-Host ''
Write-Host '[3/5] Instalando RTK...' -ForegroundColor Yellow
if (Get-Command rtk -ErrorAction SilentlyContinue) {
    $rtkVer = (& rtk --version 2>$null)
    if (-not $rtkVer) { $rtkVer = 'versao desconhecida' }
    Write-Host "  rtk ja instalado ($rtkVer)." -ForegroundColor Green
} elseif (Get-Command cargo -ErrorAction SilentlyContinue) {
    Write-Host '  Tentando cargo install --git https://github.com/rtk-ai/rtk' -ForegroundColor Cyan
    & cargo install --git https://github.com/rtk-ai/rtk
    if ($LASTEXITCODE -ne 0) {
        Write-Host '  Falha no cargo install. Baixe o binario Windows em:' -ForegroundColor Yellow
        Write-Host '    https://github.com/rtk-ai/rtk/releases (rtk-x86_64-pc-windows-msvc.zip)' -ForegroundColor Yellow
    } else {
        Write-Host '  rtk instalado via cargo.' -ForegroundColor Green
    }
} else {
    Write-Host '  cargo nao encontrado. Baixe o binario Windows em:' -ForegroundColor Yellow
    Write-Host '    https://github.com/rtk-ai/rtk/releases (rtk-x86_64-pc-windows-msvc.zip)' -ForegroundColor Yellow
    Write-Host '  Extraia e coloque rtk.exe em algum diretorio do PATH (ex.: %USERPROFILE%\.local\bin).' -ForegroundColor Yellow
    Write-Host '  Recomendado: rode o harness via WSL para ter o hook system completo.' -ForegroundColor Gray
}

# --- 4. MCP servers ---------------------------------------------------------
if (-not $SkipMcp) {
    Write-Host ''
    Write-Host '[4/5] Instalando MCP servers...' -ForegroundColor Yellow

    Write-Host '  -> mempalace' -ForegroundColor Cyan
    # NAO usar 2>&1 com uv: ele escreve mensagens informativas em stderr
    # ("Resolved N packages") que viram NativeCommandError em PS 5.1.
    # Deixamos a saida do uv aparecer naturalmente.
    & uv tool install mempalace
    if ($LASTEXITCODE -ne 0) {
        Write-Host '  Falha ao instalar mempalace. Ver: https://github.com/mempalace/mempalace' -ForegroundColor Yellow
    } else {
        Write-Host '     instalado.' -ForegroundColor Green
    }

    Write-Host '  -> openspace (Fase 5 - placeholder)' -ForegroundColor Gray

    $mcpFile = Join-Path $claudeDir 'mcp.json'
    if (-not (Test-Path $mcpFile)) {
        @'
{
  "mcpServers": {
    "mempalace": {
      "command": "mempalace",
      "args": ["mcp"]
    }
  }
}
'@ | Out-File -FilePath $mcpFile -Encoding utf8
        Write-Host "  Criado $mcpFile" -ForegroundColor Green
    } else {
        Write-Host "  $mcpFile ja existe. Adicione 'mempalace' manualmente se ainda nao estiver." -ForegroundColor Yellow
    }
} else {
    Write-Host ''
    Write-Host '[4/5] Pulando MCPs (-SkipMcp)' -ForegroundColor Gray
}

# --- 5. Doctor final --------------------------------------------------------
Write-Host ''
Write-Host '[5/5] Verificacao final...' -ForegroundColor Yellow
& (Join-Path $PSScriptRoot 'doctor.ps1')

Write-Host ''
Write-Host 'Setup completo. Reinicie o Claude Code para carregar as skills.' -ForegroundColor Green
