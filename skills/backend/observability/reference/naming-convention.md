# Convenção de nomenclatura de métricas

## Por que isso importa mais que a ferramenta

O que torna um Grafana **único** possível pra todos os projetos não é Prometheus nem Grafana — é o nome da métrica ser igual em todo lugar. Um dashboard com a query `rate(http_requests_total{servico="$servico"}[5m])` só funciona pra qualquer projeto se todos exportarem `http_requests_total` com uma label `servico` preenchida. Se cada projeto inventa `req_count`, `total_requests`, `api_hits`, o dashboard único vira ficção.

## Prefixo vs. label

Duas formas válidas de identificar o serviço — escolha uma por stack e não misture dentro do mesmo projeto:

1. **Prefixo no nome** (`financeiro_backend_http_requests_total`) — usado quando a lib de instrumentação permite prefixo fácil (`prom-client` no Express, via `client.collectDefaultMetrics({ prefix })` e nome explícito no `Counter`/`Histogram`).
2. **Label `job`/`servico` no scrape config** (nome da métrica fica genérico, `http_requests_total`, e o Prometheus adiciona a label na hora do scrape) — necessário quando a lib já vem com nome fixo (caso do `django-prometheus`, que expõe `django_http_requests_total_by_view_transport_method`).

Em ambos os casos, o dashboard modelo (`reference/dashboard.json`) usa a variável `$servico` resolvida a partir da label `job` do scrape — configure o `job_name` do Prometheus com o nome curto do projeto (ver `reference/deployment-coolify.md`) independente de qual das duas formas acima o serviço usa.

## Métricas obrigatórias por serviço HTTP

| Métrica | Tipo | Labels | O que responde |
| --- | --- | --- | --- |
| `..._http_requests_total` | Counter | `method`, `route`, `status` | Rate e taxa de erro (RED: R, E) |
| `..._http_request_duration_seconds` | Histogram | `method`, `route` | Latência em percentis (RED: D) |

## Métricas obrigatórias por recurso (quando aplicável)

| Métrica | Tipo | Labels | O que responde |
| --- | --- | --- | --- |
| `..._db_query_duration_seconds` | Histogram | `operation` | Latência de query (USE: U, indireto) |
| `..._db_connections_in_use` | Gauge | — | Saturação do pool de conexão (USE: S) |
| `..._queue_messages_pending` | Gauge | `queue` | Saturação de fila (USE: S) |
| `..._queue_messages_failed_total` | Counter | `queue` | Erros de processamento (USE: E) |

## Regras de label

- `route` é o **padrão** da rota (`/agendamentos/:id`), nunca o path resolvido com valores reais (`/agendamentos/42`) — isso explode cardinalidade e derruba o Prometheus em volume alto.
- Nunca use como label um valor de alta cardinalidade: `user_id`, `email`, `request_id`, IDs de qualquer entidade. Se precisar investigar por usuário específico, isso é trabalho de log/trace, não de métrica.
- `status` é o código HTTP inteiro (`200`, `404`, `500`), não uma categoria agregada — agregação por faixa (`2xx`/`5xx`) é feita na query do Grafana, não na hora de gravar.

## Buckets de histograma

Buckets de latência (em segundos) sugeridos como padrão pra toda API de request/response síncrona:

```
[0.01, 0.05, 0.1, 0.3, 0.5, 1, 2, 5]
```

Ajuste só se o serviço tiver um perfil de latência claramente diferente (ex.: um endpoint de relatório pesado que normalmente passa de 5s) — nesse caso, documente o desvio no `SKILL.md`/README do próprio projeto pra quem for ler o dashboard não estranhar.
