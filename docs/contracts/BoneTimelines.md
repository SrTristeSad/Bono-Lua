# Timelines de bones e BlendState

Fonte: DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e. Lidos os corpos de BoneAll/BoneTranslate/BoneRotate/BoneScale em animation/TimelineState.ts e BlendState em animation/AnimationState.ts; versões do backup cd4206a8 consultadas para os quatro bones. Módulos BoneTimelineState e BlendState. TimelineState.ts permanece parcial (4 de 16 classes); AnimationState.ts tem só BlendState portado, sem o controlador AnimationState.

## Contrato

BlendState preserva constantes, pooling, dirty/layer/leftWeight/layerWeight/blendWeight, update e reset. A ordem das camadas é responsabilidade do chamador; update detecta mudança de layer por desigualdade, não por comparação de prioridade. Primeiro peso não é limitado a [0,1]. Mesma camada acumula; mudança de camada desconta layerWeight de leftWeight ou encerra distribuição. dirty aumenta no ramo de saturação, mesmo quando retorna false. reset conserva target; _onClear limpa target.

As quatro timelines usam init/update herdados e buffers reais. Translate aplica armature.scale na leitura; All aplica escala espacial no blend. Rotate normaliza diferenças no último frame e resultados em fadeOut; All normaliza _rd[2]/[3] no último frame exatamente como o source (não trocar pelos índices das diferenças por achar mais correto). Scale conserva identidade 1 em poses sem timeline. Blend inicial substitui componentes; dirty>1 acumula. Pesos 0/negativos/acima de 1 não são clampados. Campos de transformação não envolvidos na timeline são preservados; isDirty ou dirty marca bone._transformDirty e limpa dirty do sampler.

## Evidência

1.828 cenários e 2.169.836 colunas em cada VM Lua 5.4/LuaJIT: 1.800 combinações de quatro classes, pose sem dados/dados, cinco tweens (None/Line/Curve/QuadIn/QuadInOut), escalas 0,5/1/2, pesos -0,5/0/0,5/1/1,5 e segunda camada abaixo/igual/acima. Mais 28 casos de fadeOut, cleanBlend, reset, clear, single, lastLoop e stopped. Sete tempos incluem reverso, último frame e loop. Cada tempo compara update e três contribuições de blend, incluindo retorno após esgotar peso. Modelos, Bone/Armature, pool, BlendState, timelines e views Int16/Uint16/Float32 são reais. AnimationState continua um contrato explícito de campos apenas no teste/exemplo.

Compara binary64 exato para resultados/poses/pesos/normalizações, flags, retornos, referências, constantes, buffers e limpeza; NaN por categoria. Nenhum budget numérico ampliado. Domínio finito com duração/FPS/escala temporal positivos, buffers completos e um bone regular. Todas as topologias/misturas, slots, Surface, AnimationState/Animation/player e renderização não estão validados por este recorte.

Quatro mutações deliberadas rejeitadas: mudar o primeiro blend para acúmulo, omitir desconto do peso restante, ignorar escala da translação e usar escala zero na pose sem dados. Fontes restauradas antes da reexecução integral final.

## Reprodução

`node tests/bonetimeline_differential.js ../DragonBonesJS lua5.4` ou luajit; quarto argumento opcional seleciona índice/operação. Artefatos guardam entradas e saídas das duas implementações. `lua5.4 examples/run.lua bonetimeline` importa timeline_ske.json pelo parser real, usa BoneTranslateTimelineState/BlendState/Bone.update e imprime pose e mundo em 0/20/40/20. O exemplo anterior timeline continua disponível; nenhum controlador AnimationState fictício foi criado.
