---
name: writing-for-agents
description: Escrever documentos para agentes. Invoque ao criar ou editar skills, ou ao modificar AGENTS.md ou CLAUDE.md.
---

# Writing For Agents

> **Origem:** importada de [mattpocock/skills](https://github.com/mattpocock/skills) (`productivity/writing-for-agents`), adaptada ao vocabulário deste harness.

Referência para escrever qualquer documento que um agente consome: uma skill, um `AGENTS.md`/`CLAUDE.md`, um doc alcançado por um ponteiro. A embalagem muda; a escrita não: as mesmas alavancas tornam cada um previsível, já que o agente segue o mesmo _processo_ a cada execução em vez de produzir o mesmo output.

Quando o documento que você está escrevendo é uma skill, leia [`SKILL-MECHANICS.md`](SKILL-MECHANICS.md) para frontmatter, escolha de invocação, e router skills.

## Context pointers

Um **context pointer** (ponteiro de contexto) é uma referência mantida no contexto do agente que nomeia algum material fora do contexto e codifica a condição para alcançá-lo. A `description` de uma skill é um exemplo; uma linha em `AGENTS.md` nomeando um doc é o mesmo objeto. É a _redação_ do ponteiro, não seu alvo, que decide quando o agente alcança o material, e com que confiabilidade. Um alvo indispensável atrás de um ponteiro fracamente redigido é um bug de variância: afie a redação primeiro, e só faça inline do material se afiar falhar.

Um ponteiro faz dois trabalhos: dizer o que o material é, e listar as **branches** (ramificações) que devem disparar o alcance dele (uma branch é um caso distinto que o documento trata, de forma que execuções diferentes seguem caminhos diferentes por ele). Toda palavra de um ponteiro sempre carregado custa em todo turno, então ele merece uma poda ainda mais dura que o corpo do documento:

- **Coloque a palavra líder na frente**: é onde o ponteiro faz seu trabalho de disparo.
- **Um gatilho por branch.** Sinônimos que só renomeiam uma única branch são uma branch escrita duas vezes; colapse-os e mantenha só as branches genuinamente distintas.
- **Corte identidade que o corpo já carrega.**

## As duas cargas

Todo documento e ponteiro que você adiciona gasta um de dois orçamentos:

- **Context load** (carga de contexto) é o custo de material sempre carregado na janela do agente: uma linha do `AGENTS.md`, a description de uma skill, qualquer coisa presente no contexto a cada turno, gastando tokens e atenção esteja ela disparando ou não.
- **Cognitive load** (carga cognitiva) é o custo sobre o humano: quais documentos existem e quando recorrer a cada um. O humano é o índice. Não é um custo a minimizar: é o preço da agência humana; gaste-a onde o julgamento humano importa, remova-a onde não importa.

Material alcançado só por meio de um ponteiro escapa da carga de contexto ao preço da linha do próprio ponteiro; material sem nenhum ponteiro cavalga inteiramente sobre a carga cognitiva.

## Hierarquia de informação

Um documento é construído a partir de dois tipos de conteúdo: **steps** (os passos, as ações ordenadas que o agente executa) e **reference** (referência: definições, regras, fatos consultados sob demanda). Os dois se misturam livremente: todo em steps (uma receita), todo em reference (as regras de uma revisão, esta própria skill), ou os dois. A decisão central é onde cada peça se posiciona na **information hierarchy** (hierarquia de informação), uma escada ordenada por quão imediatamente o agente precisa do material:

1. **In-file step** (passo no próprio arquivo) é o degrau primário: o que o agente faz, em ordem.
2. **In-file reference** (referência no próprio arquivo) é consultada sob demanda. Frequentemente um conjunto legitimamente plano de pares (cada regra de uma revisão no mesmo degrau), o que é um arranjo perfeitamente aceitável, não um cheiro de problema.
3. **Disclosed reference** (referência exposta à parte) é empurrada para um arquivo separado, alcançada por um context pointer, carregada só quando o ponteiro dispara. Vai de um arquivo irmão na mesma pasta até referência totalmente externa que vive em qualquer lugar e que qualquer documento pode apontar.

Empurrar de menos para baixo incha o topo; empurrar demais esconde material que o agente realmente precisa. Essa tensão é a decisão inteira.

**Progressive disclosure** (divulgação progressiva) é o movimento escada abaixo (para fora do arquivo principal e atrás de um ponteiro) para que o topo permaneça legível. Não é primariamente uma otimização de tokens: é como a hierarquia é protegida. Branching é o teste mais limpo de disclosure: deixe inline o que toda branch precisa, e empurre atrás de um ponteiro o que só algumas branches alcançam. Quando um documento tem steps, referência no próprio arquivo que deveria estar exposta à parte os enterra e transforma prestar atenção neles numa moeda ao ar: uma alavanca de variância, não só de legibilidade.

**Co-location** (co-localização) é a companheira, dentro do arquivo, da escada: onde a hierarquia decide _até que ponto embaixo_ uma peça fica, co-location decide _o que fica ao lado dela_ uma vez ali. Mantenha a definição, as regras e as ressalvas de um conceito sob um único heading em vez de espalhadas, para que ler uma parte traga os vizinhos junto. O teste: o documento deveria ler como documentação escrita para o agente. Material agrupado lê assim; material espalhado não. (Distinto de duplicação: esta repete um significado em dois lugares; espalhar fragmenta um significado por muitos.)

**Sprawl** (espraiamento) é o modo de falha aqui: um documento simplesmente longo demais, mesmo quando toda linha é viva e única. A atenção se dilui pelo excesso, e cada linha extra é mais uma para manter relevante. A cura é a escada: exponha referência atrás de ponteiros, e divida por branch ou sequência para que cada caminho carregue só o que precisa.

## Steps e critérios de conclusão

Todo step termina num **completion criterion** (critério de conclusão), a condição que diz ao agente que o trabalho está feito. Duas propriedades fazem dele uma alavanca:

- **Clarity** (clareza): o agente consegue distinguir feito de não feito? Um limite vago ("entendimento alcançado") convida à **premature completion** (conclusão prematura): encerrar o step antes de ele estar genuinamente feito, com a atenção escorregando para _estar feito_. Os steps visivelmente ainda pela frente (os **post-completion steps**, passos pós-conclusão) fornecem o puxão; a clareza do critério é a resistência. Defenda nesta ordem: **afie o limite primeiro** (local e barato); só se ele for irredutivelmente vago _e_ você observar o atropelo, esconda os steps posteriores dividindo a sequência. Esconder só funciona através de uma fronteira de contexto de verdade (um handoff ou o disparo de um sub-agente; uma chamada inline deixa os steps posteriores no contexto e não resolve nada).
- **Demand** (demanda): o quanto ele exige. "Todo model modificado contabilizado" força um trabalho minucioso onde "produza uma lista de mudanças" não força. Demand impulsiona o **legwork** (o trabalho braçal que o agente faz dentro da tarefa, latente na redação em vez de escrito como um step próprio), e não está preso a steps: "toda regra aplicada" amarra um corpo de referência plana do mesmo jeito que "todo step feito" amarra uma sequência, o que é como um documento todo-referência ainda carrega uma régua de exaustividade.

Os critérios mais fortes são ao mesmo tempo verificáveis e exaustivos.

## Quando dividir

Dividir um documento em dois gasta uma das duas cargas, então divida só quando o corte se justificar:

- **Por sequência**: divida uma sequência de steps onde os post-completion steps tentam o agente a atropelar o que está na frente dele. Manter os posteriores fora de vista força mais legwork na tarefa atual. Cuidado com o inverso: fundir sequências expõe os steps posteriores de cada step ao que vem depois, convidando à conclusão prematura.
- **Por invocação**, específico de skill: veja [`SKILL-MECHANICS.md`](SKILL-MECHANICS.md).

## Palavras líderes

Uma **leading word** (palavra líder) é um conceito compacto que já vive no pré-treino do modelo, com o qual o agente pensa enquanto executa o documento (_lesson_, _fog of war_, _tracer bullets_). Repetida como token, nunca como frase, ela acumula uma definição distribuída e ancora uma região inteira de comportamento no menor número de tokens, ao recrutar priors que o modelo já possui. Cunhar sua própria palavra funciona se você a define claramente, mas uma palavra inventada não recruta priors: você paga em tokens de definição o que uma palavra pré-treinada dá de graça; busque uma palavra já existente primeiro.

Ela ancora duas vezes. No corpo, _execução_: o agente recorre ao mesmo comportamento toda vez que a palavra aparece, e dentro de referência plana ela foca a atenção numa classe de coisa a procurar. Num ponteiro, _invocação_: quando a mesma palavra vive nos seus prompts, nos seus docs e no seu código, o agente liga essa linguagem compartilhada ao material e o alcança de forma mais confiável.

Cace oportunidades de refatorar com palavras líderes. Uma tríade soletrada em três lugares, um ponteiro gastando uma frase para apontar para uma ideia só. Cada uma é uma passagem implorando para colapsar num único token:

- "rápido, determinístico, de baixo overhead" → _tight_ (um loop _tight_).
- "um loop em que você confia" → _red_, transformando um portão vago num estado observável binário (o loop fica _red_ no bug, ou não fica).

Você ganha duas vezes: menos tokens, e um gancho mais afiado para o agente pendurar seu raciocínio. Assuma que todo documento carrega restatements que palavras líderes aposentam. Vá encontrá-los.

**Negation** (negação) é o modo de falha ao lado dessa alavanca: guiar por proibição arrasta o comportamento proibido para o contexto e o torna _mais_ disponível, não menos. _Não pense num elefante_, e o elefante é tudo o que existe; a negação é um modificador fraco que o conceito fortemente ativado sobrepuja, então a proibição meio que se lê como uma instrução para fazer a coisa. Instrua o **positivo**: declare o comportamento-alvo ("escreva comentários de uma linha") para que o proibido nunca seja sequer falado. Uma proibição só se justifica como um guardrail rígido que você não consegue frasear positivamente; mesmo assim, combine-a com o alvo positivo para que a atenção pouse no que fazer.

## Poda

- Mantenha cada significado numa **single source of truth** (fonte única de verdade): um único lugar autoritativo, para que mudar o comportamento seja uma edição num lugar só. **Duplicação** (o mesmo significado em mais de um lugar) custa manutenção e tokens, e infla a proeminência de um significado na escada além do seu ranking real. (O inverso acidental de uma palavra líder, que repete um token de propósito, nunca o significado.)
- O **ambiente** também é uma fonte de verdade (scripts do `package.json`, arquivos de config, o layout de diretórios, a saída de `--help`), e um documento que o restata é um **cache**: uma cópia de uma consulta, que só se justifica quando a consulta é cara. Faça cache do que o agente não consegue encontrar olhando: a convenção não escrita, a razão por trás de uma escolha, a pegadinha que nenhuma config confessa. Deixe as consultas de um arquivo, um comando só, para o ambiente, onde elas não podem ficar obsoletas.
- Cheque toda linha quanto a **relevance** (relevância): ela ainda tem relação com o que o documento faz? Uma linha perde relevância por nunca ter relação com a tarefa (mera exposição, ou uma branch que deveria estar exposta à parte) ou por ficar obsoleta conforme o comportamento ou o mundo que ela descreve muda. Documentos mais curtos são mais fáceis de manter relevantes. Sem uma disciplina de poda, o destino padrão é o **sediment** (sedimento): camadas obsoletas que se acumulam porque adicionar parece seguro e remover parece arriscado, até você precisar escavar por elas para achar o que ainda está vivo.
- Cace **no-ops** frase por frase: uma instrução que o modelo já obedece por padrão custa carga para não dizer nada. O teste (isso muda o comportamento em relação ao padrão?) é relativo ao modelo, não ao leitor: duas pessoas discordando sobre um no-op estão discordando sobre o padrão, e resolvem isso rodando o documento, não debatendo. Quando uma frase falha no teste, apague a frase inteira em vez de aparar palavras dela. O teste também avalia palavras líderes: uma palavra fraca demais para vencer o padrão (_seja minucioso_ quando o agente já é meio minucioso) é um no-op, e o conserto é uma palavra mais forte (_implacável_), não uma técnica diferente.

## Skills relacionadas

- Como o harness usa skills auto-evolutivas (FIX/DERIVED/CAPTURED) e quando promover uma referência solta para skill curada: `evolving-skills`
