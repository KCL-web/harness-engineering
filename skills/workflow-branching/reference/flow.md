# Fluxo completo do dev

Referência de `workflow-branching`. Volte ao [índice](../SKILL.md) para o quando-invocar.

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
