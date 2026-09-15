---
name: workflow-prs
description: Como abrir PR no Forgejo (título em Conventional Commits, body com Closes #N, validação obrigatória). Cobre PR feat/* → develop (a PR aberta é o sinal de "em review") e PR develop → main (produção). Invoque ao abrir PR, escrever título/body, ou diagnosticar PR rejeitado.
---

# Workflow: PRs

## Referência

| Arquivo | Conteúdo |
| --- | --- |
| [reference/title-body.md](reference/title-body.md) | Quando abrir cada tipo de PR, formato de título e body |
| [reference/rules-and-commands.md](reference/rules-and-commands.md) | Regras inegociáveis, comandos (web UI / API Forgejo), merge automático feat/*→develop, feedback |

## Skills relacionadas

- Mensagem do commit que vai compor o PR: `workflow-commits`
- Estratégia de branches: `workflow-branching`
- Template de issue, milestones, sprints, priorização: `workflow-issues`
- Ratchet de qualidade que bloqueia merge: `ratchet-feature-list`
