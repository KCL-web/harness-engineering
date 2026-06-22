---
name: workflow-prs
description: Como abrir PR no harness (título em Conventional Commits, body com Closes #N, validação obrigatória). Cobre PR feat/* → develop (obrigatório antes de In Review) e PR develop → main (produção). Invoque ao abrir PR, escrever título/body, ou diagnosticar PR rejeitado.
---

# Workflow: PRs

## Quando abrir cada tipo de PR

- **`feat/*` (ou `fix/*`, `chore/*`, etc.) → `develop`**: obrigatório antes de mover issue para In Review.
- **`develop` → `main`**: obrigatório antes de deployar para produção. Aprovação do senior necessária.

## Título do PR

Mesmo formato de Conventional Commits (ver `workflow-commits`):

```
feat(webhook): add github signature verification
fix(report): handle missing startTime
chore: add vitest configuration
```

- Em inglês, lowercase, sem ponto no fim.
- Máximo 72 caracteres.

## Body do PR

```markdown
## Summary
- <ponto 1 do que mudou>
- <ponto 2>

## Test plan
- [ ] <passo 1 de teste manual ou automatizado>
- [ ] <passo 2>
- [ ] Comando de validação do projeto passou
- [ ] Nenhuma métrica em `.harness/baseline.json` regrediu

Closes #<numero>
Closes #<outro-numero-se-houver>
```

## Regras

- Cada issue fechada precisa de uma linha `Closes #N` **separada** (uma por linha). Um PR pode fechar várias issues relacionadas.
- PR sem `Closes #N` em pelo menos uma issue não deve ser aprovado (exceção: PR `develop → main`, que agrega várias).
- PR em que o comando de validação do projeto falha **nunca** é aprovado.
- PR não pode mergear em `develop` enquanto qualquer feature linkada tiver `verified: false` no `feature_list.json`.
- Nenhuma métrica em `baseline.json` pode regredir sem motivo documentado no body do PR e no build log (`.gsd/progress/`).
- Nunca force push (`push --force`) em `main` ou `develop`. Em branches `feat/*` próprias, só se o dev pedir.
- Nunca skip hooks (`--no-verify`) a menos que o dev peça explicitamente.

## Abrir PR

**Via web UI** (recomendado):
```
https://git.kcl.net.br/<owner>/<repo>/compare/develop...<sua-branch>
```

**Via API** (para automação):

```bash
curl -s -X POST \
  -H "Authorization: token $FORGEJO_TOKEN" \
  -H "Content-Type: application/json" \
  "https://git.kcl.net.br/api/v1/repos/$FORGEJO_ORG/<repo>/pulls" \
  -d "{
    \"title\": \"feat(scope): description\",
    \"body\": \"## Summary\n- ...\n\n## Test plan\n- [ ] ...\n\nCloses #N\",
    \"head\": \"feat/minha-branch\",
    \"base\": \"develop\"
  }" | jq '{number, title, html_url}'
```

Para PR `develop → main`:

```bash
curl -s -X POST \
  -H "Authorization: token $FORGEJO_TOKEN" \
  -H "Content-Type: application/json" \
  "https://git.kcl.net.br/api/v1/repos/$FORGEJO_ORG/<repo>/pulls" \
  -d "{
    \"title\": \"release: <data ou versão>\",
    \"body\": \"...\",
    \"head\": \"develop\",
    \"base\": \"main\"
  }" | jq '{number, title, html_url}'
```

## Merge automático feat/* → develop

PRs de `feat/*` (ou `fix/*`, `chore/*`, etc.) com destino a `develop` podem ser mergeados pelo próprio dev assim que:

1. O dev testou as alterações na branch localmente ou em ambiente de preview.
2. O dev aprovou o PR (review de si mesmo ou de outro membro, dependendo do projeto).
3. Todos os checks de CI passaram (validação do projeto verde).
4. Nenhum item do **Test plan** no body do PR está pendente.

Nesse cenário, **não é necessário aguardar aprovação de senior** — o dev pode mergear imediatamente após aprovar.

> PRs de `develop → main` ainda exigem aprovação de senior (produção).

## Ao receber feedback no PR

- Mudanças requeridas → mover issue de volta para **In Progress**. Endereçar feedback, push, comentar com resumo do que mudou. Mover de volta para **In Review**.
- Aprovado (feat/* → develop) → dev pode mergear diretamente. Issue vira **Done** automaticamente (pelo `Closes #N`).
- Aprovado (develop → main) → senior faz o merge.

## Skills relacionadas

- Mensagem do commit que vai compor o PR: `workflow-commits`
- Estratégia de branches: `workflow-branching`
- Mover issue para In Review após abrir PR: `workflow-project-board`
- Ratchet de qualidade que bloqueia merge: `ratchet-feature-list`
