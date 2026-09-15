---
name: shadcn-ui
description: Convenção para componentes gerados pela CLI do shadcn/ui (Radix + class-variance-authority) em `src/components/ui/`. Invoque ao adicionar um primitivo de UI novo (dropdown, dialog, tooltip...) ou ao mexer em arquivo dentro de `components/ui/`.
---

# shadcn/ui

Arquivos em `src/components/ui/` são gerados/atualizados pela CLI (`npx shadcn add <componente>`) e
seguem o estilo Radix + `class-variance-authority` (`cva`) do shadcn — não os reescreva à mão para
"limpar" o padrão deles.

## Regras inegociáveis

- Quando precisar de um primitivo novo (dropdown, dialog, tooltip...), rode
  `npx shadcn add <nome>` em vez de escrever do zero — mantém consistência visual e acessibilidade
  (Radix já trata foco/teclado).
- Para customizar variantes, edite o array `cva(...)` do próprio arquivo gerado (é esperado editar
  depois de gerar) em vez de sobrescrever classes por fora com `!important`/especificidade.
- Esses arquivos comumente co-exportam variantes/constantes junto do componente (ex.:
  `buttonVariants`), o que dispara `react-refresh/only-export-components` no ESLint. **Não fatie o
  arquivo pra resolver isso** — desative a regra só para `src/components/ui/**` via override no
  `eslint.config.js`:
  ```js
  {
    files: ["src/components/ui/**/*.{ts,tsx}"],
    rules: { "react-refresh/only-export-components": "off" },
  }
  ```
- `components.json` (config da CLI do shadcn) já aponta pros aliases certos do projeto — não precisa
  reconfigurar ao rodar `npx shadcn add`.

## Campo de formulário

Se o projeto ainda não tem um componente `Input`/`Textarea` global com contrato de `label`/`error`
embutido, `components/ui/input.tsx` gerado pelo shadcn já serve de base estilizada — decida então se o
contrato de erro embutido (ver `frontend/react-hook-form-zod`) faz sentido antes de espalhar `<input>`
cru pelos forms.

## Skills relacionadas

- Estilo utilitário no resto da árvore: `frontend/tailwind`
- Estrutura de componente: `frontend/react`
