# Comandos Forgejo (API)

Referência de `workflow-issues`. Volte ao [índice](../SKILL.md) para o quando-invocar.

## Variáveis de ambiente

```bash
export FORGEJO_TOKEN=seu_token   # Settings → Applications → Generate Token
export FORGEJO_URL=https://git.kcl.net.br
export FORGEJO_ORG=kcl-web
```

## Como atribuir (assign) uma issue via API

```bash
curl -s -X PATCH \
  -H "Authorization: token $FORGEJO_TOKEN" \
  -H "Content-Type: application/json" \
  "$FORGEJO_URL/api/v1/repos/$FORGEJO_ORG/<repo>/issues/<numero>" \
  -d "{\"assignees\": [\"<username-do-dev>\"]}" | jq '{number, title, assignees: [.assignees[].login]}'
```

Se `$FORGEJO_TOKEN` ou o username não estiverem disponíveis, solicite ao dev:
```
Para continuar preciso do seu usuário no Forgejo.
Informe seu username (ou exporte FORGEJO_TOKEN) para fazer o assign da issue.
```

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
