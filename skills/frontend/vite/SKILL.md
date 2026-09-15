---
name: vite
description: Convenções de Vite — path aliases e variáveis de ambiente VITE_*. Invoque ao configurar alias, adicionar variável de ambiente, ou iniciar um projeto novo com Vite.
---

# Vite

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

Sempre use `@/` em vez de paths relativos profundos (`../../lib/api`) e em vez de aliases não
configurados — um import de alias que não existe no `vite.config.ts`/`tsconfig` quebra silenciosamente
até rodar o type check (ver `frontend/typescript`). Confira sempre os dois arquivos de config antes de
introduzir um alias novo.

## Variáveis de ambiente

- Prefixo obrigatório `VITE_*` — sem ele a variável não é exposta ao browser. O inverso também
  importa: **nunca** coloque segredo (senha, API key privada) numa var `VITE_*`, porque ela entra no
  bundle público — lógica que precisa de segredo vive numa API própria (ver `backend/express` ou
  `backend/django-drf`).
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
- Nunca comite `.env` com valores reais. `.env.example` com placeholders é obrigatório, e `.env`/
  `.env.*` (exceto `.env.example`) devem estar no `.gitignore` desde o primeiro commit do projeto.

## Skills relacionadas

- Type safety: `frontend/typescript`
