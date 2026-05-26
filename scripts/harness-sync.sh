#!/usr/bin/env bash
# Sincroniza arquivos universais do harness do harness-engineering-template para este projeto.
#
# Arquivos universais (regras do harness) são copiados do template.
# Arquivos específicos do projeto NUNCA são tocados:
#   .gsd/STACK.md, .gsd/CONVENTIONS.md, .gsd/SPEC.md, .gsd/ROADMAP.md, .gsd/progress/
#   .harness/feature_list.json, .harness/baseline.json
#   PRODUCT.md, INTEGRATION.md (modo umbrella)
#
# Uso:
#   HARNESS_TEMPLATE=/caminho/para/template ./scripts/harness-sync.sh
#   ./scripts/harness-sync.sh                 # padrão é ~/harness-engineering-template

set -euo pipefail

TEMPLATE="${HARNESS_TEMPLATE:-$HOME/harness-engineering-template}"

if [ ! -d "$TEMPLATE" ]; then
  echo "Template não encontrado em $TEMPLATE" >&2
  echo "Clone harness-engineering-template ali, ou defina HARNESS_TEMPLATE." >&2
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

echo "Atualizando template..."
pull_template
echo

# Detecta o modo com base nos arquivos que este projeto tem
MODE="single"
if [ -f "PRODUCT.md" ] && [ -f "INTEGRATION.md" ] && [ ! -d ".gsd" ]; then
  MODE="umbrella"
elif [ -f ".gsd/.mode" ] && grep -q "umbrella" .gsd/.mode 2>/dev/null; then
  MODE="sub-repo"
fi

echo "Modo detectado: $MODE"
echo

SINGLE_FILES=(
  "AGENTS.md"
  "CLAUDE.md"
  "ONBOARDING.md"
  ".gsd/BOOTSTRAP.md"
  ".gsd/bootstrap-prompt.md"
  ".gsd/SESSION_START.md"
  ".forgejo/ISSUE_TEMPLATE/default.md"
  ".forgejo/workflows/harness-gate.yml"
  ".harness/README.md"
  ".harness/feature_list.example.json"
  ".harness/baseline.example.json"
  "scripts/harness-init.sh"
  "scripts/harness-sync.sh"
  "scripts/check-harness.sh"
)

UMBRELLA_PAIRS=(
  "umbrella/AGENTS.md:AGENTS.md"
  "umbrella/CLAUDE.md:CLAUDE.md"
  "ONBOARDING.md:ONBOARDING.md"
  ".gsd/bootstrap-prompt.md:bootstrap-prompt.md"
)

copy_one() {
  local src="$1" dst="$2"
  if [ ! -f "$TEMPLATE/$src" ]; then
    echo "  pula     $dst (não está no template)"
    return
  fi
  mkdir -p "$(dirname "$dst")"
  cp "$TEMPLATE/$src" "$dst"
  case "$dst" in
    *.sh) chmod +x "$dst" ;;
  esac
  echo "  sincronizado $dst"
}

case "$MODE" in
  umbrella)
    for pair in "${UMBRELLA_PAIRS[@]}"; do
      copy_one "${pair%%:*}" "${pair##*:}"
    done
    echo
    echo "Pronto. Arquivos específicos do projeto NÃO foram tocados:"
    echo "  PRODUCT.md, INTEGRATION.md"
    ;;
  single|sub-repo)
    for f in "${SINGLE_FILES[@]}"; do
      copy_one "$f" "$f"
    done
    echo
    echo "Pronto. Arquivos específicos do projeto NÃO foram tocados:"
    echo "  .gsd/STACK.md, .gsd/CONVENTIONS.md, .gsd/SPEC.md, .gsd/ROADMAP.md, .gsd/progress/"
    echo "  .harness/feature_list.json, .harness/baseline.json"
    ;;
esac
