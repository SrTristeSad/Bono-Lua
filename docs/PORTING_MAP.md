# Correspondência de arquivos

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
