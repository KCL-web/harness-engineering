# Formulários (RHF + zod)

## Regras inegociáveis

- **Nunca declare `type`/`interface` à mão para dados de formulário.** O schema zod é a única fonte de verdade — o tipo sempre vem de `z.infer<typeof schema>`. Duplicar manualmente (`interface LoginData { email: string; ... }`) permite que schema e tipo divirjam.
- **Schema e tipo derivado ficam num arquivo `.schema.ts` separado do componente**, nunca declarados dentro do `.tsx` — mesmo quando usados em um único form (isso é mais restrito que a regra geral de colocação de `structure.md`: para formulários, "1 lugar" ainda é arquivo separado, só não vai para `src/schemas/` compartilhado até um segundo form precisar dele).
- Todo tratamento de erro de campo passa pelo zod (via `zodResolver`) — nada de `if (!email.includes('@'))` manual no componente.
- **Campo usa sempre o componente global** (`Input`/`Textarea`/`Select` de `src/components/`, ver `components.md`) — nunca `<input>`/`<textarea>`/`<select>` cru com `<span>` de erro escrito à mão no form. O form só passa `label`, `error={errors.campo?.message}` e o spread de `register(campo)`; o componente decide como renderizar label e erro.

## Estrutura de arquivos

```
LoginForm/
├── LoginForm.tsx
├── LoginForm.schema.ts
└── LoginForm.module.scss
```

### `LoginForm.schema.ts`

```ts
import { z } from 'zod';

export const loginSchema = z.object({
  email: z.string().email('Email inválido'),
  password: z.string().min(8, 'Mínimo 8 caracteres'),
});

export type LoginFormData = z.infer<typeof loginSchema>;
```

### `LoginForm.tsx`

```tsx
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { loginSchema, type LoginFormData } from './LoginForm.schema';
import { Input } from '../../components/Input/Input';

export function LoginForm() {
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<LoginFormData>({ resolver: zodResolver(loginSchema) });

  const onSubmit = async (data: LoginFormData) => {
    // data já validado pelo zod — sem if/else de validação manual
    await authService.login(data);
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <Input label="Email" error={errors.email?.message} {...register('email')} />
      <Input label="Senha" type="password" error={errors.password?.message} {...register('password')} />

      <button type="submit" disabled={isSubmitting}>Entrar</button>
    </form>
  );
}
```

O componente `Input` já embute `<label>` e `<span role="alert">` do erro — o form nunca escreve esse markup de novo (ver `components.md` → "Campos de formulário").

## Erros cross-field (confirmação de senha, etc.)

Não valide campo cruzado no componente — use `.refine()`/`.superRefine()` no schema, apontando o erro para o campo certo com `path`:

```ts
// SignupForm.schema.ts
export const signupSchema = z
  .object({
    password: z.string().min(8, 'Mínimo 8 caracteres'),
    confirmPassword: z.string(),
  })
  .refine((data) => data.password === data.confirmPassword, {
    message: 'As senhas não coincidem',
    path: ['confirmPassword'],
  });

export type SignupFormData = z.infer<typeof signupSchema>;
```

O RHF expõe isso normalmente em `errors.confirmPassword.message` — nenhum código extra no componente para ler o erro cruzado.

## Onde o schema mora

- **Um form usa o schema**: `<NomeDoForm>.schema.ts` na mesma pasta do componente (nunca dentro do `.tsx`).
- **2+ forms compartilham o schema** (ex.: endereço usado em checkout e em cadastro): promova para `src/schemas/`, seguindo a regra geral de colocação em `structure.md`.
