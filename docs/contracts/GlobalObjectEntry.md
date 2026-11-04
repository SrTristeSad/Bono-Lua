# Entrada global de objetos DragonBones

Fonte: ObjectDataParser.ts::parseDragonBonesData em DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e. Todos os 47 corpos de métodos desse arquivo estão portados e têm testes nos recortes documentados. Isso não declara equivalência JavaScript irrestrita ou conclusão do motor.

Entrada Lua: `ObjectDataParser.new():parseDragonBonesData(raw, scale)`, com objeto já decodificado, arrays marcados por JSValue.array, raw null/undefined explícitos e scale numérico TS opcional. Omitido/undefined usa 1. Não lê texto ou arquivo JSON/DBDT. O retorno é DragonBonesData real ou nil para versão não suportada; entradas inválidas podem lançar depois do diagnóstico original.

| Situação | Efeito |
| --- | --- |
| Version ou compatibleVersion suportada | Continua; data.version mantém a versão primária |
| Versão incompatível | Diagnóstico e nil; sem alocação/alteração de contexto |
| ARMATURE ausente | Só metadados; binary/views nil, contexto _data anterior preservado |
| ARMATURE lista vazia | Limpa arrays, cria Buffer/views vazios e stage nil |
| ARMATURE com dados | Grafo real por _parseArmature, ownership via addArmature |
| Binary já truthy | Preserva buffer/views; não chama _modifyArray |
| Stage presente | Busca esse nome; ausência no mapa não usa primeiro como fallback |
| Stage ausente | Primeiro nome registrado, se houver |
| TextureAtlas presente | Atribui fila ao final; não redefine índice |

Console.assert do original diagnostica sem interromper. O porte escreve a mensagem observada no host Node e permite que leituras de valor inválido lancem na posição original. Não usar assert Lua bloqueante nesse ponto. FrameRate zero vira 24; os demais valores seguem helpers e modelos já auditados.

Somente o ramo ARMATURE define _data, chama _parseArray e, após registrar armaduras, testa self._data.binary por truthiness. _parseArray limpa somente os sete arrays de trabalho; outros caches/contextos não recebem reset extra. _modifyArray é a implementação real já comparada, não serialização substituta. Só após finalização/stage bem-sucedidos _data vira nil.

Exceções conservam Data/Armature/frames/ownership e contextos parciais. Chamada posterior sem ARMATURE não apaga _data de erro. Duplicatas seguem addArmature real, incluindo warning/órfão e primeiro nome/stage. Versão inválida ou falha anterior não substitui fila de atlas. Null da fila vira nil interno, undefined é distinto e pode falhar ao consultar length. Fila nova não redefine índice consumido; esse comportamento é original, não correção pendente do porte.

Prova: tests/globalentry_differential.{js,lua}, 90 cenários/4.285 operações/149.975 colunas por VM Lua 5.4/LuaJIT, zero tolerância e 23 exceções esperadas. 115 chamadas genuínas de entrada, 31 atlas, 63 finalizações. 18 arquivos emitidos; parser começa sem Data/Armature pré-semeados e usa modelos/constraints/skins/poses/weights/animações/timelines/bytes/pool reais. Factory concreta de TextureAtlasData/TextureData é apenas teste da base abstrata, não backend gráfico.

Inclui versões/compatibilidade/defaults, argumentos omitidos/undefined, -0, nenhum/zero/vários armatures, nomes/stages/duplicatas, erros/retry, fila de atlas com consumo/substituição/falhas, returnToPool/reuso e buffer real pré-carregado por override de teste de _parseArray. Esse probe não implementa BinaryDataParser. Snapshots comparam metadados/identidades de Buffer e sete views e bytes; só células Float32 NaN têm sinal/payload normalizado conforme contrato anterior.

Próximo recorte: BinaryDataParser e seus adaptadores de bytes/UTF-8/JSON interno. TODOs upstream, domínios JSON-like/TS, coerções/reflexão/protótipos genéricos, locales especiais, Big Endian/payloads NaN arbitrários e loops patológicos anteriores continuam limitados. Runtime Armature/playback/blending/solvers/factories/backends/renderização e leitura de arquivos não estão concluídos.
