# Views de arrays binários

Fonte: BinaryDataParser.ts::_parseArray, DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e. TS e backup Lua lidos; o backup não substitui o oracle nativo.

Usa _binary como SharedBinaryBuffer já existente, _binaryOffset numérico e raw.offset em JSValue.array. Os pares do cabeçalho são offset/comprimento em bytes; o original divide comprimento por BYTES_PER_ELEMENT antes do construtor. ToIndex trunca para zero, transforma NaN/undefined em zero, rejeita infinitos/índices negativos fora da truncagem e normaliza -0 em +0. Alinhamento é verificado após conversão do offset; comprimento pode deixar bytes finais sem view quando não é múltiplo da unidade. Shared.view continua exigindo comprimento em bytes estritamente alinhado: a adaptação fica apenas neste método.

Sete segmentos: int16, float32, int16, float32, int16, uint16, int16. Segmento color só é criado quando offset.length>12 e seu comprimento é positivo; caso contrário é a mesma view intArray, não outra view igual. Todos compartilham a mesma identidade do Buffer, inclusive sobreposição e mutações entre int16/uint16/float32. Não copiar Buffer nem converter data.binary em snapshot string.

Constrói todas as views antes de publicar. Publicação: data.binary; self._intArrayBuffer antes de data.intArray; floatArray; frameIntArray; frameFloatArray; self._frameArrayBuffer antes de data.frameArray; self._timelineArrayBuffer antes de data.timelineArray; colorArray. Erro de construção mantém todos os campos anteriores; erro de setter preserva somente atribuições já realizadas, inclusive a privada do mesmo encadeamento. Não há rollback.

Domínio testado: Shared Buffer finito, offsets numéricos/null/undefined, listas JSValue.array e coerções numéricas dos comprimentos. Não declara concatenação JS de offsets string nem overloads de construtores com fontes não ArrayBuffer. Limites genéricos de reflexão/protótipos continuam. Índices Lua base 1; metadados públicos em bytes base 0; little endian conforme adaptador anterior.

189 cenários/3.402 colunas por VM Lua 5.4/LuaJIT, 69 exceções esperadas, tolerância zero. Oracle executa _parseArray TS com TypedArray nativos, DragonBonesData real e oito setters de falha observados. Comprimentos fracionários/negativos/NaN/Infinity, offset/base/alinhamento/limites, cabeçalho curto, cores ausentes, views sobrepostas, identidade, metadados, valores e bytes exatos. NaN de leitura Float32 é observado como NaN; demais valores, inclusive zero, são comparados em binary64 exato. Mutantes de alias de cores, ordem de publicação e truncagem negativa rejeitados. LuaJIT exigiu normalização de -0 no ToIndex; não relaxar o teste para ocultá-lo.

7/8 métodos binários. Falta entrada parseDragonBonesData, Uint32 do header e JSON interno; não há carregamento DBDT público nesta etapa. Runtime/factories/backends pendentes.
