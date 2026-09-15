# Validação e fluxo

Referência de `ratchet-feature-list`. Volte ao [índice](../SKILL.md) para o quando-invocar.

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
