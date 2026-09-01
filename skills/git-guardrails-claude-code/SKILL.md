---
name: git-guardrails-claude-code
description: Configura hooks do Claude Code para bloquear comandos git perigosos (push, reset --hard, clean, branch -D, etc.) antes que sejam executados. Invoque quando o dev quiser prevenir operações git destrutivas, adicionar hooks de segurança git, ou bloquear git push/reset no Claude Code. Importada de mattpocock/skills.
---

# Setup de Guardrails de Git

> **Origem:** importada de [mattpocock/skills](https://github.com/mattpocock/skills) (`misc/git-guardrails-claude-code`), adaptada ao vocabulário deste harness.

Configura um hook `PreToolUse` que intercepta e bloqueia comandos git perigosos antes do Claude executá-los.

## O que é bloqueado

- `git push` (todas as variantes, incluindo `--force`)
- `git reset --hard`
- `git clean -f` / `git clean -fd`
- `git branch -D`
- `git checkout .` / `git restore .`

Quando bloqueado, o Claude vê uma mensagem dizendo que não tem autoridade para acessar esses comandos.

Isso é um cinto de segurança adicional, independente do Git Safety Protocol já embutido no comportamento padrão deste harness (nunca fazer force push, nunca pular hooks, etc. — ver instruções do agente). Use esta skill quando o dev quiser essa garantia reforçada por hook, em vez de depender só de o agente seguir as regras.

## Passos

### 1. Perguntar o escopo

Pergunte ao dev: instalar só **para este projeto** (`.claude/settings.json`) ou **para todos os projetos** (`~/.claude/settings.json`)?

### 2. Copiar o script do hook

O script incluso está em: [scripts/block-dangerous-git.sh](scripts/block-dangerous-git.sh)

Copie para o local de destino de acordo com o escopo:

- **Projeto**: `.claude/hooks/block-dangerous-git.sh`
- **Global**: `~/.claude/hooks/block-dangerous-git.sh`

Torne executável com `chmod +x`.

### 3. Adicionar o hook às settings

Para editar `settings.json`/`settings.local.json` deste jeito, use a skill `update-config` deste harness em vez de editar o arquivo à mão — ela já sabe mesclar hooks sem sobrescrever o resto da configuração.

Adicione ao arquivo de settings apropriado:

**Projeto** (`.claude/settings.json`):

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/block-dangerous-git.sh"
          }
        ]
      }
    ]
  }
}
```

**Global** (`~/.claude/settings.json`):

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/block-dangerous-git.sh"
          }
        ]
      }
    ]
  }
}
```

Se o arquivo de settings já existir, mescle o hook no array `hooks.PreToolUse` existente. Não sobrescreva outras configurações.

### 4. Perguntar sobre customização

Pergunte se o dev quer adicionar ou remover algum padrão da lista de bloqueio. Edite o script copiado de acordo.

### 5. Verificar

Rode um teste rápido:

```bash
echo '{"tool_input":{"command":"git push origin main"}}' | <caminho-do-script>
```

Deve sair com código 2 e imprimir uma mensagem BLOCKED no stderr.

## Skills relacionadas

- Editar `settings.json`/hooks corretamente: `update-config`
- Regras de branch/commit/PR que este guardrail reforça: `workflow-branching`, `workflow-commits`, `workflow-prs`
