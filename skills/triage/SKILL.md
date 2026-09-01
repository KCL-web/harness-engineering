---
name: triage
description: Move issues e PRs externas do Forgejo por uma máquina de estados de papéis de triagem, categoriza, verifica, "grilla" se preciso, e escreve briefs prontos para agente. Importada de mattpocock/skills.
disable-model-invocation: true
---

# Triage

> **Origem:** importada de [mattpocock/skills](https://github.com/mattpocock/skills) (`engineering/triage`), adaptada ao vocabulário deste harness.

Move issues no Forgejo deste workspace por uma pequena máquina de estados de papéis de triagem.

PRs externas de contribuidores fora do time também passam por triagem: **uma PR é uma issue com código anexado**, usando os mesmos papéis, os mesmos estados, a mesma máquina, com algumas diferenças marcadas "para PR" abaixo. No Forgejo, uma PR é internamente uma issue (mesma tabela, mesmos endpoints de labels/comentários em `issues/{index}`), só os campos específicos de diff/merge vivem em `pulls/{index}` — então a mecânica de label/comentário é idêntica entre issue e PR. Trate um `#42` isolado como issue ou PR consultando qual dos dois endpoints responde.

Todo comentário ou issue postado no Forgejo durante a triagem **deve** começar com este aviso:

```
> *Isso foi gerado por IA durante a triagem.*
```

## Documentos de referência

- [AGENT-BRIEF.md](AGENT-BRIEF.md): como escrever briefs de agente duráveis
- [OUT-OF-SCOPE.md](OUT-OF-SCOPE.md): como funciona a base de conhecimento `.out-of-scope/`

## Papéis

Dois papéis de **categoria**, que reaproveitam os labels de tipo que `workflow-issues` já usa:

- `bug` → label de tipo `fix`: algo está quebrado
- `enhancement` → label de tipo `feat`: feature nova ou melhoria

Cinco papéis de **estado**, como labels novos no mesmo esquema (`tipo`/`sprint`/`priority`) de `workflow-issues`, com prefixo `triage/`:

- `triage/needs-triage`: mantenedor precisa avaliar
- `triage/needs-info`: aguardando mais informação de quem reportou
- `triage/ready-for-agent`: totalmente especificado, pronto para um agente AFK
- `triage/ready-for-human`: precisa de implementação humana
- `triage/wontfix`: não será feito

Para uma PR, os mesmos estados se leem contra o código anexado: `triage/ready-for-agent` significa que há um brief anexado e um agente deve dar o próximo passo no diff; `triage/ready-for-human` significa que está pronta para um humano mergear.

Toda issue triada deve carregar exatamente um label de categoria (`fix` ou `feat`) e um label de estado `triage/*`. Se os labels de estado conflitarem (mais de um `triage/*` na mesma issue), sinalize e pergunte ao mantenedor antes de fazer qualquer coisa.

Esses labels não existem ainda no esquema padrão de `workflow-issues` — crie-os na primeira vez que a triagem rodar neste repositório (mesmo endpoint `POST /repos/{org}/{repo}/labels` documentado em `workflow-issues`), e depois reutilize.

Transições de estado: uma issue sem label de estado normalmente vai para `triage/needs-triage` primeiro; dali se move para `triage/needs-info`, `triage/ready-for-agent`, `triage/ready-for-human`, ou `triage/wontfix`. `triage/needs-info` volta para `triage/needs-triage` assim que quem reportou responde. O mantenedor pode sobrepor a qualquer momento; sinalize transições que parecerem incomuns e pergunte antes de prosseguir.

## Invocação

O mantenedor invoca `/triage` e descreve o que quer em linguagem natural. Interprete o pedido e aja. Exemplos:

- "Mostra o que precisa da minha atenção"
- "Vamos ver a #42" (issue ou PR)
- "Move a #42 para ready-for-agent"
- "O que está pronto pra agente pegar?"

## Mostrar o que precisa de atenção

Consulte o Forgejo (`GET /repos/{org}/{repo}/issues?type=issues&state=open` e o equivalente para PRs) e apresente três grupos, do mais antigo para o mais novo:

1. **Sem label de estado**: nunca triada.
2. **`triage/needs-triage`**: avaliação em andamento.
3. **`triage/needs-info` com atividade de quem reportou desde as últimas notas de triagem**: precisa de reavaliação.

Quando PRs estão no escopo, inclua PRs externas nesses grupos e marque cada linha `[PR]` ou `[issue]`. A descoberta mostra só PRs *externas* (uma PR é externa quando o autor não é membro do org `$FORGEJO_ORG` nem está listado como colaborador do repo — confira via `GET /repos/{org}/{repo}/collaborators` ou a lista de membros do org), então uma PR em andamento de alguém do time não é trabalho de triagem. Esse filtro vale só para a descoberta; uma PR nomeada explicitamente é sempre triada, seja quem for o autor.

Mostre contagens e um resumo de uma linha por item. Deixe o mantenedor escolher.

## Triar uma issue ou PR específica

1. **Reúna contexto.** Leia a issue ou PR completa (body, comentários, labels, autor, datas; para PR, o diff também). Interprete quaisquer notas de triagem anteriores para não reperguntar o que já foi resolvido. Explore o código usando o glossário de domínio do projeto, respeitando os ADRs da área. Rode duas checagens contra o código: (a) **redundância**: procure uma implementação já existente do comportamento pedido, por conceito de domínio (não só pelas palavras do pedido), e reporte onde procurou. Se encontrar, é um `triage/wontfix` já implementado (passo 5). (b) **rejeição prévia**: leia `.out-of-scope/*.md` e mostre qualquer arquivo parecido com este pedido.

2. **Recomende.** Diga ao mantenedor sua recomendação de categoria e estado com justificativa, mais um resumo curto do código relevante ao pedido (incluindo se já está implementado). Espere direção.

3. **Verifique a alegação.** Antes de qualquer grilling, confira se a alegação se sustenta. Para um bug, reproduza a partir dos passos de quem reportou. Para uma PR, confirme que o diff faz o que alega: faça checkout, rode os testes ou comandos relevantes. Reporte o que aconteceu: confirmado (com o caminho de código), falhou, ou informação insuficiente (um sinal forte de `triage/needs-info`). Uma verificação confirmada produz um brief de agente muito mais forte.

4. **Grille (se necessário).** Se o pedido precisa ser lapidado, chame a Skill tool duas vezes, para `grilling` e `domain-modeling`, e grille-o em rodadas, uma leva de perguntas por vez, afiando termos de domínio e atualizando `CONTEXT.md`/ADRs inline conforme as decisões forem batidas.

5. **Aplique o resultado:**
   - `triage/ready-for-agent`: poste um agent brief como comentário ([AGENT-BRIEF.md](AGENT-BRIEF.md)).
   - `triage/ready-for-human`: mesma estrutura do agent brief, mas anote por que não pode ser delegado (julgamento humano, acesso externo, decisões de design, teste manual).
   - `triage/needs-info`: poste notas de triagem (template abaixo).
   - Para `triage/wontfix`, feche a issue, com o comentário variando conforme o *motivo*:
     - **Já implementado**: a mudança já existe no código. Aponte onde ela vive; NÃO escreva em `.out-of-scope/` (essa base é para pedidos *rejeitados*, não para os já construídos).
     - **Rejeitado (bug)**: dê uma explicação educada, depois feche.
     - **Rejeitado (enhancement)**: escreva em `.out-of-scope/`, linke a partir de um comentário, depois feche ([OUT-OF-SCOPE.md](OUT-OF-SCOPE.md)).
   - `triage/needs-triage`: aplique o label. Comentário opcional se houver progresso parcial.

## Sobreposição rápida de estado

Se o mantenedor disser "move a #42 para ready-for-agent", confie e aplique o label diretamente. Confirme o que está prestes a fazer (mudança de labels, comentário, fechamento), depois aja. Pule o grilling. Se mover para `triage/ready-for-agent` sem uma sessão de grilling, pergunte se querem que você escreva um agent brief.

## Template de needs-info

```markdown
## Triage Notes

**O que já estabelecemos até aqui:**

- ponto 1
- ponto 2

**O que ainda precisamos de você (@reporter):**

- pergunta 1
- pergunta 2
```

Capture tudo que foi resolvido durante o grilling em "o que já estabelecemos" para que o trabalho não se perca. Perguntas precisam ser específicas e acionáveis, não "por favor forneça mais informação".

## Retomando uma sessão anterior

Se já existem notas de triagem anteriores na issue ou PR, leia-as, confira se quem reportou respondeu alguma pergunta pendente, e apresente um panorama atualizado antes de continuar. Não repergunte o que já foi resolvido.

## Skills relacionadas

- Mecânica de issue, milestone, sprint, label no Forgejo: `workflow-issues`
- Grilling e vocabulário de domínio: `grilling`, `domain-modeling`
- Publicar spec e quebrar em tickets: `to-spec`, `to-tickets`
- Planejamento de esforços grandes: `wayfinder`
