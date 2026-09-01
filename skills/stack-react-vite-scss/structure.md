# Estrutura de pastas

```
src/
├── assets/                   # imagens e fontes estáticas
├── components/               # componentes usados em 2+ lugares
│   └── Button/
│       ├── Button.tsx
│       ├── Button.module.scss
│       └── Button.test.tsx
├── pages/                    # uma pasta por rota / view
│   └── Dashboard/
│       ├── Dashboard.tsx
│       ├── Dashboard.module.scss
│       └── Dashboard.test.tsx
├── hooks/                    # hooks reutilizados em 2+ lugares
├── lib/                      # funções utilitárias e acesso a API
│   └── __tests__/
├── schemas/                  # schemas zod usados em 2+ lugares
├── types/
│   └── index.ts
└── styles/
    ├── _variables.scss
    ├── _mixins.scss
    └── global.scss           # só importado em main.tsx
```

## Regra de colocação

| Asset | 1 lugar | 2+ lugares |
| --- | --- | --- |
| Componente | dentro da própria pasta de página | `src/components/` |
| Schema zod de formulário | arquivo `.schema.ts` próprio, junto do form (nunca inline no `.tsx` — ver `forms.md`) | `src/schemas/` |
| Mock de teste | mesma pasta do teste | `src/mocks/` |
| Tipo | mesmo arquivo ou `types.ts` local (exceto tipo de formulário: sempre via `z.infer` no `.schema.ts`, nunca `type`/`interface` à mão — ver `forms.md`) | `src/types/index.ts` |
| Função utilitária | inline ou `utils.ts` local | `src/lib/` |

Não crie pasta compartilhada preventivamente — promova quando o reuso acontecer de verdade.

## Regra de promoção de schema zod

Assim que um schema zod passa a ser usado em **2+ lugares**, ele vira global — nunca duplicado/copiado-colado entre arquivos (isso é o mesmo valor de validação virando hardcoded em dois lugares que podem divergir):

- **Schema de formulário** (RHF) reutilizado por 2+ forms → `src/schemas/` (ver `forms.md`).
- **Schema de validação de resposta de API** (não ligado a um form — ex.: `UserSchema.parse(raw)` de `type-safety.md`) reutilizado por 2+ chamadas → `src/lib/`, junto do client/função que faz a chamada.

Em ambos os casos, o arquivo original passa a **importar** do destino global — nunca mantenha as duas cópias.
