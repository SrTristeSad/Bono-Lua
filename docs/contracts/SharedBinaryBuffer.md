# Buffer e views de _modifyArray

Fonte: ObjectDataParser.ts::_modifyArray, DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e. SharedBinaryBuffer.lua adapta a plataforma, não adiciona classe ao motor original.

| Campo DragonBonesData | View Lua | Unidade |
| --- | --- | --- |
| intArray | int16 | 2 bytes |
| floatArray | float32 | 4 bytes |
| frameIntArray | int16 | 2 bytes |
| frameFloatArray | float32 | 4 bytes |
| frameArray | int16 | 2 bytes |
| timelineArray | uint16 | 2 bytes |
| colorArray | int16 | 2 bytes |

Todas as views têm `.buffer == data.binary`, `.length`, `.byteOffset`, `.byteLength`, `.BYTES_PER_ELEMENT` somente leitura. Índices Lua base 1; offsets públicos em bytes base 0. Use `.length` em loops portáveis: o proxy LuaJIT é userdata; não supor ipairs/pairs/reflexão de table. Extras nomeados podem ser anexados. Índices numéricos fracionários/fora dos limites retornam nil e ignoram escrita depois de converter o valor. Strings com índices numéricos não têm emulação completa de propriedades JS.

`Shared.new(bytes)` cria um Buffer mutável. `buffer.byteLength`, `buffer:byte(offset)`, `:setByte(offset,value)`, `:readBytes(offset,count)`, `:writeBytes(offset,bytes)` e `:bytes()` são a ponte explícita. bytes() retorna string snapshot imutável, cacheada até nova escrita. Um snapshot anterior não muda; um alias de view continua lendo/escrevendo o mesmo Buffer. `Shared.view(buffer,byteOffset,byteLength,kind)` recebe comprimento em **bytes**, múltiplo exato e dentro dos limites; não é emulação irrestrita dos overloads/conversões do construtor TypedArray JS.

Uma chamada de _modifyArray alinha int/frameInt/frame/timeline com zero, calcula os sete segmentos, cria um único Buffer e todas as views antes de copiar valores. O original verifica timeline novamente antes de color; color ímpar permanece ímpar. Cada cópia usa comprimento capturado, depois publica binary/int/float/frameInt/frameFloat/frame/timeline/color nessa ordem; só ao final redefine _defaultColorOffset=-1. Conversão inválida deixa as referências publicadas anteriores; falha em setter pode deixar campos anteriores atualizados. Não há rollback extra.

Coerção usa JSValue para números/strings/bools/null/undefined/arrays JSON-like. Int16/Uint16 truncam e aplicam módulo; NaN/infinitos/holes viram zero. Float32 arredonda ties-even com subnormais, overflow e zero assinado; holes/undefined viram NaN, null vira zero. Vários casos de intervalo e arredondamento são comparados byte a byte contra typed arrays nativas. NaN de entrada numérica é canonicalizado; não há garantia de payload arbitrário após carregar/regravar um NaN. Memória é little endian, com oráculo que rejeita host big endian.

Chamadas repetidas criam novo buffer/views; referências antigas continuam válidas. _parseArray limpa apenas arrays de trabalho, não o Buffer já publicado. DragonBonesData.returnToPool solta referências sem destruir aliases retidos pelo host.

Prova: tests/binaryarrays_differential.{js,lua}, parser e modelos reais, 163 cenários/6.272 operações/70.166 colunas por VM, 32 erros esperados, zero tolerância. Inclui 128 combinações de paridade, sobreposição, snapshots, setters com falha, pool e geometrias com/sem pesos. Não importa JSON texto/DBDT ou anima armaduras; limites JS genéricos e runtime permanecem em DIFFERENCES.md/NEXT_STEPS.md.

O adaptador também suporta `uint8` (um byte) para os helpers parciais de BinaryDataParser; não altera os sete segmentos acima. Ver BinaryUTF8.md.
