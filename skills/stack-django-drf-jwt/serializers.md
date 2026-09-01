# Serializers

- **`ModelSerializer`** para CRUD direto sobre uma model.
- **`Serializer`** para shapes que não batem 1:1 com model (login, ações, agregados).
- **Validações de campo** vão em `validate_<field>`; **cross-field** vai em `validate(self, attrs)`.
- **Validação repetida em 2+ serializers** (mesmo regex, mesmo formato, mesma regra cross-field) vira global em `lib/validators.py` — nunca copiada entre apps. Ver `structure.md` → "Regra de promoção de validação de serializer".
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
