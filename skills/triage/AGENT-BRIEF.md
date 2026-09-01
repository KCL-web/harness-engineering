# Escrevendo Agent Briefs

Um agent brief é um comentário estruturado postado numa issue ou PR do Forgejo quando ela entra em `triage/ready-for-agent`. É a especificação autoritativa a partir da qual um agente AFK vai trabalhar. O body original e a discussão são contexto: o agent brief é o contrato.

O brief declara **o que o agente deve fazer**, o que se estende às duas superfícies: para uma issue, isso é construir a mudança do zero; para uma PR, é o que falta *no diff já existente*: terminar, fechar lacunas, endereçar pontos de review. Os mesmos princípios valem para as duas; o exemplo de PR abaixo mostra a diferença.

## Princípios

### Durabilidade acima de precisão

A issue pode ficar em `triage/ready-for-agent` por dias ou semanas. O código vai mudar nesse meio-tempo. Escreva o brief para que continue útil mesmo com arquivos renomeados, movidos ou refatorados.

- **Faça** descreva interfaces, tipos e contratos de comportamento
- **Faça** nomeie tipos específicos, assinaturas de função, ou formatos de config que o agente deve procurar ou modificar
- **Não faça** referencie caminhos de arquivo: eles ficam desatualizados
- **Não faça** referencie números de linha
- **Não faça** assuma que a estrutura de implementação atual vai continuar a mesma

### Comportamental, não procedural

Descreva **o quê** o sistema deve fazer, não **como** implementar. O agente vai explorar o código do zero e tomar suas próprias decisões de implementação.

- **Bom:** "O tipo `SkillConfig` deve aceitar um campo opcional `schedule` do tipo `CronExpression`"
- **Ruim:** "Abra src/types/skill.ts e adicione um campo schedule na linha 42"
- **Bom:** "Quando um usuário roda `/triage` sem argumentos, deve ver um resumo das issues que precisam de atenção"
- **Ruim:** "Adicione um switch statement na função handler principal"

### Critérios de aceitação completos

O agente precisa saber quando terminou. Todo agent brief precisa ter critérios de aceitação concretos e testáveis. Cada critério deve ser verificável de forma independente.

- **Bom:** "Rodar a consulta de issues com o label `needs-triage` retorna issues que passaram pela classificação inicial"
- **Ruim:** "A triagem deve funcionar corretamente"

### Limites de escopo explícitos

Declare o que está fora de escopo. Isso evita que o agente faça gold-plating ou presuma coisas sobre features adjacentes.

## Template

```markdown
## Agent Brief

**Category:** bug / enhancement
**Summary:** descrição de uma linha do que precisa acontecer

**Current behavior:**
Descreva o que acontece hoje. Para bugs, é o comportamento quebrado.
Para enhancements, é o status quo sobre o qual a feature se constrói.

**Desired behavior:**
Descreva o que deve acontecer depois que o trabalho do agente estiver completo.
Seja específico sobre edge cases e condições de erro.

**Key interfaces:**
- `NomeDoTipo`: o que precisa mudar e por quê
- Tipo de retorno de `nomeDaFuncao()`: o que retorna hoje vs. o que deveria retornar
- Formato de config: quaisquer novas opções de configuração necessárias

**Acceptance criteria:**
- [ ] Critério específico e testável 1
- [ ] Critério específico e testável 2
- [ ] Critério específico e testável 3

**Out of scope:**
- Coisa que NÃO deve ser mudada ou endereçada nesta issue
- Feature adjacente que pode parecer relacionada mas é separada
```

## Exemplos

### Bom agent brief (bug)

```markdown
## Agent Brief

**Category:** bug
**Summary:** Truncamento da descrição de skill corta no meio da palavra, produzindo saída quebrada

**Current behavior:**
Quando a descrição de uma skill excede 1024 caracteres, ela é truncada em
exatamente 1024 caracteres, sem respeitar limites de palavra. Isso produz
descrições que terminam no meio de uma palavra (ex.: "Use quando o usuário
quiser confi").

**Desired behavior:**
O truncamento deve quebrar no último limite de palavra antes de 1024
caracteres e anexar "..." para indicar o corte.

**Key interfaces:**
- O campo `description` do tipo `SkillMetadata`: não precisa mudar de tipo,
  mas a lógica de validação/processamento que o preenche precisa respeitar
  limites de palavra
- Qualquer função que lê o frontmatter do SKILL.md e extrai a description

**Acceptance criteria:**
- [ ] Descrições com menos de 1024 caracteres ficam inalteradas
- [ ] Descrições com mais de 1024 caracteres são truncadas no último limite
      de palavra antes de 1024 caracteres
- [ ] Descrições truncadas terminam com "..."
- [ ] O comprimento total incluindo "..." não excede 1024 caracteres

**Out of scope:**
- Mudar o próprio limite de 1024 caracteres
- Suporte a descrição em múltiplas linhas
```

### Bom agent brief (enhancement)

```markdown
## Agent Brief

**Category:** enhancement
**Summary:** Adicionar suporte ao diretório `.out-of-scope/` para rastrear pedidos de feature rejeitados

**Current behavior:**
Quando um pedido de feature é rejeitado, a issue é fechada com o label
`wontfix` e um comentário. Não existe registro persistente da decisão ou
do raciocínio. Pedidos futuros parecidos exigem que o mantenedor lembre ou
procure pela discussão anterior.

**Desired behavior:**
Pedidos de feature rejeitados devem ser documentados em arquivos
`.out-of-scope/<conceito>.md` que capturam a decisão, o raciocínio, e links
para todas as issues que pediram a feature. Ao triar novas issues, esses
arquivos devem ser conferidos em busca de correspondências.

**Key interfaces:**
- Formato de arquivo markdown em `.out-of-scope/`: cada arquivo deve ter um
  heading `# Nome do Conceito`, uma linha `**Decision:**`, uma linha
  `**Reason:**`, e uma lista `**Prior requests:**` com links de issue
- O fluxo de triagem deve ler todos os arquivos `.out-of-scope/*.md` cedo
  e comparar issues novas com eles por similaridade de conceito

**Acceptance criteria:**
- [ ] Fechar uma feature como wontfix cria/atualiza um arquivo em `.out-of-scope/`
- [ ] O arquivo inclui a decisão, o raciocínio, e o link para a issue fechada
- [ ] Se já existe um arquivo `.out-of-scope/` correspondente, a nova issue é
      anexada à lista "Prior requests" em vez de criar um duplicado
- [ ] Durante a triagem, arquivos `.out-of-scope/` existentes são conferidos
      e mostrados quando uma nova issue corresponde a uma rejeição anterior

**Out of scope:**
- Correspondência automatizada (um humano confirma a correspondência)
- Reabrir features previamente rejeitadas
- Reports de bug (só rejeições de enhancement vão para `.out-of-scope/`)
```

### Bom agent brief (PR)

Para uma PR, "Current behavior" descreve o estado do diff, e o brief pede ao agente para terminar ou consertar em vez de construir do zero.

```markdown
## Agent Brief

**Category:** enhancement
**Summary:** Terminar a flag `--json` de saída do contribuidor para `triage list`

**Current behavior:**
A PR adiciona uma flag `--json` que serializa a lista de issues em JSON. O
caminho feliz funciona e o diff bate com a estrutura de comandos do projeto.
Faltam duas coisas: erros ainda são impressos como texto humano (não JSON),
e a nova flag não tem cobertura de teste.

**Desired behavior:**
Com `--json`, toda a saída (incluindo erros) é JSON bem formado no stdout, e
os exit codes do comando ficam inalterados. A saída legível existente
permanece intocada quando a flag está ausente.

**Key interfaces:**
- O caminho de erro do comando deve emitir `{ "error": string }` sob
  `--json` em vez do texto de erro puro
- Reaproveite o serializer que a PR já adicionou; não introduza um segundo

**Acceptance criteria:**
- [ ] `triage list --json` emite JSON válido tanto para sucesso quanto para
      erro
- [ ] Exit codes batem com o comando sem `--json`
- [ ] Um teste cobre a saída de sucesso de `--json` e um caso de erro
- [ ] A saída padrão (sem JSON) fica byte-a-byte inalterada

**Out of scope:**
- Adicionar `--json` a qualquer outro comando
- Mudar o formato JSON do payload de sucesso que a PR já definiu
```

### Mau agent brief

```markdown
## Agent Brief

**Summary:** Corrigir o bug de triagem

**What to do:**
A coisa da triagem está quebrada. Olhe o arquivo principal e conserte.
A função por volta da linha 150 tem o problema.

**Files to change:**
- src/triage/handler.ts (linha 150)
- src/types.ts (linha 42)
```

Isso é ruim porque:
- Sem categoria
- Descrição vaga ("a coisa da triagem está quebrada")
- Referencia caminhos de arquivo e números de linha que vão ficar desatualizados
- Sem critérios de aceitação
- Sem limites de escopo
- Sem descrição do comportamento atual vs. desejado
