# Fronteiras de fase

Uma **fase** é um pedaço de trabalho dentro de uma sessão: a entrevista, a implementação, o QA. A definição é vaga de propósito: uma fase termina quando você pensa *"ok, terminamos essa parte"*.

A **fronteira de fase** é o vão entre duas fases, e é o único lugar onde essa decisão cabe. No meio da fase não há decisão a tomar: continue, ou divida o que falta em subagentes. Compactar no meio da fase faz o agente perder o fio.

## As cinco opções

| Opção | O que faz |
| --- | --- |
| **Continuar** | Ficar na sessão. Nenhuma troca de contexto. |
| **`/clear`** | Esvazia a janela de contexto e recomeça do zero. |
| **`handoff`** | Escreve um markdown portátil e inicia uma sessão em qualquer lugar com ele. |
| **Subagente** | Manda a tarefa para sua própria janela de contexto e recebe um relatório de volta. |
| **`/compact`** | Compacta este contexto e inicia uma sessão nova com o resumo. |

## A árvore

Trabalhe de cima para baixo na fronteira. O primeiro **sim** vence.

**1. Dá pra continuar nesta sessão?** Duas coisas tornam a resposta sim: a próxima fase precisa desta fase como **fonte primária**, ou você tem [smart zone](https://www.aihero.dev/ai-coding-dictionary/smart-zone) suficiente sobrando (~150k tokens) para a próxima fase caber. Entrevista → implementação é o sim padrão: a implementação quer o raciocínio literal, não um resumo dele. Continuar não custa nada e não perde nada, então descarte antes de qualquer outra coisa.

**2. O contexto é irrelevante para o que vem a seguir?** Tudo nesta sessão (a exploração, as decisões, os becos sem saída) é descartável? Se sim, **`/clear`**. É o movimento mais barato do tabuleiro: não toma tempo e devolve a janela inteira. `/clear` também não é terminal: a sessão antiga continua retomável.

O custo de errar aqui é de mão única. Dê `/clear` num contexto *relevante* e você perde o **porquê** por trás do que construiu, e nenhuma releitura do diff devolve isso.

**3. Você precisa repassar para outro lugar?** `handoff` é estreito. Você só precisa dele quando está:

- trocando para um **harness novo** (Claude → Codex),
- movendo para um **diretório** ou repositório **novo**,
- enviando o trabalho para um **colega**,
- ou bifurcando uma tarefa lateral que encontrou **no meio da fase** sem descarrilar o que está fazendo.

Essa lista é a cláusula inteira. O que `handoff` compra é **portabilidade**: um arquivo que viaja. Se nada está viajando, você não precisa dele.

**4. A tarefa pode ser feita longe do teclado?** Está delimitada o suficiente para rodar com você ausente, sem direcionamento? Então mande para um **subagente** e deixe esta sessão intocada. Revisão automatizada é o caso padrão: o agente lê o diff e reporta, e você não é necessário enquanto isso acontece.

**5. Senão, `/compact`.** Contexto relevante, mesmo harness, mesmo diretório, e você precisa continuar no loop: é aqui que a árvore chega, e chega aqui com frequência. Passe uma instrução (`/compact vamos fazer QA nesta área`) para que o resumo mantenha o que a próxima fase precisa.

`/compact` é o **padrão, não o primeiro recurso**. Fica no fim porque as quatro perguntas acima dele são todas mais baratas ou mais precisas. O modo de falha de quem começa por aqui é uma sessão nova confiantemente errada sobre uma decisão que o resumo achatou.

## Fontes primárias e secundárias

Todo movimento exceto **Continuar** transforma uma **fonte primária** numa **fonte secundária**: a sessão como aconteceu, substituída por um resumo dela. A troca é sempre da mesma forma:

| Fonte | Informação | Ruído | Espaço para manobra |
| --- | --- | --- | --- |
| Primária (Continuar) | Completa | Muito | Pouco |
| Secundária (`/compact`, `handoff`) | Com perdas | Menos | Muito |

É por isso que a pergunta 1 vem primeiro. Você só paga a perda de informação quando ficar custa mais do que economiza.

## Isso são decisões de julgamento

As perguntas não são objetivas: cada uma tem gosto nela, e a mesma fronteira pode ir para dois lados em dois dias diferentes. O valor está em perguntá-las **em ordem**, na fronteira em vez de no meio do trabalho.
