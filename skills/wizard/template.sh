#!/usr/bin/env bash
#
# Um wizard guia um humano por um procedimento manual, passo a passo.
# Gerado pela skill /wizard.
#
# Tudo acima do marcador "STAGES" é a biblioteca do wizard: não edite à mão.
# Escreva os estágios de cada passo abaixo do marcador.

set -euo pipefail

# ──────────────────────────────────────────────────────────────────────────
# Biblioteca do wizard: UX agradável e consistente, idêntica em todo wizard.
# ──────────────────────────────────────────────────────────────────────────

if [[ -t 1 ]] && command -v tput >/dev/null 2>&1 && [[ "$(tput colors 2>/dev/null || echo 0)" -ge 8 ]]; then
  BOLD=$(tput bold); DIM=$(tput dim); RESET=$(tput sgr0)
  BLUE=$(tput setaf 4); GREEN=$(tput setaf 2); YELLOW=$(tput setaf 3); RED=$(tput setaf 1)
else
  BOLD=""; DIM=""; RESET=""; BLUE=""; GREEN=""; YELLOW=""; RED=""
fi

# Quem escreve o wizard ajusta isso no topo da seção de estágios.
TOTAL_STAGES=0

_STAGE_INDEX=0
ENV_FILE="${ENV_FILE:-.env}"
WRITTEN_ENV=()    # KEYs escritas em ENV_FILE nesta execução
WRITTEN_SECRET=() # NOMEs de secret setados nesta execução
SKIPPED=()        # coisas que não conseguimos fazer (ex.: token sem escopo)

# Config do Forgejo, para set_secret/set_var (mesmas env vars de workflow-issues).
FORGEJO_URL="${FORGEJO_URL:-}"
FORGEJO_TOKEN="${FORGEJO_TOKEN:-}"
FORGEJO_ORG="${FORGEJO_ORG:-}"
FORGEJO_REPO="${FORGEJO_REPO:-}"   # nome do repo (sem o org); detectado do remote se vazio

# _forgejo_owner_repo: resolve "org/repo" a partir de FORGEJO_ORG/FORGEJO_REPO,
# ou tentando extrair do remote "origin" quando algum dos dois estiver vazio.
_forgejo_owner_repo() {
  local org="$FORGEJO_ORG" repo="$FORGEJO_REPO" remote
  if [[ -z "$org" || -z "$repo" ]]; then
    remote=$(git remote get-url origin 2>/dev/null || true)
    # aceita ssh (git@host:org/repo.git) e https (https://host/org/repo.git)
    if [[ "$remote" =~ [:/]([^/:]+)/([^/]+)\.git$ ]]; then
      org="${org:-${BASH_REMATCH[1]}}"
      repo="${repo:-${BASH_REMATCH[2]}}"
    fi
  fi
  [[ -n "$org" && -n "$repo" ]] || return 1
  printf '%s/%s' "$org" "$repo"
}

# _clear apaga o terminal para que só o passo atual fique na tela. No-op quando
# a saída não é um terminal, para que logs redirecionados continuem legíveis.
_clear() {
  [[ -t 1 ]] || return 0
  if command -v tput >/dev/null 2>&1; then tput clear; else printf '\033[2J\033[3J\033[H'; fi
}

# banner "Título" mostra o quadro de abertura: o que este wizard faz.
banner() {
  _clear
  printf '\n%s%s  %s%s\n' "$BOLD" "$BLUE" "$1" "$RESET"
  printf '%s  %s estágios%s\n\n' "$DIM" "$TOTAL_STAGES" "$RESET"
  printf '%s  Você dirige o navegador; este wizard diz exatamente o que fazer e\n' "$DIM"
  printf '  captura os valores que você copia de volta. Pare a qualquer momento com\n'
  printf '  Ctrl-C e rode de novo depois, porque ele lembra os valores já salvos.%s\n' "$RESET"
  pause "Pronto para começar?"
}

# stage "Nome" limpa a tela, então anuncia um estágio e mostra o progresso.
# Limpar mantém só o passo atual visível.
stage() {
  _clear
  _STAGE_INDEX=$((_STAGE_INDEX + 1))
  printf '\n%s%s▸ Estágio %s/%s · %s%s\n' \
    "$BOLD" "$BLUE" "$_STAGE_INDEX" "$TOTAL_STAGES" "$1" "$RESET"
}

# say "..." imprime uma linha de instrução simples.
say()  { printf '  %s\n' "$1"; }
# step "..." é uma ação numerada-no-sentido que o humano executa no navegador.
step() { printf '  %s•%s %s\n' "$BLUE" "$RESET" "$1"; }
note() { printf '  %s%s%s\n' "$DIM" "$1" "$RESET"; }
warn() { printf '  %s⚠ %s%s\n' "$YELLOW" "$1" "$RESET"; }

# open_url URL abre no navegador do humano, cross-platform incl. WSL.
open_url() {
  local url="$1"
  printf '  %s↗ abrindo%s %s\n' "$GREEN" "$RESET" "$url"
  { if   command -v wslview     >/dev/null 2>&1; then wslview "$url"
    elif command -v explorer.exe >/dev/null 2>&1; then explorer.exe "$url"
    elif command -v xdg-open    >/dev/null 2>&1; then xdg-open "$url"
    elif command -v open        >/dev/null 2>&1; then open "$url"
    else warn "não consegui abrir um navegador; visite manualmente: $url"; fi
  } >/dev/null 2>&1 || warn "não consegui abrir um navegador, visite manualmente: $url"
}

# pause "msg" espera o humano confirmar que fez a parte manual.
pause() {
  printf '  %s%s%s ' "$DIM" "${1:-Pressione Enter para continuar}" "$RESET"
  read -r _ || true
}

# confirm "pergunta" é um portão y/N; retorna sucesso em caso de sim.
confirm() {
  local reply=""
  printf '  %s? %s [y/N] ' "$YELLOW" "$1"
  read -r reply || true
  [[ "$reply" =~ ^[Yy] ]]
}

# _existing KEY: valor atual de KEY em ENV_FILE, se houver.
_existing() {
  [[ -f "$ENV_FILE" ]] || return 1
  local line; line=$(grep -E "^${1}=" "$ENV_FILE" | tail -n1) || return 1
  printf '%s' "${line#*=}"
}

# ask KEY "Prompt" lê um valor em $KEY. Oferece o valor existente do .env como
# default em reexecuções (Enter mantém). Entrada visível (não-secreta).
ask() {
  local key="$1" prompt="$2" current input
  current=$(_existing "$key" || true)
  if [[ -n "$current" ]]; then
    printf '  %s%s%s %s[Enter mantém o atual]%s ' "$BOLD" "$prompt" "$RESET" "$DIM" "$RESET"
  else
    printf '  %s%s%s ' "$BOLD" "$prompt" "$RESET"
  fi
  read -r input || true
  [[ -z "$input" && -n "$current" ]] && input="$current"
  printf -v "$key" '%s' "$input"
}

# ask_secret KEY "Prompt" é como ask, mas a entrada fica oculta.
ask_secret() {
  local key="$1" prompt="$2" current input
  current=$(_existing "$key" || true)
  if [[ -n "$current" ]]; then
    printf '  %s%s%s %s[Enter mantém o atual]%s ' "$BOLD" "$prompt" "$RESET" "$DIM" "$RESET"
  else
    printf '  %s%s%s ' "$BOLD" "$prompt" "$RESET"
  fi
  read -rs input || true
  printf '\n'
  [[ -z "$input" && -n "$current" ]] && input="$current"
  printf -v "$key" '%s' "$input"
}

# write_env KEY VALUE faz upsert de KEY=VALUE em ENV_FILE (cria o arquivo;
# substitui qualquer linha existente). Idempotente.
write_env() {
  local key="$1" value="$2" tmp
  touch "$ENV_FILE"
  tmp=$(mktemp)
  grep -vE "^${key}=" "$ENV_FILE" > "$tmp" || true
  printf '%s=%s\n' "$key" "$value" >> "$tmp"
  mv "$tmp" "$ENV_FILE"
  WRITTEN_ENV+=("$key")
  printf '  %s✓ escrito%s %s → %s\n' "$GREEN" "$RESET" "$key" "$ENV_FILE"
}

# set_secret NAME VALUE seta um secret de Actions do repositório no Forgejo,
# via API (PUT /repos/{org}/{repo}/actions/secrets/{name}). Cai para um aviso
# (e registra a pendência) se FORGEJO_TOKEN/owner-repo não estiverem prontos
# ou a chamada falhar.
set_secret() {
  local name="$1" value="$2" owner_repo http_code
  owner_repo=$(_forgejo_owner_repo || true)
  if [[ -n "$FORGEJO_TOKEN" && -n "$FORGEJO_URL" && -n "$owner_repo" ]]; then
    http_code=$(curl -s -o /dev/null -w '%{http_code}' -X PUT \
      -H "Authorization: token $FORGEJO_TOKEN" \
      -H "Content-Type: application/json" \
      "$FORGEJO_URL/api/v1/repos/$owner_repo/actions/secrets/$name" \
      -d "{\"data\": $(printf '%s' "$value" | jq -Rs .)}" 2>/dev/null || echo "000")
    if [[ "$http_code" == "201" || "$http_code" == "204" ]]; then
      WRITTEN_SECRET+=("$name")
      printf '  %s✓ setado%s secret do Forgejo Actions %s\n' "$GREEN" "$RESET" "$name"
      return
    fi
  fi
  SKIPPED+=("Secret do Forgejo Actions $name (defina manualmente: repo → Settings → Actions → Secrets)")
  warn "pulei o secret $name: Forgejo não pronto (token/owner-repo); defina depois"
}

# set_var NAME VALUE seta uma variable de Actions do repositório no Forgejo
# (não-secreta), via API (PUT /repos/{org}/{repo}/actions/variables/{name}).
set_var() {
  local name="$1" value="$2" owner_repo http_code
  owner_repo=$(_forgejo_owner_repo || true)
  if [[ -n "$FORGEJO_TOKEN" && -n "$FORGEJO_URL" && -n "$owner_repo" ]]; then
    http_code=$(curl -s -o /dev/null -w '%{http_code}' -X PUT \
      -H "Authorization: token $FORGEJO_TOKEN" \
      -H "Content-Type: application/json" \
      "$FORGEJO_URL/api/v1/repos/$owner_repo/actions/variables/$name" \
      -d "{\"value\": $(printf '%s' "$value" | jq -Rs .)}" 2>/dev/null || echo "000")
    if [[ "$http_code" == "201" || "$http_code" == "204" ]]; then
      printf '  %s✓ setada%s variable do Forgejo Actions %s\n' "$GREEN" "$RESET" "$name"
      return
    fi
  fi
  SKIPPED+=("Variable do Forgejo Actions $name (defina manualmente: repo → Settings → Actions → Variables)")
  warn "pulei a variable $name: Forgejo não pronto (token/owner-repo); defina depois"
}

# finish limpa a tela, então mostra um resumo final de tudo que foi configurado.
finish() {
  _clear
  printf '\n%s%s  ✓ Setup completo%s\n' "$BOLD" "$GREEN" "$RESET"
  (( ${#WRITTEN_ENV[@]} ))    && note "escreveu ${#WRITTEN_ENV[@]} valor(es) em $ENV_FILE: ${WRITTEN_ENV[*]}"
  (( ${#WRITTEN_SECRET[@]} )) && note "setou ${#WRITTEN_SECRET[@]} secret(s) do Forgejo Actions: ${WRITTEN_SECRET[*]}"
  if (( ${#SKIPPED[@]} )); then
    printf '\n'; warn "ainda falta fazer à mão:"
    for s in "${SKIPPED[@]}"; do note "  - $s"; done
  fi
  printf '\n'
}

# ──────────────────────────────────────────────────────────────────────────
# STAGES: escreva esta seção. Um stage() por passo que o humano dá.
# Substitua o exemplo abaixo. Ajuste TOTAL_STAGES para os estágios escritos.
# ──────────────────────────────────────────────────────────────────────────

TOTAL_STAGES=1

banner "Setup do Stripe"

# ── Estágio de exemplo: substitua pelos seus passos reais ─────────────────
stage "Stripe: API keys"
say "Vamos pegar suas chaves de teste do Stripe e guardá-las para dev local + CI."
open_url "https://dashboard.stripe.com/test/apikeys"
step "Na página de API keys, copie a Publishable key (começa com pk_test_)."
ask STRIPE_PUBLISHABLE_KEY "Cole a publishable key:"
step "Clique em 'Reveal test key' na linha da Secret key, depois copie."
ask_secret STRIPE_SECRET_KEY "Cole a secret key:"
write_env STRIPE_PUBLISHABLE_KEY "$STRIPE_PUBLISHABLE_KEY"
write_env STRIPE_SECRET_KEY "$STRIPE_SECRET_KEY"
set_secret STRIPE_SECRET_KEY "$STRIPE_SECRET_KEY"   # o CI precisa desta
# ──────────────────────────────────────────────────────────────────────────

finish
