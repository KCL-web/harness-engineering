---
name: setup-imported-skills
description: "Configura o pouco que as skills importadas de mattpocock/skills ainda precisam decidir por projeto: mapeamento dos labels de triage e o layout dos docs de domínio (CONTEXT.md/ADR). Rode uma vez por projeto antes de usar `triage`, `domain-modeling` ou `grill-with-docs`. Tracker de issues já é fixo (Forgejo) — não pergunte sobre isso."
disable-model-invocation: true
---

# Setup das skills importadas

> **Origem:** adaptação de [mattpocock/skills](https://github.com/mattpocock/skills) (`engineering/setup-matt-pocock-skills`) para este harness. A skill original pergunta qual issue tracker usar (GitHub/GitLab/local/outro) e escreve um bloco `## Agent skills` em `CLAUDE.md`/`AGENTS.md` sozinha. Aqui isso não se aplica: o tracker já é decidido (Forgejo, ver `workflow-issues`) e o AGENTS.md deste harness **não é editado pelo agente fora do bootstrap inicial** (regra universal do projeto) — então esta skill só monta um rascunho e mostra para o dev colar manualmente, nunca escreve sozinha.

Duas decisões por projeto ainda ficam abertas depois que `workflow-issues`/`workflow-branching`/`workflow-prs`/`workflow-commits` já resolveram tudo sobre onde as issues vivem:

1. **Vocabulário de labels de triage** (usado pela skill `triage`) — mapear os 5 papéis canônicos para labels reais do Forgejo.
2. **Layout dos docs de domínio** (`CONTEXT.md`/ADRs, usados por `domain-modeling`, `grill-with-docs`, `tdd`, `codebase-design`) — single-context vs. multi-context.

Isso é uma skill guiada por prompt, não um script determinístico. Explore, apresente o que encontrou, confirme com o dev, e **mostre o rascunho para ele colar** — nunca escreva direto em `AGENTS.md`/`CLAUDE.md`.

## Processo

### 1. Explorar

- A skill `triage` está instalada? (pasta `triage` em `skills/`, ou disponível na lista de skills.) Isso decide se a Seção A roda.
- Sinais de monorepo: `pnpm-workspace.yaml`, campo `workspaces` no `package.json`, ou `packages/*` populados com `src/` próprio. Ausência = single-context (a maioria dos projetos deste harness).
- Já existe `CONTEXT.md`, `CONTEXT-MAP.md` ou `docs/adr/` na raiz? Se sim, a decisão já foi tomada antes — não repita a pergunta, só confirme o que está lá.

### 2. Seção A — Labels de triage (só se `triage` estiver instalada)

Pergunta única:

> Quer manter os labels padrão de triage? (recomendado: **sim**)

Padrão: os 5 papéis canônicos, cada um como um label do Forgejo com o mesmo nome — `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`. Eles entram no mesmo mecanismo de labels que `workflow-issues` já usa para tipo/sprint/priority (ver seção "Passo 2 — Labels" lá). Em **sim**, registre como estão. Só se o dev disser não — normalmente porque o Forgejo do projeto já usa outros nomes — colete os overrides.

Registre o mapeamento em [triage-labels.md](triage-labels.md).

### 3. Seção B — Docs de domínio

Padrão: **single-context** (um `CONTEXT.md` + `docs/adr/` na raiz). Serve para quase todo projeto deste harness — escreva sem perguntar.

Ofereça **multi-context** (`CONTEXT-MAP.md` na raiz apontando para um `CONTEXT.md` por contexto) só quando a exploração achou sinais de monorepo. Confirme o layout escolhido.

Detalhes de estrutura de arquivo e regras de consumo (glossário, conflito com ADR) estão em [domain.md](domain.md).

### 4. Confirmar e mostrar

Monte um rascunho com:

- O mapeamento final de `triage-labels.md` (se a Seção A rodou)
- O layout escolhido de `domain.md`

**Mostre o rascunho ao dev para ele colar manualmente** onde fizer sentido no projeto (ex.: como nota em `.gsd/STACK.md` ou `.gsd/CONVENTIONS.md`). Não escreva em `AGENTS.md`/`CLAUDE.md` por conta própria — isso está fora do escopo de escrita autorizado para o agente fora do bootstrap inicial.

### 5. Concluído

Diga ao dev que a configuração está pronta e quais skills importadas agora têm o que precisam (`triage`, `domain-modeling`, `grill-with-docs`, `tdd`, `codebase-design`). Rodar esta skill de novo só é necessário se o dev quiser trocar o mapeamento de labels ou o layout de domínio.

## Sobre o issue tracker

As skills importadas de mattpocock/skills assumem um "issue tracker" plugável e perguntam qual usar. Neste harness isso **já está decidido**: Forgejo, sem project board, com milestones/labels/issues documentados em `workflow-issues` (e branch/PR/commit em `workflow-branching`/`workflow-prs`/`workflow-commits`). Sempre que uma skill importada mencionar "publicar no tracker" ou "buscar o ticket", isso significa usar a API do Forgejo como documentado em `workflow-issues`.

## Skills relacionadas

- Mecânica de issues/milestones/sprints no Forgejo: `workflow-issues`
- Branch e PR: `workflow-branching`, `workflow-prs`
- Vocabulário de domínio e ADRs: `domain-modeling`
- Interrogatório que produz `CONTEXT.md`/ADR: `grill-with-docs`
- Estado da fila de issues: `triage`
