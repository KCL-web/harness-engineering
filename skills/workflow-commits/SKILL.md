---
name: workflow-commits
description: Convenção de mensagem de commit (Conventional Commits em inglês, imperativo, máximo 72 caracteres na primeira linha). Invoque quando o dev pedir para criar commit, revisar mensagem de commit, ou quando estiver prestes a commitar mudanças.
---

# Workflow: commits

**Conventional Commits em inglês.**

## Formato

```
<type>(<escopo opcional>): <descrição curta>

[body opcional, em inglês, explicando o "why" — não o "what"]
```

## Tipos permitidos

| Tipo | Quando usar |
| --- | --- |
| `feat` | nova feature |
| `fix` | bug fix |
| `chore` | tooling, config, dependências |
| `refactor` | mudança de código sem mudança de comportamento |
| `test` | adicionar ou atualizar testes |
| `docs` | só documentação |
| `style` | formatação (sem mudança de lógica) |
| `perf` | melhoria de performance |

## Regras

- Descrição em **inglês**, lowercase, sem ponto no fim.
- Modo **imperativo**: "add route", não "added route" nem "adds route".
- Primeira linha tem no máximo **72 caracteres**.
- Body opcional: explique o **why** (motivo, contexto, trade-off), não o **what** (o diff já mostra).

## Exemplos bons

```
feat(webhook): add github signature verification
fix(report): handle missing startTime in worked minutes calculation
chore: add vitest configuration
test(lib): add unit tests for calculateWorkedMinutes
refactor(dashboard): extract IssueRow into reusable component
docs(readme): add wsl2 setup instructions
perf(query): index user_id on sessions table
```

## Exemplos ruins

```
fix stuff                       ← vago, sem tipo
Adicionado novo componente      ← português, passado
update                          ← nenhuma informação
WIP                             ← nunca commitar WIP em branches publicadas
feat: Added webhook receiver.   ← passado + ponto no fim
feat(webhook): add github signature verification because we found a bug yesterday  ← excede 72 chars
```

## Por que inglês?

Conventional Commits é um padrão de **ferramentas** (changelog, release tools, GitHub filters). Parser inconsistente entre idiomas quebra essas ferramentas.

Documentação humana (SPEC, ROADMAP, descrição de PR, comentários em issue) fica em **português**. Só commit, slug de branch e título de PR são em inglês.

## Hooks

- Não pule hooks (`--no-verify`) a menos que o dev peça explicitamente. Se um hook falhou, investigue e corrija a causa.
- Não use `--amend` em commits já publicados. Crie commit novo.

## Skills relacionadas

- Estratégia de branches: `workflow-branching`
- Título e body de PR: `workflow-prs`
