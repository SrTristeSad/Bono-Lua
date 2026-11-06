# Bono-Lua — porte integral do DragonBonesJS para Lua

## LÖVE — Multiply sobre Canvas

Multiply foi acrescentado aos sprites com composição explícita sobre uma cópia do Canvas de destino. O shader conserva os fatores originais DST_COLOR/ONE_MINUS_SRC_ALPHA e o empacotamento separado de RGB/alpha do Pixi. Exige Canvas rgba8, sem MSAA e DPI 1; a demonstração configura isso ao pressionar N. Ver [LoveMultiply.md](docs/contracts/LoveMultiply.md).

Diferencial: 33 cenários/6.588 colunas exatas por VM Lua 5.4/LuaJIT, inclusive Multiply→Screen→Normal→Multiply. A CI acrescenta 18 capturas reais e exige 1.474.560 canais idênticos em multiply-result.json; mantém as 44 cenas anteriores e sobe para 60 suítes e 22 exemplos por VM. Resultados gráficos precisam de execução aprovada, não são inferidos da configuração.

Este é o estado atual; seções seguintes são checkpoints anteriores. Multiply faz uma cópia integral do destino por sprite e ainda não cobre janela direta, MRT, MSAA, outros formatos/DPI, texels semitransparentes ou fundos transparentes. Outros blends e exports externos continuam pendentes.

## LÖVE — blend Screen

Sprites aceitam Screen com RGB premultiplicado e alpha empacotado como no batcher Pixi 4. O shader pertence ao display, é criado sob demanda e liberado ao destruir o display; o estado gráfico do chamador é restaurado. B alterna Screen no demo, T alterna o atlas e M alterna sprites/meshes. O blend de mesh permanece como no PixiSlot original. Ver [LoveScreen.md](docs/contracts/LoveScreen.md).

Diferencial: 33 cenários/6.588 colunas exatas em Lua 5.4/LuaJIT, incluindo troca Screen→Add→Normal→Screen. CI configurada com 59 suítes por VM e 22 exemplos; acrescenta 18 capturas reais com 1.474.560 canais exigidos exatos em blend-result.json. Mantém as 26 capturas anteriores e seus critérios. A execução gráfica é a evidência; configuração não implica aprovação.

Este é o estado atual; seções seguintes registram checkpoints anteriores. Multiply e os demais blends avançados, transparência de texels/filtragem complexa e exports externos continuam pendentes. Backend e integrações oficiais não são declarados completos.

## LÖVE — atlas rotacionados

Sprites e meshes aceitam regiões de atlas giradas em 90°, preservando as dimensões originais usadas pelo Pixi e os pivôs do runtime. Sprites usam um Mesh com UVs rotacionados; meshes conservam a fórmula original de PixiSlot. `love .` abre a demonstração; T alterna o atlas e M alterna sprites/meshes. Ver [LoveRotation.md](docs/contracts/LoveRotation.md).

Diferenciais de rotação: sprites 56 cenários/11.857 colunas e meshes 82/22.352, exatos em Lua 5.4/LuaJIT. CI configurada com 58 suítes por VM, 22 exemplos e dez cenas gráficas adicionais contra Pixi WebGL real: 819.200 canais com igualdade exigida, sem tolerância nova. Evidência executada em rotation-result.json no artefato gráfico; a configuração do teste não substitui seu resultado. As 16 cenas gráficas anteriores permanecem.

Este é o estado atual; seções seguintes registram checkpoints anteriores. Blends avançados e validação de exports externos continuam pendentes. Backend e integrações oficiais não são declarados completos.

## LÖVE — meshes, skinning e deformação

Portados os ramos mesh de PixiSlot para o backend LÖVE: buffers Float32/Uint16, UVs/triângulos, deformação comum, skinning ponderado e pai Surface. `love .` inicia meshes; M alterna com sprites. Ver [LoveMeshes.md](docs/contracts/LoveMeshes.md).

Diferencial: 82 cenários/21.368 colunas exatas por VM Lua 5.4/LuaJIT, com runtime/factory reais. CI: 56 suítes por VM, 22 exemplos de terminal e job gráfico com as oito cenas anteriores de sprites mais oito cenas de meshes contra Pixi WebGL real. Mesh pixels exigem igualdade exata; resultado no artefato/mesh-result.json, sem inferir sucesso antes da execução.

Este é o estado atual; abaixo estão etapas anteriores. Atlas rotacionados e blends avançados continuam pendentes. Backend e integrações oficiais não são declarados completos; a prova numérica usa probes e a prova gráfica usa hosts reais.

## LÖVE — primeiro backend de sprites

Acrescentado backend gráfico separado do runtime: sprites com atlas não rotacionado, transformações/pivot/trim, tint/alpha, ordem, visibilidade e Normal/Add. `love .` abre a demonstração gráfica. Meshes, atlas rotacionados e blends avançados ainda são recusados. Ver [LoveSprites.md](docs/contracts/LoveSprites.md).

Diferencial numérico: 56 cenários/11.188 colunas exatas por VM Lua 5.4/LuaJIT, usando PixiSlot/PixiTextureAtlasData originais. CI: 55 suítes por VM, 22 exemplos de terminal e job gráfico separado que compara oito capturas reais LÖVE com Pixi CanvasRenderer no Chromium. Evidência de pixels depende da execução desse job e de seu result.json, sem inferir sucesso por inspeção.

Este bloco é o estado atual; os seguintes registram etapas anteriores. O recorte não declara renderer completo nem equivalência integral das integrações oficiais. A etapa 09 do comando mestre já prevê o adaptador LÖVE; os demais motores não foram substituídos por ele.

## BaseFactory — montagem automática

Portada a base de fábrica e BuildArmaturePackage: importação/cache/busca, montagem de bones/slots/constraints/filhos, atlas e substituições de display/skin/animação. Usa o runtime real; os três hooks de backend continuam abstratos. Ver [BaseFactory.md](docs/contracts/BaseFactory.md).

Diferencial: 252 cenários/85.217 colunas por VM Lua 5.4/LuaJIT, duas escritas readonly esperadas e zero aproximações. Oito mutações rejeitadas; regressão armatureruntime nas duas VMs. `lua5.4 examples/run.lua factory` importa skeleton/atlas, monta automaticamente 5 bones/3 slots/1 IK e reproduz pelo relógio. CI: 54 suítes e 22 exemplos por VM.

Este bloco é o estado atual; os seguintes registram etapas anteriores. examples/ObserverFactory.lua demonstra os hooks sem desenhar. Integração gráfica permanece pendente; nenhum motor gráfico foi escolhido nesta etapa. A cobertura e os limites de busca/recursão estão no contrato.

## Armature — avanço integrado ao relógio

Portados os corpos restantes de Armature: init/advanceTime, ordenação, consultas de colisão/display e troca de textura. O fluxo usa Animation, Bones, Surface, Slots, IK e core/clock reais, incluindo ações, alpha, cache, proxy e descarte. Ver [ArmatureRuntime.md](docs/contracts/ArmatureRuntime.md).

Diferencial: 456 cenários/466.072 colunas por VM Lua 5.4/LuaJIT, quatro exceções esperadas e zero aproximações. Oito mutações rejeitadas; regressão animationfacade nas duas VMs. `lua5.4 examples/run.lua armature` avança pelo relógio, reproduz 0→20→40→20 e despacha eventos. CI: 53 suítes e vinte e um exemplos por VM.

Este bloco é o estado atual; os seguintes registram etapas anteriores. Próxima etapa: factories e backends. Montagem de Bones/Slots/displays ainda explícita e backend observador sem desenho. Ordenação com scores empatados foi comparada para três slots; comportamento do comparador não estrito em arrays maiores permanece fora da garantia.

## Animation — API pública de reprodução

Portados os corpos restantes de Animation: playConfig/play/fadeIn, seis goto, stop/reset, busca de estados, status e seleção dos modelos. O controlador agora cria e ordena estados reais, aplica fades e liga filhos automaticamente. Ver [AnimationFacade.md](docs/contracts/AnimationFacade.md).

Diferencial: 839 cenários/2.325.490 colunas por VM Lua 5.4/LuaJIT, seis erros readonly esperados e zero aproximações. Oito mutações rejeitadas; regressão stateadvance nas duas VMs. `lua5.4 examples/run.lua animation` demonstra iniciar, pausar/retomar, parar no frame 12, transição e reset. playback também usa play, sem registrar estados manualmente. CI: 52 suítes e vinte exemplos por VM.

Este bloco é o estado atual; os seguintes registram etapas anteriores. Próxima etapa: orquestração de Armature, depois factories e backends. Montagem da armadura ainda explícita e backend observador sem desenho.

## Reprodução por delta e construção automática de timelines

`AnimationState` agora tem os três corpos restantes: `_updateTimelines`, `_updateBoneAndSlotTimelines` e `advanceTime`. `Animation.lua` fornece lifecycle, `getBlendState` e `advanceTime` reais: mistura por camada, cache e descarte adiado. O facade `playConfig`/`play`/`fadeIn`, orquestração de `Armature` e factories/backend gráfico continuam pendentes. Ver [StateAdvance.md](docs/contracts/StateAdvance.md).

Diferencial `stateadvance`: 200 cenários e 392.400 colunas por VM Lua 5.4/LuaJIT, zero aproximações. Integra bones, Surface, slots, IK, eventos/core e estados filhos reais; backend observador. CI passa a 51 suítes e dezenove exemplos por VM. `lua5.4 examples/run.lua playback` avança deltas reais e imprime pose/mundo 0→20→40→20, com troca de display. Montagem e registro ainda explícitos; sem desenho na tela.

Os blocos abaixo registram etapas anteriores; este é o estado atual. Próximo recorte: facade público de Animation, depois Armature e factories/backends.

## AnimationState — init, fade e controles públicos

Portados init, transições de fade, play/stop, máscaras, addState, activeTimeline e getters de status. AnimationConfig, timelines e eventos reais; permanecem os três métodos de construção/avanço de timelines e Animation. Ver [StateInitialization.md](docs/contracts/StateInitialization.md).

Diferencial: 338 cenários/1.065.864 colunas por VM Lua 5.4/LuaJIT, uma escrita readonly e 1.014 leituras pós-limpeza que falham como no pin; zero aproximações. Regressão animationcontrol também passou nas duas VMs. `lua5.4 examples/run.lua stateinit` inicializa estados, liga filho, aplica máscara e demonstra fade com eventos. Avanço do fade explícito; player/renderer ainda pendentes. CI passa a 50 suítes e dezoito exemplos por VM.


## Controle de estado filho e AnimationState parcial

Portadas as três timelines finais: progresso, peso e parâmetros. Elas usam AnimationState real, com construtor/limpeza e APIs reais de tempo/peso/dados; init/advanceTime/fade/construção de timelines continuam ausentes. Corpos das 16 classes de TimelineState.ts portados, integração do player pendente. Ver [AnimationControl.md](docs/contracts/AnimationControl.md).

Diferencial: 747 cenários/549.045 colunas por VM Lua 5.4/LuaJIT, 24 erros readonly esperados e 1.494 leituras pós-limpeza que falham como no original, zero aproximações. `lua5.4 examples/run.lua animationcontrol` importa JSON e controla tempo/peso/parâmetros de um estado filho real. CI agora contém 49 suítes e dezessete exemplos por VM. Próximo trabalho: completar AnimationState e Animation, depois Armature/factories/backends.


## Timeline de ações e eventos

Portada ActionTimelineState com eventos e filas reais do core; Armature.eventDispatcher retorna o proxy somente leitura. Diferencial: 585 cenários/242.190 colunas/20 erros esperados por VM Lua 5.4/LuaJIT, zero aproximações. Corrigida preservação de -0 em currentPlayTimes; regressão basetimeline também passou nas duas VMs. Ver [ActionTimeline.md](docs/contracts/ActionTimeline.md).

`lua5.4 examples/run.lua actiontimeline` importa JSON, despacha eventos de frame/som/ciclo e mostra ações Play pendentes. Backend é um observador explícito; execução das ações depende do player ainda pendente. TimelineState.ts tem 13/16 classes portadas. CI passa a 48 suítes e dezesseis exemplos por VM. Restam três timelines de controle de animação, o controlador e a integração completa de Armature/factories/renderização.


## Timelines de IK e ordem dos slots

Portadas IKConstraintTimelineState e ZOrderTimelineState, com Armature._sortZOrder real. Diferencial: 596 cenários/215.156 colunas/164 erros esperados por VM Lua 5.4/LuaJIT, zero aproximações. Contrato em [ConstraintOrderTimelines.md](docs/contracts/ConstraintOrderTimelines.md). TimelineState.ts agora tem 12/16 classes portadas.

`lua5.4 examples/run.lua constraintorder` importa JSON, muda peso/dobra de IK e ranks dos slots, e executa Bone.update/solver reais. Montagem e tempos manuais; AnimationState/Animation/player e renderer continuam pendentes. CI agora contém 47 suítes e quinze exemplos por VM. Restam ActionTimelineState e três timelines de controle de animação antes da integração completa do controlador.


## Timelines de deformação — Surface e malhas

Portadas SurfaceTimelineState e DeformTimelineState, com buffers/Surface/Slot/DisplayFrame/BlendState reais. Diferencial: 1.554 cenários, 1.048.950 colunas e 26 erros esperados por VM Lua 5.4/LuaJIT, sem aproximações numéricas. Ver [DeformationTimelines.md](docs/contracts/DeformationTimelines.md). TimelineState.ts agora tem 10/16 classes portadas.

`lua5.4 examples/run.lua deformationtimeline` importa JSON, interpola a Surface em 0/40/80/40 e a malha em 0/10/20/10. Montagem e tempos manuais; AnimationState/Animation/player e renderer continuam pendentes. CI passa a 46 suítes e catorze exemplos por VM. Próximo recorte: timelines de constraints, ações/eventos e parâmetros de animação, seguidas da integração do controlador.


## Timelines de slots — display, cor, alpha e profundidade

Portadas Alpha/SlotDisplay/SlotColor/SlotZIndexTimelineState, com Slot/Bone e BlendState reais. Diferencial: 992 cenários, 639.840 colunas por VM Lua 5.4/LuaJIT, sem erros nem aproximações numéricas. Contrato em [SlotTimelines.md](docs/contracts/SlotTimelines.md). TimelineState.ts agora tem 8/16 classes portadas.

`lua5.4 examples/run.lua slottimeline` importa JSON e altera display/cor/alpha/z do slot. Montagem e tempo manuais; AnimationState/Animation, ordenação/propagação completas de Armature e renderer continuam pendentes. CI agora executa 45 suítes e treze exemplos por VM. Próximo recorte: Surface/deformação, constraints/eventos e timelines de animação dependentes do controlador.


## Timelines de bones — aplicação à pose

Portados BlendState e BoneAll/BoneTranslate/BoneRotate/BoneScaleTimelineState, com aplicação à animationPose do Bone real e mistura de pesos/camadas. Diferencial: 1.828 cenários por VM; ver [BoneTimelines.md](docs/contracts/BoneTimelines.md). TimelineState.ts e AnimationState.ts continuam parciais.

`lua5.4 examples/run.lua bonetimeline` aplica keyframes importados à pose e à matriz mundial do bone, imprimindo 0/20/40/20. Montagem/tempo manuais, ainda sem AnimationState/Animation/player ou renderer. CI passa a 44 suítes e doze exemplos por VM. Próximo recorte: timelines de slots, Surface, constraints/eventos e integração do controlador.


## Bases de timeline — tempo e interpolação

Portadas as cinco classes de BaseTimelineState.ts em módulo próprio: avanço temporal, seleção de keyframes, easing e interpolação de um/dois/vários valores. Diferencial com o pin: 2.700 cenários, 1.052.450 colunas e 25 erros esperados por VM, sem aproximações. Contrato e limites em [BaseTimelineState.md](docs/contracts/BaseTimelineState.md).

`lua5.4 examples/run.lua timeline` (ou luajit) importa keyframes JSON e imprime 0/20/40/20 em quatro tempos. Os dados/parser/buffers são reais; AnimationState é explicitamente um contrato de campos nos testes/exemplo, ainda sem player ou renderer. CI agora executa 43 suítes e onze exemplos por VM. Próximo recorte: timelines concretas/BlendState, depois AnimationState/Animation.


## PathConstraint — curva e seguidores

Portado o corpo de PathConstraint para módulo próprio, completando as três classes de Constraint.ts no domínio documentado. Parser/modelos/Bone/Slot/Armature reais; preservados loops, buffers incompletos e TODOs originais. Teste diferencial: 2.851 cenários, 8.553 etapas, 193.868 colunas e 33 erros esperados por VM Lua 5.4/LuaJIT. Precisão e limites em [PathConstraint.md](docs/contracts/PathConstraint.md). CI passa a executar 42 suítes e dez exemplos por VM.

Teste sem dependências JS: `lua5.4 examples/run.lua path` ou `luajit examples/run.lua path`. Dois ossos seguem a curva em 25%, 50% e 75%. Montagem manual, sem player ou renderer; Animation, Armature completa, factories e backends permanecem pendentes. Esta atualização substitui as indicações históricas de Path pendente abaixo.


## Objetivo central

**Reconstruir o Bono-Lua em Lua, seguindo a arquitetura, os algoritmos e os comportamentos do DragonBonesJS oficial, com equivalência funcional demonstrada por testes contra o original executado.**

- **Destino único:** [SrTristeSad/Bono-Lua](https://github.com/SrTristeSad/Bono-Lua).
- **Fonte única:** [DragonBones/DragonBonesJS](https://github.com/DragonBones/DragonBonesJS), commit fixado [`64b6c69ae35777c2404be68c9192e2c56906079e`](https://github.com/DragonBones/DragonBonesJS/commit/64b6c69ae35777c2404be68c9192e2c56906079e).
- **Produto:** runtime Lua; LÖVE será um adaptador gráfico separado. JavaScript/TypeScript é utilizado apenas na infraestrutura de análise e no oráculo de testes.
- **Escopo:** matemática, core/modelos, JSON/DBDT, armaduras/ossos/slots/surfaces, constraints IK/Path, animação/timelines/blending/eventos/cache, factories, malhas/pesos/FFD, atlas/skins e contratos das integrações oficiais.
- **Critério de conclusão:** todo comportamento obrigatório catalogado, implementado e validado; divergências conhecidas resolvidas. CI verde e contagem de arquivos não significam 100% de equivalência.

## Como vamos trabalhar

Ler o arquivo upstream fixado e a versão Lua antes de cada alteração. Preservar a lógica original; adaptar somente diferenças indispensáveis de linguagem, registrando-as. Comparar entradas, saídas, estados, retornos e efeitos colaterais com o original executado. Registrar testes reais, pendências e próximo passo no GitHub.

O comando completo está em [RECONSTRUCTION_SPEC.md](docs/RECONSTRUCTION_SPEC.md); a sequência de etapas, em [ROADMAP.md](docs/ROADMAP.md).

DisplayFrame seleciona dados de geometria/textura/colisão e inicializa deformações. Slot tem fundação, vínculo ao osso, hit testing e seleção de dados/pivôs comparados. Slot.update e troca de displays já percorrem os hooks originais; backend e player continuam pendentes.

## Testar agora

Na raiz do repositório, com Lua 5.4 ou LuaJIT instalado:

```sh
lua5.4 examples/run.lua inspect
lua5.4 examples/run.lua transform
lua5.4 examples/run.lua bones
lua5.4 examples/run.lua surface
lua5.4 examples/run.lua displayframe
lua5.4 examples/run.lua slot
lua5.4 examples/run.lua slotdata
lua5.4 examples/run.lua slotruntime
lua5.4 examples/run.lua ik
lua5.4 examples/run.lua inspect /caminho/arquivo_ske.json 0.5
lua5.4 examples/run.lua inspect /caminho/arquivo_ske.dbbin
```

Pode trocar `lua5.4` por `luajit`. Os exemplos não precisam de Node/npm. `inspect` lista armaduras/animações e limpa os modelos; sem caminho, usa o JSON mínimo incluído. `transform` mostra a atualização da posição e rotação a partir de uma matriz. `bones` monta uma hierarquia real de dois ossos e gira o pai, alterando a posição do filho. `surface` deforma uma grade e move o osso filho. Ainda não reproduzem animações na tela. Veja [instruções dos exemplos](examples/README.md).

## Estado atual

Runtime: `TransformObject`, `Bone`, `Surface` e registro/ciclo de vida parcial de `Armature`, com comparação contra o original e exemplos executáveis. Slot parcial com registro/transformação/colisão; seleção de dados de display comparada; update/troca de displays e integração parcial com filhos comparados. IK de um/dois ossos comparado; Path, backend, init completo e reprodução continuam pendentes.

Corpus upstream validado: **74 exportações esqueléticas únicas**, em 181 caminhos, importadas em duas escalas nas duas VMs. Buffers e observações do grafo coincidiram com o original, sem tolerância. Ver [cobertura](docs/contracts/UpstreamCorpus.md).

BinaryDataParser: **8/8 corpos portados**, incluindo entrada DBDT e JSON interno. Novo recorte: 223 cenários comparados em Lua 5.4 e LuaJIT, nos domínios documentados. Isso não significa motor completo. Ver [API e limites](docs/contracts/DBDTEntry.md).

O checkpoint inicial foi integrado na `main` pelo [PR #63](https://github.com/SrTristeSad/Bono-Lua/pull/63), por solicitação explícita do proprietário. A main acompanha o porte em andamento; isso não significa que o motor está completo. O estado anterior permanece em `backup/pre-integral-rebuild-20261103` (`cd4206a8`).

As classes geométricas foram integradas pelo [PR #64](https://github.com/SrTristeSad/Bono-Lua/pull/64), merge `ab660cc`, com CI pós-merge aprovada. `BaseObject` foi integrado pelo [PR #65](https://github.com/SrTristeSad/Bono-Lua/pull/65), merge `92c0105`, com CI pós-merge aprovada. Os modelos foram integrados pelo [PR #66](https://github.com/SrTristeSad/Bono-Lua/pull/66), merge `e9ed0c9`, com CI pós-merge aprovada. WorldClock foi integrado pelo [PR #67](https://github.com/SrTristeSad/Bono-Lua/pull/67), merge `341df09`, com CI pós-merge aprovada. O núcleo de eventos e os dados de ações foram integrados pelo [PR #68](https://github.com/SrTristeSad/Bono-Lua/pull/68), merge `bc74a1a`, com CI pós-merge aprovada. `AnimationConfig` foi integrado pelo [PR #69](https://github.com/SrTristeSad/Bono-Lua/pull/69), merge `b45b575`, com CI pós-merge aprovada. Os dados de animação/timelines foram integrados pelo [PR #70](https://github.com/SrTristeSad/Bono-Lua/pull/70), merge `975b031`, com CI pós-merge aprovada. Os dados de display/geometria/pesos foram integrados pelo [PR #71](https://github.com/SrTristeSad/Bono-Lua/pull/71), merge `13ae3b1`, com CI pós-merge aprovada. Os modelos de armadura foram integrados pelo [PR #72](https://github.com/SrTristeSad/Bono-Lua/pull/72), merge `57e7d48`, com CI pós-merge aprovada. Os modelos de constraints foram integrados pelo [PR #73](https://github.com/SrTristeSad/Bono-Lua/pull/73), merge `2e25e30`, com CI pós-merge aprovada. SkinData foi integrada pelo [PR #74](https://github.com/SrTristeSad/Bono-Lua/pull/74), merge `0a156d2`, com CI pós-merge aprovada. DragonBonesData foi integrada pelo [PR #75](https://github.com/SrTristeSad/Bono-Lua/pull/75), merge `84c9b07`, com CI pós-merge aprovada. BoundingBoxData foi integrada pelo [PR #76](https://github.com/SrTristeSad/Bono-Lua/pull/76), merge `da30013`, com CI pós-merge aprovada. DataParser foi integrada pelo [PR #77](https://github.com/SrTristeSad/Bono-Lua/pull/77), merge `771b932`, com CI pós-merge aprovada. Helpers e atlas de ObjectDataParser foram integrados pelo [PR #78](https://github.com/SrTristeSad/Bono-Lua/pull/78), merge `ff2db0e`, com CI pós-merge aprovada. As nove dependências estruturais foram integradas pelo [PR #79](https://github.com/SrTristeSad/Bono-Lua/pull/79), merge `a2a3fe7`, com CI pós-merge aprovada. Unidade atual: `port/parser-global-entry`. As cinco classes geométricas estão portadas: `Point`, `Rectangle`, `ColorTransform`, `Matrix` e `Transform`. Comparações isoladas contra o original foram executadas em Lua 5.4 e LuaJIT; integração completa ainda pendente.

Inventário de 1.203 caminhos e declarações autorais catalogado. Dependências estáticas e fronteiras de APIs estão em [DEPENDENCIES.md](docs/DEPENDENCIES.md); estado e evidências reais, em [PORTING_STATUS.md](docs/PORTING_STATUS.md) e [VALIDATION.md](docs/VALIDATION.md). `BaseObject` inicia o core em `dragonbones/core/`, preservando o pool e o ciclo de vida do original, com comparação diferencial nas duas VMs. Os modelos `CanvasData`, `TextureAtlasData` e `TextureData` em `dragonbones/model/` avançam a validação de limpeza, cópia e reciclagem com BaseObject/Rectangle reais; backend gráfico ainda pendente. `WorldClock` está em `dragonbones/animation/`, com contrato IAnimatable documentado e testes diferenciais de tempo/callbacks. O algoritmo foi comparado com fonte determinística; a precisão do tempo automático no Lua padrão ainda depende de uma fonte do host com resolução de milissegundos. O núcleo `DragonBones`, seus enums, `EventObject` e `UserData`/`ActionData` agora têm comparação de filas, despacho, conversão de ações e pool com `WorldClock`/`BaseObject` reais. Armature e dispatchers gráficos ainda não foram implementados; seus contratos são probes somente no teste. `AnimationConfig` foi acrescentado em `dragonbones/model/`, com comparação de defaults/cópia, máscaras esparsas e pool; seu consumo por `Animation`/`AnimationState` ainda está pendente. `AnimationData`, `TimelineData` e `AnimationTimelineData` acrescentam comparação de coleções/reciclagem e cache, com registros de parent somente no teste; o cache agora também é comparado com `ArmatureData`/bones/slots reais na nova suíte; playback permanece pendente. `JSArray`/`JSMap` compartilham as adaptações de representação já usadas pelos modelos. `DisplayData.lua` acrescenta as oito classes do arquivo original, com comparação de geometria compartilhada, pesos, ações, pivôs/transforms e regras de limpeza. As referências externas ainda não portadas são contratos de teste; isso não implementa renderização, hit testing ou armaduras reais. `ArmatureData.lua` acrescenta os quatro modelos de armadura, bones, surface e slot, incluindo ordenação e armazenamento de cache. O armazenamento global agora é exercitado com `DragonBonesData` real; o runtime `Armature` e a renderização continuam pendentes. `ConstraintData.lua` acrescenta a base abstrata e os modelos IK/Path, com ordenação/limpeza de armadura exercitadas por constraints reais. Os solvers de runtime continuam pendentes. `SkinData.lua` agora integra skins/displays reais à armadura, com null explícito distinto de posições vazias e regras de devolução comparadas. O uso público das listas está em [SkinDataLists.md](docs/contracts/SkinDataLists.md); isso ainda não implementa seleção/renderização de skins no runtime. `DragonBonesData.lua` acrescenta o contêiner global, com ownership/limpeza em cascata, arrays lógicos compartilhados e cache real de frames. Buffers/views são referências não proprietárias; decodificação DBDT continua pendente; as sete views tipadas de `_modifyArray` já são comparadas, conforme [DragonBonesDataStorage.md](docs/contracts/DragonBonesDataStorage.md). `BoundingBoxData.lua` acrescenta os dados e as consultas locais de retângulos, elipses e polígonos, com ownership integrado a `BoundingBoxDisplayData` real. Retornos, pontos e normais seguem as peculiaridades originais, conforme [BoundingBoxQueries.md](docs/contracts/BoundingBoxQueries.md); isso ainda não implementa hit testing de slots transformados no runtime. `DataParser.lua` inicia `dragonbones/parser/` com as constantes e conversões da base abstrata, comparadas com o original e aplicadas aos modelos reais. A base abstrata não decodifica texto JSON/DBDT; o contrato e o limite de locales estão em [DataParserBase.md](docs/contracts/DataParserBase.md). `ObjectDataParser.lua` agora importa atlas a partir de objetos já decodificados, com os três helpers de valores e modelos reais de atlas/textura; seus 47 métodos têm corpos portados e testes nos recortes documentados (incluindo geometria, pesos, bones, displays, skins, finalização binária, curvas e frames genéricos/especializados). A entrada global para objetos decodificados está em [GlobalObjectEntry.md](docs/contracts/GlobalObjectEntry.md); leitura de texto JSON e DBDT continuam pendentes, conforme [ObjectDataParserAtlas.md](docs/contracts/ObjectDataParserAtlas.md). Os novos métodos interpretam slots, ações, constraints IK/Path, transformações, cores, pivôs e bounding boxes com os modelos reais; bones, displays e skins agora têm os corpos originais integrados à geometria; a entrada global agora reúne armaduras/animações reais; `_modifyArray` agora gera sete views de um buffer compartilhado, conforme [SharedBinaryBuffer.md](docs/contracts/SharedBinaryBuffer.md). O restante do runtime segue o [ROADMAP.md](docs/ROADMAP.md).

Para continuar, leia [NEXT_STEPS.md](docs/NEXT_STEPS.md), [UPSTREAM_INVENTORY.md](docs/UPSTREAM_INVENTORY.md) e [PORTING_MAP.md](docs/PORTING_MAP.md).

Licença e atribuição DragonBones: [LICENSE-DRAGONBONES](LICENSE-DRAGONBONES).

Curvas e frames genéricos agora são comparados com o original, incluindo agregação/serialização de ações, conforme [CurveFrames.md](docs/contracts/CurveFrames.md). Isso prepara timelines e animações; ainda não reproduz animações no runtime.

Oito serializers de frames especializados agora cobrem ordem de desenho, bones, displays, cores e IK, conforme [SpecializedFrames.md](docs/contracts/SpecializedFrames.md). Os dois serializers de deformação foram acrescentados conforme [DeformFrames.md](docs/contracts/DeformFrames.md); o ramo ponderado TODO do genérico segue literalmente o upstream. As timelines genérica, de bones e de slots agora são comparadas com callbacks reais, conforme [Timelines.md](docs/contracts/Timelines.md). `_parseAnimation` agora integra os formatos legado e genérico com modelos reais, conforme [AnimationParser.md](docs/contracts/AnimationParser.md). `_parseArmature` agora integra as estruturas e animações reais, conforme [ArmatureParser.md](docs/contracts/ArmatureParser.md). `parseDragonBonesData` agora recebe objetos decodificados e reúne versões, armaduras, buffers e atlas conforme [GlobalObjectEntry.md](docs/contracts/GlobalObjectEntry.md). Leitura de arquivos, BinaryDataParser e runtime de deformação continuam pendentes.

## Helpers binários e bytes — checkpoint atual

BinaryDataParser tem 3/8 métodos portados: `_inRange`, `_decodeUTF8` e `getInstance`. SharedBinaryBuffer agora oferece `uint8`, com aliases, metadados e coerções comparados ao Uint8Array nativo. A comparação executa o decoder original fixado: 67.083 operações e 134.166 colunas, incluindo todos os 65.536 pares de bytes, com tolerância zero. Ver [contrato](docs/contracts/BinaryUTF8.md).

Isso ainda não carrega DBDT: faltam `_parseBinaryTimeline`, overrides `_parseAnimation`/`_parseGeometry`/`_parseArray` e a entrada binária `parseDragonBonesData`, além da dependência JSON do cabeçalho. A entrada de objetos herdada não interpreta bytes. ObjectDataParser permanece em 47/47 corpos, nos domínios documentados. Runtime, factories e backends continuam pendentes.
