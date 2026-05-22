# AGENTS.md

Este arquivo é o contexto do harness para toda sessão do agente.
Leia inteiro antes de escrever qualquer código.

Este arquivo contém **só regras universais** — workflow, branching, contratos.
A configuração específica do projeto vive em dois arquivos, ambos carregados automaticamente no rodapé:

- `.gsd/STACK.md` — identificação: stack, comando de validação, env vars, notas do projeto
- `.gsd/CONVENTIONS.md` — convenções opinionadas para esta stack: layout de pastas, componentes, testes, schemas

---

## Acompanhamento de progresso

No fim de toda sessão, o agente precisa atualizar `.gsd/progress/` para o sprint atual.

O agente precisa mostrar explicitamente o conteúdo atualizado do arquivo para o dev
revisar e colar manualmente. O agente não escreve arquivos sozinho fora dos contextos
explicitamente permitidos (o bootstrap inicial, descrito em `.gsd/bootstrap-prompt.md`,
é uma exceção autorizada — só nele o agente edita `.gsd/SPEC.md`, `STACK.md`,
`CONVENTIONS.md`, `ROADMAP.md` diretamente).

A atualização precisa:

1. Marcar tarefas concluídas no checklist do contrato
2. Anexar ao build log: `- YYYY-MM-DD: <o que foi feito, uma linha por tarefa>`
3. Se uma tarefa não foi concluída, explicar por quê e o que está bloqueando
4. Nunca marcar tarefa como pronta se o comando de validação do projeto não passou

---

## Bootstrap do GitHub Project

**Antes de qualquer trabalho com issue, branch ou PR começar, um GitHub Project precisa existir para o repositório.**

No início de toda sessão, o agente precisa verificar que um GitHub Project já existe e está linkado ao repositório. Se não existir, o agente cria seguindo o modelo descrito na seção **GitHub Project board** abaixo.

### Verificação

Rode esta checagem no início da sessão:

```bash
gh project list --owner <owner>
```

Se nenhum project bate com o repo atual, o agente precisa criar antes de qualquer outro trabalho.

### Passos de criação

Se o project não existir, o agente cria usando este modelo:

1. **Criar o project**

   ```bash
   gh project create --owner <owner> --title "<repo-name>"
   ```

2. **Adicionar as colunas padrão** (nesta ordem exata):

   | Coluna      | Significado                                              |
   | ----------- | -------------------------------------------------------- |
   | Backlog     | Issue criada, ainda não avaliada                         |
   | Ready       | Avaliada, clara o bastante para começar                  |
   | Priority    | Ready e deve ser pegada em seguida                       |
   | In Progress | Branch criada, em trabalho ativo                         |
   | In Review   | PR aberta, esperando revisão do orquestrador             |
   | Done        | PR mergeada em preview, issue fechada                    |

3. **Linkar o project ao repositório** para que issues e PRs sejam rastreadas automaticamente:

   ```bash
   gh project link <project-number> --owner <owner> --repo <repo>
   ```

4. **Configurar campos padrão**:
   - `Status` (single select) com as seis colunas acima
   - `Type` (single select): `feat`, `fix`, `chore`, `refactor`, `test`, `docs`
   - `Priority` (single select): `low`, `medium`, `high`

5. **Confirmar a criação** mostrando a URL do project ao dev para revisão.

### Regras

- O project precisa existir antes de qualquer issue ser aberta
- O project precisa seguir exatamente o modelo de colunas definido neste arquivo
- O agente nunca avança para criação de branch, tracking de issue ou trabalho de PR se o project estiver faltando
- Se o agente não conseguir criar o project automaticamente (permissões faltando, `gh` CLI faltando), ele para e pede explicitamente para o dev criar manualmente antes de continuar

---

## Estratégia de branches

### Hierarquia de branches

```
main        → produção, sempre estável e deployada
preview     → ambiente de staging, espelha o que está prestes a ir para main
feat/*      → branches de feature
fix/*       → branches de bug fix
chore/*     → tooling, config, dependências
```

### Regras

- `main` é protegida — nunca pushe direto
- `preview` é protegida — nunca pushe direto
- Branches são nomeadas pelo trabalho, não pelo número da issue, usando um slug kebab-case curto:
  ```
  feat/webhook-receiver
  fix/missing-start-time
  chore/vitest-setup
  ```
- Uma branch pode fechar uma ou mais issues relacionadas; declare cada uma no body do PR com uma linha `Closes #N` separada. Isso é intencional — issues pequenas relacionadas costumam compartilhar uma branch.
- O tipo da branch precisa bater com o tipo dominante da issue (feat, fix, chore, refactor, test, docs).
- Nome de branch em inglês, lowercase, separado por hífen, sem caracteres especiais.

### Fluxo

```
issue criada (Backlog)
    ↓
issue priorizada (Ready → Priority)
    ↓
branch criada a partir de preview: git checkout -b feat/short-slug
    ↓
issue movida para In Progress
    ↓
trabalho feito local → comando de validação do projeto passa
    ↓
commit(s) pushados → PR aberto de feat/* para preview
    ↓
issue movida para In Review
    ↓
orquestrador revisa o PR
    ↓ aprovado             ↓ mudanças requeridas
merge feat/* → preview    volta para In Progress
    ↓
preview deployado e validado
    ↓
PR aberto de preview → main
    ↓
PR aprovado → merge → main deployado
    ↓
issue movida para Done
```

### Criando uma branch

Sempre crie a partir de `preview`, nunca de `main`:

```bash
git checkout preview
git pull origin preview
git checkout -b feat/short-slug
```

### Abrindo um PR

- PR de `feat/*` → `preview`: obrigatório antes de mover a issue para In Review
- PR de `preview` → `main`: obrigatório antes de deployar para produção
- Título do PR segue o mesmo formato Conventional Commits das mensagens de commit
- Descrição do PR precisa referenciar cada issue que fecha com uma linha `Closes #N` por issue (um único PR pode fechar várias issues relacionadas)
- PRs em que o comando de validação do projeto falha não devem ser aprovados

---

## GitHub Project board

### Colunas

| Coluna      | Significado                                              |
| ----------- | -------------------------------------------------------- |
| Backlog     | Issue criada, ainda não avaliada                         |
| Ready       | Avaliada, clara o bastante para começar                  |
| Priority    | Ready e deve ser pegada em seguida                       |
| In Progress | Branch criada, em trabalho ativo                         |
| In Review   | PR aberta, esperando revisão do orquestrador             |
| Done        | PR mergeada em preview, issue fechada                    |

### Ciclo de vida da issue

1. Criada → cai em **Backlog**
2. Depois do refinamento → vai para **Ready**
3. Escolhida como próxima tarefa → vai para **Priority**
4. Branch criada + trabalho começado → vai para **In Progress**
5. Comando de validação do projeto passa + PR aberta → vai para **In Review**
6. PR aprovada + mergeada → vai para **Done**

Uma issue nunca deve ser movida para In Review sem um PR aberto.
Uma issue nunca deve ser movida para Done sem o PR mergeado.

---

## Template de issue

Toda issue precisa conter todas as seções abaixo:

```markdown
## Descrição

Sobre o que é esta issue. Um parágrafo curto, linguagem direta.

## Situação atual

O que existe hoje. O que está faltando ou quebrado.

## O que implementar

Descrição detalhada da solução esperada.
Seja específico: quais arquivos, quais funções, qual comportamento.

## Escopo

- [ ] Backend
- [ ] Frontend
- [ ] Ambos

## Feature(s)

IDs de feature do `.harness/feature_list.json` que esta issue implementa ou verifica. Deixe vazio se for trabalho puramente de tooling/chore sem feature do usuário.

- F001
- F002

## Critérios de aceitação

Um checklist. A issue só fica Done quando todo item está marcado.

- [ ] Critério um
- [ ] Critério dois
- [ ] Comando de validação do projeto passa
- [ ] Todas as features linkadas em `.harness/feature_list.json` têm `implemented: true` (sessão de dev) e `verified: true` (sessão de QA)
- [ ] Nenhuma métrica em `.harness/baseline.json` regrediu
- [ ] PR referencia esta issue com `Closes #N`
```

---

## Convenções de commit

Todos os commits seguem Conventional Commits em **inglês**.

Formato: `<type>(escopo opcional): <descrição curta>`

Tipos permitidos:

- `feat` — nova feature
- `fix` — bug fix
- `chore` — tooling, config, dependências
- `refactor` — mudança de código sem mudança de comportamento
- `test` — adicionar ou atualizar testes
- `docs` — só documentação
- `style` — formatação, ponto-e-vírgula faltando (sem mudança de lógica)
- `perf` — melhoria de performance

Regras:

- Descrição em inglês, lowercase, sem ponto no fim
- Modo imperativo: "add route" e não "added route"
- Máximo 72 caracteres na primeira linha

Bons exemplos:

```
feat(webhook): add github signature verification
fix(report): handle missing startTime in worked minutes calculation
chore: add vitest configuration
test(lib): add unit tests for calculateWorkedMinutes
refactor(dashboard): extract IssueRow into reusable component
```

Maus exemplos:

```
fix stuff
Adicionado novo componente
update
WIP
```

> Por que o commit é em inglês mesmo com toda a documentação em pt-BR? Conventional Commits é um padrão de ferramentas (changelog, release tools, github filters) — manter em inglês evita parsing inconsistente. A documentação humana (este arquivo, SPEC, etc.) fica em português.

---

## Feature list e quality ratchet

O harness usa dois contratos legíveis por máquina em `.harness/` para ligar sessões de dev e sessões de QA:

- **`.harness/feature_list.json`** — cada feature que o projeto precisa entregar, com critérios observáveis que a sessão de QA consegue verificar contra a app rodando.
- **`.harness/baseline.json`** — valores atuais de métricas de qualidade (testes passando, coverage, lint warnings, etc.) que só podem melhorar.

Veja `.harness/README.md` para os schemas, exemplos e regras completas.

Os dois arquivos são validados por `scripts/check-harness.sh` — um gate agnóstico de stack (bash + jq + git, sem dependências do projeto) que roda:

- Localmente: como parte do comando de validação do projeto, ou diretamente via `bash scripts/check-harness.sh`
- Em CI: via `.github/workflows/harness-gate.yml` em todo PR para `main` ou `preview`

A checagem garante validade JSON, integridade do schema, `title`/`criteria[]` congelados em features existentes, sem remoção de feature, e sem regressão de métrica de baseline vs branch base.

### Por que duas sessões, dois arquivos

O harness separa o trabalho em duas sessões distintas, cada uma restrita por um artefato diferente:

| Sessão  | Lê | Escreve | Não pode |
| ------- | -- | ------- | -------- |
| **Dev** | issue, `feature_list.json`, `baseline.json`, todo `.gsd/` | código, vira `implemented: true`, atualiza `baseline.json` (só se métricas melhoraram) | editar `title` ou `criteria[]` de qualquer feature; baixar qualquer métrica do baseline sem motivo explícito no build log |
| **QA**  | `AGENTS.md`, `STACK.md`, `CONVENTIONS.md`, `feature_list.json`, `progress/<MID>-<SID>.md` | vira `verified: true`, adiciona notes em falhas, atualiza progresso | implementar código; "concordar" com o que a sessão de dev alegou — precisa rodar cada critério contra a app viva |

O ponto de duas sessões é que o agente de QA não tem **memória** da conversa do dev. Ele não pode ser convencido "sim, já discutimos isso, funciona" — só pode checar o texto literal de `criteria[]` contra o sistema rodando.

### Regras

- `title` e `criteria[]` de uma feature ficam **congelados** depois que a issue é aberta. Se o requisito mudar de verdade, feche a feature e crie uma nova com novo ID.
- A sessão de dev atualiza `implemented` e pode atualizar `baseline.json` para registrar métricas melhoradas.
- A sessão de QA atualiza `verified` só depois de rodar cada critério contra a app viva.
- Um PR não pode ser mergeado em `preview` enquanto qualquer feature linkada tiver `verified: false`.
- Nenhuma métrica em `baseline.json` pode regredir sem um motivo documentado no build log do mesmo PR.

---

## Contratos

Estas regras são inegociáveis. Nunca viole.

Contratos específicos da stack (componentes, estilos, testes, schemas, etc.) ficam em
`.gsd/CONVENTIONS.md` e se aplicam além das regras abaixo.

### Gerais

- O comando de validação do projeto (ver `.gsd/STACK.md`) precisa passar antes de cada commit
- Sem escape hatches de type system — seja explícito sobre tipos e estreite incertezas nas fronteiras (regras específicas de stack ficam em `.gsd/CONVENTIONS.md`)
- Sem código comentado em commits
- Sem debug prints em commits (sem `console.log`, `print`, `dbg!`, `fmt.Println`, etc. — use o logger do projeto)

### Feature list e ratchet

- Nunca edite `title` ou `criteria[]` de uma feature existente em `.harness/feature_list.json`
- Nunca vire `verified: true` de uma sessão de dev — isso é só de QA
- Nunca diminua qualquer métrica em `.harness/baseline.json` sem motivo documentado no build log do mesmo PR
- Todo PR voltado para usuário precisa linkar pelo menos um feature ID; PRs de chore/tooling/refactor podem não ter nenhum

### GitHub project

- Um GitHub Project precisa existir para o repositório antes de qualquer trabalho de issue ou branch começar
- Se o project não existir, o agente cria seguindo o modelo da seção **Bootstrap do GitHub Project**
- O project precisa usar exatamente as seis colunas definidas em **GitHub Project board**

### Sincronia ROADMAP ↔ GitHub

O `.gsd/ROADMAP.md` é a fonte de verdade do plano. O GitHub (Project, milestones, issues) é o espelho operacional dele. **O agente mantém os dois em sincronia automaticamente**, criando no GitHub o que existe no ROADMAP mas ainda não foi criado.

Regras:

- **Ao final do bootstrap** (depois que o ROADMAP foi escrito): o agente cria o Project (se não existir), todas as milestones do ROADMAP, e uma issue por task. Veja a seção **Sincronia: como criar Project/Milestones/Issues** abaixo para o procedimento.
- **No início de toda sessão**: o agente compara ROADMAP vs estado atual do GitHub. Se há tasks no ROADMAP sem issue correspondente, ou milestones sem entrada no GitHub, ele cria as faltantes. Mostra ao dev o resumo do que sincronizou.
- **Granularidade**: uma issue por task (`T01`, `T02`, ...). Cada issue carrega o marcador `Task: <MID>-<SID>-<TID>` na primeira linha do body para ser identificável depois (a sincronia procura esse marcador antes de criar duplicata).
- **Direção**: sincronia é só ROADMAP → GitHub. O agente **nunca apaga, fecha ou modifica** issues existentes para refletir mudanças no ROADMAP (ex.: se o dev removeu uma task, a issue continua aberta — o dev decide o que fazer).
- **Issues novas entram em**: status `Backlog`, sem priority, sem branch. A milestone correspondente já é linkada.
- **Não conflitar com criação manual**: se o dev criou uma issue manualmente que cobre uma task, ele adiciona `Task: <MID>-<SID>-<TID>` ao body — a sincronia respeita e não duplica.

---

## Sincronia: como criar Project/Milestones/Issues

Procedimento determinístico que o agente segue ao sincronizar ROADMAP → GitHub. Roda no fim do bootstrap e no início de toda sessão.

### Passo 1: Project

```bash
gh project list --owner <owner> --format json
```

Se nenhum project corresponde ao repo, criar seguindo a seção **Bootstrap do GitHub Project** acima (6 colunas, 3 campos).

### Passo 2: Milestones

Para cada milestone do `.gsd/ROADMAP.md` (M01, M02, ...):

```bash
gh api repos/<owner>/<repo>/milestones --jq '.[].title'
```

Se a milestone (pelo título, ex.: "M01 — Core pipeline") não existe, criar:

```bash
gh api repos/<owner>/<repo>/milestones \
  -f title="M01 — Core pipeline" \
  -f description="Goal: ... · Shippable when: ..." \
  -f state="open"
```

### Passo 3: Issues por task

Para cada task do ROADMAP (ex.: `M01-S02-T01: create webhook receiver`):

1. Buscar issue existente pelo marcador:
   ```bash
   gh issue list --search "Task: M01-S02-T01 in:body" --state all --json number,title
   ```
2. Se já existe, pular.
3. Se não existe, criar:
   ```bash
   gh issue create \
     --title "<type>(<scope>): T01 - <descrição da task>" \
     --body "<body do template .github/ISSUE_TEMPLATE/default.md, com 'Task: M01-S02-T01' na primeira linha>" \
     --milestone "M01 — Core pipeline" \
     --label "<type>"
   ```
4. Adicionar ao Project no status Backlog:
   ```bash
   gh project item-add <project-number> --owner <owner> --url <issue-url>
   ```
   E setar `Status=Backlog`, `Type=<type>` no Project (via `gh project item-edit`).

### Resumo ao dev

Ao final, o agente mostra:

```
Sincronia ROADMAP → GitHub:
- Project: <criado | já existia> (<url>)
- Milestones criadas: M01, M02
- Milestones já existentes (puladas): M03
- Issues criadas: 12 (#NN..#NN)
- Issues já existentes (puladas pelo marcador Task:): 5
- Tasks no ROADMAP sem issue após sincronia: 0
```

Se algum passo falhou (token sem scope `project`, milestone com nome divergente, etc.), o agente para e mostra o erro — não tenta workarounds destrutivos.

### Branches

- Sempre crie a partir de `preview`, nunca de `main`
- Nome de branch usa um slug curto descrevendo o trabalho, não o número da issue: `feat/short-slug`
- Uma única branch/PR pode fechar várias issues relacionadas — liste cada uma com uma linha `Closes #N` separada no body do PR
- Nunca pushe direto para `main` ou `preview`
- Todo PR precisa referenciar pelo menos uma issue com `Closes #N`

---

A configuração específica do projeto é carregada automaticamente destes arquivos:

@.gsd/STACK.md
@.gsd/CONVENTIONS.md
