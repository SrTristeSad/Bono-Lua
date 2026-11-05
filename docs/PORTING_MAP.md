# Correspondência de arquivos

## LÖVE — meshes, skinning e deformação

Portados os ramos mesh de PixiSlot para o backend LÖVE: buffers Float32/Uint16, UVs/triângulos, deformação comum, skinning ponderado e pai Surface. `love .` inicia meshes; M alterna com sprites. Ver [LoveMeshes.md](contracts/LoveMeshes.md).

Diferencial: 82 cenários/21.368 colunas exatas por VM Lua 5.4/LuaJIT, com runtime/factory reais. CI: 56 suítes por VM, 22 exemplos de terminal e job gráfico com as oito cenas anteriores de sprites mais oito cenas de meshes contra Pixi WebGL real. Mesh pixels exigem igualdade exata; resultado no artefato/mesh-result.json, sem inferir sucesso antes da execução.

Este é o estado atual; abaixo estão etapas anteriores. Atlas rotacionados e blends avançados continuam pendentes. Backend e integrações oficiais não são declarados completos; a prova numérica usa probes e a prova gráfica usa hosts reais.

## LÖVE — primeiro backend de sprites

Acrescentado backend gráfico separado do runtime: sprites com atlas não rotacionado, transformações/pivot/trim, tint/alpha, ordem, visibilidade e Normal/Add. `love .` abre a demonstração gráfica. Meshes, atlas rotacionados e blends avançados ainda são recusados. Ver [LoveSprites.md](contracts/LoveSprites.md).

Diferencial numérico: 56 cenários/11.188 colunas exatas por VM Lua 5.4/LuaJIT, usando PixiSlot/PixiTextureAtlasData originais. CI: 55 suítes por VM, 22 exemplos de terminal e job gráfico separado que compara oito capturas reais LÖVE com Pixi CanvasRenderer no Chromium. Evidência de pixels depende da execução desse job e de seu result.json, sem inferir sucesso por inspeção.

Este bloco é o estado atual; os seguintes registram etapas anteriores. O recorte não declara renderer completo nem equivalência integral das integrações oficiais. A etapa 09 do comando mestre já prevê o adaptador LÖVE; os demais motores não foram substituídos por ele.

## BaseFactory — montagem automática

Portada a base de fábrica e BuildArmaturePackage: importação/cache/busca, montagem de bones/slots/constraints/filhos, atlas e substituições de display/skin/animação. Usa o runtime real; os três hooks de backend continuam abstratos. Ver [BaseFactory.md](contracts/BaseFactory.md).

Diferencial: 252 cenários/85.217 colunas por VM Lua 5.4/LuaJIT, duas escritas readonly esperadas e zero aproximações. Oito mutações rejeitadas; regressão armatureruntime nas duas VMs. `lua5.4 examples/run.lua factory` importa skeleton/atlas, monta automaticamente 5 bones/3 slots/1 IK e reproduz pelo relógio. CI: 54 suítes e 22 exemplos por VM.

Este bloco é o estado atual; os seguintes registram etapas anteriores. examples/ObserverFactory.lua demonstra os hooks sem desenhar. Integração gráfica permanece pendente; nenhum motor gráfico foi escolhido nesta etapa. A cobertura e os limites de busca/recursão estão no contrato.

## Armature — avanço integrado ao relógio

Portados os corpos restantes de Armature: init/advanceTime, ordenação, consultas de colisão/display e troca de textura. O fluxo usa Animation, Bones, Surface, Slots, IK e core/clock reais, incluindo ações, alpha, cache, proxy e descarte. Ver [ArmatureRuntime.md](contracts/ArmatureRuntime.md).

Diferencial: 456 cenários/466.072 colunas por VM Lua 5.4/LuaJIT, quatro exceções esperadas e zero aproximações. Oito mutações rejeitadas; regressão animationfacade nas duas VMs. `lua5.4 examples/run.lua armature` avança pelo relógio, reproduz 0→20→40→20 e despacha eventos. CI: 53 suítes e vinte e um exemplos por VM.

Este bloco é o estado atual; os seguintes registram etapas anteriores. Próxima etapa: factories e backends. Montagem de Bones/Slots/displays ainda explícita e backend observador sem desenho. Ordenação com scores empatados foi comparada para três slots; comportamento do comparador não estrito em arrays maiores permanece fora da garantia.

## Animation — API pública de reprodução

Portados os corpos restantes de Animation: playConfig/play/fadeIn, seis goto, stop/reset, busca de estados, status e seleção dos modelos. O controlador agora cria e ordena estados reais, aplica fades e liga filhos automaticamente. Ver [AnimationFacade.md](contracts/AnimationFacade.md).

Diferencial: 839 cenários/2.325.490 colunas por VM Lua 5.4/LuaJIT, seis erros readonly esperados e zero aproximações. Oito mutações rejeitadas; regressão stateadvance nas duas VMs. `lua5.4 examples/run.lua animation` demonstra iniciar, pausar/retomar, parar no frame 12, transição e reset. playback também usa play, sem registrar estados manualmente. CI: 52 suítes e vinte exemplos por VM.

Este bloco é o estado atual; os seguintes registram etapas anteriores. Próxima etapa: orquestração de Armature, depois factories e backends. Montagem da armadura ainda explícita e backend observador sem desenho.

## Reprodução por delta e construção automática de timelines

`AnimationState` agora tem os três corpos restantes: `_updateTimelines`, `_updateBoneAndSlotTimelines` e `advanceTime`. `Animation.lua` fornece lifecycle, `getBlendState` e `advanceTime` reais: mistura por camada, cache e descarte adiado. O facade `playConfig`/`play`/`fadeIn`, orquestração de `Armature` e factories/backend gráfico continuam pendentes. Ver [StateAdvance.md](contracts/StateAdvance.md).

Diferencial `stateadvance`: 200 cenários e 392.400 colunas por VM Lua 5.4/LuaJIT, zero aproximações. Integra bones, Surface, slots, IK, eventos/core e estados filhos reais; backend observador. CI passa a 51 suítes e dezenove exemplos por VM. `lua5.4 examples/run.lua playback` avança deltas reais e imprime pose/mundo 0→20→40→20, com troca de display. Montagem e registro ainda explícitos; sem desenho na tela.

Os blocos abaixo registram etapas anteriores; este é o estado atual. Próximo recorte: facade público de Animation, depois Armature e factories/backends.

## AnimationState — init, fade e controles públicos

Portados init, transições de fade, play/stop, máscaras, addState, activeTimeline e getters de status. AnimationConfig, timelines e eventos reais; permanecem os três métodos de construção/avanço de timelines e Animation. Ver [StateInitialization.md](contracts/StateInitialization.md).

Diferencial: 338 cenários/1.065.864 colunas por VM Lua 5.4/LuaJIT, uma escrita readonly e 1.014 leituras pós-limpeza que falham como no pin; zero aproximações. Regressão animationcontrol também passou nas duas VMs. `lua5.4 examples/run.lua stateinit` inicializa estados, liga filho, aplica máscara e demonstra fade com eventos. Avanço do fade explícito; player/renderer ainda pendentes. CI passa a 50 suítes e dezoito exemplos por VM.


## Controle de estado filho e AnimationState parcial

Portadas as três timelines finais: progresso, peso e parâmetros. Elas usam AnimationState real, com construtor/limpeza e APIs reais de tempo/peso/dados; init/advanceTime/fade/construção de timelines continuam ausentes. Corpos das 16 classes de TimelineState.ts portados, integração do player pendente. Ver [AnimationControl.md](contracts/AnimationControl.md).

Diferencial: 747 cenários/549.045 colunas por VM Lua 5.4/LuaJIT, 24 erros readonly esperados e 1.494 leituras pós-limpeza que falham como no original, zero aproximações. `lua5.4 examples/run.lua animationcontrol` importa JSON e controla tempo/peso/parâmetros de um estado filho real. CI agora contém 49 suítes e dezessete exemplos por VM. Próximo trabalho: completar AnimationState e Animation, depois Armature/factories/backends.


## Timeline de ações e eventos

Portada ActionTimelineState com eventos e filas reais do core; Armature.eventDispatcher retorna o proxy somente leitura. Diferencial: 585 cenários/242.190 colunas/20 erros esperados por VM Lua 5.4/LuaJIT, zero aproximações. Corrigida preservação de -0 em currentPlayTimes; regressão basetimeline também passou nas duas VMs. Ver [ActionTimeline.md](contracts/ActionTimeline.md).

`lua5.4 examples/run.lua actiontimeline` importa JSON, despacha eventos de frame/som/ciclo e mostra ações Play pendentes. Backend é um observador explícito; execução das ações depende do player ainda pendente. TimelineState.ts tem 13/16 classes portadas. CI passa a 48 suítes e dezesseis exemplos por VM. Restam três timelines de controle de animação, o controlador e a integração completa de Armature/factories/renderização.


## Timelines de IK e ordem dos slots

Portadas IKConstraintTimelineState e ZOrderTimelineState, com Armature._sortZOrder real. Diferencial: 596 cenários/215.156 colunas/164 erros esperados por VM Lua 5.4/LuaJIT, zero aproximações. Contrato em [ConstraintOrderTimelines.md](contracts/ConstraintOrderTimelines.md). TimelineState.ts agora tem 12/16 classes portadas.

`lua5.4 examples/run.lua constraintorder` importa JSON, muda peso/dobra de IK e ranks dos slots, e executa Bone.update/solver reais. Montagem e tempos manuais; AnimationState/Animation/player e renderer continuam pendentes. CI agora contém 47 suítes e quinze exemplos por VM. Restam ActionTimelineState e três timelines de controle de animação antes da integração completa do controlador.


## Timelines de deformação — Surface e malhas

Portadas SurfaceTimelineState e DeformTimelineState, com buffers/Surface/Slot/DisplayFrame/BlendState reais. Diferencial: 1.554 cenários, 1.048.950 colunas e 26 erros esperados por VM Lua 5.4/LuaJIT, sem aproximações numéricas. Ver [DeformationTimelines.md](contracts/DeformationTimelines.md). TimelineState.ts agora tem 10/16 classes portadas.

`lua5.4 examples/run.lua deformationtimeline` importa JSON, interpola a Surface em 0/40/80/40 e a malha em 0/10/20/10. Montagem e tempos manuais; AnimationState/Animation/player e renderer continuam pendentes. CI passa a 46 suítes e catorze exemplos por VM. Próximo recorte: timelines de constraints, ações/eventos e parâmetros de animação, seguidas da integração do controlador.


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


A tabela integral está em UPSTREAM_INVENTORY.md e é regenerável; o estado por módulo vem de PORTING_PROGRESS.json. Dependências resolvidas e fronteiras externas: DEPENDENCIES.md.

| Origem | Destino proposto | Situação |
| --- | --- | --- |
| DragonBones/src/dragonBones/geom/Point.ts | dragonbones/geom/Point.lua | Implementado, validado isoladamente nos testes diferenciais |
| DragonBones/src/dragonBones/geom/Rectangle.ts | dragonbones/geom/Rectangle.lua | Implementado, validado isoladamente nos testes diferenciais |
| DragonBones/src/dragonBones/geom/ColorTransform.ts | dragonbones/geom/ColorTransform.lua | Implementado, validado isoladamente nos testes diferenciais |
| DragonBones/src/dragonBones/geom/Matrix.ts | dragonbones/geom/Matrix.lua | Implementado, validado isoladamente nos testes diferenciais |
| DragonBones/src/dragonBones/geom/Transform.ts | dragonbones/geom/Transform.lua | Implementado, validado isoladamente nos testes diferenciais |
| DragonBones/src/dragonBones/core/BaseObject.ts | dragonbones/core/BaseObject.lua | Implementado, comparado isoladamente com o original executado |
| DragonBones/src/dragonBones/model/CanvasData.ts | dragonbones/model/CanvasData.lua | Modelo e integração com pool comparados |
| DragonBones/src/dragonBones/model/TextureAtlasData.ts (duas classes) | dragonbones/model/TextureAtlasData.lua | Dados de atlas/textura e integração com pool comparados; backend gráfico pendente |
| DragonBones/src/dragonBones/animation/WorldClock.ts | dragonbones/animation/WorldClock.lua | Algoritmo comparado; precisão do relógio automático do host pendente |
| DragonBones/src/dragonBones/animation/IAnimatable.ts | docs/contracts/IAnimatable.md | Contrato de tipos documentado e exercitado; sem classe fictícia |
| DragonBones/src/dragonBones/core/DragonBones.ts | dragonbones/core/DragonBones.lua e core/Enums.lua | Núcleo de filas e 98 valores de enums comparados; shims JS documentados |
| DragonBones/src/dragonBones/event/EventObject.ts | dragonbones/event/EventObject.lua | Objeto de evento e conversão de ações comparados com pool real |
| DragonBones/src/dragonBones/model/UserData.ts (duas classes) | dragonbones/model/UserData.lua | UserData/ActionData e reciclagem de payload comparados |
| DragonBones/src/dragonBones/event/IEventDispatcher.ts | docs/contracts/IEventDispatcher.md | Contrato documentado; listeners/backend real pendentes |
| DragonBones/src/dragonBones/model/AnimationConfig.ts | dragonbones/model/AnimationConfig.lua | Defaults, cópia, máscaras esparsas/aliases e pool comparados; consumo por Animation/AnimationState pendente |
| DragonBones/src/dragonBones/model/AnimationData.ts (três classes) | dragonbones/model/AnimationData.lua | Dados/cache/timelines comparados; integração com ArmatureData/BoneData/SurfaceData/SlotData reais aprovada nos cenários, playback pendente |
| DragonBones/src/dragonBones/model/DisplayData.ts (oito classes) | dragonbones/model/DisplayData.lua | Dados/geometria/pesos e ciclo de vida comparados; referências externas por contrato, sem backend gráfico |
| DragonBones/src/dragonBones/model/ArmatureData.ts (quatro classes) | dragonbones/model/ArmatureData.lua | Ordenação/ciclo de vida/cache comparados com AnimationData e constraints reais; skin integrada; armazenamento global DragonBonesData real integrado |
| DragonBones/src/dragonBones/model/ConstraintData.ts (três classes) | dragonbones/model/ConstraintData.lua | Base abstrata/IK/Path data, pool e integração com armadura comparados; solver de runtime pendente |
| DragonBones/src/dragonBones/model/SkinData.ts | dragonbones/model/SkinData.lua | Mapa/listas nullable, ownership e integração com ArmatureData/displays reais comparados; runtime/renderização pendentes |
| DragonBones/src/dragonBones/model/DragonBonesData.ts | dragonbones/model/DragonBonesData.lua | Coleções/ownership e cache real comparados; buffers por referência, parser/typed views pendentes |
| DragonBones/src/dragonBones/model/BoundingBoxData.ts (quatro classes) | dragonbones/model/BoundingBoxData.lua | Contains/interseções locais, outputs/aliases e ownership comparados; Slot/runtime hit testing pendente |
| DragonBones/src/dragonBones/parser/DataParser.ts | dragonbones/parser/DataParser.lua | Constantes/conversões e aplicação em modelos reais comparadas; base abstrata, importação e locales especiais pendentes |
| DragonBones/src/dragonBones/parser/ObjectDataParser.ts (47 corpos; domínio declarado) | dragonbones/parser/ObjectDataParser.lua | 47/47 corpos portados e comparados nos recortes documentados, incluindo entrada de objetos decodificados/atlas/buffers reais. TODOs/limites JS preservados; não é runtime nem BinaryDataParser |
| Demais DragonBones/src/dragonBones/**/*.ts | dragonbones/**/*.lua | Inventariado; implementação/validação pendente |
| <engine>/<version>/src/dragonBones/**/*.ts | integrations/<mesmo caminho>.lua | Ausente; contratos de plataforma pendentes |
| Interfaces TS | Contratos Lua documentados/testados junto às classes | Sem algoritmos próprios; nenhuma simulação |
| Demos, recursos e arquivos gerados | Classificados individualmente no inventário | Não contados como runtime |
| builds/*.js | Ferramentas de distribuição do upstream | Catalogadas; necessidade de correspondência Lua a auditar |

Os caminhos reservados de integrações não afirmam que APIs JavaScript existem em Lua. A separação por engine/versão evita colidir classes com nomes idênticos.

JSNumberString.lua é adaptação de representação numérica da linguagem para os dois toString originais; não é uma classe adicional de runtime upstream.

JSArray.lua e JSMap.lua em dragonbones/core/ são adaptações de representação da linguagem, extraídas de AnimationConfig/TextureAtlasData e reutilizadas em AnimationData; não contam como classes upstream adicionais. A fronteira de leitura de parent está em docs/contracts/AnimationDataParent.md, sem classe de produto substituta.

DisplayDataReferences.md registra as leituras e a propriedade das referências externas de DisplayData.ts. Não é uma nova interface upstream nem uma implementação dos modelos ainda ausentes.

SharedBinaryBuffer.lua é adaptador da plataforma ArrayBuffer/Int16Array/Uint16Array/Float32Array usada pelo parser, não uma classe upstream adicional. Ver contracts/SharedBinaryBuffer.md.

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

Slot.ts contém duas classes: DisplayFrame corresponde a dragonbones/armature/DisplayFrame.lua (comparado); Slot parcialmente implementada em dragonbones/armature/Slot.lua (fundação/transformação/hit testing); seleção de dados/pivôs também comparada; atualização do objeto gráfico/backend ainda pendentes.

Slot: todos os corpos e aliases representados, update/troca/cache/child no domínio de SlotRuntime.md; hooks gráficos abstratos, Animation/backend e Armature completo pendentes. Armature também inclui clock/cache/dispose/fila de ações necessários ao recorte.

Constraint.ts: base Constraint em dragonbones/armature/Constraint.lua e IKConstraint em dragonbones/armature/IKConstraint.lua, comparados no domínio IKConstraint.md. PathConstraint do mesmo TS ainda pendente. Armature._addConstraint registra o solver real.
