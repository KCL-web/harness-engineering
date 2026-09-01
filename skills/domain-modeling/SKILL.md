---
name: domain-modeling
description: Constrói e afia o modelo de domínio de um projeto. Use ao discutir terminologia do codebase, escrever ou editar um CONTEXT.md, ou registrar/editar um ADR.
---

# Domain Modeling

> **Origem:** importada de [mattpocock/skills](https://github.com/mattpocock/skills) (`engineering/domain-modeling`), adaptada ao vocabulário deste harness.

`CONTEXT.md` e ADRs são conteúdo novo neste harness — não existiam antes desta importação. Esta skill constrói ativamente e afia o modelo de domínio do projeto enquanto você desenha. Esta é a disciplina *ativa*: desafiar termos, inventar cenários de edge case, e escrever o glossário e as decisões no momento em que se cristalizam. (Só *ler* o `CONTEXT.md` em busca de vocabulário não é esta skill: isso é um hábito de uma linha que qualquer skill pode fazer — como já fazem `tdd` e `diagnosing-bugs`. Esta skill é para quando você está mudando o modelo, não só consumindo.)

## Quando ler cada arquivo

| Tarefa | Arquivo |
| --- | --- |
| Formato e regras do `CONTEXT.md` (glossário, single vs. multi-context) | [CONTEXT-FORMAT.md](CONTEXT-FORMAT.md) |
| Formato e critério de quando registrar um ADR | [ADR-FORMAT.md](ADR-FORMAT.md) |

## Estrutura de arquivos

A maioria dos repositórios tem um único contexto:

```
/
├── CONTEXT.md
├── docs/
│   └── adr/
│       ├── 0001-event-sourced-orders.md
│       └── 0002-postgres-for-write-model.md
└── src/
```

Se existir um `CONTEXT-MAP.md` na raiz, o repositório tem múltiplos contextos. O mapa aponta para onde cada um vive:

```
/
├── CONTEXT-MAP.md
├── docs/
│   └── adr/                          ← decisões de todo o sistema
├── src/
│   ├── ordering/
│   │   ├── CONTEXT.md
│   │   └── docs/adr/                 ← decisões específicas do contexto
│   └── billing/
│       ├── CONTEXT.md
│       └── docs/adr/
```

Crie os arquivos de forma preguiçosa: só quando tiver algo para escrever. Se nenhum `CONTEXT.md` existe, crie um quando o primeiro termo for resolvido. Se nenhum `docs/adr/` existe, crie-o quando o primeiro ADR for necessário.

## Durante a sessão

### Desafie contra o glossário

Quando o usuário usa um termo que conflita com a linguagem já existente no `CONTEXT.md`, aponte isso na hora. "Seu glossário define 'cancelamento' como X, mas parece que você quer dizer Y. Qual dos dois é?"

### Afie linguagem vaga

Quando o usuário usa termos vagos ou sobrecarregados, proponha um termo canônico preciso. "Você está dizendo 'conta': quer dizer o Customer ou o User? São coisas diferentes."

### Discuta cenários concretos

Quando relações de domínio estão sendo discutidas, teste-as sob estresse com cenários específicos. Invente cenários que sondem edge cases e forcem o usuário a ser preciso sobre as fronteiras entre conceitos.

### Cruze com o código

Quando o usuário declara como algo funciona, verifique se o código concorda. Se você encontrar uma contradição, exponha-a: "Seu código cancela Orders inteiras, mas você acabou de dizer que cancelamento parcial é possível. Qual dos dois está certo?"

### Atualize o CONTEXT.md inline

Quando um termo é resolvido, atualize o `CONTEXT.md` ali mesmo. Não acumule isso para depois: capture no momento em que acontece. Use o formato em [CONTEXT-FORMAT.md](CONTEXT-FORMAT.md).

`CONTEXT.md` deve estar totalmente livre de detalhes de implementação. Não trate `CONTEXT.md` como uma spec, um rascunho, ou um repositório de decisões de implementação — isso já tem lugar próprio neste harness (`.gsd/SPEC.md`, ADRs). É um glossário e nada mais.

### Ofereça ADRs com moderação

Só ofereça criar um ADR quando as três condições forem verdadeiras:

1. **Difícil de reverter**: o custo de mudar de ideia depois é significativo
2. **Surpreendente sem contexto**: um leitor futuro vai se perguntar "por que fizeram assim?"
3. **Resultado de um trade-off real**: havia alternativas genuínas e você escolheu uma por motivos específicos

Se qualquer uma das três estiver ausente, pule o ADR. Use o formato em [ADR-FORMAT.md](ADR-FORMAT.md).

## Skills relacionadas

- Vocabulário de módulo/interface/seam: `codebase-design`
- Loop TDD que lê `CONTEXT.md` para nomear testes e interfaces: `tdd`
- Diagnóstico de bugs que lê `CONTEXT.md`/ADRs ao explorar: `diagnosing-bugs`
- Entrevista que conduz esta disciplina ativamente: `grill-with-docs`
