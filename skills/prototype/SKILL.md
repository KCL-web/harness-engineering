---
name: prototype
description: Constrói um protótipo descartável para responder uma pergunta de design. Use quando o dev quer validar se um modelo de estado/lógica faz sentido, ou explorar como uma UI deveria ficar. Importada de mattpocock/skills.
---

# Prototype

> **Origem:** importada de [mattpocock/skills](https://github.com/mattpocock/skills) (`engineering/prototype`), adaptada ao vocabulário deste harness.

Um protótipo é **código descartável que responde uma pergunta**. A pergunta decide a forma.

## Escolha um ramo

Identifique qual pergunta está sendo respondida, usando o prompt do dev, o código ao redor, ou perguntando diretamente se o dev estiver disponível:

- **"Essa lógica / modelo de estado faz sentido?"** → [LOGIC.md](LOGIC.md). Construa um único arquivo HTML compartilhável (botões de livre exploração mais walkthroughs guiados em abas) que empurra a máquina de estados por casos difíceis de raciocinar no papel, e que uma pessoa não-dev consiga operar.
- **"Como isso deveria ficar?"** → [UI.md](UI.md). Gere várias variações de UI radicalmente diferentes numa única rota, alternáveis via um parâmetro de busca na URL e uma barra flutuante na parte de baixo.

Os dois ramos produzem artefatos muito diferentes, então errar aqui desperdiça o protótipo inteiro. Se a pergunta for genuinamente ambígua e o dev não estiver disponível, escolha por padrão o ramo que melhor combina com o código ao redor (um módulo de backend → lógica; uma página ou componente → UI) e declare a suposição no topo do protótipo.

## Regras que valem para os dois ramos

1. **Descartável desde o primeiro dia, e claramente marcado como tal.** Localize o código do protótipo perto de onde ele será realmente usado (ao lado do módulo ou página que está sendo prototipada) para que o contexto fique óbvio, mas nomeie de forma que um leitor casual perceba que é um protótipo, não produção. Para rotas de UI descartáveis, obedeça a convenção de rotas que o projeto já usa; não invente uma estrutura de topo nova.
2. **Trivial de rodar.** Um protótipo de UI parte de um único comando no task runner do projeto: `pnpm <nome>`, `python <caminho>`, `bun <caminho>`, etc. Uma demo de lógica é um único arquivo HTML que o dev abre com duplo clique. De qualquer forma, zero raciocínio necessário para iniciar.
3. **Sem persistência por padrão.** O estado vive em memória. Persistência é a coisa que o protótipo está _verificando_, não algo do qual ele deveria depender. Se a pergunta envolve explicitamente um banco de dados, use um banco de teste (scratch DB) ou um arquivo local com um nome claro do tipo "PROTOTYPE, apague-me".
4. **Pule o polimento.** Sem testes, sem tratamento de erro além do que torna o protótipo _executável_, sem abstrações. O objetivo é aprender algo rápido.
5. **Exponha o estado.** Depois de cada ação (lógica) ou a cada troca de variante (UI), imprima ou renderize o estado relevante completo para que o dev veja o que mudou.
6. **Capture quando terminar.** Incorpore qualquer decisão validada ao código de verdade, depois capture o próprio protótipo como uma **fonte primária**: faça commit dele numa branch descartável, fora de main, e deixe um ponteiro de contexto para essa branch na issue de implementação (um comentário na issue do Forgejo — ver `workflow-issues`). Capture a resposta também (o veredito e a pergunta que ela resolveu) na issue ou num commit (ver `workflow-commits`). A branch principal mantém só a decisão validada.

## Skills relacionadas

- Loop test-first (para quando a decisão validada vira código de verdade): `tdd`
- Comentário/pointer de contexto na issue: `workflow-issues`
- Nome e origem de branch descartável: `workflow-branching`
- Mensagem de commit: `workflow-commits`
