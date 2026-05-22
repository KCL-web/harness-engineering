# SPEC.md — &lt;Nome do projeto&gt;

> Preencha todas as seções abaixo no início de um projeto novo.
> Seja breve. Um parágrafo por seção costuma bastar.
> Este arquivo é lido no começo de toda sessão do agente — specs vagos geram código vago.

---

## Visão

> Uma ou duas frases descrevendo o que é o produto e para quem é.
> Evite listas de funcionalidades. Foque no resultado que o produto entrega.

Formato sugerido: "Uma &lt;tipo de ferramenta&gt; que &lt;faz X&gt; para &lt;usuário-alvo&gt;, para que possam &lt;atingir Y&gt;."

---

## Problema

> Que dor ou lacuna existe hoje.
> Seja concreto: quem sofre, em que situação, e qual o custo disso.
> Se o problema não é real ou não é doloroso o bastante, o projeto não vale ser construído.

---

## Solução

> Como o produto resolve o problema, em linguagem direta.
> Liste as capacidades principais como uma lista numerada — no máximo 4 ou 5.

1. &lt;capacidade 1&gt;
2. &lt;capacidade 2&gt;
3. &lt;capacidade 3&gt;

---

## Usuários

> Quem interage com o sistema e como.
> Nomeie cada papel explicitamente. Se existe só um papel, diga isso.

- **&lt;Papel 1&gt;:** o que fazem, o que tiram disso
- **&lt;Papel 2&gt;:** o que fazem, o que tiram disso

---

## Fora de escopo

> O que este produto explicitamente NÃO faz.
> Isso é tão importante quanto o escopo em si — previne scope creep.

- &lt;não-objetivo 1&gt;
- &lt;não-objetivo 2&gt;
- &lt;não-objetivo 3&gt;

---

## Critérios de sucesso

> Como saberemos que o produto funciona.
> Cada critério precisa ser observável — algo que uma pessoa consegue checar.

- &lt;critério 1&gt;
- &lt;critério 2&gt;
- &lt;critério 3&gt;

---

## Visão técnica

> Stack e ferramentas escolhidas para este projeto.
> Mantenha factual — sem justificativas aqui; isso vai em ADRs se necessário.

- **Framework:**
- **Linguagem:**
- **Banco / ORM:**
- **Estilização:**
- **Testes:**
- **Gerenciador de pacotes:**
- **Deploy:**

---

## Restrições importantes

> Regras não-óbvias, edge cases ou invariantes que o agente precisa respeitar.
> Qualquer coisa que, se violada, quebraria o produto silenciosamente.
> Exemplos: "eventos são entregues uma única vez", "campo X pode ser null em dados legados", "o cálculo acontece na escrita, não na leitura".

- &lt;restrição 1&gt;
- &lt;restrição 2&gt;
- &lt;restrição 3&gt;
