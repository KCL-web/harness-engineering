# Formato do Learning Record

Learning records vivem em `./learning-records/` e usam numeração sequencial: `0001-slug.md`, `0002-slug.md`, etc. Crie o diretório de forma preguiçosa: só quando o primeiro registro for escrito.

São o equivalente, no ensino, dos ADRs no desenvolvimento de software: capturam lições não óbvias, insights-chave e conhecimento prévio declarado que vão direcionar sessões futuras. São usados para calcular a zona de desenvolvimento proximal.

## Template

```md
# {Título curto do que foi aprendido ou estabelecido}

{1-3 frases: o que foi aprendido (ou que conhecimento prévio foi estabelecido), e por que isso importa para sessões futuras.}
```

Esse é o formato inteiro. Um learning record pode ser um único parágrafo. O valor está em registrar _que_ isso agora é conhecido e _por que_ isso muda o que ensinar a seguir, não em preencher seções.

## Seções opcionais

Inclua estas seções só quando agregam valor genuíno. A maioria dos registros não vai precisar delas.

- **Status** no frontmatter (`active | superseded by LR-NNNN`): útil quando um entendimento anterior se revela errado e é substituído.
- **Evidence** (evidência): como o dev demonstrou o entendimento (uma pergunta respondida, um exercício completado, experiência prévia citada). Útil quando a afirmação pode ser revisitada.
- **Implications** (implicações): o que isso destrava ou descarta para sessões futuras. Vale registrar quando não é óbvio.

## Numeração

Escaneie `./learning-records/` pelo maior número existente e incremente em um.

## Quando escrever um learning record

Escreva um quando qualquer um destes for verdade:

1. **O dev demonstrou entendimento genuíno de algo não trivial**: não só exposição, mas evidência de que consegue usar o conceito corretamente. Isso define um novo piso para o que ensinar a seguir.
2. **O dev revelou conhecimento prévio**: "eu já sei X". Registre para que sessões futuras não reensinem isso. Registre também a _profundidade_ alegada.
3. **Uma concepção equivocada foi corrigida**: o dev acreditava antes em algo errado e agora entende por quê. São de alto valor: preveem futuros tropeços em tópicos relacionados.
4. **A missão mudou em resposta ao aprendizado**: o dev descobriu que se importava com algo diferente do que pensava. Faça referência cruzada com [[MISSION.md]] e atualize-o.

### O que _não_ qualifica

- Material que foi só coberto. Cobertura não é aprendizado. Espere a evidência.
- Qualquer coisa já capturada de forma enxuta em [[GLOSSARY.md]] como definição de termo. Não duplique.
- Logs de atividade sessão a sessão. Learning records não são um diário: são insights com qualidade de decisão.

## Supersessão

Quando um registro posterior contradiz um anterior (o entendimento do dev se aprofundou ou foi corrigido), marque o registro antigo como `Status: superseded by LR-NNNN` em vez de apagá-lo. O histórico de como o entendimento evoluiu já é, por si só, um sinal útil.
