# Inicialização, fade e controles de AnimationState

Fonte: DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e, animation/AnimationState.ts. Lidos init, _advanceFadeTime, play/stop, fadeOut, máscaras, addState, activeTimeline e getters de fade/reprodução; versão Lua do backup cd4206a8 consultada. Depende de AnimationConfig, Action/ZOrder/Animation timelines, eventos/core e bones reais já portados. Permanecem ausentes _updateTimelines, _updateBoneAndSlotTimelines e advanceTime; Animation também ainda pendente. Não há player substituto.

## Contrato

init é guardado por _armature e copia os valores de AnimationConfig sem normalizar os sentinelas que o facade Animation futuramente tratará. Configuração de intervalo usa position/duration; duration negativo usa duração do modelo e position inicial, incluindo o ramo reverso. Preserva -0.000001 para começar reverso em zero, progresso 0.999999 para fade inicial não positivo e o cálculo original duration-currentTime quando o tempo inicial da actionTimeline é negativo. Não corrigir esses números por conveniência. Cria ActionTimelineState real e ZOrderTimelineState só quando o modelo contém dados de ordem. Copia a máscara por conteúdo, conservando identidade separada.

_advanceFadeTime usa abs(delta), inicia e completa transições e emite eventos reais condicionados a parent/actionEnabled/listeners. Fade de entrada completo ativa bit 1 e limpa _fadeState; fade de saída completo mantém _fadeState positivo. Chamada direta repetida do helper pode repetir eventos de conclusão, como no pin; a orquestração completa ainda cabe ao advanceTime pendente.

fadeOut limita duração negativa a zero, aplica pausePlayhead ANTES da guarda que ignora pedidos mais longos, preserva o ajuste 0.000001 e recalcula duração/restante pela progressão atual. Propaga fadeOut para timelines reais e estados filhos (999999/true), sem assumir que child._parent é o próprio estado. play/stop e getters isPlaying/isCompleted seguem os bits e a actionTimeline, não são um scheduler. Helpers de bits preservam ToInt32 numérico (NaN/Infinity, fracionários e valores fora de 32 bits nos cenários declarados).

Máscara vazia significa todos os bones. addBoneMask ausente retorna sem dirty; demais alterações usam a hierarquia real. Remoção recursiva com máscara vazia preenche o complemento da subárvore. activeTimeline só marca dirty e currentTime=-1 nas timelines de slot. addState cria as três timelines reais: Progress pode substituir parent e desabilita resetToPose; em blend 1D copia x/y e zera peso. Sem Progress, um parent preexistente é preservado. Chamadas repetidas não deduplicam timelines. Getters de estado são readonly.

## Evidência e limites

338 cenários/1.065.864 colunas por VM Lua 5.4/LuaJIT, uma escrita readonly que falha e 1.014 leituras de getters após limpeza que falham como no source; zero aproximações numéricas. São 324 configurações com velocidades -1/0/1, posições 0/0,25/1,25, durações -1/0/0,5, fade inicial -0,5/0/0,5, pauseFadeIn boolean e pesos 0/1,5. Quatro perfis variam máscara, nomes, parent, listeners e flags. Outros 14 casos: reinit, argumentos padrão, máscara não recursiva/ausente, ligação sem dados/só peso/repetida, fade precoce, readonly, estado concluído, bits, parent estrangeiro, ausência de zOrder e duração negativa de fadeOut.

Compara snapshots antes/depois do despacho: configuração, flags, tempos, máscaras e contains, clones independentes, timelines reais por lista, estado filho, eventos/checks de listeners/fila/descarte e pooling. Core/WorldClock/Armature/Bone/Slot/AnimationConfig/AnimationState/ActionTimeline/EventObject reais. Só interfaces externas de dispatcher/hooks de Slot usam observadores. Regressão animationcontrol refeita nas duas VMs: 747 cenários/549.045 colunas sem aproximações.

Domínio: modelos/coleções densas/configurações numéricas declaradas, FPS positivo, duração de intervalo incluindo zero e interfaces observadoras não reentrantes. Não promete coerções JS arbitrárias ou montagem automática/avanço completo de timelines. Nenhum budget anterior ampliado. Preservar retornos parciais/flags/ownership do source ao ampliar o player.

Nove mutações deliberadas rejeitadas: retirar guarda de init, inverter origem reversa, omitir abs do fade, alterar complemento da máscara, remover gate de parent nos eventos, substituir parent indevidamente, aplicar pausa depois da guarda de fadeOut, omitir fade do filho e não limitar duração negativa. Fonte restaurada antes da execução integral final.

## Reprodução

`node tests/stateinit_differential.js ../DragonBonesJS lua5.4` ou luajit; quarto argumento opcional seleciona índice/operação. Artefatos preservam entradas/expected/actual/result. `lua5.4 examples/run.lua stateinit` usa init e addState reais, máscara branch/tip, play/stop e eventos de fade. O helper de fade é chamado explicitamente; Armature permanece fora do clock enquanto advanceTime estiver incompleto. Fade 0,5→1 na entrada e 0,5→0 na saída. Limpeza antes dos modelos, sem renderer.
