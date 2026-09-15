---
name: ratchet-feature-list
description: Como manter .harness/feature_list.json (features com critérios verificáveis) e .harness/baseline.json (métricas de qualidade que só podem melhorar). Define quem escreve o quê (dev vs QA), regras inegociáveis e validação via check-harness.sh. Invoque quando o dev pedir para adicionar feature, atualizar baseline, ou diagnosticar PR bloqueado por feature não verificada.
---

# Ratchet: feature_list e baseline

Dois contratos legíveis por máquina em `.harness/` que ligam **sessões dev** e **sessões QA**.

## Referência

| Arquivo | Conteúdo |
| --- | --- |
| [reference/schemas.md](reference/schemas.md) | Schema de `feature_list.json` e `baseline.json`, com exemplo |
| [reference/ownership-and-rules.md](reference/ownership-and-rules.md) | Quem escreve o quê (dev vs QA), regras inegociáveis |
| [reference/validation-and-flow.md](reference/validation-and-flow.md) | Validação via `check-harness.sh`, fluxo completo, por que duas sessões |

## Skills relacionadas

- Workflow de PR (validação bloqueante): `workflow-prs`
- Template de issue (campo `Feature(s)`): `workflow-issues`
- Quem escreve em `.gsd/progress`: `harness-index`
