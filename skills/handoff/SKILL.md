---
name: handoff
description: Compacta a conversa atual num documento de handoff para outro agente continuar.
argument-hint: "Para que a próxima sessão vai servir?"
disable-model-invocation: true
---

# Handoff

> **Origem:** importada de [mattpocock/skills](https://github.com/mattpocock/skills) (`productivity/handoff`), adaptada ao vocabulário deste harness.

Escreva um documento de handoff resumindo a conversa atual para que um agente novo consiga continuar o trabalho. Salve no diretório temporário do sistema operacional do dev — não no workspace do projeto.

Inclua uma seção "skills sugeridas" no documento, nomeando quais skills a próxima sessão deve invocar via Skill tool (por exemplo `workflow-issues` se sobrou trabalho de issue em aberto, `session-rituals` para o rito de início de sessão, ou qualquer skill de stack relevante ao que ficou pendente).

Não duplique conteúdo já capturado em outros artefatos (specs, planos, ADRs, issues do Forgejo, commits, diffs). Referencie-os por caminho ou URL em vez de copiar.

Redija (censure) qualquer informação sensível, como chaves de API, senhas ou dados pessoais identificáveis.

Se o dev passou argumentos, trate-os como uma descrição do que a próxima sessão vai focar e adapte o documento a isso.

## Skills relacionadas

- Ritos de início/fim de sessão: `session-rituals`
- Memória cross-projeto (o que vale virar drawer em vez de ficar só no handoff): `memory-palace`
- Mecânica de issues do Forgejo, caso o handoff referencie uma issue em aberto: `workflow-issues`
