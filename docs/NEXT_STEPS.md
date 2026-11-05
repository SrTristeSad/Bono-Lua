# Continuidade — Bono-Lua

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

Diferencial: 747 cenários/549.045 colunas por VM Lua 5.4/LuaJIT, 24 erros readonly esperados e 1.494 leituras pós-limpeza que falham como no original, zero aproximações. `lua5.4 examples/run.lua animationcontrol` importa JSON e controla tempo/peso/parâmetros de um estado filho real. CI agora contém 49 suítes e dezessete exemplos por VM. Etapa seguinte foi concluída acima com getBlendState original; resta o facade público de Animation, depois Armature/factories/backends.


## Timeline de ações e eventos

Portada ActionTimelineState com eventos e filas reais do core; Armature.eventDispatcher retorna o proxy somente leitura. Diferencial: 585 cenários/242.190 colunas/20 erros esperados por VM Lua 5.4/LuaJIT, zero aproximações. Corrigida preservação de -0 em currentPlayTimes; regressão basetimeline também passou nas duas VMs. Ver [ActionTimeline.md](contracts/ActionTimeline.md).

`lua5.4 examples/run.lua actiontimeline` importa JSON, despacha eventos de frame/som/ciclo e mostra ações Play pendentes. Backend é um observador explícito; execução das ações depende do player ainda pendente. TimelineState.ts tem 13/16 classes portadas. CI passa a 48 suítes e dezesseis exemplos por VM. As três timelines de controle já estão portadas; completar controlador e integração de Armature/factories/renderização.


## Timelines de IK e ordem dos slots

Portadas IKConstraintTimelineState e ZOrderTimelineState, com Armature._sortZOrder real. Diferencial: 596 cenários/215.156 colunas/164 erros esperados por VM Lua 5.4/LuaJIT, zero aproximações. Contrato em [ConstraintOrderTimelines.md](contracts/ConstraintOrderTimelines.md). TimelineState.ts agora tem 12/16 classes portadas.

`lua5.4 examples/run.lua constraintorder` importa JSON, muda peso/dobra de IK e ranks dos slots, e executa Bone.update/solver reais. Montagem e tempos manuais; AnimationState/Animation/player e renderer continuam pendentes. CI agora contém 47 suítes e quinze exemplos por VM. ActionTimelineState já está portada; restam três timelines de controle de animação e integração completa do controlador.


## Timelines de deformação — Surface e malhas

Portadas SurfaceTimelineState e DeformTimelineState, com buffers/Surface/Slot/DisplayFrame/BlendState reais. Diferencial: 1.554 cenários, 1.048.950 colunas e 26 erros esperados por VM Lua 5.4/LuaJIT, sem aproximações numéricas. Ver [DeformationTimelines.md](contracts/DeformationTimelines.md). TimelineState.ts agora tem 10/16 classes portadas.

`lua5.4 examples/run.lua deformationtimeline` importa JSON, interpola a Surface em 0/40/80/40 e a malha em 0/10/20/10. Montagem e tempos manuais; AnimationState/Animation/player e renderer continuam pendentes. CI passa a 46 suítes e catorze exemplos por VM. IK/ZOrder já portados; seguir com ações/eventos e parâmetros de animação, depois integrar o controlador.


## Timelines de slots — display, cor, alpha e profundidade

Portadas Alpha/SlotDisplay/SlotColor/SlotZIndexTimelineState, com Slot/Bone e BlendState reais. Diferencial: 992 cenários, 639.840 colunas por VM Lua 5.4/LuaJIT, sem erros nem aproximações numéricas. Contrato em [SlotTimelines.md](contracts/SlotTimelines.md). TimelineState.ts agora tem 8/16 classes portadas.

`lua5.4 examples/run.lua slottimeline` importa JSON e altera display/cor/alpha/z do slot. Montagem e tempo manuais; AnimationState/Animation, ordenação/propagação completas de Armature e renderer continuam pendentes. CI agora executa 45 suítes e treze exemplos por VM. Surface/deformação já portadas; seguir com constraints/eventos e timelines de animação dependentes do controlador.


## Timelines de bones — aplicação à pose

Portados BlendState e BoneAll/BoneTranslate/BoneRotate/BoneScaleTimelineState, com aplicação à animationPose do Bone real e mistura de pesos/camadas. Diferencial: 1.828 cenários por VM; ver [BoneTimelines.md](contracts/BoneTimelines.md). TimelineState.ts e AnimationState.ts continuam parciais.

`lua5.4 examples/run.lua bonetimeline` aplica keyframes importados à pose e à matriz mundial do bone, imprimindo 0/20/40/20. Montagem/tempo manuais, ainda sem AnimationState/Animation/player ou renderer. CI passa a 44 suítes e doze exemplos por VM. Timelines de slots já portadas; seguir com Surface/deformação, constraints/eventos e integração do controlador.


Objetivo: reconstruir em Lua DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e preservando arquitetura, algoritmos e comportamentos. Repositório SrTristeSad/Bono-Lua. Sem dependências/player/renderer fictícios. Autorização do proprietário mantém main acompanhando checkpoints testados.

Base deste checkpoint: main 6b63c94fb90ebebf9d8fac75c751bd9cf7390fb1, PR #111; CI pós-merge 41950757340 aprovada (49 suítes/dezessete exemplos por VM). Branch port/state-init-fade; consultar novo PR para SHA/CI/merge final. Backup backup/pre-integral-rebuild-20261103 permanece cd4206a8ac091b1b26ad02b9ee4bc6ec7f30eeeb.

## Bases de timeline — tempo e interpolação

Portadas as cinco classes de BaseTimelineState.ts em módulo próprio: avanço temporal, seleção de keyframes, easing e interpolação de um/dois/vários valores. Diferencial com o pin: 2.700 cenários, 1.052.450 colunas e 25 erros esperados por VM, sem aproximações. Contrato e limites em [BaseTimelineState.md](contracts/BaseTimelineState.md).

`lua5.4 examples/run.lua timeline` (ou luajit) importa keyframes JSON e imprime 0/20/40/20 em quatro tempos. Os dados/parser/buffers são reais; AnimationState é explicitamente um contrato de campos nos testes/exemplo, ainda sem player ou renderer. CI agora executa 43 suítes e onze exemplos por VM. BlendState e as quatro timelines de bones estão portados; seguir com as demais timelines e depois AnimationState/Animation.

Preservar BaseTimelineState: campos e buffers não são resetados por init repetido, _rd mantém identidade, blend vazio é source, callbacks puramente abstratos continuam ausentes. Duração/FPS/escala temporal zero e buffers arbitrariamente truncados não estão validados. Não usar o registro AnimationState de teste como produto.

Runtime já inclui Bone/Surface/Slot, base Constraint, IK e Path nos contratos documentados. Path preserva buffers parciais/TODOs e invalidUpdate vazio; IK preserva TODO de escala. Armature continua parcial: init/advanceTime dependem do player/proxy reais. Montagem dos exemplos é manual. Permanecem métodos de AnimationState/Animation, Armature completa, factories, backends e auditoria final. BlendState e corpos das 16 timelines já portados.

Preservar os contratos anteriores de números/zeros/ownership/cache. Liberar runtime antes dos modelos. Não avançar WorldClock contendo Armature incompleta; remover root antes de drenar descartes. Não ampliar budgets de outras suítes para acomodar mudanças novas.

## Reprodução

```sh
npm ci --ignore-scripts --no-audit --no-fund
node tools/inventory.js ../DragonBonesJS --check
node tools/dependencies.js ../DragonBonesJS --check
for vm in lua5.4 luajit; do
  node tests/basetimeline_differential.js ../DragonBonesJS "$vm"
  "$vm" examples/run.lua timeline
done
```

A workflow inventory.yml contém a bateria integral. Consultar PR para evidência remota; não antecipar resultados futuros.
