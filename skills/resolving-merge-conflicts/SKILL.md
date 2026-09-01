---
name: resolving-merge-conflicts
description: "Use quando precisar resolver um conflito de merge/rebase do git em andamento. Importada de mattpocock/skills."
---

# Resolving Merge Conflicts

> **Origem:** importada de [mattpocock/skills](https://github.com/mattpocock/skills) (`engineering/resolving-merge-conflicts`), adaptada ao vocabulário deste harness.

1. **Veja o estado atual** do merge/rebase. Confira o histórico do git e os arquivos em conflito.

2. **Encontre as fontes primárias** de cada conflito. Entenda a fundo por que cada mudança foi feita, e qual era a intenção original. Leia as mensagens de commit, confira as PRs (ver `workflow-prs`), confira as issues originais no Forgejo (ver `workflow-issues`).

3. **Resolva cada hunk.** Preserve as duas intenções sempre que possível. Onde forem incompatíveis, escolha a que combina com o objetivo declarado do merge e anote o trade-off. **Não** invente comportamento novo. Sempre resolva; nunca `--abort`.

4. Descubra as **checagens automatizadas** do projeto (o comando de validação em `.gsd/STACK.md`) e rode-as, tipicamente type check, depois testes, depois format. Conserte o que o merge quebrou.

5. **Finalize o merge/rebase.** Faça stage de tudo e commit, seguindo `workflow-commits`. Se estiver fazendo rebase, continue o processo de rebase até todos os commits serem rebaseados.

## Skills relacionadas

- Mensagem de commit: `workflow-commits`
- PR de origem do conflito: `workflow-prs`
- Issue de origem do conflito: `workflow-issues`
- Comando de validação do projeto: ver `.gsd/STACK.md`
