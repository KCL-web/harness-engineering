# Prompts de início de sessão

Copie e cole o bloco apropriado abaixo no início de toda sessão do agente.

Estes prompts são agnósticos de projeto. Eles referenciam arquivos (`AGENTS.md`, `.gsd/STACK.md`, `.gsd/CONVENTIONS.md`, `.gsd/SPEC.md`, `.gsd/ROADMAP.md`, `.gsd/progress/<MID>-<SID>.md`) que precisam existir no repo — o que muda por projeto é o conteúdo, não os prompts.

Se este repo é sub-repo de um workspace umbrella, os arquivos `../PRODUCT.md` e `../INTEGRATION.md` também são contexto relevante — leia-os quando a tarefa tocar em assuntos cross-repo.

**Sincronia automática ROADMAP → GitHub:** os blocos abaixo incluem um passo onde o agente compara o ROADMAP com o estado atual do GitHub (Project, milestones, issues) e cria o que estiver faltando. O procedimento exato vive em `AGENTS.md` → seção **"Sincronia: como criar Project/Milestones/Issues"**. O agente nunca apaga ou fecha issues existentes — só cria as faltantes.

---

## Claude.ai (chat web)

Use no claude.ai, onde `AGENTS.md` não é carregado automaticamente.

```
Antes de fazer qualquer coisa, leia estes arquivos nesta ordem:

1. AGENTS.md
2. .gsd/STACK.md
3. .gsd/CONVENTIONS.md
4. .gsd/SPEC.md
5. .gsd/ROADMAP.md
6. .gsd/progress/<MID>-<SID>.md   ← substitua pelo sprint atual, ex.: M01-S02

Depois de ler, confirme em texto:

- Qual é este projeto e o que ele faz
- Em que milestone e sprint estamos
- Quais tarefas estão pendentes neste sprint
- O que diz o contrato

Em seguida, rode a SINCRONIA ROADMAP → GitHub seguindo o procedimento em
AGENTS.md → "Sincronia: como criar Project/Milestones/Issues":

- gh auth status para confirmar acesso (se faltar scope project, pare e me avise)
- Liste o que falta criar (milestones, issues por task identificadas por
  Task: <MID>-<SID>-<TID>) e mostre o resumo antes de criar
- Espere meu "ok"
- Depois do ok: crie Project (se não existir), milestones faltantes e issues
  faltantes. Issues entram em status Backlog, linkadas à milestone, com o
  marcador Task: na primeira linha do body
- Mostre no fim o sumário (criados vs já existentes)

Não modifique nem feche issues que já existem. Não crie branch. Espere
minha instrução antes de escrever qualquer código.
```

---

## Claude Code (extensão VS Code ou CLI)

Use no Claude Code, onde `AGENTS.md` (e `.gsd/STACK.md` + `.gsd/CONVENTIONS.md` via cascade) já é carregado automaticamente.

```
Leia estes arquivos antes de começar:

1. .gsd/SPEC.md
2. .gsd/ROADMAP.md
3. .gsd/progress/<MID>-<SID>.md   ← substitua pelo sprint atual, ex.: M01-S02

Confirme o sprint atual e as tarefas pendentes em texto.

Em seguida, rode a SINCRONIA ROADMAP → GitHub conforme AGENTS.md → "Sincronia:
como criar Project/Milestones/Issues":

- Liste o que vai criar (milestones faltantes, issues por task identificadas
  pelo marcador Task: <MID>-<SID>-<TID>) e espere meu "ok"
- Depois do ok: crie no Backlog, com milestone linkada e marcador Task: no body
- Mostre o sumário

Não modifique issues existentes. Espere minha instrução antes de escrever código.
```

---

## Pulando a sincronia

Se você quer só uma sessão rápida de leitura/discussão sem sincronizar (ex.: revisar arquitetura, debugar uma dúvida sem mexer no board), adicione esta linha ao final do prompt:

```
PULE a sincronia ROADMAP → GitHub nesta sessão.
```

---

## Iniciando uma tarefa

Depois que o agente confirmar o sprint, use isto para começar uma tarefa específica:

```
Comece <TAREFA>. Siga o protocolo de aprendizagem:

- Liste edge cases considerados
- Não commita nada
```

Exemplo:

```
Comece T01 de M01-S02. Siga o protocolo de aprendizagem:

- Liste edge cases considerados
- Não commita nada
```

---

## Fechando a sessão

Use isto no fim de toda sessão para atualizar o progresso do sprint:

```
A sessão está terminando. Atualize .gsd/progress/<MID>-<SID>.md:

- Marque as tarefas concluídas no contrato
- Adicione ao build log o que foi feito hoje (uma linha por tarefa, formato: - YYYY-MM-DD: <o que foi feito>)
- Documente bloqueios se uma tarefa não foi concluída
- Não marque nada como pronto se o comando de validação do projeto (ver `.gsd/STACK.md`) não passou

Mostre o conteúdo completo do arquivo atualizado para eu colar.
```

---

## Sessão de QA

Use isto ao iniciar uma sessão de QA depois do build estar completo:

```
Antes de fazer qualquer coisa, leia:

1. AGENTS.md
2. .gsd/STACK.md
3. .gsd/CONVENTIONS.md
4. .gsd/progress/<MID>-<SID>.md
5. .harness/feature_list.json
6. .harness/baseline.json

Você é o agente de QA. Seu trabalho é verificar os itens do contrato um a um
contra a aplicação rodando — não contra o que a sessão de dev alegou.

Para cada feature ligada ao sprint atual ou à issue:

- Leia os `criteria[]` literalmente do feature_list.json. NÃO parafraseie.
- Rode cada critério contra a app viva (chamada HTTP, navegação no browser,
  invocação CLI — o que o critério descrever).
- Se todos passam, vire `verified: true` no feature_list.json.
- Se algum falha, mantenha `verified: false` e escreva o que falhou em `notes`.

Então:

- Rode o comando de validação do projeto (ver `.gsd/STACK.md`) e confirme
  que ainda passa com zero erros.
- Remensure cada métrica em baseline.json. Se alguma regrediu, sinalize —
  não atualize o arquivo silenciosamente.

Atualize o checklist da issue e `.gsd/progress/<MID>-<SID>.md` para refletir
o que passou e o que não passou.

Não implemente nada. Só verifique.

Mostre o feature_list.json, baseline.json e arquivo de progresso atualizados
quando terminar.
```
