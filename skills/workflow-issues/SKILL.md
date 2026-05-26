---
name: workflow-issues
description: Template de issue do harness (seções obrigatórias, marcador Task, link com feature_list), ciclo de vida Backlog/Ready/Priority/InProgress/InReview/Done, e regras para mover entre colunas. Invoque quando o dev pedir para abrir issue, revisar issue, ou avançar status no project.
---

# Workflow: issues

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
Checklist. Só vira Done quando todo item está marcado.

- [ ] Critério um (específico e verificável)
- [ ] Critério dois
- [ ] Comando de validação do projeto passa
- [ ] Todas features linkadas em `.harness/feature_list.json` têm `implemented: true` (dev) e `verified: true` (QA)
- [ ] Nenhuma métrica em `.harness/baseline.json` regrediu
- [ ] PR referencia esta issue com `Closes #N`
```

## Ciclo de vida no Project

| Coluna | Quando |
| --- | --- |
| Backlog | Issue criada, ainda não avaliada |
| Ready | Avaliada, clara o bastante para começar |
| Priority | Ready e deve ser pegada em seguida |
| In Progress | Branch criada, em trabalho ativo |
| In Review | PR aberta, esperando revisão do orquestrador |
| Done | PR mergeada em develop, issue fechada |

## Regras

- Issue nunca vai para **In Review** sem PR aberta.
- Issue nunca vai para **Done** sem PR mergeada.
- Issue criada pela sincronia ROADMAP→Forgejo carrega `Task: <MID>-<SID>-<TID>` na primeira linha do body (rastreável; impede duplicata).
- Issue criada manualmente também deve adicionar `Task:` se cobrir uma task do ROADMAP.
- Antes de começar a trabalhar em uma issue, mova-a para In Progress.

## Mover issue entre colunas

No Forgejo, o project board é gerenciado pela web UI:
**`https://git.kcl.net.br/<owner>/<repo>/projects`**

Arraste a issue para a coluna correta. Não há CLI equivalente ao `gh project item-edit`.

## Skills relacionadas

- Configurar colunas/projeto pela primeira vez: `workflow-project-board`
- Criar branch a partir da issue: `workflow-branching`
- Abrir PR que fecha a issue: `workflow-prs`
- Features e critérios: `ratchet-feature-list`
