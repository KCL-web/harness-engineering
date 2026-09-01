# Docs de domínio

Como as skills importadas devem consumir a documentação de domínio deste repo ao explorar o código.

## Antes de explorar, leia isto

- **`CONTEXT.md`** na raiz do repo, ou
- **`CONTEXT-MAP.md`** na raiz, se existir: aponta para um `CONTEXT.md` por contexto. Leia cada um relevante ao tópico.
- **`docs/adr/`**: leia ADRs que tocam a área que você vai mexer. Em repos multi-context, confira também `src/<context>/docs/adr/` para decisões específicas do contexto.

Se algum desses arquivos não existir, **prossiga em silêncio**. Não sinalize a ausência; não sugira criá-los de antemão. A skill `domain-modeling` (acionada via `grill-with-docs` ou `improve-codebase-architecture`) os cria de forma preguiçosa (lazy), conforme termos ou decisões realmente forem resolvidos.

## Estrutura de arquivos

Repo single-context (a maioria dos projetos deste harness):

```
/
├── CONTEXT.md
├── docs/adr/
│   ├── 0001-event-sourced-orders.md
│   └── 0002-postgres-for-write-model.md
└── src/
```

Repo multi-context (presença de `CONTEXT-MAP.md` na raiz):

```
/
├── CONTEXT-MAP.md
├── docs/adr/                          ← decisões do sistema inteiro
└── src/
    ├── ordering/
    │   ├── CONTEXT.md
    │   └── docs/adr/                  ← decisões específicas do contexto
    └── billing/
        ├── CONTEXT.md
        └── docs/adr/
```

## Use o vocabulário do glossário

Quando sua saída nomear um conceito de domínio (num título de issue, numa proposta de refactor, numa hipótese, num nome de teste), use o termo como definido em `CONTEXT.md`. Não derive para sinônimos que o glossário evita explicitamente.

Se o conceito de que você precisa ainda não está no glossário, isso é um sinal: ou você está inventando linguagem que o projeto não usa (reconsidere), ou há uma lacuna real (anote para a skill `domain-modeling`).

## Sinalize conflitos com ADR

Se sua saída contradiz um ADR existente, exponha isso explicitamente em vez de sobrescrever silenciosamente:

> _Contradiz o ADR-0007 (event-sourced orders), mas vale reabrir porque…_
