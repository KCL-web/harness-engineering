---
name: scaffold-exercises
description: Cria estruturas de diretório de exercícios com sections, problems, solutions e explainers que passam no lint. Invoque quando o dev quiser criar esqueletos de exercícios ou configurar uma nova section de curso. Importada de mattpocock/skills.
---

# Scaffold de Exercícios

> **Origem:** importada de [mattpocock/skills](https://github.com/mattpocock/skills) (`misc/scaffold-exercises`), adaptada ao vocabulário deste harness.

Cria estruturas de diretório de exercícios que passam em `pnpm ai-hero-cli internal lint`, depois faz commit com `git commit`.

Esta skill é específica de repositórios de curso no formato `ai-hero-cli` (a ferramenta interna da mattpocock para material didático). Se este projeto não usa essa convenção de `exercises/`, ela não se aplica.

## Nomenclatura de diretórios

- **Sections**: `XX-nome-da-section/` dentro de `exercises/` (ex.: `01-retrieval-skill-building`)
- **Exercises**: `XX.YY-nome-do-exercicio/` dentro de uma section (ex.: `01.03-retrieval-with-bm25`)
- Número da section = `XX`, número do exercício = `XX.YY`
- Nomes em dash-case (minúsculo, hífens)

## Variantes de exercício

Cada exercício precisa de pelo menos uma dessas subpastas:

- `problem/` — workspace do estudante com TODOs
- `solution/` — implementação de referência
- `explainer/` — material conceitual, sem TODOs

Ao criar o esqueleto, use `explainer/` como padrão a menos que o plano especifique outra coisa.

## Arquivos obrigatórios

Cada subpasta (`problem/`, `solution/`, `explainer/`) precisa de um `readme.md` que:

- **Não esteja vazio** (precisa ter conteúdo real, mesmo que só uma linha de título)
- Não tenha links quebrados

Ao criar o esqueleto, crie um readme mínimo com título e descrição:

```md
# Título do Exercício

Descrição aqui
```

Se a subpasta tiver código, também precisa de um `main.ts` (mais de 1 linha). Mas para esqueletos, um exercício só com readme está ok.

## Workflow

1. **Parsear o plano** — extraia nomes de section, nomes de exercício e tipos de variante
2. **Criar diretórios** — `mkdir -p` para cada caminho
3. **Criar readmes de esqueleto** — um `readme.md` por pasta de variante com um título
4. **Rodar lint** — `pnpm ai-hero-cli internal lint` para validar
5. **Corrigir erros** — iterar até o lint passar

## Resumo das regras de lint

O linter (`pnpm ai-hero-cli internal lint`) verifica:

- Cada exercício tem subpastas (`problem/`, `solution/`, `explainer/`)
- Existe pelo menos um `problem/`, `explainer/` ou `explainer.1/`
- `readme.md` existe e não está vazio na subpasta principal
- Não há arquivos `.gitkeep`
- Não há arquivos `speaker-notes.md`
- Não há links quebrados nos readmes
- Não há comandos `pnpm run exercise` nos readmes
- `main.ts` é obrigatório por subpasta, a menos que seja readme-only

## Movendo/renomeando exercícios

Ao renumerar ou mover exercícios:

1. Use `git mv` (não `mv`) para renomear diretórios — preserva o histórico do git
2. Atualize o prefixo numérico para manter a ordem
3. Rode o lint de novo depois de mover

Exemplo:

```bash
git mv exercises/01-retrieval/01.03-embeddings exercises/01-retrieval/01.04-embeddings
```

## Exemplo: criando esqueleto a partir de um plano

Dado um plano como:

```
Section 05: Memory Skill Building
- 05.01 Introduction to Memory
- 05.02 Short-term Memory (explainer + problem + solution)
- 05.03 Long-term Memory
```

Crie:

```bash
mkdir -p exercises/05-memory-skill-building/05.01-introduction-to-memory/explainer
mkdir -p exercises/05-memory-skill-building/05.02-short-term-memory/{explainer,problem,solution}
mkdir -p exercises/05-memory-skill-building/05.03-long-term-memory/explainer
```

Depois crie os readmes de esqueleto:

```
exercises/05-memory-skill-building/05.01-introduction-to-memory/explainer/readme.md -> "# Introduction to Memory"
exercises/05-memory-skill-building/05.02-short-term-memory/explainer/readme.md -> "# Short-term Memory"
exercises/05-memory-skill-building/05.02-short-term-memory/problem/readme.md -> "# Short-term Memory"
exercises/05-memory-skill-building/05.02-short-term-memory/solution/readme.md -> "# Short-term Memory"
exercises/05-memory-skill-building/05.03-long-term-memory/explainer/readme.md -> "# Long-term Memory"
```

## Skills relacionadas

- Convenção de mensagem de commit ao commitar o esqueleto: `workflow-commits`
