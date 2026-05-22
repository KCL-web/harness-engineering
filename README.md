# Harness Engineering Template

Um scaffolding reutilizável de regras, prompts e tooling que permite a um agente de IA (Claude Code ou similar) operar qualquer projeto com a mesma disciplina de workflow: branches, commits, issues, project board, validação e tracking de progresso.

Isto não é um gerador de código. É um **harness** — os documentos e convenções que um agente lê antes de escrever qualquer código, para que o trabalho produzido seja consistente e revisável.

---

## Por que isso existe

Sem um harness, toda sessão de IA começa do zero: o agente inventa convenções, o dev corrige, e o projeto deriva. Com um harness:

- Regras universais (formato de commit, branching, GitHub Project board) são escritas uma vez e compartilhadas entre todos os projetos.
- Decisões específicas de stack (folder layout, componentes, testes) são capturadas uma vez por projeto e nunca relitigadas.
- O agente lê as regras no início da sessão e segue sem ser lembrado.
- Atualizações nas regras universais propagam para todos os projetos via script de sync.

Três modos de workspace são suportados, então o mesmo template funciona para apps solo, produtos full-stack espalhados por vários repos, ou qualquer coisa no meio.

---

## Requisitos

O harness é agnóstico de stack e intencionalmente mínimo. Para usar você precisa de:

| Ferramenta | Usada por | Por quê |
| --- | --- | --- |
| `bash` ≥ 4 | todos os scripts | roda `harness-init.sh`, `harness-sync.sh`, `check-harness.sh` |
| `git` | todos os scripts | necessário para detecção de repo e o diff de base-ref em `check-harness.sh` |
| **`jq`** | `scripts/check-harness.sh` e o gate de CI | valida `.harness/feature_list.json` e `.harness/baseline.json` |
| `gh` CLI *(opcional)* | regras do GitHub Project bootstrap em `AGENTS.md` | só precisa se você quiser o agente gerenciando issues/projects do terminal — [instalar](#instalando-o-gh-cli-opcional) |
| `claude` CLI *(opcional)* | auto-start do `harness-init.sh` | só precisa se você quiser que a entrevista de bootstrap suba automaticamente — [instalar](#instalando-o-claude-code-cli-opcional) |

`jq` é um binário de sistema — não dá pra declarar como dependência de projeto em `package.json`/`pyproject.toml`/etc. `harness-init.sh` detecta seu OS (distro Linux / macOS / shell Windows) e oferece instalar pra você na primeira vez que rodar o bootstrap. Para instalar manualmente:

```bash
# Debian/Ubuntu/WSL
sudo apt-get install -y jq

# macOS (Homebrew)
brew install jq

# Fedora/RHEL
sudo dnf install -y jq

# Arch
sudo pacman -S jq

# Alpine
sudo apk add jq

# Windows (Git Bash, MSYS2, Cygwin ou PowerShell)
winget install jqlang.jq      # padrão no Windows 11; funciona em qualquer shell
# ou:
scoop install jq
choco install jq
```

### Notas específicas de Windows

Os shell scripts (`harness-init.sh`, `harness-sync.sh`, `check-harness.sh`) precisam de **bash**. Windows nativo não vem com bash, então use um destes:

- **WSL** (recomendado) — ambiente Ubuntu/Debian completo; `apt-get` funciona como no Linux. Os scripts do harness rodam sem modificação.
- **Git Bash** — instalado com Git for Windows. Bash funciona; install de `jq` cai em `winget`/`scoop`/`choco`.
- **MSYS2** ou **Cygwin** — mesmo que Git Bash para nossos propósitos.

PowerShell sozinho não basta — os scripts precisam de bash. Dentro de qualquer um dos shells acima, `winget install jqlang.jq` funciona porque `winget.exe` é um executável Windows comum chamável de qualquer shell.

Em CI, `.github/workflows/harness-gate.yml` instala `jq` automaticamente no runner (Ubuntu) antes do check.

### Instalando o Claude Code CLI (opcional)

`harness-init.sh` consegue subir a entrevista de bootstrap automaticamente se o CLI `claude` estiver no seu PATH. Sem ele, o script cai num fallback que imprime o caminho do prompt para você colar numa sessão Claude Code manualmente — nada quebra, só uma etapa a mais.

Precisa de Node 18+:

```bash
node --version    # check; install com `sudo apt-get install -y nodejs npm` se faltar
npm install -g @anthropic-ai/claude-code
claude --version  # verifica
```

**Erro de permissão?** Se o npm reclamar de `/usr/local/lib/node_modules` (EACCES), não faça `sudo npm install` — arrume o prefix do npm uma vez e nunca mais veja isso para qualquer pacote global:

```bash
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
source ~/.bashrc

# Agora tente de novo sem sudo:
npm install -g @anthropic-ai/claude-code
```

Isso move o prefix global do npm de um path do sistema (root-owned) para sua home. Todos os `npm install -g` futuros funcionam sem `sudo`.

### Instalando o `gh` CLI (opcional)

O agente usa `gh` para criar issues, linkar projects e abrir PRs do terminal. Sem ele você faz essas etapas pela UI do GitHub — também ok.

```bash
# Debian/Ubuntu/WSL — repo oficial (apt-get install gh instala versão antiga)
sudo apt-get install -y gh

# macOS
brew install gh

# Windows
winget install --id GitHub.cli

# Depois do install, autentique uma vez:
gh auth login
```

---

## Quick start

### 1. Clone o template num lugar estável

```bash
git clone <este-repo> ~/harness-engineering-template
export HARNESS_TEMPLATE=~/harness-engineering-template
```

Adicione o `export` ao seu shell profile para que todo shell tenha.

### 2. Inicialize um projeto novo

```bash
cd ~/projects/my-new-project
$HARNESS_TEMPLATE/scripts/harness-init.sh
```

O script pergunta qual modo se aplica:

| Modo | Quando escolher |
| --- | --- |
| **single-repo** | Um repo Git. Caso padrão. |
| **umbrella** | Uma pasta de workspace contendo vários repos independentes que servem um produto (ex.: `backend/` + `frontend/`). |
| **sub-repo** | Um repo Git que vive dentro de um workspace umbrella. |

Aí copia os arquivos certos e oferece subir a entrevista de bootstrap, que preenche os documentos específicos do projeto fazendo perguntas pra você.

### 3. Rode a entrevista de bootstrap

Se você deixou o script subir, Claude Code abre com o prompt já carregado. **A partir desta versão, o agente escreve os arquivos diretamente:** ele analisa o código existente (em projetos existentes), pré-preenche o que consegue inferir, marca lacunas com `> [TBD: <pergunta>]` e te pergunta as lacunas em lote. No fim você tem:

- `.gsd/SPEC.md` — o que o produto é
- `.gsd/STACK.md` — identificação da stack, comando de validação, env vars
- `.gsd/CONVENTIONS.md` — folder layout e regras específicas da stack
- `.gsd/ROADMAP.md` — milestones, sprints, tarefas

No modo umbrella você ganha `PRODUCT.md` e `INTEGRATION.md` no lugar.

### 4. Comece uma sessão de coding

Abra seu agente dentro do projeto. Com `CLAUDE.md` no root, `AGENTS.md` e suas referências em `@`-cascade carregam automaticamente. Para claude.ai ou outras interfaces que não auto-carregam, use os prompts em `.gsd/SESSION_START.md`.

---

## O que tem no template

```
harness-engineering-template/
├── AGENTS.md                  Regras universais que toda sessão precisa seguir
├── CLAUDE.md                  @AGENTS.md — carregado pelo Claude Code
├── .github/ISSUE_TEMPLATE/    Template padrão de issue
├── .gsd/
│   ├── BOOTSTRAP.md           Como rodar a entrevista de bootstrap
│   ├── bootstrap-prompt.md    O prompt em si (alimentado para o agente pelo harness-init.sh)
│   ├── SESSION_START.md       Prompts de início de sessão, início de tarefa, fechamento, QA
│   ├── STACK.md               Skeleton: qual stack, comando de validação, env vars
│   ├── CONVENTIONS.md         Skeleton: folder layout, componentes, testes, schemas
│   ├── SPEC.md                Skeleton: visão do produto e restrições
│   ├── ROADMAP.md             Skeleton: milestones / sprints / tarefas
│   └── progress/              Logs de progresso de sprint vão aqui
├── umbrella/                  Arquivos usados só em modo umbrella
│   ├── AGENTS.md              Meta-regras para trabalho cross-repo
│   ├── CLAUDE.md
│   ├── PRODUCT.md             Skeleton: visão de produto unificada
│   └── INTEGRATION.md         Skeleton: contratos cross-repo (API, tipos, auth, deploy)
└── scripts/
    ├── harness-init.sh        Setup uma vez só: copia arquivos + sobe a entrevista
    └── harness-sync.sh        Atualiza arquivos universais num projeto existente
```

---

## Como divide responsabilidade

Três camadas, separadas de propósito para que atualizações propaguem limpas.

| Camada | Arquivo | Varia por | Sincronizado por `harness-sync.sh`? |
| --- | --- | --- | --- |
| Workflow universal | `AGENTS.md` | nada | sim |
| Identificação | `.gsd/STACK.md` | projeto | **não** |
| Convenções de stack | `.gsd/CONVENTIONS.md` | projeto | **não** |
| Descrição do produto | `.gsd/SPEC.md` | projeto | **não** |
| Plano | `.gsd/ROADMAP.md` | projeto | **não** |
| Prompts de sessão | `.gsd/SESSION_START.md`, `.gsd/BOOTSTRAP.md`, `.gsd/bootstrap-prompt.md` | nada | sim |

O script de sync copia só a camada universal. Arquivos específicos do projeto nunca são tocados depois de preenchidos.

---

## Modos explicados

### single-repo

Caso mais comum. Um repo Git, uma stack, um conjunto de arquivos de harness. Sessões começam dentro do repo com o harness completo carregado automaticamente.

### umbrella

Uma pasta de workspace (não é repo Git em si) que segura vários repos Git independentes servindo um produto. A raiz do workspace carrega:

- `PRODUCT.md` — fonte única de verdade para visão do produto, problema, usuários, escopo. O `SPEC.md` de cada sub-repo referencia este arquivo em vez de duplicar.
- `INTEGRATION.md` — contratos cross-repo: dono da API, tipos compartilhados, fluxo de auth, ordem de deploy.

Um único GitHub Project (Projects v2) linkado a todos os repos é recomendado. O `AGENTS.md` umbrella documenta as regras cross-repo (issues âncora, nomes de branch combinando, ordem de merge).

### sub-repo

Um repo Git que vive dentro de um workspace umbrella. Operado independentemente no dia a dia mas sabe que tem irmãos. O `SPEC.md` dele começa com uma linha tipo:

> Este repo entrega <fatia X> do produto definido em `../PRODUCT.md`.

O bootstrap, quando rodado em modo sub-repo, lê `../PRODUCT.md` e `../INTEGRATION.md` antes de entrevistar, então o SPEC resultante mantém o foco na fatia deste repo.

---

## Workflow dia a dia

O harness espera uma disciplina que espelha um time pequeno:

1. **GitHub Project board** — seis colunas (Backlog → Ready → Priority → In Progress → In Review → Done). O agente verifica se um project existe no início da sessão e cria se não.
2. **Issues** — toda mudança começa como issue. O template de issue está em `.github/ISSUE_TEMPLATE/`.
3. **Branches** — toda issue ganha sua branch (`feat/slug`, `fix/slug`, `chore/slug`). Sempre saída de `preview`, nunca de `main`.
4. **Commits** — Conventional Commits, inglês, lowercase, modo imperativo, máx 72 chars.
5. **Validação** — o comando de validação do projeto precisa passar antes de cada commit e antes de qualquer PR ser aprovado.
6. **PRs** — de `feat/*` para `preview` para ir pra staging, depois `preview` para `main` para produção. Todo PR referencia sua issue com `Closes #N`.
7. **Tracking de progresso** — no fechamento da sessão, o agente atualiza `.gsd/progress/<MID>-<SID>.md` com o build log e tarefas marcadas.

Os prompts de início e fechamento em `.gsd/SESSION_START.md` reforçam tudo isso sem o dev precisar lembrar.

---

## Mantendo projetos atualizados

Quando você melhorar uma regra universal no template (ex.: convenções de commit mais apertadas), propague para todo projeto que usa o harness:

```bash
cd ~/projects/my-project
./scripts/harness-sync.sh
```

O script de sync detecta o modo do projeto (single-repo, umbrella ou sub-repo) a partir dos arquivos presentes e copia só os arquivos universais daquele modo. Seus `STACK.md`, `CONVENTIONS.md`, `SPEC.md`, `ROADMAP.md`, `PRODUCT.md`, `INTEGRATION.md` e `progress/` preenchidos nunca são tocados.

### Auto-update do template em si

Tanto `harness-init.sh` quanto `harness-sync.sh` rodam `git pull --ff-only` em `$HARNESS_TEMPLATE` antes de copiar, então você sempre pega os arquivos universais mais novos sem puxar manualmente. O pull é pulado (com warning, não erro) se:

- o template tem mudanças locais não commitadas,
- o template não tem remote `origin`,
- `HARNESS_NO_PULL=1` está setado, ou
- a máquina está offline / o fetch falha.

Para desativar o auto-pull em uma execução:

```bash
HARNESS_NO_PULL=1 ./scripts/harness-sync.sh
```

Para puxar manualmente a qualquer hora:

```bash
git -C "$HARNESS_TEMPLATE" pull
```

---

## Customizando por stack

O skeleton do `CONVENTIONS.md` no template descreve um projeto Next.js + TypeScript + SCSS Modules + Vitest. Quando você faz bootstrap de um projeto com stack diferente, o agente adapta: remove seções que não se aplicam (ex.: SCSS num backend) e adiciona as que se aplicam (ex.: padrões de middleware para Express, regras de migration para um app Rails).

Se você se pegar repetindo as mesmas convenções entre vários projetos da mesma stack (ex.: várias APIs Express), o passo natural é forkar este template numa variante específica da stack onde `CONVENTIONS.md` já vem preenchido. Mas não antecipe — comece genérico, especialize quando o padrão se repetir.

---

## Conceitos que vale entender

- **Universal vs específico do projeto**: o harness só funciona se você mantiver a linha limpa. Se uma regra vale para um projeto mas não todos, vai no `CONVENTIONS.md`, não no `AGENTS.md`.
- **Vagueza é o inimigo**: a entrevista de bootstrap faz pushback em respostas vagas ("uma ferramenta pra rastrear coisas") porque specs vagos geram código vago.
- **TBD é permitido**: melhor marcar algo desconhecido do que inventar resposta errada.
- **Fricção é o valor**: se as perguntas parecem chatas, o harness está fazendo o trabalho. Specs que passam sem resistência geralmente estão errados.

---

## Troubleshooting

**O agente não está seguindo as regras de `AGENTS.md`.**
Confirme que `CLAUDE.md` existe no root do projeto e contém `@AGENTS.md`. No claude.ai, cole o prompt de início de sessão de `.gsd/SESSION_START.md` para forçar o agente a ler tudo.

**`harness-sync.sh` sobrescreveu meu `STACK.md`.**
Não deveria — o script nunca lista arquivos específicos do projeto. Se aconteceu, abre uma issue com a versão do script que você rodou.

**A entrevista de bootstrap fica perguntando a mesma coisa.**
É por design quando uma resposta está vaga demais. Seja mais específico.

**Minha stack é exótica (Elixir, Rust, Zig, etc.).**
O prompt de bootstrap é agnóstico de stack nas fases universais. A Fase 3 (Convenções) é onde adapta — responda com base nos idiomas da sua stack e o agente escreve `CONVENTIONS.md` combinando.
