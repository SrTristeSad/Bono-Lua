# Serialização de frames de deformação

Fonte: ObjectDataParser.ts::_parseSlotDeformFrame/_parseDeformFrame em DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e. Métodos genéricos/tween, Geometry/WeightData, Matrix e buffers são dependências reais já portadas.

| Aspecto | SlotDeform | Deform genérico |
| --- | --- | --- |
| Geometria | _mesh.geometry | _geometry |
| Valores raw | VERTICES, senão null | VERTICES, senão VALUE, senão null |
| Sem pesos | Copia deltas ou zero fora do intervalo | Mesmo algoritmo |
| Com pesos | Pose do slot, inversa da pose de cada bone, delta=true | TODO literal upstream: não adiciona floats |
| Header | Apenas frameStart===0 | Mesmo header, inclusive contagem zero no TODO |

Offsets públicos base 0; armazenamento Lua base 1 com length lógico. Captura frameFloatOffset antes de parsear tween; reserva floatArray depois das leituras de geometria/offset/poses, mantendo holes. Componentes ausentes fora do intervalo viram zero; dentro, undefined/hole/null são copiados até a etapa tipada. VERTICES null preenche zero, VERTICES undefined pode lançar ao consultar length. Offset pode impedir essa consulta pelo curto-circuito original. Não trocar presença por truthiness, nem aplicar VALUE ao caminho de slot.

Slot ponderado lê pose por mesh.parent.name + '_' + slot.name + '_' + mesh.name, copia Matrix A antes da reserva, usa weight.count*2 e cabeçalhos indiretos de intArray. Cada vértice é transformado pela pose do slot em modo delta, depois pela inversa da pose do bone, também delta. Translação de pose não entra no delta. Não multiplicar por coeficiente de peso: o original não faz isso neste serializer. Loops e quantidades seguem os dados originais; escritas podem crescer além da reserva ou deixar holes quando contagens inconsistentes. Poses incompletas/ausentes preservam NaN/erros e estado anterior, sem substituir por identidade.

O genérico ponderado mantém o TODO original: tween/leituras e header continuam ocorrendo, mas nenhum cálculo de floats é inventado. Portanto, portar o corpo não significa implementar comportamento que falta no próprio upstream.

Header no primeiro frame reserva cinco ints e escreve, nesta ordem: geometry.offset, quantidade final de floats, mesma quantidade como valueCount, valueOffset zero, floatStart−animation.frameFloatOffset. Só depois atualiza timelineArray[timeline.offset+TimelineFrameValueCount] com intStart−animation.frameIntOffset. Erros em animation/timeline preservam reservas e campos anteriores. Demais frames não escrevem novo header. Os modelos AnimationData/TimelineData usados no teste são reais, sem _parseTimeline fictício.

Prova: tests/deformframes_differential.{js,lua}, 117 cenários/5.773 operações/127.006 colunas por VM Lua 5.4/LuaJIT, zero tolerância e 26 exceções esperadas. Contadores genuínos: 143 slot/131 genérico. Inclui pesos/poses vindos de _parseMesh real, transformações gerais/singulares/incompletas, componentes/offsets/esparsidade, prefixos e offsets relativos, contagens inconsistentes, falhas em cada contexto/reserva, pool e bytes finais. Somente NaN Float32 tem sinal/payload normalizado em snapshot separado, conforme o contrato anterior; demais valores/bytes exatos.

Estado atual: 41/47 métodos, seis ausentes (_parseTimeline/_parseBoneTimeline/_parseSlotTimeline/_parseAnimation/_parseArmature/parseDragonBonesData). Não implementa aplicação de deformações no runtime, importação JSON/DBDT completa, playback ou renderização. Controles/contexto seguem os tipos/offsets TS e valores raw JSON-like; reflexão/coerções genéricas e limites de plataforma anteriores permanecem.
