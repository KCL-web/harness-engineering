---
name: setup-pre-commit
description: Configura hooks de pre-commit do Husky com lint-staged (Prettier), type checking e testes no repositório atual. Invoque quando o dev quiser adicionar hooks de pre-commit, configurar Husky, configurar lint-staged, ou adicionar formatação/typecheck/testes no momento do commit. Importada de mattpocock/skills.
---

# Setup de Hooks de Pre-Commit

> **Origem:** importada de [mattpocock/skills](https://github.com/mattpocock/skills) (`misc/setup-pre-commit`), adaptada ao vocabulário deste harness.

Esta skill é específica de projetos Node/TypeScript (Husky + npm/pnpm/yarn/bun). Antes de rodar, confira `.gsd/STACK.md` — se o projeto já tem um comando único de validação documentado lá (regra universal 3 do `AGENTS.md`: "validação do projeto passa antes de cada commit"), o hook de pre-commit criado aqui deve chamar esse mesmo comando (ou os passos equivalentes) em vez de divergir com scripts `typecheck`/`test` paralelos. Se `.gsd/STACK.md` ainda estiver com placeholder, prossiga com os passos abaixo normalmente.

## O que isto configura

- Hook de pre-commit do **Husky**
- **lint-staged** rodando Prettier em todos os arquivos staged
- Config do **Prettier** (se estiver faltando)
- Scripts de **typecheck** e **test** no hook de pre-commit

## Passos

### 1. Detectar o gerenciador de pacotes

Verifique `package-lock.json` (npm), `pnpm-lock.yaml` (pnpm), `yarn.lock` (yarn), `bun.lockb` (bun). Use o que estiver presente. Padrão para npm se não estiver claro.

### 2. Instalar dependências

Instale como devDependencies:

```
husky lint-staged prettier
```

### 3. Inicializar o Husky

```bash
npx husky init
```

Isso cria o diretório `.husky/` e adiciona `prepare: "husky"` ao `package.json`.

### 4. Criar `.husky/pre-commit`

Escreva este arquivo (sem shebang necessário no Husky v9+):

```
npx lint-staged
npm run typecheck
npm run test
```

**Adapte**: substitua `npm` pelo gerenciador de pacotes detectado. Se o repositório não tiver script `typecheck` ou `test` no `package.json`, omita essas linhas e avise o dev.

### 5. Criar `.lintstagedrc`

```json
{
  "*": "prettier --ignore-unknown --write"
}
```

### 6. Criar `.prettierrc` (se estiver faltando)

Só crie se não existir nenhuma config de Prettier. Use estes padrões:

```json
{
  "useTabs": false,
  "tabWidth": 4,
  "printWidth": 80,
  "singleQuote": false,
  "trailingComma": "es5",
  "semi": true,
  "arrowParens": "always"
}
```

### 7. Verificar

- [ ] `.husky/pre-commit` existe e é executável
- [ ] `.lintstagedrc` existe
- [ ] script `prepare` no `package.json` é `"husky"`
- [ ] config do prettier existe
- [ ] Rodar `npx lint-staged` para verificar que funciona

### 8. Commit

Adicione ao stage todos os arquivos alterados/criados e faça commit seguindo a convenção de mensagem da skill `workflow-commits` deste harness (não use uma mensagem livre como `Add pre-commit hooks (husky + lint-staged + prettier)`).

Isso vai passar pelos novos hooks de pre-commit: um bom teste de fumaça de que tudo funciona.

## Notas

- Husky v9+ não precisa de shebangs nos arquivos de hook
- `prettier --ignore-unknown` pula arquivos que o Prettier não consegue parsear (imagens, etc.)
- O pre-commit roda lint-staged primeiro (rápido, só nos arquivos staged), depois typecheck e testes completos

## Skills relacionadas

- Comando único de validação do projeto (para manter o hook em sincronia): `.gsd/STACK.md` (ver `AGENTS.md`, regra universal 3)
- Convenção de mensagem de commit: `workflow-commits`
- Disciplina de teste por trás do que o hook valida: `tdd`
