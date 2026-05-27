---
name: workflow-issues
description: Issues, milestones e sprints no Forgejo (sem project board). Template de issue, marcador Task, mapeamento ROADMAP (milestone = M0X, sprint = label sprint/M0X-S0X), status implícito por branch/PR + label priority, e sincronia determinística ROADMAP → Forgejo via API. Invoque ao abrir issue, criar/sincronizar milestones e labels, priorizar, ou diagnosticar "task do ROADMAP sem issue".
---

# Workflow: issues, milestones e sprints

O Forgejo deste workspace **não usa project board**. Trabalhamos com **issues, milestones, sprints (labels) e branches** — nada de colunas/kanban. Status não é uma coluna; é inferido de sinais nativos (issue aberta/fechada, branch existe, PR aberta) mais um único label `priority`.

GitHub é **só espelho de backup** — nunca opere issues/milestones nele.

## Variáveis de ambiente

```bash
export FORGEJO_TOKEN=seu_token   # Settings → Applications → Generate Token
export FORGEJO_URL=https://git.kcl.net.br
export FORGEJO_ORG=kcl-web
```

## Mapeamento ROADMAP → Forgejo

A hierarquia do ROADMAP é **Milestone (M01) > Sprint (S02) > Task (T01)**. Forgejo só tem milestones (um nível), então:

| Conceito do ROADMAP | Representação no Forgejo |
| --- | --- |
| Milestone `M01` | **Milestone** com título `M01 — <nome>` |
| Sprint `S02` | **Label** `sprint/M01-S02` na issue |
| Task `T01` | **Issue**, com marcador `Task: M01-S02-T01` na 1ª linha do body |

## Template

Toda issue do harness precisa ter estas seções (template em `.forgejo/ISSUE_TEMPLATE/default.md`):

```markdown
Task: M01-S02-T01     ← primeira linha, marcador para sincronia ROADMAP↔Forgejo

## Descrição
Sobre o que é esta issue. Um parágrafo curto, linguagem direta.

## Situação atual
O que existe hoje. O que está faltando ou quebrado.

## O que implementar
Descrição detalhada da solução esperada. Especifique arquivos, funções, comportamento.

## Escopo
- [ ] Backend
- [ ] Frontend
- [ ] Ambos

## Feature(s)
IDs de feature do `.harness/feature_list.json` que esta issue implementa ou verifica.
Vazio se for trabalho puramente de tooling/chore sem feature de usuário.

- F001
- F002

## Critérios de aceitação
Checklist. Só fecha quando todo item está marcado.

- [ ] Critério um (específico e verificável)
- [ ] Critério dois
- [ ] Comando de validação do projeto passa
- [ ] Todas features linkadas em `.harness/feature_list.json` têm `implemented: true` (dev) e `verified: true` (QA)
- [ ] Nenhuma métrica em `.harness/baseline.json` regrediu
- [ ] PR referencia esta issue com `Closes #N`
```

## Status sem board

Não existe coluna. O estado de uma issue é lido de sinais nativos:

| Estado | Como se reconhece |
| --- | --- |
| A fazer | Issue **aberta**, sem branch, sem label `priority` |
| Próxima | Issue aberta com label `priority` (deve ser pega em seguida) |
| Em progresso | Existe uma branch (`feat/*`, `fix/*`, …) para o trabalho da issue |
| Em review | Existe uma **PR aberta** com `Closes #N` apontando para a issue |
| Done | Issue **fechada** (automático quando a PR com `Closes #N` mergeia) |

Prioridade é o **único** controle manual: adicione o label `priority` às poucas issues que devem ser pegadas em seguida; remova quando não forem mais a próxima coisa. Sem prioridade = backlog.

## Regras

- A issue só "entra em review" quando há PR aberta — e isso é automático: a PR existe, logo está em review.
- A issue só fecha via `Closes #N` na PR mergeada. Não feche issue à mão para "marcar como done".
- Issue criada pela sincronia ROADMAP→Forgejo carrega `Task: <MID>-<SID>-<TID>` na 1ª linha do body (rastreável; impede duplicata) + milestone do `M0X` + label `sprint/M0X-S0X`.
- Issue criada manualmente que cobre uma task do ROADMAP também adiciona o marcador `Task:`, a milestone e o label de sprint.
- Direção da sincronia é **só** ROADMAP → Forgejo. Nunca apague/feche issues para refletir mudanças no ROADMAP.

---

## Sincronia ROADMAP → Forgejo

Procedimento determinístico que roda no fim do bootstrap e no início de cada sessão. Verifica/cria milestones, labels e issues a partir do `.gsd/ROADMAP.md`.

### Verificação no início da sessão

Antes de qualquer trabalho de issue/branch/PR, confirme que o token responde e que as milestones do ROADMAP existem:

```bash
curl -s -H "Authorization: token $FORGEJO_TOKEN" \
  "$FORGEJO_URL/api/v1/repos/$FORGEJO_ORG/<repo>/milestones?state=all" \
  | jq '[.[] | {id, title, state}]'
```

Se faltar milestone do ROADMAP, rode a sincronia abaixo antes de continuar.

### Passo 1 — Milestones (= M0X do ROADMAP)

Se a milestone (título `M01 — <nome>`) não existe, criar:

```bash
curl -s -X POST \
  -H "Authorization: token $FORGEJO_TOKEN" \
  -H "Content-Type: application/json" \
  "$FORGEJO_URL/api/v1/repos/$FORGEJO_ORG/<repo>/milestones" \
  -d '{
    "title": "M01 — Core pipeline",
    "description": "Goal: ... · Shippable when: ..."
  }' | jq '{id, title}'
```

Guarde os IDs das milestones em `.gsd/STACK.md` (seção "Notas") — necessários para criar issues.

**Fechar milestone quando 100%.** Uma milestone cujas issues estão **todas fechadas** (0 abertas) está concluída e **pode ser fechada**. Cheque a contagem e, se `open_issues == 0` e houver pelo menos uma issue fechada, feche-a:

```bash
# Contagem da milestone (open_issues / closed_issues)
curl -s -H "Authorization: token $FORGEJO_TOKEN" \
  "$FORGEJO_URL/api/v1/repos/$FORGEJO_ORG/<repo>/milestones/<milestone-id>" \
  | jq '{title, open_issues, closed_issues, state}'

# Se open_issues == 0 (e closed_issues > 0): fechar
curl -s -X PATCH \
  -H "Authorization: token $FORGEJO_TOKEN" \
  -H "Content-Type: application/json" \
  "$FORGEJO_URL/api/v1/repos/$FORGEJO_ORG/<repo>/milestones/<milestone-id>" \
  -d '{"state": "closed"}' | jq '{title, state}'
```

Não feche milestone que ainda tem issue aberta. Fechar a milestone é o sinal de marco entregue — faça-o quando a sincronia detectar 100%, e reporte no resumo ao dev.

### Passo 2 — Labels (tipo, sprint, priority)

Listar labels existentes:

```bash
curl -s -H "Authorization: token $FORGEJO_TOKEN" \
  "$FORGEJO_URL/api/v1/repos/$FORGEJO_ORG/<repo>/labels" | jq '[.[] | {id, name}]'
```

Garanta que estes labels existem (crie os que faltarem):

- **Tipo** — um por tipo de Conventional Commit relevante: `feat`, `fix`, `chore`, `refactor`, `test`, `docs`.
- **Sprint** — um por sprint do ROADMAP: `sprint/M01-S01`, `sprint/M01-S02`, …
- **Priority** — exatamente um: `priority` (marca o que pegar em seguida).

```bash
curl -s -X POST \
  -H "Authorization: token $FORGEJO_TOKEN" \
  -H "Content-Type: application/json" \
  "$FORGEJO_URL/api/v1/repos/$FORGEJO_ORG/<repo>/labels" \
  -d '{"name": "sprint/M01-S02", "color": "#5319e7"}' | jq '{id, name}'
```

Guarde os IDs dos labels junto dos IDs de milestone em `.gsd/STACK.md`.

### Passo 3 — Issues por task

Para cada task do ROADMAP (`M01-S02-T01: ...`):

1. Buscar pelo marcador (evita duplicata) — aberta **e** fechada:

```bash
curl -s -H "Authorization: token $FORGEJO_TOKEN" \
  "$FORGEJO_URL/api/v1/repos/$FORGEJO_ORG/<repo>/issues?type=issues&state=all&limit=50&page=1" \
  | jq '[.[] | select(.body | contains("Task: M01-S02-T01")) | {number, title}]'
```

2. Se já existe → **pular**.

3. Se não existe, criar (substituir `<milestone-id>`, `<type-label-id>` e `<sprint-label-id>` pelos IDs capturados):

```bash
curl -s -X POST \
  -H "Authorization: token $FORGEJO_TOKEN" \
  -H "Content-Type: application/json" \
  "$FORGEJO_URL/api/v1/repos/$FORGEJO_ORG/<repo>/issues" \
  -d '{
    "title": "feat(scope): T01 - descrição",
    "body": "Task: M01-S02-T01\n\n## Descrição\n...",
    "milestone": <milestone-id>,
    "labels": [<type-label-id>, <sprint-label-id>]
  }' | jq '{number, title, html_url}'
```

Issues novas da sincronia entram **sem** label `priority` (= backlog). A priorização é manual, depois.

## Resumo ao dev após sincronia

```
Sincronia ROADMAP → Forgejo:
- Milestones criadas: M01, M02
- Milestones puladas (já existiam): M03
- Milestones fechadas (100% concluídas): M00
- Labels criados: sprint/M01-S02, priority
- Issues criadas: 12 (#NN..#NN)
- Issues puladas (marcador Task: já existia): 5
- Tasks no ROADMAP sem issue após sincronia: 0
```

Se algum passo falhou (token sem scope, milestone com nome divergente, curl falhando), pare e mostre o erro — não tente workarounds destrutivos.

## Skills relacionadas

- Criar branch a partir da issue: `workflow-branching`
- Abrir PR que fecha a issue: `workflow-prs`
- Mensagem de commit: `workflow-commits`
- Features e critérios: `ratchet-feature-list`
