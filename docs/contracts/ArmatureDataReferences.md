# Fronteiras remanescentes de ArmatureData

Atualização de SkinData: a suíte skindata_differential agora usa SkinData/displays reais em ArmatureData.addSkin/getMesh/_onClear. Os registros de skin da suíte isolada antiga permanecem apenas nessa prova anterior; a fronteira global DragonBonesData ainda está pendente.

Atualização: constraintdata_differential agora exercita ArmatureData com IKConstraintData/PathConstraintData reais, além de bones/slots/path display reais. A suíte armaturedata isolada abaixo mantém seus registros anteriores; SkinData e DragonBonesData continuam como fronteiras, e os solvers de runtime estão pendentes.

Fonte: model/ArmatureData.ts em DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e. As quatro classes desse arquivo são código de produto; esta tabela identifica referências externas ainda exercitadas por contratos, sem substituí-las por classes fictícias.

| Referência | Uso no algoritmo | Limite atual |
| --- | --- | --- |
| constraints[name] | name, root, target e returnToPool | Registros de teste; ConstraintData real e solver de runtime pendentes |
| skins[name] | name, parent, getDisplay(slotName, meshName), returnToPool | Registros de teste retornam MeshDisplayData real; SkinData e sua lista de displays pendentes |
| parent.cachedFrames | Array lógico numérico compartilhado; resize antes de escrever dez componentes | Registro de armazenamento no teste; DragonBonesData real e buffers binários pendentes |

Já são reais na suíte armaturedata_differential: ArmatureData/BoneData/SurfaceData/SlotData, AnimationData, GeometryData/WeightData, Matrix/Transform/Rectangle/ColorTransform, CanvasData, ActionData/UserData e o pool BaseObject. AnimationData.cacheFrames percorre os sortedBones/sortedSlots reais; não usa o registro de parent da antiga suíte isolada. O registro de armazenamento global é uma fronteira diferente, usada somente por setCacheFrame/getCacheFrame.

Estados internos distinguem referências undefined no construtor de null após limpeza/atribuição nil em defaultSkin/defaultAnimation e BoneData.parent. Publicamente ambas leem nil; a decisão de igualdade estrita com null é preservada. Outros descritores/proxies/reflexão e rawset que burle esses acessores não são equivalência declarada.

sortBones mantém as esperas originais por pai e alvo de constraint. Não acrescenta detector de ciclos, fallback ou timeout ao produto. A suíte usa grafos acíclicos; dados com ciclos, pais ausentes/undefined ou duplicatas diretas no array podem não terminar no original. O timeout do subprocesso Lua é limite do teste, não comportamento do motor.
