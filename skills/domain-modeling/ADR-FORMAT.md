# Formato de ADR

ADRs vivem em `docs/adr/` e usam numeração sequencial: `0001-slug.md`, `0002-slug.md`, etc.

Crie o diretório `docs/adr/` de forma preguiçosa: só quando o primeiro ADR for necessário.

## Template

```md
# {Título curto da decisão}

{1-3 frases: qual é o contexto, o que decidimos, e por quê.}
```

Só isso. Um ADR pode ser um único parágrafo. O valor está em registrar *que* uma decisão foi tomada e *por quê*, não em preencher seções.

## Seções opcionais

Inclua estas só quando agregarem valor genuíno. A maioria dos ADRs não vai precisar.

- **Status** no frontmatter (`proposed | accepted | deprecated | superseded by ADR-NNNN`): útil quando decisões são revisitadas
- **Considered Options**: só quando as alternativas rejeitadas valem a pena lembrar
- **Consequences**: só quando efeitos colaterais não óbvios precisam ser destacados

## Numeração

Procure em `docs/adr/` o maior número existente e incremente em um.

## Quando oferecer um ADR

As três condições precisam ser verdadeiras:

1. **Difícil de reverter**: o custo de mudar de ideia depois é significativo
2. **Surpreendente sem contexto**: um leitor futuro vai olhar para o código e se perguntar "por que raios fizeram assim?"
3. **Resultado de um trade-off real**: havia alternativas genuínas e você escolheu uma por motivos específicos

Se uma decisão é fácil de reverter, pule: você simplesmente vai revertê-la. Se não é surpreendente, ninguém vai se perguntar por quê. Se não havia alternativa real, não há nada a registrar além de "fizemos o óbvio".

### O que se qualifica

- **Forma arquitetural.** "Estamos usando um monorepo." "O write model é event-sourced, o read model é projetado em Postgres."
- **Padrões de integração entre contextos.** "Ordering e Billing se comunicam via domain events, não HTTP síncrono."
- **Escolhas de tecnologia que carregam lock-in.** Banco de dados, message bus, provedor de auth, alvo de deploy. Não toda biblioteca: só as que levariam um trimestre para trocar.
- **Decisões de fronteira e escopo.** "Dados de Customer são de propriedade do contexto Customer; outros contextos referenciam por ID só." Os "não" explícitos valem tanto quanto os "sim".
- **Desvios deliberados do caminho óbvio.** "Estamos usando SQL manual em vez de um ORM por causa de X." Qualquer coisa em que um leitor razoável assumiria o oposto. Isso impede o próximo engenheiro de "consertar" algo que era deliberado.
- **Restrições não visíveis no código.** "Não podemos usar AWS por causa de requisitos de compliance." "Tempos de resposta precisam ser abaixo de 200ms por causa do contrato da API do parceiro."
- **Alternativas rejeitadas quando a rejeição não é óbvia.** Se você considerou GraphQL e escolheu REST por motivos sutis, registre; senão alguém vai sugerir GraphQL de novo daqui a seis meses.
