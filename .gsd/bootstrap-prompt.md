Você está fazendo o bootstrap da documentação de um projeto. Seu trabalho é preencher arquivos específicos do projeto a partir de uma entrevista com o desenvolvedor, **escrevendo os arquivos diretamente** com a ferramenta Write/Edit conforme as respostas chegam.

Regras desta sessão:
- Você TEM permissão de escrever os arquivos (Write/Edit) — diferente das regras gerais do AGENTS.md, aqui o objetivo é justamente preencher os skeletons.
- Você TEM permissão de chamar `gh` para criar Project/milestones/issues no PASSO FINAL (sincronia ROADMAP → GitHub). Veja a seção "Sincronia final" no fim deste prompt.
- Você NÃO TEM permissão de rodar `git commit`, `git push`, ou qualquer comando que altere o conteúdo do repositório fora dos arquivos `.gsd/` listados.
- Em projeto existente, analise o código ANTES de perguntar — pré-preencha o que conseguir inferir.
- Para o que não conseguir inferir, escreva o arquivo com marcadores explícitos:
  - `> [inferido]` antes de campos que você deduziu do código
  - `> [TBD: <pergunta específica e curta>]` antes de campos que precisam de input do dev
- Pergunte as lacunas EM LOTE, agrupadas por arquivo — não uma a uma. Ex.: "Tenho 3 TBDs no SPEC.md: visão, problema e usuários. Resposta combinada?"
- Se a resposta do dev for vaga ("uma ferramenta pra rastrear coisas"), faça pushback e peça especificidade.
- Se o dev contradisser algo dito antes, aponte.
- Não invente. Se o dev não souber, marque como `TBD: <descrição do que falta>` no arquivo final (rastreável com `grep -r "TBD:" .gsd/`).
- Mantenha as perguntas em linguagem simples. Sem jargão a menos que o dev use primeiro.
- A documentação resultante é em **português-BR**. Os arquivos do template já estão nesse idioma — preserve.
- Conventional Commits, nomes de branch e identificadores técnicos (`feat`, `fix`, etc.) seguem em **inglês** mesmo na documentação em pt-BR.

==================================================================
PERGUNTA ZERO-A — modo de workspace
==================================================================

Antes de tudo, pergunte:

  "Qual é o modo deste diretório?
    1) single-repo — um repo Git, projeto standalone
    2) umbrella    — workspace raiz contendo múltiplos repos Git como subpastas
    3) sub-repo    — um dos repos Git dentro de um workspace umbrella"

Espere a resposta. O modo determina quais arquivos você preenche:

  - single-repo → .gsd/SPEC.md, .gsd/STACK.md, .gsd/CONVENTIONS.md, .gsd/ROADMAP.md
  - umbrella    → PRODUCT.md, INTEGRATION.md
  - sub-repo    → mesmos arquivos do single-repo, mas você precisa LER PRIMEIRO ../PRODUCT.md e
                  ../INTEGRATION.md. O SPEC deste repo é uma fatia do produto,
                  não o produto inteiro.

==================================================================
PERGUNTA ZERO-B — estado do código
==================================================================

Depois pergunte:

  "Este é um projeto NOVO (sem código ainda) ou EXISTENTE (código já existe, total ou parcialmente)?"

Se EXISTENTE → rode a FASE 0 antes (descrita abaixo). Caso contrário, pule para as fases de entrevista.

==================================================================
FASE 0 — Análise (só para projetos existentes)
==================================================================

Para single-repo e sub-repo: analise o diretório atual.
Para umbrella: analise brevemente cada sub-repo para entender o que cada um faz.

Examine nesta ordem:
  a) Manifestos (package.json, Cargo.toml, go.mod, pyproject.toml, requirements.txt, etc.)
  b) Estrutura de pastas
  c) README.md e qualquer docs/
  d) Histórico recente de commits (últimos 30-50)
  e) Issues e PRs abertas se acessíveis
  f) Arquivos de entrada (page, route, index, main)

Depois da análise, mostre ao dev um SUMÁRIO CURTO (5-10 linhas):
  - single/sub-repo: stack identificada, propósito aparente do produto, maturidade, o que está obscuro
  - umbrella: lista de sub-repos com uma linha por cada descrevendo o que faz, padrões de integração identificados

Espere a confirmação do dev antes de prosseguir para as fases de entrevista.

==================================================================
ENTREVISTA — MODO SINGLE-REPO
==================================================================

O fluxo é: **rascunho primeiro, perguntas depois.**

PASSO A — Rascunho dos 4 arquivos

Crie via Write os 4 arquivos `.gsd/SPEC.md`, `.gsd/STACK.md`, `.gsd/CONVENTIONS.md`, `.gsd/ROADMAP.md` a partir dos skeletons existentes, preenchendo:

- Em projeto EXISTENTE: tudo o que conseguiu inferir da análise da FASE 0. Marque com `> [inferido]` no parágrafo inferido.
- Em projeto NOVO: deixe todas as seções com `> [TBD: <pergunta curta>]` em vez de placeholder genérico.

PASSO B — Mostre ao dev o que escreveu

Faça um resumo em 1 frase do que cada arquivo ficou (inferências + TBDs).

PASSO C — Entrevista em lote por arquivo

Para cada arquivo, pergunte os TBDs em UM ÚNICO bloco. Exemplo:

  "Para o SPEC.md ficar pronto, preciso de:
   1. Visão (uma frase: que tipo de ferramenta, para quem, qual resultado)
   2. Problema concreto (quem sofre, em que situação)
   3. Out of scope (pelo menos 3 itens)
   Pode responder os 3 juntos."

Depois de cada lote, edite o arquivo via Edit (substitua os TBDs pelas respostas e remova o marcador `> [inferido]` se virou conteúdo real).

Cobertura mínima por arquivo:

**SPEC.md**
  1. Visão em uma frase
  2. Problema (quem sofre, situação, custo)
  3. Solução em 3-5 capacidades numeradas
  4. Papéis de usuário
  5. Pelo menos 3 itens fora de escopo
  6. Critérios de sucesso observáveis
  7. Restrições não-óbvias, edge cases, invariantes

**STACK.md** — Stack, Validação, Setup
  8. Framework, linguagem, banco/ORM, estilização, testes, gerenciador de pacotes, deploy.
     Em projeto existente, parta do que identificou na FASE 0.
     Se o dev disser "você escolhe", sugira 2 opções e explique o trade-off brevemente.
  9. Comando de validação — o comando único que precisa passar antes de cada commit.
     O que ele roda internamente? (typecheck, lint, testes, format check, etc.)
 10. Comandos de setup — clone, install, env file, dev server.

**STACK.md** — Env vars + Notas
 11. Para cada serviço externo (banco, APIs, auth providers), que env vars são necessárias?
 12. Restrições, decisões, edge cases conhecidos que o agente precisa respeitar em toda sessão.

**CONVENTIONS.md**
 13. Com base na stack, proponha um layout de pastas/arquivos. O skeleton no template é Next.js +
     SCSS Modules + Vitest — adapte ou substitua para combinar com a stack (ex.: backend Express usa
     routes/middleware/services; Go usa cmd/pkg/internal).
 14. Contratos específicos da stack: que regras são inegociáveis para ESTA stack?
     (componentes, estilos, testes, schemas, padrões de API, migrations, etc.)
     Remova seções que não se aplicam, adicione as que se aplicam.

**ROADMAP.md**
 15. Menor versão demonstrável → Milestone 1. Nomeie.
     Se for projeto existente, marque tarefas já feitas como [x] com base no histórico de commits.
 16. Sprints do M01 (2-4), cada um entregando algo demonstrável. Nomeie cada.
 17. Tarefas por sprint. Cada tarefa precisa caber em uma sessão do agente (um arquivo ou uma superfície de feature).
 18. M02 e M03 se aplicáveis. Pare em 3 milestones — qualquer coisa além é especulação.

PASSO D — Verificação final

No fim, rode `grep -n "TBD:" .gsd/*.md` mentalmente e mostre ao dev a lista dos TBDs que sobraram. Pergunte:

  "Sobraram N TBDs. Quer responder agora, ou prefere deixar para revisitar depois?"

Se o dev quiser revisitar depois, deixe os TBDs no arquivo — eles ficam rastreáveis e o próximo bootstrap pode continuar de onde parou.

==================================================================
ENTREVISTA — MODO UMBRELLA
==================================================================

Mesma estrutura: rascunho primeiro com `PRODUCT.md` e `INTEGRATION.md` via Write, depois entrevista em lote.

Cobertura mínima:

**PRODUCT.md**
  1. Produto geral (cruzando todos os repos) em uma frase
  2. Para quem é
  3. Que problema resolve hoje que não está bem resolvido
  4. 3-5 capacidades principais do produto inteiro
  5. Fora de escopo (no nível do produto)
  6. Critérios de sucesso observáveis
  7. Lista de repos no workspace: para cada — nome da pasta + uma linha do que entrega
     (Se existente, proponha a lista a partir das subpastas que encontrou.)
  8. Restrições não-óbvias que atravessam o produto inteiro

**INTEGRATION.md**
  9. Para cada par de repos que se falam: identifique o contrato
     - Qual é a API ou protocolo?
     - Qual repo é DONO do contrato (fonte de verdade)?
     - Quais repos CONSOMEM?
     - Como os consumidores ficam em sincronia? (manual, codegen OpenAPI, pacote compartilhado, etc.)
 10. Tipos ou schemas compartilhados — onde estão definidos, como propagados
 11. Fluxo de autenticação — emissor do token, formato, consumidores, política de rotação
 12. Env vars compartilhadas — quais precisam bater entre os repos
 13. Ordem de deploy para features cross-repo

NÃO gere arquivos por-repo (SPEC, STACK, CONVENTIONS, ROADMAP) em modo umbrella.
Esses são preenchidos depois rodando este bootstrap dentro de cada sub-repo separadamente.

==================================================================
ENTREVISTA — MODO SUB-REPO
==================================================================

PRIMEIRO, leia ../PRODUCT.md e ../INTEGRATION.md.
Se não existirem, pare e diga ao dev para rodar o bootstrap umbrella primeiro.

Então rode a entrevista de single-repo, com estes ajustes:

- No SPEC.md, a primeira linha deve ser:
  "Este repo entrega <fatia X> do produto definido em `../PRODUCT.md`."
- Capacidades listadas no SPEC são as capacidades DESTE repo, não do produto inteiro.
- "Fora de escopo" aqui significa fora do escopo DESTE repo (repos irmãos podem cobrir esses itens).
- Cite ../INTEGRATION.md quando contratos com repos irmãos aparecerem.
- Em CONVENTIONS, pode legitimamente emprestar convenções de um repo irmão quando fizer sentido.

==================================================================
SINCRONIA FINAL — só em modo single-repo e sub-repo
==================================================================

Depois que o `.gsd/ROADMAP.md` está preenchido (com confirmação do dev), o agente cria automaticamente no GitHub:

1. **GitHub Project** (se não existir) — seguindo o modelo de 6 colunas em AGENTS.md → Bootstrap do GitHub Project.
2. **Milestones** — uma por marco do ROADMAP (M01, M02, M03 se aplicável).
3. **Issues** — uma por task de cada sprint, no Backlog, linkadas à milestone correspondente.

Procedimento exato: ver seção **"Sincronia: como criar Project/Milestones/Issues"** em `AGENTS.md`. Resumido:

- Pré-checagem: `gh auth status` e `gh project list` devem responder. Se o token não tem scope `project`, pare e peça ao dev: `gh auth refresh -s project,read:project`.
- Antes de criar QUALQUER coisa, mostre ao dev a lista do que vai criar (resumo: N milestones, M issues) e espere "ok". Isso é a única fricção — depois do "ok", roda tudo.
- Cada issue criada carrega o marcador `Task: <MID>-<SID>-<TID>` na primeira linha do body, para que sincronias futuras (no início de toda sessão) não dupliquem.
- Ao final, mostre o resumo (Project URL, milestones criadas, issues criadas com números).

Em modo **umbrella**, o agente NÃO cria issues por task — esse fluxo roda em cada sub-repo separadamente, com o ROADMAP daquele sub-repo. No nível umbrella, só cria o Project compartilhado (se aplicável) e nada mais.

==================================================================
REGRAS GERAIS
==================================================================

- Você PODE editar `.gsd/SPEC.md`, `.gsd/STACK.md`, `.gsd/CONVENTIONS.md`, `.gsd/ROADMAP.md` (ou `PRODUCT.md`/`INTEGRATION.md` em umbrella, ou tudo isso em sub-repo).
- Você PODE chamar `gh` no passo de sincronia final (Project/milestones/issues), depois do "ok" explícito do dev.
- Você NÃO PODE: rodar `git commit`/`git push`, mexer em `AGENTS.md`/`CLAUDE.md`/`scripts/`/`.harness/`, ou criar/fechar issues fora do passo de sincronia final.
- Comece pela PERGUNTA ZERO-A.
