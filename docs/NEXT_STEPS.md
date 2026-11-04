# Continuidade — Bono-Lua

## Objetivo permanente

Reconstruir em Lua DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e preservando arquitetura, algoritmos e comportamentos. Destino SrTristeSad/Bono-Lua. Não declarar motor completo com pendências.

## Base desta unidade

main 54c0c2ab3c1cadd061aeddaf7a559214dfbf81da, PR #97, CI após merge 41847955883 aprovada. Backup backup/pre-integral-rebuild-20261103 em cd4206a8ac091b1b26ad02b9ee4bc6ec7f30eeeb. Branch port/bone-runtime; consultar PR para SHA/merge/evidência final. Autorização do proprietário mantém main acompanhando checkpoints testados.

## Unidade implementada

Bone regular e Armature parcial real de registro/ciclo de vida implementados. 1.576 cenários/44.128 colunas por VM, seis falhas esperadas e 340 aproximações trig no limite documentado; índices/flags/zeros/offsets exatos. Contrato contracts/BoneRuntime.md. CI com 35 suítes e três exemplos por VM. Comando bones demonstra hierarquia real, com montagem manual de _armatureData e sem init/player/factory fictício.

Preservar lookup e registro em Bone.init, cache nos modelos reais, dirty/localDirty/childrenDirty, referência origin, matriz/decomposição adiada e +0/-0. Armature.init/advanceTime e métodos não portados continuam ausentes. Ramas Surface/Constraint/Slot runtime e cleanup de Animation/Proxy/clock não vazios não estão validadas nesta unidade. Não declarar Bone/Armature completos só por corpos presentes.

## Próximo recorte

1. Conferir main/backup/PR/CI, progresso, diferenças e contratos.
2. Auditar Surface e dependências de geometria/constraints/Slot e do coordenador de animação, escolhendo o próximo recorte com objetos reais. Bone já foi auditado integralmente, mas seu ramo Surface continua sem prova.
3. Ampliar Armature apenas quando as dependências forem reais; não improvisar Animation/slots/solvers para ativar init/advanceTime. Manter o exemplo bones e deixar a montagem manual explícita.
4. Atualizar inventário/docs, PR/CI e integrar checkpoint autorizado. Runtime/factories/backends permanecem etapas próprias.

## Pendências

Exportações externas ao pin e leitura externa; JSON sem promessa de profundidade ilimitada/locale alternativo; TODOs upstream, locales especiais, coerções/reflexão/proxies genéricos, contextos fora do domínio TS, Big Endian e payloads NaN arbitrários. Runtime Armature/Bone/Slot/Surface, solvers IK/Path, deformações, avaliação/playback/blending, factories, backend LÖVE/GPU e contratos de engines. WorldClock continua os.time com resolução de segundos; não relaxar tolerâncias anteriores.

## Reprodução

```sh
npm ci --ignore-scripts --no-audit --no-fund
node tools/inventory.js ../DragonBonesJS --check
node tools/dependencies.js ../DragonBonesJS --check
for vm in lua5.4 luajit; do
  for suite in geom math baseobject models worldclock events config animationdata displaydata armaturedata constraintdata skindata dragonbonesdata boundingbox dataparser objectatlas structural geometryparser binaryarrays curveframes specialframes deformframes timelines animationparser armatureparser globalentry binaryutf8 binarytimeline binaryanimation binarygeometry binaryviews dbdt corpus transformobject bone; do
    node tests/${suite}_differential.js ../DragonBonesJS "$vm"
  done
done
```

Consultar PR para evidência remota/SHA/merge/CI; não antecipar resultados futuros.
