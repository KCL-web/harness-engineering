# Bootstrap do projeto

Como preencher os arquivos do harness específicos do projeto (SPEC, STACK, CONVENTIONS, ROADMAP — ou PRODUCT, INTEGRATION em modo umbrella) entrevistando o dev.

O prompt bruto vive em [`bootstrap-prompt.md`](./bootstrap-prompt.md) — esse arquivo é a fonte de verdade e o que o script de init alimenta o agente. Este arquivo é uma explicação legível.

---

## Quando usar isto

Uma vez por projeto, quando:

- Os templates do harness estão no repo mas ainda não preenchidos
- Você quer que o agente faça pushback em respostas vagas antes de gravar
- Você quer formalizar a documentação do projeto

Três modos de workspace são suportados:

- **single-repo** — um repo Git, projeto padrão
- **umbrella** — workspace raiz contendo múltiplos repos Git como subpastas; preenche `PRODUCT.md` e `INTEGRATION.md`
- **sub-repo** — um dos repos Git dentro de um workspace umbrella; preenche os arquivos por-repo e referencia `../PRODUCT.md`

O prompt pergunta em qual modo você está antes de começar.

---

## Como rodar

### Mais fácil — via script de init

```bash
/caminho/para/harness-engineering-template/scripts/harness-init.sh
```

O script copia os arquivos do harness, pergunta em qual modo este projeto está, e oferece para iniciar a entrevista de bootstrap automaticamente.

### Manual

Se os arquivos do harness já estão no lugar, cole o conteúdo de [`bootstrap-prompt.md`](./bootstrap-prompt.md) numa sessão do agente dentro do diretório do projeto. O agente começa a entrevista.

Para Claude Code via CLI:

```bash
claude "$(cat .gsd/bootstrap-prompt.md)"
```

---

## Como o auto-preenchimento funciona

A partir desta versão do harness, o agente do bootstrap **escreve os arquivos diretamente** com a ferramenta Write/Edit. O fluxo é:

1. **Análise inicial** (em projeto existente): o agente lê manifestos, estrutura, commits recentes e READMEs antes de fazer qualquer pergunta.
2. **Geração de drafts**: o agente cria os arquivos preenchidos com tudo o que conseguiu inferir, marcando lacunas com `> [TBD: <pergunta específica>]` e inferências com `> [inferido]`.
3. **Entrevista curta em lote**: o agente pergunta as lacunas restantes agrupadas por arquivo (não uma por vez), e atualiza cada arquivo conforme as respostas chegam.
4. **Encerramento**: ao fechar a sessão, sobram apenas TBDs que o dev pediu para deixar pra depois — todos rastreáveis com `grep -r "TBD:" .gsd/`.

Em projeto novo (sem código) o passo 1 é pulado; o agente vai direto para a entrevista em lote e escreve os arquivos conforme as respostas.

---

## Dicas

**Leve o pushback a sério.** Se o agente perguntar "para quem é isso?" e sua resposta for "desenvolvedores", ele vai perguntar de novo — esse é o ponto. A fricção é o valor. Specs escritas sem fricção geralmente estão erradas.

**Não responda "você decide" no reflexo.** Para escolhas de stack, tudo bem — o agente sugere duas opções. Para perguntas de produto ("qual o problema?"), não — só você sabe.

**Pare o agente se ele começar a inventar.** Se ele escrever uma capacidade que você não mencionou, interrompa. Em modo "projeto existente" isso importa especialmente: o agente tem muito mais contexto disponível e o risco de inferências confiantes-mas-erradas aumenta.

**TBD é permitido.** Se você genuinamente não sabe o deploy target ainda, deixe TBD e revisite depois. Melhor do que uma resposta falsa.

**Em projetos existentes, revise o sumário da Fase 0 com cuidado.** É a primeira chance de pegar interpretações erradas antes que contaminem o resto da entrevista.

**Para bootstrap em sub-repo, rode o bootstrap umbrella primeiro.** A entrevista de sub-repo lê `../PRODUCT.md` para focar o SPEC. Sem isso, o SPEC do sub-repo vai repetir contexto do produto sem necessidade.
