---
name: harness-index
description: Índice das skills do harness-engineering. Carrega regras universais (branches develop/main, sessões dev/QA, validação antes de commit) e aponta para skills específicas (workflow-*, frontend/*, backend/*, ratchet-*). Invoque sempre que iniciar uma sessão em projeto que contém .gsd/ ou .harness/, ou quando o dev mencionar "harness".
---

# Harness Index

Você está em um projeto que usa o **harness-engineering**. Este índice descreve quando invocar cada skill específica e aponta para as regras universais.

## Referência

| Arquivo | Conteúdo |
| --- | --- |
| [reference/how-it-works.md](reference/how-it-works.md) | Como o harness organiza sessões dev/QA por contrato |
| [reference/universal-rules.md](reference/universal-rules.md) | Regras universais válidas em toda sessão |
| [reference/project-config-and-progress.md](reference/project-config-and-progress.md) | Onde buscar configuração do projeto, como atualizar progresso |

## Skills específicas — quando invocar cada

| O dev pediu… | Invoque |
| --- | --- |
| Criar branch, naming, hierarquia develop/main | `workflow-branching` |
| Abrir/priorizar issue, template, milestones, sprints, assign ao dev, sincronia ROADMAP → Forgejo | `workflow-issues` |
| Abrir PR, `Closes #N`, validação, auto-merge em develop | `workflow-prs` |
| Mensagem de commit (Conventional Commits) | `workflow-commits` |
| Adicionar feature, atualizar baseline, ratchet | `ratchet-feature-list` |
| Código frontend — componente React, estrutura, props | `frontend/react` |
| Código frontend — type safety TypeScript | `frontend/typescript` |
| Código frontend — aliases, env vars `VITE_*` | `frontend/vite` |
| Código frontend — estilo SCSS Modules + BEM | `frontend/scss-bem` |
| Código frontend — estilo Tailwind CSS | `frontend/tailwind` |
| Código frontend — componentes shadcn/ui (Radix + cva) | `frontend/shadcn-ui` |
| Código frontend — formulário (RHF + zod) | `frontend/react-hook-form-zod` |
| Código frontend — teste unitário/componente (Vitest + Testing Library) | `frontend/vitest-testing-library` |
| Código frontend — teste E2E de fluxo crítico (Playwright) | `frontend/playwright-e2e` |
| Código backend — Django, DRF (model, serializer, view) | `backend/django-drf` |
| Código backend — autenticação JWT via cookie httpOnly | `backend/jwt-cookie-auth` |
| Código backend — API de apoio Node/Express para lógica sensível a segredo | `backend/express` |
| Código backend — instrumentação de métricas (RED/USE), Prometheus/Grafana central | `backend/observability` |
| Decidir arquitetura pra tráfego/volume crescente, escada de padrões por escala | `scaling-architecture` |
| Memória cross-projeto (wings/rooms/drawers, MemPalace) | `memory-palace` |
| Rituais de início/fim de sessão (wake-up, search, drawer recap) | `session-rituals` |
| Skills auto-evolutivas (FIX/DERIVED/CAPTURED, OpenSpace) | `evolving-skills` |
| Auditoria de segurança completa (validação final ou bootstrap de projeto existente) | `security-audit` |
| Infra: por que Forgejo não responde por IP direto, como o deploy automático dispara, endereços da tailnet | `infra-forgejo-coolify` |

## Skills importadas de mattpocock/skills (disciplina de engenharia agnóstica de stack)

Importadas de [mattpocock/skills](https://github.com/mattpocock/skills) e adaptadas ao vocabulário deste harness (tracker = Forgejo, sessões dev/QA). Rode `setup-imported-skills` uma vez por projeto antes de usar `triage`, `domain-modeling` ou `grill-with-docs` (mapeia labels de triage e decide layout de `CONTEXT.md`/ADR).

**User-invoked** (o dev digita explicitamente; nunca acionadas sozinhas pelo modelo):

| O dev pediu… | Invoque |
| --- | --- |
| Não sabe qual skill usar, quer um roteador | `ask-matt` |
| Entrevista implacável antes de codar (alinhamento) | `grill-me` |
| Igual acima, mas também constrói `CONTEXT.md`/ADR inline | `grill-with-docs` |
| Transformar a conversa numa spec e publicar como issue | `to-spec` |
| Quebrar spec/plano em tickets tracer-bullet com dependências | `to-tickets` |
| Implementar o que está em spec/tickets, terminando com `code-review` | `implement` |
| Planejar trabalho maior que uma sessão aguenta, como grafo de decisões | `wayfinder` |
| Mover issues/PRs externas por estados de triagem | `triage` |
| Varrer a codebase por oportunidades de deepening (relatório HTML) | `improve-codebase-architecture` |
| Compactar a sessão atual num handoff para outro agente continuar | `handoff` |
| Ensinar o dev uma skill/conceito ao longo de várias sessões | `teach` |
| Transformar uma decisão em questionário para outra pessoa responder | `to-questionnaire` |
| "Não entendi, repete o pitch" quando uma mensagem não fez sentido | `wait-what` |
| Configurar labels de triage e layout de `CONTEXT.md`/ADR (uma vez por projeto) | `setup-imported-skills` |

**Model-invoked** (podem ser acionadas por você mesmo quando a tarefa encaixa, sem o dev precisar digitar):

| Situação | Invoque |
| --- | --- |
| TDD, red-green-refactor, teste antes do código | `tdd` |
| Loop de diagnóstico para bug difícil ou regressão de performance | `diagnosing-bugs` |
| Revisar diff/PR em dois eixos (Standards vs. Spec da issue) | `code-review` |
| Vocabulário de módulo profundo/interface/seam ao desenhar código | `codebase-design` |
| Afiar termo de domínio, atualizar `CONTEXT.md`/ADR inline | `domain-modeling` |
| Protótipo descartável para responder pergunta de design de UI/lógica | `prototype` |
| Investigar pergunta contra fontes primárias, registrar achados citados | `research` |
| Resolver conflito de merge/rebase em andamento hunk a hunk | `resolving-merge-conflicts` |
| Gerar wizard bash interativo para passo manual (credencial, infra, migration) | `wizard` |
| Primitiva de entrevista implacável por trás de `grill-me`/`grill-with-docs`/`triage`/`wayfinder` | `grilling` |
| Escrever/editar skill, AGENTS.md/CLAUDE.md, ou doc que um agente lê por ponteiro | `writing-for-agents` |
| Configurar hook do Claude Code contra comando git perigoso | `git-guardrails-claude-code` |
| Migrar teste de type assertion `as` para `@total-typescript/shoehorn` | `migrate-to-shoehorn` |
| Criar estrutura de diretório de exercícios (sections/problems/solutions) | `scaffold-exercises` |
| Configurar hooks de pre-commit (Husky + lint-staged + type check) | `setup-pre-commit` |

## Delegação para subagentes especializados

Ao receber uma tarefa de **implementação ou revisão**, delegue para o subagente especializado via `Agent(subagent_type: "nome")` antes de executar diretamente. O subagente recebe o contexto do harness (AGENTS.md, STACK.md) como briefing — inclua-o no prompt.

| Tipo de tarefa | Subagente |
| --- | --- |
| Implementar código backend Django/DRF | `django-developer` |
| Implementar código backend FastAPI | `fastapi-developer` |
| Implementar código frontend React/Next.js/TypeScript | `frontend-developer` |
| TypeScript puro (sem framework específico) | `typescript-pro` |
| Revisar diff / PR (code review) | `code-reviewer` |
| Auditoria de segurança | `security-auditor` |
| Escrever ou atualizar testes | `test-automator` |
| Decisão ou revisão de arquitetura | `architect-reviewer` |
| Documentação técnica | `technical-writer` |
| Infra, CI/CD, SRE | `sre-engineer` |

**Quando NÃO delegar:** tarefas de uma linha, lookups, leitura de arquivo, perguntas sobre o harness, workflow (branch/commit/PR/issue) — essas ficam no agente principal.

**Os subagentes são instalados por `setup.sh`** (step 4) a partir de `MatheusSlvRibeiro/awesome-claude-code-subagents`. Se um subagente não for encontrado, execute a tarefa diretamente e avise o dev para rodar `setup.sh` novamente.

## Contratos adicionais (todas as sessões)

- **Branch naming**: slug descritivo em kebab-case. **NUNCA** use número de issue (`feat/issue-42` é inválido).
- **Issue assign**: ao pegar qualquer issue, atribua-a ao dev imediatamente. Se o usuário não for conhecido, peça autenticação antes de continuar.
- **Merge em develop**: PRs `feat/* → develop` podem ser mergeados pelo próprio dev após testar e aprovar — sem necessidade de senior. PRs `develop → main` exigem aprovação de senior.
- **Merge em main pelo Matheus**: Matheus tem permissão de mergear `develop → main` diretamente quando pedir — sem aguardar processo de release formal.
- **Testes frontend**: todo componente/função deve cobrir os 3 princípios — parâmetros, ações e o que pode dar errado. Fluxos críticos exigem teste Playwright E2E.
- **Playwright**: instale por projeto (`npm install -D @playwright/test && npx playwright install --with-deps chromium`). Inclua `test:e2e` no script do `package.json`.
