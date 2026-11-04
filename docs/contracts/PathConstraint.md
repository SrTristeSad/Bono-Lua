# PathConstraint

Fonte: DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e, armature/Constraint.ts; algoritmo e backup cd4206a8 lidos integralmente. Módulo dragonbones.armature.PathConstraint herda Constraint. Montagem manual usa modelos, parser, Bone, Slot e Armature reais; não implementa Animation/factory/renderer.

## Comportamento preservado

Portados init/update/invalidUpdate/_onClear, atualização dos vértices com/sem pesos, cópia, amostragem Bézier e aplicação de translação/rotação/escala. Curva aberta/fechada, velocidade constante ou comprimentos fornecidos, posição fixa/percentual, espaçamento fixo/length/percent e tangent/chain/chainScale seguem os ramos originais.

Não corrigir silenciosamente: o ramo sem pesos escreve só metade do buffer; _computeVertices usa count como limite final mesmo com offset; os TODOs fora da curva aberta não escrevem posições; ausência de bone ponderado não consome seus floats; init repetido acumula bones; invalidUpdate é vazio; _segments começa como [10] e sobrevive à limpeza, assim como _constraintData. Buracos, undefined explícito e NaN são distintos. O array local curves não atualiza o campo _curves. A ordem dos operandos, inclusive dfx += (ddfx + dddfx), é preservada.

## Verificação

2.851 cenários, 8.553 etapas, 193.868 colunas e 33 erros de etapas esperados por VM. Grade de 2.592 combinações, 160 amostragens diretas, 69 casos de API/flags/erros/limpeza e 30 helpers. Modelos e buffers vêm de JSON pelo parser real; só os quatro hooks abstratos necessários de Slot são observadores locais. Fixtures incluem dois bones seguidores e zero/um/dois bones por vértice, reflexões, misturas e diferentes posições. O exemplo path também usa o registro de constraints e Bone.update para disparar o solver.

Quatro mutações deliberadas foram rejeitadas: preencher todo o ramo sem pesos, mudar count para offset+count, adicionar guarda a init e fazer invalidUpdate marcar dirty. Produto restaurado antes da execução integral final.

## Precisão específica

Comparador mantém flags, referências, comprimentos/índices de arrays, buracos, undefined, NaN e zeros assinados exatos. Apenas derivados finitos declarados admitem diferença V8/libm: espaços/comprimentos/ângulos amostrados e tangente helper até 8 epsilon vezes max(1,abs(expected)); coordenadas amostradas e de matriz/pose até 32 epsilon vezes max(R,abs(expected)). R é max(1, valores absolutos finitos do expected nas posições/vértices/matrizes/poses dos seguidores nas três etapas). Coeficientes/pose admitem 32*N epsilon vezes max(1,abs(expected)), N é o número esperado de seguidores (2 normalmente, 4 no init repetido). Skew derivado por cancelamento admite 8 epsilon inclusive zero contra resíduo, mas pares de zeros assinados continuam exatos. Nenhum budget das outras suítes mudou.

Evidência do condicionamento: no cenário 1725, curva fechada refletida e espaçamento percentual propagam diferenças de comprimento para coordenadas por cerca de 1e-13; no init repetido, a composição gera cerca de 2e-14 na rotação inferior. Não alterar o algoritmo para forçar igualdade entre bibliotecas matemáticas. São 5.275 componentes aproximados em Lua 5.4 e 5.274 em LuaJIT local, sem divergência estrutural.

Domínio: fixtures numéricas e representações documentadas; não promete objetos JS arbitrários, coerções exóticas, todas as topologias ou integração com pai Surface. Armature.init/advanceTime, Animation, factories e renderização continuam pendentes.

## Reprodução

`node tests/path_differential.js ../DragonBonesJS lua5.4` (ou luajit). Quarto argumento opcional seleciona índice ou operação, por exemplo reinit/copy/cleanReturn. `lua5.4 examples/run.lua path` importa examples/path_ske.json e move os seguidores em 25/50/75%, imprimindo coordenadas. Não reproduz animação nem abre janela.
