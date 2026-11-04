# _parseAnimation

Fonte integral: ObjectDataParser.ts::_parseAnimation, DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e. O método cria AnimationData real, interpreta os formatos legado/genérico e retorna o objeto; não o registra automaticamente na armadura nem executa playback.

Metadados seguem ordem original: blendType/frameCount/playTimes/duration/fadeInTime/scale/name, fallback de nome vazio para default. Duration usa frameCount/armature.frameRate, inclusive zero/infinitos. Depois captura comprimentos int/float/frame, define _animation e inicia os ramos. Erros anteriores mantêm o contexto antigo e o AnimationData parcialmente preenchido.

Ordem: ações em frame (length capturado), zOrder, bones, slots, FFD, IK, actionTimeline/limpeza de actionFrames e só então timelines genéricas. Os demais for-of usam emit ES5 com length vivo. Cada ramo usa os modelos/serializers/timelines reais já portados, sem fabricar dados de dependências ausentes. FFD procura skin/slot/display, retém contexto parcial em continue inválido e limpa slot/mesh após sucesso.

| Grupo genérico | Codec/modo | Escala/default |
| --- | --- | --- |
| SlotDisplay | Single/Step, TODO original | 1/0 |
| SlotZIndex | Single/Int | 1/0 |
| BoneAlpha, SlotAlpha | Single/Int | 100/1 |
| AnimationProgress | Single/Int | 10000/0 |
| AnimationWeight | Single/Int | 10000/1 |
| BoneTranslate | Double/Float | 1/0 |
| BoneRotate | Double/Float x/y | DEG_RAD/0 |
| BoneScale | Double/Float | 1/1 |
| IKConstraint | Double/Int x/y | 100/1 |
| AnimationParameter | Double/Int | 10000/0 |
| Surface, SlotDeform | Deform/Float | Geometria encontrada |
| SlotColor | SlotColorFrame/Int | Registro/offset de cor |
| Action, ZOrder, tipos sem ramo | TODO/sem saída | Não inventar timeline |

Não unificar formatos: rotação legada usa rotate/skew/voltas; genérica usa x/y escalados. IK legado usa bendPositive/weight; genérico usa x/y. SlotDisplay genérico usa single-value Step sem parse de ações, conforme TODO original. Os registros finais vão para bone/slot/constraint/animationTimelines conforme a lista original, inclusive nomes sem validação adicional onde o upstream não procura o modelo.

AnimationProgress com blend diferente de None aloca AnimationTimelineData antes de ler x/y e parsear frames. Se x/y falha, fica objeto parcial; se frames vazio retorna nil, fica órfão. Não devolver ou normalizar esse objeto inventando limpeza extra.

Busca SlotDeform percorre skins/displays por ordem de propriedades JS via JSMap.keys, com placeholders SkinData.NULL. Só interrompe o loop da lista de displays; continua slots/skins e preserva o último match. Display undefined presente pode lançar; geometria ausente continua undefined. Surface usa a geometria do bone encontrado sem validação extra de classe. Não trocar essas regras por first match, default ou cast mais permissivo.

_animation só é solta no sucesso. Erros mantêm maps, arrays/holes, caches/contextos/órfãos e ações já consumidas. Ações permanecem após falha em ramo legado, mas já estão limpas se a falha acontece nas genéricas. Novas chamadas continuam dos buffers e caches atuais, sem reset global adicional.

Prova: tests/animationparser_differential.{js,lua}, 172 cenários/15.997 operações/447.916 colunas por VM Lua 5.4/LuaJIT, zero tolerância, 28 exceções esperadas, 194 chamadas genuínas. Todos os tipos, blends/frames vazios/um/vários, metadados, fases de ações, busca em skins e órfãos; AnimationData/AnimationTimelineData/timelines/SurfaceData/pesos/poses/constraints/maps/pool/bytes reais. NaN Float32 normalizado somente no snapshot conforme contrato anterior. Transcript usa limite 128 MiB/30s por volume, sem tolerância nova.

Estado 45/47; _parseArmature e parseDragonBonesData ausentes. Não importa arquivo global/JSON texto/DBDT completos e não implementa motor/blending/playback/renderização. TODOs upstream, domínio JSON-like/tipos TS, locales/reflexão/coerções/plataforma anteriores continuam explícitos.

Unidade posterior: _parseArmature está em [ArmatureParser.md](ArmatureParser.md), registrando esses AnimationData na ordem original. Estado atual 46/47; parseDragonBonesData permanece ausente. Os totais históricos acima não incluem essa unidade.
