# Formato do relatório HTML

A revisão arquitetural é renderizada como um único arquivo HTML autocontido no diretório temp do SO. Tailwind e Mermaid vêm ambos de CDNs. Mermaid lida bem com diagramas em forma de grafo; divs feitas à mão e SVG inline lidam com os visuais mais editoriais (diagramas de massa, cortes transversais). Misture os dois: não se apoie no Mermaid para tudo, ou vai começar a parecer genérico.

## Scaffold

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <title>Architecture review for {{repo name}}</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script type="module">
      import mermaid from "https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs";
      mermaid.initialize({ startOnLoad: true, theme: "neutral", securityLevel: "loose" });
    </script>
    <style>
      /* small custom layer for things Tailwind doesn't cover cleanly:
         dashed seam lines, hand-drawn-feeling arrow heads, etc. */
      .seam { stroke-dasharray: 4 4; }
      .leak { stroke: #dc2626; }
      .deep { background: linear-gradient(135deg, #0f172a, #1e293b); }
    </style>
  </head>
  <body class="bg-stone-50 text-slate-900 font-sans">
    <main class="max-w-5xl mx-auto px-6 py-12 space-y-12">
      <header>...</header>
      <section id="candidates" class="space-y-10">...</section>
      <section id="top-recommendation">...</section>
    </main>
  </body>
</html>
```

## Header

Nome do repo, data, e uma legenda compacta: caixa sólida = módulo, linha tracejada = seam, seta vermelha = vazamento (leakage), caixa grossa e escura = módulo profundo. Sem parágrafo de introdução. Direto para os candidatos.

## Card do candidato

Os diagramas carregam o peso. A prosa é escassa, simples, e usa os termos do glossário (da skill `codebase-design`) sem cerimônia.

Cada candidato é um `<article>`:

- **Título**: curto, nomeia o aprofundamento (ex.: "Colapsar o pipeline de intake de Order").
- **Linha de badges**: força da recomendação (`Strong` = esmeralda, `Worth exploring` = âmbar, `Speculative` = cinza-ardósia), mais uma tag para a categoria de dependência (`in-process`, `local-substitutable`, `ports & adapters`, `mock`).
- **Arquivos**: lista monoespaçada, `font-mono text-sm`.
- **Diagrama Antes / Depois**: a peça central. Duas colunas, lado a lado. Ver padrões abaixo.
- **Problema**: uma frase. O que dói.
- **Solução**: uma frase. O que muda.
- **Ganhos**: bullets, ≤6 palavras cada. Ex.: "Testes batem em uma interface", "Lógica de pricing para de vazar", "Deleta 4 wrappers rasos".
- **Callout de ADR** (se aplicável): uma linha numa caixa com tom âmbar.

Sem parágrafos de explicação. Se o diagrama precisa de um parágrafo para ser entendido, redesenhe o diagrama.

## Padrões de diagrama

Escolha o padrão que se encaixa no candidato. Misture-os. Não deixe todo diagrama com a mesma cara. Variedade é parte do ponto.

### Grafo Mermaid (o cavalo de batalha para dependências / fluxo de chamadas)

Use um `flowchart` ou `graph` do Mermaid quando o ponto é "X chama Y chama Z, e olha a bagunça." Envolva em um card com estilo Tailwind para não parecer largado ali de paraquedas. Estilize com classDef para colorir arestas de vazamento em vermelho e o módulo profundo em escuro. Diagramas de sequência funcionam bem para "antes: 6 idas e voltas; depois: 1."

```html
<div class="rounded-lg border border-slate-200 bg-white p-4">
  <pre class="mermaid">
    flowchart LR
      A[OrderHandler] --> B[OrderValidator]
      B --> C[OrderRepo]
      C -.leak.-> D[PricingClient]
      classDef leak stroke:#dc2626,stroke-width:2px;
      class C,D leak
  </pre>
</div>
```

### Caixas-e-setas feitas à mão (quando o layout do Mermaid briga com você)

Módulos como `<div>`s com bordas e rótulos. Setas como elementos SVG `<line>` ou `<path>` inline, posicionados de forma absoluta sobre um container relativo. Recorra a isso quando quiser que o diagrama "depois" pareça um único módulo profundo de borda grossa com internals acinzentados, já que o Mermaid não renderiza isso com o peso certo.

### Corte transversal (bom para rasidão em camadas)

Empilhe faixas horizontais (`h-12 border-l-4`) para mostrar as camadas pelas quais uma chamada passa. Antes: 6 camadas finas, cada uma sem fazer nada de útil. Depois: 1 faixa grossa rotulada com a responsabilidade consolidada.

### Diagrama de massa (bom para "interface tão larga quanto a implementação")

Dois retângulos por módulo: um para a área de superfície da interface, um para a implementação. Antes: o retângulo de interface é quase tão alto quanto o de implementação (raso). Depois: o retângulo de interface é curto, o de implementação é alto (profundo).

### Colapso de grafo de chamadas

Antes: uma árvore de chamadas de função renderizada como caixas aninhadas. Depois: a mesma árvore colapsada em uma única caixa, com as chamadas agora internas mostradas esmaecidas dentro dela.

## Orientação de estilo

- Editorial enxuto, não dashboard corporativo. Espaço em branco generoso. Serifada opcional para títulos (`font-serif` combina bem com stone/slate).
- Cor com moderação: um acento (esmeralda ou índigo) mais vermelho para vazamento e âmbar para avisos.
- Mantenha os diagramas com ~320px de altura para que antes/depois caibam lado a lado sem rolagem.
- Use `text-xs uppercase tracking-wider` para rótulos de módulo dentro dos diagramas, para que leiam como esquema, não como UI.
- Os únicos scripts são o CDN do Tailwind e o import ESM do Mermaid. O relatório é, fora isso, estático: sem código de app, sem interatividade além da própria renderização do Mermaid.

## Seção de recomendação principal

Um card maior. Nome do candidato, uma frase do porquê, link âncora para o card dele. Só isso.

## Tom

Português simples, conciso, mas os substantivos e verbos arquiteturais vêm direto do glossário da skill `codebase-design`. Concisão não é desculpa para escorregar no vocabulário.

**Use exatamente:** módulo, interface, implementação, profundidade, profundo, raso, seam, adapter, leverage, localidade.

**Nunca substitua:** componente, serviço, unidade (por módulo) · API, assinatura (por interface) · boundary (por seam) · camada, wrapper (por módulo, quando o sentido é módulo).

**Frases que combinam com o estilo:**

- "O módulo de intake de Order é raso: a interface quase iguala a implementação."
- "Pricing vaza pelo seam."
- "Aprofunde: uma interface, um lugar para testar."
- "Dois adapters justificam o seam: HTTP em produção, in-memory nos testes."

**Bullets de ganhos** nomeiam o ganho em termos do glossário: *"localidade: bugs se concentram em um módulo"*, *"leverage: uma interface, N pontos de chamada"*, *"a interface encolhe; a implementação absorve os wrappers"*. Não escreva *"mais fácil de manter"* ou *"código mais limpo"*, porque esses termos não estão no glossário e não merecem espaço aqui.

Sem enrolação, sem preâmbulo, sem "vale notar que…". Se uma frase pode virar bullet, vire bullet. Se um bullet pode ser cortado, corte-o. Se um termo não está no glossário da skill `codebase-design`, procure um que esteja antes de inventar um novo.
