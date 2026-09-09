# Testes

**Use este arquivo quando:** for escrever ou revisar teste de model, serializer, view/endpoint ou service em um projeto Django + DRF.

Stack: **pytest + pytest-django + factory_boy**.

## Regra de ouro: teste deriva do requisito, não do código

Ao escrever teste para código já existente, formule primeiro o comportamento esperado em uma frase, sem olhar a implementação. Se divergir do código, é bug — não é motivo para ajustar o teste.

- **Factories**, não fixtures globais com dados grandes. Cada factory em `apps/<domain>/tests/factories.py`.
- **Banco real: Postgres**, o mesmo motor de produção — via container, com `--reuse-db` para não pagar o custo de recriar o banco a cada rodada. SQLite não é um substituto válido: `CheckConstraint`, `select_for_update`, `JSONField` e ordenação/collation se comportam diferente entre os dois motores, e teste verde em SQLite não garante nada sobre Postgres em produção.
- Não moque a ORM — moque só bordas externas (HTTP, S3, email).
- **Todo endpoint precisa de teste de integração**: status code + shape da resposta + efeito no banco.
- Organize por comportamento, não só por camada técnica: `test_criacao_pedido.py`, `test_cancelamento.py` lê melhor e conflita menos em merge do que um único `test_models.py` de 600 linhas acumulando tudo que toca aquele model.

```python
# conftest.py
import pytest
from rest_framework.test import APIClient
from apps.users.tests.factories import UserFactory

@pytest.fixture
def api_client() -> APIClient:
    return APIClient()

@pytest.fixture
def user():
    return UserFactory()

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
# apps/billing/tests/test_listagem_assinaturas.py
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
    ids = {s['id'] for s in res.json()['results']}
    assert ids == {str(own.id)}
```

Use `set()`/`{...}` para comparar coleções quando a ordem não é parte do contrato testado — com um item só a asserção posicional (`== [x]`) passa por acaso; com dois vira flake no primeiro reorder inocente. Se a ordenação é parte do requisito, teste a ordenação explicitamente, em teste separado.

## Matriz de permissão

Todo endpoint que retorna ou altera dado de usuário precisa de teste parametrizado cobrindo pelo menos: dono, outro usuário, anônimo, admin (quando existir). Para objeto de outro dono, o retorno esperado é **404, não 403** — 403 confirma para quem pergunta que o recurso existe, o que já é um vazamento de informação.

```python
@pytest.mark.django_db
@pytest.mark.parametrize('as_user,expected_status', [
    ('owner', 200),
    ('other', 404),
    (None, 401),
])
def test_get_subscription_permission_matrix(api_client, as_user, expected_status, request):
    owner = UserFactory()
    subscription = SubscriptionFactory(user=owner)

    if as_user == 'owner':
        api_client.force_authenticate(user=owner)
    elif as_user == 'other':
        api_client.force_authenticate(user=UserFactory())

    res = api_client.get(f'/api/subscriptions/{subscription.id}/')
    assert res.status_code == expected_status
```

## N+1

Teste de queries é o item mais barato que evita alguém adicionar um `SerializerMethodField` com query embutida daqui a seis meses. Com um registro só, N+1 não aparece — o teste precisa de um lote (20+ objetos).

```python
@pytest.mark.django_db
def test_list_subscriptions_does_not_n_plus_1(django_assert_num_queries, authenticated_client, user):
    SubscriptionFactory.create_batch(25, user=user)

    with django_assert_num_queries(2):  # 1 count + 1 select, sem crescer com o tamanho do lote
        authenticated_client.get('/api/subscriptions/')
```

## Transações e concorrência

`select_for_update` e `transaction.on_commit` não funcionam sob `django_db` normal — a transação de teste nunca commita de verdade, então o código sob teste roda em condições que não existem em produção. Use `@pytest.mark.django_db(transaction=True)` para esses casos.

```python
@pytest.mark.django_db(transaction=True)
def test_reserva_de_estoque_e_atomica(user):
    ...
```

## Regras gerais

- **`@pytest.mark.django_db`** em todo teste que toca banco (`transaction=True` quando o código usa `select_for_update`/`on_commit`).
- **Sem `assert True`** nem testes que só rodam sem verificar nada.
- Controle o tempo com `freezegun` quando o teste depende de `timezone.now()` — sem isso, teste falha esporadicamente na virada do dia ou perto de fuso horário.
- Bloqueie rede real em teste (fixture `autouse` que falha em qualquer socket externo) — evita que uma chamada HTTP esquecida sem mock passe despercebida até quebrar em CI.
- Use `pytest-randomly` para randomizar a ordem dos testes — ordem fixa esconde acoplamento entre testes (um teste que depende de objeto criado por outro).

## Cobertura: patch coverage + mutation testing, não ratchet global

Cobertura global como ratchet (`.harness/baseline.json` só sobe) é gamificável — importar um módulo já sobe o número sem verificar nada — e recompensa testar código fácil (getter, serializer trivial) em vez do código difícil. Sob geração automática, isso empurra para o caminho mais barato: teste raso que só sobe o número.

Duas métricas que substituem isso de forma honesta:

- **Patch coverage**: cobertura das linhas alteradas no diff da PR, com piso alto (85–90%). Impede código novo sem teste, sem premiar teste de enfeite em código antigo já existente.
- **Mutation testing** (`mutmut`) nos módulos críticos (`services.py`, permissões, cálculo). A ferramenta altera o código de propósito e verifica se algum teste quebra; mutante sobrevivente é comportamento sem cobertura real — a única métrica que um teste vazio não engana.

## Checklist antes de terminar

- [ ] Testou contra Postgres, não SQLite.
- [ ] Todo endpoint novo tem teste de dono / outro usuário / anônimo (matriz de permissão).
- [ ] Endpoint de listagem tem teste de N+1 com lote de 20+ objetos.
- [ ] Código com `select_for_update`/`on_commit` está sob `django_db(transaction=True)`.
- [ ] Nenhuma asserção de ordenação posicional em coleção sem ordenação explícita no contrato.
- [ ] Patch coverage do diff está acima do piso combinado no projeto.
