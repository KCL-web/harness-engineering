---
name: react
description: Convenções de componente React 18 — estrutura de pasta, export, props tipadas — independente da biblioteca de estilo (SCSS Modules ou Tailwind). Invoque ao criar ou revisar qualquer componente React.
---

# React

Convenções de componente que valem **qualquer que seja a lib de estilo**. Estilização em si mora em
`frontend/scss-bem` ou `frontend/tailwind`, conforme o archetype do projeto.

## Referência

| Arquivo | Conteúdo |
| --- | --- |
| [reference/components.md](reference/components.md) | Estrutura de componente, export, props tipadas |
| [reference/folder-structure.md](reference/folder-structure.md) | Estrutura de `src/`, regra de colocação e promoção |

## Regras inegociáveis

- Export **nomeado**, não `default`, para componentes não-page. Páginas roteadas (`src/pages/`) podem
  seguir `export default`, que é o que roteadores com lazy-loading esperam.
- Props tipadas com `interface`, nunca `type` inline anônimo.
- Sem inline styles (`style={{}}`) — a classe/token vem da lib de estilo do projeto. Exceção: valor
  verdadeiramente dinâmico que não dá pra expressar em classe (ex. progresso calculado).
- Componente sobe para `src/components/` só quando há 2+ usos reais.
- Componente `.tsx` é só estrutura — tipo de dado externo (form, resposta de API, params de URL) vem
  de um schema zod (`frontend/react-hook-form-zod`), nunca `interface`/`type` solto no `.tsx`.

## Skills relacionadas

- Tipagem: `frontend/typescript`
- Build tool, aliases, env vars: `frontend/vite`
- Estilo: `frontend/scss-bem` ou `frontend/tailwind`
- Componentes gerados via CLI (shadcn/ui): `frontend/shadcn-ui`
- Forms: `frontend/react-hook-form-zod`
- Testes: `frontend/vitest-testing-library`, `frontend/playwright-e2e`
