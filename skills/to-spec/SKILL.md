---
name: to-spec
description: "Transforma a conversa atual em uma spec e publica como issue no Forgejo: sem entrevista, só síntese do que já foi discutido. Importada de mattpocock/skills."
disable-model-invocation: true
---

# To Spec

> **Origem:** importada de [mattpocock/skills](https://github.com/mattpocock/skills) (`engineering/to-spec`), adaptada ao vocabulário deste harness.

Esta skill pega o contexto da conversa atual e o entendimento do código e produz uma spec. NÃO entreviste o dev; apenas sintetize o que você já sabe.

A publicação é sempre no Forgejo deste workspace, pela mecânica de `workflow-issues`.

## Processo

1. Explore o repositório para entender o estado atual do código, se ainda não o fez. Use o vocabulário do glossário de domínio do projeto ao longo da spec, e respeite quaisquer ADRs na área que está tocando.

2. Esboce os seams em que você vai testar a feature. Prefira seams existentes a novos. Use o seam mais alto possível. Se novos seams forem necessários, proponha-os no ponto mais alto que puder. Quanto menos seams espalhados pelo código, melhor — o ideal é um só.

   Confirme com o dev que esses seams batem com a expectativa dele.

3. Escreva a spec usando o template abaixo, então publique-a como uma **issue no Forgejo** (ver `workflow-issues` para o formato da API, `FORGEJO_TOKEN`/`FORGEJO_URL`/`FORGEJO_ORG` e convenções de milestone/label). Esta issue ainda não precisa do marcador `Task:` nem de milestone — ela é a spec-mãe que a skill `to-tickets` depois quebra em tickets menores, cada um com seu próprio marcador quando mapear para uma task do ROADMAP. Aplique o label `triage/ready-for-agent` (ver skill `triage`) — não precisa de triagem adicional.

<spec-template>

## Problem Statement

O problema que o usuário enfrenta, da perspectiva do usuário.

## Solution

A solução para o problema, da perspectiva do usuário.

## User Stories

Uma lista LONGA e numerada de user stories. Cada user story deve seguir o formato:

1. As an <actor>, I want a <feature>, so that <benefit>

<user-story-example>
1. As a mobile bank customer, I want to see balance on my accounts, so that I can make better informed decisions about my spending
</user-story-example>

Essa lista de user stories deve ser extremamente extensa e cobrir todos os aspectos da feature.

## Implementation Decisions

Uma lista de decisões de implementação que foram tomadas. Pode incluir:

- Os módulos que serão construídos/modificados
- As interfaces desses módulos que serão modificadas
- Esclarecimentos técnicos do desenvolvedor
- Decisões arquiteturais
- Mudanças de schema
- Contratos de API
- Interações específicas

NÃO inclua caminhos de arquivo específicos nem trechos de código. Eles tendem a ficar desatualizados rápido.

Exceção: se um protótipo produziu um trecho que encapsula uma decisão com mais precisão do que a prosa consegue (state machine, reducer, schema, formato de tipo), inclua-o dentro da decisão relevante e anote brevemente que veio de um protótipo. Corte para as partes ricas em decisão, não uma demo funcional — só o essencial.

## Testing Decisions

Uma lista de decisões de teste que foram tomadas. Inclua:

- Uma descrição do que faz um bom teste (testar só comportamento externo, não detalhes de implementação)
- Quais módulos serão testados
- Referências (prior art) para os testes (ex.: tipos similares de teste já existentes no código)

## Out of Scope

Uma descrição do que está fora de escopo para esta spec.

## Further Notes

Quaisquer notas adicionais sobre a feature.

</spec-template>

## Skills relacionadas

- Quebrar a spec publicada em tickets executáveis: `to-tickets`
- Mecânica de issue, milestone, sprint no Forgejo: `workflow-issues`
- Estados de triagem e labels: `triage`
- Loop de implementação test-first: `tdd`
