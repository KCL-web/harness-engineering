# Hierarquia e naming

Referência de `workflow-branching`. Volte ao [índice](../SKILL.md) para o quando-invocar.

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
