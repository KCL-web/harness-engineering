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

  # um bloco novo por projeto, ao adicionar observabilidade nele
```

`job_name` é o valor que popula a label `job` usada pela variável `$servico` no dashboard modelo (ver `reference/dashboard.json`) — use o nome curto e estável do projeto, igual em todo lugar (issues, branch, repo).

## Checklist ao adicionar observabilidade a um projeto novo

1. Instrumentar o serviço seguindo `SKILL.md` deste skill (Express ou Django DRF) e a convenção de nome em `reference/naming-convention.md`.
2. Confirmar que `/metrics` só responde dentro da rede interna do Coolify (não tem rota pública configurada pra ele).
3. Adicionar um bloco `scrape_configs` novo no `prometheus.yml` central apontando pro nome do serviço na rede Docker.
4. Redeployar o Prometheus (recarrega config) e confirmar o novo target em `Status → Targets` na UI do Prometheus.
5. Confirmar que o serviço aparece no dropdown `$servico` do dashboard modelo no Grafana.
