# Geometria, bones, displays e skins (parser parcial)

Fonte: ObjectDataParser.ts de DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e. Novos corpos Lua completos:

| Método | Responsabilidade |
| --- | --- |
| _parseGeometry | Reserva/copia vértices/triângulos/UVs e interpreta pesos com/sem poses e matrizes reais |
| _parseArray | Esvazia os sete arrays de trabalho, mantendo identidade/extras |
| _parseBone | BoneData ou SurfaceData, atributos/transform/geometria |
| _parsePath/_parseMesh | Geometria e caches de pose para meshes com weights |
| _parseDisplay | Cinco tipos, transform/pivot/actions, share deferido e comprimentos de path |
| _parseSkin | Slots/displays conhecidos, placeholders null, transferência de ações e contexto |

Estado atual do arquivo: 45/47 métodos; os outros 2 continuam ausentes. Curvas e frames genéricos constam em [CurveFrames.md](CurveFrames.md). _modifyArray foi acrescentado na unidade seguinte, conforme [SharedBinaryBuffer.md](SharedBinaryBuffer.md). _parseArmature, animações e parseDragonBonesData não têm stubs. Testes semeiam contexto global/armadura/bones/slots com classes reais, sem importar uma armadura completa artificialmente.

Arrays de trabalho usam .length e índices Lua base 1; offsets armazenados/retornados continuam base 0. Reservas deixam holes e não devem ser preenchidas com zero antes da coerção tipada original. Pesos mantêm floor(length−vertexCount)/2, reserva anterior à contagem de bones e loop weightCount no ramo sem poses. Não reparar silenciosamente entrada malformada ou cabeçalhos deixados undefined pela fonte; RangeError e efeitos parciais são comparados.

Poses numéricas usam Matrix real. Ausência de componentes permanece undefined após copy e propaga NaN nas operações, inclusive matriz desconhecida/singular/incompleta. Não há fallback de identidade novo nem emulação irrestrita de coerções JS para coeficientes não numéricos. Null/undefined como objetos de pose continuam erros, com alocações e reservas anteriores preservadas.

SHARE por presença guarda raw/mesh em caches; resolver compartilhamento é responsabilidade do _parseArmature ainda ausente. Cache de pose guarda refs originais. Skin usa falsy JS para nulls e transfere ações herdadas somente no índice correto; erro conserva contexto até o ponto em que a fonte o conserva. Mesh/Surface/Path possuem GeometryData e WeightData reais; devolução não cria contagem de referências.

Este lote não produz Int16Array/Float32Array, ArrayBuffer ou arquivo binário. Teste pode ligar arrays de trabalho ao DragonBonesData real para observar getters em armazenamento já decodificado. _modifyArray/alinhamento/coerção/views compartilhados precisam de implementação própria antes de declarar importação binária.

Validação: 53 cenários/2.498 operações/34.972 colunas por VM, tolerância zero; regressão matemática anterior aprovada. Artefatos e limites em VALIDATION.md.
