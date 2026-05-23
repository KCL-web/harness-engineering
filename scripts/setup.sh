#!/usr/bin/env bash
# Setup do harness-engineering em uma nova máquina (Linux/macOS).
# Roda uma vez por máquina. Idempotente.
#
# Flags:
#   SKIP_MCP=1   pula instalação dos MCPs
#   FORCE=1      recria symlink mesmo se existir
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLAUDE_DIR="$HOME/.claude"
CLAUDE_SKILLS_DIR="$CLAUDE_DIR/skills"
SKILLS_TARGET="$CLAUDE_SKILLS_DIR/harness"
REPO_SKILLS="$REPO_ROOT/skills"
SKIP_MCP="${SKIP_MCP:-0}"
FORCE="${FORCE:-0}"

echo "=== Harness Engineering Setup ==="
echo "Repo:   $REPO_ROOT"
echo "Target: $SKILLS_TARGET"

# --- 1. Validar dependências ------------------------------------------------
echo ""
echo "[1/5] Validando dependências..."
missing=()
command -v git >/dev/null 2>&1 || missing+=("git")
command -v gh  >/dev/null 2>&1 || missing+=("gh (GitHub CLI)")
if [[ "$SKIP_MCP" != "1" ]]; then
    command -v python3 >/dev/null 2>&1 || missing+=("python 3.9+")
    command -v uv      >/dev/null 2>&1 || missing+=("uv (Astral)")
fi
if [[ ${#missing[@]} -gt 0 ]]; then
    echo "  Faltam: ${missing[*]}"
    echo "  Rode ./scripts/doctor.sh para instruções."
    exit 1
fi
echo "  Tudo certo."

# --- 2. Symlink skills/ -> ~/.claude/skills/harness/ -----------------------
echo ""
echo "[2/5] Linkando skills em ~/.claude/skills/harness..."
mkdir -p "$CLAUDE_SKILLS_DIR"
if [[ -L "$SKILLS_TARGET" || -e "$SKILLS_TARGET" ]]; then
    if [[ "$FORCE" == "1" ]]; then
        echo "  FORCE=1: removendo link existente."
        rm -rf "$SKILLS_TARGET"
    else
        echo "  Symlink já existe. Use FORCE=1 para recriar."
    fi
fi
if [[ ! -L "$SKILLS_TARGET" ]]; then
    ln -s "$REPO_SKILLS" "$SKILLS_TARGET"
fi
echo "  $SKILLS_TARGET -> $REPO_SKILLS"

# --- 3. RTK (Rust Token Killer) --------------------------------------------
echo ""
echo "[3/5] Instalando RTK..."
if command -v rtk >/dev/null 2>&1; then
    echo "  rtk já instalado ($(rtk --version 2>/dev/null || echo 'versão desconhecida'))."
elif command -v brew >/dev/null 2>&1; then
    if brew install rtk >/dev/null 2>&1; then
        echo "  rtk instalado via Homebrew."
    else
        echo "  Falha ao instalar rtk via Homebrew. Tente o instalador upstream:"
        echo "    curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh"
    fi
else
    echo "  Homebrew não encontrado. Instale rtk via:"
    echo "    curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh"
    echo "  Ou via cargo:"
    echo "    cargo install --git https://github.com/rtk-ai/rtk"
fi

# --- 4. MCP servers ---------------------------------------------------------
if [[ "$SKIP_MCP" != "1" ]]; then
    echo ""
    echo "[4/5] Instalando MCP servers..."

    echo "  -> mempalace"
    if uv tool install mempalace >/dev/null 2>&1; then
        echo "     instalado."
    else
        echo "  Falha ao instalar mempalace. Ver: https://github.com/mempalace/mempalace"
    fi

    echo "  -> openspace (Fase 5 — placeholder)"

    mcp_file="$CLAUDE_DIR/mcp.json"
    if [[ ! -f "$mcp_file" ]]; then
        cat > "$mcp_file" <<'EOF'
{
  "mcpServers": {
    "mempalace": {
      "command": "mempalace",
      "args": ["mcp"]
    }
  }
}
EOF
        echo "  Criado $mcp_file"
    else
        echo "  $mcp_file já existe. Adicione 'mempalace' manualmente se ainda não tiver."
    fi
else
    echo ""
    echo "[4/5] Pulando MCPs (SKIP_MCP=1)"
fi

# --- 5. Doctor --------------------------------------------------------------
echo ""
echo "[5/5] Verificação final..."
"$REPO_ROOT/scripts/doctor.sh"

echo ""
echo "Setup completo. Reinicie o Claude Code para carregar as skills."
