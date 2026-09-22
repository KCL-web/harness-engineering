---
name: scaling-architecture
description: Escada de padrões arquiteturais por volume de requisição (1k → 1M+/dia), de monólito+cache até edge routing multi-região. Invoque ao decidir infraestrutura para tráfego crescente, avaliar se é hora de migrar de arquitetura, ou explicar trade-offs de escalonamento pro dev.
---

# Scaling Architecture

Cada degrau desta escada resolve uma dor específica que só aparece num certo volume de tráfego. **Não pule degraus por antecipação** — arquitetura pra um volume que você não tem ainda é custo e complexidade sem retorno, e cada degrau tem uma dor operacional própria (fila assíncrona é mais difícil de debugar que chamada síncrona, service mesh exige operação séria, multi-região é o nível mais caro que existe).

## A escada

| Tráfego/dia | Padrão | Dor que resolve |
| --- | --- | --- |
| ~1k | Monólito + cache in-memory | Reconsultas repetidas no banco |
| ~10k | API Gateway + Service Directory | Múltiplas instâncias precisam de um ponto único de entrada |
| ~50k | Arquitetura orientada a eventos (RabbitMQ) | Acoplamento síncrono em cadeia vira gargalo/timeout em cascata |
| ~100k | Service Mesh (Istio) + gRPC | Muitos serviços conversando entre si precisam de padrão e observabilidade automática |
| ~500k | Kafka streaming + CQRS | Volume de eventos e leitura/escrita competindo pelo mesmo banco |
| 1M+ | Edge Routing + Kubernetes multi-região | Latência geográfica e disponibilidade global |

Walkthrough completo de cada degrau (o que muda na prática, quando migrar, armadilhas comuns) em [reference/ladder.md](reference/ladder.md).

## Regra de ouro: meça, não adivinhe

A decisão de subir de degrau nunca é por intuição — é por métrica. Golden signals (RED/USE) instrumentados desde o degrau 1 são o que te diz, com número, quando a dor de um degrau apareceu de verdade. Ver `backend/observability` para a convenção de métricas e a topologia de Prometheus/Grafana usada em todos os projetos.

## Regras inegociáveis

- Nenhuma migração de degrau sem a dor correspondente já estar acontecendo em produção (gargalo real, não hipotético) — nunca "vamos precisar um dia".
- Toda decisão de subir de degrau é justificada por métrica (latência subindo, taxa de erro subindo, saturação de recurso), nunca só por achismo.
- Cada degrau deve funcionar sozinho antes de somar o próximo — não implemente dois degraus de uma vez.

## Skills relacionadas

- Convenção de métricas e topologia Prometheus/Grafana: `backend/observability`
- Infra atual (Forgejo + Coolify): `infra-forgejo-coolify`
- Decisão ou revisão de arquitetura de codebase (módulo, interface, seam): `codebase-design`
