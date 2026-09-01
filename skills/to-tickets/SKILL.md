---
name: to-tickets
description: "Quebra um plano, spec, ou a conversa atual em um conjunto de tickets tracer-bullet, cada um declarando suas dependências (bloqueios), publicados como issues no Forgejo com os labels e milestones do workflow-issues. Importada de mattpocock/skills."
disable-model-invocation: true
---

# To Tickets

> **Origem:** importada de [mattpocock/skills](https://github.com/mattpocock/skills) (`engineering/to-tickets`), adaptada ao vocabulário deste harness.

Quebre o trabalho em **tickets**: fatias verticais tracer-bullet, cada um declarando os tickets que o **bloqueiam**.

Publicação sempre no Forgejo, pela mecânica de `workflow-issues`.

## Processo

### 1. Reúna contexto

Trabalhe a partir do que já está no contexto da conversa. Se o dev passar uma referência (caminho de spec, número ou URL de issue) como argumento, busque-a e leia o corpo e os comentários completos.

### 2. Explore o código (opcional)

Se ainda não explorou o código, faça-o para entender o estado atual. Títulos e descrições de ticket devem usar o vocabulário do glossário de domínio do projeto, e respeitar os ADRs da área que está tocando.

Procure oportunidades de fazer um prefactor no código para facilitar a implementação. "Torne a mudança fácil, depois faça a mudança fácil."

### 3. Esboce fatias verticais

Quebre o trabalho em tickets **tracer bullet**.

<vertical-slice-rules>

- Cada fatia corta um caminho estreito, mas COMPLETO, por toda camada (schema, API, UI, testes): vertical, NÃO uma fatia horizontal de uma única camada
- Uma fatia concluída é demonstrável ou verificável por si só
- Cada fatia é dimensionada para caber numa única sessão de contexto fresco
- Qualquer prefactoring deve ser feito primeiro

</vertical-slice-rules>

Dê a cada ticket suas **arestas de bloqueio**: os outros tickets que precisam terminar antes que ele possa começar. Um ticket sem bloqueadores pode começar imediatamente.

**Refactors largos são a exceção ao fatiamento vertical.** Um **refactor largo** é uma mudança mecânica única (renomear uma coluna, retipar um símbolo compartilhado) cujo **raio de impacto** se espalha pelo código inteiro, de modo que uma única edição quebra milhares de pontos de uso de uma vez e nenhuma fatia vertical consegue ficar verde sozinha. Não force isso num tracer bullet; sequencie como **expand–contract**. Primeiro expanda: adicione a forma nova ao lado da antiga sem quebrar nada. Depois migre os pontos de uso em lotes dimensionados pelo raio de impacto (por pacote, por diretório), cada lote seu próprio ticket bloqueado pelo expand, mantendo a validação verde lote a lote porque a forma antiga ainda existe. Por fim contraia: apague a forma antiga quando não sobrar nenhum chamador, num ticket bloqueado por todos os lotes de migração. Quando nem os lotes conseguem ficar verdes sozinhos, mantenha a sequência mas deixe-os compartilhar uma branch de integração que todos bloqueiam num ticket final de integrar-e-verificar; o verde só é prometido ali.

### 4. Questione o dev

Apresente a quebra proposta como lista numerada. Para cada ticket, mostre:

- **Título**: nome curto e descritivo
- **Bloqueado por**: quais outros tickets (se houver) precisam terminar antes
- **O que entrega**: o comportamento ponta a ponta que este ticket faz funcionar

Pergunte ao dev:

- A granularidade está certa? (grossa demais / fina demais)
- As arestas de bloqueio estão corretas: cada ticket depende só dos tickets que realmente o travam?
- Algum ticket deveria ser fundido ou dividido mais?

Itere até o dev aprovar a quebra.

### 5. Publique os tickets no Forgejo

Publique os tickets aprovados como issues, um por ticket, na ordem de dependência (bloqueadores primeiro), seguindo a mecânica de `workflow-issues`:

- **Título**: formato Conventional Commits, igual a `workflow-commits`/`workflow-prs` (ex.: `feat(checkout): add payment step`).
- **Marcador `Task:`**: se o ticket mapeia para uma task do ROADMAP, adicione `Task: M0X-S0X-T0X` na primeira linha do body e associe milestone + label `sprint/M0X-S0X`, exatamente como `workflow-issues` descreve. Se for uma quebra ad hoc que ainda não está no ROADMAP, omita o marcador e a milestone.
- **Parent**: se a origem foi uma issue de spec existente (publicada por `to-spec`), referencie-a na primeira seção do body (`## Parent` → link/número da issue).
- **Label de triagem**: aplique `triage/ready-for-agent` (ver skill `triage`) — os tickets já nascem prontos para um agente pegar.
- **Bloqueio**: use a API de dependências de issues do Forgejo quando o recurso estiver habilitado no repositório (endpoint `issues/{index}/dependencies`, renderiza nativamente na UI do Forgejo). Se não estiver habilitado, registre o bloqueio como texto na seção `## Blocked by` do body, referenciando o número de cada ticket bloqueador. De qualquer forma, publique os tickets em ordem de dependência (bloqueadores primeiro) para que cada um possa referenciar identificadores reais.

Trabalhe a **fronteira**: qualquer ticket cujos bloqueadores estejam todos concluídos. Para uma cadeia puramente linear, isso é de cima para baixo.

NÃO feche nem modifique nenhuma issue-mãe.

<issue-template>

## Parent

Uma referência à issue-mãe no Forgejo (se a origem foi uma issue existente; senão, omita esta seção).

## What to build

O comportamento ponta a ponta que este ticket faz funcionar, da perspectiva do usuário, não uma lista de implementação camada por camada.

## Acceptance criteria

- [ ] Critério 1
- [ ] Critério 2
- [ ] Comando de validação do projeto passa (ver `.gsd/STACK.md`)

## Blocked by

- Uma referência a cada ticket bloqueador (número/link), ou "None (can start immediately)".

</issue-template>

Em qualquer caso, evite caminhos de arquivo específicos ou trechos de código: eles ficam desatualizados rápido. Exceção: se um protótipo produziu um trecho que encapsula uma decisão com mais precisão do que a prosa consegue (state machine, reducer, schema, formato de tipo), inclua-o e anote brevemente que veio de um protótipo. Corte para as partes ricas em decisão, não uma demo funcional — só o essencial.

## Skills relacionadas

- Publicar a spec de origem: `to-spec`
- Mecânica de issue, milestone, sprint no Forgejo: `workflow-issues`
- Branch a partir do ticket: `workflow-branching`
- PR que fecha o ticket: `workflow-prs`
- Estados de triagem e labels: `triage`
- Planejamento de esforços grandes demais para um ticket só: `wayfinder`
