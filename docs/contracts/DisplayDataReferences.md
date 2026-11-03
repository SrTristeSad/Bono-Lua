# Referências de DisplayData

Atualização: ArmatureData/BoneData/SurfaceData/SlotData, SkinData, DragonBonesData e BoundingBoxData agora são modelos reais. As suítes específicas exercitam suas integrações; boundingbox_differential cobre queries locais e ownership com BoundingBoxDisplayData. A suíte displaydata_differential mantém seus probes isolados como prova anterior, sem validar runtime/renderização.

Fontes: model/DisplayData.ts e declaração intArray de model/DragonBonesData.ts em DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e. Este documento descreve fronteiras do arquivo; não cria interfaces upstream ou classes substitutas.

| Referência | Uso real e propriedade |
| --- | --- |
| GeometryData.weight | WeightData real; clear devolve ao pool apenas quando isShared é falso/ausente |
| GeometryData.data.intArray | Buffer Int16Array já decodificado; getters leem offset + BinaryOffset antes da conversão base 1 |
| DisplayData.parent | SkinData, referência não proprietária apagada na limpeza |
| ImageDisplayData.texture / MeshDisplayData.texture | TextureData, referência não proprietária apagada na limpeza |
| ArmatureDisplayData.actions | ActionData reais, devolvidos ao pool na limpeza; podem crescer durante a iteração |
| ArmatureDisplayData.armature | ArmatureData, referência não proprietária apagada na limpeza |
| BoundingBoxDisplayData.boundingBox | BoundingBoxData real proprietário, devolvido na limpeza; queries locais comparadas na suíte específica |
| WeightData.bones | Referências BoneData não proprietárias; duplicatas permitidas, lista esvaziada sem devolver bones |

shareFrom copia somente isShared=true, offset e weight. Não copia data nem inheritDeform e não devolve o weight anterior do destino. Compartilhamento não implementa contagem de referências nem sincroniza a vida útil de consumidores; preservar o comportamento original.

O teste usa WeightData, ActionData/UserData, Transform/Point e TextureData reais. TextureData é instanciado cru no teste para observar uma referência não proprietária, sem subclasse gráfica ou backend. Registros locais representam somente SkinData/ArmatureData/BoneData, o contrato returnToPool de boundingBox e a leitura intArray de DragonBonesData. Esses registros não contam como implementações das classes nem validam parsing binário, deformação, hit testing ou renderização.

No Lua, o buffer de entrada já contém números Int16 decodificados em posições base 1. Os testes usam valores dentro da faixa Int16 (com Int16Array genuíno no oráculo); esta unidade não decodifica bytes nem implementa typed arrays genéricos. Getters rejeitam índices não integrais/negativos/não finitos como posição ausente e mantêm erro se data/intArray não existir. Null/undefined de referências normalizam para nil; leitura de posição ausente produz nil.
