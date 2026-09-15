---
name: vitest-testing-library
description: Convenção de teste de componente React e de função com Vitest + Testing Library — os 3 princípios obrigatórios, anti-padrões, mocking de rede via MSW. Invoque ao escrever teste de componente ou de função em src/lib/.
---

# Testes unitários e de componente (Vitest + Testing Library)

**Use esta skill quando:** for testar lógica de função/hook isolada ou um componente renderizando e
respondendo a eventos, dentro do processo (sem browser real). Para fluxo completo, navegação real ou
comportamento visual, veja `frontend/playwright-e2e`.

## Regra de ouro: teste deriva do requisito, não do código

Ao escrever teste para código já existente, formule primeiro o comportamento esperado em uma frase,
**sem olhar a implementação**. Se o comportamento real divergir do que você formulou, isso é bug — não
é motivo para ajustar o teste ao código. Um teste escrito lendo a implementação linha a linha tende a
codificar o bug junto, porque descreve o que o código faz, não o que deveria fazer.

## Os 3 princípios obrigatórios

Todo teste de componente ou função deve cobrir pelo menos estes três ângulos:

### 1. Parâmetros (variações de entrada)
Teste cada variante relevante dos props/argumentos. Se um componente aceita
`variant="primary" | "secondary"`, ambas devem ter teste. Se uma função aceita um número, teste
limites (0, negativo, muito grande).

### 2. Ações (cada interação com efeito observável)
Cada ação do usuário que produz um efeito observável (click que dispara callback, submit que muda
estado, change que atualiza validação) é candidata a teste — não cada interação possível em abstrato
(ver "teto" abaixo).

### 3. O que pode dar errado (dados inválidos, nulos, invertidos, edge cases)
- Dados inválidos: email sem `@`, senha curta demais, CPF com letras.
- Dados nulos/undefined: prop obrigatória ausente, resposta de API vazia.
- Dados invertidos: ordenação DESC quando se espera ASC, booleano negado.
- Boundary: string vazia `""`, array vazio `[]`, objeto `{}`.

## Teto: priorize, não esgote

"Cada ação é candidata a teste" não é licença para gerar testes até esgotar combinações. Ordem de
prioridade quando o tempo/contexto é limitado:

1. Caminho de erro (o que quebra silenciosamente é mais caro que o que quebra visivelmente).
2. Edge case / boundary.
3. Caminho feliz.
4. Variação de estilo ou prop cosmética — geralmente **não** merece teste próprio (ver anti-padrões
   abaixo).

Um componente trivial (renderiza props, sem lógica) não precisa de 5 testes — às vezes não precisa de
nenhum.

## O que NÃO testar

| ❌ Não faça | ✅ Faça no lugar |
| --- | --- |
| `expect(screen.getByRole('button')).toHaveClass('button--primary')` | `toHaveAttribute('aria-pressed', 'true')`, `toBeDisabled()`, ou outro contrato acessível/observável. Variante puramente visual vai para regressão visual no Playwright (`toHaveScreenshot()`), não para teste unitário. |
| Testar que um componente renderiza props sem nenhuma lógica (`<Avatar src={x} />` só passa `src` pro `<img>`) | Não escrever teste — não há comportamento a verificar. |
| Testar que uma prop foi repassada para um componente filho | Testar o efeito observável do filho renderizado, não a prop em si. |
| Snapshot de estrutura de DOM | Assertion específica do comportamento esperado. |
| Testar comportamento interno de biblioteca de terceiro (RHF, zod, Radix) | Testar só a integração que o seu código faz com ela. |
| `vi.mock` de componente filho | Renderizar a árvore real; mockar só bordas do sistema (rede, `localStorage`, `matchMedia`). |

## Assíncrono

- Use `findBy*` para o que aparece depois de uma ação assíncrona. Nunca
  `waitFor(() => expect(getByRole(...)).toBeInTheDocument())` — é redundante e a mensagem de erro é
  pior; `findBy*` já faz isso.
- Ausência só é uma asserção válida **depois** de esperar o sinal de que a operação terminou (ex.:
  `await screen.findByRole('button', { name: 'Entrar' })` voltar a ficar habilitado).
  `expect(screen.queryByRole('alert')).toBeNull()` isolado logo após disparar uma ação assíncrona
  passa trivialmente porque o elemento ainda nem teve chance de aparecer.
- Zero `waitForTimeout` / `sleep` arbitrário. Se precisa esperar algo, espere o sinal (elemento,
  chamada de mock, mudança de estado), não um tempo fixo.

## Exemplo completo aplicando os princípios

Formulário com submit assíncrono — é onde teste unitário paga; componente puramente apresentacional
geralmente não justifica este nível de cobertura.

```tsx
// LoginForm.test.tsx
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, it, expect, vi } from 'vitest';
import { LoginForm } from './LoginForm';

describe('LoginForm', () => {
  // O que pode dar errado: dado inválido
  it('exibe erro quando o e-mail não tem @', async () => {
    const user = userEvent.setup();
    render(<LoginForm onSubmit={vi.fn()} />);

    await user.type(screen.getByLabelText('E-mail'), 'invalido');
    await user.click(screen.getByRole('button', { name: 'Entrar' }));

    expect(await screen.findByText('E-mail inválido')).toBeInTheDocument();
  });

  // Ação: submit com dados válidos
  it('chama onSubmit com os dados quando o formulário é válido', async () => {
    const user = userEvent.setup();
    const onSubmit = vi.fn();
    render(<LoginForm onSubmit={onSubmit} />);

    await user.type(screen.getByLabelText('E-mail'), 'user@example.com');
    await user.type(screen.getByLabelText('Senha'), 'senha123');
    await user.click(screen.getByRole('button', { name: 'Entrar' }));

    expect(onSubmit).toHaveBeenCalledWith({ email: 'user@example.com', password: 'senha123' });
  });

  // Ação: estado transiente durante submit assíncrono
  it('desabilita o botão enquanto o submit está em andamento', async () => {
    const user = userEvent.setup();
    const onSubmit = vi.fn(() => new Promise((resolve) => setTimeout(resolve, 50)));
    render(<LoginForm onSubmit={onSubmit} />);

    await user.type(screen.getByLabelText('E-mail'), 'user@example.com');
    await user.type(screen.getByLabelText('Senha'), 'senha123');
    await user.click(screen.getByRole('button', { name: 'Entrar' }));

    expect(screen.getByRole('button', { name: 'Entrar' })).toBeDisabled();
    expect(await screen.findByRole('button', { name: 'Entrar' })).toBeEnabled();
  });

  // O que pode dar errado: servidor rejeita
  it('exibe erro do servidor sem quebrar quando a API rejeita', async () => {
    const user = userEvent.setup();
    const onSubmit = vi.fn(() => Promise.reject(new Error('Credenciais inválidas')));
    render(<LoginForm onSubmit={onSubmit} />);

    await user.type(screen.getByLabelText('E-mail'), 'user@example.com');
    await user.type(screen.getByLabelText('Senha'), 'errada');
    await user.click(screen.getByRole('button', { name: 'Entrar' }));

    expect(await screen.findByRole('alert')).toHaveTextContent('Credenciais inválidas');
  });
});
```

## Mocking de rede: MSW, não `vi.mock` de módulo de API

`vi.mock('./api')` testa o mock, não a integração — passa mesmo se a URL, o método, o header ou o
parsing da resposta estiverem errados. Prefira **MSW** (Mock Service Worker), que intercepta na
camada de rede: o componente faz a requisição de verdade, você só controla a resposta HTTP.

```ts
// src/mocks/handlers.ts
import { http, HttpResponse } from 'msw';

export const handlers = [
  http.post('/api/login', () => HttpResponse.json({ token: 'fake-token' })),
];
```

```ts
// src/mocks/server.ts
import { setupServer } from 'msw/node';
import { handlers } from './handlers';

export const server = setupServer(...handlers);
```

```ts
// src/test-setup.ts
import '@testing-library/jest-dom';
import { server } from './mocks/server';

beforeAll(() => server.listen({ onUnhandledRequest: 'error' }));
afterEach(() => server.resetHandlers());
afterAll(() => server.close());
```

`vi.mock` continua sendo a ferramenta certa para o que **não** é HTTP: `localStorage`, `matchMedia`,
`IntersectionObserver`, `crypto`.

## Regras inegociáveis

- Função em `src/lib/` tem teste quando tem ramificação, cálculo, parsing, ou já causou um bug uma
  vez. Não escreva teste para re-export, constante, ou wrapper trivial de uma linha só porque está em
  `src/lib/`.
- Testes de componente ficam colocados junto (`Button.test.tsx`).
- Prefira `screen.getByRole` a `getByTestId` — testa comportamento acessível.
- Teste o comportamento observável, não internals de implementação.
- Rede via MSW; `vi.mock` só para o que não é HTTP.
- Use `userEvent.setup()` no início de cada teste — não chame `userEvent.click(...)` direto sem
  `setup()` (a API direta ainda funciona, mas não isola pointer/clipboard entre testes e quebra com
  fake timers).

## Configuração mínima do Vitest

```ts
// vite.config.ts (ou vitest.config.ts separado)
test: {
  environment: 'jsdom',
  globals: false,
  setupFiles: './src/test-setup.ts',
  restoreMocks: true,
  clearMocks: true,
}
```

```ts
// src/test-setup.ts
import '@testing-library/jest-dom';
```

Com `globals: false`, importe `describe`, `it`, `expect`, `vi` explicitamente de `'vitest'` em cada
arquivo — funciona melhor com TypeScript e deixa claro de onde vem cada símbolo. `restoreMocks`/
`clearMocks` evitam mock vazando de um teste para o outro, causa comum de teste que passa sozinho e
falha quando roda junto com a suíte.

## Checklist antes de terminar

- [ ] Rodou a suíte inteira, não só o arquivo novo.
- [ ] Cada teste novo falha se você reverter a mudança que ele cobre (se não falha, o teste não testa
      nada).
- [ ] Nenhum `.only`, `.skip`, `waitForTimeout` ou `sleep` esquecido.
- [ ] Nenhuma asserção em classe CSS, estrutura de DOM ou snapshot.
- [ ] `findBy*` para tudo que é assíncrono; nenhum `waitFor(() => expect(getBy...))`.

## Skills relacionadas

- Estrutura de componente: `frontend/react`
- E2E de fluxo crítico: `frontend/playwright-e2e`
