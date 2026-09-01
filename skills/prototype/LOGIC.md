# Protótipo de lógica

Um único arquivo HTML autocontido (uma **demo compartilhável**) que deixa qualquer pessoa operar um modelo de estado clicando em botões. Use isso quando a pergunta é sobre **lógica de negócio, transições de estado ou formato de dados**: o tipo de coisa que parece razoável no papel mas só revela o problema quando você a empurra por casos reais.

Como é um único arquivo, sem nada para instalar, você pode entregá-lo a uma pessoa não-dev (um designer, um PM, um especialista de domínio) e deixá-la sentir o modelo por conta própria. Por isso ele fala a linguagem dela, não a do código.

## Quando essa é a forma certa

- "Não tenho certeza se essa máquina de estados trata bem o caso em que X e depois Y."
- "Esse modelo de dados realmente permite representar o caso onde..."
- "Quero sentir como a API deveria ficar antes de escrevê-la."
- Qualquer coisa em que alguém queira **apertar botões e ver o estado mudar**.

Se a pergunta é "como isso deveria ficar", esse é o ramo errado. Use [UI.md](UI.md).

## Processo

### 1. Declare a pergunta

Antes de escrever código, escreva qual modelo de estado e qual pergunta você está prototipando. Um parágrafo, no topo da demo (numa introdução visível, não só um comentário). Um protótipo de lógica que responde a pergunta errada é desperdício puro, então torne a pergunta explícita para que possa ser checada depois, esteja o dev observando agora ou voltando a isso mais tarde.

### 2. Isole a lógica num módulo portável

Coloque a lógica de fato (a parte que responde à pergunta) num único bloco `<script>` escrito como um módulo pequeno e puro que poderia ser retirado dali e colocado na codebase de verdade depois. A página ao redor é descartável; esse módulo não é.

A forma certa depende da pergunta:

- **Um reducer puro**: `(state, action) => state`. Bom quando ações são eventos discretos e o estado é um valor único.
- **Uma máquina de estados**: estados e transições explícitos. Bom quando "quais ações são sequer legais agora" faz parte da pergunta.
- **Um pequeno conjunto de funções puras** sobre um tipo de dado simples. Bom quando não há estado atual implícito, só transformações.
- **Uma classe ou módulo com uma superfície de métodos clara** quando a lógica de fato possui estado interno contínuo.

Escolha a forma que melhor se encaixa na pergunta sendo feita, *não* a mais fácil de conectar a uma página. Mantenha puro: sem DOM, sem `document`, sem handlers de botão mexendo por dentro. A página chama esse módulo; nada flui na direção contrária. É isso que torna o protótipo útil além da própria vida útil: uma vez respondida a pergunta, o reducer/máquina/conjunto de funções validado é incorporado ao módulo de verdade sozinho.

### 3. Construa o arquivo HTML compartilhável

Um único arquivo, HTML/CSS/JS puro: sem framework, sem bundler, sem servidor, tudo inline para que abra com duplo clique e sobreviva a ser enviado por e-mail. Qualquer pessoa deveria conseguir rodá-lo abrindo o arquivo.

Escreva para uma pessoa não-dev. Cada rótulo está em **linguagem de domínio**, não em código: botões e estado leem como o negócio, não como o reducer. Explique em palavras simples o que está acontecendo.

Organize numa hierarquia limpa, de cima para baixo:

1. **Título e explicação de uma linha** sobre o que essa demo permite explorar (a pergunta do passo 1).
2. **Estado atual**: o estado relevante completo, renderizado como um painel legível (campos rotulados, não um dump de JSON cru), re-renderizado depois de cada clique para que a mudança fique visível. Onde ajudar uma pessoa não-dev a acompanhar, destaque o que acabou de mudar.
3. **Botões de livre exploração**: um botão por ação, sempre disponível, para que qualquer pessoa possa cutucar o modelo em qualquer ordem. Cada clique dispara sua ação e re-renderiza o estado.
4. **Walkthroughs guiados**: um conjunto de **cenários**, um por aba. Cada aba traz uma descrição curta em linguagem simples do cenário (a situação que ele configura e o que observar) e, abaixo dela, os **botões a apertar**, em ordem, para aquele cenário. Cada passo é um botão de verdade: clicar nele executa a ação e avança para o próximo passo. Iniciar um walkthrough reseta para um estado inicial conhecido, para que o cenário rode do mesmo jeito toda vez.

Escolha cenários que demonstrem os casos incômodos, os difíceis de raciocinar no papel: o caminho feliz, uma borda complicada, uma tentativa de algo que deveria ser ilegal.

Mantenha bonito mas contido: tipografia limpa, espaçamento generoso, uma cor de acento. Sem animações, sem gimmicks: nada que compita com o estado e os botões.

### 4. Entregue

Envie o arquivo, ou abra-o para o dev. Ele vai clicar pelos walkthroughs e brincar livremente quando tiver tempo; os momentos interessantes são quando ele diz "espera, isso não deveria ser possível" ou "hã, eu assumia que X seria diferente"; esses são os bugs da _ideia_, que é o objetivo de tudo isso. Se quiser novas ações ou um novo cenário, adicione-os. Protótipos evoluem.

### 5. Capture a resposta e o protótipo

Uma vez que o protótipo tenha respondido sua pergunta, capture a resposta, depois capture o protótipo do jeito que o [SKILL](SKILL.md) descreve. O mapeamento específico de lógica: o reducer/máquina/conjunto de funções validado é incorporado ao módulo de verdade (a decisão, absorvida); o shell HTML segue para a branch descartável que mantém o protótipo como fonte primária, e por ser um único arquivo autocontido, ele permanece trivialmente re-executável lá.

## Anti-padrões

- **Não adicione testes.** Um protótipo que precisa de testes não é mais um protótipo.
- **Não conecte ao banco de dados de verdade.** Use estado em memória a menos que a pergunta seja especificamente sobre persistência.
- **Não generalize.** Sem "e se quiséssemos suportar X depois." O protótipo responde uma pergunta.
- **Não misture a lógica e a página.** Se o módulo puro referencia o DOM, `document`, ou handlers de botão, ele deixa de ser retirável. Mantenha a página como um shell fino sobre um módulo puro.
- **Não recorra a um framework, bundler ou servidor.** Um arquivo que o destinatário abre com duplo clique; um app React ou um dev server derrota o propósito de "compartilhável".
- **Não envie o shell HTML para produção.** A página é otimizada para ser clicada manualmente. O módulo de lógica por trás dela é a parte que vale a pena manter.
