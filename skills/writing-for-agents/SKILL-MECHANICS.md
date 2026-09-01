# Mecânica de skill

O ramo específico de skill de [`writing-for-agents`](SKILL.md): o que muda quando o documento é uma skill (frontmatter, a escolha de invocação, e router skills). Todo o resto sobre escrevê-lo é a referência universal em `SKILL.md`.

## Invocação

Duas escolhas, trocando as duas cargas:

- Uma skill **model-invoked** (invocada pelo modelo) mantém uma `description`, para que o agente possa dispará-la de forma autônoma, e outras skills possam alcançá-la. Você ainda consegue digitar o nome dela: invocação por modelo sempre _inclui_ o alcance pelo dev; uma description só adiciona descoberta pelo agente, nunca remove o alcance do humano. A description é o context pointer de topo da skill, forçado a ficar sempre carregado: carga de contexto permanente em troca de descobribilidade. Uma skill model-invoked cujo conteúdo é todo referência também é um bom lugar para referência compartilhada: outra skill pode invocá-la, então referência necessária a várias skills vive num lugar só. Mecânica: omita `disable-model-invocation`, e escreva uma description voltada ao modelo carregando as branches de gatilho (as regras de redação de ponteiro em `SKILL.md` se aplicam por inteiro).
- Uma skill **user-invoked** (invocada pelo dev) tira a description do alcance do agente: só o humano digitando o nome dela consegue invocá-la, e nenhuma outra skill consegue. Zero carga de contexto, mas ela gasta carga cognitiva: você é o índice que precisa lembrar que ela existe. Mecânica: defina `disable-model-invocation: true`; a `description` passa a ser voltada ao humano: um resumo de uma linha, sem listas de gatilho.

Escolha invocação por modelo só quando o agente precisa alcançar a skill sozinho, ou quando outra skill precisa alcançá-la. Se ela só dispara na mão, torne-a user-invoked e não pague carga de contexto.

Referência compartilhada de que duas skills user-invoked precisam não pode viver em nenhuma das duas: sem descriptions, nenhuma consegue disparar a outra. Empurre para um arquivo simples fora do sistema de skills: referência externa que qualquer skill pode apontar.

## Dividindo por invocação

O corte de invocação da divisão (o corte de sequência vive em `SKILL.md`): separe uma skill model-invoked quando você tem uma palavra líder distinta que deveria dispará-la sozinha (uma palavra de gatilho que você realmente usa nos seus prompts), ou outra skill precisa alcançá-la. Você paga carga de contexto pela nova description sempre carregada, então esse alcance independente precisa valer a pena.

## Router skills

Quando skills user-invoked se multiplicam além do que você consegue lembrar, essa carga cognitiva acumulada se resolve com uma **router skill**: uma única skill user-invoked que nomeia as outras e quando recorrer a cada uma, para que o humano tenha uma skill só para lembrar em vez de muitas. Ela só consegue sugerir, nunca disparar as outras: skills user-invoked não têm description, então nada além do humano consegue alcançá-las.
