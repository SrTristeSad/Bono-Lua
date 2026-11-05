# Controle de animação e ciclo de vida de AnimationState

Fonte: DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e. Lidas as três classes finais de animation/TimelineState.ts e os corpos selecionados de animation/AnimationState.ts; versões Lua do backup cd4206a8 consultadas. AnimationTimelineState exporta AnimationProgress/AnimationWeight/AnimationParametersTimelineState. Os corpos das 16 classes de TimelineState.ts estão agora portados em módulos separados, com integração do player ainda pendente.

## AnimationState parcial, real

Portados construtor/toString, _onClear completo, getters currentPlayTimes/totalTime/currentTime/weight/animationData e setters currentTime/weight. Os outros métodos, incluindo init/advanceTime/construção de timelines/fade/play/stop, permanecem AUSENTES. Não há controlador substituto. Arrays são JSArray lógicos, conservam identidade no pool; o iterador acompanha comprimento vivo, inclusive posições vazias que podem causar erro conforme o source.

_onClear devolve timelines pertencentes ao estado, além de action/zOrder. Timelines de controle podem apontar para estados filhos: só quando child._parent==self marca fade/subFade=1 e remove parent; não devolve o filho ao pool. _poseTimelines é lista de aliases, esvaziada sem devolver novamente objetos já pertencentes às outras listas. Limpa referências a modelos, sem assumir sua propriedade.

currentTime usa remainder assinado quando fora de [0,duration], preserva o número de ciclos da actionTimeline e o ajuste duration-0.000001 no último ciclo de um estado raiz. Retorna cedo se _time não muda. Quando muda, chama ActionTimelineState.setCurrentTime real e invalida playState de zOrder, boneTimelines e slotTimelines; não estende a invalidação às outras listas. weight retorna cedo se não muda e só marca dirty em boneTimelines, boneBlendTimelines e slotBlendTimelines. Getters sem setter permanecem readonly.

## Três timelines

As três leem frameIntArray com escala 0,0001 e chamam a interpolação real das bases. Só publicam quando target._parent não é null; não exigem que esse parent seja o estado controlador. Progress escreve currentTime=result*totalTime, acionando o setter real; Weight escreve weight, acionando invalidação real; Parameters escreve parameterX/Y diretamente. Limpam dirty mesmo quando não publicam. Pose sem dados, último frame, repetição e valores negativos/acima de 1 seguem o pin; não clampá-los por conveniência.

## Evidência e domínio

747 cenários/549.045 colunas por VM Lua 5.4/LuaJIT, 24 erros de escrita readonly esperados, 1.494 leituras de getters que falham após limpeza e zero aproximações numéricas. Grade de 720 combinações: três timelines, pose/dados, parent ausente/presente, cinco tweens, durações filhas 0,5/1/2, controlador com zero/duas repetições e duas direções. Oito tempos incluem tempo repetido, salto, último frame, loop e reverso. Outros 27 casos cobrem seek negativo/além/fim/igual, peso igual, readonly, detach, parent estrangeiro e zero negativo.

Alvos e controlador são AnimationState reais (com APIs selecionadas), e ActionTimelineState, seis classes de timelines auxiliares, modelos/parser/Armature/pool e views Int16/Uint16 são reais. Sem registros substitutos de AnimationState neste diferencial. A montagem é manual porque init/advanceTime ainda não existem. Compara resultados, efeitos dos setters por lista, referências, array aliases, ownership, desanexação dos filhos e flags de pooling. Os getters currentTime/currentPlayTimes falham sem actionTimeline após limpeza, como no source.

Domínio: buffers completos declarados, estados montados manualmente com duração/FPS positivos e coleções densas de timelines reais. Não promete todos os métodos de AnimationState, todos os casos de coerção JS, player/factory/renderer completos. As métricas de leitura pós-limpeza são separadas das exceções de etapas. Nenhum budget anterior alterado.

Sete mutações deliberadas rejeitadas: remover gate de parent, alterar escala dos inteiros, omitir invalidação de peso, omitir invalidação de seek, não desanexar filho, remover ajuste de fim e exigir que parent seja exatamente o controlador. Fontes restauradas antes da execução integral final.

## Reprodução

`node tests/animationcontrol_differential.js ../DragonBonesJS lua5.4` ou luajit; quarto argumento opcional seleciona índice/operação. Artefatos guardam entrada, expected, actual e resultado. `lua5.4 examples/run.lua animationcontrol` importa JSON, monta estados reais e imprime tempo 0/1/2/1, peso 1/0,625/0,25/0,625 e parâmetros X/Y. Saída com três casas; ajustes de precisão originais são preservados. Tempo e montagem manuais, sem player ou renderer.
