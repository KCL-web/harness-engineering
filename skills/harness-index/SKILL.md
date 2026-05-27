---
name: harness-index
description: Índice das skills do harness-engineering. Carrega regras universais (branches develop/main, sessões dev/QA, validação antes de commit) e aponta para skills específicas (workflow-*, stack-*, ratchet-*). Invoque sempre que iniciar uma sessão em projeto que contém .gsd/ ou .harness/, ou quando o dev mencionar "harness".
---

# Harness Index

Você está em um projeto que usa o **harness-engineering**. Este índice carrega regras universais e descreve quando invocar cada skill específica.

## Como o harness funciona

O harness organiza desenvolvimento em **sessões** restritas por contratos legíveis por máquina:

| Sessão | Lê | Escreve |
| --- | --- | --- |
| **Dev** | issue, `.harness/feature_list.json`, `.harness/baseline.json`, `.gsd/` | código, vira `implemented: true`, atualiza baseline se métricas melhoraram |
| **QA**  | AGENTS.md, STACK.md, CONVENTIONS.md, feature_list.json | vira `verified: true` **somente** depois de rodar cada critério contra a app viva |

A separação impede que o QA seja "convencido" pela sessão dev — ele só checa critérios literais do `feature_list.json`.

## Regras universais (todas as sessões)

- O comando de validação do projeto (ver `.gsd/STACK.md`) precisa passar antes de cada commit.
- Sem `any`/escape hatches no type system. Sem código comentado em commits. Sem debug prints.
- Conteúdo de documentação em **português-BR**. Identificadores técnicos (tipo de commit, slug de branch, label de issue) em **inglês**.
- No fim de cada sessão, **mostre ao dev** o conteúdo atualizado de `.gsd/progress/<MID>-<SID>.md` para ele colar manualmente. Você **não** escreve sozinho em `.gsd/` fora do bootstrap inicial.
- Antes de qualquer trabalho com issue/branch/PR, verifique se as milestones do ROADMAP existem no Forgejo — se faltar, rode a sincronia em `workflow-issues`. (Sem project board: trabalhamos com issues, milestones, sprints-como-label e branches. GitHub é só espelho de backup.)
- No início de toda sessão, execute o ritual de abertura (`session-rituals` → wake-up + search direcionado). Antes de propor decisão arquitetural, search antes — se há decisão prévia, exponha-a literalmente.
- No fim de toda sessão (sinalizado pelo dev), execute o ritual de fechamento (recap de decisões → drawers explícitos → progress log).

## Skills específicas — quando invocar cada

| O dev pediu… | Invoque |
| --- | --- |
| Criar branch, naming, hierarquia develop/main | `workflow-branching` |
| Abrir/priorizar issue, template, milestones, sprints, sincronia ROADMAP → Forgejo | `workflow-issues` |
| Abrir PR, `Closes #N`, validação | `workflow-prs` |
| Mensagem de commit (Conventional Commits) | `workflow-commits` |
| Adicionar feature, atualizar baseline, ratchet | `ratchet-feature-list` |
| Código frontend (React, Vite, SCSS, RHF, zod, BEM, aliases) | `stack-react-vite-scss` |
| Código backend (Django, DRF, JWT) | `stack-django-drf-jwt` |
| Memória cross-projeto (wings/rooms/drawers, MemPalace) | `memory-palace` |
| Rituais de início/fim de sessão (wake-up, search, drawer recap) | `session-rituals` |
| Skills auto-evolutivas (FIX/DERIVED/CAPTURED, OpenSpace) | `evolving-skills` |

## Onde buscar configuração do projeto

- `.gsd/STACK.md` — stack, comando de validação, env vars, notas do projeto
- `.gsd/CONVENTIONS.md` — convenções da stack (em projetos v2 isso vira referência ao archetype global)
- `.gsd/SPEC.md` — visão e capacidades
- `.gsd/ROADMAP.md` — milestones, sprints, tasks
- `.harness/feature_list.json` — features + critérios verificáveis
- `.harness/baseline.json` — métricas que só podem melhorar

## Acompanhamento de progresso

No fim da sessão, atualize `.gsd/progress/<MID>-<SID>.md`:

1. Marque tarefas concluídas no checklist do contrato.
2. Anexe ao build log: `- YYYY-MM-DD: <o que foi feito, uma linha por tarefa>`.
3. Se uma tarefa não foi concluída, explique por quê e o que está bloqueando.
4. Nunca marque tarefa pronta se o comando de validação do projeto não passou.

Você **mostra** o conteúdo ao dev. Ele cola. Você não escreve em `.gsd/` direto fora do bootstrap.
