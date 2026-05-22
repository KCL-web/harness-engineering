# CONVENTIONS.md

Convenções opinionadas para a stack deste projeto: como o código é organizado, como componentes são escritos, como testes são estruturados.

Este arquivo é **preenchido pela entrevista de bootstrap** com base na stack e **nunca é sobrescrito por `scripts/harness-sync.sh`**.

O template abaixo mostra um formato de exemplo para Next.js + TypeScript + SCSS Modules + Vitest. Adapte para sua stack — remova seções que não se aplicam (ex.: SCSS num backend), adicione as que se aplicam (ex.: padrões de middleware, regras de migration).

---

## Estrutura de pastas e arquivos

### Páginas e componentes — uma pasta por unidade

Toda página e todo componente vive na sua própria pasta contendo:

- O arquivo principal (`page.tsx` ou `ComponentName.tsx`)
- Os estilos (`page.module.scss` ou `ComponentName.module.scss`)
- Os testes quando aplicável (`page.test.ts` ou `ComponentName.test.ts`)

```
src/app/dashboard/
├── page.tsx
├── page.module.scss
└── page.test.ts

src/components/Button/
├── Button.tsx
├── Button.module.scss
└── Button.test.ts
```

### Regra de colocação

Mantenha tudo perto de onde é usado.
Só mova para um local compartilhado quando 2 ou mais lugares usarem.

| Asset            | Usado em 1 lugar                   | Usado em 2+ lugares             |
| ---------------- | ---------------------------------- | ------------------------------- |
| Componente       | dentro da própria pasta            | `src/components/ComponentName/` |
| Schema           | mesma pasta da página/componente   | `src/schemas/`                  |
| Mock data        | mesma pasta do teste               | `src/mocks/`                    |
| Tipo             | mesmo arquivo ou `types.ts` local  | `src/types/index.ts`            |
| Função utilitária| inline ou `utils.ts` local         | `src/lib/`                      |

**Não crie uma pasta compartilhada preventivamente.**
Comece colocado junto. Promova para cima só quando o reuso realmente acontecer.

### Estrutura completa do projeto

```
src/
├── app/
│   ├── api/
│   ├── layout.tsx
│   └── globals.scss
├── components/              # reutilizados em 2+ lugares só
│   └── ComponentName/
├── lib/                     # funções utilitárias
│   └── __tests__/
├── schemas/                 # schemas de validação reutilizados em 2+ lugares
├── mocks/                   # mock data reutilizado em 2+ lugares
├── types/
│   └── index.ts
└── styles/
    ├── globals.scss
    ├── _variables.scss
    └── _mixins.scss
```

---

## Contratos específicos da stack

Estas regras são inegociáveis **para esta stack**. Nunca viole.
(Contratos universais do projeto estão em `AGENTS.md`.)

### Type safety

- Sem `any` — use `unknown` e estreite, ou defina o tipo correto
- Toda assinatura de função tipada por completo (sem `any` implícito)
- Prefira `interface` para shapes de objeto, `type` para uniões e aliases
- Trate input externo como `unknown` até ser validado por um schema

### Componentes

- Um componente usado em 2+ lugares deve viver em `src/components/`
- Toda pasta de componente deve conter seu `.tsx` e `.module.scss`
- Nunca importe CSS global dentro de um componente — use SCSS modules
- Nunca use inline styles

### Estilos

- Variáveis e mixins SCSS estão disponíveis globalmente via `sassOptions.additionalData`
- Não repita `@use '@/styles/index'` — já é injetado
- `sass:color` deve ser importado explicitamente quando necessário: `@use 'sass:color'`

### Rotas de API

- Nunca escreva queries de banco direto em route handlers
- Todo acesso a banco vai por funções em `src/lib/`

### Testes

- Toda função em `src/lib/` precisa de um teste correspondente
- Testes ficam colocados junto do arquivo que testam, dentro de uma subpasta `__tests__/`
- Mock data usado em um único teste fica na mesma pasta
- Descrições de teste em português ou inglês — escolha uma e mantenha consistente no projeto

### Schemas de validação

- Todo input externo (body de request, form data) precisa ser validado
- Schemas usados por uma única rota ou componente ficam colocados juntos
- Schemas usados por 2+ lugares vão para `src/schemas/`
