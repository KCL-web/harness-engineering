# INTEGRATION.md

Como os repos deste workspace se falam. Leia antes de fazer qualquer mudança cross-repo.

---

## Contratos de API

> Onde vive a fonte de verdade de cada contrato de API, e como os consumidores ficam em sincronia.

| Contrato | Repo dono | Consumidores | Como sincronizado |
| --- | --- | --- | --- |
| &lt;ex.: endpoints REST&gt; | &lt;backend&gt; | &lt;frontend&gt; | &lt;manual / openapi / pacote compartilhado&gt; |

Regra: o repo dono é a fonte de verdade. Consumidores nunca definem um tipo ou schema que conflite com o do dono.

---

## Tipos e schemas compartilhados

> Se tipos/schemas são duplicados entre repos, documente como ficam em sincronia.
> Opções: pacote publicado, geração de código, cópia manual com checklist.

- &lt;tipo/schema&gt;: definido em &lt;dono&gt;, usado em &lt;consumidores&gt;, método de sync: &lt;…&gt;

---

## Autenticação e autorização

> Como tokens de auth, sessões ou API keys fluem entre os repos.

- Emissor do token: &lt;repo&gt;
- Formato do token: &lt;JWT / opaco / session cookie&gt;
- Consumidores: como validam
- Política de rotação: &lt;…&gt;

---

## Variáveis de ambiente que atravessam repos

> Vars que precisam ter o mesmo valor entre vários repos (URLs, secrets, feature flags).

| Variável | Repos que leem | Notas |
| --- | --- | --- |
| &lt;ex.: API_BASE_URL&gt; | &lt;backend, frontend&gt; | &lt;precisa bater por ambiente&gt; |

---

## Ordem de deploy

> Quando uma feature atravessa repos, em que ordem os deploys saem?

1. &lt;repo que entrega o contrato&gt; → `preview`
2. &lt;repo que consome o contrato&gt; → `preview`
3. Depois dos dois validados em preview: ambos → `main`

Regra: nunca deploy de consumidor para produção antes do contrato.

---

## Mudanças que quebram contrato

> Protocolo para mudar um contrato de forma que consumidores precisem se adaptar.

1. Abra a mudança de contrato no repo dono com nota clara de migração.
2. Abra issues filhas em cada repo consumidor, referenciando a issue do dono.
3. Faça primeiro a mudança aditiva (novo campo/endpoint), dê tempo para os consumidores adotarem.
4. Remova a forma antiga só depois que todo consumidor migrou.

Nunca quebre um contrato em um único deploy.
