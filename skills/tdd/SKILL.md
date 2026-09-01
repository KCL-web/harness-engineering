---
name: tdd
description: Test-driven development (red-green-refactor). Invoque quando o dev quer construir feature ou corrigir bug test-first, menciona "red-green-refactor", ou quer testes de integração. Referência agnóstica de stack — importada de mattpocock/skills.
---

# TDD (Test-Driven Development)

> **Origem:** importada de [mattpocock/skills](https://github.com/mattpocock/skills) (`engineering/tdd`), adaptada ao vocabulário deste harness.

TDD é o loop red → green. Esta skill é a referência que faz esse loop produzir testes que valem a pena manter: o que é um bom teste, onde os testes ficam, os anti-padrões e as regras do loop. Toda seção se aplica em todo ciclo: consulte antes e durante o loop, não depois.

Ao explorar o código, leia `CONTEXT.md` (se existir — ver skill `domain-modeling`) para que nomes de teste e vocabulário de interface batam com a linguagem de domínio do projeto, e respeite os ADRs da área que está tocando.

Para mecânica específica de stack (pytest-django + factory_boy, ou Vitest/Playwright), veja `stack-django-drf-jwt` → `testing.md` e `stack-react-vite-scss` → `testing-unit.md`/`testing-e2e.md`. Esta skill é a disciplina agnóstica de stack por trás desses arquivos.

## Quando ler cada arquivo

| Tarefa | Arquivo |
| --- | --- |
| Ver exemplos de teste bom vs. ruim (integration-style, implementation-detail, tautológico) | [tests.md](tests.md) |
| Decidir o que mockar e como projetar para mockabilidade | [mocking.md](mocking.md) |

## O que é um bom teste

Testes verificam comportamento através de interfaces públicas, não detalhes de implementação. O código pode mudar inteiramente; os testes não deveriam. Um bom teste lê como uma especificação: "usuário consegue finalizar compra com carrinho válido" diz exatamente qual capacidade existe, e sobrevive a refatorações porque não se importa com estrutura interna.

Veja [tests.md](tests.md) para exemplos e [mocking.md](mocking.md) para diretrizes de mock.

## Seams: onde os testes ficam

Um **seam** é o limite público onde você testa: a interface onde se observa comportamento sem entrar por dentro. Testes vivem em seams, nunca contra internals.

**Teste só em seams pré-acordados.** Antes de escrever qualquer teste, escreva os seams sob teste e confirme com o dev. Nenhum teste é escrito num seam não confirmado. Não dá para testar tudo, então acordar os seams de antemão é como o esforço de teste cai nos caminhos críticos e na lógica complexa em vez de em cada edge case.

Pergunte: "Qual é a interface pública, e quais seams devemos testar?"

Quando a forma dessa interface está em questão (quão profundo é o módulo, onde fica o seam, o que a interface deve expor), invoque a skill `codebase-design` para o vocabulário. Ela é a fonte compartilhada dos termos módulo, interface, profundidade, seam, adapter, leverage e localidade — é referência a consultar, não uma sessão a rodar.

## Anti-padrões

- **Acoplado à implementação**: mocka colaboradores internos, testa métodos privados, ou verifica por canal lateral (consultar o banco direto em vez de usar a interface). O sinal: o teste quebra quando você refatora mas o comportamento não mudou.
- **Tautológico**: a asserção recalcula o valor esperado do mesmo jeito que o código calcula (`expect(add(a, b)).toBe(a + b)`, um snapshot derivado à mão da mesma forma, uma constante comparada a si mesma), então passa por construção e nunca pode discordar do código. Valores esperados precisam vir de uma fonte de verdade independente: um literal conhecido, um exemplo trabalhado, o spec.
- **Fatiamento horizontal**: escrever todos os testes primeiro, depois toda a implementação. Testes em lote verificam comportamento _imaginado_: você testa a _forma_ das coisas em vez do comportamento visível ao usuário, os testes ficam insensíveis a mudanças reais, e você se compromete com a estrutura de teste antes de entender a implementação. Trabalhe em **fatias verticais**: um teste → uma implementação → repita, cada teste sendo uma **tracer bullet** que responde ao que o último ciclo ensinou.

## Regras do loop

- **Red antes do green.** Escreva o teste que falha primeiro, depois só o código suficiente para passá-lo. Não antecipe testes futuros nem adicione features especulativas.
- **Uma fatia por vez.** Um seam, um teste, uma implementação mínima por ciclo.
- **Refatoração não faz parte do loop.** Ela pertence à etapa de revisão (skill `code-review`), não ao ciclo de implementação red → green.

## Skills relacionadas

- Vocabulário de design de módulo/interface/seam: `codebase-design`
- Vocabulário de domínio e `CONTEXT.md`: `domain-modeling`
- Revisão de código pós-implementação: `code-review`
- Mecânica de teste por stack: `stack-django-drf-jwt`, `stack-react-vite-scss`
