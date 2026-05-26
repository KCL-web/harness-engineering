---
name: workflow-project-board
description: Bootstrap do Forgejo Project (6 colunas padrão), sincronia ROADMAP → milestones/issues, e operações via Forgejo API. Invoque quando o dev pedir para criar project, sincronizar roadmap, mover issue de coluna, configurar campos, ou diagnosticar "project ausente".
---

# Workflow: Forgejo Project board

## Variáveis de ambiente necessárias

```bash
export FORGEJO_TOKEN=seu_token   # Settings → Applications → Generate Token
export FORGEJO_URL=https://git.kcl.net.br
export FORGEJO_ORG=kcl-web
```

## Verificação no início da sessão

Antes de qualquer trabalho com issue/branch/PR, verifique se o Project existe:

```bash
curl -s -H "Authorization: token $FORGEJO_TOKEN" \
  "$FORGEJO_URL/api/v1/repos/$FORGEJO_ORG/<repo>/projects" | jq '.[].name'
```

Se não retornar nenhum project, criar via web UI antes de continuar:
**`https://git.kcl.net.br/<owner>/<repo>/projects`** → "New Project"

## Bootstrap — criar project do zero

O project board no Forgejo é criado e configurado pela **web UI**:

1. Acesse `https://git.kcl.net.br/<owner>/<repo>/projects` → **"New Project"**
2. Crie as 6 colunas padrão (nessa ordem):

| Coluna | Significado |
| --- | --- |
| Backlog | Issue criada, ainda não avaliada |
| Ready | Avaliada, clara o bastante para começar |
| Priority | Ready e deve ser pegada em seguida |
| In Progress | Branch criada, em trabalho ativo |
| In Review | PR aberta, esperando revisão do orquestrador |
| Done | PR mergeada em develop, issue fechada |

## Sincronia ROADMAP → Forgejo

Procedimento determinístico que roda no fim do bootstrap e no início de cada sessão.

### Passo 1 — Milestones

Listar milestones existentes:

```bash
curl -s -H "Authorization: token $FORGEJO_TOKEN" \
  "$FORGEJO_URL/api/v1/repos/$FORGEJO_ORG/<repo>/milestones" \
  | jq '[.[] | {id, title, state}]'
```

Se a milestone (título "M01 — <nome>") não existe, criar:

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

### Passo 2 — Labels

Listar labels existentes:

```bash
curl -s -H "Authorization: token $FORGEJO_TOKEN" \
  "$FORGEJO_URL/api/v1/repos/$FORGEJO_ORG/<repo>/labels" | jq '[.[] | {id, name}]'
```

Criar label se não existir:

```bash
curl -s -X POST \
  -H "Authorization: token $FORGEJO_TOKEN" \
  -H "Content-Type: application/json" \
  "$FORGEJO_URL/api/v1/repos/$FORGEJO_ORG/<repo>/labels" \
  -d '{"name": "feat", "color": "#0075ca"}' | jq '{id, name}'
```

### Passo 3 — Issues por task

Para cada task do ROADMAP (`M01-S02-T01: ...`):

1. Buscar pelo marcador (evita duplicata):

```bash
curl -s -H "Authorization: token $FORGEJO_TOKEN" \
  "$FORGEJO_URL/api/v1/repos/$FORGEJO_ORG/<repo>/issues?type=issues&state=open&limit=50&page=1" \
  | jq '[.[] | select(.body | contains("Task: M01-S02-T01")) | {number, title}]'
# Repetir com state=closed para issues fechadas
```

2. Se já existe → **pular**.

3. Se não existe, criar (substituir `<milestone-id>` e `<label-id>` pelos IDs capturados):

```bash
curl -s -X POST \
  -H "Authorization: token $FORGEJO_TOKEN" \
  -H "Content-Type: application/json" \
  "$FORGEJO_URL/api/v1/repos/$FORGEJO_ORG/<repo>/issues" \
  -d '{
    "title": "feat(scope): T01 - descrição",
    "body": "Task: M01-S02-T01\n\n## Descrição\n...",
    "milestone": <milestone-id>,
    "labels": [<label-id>]
  }' | jq '{number, title, html_url}'
```

4. Adicionar ao Project via web UI: acesse a issue e use o painel lateral "Projects".

## Mover issue entre colunas

No Forgejo, o project board é gerenciado pela web UI:
**`https://git.kcl.net.br/<owner>/<repo>/projects`**

Arraste a issue para a coluna correta.

## Regras

- Project precisa existir **antes** de qualquer trabalho de issue/branch.
- Direção da sincronia é **só** ROADMAP → Forgejo. Nunca apague/feche issues para refletir mudanças no ROADMAP.
- Issues novas criadas pela sincronia entram em `Backlog`, sem priority, sem branch. Milestone correspondente já linkada.
- Issue com marcador `Task: <MID>-<SID>-<TID>` não deve ser duplicada — a sincronia procura o marcador antes de criar.

## Resumo ao dev após sincronia

```
Sincronia ROADMAP → Forgejo:
- Project: <criado | já existia> (<url>)
- Milestones criadas: M01, M02
- Milestones puladas (já existiam): M03
- Issues criadas: 12 (#NN..#NN)
- Issues puladas (marcador Task: já existia): 5
- Tasks no ROADMAP sem issue após sincronia: 0
```

Se algum passo falhou (token sem scope, milestone com nome divergente, curl falhando), pare e mostre o erro — não tente workarounds destrutivos.

## Skills relacionadas

- Template de issue: `workflow-issues`
- Criar branch a partir de issue: `workflow-branching`
- Abrir PR: `workflow-prs`
