---
name: migrate-to-shoehorn
description: Migra arquivos de teste de type assertions `as` para @total-typescript/shoehorn. Invoque quando o dev mencionar shoehorn, quiser substituir `as` em testes, ou precisar de dados parciais de teste. Importada de mattpocock/skills.
---

# Migrar para Shoehorn

> **Origem:** importada de [mattpocock/skills](https://github.com/mattpocock/skills) (`misc/migrate-to-shoehorn`), adaptada ao vocabulário deste harness.

## Por que shoehorn?

`shoehorn` deixa passar dados parciais em testes mantendo o TypeScript satisfeito. Substitui assertions `as` por alternativas type-safe.

**Só em código de teste.** Nunca use shoehorn em código de produção.

Problemas do `as` em testes:

- Treina o hábito de não usá-lo
- Precisa especificar manualmente o tipo alvo
- Double-as (`as unknown as Type`) para dados propositalmente errados

## Instalação

```bash
npm i @total-typescript/shoehorn
```

## Padrões de migração

### Objetos grandes com poucas propriedades necessárias

Antes:

```ts
type Request = {
  body: { id: string };
  headers: Record<string, string>;
  cookies: Record<string, string>;
  // ...mais 20 propriedades
};

it("gets user by id", () => {
  // Só importa body.id mas precisa fingir o Request inteiro
  getUser({
    body: { id: "123" },
    headers: {},
    cookies: {},
    // ...fingir as 20 propriedades
  });
});
```

Depois:

```ts
import { fromPartial } from "@total-typescript/shoehorn";

it("gets user by id", () => {
  getUser(
    fromPartial({
      body: { id: "123" },
    }),
  );
});
```

### `as Type` → `fromPartial()`

Antes:

```ts
getUser({ body: { id: "123" } } as Request);
```

Depois:

```ts
import { fromPartial } from "@total-typescript/shoehorn";

getUser(fromPartial({ body: { id: "123" } }));
```

### `as unknown as Type` → `fromAny()`

Antes:

```ts
getUser({ body: { id: 123 } } as unknown as Request); // tipo errado de propósito
```

Depois:

```ts
import { fromAny } from "@total-typescript/shoehorn";

getUser(fromAny({ body: { id: 123 } }));
```

## Quando usar cada função

| Função          | Caso de uso                                                  |
| --------------- | ------------------------------------------------------------- |
| `fromPartial()` | Passar dados parciais que ainda type-checkam                  |
| `fromAny()`      | Passar dados propositalmente errados (mantém autocomplete)    |
| `fromExact()`    | Forçar objeto completo (trocar por fromPartial depois)        |

## Workflow

1. **Levantar requisitos** — pergunte ao dev:
   - Quais arquivos de teste têm assertions `as` causando problemas?
   - São objetos grandes onde só algumas propriedades importam?
   - Precisam passar dados propositalmente errados para testar erro?

2. **Instalar e migrar**:
   - [ ] Instalar: `npm i @total-typescript/shoehorn`
   - [ ] Encontrar arquivos de teste com assertions `as`: `grep -r " as [A-Z]" --include="*.test.ts" --include="*.spec.ts"`
   - [ ] Substituir `as Type` por `fromPartial()`
   - [ ] Substituir `as unknown as Type` por `fromAny()`
   - [ ] Adicionar imports de `@total-typescript/shoehorn`
   - [ ] Rodar type check para verificar

## Skills relacionadas

- Disciplina de teste (o que testar, seams, mocking): `tdd`
- Mecânica de teste unitário em React/Vite (arquivos `.test.ts`/`.spec.ts`, TypeScript): `stack-react-vite-scss` → `testing-unit.md`, `type-safety.md`
