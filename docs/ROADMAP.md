# Etapas obrigatórias

## Timelines de slots — display, cor, alpha e profundidade

Portadas Alpha/SlotDisplay/SlotColor/SlotZIndexTimelineState, com Slot/Bone e BlendState reais. Diferencial: 992 cenários, 639.840 colunas por VM Lua 5.4/LuaJIT, sem erros nem aproximações numéricas. Contrato em [SlotTimelines.md](contracts/SlotTimelines.md). TimelineState.ts agora tem 8/16 classes portadas.

`lua5.4 examples/run.lua slottimeline` importa JSON e altera display/cor/alpha/z do slot. Montagem e tempo manuais; AnimationState/Animation, ordenação/propagação completas de Armature e renderer continuam pendentes. CI agora executa 45 suítes e treze exemplos por VM. Próximo recorte: Surface/deformação, constraints/eventos e timelines de animação dependentes do controlador.


## Timelines de bones — aplicação à pose

Portados BlendState e BoneAll/BoneTranslate/BoneRotate/BoneScaleTimelineState, com aplicação à animationPose do Bone real e mistura de pesos/camadas. Diferencial: 1.828 cenários por VM; ver [BoneTimelines.md](contracts/BoneTimelines.md). TimelineState.ts e AnimationState.ts continuam parciais.

`lua5.4 examples/run.lua bonetimeline` aplica keyframes importados à pose e à matriz mundial do bone, imprimindo 0/20/40/20. Montagem/tempo manuais, ainda sem AnimationState/Animation/player ou renderer. CI passa a 44 suítes e doze exemplos por VM. Próximo recorte: timelines de slots, Surface, constraints/eventos e integração do controlador.


## Bases de timeline — tempo e interpolação

Portadas as cinco classes de BaseTimelineState.ts em módulo próprio: avanço temporal, seleção de keyframes, easing e interpolação de um/dois/vários valores. Diferencial com o pin: 2.700 cenários, 1.052.450 colunas e 25 erros esperados por VM, sem aproximações. Contrato e limites em [BaseTimelineState.md](contracts/BaseTimelineState.md).

`lua5.4 examples/run.lua timeline` (ou luajit) importa keyframes JSON e imprime 0/20/40/20 em quatro tempos. Os dados/parser/buffers são reais; AnimationState é explicitamente um contrato de campos nos testes/exemplo, ainda sem player ou renderer. CI agora executa 43 suítes e onze exemplos por VM. Próximo recorte: timelines concretas/BlendState, depois AnimationState/Animation.


## PathConstraint — curva e seguidores

Portado o corpo de PathConstraint para módulo próprio, completando as três classes de Constraint.ts no domínio documentado. Parser/modelos/Bone/Slot/Armature reais; preservados loops, buffers incompletos e TODOs originais. Teste diferencial: 2.851 cenários, 8.553 etapas, 193.868 colunas e 33 erros esperados por VM Lua 5.4/LuaJIT. Precisão e limites em [PathConstraint.md](contracts/PathConstraint.md). CI passa a executar 42 suítes e dez exemplos por VM.

Teste sem dependências JS: `lua5.4 examples/run.lua path` ou `luajit examples/run.lua path`. Dois ossos seguem a curva em 25%, 50% e 75%. Montagem manual, sem player ou renderer; Animation, Armature completa, factories e backends permanecem pendentes. Esta atualização substitui as indicações históricas de Path pendente abaixo.


| Etapa | Objetivo | Estado |
| --- | --- | --- |
| 00 | Backup remoto e reconstrução isolada | Concluída |
| 01 | Inventário integral, contratos e dependências | Arquivos, contratos declarados e dependências estáticas catalogados; fronteiras externas registradas |
| 02 | Matemática: Matrix, Transform, Point, Rectangle, ColorTransform | Cinco classes implementadas e comparadas isoladamente; integração e auditoria exaustiva pendentes |
| 03 | Core, modelos e ciclo de vida | Em andamento: BaseObject, núcleo DragonBones/enums, UserData/ActionData, AnimationConfig, AnimationData/TimelineData/AnimationTimelineData, ArmatureData/BoneData/SurfaceData/SlotData e dados de Canvas/atlas/textura/display/geometria/pesos comparados; cache AnimationData integrado com modelos reais; ConstraintData/IKConstraintData/PathConstraintData comparados com integração real; SkinData e cadeia de limpeza/getMesh comparados com modelos reais; DragonBonesData e armazenamento global/cache integrados com modelos reais; BoundingBoxData retângulo/elipse/polígono e ownership com displays reais comparados; buffers tipados e parsers pendentes |
| 04 | Parsers JSON/DBDT | Base DataParser e 47/47 corpos de ObjectDataParser portados/comparados no domínio documentado, incluindo entrada de objetos decodificados; BinaryDataParser 8/8 corpos com entrada DBDT/JSON interno comparados no domínio documentado; 74 exportações únicas do corpus upstream comparadas; I/O, locales especiais e exportações externas pendentes |
| 05 | Armature, Bone, Slot, Surface, TransformObject | TransformObject, Bone e Surface comparados nos domínios documentados; Armature parcial de registro/ciclo de vida; DisplayFrame e fundação/transformação/hit testing de Slot comparados; seleção de dados/pivôs de Slot comparada; pipeline update/troca de objetos de Slot comparado com hooks abstratos; Armature.init/advanceTime e integração de animação pendentes |
| 06 | IKConstraint e PathConstraint | Base Constraint e IK de um/dois ossos portados/comparados com runtime/modelos reais; PathConstraint pendente |
| 07 | Animação, timelines, blending e eventos | WorldClock, núcleo/EventObject, configuração AnimationConfig e dados de timelines comparados; Armature, animação, listeners/backend e precisão de host pendentes |
| 08 | BaseFactory e runtime | Pendente |
| 09 | Adaptador gráfico Lua/LÖVE e comparação real | Pendente |
| 10 | Auditoria de todas as integrações oficiais | Pendente |
| 11 | Exportações reais e testes externos | Corpus esquelético upstream: 74 blobs/181 caminhos comparados em duas escalas; exportações externas e integrações com engines pendentes |
| 12 | Auditoria final de equivalência | Pendente |

O proprietário autorizou posteriormente a main a acompanhar checkpoints do porte em andamento. Integrar somente unidades com testes/CI pertinentes aprovados e status explícito de incompletude; CI estrutural verde não comprova equivalência do motor.

## Helpers binários e bytes — checkpoint atual

BinaryDataParser tem 3/8 métodos portados: `_inRange`, `_decodeUTF8` e `getInstance`. SharedBinaryBuffer agora oferece `uint8`, com aliases, metadados e coerções comparados ao Uint8Array nativo. A comparação executa o decoder original fixado: 67.083 operações e 134.166 colunas, incluindo todos os 65.536 pares de bytes, com tolerância zero. Ver [contrato](contracts/BinaryUTF8.md).

Isso ainda não carrega DBDT: faltam `_parseBinaryTimeline`, overrides `_parseAnimation`/`_parseGeometry`/`_parseArray` e a entrada binária `parseDragonBonesData`, além da dependência JSON do cabeçalho. A entrada de objetos herdada não interpreta bytes. ObjectDataParser permanece em 47/47 corpos, nos domínios documentados. Runtime, factories e backends continuam pendentes.

## Timelines binárias — checkpoint seguinte

`BinaryDataParser._parseBinaryTimeline` portado: agora 4/8 métodos. Usa views Int16/Uint16 e modelos/pool reais; acrescenta índices ao segmento existente, preserva o frame final extra e o estado parcial em erros. Comparação contra o método TS executado: 439 cenários, 448 chamadas, 6.585 colunas por VM, 12 falhas esperadas, tolerância zero. Contrato: [BinaryTimeline.md](contracts/BinaryTimeline.md).

Faltam os overrides binários `_parseAnimation`, `_parseGeometry`, `_parseArray` e a entrada `parseDragonBonesData`/cabeçalho JSON. A entrada herdada continua sendo de objetos, sem suporte DBDT. CI passa a executar 28 suítes por VM.

## Animação binária — checkpoint seguinte

`BinaryDataParser._parseAnimation` portado, total 5/8 métodos. Compara metadados/offsets, grupos ordenados, todos os tipos genéricos, subclasses de blend, pool e falhas parciais com modelos reais. São 243 cenários, 468 chamadas reais de timeline, 3.159 colunas por VM, 32 exceções esperadas e tolerância zero. Ver [BinaryAnimation.md](contracts/BinaryAnimation.md). CI ampliada para 29 suítes por VM.

Mapas de grupos decodificados exigem JSMap.new; listas raw usam JSValue.array. Não afirma reflexão/protótipos/for-in de primitivas genéricos. Preserva Action/ZOrder genéricos sem registro e órfãos upstream; não avalia animação no runtime. Restam _parseGeometry, _parseArray e parseDragonBonesData binários/JSON interno.

## Geometria binária — checkpoint seguinte

`BinaryDataParser._parseGeometry` portado, total 6/8 métodos. Preserva correção de offset abaixo de -1, ausência de peso sem limpeza, contagem de influências e referências aos bones, inclusive undefined. Peso novo só é publicado ao final; falhas preservam peso anterior e alocações parciais upstream.

Comparação com TS fixado executado: 238 cenários/4.284 colunas por VM, três exceções esperadas, tolerância zero, modelos/pool/views reais. Ver [BinaryGeometry.md](contracts/BinaryGeometry.md). CI com 30 suítes por VM. Restam _parseArray e entrada parseDragonBonesData binários/JSON interno; DBDT ainda não está disponível.

## Arrays binários — checkpoint seguinte

`BinaryDataParser._parseArray` portado, total 7/8 métodos. Cria as views sobre o mesmo Buffer, preserva o alias colorArray=intArray quando cores estão ausentes e publica campos na ordem original, incluindo referências privadas antes dos setters correspondentes. Conversão ToIndex específica trunca comprimentos fracionários e normaliza -0 para +0; Shared.view mantém contrato estrito em bytes.

189 cenários/3.402 colunas por VM, 69 exceções esperadas, tolerância zero contra typed arrays nativos do TS fixado. Ver [BinaryViews.md](contracts/BinaryViews.md). CI com 31 suítes por VM. Falta parseDragonBonesData binário/cabeçalho DBDT/JSON; não declarar carregamento DBDT pronto.

## Entrada DBDT — checkpoint seguinte

`BinaryDataParser.parseDragonBonesData` portado: agora 8/8 corpos, com comparação nos domínios documentados. Lê tag, tamanho Uint32 little endian e cabeçalho com o decoder original, adapta JSON e chama ObjectDataParser real. Recebe SharedBinaryBuffer, preservando sua identidade nas views. JSON inválido não publica novos campos binários; erros posteriores preservam o estado original.

223 cenários (184 JSON/39 DBDT), 797 colunas por VM, 45 exceções esperadas e tolerância zero. Grafo real com armadura/mesh/pesos/animação, buffers, pool, limpeza e mutação; cabeçalhos de até 65.536 bytes e JSON aninhado em 64 níveis. Ver [DBDTEntry.md](contracts/DBDTEntry.md). CI com 32 suítes por VM. Isso não declara equivalência JS irrestrita nem motor completo: corpus de exportações reais, I/O, runtime/factories/backends e limites anteriores continuam pendentes.

## Corpus esquelético upstream — validação integrada

Todos os blobs do commit fixado com extensão dbbin, ou JSON válido com propriedade armature, foram catalogados: 181 caminhos, 74 conteúdos únicos (71 JSON/3 DBDT). Cada conteúdo foi importado nas escalas 1 e 0,5: 148 importações/1.924 colunas por VM, sem erro e sem tolerância numérica. Manifesto registra SHA Git, SHA-256, tamanho e todos os caminhos.

Compara grafo selecionado, poses/cores/metadados, buffers byte a byte e classes/ordem de objetos emprestados, inclusive estado após limpeza. JSON e ArrayBuffer do oracle são criados no mesmo contexto VM do TS para evitar diferença artificial de instanceof. Ver [UpstreamCorpus.md](contracts/UpstreamCorpus.md). CI com 33 suítes por VM; nenhuma alteração no motor foi necessária neste checkpoint. Não cobre renderização/playback, exportações externas ao commit ou todo campo dinâmico.

## Primeira base do runtime — TransformObject

TransformObject portado com inicializadores, dois métodos e getter armature. Usa BaseObject/Matrix/Transform/Point reais; Armature aparece somente como tipo/referência, sem dependência executável ou stub. Mantém identidade dos vetores, dirty limpo antes de decompor e estado parcial em falhas. 212 cenários/8.056 colunas por VM, 35 exceções esperadas; 27 diferenças trigonométricas dentro da tolerância anterior de Transform, demais campos exatos. Ver [TransformObject.md](contracts/TransformObject.md).

Exemplos executáveis em Lua 5.4/LuaJIT: examples/run.lua inspect importa JSON/DBDT e lista modelos; examples/run.lua transform demonstra atualização adiada da matriz. Sem Node/npm para executar esses exemplos. Ainda não há player/renderização; classe concreta da demonstração não é Bone/Slot de produto. CI com 34 suítes por VM e execução dos dois exemplos.

## Bone regular e registro da armadura

Bone portado com uma Armature parcial real de ciclo de vida/registro. Hierarquia, modos de offset, flips/yDown, quatro flags de herança, alpha, dirty flags, cache de ArmatureData/DragonBonesData reais e getters/setters comparados contra TS executado. 1.576 cenários/44.128 colunas por VM, seis falhas esperadas e 340 aproximações trig limitadas; índices/flags/zeros/offsets exatos. Ver [BoneRuntime.md](contracts/BoneRuntime.md).

Comando executável examples/run.lua bones carrega dois modelos, monta dois Bone reais, gira o pai e move o filho de (40,20) para (10,50). Montagem manual com _armatureData, sem init/factory/player fictício. Surface, solvers, Slot runtime e Armature.init/advanceTime continuam pendentes. CI com 35 suítes e três exemplos por VM.

## Surface e integração com Bone

Surface portado com oito corpos e geometria/pool/armadura parcial reais. 585 cenários, 38.610 consultas e 26.325 colunas por VM; duas falhas esperadas. Inclui regiões central/laterais/bordas, cache hit/restauração/invalidação, deformação e cadeias de pais Bone/Surface. Não muda a tolerância da suíte Bone: a integração Surface usa orçamento próprio para trigonometria e projeção de coordenadas, registrado em [SurfaceRuntime.md](contracts/SurfaceRuntime.md).

Exemplo `examples/run.lua surface`: o filho em (50,50) vai a (50,90) ao deformar o centro da grade em +80 no eixo Y. Montagem e deformação manuais, sem player/factory falso. CI com 36 suítes e quatro exemplos por VM. Slot, constraints/solvers, Armature.init/advanceTime, animação e backend continuam pendentes.
