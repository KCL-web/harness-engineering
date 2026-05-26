---
name: workflow-project-board
description: Bootstrap do GitHub Project (6 colunas padrão), sincronia ROADMAP → milestones/issues, e automação via gh CLI. Invoque quando o dev pedir para criar project, sincronizar roadmap, mover issue de coluna, configurar campos, ou diagnosticar "project ausente".
---

# Workflow: GitHub Project board

## Verificação no início da sessão

Antes de qualquer trabalho com issue/branch/PR, verifique se o Project existe:

```bash
gh project list --owner <owner>
```

Se nenhum project corresponde ao repo, criar antes de qualquer outro trabalho.

## Bootstrap — criar project do zero

### 1. Criar

```bash
gh project create --owner <owner> --title "<repo-name>"
```

### 2. Linkar ao repositório

```bash
gh project link <project-number> --owner <owner> --repo <repo>
```

### 3. Configurar campos padrão

- **Status** (single select): 6 colunas, nesta ordem exata
- **Type** (single select): `feat`, `fix`, `chore`, `refactor`, `test`, `docs`
- **Priority** (single select): `low`, `medium`, `high`

## Colunas padrão (6, nesta ordem)

| Coluna | Significado |
| --- | --- |
| Backlog | Issue criada, ainda não avaliada |
| Ready | Avaliada, clara o bastante para começar |
| Priority | Ready e deve ser pegada em seguida |
| In Progress | Branch criada, em trabalho ativo |
| In Review | PR aberta, esperando revisão do orquestrador |
| Done | PR mergeada em develop, issue fechada |

## Sincronia ROADMAP → GitHub

Procedimento determinístico que roda no fim do bootstrap e no início de cada sessão.

### Passo 1 — Project

```bash
gh project list --owner <owner> --format json
```

Se nenhum project corresponde ao repo, criar (passos acima).

### Passo 2 — Milestones

Para cada milestone do `.gsd/ROADMAP.md` (M01, M02, ...):

```bash
gh api repos/<owner>/<repo>/milestones --jq '.[].title'
```

Se a milestone (título "M01 — <nome>") não existe:

```bash
gh api repos/<owner>/<repo>/milestones \
  -f title="M01 — Core pipeline" \
  -f description="Goal: ... · Shippable when: ..." \
  -f state="open"
```

### Passo 3 — Issues por task

Para cada task do ROADMAP (`M01-S02-T01: ...`):

1. Buscar pelo marcador:

   ```bash
   gh issue list --search "Task: M01-S02-T01 in:body" --state all --json number,title
   ```

2. Se já existe, **pular**.

3. Se não existe, criar:

   ```bash
   gh issue create \
     --title "<type>(<scope>): T01 - <descrição>" \
     --body "Task: M01-S02-T01

   <body do template — ver workflow-issues>" \
     --milestone "M01 — Core pipeline" \
     --label "<type>"
   ```

4. Adicionar ao Project no status `Backlog`:

   ```bash
   gh project item-add <project-number> --owner <owner> --url <issue-url>
   ```

   E setar `Status=Backlog`, `Type=<type>` via `gh project item-edit`.

## Mover issue entre colunas

```bash
gh project item-edit \
  --project-id <project-node-id> \
  --id <item-id> \
  --field-id <status-field-id> \
  --single-select-option-id <option-id-da-coluna-destino>
```

Capture os IDs estáveis no bootstrap e guarde em `.gsd/STACK.md` (seção "Notas") para reutilizar.

## Regras

- Project precisa existir **antes** de qualquer trabalho de issue/branch.
- Direção da sincronia é **só** ROADMAP → GitHub. Nunca apague/feche issues para refletir mudanças no ROADMAP.
- Issues novas criadas pela sincronia entram em `Backlog`, sem priority, sem branch. Milestone correspondente já linkada.
- Issue com marcador `Task: <MID>-<SID>-<TID>` não deve ser duplicada — a sincronia procura o marcador antes de criar.

## Resumo ao dev após sincronia

```
Sincronia ROADMAP → GitHub:
- Project: <criado | já existia> (<url>)
- Milestones criadas: M01, M02
- Milestones puladas (já existiam): M03
- Issues criadas: 12 (#NN..#NN)
- Issues puladas (marcador Task: já existia): 5
- Tasks no ROADMAP sem issue após sincronia: 0
```

Se algum passo falhou (token sem scope `project`, milestone com nome divergente, gh CLI faltando), pare e mostre o erro — não tente workarounds destrutivos.

## Skills relacionadas

- Template de issue: `workflow-issues`
- Criar branch a partir de issue: `workflow-branching`
- Abrir PR: `workflow-prs`
