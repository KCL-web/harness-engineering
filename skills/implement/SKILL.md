---
name: implement
description: "Implementa um trabalho a partir de um spec ou conjunto de issues. Importada de mattpocock/skills."
disable-model-invocation: true
---

# Implement

> **Origem:** importada de [mattpocock/skills](https://github.com/mattpocock/skills) (`engineering/implement`), adaptada ao vocabulário deste harness.

Implemente o trabalho descrito pelo dev no spec ou nas issues.

Use a skill `tdd` sempre que possível, nos seams pré-acordados.

Rode o type check com frequência, arquivos de teste isolados com frequência, e a suíte completa de testes uma vez ao final.

Ao terminar, use a skill `code-review` para revisar o trabalho.

Faça commit do trabalho na branch atual, seguindo a convenção de `workflow-commits`. Atualização e fechamento de issue não são passos manuais: acontecem automaticamente quando a PR com `Closes #N` mergeia (ver `workflow-issues`/`workflow-prs`) — não crie, edite nem mova issues fora dessa mecânica.

## Skills relacionadas

- Loop test-first: `tdd`
- Revisão pós-implementação: `code-review`
- Mensagem de commit: `workflow-commits`
- Issues, milestones e status: `workflow-issues`
- Abrir PR que fecha a issue: `workflow-prs`
- Nome e origem da branch: `workflow-branching`
