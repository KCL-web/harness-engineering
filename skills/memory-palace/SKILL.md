---
name: memory-palace
description: Convenção de uso do MemPalace (memória local-first, verbatim, busca semântica) dentro do harness. Define wings/rooms/drawers, cadência (wake-up, search, mine, sweep) e o que vale guardar vs ruído. Invoque no início de qualquer sessão (para puxar contexto cross-projeto), ao tomar decisão arquitetural (para registrar), ou ao terminar sessão (para indexar).
---

# Memory Palace

O **MemPalace** é uma memória local-first com busca semântica que **não resume nem parafraseia** — guarda *verbatim*. O índice tem estrutura: **wings** (escopo top-level), **rooms** (tópicos) e **drawers** (memórias literais).

Tudo fica em `~/.mempalace/` por padrão. Nada sai da máquina sem opt-in.

## Conceitos

| Conceito | Significado |
| --- | --- |
| **Palace** | A memória inteira da máquina |
| **Wing** | Escopo top-level (um projeto, uma pessoa, um agente especialista) |
| **Room** | Tópico dentro de uma wing (`decisions/`, `lessons/`, `glossary/`) |
| **Drawer** | Memória literal — texto exato salvo, recuperado por busca semântica |

## Wings convencionadas no harness

| Wing | Conteúdo |
| --- | --- |
| `<slug-do-projeto>` | Tudo específico daquele projeto (uma wing por projeto, slug igual ao nome da pasta) |
| `harness` | Meta-decisões sobre como o dev usa o harness (workflow adotado, convenções de PR que diferem do default) |
| `stack-react-vite-scss` | Decisões cross-projeto sobre o archetype frontend (libs adotadas, padrões que evoluíram) |
| `stack-django-drf-jwt` | Idem para backend |
| `agents/<nome>` | Diários de agentes especialistas (gerenciado pelo próprio MemPalace via `mempalace_list_agents`) |

**Regra:** wing de projeto = nome da pasta do repo, em kebab-case. Não invente apelido novo.

## Rooms padrão dentro de wing de projeto

| Room | O que vai aqui |
| --- | --- |
| `decisions` | Decisões arquiteturais — *por que* escolhemos X em vez de Y |
| `lessons` | Postmortems, gotchas, bugs que custaram tempo |
| `glossary` | Termos do domínio do negócio (cliente, billing, schedule, etc.) |
| `stakeholders` | Pessoas envolvidas, preferências, contatos não-óbvios |
| `env` | Ponteiros para envs/infra (vault, dashboards) — **nunca o segredo em si** |

Rooms novos podem ser criados livremente; estes cinco são o mínimo esperado.

## Cadência

```
sessão começa            → mempalace wake-up   (carrega contexto recente)
                         → mempalace search "<dúvida específica>"
                            antes de tomar decisão arquitetural
durante o trabalho       → registrar drawer ao tomar decisão notável
                            (via MCP tool, não CLI)
sessão termina           → auto-save hooks indexam o transcript
                            (ver mempalaceofficial.com/guide/hooks)
periodicamente (dia/sem) → mempalace sweep ~/.claude/projects/
                            para recall message-level
```

## O que vira drawer (vs ruído)

Vira drawer:

- **Decisão arquitetural** com o *porquê* — "trocamos Pinia por Zustand porque o time já dominava e SSR não era requisito".
- **Postmortem** — "o webhook duplicava porque o GitHub reentrega em 10s; corrigimos com idempotency key".
- **Convenção adotada** que diverge do padrão do harness — "neste projeto usamos cookies em vez de JWT em header porque o front é same-origin".
- **Termo do domínio** com definição literal do cliente — não parafraseie.
- **Preferência do dev** que apareceu em conversa — "o Matheus prefere PR único bundleado a vários PRs pequenos em refactors locais".

**Não** vira drawer:

- O que está no código (a fonte é a fonte).
- O que está em `.gsd/` (specs, roadmap, convenções).
- Histórico de git (já é histórico).
- Solução passo-a-passo de bug já fixado (o diff e o commit message bastam).
- Comentários ephemeral de uma sessão ("rodei o teste, passou").

Regra de bolso: se um futuro você não vai ganhar nada relendo isso em outro projeto, **não guarde**.

## Search antes de decidir

Antes de propor stack, padrão de pasta, lib de form, etc., **busque o que já foi decidido**:

```bash
mempalace search "form library escolhida" --wing stack-react-vite-scss
mempalace search "auth flow django" --wing stack-django-drf-jwt
mempalace search "preferência de PR" --wing harness
```

Se houver decisão prévia conflitante com a sugestão atual, **mostre a tensão** ao dev — não silencie a memória nem ignore a sugestão. O dev decide se a decisão antiga ainda vale.

## MCP tools

O MemPalace expõe 29 tools via MCP — leitura/escrita do palace, knowledge graph temporal, navegação cross-wing, gerência de drawers, diários de agentes.

Lista completa: `mempalaceofficial.com/reference/mcp-tools`.

No harness, as tools mais usadas são:

- `mempalace_search` — busca semântica
- `mempalace_add_drawer` — registrar memória verbatim
- `mempalace_wake_up` — contexto recente no início da sessão
- `mempalace_list_wings` / `mempalace_list_rooms` — descobrir estrutura existente

## Regras inegociáveis

- Nada de secret (token, password, chave de API) em drawer. Use `env` room só para **ponteiros** (ex.: "DATABASE_URL fica no 1Password vault `acme-prod`").
- Não parafraseie ao salvar — guarde o texto literal do dev, do cliente, do log. MemPalace existe exatamente para evitar a perda em LLM summarization.
- Wing de projeto = nome da pasta, sempre. Não duplique sob outro slug.
- Antes de propor decisão arquitetural, **search**. Se houver decisão prévia, exiba-a.
- Drawer não substitui `.gsd/progress/` — progresso de sprint vive em `.gsd/`, memória cross-sessão vive no palace.

## Skills relacionadas

- Índice geral e quando invocar cada skill: `harness-index`
- Convenções de stack (decisões podem migrar pra cá quando viram regra): `stack-react-vite-scss`, `stack-django-drf-jwt`
- Acompanhamento de progresso (fica em `.gsd/`, não no palace): `harness-index`
