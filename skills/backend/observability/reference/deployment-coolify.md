# Deploy: Prometheus central + Grafana único no Coolify

## Decisão: reaproveitar a VPS do Coolify, não criar VM nova

Prometheus + Grafana pra ~12-15 serviços com métricas RED/USE básicas (sem cardinalidade alta) consomem tipicamente 300-600MB de RAM e menos de 1 CPU em uso normal, e poucos GB de disco com retenção de 15-30 dias — ruído dentro de uma VPS de 32GB RAM / 10 CPU / 120GB já usada pelo Coolify. Criar VM dedicada agora seria escalar antes da dor (ver `scaling-architecture`).

O motivo mais forte pra ficar no mesmo host não é recurso, é rede: o Prometheus precisa alcançar o `/metrics` de cada serviço, e esse endpoint **não pode ficar exposto publicamente**. No mesmo host/rede Docker do Coolify, o scrape acontece por rede interna, sem nunca sair pra internet. Numa VM separada, isso forçaria expor `/metrics` publicamente (com auth) pra ser alcançável — pior postura de segurança e mais fricção.

### Mitigação do trade-off de estar no mesmo host

Monitoramento no mesmo host que ele monitora significa que, se o host cair inteiro, perde-se app e visibilidade ao mesmo tempo. Mitigação sem criar VM nova:

- **Limites de recurso** (CPU/RAM) nos containers de Prometheus/Grafana no Coolify, pra garantir que nunca disputam recurso com as apps de produção.
- **Heartbeat externo** simples (ex.: UptimeRobot gratuito, ou um cron numa VPS separada já existente) só pra detectar "o host inteiro caiu" — cobre o cenário mais grave sem duplicar a stack inteira de observabilidade.

Revisitar isolamento em infra própria só se o volume crescer pra dezenas de projetos ou exigir alta disponibilidade formal — outro caso de "sobe de degrau quando a métrica pedir".

## docker-compose (serviço Coolify)

```yaml
services:
  prometheus:
    image: prom/prometheus:latest
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - prometheus-data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.retention.time=30d'
    deploy:
      resources:
        limits:
          cpus: '1'
          memory: 1G
    networks:
      - coolify   # mesma rede dos serviços de aplicação, pra scrape interno

  grafana:
    image: grafana/grafana:latest
    volumes:
      - grafana-data:/var/lib/grafana
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=${GRAFANA_ADMIN_PASSWORD}
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
    networks:
      - coolify

volumes:
  prometheus-data:
  grafana-data:

networks:
  coolify:
    external: true
```

Publique só o Grafana atrás de domínio + HTTPS (proxy do Coolify) — o Prometheus nunca precisa de rota pública, só a rede interna.

`networks.coolify` acima **não é placeholder** — validado no primeiro deploy real (agendafacil-backend, 2026-09): o nome da rede Docker externa do Coolify é literalmente `coolify`. Use como está, sem precisar confirmar isso de novo por projeto.

⚠️ **Bug confirmado: bind mount de arquivo vira diretório vazio se o arquivo ainda não existe no host.** A linha `./prometheus.yml:/etc/prometheus/prometheus.yml:ro` é um bind mount relativo. Se `prometheus.yml` não existir no host no momento em que o Coolify aplica o compose pela primeira vez, o Docker **cria um diretório vazio** nesse caminho em vez de esperar um arquivo — e o Prometheus falha ao ler config de um diretório. Sintoma: serviço fica "Starting"/sem logs indefinidamente, ou o container nunca sai do estado "Created".

- **Prevenção (faça isso antes do primeiro deploy do compose):** garanta que `prometheus.yml` (mesmo que placeholder/vazio) já existe no host antes de subir o serviço pela primeira vez. Evita o problema de vez.
- **Se já aconteceu:** SSH no host → achar o diretório de trabalho do serviço (`/data/coolify/services/<uuid>/`, o `<uuid>` aparece no nome dos volumes do serviço, ex. `<uuid>_prometheus-data`) → `ls -la` pra confirmar que `prometheus.yml` é um diretório → `rmdir` (só funciona se estiver vazio) → criar o arquivo de verdade com `cat > .../prometheus.yml <<'EOF' ... EOF` → clicar **Redeploy** na UI do Coolify (`docker start` manual não reaplica o mount).

## `prometheus.yml` — scrape config

```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'financeiro-backend'
    static_configs:
      - targets: ['financeiro-backend:8000']   # nome do serviço na rede Docker do Coolify

  - job_name: 'ponto-backend'
    static_configs:
      - targets: ['controle-ponto-backend:8000']

  - job_name: 'agendafacil-backend'
    static_configs:
      - targets: ['agendafacil-backend:3000']
    metrics_path: /metrics/   # barra final se a app for Django — ver "Gotchas Django" abaixo
    authorization:
      credentials: '${AGENDAFACIL_METRICS_TOKEN}'   # ver "Autenticação do scrape" abaixo

  # um bloco novo por projeto, ao adicionar observabilidade nele
```

`job_name` é o valor que popula a label `job` usada pela variável `$servico` no dashboard modelo (ver `reference/dashboard.json`) — use o nome curto e estável do projeto, igual em todo lugar (issues, branch, repo).

### Autenticação do scrape (bearer token)

Se o `/metrics` do serviço exige token (ver "Postura de segurança" abaixo), use o campo nativo `authorization.credentials` do `scrape_configs`, não o `bearer_token` legado:

```yaml
authorization:
  credentials: '<token>'
```

Isso seta o header `Authorization: Bearer <token>` automaticamente — compatível com qualquer view que valide esse header manualmente (foi o padrão usado no `core/metrics.py` do agendafacil-backend).

## Checklist ao adicionar observabilidade a um projeto novo

1. Instrumentar o serviço seguindo `SKILL.md` deste skill (Express ou Django DRF) e a convenção de nome em `reference/naming-convention.md`. Em Django, antes de configurar o scrape, confirme os 3 itens da seção "Gotchas Django" abaixo, na ordem — cada um mascara o próximo com um erro diferente.
2. No resource "Application" do Coolify (Dockerfile único), ativar **"Consistent Name (no rolling updates)"** se o `/metrics` desse serviço vai ser raspado pelo Prometheus central (ver "Nome de container muda a cada redeploy" abaixo) — sem isso, o `static_configs` do scrape quebra a cada deploy do serviço alvo.
3. Garantir que a imagem runtime tem `curl` ou `wget` instalado antes de configurar qualquer healthcheck HTTP no Coolify (ver "Healthcheck sem curl/wget" abaixo) — sem isso, o serviço inteiro pode sair do ar quando o Traefik recusa rotear pra um container unhealthy.
4. Se `prometheus.yml` (ou qualquer config referenciada por bind mount) ainda não existir no host, criar o arquivo (mesmo que placeholder) antes do primeiro deploy do compose (ver bug de bind mount acima).
5. Revisar cada env var sensível do projeto no Coolify e desligar "Available during build" pra tudo que o Dockerfile não usa via `ARG` (ver "Vazamento de segredos via build args" abaixo).
6. Confirmar que `/metrics` só responde dentro da rede interna do Coolify (não tem rota pública configurada pra ele) — se isolar na rede interna for inviável nesse projeto, proteger com bearer token forte é o mínimo aceitável (ver "Postura de segurança" abaixo) e essa exceção deve ser uma decisão consciente, documentada, não um esquecimento.
7. Adicionar um bloco `scrape_configs` novo no `prometheus.yml` central apontando pro nome do serviço na rede Docker.
8. Redeployar o Prometheus (recarrega config) e confirmar o novo target em `Status → Targets` na UI do Prometheus.
9. Confirmar que o serviço aparece no dropdown `$servico` do dashboard modelo no Grafana. Se importar o `dashboard.json` pela primeira vez nesse Grafana, ver "Import do dashboard.json" abaixo — o placeholder de datasource não vai resolver sozinho.
10. Depois de qualquer mudança em healthcheck, rodar `docker inspect <container> --format='{{json .State.Health}}'` e confirmar `"Status": "healthy"` antes de considerar o trabalho concluído — "container Up" não é "container healthy", e "healthy" não é "rota pública funciona" (confirme a rota também).

## Lições do primeiro deploy real (agendafacil-backend, 2026-09)

Achados operacionais do primeiro projeto instrumentado com este skill em produção. Ler antes de repetir os mesmos erros no próximo projeto.

### Nome de container muda a cada redeploy (quebra o scrape)

Resource "Application" do Coolify (Dockerfile único, deploy blue-green) gera um nome de container novo a cada redeploy (sufixo timestamp, ex. `iq8qp30ipni9nlexgfcw3jhs-202054630845`), sem alias de rede estável por padrão — quebra qualquer `static_configs` fixo do Prometheus a cada novo deploy do serviço alvo.

**Solução:** ativar a opção avançada **"Consistent Name (no rolling updates)"** nesse resource — fixa o nome do container (ex. `agendafacil-api`) permanentemente. **Trade-off explícito e aceito:** perde-se o deploy blue-green zero-downtime; vira "para o container antigo, sobe o novo" (janela curta de downtime a cada deploy). Qualquer projeto cujo `/metrics` vá ser raspado pelo Prometheus central deveria ativar essa opção desde o início, aceitando esse trade-off conscientemente — documente a troca no README/runbook do próprio projeto, não só o "como fazer".

### Gotchas Django ao expor `/metrics` (cascata de 3 erros diferentes)

Cada um destes mascara o seguinte — resolva na ordem, ou vai parecer que são 3 bugs não relacionados:

1. **`metrics_path` sem barra final.** `path("metrics/", ...)` no Django exige `metrics_path: /metrics/` no scrape config (barra incluída). Sem a barra, `APPEND_SLASH` do Django devolve 301 e o scrape falha.
2. **`ALLOWED_HOSTS` sem o nome do container.** O Prometheus faz scrape usando o nome/alias do container na rede interna (ex. `agendafacil-api`) como Host header. Se não estiver em `ALLOWED_HOSTS`, Django devolve 400 Bad Request — fácil de confundir com problema de token/bearer, mas não tem relação.
3. **`SECURE_SSL_REDIRECT=True` derruba o scrape com timeout, não com redirect.** Comum em prod Django, redireciona qualquer request HTTP sem `X-Forwarded-Proto: https` pra HTTPS. O scrape interno do Prometheus é HTTP puro na rede Docker (não passa pelo proxy TLS) e a porta interna do app só fala HTTP — então o redirect não acontece de forma limpa, o resultado é timeout/handshake failure ("context deadline exceeded"). **Fix:** adicionar o path de métricas ao `SECURE_REDIRECT_EXEMPT`, igual já era feito pro healthcheck:
   ```python
   SECURE_REDIRECT_EXEMPT = [r"^api/health/?$", r"^metrics/?$"]
   ```

Ver também a seção Django DRF em [SKILL.md](../SKILL.md) — o middleware de métricas HTTP genérico que complementa o `django-prometheus`.

### Healthcheck sem `curl`/`wget` derruba a rota pública inteira (achado crítico, causou incidente real)

O healthcheck HTTP do Coolify roda `curl`/`wget` **de dentro do container-alvo**, não do host. Se a imagem runtime (ex. `python:3.11-slim`) não tiver nenhum dos dois binários, o healthcheck falha pra sempre ("curl: not found") e o container fica permanentemente `unhealthy`. **O Traefik v3 (proxy padrão do Coolify) recusa rotear tráfego externo pra um container que o Docker considera unhealthy** — configurar mal (ou deixar quebrado sem querer) o healthcheck pode derrubar a aplicação pública INTEIRA, mesmo com o app 100% saudável por dentro. Isso aconteceu no agendafacil-backend e causou incidente real (API de produção fora do ar por um tempo).

**Checklist obrigatório:**
- (a) garantir `curl` ou `wget` instalado na imagem runtime **antes** de configurar qualquer healthcheck HTTP no Coolify;
- (b) depois de configurar/mudar um healthcheck, rodar `docker inspect <container> --format='{{json .State.Health}}'` e confirmar `"Status": "healthy"` antes de considerar o trabalho concluído — nunca assumir "container Up" = "container healthy" = "rota pública funciona";
- (c) se uma rota pública some ("no available server" do Traefik) logo depois de mexer em healthcheck, **esse é o primeiro lugar a checar**, antes de suspeitar de rede/labels/DNS.

### Labels customizados do Traefik: operação de alto risco

O campo de labels customizados fica numa aba/seção "Labels" no resource do Coolify (não confundir com "Tags", que é só categorização cosmética, sem efeito no container). Tem um toggle **"Managed by Coolify (auto-generated)"** vs. **"Managed manually"** — no modo automático, o Coolify sobrescreve esse campo inteiro a cada redeploy, apagando qualquer customização. Trocar pra manual faz a customização sobreviver a redeploys, mas também significa que mudanças futuras na aba Domains (novo domínio, troca de porta) **não se propagam mais automaticamente** pros labels — exige edição manual depois.

**Cuidado documentado:** uma tentativa de adicionar uma regra de bloqueio customizada (router+middleware Traefik pra negar acesso externo a um path específico) quebrou o roteamento do app inteiro ("no available server" em todas as rotas, não só a pretendida) mesmo com sintaxe aparentemente válida. Não foi possível confirmar com certeza total a causa raiz — o Traefik desse Coolify gera duas famílias de labels simultâneas (Traefik e Caddy), e paralelamente havia também um healthcheck quebrado (ver seção acima). A causa real do "no available server" acabou sendo o healthcheck, não os labels — mas isso só foi descoberto **depois** de reverter os labels sem resolver o problema.

**Recomendação:** editar labels do Traefik manualmente num resource de produção é alto risco. Teste sintaxe isoladamente antes se possível, tenha os labels originais salvos pra revert rápido, e ao diagnosticar problemas de roteamento cheque **também** o healthcheck/status do container antes de assumir que a causa é labels.

### Vazamento de segredos via build args

Por padrão, toda env var configurada num resource "Application" do Coolify é passada como `--build-arg` pro `docker build` — aparece em texto plano no log de build completo (inclusive num bloco "Final Dockerfile" que o Coolify imprime com todos os ARGs, visível a qualquer um com acesso aos logs de deploy) **e** é injetada em runtime. São dois toggles independentes por variável: "Build time: Available during build / Not available during build" e "Runtime: Available in the container".

Se o Dockerfile do projeto não usa `ARG <nome>` pra uma variável (o caso comum — muitos Dockerfiles não precisam de segredo nenhum em build time), é seguro e recomendado desligar "Available during build" sem afetar runtime. **Antes do primeiro deploy de qualquer projeto novo no Coolify, revise cada env var e desligue "Available during build" pra tudo que não seja genuinamente necessário no build** (a lista de exceções costuma ser curta ou vazia).

### Build mais rápido com cache de pip (BuildKit)

Build de Dockerfile Python sem cache de pip demorava ~6min no agendafacil-backend, majoritariamente baixando/compilando pacotes do zero a cada deploy mesmo sem mudança no `requirements.txt`. Fix:

```dockerfile
# syntax=docker/dockerfile:1
...
RUN --mount=type=cache,target=/root/.cache/pip pip install --user -r requirements.txt
```

Remova `--no-cache-dir` do `pip install` se ele já estiver lá — contradiz o propósito do cache mount. Vale como padrão pra qualquer Dockerfile Python novo no Coolify.

### Import do `dashboard.json` no Grafana

O dashboard modelo usa `${DS_PROMETHEUS}` como placeholder de datasource, mas **sem declarar `__inputs`/`__requires`** no JSON — por isso a tela padrão de "Upload/paste JSON" do Grafana não pergunta qual datasource usar (esse prompt só aparece se `__inputs` estiver declarado), e o placeholder fica como texto literal não resolvido. Isso quebra todos os painéis e a variável `$servico` silenciosamente ("No data" em tudo, sem erro claro na tela principal — só um ícone de alerta discreto ao lado do dropdown).

**Fix manual necessário hoje:** pegar o UID real do datasource (Connections → Data sources → Prometheus → UID na URL) e fazer find-replace de `${DS_PROMETHEUS}` por esse UID direto em Dashboard Settings → JSON Model, depois salvar.

**Decisão editorial:** não alteramos o `dashboard.json` pra adicionar `__inputs`/`__requires` agora — a estrutura correta desse bloco (lista de inputs + `requires` com versão de plugin) é fácil de escrever errado sem uma instância Grafana à mão pra validar que o prompt de import realmente aparece, e um dashboard de referência quebrado é pior que o workaround manual documentado aqui. Fica como recomendação pra quem tiver ambiente de teste disponível.

**Gotcha adicional — schema v2:** versões mais novas do Grafana (confirmado numa instância `grafana/grafana:latest`) usam um schema de dashboard **v2** (`apiVersion: dashboard.grafana.app/v2`), diferente do schema clássico deste `dashboard.json` (`schemaVersion: 39`, `panels: []` plano). No v2, cada painel fica em `spec.elements` (chave `panel-N`), a posição/grid fica separada em `spec.layout.spec.items[]` (referenciando o elemento por nome), e o datasource é referenciado só por `{"name": "<uid-ou-nome>"}`, não por `{"type":"prometheus","uid":"..."}`. O Grafana parece migrar/exibir dashboards importados nesse schema v2 mesmo quando o JSON original importado era v1-clássico — não é motivo de alarme se o JSON deste arquivo continuar v1 (o import ainda funciona), só uma diferença a esperar ao inspecionar o JSON depois de importado num Grafana recente.

### Postura de segurança aceita: `/metrics` no domínio público (agendafacil-backend)

O `/metrics` do agendafacil-backend fica no **mesmo domínio público da API**, não isolado só na rede interna como a regra padrão deste skill recomenda (ver "Regras inegociáveis" no `SKILL.md`) — protegido só pelo bearer token. Decisão consciente do usuário, tomada depois que uma tentativa de reforçar com bloqueio de rede via Traefik já havia causado o incidente de produção descrito acima. Isso é um trade-off aceito por ora (bearer token forte é considerado suficiente), não um bug pendente — mas fica registrado que existe a opção de reforçar com bloqueio de rede no futuro, com mais cautela e testando a mudança isolada antes de aplicar em produção.

### Nota: métricas de fila (Celery)

Um plano de métricas de saturação de fila do Celery (`..._queue_messages_pending`/`..._queue_messages_failed_total`, ver `reference/naming-convention.md`) está em elaboração como possível expansão deste padrão — ainda não aprovado nem implementado. Trate como item futuro, não como parte do checklist atual.
