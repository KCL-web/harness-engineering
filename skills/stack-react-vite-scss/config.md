# Configuração: SCSS global, path aliases e env vars

## SCSS global

Variáveis CSS custom properties e mixins ficam em `src/styles/_variables.scss` / `_mixins.scss`.
Injete globalmente via `vite.config.ts` para não repetir `@use` em cada arquivo:

```ts
// vite.config.ts
export default defineConfig({
  css: {
    preprocessorOptions: {
      scss: {
        additionalData: `@use "@/styles/variables" as *; @use "@/styles/mixins" as *;`,
      },
    },
  },
});
```

Quando precisar de funções do Sass no arquivo, importe explicitamente:
```scss
@use 'sass:color';
.foo { background: color.adjust(#3366ff, $lightness: 10%); }
```

## Path aliases

```ts
// vite.config.ts
import path from 'path';
import { defineConfig } from 'vite';

export default defineConfig({
  resolve: {
    alias: { '@': path.resolve(__dirname, './src') },
  },
});
```

```json
// tsconfig.json  (dentro de "compilerOptions")
{
  "baseUrl": ".",
  "paths": { "@/*": ["./src/*"] }
}
```

Sempre use `@/` em vez de paths relativos profundos (`../../lib/api`).

## Variáveis de ambiente

- Prefixo obrigatório `VITE_*` — sem ele a variável não é exposta ao browser.
- Acesso via `import.meta.env.VITE_*`.
- Declare tipos em `src/env.d.ts`:
  ```ts
  interface ImportMetaEnv {
    readonly VITE_API_URL: string;
  }
  interface ImportMeta {
    readonly env: ImportMetaEnv;
  }
  ```
- Nunca comite `.env` com valores reais. `.env.example` com placeholders é obrigatório.
