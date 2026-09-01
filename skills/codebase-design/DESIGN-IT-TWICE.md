# Design It Twice

Quando o usuário quiser explorar interfaces alternativas para um candidato a aprofundamento já escolhido, use este padrão de subagentes paralelos. Baseado em "Design It Twice" (Ousterhout): sua primeira ideia dificilmente é a melhor.

Usa o vocabulário em [SKILL.md](SKILL.md): **módulo**, **interface**, **seam**, **adapter**, **leverage**.

## Processo

### 1. Enquadre o espaço do problema

Antes de disparar subagentes, escreva uma explicação voltada ao usuário sobre o espaço do problema para o candidato escolhido:

- As restrições que qualquer interface nova precisaria satisfazer
- As dependências das quais ela dependeria, e em qual categoria se encaixam (ver [DEEPENING.md](DEEPENING.md))
- Um esboço de código ilustrativo bruto para concretizar as restrições, não uma proposta, só uma forma de tornar as restrições concretas

Mostre isso ao usuário, depois prossiga imediatamente para o Passo 2. O usuário lê e pensa enquanto os subagentes trabalham em paralelo.

### 2. Dispare subagentes

Dispare 3+ subagentes em paralelo. Cada um deve produzir uma interface **radicalmente diferente** para o módulo aprofundado.

Dê a cada subagente um briefing técnico separado (caminhos de arquivo, detalhes de acoplamento, categoria de dependência de [DEEPENING.md](DEEPENING.md), o que fica atrás do seam). O briefing é independente da explicação do espaço do problema voltada ao usuário do Passo 1. Dê a cada agente uma restrição de design diferente:

- Agente 1: "Minimize a interface: mire em 1–3 pontos de entrada no máximo. Maximize leverage por ponto de entrada."
- Agente 2: "Maximize flexibilidade: suporte muitos casos de uso e extensão."
- Agente 3: "Otimize para quem chama mais comum: torne o caso padrão trivial."
- Agente 4 (se aplicável): "Desenhe em torno de ports & adapters para dependências que cruzam o seam."

Inclua tanto o vocabulário de [SKILL.md](SKILL.md) quanto o vocabulário do `CONTEXT.md` no briefing para que cada subagente nomeie as coisas de forma consistente com a linguagem de arquitetura e a linguagem de domínio do projeto.

Cada subagente produz:

1. Interface (tipos, métodos, parâmetros, mais invariantes, ordem, modos de erro)
2. Exemplo de uso mostrando como quem chama usa
3. O que a implementação esconde atrás do seam
4. Estratégia de dependência e adapters (ver [DEEPENING.md](DEEPENING.md))
5. Trade-offs: onde a leverage é alta, onde é fraca

### 3. Apresente e compare

Apresente os designs sequencialmente para que o usuário absorva cada um, depois compare-os em prosa. Contraste por **profundidade** (leverage na interface), **localidade** (onde a mudança se concentra) e **posicionamento do seam**.

Depois de comparar, dê sua própria recomendação: qual design você acha mais forte e por quê. Se elementos de designs diferentes se combinariam bem, proponha um híbrido. Seja opinativo: o usuário quer uma leitura forte, não um cardápio.
