# Animação binária

Fonte: BinaryDataParser.ts::_parseAnimation, DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e. Método TS e backup Lua auditados; oracle executa TS fixado, não o backup.

Usa ArmatureData, DragonBonesData, modelos/pool e views reais. Recebe objeto decodificado com offset em JSValue.array. Listas raw exigem JSValue.array; grupos bone/slot/constraint usam JSMap.new para preservar chaves numéricas primeiro e strings em inserção. Tabelas Lua comuns não fornecem essa ordem. Grupos null/undefined são ignorados como for-in upstream. Não há emulação geral de protótipos/descritores/setters ou for-in de primitivas.

Metadados seguem helpers de ObjectDataParser. Os três offsets vêm do cabeçalho, não dos arrays de trabalho. Entrada curta preserva UNDEFINED nos campos; nos cálculos de timeline isso vira NaN. Offset ausente de par ímpar segue o mesmo caminho. Não se afirma coerção de offsets string por concatenação JS.

Ações e ZOrder legados precedem bone, slot, constraint e lista genérica. Grupos ignoram modelo inexistente antes de acessar sua lista. Cada par é registrado imediatamente, preservando registros anteriores se um grupo posterior falhar. Timeline genérica com offset negativo é ignorada. AnimationProgress em blend não None recebe AnimationTimelineData e x/y; demais tipos usam TimelineData. Action/ZOrder e tipos genéricos desconhecidos ficam sem registro, mantendo órfãos originais; BoneAll genérico também não é registrado. Não preencher TODOs.

Só sucesso limpa _animation. Falhas anteriores à publicação deixam animação órfã e contexto anterior; falhas posteriores retêm animação, mapas e possível _timeline. Não há rollback adicional. Retorno ao pool limpa timelines registradas, não órfãos sem ownership.

243 cenários, 468 chamadas reais a _parseBinaryTimeline, 3.159 colunas por VM e 32 exceções esperadas. Binary64 exato, inclusive duração/Infinity e zeros; só NaN observado como NaN. Todos os tipos, três modos de blend/contagens, mapas numéricos/inserção, modelos inexistentes, par ímpar, offset curto/ausente/null, contexto ausente, listas null/holes, coerções, estados parciais, repetição, limpeza e bytes compartilhados. Espião de timeline chama o método real; não substitui serializers/modelos por stubs. Mutantes de frameOffset e condição de subclass de blend rejeitados. Regressão BinaryTimeline preservada.

5/8 métodos binários. Restam _parseGeometry, _parseArray e parseDragonBonesData com DBDT/JSON; não implica playback/runtime/factories/backends.
