---
name: to-questionnaire
description: Transforma uma decisão que você não consegue responder sozinho num questionário para outra pessoa preencher.
disable-model-invocation: true
---

# To Questionnaire

> **Origem:** importada de [mattpocock/skills](https://github.com/mattpocock/skills) (`productivity/to-questionnaire`), adaptada ao vocabulário deste harness.

Transforme algo que o dev não consegue responder sozinho num **questionário**: um documento Markdown que ele entrega para uma pessoa preencher de forma assíncrona, ou preencher junto numa reunião. O destinatário tem o conhecimento que o dev não tem; o questionário extrai isso dele.

**Interrogue o envio, não o assunto.** Entreviste o dev só sobre o _envio_, que ele sempre consegue responder: para quem vai, e o que ele precisa de volta. As perguntas do documento então miram a **lacuna** entre o que o destinatário sabe e o que o dev precisa.

1. **Para quem vai?** Pergunte, numa única troca, o papel do destinatário, sua expertise e sua relação com o dev. Isso fixa o tom do questionário e quanto contexto ele precisa carregar. Terminado quando você sabe quem é o destinatário e o que ele sabe que o dev não sabe.

2. **O que você precisa de volta?** Pergunte, numa única troca, as decisões ou fatos concretos que o dev não consegue resolver sozinho e precisa dessa pessoa. Terminado quando você tem uma lista concreta do que o dev precisa conseguir fazer ou decidir ao final.

3. **Escreva o questionário.** Redija perguntas mirando a lacuna dos passos 1–2, seguindo a estrutura de documento abaixo. Escreva em `to-questionnaire-<slug>.md` no diretório atual (slug a partir do tema) e reporte o caminho. Terminado quando o arquivo existe e todo item que o dev nomeou no passo 2 está coberto por uma pergunta.

## Estrutura do documento

Enquadre o documento como um **discovery questionnaire** (questionário de descoberta): o dev carece de contexto, o destinatário o detém. Ordene as perguntas da mais importante para a menos importante, já que ser assíncrono pode significar só uma passada, e agrupe sob headings `##` por tema quando houver mais que um punhado de perguntas. Escreva usando o template abaixo.

<questionnaire-template>

# <Título do questionário>

**Propósito:** por que este questionário existe e a decisão que depende dele.

**De:** <o dev>, **Para:** <o destinatário>, **Como suas respostas serão usadas:** <para onde elas vão>

## Contexto

Um parágrafo situando um destinatário que não estava na cabeça do dev. O suficiente para responder bem, não uma página.

## Como responder

Prazo e esforço aproximado. Respostas parciais e "não sei" são úteis: sinalize qualquer coisa da qual você não tem certeza em vez de pular.

## <Título do tema>

Uma seção `##` por tema. Sob cada uma, suas perguntas, da mais importante para a menos importante. Cada pergunta é uma ideia só, nunca composta, com um espaço de resposta logo abaixo, e uma linha _por que isso importa_ só onde a pergunta puder ser mal-interpretada ou convidar a uma resposta descartável.

<question-example>
### Que carga o sistema deve suportar no lançamento?

_Por que isso importa: decide se provisionamos para tráfego em rajada agora ou adiamos isso._

>
</question-example>

## Mais alguma coisa?

Um fechamento coringa: algo que não perguntamos e deveríamos saber?

</questionnaire-template>

## Skills relacionadas

- Interrogatório de trade-offs e decisões que o próprio dev consegue responder: `grilling`
- Mecânica de issues do Forgejo, caso o questionário alimente uma issue: `workflow-issues`
