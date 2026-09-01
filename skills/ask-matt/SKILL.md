---
name: ask-matt
description: Pergunte qual skill ou fluxo se encaixa na sua situação. Um roteador sobre as skills deste repositório.
disable-model-invocation: true
---

# Ask Matt

> **Origem:** importada de [mattpocock/skills](https://github.com/mattpocock/skills) (`engineering/ask-matt`), adaptada ao vocabulário deste harness.

Você não memoriza toda skill que existe, então pergunte.

Um **fluxo** é um caminho pelas skills. A maioria dos caminhos percorre um **fluxo principal**, e dois **ramais de entrada** se juntam a ele. Tudo mais é independente, ou uma camada de vocabulário que roda por baixo.

## Quando ler cada arquivo

| Tarefa | Arquivo |
| --- | --- |
| Decidir entre continuar, `/clear`, `handoff`, subagente ou `/compact` numa fronteira de fase | [PHASE-BOUNDARIES.md](PHASE-BOUNDARIES.md) |

## O fluxo principal: ideia → shippado

A rota que a maior parte do trabalho percorre. Você tem uma ideia e quer construí-la.

1. **`grill-with-docs`** afia a ideia por entrevista. Comece aqui sempre que estiver **trabalhando num diretório de trabalho**: é stateful, retendo o que aprende em `CONTEXT.md` e ADRs. (Sem diretório de trabalho? Use `grill-me` (ver Independentes). Ambas rodam a mesma primitiva `grilling`; `grill-with-docs` é a que deixa rastro documental, o que a torna a melhor opção sempre que houver um repositório para deixar esse rastro.)
2. **Ramificação: dá pra resolver toda pergunta em conversa?** Se uma pergunta precisa de resposta executável (estado, lógica de negócio, uma UI que você precisa ver), desvie para um protótipo, conectado por **`handoff`** nas duas direções (um protótipo vive no seu próprio diretório, que é exatamente para isso que serve `handoff`; ver Fronteiras de fase):
   - **`handoff`** para fora, depois abra uma sessão nova contra esse arquivo,
   - **`prototype`** para responder a pergunta com código descartável,
   - **`handoff`** de volta trazendo o que você aprendeu, e referencie a partir da thread original da ideia.
3. **Ramificação: é uma build multi-sessão?**
   - **Sim** → **`to-spec`** (transforma a thread numa spec), depois **`to-tickets`** para dividir em tickets tracer-bullet, cada um declarando suas **arestas de bloqueio**. Neste harness os tickets viram issues no Forgejo seguindo o template e a mecânica de `workflow-issues` (marcador `Task:`, milestone `M0X`, label de sprint); como o Forgejo não tem link nativo de bloqueio entre issues, as arestas de bloqueio ficam documentadas no corpo da issue (referenciando o número da issue bloqueadora) e são trabalhadas bloqueadores-primeiro à mão. Dispare **`implement`** por ticket, dando **`/clear` no contexto entre cada um**. Cada ticket é autocontido, então o contexto do último é descartável.
   - **Não** → **`implement`** direto aqui, na mesma janela de contexto.

   De qualquer forma, **`implement`** constrói cada issue dirigindo **`tdd`** internamente (uma fatia red-green por vez), depois fecha rodando **`code-review`**, uma revisão de dois eixos (Standards + Spec) do diff, antes de commitar. Recorra a **`tdd`** sozinho quando você só quer construir um comportamento concreto test-first sem uma spec completa, e a **`code-review`** sozinho sempre que quiser revisar uma branch ou PR contra um ponto fixo.

### Higiene de contexto

Mantenha os passos 1–3 numa **única janela de contexto ininterrupta** (não dê `/compact` nem `/clear` até depois do `to-tickets`) para que a entrevista, a spec e os tickets se construam sobre o mesmo raciocínio. Cada `implement` então começa do zero, trabalhando a partir do ticket.

O limite disso é a **[smart zone](https://www.aihero.dev/ai-coding-dictionary/smart-zone)**: a janela (~150k tokens nos modelos mais avançados) dentro da qual o modelo ainda raciocina com nitidez. Se uma sessão se aproximar dela antes do `to-tickets`, não force no modo degradado; dê `/compact` na fronteira de fase mais próxima e continue (ver Fronteiras de fase).

## Ramais de entrada

Uma situação inicial que gera trabalho, depois se junta ao fluxo principal.

- **Bugs e pedidos empilhando** → **`triage`**. Move issues pelos papéis de triagem e produz issues prontas para agente, que o **`implement`** pega depois.

  Triagem é só para issues que **você não criou**: bug reports, pedidos de feature que chegam de fora, qualquer coisa que chegue crua. Tickets que o `to-tickets` produziu já estão prontos para agente, então **não triage-os**.

- **Algo quebrou** → **`diagnosing-bugs`**. Para os bugs difíceis: o que resiste a uma primeira olhada, o flake intermitente, a regressão que se infiltrou entre dois estados conhecidos como bons. Recusa-se a teorizar até ter um **loop de feedback apertado** (um comando que já fica red neste bug específico), depois corrige com um teste de regressão. O post-mortem dele repassa para `improve-codebase-architecture` quando a conclusão real é que não existe um bom seam para travar o bug.

- **Um esforço grande e nebuloso: um projeto greenfield ou uma feature enorme demais para uma sessão** → **`wayfinder`**, o fluxo mais exigente cognitivamente daqui. Quando o caminho daqui até o destino ainda não é visível, ele traça um **mapa compartilhado** de **tickets de decisão** no Forgejo (via `workflow-issues`) e resolve um de cada vez, produzindo **decisões, não entregáveis**, até a neblina recuar e o caminho ficar claro. Onde **`grill-with-docs`** afia uma ideia que cabe numa sessão, wayfinder é para a ideia que não cabe, e é mais lento e denso, então reserve para exatamente isso, nunca para uma feature bem definida.

  Quando o mapa clareia, **ele repassa, não constrói**: junte-se ao fluxo principal em **`to-spec`**, que colapsa as decisões interligadas do mapa num plano construível, depois `to-tickets` e `implement` como de costume. Pular o mapa direto para `implement` ignora esse colapso e joga fora o detalhe interligado, então vá direto para `implement` só quando o esforço acabou se mostrando genuinamente pequeno.

## Saúde do codebase

Não é trabalho de feature, é manutenção.

- **`improve-codebase-architecture`** roda sempre que você tem um momento livre para manter o codebase bom para agentes operarem nele. Ele revela **oportunidades de aprofundamento**; escolher uma _gera uma ideia_ que você leva para o fluxo principal em `grill-with-docs`. É o levantamento que encontra os candidatos; **`codebase-design`** (abaixo) é a bancada onde você desenha o escolhido.

## Vocabulário por baixo

Duas referências invocadas pelo modelo que rodam *por baixo* das outras skills, cada uma a fonte única de verdade do seu vocabulário. Recorra a elas diretamente quando o problema forem as **palavras**, não o processo; ou deixe as skills acima puxá-las.

- **`domain-modeling`**: afia a linguagem de *domínio* do projeto: desafia um termo vago, resolve uma palavra sobrecarregada ("conta" fazendo três papéis), registra uma decisão difícil de reverter como ADR. É a disciplina ativa que `grill-with-docs` conduz para manter o `CONTEXT.md` um glossário limpo.
- **`codebase-design`** é o vocabulário de módulo profundo (módulo, interface, profundidade, seam, adapter, leverage, localidade) para desenhar a *forma* de um módulo: muito comportamento atrás de uma interface pequena, num seam limpo. `tdd` e `improve-codebase-architecture` falam esse vocabulário.

## Fronteiras de fase

Uma **fase** é um pedaço de trabalho dentro de uma sessão: a entrevista, a implementação, o QA. Na **fronteira** entre duas fases você tem cinco opções, e escolher entre elas é a decisão mais nebulosa deste mapa inteiro:

- **Continuar**: ficar onde está. Não custa nada, não perde nada.
- **`/clear`**: esvaziar a janela, quando nada aqui importa para o que vem a seguir.
- **`handoff`** escreve um arquivo markdown portátil. Estreito: só para um **harness novo**, um **diretório novo**, um **colega**, ou bifurcar uma tarefa lateral **no meio da fase**. O que ele compra é portabilidade.
- **Subagente**: manda uma tarefa bem delimitada para a própria janela e recebe um relatório de volta.
- **`/compact`** comprime este contexto e semeia uma sessão nova com ele. O **padrão**, no fim da árvore em vez do primeiro recurso.

Leia [PHASE-BOUNDARIES.md](PHASE-BOUNDARIES.md) para a árvore ordenada: as cinco perguntas, o raciocínio por trás de cada ramo, e por que o custo da fonte primária faz o **Continuar** ser o primeiro a descartar. Tome a decisão **na** fronteira; no meio da fase, continue ou divida o resto em subagentes.

## Independentes

Fora do fluxo principal por completo.

- **`grill-me`**: a mesma entrevista implacável de `grill-with-docs`, mas **stateless**: não salva nada localmente nem constrói `CONTEXT.md`. Recorra a ela quando você **não está** num diretório de trabalho (afiando um plano, um design, um texto, qualquer coisa sem repositório embaixo). Se você está num diretório de trabalho, use `grill-with-docs`: roda a mesma entrevista e deixa rastro documental, então é estritamente a melhor opção.
- **`grilling`** é a primitiva de entrevista em si: rodadas, a fronteira do conhecido, fatos são trabalho do agente e decisões são suas. `grill-me` e `grill-with-docs` são as duas portas de entrada nomeadas, e `triage`, `wayfinder` e `improve-codebase-architecture` rodam ela internamente. Recorra a ela diretamente só quando quiser a entrevista sem nenhum wrapper em volta.
- **`resolving-merge-conflicts`** trabalha um merge ou rebase em conflito em andamento, hunk a hunk, resolvendo por **intenção** rastreada até a fonte primária de cada lado em vez de escolher linhas, depois finaliza a operação. Nunca roda `--abort`. Independente e fora de qualquer fluxo: recorra a ela quando você já está no meio de um conflito.
- **`prototype`** é um programa pequeno e descartável que responde uma pergunta de design: esse modelo de estado parece certo, ou qual deveria ser a cara dessa UI. Descartável é uma restrição em como o código é escrito, não uma promessa de destruí-lo: a resposta se incorpora ao código real, e o protótipo em si é mantido como **fonte primária** numa branch `prototype/<nome>` a partir de `develop` (ver `workflow-branching`), apontada a partir da issue de implementação. É o desvio do passo 2 do fluxo principal, mas recorra a ele sempre que uma pergunta de design for difícil de resolver no papel.
- **`research`**: delega o trabalho pesado de leitura para um **agente em background**: ele investiga uma pergunta contra **fontes primárias**, depois deixa um arquivo Markdown citado no repositório. Continue trabalhando enquanto ele lê. O arquivo que ele produz é algo para levar *para dentro* do fluxo principal em `grill-with-docs`, já que pesquisa alimenta o raciocínio em vez de substituí-lo.
- **`to-questionnaire`** entra quando o que está te travando não está na sua cabeça nem no codebase, mas na **cabeça de outra pessoa**, e escreve um questionário para ela preencher. É o inverso de `grill-me`: em vez de te entrevistar sobre o assunto, ele te entrevista sobre o **envio** (para quem vai, o que você precisa de volta) e mira as perguntas na lacuna. O que volta é material para `grill-with-docs` ou `to-spec`.
- **`wizard`** é para os passos que só um **humano** consegue dar: provisionar infraestrutura, configurar credenciais ou secrets de CI, clicar num dashboard de terceiros desconhecido, rodar uma migration ou cutover pontual. Gera um script bash interativo que abre cada URL, captura cada valor, e escreve no `.env` e nos secrets de CI do repositório, assim o procedimento para de ser algo que você reexplica pro agente toda vez. Invocado pelo modelo, então o agente recorre a ela no momento em que esbarra num muro que só um humano atravessa. Se o agente conseguisse fazer sozinho, deveria; isso é para quando um humano está genuinamente no loop.
- **`wait-what`** é o corretivo para uma mensagem que não foi entendida. Use no meio de uma conversa, dentro de qualquer outra skill, e o agente reapresenta o que acabou de dizer com o contexto que faltava, em português simples, usando o vocabulário do `CONTEXT.md`. Funciona depois do fato; `grill-with-docs` é a cura antecipada, porque uma linguagem compartilhada acordada cedo é o que evita o jargão chegar de saída.
- **`teach`**: aprenda um conceito ao longo de várias sessões, usando o diretório atual como um workspace stateful.
- **`writing-for-agents`** é a referência para escrever documentos que agentes consomem: skills, AGENTS.md, docs apontados.

## Pré-requisito

Este harness já fixa nativamente o tracker de issues, as convenções de branch/PR/commit e o layout de doc — não há setup equivalente ao `setup-matt-pocock-skills` da fonte. Antes do primeiro fluxo de engenharia, familiarize-se com `workflow-issues` (issues, milestones, sprints e template no Forgejo), `workflow-branching` (nomenclatura e hierarquia de branch) e `workflow-prs` (título/body de PR, `Closes #N`); `workflow-commits` cobre a mensagem de commit usada dentro de `implement`.

## Skills relacionadas

- Tracker, branch, PR, commit nativos deste harness: `workflow-issues`, `workflow-branching`, `workflow-prs`, `workflow-commits`
- Loop TDD: `tdd`
- Revisão de dois eixos: `code-review`
- Vocabulário de módulo/interface: `codebase-design`
- Vocabulário de domínio e `CONTEXT.md`/ADR: `domain-modeling`
- Diagnóstico de bugs difíceis: `diagnosing-bugs`
- Interview que gera `CONTEXT.md`/ADR: `grill-with-docs`
- Feature list e baseline: `ratchet-feature-list`
