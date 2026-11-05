# Construção e avanço reais do estado

Fonte: DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e. Lidos `_updateTimelines`, `_updateBoneAndSlotTimelines` e `advanceTime` de AnimationState.ts, construtor/limpeza/init/getBlendState/advanceTime de Animation.ts; consultados os corpos Lua do backup cd4206a8. Os demais corpos de AnimationState foram portados nas etapas anteriores.

## Algoritmo e representação

A construção usa os bones, slots, constraints, displays e modelos reais da armadura. Timelines são emprestadas das classes concretas existentes; poses são aliases não proprietários. Reconstrução por máscara conserva grupos existentes e devolve os excluídos ao pool. O binding de deformação procura o geometry offset binário e configura displayFrame antes de init. Os mapas preservam a ordem JS de chaves próprias, inclusive índices inteiros; nomes especiais de protótipo não fazem parte deste contrato. Arrays usam length lógico e armazenamento Lua base um, conservando offsets públicos base zero.

O avanço conserva a ordem fade → tempo → construção → action → cache → poses/blends/slots/constraints/filhos → remoção das poses → autoFadeOut. Peso zero ainda avança ações e construção antes do retorno, mas não executa o restante. Cache usa Math.floor adaptado para conservar zero assinado e quantização de meio frame. Os loops numéricos capturam length; loops for-of usam comprimento vivo. Slot captura o blend antes de update como no original.

E1D mantém os sentinelas dL/dR=100, seleção por parameterX, ativação apenas do filho A, e pesos anteriores quando não encontra filho à esquerda. Animation conserva o primeiro target de cada BlendState, reseta blends por frame, distingue zero/um/vários estados e adia a reciclagem pelo DragonBones core. Vários estados desabilitam cache e compactam a lista; o ramo de um estado conserva o cache index ao remover o último estado até o frame seguinte. Cache de slots só é vinculado ao rawDisplayData da defaultSkin.

## Validação

`tests/stateadvance_differential.js` transpila os blobs do commit original e compara com `tests/stateadvance_differential.lua`. 200 cenários, dez deltas por cenário e 392.400 colunas por VM Lua 5.4/LuaJIT, zero aproximações. Números são comparados pelos bytes binary64, incluindo sinal de zero; NaNs por categoria. Casos cruzam zero/um/dois/três estados, poses opcionais, fade, cache, reprodução reversa e pesos 0/.5/1.5. Casos adicionais mudam máscaras, play/stop/fadeOut, displayController/displayControl, cache e reutilização do blend, ou usam animação sem dados.

Fixture JSON real com Bone/Surface, malha não ponderada, display/cor/alpha/z, IK, eventos de frame/som e controlador E1D. Cada frame executa Animation.advanceTime, Bone.update/_updateAlpha, Slot._updateAlpha/update e despacho no core real; subclasses de Slot só observam os 14 hooks de renderer. Compara poses, tempos/listas/pool, buffers deformados, cores/flags, referências de cache, mapas de blends, fila e despacho, sequência de callbacks. Matrizes trigonométricas não são comparadas nesta suíte; os contratos numéricos específicos de Bone/Surface/IK continuam vigentes e não foram ampliados. Sem clock contendo Armature incompleta.

Oito mutações foram rejeitadas: construção omitida, retorno de peso zero removido, poses não limpas, cache sem quantização, blends sem reset, estado faded retido, lista sem compactação e gate displayControl removido. Regressões stateinit e animationcontrol nas duas VMs; CI executa todas as 51 suítes e dezenove exemplos por VM.

## Uso e fronteiras

`lua5.4 examples/run.lua playback` (também LuaJIT) imprime root pose.x/mundo.x 0→20→40→20 e a troca de display no meio do ciclo. Montagem e registro do estado são explícitos; o backend conta callbacks sem desenhar pixels. A animação avança pelo delta, sem atribuir manualmente os tempos das timelines.

Animation ainda não fornece playConfig, play, fadeIn, reset, seleção de estados nem o restante do facade. Armature.init/advanceTime e fábricas/backends permanecem pendentes. Não interpretar todos os corpos de AnimationState como compatibilidade integral de DragonBonesJS ou validação de toda entrada arbitrária. Herança de escala de tempo, cache de skin alternativa, malhas ponderadas, nomes numéricos e reentrância ficam para ampliar a cobertura de integração; as unidades existentes continuam cobrindo seus algoritmos isolados.
