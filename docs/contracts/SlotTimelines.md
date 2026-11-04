# Timelines de slots e alpha

Fonte integral dos quatro corpos em DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e, animation/TimelineState.ts; versão Lua do backup cd4206a8 consultada. Módulo SlotTimelineState exporta AlphaTimelineState, SlotDisplayTimelineState, SlotColorTimelineState e SlotZIndexTimelineState. Junto com BoneTimelineState são 8/16 classes do arquivo, ainda parcial.

## Contrato

AlphaTimelineState usa frameIntArray com escala 0,01 e pose 1. Target é BlendState real para Bone ou Slot. Primeiro blend substitui alpha sem clamp; contribuições posteriores somam e limitam somente o teto em 1. Não adicionar piso nem limitar o primeiro peso. Dirty marca Armature._alphaDirty, sem forçar uma atualização global inexistente.

SlotDisplayTimelineState aplica índice do frame ou displayIndex de SlotData, somente com playState>=0. Chama Slot._setDisplayIndex(index,true) quando muda, preservando _animationDisplayIndex e flags do Slot real. Hook de update é vazio no source. Não invocar setter público/update completo em seu lugar.

SlotColorTimelineState mantém três arrays fixos de oito valores, cuja identidade e conteúdo sobrevivem a _onClear/pooling como no pin. Não limpar arrays por conveniência. Lê índices de cores via frameIntArray, incluindo ajuste +65536 para offsets negativos. Interpola quatro multiplicadores com escala 0,01 e quatro offsets sem escala, faz wrap no último frame e usa SlotData.color na pose sem dados. Fade usa progresso elevado a 4 e conserva dirty; fora do fade, limpa dirty e copia só quando há diferenças. fadeOut desativa tween, sem limpar dirty. Buffers usam JSArray lógico; valores numéricos permanecem binary64.

SlotZIndexTimelineState usa valores inteiros sem escala e pose slotData.zIndex. Blend inicial substitui, posteriores somam; dirty marca Armature._zIndexDirty. A ordenação completa de Armature continua pendente, assim como propagação automática de alpha pelo player.

## Evidência e domínio

992 cenários/639.840 colunas por VM Lua 5.4/LuaJIT, zero erros de etapas e zero aproximações numéricas. São 960 combinações de quatro classes, pose/dados, cinco tweens, três estados de fade, quatro pesos -0,5/0/0,5/1,5 e duas variantes (target bone/slot para alpha, mistura na mesma/outra camada e progresso de fade 0,5/0,75). Mais 32 casos de fadeOut, cleanBlend, reset, clear, single, lastLoop, stopped e negativeColorOffset. Sete tempos incluem reverso, último frame e loop. Compara resultados, cor completa, flags, índices de display, alpha/z, BlendState, referências e identidade/conteúdo de arrays após pool.

Modelos, Slot/Bone/Armature, BlendState, timelines, pool e views tipadas são reais. Subclasse observadora implementa só os quatro hooks abstratos necessários para montar/limpar Slot; não desenha nem substitui métodos de seleção. AnimationState ainda é contrato explícito de campos nos testes/exemplo, sem implementação de controlador.

Domínio: buffers completos, duração/FPS/escala temporal positivos e cenários declarados. Não promete todas as coerções JS, buffers arbitrariamente truncados, todas as topologias, ordenação/propagação completas de Armature, player ou renderer. Mantidos todos os budgets das outras suítes.

Cinco mutações deliberadas rejeitadas: remover teto de alpha no acúmulo, trocar flag de animação do índice, mudar expoente do fade, alterar ajuste do offset negativo de cor e omitir zIndexDirty. Fonte restaurada antes da execução integral final.

## Reprodução

`node tests/slottimeline_differential.js ../DragonBonesJS lua5.4` ou luajit; quarto argumento opcional seleciona índice/operação. Artefatos preservam entradas/expected/actual/result. `lua5.4 examples/run.lua slottimeline` importa examples/slottimeline_ske.json pelo parser real e aplica quatro timelines ao Slot. Imprime display 0/0/1/1, vermelho e alpha 1/0,6/0,2/0,6, z 0/2/4/2. Tempo e montagem manuais, sem player/tela.
