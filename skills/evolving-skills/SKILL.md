---
name: evolving-skills
description: Como o harness usa OpenSpace (MCP de skills auto-evolutivas — FIX/DERIVED/CAPTURED). Define onde skills curadas vs evoluídas ficam, como distingui-las, quando confiar numa CAPTURED e como promover uma CAPTURED bem-sucedida para o conjunto curado. Invoque ao adotar/criticar uma skill evoluída, ao ver uma CAPTURED nova, ou ao decidir promover.
---

# Skills evolutivas (OpenSpace)

O **OpenSpace** é um MCP que adiciona auto-evolução ao conjunto de skills do agente. Plugado, ele observa execução real, detecta padrões e propõe (ou aplica) três tipos de evolução.

> Curated stays in this repo. Evolved stays out. Promotion is manual and explicit.

## Os três modos

| Modo | O que faz | Quando dispara |
| --- | --- | --- |
| **FIX** | Repara uma skill que está falhando (output errado, tool quebrada) | Quando uma skill curada para de funcionar — ex.: comando `gh` mudou de assinatura, regex parou de bater |
| **DERIVED** | Cria nova versão de uma skill existente que se mostrou consistentemente melhor | Quando um padrão de uso recorrente bate a skill original em sucesso/tokens |
| **CAPTURED** | Cria skill nova a partir de fluxo bem-sucedido observado várias vezes | Quando um workflow ad-hoc se repete e dá certo — vira skill reutilizável |

## Layout no harness

Dois diretórios — separação dura entre **curated** (revisado, versionado) e **evolved** (auto-gerado, untracked):

```
<repo>/skills/                              ← CURATED (este repo)
   └── workflow-*, stack-*, memory-palace,
       evolving-skills, ...                 ← versionado, revisado em PR

~/.claude/skills/harness/                   ← symlink → <repo>/skills/

~/.claude/skills/captured/                  ← EVOLVED (untracked, local)
   └── <slug-gerado-pelo-OpenSpace>/        ← FIX/DERIVED/CAPTURED moram aqui
       └── SKILL.md
```

Claude Code carrega ambos diretórios automaticamente (`~/.claude/skills/` é escaneado inteiro). O agente vê curated + evolved sem distinção visual no autoload — distinção vem do **caminho**.

### Por que dois diretórios

- **Sem poluir o repo**: CAPTURED é experimental por definição. Não deve aparecer em `git status` nem entrar em PR sem revisão.
- **Promoção é deliberada**: copiar de `captured/` para `<repo>/skills/` é um ato consciente, não default.
- **Rollback é trivial**: apagar `~/.claude/skills/captured/<slug>/` reverte sem afetar curado.

## Como distinguir curated vs evolved

Pelo caminho. Se o `SKILL.md` que o agente carregou está em:

- `<repo>/skills/<nome>/SKILL.md` → **curated**: tem revisão humana, foi pensado, segue convenção do harness.
- `~/.claude/skills/captured/<slug>/SKILL.md` → **evolved**: auto-gerado, ainda não validado pelo dev.

OpenSpace também grava metadados (`evolution_processed_at`, lineage, success rate) — quando você ler uma skill evolved, busque esses sinais antes de seguir o que ela diz.

## Quando confiar numa skill evolved

Não confie automaticamente. Aplique este filtro:

1. **Origem**: a skill veio de quantas execuções? OpenSpace expõe `evolution_processed_at` e contadores. Se for ≤ 2 ocorrências, trate como hipótese.
2. **Escopo**: a skill é específica do seu projeto? Se for stack-genérica (`stack-*`), só promova se a regra realmente generaliza.
3. **Conflito**: a skill evolved contradiz uma curated? **Curated ganha por default.** Se a evolved está certa e a curated está errada, isso vira issue para o dev decidir.
4. **Side effects**: a skill propõe executar comando destrutivo ou alterar config global? Nunca rode sem confirmação do dev — mesmo se a tag for FIX.

## Cadência

```
sessão começa            → escaneia ~/.claude/skills/ inteiro (curated + evolved)
durante o trabalho       → OpenSpace observa Bash, tool calls, sucessos/falhas
                            e armazena candidatos a FIX/DERIVED/CAPTURED
fim da sessão / periódico → openspace decide se promove candidato a skill
                            real em ~/.claude/skills/captured/
revisão manual           → dev abre ~/.claude/skills/captured/, lê o que apareceu,
                            decide: descartar, manter local, ou promover para o repo
```

## Promovendo CAPTURED → curated

Quando uma skill em `~/.claude/skills/captured/` provou seu valor (você usou várias vezes, validou que o conteúdo está certo, e ela generaliza além de um caso isolado):

1. **Revise o `SKILL.md`** — reescreva no tom e formato das curated. Frontmatter do harness, descrição clara de quando invocar, exemplos, regras inegociáveis.
2. **Decida o nome curado** — não use o slug auto-gerado. Pense no namespace (`workflow-*`, `stack-*`, etc.).
3. **Copie** para `<repo>/skills/<nome-novo>/SKILL.md`.
4. **Registre** em `skills/harness-index/SKILL.md` na tabela "Skills específicas".
5. **PR para `develop`** com tipo `feat` (nova skill) ou `refactor` (substitui uma curada).
6. **Apague** a versão em `~/.claude/skills/captured/<slug>/` para evitar duplicata na próxima sessão.

## Regras inegociáveis

- **Curated nunca é sobrescrito por OpenSpace**: `OPENSPACE_HOST_SKILL_DIRS=~/.claude/skills/captured`, **não** `~/.claude/skills/harness`. Confirme em `~/.claude/mcp.json` antes de rodar.
- **Conflito curated × evolved**: curated ganha. Se a evolved está mais certa, vira issue, não merge silencioso.
- **CAPTURED não vai pra commit**: o repo guarda só curated. Evolved é local da máquina.
- **Sem ação destrutiva auto-aplicada**: mesmo um FIX precisa de validação humana se altera config, derruba serviço, ou apaga dado.
- **Promoção exige PR**: copiar de captured para o repo é uma decisão revisável, não atalho.

## Skills relacionadas

- Índice geral: `harness-index`
- Memória cross-projeto (decisões cabem aqui antes de virarem skill curada): `memory-palace`
- Convenção de PR para promover skill nova: `workflow-prs`, `workflow-commits`
