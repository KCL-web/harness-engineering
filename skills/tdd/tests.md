# Testes bons e ruins

## Testes bons

**Estilo integração**: testa através de interfaces reais, não mocks de partes internas.

```typescript
// BOM: testa comportamento observável
test("usuário consegue finalizar compra com carrinho válido", async () => {
  const cart = createCart();
  cart.add(product);
  const result = await checkout(cart, paymentMethod);
  expect(result.status).toBe("confirmed");
});
```

Características:

- Testa comportamento que usuários/chamadores se importam
- Usa só a API pública
- Sobrevive a refatorações internas
- Descreve O QUÊ, não COMO
- Uma asserção lógica por teste

## Testes ruins

**Testes de detalhe de implementação**: acoplados à estrutura interna.

```typescript
// RUIM: testa detalhe de implementação
test("checkout chama paymentService.process", async () => {
  const mockPayment = jest.mock(paymentService);
  await checkout(cart, payment);
  expect(mockPayment.process).toHaveBeenCalledWith(cart.total);
});
```

Sinais de alerta:

- Mockar colaboradores internos
- Testar métodos privados
- Verificar contagem/ordem de chamadas
- Teste quebra ao refatorar sem mudança de comportamento
- Nome do teste descreve COMO, não O QUÊ
- Verificar por meio externo em vez da interface

```typescript
// RUIM: contorna a interface para verificar
test("createUser salva no banco", async () => {
  await createUser({ name: "Alice" });
  const row = await db.query("SELECT * FROM users WHERE name = ?", ["Alice"]);
  expect(row).toBeDefined();
});

// BOM: verifica através da interface
test("createUser torna o usuário recuperável", async () => {
  const user = await createUser({ name: "Alice" });
  const retrieved = await getUser(user.id);
  expect(retrieved.name).toBe("Alice");
});
```

**Testes tautológicos**: o valor esperado reafirma a implementação, então o teste passa por construção.

```typescript
// RUIM: valor esperado é recalculado do jeito que o código calcula
test("calculateTotal soma os itens", () => {
  const items = [{ price: 10 }, { price: 5 }];
  const expected = items.reduce((sum, i) => sum + i.price, 0);
  expect(calculateTotal(items)).toBe(expected);
});

// BOM: valor esperado é um literal conhecido e independente
test("calculateTotal soma os itens", () => {
  expect(calculateTotal([{ price: 10 }, { price: 5 }])).toBe(15);
});
```
