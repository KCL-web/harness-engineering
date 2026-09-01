---
name: codebase-design
description: Vocabulário compartilhado para desenhar módulos profundos. Use quando o usuário quiser desenhar ou melhorar a interface de um módulo, encontrar oportunidades de aprofundamento, decidir onde fica um seam, tornar o código mais testável ou navegável por IA, ou quando outra skill precisar do vocabulário de módulo profundo.
---

# Codebase Design

> **Origem:** importada de [mattpocock/skills](https://github.com/mattpocock/skills) (`engineering/codebase-design`), adaptada ao vocabulário deste harness.

Desenhe **módulos profundos**: muito comportamento atrás de uma interface pequena, posicionada num seam limpo, testável através dessa interface. Use esta linguagem e estes princípios sempre que código estiver sendo desenhado ou reestruturado. O objetivo é leverage para quem chama, localidade para quem mantém, e testabilidade para todo mundo.

## Quando ler cada arquivo

| Tarefa | Arquivo |
| --- | --- |
| Aprofundar um cluster de módulos rasos dado suas dependências | [DEEPENING.md](DEEPENING.md) |
| Explorar interfaces alternativas com subagentes paralelos ("design it twice") | [DESIGN-IT-TWICE.md](DESIGN-IT-TWICE.md) |

## Glossário

Use estes termos exatamente: não substitua por "component", "service", "API" ou "boundary". Linguagem consistente é o ponto inteiro.

**Módulo**: qualquer coisa com uma interface e uma implementação. Deliberadamente agnóstico de escala: uma função, classe, pacote, ou fatia que atravessa camadas. _Evite_: unit, component, service.

**Interface**: tudo que quem chama precisa saber para usar o módulo corretamente: a assinatura de tipos, mas também invariantes, restrições de ordem, modos de erro, configuração obrigatória e características de performance. _Evite_: API, assinatura (estreito demais, referem-se só à superfície no nível de tipos).

**Implementação**: o que está dentro de um módulo, seu corpo de código. Distinto de **Adapter**: uma coisa pode ser um adapter pequeno com implementação grande (um repositório Postgres) ou um adapter grande com implementação pequena (um fake em memória). Recorra a "adapter" quando o seam é o assunto; "implementação" nos outros casos.

**Profundidade**: leverage na interface. A quantidade de comportamento que quem chama (ou um teste) consegue exercitar por unidade de interface que precisa aprender. Um módulo é **profundo** quando uma grande quantidade de comportamento está atrás de uma interface pequena, **raso** quando a interface é quase tão complexa quanto a implementação.

**Seam** _(Michael Feathers)_: um lugar onde você pode alterar comportamento sem editar naquele lugar; a *localização* onde a interface de um módulo vive. Onde colocar o seam é uma decisão de design própria, distinta do que fica atrás dele. _Evite_: boundary (sobrecarregado com o bounded context do DDD).

**Adapter**: uma coisa concreta que satisfaz uma interface num seam. Descreve *papel* (que encaixe preenche), não substância (o que tem dentro).

**Leverage**: o que quem chama ganha com a profundidade. Mais capacidade por unidade de interface que precisa aprender. Uma implementação se paga em N pontos de chamada e M testes.

**Localidade**: o que quem mantém ganha com a profundidade. Mudança, bugs, conhecimento e verificação se concentram num lugar só em vez de se espalhar entre quem chama. Corrige uma vez, corrigido em todo lugar.

## Profundo vs. raso

**Módulo profundo** = interface pequena + muita implementação:

```
┌─────────────────────┐
│  Interface pequena  │  ← Poucos métodos, params simples
├─────────────────────┤
│                     │
│ Implementação profunda│  ← Lógica complexa escondida
│                     │
└─────────────────────┘
```

**Módulo raso** = interface grande + pouca implementação (evite):

```
┌─────────────────────────────────┐
│       Interface grande          │  ← Muitos métodos, params complexos
├─────────────────────────────────┤
│  Implementação fina              │  ← Só repassa adiante
└─────────────────────────────────┘
```

Ao desenhar uma interface, pergunte:

- Dá pra reduzir o número de métodos?
- Dá pra simplificar os parâmetros?
- Dá pra esconder mais complexidade por dentro?

## Princípios

- **Profundidade é uma propriedade da interface, não da implementação.** Um módulo profundo pode ser composto internamente de partes pequenas, mockáveis, trocáveis; elas simplesmente não fazem parte da interface. Um módulo pode ter **seams internos** (privados à sua implementação, usados pelos próprios testes) além do **seam externo** na sua interface.
- **O teste da deleção.** Imagine deletar o módulo. Se a complexidade some, era um pass-through. Se a complexidade reaparece em N chamadores, ela estava merecendo seu lugar.
- **A interface é a superfície de teste.** Quem chama e os testes cruzam o mesmo seam. Se você quer testar *além* da interface, o módulo provavelmente tem a forma errada.
- **Um adapter é um seam hipotético. Dois adapters é um seam real.** Não introduza um seam a menos que algo de fato varie através dele.

## Desenhando para testabilidade

Boas interfaces tornam o teste natural:

1. **Aceite dependências, não as crie.**

   ```typescript
   // Testável
   function processOrder(order, paymentGateway) {}

   // Difícil de testar
   function processOrder(order) {
     const gateway = new StripeGateway();
   }
   ```

2. **Retorne resultados, não produza efeitos colaterais.**

   ```typescript
   // Testável
   function calculateDiscount(cart): Discount {}

   // Difícil de testar
   function applyDiscount(cart): void {
     cart.total -= discount;
   }
   ```

3. **Superfície pequena.** Menos métodos = menos testes necessários. Menos parâmetros = setup de teste mais simples.

## Relações

- Um **Módulo** tem exatamente uma **Interface** (a superfície que apresenta a quem chama e aos testes).
- **Profundidade** é uma propriedade de um **Módulo**, medida contra sua **Interface**.
- Um **Seam** é onde a **Interface** de um **Módulo** vive.
- Um **Adapter** senta num **Seam** e satisfaz a **Interface**.
- **Profundidade** produz **Leverage** para quem chama e **Localidade** para quem mantém.

## Enquadramentos rejeitados

- **Profundidade como razão linhas-de-implementação/linhas-de-interface** (Ousterhout): recompensa inflar a implementação. Usamos profundidade-como-leverage em vez disso.
- **"Interface" como a palavra-chave `interface` do TypeScript ou os métodos públicos de uma classe**: estreito demais: interface aqui inclui todo fato que quem chama precisa saber.
- **"Boundary"**: sobrecarregado com o bounded context do DDD. Diga **seam** ou **interface**.

## Skills relacionadas

- Loop TDD que testa através do seam definido aqui: `tdd`
- Vocabulário de domínio e `CONTEXT.md`: `domain-modeling`
- Revisão de dois eixos pós-implementação: `code-review`
