---
name: diagnosing-bugs
description: Loop de diagnóstico para bugs difíceis e regressões de performance. Use quando o usuário disser "diagnostica"/"debuga isso", ou reportar algo quebrado/lançando erro/falhando/lento.
---

# Diagnosing Bugs

> **Origem:** importada de [mattpocock/skills](https://github.com/mattpocock/skills) (`engineering/diagnosing-bugs`), adaptada ao vocabulário deste harness.

Uma disciplina para bugs difíceis. Pule fases só quando houver justificativa explícita.

Ao explorar o codebase, leia `CONTEXT.md` (se existir — ver skill `domain-modeling`) para ter um modelo mental claro dos módulos relevantes, e cheque os ADRs da área que está tocando.

Um loop de reprodução manual (passo 10 abaixo) usa o script em [scripts/hitl-loop.template.sh](scripts/hitl-loop.template.sh).

## Redija com cuidado (redact)

Esta skill faz você mostrar comandos, saídas e artefatos capturados. **Redacte todo segredo primeiro**: escreva `<REDACTED>` no lugar. Construa loops contra env vars, para que a credencial fique no ambiente em vez de aparecer no que você mostra. Artefatos capturados carregam headers de auth: cite só as linhas que carregam o sinal.

Se a saída redigida não for suficiente para diagnosticar o bug, diga isso e pergunte ao usuário.

## Fase 1: Construa um loop de feedback

**Esta é a skill.** Todo o resto é mecânico. Se você tem um sinal pass/fail **apertado** para o bug (um que fica red *neste* bug específico), você vai achar a causa; bisseção, teste de hipóteses e instrumentação só consomem esse sinal. Se você não tem um, nenhuma quantidade de olhar para o código vai te salvar.

Gaste esforço desproporcional aqui. **Seja agressivo. Seja criativo. Recuse-se a desistir.**

### Formas de construir um, mais ou menos nesta ordem

1. **Teste que falha** no seam que alcança o bug: unit, integração, e2e.
2. **Script curl/HTTP** contra um servidor de dev rodando.
3. **Invocação de CLI** com um input de fixture, comparando o stdout contra um snapshot conhecido-bom.
4. **Script de browser headless** (Playwright/Puppeteer) que dirige a UI e afirma sobre DOM/console/rede.
5. **Reproduza um trace capturado.** Salve um request/payload/log de evento real em disco; reproduza através do caminho de código em isolamento.
6. **Harness descartável.** Suba um subconjunto mínimo do sistema (um serviço, deps mockadas) que exercite o caminho de código do bug com uma única chamada de função.
7. **Loop de property/fuzz.** Se o bug é "às vezes a saída está errada", rode 1000 inputs aleatórios e procure o modo de falha.
8. **Harness de bisseção.** Se o bug apareceu entre dois estados conhecidos (commit, dataset, versão), automatize "sobe no estado X, checa, repete" para rodar com `git bisect run`.
9. **Loop diferencial.** Rode o mesmo input pela versão antiga vs. nova (ou duas configs) e compare as saídas.
10. **Script HITL (humano no loop).** Último recurso. Se um humano precisa clicar, dirija-o com [scripts/hitl-loop.template.sh](scripts/hitl-loop.template.sh) para que o loop continue estruturado. A saída capturada volta para você.

Construa o loop de feedback certo, e o bug está 90% corrigido.

### Aperte o loop

Trate o loop como um produto. Uma vez que você tem *um* loop, **aperte-o**:

- Dá pra deixar mais rápido? (Cache no setup, pula init irrelevante, estreita o escopo do teste.)
- Dá pra deixar o sinal mais nítido? (Afirme sobre o sintoma específico, não "não travou".)
- Dá pra deixar mais determinístico? (Fixa o tempo, semeia o RNG, isola o filesystem, congela a rede.)

Um loop flaky de 30 segundos é pouco melhor que nenhum loop; um determinístico de 2 segundos é apertado, um superpoder de debug.

### Bugs não determinísticos

O objetivo não é uma reprodução limpa, mas uma **taxa de reprodução mais alta**. Repita o gatilho 100×, paralelize, adicione stress, estreite janelas de timing, injete sleeps. Um bug com 50% de flake é debugável; 1% não é, então continue elevando a taxa até ficar debugável.

### Quando você genuinamente não consegue construir um loop

Pare e diga isso explicitamente. Liste o que tentou. Peça ao usuário: (a) acesso a qualquer ambiente que reproduza o bug, (b) um artefato capturado redigido (arquivo HAR, dump de log, core dump, gravação de tela com timestamps), ou (c) permissão para adicionar instrumentação temporária em produção. **Não** prossiga para hipotetizar sem um loop.

### Critério de conclusão: um loop apertado que fica red

A Fase 1 termina quando o loop é **apertado** e **capaz de ficar red**: você consegue nomear **um comando** (um caminho de script, uma invocação de teste, um curl) que você **já rodou pelo menos uma vez** (mostre a invocação e sua saída, redigida), e que é:

- [ ] **Capaz de ficar red**: dirige o caminho de código real do bug e afirma sobre o **sintoma exato do usuário**, então consegue ficar red neste bug e green quando corrigido. Não "roda sem dar erro"; precisa conseguir _capturar este bug específico_.
- [ ] **Determinístico**: mesmo veredito a cada execução (bugs flaky: uma taxa de reprodução fixada e alta, conforme acima).
- [ ] **Rápido**: segundos, não minutos.
- [ ] **Executável por agente**: você consegue rodar sem supervisão; um humano no loop só via [scripts/hitl-loop.template.sh](scripts/hitl-loop.template.sh).

Se você se pegar lendo código para construir uma teoria antes desse comando existir, **pare: pular direto para uma hipótese é exatamente a falha que esta skill previne.** Sem comando capaz de ficar red, sem Fase 2.

## Fase 2: Reproduza + minimize

Rode o loop. Observe ele ficar red conforme o bug aparece.

Confirme:

- [ ] O loop produz o modo de falha que o **usuário** descreveu, não uma falha diferente que por acaso está por perto. Bug errado = correção errada.
- [ ] A falha é reproduzível em múltiplas execuções (ou, para bugs não determinísticos, reproduzível numa taxa alta o suficiente para debugar).
- [ ] Você capturou o sintoma exato (mensagem de erro, saída errada, timing lento) para que fases posteriores possam verificar que a correção realmente resolveu.

### Minimize

Uma vez red, encolha a reprodução para o **menor cenário que ainda fica red**. Corte inputs, chamadores, config, dados e passos **um de cada vez**, rerodando o loop após cada corte, e mantenha só o que é load-bearing para a falha.

Por que se importar: uma reprodução mínima encolhe o espaço de hipóteses na Fase 3 (menos peças móveis para suspeitar) e vira o teste de regressão limpo na Fase 5.

Terminado quando **todo elemento restante é load-bearing**: remover qualquer um deles faz o loop ficar green.

Não prossiga até ter reproduzido **e** minimizado.

## Fase 3: Hipotetize

Gere **3–5 hipóteses ranqueadas** antes de testar qualquer uma delas. Gerar uma única hipótese ancora na primeira ideia plausível.

Cada hipótese precisa ser **falseável**: declare a predição que ela faz.

> Formato: "Se <X> é a causa, então <mudar Y> vai fazer o bug desaparecer / <mudar Z> vai piorá-lo."

Se você não consegue declarar a predição, a hipótese é um chute: descarte ou refine.

**Mostre a lista ranqueada ao usuário antes de testar.** Ele frequentemente tem conhecimento de domínio que reordena instantaneamente ("acabamos de fazer deploy de uma mudança na #3"), ou conhece hipóteses que já descartou. Checkpoint barato, grande economia de tempo. Não bloqueie nisso; prossiga com seu ranking se o usuário estiver ausente.

## Fase 4: Instrumente

Cada sonda precisa mapear para uma predição específica da Fase 3. **Mude uma variável de cada vez.**

Preferência de ferramenta:

1. **Inspeção com debugger/REPL** se o ambiente suportar. Um breakpoint vale mais que dez logs.
2. **Logs direcionados** nas fronteiras que distinguem hipóteses.
3. Nunca "loga tudo e faz grep".

**Marque todo log de debug** com um prefixo único, ex.: `[DEBUG-a4f2]`. A limpeza no final vira um único grep. Logs sem marca sobrevivem; logs marcados morrem.

**Ramo de performance.** Para regressões de performance, logs geralmente estão errados. Em vez disso: estabeleça uma medição de baseline (harness de timing, `performance.now()`, profiler, plano de query), depois bissecione. Meça primeiro, corrija depois.

## Fase 5: Corrija + teste de regressão

Escreva o teste de regressão **antes da correção**, mas só se houver um **seam correto** para ele.

Um seam correto é aquele em que o teste exercita o **padrão real do bug** como ele ocorre no ponto de chamada. Se o único seam disponível é raso demais (teste de chamador único quando o bug precisa de múltiplos chamadores, teste unitário que não consegue replicar a cadeia que disparou o bug), um teste de regressão ali dá falsa confiança.

**Se nenhum seam correto existe, isso em si é o achado.** Anote. A arquitetura do codebase está impedindo o bug de ser travado. Sinalize isso para a próxima fase.

Se existe um seam correto:

1. Transforme a reprodução minimizada num teste que falha nesse seam.
2. Observe ele falhar.
3. Aplique a correção.
4. Observe ele passar.
5. Rerode o loop de feedback da Fase 1 contra o cenário original (não minimizado).

## Fase 6: Limpeza

Obrigatório antes de declarar concluído:

- [ ] A reprodução original não reproduz mais (rerode o loop da Fase 1)
- [ ] O teste de regressão passa (ou a ausência de seam está documentada)
- [ ] Toda instrumentação `[DEBUG-...]` foi removida (`grep` do prefixo)
- [ ] Protótipos descartáveis foram deletados (ou movidos para um local de debug claramente marcado)
- [ ] A hipótese que se confirmou correta está declarada na mensagem de commit/PR, para que o próximo debugger aprenda

## Skills relacionadas

- Mensagem de commit e `Closes #N` da correção: `workflow-commits`, `workflow-prs`
- Loop TDD (o teste de regressão da Fase 5 usa a mesma disciplina): `tdd`
- Vocabulário de domínio e ADRs consultados na exploração: `domain-modeling`
