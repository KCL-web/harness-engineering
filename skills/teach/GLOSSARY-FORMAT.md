# Formato do GLOSSARY.md

`GLOSSARY.md` é a linguagem canônica deste workspace de ensino. Todos os explainers, exercícios e learning records devem aderir à sua terminologia. Construí-lo já é parte do aprendizado: comprimir um conceito numa definição enxuta é evidência de que o dev entendeu.

## Estrutura

```md
# Glossário de {Tema}

{Uma ou duas frases descrevendo o tema que este glossário cobre.}

## Termos

**Hipertrofia**:
Crescimento muscular impulsionado por tensão mecânica e estresse metabólico ao longo de sessões repetidas de treino.
_Evitar_: Bulking, ficar grande

**Sobrecarga progressiva**:
Aumentar sistematicamente a demanda sobre um músculo ao longo do tempo, via carga, volume ou intensidade.
_Evitar_: Forçar mais, subir de nível

**RPE (Rate of Perceived Exertion)**:
Uma autoavaliação de 1 a 10 de quão difícil uma série pareceu, onde 10 é falha e 8 significa duas repetições ainda no tanque.
_Evitar_: Nota de esforço, nota de intensidade
```

## Regras

- **Adicione um termo só quando o dev o entende.** O glossário é um registro de conhecimento comprimido, não um dicionário para o dev aprender lendo. Se o dev acabou de ser apresentado a um conceito, espere até que consiga usá-lo corretamente antes de promovê-lo aqui.
- **Seja opinativo.** Quando várias palavras existem para o mesmo conceito, escolha a melhor e liste as outras como aliases a evitar. É assim que a linguagem comprime.
- **Mantenha as definições enxutas.** Uma ou duas frases. Defina o que o termo É, não o que ele faz ou como fazê-lo.
- **Use os próprios termos do glossário dentro das definições.** Uma vez que um termo está no glossário, prefira-o em todo lugar, inclusive dentro de outras definições. É isso que torna termos complexos mais fáceis de entender depois.
- **Agrupe sob subheadings** quando surgirem clusters naturais (ex.: `## Anatomia`, `## Programação`). Uma lista plana é aceitável quando os termos coerem entre si.
- **Sinalize ambiguidades explicitamente.** Se um termo é usado de forma solta no campo mais amplo, anote a resolução: "Neste workspace, 'série' sempre significa série de trabalho; aquecimentos são rastreados separadamente."
- **Revise conforme o entendimento se aprofunda.** Uma definição que o dev escreveu na semana um pode estar errada na semana seis. Atualize no lugar; não deixe entradas obsoletas.
