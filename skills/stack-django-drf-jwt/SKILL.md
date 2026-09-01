---
name: stack-django-drf-jwt
description: Archetype backend Django 5 + Django REST Framework + SimpleJWT (autenticação). Invoque ao criar model, serializer, view, endpoint de autenticação, migration ou teste em qualquer projeto que usa esta stack. Convenções iniciais — devem amadurecer via CAPTURED conforme projetos reais adotam.
---

# Stack: Django + DRF + JWT

Archetype para projetos **Django 5 + Django REST Framework + djangorestframework-simplejwt**.
Banco padrão: **PostgreSQL**. Testes: **pytest-django + factory_boy**. Config: **django-environ**.

> **Status:** esqueleto opinionado. Convenções aqui são um ponto de partida razoável — espera-se
> que amadureçam via CAPTURED (mecanismo OpenSpace) conforme projetos reais decidam.

Este arquivo é o índice da skill. Leia só o arquivo do tópico que a tarefa atual precisa — não carregue todos de uma vez.

## Quando ler cada arquivo

| Tarefa | Arquivo |
| --- | --- |
| Organizar apps, settings, requirements | [structure.md](structure.md) |
| Configurar ou usar autenticação JWT (SimpleJWT) | [auth-jwt.md](auth-jwt.md) |
| Criar model, PK, timestamps, `on_delete`, choices | [models.md](models.md) |
| Criar serializer, validação de campo/cross-field, leitura vs escrita | [serializers.md](serializers.md) |
| Criar view/viewset, `@action`, paginação, `urls.py` | [views.md](views.md) |
| Onde colocar lógica de negócio (`services.py`) | [services.md](services.md) |
| Escrever teste (pytest + pytest-django + factory_boy) | [testing.md](testing.md) |
| Configurar `django-environ`, variáveis obrigatórias do projeto | [env-vars.md](env-vars.md) |

## Regras inegociáveis

- Lógica de negócio em `services.py`, nunca em views ou models.
- Nenhuma query de banco direto em views — só via managers ou services.
- `fields = '__all__'` é proibido em serializers — sempre liste explicitamente.
- Todo endpoint tem teste de integração que bate no banco real.
- `get_queryset()` filtra por escopo do usuário em todo viewset que retorna dados de usuário.
- JWT em header `Authorization: Bearer <token>` — sem cookies para APIs puras.
- `SECRET_KEY` e credenciais nunca no repo; sempre via env var.
- Migrations geradas com `makemigrations` ficam commitadas; nunca edite migration aplicada em outra branch sem coordenar.

## Skills relacionadas

- Fluxo de issue, branch e PR: `workflow-branching`, `workflow-prs`, `workflow-issues`
- Feature list e baseline: `ratchet-feature-list`
- Frontend: `stack-react-vite-scss`
