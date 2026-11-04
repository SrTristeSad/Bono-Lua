# Continuidade — Bono-Lua

DisplayFrame e Slot parcial publicados no PR #100, branch port/display-frame, ainda sem merge enquanto CI estiver na fila. Slot: 1.448 cenários/56.472 colunas/120 falhas esperadas/30 aproximações por VM. CI configurada para 38 suítes/seis exemplos. Não afirmar main atualizada sem confirmar aprovação e merge.

## Objetivo permanente

Reconstruir em Lua DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e preservando arquitetura, algoritmos e comportamentos. Destino SrTristeSad/Bono-Lua. Não declarar motor completo com pendências.

## Base desta unidade

main 265304b316a2987df5e57bd9078a27049f883ae6, PR #99, CI após merge 41860056636 aprovada. Backup backup/pre-integral-rebuild-20261103 em cd4206a8ac091b1b26ad02b9ee4bc6ec7f30eeeb. Branch port/display-frame; consultar PR para SHA/merge/evidência final. Autorização do proprietário mantém main acompanhando checkpoints testados.

## Unidade implementada

DisplayFrame completa e fundação parcial de Slot: init/registro/getters, frames/visibilidade/alpha/flags, matriz e hit testing com Bone/Armature reais. Slot: 1.448 cenários/56.472 colunas/120 falhas esperadas/30 aproximações por VM, contrato contracts/SlotFoundation.md. Regressão local: 38 suítes/seis exemplos nas duas VMs. Exemplo slot: posição (45,20)→(55,20), com caixa real e observador local dos hooks abstratos.

Surface/Bone/TransformObject e parsers continuam como base validada nos contratos anteriores. Preservar budgets próprios de Surface (32 eps) e Bone/TransformObject (8 eps); o budget de Slot só cobre pose/outputs matemáticos não nulos até 8 eps, não matrizes/flags/zeros. _matrixCahce, hull inicial 10→12, TODOs e demais diferenças upstream continuam intactos. Armature ainda exige montagem explícita de _armatureData, sem init/player/factory fictício.

## Próximo recorte

1. Conferir main/backup/PR/CI, progresso, diferenças e contratos.
2. Continuar Slot em _updateDisplayData e APIs de substituição com modelos reais; preservar hooks abstratos. Auditar fonte completa dos corpos antes de portar.
3. Validar pai Surface, polígono/aliases no hit testing e lifecycle child Armature quando dependências reais estiverem prontas. Manter montagem manual explícita até init/factory completos.
4. Atualizar inventário/docs, PR/CI e integrar checkpoint autorizado. Runtime/factories/backends permanecem etapas próprias.

## Pendências

Exportações externas ao pin e leitura externa; JSON sem promessa de profundidade ilimitada/locale alternativo; TODOs upstream, locales especiais, coerções/reflexão/proxies genéricos, contextos fora do domínio TS, Big Endian e payloads NaN arbitrários. Runtime Armature/Bone/Slot/Surface, solvers IK/Path, deformações, avaliação/playback/blending, factories, backend LÖVE/GPU e contratos de engines. WorldClock continua os.time com resolução de segundos; não relaxar tolerâncias anteriores.

## Reprodução

```sh
npm ci --ignore-scripts --no-audit --no-fund
node tools/inventory.js ../DragonBonesJS --check
node tools/dependencies.js ../DragonBonesJS --check
for vm in lua5.4 luajit; do
  for suite in geom math baseobject models worldclock events config animationdata displaydata armaturedata constraintdata skindata dragonbonesdata boundingbox dataparser objectatlas structural geometryparser binaryarrays curveframes specialframes deformframes timelines animationparser armatureparser globalentry binaryutf8 binarytimeline binaryanimation binarygeometry binaryviews dbdt corpus transformobject bone surface displayframe slot; do
    node tests/${suite}_differential.js ../DragonBonesJS "$vm"
  done
done
```

Consultar PR para evidência remota/SHA/merge/CI; não antecipar resultados futuros.
