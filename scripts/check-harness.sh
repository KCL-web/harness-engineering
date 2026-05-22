#!/usr/bin/env bash
# Valida os contratos JSON em .harness/.
#
# Duas passadas:
#   1. Checagem de schema/integridade nos arquivos atuais
#   2. Checagem de diff contra a ref base (sem edição de campo congelado, sem regressão)
#
# Agnóstico de stack. Precisa só de bash + jq + git.
#
# Uso:
#   bash scripts/check-harness.sh
#   HARNESS_BASE_REF=origin/preview bash scripts/check-harness.sh    # para CI

set -euo pipefail

cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

FEATURE_LIST=".harness/feature_list.json"
BASELINE=".harness/baseline.json"

errors=0
warns=0
err()  { printf '  \033[31m✗\033[0m %s\n' "$*" >&2; errors=$((errors+1)); }
warn() { printf '  \033[33m!\033[0m %s\n' "$*";       warns=$((warns+1)); }
ok()   { printf '  \033[32m✓\033[0m %s\n' "$*"; }

if ! command -v jq >/dev/null 2>&1; then
  echo "jq é exigido mas não está instalado." >&2
  case "$(uname -s 2>/dev/null || echo unknown)" in
    MINGW*|MSYS*|CYGWIN*)
      echo "  Instalar (Windows): winget install jqlang.jq" >&2
      echo "                  ou: scoop install jq" >&2
      echo "                  ou: choco install jq" >&2
      ;;
    Darwin)
      echo "  Instalar: brew install jq" >&2
      ;;
    *)
      if [ -f /etc/debian_version ] || grep -qi ubuntu /etc/os-release 2>/dev/null; then
        echo "  Instalar: sudo apt-get install -y jq" >&2
      elif [ -f /etc/fedora-release ] || [ -f /etc/redhat-release ]; then
        echo "  Instalar: sudo dnf install -y jq" >&2
      elif command -v pacman >/dev/null 2>&1; then
        echo "  Instalar: sudo pacman -S jq" >&2
      elif command -v apk >/dev/null 2>&1; then
        echo "  Instalar: sudo apk add jq" >&2
      else
        echo "  Instalar de https://jqlang.org/download/" >&2
      fi
      ;;
  esac
  exit 2
fi

# ---------- Passada 1: integridade do estado atual ----------

echo "==> feature_list.json"
if [ ! -f "$FEATURE_LIST" ]; then
  warn "faltando — projeto ainda não foi inicializado (cp $FEATURE_LIST.example $FEATURE_LIST)"
else
  if ! jq empty "$FEATURE_LIST" >/dev/null 2>&1; then
    err "JSON inválido"
  else
    missing=$(jq '[.features[] | select((has("id") and has("title") and has("criteria") and has("implemented") and has("verified")) | not)] | length' "$FEATURE_LIST")
    [ "$missing" = "0" ] || err "$missing feature(s) com campos obrigatórios faltando"

    empty_crit=$(jq '[.features[] | select((.criteria | type) != "array" or (.criteria | length) == 0)] | length' "$FEATURE_LIST")
    [ "$empty_crit" = "0" ] || err "$empty_crit feature(s) com criteria vazio ou não-array"

    dup_ids=$(jq -r '.features | group_by(.id) | map(select(length > 1) | .[0].id) | .[]?' "$FEATURE_LIST" | tr '\n' ' ')
    [ -z "$dup_ids" ] || err "IDs de feature duplicados: $dup_ids"

    bad_ids=$(jq -r '.features[].id | select(test("^F[0-9]+$") | not)' "$FEATURE_LIST" | tr '\n' ' ')
    [ -z "$bad_ids" ] || err "IDs de feature precisam bater com ^F[0-9]+\$: $bad_ids"

    bad_state=$(jq -r '.features[] | select(.verified == true and .implemented == false) | .id' "$FEATURE_LIST" | tr '\n' ' ')
    [ -z "$bad_state" ] || err "verified:true com implemented:false: $bad_state"

    count=$(jq '.features | length' "$FEATURE_LIST")
    [ "$errors" -eq 0 ] && ok "schema válido · $count feature(s)"
  fi
fi

echo
echo "==> baseline.json"
if [ ! -f "$BASELINE" ]; then
  warn "faltando — projeto ainda não foi inicializado (cp $BASELINE.example $BASELINE)"
else
  if ! jq empty "$BASELINE" >/dev/null 2>&1; then
    err "JSON inválido"
  else
    bad_metric=$(jq '[.metrics | to_entries[] | select((.value.value | type) != "number" or (.value.better // "" | IN("higher","lower") | not))] | length' "$BASELINE")
    [ "$bad_metric" = "0" ] || err "$bad_metric métrica(s) com forma errada (precisa .value número + .better \"higher\"|\"lower\")"

    mcount=$(jq '.metrics | length' "$BASELINE")
    [ "$errors" -eq 0 ] && ok "schema válido · $mcount métrica(s)"
  fi
fi

# ---------- Passada 2: diff vs ref base ----------

echo
echo "==> diff vs ref base"

BASE_REF="${HARNESS_BASE_REF:-}"
if [ -z "$BASE_REF" ]; then
  for candidate in preview main master; do
    if git show-ref --verify --quiet "refs/heads/$candidate" 2>/dev/null; then
      BASE_REF="$candidate"
      break
    fi
  done
fi

if [ -z "$BASE_REF" ] || ! git rev-parse --verify "$BASE_REF" >/dev/null 2>&1; then
  warn "sem ref base disponível — pulando checagens de campo congelado e regressão"
else
  echo "  base: $BASE_REF"

  # feature_list: campos congelados (id/title/criteria) em features que existiam na base
  if [ -f "$FEATURE_LIST" ] && git cat-file -e "$BASE_REF:$FEATURE_LIST" 2>/dev/null; then
    base_fl=$(git show "$BASE_REF:$FEATURE_LIST")
    curr_fl=$(cat "$FEATURE_LIST")

    edited=$(jq -nr --argjson base "$base_fl" --argjson curr "$curr_fl" '
      [
        $base.features[] as $b
        | ($curr.features[] | select(.id == $b.id)) as $c
        | if ($c.title != $b.title) or ($c.criteria != $b.criteria)
          then $b.id
          else empty
          end
      ] | join(" ")
    ')
    [ -z "$edited" ] || err "edição de campo congelado em feature(s) existente(s): $edited (title e criteria não podem mudar depois da criação)"

    removed=$(jq -nr --argjson base "$base_fl" --argjson curr "$curr_fl" '
      ($curr.features | map(.id)) as $curr_ids
      | [$base.features[] | select(.id as $id | $curr_ids | index($id) | not) | .id] | join(" ")
    ')
    [ -z "$removed" ] || err "feature(s) removida(s): $removed (feche, não delete)"

    [ -z "$edited$removed" ] && ok "feature_list.json: sem edição de campo congelado nem remoção"
  fi

  # baseline: nenhuma métrica regrediu
  if [ -f "$BASELINE" ] && git cat-file -e "$BASE_REF:$BASELINE" 2>/dev/null; then
    base_bl=$(git show "$BASE_REF:$BASELINE")
    curr_bl=$(cat "$BASELINE")

    regressions=$(jq -nr --argjson base "$base_bl" --argjson curr "$curr_bl" '
      [
        $base.metrics | to_entries[] as $b
        | ($curr.metrics[$b.key]) as $c
        | if $c == null then "\($b.key)(removida)"
          elif ($b.value.better == "higher") and ($c.value < $b.value.value)
            then "\($b.key): \($b.value.value)→\($c.value) (diminuiu, mas higher é melhor)"
          elif ($b.value.better == "lower") and ($c.value > $b.value.value)
            then "\($b.key): \($b.value.value)→\($c.value) (aumentou, mas lower é melhor)"
          else empty
          end
      ] | join("; ")
    ')
    if [ -n "$regressions" ]; then
      err "regressão de baseline: $regressions"
    else
      ok "baseline.json: nenhuma métrica regrediu"
    fi
  fi
fi

# ---------- Sumário ----------

echo
if [ $errors -gt 0 ]; then
  echo "Harness check FALHOU: $errors erro(s), $warns aviso(s)" >&2
  exit 1
fi

if [ $warns -gt 0 ]; then
  echo "Harness check passou com $warns aviso(s)"
else
  echo "Harness check passou"
fi
