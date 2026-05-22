# Onboarding — Harness Engineering

> Você acabou de receber acesso a um projeto que usa o **harness engineering**. Esse documento te coloca produtivo em 5 minutos e mostra como o agente (Claude Code) trabalha junto com você.

---

## 5 minutos de pitch

O **harness** é um pacote pequeno de arquivos e regras que faz toda sessão de Claude Code **começar já sabendo**:

- Quais convenções respeitar (folder layout, tests, schemas, lint, auth, validation)
- Como criar branches, commits e PRs
- Quais comandos rodar pra validar antes de commitar
- O que o produto faz, pra quem, e o que está na fila do roadmap

**Por que isso importa:** sem o harness, toda sessão começa do zero. O agente inventa conventions, você corrige, e o projeto deriva. Com o harness, o agente lê as regras antes de escrever código, e você revisa **o trabalho** — não decisões já tomadas em outra sessão.

---

## Sua primeira sessão — passo a passo

### 1. Clone o repo

```bash
git clone <repo-url> <pasta>
cd <pasta>
```

### 2. Setup do ambiente

Cada projeto tem seu próprio README com as instruções específicas. Exemplos típicos:

- **Backend Django:** `docker compose up -d && docker compose exec web python manage.py migrate`
- **Frontend Next.js:** `npm install && npm run dev`
- **Outros stacks:** ver `.gsd/STACK.md` → seção *Setup from scratch*

### 3. Instale `jq` (obrigatório pro gate do harness)

| OS | Comando |
|---|---|
| WSL / Linux (Debian/Ubuntu) | `sudo apt install jq` |
| Mac (Homebrew) | `brew install jq` |
| Windows | `winget install jqlang.jq` |

### 4. Padronize o caminho do template

Em qualquer shell profile (`~/.bashrc`, `~/.zshrc`, etc.):

```bash
export HARNESS_TEMPLATE="$HOME/harness-engineering-template"
```

Clone o template uma vez:

```bash
git clone https://github.com/KCL-web/harness-engineering-template.git "$HARNESS_TEMPLATE"
```

Isso faz `scripts/harness-sync.sh` rodar sem argumentos quando você precisar atualizar regras universais.

### 5. Abra Claude Code no root do projeto

O `CLAUDE.md` no root carrega automaticamente:

- `@AGENTS.md` (regras universais)
- `@.gsd/STACK.md` (identificação técnica)
- `@.gsd/CONVENTIONS.md` (convenções deste stack)

**Não precisa de prompt de setup adicional.** O contexto já está lá.

### 6. Confirme o contexto antes de pedir código

Antes da primeira tarefa real, peça pro agente:

> "Resume o que você sabe sobre stack, convenções e milestones atuais deste repo."

Se o resumo bater, ele leu tudo. Se faltar algo importante, o `.gsd/*` provavelmente não está completo — pause e corrige antes de continuar.

---

## Os 5 arquivos que importam

| Arquivo | O que tem | Mexer quando |
|---|---|---|
| **`AGENTS.md`** | Regras universais — branch flow, commit format, project board, validation. **Igual em todo repo da empresa.** | Nunca direto. Vem do template via `scripts/harness-sync.sh`. |
| **`.gsd/STACK.md`** | Stack técnica deste repo, validation command, env vars, project notes. | Quando o stack muda (nova lib core, novo env var). |
| **`.gsd/CONVENTIONS.md`** | Convenções opinionadas deste stack — folder layout, tests, schemas, overrides do AGENTS.md. | Quando uma convenção do projeto evolui. |
| **`.gsd/SPEC.md`** | O que o produto faz, pra quem, restrições deste repo. | Quando a fatia do produto que esse repo entrega muda. |
| **`.gsd/ROADMAP.md`** | Milestones, sprints, tasks. Status `[ ]/[~]/[x]`. | Sempre que um sprint vira ou uma task completa. |

Em projetos com **mais de um repo** (umbrella → backend + frontend), o repo "owner" também hospeda:

- **`docs/PRODUCT.md`** — visão global do produto (compartilhada via URL do GitHub).
- **`docs/INTEGRATION.md`** — contratos cross-repo (API, auth, deploy order).

---

## Fluxo dia-a-dia

```
1. Pega uma issue do board → move pra "In Progress"
2. git checkout preview && git pull
3. git checkout -b <type>/<slug>  (ver convenção de branch abaixo)
4. Trabalha; a validation tem que passar antes de cada commit
5. git push -u origin <branch>
6. gh pr create --base preview --title "<type>(...): ..."
7. CI roda (validation.yml + harness-gate). Tudo verde = pronto pra review.
8. Merge → issue vira "Done"
```

### Validation command

Sempre documentada em `.gsd/STACK.md`. Tem que passar 100% **antes de qualquer commit**.

Exemplos típicos de stacks comuns:

- **Python/Django:** `ruff check . && ruff format --check . && pytest`
- **Node/Next.js:** `npx tsc --noEmit && npm run lint && npx prettier --check . && npm run build`
- **Go:** `go vet ./... && go test ./...`
- **Rust:** `cargo clippy -- -D warnings && cargo test`

O comando exato vive no `STACK.md` do seu projeto.

### Branch naming

**Padrão do `AGENTS.md`:** `<type>/<slug>` — sem número de issue. Uma branch/PR pode fechar várias issues relacionadas; cada uma vai como uma linha `Closes #N` separada no body do PR.
Exemplos: `feat/webhook-receiver`, `fix/missing-start-time`, `chore/vitest-setup`.

Alguns projetos podem **overridar** essa regra em `.gsd/CONVENTIONS.md`. **Antes de criar branch, confira `.gsd/CONVENTIONS.md` do projeto.**

Tipos válidos: `feat`, `fix`, `chore`, `refactor`, `test`, `docs`, `style`, `perf`.

### Commit messages

Conventional Commits, em **inglês**, lowercase, imperativo, max 72 chars na primeira linha.

Bom: `feat(webhook): add github signature verification`
Ruim: `fix stuff`, `Adicionado novo componente`, `WIP`

---

## Quando tem dúvida, onde olhar

| Dúvida | Olhe em |
|---|---|
| "Posso usar X biblioteca?" | `.gsd/CONVENTIONS.md` |
| "Como funciona o auth aqui?" | `.gsd/STACK.md` + `docs/INTEGRATION.md` (se multi-repo) |
| "Qual a próxima feature?" | `.gsd/ROADMAP.md` + GitHub Project board |
| "Por que esse padrão estranho?" | `.gsd/CONVENTIONS.md` (constraint sections) ou `docs/PRODUCT.md` |
| "Como começo um projeto novo do zero?" | `$HARNESS_TEMPLATE/scripts/harness-init.sh` na pasta nova |
| "O Claude sugeriu algo que parece estranho" | Confronta com `.gsd/CONVENTIONS.md` — se contraria, pergunta antes de aceitar |

---

## Atualizando o harness no projeto

Quando uma regra **universal** mudar no template `harness-engineering-template`:

```bash
cd <projeto>
./scripts/harness-sync.sh
```

Copia só os arquivos universais (`AGENTS.md`, `CLAUDE.md`, `ONBOARDING.md`, scripts, workflows, `.gsd/BOOTSTRAP.md`, etc.). **Nunca toca em STACK/CONVENTIONS/SPEC/ROADMAP/docs** desse projeto — esses são únicos por repo.

---

## Princípios que vale entender

- **Universal vs project-specific.** Mantém a linha limpa: se uma regra vale pra todo projeto, vai no AGENTS.md (template). Se vale só pra um repo, vai no CONVENTIONS.md desse repo.
- **TBD é aceito.** Melhor marcar algo como TBD do que inventar resposta errada na entrevista de bootstrap.
- **Friction é o ponto.** Se as perguntas do bootstrap parecem chatas, é porque o harness está fazendo o trabalho. Specs que passam sem resistência geralmente estão erradas.
- **PR atômico.** Uma PR fecha quantas issues precisar, mas mantém um único tema. Refactor + feature + format na mesma PR vira pesadelo de review.
- **Validation manda.** Se a validation falha local, não pusha. Se passa local mas falha CI, é problema de ambiente — não bypasse.

---

## FAQ

**"O Claude inventou uma convenção que não está no harness — devo aceitar?"**
Não. Pergunta de onde veio. Se for boa, vira PR no `.gsd/CONVENTIONS.md` antes de virar código.

**"A validation está falhando em código que eu não toquei."**
Significa que existe débito pré-existente. Pode corrigir em um `style:` commit no mesmo PR, OU abre uma issue separada e segue só com a tua mudança original (se a falha não bloquear).

**"Quero adicionar uma feature que não está no roadmap."**
Abre issue no board → entra no Backlog → planeja com o time se precisa entrar num sprint próximo.

**"Vou trabalhar offline / a internet caiu."**
Sem problema — o harness é todo arquivos locais. Só o `gh` (issues/PRs) precisa de internet.

---

## Próximos passos

1. Lê o `AGENTS.md` do projeto. **De ponta a ponta**, uma vez. Depois você só precisa consultar.
2. Lê o `.gsd/STACK.md` e `.gsd/CONVENTIONS.md` do projeto que você vai começar a trabalhar.
3. Pega uma task pequena do board (look for "Ready" ou "Priority" no Project) e roda o fluxo completo uma vez antes de pegar algo grande. O primeiro PR é sempre o que mais ensina.

Dúvidas? Pergunta no canal `#engineering` da empresa ou abre uma issue marcando `@KCL-web`.
