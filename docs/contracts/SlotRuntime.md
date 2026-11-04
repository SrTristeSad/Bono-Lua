# Slot — pipeline de atualização e displays

Fonte: DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e, armature/Slot.ts e métodos necessários de Armature.ts. TS e Lua do backup cd4206a8 lidos; oráculo executa o TS fixado. Completa os corpos de Slot e seus acessores/aliases, conservando os quatorze hooks abstratos. Não implementa renderer, Animation ou Armature.init/advanceTime.

## Contrato preservado

replaceDisplay grava o frame antes de callbacks e não descarta a referência anterior se for compartilhada, raw/mesh ou Armature. Retenção do novo objeto usa _hasDisplay(prevDisplay), exatamente como no original; não trocar por _hasDisplay(value). Uma substituição de child Armature não o descarta automaticamente. displayList retorna uma cópia lógica e seu setter passa por replaceDisplay em ordem; null tem posição/comprimento mesmo como nil Lua. display não altera _display imediatamente: passa pelo frame e fica dirty. displayIndex sempre chama update(-1), inclusive quando o índice é igual. Aliases getDisplay/setDisplay preservados.

_updateDisplay distingue somente null, não truthiness. false/0/string vazia são displays válidos no domínio any. Reconhecimento de Armature é por classe/metatable, sem duck typing nem dependência fictícia. Marca flags antes de _onUpdateDisplay/_replaceDisplay. Para filhos, desliga parent/clock antes de reset e liga parent/clock/cache antes de ações/play. Falhas preservam o estado parcial original, sem rollback.

update consome flags depois de cada chamada. Atualiza frame antes de retornar por display null. Mesh com skin ou pai Surface pode retornar antes da transformação do slot; o hook _updateMesh recebe _verticesDirty=false e pode rearmá-lo. Cache hit/restore/reuse/miss seguem a ordem original, inclusive preferência do hit sobre parent dirty. Arrays de cache públicos usam base 0; armazenamento Lua base 1 com length lógico. Mantidas as diferenças/TODOs documentados nas unidades anteriores, inclusive pivôs e truncamento de frames sem pooling.

## Armature e ownership

clock adiciona/remove no WorldClock real e propaga a filhos sem substituir o sistema por um relógio fake. cacheFrameRate chama ArmatureData.cacheFrames real e propaga a filhos. _bufferAction deduplica por identidade; append=false insere no começo, preservando a reversão das ações de child. dispose marca _lockUpdate antes de Core.bufferObject; a devolução ao pool acontece no próximo Core.advanceTime, não imediatamente. _onClear de Slot encaminha child.dispose e deduplica referências.

Construção ainda manual: bind _armatureData/_dragonBones/_display de Armature aos objetos reais. Não chamar advanceTime de um WorldClock que ainda contenha Armature sem seu runtime Animation/advanceTime pronto. Na limpeza testada, root.returnToPool remove root/filhos do relógio; Core.advanceTime(0) drena descartes; modelos são liberados por último. display/animation/parent de Armature são somente leitura.

## Evidência e fronteiras

1.970 cenários/7.880 etapas/165.480 colunas por VM, 333 exceções de etapas esperadas e zero aproximações locais. 1.024 casos de substituição/listas/callbacks, 850 de update com cache e mesh/Surface e 96 de filhos. Quatro etapas observam referências, cópia de listas, flags, matrizes/cache, ordem/argumentos/estado de hooks, ações/eventos, parent/clock/lock/pool. Cleanup compara fila antes/depois do Core real. O teste limpa o pool da classe observadora a cada cenário para separar suas closures, sem alterar a semântica do pool do produto.

Bone e Surface vêm de fixtures JSON reais importadas pelo parser. Classes de geometry/weight e seus metadados sintéticos exercitam a seleção/chamada do hook, sem validar cálculo de vértices/GPU. Display objetos opacos, false/0/string vazia, __eq sobrecarregado e objeto parecido com Armature estão cobertos. Casos de Surface aceitam somente no matrix/global/cache o budget de 32 eps da unidade Surface: coeficientes/pose max(1,abs(expected)), coordenadas incluem escala de projeção 1000; pares de zeros e todas as flags/refs/índices são exatos. Demais cenários têm comparação exata. Nenhum limite de outra suíte mudou.

Child inheritAnimation=false e attach com ActionData/EventObject reais são validados sem Animation fake. Play/reset quando Animation ainda é nil são exceções comparadas em montagem manual, não sucesso de playback. Excluídos reentrância arbitrária, proxies/protótipos/coerções genéricas, subclasses incomuns fora do padrão Lua declarado, ciclos de clock/child, alocações enormes e uso antes de _onClear. APIs restantes de Armature/factory/Animation/backends/IK/Path continuam pendentes.

Seis mutantes rejeitados e arquivo restaurado antes dos testes finais nas duas VMs. Exemplo slotruntime percorre displayIndex/update público com observador local, sem renderização. Os exemplos slot/slotdata anteriores preservam a montagem de baixo nível para comparação.
