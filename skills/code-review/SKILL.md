---
name: code-review
description: "Revisa as mudanças desde um ponto fixo (commit, branch, tag ou merge-base) em dois eixos: Standards (o código segue os padrões de código documentados deste repositório?) e Spec (o código corresponde ao que a issue/spec de origem pediu?). Roda as duas revisões em subagentes paralelos e reporta lado a lado. Use quando o usuário quiser revisar uma branch, uma PR, mudanças em andamento, ou pedir para \"revisar desde X\"."
---

# Code Review

> **Origem:** importada de [mattpocock/skills](https://github.com/mattpocock/skills) (`engineering/code-review`), adaptada ao vocabulário deste harness.

Revisão de dois eixos do diff entre `HEAD` e um ponto fixo que o usuário fornece:

- **Standards**: o código está em conformidade com os padrões de código documentados deste repositório?
- **Spec**: o código implementa fielmente a issue/spec de origem?

Os dois eixos rodam como **subagentes paralelos** para não poluir o contexto um do outro, depois esta skill agrega as descobertas.

## Processo

### 1. Fixe o ponto de referência

O que o usuário disse é o ponto fixo (um SHA de commit, nome de branch, tag, `main`, `HEAD~5`, etc.). Se não especificou, pergunte.

Capture o comando de diff uma vez: `git diff <ponto-fixo>...HEAD` (three-dot, então a comparação é contra o merge-base). Anote também a lista de commits via `git log <ponto-fixo>..HEAD --oneline`.

Antes de seguir, confirme que o ponto fixo resolve (`git rev-parse <ponto-fixo>`) e que o diff não está vazio. Uma ref inválida ou diff vazio deve falhar aqui, não dentro de dois subagentes paralelos.

### 2. Identifique a fonte da spec

Procure a spec de origem, nesta ordem:

1. Referências de issue nas mensagens de commit (`Closes #N`, marcador `Task: M0X-S0X-T0X`, ver `workflow-commits`/`workflow-issues`), buscando a issue correspondente via API do Forgejo. `workflow-issues` documenta as env vars (`FORGEJO_TOKEN`, `FORGEJO_URL`, `FORGEJO_ORG`) e o formato de consulta; um lookup típico:

   ```bash
   curl -s -H "Authorization: token $FORGEJO_TOKEN" \
     "$FORGEJO_URL/api/v1/repos/$FORGEJO_ORG/<repo>/issues/<numero>" \
     | jq '{number, title, body}'
   ```

2. Um caminho que o usuário passou como argumento.
3. Um arquivo de spec em `.gsd/` (ver `bootstrap`) que corresponda ao nome da branch ou à feature.
4. Se nada for encontrado, pergunte ao usuário onde está a spec. Se ele disser que não existe, o subagente **Spec** pula e reporta "sem spec disponível".

### 3. Identifique as fontes de standards

Qualquer coisa no repositório que documente como o código deve ser escrito, como `.gsd/CONVENTIONS.md`, `CODING_STANDARDS.md` ou `CONTRIBUTING.md`.

Além do que o repositório documenta, o eixo Standards sempre carrega o **baseline de smells** abaixo: um conjunto fixo de code smells de Fowler (_Refactoring_, cap. 3) que se aplica mesmo quando um repositório não documenta nada. Duas regras o regem:

- **O repositório tem precedência.** Um padrão documentado do repositório sempre vence; onde ele endossa algo que o baseline sinalizaria, suprima o smell.
- **Sempre um julgamento.** Cada smell é uma heurística rotulada ("possível Feature Envy"), nunca uma violação dura. Como qualquer padrão aqui, ignore o que já é imposto por tooling (linter, formatter).

Cada smell lê *o que é* → *como corrigir*; compare contra o diff:

- **Nome misterioso**: uma função, variável ou tipo cujo nome não revela o que faz ou contém. → renomeie; se nenhum nome honesto aparece, o design está obscuro.
- **Código duplicado**: a mesma forma de lógica aparece em mais de um hunk ou arquivo na mudança. → extraia a forma compartilhada, chame dos dois lugares.
- **Feature Envy**: um método que mexe mais nos dados de outro objeto do que nos próprios. → mova o método para os dados que ele cobiça.
- **Data Clumps**: os mesmos poucos campos ou parâmetros sempre viajam juntos (um tipo querendo nascer). → agrupe-os num tipo só, passe esse tipo.
- **Obsessão por primitivo**: um primitivo ou string no lugar de um conceito de domínio que merece seu próprio tipo. → dê ao conceito seu próprio tipo pequeno.
- **Switches repetidos**: o mesmo `switch`/cascata de `if` no mesmo tipo se repete ao longo da mudança. → substitua por polimorfismo, ou um mapa que os dois pontos compartilham.
- **Shotgun Surgery**: uma mudança lógica força edições espalhadas por muitos arquivos no diff. → reúna o que muda junto num módulo só.
- **Mudança divergente**: um arquivo ou módulo é editado por vários motivos não relacionados. → separe para que cada módulo mude por um motivo só.
- **Generalidade especulativa**: abstração, parâmetros ou hooks adicionados para necessidades que a spec não tem. → apague; volte a inline até uma necessidade real aparecer.
- **Message Chains**: navegação longa `a.b().c().d()` que o chamador não deveria depender. → esconda o percurso atrás de um método no primeiro objeto.
- **Middle Man**: uma classe ou função que majoritariamente só delega adiante. → corte, chame o alvo real direto.
- **Refused Bequest**: uma subclasse ou implementador que ignora ou sobrescreve a maior parte do que herda. → abandone a herança, use composição.

### 4. Dispare os dois subagentes em paralelo

**Prompt do subagente Standards** deve incluir:

- O comando de diff completo e a lista de commits.
- A lista de arquivos-fonte de standards encontrados no passo 3, **mais o baseline de smells do passo 3** colado por completo (o subagente não tem outro acesso a ele).
- O briefing: "Reporte, por arquivo/hunk onde relevante, (a) todo lugar em que o diff viola um padrão documentado: cite o padrão (arquivo + a regra); e (b) qualquer smell do baseline que você notar: nomeie e cite o hunk. Distinga violações duras de julgamentos: quebras de padrão documentado podem ser duras, mas smells do baseline são sempre julgamento, e um padrão documentado do repositório tem precedência sobre o baseline. Ignore o que já é imposto por tooling. Menos de 400 palavras."

**Prompt do subagente Spec** deve incluir:

- O comando de diff e a lista de commits.
- O caminho ou conteúdo buscado da spec.
- O briefing: "Reporte: (a) requisitos que a spec pediu e que estão faltando ou parciais; (b) comportamento no diff que não foi pedido (scope creep); (c) requisitos que parecem implementados mas cuja implementação parece errada. Cite a linha da spec para cada achado. Menos de 400 palavras."

Se a spec estiver faltando, pule o subagente Spec e anote isso no relatório final.

### 5. Agregue

Apresente os dois relatórios sob os títulos `## Standards` e `## Spec`, literalmente ou levemente limpos. **Não** combine nem reordene os achados juntos, porque os dois eixos são deliberadamente separados (ver _Por que dois eixos_).

Termine com um resumo de uma linha: total de achados por eixo, e o pior problema _dentro de cada eixo_ (se houver). Não escolha um vencedor único entre os eixos: essa é exatamente a reordenação que a separação existe para evitar.

## Por que dois eixos

Uma mudança pode passar num eixo e falhar no outro:

- Código que segue todo padrão mas implementa a coisa errada → **Standards passa, Spec falha.**
- Código que faz exatamente o que a issue pediu mas quebra as convenções do projeto → **Spec passa, Standards falha.**

Reportar separadamente evita que um eixo mascare o outro.

## Skills relacionadas

- Origem da spec via marcador de commit e issue: `workflow-commits`, `workflow-issues`
- Abertura de PR e `Closes #N`: `workflow-prs`
- Loop TDD que antecede esta revisão: `tdd`
- Vocabulário de módulo/interface usado nos smells de design: `codebase-design`
