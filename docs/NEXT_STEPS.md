# Continuidade — Bono-Lua

Objetivo: reconstruir em Lua DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e preservando arquitetura, algoritmos e comportamentos. Repositório SrTristeSad/Bono-Lua. Sem dependências/player/renderer fictícios. Autorização do proprietário mantém main acompanhando checkpoints testados.

Base deste checkpoint: main 1a1128a74af09174108ca3a26fdc819443cc87e7, PR #104; CI pós-merge 41899598070 aprovada (42 suítes/dez exemplos por VM). Branch port/base-timeline-state; consultar novo PR para SHA/CI/merge final. Backup backup/pre-integral-rebuild-20261103 permanece cd4206a8ac091b1b26ad02b9ee4bc6ec7f30eeeb.

## Bases de timeline — tempo e interpolação

Portadas as cinco classes de BaseTimelineState.ts em módulo próprio: avanço temporal, seleção de keyframes, easing e interpolação de um/dois/vários valores. Diferencial com o pin: 2.700 cenários, 1.052.450 colunas e 25 erros esperados por VM, sem aproximações. Contrato e limites em [BaseTimelineState.md](contracts/BaseTimelineState.md).

`lua5.4 examples/run.lua timeline` (ou luajit) importa keyframes JSON e imprime 0/20/40/20 em quatro tempos. Os dados/parser/buffers são reais; AnimationState é explicitamente um contrato de campos nos testes/exemplo, ainda sem player ou renderer. CI agora executa 43 suítes e onze exemplos por VM. Próximo recorte: timelines concretas/BlendState, depois AnimationState/Animation.

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
