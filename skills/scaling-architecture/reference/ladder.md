# A escada de escalonamento, degrau a degrau

Uma forma de visualizar essa progressão: uma lanchonete de esquina virando rede internacional. Cada fase resolve a dor operacional que a fase anterior não aguenta mais — e só ela.

## ~1k requisições/dia — Monólito + cache in-memory

Um único servidor/aplicação (o monólito) roda tudo no mesmo processo — auth, regras de negócio, persistência. Respostas repetidas (ex.: "quais horários estão livres hoje?") ficam num cache em memória (`Map`, `node-cache`, ou um Redis local) por alguns segundos/minutos, evitando reconsulta ao banco a cada request.

- **Por que basta aqui**: nesse volume o banco de dados não é gargalo; o cache só evita trabalho redundante.
- **Armadilha comum**: introduzir microsserviço para um sistema que atende poucas dezenas de pessoas por dia — complexidade sem correspondência de carga real.
- **Sinal de subir de degrau**: servidor trava em horário de pico, ou o banco vira gargalo mesmo com cache.

## ~10k requisições/dia — API Gateway + Service Directory

Múltiplas instâncias da aplicação passam a existir atrás de um ponto único de entrada — o **API Gateway** (Kong, NGINX, ou um proxy simples) — que centraliza autenticação, rate limiting e roteamento. O **Service Directory** (Consul, Eureka, ou DNS interno) mantém a lista de quais instâncias estão de pé agora, já que deploys/crashes/auto-scaling fazem elas subirem e descerem.

- **O que muda de verdade**: separação de responsabilidades em módulos (mesmo que ainda no mesmo monólito) e múltiplas cópias da aplicação atrás de um load balancer.
- **Armadilha comum**: gateway pesado vira o novo gargalo — ele precisa ser fino e rápido, senão só moveu o problema.

## ~50k requisições/dia — Arquitetura orientada a eventos (RabbitMQ)

Em vez do serviço A chamar B e ficar esperando resposta (acoplamento síncrono), A publica um **evento** numa fila (ex.: `agendamento.criado`) e cada interessado (notificação, relatório, faturamento) processa no seu próprio ritmo.

- **Por que precisa disso aqui**: nesse volume, chamadas síncronas encadeadas (A espera B que espera C) criam filas de espera reais e timeouts em cascata. Desacoplar evita que um serviço lento derrube os outros.
- **Armadilha comum**: introduzir fila antes da hora — fluxo assíncrono é mais difícil de debugar que síncrono, só compensa quando o acoplamento síncrono já dói de verdade.

## ~100k requisições/dia — Service Mesh (Istio) + gRPC

Com dezenas de serviços conversando entre si o tempo todo, entra uma camada de infraestrutura dedicada a isso — o **Service Mesh** (Istio, tipicamente via sidecar Envoy ao lado de cada serviço), que cuida de:

- Retry automático em falha
- mTLS entre serviços sem código extra
- Observabilidade (quem chamou quem, quanto demorou)
- Circuit breaker (para de mandar tráfego pra um serviço capenga)

**gRPC** substitui JSON/REST na comunicação interna entre serviços — Protocol Buffers é um formato binário compacto, feito pra chamadas serviço-a-serviço de alta frequência.

- **Por que só agora**: Service Mesh tem overhead operacional alto (curva de aprendizado, mais peças rodando). Só compensa com muitos microsserviços já existindo e precisando de padronização.
- **Armadilha comum**: Istio não é "instalar e esquecer" — é compromisso sério de operação.

## ~500k requisições/dia — Kafka streaming + CQRS

RabbitMQ não aguenta mais o volume/retenção necessários; entra o **Kafka**, um log distribuído que aguenta volume alto, guarda histórico de eventos por dias/semanas, e permite múltiplos consumidores lendo o mesmo stream de forma independente.

**CQRS** (Command Query Responsibility Segregation) separa quem escreve de quem lê:
- **Command side**: recebe o pedido, valida, grava o evento.
- **Query side**: cópia dos dados já otimizada pra leitura rápida, às vezes num banco totalmente diferente (ex.: Elasticsearch pra busca).

Isso evita que o mesmo banco aguente escrita pesada e leitura pesada ao mesmo tempo — cada lado escala independente.

- **Armadilha comum**: CQRS + Event Sourcing introduz *eventual consistency* — o dado lido pode estar segundos atrasado em relação ao que foi escrito. Exige mudança de mentalidade no time e às vezes no produto.

## 1M+ requisições/dia — Edge Routing + Kubernetes multi-região

Usuários em continentes diferentes não são bem servidos por um datacenter único — a velocidade da luz vira o gargalo, não o código.

- **Edge Routing**: CDNs e roteamento inteligente (Cloudflare, AWS Global Accelerator) direcionam cada usuário pro datacenter/região mais próxima, cacheando conteúdo estático (e às vezes respostas de API) perto do usuário.
- **Kubernetes multi-região**: vários clusters em regiões diferentes, com replicação de dados entre eles, failover automático, e às vezes bancos "primários" regionais pra reduzir latência de escrita.

- **Armadilha comum**: é o nível mais caro e operacionalmente mais complexo. Envolve decisões difíceis de consistência de dados entre regiões (CAP theorem na prática). Só compensa com tráfego global de verdade.
