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

## Regras inegociáveis

- `/metrics` nunca exposto publicamente sem proteção — só acessível pela rede interna do Coolify (Prometheus fala com os containers pela rede Docker), nunca solto na internet.
- Nomenclatura de métrica segue a convenção deste skill em todo projeto novo — sem exceção, sem nome inventado por projeto.
- Latência sempre em percentis (p95 no mínimo); nunca reporte só a média.
- Job/serviço curto que morre em segundos (batch, script) não usa scrape — usa Pushgateway ou OpenTelemetry Collector (push), não force o modelo pull nesse caso.

## Skills relacionadas

- Quando subir de degrau de arquitetura com base nessas métricas: `scaling-architecture`
- Infra Coolify onde Prometheus/Grafana rodam: `infra-forgejo-coolify`
- API de apoio Node/Express: `backend/express`
- Convenções Django/DRF: `backend/django-drf`
