---
name: wizard
description: Gera um wizard interativo em bash que guia um humano por passos que só ele pode executar. Use ao provisionar infraestrutura, configurar credenciais ou secrets de CI, navegar um dashboard de terceiros desconhecido, ou rodar uma migração/corte pontual. Não invoque para passos que o agente consegue executar sozinho. Importada de mattpocock/skills.
---

# Wizard

> **Origem:** importada de [mattpocock/skills](https://github.com/mattpocock/skills) (`engineering/wizard`), adaptada ao vocabulário deste harness.

Um **wizard** é um script bash que guia um humano, passo a passo, por um procedimento manual que é tedioso de fazer à mão e tedioso de reexplicar para uma IA toda vez. Ele abre cada URL, diz exatamente o que clicar e copiar, captura os valores, escreve-os onde pertencem (`.env`, secrets/variables de Actions), confirma em cada etapa, e mostra quantas etapas faltam. Pode configurar serviços de terceiros, rodar uma migração pontual, ou mover o projeto de um estado para outro.

A UX agradável já está resolvida em [template.sh](template.sh): progresso por estágio, portões de confirmação, abertura de URL cross-platform (incluindo WSL), entrada de secret oculta, upsert idempotente de `.env`, escrita de secrets/variables de Actions do Forgejo via API, e um resumo final. **Seu trabalho é só definir o escopo do procedimento e autorar seus estágios.** A biblioteca acima do marcador `STAGES` é idêntica em todo wizard; essa consistência é o ponto: nunca edite-a à mão.

Um wizard é efêmero por padrão: construído para uma execução, salvo num caminho de scratch ou `scripts/`, apagado quando o trabalho termina. Só faça commit dele quando o dev quiser um caminho de setup repetível que deva viver no repo.

## Processo

### 1. Defina o escopo do procedimento

Descubra cada passo manual que o humano precisa dar e cada valor capturado ao longo do caminho. Leia o repo primeiro, não pergunte a frio:

- Para setup: `.env`, `.env.example`, `.env.*`, `README`, `docker-compose*`, config do framework, e `.forgejo/workflows/*` (toda referência a `secrets.*`/`vars.*` é um valor que o wizard precisa produzir).
- Para uma migração ou transição: o estado atual, o estado alvo, e as ações irreversíveis entre eles.

Depois mostre ao dev a lista ordenada de estágios e os valores que cada um produz, e confirme: ele pode adicionar, remover, ou reordenar.

**Pronto quando:** todo estágio está nomeado em ordem, e para cada valor capturado você sabe (a) onde o humano o consegue, (b) onde ele é escrito (`.env`, um secret/variable de Actions do Forgejo, ambos, ou lugar nenhum; alguns estágios são ações puras), e (c) se é secreto (entrada oculta) ou público.

### 2. Mapeie a jornada de cada estágio

Para cada estágio, escreva o caminho preciso que um humano segue: qual URL abrir, o que fazer lá, onde um valor aparece, qual variável ele preenche: ex.: "Dashboard → Developers → API keys → Reveal test key → copiar". Onde você não sabe de fato a UI atual ou o comando exato, diga isso e pergunte ao dev ou confira a documentação: nunca invente passos que podem não existir.

**Pronto quando:** todo estágio se traduz em instruções concretas que um estranho conseguiria seguir.

### 3. Escreva o wizard

Copie `template.sh` para o caminho alvo. Substitua o estágio de exemplo por um `stage` por passo, em ordem de dependência. Use os helpers da biblioteca: `stage`, `say`/`step`, `open_url`, `ask`/`ask_secret`, `write_env`, `set_secret`/`set_var`, `pause`/`confirm`. Ajuste `TOTAL_STAGES` para o número de estágios que você escreveu.

Mantenha o padrão que o template define: abra a URL antes de pedir seu valor, use `ask_secret` para qualquer coisa secreta, `write_env` todo valor persistido, `set_secret` só os valores que o CI de fato precisa, e `confirm` antes de qualquer ação irreversível. Cada `stage` limpa a tela para que só o passo atual fique visível: mantenha um estágio focado numa única tarefa para que nada que o humano precisa role para fora da tela. Não toque na biblioteca acima do marcador.

### 4. Verifique e entregue

- `bash -n <script>`; rode `shellcheck` se disponível.
- `chmod +x <script>`.
- Não rode do início ao fim você mesmo: ele abre navegadores e bloqueia esperando entrada humana. Em vez disso, trace-o estaticamente: todo valor do passo 1 é capturado e vai parar onde o passo 1 disse, e todo `set_secret`/`set_var` bate exatamente com uma referência `secrets.*`/`vars.*` em `.forgejo/workflows/*`.
- Diga ao dev como rodá-lo. Se for um caminho de setup repetível, faça commit e linke a partir do README para que a próxima pessoa rode o script em vez de perguntar para uma IA.

## Secrets e variables no Forgejo

`template.sh` escreve secrets/variables de Actions direto na API do Forgejo (via `curl` + `FORGEJO_TOKEN`/`FORGEJO_URL`/`FORGEJO_ORG`, as mesmas env vars de `workflow-issues`), não via `gh` (este workspace usa **Forgejo Actions** em `.forgejo/workflows/`, não GitHub Actions — ver `harness-index`). Se a API falhar (token sem escopo de Actions, endpoint indisponível nesta instância), o wizard registra o valor como pendência manual e mostra o caminho na UI web (repo → Settings → Actions → Secrets/Variables) no resumo final.

## Skills relacionadas

- Env vars e API do Forgejo: `workflow-issues`
- Convenção de commit/branch/PR para commitar um wizard repetível: `workflow-commits`, `workflow-branching`, `workflow-prs`
