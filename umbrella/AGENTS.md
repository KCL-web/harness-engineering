# AGENTS.md — Umbrella

Este arquivo é carregado quando uma sessão do agente começa na **raiz do workspace** de um projeto multi-repo (onde dois ou mais repos Git independentes vivem lado a lado como subpastas).

É uma camada meta fina. As regras reais de cada repo vivem dentro do `AGENTS.md` (slim, ~40 linhas) e `.gsd/STACK.md` desse repo, mais as **skills do harness** carregadas globalmente via `~/.claude/skills/harness/`.

---

## O que é o modo umbrella

Este workspace contém **múltiplos repositórios Git independentes** que servem ao mesmo produto. Cada repo:

- Tem seu próprio remote (Forgejo; GitHub é só espelho de backup), branches, milestones/issues, comando de validação, deploy.
- Tem `AGENTS.md` slim + `.gsd/STACK.md` + `.gsd/SPEC.md` + `.gsd/ROADMAP.md`. As convenções de código vêm da skill `stack-<archetype>` apontada no STACK.md — não há mais `CONVENTIONS.md` por sub-repo na v2.
- É operado **independentemente** no dia a dia.

A raiz do workspace adiciona **contexto compartilhado** que é importante demais para duplicar:

- `PRODUCT.md` — a fonte única de verdade para visão do produto, problema, usuários, escopo.
- `INTEGRATION.md` — contratos cross-repo: APIs, tipos compartilhados, fluxo de auth, ordem de deploy.

---

## Quando usar umbrella vs sessões de single-repo

| Você vai… | Onde começar a sessão |
| --- | --- |
| Mudar só um repo (bug fix típico, feature isolada) | `cd <repo>` e comece ali |
| Desenhar uma feature cross-repo (API + UI juntos, mudança de contrato) | Comece na raiz do workspace |
| Raciocinar sobre o produto, usuários ou não-objetivos | Comece na raiz do workspace |
| Refatorar internals de um sub-repo | Dentro desse sub-repo |

Modo single-repo é o padrão — use sempre que puder. Modo umbrella custa mais tokens (carrega as duas stacks). Promova para umbrella só quando o trabalho cruzar repos de verdade.

---

## Ordem de leitura quando começar na raiz do workspace

1. Este arquivo (`AGENTS.md`)
2. `PRODUCT.md`
3. `INTEGRATION.md`
4. Para cada sub-repo que você for tocar: `AGENTS.md` (slim) e `.gsd/STACK.md` desse repo — a skill `stack-<archetype>` correspondente é carregada automaticamente pelo Claude

**Não** pré-carregue todos os sub-repos. Só os relevantes para a tarefa atual.

---

## Regras de trabalho cross-repo

### Coordenação de issues

- Features que atravessam repos ganham uma **issue âncora** no repo que inicia a mudança (geralmente backend, já que contratos nascem ali).
- Cada repo afetado abre sua **issue filha** referenciando a âncora: `Refs <owner>/<repo-âncora>#N`.
- Os critérios de aceitação da issue âncora listam as issues filhas.
- Feche a âncora só quando todos os PRs filhos tiverem mergeado.

### Naming de branch entre repos

- Use o **mesmo slug** em todos os repos para a mesma feature: `feat/favorites` tanto no backend quanto no frontend.
- Isso deixa óbvio quais branches pertencem ao mesmo trabalho na hora de revisar.
- Se a issue âncora e as filhas vivem todas na mesma branch (trabalho single-repo), feche todas no body do PR com várias linhas `Closes #N`.

### Ordem de merge

- O repo que **define** um contrato (ex.: um endpoint de API) mergeia para `develop` primeiro.
- O repo que **consome** o contrato vem depois, com a descrição do PR anotando a dependência.
- Nunca mergeie um consumidor antes do contrato estar disponível em `develop`.

### Validação

- O comando de validação de cada repo roda **independentemente**. Não existe validate no nível umbrella.
- Antes de abrir qualquer PR, o comando do repo alterado precisa passar.
- Se uma mudança cross-repo está em andamento, rode a validação de cada repo afetado localmente antes de abrir qualquer PR.

---

## Coordenação cross-repo no Forgejo (sem board)

O Forgejo deste workspace **não usa project board**. Não existe board compartilhado — cada repo tem suas próprias milestones, labels e issues. A coordenação cross-repo é por **convenção**, não por um quadro central:

- **Issue âncora + filhas** (ver "Coordenação de issues" acima) conectam o trabalho entre repos via `Refs <owner>/<repo-âncora>#N`.
- **Mesmo slug de branch** em todos os repos da mesma feature deixa óbvio o que pertence junto.
- **Mesma nomenclatura de milestone/sprint** (`M01 — <nome>`, label `sprint/M01-S0X`) em cada repo afetado, para que filtrar por milestone/sprint dê a visão cross-repo daquele marco.
- **Priorização** é o label `priority` em cada repo (ver `workflow-issues`) — não há lista central priorizada.

GitHub é só espelho de backup — nunca opere issues/milestones nele.

---

## O que vive onde

| Assunto | Vive em |
| --- | --- |
| Visão do produto, usuários, critérios de sucesso | `PRODUCT.md` (umbrella) |
| Contratos de API, tipos compartilhados, ordem de deploy | `INTEGRATION.md` (umbrella) |
| Fatia deste repo no produto | `<repo>/.gsd/SPEC.md` |
| Milestones e sprints deste repo | `<repo>/.gsd/ROADMAP.md` |
| Stack deste repo + archetype skill correspondente | `<repo>/.gsd/STACK.md` |
| Convenções de código deste stack | skill `stack-<archetype>` (carregada via `~/.claude/skills/harness/`) |
| Regras universais de workflow (branches, commits, PRs, ratchet) | skills `workflow-*` e `ratchet-feature-list` (também via `~/.claude/skills/harness/`) |
| Decisões customizadas que contradizem a skill genérica | drawers no MemPalace, wing do projeto, room `decisions` |

Quando o `SPEC.md` de um sub-repo for duplicar algo do `PRODUCT.md`, ele deve referenciar: "Este repo entrega <fatia X> do produto definido em `../PRODUCT.md`."
