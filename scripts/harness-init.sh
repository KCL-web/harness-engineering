#!/usr/bin/env bash
# Inicializa um projeto novo a partir do harness-engineering-template.
#
# Uso:
#   cd /caminho/para/projeto-novo
#   /caminho/para/harness-engineering-template/scripts/harness-init.sh
#
# Ou com HARNESS_TEMPLATE apontando para a raiz do template:
#   HARNESS_TEMPLATE=/caminho/para/template harness-init.sh
#
# O script:
#   1. Detecta o local do template (a partir de $HARNESS_TEMPLATE ou do path do próprio script).
#   2. Se recusa a sobrescrever um harness existente.
#   3. Pergunta qual o modo deste diretório: single-repo, umbrella ou sub-repo.
#   4. Copia o conjunto certo de arquivos.
#   5. Opcionalmente inicia o Claude Code com o prompt de bootstrap.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE="${HARNESS_TEMPLATE:-$(cd "$SCRIPT_DIR/.." && pwd)}"

if [ ! -f "$TEMPLATE/AGENTS.md" ] || [ ! -d "$TEMPLATE/.gsd" ]; then
  echo "Template inválido em: $TEMPLATE" >&2
  echo "Defina HARNESS_TEMPLATE apontando para o diretório do harness-engineering-template." >&2
  exit 1
fi

pull_template() {
  [ "${HARNESS_NO_PULL:-}" = "1" ] && { echo "  HARNESS_NO_PULL=1 — pulando atualização do template"; return; }
  [ -d "$TEMPLATE/.git" ] || { echo "  template não é um checkout git — pulando atualização"; return; }
  git -C "$TEMPLATE" remote get-url origin >/dev/null 2>&1 || { echo "  template sem remote 'origin' — pulando atualização"; return; }

  if ! git -C "$TEMPLATE" diff --quiet HEAD 2>/dev/null; then
    echo "  template tem alterações locais não commitadas — pulando atualização (commit ou stash para reativar)"
    return
  fi

  echo "  puxando template mais recente do origin..."
  if git -C "$TEMPLATE" pull --ff-only --quiet 2>&1; then
    echo "  template atualizado ($(git -C "$TEMPLATE" log -1 --format='%h %s'))"
  else
    echo "  pull falhou (offline ou divergiu) — usando template local como está"
  fi
}

TARGET_DIR="$(pwd)"

echo "Template do harness: $TEMPLATE"
echo "Diretório alvo:      $TARGET_DIR"
echo

echo "Atualizando template..."
pull_template
echo

if [ -f "AGENTS.md" ] || [ -d ".gsd" ] || [ -f "PRODUCT.md" ]; then
  echo "Arquivos do harness já existem neste diretório." >&2
  echo "Se quer só atualizar os arquivos universais, rode scripts/harness-sync.sh." >&2
  exit 1
fi

echo "Qual é o modo de workspace deste diretório?"
echo
echo "  1) single-repo  — um repo Git, projeto standalone"
echo "  2) umbrella     — workspace raiz contendo múltiplos repos Git (ex.: BE + FE)"
echo "  3) sub-repo     — um repo Git dentro de um workspace umbrella"
echo
read -r -p "Escolha [1/2/3]: " MODE

SINGLE_FILES=(
  "AGENTS.md"
  "CLAUDE.md"
  "ONBOARDING.md"
  ".gsd/BOOTSTRAP.md"
  ".gsd/bootstrap-prompt.md"
  ".gsd/SESSION_START.md"
  ".gsd/STACK.md"
  ".gsd/CONVENTIONS.md"
  ".gsd/SPEC.md"
  ".gsd/ROADMAP.md"
  ".forgejo/ISSUE_TEMPLATE/default.md"
  ".forgejo/workflows/harness-gate.yml"
  ".harness/README.md"
  ".harness/feature_list.example.json"
  ".harness/baseline.example.json"
  "scripts/harness-sync.sh"
  "scripts/check-harness.sh"
)

UMBRELLA_PAIRS=(
  "umbrella/AGENTS.md:AGENTS.md"
  "umbrella/CLAUDE.md:CLAUDE.md"
  "umbrella/PRODUCT.md:PRODUCT.md"
  "umbrella/INTEGRATION.md:INTEGRATION.md"
  "ONBOARDING.md:ONBOARDING.md"
  "scripts/harness-sync.sh:scripts/harness-sync.sh"
)

ensure_jq() {
  if command -v jq >/dev/null 2>&1; then
    echo "  jq já instalado ($(jq --version))"
    return 0
  fi

  echo
  echo "jq é exigido por scripts/check-harness.sh mas não está instalado."

  local installer=""
  local uname_s
  uname_s="$(uname -s 2>/dev/null || echo unknown)"

  case "$uname_s" in
    MINGW*|MSYS*|CYGWIN*)
      # Native Windows bash (Git Bash, MSYS2, Cygwin) — use a Windows package manager
      if command -v winget >/dev/null 2>&1; then
        installer="winget install --id jqlang.jq --silent --accept-source-agreements --accept-package-agreements"
      elif command -v scoop >/dev/null 2>&1; then
        installer="scoop install jq"
      elif command -v choco >/dev/null 2>&1; then
        installer="choco install jq -y"
      fi
      ;;
    *)
      if [ -f /etc/debian_version ] || grep -qi ubuntu /etc/os-release 2>/dev/null; then
        installer="sudo apt-get update -qq && sudo apt-get install -y jq"
      elif [ "$uname_s" = "Darwin" ] && command -v brew >/dev/null 2>&1; then
        installer="brew install jq"
      elif [ -f /etc/fedora-release ] || [ -f /etc/redhat-release ]; then
        installer="sudo dnf install -y jq"
      elif command -v pacman >/dev/null 2>&1; then
        installer="sudo pacman -S --noconfirm jq"
      elif command -v apk >/dev/null 2>&1; then
        installer="sudo apk add --no-cache jq"
      fi
      ;;
  esac

  if [ -z "$installer" ]; then
    echo "  Não foi possível detectar um gerenciador de pacotes. Instale jq manualmente:"
    echo "    https://jqlang.org/download/"
    return 1
  fi

  echo "  Installer detectado: $installer"
  read -r -p "  Rodar agora? [s/N]: " ans
  case "$ans" in
    s|S|y|Y|sim|SIM|yes|YES)
      bash -c "$installer"
      command -v jq >/dev/null 2>&1 && echo "  jq instalado: $(jq --version)" || {
        echo "  jq ainda fora do PATH — instale manualmente antes de rodar check-harness.sh" >&2
        return 1
      }
      ;;
    *)
      echo "  Pulado. Para instalar depois: $installer"
      ;;
  esac
}

copy_one() {
  local src="$1" dst="$2"
  if [ ! -f "$TEMPLATE/$src" ]; then
    echo "  pula    $src → $dst (não está no template)" >&2
    return
  fi
  mkdir -p "$(dirname "$dst")"
  cp "$TEMPLATE/$src" "$dst"
  case "$dst" in
    *.sh) chmod +x "$dst" ;;
  esac
  echo "  copiado $dst"
}

PROMPT_PATH=""

case "$MODE" in
  1)
    echo
    echo "Modo: single-repo"
    for f in "${SINGLE_FILES[@]}"; do
      copy_one "$f" "$f"
    done
    mkdir -p .gsd/progress
    touch .gsd/progress/.gitkeep
    PROMPT_PATH=".gsd/bootstrap-prompt.md"
    ;;
  2)
    echo
    echo "Modo: umbrella"
    for pair in "${UMBRELLA_PAIRS[@]}"; do
      copy_one "${pair%%:*}" "${pair##*:}"
    done
    # O prompt de bootstrap é compartilhado — também copiado para a raiz do workspace por conveniência
    copy_one ".gsd/bootstrap-prompt.md" "bootstrap-prompt.md"
    PROMPT_PATH="bootstrap-prompt.md"
    ;;
  3)
    echo
    echo "Modo: sub-repo"
    for f in "${SINGLE_FILES[@]}"; do
      copy_one "$f" "$f"
    done
    mkdir -p .gsd/progress
    touch .gsd/progress/.gitkeep
    # Marcador para que tooling futuro saiba que este repo é parte de um workspace umbrella
    echo "umbrella" > .gsd/.mode
    PROMPT_PATH=".gsd/bootstrap-prompt.md"
    if [ ! -f "../PRODUCT.md" ]; then
      echo
      echo "  NOTA: ../PRODUCT.md não encontrado." >&2
      echo "  Rode o bootstrap umbrella primeiro (modo 2 na raiz do workspace)" >&2
      echo "  antes de rodar a entrevista de bootstrap neste sub-repo." >&2
    fi
    ;;
  *)
    echo "Escolha inválida." >&2
    exit 1
    ;;
esac

echo
echo "Arquivos do harness copiados."
echo
echo "Verificando dependências..."
ensure_jq || true
echo

read -r -p "Iniciar a entrevista de bootstrap agora com Claude Code? [s/N]: " START
case "$START" in
  s|S|y|Y|sim|SIM|yes|YES)
    if ! command -v claude >/dev/null 2>&1; then
      echo
      echo "CLI claude não encontrado no PATH."
      echo "Abra o Claude Code manualmente e cole o conteúdo de $PROMPT_PATH"
      exit 0
    fi
    if [ ! -f "$PROMPT_PATH" ]; then
      echo "Prompt de bootstrap não encontrado em $PROMPT_PATH" >&2
      exit 1
    fi
    echo
    echo "Iniciando Claude Code com o prompt de bootstrap..."
    claude "$(cat "$PROMPT_PATH")"
    ;;
  *)
    echo
    echo "Para iniciar a entrevista depois:"
    echo "  claude \"\$(cat $PROMPT_PATH)\""
    echo "Ou abra o Claude Code e cole o prompt manualmente."
    ;;
esac
