# AGENTS.md

Este projeto usa **Claude Code Skills** como mecanismo principal de contexto. As regras de workflow, branching, PRs, commits, project board, feature list e ratchet vivem em skills sob `~/.claude/skills/harness/` (symlink/junction para `skills/` deste repo).

**Ponto de entrada:** invoque `harness-index` no início da sessão — ele tem a tabela "para fazer X, leia skill Y".

---

## Regras universais (fora de skill)

As skills cobrem o operacional. O que sobra aqui são contratos que toda sessão precisa respeitar antes mesmo de carregar uma skill específica:

1. **Idioma.** Conteúdo (documentação, prosa, drawers de memória) em **pt-BR**. Identificadores técnicos (Conventional Commits, slugs de branch, nomes de skill, frontmatter) em **inglês**.
2. **Não escreve sozinho fora do escopo permitido.** O agente nunca edita arquivos por conta própria fora dos contextos autorizados — atualização de progresso é mostrada ao dev para colar manual. As únicas exceções são:
   - O bootstrap inicial (ver `bootstrap/prompt.md`), que tem permissão de Write/Edit em `.gsd/` e `.harness/`.
   - Comandos que o dev pediu explicitamente para executar.
3. **Validação do projeto passa antes de cada commit.** O comando único de validação está em `.gsd/STACK.md`. Tarefa sem validação verde não é tarefa pronta.
4. **Nunca pushe direto** para `main` ou `preview`. Tudo via PR de `feat/*` → `preview` → `main`. Detalhes em `workflow-branching` e `workflow-prs`.
5. **Search antes de decidir.** Antes de propor decisão arquitetural relevante, consulte memória (`memory-palace` → `mempalace_search`). Se há decisão prévia, exponha-a.

---

## Mecanismos do harness

- **Skills** (auto-carregadas via `~/.claude/skills/`) — `harness-index` lista todas e quando invocar cada uma.
- **MemPalace** (MCP) — memória *verbatim* cross-projeto. Convenção de wings/rooms/drawers e cadência em `memory-palace`.
- **OpenSpace** (MCP) — skills auto-evolutivas (FIX/DERIVED/CAPTURED). Distinção curated × evolved, promoção e regras em `evolving-skills`.
- **RTK** (CLI, hook) — filtra/comprime saída de comandos do shell antes de chegar ao contexto (60–90% menos tokens em `git`, `ls`, `pytest`, etc.). Transparente.

---

## Setup e doctor

- Setup por máquina (rodar uma vez): `./scripts/setup.sh` (Linux/macOS) ou `.\scripts\setup.ps1` (Windows). Instala junction, RTK, MemPalace, OpenSpace, e escreve `~/.claude/mcp.json`.
- Verificação: `./scripts/doctor.sh` ou `.\scripts\doctor.ps1`.
- Arquitetura completa: `docs/harness-v2/overview.md`.

---

## Documentação específica do projeto

@.gsd/STACK.md
