---
name: stack-django-drf-jwt
description: Archetype backend Django 5 + Django REST Framework + SimpleJWT (autenticação). Invoque ao criar model, serializer, view, endpoint de autenticação, migration ou teste em qualquer projeto que usa esta stack. Convenções iniciais — devem amadurecer via CAPTURED conforme projetos reais adotam.
---

# Stack: Django + DRF + JWT

Archetype para projetos **Django 5 + Django REST Framework + djangorestframework-simplejwt**.
Banco padrão: **PostgreSQL**. Testes: **pytest-django + factory_boy**. Config: **django-environ**.

> **Status:** esqueleto opinionado. Convenções aqui são um ponto de partida razoável — espera-se
> que amadureçam via CAPTURED (mecanismo OpenSpace) conforme projetos reais decidam.

## Estrutura de pastas

```
project/
├── config/
│   ├── settings/
│   │   ├── base.py
│   │   ├── local.py
│   │   └── production.py
│   ├── urls.py
│   └── wsgi.py
├── apps/
│   └── <domain>/            # uma app por domínio (users, billing, etc.)
│       ├── models.py
│       ├── serializers.py
│       ├── views.py
│       ├── urls.py
│       ├── services.py      # lógica de negócio (não na view, não no model)
│       └── tests/
│           ├── test_models.py
│           ├── test_serializers.py
│           └── test_views.py
├── manage.py
└── requirements/
    ├── base.txt
    ├── local.txt
    └── production.txt
```

## Autenticação JWT

Usar **djangorestframework-simplejwt**.

```python
# config/settings/base.py
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ],
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticated',
    ],
}

SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(minutes=15),
    'REFRESH_TOKEN_LIFETIME': timedelta(days=7),
    'ROTATE_REFRESH_TOKENS': True,
    'BLACKLIST_AFTER_ROTATION': True,
}
```

```python
# apps/auth/urls.py
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView

urlpatterns = [
    path('token/', TokenObtainPairView.as_view()),
    path('token/refresh/', TokenRefreshView.as_view()),
]
```

## Models

- **PK**: UUID por padrão (`UUIDField(primary_key=True, default=uuid4)`). Use `BigAutoField` só quando há razão concreta (ex.: integração legada).
- **Timestamps**: todo model herda `created_at` / `updated_at` via base abstrata.
- **Sem lógica de negócio em models** — só persistência, invariantes simples e `__str__`. Lógica vai para `services.py`.
- **Managers customizados** para querysets que repetem (`active()`, `for_user(user)`), nunca `@classmethod` na model.
- **Meta.ordering** padrão por `-created_at` para listagens.

```python
# apps/core/models.py
import uuid
from django.db import models

class BaseModel(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        abstract = True
        ordering = ['-created_at']

# apps/billing/models.py
from apps.core.models import BaseModel

class Subscription(BaseModel):
    user = models.ForeignKey('users.User', on_delete=models.PROTECT, related_name='subscriptions')
    plan = models.ForeignKey('Plan', on_delete=models.PROTECT)
    status = models.CharField(max_length=20, choices=[('active', 'Active'), ('canceled', 'Canceled')])

    def __str__(self):
        return f'{self.user.email} → {self.plan.name}'
```

- **`on_delete`**: prefira `PROTECT` para FKs com sentido de negócio; `CASCADE` só para dependência forte (ex.: filhos órfãos de fato).
- **Choices** em listas no topo do arquivo ou como `TextChoices`/`IntegerChoices` — nunca strings mágicas espalhadas.

## Serializers

- **`ModelSerializer`** para CRUD direto sobre uma model.
- **`Serializer`** para shapes que não batem 1:1 com model (login, ações, agregados).
- **Validações de campo** vão em `validate_<field>`; **cross-field** vai em `validate(self, attrs)`.
- **Escrita com FK por ID, leitura com objeto aninhado** — use dois serializers (`*WriteSerializer` / `*ReadSerializer`) ou `to_representation`.
- **Nunca exponha** `password`, hashes, tokens, ou campos internos (`is_staff`, flags) sem `write_only`/`read_only` explícito.

```python
# apps/users/serializers.py
from rest_framework import serializers
from .models import User

class UserSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=8)

    class Meta:
        model = User
        fields = ['id', 'email', 'name', 'password', 'created_at']
        read_only_fields = ['id', 'created_at']

    def validate_email(self, value: str) -> str:
        if User.objects.filter(email__iexact=value).exists():
            raise serializers.ValidationError('Email já cadastrado.')
        return value.lower()

    def create(self, validated_data: dict) -> User:
        # delega para o service — não escreva lógica de criação aqui
        from .services import create_user
        return create_user(**validated_data)
```

- **`fields = '__all__'`** é proibido. Liste explicitamente — evita expor campos novos sem querer ao adicionar coluna.
- **Serializer aninhado** só para **leitura**. Para escrita, aceite IDs (`PrimaryKeyRelatedField`).

## Views / ViewSets

- **`ModelViewSet` + Router** para CRUD padrão (`list`, `retrieve`, `create`, `update`, `destroy`).
- **`APIView`** para endpoints que não são CRUD (login, ações cruzadas, webhooks).
- **`@action`** para operações sobre um recurso que não cabem em CRUD (`/users/{id}/activate/`).
- **Paginação padrão**: `PageNumberPagination` com `page_size = 20`.
- **Permissions** declaradas explicitamente em cada viewset — não confie só na global.

```python
# apps/billing/views.py
from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response

from .models import Subscription
from .serializers import SubscriptionSerializer
from . import services

class SubscriptionViewSet(viewsets.ModelViewSet):
    serializer_class = SubscriptionSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        # nunca retorne objetos de outros usuários
        return Subscription.objects.for_user(self.request.user)

    @action(detail=True, methods=['post'])
    def cancel(self, request, pk=None):
        subscription = self.get_object()
        services.cancel_subscription(subscription, reason=request.data.get('reason'))
        return Response(status=status.HTTP_204_NO_CONTENT)
```

- **Views são finas**: validação via serializer → chamada a `services.*` → resposta. Sem queries em handlers; sem `if user.is_staff` espalhado (use permission class).
- **`get_queryset`** sempre filtra por escopo do usuário — vazamento entre tenants/users é o bug mais comum.
- **Status codes corretos**: `201` em create, `204` em delete/action sem body, `400` em validação, `403` em permission, `404` em not found.

### Paginação

```python
# config/settings/base.py
REST_FRAMEWORK = {
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': 20,
}
```

### URLs

```python
# apps/billing/urls.py
from rest_framework.routers import DefaultRouter
from .views import SubscriptionViewSet

router = DefaultRouter()
router.register('subscriptions', SubscriptionViewSet, basename='subscription')

urlpatterns = router.urls
```

## Services

Lógica de negócio fica em `services.py`, não em views nem em models:

```python
# apps/billing/services.py
def create_subscription(user: User, plan: Plan) -> Subscription:
    # validações, criação, side effects
    ...
```

Views chamam services. Models são só persistência.

## Testes

Stack: **pytest + pytest-django + factory_boy**.

- **Um arquivo por camada** dentro de `apps/<domain>/tests/`: `test_models.py`, `test_serializers.py`, `test_views.py`, `test_services.py`.
- **Factories**, não fixtures globais com dados grandes. Cada factory em `apps/<domain>/tests/factories.py`.
- **Banco real** (Postgres ou SQLite em teste). Não moque a ORM — moque só bordas externas (HTTP, S3, email).
- **Todo endpoint precisa de teste de integração**: status code + shape da resposta + efeito no banco.

```python
# conftest.py
import pytest
from rest_framework.test import APIClient

@pytest.fixture
def api_client() -> APIClient:
    return APIClient()

@pytest.fixture
def authenticated_client(api_client, user) -> APIClient:
    api_client.force_authenticate(user=user)
    return api_client
```

```python
# apps/users/tests/factories.py
import factory
from apps.users.models import User

class UserFactory(factory.django.DjangoModelFactory):
    class Meta:
        model = User

    email = factory.Sequence(lambda n: f'user{n}@example.com')
    name = factory.Faker('name')
```

```python
# apps/billing/tests/test_views.py
import pytest
from apps.users.tests.factories import UserFactory
from apps.billing.tests.factories import SubscriptionFactory

@pytest.mark.django_db
def test_user_lists_only_own_subscriptions(api_client):
    user = UserFactory()
    other = UserFactory()
    own = SubscriptionFactory(user=user)
    SubscriptionFactory(user=other)  # não deve aparecer

    api_client.force_authenticate(user=user)
    res = api_client.get('/api/subscriptions/')

    assert res.status_code == 200
    ids = [s['id'] for s in res.json()['results']]
    assert ids == [str(own.id)]
```

- **`@pytest.mark.django_db`** em todo teste que toca banco.
- **Sem `assert True`** nem testes que só rodam sem verificar nada.
- **Coverage como ratchet**: o número vai em `.harness/baseline.json` — só pode subir.

## Variáveis de ambiente

Usar **django-environ**. `.env` por ambiente, `.env.example` versionado com placeholders.

```python
# config/settings/base.py
import environ

env = environ.Env()
environ.Env.read_env()  # lê .env na raiz

SECRET_KEY = env('DJANGO_SECRET_KEY')
DEBUG = env.bool('DJANGO_DEBUG', default=False)
ALLOWED_HOSTS = env.list('DJANGO_ALLOWED_HOSTS', default=[])
DATABASES = {'default': env.db('DATABASE_URL')}
CORS_ALLOWED_ORIGINS = env.list('CORS_ALLOWED_ORIGINS', default=[])
```

Variáveis obrigatórias em todo projeto:

| Variável | Descrição |
| --- | --- |
| `DJANGO_SECRET_KEY` | Chave do Django. Nunca commit, sempre rotacionável. |
| `DJANGO_DEBUG` | `True` só em local. Em prod, `False`. |
| `DJANGO_ALLOWED_HOSTS` | Lista separada por vírgula. |
| `DATABASE_URL` | URL completa (`postgres://user:pass@host:port/db`). |
| `DJANGO_SETTINGS_MODULE` | `config.settings.local` / `config.settings.production`. |
| `CORS_ALLOWED_ORIGINS` | Origens permitidas pelo django-cors-headers. |

- **`.env` no `.gitignore`**, sempre.
- **`.env.example` versionado** com placeholders (`DJANGO_SECRET_KEY=changeme`).
- **Secrets reais em vault** (1Password, AWS Secrets Manager, etc.), nunca no repo.

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
