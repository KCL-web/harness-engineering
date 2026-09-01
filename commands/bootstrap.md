---
description: Bootstrap da documentação .gsd/ de um projeto (SPEC, STACK, ROADMAP, feature_list, baseline)
---

# Bootstrap do harness em um projeto

Você está fazendo o bootstrap da documentação `.gsd/` de um projeto. Seu trabalho é preencher arquivos específicos do projeto a partir de uma entrevista com o desenvolvedor, **escrevendo os arquivos diretamente** com Write/Edit conforme as respostas chegam.

Pré-requisito: as skills do harness já estão carregadas (junction `~/.claude/skills/harness/` ativa). Comece consultando `harness-index` se tiver dúvida de roteamento.

## Regras desta sessão

- Você TEM permissão de Write/Edit nos arquivos `.gsd/*.md` (exceção autorizada ao "não escrevo sozinho").
- Você TEM permissão de chamar `curl` contra a API do Forgejo no PASSO FINAL (sincronia ROADMAP → Forgejo). Para o procedimento, siga `workflow-issues`. (GitHub é só espelho de backup — nunca opere nele.)
- Você TEM permissão de **criar** `CLAUDE.md` e `AGENTS.md` **somente se ainda não existirem** no projeto. Se já existirem, não toque neles. Criação acontece no Passo A, após os arquivos `.gsd/`.
- Você NÃO TEM permissão de `git commit`/`git push`, nem de editar `AGENTS.md` já existente, nem de mexer em `scripts/`/`.harness/` fora dos arquivos `.harness/feature_list.json` e `.harness/baseline.json` (que você inicializa a partir de `templates/`).
- Em projeto existente, analise o código ANTES de perguntar — pré-preencha o que conseguir inferir.
- Para o que não conseguir inferir, escreva com marcadores explícitos:
  - `> [inferido]` antes de campos que você deduziu do código
  - `> [TBD: <pergunta específica e curta>]` antes de campos que precisam de input do dev
- Pergunte as lacunas EM LOTE, agrupadas por arquivo — não uma a uma.
- Pushback em resposta vaga ("uma ferramenta pra rastrear coisas"): peça especificidade.
- Documentação em **pt-BR**. Identificadores técnicos (`feat`, `fix`, slugs de branch/skill) em **inglês**.

## PERGUNTA ZERO — estado do código

> "Este é um projeto NOVO (sem código ainda) ou EXISTENTE (código já existe, total ou parcialmente)?"

Se EXISTENTE → rode a FASE 0 antes. Caso contrário, pule para a entrevista.

> **Modo padrão é single-repo.** Se este projeto é parte de um workspace umbrella (múltiplos repos compartilhando um produto, com `PRODUCT.md`/`INTEGRATION.md` versionados na raiz), pule para a seção **"Modo avançado: umbrella e sub-repo"** no fim deste prompt. Casos de uso solo quase sempre são single-repo.

## FASE 0 — Análise (só para projetos existentes)

Analise o diretório atual nesta ordem:

a) Manifestos (`package.json`, `Cargo.toml`, `go.mod`, `pyproject.toml`, `requirements.txt`)
b) Estrutura de pastas
c) `README.md` e qualquer `docs/`
d) Histórico recente de commits (últimos 30–50)
e) Issues e PRs abertas se acessíveis
f) Arquivos de entrada (`page`, `route`, `index`, `main`)

Depois da análise, mostre um SUMÁRIO CURTO (5–10 linhas) com stack identificada, propósito aparente, maturidade, o que está obscuro. Espere confirmação.

Em seguida, **ofereça rodar a skill `security-audit`** antes de continuar a entrevista — em projeto existente, vale surfacear falhas de segurança logo no início em vez de descobri-las só na validação final. É uma auditoria pesada (gera PDF e pode levar bastante tempo): pergunte ao dev se quer rodar agora ou pular para depois. Se ele topar, invoque `security-audit` e só volte para a entrevista quando ela terminar.

## Entrevista (single-repo)

**Fluxo: rascunho primeiro, perguntas depois.**

### Passo A — Rascunho

Copie os skeletons de `templates/` para `.gsd/` (e `.harness/` para os JSONs):

```
templates/SPEC.md             → .gsd/SPEC.md
templates/STACK.md            → .gsd/STACK.md
templates/ROADMAP.md          → .gsd/ROADMAP.md
templates/feature_list.json   → .harness/feature_list.json
templates/baseline.json       → .harness/baseline.json
```

Em projeto EXISTENTE, preencha tudo o que conseguir inferir e marque com `> [inferido]`.
Em projeto NOVO, deixe seções com `> [TBD: <pergunta curta>]`.

**Se `CLAUDE.md` e/ou `AGENTS.md` não existirem no projeto**, crie-os agora:

- `CLAUDE.md` → sempre `@AGENTS.md` (uma linha, sem mais nada).
- `AGENTS.md` → use o template abaixo, adaptando a seção **Stack deste projeto** e a tabela de **subagentes** para a linguagem/framework detectados na FASE 0:

```markdown
# AGENTS.md — <nome-do-projeto>

Este projeto usa **Claude Code Skills** como mecanismo principal de contexto.
As regras de workflow, branching, PRs, commits, issues/milestones, feature list e ratchet
vivem em skills sob `~/.claude/skills/harness/`.

**Ponto de entrada:** invoque `harness-index` no início da sessão.

---

## Regras universais (fora de skill)

1. **Idioma.** Conteúdo em **pt-BR**. Identificadores técnicos em **inglês**.
2. **Não escreve sozinho fora do escopo permitido.** Atualização de progresso é mostrada ao dev para colar manual. Exceções: bootstrap inicial e comandos pedidos explicitamente.
3. **Validação do projeto passa antes de cada commit.** Comando: `<comando de validação>`. Tarefa sem validação verde não é tarefa pronta.
4. **`main` é protegida** — nunca pushe direto. Fluxo: `feat/*` → `develop` → `main`.
5. **Search antes de decidir.** Antes de propor decisão arquitetural, consulte MemPalace. Wing: `<nome-do-projeto>`.

---

## Stack deste projeto

<uma linha descrevendo linguagem + framework + banco + deploy>
Detalhes completos em `.gsd/STACK.md`.

---

## Mecanismos do harness

- **Skills** (`~/.claude/skills/`) — `harness-index` lista todas.
- **MemPalace** (MCP) — memória cross-projeto. Wing: `<nome-do-projeto>`.
- **OpenSpace** (MCP) — skills auto-evolutivas.
- **RTK** (CLI, hook) — comprime saída de shell. Transparente.

---

## Delegação para subagentes especializados

| Tipo de tarefa | Subagente |
|---|---|
| <adaptar à stack detectada> | <subagent-type> |

**Quando NÃO delegar:** tarefas de uma linha, lookups, workflow (branch/commit/PR/issue).

---

## Documentação específica do projeto

@.gsd/STACK.md
```

### Passo B — Resumo ao dev

Uma frase por arquivo descrevendo o estado (quantos campos inferidos, quantos TBDs).

### Passo C — Entrevista em lote por arquivo

Para cada arquivo, pergunte os TBDs em UM ÚNICO bloco. Depois edite o arquivo substituindo TBDs pelas respostas.

**Cobertura mínima:**

- **SPEC.md** — Visão (1 frase), Problema (quem sofre/situação/custo), Solução (3–5 capacidades), Usuários (papéis explícitos), ≥3 itens fora de escopo, ≥3 critérios observáveis, Restrições não-óbvias.
- **STACK.md** — Stack identificada, archetype skill correspondente (ou "nenhum ainda"), comando de validação único, comandos de setup, env vars, notas específicas.
- **ROADMAP.md** — M01 (menor versão demonstrável), sprints do M01 (2–4, cada um demonstrável), tarefas (cada uma cabe em uma sessão). M02 e M03 se aplicável. Pare em 3 milestones.
- **feature_list.json** — IDs F001+, `title`/`criteria[]` observáveis (regra detalhada em skill `ratchet-feature-list`).
- **baseline.json** — `updated_at` para hoje, valores reais de métricas atuais (rode o validador do projeto pra ter os números).

### Passo D — Verificação final

Liste os TBDs remanescentes (`grep -n "TBD:" .gsd/*.md`). Pergunte se quer responder agora ou revisitar depois.

## Sincronia final — single-repo

Depois que `.gsd/ROADMAP.md` está confirmado, crie no GitHub:

1. **GitHub Project** — siga `workflow-project-board` (6 colunas, 3 campos).
2. **Milestones** — uma por marco do ROADMAP.
3. **Issues** — uma por task, no Backlog, linkada à milestone, com marcador `Task: <MID>-<SID>-<TID>` na primeira linha do body (para sincronias futuras não duplicarem).

Pré-checagem: `gh auth status` e `gh project list` devem responder. Se faltar scope: `gh auth refresh -s project,read:project`.

Antes de criar QUALQUER coisa, mostre o resumo (N milestones, M issues) e espere "ok" explícito. Depois rode tudo e mostre o resultado (Project URL, milestones criadas, issues criadas com números).

## Skills úteis durante o bootstrap

- `harness-index` — quando ficar em dúvida de qual skill consultar
- `workflow-project-board` — criar/configurar o GitHub Project
- `workflow-issues` — template de issue, marcador Task
- `ratchet-feature-list` — schema e regras de `.harness/*.json`
- `memory-palace` — pra propor uma drawer registrando decisões fundadoras desta sessão (problema, vision, escolhas de stack)

Comece pela PERGUNTA ZERO.

---

## Modo avançado: umbrella e sub-repo

> **Quando usar.** Time (não solo) que compartilha um produto entre vários repos Git independentes (ex.: `backend/` + `frontend/` + `mobile/`) e precisa de uma fonte única de verdade versionada para visão de produto e contratos de integração. Para uso solo, **MemPalace cobre o papel** dos arquivos `PRODUCT.md`/`INTEGRATION.md` com busca semântica — basta usar wings por projeto.

Antes de seguir abaixo, confirme: "Este projeto realmente compartilha um produto com outros repos Git independentes, e múltiplas pessoas precisam ver o mesmo PRODUCT.md/INTEGRATION.md versionados? Ou MemPalace resolveria?"

Se MemPalace resolve, volte ao fluxo single-repo. Caso contrário, siga.

### Modo umbrella

Workspace raiz contendo múltiplos repos Git como subpastas. Você preenche dois arquivos no raiz:

- **PRODUCT.md** — Produto cruzando repos (1 frase), público-alvo, problema, 3–5 capacidades do produto inteiro, fora de escopo no nível produto, critérios de sucesso, lista de repos (uma linha cada descrevendo o que entregam), restrições cross-repo.
- **INTEGRATION.md** — Para cada par de repos que se falam: dono do contrato, consumidores, sincronia (manual / OpenAPI codegen / pacote compartilhado); tipos/schemas compartilhados; fluxo de auth (emissor, formato, rotação); env vars cross-repo; ordem de deploy.

NÃO gere SPEC/STACK/ROADMAP por sub-repo no umbrella — isso roda dentro de cada sub-repo separadamente.

### Modo sub-repo

Repo Git que vive dentro de um workspace umbrella. LEIA `../PRODUCT.md` e `../INTEGRATION.md` primeiro. Se não existirem, pare e peça pra rodar bootstrap umbrella primeiro.

Então rode a entrevista single-repo com ajustes:

- SPEC.md começa com: "Este repo entrega <fatia X> do produto definido em `../PRODUCT.md`."
- Capacidades e "fora de escopo" são DESTE repo, não do produto inteiro.
- Cite `../INTEGRATION.md` quando contratos com repos irmãos aparecerem.

### Sincronia final em umbrella

Em modo umbrella **NÃO crie issues por task** — cada sub-repo cuida do seu próprio ROADMAP. No nível umbrella, só crie o Project compartilhado (se for ter um único board cross-repo) e nada mais.
