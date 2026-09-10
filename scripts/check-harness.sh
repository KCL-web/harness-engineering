#!/usr/bin/env bash
# Valida os contratos JSON em .harness/.
#
# Duas passadas:
#   1. Checagem de schema/integridade nos arquivos atuais
#   2. Checagem de diff contra a ref base (sem edição de campo congelado, sem regressão)
#
# Agnóstico de stack. Precisa só de bash + node + git.
#
# Uso:
#   bash scripts/check-harness.sh
#   HARNESS_BASE_REF=origin/preview bash scripts/check-harness.sh    # para CI

set -euo pipefail

cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

FEATURE_LIST=".harness/feature_list.json"
BASELINE=".harness/baseline.json"

base_tmp=""
baseline_tmp=""
cleanup() { rm -f "$base_tmp" "$baseline_tmp" 2>/dev/null || true; }
trap cleanup EXIT

errors=0
warns=0
err()  { printf '  \033[31m✗\033[0m %s\n' "$*" >&2; errors=$((errors+1)); }
warn() { printf '  \033[33m!\033[0m %s\n' "$*";       warns=$((warns+1)); }
ok()   { printf '  \033[32m✓\033[0m %s\n' "$*"; }

if ! command -v node >/dev/null 2>&1; then
  echo "node é exigido mas não está instalado." >&2
  echo "  Instale o Node.js: https://nodejs.org (já é pré-requisito deste projeto — ver package.json)." >&2
  exit 2
fi

# ---------- Passada 1: integridade do estado atual ----------

echo "==> feature_list.json"
if [ ! -f "$FEATURE_LIST" ]; then
  warn "faltando — projeto ainda não foi inicializado (cp $FEATURE_LIST.example $FEATURE_LIST)"
else
  if ! node -e 'JSON.parse(require("fs").readFileSync(process.argv[1], "utf8"))' "$FEATURE_LIST" >/dev/null 2>&1; then
    err "JSON inválido"
  else
    missing=$(node -e '
      const d = JSON.parse(require("fs").readFileSync(process.argv[1], "utf8"));
      const req = ["id", "title", "criteria", "implemented", "verified"];
      const n = (d.features || []).filter(
        (f) => !req.every((k) => Object.prototype.hasOwnProperty.call(f, k))
      ).length;
      console.log(n);
    ' "$FEATURE_LIST")
    [ "$missing" = "0" ] || err "$missing feature(s) com campos obrigatórios faltando"

    empty_crit=$(node -e '
      const d = JSON.parse(require("fs").readFileSync(process.argv[1], "utf8"));
      const n = (d.features || []).filter(
        (f) => !Array.isArray(f.criteria) || f.criteria.length === 0
      ).length;
      console.log(n);
    ' "$FEATURE_LIST")
    [ "$empty_crit" = "0" ] || err "$empty_crit feature(s) com criteria vazio ou não-array"

    dup_ids=$(node -e '
      const d = JSON.parse(require("fs").readFileSync(process.argv[1], "utf8"));
      const counts = {};
      for (const f of d.features || []) counts[f.id] = (counts[f.id] || 0) + 1;
      Object.keys(counts).filter((id) => counts[id] > 1).forEach((id) => console.log(id));
    ' "$FEATURE_LIST" | tr '\n' ' ')
    [ -z "$dup_ids" ] || err "IDs de feature duplicados: $dup_ids"

    bad_ids=$(node -e '
      const d = JSON.parse(require("fs").readFileSync(process.argv[1], "utf8"));
      (d.features || [])
        .map((f) => f.id)
        .filter((id) => !/^F[0-9]+$/.test(id))
        .forEach((id) => console.log(id));
    ' "$FEATURE_LIST" | tr '\n' ' ')
    [ -z "$bad_ids" ] || err "IDs de feature precisam bater com ^F[0-9]+\$: $bad_ids"

    bad_state=$(node -e '
      const d = JSON.parse(require("fs").readFileSync(process.argv[1], "utf8"));
      (d.features || [])
        .filter((f) => f.verified === true && f.implemented === false)
        .forEach((f) => console.log(f.id));
    ' "$FEATURE_LIST" | tr '\n' ' ')
    [ -z "$bad_state" ] || err "verified:true com implemented:false: $bad_state"

    count=$(node -e '
      const d = JSON.parse(require("fs").readFileSync(process.argv[1], "utf8"));
      console.log((d.features || []).length);
    ' "$FEATURE_LIST")
    [ "$errors" -eq 0 ] && ok "schema válido · $count feature(s)"
  fi
fi

echo
echo "==> baseline.json"
if [ ! -f "$BASELINE" ]; then
  warn "faltando — projeto ainda não foi inicializado (cp $BASELINE.example $BASELINE)"
else
  if ! node -e 'JSON.parse(require("fs").readFileSync(process.argv[1], "utf8"))' "$BASELINE" >/dev/null 2>&1; then
    err "JSON inválido"
  else
    bad_metric=$(node -e '
      const d = JSON.parse(require("fs").readFileSync(process.argv[1], "utf8"));
      const n = Object.values(d.metrics || {}).filter(
        (m) => typeof m.value !== "number" || !["higher", "lower"].includes(m.better || "")
      ).length;
      console.log(n);
    ' "$BASELINE")
    [ "$bad_metric" = "0" ] || err "$bad_metric métrica(s) com forma errada (precisa .value número + .better \"higher\"|\"lower\")"

    mcount=$(node -e '
      const d = JSON.parse(require("fs").readFileSync(process.argv[1], "utf8"));
      console.log(Object.keys(d.metrics || {}).length);
    ' "$BASELINE")
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
    base_tmp="$(mktemp)"
    git show "$BASE_REF:$FEATURE_LIST" > "$base_tmp"

    edited=$(node -e '
      const fs = require("fs");
      const base = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
      const curr = JSON.parse(fs.readFileSync(process.argv[2], "utf8"));
      const currById = new Map((curr.features || []).map((f) => [f.id, f]));
      const out = [];
      for (const b of base.features || []) {
        const c = currById.get(b.id);
        if (!c) continue; // tratado abaixo, em "removed"
        if (
          JSON.stringify(c.title) !== JSON.stringify(b.title) ||
          JSON.stringify(c.criteria) !== JSON.stringify(b.criteria)
        ) {
          out.push(b.id);
        }
      }
      console.log(out.join(" "));
    ' "$base_tmp" "$FEATURE_LIST")
    [ -z "$edited" ] || err "edição de campo congelado em feature(s) existente(s): $edited (title e criteria não podem mudar depois da criação)"

    removed=$(node -e '
      const fs = require("fs");
      const base = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
      const curr = JSON.parse(fs.readFileSync(process.argv[2], "utf8"));
      const currIds = new Set((curr.features || []).map((f) => f.id));
      const out = (base.features || []).filter((f) => !currIds.has(f.id)).map((f) => f.id);
      console.log(out.join(" "));
    ' "$base_tmp" "$FEATURE_LIST")
    [ -z "$removed" ] || err "feature(s) removida(s): $removed (feche, não delete)"

    [ -z "$edited$removed" ] && ok "feature_list.json: sem edição de campo congelado nem remoção"
  fi

  # baseline: nenhuma métrica regrediu
  if [ -f "$BASELINE" ] && git cat-file -e "$BASE_REF:$BASELINE" 2>/dev/null; then
    baseline_tmp="$(mktemp)"
    git show "$BASE_REF:$BASELINE" > "$baseline_tmp"

    regressions=$(node -e '
      const fs = require("fs");
      const base = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
      const curr = JSON.parse(fs.readFileSync(process.argv[2], "utf8"));
      const out = [];
      for (const [key, bMetric] of Object.entries(base.metrics || {})) {
        const cMetric = curr.metrics ? curr.metrics[key] : undefined;
        if (cMetric == null) {
          out.push(`${key}(removida)`);
        } else if (bMetric.better === "higher" && cMetric.value < bMetric.value) {
          out.push(`${key}: ${bMetric.value}→${cMetric.value} (diminuiu, mas higher é melhor)`);
        } else if (bMetric.better === "lower" && cMetric.value > bMetric.value) {
          out.push(`${key}: ${bMetric.value}→${cMetric.value} (aumentou, mas lower é melhor)`);
        }
      }
      console.log(out.join("; "));
    ' "$baseline_tmp" "$BASELINE")
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
