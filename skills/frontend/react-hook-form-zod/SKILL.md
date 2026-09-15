---
name: react-hook-form-zod
description: Convenção de formulários com React Hook Form + zod — schema, tipo e mensagem de erro vivem juntos, componente é só estrutura. Invoque ao criar ou revisar qualquer form.
---

# React Hook Form + zod

**Schema, tipo e mensagem de erro vivem juntos no arquivo de schema — nunca inline no componente.** O
`.tsx` só importa o schema e o tipo; não declara `interface`/`type` de dados de form nem faz
validação manual (`if (!email.includes('@'))`). Toda regra de validação — obrigatoriedade, formato,
mensagem exibida ao usuário — é responsabilidade do zod.

```ts
// LoginForm.schema.ts
import { z } from 'zod';

export const loginSchema = z.object({
  email: z.string().email('Email inválido'),
  password: z.string().min(8, 'Mínimo 8 caracteres'),
});

export type LoginFormData = z.infer<typeof loginSchema>;
```

```tsx
// LoginForm.tsx — só estrutura: hook de form, JSX, submit. Zero tipo, zero regra de validação.
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { loginSchema, type LoginFormData } from './LoginForm.schema';
import { Input } from '@/components/Input/Input';

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

## Regras inegociáveis

- Schema e tipo derivado ficam num arquivo `.schema.ts` separado do componente, nunca declarados
  dentro do `.tsx` — mesmo quando usados em um único form. Schema de um único form:
  `<Form>.schema.ts` na mesma pasta do componente (ver `frontend/react` → folder-structure). Schema
  usado por 2+ forms: `src/schemas/`.
- O componente lê `errors.<campo>.message` — a mensagem em si mora no schema, não em string solta na
  JSX.
- Erro cross-field (confirmação de senha, etc.) vai no schema via `.refine()`/`.superRefine()`,
  apontando o erro pro campo certo com `path` — nunca comparado manualmente no `onSubmit` ou no JSX:
  ```ts
  export const signupSchema = z
    .object({
      password: z.string().min(8, 'Mínimo 8 caracteres'),
      confirmPassword: z.string(),
    })
    .refine((data) => data.password === data.confirmPassword, {
      message: 'As senhas não coincidem',
      path: ['confirmPassword'],
    });
  ```
- Resposta de API dentro de um form (ex.: erro 422 do backend) é reaplicada com `setError`, mas o
  **shape** esperado da resposta ainda é validado por um schema zod antes de virar estado — não se
  confia em `unknown` solto.
- **Validação de servidor é sempre a fonte de verdade**, com ou sem RHF no client: a API que recebe o
  submit valida de novo com seu próprio schema (zod, DRF serializer, etc. — ver o skill de backend do
  projeto) — um form que só valida no browser pode ser contornado por requisição direta (curl/Postman).
- Trate sempre os 3 estados do submit: `loading` (desabilita o botão via `isSubmitting`), sucesso
  (feedback pro usuário) e `error` (feedback de falha) — um form que só trata o caminho feliz esconde
  erro de rede/validação do usuário.

## Campo de formulário global (Input, Textarea, Select)

Todo campo de formulário global (`Input`, `Textarea`, `Select`, etc.) segue um contrato fixo:

- **`label` e `error` são sempre props** — o componente nunca recebe label ou mensagem de erro via
  `children`, só via parâmetro. É isso que permite reuso: o form só passa dados, o componente decide
  como renderizar.
- **`<label>` e `<span role="alert">` do erro já vêm embutidos no componente**, condicionados a
  `error` estar presente — nenhum form escreve `{errors.campo && <span>...}` manualmente.
- **`error` é sempre a `message` do zod** (`errors.campo?.message`) — o componente não sabe nem
  precisa saber que existe zod, só recebe a string pronta.
- **`forwardRef` obrigatório** — o `ref` do `register()` do RHF precisa chegar ao elemento nativo.

```tsx
// Input/Input.tsx
import { forwardRef, type InputHTMLAttributes } from 'react';

interface InputProps extends InputHTMLAttributes<HTMLInputElement> {
  label: string;
  error?: string;
}

export const Input = forwardRef<HTMLInputElement, InputProps>(
  ({ label, error, id, name, ...props }, ref) => {
    const inputId = id ?? name;
    return (
      <div>
        <label htmlFor={inputId}>{label}</label>
        <input id={inputId} name={name} ref={ref} {...props} />
        {error && <span role="alert">{error}</span>}
      </div>
    );
  },
);
Input.displayName = 'Input';
```

`Textarea` e `Select` seguem exatamente o mesmo contrato (`label`, `error`, `forwardRef`), só trocando
o elemento nativo interno. Se o projeto usa shadcn/ui, `components/ui/input.tsx` gerado já serve de
base estilizada — ver `frontend/shadcn-ui`.

## Skills relacionadas

- Estrutura de componente: `frontend/react`
- Type safety: `frontend/typescript`
