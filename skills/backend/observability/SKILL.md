---
name: observability
description: Convenção de métricas RED/USE e topologia Prometheus central (pull) + Grafana único, compartilhada por todos os projetos. Invoque ao instrumentar uma API nova com métricas, ou ao configurar/consultar o Prometheus/Grafana do Coolify.
---

# Observability (métricas)

Um serviço só sabe em que degrau de `scaling-architecture` está se ele expõe números. O objetivo aqui não é "medir tudo" — é medir o mínimo que responde "está lento?", "está quebrando?", "está perto do limite?", com o **mesmo nome de métrica em todos os projetos**, pra um único Grafana servir a todos sem tradução manual.

## O que medir

**RED, por serviço/endpoint:**
- **R**ate — requisições por segundo
- **E**rrors — taxa de erro (não só contagem)
- **D**uration — latência em percentis (p50/p95/p99 — nunca só a média)

**USE, por recurso (CPU, memória, banco, fila):**
- **U**tilization — % de uso
- **S**aturation — quanto está na fila esperando (conexões de banco represadas, mensagens acumuladas)
- **E**rrors — erros do próprio recurso (timeout de conexão, etc.)

## Convenção de nome (obrigatória)

```
<servico>_http_requests_total{method, route, status}
<servico>_http_request_duration_seconds{method, route}
<servico>_db_query_duration_seconds{operation}
<servico>_queue_messages_pending{queue}
```

`<servico>` é o nome curto do projeto (`financeiro_backend`, `controle_ponto_backend`, `agendafacil_backend`...). Sem essa convenção fixa, cada projeto inventa nome próprio e o dashboard único deixa de funcionar — a convenção é o que torna um Grafana compartilhado possível. Especificação completa de labels em [reference/naming-convention.md](reference/naming-convention.md).

## Topologia: um Prometheus central, um Grafana único

Não crie Prometheus/Grafana por projeto, e não crie VM nova só pra isso. Roda como mais um serviço no Coolify existente, ao lado dos projetos: o Prometheus central faz *pull* (scrape) do endpoint `/metrics` de cada serviço periodicamente, e o mesmo Grafana serve dashboards de todos os projetos via a variável `$servico`.

```
financeiro-backend  ──/metrics──┐
ponto-backend        ──/metrics──┤
agendafacil-backend  ──/metrics──┼──►  Prometheus (central, 1 instância)  ──►  Grafana (único)
valentina-backend    ──/metrics──┤
as-link-backend      ──/metrics──┘
```

Detalhes de deploy (docker-compose pro Coolify, scrape config, sizing de recursos, checklist de rede/segurança) em [reference/deployment-coolify.md](reference/deployment-coolify.md). Dashboard modelo, parametrizado por `$servico`, em [reference/dashboard.json](reference/dashboard.json).

## Instrumentação por stack

### Express

```ts
// metrics.ts
import client from 'prom-client';

const register = new client.Registry();
client.collectDefaultMetrics({ register, prefix: 'meuservico_' });

export const httpRequestsTotal = new client.Counter({
  name: 'meuservico_http_requests_total',
  help: 'Total de requisições HTTP',
  labelNames: ['method', 'route', 'status'],
  registers: [register],
});

export const httpRequestDuration = new client.Histogram({
  name: 'meuservico_http_request_duration_seconds',
  help: 'Duração da requisição HTTP em segundos',
  labelNames: ['method', 'route'],
  buckets: [0.01, 0.05, 0.1, 0.3, 0.5, 1, 2, 5],
  registers: [register],
});

export function metricsMiddleware(req, res, next) {
  const end = httpRequestDuration.startTimer({ method: req.method, route: req.route?.path ?? req.path });
  res.on('finish', () => {
    end();
    httpRequestsTotal.inc({ method: req.method, route: req.route?.path ?? req.path, status: res.statusCode });
  });
  next();
}

export { register };
```

```ts
// app.ts
app.use(metricsMiddleware);
app.get('/metrics', async (_req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});
```

### Django DRF

```python
# requirements: django-prometheus

INSTALLED_APPS = [
    'django_prometheus',
    # ... resto dos apps
]

MIDDLEWARE = [
    'django_prometheus.middleware.PrometheusBeforeMiddleware',
    # ... resto do middleware
    'django_prometheus.middleware.PrometheusAfterMiddleware',
]
```

```python
# urls.py
urlpatterns = [
    path('', include('django_prometheus.urls')),  # expõe /metrics
    # ... resto das rotas
]
```

`django-prometheus` já expõe `django_http_requests_total_by_view_transport_method` e latência por view no formato Prometheus — o prefixo `<servico>_` some do nome nesse caso; use a label `job`/`instance` do scrape config (ver [reference/deployment-coolify.md](reference/deployment-coolify.md)) pra distinguir serviço no Grafana em vez de prefixo no nome da métrica.

**`django-prometheus` sozinho não basta pra bater com o dashboard modelo** — achado do primeiro deploy real (agendafacil-backend). Os nomes/labels que ele expõe (`django_http_requests_total_by_view_transport_method_total`, com label `view`, sem `status` na mesma série) não batem com a convenção `..._http_requests_total{method,route,status}`/`..._http_request_duration_seconds{method,route}` de `reference/naming-convention.md`, nem com o que o dashboard modelo espera pra popular painéis e o dropdown `$servico` (`label_values(http_requests_total, job)`). O padrão que funcionou em produção: um middleware Django custom que **complementa** o `django-prometheus` (que segue cobrindo DB/processo) expondo as duas métricas genéricas exigidas pela convenção:

```python
# core/middleware.py
import time
from prometheus_client import Counter, Histogram

http_requests_total = Counter(
    'http_requests_total', 'Total de requisições HTTP',
    ['method', 'route', 'status'],
)
http_request_duration_seconds = Histogram(
    'http_request_duration_seconds', 'Duração da requisição HTTP em segundos',
    ['method', 'route'],
    buckets=[0.01, 0.05, 0.1, 0.3, 0.5, 1, 2, 5],
)

class HttpMetricsMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        start = time.monotonic()
        response = self.get_response(request)
        # resolver_match.route é o padrão da rota (/agendamentos/<id>), nunca o path
        # resolvido — requests sem match (scanners, 404 em path aleatório) viram
        # route="unmatched" pra não explodir cardinalidade.
        route = request.resolver_match.route if request.resolver_match else 'unmatched'
        http_requests_total.labels(method=request.method, route=route, status=response.status_code).inc()
        http_request_duration_seconds.labels(method=request.method, route=route).observe(time.monotonic() - start)
        return response
```

```python
MIDDLEWARE = [
    'django_prometheus.middleware.PrometheusBeforeMiddleware',
    'core.middleware.HttpMetricsMiddleware',   # logo depois do PrometheusBeforeMiddleware
    # ... resto do middleware
    'django_prometheus.middleware.PrometheusAfterMiddleware',
]
```

Isso deveria ser o padrão pra qualquer projeto Django novo — instrumentar "seguindo a convenção" sem esse middleware deixa o dashboard modelo sem dados nos painéis de Rate/Errors/Duration.

**Antes de configurar o scrape pro `/metrics` de um app Django em produção**, confirme estes 3 itens nesta ordem — cada um produz um erro diferente e não óbvio (404/301, 400, timeout) que parece não relacionado ao anterior. Detalhe de cada um em "Gotchas Django" no [reference/deployment-coolify.md](reference/deployment-coolify.md#gotchas-django-ao-expor-metrics-cascata-de-3-erros-diferentes):

1. `metrics_path` do scrape config com barra final, igual à URL Django (`/metrics/`).
2. `ALLOWED_HOSTS` incluindo o nome/alias do container usado como scrape target.
3. `SECURE_REDIRECT_EXEMPT` incluindo o path de métricas, se `SECURE_SSL_REDIRECT=True`.

## Regras inegociáveis

- `/metrics` nunca exposto publicamente sem proteção — só acessível pela rede interna do Coolify (Prometheus fala com os containers pela rede Docker), nunca solto na internet. **Exceção aceita conscientemente, não padrão:** se isolamento de rede for operacionalmente inviável/arriscado no projeto (ex.: tentativa de bloqueio via label Traefik já causou incidente — ver caso real do agendafacil-backend em [reference/deployment-coolify.md](reference/deployment-coolify.md)), bearer token forte via `authorization.credentials` no scrape config é o mínimo compensador aceitável — mas isso é decisão explícita e documentada por projeto, nunca o default de um projeto novo.
- Nomenclatura de métrica segue a convenção deste skill em todo projeto novo — sem exceção, sem nome inventado por projeto.
- Latência sempre em percentis (p95 no mínimo); nunca reporte só a média.
- Job/serviço curto que morre em segundos (batch, script) não usa scrape — usa Pushgateway ou OpenTelemetry Collector (push), não force o modelo pull nesse caso.

## Skills relacionadas

- Quando subir de degrau de arquitetura com base nessas métricas: `scaling-architecture`
- Infra Coolify onde Prometheus/Grafana rodam: `infra-forgejo-coolify`
- API de apoio Node/Express: `backend/express`
- Convenções Django/DRF: `backend/django-drf`
