# Type safety

- Sem `any`. Use `unknown` + narrowing, ou defina o tipo correto.
- Toda função tipada por completo — sem parâmetro implicitamente `any`.
- `interface` para shapes de objeto; `type` para uniões, aliases e mapped types.
- Resposta de API é `unknown` até ser validada por um schema zod:
  ```ts
  const raw: unknown = await res.json();
  const data = UserSchema.parse(raw);   // lança se inválido
  ```
- Evite non-null assertion (`!`) — prefira narrowing explícito ou optional chaining.
