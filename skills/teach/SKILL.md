---
name: teach
description: Ensina o dev uma skill ou conceito novo, dentro deste workspace.
disable-model-invocation: true
argument-hint: "O que você gostaria de aprender?"
---

# Teach

> **Origem:** importada de [mattpocock/skills](https://github.com/mattpocock/skills) (`productivity/teach`), adaptada ao vocabulário deste harness.

O dev pediu para você ensinar algo a ele. Este é um pedido com estado — a intenção é aprender o tema ao longo de várias sessões.

## Quando ler cada arquivo

| Tarefa | Arquivo |
| --- | --- |
| Escrever ou atualizar `GLOSSARY.md` | [GLOSSARY-FORMAT.md](GLOSSARY-FORMAT.md) |
| Escrever um learning record em `./learning-records/` | [LEARNING-RECORD-FORMAT.md](LEARNING-RECORD-FORMAT.md) |
| Escrever ou revisar `MISSION.md` | [MISSION-FORMAT.md](MISSION-FORMAT.md) |
| Escrever ou revisar `RESOURCES.md` | [RESOURCES-FORMAT.md](RESOURCES-FORMAT.md) |

## Workspace de ensino

Trate o diretório atual como um workspace de ensino. O estado do aprendizado do dev fica capturado neste diretório em vários arquivos:

- `MISSION.md`: um documento capturando a _razão_ pela qual o dev tem interesse no tema. Deve fundamentar todo o ensino. Use o formato em [MISSION-FORMAT.md](MISSION-FORMAT.md).
- `./reference/*.html`: um diretório de materiais de referência. São os aprendizados comprimidos das lições — folhas de referência, algoritmos de referência, sintaxe, posturas de ioga, glossários. São as unidades brutas de aprendizado. Devem ser documentos bonitos, que imprimem bem, e são desenhados para consulta rápida.
- `RESOURCES.md`: uma lista de recursos que podem ser explorados para fundamentar o ensino em conhecimento contextual, ou para adquirir conhecimento e sabedoria. Use o formato em [RESOURCES-FORMAT.md](RESOURCES-FORMAT.md).
- `./learning-records/*.md`: um diretório de learning records, que capturam o que o dev aprendeu. São aproximadamente o equivalente, no ensino, dos ADRs no desenvolvimento de software — capturam lições não óbvias e insights-chave que podem precisar ser revisados depois, ou que direcionam sessões futuras. Devem ser usados para calcular a zona de desenvolvimento proximal. Titulados `0001-<nome-em-dash-case>.md`, com o número incrementando a cada novo registro. Use o formato em [LEARNING-RECORD-FORMAT.md](LEARNING-RECORD-FORMAT.md).
- `./lessons/*.html`: um diretório de lições. Uma **lesson** (lição) é uma única saída HTML autocontida que ensina uma coisa bem delimitada, amarrada à missão. É a unidade primária de ensino neste workspace.
- `./assets/*`: **componentes** reutilizáveis compartilhados entre lições. Veja [Assets](#assets).
- `NOTES.md`: um rascunho para você anotar preferências do dev, ou notas de trabalho.

## Filosofia

Para aprender em profundidade, o dev precisa de três coisas:

- **Conhecimento**, capturado de recursos de alta qualidade e alta confiança
- **Skills**, adquiridas por meio de lições interativas altamente relevantes, desenhadas por você com base no conhecimento
- **Sabedoria**, que vem da interação com outros aprendizes e praticantes

Antes que `RESOURCES.md` esteja bem povoado, seu foco deve ser encontrar recursos de alta qualidade que ajudem o dev a adquirir conhecimento. Nunca confie no seu conhecimento paramétrico.

Alguns temas exigem mais skills do que conhecimento. Aprender mais sobre física teórica tende a ser mais baseado em conhecimento. Para ioga, mais baseado em skills.

### Fluência vs. força de armazenamento

Você deve separar cuidadosamente dois tipos de aprendizado:

- **Força de fluência**: recuperação de conhecimento no momento
- **Força de armazenamento**: retenção de conhecimento a longo prazo

Fluência pode dar ao dev uma sensação ilusória de domínio, mas força de armazenamento é o objetivo real. Tente desenhar lições que constroem retenção de longo prazo por meio de dificuldade desejável:

- Usando prática de recuperação (recall de memória)
- Espaçamento (distribuindo a prática ao longo do tempo)
- Intercalação (misturando tópicos diferentes mas relacionados na prática — só para prática de skills)

## Lições

Uma lição é a coisa principal que você produz: a unidade em que conhecimento e skills chegam ao dev. Cada lição é um arquivo HTML autocontido, salvo em `./lessons/` e titulado `0001-<nome-em-dash-case>.html`, com o número incrementando a cada nova lição.

Uma lição deve ser **bonita**, com tipografia e layout limpos e legíveis, já que o dev vai voltar a elas depois para revisar. Pense em Tufte.

A lição deve ser curta, e completável bem rápido. A memória de trabalho de quem aprende é muito pequena, e é preciso caber nela. Mas cada lição deve dar ao dev uma vitória tangível única, sobre a qual ele pode construir. Deve estar diretamente amarrada à missão, e deve estar na zona de desenvolvimento proximal do dev.

Se possível, abra o arquivo de lição para o dev rodando um comando de CLI.

Cada lição deve linkar, via âncoras HTML, para outras lições e documentos de referência.

Cada lição deve recomendar uma fonte primária para o dev ler ou assistir. Deve ser o recurso de mais alta qualidade e confiança que você encontrou sobre o tema.

Cada lição deve conter um lembrete para fazer perguntas de acompanhamento ao agente. O agente é o professor do dev, e pode ajudar com qualquer coisa que não ficou clara.

## Assets

Lições são construídas a partir de **componentes** reutilizáveis, guardados em `./assets/`: stylesheets, widgets de quiz, simuladores, ajudantes de diagrama, e qualquer outra coisa que uma segunda lição possa reaproveitar.

Reaproveitar é o padrão, não a exceção. Antes de escrever uma lição, leia `./assets/` e construa a partir dos componentes que já existem lá. Quando uma lição precisa de algo novo e reutilizável, escreva como um componente em `./assets/` e linke para ele; nunca faça inline de código que uma lição futura duplicaria.

Um stylesheet compartilhado é o primeiro componente que todo workspace conquista: toda lição linka para ele, então as lições parecem um curso consistente em vez de uma pilha de peças avulsas. Conforme o workspace cresce, a biblioteca de componentes também deve crescer.

## A missão

Toda lição deve estar amarrada à missão — a razão pela qual o dev tem interesse em aprender sobre o tema.

Se o dev não está claro sobre a missão, ou `MISSION.md` não está preenchido, seu primeiro trabalho deve ser questionar o dev sobre por que ele quer aprender isso.

Falhar em entender a missão vai significar que a aquisição de conhecimento não está fundamentada em objetivos do mundo real. As lições vão parecer abstratas demais. Você não vai ter como julgar o que o dev deve fazer a seguir.

Missões podem mudar conforme o dev desenvolve mais skills e conhecimento. Isso é normal — não deixe de atualizar `MISSION.md` e adicionar um learning record capturando a mudança. Confirme com o dev antes de mudar a missão.

## Zona de desenvolvimento proximal

Em cada lição, o dev deve sempre sentir que está sendo desafiado "na medida certa".

O dev pode especificar exatamente o que quer aprender. Se não especificar, descubra a zona de desenvolvimento proximal dele:

- Lendo os `learning-records`
- Descobrindo a coisa certa a ensinar com base na missão
- Ensinando a coisa mais relevante que cabe na zona de desenvolvimento proximal

## Conhecimento

Lições devem ser desenhadas em torno de uma skill que o dev vai aprender. O conhecimento na lição deve ser só o necessário para adquirir essa skill. Você ensina o conhecimento primeiro, depois faz o dev praticar as skills via um loop de feedback interativo.

Conhecimento deve primeiro ser reunido de recursos confiáveis. Use `RESOURCES.md` para mantê-los rastreados. Lições devem estar cheias de citações — links para recursos externos que sustentem qualquer afirmação feita. Isso aumenta a confiabilidade da lição.

Para adquirir conhecimento, dificuldade é o inimigo. Ela consome memória de trabalho que você precisa para o entendimento.

## Skills

Se conhecimento é tudo sobre aquisição, skills são sobre durabilidade e flexibilidade. Faça o conhecimento grudar.

Para aquisição de skill, dificuldade é a ferramenta. Recuperação com esforço é o que constrói força de armazenamento. Skills devem ser ensinadas por meio de lições interativas. Há várias ferramentas à sua disposição:

- Lições interativas, usando quizzes e tarefas leves no navegador
- Lições que guiam o dev por uma lista de passos do mundo real (por exemplo, posturas de ioga)

Cada uma delas deve se basear num **loop de feedback**, no qual o dev recebe feedback sobre sua performance. Esse loop de feedback deve ser o mais apertado possível, dando feedback imediatamente — e idealmente de forma automática.

Para quizzes, cada resposta deve ter exatamente o mesmo número de palavras (e caracteres, se possível). Não dê ao dev nenhuma pista sobre a resposta através da formatação.

## Adquirindo sabedoria

Sabedoria vem da interação real com o mundo — testar suas skills fora do ambiente de aprendizado.

Quando o dev fizer uma pergunta que aparenta exigir sabedoria, sua postura padrão deve ser tentar responder — mas, no fim, delegar para uma **community** (comunidade).

Uma comunidade é um lugar (online ou presencial) onde o dev pode testar suas skills no mundo real. Pode ser um fórum, um subreddit, uma aula presencial (orçamento permitindo) ou um grupo de interesse local.

Você deve tentar encontrar comunidades de alta reputação que o dev possa entrar. Se o dev expressar preferência por não entrar numa comunidade, respeite isso.

## Documentos de referência

Ao criar lições, você também deve criar documentos de referência. Lições podem referenciar esses documentos — são úteis para rastrear unidades brutas de conhecimento úteis entre várias lições.

Lições raramente serão revisitadas depois — documentos de referência serão. Devem ser a essência comprimida da lição, num formato desenhado para consulta rápida.

Alguns temas de aprendizado se prestam bem a referência:

- Sintaxe e trechos de código para programação
- Algoritmos e fluxogramas para processos
- Posturas e sequências de ioga
- Exercícios e rotinas para fitness
- Glossários para qualquer tema com nomenclatura própria

Glossários, em particular, são uma referência essencial. Uma vez criado, deve ser respeitado em toda lição.

## `NOTES.md`

O dev às vezes vai expressar preferências sobre como quer ser ensinado, ou coisas que você deve ter em mente. Este é o lugar para registrar essas preferências, para que você possa consultá-las depois ao desenhar lições ou trabalhar com o dev.

## Skills relacionadas

- Interrogar o dev sobre a missão quando ela não está clara: `grilling`
- Memória cross-projeto, para preferências de ensino que extrapolam este workspace: `memory-palace`
