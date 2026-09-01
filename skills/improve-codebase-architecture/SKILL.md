---
name: improve-codebase-architecture
description: Varre a codebase em busca de oportunidades de aprofundamento (deepening), apresenta como relatório HTML visual, depois grilla a que for escolhida. Importada de mattpocock/skills.
disable-model-invocation: true
---

# Improve Codebase Architecture

> **Origem:** importada de [mattpocock/skills](https://github.com/mattpocock/skills) (`engineering/improve-codebase-architecture`), adaptada ao vocabulário deste harness.

Traga à tona a fricção arquitetural e proponha **oportunidades de aprofundamento**: refatorações que transformam módulos rasos em módulos profundos. O objetivo é testabilidade e navegabilidade por IA.

Este comando é _informado_ pelo modelo de domínio do projeto e construído sobre um vocabulário de design compartilhado:

- Invoque a skill `codebase-design` para o vocabulário de arquitetura (**módulo**, **interface**, **profundidade**, **seam**, **adapter**, **leverage**, **localidade**) e seus princípios (o teste de deleção, "a interface é a superfície de teste", "um adapter = seam hipotético, dois = seam real"). Use esses termos exatamente em cada sugestão, e não escorregue para "componente", "serviço", "API" ou "boundary".
- A linguagem de domínio em `CONTEXT.md` dá nomes aos bons seams; os ADRs em `docs/adr/` registram decisões que este comando não deve reabrir.

## Processo

### 1. Explorar

**Delimite o escopo antes de varrer: YAGNI.** Aprofundar um módulo só compensa se isso facilitar mudanças futuras nele, então dê peso extra às partes da codebase que mudaram recentemente. Decida *onde* olhar antes de olhar:

- Se o dev indicou uma direção (um módulo, um subsistema, um ponto de dor), siga-a e pule a inferência abaixo.
- Caso contrário, percorra um bom trecho do histórico de commits (`git log --oneline`) para achar os hot spots da codebase — os arquivos e áreas que voltam sempre — e deixe que esses caminhos puxem sua atenção primeiro. Se as mudanças estiverem espalhadas sem hot spot claro, amplie a rede.

Leia primeiro o glossário de domínio do projeto (`CONTEXT.md`) e qualquer ADR na área que está tocando.

Depois, dispare um subagente para percorrer a codebase. Não siga heurísticas rígidas; explore organicamente e anote onde sentir fricção:

- Onde entender um conceito exige pular entre muitos módulos pequenos?
- Onde os módulos são **rasos**, com uma interface quase tão complexa quanto a implementação?
- Onde funções puras foram extraídas só por testabilidade, mas os bugs reais se escondem em como elas são chamadas (sem **localidade**)?
- Onde módulos fortemente acoplados vazam através dos seus seams?
- Quais partes da codebase estão sem teste, ou são difíceis de testar pela interface atual?

Aplique o **teste de deleção** a qualquer coisa que você suspeite ser rasa: deletar isso concentraria a complexidade, ou só a moveria? Um "sim, concentra" é o sinal que você quer.

### 2. Apresentar candidatos como um relatório HTML

Escreva um arquivo HTML autocontido no diretório temp do SO, para que nada caia no repositório. Resolva o diretório temp a partir de `$TMPDIR`, caindo para `/tmp` (ou `%TEMP%` no Windows), e escreva em `<tmpdir>/architecture-review-<timestamp>.html` para que cada execução gere um arquivo novo. Abra-o para o dev (`xdg-open <path>` no Linux, `open <path>` no macOS, `start <path>` no Windows) e informe o caminho absoluto.

O relatório usa **Tailwind via CDN** para layout e estilo, e **Mermaid via CDN** para diagramas onde um grafo/fluxo/sequência comunica a estrutura de forma confiável. Misture Mermaid com visuais em CSS/SVG feitos à mão: use Mermaid quando as relações têm forma de grafo (grafos de chamada, dependências, sequências), e divs/SVG feitos à mão quando quiser algo mais editorial (diagramas de massa, cortes transversais, animações de colapso). Cada candidato recebe uma **visualização antes/depois**. Seja visual.

Para cada candidato, renderize um card com:

- **Arquivos**: quais arquivos/módulos estão envolvidos
- **Problema**: por que a arquitetura atual causa fricção
- **Solução**: descrição em português simples do que mudaria
- **Benefícios**: explicados em termos de localidade e leverage, e como os testes melhorariam
- **Diagrama Antes / Depois**: lado a lado, desenhado sob medida, ilustrando a rasidão e o aprofundamento
- **Força da recomendação**: uma de `Strong`, `Worth exploring`, `Speculative`, renderizada como badge

Termine o relatório com uma seção **Top recommendation**: qual candidato você atacaria primeiro e por quê.

**Use o vocabulário do `CONTEXT.md` para o domínio, e o vocabulário da skill `codebase-design` para a arquitetura.** Se `CONTEXT.md` define "Order," fale sobre "o módulo de intake de Order," não sobre "o FooBarHandler," nem "o serviço de Order."

**Conflitos com ADR**: se um candidato contradiz um ADR existente, só o traga à tona quando a fricção for real o bastante para justificar reabrir o ADR. Marque isso claramente no card (ex.: um callout de aviso: _"contradiz o ADR-0007, mas vale reabrir porque…"_). Não liste toda refatoração teórica que um ADR proíbe.

Veja [HTML-REPORT.md](HTML-REPORT.md) para o scaffold HTML completo, padrões de diagrama e orientação de estilo.

NÃO proponha interfaces ainda. Depois de escrever o arquivo, pergunte ao dev: "Qual desses você gostaria de explorar?"

### 3. Loop de grilling

Quando o dev escolher um candidato, invoque a skill `grilling` para percorrer com ele a árvore de decisão: restrições, dependências, a forma do módulo aprofundado, o que fica atrás do seam, quais testes sobrevivem.

Efeitos colaterais acontecem inline conforme as decisões se cristalizam; invoque a skill `domain-modeling` para manter o modelo de domínio atualizado ao longo do caminho:

- **Nomeando um módulo aprofundado com um conceito que não está em `CONTEXT.md`?** Adicione o termo ao `CONTEXT.md`. Crie o arquivo de forma preguiçosa (lazy) se ele não existir.
- **Afiando um termo vago durante a conversa?** Atualize o `CONTEXT.md` na hora.
- **O dev rejeita o candidato com uma razão que pesa (load-bearing)?** Ofereça um ADR, com a frase: _"Quer que eu registre isso como um ADR para que futuras revisões de arquitetura não sugiram a mesma coisa de novo?"_ Só ofereça quando a razão realmente for necessária para um explorador futuro evitar repetir a mesma sugestão; pule razões efêmeras ("não vale a pena agora") e razões óbvias.
- **Quer explorar interfaces alternativas para o módulo aprofundado?** Invoque a skill `codebase-design` e use seu padrão de subagentes paralelos "design it twice".

## Nota de idioma no relatório gerado

O scaffold HTML em [HTML-REPORT.md](HTML-REPORT.md) é reproduzido tal como na fonte (em inglês, como exemplo de código). Ao gerar o relatório de verdade para o dev, escreva os textos (títulos, legendas, rótulos dos cards, prosa) em **pt-BR**, seguindo a regra de idioma deste harness (ver AGENTS.md) — só os termos de vocabulário de `codebase-design` (module, interface, seam, adapter, leverage etc., quando mantidos em inglês por não terem tradução natural) e nomes de classes/CSS ficam como estão.

## Skills relacionadas

- Vocabulário de arquitetura: `codebase-design`
- Vocabulário de domínio e `CONTEXT.md`/ADRs: `domain-modeling`
- Sessão de decisão guiada: `grilling`
- Revisão de código: `code-review`
- Loop test-first: `tdd`
- Feature list e baseline: `ratchet-feature-list`
