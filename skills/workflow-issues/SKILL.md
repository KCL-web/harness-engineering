---
name: workflow-issues
description: Issues, milestones e sprints no Forgejo (sem project board). Template de issue, marcador Task, mapeamento ROADMAP (milestone = M0X, sprint = label sprint/M0X-S0X), status implícito por branch/PR + label priority, e sincronia determinística ROADMAP → Forgejo via API. Invoque ao abrir issue, criar/sincronizar milestones e labels, priorizar, ou diagnosticar "task do ROADMAP sem issue".
---

# Workflow: issues, milestones e sprints

O Forgejo deste workspace **não usa project board**. Trabalhamos com **issues, milestones, sprints (labels) e branches** — nada de colunas/kanban. Status não é uma coluna; é inferido de sinais nativos (issue aberta/fechada, branch existe, PR aberta) mais um único label `priority`.

GitHub é **só espelho de backup** — nunca opere issues/milestones nele.

## Referência

| Arquivo | Conteúdo |
| --- | --- |
| [reference/template.md](reference/template.md) | Template de issue obrigatório (seções, marcador `Task:`) |
| [reference/lifecycle.md](reference/lifecycle.md) | Mapeamento ROADMAP → Forgejo, status sem board, regras |
| [reference/forgejo-commands.md](reference/forgejo-commands.md) | Variáveis de ambiente, assign via API, sincronia ROADMAP → Forgejo passo a passo |

## Skills relacionadas

- Criar branch a partir da issue: `workflow-branching`
- Abrir PR que fecha a issue: `workflow-prs`
- Mensagem de commit: `workflow-commits`
- Features e critérios: `ratchet-feature-list`
