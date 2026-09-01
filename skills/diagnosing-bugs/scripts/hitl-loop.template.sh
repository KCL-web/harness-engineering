#!/usr/bin/env bash
# Loop de reprodução com humano no loop (human-in-the-loop).
# Copie este arquivo, edite os passos abaixo, e rode.
# O agente roda o script; o usuário segue as instruções no próprio terminal.
#
# Uso:
#   bash hitl-loop.template.sh
#
# Dois helpers:
#   step "<instrução>"            → mostra a instrução, espera Enter
#   capture VAR "<pergunta>"      → mostra a pergunta, lê a resposta em VAR
#
# No final, os valores capturados são impressos como KEY=VALUE para o agente parsear.
#
# `capture` imprime seu valor de volta no terminal, onde o agente lê,
# então capture observações, e deixe o login a cargo do usuário como um `step`.

set -euo pipefail

step() {
  printf '\n>>> %s\n' "$1"
  read -r -p "    [Enter quando terminar] " _
}

capture() {
  local var="$1" question="$2" answer
  printf '\n>>> %s\n' "$question"
  read -r -p "    > " answer
  printf -v "$var" '%s' "$answer"
}

# --- edite abaixo --------------------------------------------------------

step "Abra o app em http://localhost:3000 e faça login."

capture ERRORED "Clique no botão 'Export'. Deu erro? (y/n)"

capture ERROR_MSG "Cole a mensagem de erro (ou 'none'):"

# --- edite acima ----------------------------------------------------------

printf '\n--- Capturado ---\n'
printf 'ERRORED=%s\n' "$ERRORED"
printf 'ERROR_MSG=%s\n' "$ERROR_MSG"
