---
name: typescript
description: Regras de type safety em TypeScript — sem any, narrowing, validação de resposta de API. Invoque ao escrever ou revisar qualquer código TypeScript no frontend.
---

# TypeScript

## Regras inegociáveis

- Sem `any`. Use `unknown` + narrowing, ou defina o tipo correto. Um `field as any` pra contornar um
  erro de tipo quase sempre indica que o tipo de origem está errado — corrija o tipo, não o cast.
- Toda função tipada por completo — sem parâmetro implicitamente `any`.
- `interface` para shapes de objeto; `type` para uniões, aliases e mapped types. Nunca
  `interface Foo extends Bar {}` vazia só para renomear um tipo — use `type Foo = Bar`.
- Resposta de API é `unknown` até ser validada por um schema zod:
  ```ts
  const raw: unknown = await res.json();
  const data = UserSchema.parse(raw);   // lança se inválido
  ```
- Evite non-null assertion (`!`) — prefira narrowing explícito ou optional chaining.
- Import de módulo/alias inexistente (ex. `@schema/...` quando o alias configurado é só `@/...`) só
  aparece no `tsc --noEmit` — o dev server (Vite/esbuild) não pega isso. Rode o type check antes de
  considerar uma tarefa pronta.

## Skills relacionadas

- Validação de schema (zod): `frontend/react-hook-form-zod`
- Build tool e env vars tipadas: `frontend/vite`
