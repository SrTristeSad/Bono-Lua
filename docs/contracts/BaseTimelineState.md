# Bases de timeline

Fonte: DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e, animation/BaseTimelineState.ts; arquivo integral e versão Lua do backup cd4206a8 lidos. Módulo dragonbones.animation.BaseTimelineState exporta TimelineState, TweenTimelineState, SingleValueTimelineState, DoubleValueTimelineState e MutilpleValueTimelineState (grafia original).

## Contrato

Preservados os corpos de todos os métodos das cinco bases, inclusive blend vazio original. TimelineState mantém callbacks abstratos ausentes; subclasses precisam implementá-los quando não herdarem corpos concretos das outras bases. Sem toString artificial para classes abstratas; subclasses declaram identidade para pooling. Construtores aceitam classe derivada. _rd usa JSArray lógico, conserva identidade e perde conteúdo na limpeza; índices públicos de buffers são base zero, armazenamento Lua base um.

_setCurrentTime mantém tempo reverso, remainder assinado, contagem de repetições, _playheadState, posição/duração, escala/offset, driver de ação e exceção de precisão duration+0.000001 na conclusão. Reinício/loop invalida índice conforme condição original; tempo inalterado não dispara callbacks novamente. init não possui guarda nem limpa referências de buffers anteriores se receber timelineData nil em reinicialização. O teste de reinit compara os erros subsequentes do original.

update seleciona frame por frameIndices e offsets reais; arrive chama atualização conforme dirty/_isTween. Tween mantém None/Line/Curve/QuadIn/QuadOut/QuadInOut, curva amostrada e transição final/loop. Single/Double/Mutilple preservam escala, diferença, wrap do último valor, estado de pose sem dados e ordem de operações. Samples ausentes do helper de curva participam da aritmética como NaN, conforme JSValue.number; não são substituídos por zero.

## Evidência e domínio

2.700 cenários e 1.052.450 colunas por VM Lua 5.4/LuaJIT; 25 exceções esperadas no reinit, nenhuma aproximação numérica. São 2.160 combinações de cinco classes, zero/um/três frames, seis tweens, zero/uma/duas repetições, driver externo ou próprio, escala temporal 50/100 e offset 0/25; escala dos valores 1/0,5/-1 alternada. Nove tempos incluem negativo, zero, frações, fim e repetição. Mais 50 casos de pausa/parada/fadeOut/reinit/clear/noAction/zeroSpan/curveZero/curveNegative/blend e 490 helpers de easing/tipo/progresso/peso.

Modelos DragonBonesData/ArmatureData/AnimationData/TimelineData, Armature, pool, Int16/Uint16/Float32 compartilhados e arrays lógicos são reais. As subclasses Probe só contam callbacks e chamam super; a base puramente abstrata ganha hooks observadores no teste. AnimationState é somente um registro explícito de campos consumidos nestes testes e no exemplo, NÃO uma implementação do player. Não há substituto de produto para Animation/AnimationState nem alegação de reprodução integrada.

Comparação binária de números binary64, flags, contadores, referências, offsets, buffers e limpeza; NaN por categoria, payload não prometido. Sem ampliar budgets existentes. O domínio temporal testado usa duração/FPS/escala temporal positivos; duração/FPS/escala zero, arrays truncados arbitrários, coerções JS gerais e subclasses concretas de TimelineState.ts ficam fora desta evidência.

Quatro mutações rejeitadas: remover epsilon de conclusão, inverter clamp superior da curva, mudar fadeOut para dirty=true e omitir limpeza de _rd. Produto restaurado antes da reexecução integral final.

## Reprodução

`node tests/basetimeline_differential.js ../DragonBonesJS lua5.4` (ou luajit). Quarto argumento opcional: índice ou operação, como reinit/helper/clear. Artefatos preservam entrada, expected, actual e resultado. `lua5.4 examples/run.lua timeline` importa examples/timeline_ske.json com o parser real e interpola translação 0/20/40/20 nos tempos 0/0,25/0,5/0,75. Não aplica pose a Bone nem abre janela.

Próximo trabalho: subclasses concretas de TimelineState.ts e BlendState; depois AnimationState/Animation e integração de Armature. Preservar contratos e ownership; não preencher dependências com player fictício.
