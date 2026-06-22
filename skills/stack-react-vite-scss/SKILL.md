---
name: stack-react-vite-scss
description: Archetype frontend React 18 + Vite + TypeScript + SCSS Modules + React Hook Form + zod + BEM + path aliases. Invoque ao criar componente, form, rota, configurar alias, escrever teste, ou ao iniciar qualquer projeto que usa esta stack.
---

# Stack: React + Vite + SCSS

Archetype para projetos **React 18 + Vite + TypeScript + SCSS Modules**.
Formulários: **React Hook Form (RHF) + zod**. Convenção de CSS: **BEM dentro de SCSS Modules**.

## Estrutura de pastas

```
src/
├── assets/                   # imagens e fontes estáticas
├── components/               # componentes usados em 2+ lugares
│   └── Button/
│       ├── Button.tsx
│       ├── Button.module.scss
│       └── Button.test.tsx
├── pages/                    # uma pasta por rota / view
│   └── Dashboard/
│       ├── Dashboard.tsx
│       ├── Dashboard.module.scss
│       └── Dashboard.test.tsx
├── hooks/                    # hooks reutilizados em 2+ lugares
├── lib/                      # funções utilitárias e acesso a API
│   └── __tests__/
├── schemas/                  # schemas zod usados em 2+ lugares
├── types/
│   └── index.ts
└── styles/
    ├── _variables.scss
    ├── _mixins.scss
    └── global.scss           # só importado em main.tsx
```

### Regra de colocação

| Asset | 1 lugar | 2+ lugares |
| --- | --- | --- |
| Componente | dentro da própria pasta de página | `src/components/` |
| Schema zod | junto da página / form | `src/schemas/` |
| Mock de teste | mesma pasta do teste | `src/mocks/` |
| Tipo | mesmo arquivo ou `types.ts` local | `src/types/index.ts` |
| Função utilitária | inline ou `utils.ts` local | `src/lib/` |

Não crie pasta compartilhada preventivamente — promova quando o reuso acontecer de verdade.

## Componentes

- Uma pasta por componente (`.tsx` + `.module.scss` + `.test.tsx`).
- Export **nomeado**, não `default`, para componentes não-page.
- Props tipadas com `interface`, nunca com `type` inline anônimo.
- Nunca importe CSS global dentro de um componente — use **SCSS Modules**.
- Nunca use inline styles (`style={{}}`).

```tsx
// Button/Button.tsx
import styles from './Button.module.scss';

interface ButtonProps {
  label: string;
  variant?: 'primary' | 'secondary';
  onClick: () => void;
}

export function Button({ label, variant = 'primary', onClick }: ButtonProps) {
  return (
    <button
      className={`${styles.button} ${styles[`button--${variant}`]}`}
      onClick={onClick}
    >
      {label}
    </button>
  );
}
```

## BEM + SCSS Modules

BEM dentro de SCSS Modules: o escopo do arquivo já evita colisão global.

```scss
// Button.module.scss
.button {
  padding: 8px 16px;
  border-radius: 4px;

  &--primary   { background: var(--color-primary); color: #fff; }
  &--secondary { background: transparent; border: 1px solid var(--color-primary); }

  &__icon { margin-right: 8px; }
}
```

Uso no `.tsx`:
```tsx
// elemento + modifier
<button className={`${styles.button} ${styles['button--primary']}`} />

// elemento filho
<span className={styles.button__icon} />
```

Quando o modifier é dinâmico, prefira `clsx` ou template literal em vez de concatenação manual:
```tsx
import clsx from 'clsx';
<button className={clsx(styles.button, styles[`button--${variant}`])} />
```

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

## Formulários (RHF + zod)

```tsx
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';

const loginSchema = z.object({
  email: z.string().email('Email inválido'),
  password: z.string().min(8, 'Mínimo 8 caracteres'),
});

type LoginData = z.infer<typeof loginSchema>;

export function LoginForm() {
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<LoginData>({ resolver: zodResolver(loginSchema) });

  const onSubmit = async (data: LoginData) => {
    // data já validado pelo zod — sem if/else de validação manual
    await authService.login(data);
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input {...register('email')} />
      {errors.email && <span role="alert">{errors.email.message}</span>}

      <input type="password" {...register('password')} />
      {errors.password && <span role="alert">{errors.password.message}</span>}

      <button type="submit" disabled={isSubmitting}>Entrar</button>
    </form>
  );
}
```

Schemas de um único form ficam na mesma pasta. Schemas de 2+ forms vão para `src/schemas/`.

## Type safety

- Sem `any`. Use `unknown` + narrowing, ou defina o tipo correto.
- Toda função tipada por completo — sem parâmetro implicitamente `any`.
- `interface` para shapes de objeto; `type` para uniões, aliases e mapped types.
- Resposta de API é `unknown` até ser validada por um schema zod:
  ```ts
  const raw: unknown = await res.json();
  const data = UserSchema.parse(raw);   // lança se inválido
  ```
- Evite non-null assertion (`!`) — prefira narrowing explícito ou optional chaining.

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

## Testes (Vitest + Testing Library)

### Os 3 princípios obrigatórios

Todo teste de componente ou função deve cobrir pelo menos estes três ângulos:

#### 1. Parâmetros (variações de entrada)
Teste cada variante relevante dos props/argumentos. Se um componente aceita `variant="primary" | "secondary"`, ambas devem ter teste. Se uma função aceita um número, teste limites (0, negativo, muito grande).

```ts
it('renderiza variant primary', () => { ... });
it('renderiza variant secondary', () => { ... });
it('usa primary como padrão quando variant não é passado', () => { ... });
```

#### 2. Ações (cada interação é candidata a teste)
Cada ação do usuário que o componente suporta (click, submit, change, hover com efeito visível) é um candidato de teste.

```ts
it('chama onSubmit com dados corretos ao submeter o form', async () => { ... });
it('desabilita o botão enquanto isSubmitting é true', async () => { ... });
it('limpa o campo ao clicar em reset', async () => { ... });
```

#### 3. O que pode dar errado (dados inválidos, nulos, invertidos, edge cases)
- Dados inválidos: email sem `@`, senha curta demais, CPF com letras.
- Dados nulos/undefined: prop obrigatória ausente, resposta de API vazia.
- Dados invertidos: ordenação DESC quando se espera ASC, booleano negado.
- Boundary: string vazia `""`, array vazio `[]`, objeto `{}`.

```ts
it('exibe erro quando email é inválido', async () => { ... });
it('exibe estado vazio quando lista retorna []', () => { ... });
it('não quebra quando onClose é undefined', () => { ... });
```

### Exemplo completo aplicando os 3 princípios

```ts
// Button.test.tsx
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, it, expect, vi } from 'vitest';
import { Button } from './Button';

describe('Button', () => {
  // Parâmetros
  it('renderiza label corretamente', () => {
    render(<Button label="Salvar" onClick={vi.fn()} />);
    expect(screen.getByRole('button', { name: 'Salvar' })).toBeInTheDocument();
  });

  it('aplica classe primary por padrão', () => {
    render(<Button label="X" onClick={vi.fn()} />);
    expect(screen.getByRole('button')).toHaveClass('button--primary');
  });

  it('aplica classe secondary quando variant="secondary"', () => {
    render(<Button label="X" variant="secondary" onClick={vi.fn()} />);
    expect(screen.getByRole('button')).toHaveClass('button--secondary');
  });

  // Ações
  it('chama onClick ao clicar', async () => {
    const handler = vi.fn();
    render(<Button label="Salvar" onClick={handler} />);
    await userEvent.click(screen.getByRole('button'));
    expect(handler).toHaveBeenCalledOnce();
  });

  // O que pode dar errado
  it('não chama onClick quando desabilitado', async () => {
    const handler = vi.fn();
    render(<Button label="Salvar" onClick={handler} disabled />);
    await userEvent.click(screen.getByRole('button'));
    expect(handler).not.toHaveBeenCalled();
  });
});
```

### Regras de testes unitários / integração

- Toda função em `src/lib/` precisa de teste em `src/lib/__tests__/`.
- Testes de componente ficam colocados junto (`Button.test.tsx`).
- Prefira `screen.getByRole` a `getByTestId` — testa comportamento acessível.
- Teste o comportamento observável, não internals de implementação.
- `vi.mock` só para módulos de borda do sistema (API calls, localStorage). Não moque componentes filhos.

### Configuração mínima do Vitest

```ts
// vite.config.ts (ou vitest.config.ts separado)
test: {
  environment: 'jsdom',
  globals: true,
  setupFiles: './src/test-setup.ts',
}
```

```ts
// src/test-setup.ts
import '@testing-library/jest-dom';
```

## Testes UX/UI com Playwright

Playwright é usado para testes end-to-end que verificam fluxos completos no browser — navegação, formulários multi-step, comportamento responsivo e acessibilidade visual.

### Quando usar Playwright vs Vitest

| Cenário | Ferramenta |
| --- | --- |
| Lógica de função/hook isolada | Vitest |
| Componente renderizando e respondendo a eventos | Vitest + Testing Library |
| Fluxo completo (login → dashboard → ação) | Playwright |
| Comportamento visual / layout / responsividade | Playwright |
| Interações que dependem de navegação real | Playwright |

### Instalação (por projeto)

```bash
npm install -D @playwright/test
npx playwright install --with-deps chromium
```

Adicione ao `package.json`:
```json
{
  "scripts": {
    "test:e2e": "playwright test",
    "test:e2e:ui": "playwright test --ui"
  }
}
```

### Estrutura de pastas

```
e2e/
├── fixtures/          # dados de teste reutilizáveis
├── pages/             # Page Object Models (POM)
│   └── LoginPage.ts
└── tests/
    └── login.spec.ts
```

### Exemplo com os 3 princípios aplicados a E2E

```ts
// e2e/tests/login.spec.ts
import { test, expect } from '@playwright/test';

test.describe('Login', () => {
  // Parâmetros: credenciais válidas e inválidas
  test('loga com credenciais corretas', async ({ page }) => {
    await page.goto('/login');
    await page.fill('[name="email"]', 'user@example.com');
    await page.fill('[name="password"]', 'senha123');
    await page.click('button[type="submit"]');
    await expect(page).toHaveURL('/dashboard');
  });

  // Ação: submit do formulário
  test('exibe spinner durante submit', async ({ page }) => {
    await page.goto('/login');
    await page.fill('[name="email"]', 'user@example.com');
    await page.fill('[name="password"]', 'senha123');
    await page.click('button[type="submit"]');
    await expect(page.getByRole('progressbar')).toBeVisible();
  });

  // O que pode dar errado: credenciais inválidas, campos vazios
  test('exibe erro com senha errada', async ({ page }) => {
    await page.goto('/login');
    await page.fill('[name="email"]', 'user@example.com');
    await page.fill('[name="password"]', 'errada');
    await page.click('button[type="submit"]');
    await expect(page.getByRole('alert')).toContainText('Credenciais inválidas');
  });

  test('bloqueia submit com campos vazios', async ({ page }) => {
    await page.goto('/login');
    await page.click('button[type="submit"]');
    await expect(page.getByRole('alert')).toBeVisible();
    await expect(page).toHaveURL('/login');
  });
});
```

### playwright.config.ts mínimo

```ts
import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: './e2e/tests',
  use: {
    baseURL: 'http://localhost:5173',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  },
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:5173',
    reuseExistingServer: !process.env.CI,
  },
});
```

### Regras

- Todo fluxo crítico (login, checkout, cadastro, pagamento) precisa de pelo menos um teste Playwright cobrindo os 3 princípios.
- Playwright roda separado dos testes Vitest — não misture no mesmo comando de CI.
- Adicione `playwright install` ao setup do projeto (veja `scripts/setup.sh`).
- Screenshots e vídeos de falha são artifacts de CI — configure `reporter: 'html'` para revisão.

## Regras inegociáveis

- Sem `any`. Sem inline styles. Sem import de CSS global dentro de componente.
- `@/` em vez de paths relativos com `../../`.
- Schema zod para todo input externo (forms, resposta de API, params de URL).
- Toda função em `src/lib/` tem teste correspondente.
- Componente sobe para `src/components/` só quando há 2+ usos reais.
- Export nomeado para componentes não-page (facilita tree-shaking e grep).

## Skills relacionadas

- Fluxo de issue, branch e PR: `workflow-branching`, `workflow-prs`, `workflow-issues`
- Feature list e baseline: `ratchet-feature-list`
- Backend: `stack-django-drf-jwt`
