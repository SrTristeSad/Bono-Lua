# Etapas obrigatórias

| Etapa | Objetivo | Estado |
| --- | --- | --- |
| 00 | Backup remoto e reconstrução isolada | Concluída |
| 01 | Inventário integral, contratos e dependências | Arquivos, contratos declarados e dependências estáticas catalogados; fronteiras externas registradas |
| 02 | Matemática: Matrix, Transform, Point, Rectangle, ColorTransform | Cinco classes implementadas e comparadas isoladamente; integração e auditoria exaustiva pendentes |
| 03 | Core, modelos e ciclo de vida | Em andamento: BaseObject, núcleo DragonBones/enums, UserData/ActionData, AnimationConfig, AnimationData/TimelineData/AnimationTimelineData, ArmatureData/BoneData/SurfaceData/SlotData e dados de Canvas/atlas/textura/display/geometria/pesos comparados; cache AnimationData integrado com modelos reais; ConstraintData/IKConstraintData/PathConstraintData comparados com integração real; SkinData e cadeia de limpeza/getMesh comparados com modelos reais; DragonBonesData e armazenamento global/cache integrados com modelos reais; BoundingBoxData retângulo/elipse/polígono e ownership com displays reais comparados; buffers tipados e parsers pendentes |
| 04 | Parsers JSON/DBDT | Base DataParser e 47/47 corpos de ObjectDataParser portados/comparados no domínio documentado, incluindo entrada de objetos decodificados; BinaryDataParser parcial 4/8 (helpers UTF-8 e timeline binária comparados); overrides/entrada DBDT/JSON interno, leitura de arquivos e locales especiais pendentes |
| 05 | Armature, Bone, Slot, Surface, TransformObject | Pendente |
| 06 | IKConstraint e PathConstraint | Pendente |
| 07 | Animação, timelines, blending e eventos | WorldClock, núcleo/EventObject, configuração AnimationConfig e dados de timelines comparados; Armature, animação, listeners/backend e precisão de host pendentes |
| 08 | BaseFactory e runtime | Pendente |
| 09 | Adaptador gráfico Lua/LÖVE e comparação real | Pendente |
| 10 | Auditoria de todas as integrações oficiais | Pendente |
| 11 | Exportações reais e testes externos | Pendente |
| 12 | Auditoria final de equivalência | Pendente |

O proprietário autorizou posteriormente a main a acompanhar checkpoints do porte em andamento. Integrar somente unidades com testes/CI pertinentes aprovados e status explícito de incompletude; CI estrutural verde não comprova equivalência do motor.

## Helpers binários e bytes — checkpoint atual

BinaryDataParser tem 3/8 métodos portados: `_inRange`, `_decodeUTF8` e `getInstance`. SharedBinaryBuffer agora oferece `uint8`, com aliases, metadados e coerções comparados ao Uint8Array nativo. A comparação executa o decoder original fixado: 67.083 operações e 134.166 colunas, incluindo todos os 65.536 pares de bytes, com tolerância zero. Ver [contrato](contracts/BinaryUTF8.md).

Isso ainda não carrega DBDT: faltam `_parseBinaryTimeline`, overrides `_parseAnimation`/`_parseGeometry`/`_parseArray` e a entrada binária `parseDragonBonesData`, além da dependência JSON do cabeçalho. A entrada de objetos herdada não interpreta bytes. ObjectDataParser permanece em 47/47 corpos, nos domínios documentados. Runtime, factories e backends continuam pendentes.

## Timelines binárias — checkpoint seguinte

`BinaryDataParser._parseBinaryTimeline` portado: agora 4/8 métodos. Usa views Int16/Uint16 e modelos/pool reais; acrescenta índices ao segmento existente, preserva o frame final extra e o estado parcial em erros. Comparação contra o método TS executado: 439 cenários, 448 chamadas, 6.585 colunas por VM, 12 falhas esperadas, tolerância zero. Contrato: [BinaryTimeline.md](contracts/BinaryTimeline.md).

Faltam os overrides binários `_parseAnimation`, `_parseGeometry`, `_parseArray` e a entrada `parseDragonBonesData`/cabeçalho JSON. A entrada herdada continua sendo de objetos, sem suporte DBDT. CI passa a executar 28 suítes por VM.
