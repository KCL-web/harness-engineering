# Aprofundamento (Deepening)

Como aprofundar com segurança um cluster de módulos rasos, dado suas dependências. Assume o vocabulário em [SKILL.md](SKILL.md): **módulo**, **interface**, **seam**, **adapter**.

## Categorias de dependência

Ao avaliar um candidato a aprofundamento, classifique suas dependências. A categoria determina como o módulo aprofundado é testado através do seu seam.

### 1. In-process

Computação pura, estado em memória, sem I/O. Sempre aprofundável: junte os módulos e teste através da nova interface diretamente. Nenhum adapter necessário.

### 2. Substituível localmente

Dependências que têm stand-ins de teste locais (PGLite para Postgres, filesystem em memória). Aprofundável se o stand-in existir. O módulo aprofundado é testado com o stand-in rodando na suíte de testes. O seam é interno; nenhum port na interface externa do módulo.

### 3. Remoto mas próprio (Ports & Adapters)

Serviços próprios através de uma fronteira de rede (microserviços, APIs internas). Defina um **port** (interface) no seam. O módulo profundo é dono da lógica; o transporte é injetado como um **adapter**. Testes usam um adapter em memória. Produção usa um adapter HTTP/gRPC/fila.

Formato da recomendação: *"Defina um port no seam, implemente um adapter HTTP para produção e um adapter em memória para teste, para que a lógica fique num módulo profundo só mesmo que esteja implantada através de uma rede."*

### 4. Verdadeiramente externo (Mock)

Serviços de terceiros (Stripe, Twilio, etc.) que você não controla. O módulo aprofundado recebe a dependência externa como um port injetado; testes fornecem um adapter mock.

## Disciplina de seam

- **Um adapter é um seam hipotético. Dois adapters é um seam real.** Não introduza um port a menos que pelo menos dois adapters se justifiquem (tipicamente produção + teste). Um seam de adapter único é só indireção.
- **Seams internos vs. seams externos.** Um módulo profundo pode ter seams internos (privados à sua implementação, usados pelos próprios testes) além do seam externo na sua interface. Não exponha seams internos através da interface só porque os testes os usam.

## Estratégia de teste: substitua, não empilhe

- Testes unitários antigos em módulos rasos viram desperdício assim que existem testes na interface do módulo aprofundado; delete-os.
- Escreva testes novos na interface do módulo aprofundado. A **interface é a superfície de teste**.
- Testes verificam resultados observáveis através da interface, não estado interno.
- Testes devem sobreviver a refatorações internas, já que descrevem comportamento, não implementação. Se um teste precisa mudar quando a implementação muda, ele está testando além da interface.
