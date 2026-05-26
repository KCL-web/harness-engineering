#!/bin/bash
# Configura git user local para bater com a conta Forgejo.
# Rode uma vez em cada máquina do desenvolvedor.
set -euo pipefail

FORGEJO_URL="https://git.kcl.net.br"
FORGEJO_TOKEN="${FORGEJO_TOKEN:-}"

if [[ -n "$FORGEJO_TOKEN" ]]; then
  # Preenche automaticamente a partir do token
  USER_DATA=$(curl -s -H "Authorization: token $FORGEJO_TOKEN" "$FORGEJO_URL/api/v1/user")
  AUTO_NAME=$(echo "$USER_DATA" | jq -r '.full_name // .login')
  AUTO_EMAIL=$(echo "$USER_DATA" | jq -r '.email')
  echo "Token detectado. Usuário Forgejo: $AUTO_NAME <$AUTO_EMAIL>"
  read -rp "Usar esses dados? [S/n] " CONFIRM
  if [[ "$CONFIRM" =~ ^[Nn] ]]; then
    AUTO_NAME=""
    AUTO_EMAIL=""
  fi
fi

if [[ -z "${AUTO_NAME:-}" ]]; then
  read -rp "Nome completo (igual ao Forgejo): " AUTO_NAME
fi
if [[ -z "${AUTO_EMAIL:-}" ]]; then
  read -rp "Email (igual ao Forgejo): " AUTO_EMAIL
fi

git config --global user.name  "$AUTO_NAME"
git config --global user.email "$AUTO_EMAIL"

echo ""
echo "✓ Git configurado:"
echo "  user.name  = $(git config --global user.name)"
echo "  user.email = $(git config --global user.email)"
echo ""

# Configura credential helper para salvar token Forgejo (HTTPS)
if [[ -n "$FORGEJO_TOKEN" ]]; then
  git config --global credential.helper store

  CRED_FILE="$HOME/.git-credentials"
  FORGEJO_HOST=$(echo "$FORGEJO_URL" | sed 's|https://||')
  FORGEJO_LOGIN=$(echo "$USER_DATA" | jq -r '.login')
  CRED_LINE="https://$FORGEJO_LOGIN:$FORGEJO_TOKEN@$FORGEJO_HOST"

  if grep -qF "$FORGEJO_HOST" "$CRED_FILE" 2>/dev/null; then
    # Atualiza linha existente
    sed -i "/$FORGEJO_HOST/d" "$CRED_FILE"
  fi
  echo "$CRED_LINE" >> "$CRED_FILE"
  chmod 600 "$CRED_FILE"
  echo "✓ Credencial salva em $CRED_FILE (push/pull sem digitar senha)"
fi

echo ""
echo "Próximo passo: aponte o remote origin dos repos para o Forgejo:"
echo "  git remote set-url origin $FORGEJO_URL/kcl-web/NOME-DO-REPO.git"
