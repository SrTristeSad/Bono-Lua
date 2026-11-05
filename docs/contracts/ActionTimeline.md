# ActionTimelineState — ações e eventos

Fonte: DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e, animation/TimelineState.ts. Classe completa e versão Lua do backup cd4206a8 lidas. Armature.eventDispatcher segue o getter de armature/Armature.ts, retornando _proxy somente leitura. Interfaces IEventDispatcher consultadas: implementações são responsabilidade dos backends. TimelineState.ts agora tem 13/16 classes portadas; AnimationState/Animation ainda pendentes.

## Contrato

Portados _onCrossFrame, hooks vazios originais, update e setCurrentTime. A classe usa TimelineState real para tempo/loop e percorre keyframes em ambas as direções, com filtro inclusivo de intervalo. Mantém ordem de frame/som/loopComplete/complete do pin, seleção inicial, flags e reset de ordem dos slots por displayControl/resetToPose. Leituras numéricas anteriores ao buffer produzem NaN; não inventar cruzamento inicial em montagem manual partindo de currentTime=-1.

Play gera EventObject real e entra em Armature._bufferAction; não executar Animation inexistente. Frame exige listener; Sound não exige listener local para entrar na fila e é despachado pelo core também ao gerenciador global de som. actionEnabled suprime ações de frames. _parent não nulo suprime eventos de ciclo de vida, mas não substitui o gate actionEnabled do cruzamento de frames. Todos esses ramos são preservados separadamente.

EventObject.actionDataToInstance resolve bone/slot por nome na armadura real e conserva referência aos dados da ação. A lista de ações vem de animationData.parent, que pode ser um modelo diferente da armadura runtime. Tempos de frame usam divisão framePosition/frameRate, não multiplicação por reciprocal; eventos de ciclo de vida conservam time=0 da limpeza original.

DragonBones.bufferEvent/advanceTime/bufferObject são usados sem substitutos. Ações Play permanecem na fila da armadura até o player futuro ou limpeza; eventos despachados entram no descarte adiado e voltam ao pool no próximo advanceTime. O exemplo mantém Armature fora do WorldClock porque advanceTime da armadura ainda está incompleto. Runtime é limpo antes dos modelos.

## Correção na base temporal

A reprodução reversa com tempo -0 revelou perda de sinal em currentPlayTimes: Math.floor(-0) conserva -0, mas math.floor de Lua 5.4 converte para inteiro 0. A base usa agora um helper que retorna o próprio valor quando zero e math.floor nos demais casos, somente nas duas atribuições de currentPlayTimes. Caso 24 do diferencial de ações discrimina a regressão. A suíte basetimeline anterior foi reexecutada integralmente nas duas VMs; seus 2.700 cenários/1.052.450 colunas/25 erros esperados continuam passando sem aproximações.

## Evidência e domínio

585 cenários/242.190 colunas por VM Lua 5.4/LuaJIT, 20 erros de etapas esperados e zero aproximações numéricas. Grade de 576 combinações: pose/um/vários keyframes, ações habilitadas/desabilitadas, parent ausente/presente, duas direções, zero/uma/duas repetições, quatro máscaras de listeners e resetToPose. Oito chamadas por caso cobrem repetição de tempo, saltos e reverso. Outros nove casos: reinit, seek, intervalo, readonly, proxy ausente, AnimationData estrangeiro, clear, displayControlOff e precisão em frame 5/24. Erros de estados inválidos/readonly/proxy ausente são comparados; só a limpeza do harness restaura o proxy para drenar filas que falharam no despacho.

Compara estado do sampler, referências, ranks/flags dos slots, ordem e conteúdo das filas de ações/eventos/objetos adiados, consultas de listeners, despacho local/global, tempos binary64, referências a ActionData/UserData/Bone/Slot e pooling. Modelos/parser/Bone/Slot/Armature/EventObject/DragonBones/WorldClock são reais. Observadores implementam só hooks de Slot e as interfaces externas necessárias; não há dispatcher/backend/player de produto fictício. AnimationState é registro explícito de campos de entrada nos testes/exemplo.

Domínio: buffers e modelos importados declarados, duração/FPS positivos, observadores não reentrantes. Não promete todas as coerções JS, buffers arbitrariamente truncados, controlador AnimationState/Animation, execução de Play ou renderer. Reentrância geral do core tem seu contrato anterior; não é acrescentada por esta suíte. Nenhum budget numérico anterior ampliado.

Seis mutações deliberadas rejeitadas: exigir listener local para Sound, enviar Play à fila de eventos, multiplicar pelo reciprocal em vez de dividir o tempo de frame, remover filtro de intervalo, ignorar parent no ciclo de vida e perder o sinal de zero em floor. Fontes restauradas antes da execução integral final.

## Reprodução

`node tests/actiontimeline_differential.js ../DragonBonesJS lua5.4` ou luajit; quarto argumento opcional seleciona índice/operação. Artefatos preservam entradas, expected, actual e resultado. `lua5.4 examples/run.lua actiontimeline` importa JSON, mostra start/frame/som/loopComplete/complete e três ações Play pendentes, usando as filas e o despacho reais com observadores locais. Montagem/tempo manuais, sem player ou renderer.
