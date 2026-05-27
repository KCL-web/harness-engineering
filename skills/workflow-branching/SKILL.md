---
name: workflow-branching
description: Hierarquia de branches (main, develop, feat/*, fix/*, chore/*, refactor/*, test/*, docs/*), regras de naming kebab-case curto e fluxo do dev a partir de uma issue. Invoque ao criar branch, escolher nome, ou explicar o fluxo issue → branch → PR.
---

# Workflow: branches

## Hierarquia

```
main        → produção, sempre estável e deployada
develop     → staging, espelha o que está prestes a ir para main
feat/*      → branches de feature
fix/*       → branches de bug fix
chore/*     → tooling, config, dependências
refactor/*  → mudança de código sem mudança de comportamento
test/*      → adicionar ou atualizar testes
docs/*      → só documentação
```

## Regras inegociáveis

- `main` é **protegida**. Nunca push direto.
- Sempre criar branch a partir de `develop`, **nunca** de `main`.
- Naming: kebab-case curto descrevendo o trabalho, não número da issue.
- O tipo da branch precisa bater com o tipo dominante da issue (feat/fix/chore/etc).
- Uma branch pode fechar várias issues relacionadas — listar com `Closes #N` separadas no body do PR.

### Exemplos

Bom:
```
feat/webhook-receiver
fix/missing-start-time
chore/vitest-setup
refactor/extract-issue-row
```

Ruim:
```
feat/issue-42          ← não use número, descreva o trabalho
fix-bug                ← sem prefixo de tipo
Feature/NewStuff       ← não use camelCase nem PascalCase
feat/this-branch-name-is-way-too-long-and-says-everything-it-does
```

## Criar uma branch

```bash
git checkout develop
git pull origin develop
git checkout -b feat/<short-slug>
```

## Fluxo completo do dev

Sem project board: o status é inferido dos sinais (branch existe, PR aberta, issue fechada) — ver `workflow-issues`.

```
issue criada (aberta, backlog)
   ↓
issue priorizada (recebe label `priority`)
   ↓
branch criada a partir de develop          ← issue agora "em progresso" (tem branch)
   ↓
trabalho local → comando de validação do projeto passa
   ↓
commit(s) → push → PR feat/* → develop     ← issue agora "em review" (tem PR aberta)
   ↓
PR aprovado → merge → develop deployado e validado
   ↓
PR de develop → main (aprovação do senior)
   ↓
PR aprovado → merge → main deployado
   ↓
issue fecha automaticamente (via Closes #N da PR)
```

## Skills relacionadas

- Mensagem de commit: `workflow-commits`
- Abrir PR: `workflow-prs`
- Template de issue, milestones, sprints, priorização: `workflow-issues`
