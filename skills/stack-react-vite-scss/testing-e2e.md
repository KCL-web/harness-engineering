# Testes UX/UI com Playwright

Playwright é usado para testes end-to-end que verificam fluxos completos no browser — navegação, formulários multi-step, comportamento responsivo e acessibilidade visual.

## Quando usar Playwright vs Vitest

| Cenário | Ferramenta |
| --- | --- |
| Lógica de função/hook isolada | Vitest |
| Componente renderizando e respondendo a eventos | Vitest + Testing Library |
| Fluxo completo (login → dashboard → ação) | Playwright |
| Comportamento visual / layout / responsividade | Playwright |
| Interações que dependem de navegação real | Playwright |

## Instalação (por projeto)

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

## Estrutura de pastas

```
e2e/
├── fixtures/          # dados de teste reutilizáveis
├── pages/             # Page Object Models (POM)
│   └── LoginPage.ts
└── tests/
    └── login.spec.ts
```

## Exemplo com os 3 princípios aplicados a E2E

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

## playwright.config.ts mínimo

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

## Regras

- Todo fluxo crítico (login, checkout, cadastro, pagamento) precisa de pelo menos um teste Playwright cobrindo os 3 princípios.
- Playwright roda separado dos testes Vitest — não misture no mesmo comando de CI.
- Adicione `playwright install` ao setup do projeto (veja `scripts/setup.sh`).
- Screenshots e vídeos de falha são artifacts de CI — configure `reporter: 'html'` para revisão.
