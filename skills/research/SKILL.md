---
name: research
description: Investiga uma pergunta contra fontes primárias de alta confiança e captura os achados como um arquivo Markdown no repo. Use quando o dev quer um tópico pesquisado, fatos de docs/API levantados, ou o trabalho braçal de leitura delegado a um agente em background. Importada de mattpocock/skills.
---

# Research

> **Origem:** importada de [mattpocock/skills](https://github.com/mattpocock/skills) (`engineering/research`), adaptada ao vocabulário deste harness.

Dispare um **agente em background** (Agent tool, `run_in_background`) para fazer a pesquisa, assim você continua trabalhando enquanto ele lê.

O trabalho dele:

1. Investigar a pergunta contra **fontes primárias** (docs oficiais, código-fonte, specs, APIs first-party), não uma versão secundária delas. Rastreie cada afirmação até a fonte que a origina.
2. Escrever os achados num único arquivo Markdown, citando a fonte de cada afirmação.
3. Salvá-lo onde o repo já guarda notas desse tipo; siga a convenção existente (ex.: `docs/` ou `.gsd/`), e se não houver nenhuma, coloque em um lugar sensato e diga onde.

## Skills relacionadas

- Memória cross-projeto (para achados que valem além deste repo): `memory-palace`
- Feature list e baseline: `ratchet-feature-list`
