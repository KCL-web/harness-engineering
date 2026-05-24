# Bootstrap do harness em um projeto

Você está fazendo o bootstrap da documentação `.gsd/` de um projeto. Seu trabalho é preencher arquivos específicos do projeto a partir de uma entrevista com o desenvolvedor, **escrevendo os arquivos diretamente** com Write/Edit conforme as respostas chegam.

Pré-requisito: as skills do harness já estão carregadas (junction `~/.claude/skills/harness/` ativa). Comece consultando `harness-index` se tiver dúvida de roteamento.

## Regras desta sessão

- Você TEM permissão de Write/Edit nos arquivos `.gsd/*.md` (exceção autorizada ao "não escrevo sozinho").
- Você TEM permissão de chamar `gh` no PASSO FINAL (sincronia ROADMAP → GitHub). Para o procedimento, siga `workflow-project-board` e `workflow-issues`.
- Você NÃO TEM permissão de `git commit`/`git push`, nem de mexer em `AGENTS.md`/`scripts/`/`.harness/` fora dos arquivos `.harness/feature_list.json` e `.harness/baseline.json` (que você inicializa a partir de `templates/`).
- Em projeto existente, analise o código ANTES de perguntar — pré-preencha o que conseguir inferir.
- Para o que não conseguir inferir, escreva com marcadores explícitos:
  - `> [inferido]` antes de campos que você deduziu do código
  - `> [TBD: <pergunta específica e curta>]` antes de campos que precisam de input do dev
- Pergunte as lacunas EM LOTE, agrupadas por arquivo — não uma a uma.
- Pushback em resposta vaga ("uma ferramenta pra rastrear coisas"): peça especificidade.
- Documentação em **pt-BR**. Identificadores técnicos (`feat`, `fix`, slugs de branch/skill) em **inglês**.

## PERGUNTA ZERO-A — modo de workspace

Pergunte:

> "Qual é o modo deste diretório?
> 1) single-repo — um repo Git, projeto standalone
> 2) umbrella    — workspace raiz contendo múltiplos repos Git como subpastas
> 3) sub-repo    — um dos repos Git dentro de um workspace umbrella"

Arquivos a preencher por modo:

- **single-repo** → `.gsd/SPEC.md`, `.gsd/STACK.md`, `.gsd/ROADMAP.md`, `.harness/feature_list.json`, `.harness/baseline.json`
- **umbrella** → `PRODUCT.md`, `INTEGRATION.md` (sem .gsd/ no nível umbrella)
- **sub-repo** → mesmos arquivos do single-repo, mas LEIA `../PRODUCT.md` e `../INTEGRATION.md` primeiro. O SPEC deste repo é uma fatia do produto.

> **Nota v2:** `.gsd/CONVENTIONS.md` não existe mais. Convenções de código vêm da skill `stack-<archetype>` (`stack-react-vite-scss`, `stack-django-drf-jwt`). A entrevista identifica qual archetype combina com o projeto e registra o nome em STACK.md — Claude carrega a skill correspondente.

## PERGUNTA ZERO-B — estado do código

> "Este é um projeto NOVO (sem código ainda) ou EXISTENTE (código já existe, total ou parcialmente)?"

Se EXISTENTE → rode a FASE 0 antes. Caso contrário, pule para as fases de entrevista.

## FASE 0 — Análise (só para projetos existentes)

Para single/sub-repo: analise o diretório atual.
Para umbrella: analise brevemente cada sub-repo.

Examine nesta ordem:
a) Manifestos (`package.json`, `Cargo.toml`, `go.mod`, `pyproject.toml`, `requirements.txt`)
b) Estrutura de pastas
c) `README.md` e qualquer `docs/`
d) Histórico recente de commits (últimos 30–50)
e) Issues e PRs abertas se acessíveis
f) Arquivos de entrada (`page`, `route`, `index`, `main`)

Depois da análise, mostre um SUMÁRIO CURTO (5–10 linhas) e espere confirmação:
- single/sub-repo: stack identificada, propósito aparente, maturidade, o que está obscuro
- umbrella: uma linha por sub-repo + padrões de integração

## ENTREVISTA — modo single-repo

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

## ENTREVISTA — modo umbrella

Mesma estrutura, mas para `PRODUCT.md` e `INTEGRATION.md`. Cobertura: produto cruzando repos, problema/solução no nível produto, lista de repos com uma linha cada, integração (contratos, donos, consumidores, sincronia de tipos, auth, env vars compartilhadas, ordem de deploy).

NÃO gere SPEC/STACK/ROADMAP por sub-repo aqui — esses são preenchidos depois rodando este bootstrap em cada sub-repo.

## ENTREVISTA — modo sub-repo

LEIA `../PRODUCT.md` e `../INTEGRATION.md` primeiro. Se não existirem, pare e peça pra rodar bootstrap umbrella primeiro.

Então rode a entrevista single-repo com ajustes:

- SPEC.md começa com: "Este repo entrega <fatia X> do produto definido em `../PRODUCT.md`."
- Capacidades e "fora de escopo" são DESTE repo, não do produto inteiro.
- Cite `../INTEGRATION.md` quando contratos com repos irmãos aparecerem.

## SINCRONIA FINAL — single-repo e sub-repo

Depois que `.gsd/ROADMAP.md` está confirmado, crie no GitHub:

1. **GitHub Project** — siga `workflow-project-board` (6 colunas, 3 campos).
2. **Milestones** — uma por marco do ROADMAP.
3. **Issues** — uma por task, no Backlog, linkada à milestone, com marcador `Task: <MID>-<SID>-<TID>` na primeira linha do body (para sincronias futuras não duplicarem).

Pré-checagem: `gh auth status` e `gh project list` devem responder. Se faltar scope: `gh auth refresh -s project,read:project`.

Antes de criar QUALQUER coisa, mostre o resumo (N milestones, M issues) e espere "ok" explícito. Depois rode tudo e mostre o resultado (Project URL, milestones criadas, issues criadas com números).

Em modo **umbrella**, NÃO crie issues por task — cada sub-repo cuida do seu próprio ROADMAP.

## Skills úteis durante o bootstrap

- `harness-index` — quando ficar em dúvida de qual skill consultar
- `workflow-project-board` — criar/configurar o GitHub Project
- `workflow-issues` — template de issue, marcador Task
- `ratchet-feature-list` — schema e regras de `.harness/*.json`
- `memory-palace` — pra propor uma drawer registrando decisões fundadoras desta sessão (problema, vision, escolhas de stack)

Comece pela PERGUNTA ZERO-A.
