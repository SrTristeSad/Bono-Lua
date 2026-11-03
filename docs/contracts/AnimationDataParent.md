# Fronteira AnimationData.parent

Fonte auditada: model/AnimationData.ts e model/ArmatureData.ts em DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e. Este documento descreve a leitura feita por cacheFrames, não declara uma interface upstream nova nem fornece uma classe ArmatureData substituta.

| Acesso do algoritmo | Contrato Lua |
| --- | --- |
| parent.sortedBones | Array lógico base 1 com length; cada entrada deve expor name string |
| parent.sortedSlots | Mesmo contrato para slots |
| bone.name / slot.name | Chave dos índices de cache; nomes repetidos substituem o array anterior |

O algoritmo não instancia ArmatureData nem chama seus métodos; só percorre essas listas. A lista de slots é lida depois dos bones. Falhas e posições undefined propagam erro após os efeitos anteriores do cache. Rate positivo faz o método retornar antes de acessar parent.

O teste usa registros locais com listas e getters de nome para observar ordem e falhas. Não são objetos de produto, não provam ArmatureData/BoneData/SlotData portados e não implementam classificação de bones, cache de transformações ou playback.

A leitura completa de ArmatureData.ts mostrou outras responsabilidades: reciclagem de modelos, ordenação dependente de pais/constraints, cache de animações, escrita/leitura de dez valores no cachedFrames de DragonBonesData e acesso a skins/displays. SurfaceData instancia GeometryData de DisplayData.ts. Essas dependências reais precisam de auditoria/implementação antes da integração; não criar constantes ou classes provisórias para contorná-las.
