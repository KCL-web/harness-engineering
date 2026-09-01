# Testes (Vitest + Testing Library)

## Os 3 princípios obrigatórios

Todo teste de componente ou função deve cobrir pelo menos estes três ângulos:

### 1. Parâmetros (variações de entrada)
Teste cada variante relevante dos props/argumentos. Se um componente aceita `variant="primary" | "secondary"`, ambas devem ter teste. Se uma função aceita um número, teste limites (0, negativo, muito grande).

```ts
it('renderiza variant primary', () => { ... });
it('renderiza variant secondary', () => { ... });
it('usa primary como padrão quando variant não é passado', () => { ... });
```

### 2. Ações (cada interação é candidata a teste)
Cada ação do usuário que o componente suporta (click, submit, change, hover com efeito visível) é um candidato de teste.

```ts
it('chama onSubmit com dados corretos ao submeter o form', async () => { ... });
it('desabilita o botão enquanto isSubmitting é true', async () => { ... });
it('limpa o campo ao clicar em reset', async () => { ... });
```

### 3. O que pode dar errado (dados inválidos, nulos, invertidos, edge cases)
- Dados inválidos: email sem `@`, senha curta demais, CPF com letras.
- Dados nulos/undefined: prop obrigatória ausente, resposta de API vazia.
- Dados invertidos: ordenação DESC quando se espera ASC, booleano negado.
- Boundary: string vazia `""`, array vazio `[]`, objeto `{}`.

```ts
it('exibe erro quando email é inválido', async () => { ... });
it('exibe estado vazio quando lista retorna []', () => { ... });
it('não quebra quando onClose é undefined', () => { ... });
```

## Exemplo completo aplicando os 3 princípios

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

## Regras de testes unitários / integração

- Toda função em `src/lib/` precisa de teste em `src/lib/__tests__/`.
- Testes de componente ficam colocados junto (`Button.test.tsx`).
- Prefira `screen.getByRole` a `getByTestId` — testa comportamento acessível.
- Teste o comportamento observável, não internals de implementação.
- `vi.mock` só para módulos de borda do sistema (API calls, localStorage). Não moque componentes filhos.

## Configuração mínima do Vitest

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
