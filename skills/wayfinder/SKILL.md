---
name: wayfinder
description: Planeja um pedaço grande de trabalho (maior do que uma sessão de agente aguenta) como um mapa compartilhado de tickets de decisão no Forgejo, e resolve esses tickets um de cada vez até a rota até o destino ficar clara. Importada de mattpocock/skills.
disable-model-invocation: true
---

# Wayfinder

> **Origem:** importada de [mattpocock/skills](https://github.com/mattpocock/skills) (`engineering/wayfinder`), adaptada ao vocabulário deste harness.

Uma ideia solta chegou, grande demais para uma sessão de agente, e envolta em neblina: a rota daqui até o **destino** ainda não é visível. Wayfinding é sobre encontrar essa rota, não avançar direto no destino. Esta skill traça a rota como um **mapa compartilhado** numa issue do Forgejo, depois trabalha os **tickets de decisão** desse mapa (perguntas cuja resolução é uma decisão, não fatias de uma construção para executar) um de cada vez até a rota ficar clara.

O destino varia por esforço, e nomeá-lo é o primeiro ato de traçar o mapa: ele molda cada ticket. Pode ser uma spec para entregar e iterar, uma decisão para travar antes de planejar, ou uma mudança feita in place como uma migração de estrutura de dados. O mapa é agnóstico de domínio: trabalho de engenharia, conteúdo de curso, o que se encaixar na forma.

## Planeje, não execute

Wayfinder é **planejamento** por padrão: cada ticket resolve uma decisão, e o mapa está pronto quando a rota está clara, sem nada restando para decidir antes de alguém ir e fazer a coisa. O impulso de simplesmente fazer o trabalho geralmente é o sinal de que você chegou na borda do mapa e é hora de entregar (handoff). Um esforço pode sobrepor isso nas suas **Notes**, carregando execução para dentro do próprio mapa, mas na ausência disso, produza decisões, não entregas.

## Refira-se pelo nome

Todo mapa e ticket é uma issue, então tem um **nome**: seu título. Em tudo que o humano lê (narração, o "Decisions so far" do mapa), refira-se a ele por esse nome, nunca por um id, número ou slug isolado. Uma parede de `#42, #43, #44` é ilegível; nomes se leem de relance. O id e a URL não desaparecem; um nome envolve seu link, mas eles viajam _dentro_ do nome, nunca no lugar dele.

## O Mapa

O mapa é uma única issue no Forgejo deste workspace, com o label `wayfinder:map`, o artefato canônico. Seus tickets são issues-filhas do mapa.

O mapa é um **índice**, não um repositório. Ele lista as decisões tomadas e aponta para os tickets que guardam o detalhe; uma decisão vive em exatamente um lugar, seu ticket, então o mapa nunca a reafirma, só a resume (gist) e linka.

### Operações no Forgejo

Onde o mapa, seus tickets-filhas, o bloqueio e as consultas de fronteira vivem fisicamente é específico do Forgejo. Use a mecânica de `workflow-issues` (env vars `FORGEJO_TOKEN`/`FORGEJO_URL`/`FORGEJO_ORG`, curl + jq contra a API) como base para tudo abaixo:

- **Label do mapa:** `wayfinder:map` na issue-mãe. Crie-o (`POST /repos/{org}/{repo}/labels`) na primeira vez que usar esta skill neste repo, como já se faz para os labels de `triage`.
- **Labels de tipo de ticket:** cada ticket-filha carrega um label `wayfinder:<tipo>`, um de `wayfinder:research`, `wayfinder:prototype`, `wayfinder:grilling`, `wayfinder:task` (ver [Tipos de Ticket](#tipos-de-ticket)).
- **Vínculo pai↔filho:** o Forgejo não tem sub-issues nativas como o GitHub. Use um marcador na primeira linha do body do ticket, `Wayfinder-Map: #<numero-da-issue-mapa>`, no mesmo espírito do marcador `Task:` de `workflow-issues`. Para listar os tickets de um mapa, busque todas as issues do repo e filtre pelo body contendo esse marcador (o mesmo padrão de busca client-side com `jq` que `workflow-issues` usa para o marcador `Task:`).
- **Bloqueio:** use a API de dependências de issues do Forgejo quando o recurso estiver habilitado no repositório (Settings → Issues → "Issue Dependencies"; endpoint `POST /repos/{org}/{repo}/issues/{index}/dependencies` com o número do ticket bloqueador). Isso é o que faz o bloqueio renderizar nativamente na UI do Forgejo, para que o humano veja o que está pegável sem abrir o mapa. Se o recurso não estiver habilitado neste repo, caia para a convenção de texto: uma seção `## Blocked by` no body listando os números dos bloqueadores. Um ticket está **desbloqueado** quando todo ticket que o bloqueia está fechado; a **fronteira** são as issues-filhas abertas, desbloqueadas e não reivindicadas — a borda do conhecido.
- **Reivindicar (claim):** uma sessão reivindica um ticket atribuindo-o (assign) a si mesma via `PATCH /repos/{org}/{repo}/issues/{index}` com `{"assignees": [...]}`, **antes** de qualquer trabalho, para que sessões concorrentes o pulem — o mesmo endpoint de assign que `workflow-issues` já documenta. Esse assignee _é_ a reivindicação: um ticket aberto e sem assignee está livre.

A resposta não faz parte do body; ela é registrada na resolução (ver [Trabalhando o mapa](#trabalhando-o-mapa)) como comentário na issue. Ativos criados ao resolver um ticket são linkados a partir da issue, não colados nela.

### O body do mapa

O mapa inteiro em baixa resolução, carregado uma vez por sessão. Tickets abertos **não** são listados: eles são issues-filhas abertas, encontradas por consulta.

```markdown
## Destination

<como é chegar ao fim deste mapa: a spec, decisão, ou mudança para a qual este esforço está encontrando o caminho. Uma ou duas linhas; toda sessão se orienta a partir daqui antes de escolher um ticket.>

## Notes

<domínio; skills que toda sessão deveria consultar; preferências fixas para este esforço>

## Decisions so far

<!-- o índice: uma linha por ticket fechado, o suficiente para julgar relevância, depois dar zoom no link para o detalhe que o ticket guarda -->

- [<título do ticket fechado>](link): <resumo de uma linha da resposta>

## Not yet specified

<!-- ver "Neblina de guerra": neblina dentro do escopo que você ainda não consegue transformar em ticket, e que se forma em ticket conforme a fronteira avança -->

## Out of scope

<!-- ver "Fora de escopo": trabalho considerado além do destino; fechado, nunca se forma em ticket -->
```

### Tickets

Cada ticket é uma **issue-filha** do mapa (via o marcador `Wayfinder-Map:`); o número da issue no Forgejo é sua identidade. Seu body é a pergunta, dimensionada para caber numa sessão de agente de 100K tokens:

```markdown
Wayfinder-Map: #<numero-da-issue-mapa>

## Question

<a decisão ou investigação que este ticket resolve>
```

## Tipos de Ticket

Todo ticket é **HITL** (human in the loop, trabalhado _com_ um humano que fala por si) ou **AFK**, conduzido pelo agente sozinho. Um ticket HITL só se resolve através dessa troca ao vivo; o agente nunca substitui o lado do humano nela (um agente de grilling que responde suas próprias perguntas quebrou essa regra).

- **Research** (AFK): Ler documentação, APIs de terceiros, ou recursos locais como bases de conhecimento para trazer à tona um fato do qual uma decisão depende. Resolvido por um subagente que chama a Skill tool com "research". Use quando conhecimento fora do diretório de trabalho atual é necessário.
- **Prototype** (HITL): Elevar a fidelidade da discussão fazendo um artefato barato, cru e concreto para reagir a ele (um outline, um rascunho, um stub, ou código de UI/lógica) chamando a Skill tool com "prototype". Linka o protótipo como um ativo. Use quando "como deveria parecer" ou "como deveria se comportar" é a pergunta-chave.
- **Grilling** (HITL): Conversa. O caso padrão. Sempre chame a Skill tool duas vezes, para "grilling" e "domain-modeling".
- **Task** (HITL ou AFK): Trabalho manual que precisa acontecer antes que uma _decisão_ possa ser tomada: nada para decidir, prototipar, ou pesquisar, mas a discussão está bloqueada até isso ser feito. Assinar um serviço para que sua API possa ser julgada, provisionar acesso, mover dados para que sua forma possa ser vista. Esse é o único tipo que _executa_ em vez de decidir, e ele ganha seu lugar por desbloquear uma decisão, não por entregar o destino. O agente conduz sozinho onde consegue (AFK); senão, entrega ao humano um checklist preciso (HITL). Resolvido quando o trabalho está feito; a resposta registra o que foi feito e quaisquer fatos resultantes (localização de credenciais, URLs novas, contagens de linha) dos quais tickets futuros dependem.

## Neblina de guerra

O mapa é _deliberadamente_ incompleto: não trace o que você ainda não consegue ver. Além dos tickets vivos está a **neblina de guerra**: a visão turva de decisões e investigações que você percebe que estão chegando mas ainda não consegue fixar, porque dependem de perguntas ainda abertas. Resolver um ticket limpa a neblina à frente dele, formando em tickets frescos, um de cada vez, o que agora é especificável, até que a rota até o destino esteja clara e não sobre nenhum ticket.

A seção **Not yet specified** do mapa é onde essa visão turva fica registrada: a pergunta suspeita, a área a revisitar depois. É a fronteira ainda não descoberta _rumo_ ao destino: tudo aqui está no escopo, só não está afiado o bastante para virar ticket. Escreva tão solto ou tão completo quanto a visão permitir; também funciona como uma placa de sinalização para colaboradores lendo para onde o esforço está indo.

**Neblina ou ticket?** O teste é se você consegue declarar a pergunta com precisão agora, _não_ se você consegue respondê-la agora.

- **Ticket quando** a pergunta já está afiada, mesmo que esteja bloqueada e você não possa agir nela ainda.
- **Not yet specified quando** você ainda não consegue frasear com essa nitidez. Não pré-fatie a neblina em pedaços do tamanho de ticket: ela é mais grossa que um ticket, e um pedaço pode se formar em vários tickets, ou nenhum, quando a fronteira o alcançar.

**Not yet specified** exclui o que já foi decidido (Decisions so far), o que já é um ticket vivo, e o que está fora de escopo (a próxima seção).

## Fora de escopo

A neblina só se acumula _rumo_ ao destino. O destino fixa o escopo, então trabalho além dele está **fora de escopo**: não é neblina, e não pertence a **Not yet specified**. Ganha sua própria seção **Out of scope** no mapa: trabalho que você conscientemente excluiu deste esforço. Escopo, não nitidez, é o que manda algo para cá.

Trabalho fora de escopo nunca se forma em ticket (a fronteira para no destino), então só retorna se o destino for redesenhado, e aí como um esforço novo, não uma retomada.

Descartar algo como fora de escopo é um ato de definição de escopo, não um passo na rota. Quando um ticket que já existe acaba estando além do destino (mal escopado ao traçar o mapa, ou exposto por uma resolução), **feche-o** (um ticket fechado está inequivocamente fora da fronteira) e deixe uma linha na seção **Out of scope**: o resumo mais o porquê de estar fora de escopo, linkando o ticket fechado. Ele fica fora de **Decisions so far**, que registra a rota de fato percorrida; um limite de escopo não é um passo nela.

## Invocação

Dois modos. De qualquer forma, **nunca resolva mais de um ticket por sessão**, com exceção de tickets de research.

### Traçar o mapa

O usuário invoca com uma ideia solta.

1. **Nomeie o destino.** Chame a Skill tool duas vezes, para "grilling" e "domain-modeling", para fixar para onde este mapa está encontrando o caminho: a spec, decisão, ou mudança. O destino fixa o escopo, então é resolvido primeiro.
2. **Mapeie a fronteira.** Grille de novo, **em largura** desta vez: espalhe por todo o espaço em vez de aprofundar numa única linha, trazendo à tona as decisões abertas e os primeiros passos pegáveis agora. **Se isso não trouxer neblina** (a rota até o destino já está clara, a jornada inteira pequena o bastante para uma sessão), você não precisa de um mapa. Pare e pergunte ao usuário como prefere prosseguir.
3. **Crie o mapa** (label `wayfinder:map`): Destination e Notes preenchidos, Decisions-so-far vazio, a neblina esboçada em **Not yet specified**.
4. **Crie os tickets que já consegue especificar agora** como issues-filhas do mapa (com o marcador `Wayfinder-Map:`), depois conecte as arestas de bloqueio numa **segunda passada** (issues precisam de ids antes de poder se referenciar). Conectar as ordena entre a fronteira e o bloqueado; tudo que você ainda não consegue especificar fica na neblina: a seção **Not yet specified**.
5. **Dispare os subagentes de research.** Para cada ticket `research` que você acabou de criar, suba um subagente que chama a Skill tool com "research" para resolvê-lo em paralelo, capturando as descobertas numa branch descartável `research/<nome>` com um ponteiro de contexto a partir do ticket.
6. Pare: traçar o mapa é trabalho de uma sessão; ele não resolve nada à mão.

### Trabalhando o mapa

O usuário invoca com um mapa (URL ou número). Um ticket é **opcional**: sem um, você escolhe a próxima decisão, não o usuário.

1. Carregue o **mapa**: a visão de baixa resolução, não o body de cada ticket.
2. Escolha o ticket. Se o usuário nomeou um, use-o. Senão pegue o primeiro ticket da fronteira, em ordem. **Reivindique-o**: atribua a si mesmo antes de qualquer trabalho.
3. Resolva-o. **Dê zoom conforme necessário**: busque o body completo de qualquer ticket relacionado ou fechado sob demanda; chame a Skill tool para quaisquer skills que o bloco `## Notes` nomear. Em caso de dúvida, chame a Skill tool duas vezes, para "grilling" e "domain-modeling".
4. Registre a resolução: poste a resposta como um **comentário de resolução**, **feche** a issue, e **anexe um ponteiro de contexto** ao Decisions-so-far do mapa.
5. Adicione tickets recém-surgidos (crie-depois-conecte); forme em ticket qualquer neblina que a resposta tornou especificável, limpando cada pedaço formado de **Not yet specified** para que ele viva só como seu ticket novo. Se a resposta revelar que um ticket (este ou outro) está além do destino, **marque-o como fora de escopo** em vez de resolvê-lo na rota. Se a decisão invalidar outras partes do mapa, atualize ou apague esses tickets.

O usuário pode rodar tickets desbloqueados em paralelo, então espere que outras sessões estejam editando o Forgejo concorrentemente.

## Skills relacionadas

- Mecânica de issue, milestone, sprint, label no Forgejo: `workflow-issues`
- Estados de triagem: `triage`
- Publicar spec e quebrar em tickets: `to-spec`, `to-tickets`
- Grilling e vocabulário de domínio: `grilling`, `domain-modeling`
