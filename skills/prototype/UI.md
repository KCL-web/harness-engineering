# Protótipo de UI

Gere **várias variações de UI radicalmente diferentes** numa única rota, alternáveis a partir de uma barra flutuante na parte de baixo. O dev alterna entre variantes no navegador, escolhe uma (ou rouba pedaços de cada uma), depois descarta o resto.

Se a pergunta é sobre lógica/estado em vez de como algo se parece, esse é o ramo errado. Use [LOGIC.md](LOGIC.md).

## Quando essa é a forma certa

- "Como essa página deveria ficar?"
- "Quero ver algumas opções para esse dashboard antes de me comprometer."
- "Tenta um layout diferente para a tela de configurações."
- Qualquer momento em que o dev gastaria um dia inteiro escolhendo entre três mockups vagos na cabeça.

## Duas sub-formas: prefira fortemente a sub-forma A

Um protótipo de UI é muito mais fácil de julgar quando está **encostado no resto do app**: header real, sidebar real, dados reais, densidade real. Uma rota descartável isolada é um vácuo: toda variante parece boa isoladamente. Vá de sub-forma A sempre que houver uma página existente plausível para hospedar as variantes. Só recorra à sub-forma B se o protótipo genuinamente não tiver um lar por perto.

### Sub-forma A: ajuste a uma página existente (preferida)

A rota já existe. As variantes são renderizadas **na mesma rota**, controladas por um parâmetro de busca `?variant=` na URL. O data fetching, params e auth existentes permanecem. Só a renderização muda. Essa é a opção padrão; escolha-a a menos que haja uma razão específica para não fazê-lo.

Se o protótipo é para algo que ainda não tem uma página mas *naturalmente viveria dentro de uma* (uma nova seção do dashboard, um novo card na tela de configurações, um novo passo num fluxo existente), ainda é sub-forma A. Monte as variantes dentro da página hospedeira.

### Sub-forma B: uma página nova (último recurso)

Só use isso quando o que está sendo prototipado genuinamente não tem página existente para viver dentro (ex.: uma superfície de topo inteiramente nova, ou um fluxo que não pode ser embutido em nenhum lugar sensato).

Crie uma **rota descartável** seguindo a convenção de rotas que o projeto já usa. Não invente uma estrutura de topo nova. Nomeie de forma que fique óbvio que é um protótipo (ex.: inclua a palavra `prototype` no caminho ou nome de arquivo). Mesmo padrão `?variant=`.

Antes de se comprometer com a sub-forma B, faça uma checagem de sanidade: será que realmente não há uma página existente onde isso poderia ser embutido? Uma rota vazia esconde problemas de design que uma rota povoada exporia.

Nas duas sub-formas a barra flutuante na parte de baixo é idêntica.

## Processo

### 1. Declare a pergunta e escolha N

Padrão de **3 variantes**. Mais de 5 deixa de ser radicalmente diferente e vira ruído, então limite por aí.

Escreva o plano em uma linha, no local do protótipo ou num comentário no topo do arquivo:

> "Três variantes da página de configurações, alternáveis via `?variant=`, na rota `/settings` existente."

Isso funciona esteja o dev aqui para discordar ou não.

### 2. Gere variantes radicalmente diferentes

Rascunhe cada variante. Prenda cada uma a:

- O propósito da página e os dados a que ela tem acesso.
- A biblioteca de componentes / sistema de estilo do projeto (TailwindCSS, shadcn, MUI, CSS puro, o que for).
- Um nome de componente exportado claro, ex.: `VariantA`, `VariantB`, `VariantC`.

Variantes precisam ser **estruturalmente diferentes**: layout diferente, hierarquia de informação diferente, affordance primária diferente, não só cores diferentes. Três grids de card levemente ajustados não é um protótipo de UI, é papel de parede. Se dois rascunhos saírem parecidos demais, refaça um deles com uma instrução explícita tipo "não use grid de card."

### 3. Conecte tudo

Crie um único componente switcher na rota:

```tsx
// pseudo-código, adapte ao framework do projeto
const variant = searchParams.get('variant') ?? 'A';
return (
  <>
    {variant === 'A' && <VariantA {...data} />}
    {variant === 'B' && <VariantB {...data} />}
    {variant === 'C' && <VariantC {...data} />}
    <PrototypeSwitcher variants={['A','B','C']} current={variant} />
  </>
);
```

Para sub-forma A (página existente): mantenha todo o data fetching existente acima do switcher; só a subárvore renderizada muda por variante.

Para sub-forma B (página nova): a rota descartável em `/prototype/<nome>` monta o mesmo switcher.

### 4. Construa o switcher flutuante

Uma pequena barra fixa no rodapé-centro da tela com três peças:

- **Seta para a esquerda**: cicla para a variante anterior (dá a volta).
- **Rótulo da variante**: mostra a chave da variante atual e, se a variante exporta um nome, esse nome também. Ex.: `B (Layout com sidebar)`.
- **Seta para a direita**: cicla para frente (dá a volta).

Comportamento:

- Clicar numa seta atualiza o parâmetro de busca na URL (use o router do framework, ex.: `router.replace` no Next, `navigate` no React Router, etc.) para que a variante seja compartilhável e estável a reload.
- Teclado: `←` e `→` também ciclam. Não intercepte as setas quando um `<input>`, `<textarea>`, ou `[contenteditable]` estiver com foco.
- Visualmente distinta da página (ex.: pílula de alto contraste, sombra sutil) para que fique óbvio que não faz parte do design sendo avaliado.
- Escondida em builds de produção: proteja com `process.env.NODE_ENV !== 'production'` ou uma checagem equivalente, para que um merge acidental do protótipo não leve a barra para os usuários.

Coloque o switcher num único componente compartilhado para que as duas sub-formas possam reutilizá-lo. Localize-o onde a UI compartilhada já vive no projeto.

### 5. Entregue

Exponha a URL (e as chaves `?variant=`). O dev vai alternar entre elas quando tiver tempo. O feedback interessante costuma ser **"quero o header da B com a sidebar da C"**, que é o design de verdade que ele quer.

### 6. Capture a resposta e limpe

Uma vez que uma variante tenha vencido, capture a resposta (qual variante e por quê), depois capture o protótipo do jeito que o [SKILL](SKILL.md) descreve. Incorpore a vencedora ao código de verdade e mova o resto para a branch descartável, não para main:

- **Sub-forma A**: incorpore a vencedora à página existente; descarte as variantes perdedoras e o switcher de main.
- **Sub-forma B**: promova a variante vencedora a uma rota de verdade; descarte a rota descartável e o switcher de main.

O conjunto completo de variantes é a fonte primária, então ele vai para a branch descartável, não para a lixeira, já que componentes de variante e o switcher deixados na branch principal apodrecem rápido e confundem o próximo leitor.

## Anti-padrões

- **Variantes que diferem só em cor ou texto.** Isso é um ajuste, não um protótipo. Variantes de verdade discordam sobre estrutura.
- **Compartilhar código demais entre variantes.** Um `<Header>` compartilhado tudo bem; um `<Layout>` compartilhado derrota o propósito. Cada variante deveria ser livre para descartar o layout.
- **Conectar variantes a mutações reais.** Protótipos somente leitura tudo bem. Se uma variante precisa mutar algo, aponte para um stub: a pergunta é "como isso deveria ficar", não "o backend funciona".
- **Promover o protótipo direto para produção.** O código da variante foi escrito sob restrições de protótipo (sem testes, tratamento de erro mínimo). Reescreva-o direito quando for incorporá-lo.
