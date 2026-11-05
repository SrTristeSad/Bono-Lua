# Timelines de IK e ordem dos slots

Fonte: DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e. Corpos completos de IKConstraintTimelineState/ZOrderTimelineState em animation/TimelineState.ts e Armature._sortZOrder em armature/Armature.ts lidos, além das versões Lua das timelines no backup cd4206a8. Módulo ConstraintOrderTimelineState; agora são 12/16 classes concretas portadas. Armature permanece parcial.

## Contrato

IK.init usa frameIntArray e escala 0,01. _onUpdateFrame chama a base, mas publica _currentA>0 e _currentB no solver, não _resultA/_resultB interpolados. Não corrigir esse comportamento por expectativa: None e single podem conservar _current em zero mesmo com _result diferente; durante tween os valores publicados mudam por keyframe. Pose sem dados usa bendPositive/weight do IKConstraintData. Sempre chama IK.invalidUpdate e limpa dirty. A invalidação marca root e segundo bone quando existe, não o alvo.

ZOrderTimelineState aplica o frame somente com playState>=0; count>0 chama Armature._sortZOrder com offset do buffer, count<=0 pede restauração original. Hook _onUpdateFrame vazio conforme source. Pose sem TimelineData não tem buffer de frames e pode falhar ao chegar ao frame: erro original preservado, sem defaults fictícios.

Armature._sortZOrder percorre sortedSlots do modelo e busca os slots reais por nome. Índices fora de [0,length) são ignorados; duplicados sobrescrevem o mesmo slot; slots ausentes são ignorados. Índices fracionários/ausentes podem falhar após escritas parciais, conforme o pin. Uma ordem customizada marca _slotsDirty/_zOrderDirty; restauração só ocorre quando havia ordem customizada suja, chama _setZOrder em todos os slots encontrados e limpa _zOrderDirty. _setZOrder não ganha guarda para valores inalterados. Este método define ranks/flags, não substitui o sort posterior de Armature.advanceTime ou os hooks do renderer.

## Evidência e domínio

596 cenários/215.156 colunas por VM Lua 5.4/LuaJIT, 164 erros de etapas esperados e zero aproximações numéricas. Grade de 576 combinações: duas timelines, pose/dados, quatro tweens, zero/uma/duas repetições, três estados de playhead e quatro variantes (IK de um/dois bones, dobra/peso do modelo; mapas de ordem distintos, duplicados e fora dos limites). Sete tempos incluem reverso, último frame e loop. Mais 20 casos cobrem single/fadeOut/reinit/slot ausente/clear/restauração/duplicados/limites/fracionários/índices ausentes. Erros esperados incluem ZOrder sem dados, reinicialização e mapas fracionários/truncados.

Modelos vêm do parser real, runtime usa IKConstraint/Bone/Slot/Armature/pool e views tipadas reais. Subclasse Slot fornece só quatro hooks abstratos de montagem/limpeza. AnimationState é contrato explícito de campos de entrada, sem controlador/player fictício. Compara binary64 exato para todos os valores do sampler/IK, flags de invalidação, ranks/dirty, referências e limpeza. Esta suíte não repete comparações numéricas de matrizes do solver; a suíte IK anterior cobre o solver e o exemplo executa Bone.update/IK reais.

Domínio: entradas e representações declaradas, duração/FPS/escala temporal positivos e topologias regulares. Não promete todas as coerções JS nem ordenação/renderer/player completos. Nenhum budget anterior alterado.

Quatro mutações deliberadas rejeitadas: publicar _resultB no IK, omitir invalidUpdate, remover limites dos índices e bloquear restauração da ordem original. Fontes restauradas antes da execução integral final.

## Reprodução

`node tests/constraintorder_differential.js ../DragonBonesJS lua5.4` ou luajit. Quarto argumento opcional seleciona índice/operação. Artefatos guardam inputs/expected/actual/result. `lua5.4 examples/run.lua constraintorder` importa JSON, passa peso/dobra ao IK e ranks aos slots, executando Bone.update real. Imprime peso 1/1/0,25/0,25, dobra true/true/false/false e ranks 2,0,1 → 0,1,2. Tempo/montagem manuais, sem player ou renderer.
