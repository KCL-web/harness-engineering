# Mapeamento e ciclo de vida

Referência de `workflow-issues`. Volte ao [índice](../SKILL.md) para o quando-invocar.

## Mapeamento ROADMAP → Forgejo

A hierarquia do ROADMAP é **Milestone (M01) > Sprint (S02) > Task (T01)**. Forgejo só tem milestones (um nível), então:

| Conceito do ROADMAP | Representação no Forgejo |
| --- | --- |
| Milestone `M01` | **Milestone** com título `M01 — <nome>` |
| Sprint `S02` | **Label** `sprint/M01-S02` na issue |
| Task `T01` | **Issue**, com marcador `Task: M01-S02-T01` na 1ª linha do body |

## Status sem board

Não existe coluna. O estado de uma issue é lido de sinais nativos:

| Estado | Como se reconhece |
| --- | --- |
| A fazer | Issue **aberta**, sem branch, sem label `priority` |
| Próxima | Issue aberta com label `priority` (deve ser pega em seguida) |
| Em progresso | Existe uma branch (`feat/*`, `fix/*`, …) para o trabalho da issue |
| Em review | Existe uma **PR aberta** com `Closes #N` apontando para a issue |
| Done | Issue **fechada** (automático quando a PR com `Closes #N` mergeia) |

Prioridade é o **único** controle manual: adicione o label `priority` às poucas issues que devem ser pegadas em seguida; remova quando não forem mais a próxima coisa. Sem prioridade = backlog.

## Regras

- A issue só "entra em review" quando há PR aberta — e isso é automático: a PR existe, logo está em review.
- A issue só fecha via `Closes #N` na PR mergeada. Não feche issue à mão para "marcar como done".
- Issue criada pela sincronia ROADMAP→Forgejo carrega `Task: <MID>-<SID>-<TID>` na 1ª linha do body (rastreável; impede duplicata) + milestone do `M0X` + label `sprint/M0X-S0X`.
- Issue criada manualmente que cobre uma task do ROADMAP também adiciona o marcador `Task:`, a milestone e o label de sprint.
- Direção da sincronia é **só** ROADMAP → Forgejo. Nunca apague/feche issues para refletir mudanças no ROADMAP.
- **Ao pegar uma issue, atribua-a (assign) ao usuário do dev imediatamente.** Se o usuário não for conhecido, peça que ele informe o username antes de continuar. Issue sem assignee não pode entrar em progresso.
