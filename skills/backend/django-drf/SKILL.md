---
name: django-drf
description: Convenções Django 5 + Django REST Framework — models, serializers, views/viewsets, services, env vars, testes. Invoque ao criar model, serializer, view, endpoint ou teste num projeto Django.
---

# Django + DRF

Banco padrão: **PostgreSQL**. Config: **django-environ**. Testes: **pytest-django + factory_boy**.

## Referência

| Arquivo | Conteúdo |
| --- | --- |
| [reference/folder-structure.md](reference/folder-structure.md) | Organização de `config/`, `apps/`, requirements |
| [reference/models.md](reference/models.md) | PK, timestamps, managers, `on_delete`, choices |
| [reference/serializers-and-views.md](reference/serializers-and-views.md) | Serializers, ViewSets, `@action`, paginação, services |
| [reference/env-vars.md](reference/env-vars.md) | django-environ, variáveis obrigatórias |
| [reference/testing.md](reference/testing.md) | pytest-django, factories, N+1, matriz de permissão |

## Regras inegociáveis

- Lógica de negócio em `services.py`, nunca em views ou models.
- Nenhuma query de banco direto em views — só via managers ou services.
- `fields = '__all__'` é proibido em serializers — sempre liste explicitamente.
- Todo endpoint tem teste de integração que bate no banco real (Postgres, não SQLite — ver
  `reference/testing.md`).
- `get_queryset()` filtra por escopo do usuário em todo viewset que retorna dados de usuário.
- `SECRET_KEY` e credenciais nunca no repo; sempre via env var.
- Migrations geradas com `makemigrations` ficam commitadas; nunca edite migration aplicada em outra
  branch sem coordenar.

## Skills relacionadas

- Autenticação: `backend/jwt-cookie-auth`
