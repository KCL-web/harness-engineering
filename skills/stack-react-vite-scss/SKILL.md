---
name: stack-react-vite-scss
description: Archetype frontend React 18 + Vite + TypeScript + SCSS Modules + React Hook Form + zod + BEM + path aliases. Invoque ao criar componente, form, rota, configurar alias, escrever teste, ou ao iniciar qualquer projeto que usa esta stack.
---

# Stack: React + Vite + SCSS

Archetype para projetos **React 18 + Vite + TypeScript + SCSS Modules**.
Formulários: **React Hook Form (RHF) + zod**. Convenção de CSS: **BEM dentro de SCSS Modules**.

Este arquivo é o índice da skill. Leia só o arquivo do tópico que a tarefa atual precisa — não carregue todos de uma vez.

## Quando ler cada arquivo

| Tarefa | Arquivo |
| --- | --- |
| Decidir onde colocar componente/schema/tipo/mock, layout de `src/` | [structure.md](structure.md) |
| Criar componente, aplicar BEM em SCSS Modules | [components.md](components.md) |
| Configurar path alias (`@/`), SCSS global (variáveis/mixins), variáveis de ambiente `VITE_*` | [config.md](config.md) |
| Criar ou validar formulário com React Hook Form + zod | [forms.md](forms.md) |
| Dúvida sobre `any`, tipagem de resposta de API, non-null assertion | [type-safety.md](type-safety.md) |
| Escrever teste unitário/componente (Vitest + Testing Library) | [testing-unit.md](testing-unit.md) |
| Escrever teste E2E de fluxo crítico (Playwright) | [testing-e2e.md](testing-e2e.md) |

## Regras inegociáveis

- Sem `any`. Sem inline styles. Sem import de CSS global dentro de componente.
- `@/` em vez de paths relativos com `../../`.
- Schema zod para todo input externo (forms, resposta de API, params de URL).
- Toda função em `src/lib/` tem teste correspondente.
- Componente sobe para `src/components/` só quando há 2+ usos reais.
- Export nomeado para componentes não-page (facilita tree-shaking e grep).

## Skills relacionadas

- Fluxo de issue, branch e PR: `workflow-branching`, `workflow-prs`, `workflow-issues`
- Feature list e baseline: `ratchet-feature-list`
- Backend: `stack-django-drf-jwt`
