# Formato do CONTEXT.md

## Estrutura

```md
# {Nome do Contexto}

{Uma ou duas frases descrevendo o que é este contexto e por que ele existe.}

## Linguagem

**Order**:
{Uma ou duas frases descrevendo o termo}
_Evite_: Purchase, transaction

**Invoice**:
Uma cobrança enviada a um cliente após a entrega.
_Evite_: Bill, payment request

**Customer**:
Uma pessoa ou organização que faz pedidos.
_Evite_: Client, buyer, account
```

## Regras

- **Seja opinativo.** Quando várias palavras existem para o mesmo conceito, escolha a melhor e liste as outras em `_Evite_`.
- **Mantenha definições enxutas.** Uma ou duas frases no máximo. Defina o que a coisa É, não o que ela faz.
- **Inclua só termos específicos do contexto deste projeto.** Conceitos gerais de programação (timeouts, tipos de erro, padrões utilitários) não pertencem aqui mesmo que o projeto os use extensivamente. Antes de adicionar um termo, pergunte: isso é um conceito único deste contexto, ou um conceito geral de programação? Só o primeiro pertence aqui.
- **Agrupe termos sob subtítulos** quando clusters naturais surgirem. Se todos os termos pertencem a uma área coesa só, uma lista plana está de bom tamanho.

## Repositórios de contexto único vs. múltiplo

**Contexto único (a maioria dos repositórios):** Um `CONTEXT.md` na raiz do repositório.

**Múltiplos contextos:** Um `CONTEXT-MAP.md` na raiz do repositório lista os contextos, onde vivem, e como se relacionam:

```md
# Context Map

## Contexts

- [Ordering](./src/ordering/CONTEXT.md): recebe e rastreia pedidos de clientes
- [Billing](./src/billing/CONTEXT.md): gera faturas e processa pagamentos
- [Fulfillment](./src/fulfillment/CONTEXT.md): gerencia picking e envio no armazém

## Relationships

- **Ordering → Fulfillment**: Ordering emite eventos `OrderPlaced`; Fulfillment os consome para iniciar o picking
- **Fulfillment → Billing**: Fulfillment emite eventos `ShipmentDispatched`; Billing os consome para gerar faturas
- **Ordering ↔ Billing**: Tipos compartilhados para `CustomerId` e `Money`
```

A skill infere qual estrutura se aplica:

- Se `CONTEXT-MAP.md` existe, leia-o para encontrar os contextos
- Se só um `CONTEXT.md` na raiz existe, contexto único
- Se nenhum dos dois existe, crie um `CONTEXT.md` na raiz de forma preguiçosa quando o primeiro termo for resolvido

Quando múltiplos contextos existem, infira a qual o tópico atual se relaciona. Se não estiver claro, pergunte.
