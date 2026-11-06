# Adaptações e divergências

## LÖVE — Multiply sobre Canvas

Multiply foi acrescentado aos sprites com composição explícita sobre uma cópia do Canvas de destino. O shader conserva os fatores originais DST_COLOR/ONE_MINUS_SRC_ALPHA e o empacotamento separado de RGB/alpha do Pixi. Exige Canvas rgba8, sem MSAA e DPI 1; a demonstração configura isso ao pressionar N. Ver [LoveMultiply.md](contracts/LoveMultiply.md).

Diferencial: 33 cenários/6.588 colunas exatas por VM Lua 5.4/LuaJIT, inclusive Multiply→Screen→Normal→Multiply. A CI acrescenta 18 capturas reais e exige 1.474.560 canais idênticos em multiply-result.json; mantém as 44 cenas anteriores e sobe para 60 suítes e 22 exemplos por VM. Resultados gráficos precisam de execução aprovada, não são inferidos da configuração.

Este é o estado atual; seções seguintes são checkpoints anteriores. Multiply faz uma cópia integral do destino por sprite e ainda não cobre janela direta, MRT, MSAA, outros formatos/DPI, texels semitransparentes ou fundos transparentes. Outros blends e exports externos continuam pendentes.

## LÖVE — blend Screen

Sprites aceitam Screen com RGB premultiplicado e alpha empacotado como no batcher Pixi 4. O shader pertence ao display, é criado sob demanda e liberado ao destruir o display; o estado gráfico do chamador é restaurado. B alterna Screen no demo, T alterna o atlas e M alterna sprites/meshes. O blend de mesh permanece como no PixiSlot original. Ver [LoveScreen.md](contracts/LoveScreen.md).

Diferencial: 33 cenários/6.588 colunas exatas em Lua 5.4/LuaJIT, incluindo troca Screen→Add→Normal→Screen. CI configurada com 59 suítes por VM e 22 exemplos; acrescenta 18 capturas reais com 1.474.560 canais exigidos exatos em blend-result.json. Mantém as 26 capturas anteriores e seus critérios. A execução gráfica é a evidência; configuração não implica aprovação.

Este é o estado atual; seções seguintes registram checkpoints anteriores. Multiply e os demais blends avançados, transparência de texels/filtragem complexa e exports externos continuam pendentes. Backend e integrações oficiais não são declarados completos.

## LÖVE — atlas rotacionados

Sprites e meshes aceitam regiões de atlas giradas em 90°, preservando as dimensões originais usadas pelo Pixi e os pivôs do runtime. Sprites usam um Mesh com UVs rotacionados; meshes conservam a fórmula original de PixiSlot. `love .` abre a demonstração; T alterna o atlas e M alterna sprites/meshes. Ver [LoveRotation.md](contracts/LoveRotation.md).

Diferenciais de rotação: sprites 56 cenários/11.857 colunas e meshes 82/22.352, exatos em Lua 5.4/LuaJIT. CI configurada com 58 suítes por VM, 22 exemplos e dez cenas gráficas adicionais contra Pixi WebGL real: 819.200 canais com igualdade exigida, sem tolerância nova. Evidência executada em rotation-result.json no artefato gráfico; a configuração do teste não substitui seu resultado. As 16 cenas gráficas anteriores permanecem.

Este é o estado atual; seções seguintes registram checkpoints anteriores. Blends avançados e validação de exports externos continuam pendentes. Backend e integrações oficiais não são declarados completos.

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


## Constraint/IKConstraint — solver real

Implementadas a base abstrata Constraint e a classe IKConstraint, em módulos separados, com _addConstraint original em Armature. Bone.update já chama o solver real pelo registro, incluindo updateByConstraint e cache. PathConstraint do mesmo TS ainda está pendente; scaleEnabled permanece TODO sem comportamento como no pin. Não há Animation/factory/renderer substitutos.

ik_differential: 15.404 cenários, 46.212 etapas, 955.048 colunas por VM Lua 5.4/LuaJIT, 32 exceções de etapas esperadas e 25.355 aproximações locais de componentes. Grade de 15.360 combinações de um/dois ossos, dobra, pesos -0,5/0/0,25/1/1,5, oito alvos, quatro flips, dois eixos Y, três avós/reflexões e quatro poses/comprimentos. Outros 44 casos cobrem chamada direta, cache hit/miss/restore, init repetido, readonly, limpeza da base/IK, dados/referências ausentes, escalas/comprimento negativos, TODO de escala, NaN e zeros. Modelos/Bone/Armature/pool reais; nenhum solver/armadura fake.

A primeira comparação mostrou propagação trigonométrica: em uma cadeia com peso 1,5 e junta perto do alvo, uma diferença de cerca de 1,33e-15 na rotação superior propagou-se até 1,33e-14 no coeficiente inferior. O algoritmo não foi trocado para igualar libm/V8. O comparador usa escala geométrica para coordenadas e condicionamento limitado para coeficientes/pose de IK; limite total de 64 eps. Flags/referências/índices/zeros e casos de erro são exatos. Ver fórmula/limites em [IKConstraint.md](contracts/IKConstraint.md); budgets anteriores intactos.

Seis mutantes rejeitados: ignorar peso, dobra, reflexão, pular update com peso zero (flags de dois ossos), perder guarda de reinit e remover compensação dR da rotação inferior. Produto restaurado e suíte completa reexecutada nas duas VMs; Bone diferencial também reexecutado. Nome da base usa _constraintData; _onClear da base deixa essa referência intacta como TS, IK a limpa. Pool/registro/flags observados após cleanup.

Exemplo `lua5.4 examples/run.lua ik` ou luajit: JSON próprio com cadeia 10+8, ponta sem IK (18,0), resolvida em (12,8), depois (8,12) ao mover o alvo. Parser, ordenação de modelos, ossos e solver reais; montagem explícita de Armature, sem player ou tela. CI configurada para 41 suítes e nove exemplos por VM.


## Slot — atualização e troca do display

Representados os corpos restantes de Slot: _updateDisplay, update, replaceDisplay e acessores/aliases displayIndex/displayList/display/childArmature/getDisplay/setDisplay. Os quatorze hooks de renderer seguem abstratos no produto. Armature recebe dispose adiado, _bufferAction e acessores clock/cacheFrameRate/display/animation/parent originais, com dependências reais. Armature.init/advanceTime/Animation/backend continuam pendentes; não é player completo.

slotruntime_differential: 1.970 cenários (1.024 de troca, 850 de update/cache/mesh/Surface, 96 de child Armature), 7.880 etapas, 165.480 colunas e 333 exceções esperadas por VM Lua 5.4/LuaJIT. Zero aproximações locais. Compara callbacks/estado/ordem/erros, flags, referências, listas, matrizes/cache, eventos e propriedade/clock/pool de filhos. Hook _updateMesh pode rearmar dirty e falhas de hooks não são revertidas. Valores false/0/string vazia não viram null; __eq não altera identidade; objeto com campos semelhantes a Armature continua display comum.

WorldClock, DragonBones core, EventObject, ActionData, Bone/Surface/modelos e Armature são reais. No teste, uma subclasse local apenas registra os quatorze hooks; não calcula/desenha vértices. Metadata de geometria sintética exercita decisões de delegação de mesh; não é equivalência de GPU. Child sem herdar animação e attach com ações reais são sucesso; play/reset sem Animation real são falhas comparadas no ponto original, não simuladores. Root é removido do relógio antes de drenar Core.advanceTime(0), que devolve filhos ao pool antes de liberar modelos.

Seis mutantes rejeitados (false como null, retenção baseada na referência errada, dirty de mesh limpo após callback, cache hit perdido, dispose sem lock e ações com push no lugar de unshift). Produto restaurado e revalidado nas duas VMs; SlotFoundation/SlotDisplayData também passam. Budgets numéricos antigos intactos; só derivados Surface usam seu orçamento 32 eps/escala de projeção 1000, flags/ref/zeros pareados exatos.

Novo comando `lua5.4 examples/run.lua slotruntime` (ou luajit): troca espada→escudo por displayIndex público, percorre Slot.update e mantém posição/colisão ao mover o pai (45,20)→(55,20). Views são referências locais observadas, sem desenho/player; montagem de Armature/modelos continua explícita. CI configurada para 40 suítes/oito exemplos por VM. Contrato: [SlotRuntime.md](contracts/SlotRuntime.md).


## Slot — seleção e substituição dos dados de display

Implementados _updateDisplayData, replaceRawDisplayData, replaceDisplayData e replaceTextureData. A seleção usa DisplayFrame/modelos/SkinData/Bone/Armature reais. Trata pivô de textura rotacionada/recortada, escala atlas×armadura, correção de transform na substituição, yDown, origin compatível, flags de geometria/textura e a lista de ossos ponderados. Não implementa Slot.update, _updateDisplay, replaceDisplay nem renderer/player.

slotdata_differential: 1.224 cenários, 11.016 etapas, 182.376 colunas e 146 exceções de etapas esperadas por VM Lua 5.4/LuaJIT; zero aproximações observadas localmente. Só quatro campos derivados (matriz local, pose, pivôs) dos casos explicitamente trig admitem o budget anterior de 8*epsilon*max(1,abs(expected)), com zeros/identidades/flags exatos. Demais cenários são comparados byte a byte. Nenhum budget anterior foi alterado.

São 1.152 combinações de tipos raw/substituto, textura rotacionada/recorte, eixo Y, escalas efetivas 1/1,5 e pesos, mais 72 cenários de fronteira. Cada caso compara nove transições e limpeza: índice omitido/negativo/inativo/alto/fracionário/NaN, frames ausentes, skin ausente/lista ausente/curta/null, textura sem atlas, armadura ausente, data igual ao raw, textura null, trig e troca apenas da caixa. Callbacks abstratos têm adaptadores somente no teste; atlas/textura são modelos reais construídos/limpos diretamente, sem recurso gráfico fictício.

Mantida a guarda por identidade frame/geometria/textura: editar offset ou trocar somente boundingBox não reconstrói a matriz. BoundingBox é relido fora da guarda. Repetir raw não limpa deformação; trocar raw limpa antes do fallback/possível erro; raw nil igual ao atual não tenta buscar a skin. Preservadas posições null/repetidas de ossos; sentinel SkinData.NULL traduzido explicitamente para nil. Seis mutantes rejeitados (guarda, yUp, sentinel, osso ausente, escala e hook gráfico inesperado), produto restaurado e revalidado nas duas VMs, com regressão de SlotFoundation aprovada.

Exemplo `lua5.4 examples/run.lua slotdata` (ou luajit): pivô (50,40)→(40,30), conservando origin.x=5; depois repete vínculo/colisão do slot. É montagem manual com _updateDisplayData direto e observador local, sem Slot.update/player/renderização. CI configurada para 39 suítes e sete exemplos por VM. Contrato: [SlotDisplayData.md](contracts/SlotDisplayData.md).


## Slot — fundação e hit testing

Slot.lua implementa inicializadores/limpeza, init/registro em Armature real, visibilidade, alpha, frames, flags/índices, cor/zOrder, transformação e hit testing. Armature recebe _addSlot/getSlot originais. DisplayFrame continua em módulo próprio. update, avaliação/troca de displays, animação filha, factory e renderer continuam pendentes; nenhum hook gráfico concreto foi adicionado ao produto.

slot_differential executa o TS fixado com Bone/Armature/modelos reais e uma subclasse observadora apenas no teste. 1.448 cenários (440 de ciclo de vida/estado, 1.008 de hit testing), 56.472 colunas, 120 falhas esperadas e 30 comparações aproximadas por VM Lua 5.4/LuaJIT. Hit testing usa retângulo/elipse, seis matrizes (incluindo reflexão, shear e singularidade), sete segmentos e oito máscaras de outputs. Só pose/outputs matemáticos não nulos aceitam 8*epsilon*max(1,abs(expected)); matrizes, flags, identidade, comprimento e zeros exatos. Não relaxa budgets anteriores.

Mantidos i < value da redução de displayFrameCount (trunca sem devolver frames removidos ao pool), _setZOrder sujando mesmo valor igual, guarda separada do índice de animação, flags publicadas antes do callback e deduplicação incluindo display null na limpeza. Quatro mutantes rejeitados (redução diferente, parar em osso null, callback antes da visibilidade e igualdade sobrecarregada de display); produto restaurado e revalidado. Contrato/limites: [SlotFoundation.md](contracts/SlotFoundation.md).

Exemplo `lua5.4 examples/run.lua slot` ou `luajit`: slot ligado ao filho passa de (45,20) a (55,20) após mover o pai; contém o centro da caixa em ambas as poses e confirma registro. Montagem manual, caixa atribuída diretamente e subclasse observadora local, sem desenho/player. CI configurada para 38 suítes e seis exemplos por VM; consultar PR #100 para estado remoto, sem antecipar aprovação/merge.


## DisplayFrame — dados dos displays de Slot

DisplayFrame, classe separada dentro de Slot.ts, implementada integralmente: inicializadores, toString, _onClear, updateDeformVertices, getGeometryData, getBoundingBox e getTextureData. A classe Slot abstrata permanece pendente; isso não implementa troca gráfica nem reprodução de animação.

Comparação diferencial com o TS fixado executado: 2.304 cenários, 32.256 colunas e 192 falhas esperadas por VM (Lua 5.4 e LuaJIT), tolerância zero. Combina seis tipos de display bruto/substituto, quatro configurações de textura, geometria com/sem pesos, buffers vazios/esparsos/editados, repetição, contagem inválida/zero, offset inválido e dados ausentes. Compara identidades retornadas, length/holes/zeros assinados, ordem de falha, limpeza e reuso do mesmo objeto/array pelo pool. Duas mutações (ignorar deformação existente e buscar fallback após textura nula do substituto) rejeitadas; produto restaurado antes da validação final.

Exemplo: `lua5.4 examples/run.lua displayframe` (ou `luajit`): malha com três vértices gera seis componentes; editar Y para 12 e atualizar novamente conserva 12. Usa modelos reais, SharedBinaryBuffer/view Int16 e pool. Ainda sem player/renderização. CI passa a 37 suítes e cinco exemplos por VM. Contrato: [DisplayFrame.md](contracts/DisplayFrame.md).


## Primeiro lote geométrico

| Aspecto | Original TS/JS | Representação Lua | Evidência/limite |
| --- | --- | --- | --- |
| Classes/construtor | new Point/Rectangle/ColorTransform | Tabelas/metatables e Class.new(...) | Mesmo estado numérico dos construtores nos testes |
| Argumento omitido | undefined aciona default | nil aciona default | Casos omitidos e com lacunas comparados |
| Métodos void | undefined | nil | Retorno verificado após copyFrom/clear/identity |
| Campos numéricos | number (binary64) | number Lua; inteiros exatos também possíveis em 5.4 | Comparação numérica exata, NaN/infinito/zero negativo explícitos |
| Cópia/limpeza | Mutação da instância, origem preservada | Mesma sequência de campos na implementação preservada | Estados e não mutação da origem comparados |

Lua não distingue automaticamente null de undefined. O contrato numérico TS não aceita null; não foi criada nem validada uma camada universal de compatibilidade JavaScript. Objetos com getters/setters arbitrários, Proxy, reflexão de protótipos e chamadas inválidas fora dos tipos TS não foram cobertos. A comparação trata registros simples com campos numéricos/ausentes.
Nenhuma divergência foi observada nas 1.384 operações do lote nas duas VMs. Isso não prova equivalência para entradas arbitrárias nem integração completa.

## Próximos módulos e plataformas

Ainda precisam de análise: índices zero, arrays esparsos e tipados, identidade de buffers, remainder, stringificação, relógio, eventos, hierarquias e APIs gráficas. Não adotar automaticamente adaptações do backup.
DEPENDENCIES.md registra APIs globais, referências não resolvidas e cinco declarações externas ausentes nos tsconfigs do commit fixado. Um backend LÖVE não será considerado prova de todas as integrações oficiais.

## Matrix e Transform

- `copyFromArray`: array Lua começa em 1, enquanto o offset público continua zero-based. Índices ausentes produzem nil, correspondente a undefined na transcrição de teste.
- `normalizeRadian`: math.fmod preserva o resto assinado do operador % JavaScript; não usar o operador % de Lua para esta função.
- `fromMatrix`: preservados atan(b/a), as duas ramificações por PI_Q e a recuperação dos sinais de escala anteriores; não substituído por atan2 ou outra decomposição.
- `Matrix.invert`: preservadas as degenerações distintas de matriz diagonal e de determinante zero, inclusive a manutenção peculiar do campo d na diagonal degenerada.
- `transformRectangle`: math.floor/math.ceil em Lua 5.4 podem retornar inteiro zero; wrappers mantêm -0 e ceil negativo próximo de zero como no Math original. A comparação adicional revelou e comprovou a necessidade.
- `toString`: JSNumberString é um adaptador Lua de representação numérica reaproveitado do backup, pois Lua tostring não usa as regras decimais de Number. Não participa das fórmulas do motor. As 158 strings do lote compararam exatamente; não há prova exaustiva de todos os binary64, locales ou chamadas fora dos tipos TS.
- Trigonometria: somente resultados não nulos de seno/cosseno/atan e sua decomposição aceitam `8 * 2^-52 * max(1, abs(esperado))`, por diferença de arredondamento entre V8 e libm. NaN, infinitos, sinais de zero, translações e demais operações permanecem exatos.

Sem divergências nos cenários numéricos/string executados após corrigir o zero assinado. Não foram validadas operações encadeadas arbitrárias sobre campos nil/undefined, objetos Proxy/getters, coerção geral de tipos JS ou inteiros Lua fora da representação canônica Number; esses limites não são uma declaração de equivalência irrestrita. Integração de armaduras, cache e GPU ainda pendente.

## BaseObject

- `new Subclass()` e inicializadores de campo TS são representados por `Subclass.new()` chamando `BaseObject.new(Subclass)`. Tabelas/metatables substituem protótipos; constructor é uma referência explícita na instância.
- `String(constructor)` usa `constructor.toString(constructor)` no contrato de classes Lua. O argumento explícito representa o receptor estático JS; os métodos originais retornam strings. Não usar identidade de tabela como chave, pois removeria colisões e compartilhamento observáveis no original.
- `_hashCode` inicia em 0.0 e incrementa em 1.0, preservando o comportamento binary64 inclusive perto de 2^53; campos estáticos, mapas e flags são observáveis.
- Uma lista auxiliar de chaves mantém a enumeração de pools: índices canônicos 0..2^32-2 em ordem numérica, depois outras strings na ordem de inserção. "-0" é string comum, não índice. Isso preserva efeitos anteriores a uma exceção de resize global; não substituir pelo pairs não ordenado.
- `Array.length = limite` só lança erro de comprimento fracionário quando ocorre uma redução real. Limites fracionários podem aceitar ceil(limite) objetos no retorno, conforme a condição original; não arredondar o limite antecipadamente. Clear/truncamento não mudam flags dos objetos removidos.
- console.warn é encaminhado a stderr com a mesma mensagem. Teste intercepta o canal de avisos em ambas as linguagens. Exceções são comparadas por categoria/efeitos, sem exigir stack traces idênticos.

38 cenários/1.211 operações passaram exatamente nas duas VMs. A comparação usa subclasses de teste exclusivamente para observar chamadas _onClear e identidade. Integração com subclasses reais será validada ao portá-las.
Limites explícitos: não emula Object.prototype para chaves como __proto__/constructor herdadas do objeto-mapa JS; não reproduz a reflexão genérica/PropertyDescriptors/Function.toString de classes sem o contrato estático do runtime; substituir mapas readonly ou manipular seus protótipos diretamente não foi coberto. Construtores cujo toString viola a assinatura string TS não foram tratados como equivalentes. Não declarar equivalência irrestrita de JavaScript a partir deste lote.

## CanvasData, TextureAtlasData e TextureData

- Construtores Lua preservam campos TS sem inicialização como nil/undefined observável; não executam _onClear antecipadamente. Borrow real executa a limpeza original. Canvas mantém os seis campos/reset exatos e não apaga propriedades extras alheias a _onClear.
- Rectangle de region permanece por identidade durante cópia, limpeza e retorno ao pool. Frames existentes são reutilizados na cópia; criados/descartados conforme o teste de null original. TextureData.copyFrom mantém parent da origem, sem trocá-lo pelo atlas de destino.
- textures é uma tabela pública comum, preservada por identidade. __newindex e metadados fracos registram inserção de nomes; os métodos do motor enumeram índices canônicos primeiro e as demais strings por inserção, como for..in. Atualização de valor mantém posição; exclusão/reinserção recebe nova posição. Escritas normais diretas são cobertas; rawset/substituição de metatable ou da tabela readonly não são equivalentes declarados.
- A normalização do teste é explícita: parent JS undefined/null e resultado ausente de getTexture representam nil no Lua. Scalars não inicializados continuam distintos de false/0; frame/region/identidades são comparados. Não há tolerância numérica.
- createTexture continua um contrato abstrato do backend. A implementação Lua falha explicitamente se chamada sem adaptação concreta; o teste usa apenas uma subclasse local que retorna TextureData pelo pool e permite injetar falha, sem simular gráficos.
- O compilador do teste recebe o namespace TS completo para resolver BaseObject/Rectangle entre arquivos; só os quatro JS correspondentes são executados no oráculo. Não foram adicionados aliases globais ou versões reescritas das fórmulas para mascarar referências não resolvidas.

18 cenários/639 operações passaram nas duas VMs. A ordem de pares do backup falhou no copy dest src; corrigida a representação de mapa, o caso e as identidades passaram sem alterar expectativas.
Limitações conhecidas: o mapa Lua não emula propriedades herdadas de Object.prototype (ex.: nomes constructor/__proto__/toString), nem getters/proxies/protótipos arbitrários ou distinção universal null/undefined. A integração gráfica e a equivalência irrestrita continuam pendentes.

## WorldClock / IAnimatable

- IAnimatable é somente interface TS. O contrato Lua é documentado, não simulado como classe; void vira nil e clock nulo vira nil.
- Objetos e marcadores usam rawequal onde o original exige ===/!==/indexOf por identidade. __eq de um animatable Lua não pode fazê-lo substituir outro nem confundi-lo com o marcador null.
- _animatebles conserva a grafia original. A tabela usa índices Lua 1-based, marcador privado para null, nil para leitura de undefined e campo length para o comprimento lógico JS. Não usar #/ipairs para perder posições sem valor após callbacks reentrantes. Escritas internas além do fim atualizam length; resize inválido lança erro antes de mudar o comprimento, como Array.length.
- clear mantém o algoritmo original de atribuir clock=null. Campos simples podem continuar na lista mesmo sem proprietário; setters recíprocos podem remover entradas. O loop usa comprimento corrente como for..of, sem antecipar remoção/compactação.
- Fonte _now retorna segundos de época e representa new Date().getTime()/Date.now() * 0.001. O default usa os.time()+0.0: época correta, mas resolução de segundos. O uso automático de love.timer monotônico do backup foi removido, pois troca a origem observável do tempo.
- **Divergência conhecida:** resolução do tempo automático no host Lua padrão ainda inferior ao Date em milissegundos. Hosts podem fornecer _now com resolução adequada, antes de criar relógios. Não se afirmou equivalência da fonte real com base no provider determinístico de teste.
- Os testes distinguem null de posições undefined na lista por seus marcadores/índices, mas não refletem descritores de propriedade de arrays, coerções JS arbitrárias ou manipulação direta do array privado. Null de clock vira nil. NaNs usam um marcador canônico; demais números são comparados por bytes.

Ciclos não recebem detecção nova: os testes inspecionam somente consultas finitas e desfazem ciclos antes de avançar. Não afirmam suportar travessias que já não terminam no original. Armature e animação reais ainda não estão envolvidos nesses testes.

## Núcleo de eventos, enums e dados de usuário

- Const enums de core/DragonBones.ts ficam em core/Enums.lua; DragonBones reexporta as tabelas por nome e EventObject/UserData importam a mesma fonte. São 98 valores conferidos com a emissão genuína TS preserveConstEnums do teste. Isso evita ciclo de require; não duplica números mágicos nos algoritmos. O teste habilita emissão dos enums sem alterar o TS fixado; o produto continua Lua.
- JavaScript console.info vira print da mensagem original do construtor; console.warn continua stderr de BaseObject. Fallbacks console.warn/assert e Date.now, helper __extends e exports AMD/CommonJS/window/global são mecanismos JS, não algoritmos portados. Lua usa require/return e metatables; não altera globais console/Date/window nem simula loaders JS. Map<T> é contrato de mapa, não classe; EventStringType é string. Compatibilidade de integrações oficiais ainda será auditada.
- Filas privadas densas usam índices Lua base 1. Métodos só acrescentam e esvaziam; iteração consulta o tamanho corrente como no original. bufferEvent/bufferObject deduplicam por rawequal, inclusive com __eq que considere dois objetos iguais. Reciclagem ocorre antes de avançar o clock; eventos despachados são devolvidos no avanço seguinte. Falhas propagam mantendo filas/estado parcial do upstream. Nenhum guard, catch ou filtro novo foi adicionado.
- clock/eventManager são getters somente leitura e rejeitam atribuição normal. Rawset, troca de metatable, propriedades esparsas da fila privada e reflexão JS arbitrária não são equivalência declarada.
- Armature descartada usa _armatureData=nil para null; referências objeto null/undefined normalizam nil. A chamada de som mantém a ordem local/global e relê eventObject.type após callback. O contrato de Armature precisa fornecer campos/métodos originais; probes não são runtime.
- EventObject._onClear não devolve payload/ActionData ao pool; ActionData._onClear devolve seu UserData antes dos próprios resets, preservando falha/estado parcial. Construtores não antecipam _onClear. actionDataToInstance mantém time/animationState e bone/slot antigos quando a ação não tem essas referências, conforme o original.
- UserData preserva identidade de ints/floats/strings na limpeza; arrays Lua densos base 1, getters públicos base 0. Não converte addInt para inteiro: preserva binary64, NaN e sinal de zero. Fora dos limites, getters retornam 0/0.0/empty string; índice fracionário dentro do intervalo produz nil, equivalente ao undefined da propriedade ausente JS. A integralidade é verificada antes de +1 para impedir arredondamento subnormal ao primeiro elemento. Escritas esparsas/propriedades fracionárias customizadas/proxies no array público não são equivalência comprovada neste lote.
- IEventDispatcher é contrato documentado. Só dispatchDBEvent foi exercitado pelo núcleo com probes; has/add/removeDBEventListener, binding de thisObject e backend real continuam pendentes.

Os testes executam os cinco arquivos TS genuínos pertinentes ao pool/clock/eventos/modelos/core. Todo o namespace é compilado para resolver referências, mas nenhuma classe não portada é simulada como código de produto.

## AnimationConfig e boneMask

- Classe Lua herda BaseObject e importa core/Enums diretamente; não carrega DragonBones/WorldClock para acessar constantes. Inicializa apenas boneMask no construtor; borrow e clear executam os defaults exatos, inclusive timeScale=-100.0 (a prosa @default 1.0 do upstream não substitui o código).
- copyFrom mantém a sequência de atribuições e leituras do original. Todos os 21 campos são copiados; a máscara é copiada elemento a elemento para o mesmo array do destino, sem devolver self ou criar um array substituto. Exceções de leitura propagam com os efeitos parciais originais. Getters de origem são instrumentação somente do teste.
- boneMask é tabela com entradas base 1 e propriedade length mantida por metatable/estado privado. Atribuir índice inteiro novo estende length; atribuir length valida 0..2^32-1 integral, remove somente índices acima do novo fim e preserva propriedades nomeadas. Crescer length não inventa strings nas posições vazias. #/ipairs/table.insert não substituem esse contrato em arrays esparsos, especialmente entre Lua 5.4 e LuaJIT.
- Para adicionar, usar m[m.length+1]=nome; para dimensionar, m.length=n; ler/escrever entradas por índice Lua. Para o equivalente de delete JS sem estender o comprimento, rawset(m,index,nil). Outros rawset que acrescentem índices ou substituam length podem violar a representação e não são uso equivalente. Métodos do próprio AnimationConfig preservam length/identidade.
- A comparação normaliza hole e undefined explícito como leitura nil, preservando comprimento e valores, não descritores/hasOwnProperty. Não emula propriedades herdadas de Array.prototype, Proxy JS ou coerção de tipos arbitrários para length. Comparados strings repetidas/vazias/UTF-8, máscaras vazias, autocópia e aliases de array injetados no teste (readonly TS não é um getter de runtime).
- Campos extras da instância e da máscara permanecem após clear; somente campos/índices que o original limpa são modificados. Erros de comprimento inválido são comparados por categoria e efeitos, não por texto/stack JS.

A classe está comparada com pool real; integração em Animation/AnimationState e reprodução de animações ainda estão pendentes.

## AnimationData / TimelineData / AnimationTimelineData

- JSArray.lua compartilha a adaptação de comprimento lógico já usada por boneMask; JSMap.lua compartilha a ordenação de mapas já usada no atlas. AnimationConfig/TextureAtlasData passaram novamente em ambas as VMs após a extração, sem mudança de algoritmo ou perda de identidade.
- Coleções de timelines e índices de cache são mapas de tabelas com as mesmas identidades durante a limpeza. Chaves numéricas canônicas primeiro, depois strings por inserção. A enumeração captura chaves iniciais, ignora as excluídas antes da visita e não visita novas chaves adicionadas durante esse for..in; listas internas consultam length corrente, inclusive em callbacks que acrescentam timelines. Erros em posições sem valor propagam; ipairs não encurta silenciosamente uma lista esparsa.
- add*Timeline deduplica por rawequal, preservando indexOf JS mesmo com __eq Lua. Retorno ao pool segue grupos bone/slot/constraint/animation, depois mapas de índices, actionTimeline e zOrderTimeline antes dos resets. Duplicatas entre grupos/refs podem devolver o mesmo objeto várias vezes e emitir os avisos originais; não foi criado proprietário alternativo nem captura de erros.
- cachedFrames e índices por bone/slot usam posições Lua base 1 e length lógico. cacheFrameCount passa pela validação de tamanho de array original: números negativos, fracionários não integrais, NaN, infinitos ou >2^32-1 inválidos geram erro antes de alterar o array. Os índices novos são preenchidos com -1 e substituem nomes repetidos, sem limpar nomes antigos que o original não remove.
- A fonte usa this.cacheFrames.length, não this.cachedFrames.length. Para a função original isso vale 1: escreve false no primeiro slot, preservando valores anteriores nas demais posições ainda existentes e posições vazias novas. Contagem zero ainda executa essa escrita e cresce cachedFrames para 1; arrays de índices continuam com contagem zero. Não corrigir a peculiaridade para preencher todos os slots nem limitar por cacheFrameCount.
- Campo numérico sem inicializador TS é nil no Lua; nesta aritmética/comparação representa undefined convertido em NaN. Math.max também propaga NaN explicitamente, evitando diferença do host. Construtor raw seguido de cache mantém o estado parcial original (rate atualizado, RangeError de length), sem erro Lua anterior por comparação/multiplicação de nil. Não é emulação genérica de coerções JS fora dos tipos declarados.
- Parent usa apenas listas sortedBones/sortedSlots com length e membros name. Registros e getters de nome só nos testes; contrato em contracts/AnimationDataParent.md, sem ArmatureData substituto. O método não depende de executar a classe ArmatureData. Integração real, ordenação e armazenamento de transformações ainda pendentes.
- TimelineData.new aceita classe de subclasse para representar inicializadores herdados. AnimationTimelineData chama a limpeza de TimelineData antes de x/y. Chaves toString e pools são os originais, sem compartilhar indevidamente as duas classes.

Normalizações: referências objeto JS null/undefined para nil; holes/undefined explícito por valor/length, sem descritores/Array.prototype. Mapas não emulam chaves herdadas de Object.prototype, protótipos/proxies arbitrários ou rawset que burle metadados. A observação de aridade vale para o método original não substituído; reflexão/redefinição arbitrária de Function.length não é equivalência declarada. Nenhum playback foi demonstrado por esta suíte.

## DisplayData, GeometryData e WeightData

- As oito classes do arquivo preservam a estrutura original. GeometryData é objeto comum sem hashCode/returnToPool; DisplayData é base abstrata, sem chave de pool concreta inventada. Subclasses chamam o construtor base com sua própria classe e mantêm Point/Transform/GeometryData/arrays por identidade durante a limpeza e reutilização.
- GeometryData.clear devolve WeightData real quando isShared é falso/ausente; geometria compartilhada apenas solta sua referência. shareFrom atribui isShared=true, offset e weight nessa ordem; data/inheritDeform permanecem no destino, peso anterior não é devolvido e compartilhamento em si mesmo mantém o comportamento original. Não acrescenta contagem de referências nem repara a vida útil do upstream.
- vertexCount/triangleCount são getters sem setter. O índice é calculado offset+BinaryOffset em base 0; offset sem inicialização representa undefined->NaN nessa adição. Índice negativo, não finito ou não integral retorna nil (undefined do Int16Array). Só após validar o índice efetivo ocorre +1 para a tabela Lua, evitando que 5e-324 arredonde para a posição 1. Índices próximos de inteiros respeitam o arredondamento da própria adição com BinaryOffset. data/intArray ausentes mantêm erro; não viram contagem zero.
- intArray é uma fronteira de dados já decodificados em posições base 1; esta unidade não implementa Int16Array, serialização ou coerções/propriedades arbitrárias de typed arrays JS. O oráculo usa Int16Array genuíno e os registros Lua usam os mesmos valores Int16 válidos. Referências externas documentadas em contracts/DisplayDataReferences.md, sem modelos de produto fictícios.
- DisplayData._onClear não altera type; subclasses atribuem seus tipos na ordem original, inclusive em falhas. Image limpa pivot e solta texture; ArmatureDisplay limpa ações proprietárias antes de type/inheritAnimation/armature; Mesh atribui type, limpa geometry e só depois texture; BoundingBox devolve o objeto antes de type/nulificação; Path atribui tipo/closed/constantSpeed antes de geometry e só depois limpa curveLengths. Falhas mantêm os efeitos anteriores.
- actions, curveLengths e bones usam JSArray base 1/length. addAction/addBone aceitam duplicatas e acrescentam após o comprimento lógico, inclusive depois de posições vazias. A iteração de ações consulta length corrente, processa acréscimos de callbacks e propaga erro em undefined; não encerra como ipairs em uma lista esparsa. Comprimento inválido lança erro antes de alterar o array; campos nomeados extras permanecem após truncar.
- WeightData esvazia bones sem devolver BoneData; textura, skin parent e referência armature também não são devolvidas por suas classes de display. Ações usam ActionData/UserData reais; o contrato de boundingBox é probe de teste, sem algoritmo de BoundingBoxData. TextureData é instanciado cru no teste como referência, sem backend concreto, e não é reciclado pela limpeza do display.

Referências null/undefined normalizam nil; holes/undefined por valor/length; descritores/proxies/Array.prototype, coerções JS fora dos tipos TS e rawset que burle metadados não são equivalência declarada. Objetos de dados e regras de ciclo de vida não demonstram renderização, deformação ou integração de armadura.

## ArmatureData, BoneData, SurfaceData e SlotData

- Campos sem inicializador não recebem defaults antecipados; borrow executa o _onClear original. Em defaultSkin/defaultAnimation e BoneData.parent, nil público representa tanto undefined inicial como null; _referenceState interno da instância distingue as decisões estritas. Escrita normal de nil representa null. addSkin/addAnimation escolhem padrão somente quando o original testa null (ou nome default para skin), não por qualquer leitura nil. SurfaceData usa os mesmos acessores de parent herdados; sem registro global de referências.
- Arrays JSArray base 1/length e mapas JSMap preservam identidades, comprimento lógico, enumeração de chaves próprias canônicas/inserção e alterações de callbacks. Ações crescentes são processadas pelo loop e posições sem valor geram erro como for..of. Mapas só excluem a entrada após retorno ao pool bem-sucedido, respeitando grupos/ordem e deixando estado parcial em erro.
- sortBones mantém a cópia concat, o comprimento original, a varredura circular e as duas esperas (pai e alvo de constraint). indexOf/=== de objetos viram rawequal; leitura de hole não é elemento encontrado por indexOf. Não é substituído por outro algoritmo de ordenação. Não há detector de ciclos, fallback ou limite de iterações no produto; grafos com ciclos/pais ausentes ou duplicatas diretas podem não terminar no próprio upstream. O subprocesso de teste tem timeout de 10s, independente do algoritmo.
- cacheFrames preserva guarda positiva, atualização antes de delegar e ordem do mapa de AnimationData reais. Campo cacheFrameRate não inicializado representa undefined->NaN na comparação, sem erro Lua precoce. Falha de animação mantém rate e efeitos anteriores; TODO do upstream não foi reinterpretado como recache automático.
- setCacheFrame usa parent.cachedFrames.length, retorna offset base 0, aumenta length em dez antes de ler/escrever os seis campos de Matrix e os quatro de Transform. Assim preserva holes, erros de resize e dados parcialmente gravados se uma leitura falhar. getCacheFrame calcula cada índice base 0 antes de converter para base 1; índices fracionários/subnormais/ausentes são tratados pelo índice efetivo de cada acesso, evitando arredondamento ao primeiro slot. Transform.x/y vêm de Matrix.tx/ty, conforme a fonte.
- BoneData devolve UserData antes dos resets. SurfaceData executa limpeza de BoneData, redefine type/segmentos e então GeometryData; falha no peso deixa os efeitos anteriores. SlotData devolve UserData, solta color sem devolver/resetar ColorTransform e mantém DEFAULT_COLOR compartilhado separado de createColor. Rectangle/Transform/GeometryData/ColorTransform preservam identidades e valores nas regras originais.
- addBone/addSlot/addConstraint/addSkin/addAnimation preservam recusa/aviso de nome duplicado e atribuições parent no ponto original. Não ordenam slots por zOrder. getMesh delega a getSkin/getDisplay e preserva retorno/erro, sem implementar skin, mesh rendering ou hit testing.

AnimationData.cacheFrames agora é exercitado com parent/bones/slots reais; skins, constraints e parent.cachedFrames global seguem contratos de teste. Nomes violando assinatura string TS, Object.prototype, propriedades esparsas/customizadas arbitrárias de arrays JS, descritores/proxies e rawset que burle acessores/metadados não são equivalência declarada. A normalização pública nil não promete distinção universal null/undefined fora das decisões explicitamente adaptadas.

## ConstraintData, IKConstraintData e PathConstraintData

- ConstraintData é base abstrata com inicializadores de BaseObject, sem defaults antecipados ou chave de pool concreta inventada. IK chama a limpeza base e redefine scaleEnabled/bendPositive/weight; Path chama a mesma base, solta vínculos e esvazia a mesma tabela bones antes dos modos/valores. Tipos e valores seguem o código, não correções inferidas pelo nome da classe.
- **Peculiaridade preservada:** PathConstraintData._onClear não define ConstraintType.Path; mantém ConstraintType.IK da base. Não alterar esse reset para tornar o nome intuitivo. Todos os campos sem inicializador permanecem nil/undefined até a limpeza; Path só cria bones no construtor.
- AddBone mantém A maiúsculo e não recebe alias addBone. Usa JSArray com posições base 1/length, aceita duplicatas, acrescenta após posições vazias e não assume #. Como Array.push, escreve a propriedade antes de definir o novo length. Em length=2^32-1, a propriedade JS 4294967295 (não índice de array; Lua 4294967296) é escrita, a tentativa de length=2^32 falha e o length anterior permanece. Essa propriedade sobrevive a bones.length=0; o teste a observa separadamente dos índices normais.
- A lista bones é não proprietária e mutável como no TS; aliases de array mantêm identidade e efeitos compartilhados da limpeza. Substituição deve respeitar a representação JSArray. Root/target/bone/pathSlot/pathDisplayData são soltos sem returnToPool dos referidos, sem reset de GeometryData/pesos/displays ou contagem de referências nova.
- Integração usa ArmatureData/BoneData/SurfaceData/SlotData/PathDisplayData reais: espera por alvo/root na ordenação original, devolução das constraints pelo modelo de armadura e avisos/falhas parciais. Isso substitui a fronteira de constraint na nova suíte de integração; a suíte antiga armaturedata mantém seus probes isolados.

Referências null/undefined representam nil; holes/undefined comparam por valor e comprimento. A propriedade não índice observada é a do overflow de push, sem emulação genérica de coerções/proxies/descritores JS. Grafos são acíclicos nos testes, sem detector de ciclos ou timeout no produto. Dados de IK/Path não implementam solvers de runtime, física, deformação ou playback.

## SkinData e listas nullable

- displays é JSMap e listas são JSArray, preservadas por identidade. Não antecipar defaults de name/parent no construtor. Índices Lua base 1/length lógico; enumeração de chaves próprias canônicas e de inserção mantém a ordem de devolução/pool. O loop de lista consulta length corrente e não encerra silenciosamente em hole como ipairs.
- Null explícito usa SkinData.NULL por identidade rawequal; é marcador, não display poolável. addDisplay(slot,nil) é null explícito, assim como o marcador; omitindo o segundo argumento, a chamada representa undefined e falha após criar a lista vazia. Leitura nil dentro de length é undefined/hole, não null: getDisplay/clear propagam erro ao acessar name/returnToPool. O teste compara null distintamente de undefined, normalizando somente descritores de hole versus undefined próprio.
- addDisplay cria a lista, atribui parent ao display e só então busca a lista e executa os passos de push. Setters de parent instrumentados no teste podem falhar, substituir ou excluir a lista; o estado parcial e o destino efetivo do append são mantidos. Em overflow uint32, parent e propriedade não índice são escritos antes de length inválido falhar, como Array.push.
- getDisplays retorna a mesma lista, sem filtrar/compactar null ou clonar; getDisplay busca o primeiro nome e ignora apenas o marcador null. ArmatureData.getMesh mantém o cast TS apagado: pode retornar outro tipo de DisplayData com o mesmo nome, sem filtro de tipo novo.
- clear devolve referências repetidas/compartilhadas em cada posição e remove a chave só após a lista terminar. Não solta vínculos da skin anterior em add nem implementa contagem de referências. Chaves excluídas antes da visita são ignoradas; novas chaves de callbacks não são visitadas na enumeração corrente do original executado e podem permanecer até após retorno/reuso do pool. Preservados avisos e efeitos parciais de falhas.
- O marcador é truthy no Lua. APIs consumidoras futuras das listas precisam testar rawequal(value,SkinData.NULL); não basta if value. Operações públicas e exemplo em contracts/SkinDataLists.md. Escritas nil em listas representam undefined/hole; para null explícito usar o marcador. Não modificar marcador ou burlar metadados com rawset indiscriminado.

A nova suíte usa ArmatureData/SkinData/displays/GeometryData/WeightData/ActionData/UserData reais, sem registro substituindo skin. Setters/hooks são infraestrutura de observação em instâncias reais. Isso não é runtime de skins, renderização, hit testing ou playback. Object.prototype/proxies/descritores/coerções arbitrárias e buffers binários ainda não são equivalência declarada.


## DragonBonesData

Porta o contêiner global com JSArray base 1/length e JSMap em ordem própria de JS. Offsets de cache públicos continuam base 0 em ArmatureData. Retém referências a binary e sete views sem copiar/decodificar; _onClear apenas as remove, como TS. Não traz setBinaryBuffer/_binaryBuffer do backup: eles pertenciam à adaptação anterior de buffers/parser, não à classe upstream. A representação compartilhada de ArrayBuffer/typed arrays será implementada na fronteira binária, sem declarar equivalência por referências isoladas. stage não é proprietário; armaduras e userData são devolvidos na ordem original. parent/name/mapa/push mantêm leitura tardia e falhas parciais. Null/undefined de refs normalizam nil; arrays numéricos preservam length, holes por valor e extras, sem emulação genérica de descritores/proxies/Object.prototype.


## BoundingBoxData

Quatro classes do TS mantidas, base abstrata sem chave concreta nova no pool. Outcodes usam flags aritméticas 0..15 para portabilidade Lua 5.4/LuaJIT; atan2 usa math.atan2 quando disponível ou math.atan(y,x). Vertices JSArray base 1/length preserva holes, length ímpar, extras e identidade no clear; campos numéricos undefined/holes convertem NaN no uso aritmético, sem inicializar defaults cedo. Segue a ordem aritmética TS, inclusive pY*(widthH/heightH) na elipse. Não altera peculiaridades pointB.y=xB, nome EllipseData, outputs opcionais/aliases, deslocamentos do polígono ou broad phase. Resultados exatos salvo componentes não nulas de normal provenientes de atan2, inclusive valores herdados, com limite explícito 8*epsilon*max(1,abs(expected)); zeros e sinais permanecem exatos. Não implementa hit testing de Slot ou transformações/renderização do runtime. Contrato em contracts/BoundingBoxQueries.md.


## DataParser

Base abstrata representada como módulo/tabela; sem BaseObject, pool ou corpos inventados para as duas assinaturas abstratas. Constantes e dez switches mantêm nomes/valores/defaults, sem trim/coerção de tipos; DRADON_BONES conserva grafia da fonte. DATA_VERSIONS usa JSArray base 1/length e é compartilhado por herança estática, preservando identidade/mutações/extras. Protected/readonly não viram descritores de runtime, conforme emit JS. Para matching dos tokens ASCII, baixa ASCII explicitamente e Kelvin UTF-8→k; outros strings desconhecidos usam default. Isso evita depender do locale C e não é lower Unicode geral. Três helpers usam toLocaleLowerCase na fonte: suporte comparado no casing não túrquico en-US; equivalência em outros locales de host, como tr/az, está pendente. Valores fora de string lançam erro, sem emular objetos JS com métodos customizados. Ver contracts/DataParserBase.md.


## ObjectDataParser parcial e valores raw

Cinco dos 47 métodos, inicializadores, singleton e ActionFrame; métodos de armadura/animação permanecem ausentes. ActionFrame é exportado como ObjectDataParser.ActionFrame para corresponder à segunda classe do arquivo; FrameValueType é const enum e Step inicial é 0. Arrays de trabalho usam JSArray, mapas JSMap e math helpers reais. JSValue (não classe upstream) adapta valores JSON-like já decodificados: NULL/UNDEFINED marcados, presença de chave, truthiness, String e Number; arrays raw devem vir de JSValue.array, sem inferência de tipo por #. O argumento raw nil explícito corresponde a null, raw omitido/UNDEFINED gera assert e erro; escala nil/UNDEFINED é default, escala null deve usar NULL. Coerções primitivas seguem gramática JS, não tonumber permissivo; String(number) reutiliza JSNumberString. Sem suporte geral a métodos customizados/proxies/protótipos/descritores. A fila usa índice público interno base 0 e itens raw base 1, pós-incrementa antes de recursão e relê campo vivo depois. Limites em contracts/ObjectDataParserAtlas.md. Isso não é JSON decoder nem parsing de armadura/DBDT/renderização.


## Dependências estruturais do parser

UserData usa JSArray base 1/length em vez de # para conservar payloads undefined/holes; valores raw não são convertidos quando a fonte só faz push. Marcador raw UNDEFINED vira nil ao ser acrescentado, mantendo length; NULL permanece marcador quando um payload de tipo inválido contém null. Adaptador interno ArmatureData._isNullReference compartilha o estado privado já existente para comparações estritas do parser, sem mudar leitura pública nil. Path instanceof percorre herança de classes e aceita subclasses. JSValue.iterator reflete o emit TS2.4/ES5 com comprimento vivo e indexação de arrays/array-like, não Symbol.iterator; strings usam unidades UTF-16 e surrogates isolados são WTF-8 em Lua. Strings de entrada seguem UTF-8; consumidores/serializadores de payloads fora do tipo precisam preservar essas unidades. Sem decoder JSON ou emulação de descritores/proxies/coerções genéricos. Contrato em StructuralParser.md.


## Geometria e skins do parser

Arrays de trabalho JSArray preservam reservas/hole/length, sem preencher zero antes da etapa binária. Offsets públicos internos base 0, índices Lua base 1; indexOf usa identidade/igualdade estrita e skip de holes. Marcador UNDEFINED conserva valores copiados, com normalização por valor/length nos testes. Ponte de leitura de poses adapta índices para Matrix.copyFromArray real e mantém undefined como nil; invert/transformPoint convertem nil para NaN no uso aritmético, com ordem/singularidades originais. Sem emulação de coerções de coeficientes não numéricos. SHARE apenas enfileira as mesmas refs, ações usam comprimento vivo e skins convertem raw falsy para SkinData.NULL. _parseArray esvazia só os sete arrays originais, preservando outros caches. ArrayBuffer/views/alinhamento/coerção tipada continuam pendentes; nenhuma serialização binária foi inventada. Ver GeometryParser.md.


## _modifyArray e armazenamento tipado — estado atual

A pendência de empacotamento descrita nas unidades anteriores é sucedida por _modifyArray. Um Buffer mutável preserva identidade em DragonBonesData.binary; sete proxies de view compartilham o mesmo objeto e não copiam memória independentemente. bytes() produz snapshot string imutável e cache invalidado em escrita. Lua 5.4 usa proxy table; LuaJIT usa newproxy para comprimento numérico. Use .length em loops portáveis, índices base 1 e offsets de bytes base 0.

Int16/Uint16 seguem conversão JSValue, truncamento e módulo; Float32 usa arredondamento ties-even, subnormais, infinito e sinal do zero. Undefined/holes viram NaN nas views float, zero nas inteiras; null vira zero. Escritas numéricas fora dos limites ainda convertem antes de serem ignoradas, como no original. Propriedades de metadados são somente leitura, extras nomeados são preservados. Não emula índices numéricos canônicos em strings, descritores/proxies/reflexão/espécies JavaScript, buffers destacáveis/redimensionáveis, BigInt ou todo o construtor ToIndex. O adaptador view recebe comprimento em bytes inteiro/múltiplo, diferente do construtor JS com contagem de elementos. Contrato restrito às três views usadas pelo parser.

Representação little endian validada contra host little endian. NaNs numéricos de entrada são canonicalizados; bytes de NaN arbitrários continuam visíveis em aliases, sem promessa de preservar payload ao carregar/regravar o número. Não equivale a suporte big endian. Preservada peculiaridade original do alinhamento de colorArray, ordem das sete cópias e atribuições, refs antigas em falhas, reset final de _defaultColorOffset. Ver contracts/SharedBinaryBuffer.md.


## Curvas, frames e agregação de ações

_getCurvePoint conserva a ordem de multiplicações/somas, convertendo coordenadas com JSValue (undefined/hole→NaN, null→0). O contrato dos argumentos de controle de frame (start/count/type/default/scale) é numérico conforme TS; não afirma coerção JS genérica para esses campos injetados. Curvas raw aceitam arrays JSON-like, array-like/string ES5 e coordenadas coercíveis do adaptador. _samplingEasingCurve mantém os dois ramos, saltos de segmento, endpoints implícitos/explicítos, limiar e último probe. Não substitui por fórmula fechada ou midpoint novo. Curvas patológicas que fazem o while do upstream não terminar não recebem timeout inventado de produto.

_parseTweenFrame usa presença de CURVE antes de easing, reserva helpArray por length (sem preencher zeros), conserva sinal da contagem de samples e arredonda os valores ×10000. Math.round é ties para +infinito e preserva -0, sem floor(x+0.5) que muda inteiros grandes. Single/Double Step não aplicam escala/tween; Int/Float reservam após tween e antes das leituras dos valores. Tipo desconhecido retorna offset zero sem tocar raw/arrays. Ordem das leituras de x/y e efeitos parciais são observáveis e preservados.

_parseActionDataInFrame usa EVENT/SOUND/ACTION/EVENTS/ACTIONS nessa ordem. _mergeActionFrame captura actionOffset antes do parse, adiciona ações reais à armadura antes de criar frames, mantém frame zero inicial e insere/reusa por comparação original, inclusive NaN/infinitos sem ordenar de novo. ActionFrame não é BaseObject nem devolvido ao pool; seus offsets são base 0, armazenamento Lua base 1 com length lógico. _parseActionFrame copia offsets inclusive undefined/holes; _modifyArray depois faz a coerção Int16. Teste injeta falha em addAction da instância real para observar órfãos e ações já adicionadas, sem hooks novos de produto. Contrato CurveFrames.md; timelines/playback continuam ausentes.


## Oito serializers especializados

ZOrder reserva frame antes de ler raw, usa arrays temporários com length lógico validado (inclusive RangeError para quantidade ímpar/excessiva), insere índices e preenche do fim para o começo com fallback ||0. Offsets numéricos, null/undefined e algumas strings seguem os casos comparados; não afirma +/ToPrimitive genérico para objetos/proxies. Índices de slots impossíveis podem causar while não terminante no original e não receberam correção ou limite inventado no produto.

BoneAll/Rotate compartilham helper local para a mesma expressão de rotação original, sem simplificar prev+rotation−prev. Mantêm atualização parcial de _prevClockwise e _prevRotation antes do tween; BoneAll reinicia helpTransform e parseia transform legado/atual antes desse passo. Translate/Scale/Rotate/IK reservam comprimento completo antes de ler os valores. SlotDisplay dá precedência à presença de value, inclusive null/undefined, e parseia ações com slot.parent somente após guardar o índice. BoneAll guarda seis floats antes das ações; falha em ação não apaga valores.

SlotColor adapta for-in apenas ao domínio JSON-like: null/undefined/primitivos sem propriedades/objeto vazio/array com apenas holes usam default; string não vazia tem chave enumerável e falha no parser de cor com o mesmo estado anterior. Qualquer propriedade própria em objeto/array dispara registro explícito mesmo que seja desconhecida. Não emula protótipos/descritores/proxies JS genéricos. _defaultColorOffset é atribuído antes de reservar a cor default, inclusive overflow; offset é escrito em frameInt só depois. _modifyArray redefine cache, _parseArray não o redefine. Sem deduplicação nova de cores explícitas.

Infinitos em rotações geram NaN aritmético com sinal/payload dependentes do host. SharedBinaryBuffer continua canonicalizando NaNs numéricos; não foi prometida igualdade desses bits arbitrários. A suíte specialframes normaliza somente essas células Float32 num snapshot separado de observação, em ambos os lados, sem tocar memória/views de produto. Todas as outras células/bytes, valores finitos/infinitos e zero assinado continuam exatos, com tolerância zero. Curvas/frames anteriores e seus critérios permanecem intactos. Ver SpecializedFrames.md.


## Frames de deformação

Os dois serializers reservam após tween, preservando holes e usando length lógico; não reaproveitar appendZeros do backup. Componentes fora do intervalo viram zero; posições dentro do intervalo mantêm hole/undefined/null até a coerção tipada. VERTICES presente null significa preencher zero; undefined pode lançar ao ler length, exceto curto-circuito por offset. Slot ignora VALUE; genérico usa VALUE só se VERTICES não estiver presente. Raw JSON-like e controles/offsets/contexto conforme TS; não afirma reflexão/coerções genéricas fora desse domínio.

Slot ponderado copia pose do slot antes de reservar weight.count*2, percorre o cabeçalho de pesos indireto e transforma deltas com delta=true, sem translação de pose, depois inversa da pose do bone. Loop segue vertexCount, e cada vertexBoneCount pode escrever além da reserva inicial se os dados forem inconsistentes; preservar crescimento/holes originais. Não multiplicar por coeficientes weight aqui: o serializer upstream não o faz. Matrizes reais e ponte base 0→Lua base 1 já auditada; poses incompletas propagam undefined/NaN, ausentes podem lançar antes da reserva ou depois de valores anteriores.

Genérico ponderado contém TODO literal e não acrescenta floats; ainda pode escrever header de contagem zero no primeiro frame. Não inventar deformação com pesos nesse ramo para aparentar completude. Header reserva cinco ints e escreve geometryOffset/count/valueCount/valueOffset antes de acessar animation.frameFloatOffset; timeline é acessada só depois do último int. Falhas preservam cada etapa. Atualiza TimelineFrameValueCount com offset relativo do header, sem parsear timeline ou gerar frameIndices. Contrato DeformFrames.md. NaN/payloads e demais limites anteriores mantidos.


## Parsing de timelines

_parseTimeline usa arrays raw conforme TS (arrays JSON-like marcados ou _actionFrames interno), nil/V.NULL como null e V.UNDEFINED distinto. Domínio não inclui length com coerções arbitrárias/proxies/reflexão JS genérica; não equivale a todos os objetos array-like inválidos. Callback Lua recebe self explicitamente, traduzindo frameParser.call(this,...); callbacks de produto são os serializers originais já portados. TimelineData existente conserva identidade; sem frames/null retorna antes de modificar timeline/contexto.

Reserva cinco campos mais keyFrameCount sem preencher holes, define escala/offset arredondados e offsets relativos de Int/Float/Step. Um frame recebe start/count 0 e frameIndicesOffset=-1; vários reservam animation.frameCount+1 índices e chamam no máximo um frame por posição, mantendo durações zero/negativas/fracionárias e frames ainda não alcançados. Offsets retornados pelo callback são relativos a animation.frameOffset. Em falha não limpar _timeline, reservas ou índices parcialmente escritos. Finalização bem-sucedida apenas solta _timeline.

ActionFrame é reconhecido pela classe/cadeia Lua, sem tratá-lo como BaseObject; a duração não final vem de _actionFrames[iK+1] original, não do array de frames fornecido. Bone mantém ordem translate/rotate/scale/all, defaults/escala e registro imediato por ramo. Slot prioriza propriedades displayFrame/colorFrame por presença, fallback frame; só registra display e cor após ambos os parses. Falha no segundo deixa o primeiro TimelineData órfão, sem inserir mapa novo. Contexto bone/slot retido em falhas e limpo no sucesso, sem finally/rollback inventado. Contrato Timelines.md; playback/animação completos continuam pendentes.


## Orquestração de _parseAnimation

Metadados e duração são atribuídos na ordem original, inclusive divisão por frameRate zero/negativo/infinito. Captura offsets dos três arrays antes de qualquer frame e só então define _animation. Frames de ações iniciais usam comprimento capturado; demais for-of seguem emit TS2.4/ES5 com length vivo via JSValue.iterator. Não substituir por ipairs que encerra em holes. Arrays/objetos raw seguem domínio JSON-like e tipos de modelo, sem getters/reflexão/protótipos genéricos.

Mantida ordem frame actions→zOrder→bone→slot→FFD→IK→actionTimeline/clear de actionFrames→timeline genérica. FFD inválido pode deixar _slot ou _mesh retido pelo continue original; sucesso limpa ambos. TODOs de Action/ZOrder genéricos não geram timeline. SlotDisplay genérico usa single-value Step (TODO original), não SlotDisplayFrame com ações. BoneRotate genérico usa Double x/y ×DEG_RAD, enquanto legado usa rotate/skew/voltas; IK genérico usa Double x/y ×100, legado usa bendPositive/weight. Não harmonizar os formatos inventando equivalência nova.

Blend AnimationProgress aloca AnimationTimelineData antes de ler x/y e de parsear frames; erro parcial ou frames vazios deixam objeto órfão, sem returnToPool extra. Busca SlotDeform usa JSMap.keys em skins/displays, não pairs do backup; só quebra o loop de displays, continuando slots/skins e mantendo o último match. SkinData.NULL é null; undefined presente pode falhar em display.name. Geometry ausente continua undefined, não é convertida para null no produto. Surface bone não é validado como classe adicional pelo upstream.

_animation só é limpa no sucesso. Maps de timelines, ações já consumidas, reservas/caches/contexto e objetos alocados permanecem após erros; nova animação continua dos arrays/caches existentes, sem reset inventado. O método retorna AnimationData sem registrá-lo na armadura (responsabilidade do futuro _parseArmature). Contrato AnimationParser.md. Demais limites/NaN normalizado só no snapshot e TODO ponderado do deform genérico permanecem.


## Orquestração de _parseArmature

CanvasData é dependência real. Metadados antecedem _armature; canvas é alocado antes de consultar cor/campos, mas só atribuído após todos os valores; erro pode deixá-lo órfão. Aabb é alterado progressivamente. FrameRate zero vira 24, demais valores mantidos. Scale segue parâmetro numérico TS, sem default novo.

Bone parents posteriores usam JSMap de arrays JSArray, resolvidos antes de addBone/rawBones.push. Mantida ordem de _rawBones e duplicatas/órfãos; sortBones após IK, antes de slots/skins/path. Parent ausente continua nil após sort e cache é limpo só no sucesso. Ciclos/parents patológicos podem não terminar no sort original; não há reparo inventado. Slots recebem zOrder sequencial, sem sort adicional por zIndex.

Meshes compartilhados são ligados depois de skins/path e antes de animações, usando comprimento capturado de _cacheRawMeshes e índices paralelos. Slot vazio literal no getMesh é TODO upstream: compartilhar só funciona quando a busca nesse slot encontra o display; não procurar automaticamente em todos os slots. GeometryData.shareFrom real preserva ownership/peso/offset e flag de compartilhamento. Animações são criadas e registradas antes de ações padrão; cada Play válido pode substituir defaultAnimation, prevalecendo o último.

Só sucesso limpa lengths rawBones/cacheMeshes/cacheRawMeshes, solta _armature e remove membros de quatro mapas sem trocar identidades; exceção conserva tudo que já ocorreu. Nova chamada pode usar contexto/caches deixados pelo erro, como no original. Métodos de arrays traduzem ES5 indexed/live length; mapas usam JSMap.remove/keys, não pairs/# do backup. Não chama _parseArray, _modifyArray ou data.addArmature automaticamente. Contrato ArmatureParser.md; entrada global/runtime permanecem pendentes.


## parseDragonBonesData e domínio da entrada pública

A API recebe objeto JSON-like já decodificado (arrays JSValue marcados e null/undefined distintos), não texto ou arquivo JSON. Scale opcional segue número TS; omitido/V.UNDEFINED usa 1. Console.assert do original produz diagnóstico sem interromper, com prefixo de observação Node; leituras posteriores de raw null/undefined ainda lançam. Versão primária ou compatível aceita; data.version conserva a primária. Versão não suportada retorna nil, sem alocar nem alterar caches/fila. Não usar assert Lua que interrompe antes dessas leituras.

Somente presença de ARMATURE entra no ramo _data/parseArray/armaduras/finalização/stage. Lista vazia cria Buffer/views vazios, ausência deixa binary nil e não limpa contexto anterior. _parseArray real só limpa sete arrays de trabalho; outros caches persistem. Testa self._data.binary por truthiness antes de _modifyArray, permitindo override futuro de parser binário sem sobrescrever memória pré-carregada. Stage presente busca nome convertido e pode ficar nil sem fallback; ausente usa primeiro armatureNames, inclusive em duplicatas rejeitadas pelo modelo.

Atlas só atribuído após sucesso anterior, sem redefinir _rawTextureAtlasIndex; queue null vira nil de referência interna, undefined conserva marcador para falha original ao ler length. Sucesso sem ARMATURE não limpa _data anterior de erro; unsupported/falha não substituem a fila. Erros deixam objetos órfãos/ownership/buffers/contexto conforme estágio alcançado. Retornar DragonBonesData ao pool solta referências sem destruir aliases de buffer já demonstrados.

47/47 é contagem dos corpos deste arquivo, não todos os comportamentos JS/plataformas. TODOs upstream, coerções/protótipos/reflexão genéricos, controles fora do TS, NaN payload/Big Endian, locales especiais e runtime/backends seguem limitados. BinaryDataParser ainda exige bytes/UTF-8/JSON interno; não confundir com a entrada de objetos. Contrato GlobalObjectEntry.md.

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

Regressão de arredondamento: preservado o agrupamento TS pivot*(width*scale) e pivot*(height*scale), em vez de (pivot*width)*scale do backup Lua. O caso fractionalPivot com pivot.x=0,1, width=33,3, atlas.scale=0,1 e armature.scale=0,3 revelou divergência de 1 ULP antes da correção e é comparado sem tolerância. Esse caso foi acrescentado antes de integrar esta unidade.
