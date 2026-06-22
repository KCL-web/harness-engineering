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

- `main` e `develop` são **protegidas**. Nunca push direto.
- Sempre criar branch a partir de `develop`, **nunca** de `main`.
- **Naming: kebab-case curto descrevendo o trabalho. NUNCA use número de issue no nome da branch.**
- O tipo da branch precisa bater com o tipo dominante da issue (feat/fix/chore/etc).
- Uma branch pode fechar várias issues relacionadas — listar com `Closes #N` separadas no body do PR.

> **Regra de ouro de naming:** o nome da branch deve descrever *o que o trabalho faz*, não *qual issue ele resolve*.
> `feat/login-oauth` é sempre certo. `feat/issue-42` é sempre errado — mesmo que descreva a issue 42.

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
feat/issue-42          ← PROIBIDO: nunca use número de issue
feat/#42               ← PROIBIDO: nunca use número de issue
fix/42-missing-time    ← PROIBIDO: número de issue no início também não
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

```
issue criada (Backlog)
   ↓
issue priorizada (Ready → Priority)
   ↓
branch criada a partir de develop
   ↓
issue movida para In Progress (Forgejo Project board)
   ↓
trabalho local → comando de validação do projeto passa
   ↓
commit(s) → push → PR feat/* → develop
   ↓
issue movida para In Review
   ↓
PR aprovado → merge → develop deployado e validado
   ↓
PR de develop → main (aprovação do senior)
   ↓
PR aprovado → merge → main deployado
   ↓
issue movida para Done
```

## Skills relacionadas

- Mensagem de commit: `workflow-commits`
- Abrir PR: `workflow-prs`
- Mover issue entre colunas do project: `workflow-project-board`
- Template de issue: `workflow-issues`
