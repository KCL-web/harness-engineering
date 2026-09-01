---
name: security-audit
description: Auditoria de segurança completa do projeto (6 categorias: isolamento de tenant, autorização client-side, IDOR, segredos hardcoded, XSS, armazenamento inseguro de token de auth), com relatório em PDF e issues prontas para o tracker. Invoque para validação final antes de release/PR develop→main, ou na FASE 0 do bootstrap quando o projeto já tem código (para surfacear falhas logo no início). Diferente da skill genérica `security-review` (revisão de diff) — esta é uma auditoria completa do código-fonte, mais pesada, com saída em PDF.
disable-model-invocation: true
---

# Auditoria de segurança do projeto

Revisa o código atrás de **seis** falhas de segurança. Antes de começar, detecte a stack do projeto (linguagem, framework, ORM/query builder, mecanismo de auth, frontend, arquivos de deploy como Docker/CI/Helm/Terraform) e adapte cada categoria ao equivalente dessa stack.

## Quando rodar

- **Validação final do projeto** — antes de um PR `develop → main`, ou quando o dev pedir uma auditoria de segurança pontual.
- **FASE 0 do bootstrap, em projeto EXISTENTE** — depois do sumário curto da análise (ver `commands/bootstrap.md` → FASE 0), ofereça rodar esta auditoria completa antes de seguir a entrevista, para já indicar falhas de segurança logo no início em vez de descobri-las depois. É pesada — confirme com o dev antes de disparar, não rode sem perguntar.

## As seis categorias

### 1. Banco sem tranca (isolamento de inquilino/dono)

Em Supabase é RLS ausente; em APIs próprias são queries de listagem/busca/agregação/relatório/exportação que não filtram pelo usuário autenticado ou pela organização/workspace/tenant ao qual ele pertence. Identifique primeiro **qual** é o mecanismo de isolamento do projeto (RLS, middleware de tenant, filtro manual por `user_id`, etc.) e aponte onde ele está ausente ou furado.

### 2. Permissão definida no navegador

Operações privilegiadas (admin, configurações, gestão de usuários, ações de escrita) em que o frontend esconde a UI por papel (`isAdmin`, `canEdit`, `role`...) mas o servidor **não** faz a verificação equivalente. Cruze cada gate de papel do frontend com o endpoint correspondente e confirme se o backend valida o privilégio em toda rota sensível.

### 3. IDOR

Rotas que buscam, alteram ou deletam um objeto por ID (path, query ou body) sem verificar se o objeto pertence ao usuário/tenant do chamador. Percorra sistematicamente **todos** os handlers de rota do backend, não amostras.

### 4. Chaves expostas (hardcode)

API keys, tokens, senhas, segredos de assinatura (JWT, webhooks), chaves privadas e credenciais padrão embutidos no código-fonte, configs, docker-compose, charts, CI, scripts e documentação. Atenção especial a defaults públicos que viram segredo real se não forem sobrescritos (ex.: `${VAR:-valor-default}`) e à ausência de validação de startup que rejeite esses defaults. Verifique também o histórico git por segredos commitados e o bundle do frontend por chaves embutidas.

### 5. Inputs sem tratamento (XSS)

No frontend: `innerHTML`/`dangerouslySetInnerHTML`/equivalentes do framework (`v-html`, `[innerHTML]`, `dangerouslySet...`), renderização de markdown/HTML sem sanitização, URLs controladas por usuário em `href`/`src` (`javascript:`), `eval`/`new Function`. No backend: input do usuário entrando em HTML de e-mails, templates ou respostas sem escape. Verifique se existe lib de sanitização no projeto e se ela é aplicada nos pontos encontrados.

### 6. Token de autenticação em armazenamento inseguro

Verifique **onde** o token/sessão de autenticação é persistido no cliente:

- `localStorage`/`sessionStorage` são acessíveis via JS e portanto vulneráveis a exfiltração via XSS.
- Cookie sem `HttpOnly` tem o mesmo problema (qualquer XSS lê `document.cookie`).
- **A preferência é sempre cookie `HttpOnly`** (+ `Secure` + `SameSite=Lax` ou `Strict`) definido pelo servidor, nunca legível por JS do lado cliente.

Verifique especificamente:

- Mecanismo de storage usado — grep por `localStorage.setItem`/`getItem` de token, `sessionStorage`, ou `Set-Cookie` sem `HttpOnly`.
- Se o cookie tem os atributos `Secure` e `SameSite` corretos para o contexto (cross-site vs same-site).
- Se existe proteção CSRF complementar quando cookies são usados para autenticação — necessária porque `HttpOnly` protege contra leitura via XSS mas **não** contra CSRF: double-submit token, header customizado (`X-Requested-With`/token custom que CSRF não consegue setar cross-origin), ou `SameSite=Strict` quando o fluxo permite.
- Se o refresh token (se houver) segue a mesma regra de armazenamento.

Aponte cada lugar que usa `localStorage`/`sessionStorage` para token como achado de **severidade alta** (exposição a XSS), e recomende migração para cookie `HttpOnly` com as boas práticas acima. Se o projeto não tem frontend com sessão de usuário (ex.: API pura machine-to-machine com API key), declare a categoria não aplicável em vez de forçar achado.

## Regras da auditoria

- Reporte apenas achados verificados no código real. Nada de especulação. Para cada achado: caminho do arquivo, número(s) exato(s) da linha, trecho do código, por que é explorável e severidade (crítica/alta/média/baixa/informativa).
- Liste arquivo por arquivo, linha por linha.
- Registre também o que foi verificado e está **correto** (ex.: "router X valida posse em todos os handlers") — isso vira a seção de pontos fortes e prova a cobertura da auditoria.
- Quando a categoria não se aplicar à stack (ex.: projeto sem frontend), diga isso explicitamente em vez de forçar achados.
- Note condições de explorabilidade (feature flags, config insegura necessária, etc.).

## Relatório em PDF

Depois da auditoria, gere um **RELATÓRIO EM PDF**, visualmente amigável, em pt-BR, salvo em `docs/security-audit/relatorio-auditoria-seguranca.pdf`, contendo:

**a) Capa** — título "Relatório de Auditoria de Segurança — `<nome do projeto>`", data, escopo auditado e nota metodológica (como cada categoria foi mapeada para a stack detectada).

**b) Resumo executivo** — total de achados por severidade, gráfico de rosca por severidade e gráfico de barras por categoria (7 categorias agora, incluindo a #6). Paleta: crítica `#B91C1C`, alta `#EA580C`, média `#D97706`, baixa `#2563EB`, ponto forte `#059669`.

**c) Pontos fortes** (o que está protegido, com evidência) e **pontos fracos** (os riscos centrais).

**d) Tabela de achados detalhados por categoria** — Severidade | Arquivo:linha | Descrição, com chip de severidade colorido.

**e) Recomendações priorizadas** (P1, P2, P3...).

**f) Ao final do PDF, uma seção "ISSUES PARA O TRACKER"** — este projeto usa **Forgejo** como tracker (nunca GitHub — ver `workflow-issues`; GitHub é só espelho de backup). Para cada achado acionável, o texto **completo** de uma issue em Markdown, pronto para copiar e colar ou publicar via API do Forgejo (`workflow-issues`), dentro de um bloco delimitado (`--- ISSUE n ---` / `--- FIM ISSUE n ---`). Cada issue deve conter:

- Título no formato `[Segurança] <descrição curta da falha>`
- Labels sugeridas: `security` + label de severidade (crie-as via `workflow-issues` se ainda não existirem no Forgejo do projeto)
- Descrição do problema e por que é explorável
- Evidência: arquivo:linha com trecho de código
- Impacto
- Sugestão de correção
- Critérios de aceite (checklist verificável — mesmo formato do template de issue em `workflow-issues`)

Agrupe achados triviais relacionados numa issue única quando fizer sentido (ex.: vários defaults de segredo no mesmo tema), para não gerar spam de issues.

## Geração do PDF — regras técnicas

- Não instale nada globalmente. Use ambiente isolado (venv Python com `reportlab`+`matplotlib`, ou ferramenta equivalente da stack local; se houver navegador headless/`wkhtmltopdf`/`pandoc` disponível, HTML→PDF também vale).
- Deixe o script gerador em `docs/security-audit/` para regerar o relatório depois.
- Verifique o PDF gerado: número de páginas, renderização dos gráficos e legibilidade das tabelas (rasterize as páginas se possível). Corrija defeitos visuais antes de entregar.
- Páginas A4, margens ~2cm, cabeçalho/rodapé com nome do relatório e número de página.

## Entrega final

Ao terminar, entregue:

1. O relatório em PDF.
2. A lista de achados no chat (arquivo por arquivo, linha por linha).
3. O caminho de todos os arquivos gerados.

## Skills relacionadas

- Revisão leve de diff (não substitui esta auditoria completa): skill genérica `security-review`
- Publicar as issues geradas no Forgejo: `workflow-issues`
- FASE 0 de bootstrap em projeto existente: ver `commands/bootstrap.md`
- Métricas de qualidade que só podem melhorar: `ratchet-feature-list`
