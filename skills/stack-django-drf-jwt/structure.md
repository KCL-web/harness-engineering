# Estrutura de pastas

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
├── lib/                     # validadores e serializer fields reusados por 2+ apps
│   └── validators.py
├── manage.py
└── requirements/
    ├── base.txt
    ├── local.txt
    └── production.txt
```

## Regra de promoção de validação de serializer

Assim que uma validação (regex, formato, `validate_<field>`/`validate()` cross-field) passa a se repetir em **2+ serializers** — mesmo em apps diferentes — ela vira global em `lib/validators.py`, nunca copiada/colada entre apps (isso é o mesmo valor de validação virando hardcoded em dois lugares que podem divergir). O serializer original passa a **importar** do `lib/`:

```python
# lib/validators.py
import re
from rest_framework import serializers

def validate_cpf(value: str) -> str:
    if not re.fullmatch(r'\d{11}', value):
        raise serializers.ValidationError('CPF deve ter 11 dígitos.')
    return value
```

```python
# apps/users/serializers.py
from lib.validators import validate_cpf

class UserSerializer(serializers.ModelSerializer):
    cpf = serializers.CharField(validators=[validate_cpf])
```
