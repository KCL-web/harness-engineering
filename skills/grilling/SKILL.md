---
name: grilling
description: Interroga o dev de forma implacável sobre um plano, decisão ou ideia até chegar a um entendimento compartilhado. Invoque quando o dev quer estressar o próprio raciocínio, ou usa qualquer frase-gatilho com "grill". Importada de mattpocock/skills.
---

# Grilling

> **Origem:** importada de [mattpocock/skills](https://github.com/mattpocock/skills) (`productivity/grilling`), adaptada ao vocabulário deste harness.

Interrogue o dev de forma implacável até chegar a um entendimento compartilhado. Mapeie isso como uma **design tree** (árvore de decisão): toda decisão se ramifica nas decisões que dependem dela.

Trabalhe a árvore em **rounds** (rodadas). A **frontier** (fronteira) é todo item de decisão cujos pré-requisitos já estão resolvidos: as perguntas que dá para fazer _agora_ sem chutar respostas que ainda não foram ouvidas. Faça toda a fronteira numa rodada só: numere cada pergunta e dê sua resposta recomendada. Depois espere as respostas do dev antes de abrir a próxima rodada.

Formate uma rodada assim:

```
❓ **Q1** - **<título da pergunta>**: <corpo da pergunta, pode ter múltiplos parágrafos, incluindo múltiplas alternativas>

➡️ <sua resposta recomendada>

---

❓ **Q2** - **<título da pergunta>**: <corpo da pergunta, pode ter múltiplos parágrafos, incluindo múltiplas alternativas>

➡️ <sua resposta recomendada>
```

A cada rodada, as respostas do dev remodelam a árvore: decisões resolvidas empurram a fronteira para fora e destravam perguntas que dependiam delas. Recalcule a fronteira e faça a rodada seguinte. Uma pergunta cuja resposta depende de outra pergunta ainda aberta nesta rodada pertence a uma rodada _posterior_, não a esta.

Achar _fatos_ é trabalho seu, nunca do dev. Quando uma pergunta da fronteira precisa de um fato do ambiente (sistema de arquivos, ferramentas etc.), dispare um sub-agente para buscá-lo; não peça ao dev nada que você mesmo consiga pesquisar. Não bloqueie por causa disso: uma exploração em andamento é um pré-requisito ainda não resolvido, então só as perguntas que dependem dela esperam o sub-agente reportar — faça o resto da fronteira agora mesmo. As _decisões_, essas sim são do dev: coloque cada uma diante dele e espere.

A sessão termina quando a fronteira está vazia: todo ramo da árvore visitado, nada assumido em silêncio. Não aja com base no que foi levantado até o dev confirmar que vocês chegaram a um entendimento compartilhado.

## Skills relacionadas

- Primitiva reutilizada por outras skills de interrogatório: `grill-me`, `grill-with-docs`, `triage`, `wayfinder`, `improve-codebase-architecture`
