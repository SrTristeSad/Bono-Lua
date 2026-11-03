# Armazenamento DragonBonesData

Fonte: model/DragonBonesData.ts de DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e. A classe real é dragonbones/model/DragonBonesData.lua.

| Campo | Representação Lua | Propriedade/limpeza |
| --- | --- | --- |
| frameIndices, cachedFrames | JSArray numérico base 1, length lógico | Mesma identidade; length=0 no clear, extras preservados |
| armatureNames | JSArray de strings base 1 | push após parent e mapa; mesma identidade no clear |
| armatures | JSMap de nomes para ArmatureData | returnToPool em ordem própria JS; chave removida só após sucesso |
| stage | Referência ArmatureData ou nil | Não devolve; remove referência |
| userData | UserData ou nil | Devolve após armaduras, antes dos resets |
| binary e sete views | Referências ao armazenamento fornecido pelo parser/host | Não copia/decodifica/devolve; atribui nil no clear |

`ArmatureData:setCacheFrame` retorna offset público base 0; o armazenamento numérico usa índices Lua base 1. `getCacheFrame` lê o mesmo objeto compartilhado. Arrays esparsos devem usar `.length`; `#array` e ipairs não equivalem ao algoritmo JS em presença de holes.

No construtor, somente arrays/mapa e userData têm inicializadores upstream. Borrow/clear estabelece os demais defaults. Não antecipar name, frameRate, autoSearch, stage ou buffers em new. O clear de armaduras pode falhar, mantendo arrays/campos ainda não resetados; nomes não são sincronizados por mutação direta do mapa, como no original.

O teste de integração usa buffers JS genuínos e referências Lua já decodificadas para comparar identidade/retirada e leituras de GeometryData.intArray. Isso não implementa ArrayBuffer, coerção numérica tipada, views compartilhadas, endianness/alinhamento ou parser JSON/DBDT. Esses contratos precisam de implementação e prova próprias antes de importar dados binários reais.
