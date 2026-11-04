# Entrada DBDT e JSON interno

Fonte: BinaryDataParser.ts::parseDragonBonesData, DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e. Entrada TS e JSON do backup auditados. O backup usa null próprio, whitespace amplo e rejeita surrogates isolados/overflow numérico; não foi usado como oracle nem copiado como equivalência.

```lua
local Parser = require('dragonbones.parser.BinaryDataParser')
local Shared = require('dragonbones.parser.SharedBinaryBuffer')
local buffer = Shared.new(bytes) -- bytes é a string binária já obtida pelo chamador
local data = Parser.new():parseDragonBonesData(buffer, 1)
```

Aceita Buffer do adaptador, não texto JSON, string binária direta ou overloads TypedArray sobre fontes arbitrárias. Shared.isBuffer distingue essa representação. Entrada fora desse domínio produz diagnóstico e erro explícito; não se afirma equivalência dos overloads JS após console.assert. I/O/arquivo/rede não é adicionado ao motor.

Cria view uint8 dos oito primeiros bytes (exige oito), compara apenas DBDT nos quatro primeiros. Tag errada diagnostica e retorna nil. Lê Uint32 LE em offset 8 com quatro bytes; é leitura específica do cabeçalho, sem API Uint32 geral. Header começa em 12, com comprimento validado pela view antes de decodificar. Decoder custom upstream conserva NUL omitido/bytes inválidos; não trocar por biblioteca UTF-8 padrão.

JSON.parse é uma adaptação de plataforma em parser/JSON.lua: objects JSMap, arrays JSValue.array, null JSValue.NULL, booleanos e números binary64. Whitespace só espaço/tab/LF/CR; gramática numérica estrita, -0 preservado e overflow para Infinity como JS. Strings aceitam escapes e surrogates isolados como WTF-8; pares válidos normalizam em escalar UTF-8, permitindo igualdade entre nome literal e escapado. Duplicatas mantêm posição e último valor; chaves numéricas seguem ordem JS. Não usa load/execução de conteúdo JSON. Sem reviver, protótipos/descriptors genéricos ou mensagens de erro idênticas ao host. Entrada direta JSON testada em UTF-8 válido/escapes, locale numérico padrão; não declara bytes UTF-8 arbitrários, locale numérico alternativo ou profundidade ilimitada.

Só após JSON bem-sucedido publica _binaryOffset=12+headerLength e _binary=rawData; chama ObjectDataParser.parseDragonBonesData real, com overrides binários. Erro antes disso mantém campos antigos. Versão incompatível já deixa campos binários novos, mas retorna nil. Falhas posteriores podem reter _data/_animation e alocações parciais. Não acrescentar rollback. Buffer e views conservam identidade; no ramo sem armature o dado global não recebe arrays, conforme base original.

223 cenários: 184 JSON e 39 DBDT; 797 colunas por VM Lua 5.4/LuaJIT; 45 exceções esperadas, tolerância zero. JSON inclui grammar/whitespace, duplicatas/ordem, null/false, binary64/-0/overflow/underflow, NUL escapado, pares e surrogates isolados, 128 objetos determinísticos e 64 níveis. DBDT inclui mesh/WeightData/BoneData/AnimationData/timelines reais, escala/blend/cores opcionais, pool/cleanup/alias mutation, versões, falhas de dados e headers, truncamento 0..12, tamanho 0xffffffff e cabeçalhos 256/65536 bytes. Byte NUL/0xff dentro do header confirma uso do decoder custom. Oracle executa TS fixado e JSON.parse/TypedArrays nativos, sem parser/modelos fictícios. Mutantes de tamanho Uint32, publicação anterior ao JSON e perda de -0 rejeitados.

Todos os 8 corpos de BinaryDataParser presentes; isso não demonstra equivalência irrestrita do parser ou motor. Faltam corpus de exportações reais e seus limites, runtime/solvers/playback/blending/factories/backends, I/O e demais divergências já registradas.
