# Base de Conhecimento Out-of-Scope

O diretório `.out-of-scope/` no repo guarda registros persistentes de pedidos de feature rejeitados. Serve a dois propósitos:

1. **Memória institucional**: por que uma feature foi rejeitada, para que o raciocínio não se perca quando a issue é fechada
2. **Deduplicação**: quando uma nova issue chega correspondendo a uma rejeição anterior, a skill pode mostrar a decisão anterior em vez de relitigar

## Estrutura de diretório

```
.out-of-scope/
├── dark-mode.md
├── plugin-system.md
└── graphql-api.md
```

Um arquivo por **conceito**, não por issue. Múltiplas issues pedindo a mesma coisa são agrupadas num arquivo só.

## Formato do arquivo

O arquivo deve ser escrito num estilo solto e legível, mais parecido com um design doc curto do que com uma entrada de banco de dados. Use parágrafos, exemplos de código e exemplos para deixar o raciocínio claro e útil para quem encontrar isso pela primeira vez.

```markdown
# Dark Mode

Este projeto não suporta modo escuro nem theming voltado ao usuário.

## Por que está fora de escopo

O pipeline de renderização assume uma paleta de cor única definida em
`ThemeConfig`. Suportar múltiplos temas exigiria:

- Um theme context provider envolvendo toda a árvore de componentes
- Resolução de estilo por componente, ciente do tema
- Uma camada de persistência para preferência de tema do usuário

Essa é uma mudança arquitetural significativa que não se alinha com o foco
do projeto em autoria de conteúdo. Theming é uma preocupação de consumidores
downstream que embarcam ou redistribuem a saída.

```ts
// A interface ThemeConfig atual não foi desenhada para troca em runtime:
interface ThemeConfig {
  colors: ColorPalette; // paleta única, resolvida em build time
  fonts: FontStack;
}
```

## Prior requests

- #42: "Add dark mode support"
- #87: "Night theme for accessibility"
- #134: "Dark theme option"
```

### Nomeando o arquivo

Use um nome curto e descritivo em kebab-case para o conceito: `dark-mode.md`, `plugin-system.md`, `graphql-api.md`. O nome deve ser reconhecível o bastante para que alguém navegando o diretório entenda o que foi rejeitado sem abrir o arquivo.

### Escrevendo o motivo

O motivo deve ser substantivo: não "não queremos isso" mas por quê. Bons motivos referenciam:

- Escopo ou filosofia do projeto ("Este projeto foca em X; theming é uma preocupação downstream")
- Restrições técnicas ("Suportar isso exigiria Y, que conflita com nossa arquitetura Z")
- Decisões estratégicas ("Escolhemos usar A em vez de B porque...")

O motivo deve ser durável. Evite referenciar circunstâncias temporárias ("estamos muito ocupados agora"); isso não são rejeições de verdade, são adiamentos.

## Quando conferir `.out-of-scope/`

Durante a triagem (Passo 1: Reúna contexto), leia todos os arquivos em `.out-of-scope/`. Ao avaliar uma nova issue:

- Confira se o pedido corresponde a um conceito já registrado como out-of-scope
- A correspondência é por similaridade de conceito, não por palavra-chave: "night theme" corresponde a `dark-mode.md`
- Se houver correspondência, mostre ao mantenedor: "Isso é parecido com `.out-of-scope/dark-mode.md`. Rejeitamos isso antes porque [motivo]. Ainda pensa assim?"

O mantenedor pode:

- **Confirmar**: a nova issue é adicionada à lista "Prior requests" do arquivo existente, depois fechada
- **Reconsiderar**: o arquivo out-of-scope é apagado ou atualizado, e a issue segue pela triagem normal
- **Discordar**: as issues são relacionadas mas distintas, siga com a triagem normal

## Quando escrever em `.out-of-scope/`

Só quando um **enhancement** (não um bug) é *rejeitado* como `triage/wontfix`. Isso vale para PRs de enhancement exatamente como vale para issues: uma PR rejeitada é registrada aqui para que o mesmo pedido não volte como código novo.

NÃO escreva aqui quando algo é fechado como `triage/wontfix` porque **já está implementado**. Isso é uma feature construída, não rejeitada; registrar isso envenenaria as checagens de dedup com falsas rejeições. Em vez disso, o comentário de fechamento aponta para onde a feature já vive.

O fluxo:

1. Mantenedor decide que um pedido de feature está fora de escopo
2. Confira se já existe um arquivo `.out-of-scope/` correspondente
3. Se sim: anexe a nova issue à lista "Prior requests"
4. Se não: crie um arquivo novo com o nome do conceito, decisão, motivo, e o primeiro prior request
5. Poste um comentário na issue explicando a decisão e mencionando o arquivo `.out-of-scope/`
6. Feche a issue com o label `triage/wontfix`

## Atualizando ou removendo arquivos out-of-scope

Se o mantenedor mudar de ideia sobre um conceito previamente rejeitado:

- Apague o arquivo `.out-of-scope/`
- A skill não precisa reabrir issues antigas; elas são registros históricos
- A nova issue que motivou a reconsideração segue pela triagem normal
