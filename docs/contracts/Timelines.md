# Parsers de timelines

Fonte: ObjectDataParser.ts::_parseTimeline/_parseBoneTimeline/_parseSlotTimeline, DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e. Dependências reais: AnimationData/TimelineData, ActionFrame, DragonBonesData.frameIndices e serializers de frames já portados.

| Caso | Comportamento original |
| --- | --- |
| Frames null/vazios | Retorna nil antes de alterar timeline/contexto |
| Timeline fornecida | Reutiliza o objeto, sem clone/pool extra |
| Um keyframe | Callback start/count=0; frameIndicesOffset=-1 |
| Vários keyframes | Reserva frameCount+1 índices; no máximo um callback por posição |
| Int/Float | Offsets relativos a animation.frameIntOffset/frameFloatOffset |
| Posição do frame | Retorno do callback menos animation.frameOffset |
| ActionFrame não final | Duração lê próximo frame do cache _actionFrames |
| Erro | Mantém reservas/índices/contexto/objetos anteriores; sem rollback |

Índices Lua base 1; offsets/índices públicos base 0. RawFrames é array JSON-like marcado por JSValue ou _actionFrames interno, conforme tipos TS; nil/V.NULL significa null, V.UNDEFINED não. Não emula length arbitrário de objetos JS/proxies ou ToPrimitive geral. frameParser Lua recebe self explicitamente, traduzindo .call(this,...). No produto são funções originais dos serializers, sem substitutos.

O parser reserva cinco campos e keyFrameCount posições, mantendo holes. Define TimelineData.type/offset e self._frameValueType/_timeline antes da reserva. Scale e offset são arredondados ×100; offsets de valores usam comprimentos capturados antes dos callbacks. No caso de vários frames, captura frameIndices.length, reserva animation.frameCount+1 posições e escreve índices progressivamente. Durações zero/negativas/fracionárias seguem comparação/loops originais; frames ainda não alcançados ficam com posições de offset não preenchidas. No sucesso _timeline vira nil; falhas não fazem essa limpeza.

ActionFrame é classe comum, não BaseObject. Reconhecimento pela classe/cadeia Lua conserva o ramo instanceof. O próximo tempo vem de self._actionFrames mesmo se rawFrames for outro array; não corrigir essa peculiaridade para consultar o argumento. A ausência do próximo frame pode lançar depois das reservas, antes do callback.

BoneTimeline busca bone real, depois slot com o mesmo nome, processa translate/rotate/scale/all nessa ordem e define defaults/escala nos ramos originais. Registra cada timeline concluída imediatamente em AnimationData.boneTimelines; falha posterior mantém as anteriores e o contexto bone/slot. Bone ausente retorna sem mudar contexto. Limpa bone/slot somente no sucesso.

SlotTimeline busca slot real, escolhe displayFrame e colorFrame por presença, com fallback frame. Parseia ambas antes de registrar qualquer uma; falha na segunda deixa a primeira órfã sem novo registro em slotTimelines. No sucesso registra display e depois cor e limpa slot. Propriedade presente null/vazia suprime fallback, como no original.

Validação: tests/timelines_differential.{js,lua}, 132 cenários/7.909 operações/213.543 colunas por VM Lua 5.4/LuaJIT, zero tolerância e 20 exceções esperadas. Contadores genuínos: 200 genéricas/8 bone/8 slot. Callbacks reais de frame/single/double/bones/slot/color/IK/ZOrder/deform/ações; wrappers só observam argumentos e injetam falha após o corpo real. Modelos/maps/índices/pool/bytes reais, timeline fornecida e reuso, durações/escala/offsets, cache de ações, registros parciais e overflow. NaN Float32 só normalizado no snapshot, conforme contrato anterior.

Estado atual: 44/47 métodos; _parseAnimation/_parseArmature/parseDragonBonesData ausentes. Contexto de animação é semeado em teste, não importado por entrypoint fictício. Isso não avalia timelines em runtime, anima/deforma/blenda/renderiza nem importa JSON/DBDT completos. TODO ponderado do deform genérico e limites de plataforma/coerção anteriores continuam explícitos.
