# Services

Lógica de negócio fica em `services.py`, não em views nem em models:

```python
# apps/billing/services.py
def create_subscription(user: User, plan: Plan) -> Subscription:
    # validações, criação, side effects
    ...
```

Views chamam services. Models são só persistência.
