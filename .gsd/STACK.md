# STACK.md

Identificação do projeto: qual stack este código usa, como validar, que ambiente ele precisa.

Este arquivo é **preenchido pela entrevista de bootstrap** e **nunca é sobrescrito por `scripts/harness-sync.sh`**.
As convenções de stack (folder layout, componentes, testes, schemas) ficam separadas em `.gsd/CONVENTIONS.md`.

---

## Stack

> Preenchido pelo bootstrap. Marque o que não souber como TBD.

- Runtime / framework:
- Linguagem:
- Banco / ORM:
- Estilização:
- Testes:
- Gerenciador de pacotes:
- Deploy:

---

## Validação (rodar antes de cada commit)

> Preenchido pelo bootstrap. Substitua o placeholder abaixo pelo comando real deste projeto.

```bash
<comando de validação>
```

O que ele roda, em sequência:

1. <passo 1, ex.: type check>
2. <passo 2, ex.: lint>
3. <passo 3, ex.: testes>
4. <passo 4, ex.: format check>

**Uma tarefa só está completa quando este comando passa com zero erros.**
Nunca considere uma tarefa pronta com base apenas no seu próprio julgamento.

---

## Setup do zero

> Preenchido pelo bootstrap. Comandos para subir este projeto a partir de um clone limpo.

```bash
git clone <repo>
<comando de instalação>
cp .env.example .env     # preencha as variáveis necessárias
<comando de dev>
```

Depois de instalar as dependências, o agente deve verificar se as milestones do ROADMAP existem no Forgejo (ver skill `workflow-issues`). Se faltar, roda a sincronia ROADMAP → Forgejo antes de qualquer outro trabalho. (Sem project board — só milestones, labels e issues.)

---

## Variáveis de ambiente

> Preenchido pelo bootstrap. Liste cada serviço externo com que este projeto fala e as env vars necessárias.

| Variável | Descrição |
| -------- | --------- |
| —        | —         |

---

## Notas específicas do projeto

> Preenchido pelo bootstrap. Documente restrições, edge cases conhecidos e invariantes não-óbvios que o agente deve respeitar em toda sessão.
