---
name: ratchet-feature-list
description: Como manter .harness/feature_list.json (features com critérios verificáveis) e .harness/baseline.json (métricas de qualidade que só podem melhorar). Define quem escreve o quê (dev vs QA), regras inegociáveis e validação via check-harness.sh. Invoque quando o dev pedir para adicionar feature, atualizar baseline, ou diagnosticar PR bloqueado por feature não verificada.
---

# Ratchet: feature_list e baseline

Dois contratos legíveis por máquina em `.harness/` que ligam **sessões dev** e **sessões QA**.

## .harness/feature_list.json

Cada feature do projeto, com critérios observáveis que a sessão QA verifica contra a app rodando.

```json
{
  "features": [
    {
      "id": "F001",
      "title": "Login com email/senha",
      "criteria": [
        "Usuário consegue submeter formulário com email válido e senha",
        "Token JWT é armazenado em httpOnly cookie",
        "Redirect para /dashboard após sucesso"
      ],
      "implemented": false,
      "verified": false
    }
  ]
}
```

## .harness/baseline.json

Valores atuais de métricas de qualidade que **só podem melhorar** (quality ratchet).

```json
{
  "metrics": {
    "tests_passing": 142,
    "tests_total": 142,
    "coverage_pct": 78.4,
    "lint_warnings": 0,
    "type_errors": 0
  }
}
```

## Quem escreve o quê

| Quem | Escreve | Não pode |
| --- | --- | --- |
| **Dev** | código, `implemented: true`, atualizar `baseline.json` se métricas melhoraram | editar `title`/`criteria[]` de feature existente, virar `verified: true`, baixar métrica do baseline sem motivo no build log |
| **QA** | `verified: true` (ou notas em falha), atualizar progresso | implementar código, "concordar" com o dev sem rodar critérios contra a app viva |

## Regras inegociáveis

- `title` e `criteria[]` de uma feature ficam **congelados** após a issue ser aberta. Se o requisito mudar de verdade: feche a feature e crie uma nova com novo ID.
- PR **não pode mergear** em `develop` enquanto qualquer feature linkada tiver `verified: false`.
- Nenhuma métrica em `baseline.json` pode regredir sem motivo documentado no body do PR e no build log do mesmo PR.
- Sessão dev **nunca** vira `verified: true` — isso é só de QA.
- Todo PR voltado para usuário precisa linkar ao menos um feature ID; PRs de chore/tooling/refactor podem não ter nenhum.

## Validação

`scripts/check-harness.sh` valida:

- JSON válido em `feature_list.json` e `baseline.json`
- Integridade do schema
- `title` e `criteria[]` **congelados** em features existentes (compara com branch base)
- Sem remoção de feature
- Sem regressão de métrica `baseline` vs branch base

Roda:

- Local: `bash scripts/check-harness.sh`
- CI: `.forgejo/workflows/harness-gate.yml` em todo PR para `main` ou `develop`

## Fluxo

```
Issue aberta com Feature(s) listadas no body
   ↓
Sessão dev implementa, marca implemented: true
   ↓
Atualiza baseline.json se métricas melhoraram
   ↓
PR aberto → CI valida via check-harness.sh
   ↓
Senior aprova merge em develop
   ↓
Sessão QA roda critérios contra app rodando em develop
   ↓
QA marca verified: true (ou adiciona notes em falha)
   ↓
PR develop → main pode mergear (só agora)
```

## Por que duas sessões, dois arquivos

A sessão QA **não tem memória** da conversa do dev. Ela não pode ser "convencida" — só consegue ler o texto literal de `criteria[]` e tentar reproduzir contra a app viva. Isso impede falsos positivos onde o dev pensa que entregou mas faltou algo.

## Skills relacionadas

- Workflow de PR (validação bloqueante): `workflow-prs`
- Template de issue (campo `Feature(s)`): `workflow-issues`
- Quem escreve em `.gsd/progress`: `harness-index`
