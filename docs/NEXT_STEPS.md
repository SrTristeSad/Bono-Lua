# Continuidade — Bono-Lua

## Timelines de slots — display, cor, alpha e profundidade

Portadas Alpha/SlotDisplay/SlotColor/SlotZIndexTimelineState, com Slot/Bone e BlendState reais. Diferencial: 992 cenários, 639.840 colunas por VM Lua 5.4/LuaJIT, sem erros nem aproximações numéricas. Contrato em [SlotTimelines.md](contracts/SlotTimelines.md). TimelineState.ts agora tem 8/16 classes portadas.

`lua5.4 examples/run.lua slottimeline` importa JSON e altera display/cor/alpha/z do slot. Montagem e tempo manuais; AnimationState/Animation, ordenação/propagação completas de Armature e renderer continuam pendentes. CI agora executa 45 suítes e treze exemplos por VM. Próximo recorte: Surface/deformação, constraints/eventos e timelines de animação dependentes do controlador.


## Timelines de bones — aplicação à pose

Portados BlendState e BoneAll/BoneTranslate/BoneRotate/BoneScaleTimelineState, com aplicação à animationPose do Bone real e mistura de pesos/camadas. Diferencial: 1.828 cenários por VM; ver [BoneTimelines.md](contracts/BoneTimelines.md). TimelineState.ts e AnimationState.ts continuam parciais.

`lua5.4 examples/run.lua bonetimeline` aplica keyframes importados à pose e à matriz mundial do bone, imprimindo 0/20/40/20. Montagem/tempo manuais, ainda sem AnimationState/Animation/player ou renderer. CI passa a 44 suítes e doze exemplos por VM. Timelines de slots já portadas; seguir com Surface/deformação, constraints/eventos e integração do controlador.


Objetivo: reconstruir em Lua DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e preservando arquitetura, algoritmos e comportamentos. Repositório SrTristeSad/Bono-Lua. Sem dependências/player/renderer fictícios. Autorização do proprietário mantém main acompanhando checkpoints testados.

Base deste checkpoint: main ed3dbfcf3aa9c465140772c1658269f3a53732c5, PR #106; CI pós-merge 41926717311 aprovada (44 suítes/doze exemplos por VM). Branch port/slot-timelines; consultar novo PR para SHA/CI/merge final. Backup backup/pre-integral-rebuild-20261103 permanece cd4206a8ac091b1b26ad02b9ee4bc6ec7f30eeeb.

## Bases de timeline — tempo e interpolação

Portadas as cinco classes de BaseTimelineState.ts em módulo próprio: avanço temporal, seleção de keyframes, easing e interpolação de um/dois/vários valores. Diferencial com o pin: 2.700 cenários, 1.052.450 colunas e 25 erros esperados por VM, sem aproximações. Contrato e limites em [BaseTimelineState.md](contracts/BaseTimelineState.md).

`lua5.4 examples/run.lua timeline` (ou luajit) importa keyframes JSON e imprime 0/20/40/20 em quatro tempos. Os dados/parser/buffers são reais; AnimationState é explicitamente um contrato de campos nos testes/exemplo, ainda sem player ou renderer. CI agora executa 43 suítes e onze exemplos por VM. BlendState e as quatro timelines de bones estão portados; seguir com as demais timelines e depois AnimationState/Animation.

Preservar BaseTimelineState: campos e buffers não são resetados por init repetido, _rd mantém identidade, blend vazio é source, callbacks puramente abstratos continuam ausentes. Duração/FPS/escala temporal zero e buffers arbitrariamente truncados não estão validados. Não usar o registro AnimationState de teste como produto.

Runtime já inclui Bone/Surface/Slot, base Constraint, IK e Path nos contratos documentados. Path preserva buffers parciais/TODOs e invalidUpdate vazio; IK preserva TODO de escala. Armature continua parcial: init/advanceTime dependem do player/proxy reais. Montagem dos exemplos é manual. Permanecem timelines concretas, BlendState, AnimationState/Animation, Armature completa, factories, backends e auditoria final.

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
