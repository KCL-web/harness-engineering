# Testes E2E com Playwright

**Use este arquivo quando:** for testar um fluxo completo no browser real (navegação, formulário multi-step, autenticação) ou comportamento que só existe fora do processo (roteamento, responsividade). Para lógica de função/hook ou componente isolado, veja [testing-unit.md](testing-unit.md).

## Regra de ouro: teste deriva do requisito, não do código

Mesma regra de [testing-unit.md](testing-unit.md): formule o comportamento esperado do fluxo antes de olhar a implementação. Um E2E escrito clicando pela UI existente até "passar" tende a validar o bug atual, não o requisito.

## Quando usar Playwright vs Vitest

| Cenário | Ferramenta |
| --- | --- |
| Lógica de função/hook isolada | Vitest |
| Componente renderizando e respondendo a eventos | Vitest + Testing Library |
| Fluxo completo (login → dashboard → ação) | Playwright |
| Interações que dependem de navegação real | Playwright |

Regressão visual e acessibilidade automatizada **não** estão cobertas por este documento ainda — não assuma que "comportamento visual" ou "acessibilidade" têm teste só porque o fluxo passa por aqui. Se o projeto precisar disso, adicione explicitamente `toHaveScreenshot()` (regressão visual) ou `@axe-core/playwright` (acessibilidade) e documente o setup.

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
├── auth.setup.ts       # login único, salva storageState
└── tests/
    └── login.spec.ts
```

Page Object Model (POM) é opcional — só crie `e2e/pages/` se a suíte crescer o suficiente para justificar a camada de abstração. Não declare a pasta na estrutura se não vai usá-la.

## Seletores: locators semânticos, nunca CSS puro

Mesma regra de [testing-unit.md](testing-unit.md) — `getByRole`/`getByLabel` em vez de seletor CSS ou `data-testid`. Um agente que carrega os dois arquivos não pode ver um usando `getByRole` e o outro usando `page.click('button[type="submit"]')`; a inconsistência vira instrução contraditória.

```ts
// ❌ não faça
await page.fill('[name="email"]', 'user@example.com');
await page.click('button[type="submit"]');

// ✅ faça
await page.getByLabel('E-mail').fill('user@example.com');
await page.getByRole('button', { name: 'Entrar' }).click();
```

## Autenticação: login uma vez, reusar via `storageState`

Sem isso, todo teste que precisa de sessão faz login pela UI — numa suíte de 40 testes são 40 logins, cada um uma chance de flake sem relação com o que está sendo testado de fato. Padrão: um projeto de setup loga uma vez e salva o estado; os demais projetos reusam via `dependencies`.

```ts
// e2e/auth.setup.ts
import { test as setup } from '@playwright/test';

const authFile = 'e2e/.auth/user.json';

setup('autentica', async ({ page }) => {
  await page.goto('/login');
  await page.getByLabel('E-mail').fill('user@example.com');
  await page.getByLabel('Senha').fill('senha123');
  await page.getByRole('button', { name: 'Entrar' }).click();
  await page.waitForURL('/dashboard');
  await page.context().storageState({ path: authFile });
});
```

```ts
// playwright.config.ts (trecho de projects)
projects: [
  { name: 'setup', testMatch: /auth\.setup\.ts/ },
  {
    name: 'chromium',
    use: { storageState: 'e2e/.auth/user.json' },
    dependencies: ['setup'],
  },
],
```

O fluxo de login em si continua tendo **exatamente um** teste cobrindo a UI de login (incluindo o caminho de erro); todo o resto reusa a sessão salva.

## Isolamento de dados entre testes

Playwright roda em paralelo por padrão. Se dois testes compartilham o mesmo usuário/registro seed e um altera estado, você tem falha que só aparece no CI e não reproduz local.

- Cada teste cria os próprios dados via chamada de API direta (não pela UI), com identificador único por worker (`test.info().workerIndex` ou um sufixo aleatório).
- Nenhum teste depende de estado deixado por outro teste, nem de ordem de execução.

## Exemplo com os 3 princípios aplicados a E2E

```ts
// e2e/tests/login.spec.ts
import { test, expect } from '@playwright/test';

test.describe('Login', () => {
  // Parâmetros: credenciais válidas
  test('loga com credenciais corretas', async ({ page }) => {
    await page.goto('/login');
    await page.getByLabel('E-mail').fill('user@example.com');
    await page.getByLabel('Senha').fill('senha123');
    await page.getByRole('button', { name: 'Entrar' }).click();
    await expect(page).toHaveURL('/dashboard');
  });

  // Ação: estado transiente controlado, não observado por sorte
  test('exibe spinner durante submit', async ({ page }) => {
    await page.route('**/api/login', async (route) => {
      await new Promise((resolve) => setTimeout(resolve, 1000));
      await route.fulfill({ status: 200, body: '{}' });
    });

    await page.goto('/login');
    await page.getByLabel('E-mail').fill('user@example.com');
    await page.getByLabel('Senha').fill('senha123');
    await page.getByRole('button', { name: 'Entrar' }).click();

    await expect(page.getByRole('progressbar')).toBeVisible();
  });

  // O que pode dar errado: credenciais inválidas, campos vazios
  test('exibe erro com senha errada', async ({ page }) => {
    await page.goto('/login');
    await page.getByLabel('E-mail').fill('user@example.com');
    await page.getByLabel('Senha').fill('errada');
    await page.getByRole('button', { name: 'Entrar' }).click();
    await expect(page.getByRole('alert')).toContainText('Credenciais inválidas');
  });

  test('bloqueia submit com campos vazios', async ({ page }) => {
    await page.goto('/login');
    await page.getByRole('button', { name: 'Entrar' }).click();
    await expect(page.getByRole('alert')).toBeVisible();
    await expect(page).toHaveURL('/login');
  });
});
```

O teste de spinner acima usa `page.route` para segurar a resposta por 1s de propósito — sem isso, se a API responder em 30ms o spinner some antes da asserção rodar, e o teste fica flaky por construção (falha intermitente que corrói a confiança no CI).

## playwright.config.ts mínimo

```ts
import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: './e2e/tests',
  retries: process.env.CI ? 2 : 0,
  forbidOnly: !!process.env.CI,
  reporter: 'html',
  use: {
    baseURL: 'http://localhost:5173',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
    trace: 'on-first-retry',
  },
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:5173',
    reuseExistingServer: !process.env.CI,
  },
});
```

`trace: 'on-first-retry'` é mais útil que screenshot e vídeo juntos — abre o timeline completo (DOM, rede, console) do momento da falha. `forbidOnly` barra `.only` esquecido de chegar em CI.

## Regras

- Locators semânticos (`getByRole`, `getByLabel`) — nunca seletor CSS ou `data-testid` como primeira opção.
- Todo fluxo crítico (login, checkout, cadastro, pagamento) precisa de pelo menos um teste Playwright cobrindo os 3 princípios.
- Login pela UI só no teste de login em si; todo outro teste reusa `storageState`.
- Cada teste cria seus próprios dados via API, isolados por worker — nunca compartilha seed com outro teste.
- Playwright roda separado dos testes Vitest — não misture no mesmo comando de CI.
- Estado transiente (spinner, loading) é controlado via `page.route`, nunca observado torcendo para a asserção rodar a tempo.
- Adicione `playwright install` ao setup do projeto (veja `scripts/setup.sh`).

## Checklist antes de terminar

- [ ] Nenhum seletor CSS puro ou `data-testid` onde um locator semântico resolveria.
- [ ] Nenhum teste depende de timing de rede não controlado (`page.route` quando o estado importa).
- [ ] Login pela UI acontece no máximo uma vez na suíte inteira.
- [ ] Dados do teste são criados por ele mesmo, com identificador único — nada de seed compartilhado.
- [ ] Nenhum `.only` ou `test.skip` esquecido.
