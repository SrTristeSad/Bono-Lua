# Continuidade — Bono-Lua

## Objetivo permanente

Reconstruir em Lua DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e preservando arquitetura, algoritmos e comportamentos. Destino SrTristeSad/Bono-Lua. Não declarar motor completo com pendências.

## Base desta unidade

main 783edc7764c246f7daa50a0aad39fc051a43f38e, PR #93, CI após merge 41785404656 aprovada. Backup backup/pre-integral-rebuild-20261103 em cd4206a8ac091b1b26ad02b9ee4bc6ec7f30eeeb. Branch port/binary-array-views; consultar PR para SHA/merge/evidência final. Autorização do proprietário mantém main acompanhando checkpoints testados.

## Unidade implementada

BinaryDataParser agora 7/8 métodos: helpers, singleton, timeline, animação, geometria e arrays binários. ObjectDataParser permanece 47/47 nos domínios documentados. Novo teste: 189 cenários/3.402 colunas por VM, 69 exceções esperadas, tolerância zero. Contrato contracts/BinaryViews.md. CI com 31 suítes por VM.

Preservar Buffer por referência, alias exato de cores ausentes, conversão ToIndex de offset e contagem, +0 em LuaJIT, alinhamento e atribuições privadas antes dos setters públicos. Todas as views são construídas antes de publicar. Limites anteriores de mapas JSMap/listas JSValue.array/offsets e TODOs permanecem.

## Próximo recorte

1. Conferir main/backup/PR/CI, progresso, diferenças e contratos.
2. Portar entrada parseDragonBonesData binária: Uint8/tag, Uint32 headerLength, decoder custom, JSON interno preservando NULL/UNDEFINED/ordem/listas e chamada ao parser base real.
3. Validar DBDT inteiro e malformado com modelos/views/ownership reais; auditar dependência JSON antes de escolher adaptação.
4. Atualizar inventário/docs, PR/CI e integrar checkpoint autorizado. Runtime/factories/backends permanecem etapas próprias.

## Pendências

Entrada binária restante e DBDT/JSON interno/leitura externa; TODOs upstream, locales especiais, coerções/reflexão/proxies genéricos, contextos fora do domínio TS, Big Endian e payloads NaN arbitrários. Runtime Armature/Bone/Slot/Surface, solvers IK/Path, deformações, avaliação/playback/blending, factories, backend LÖVE/GPU e contratos de engines. WorldClock continua os.time com resolução de segundos; não relaxar tolerâncias anteriores.

## Reprodução

```sh
npm ci --ignore-scripts --no-audit --no-fund
node tools/inventory.js ../DragonBonesJS --check
node tools/dependencies.js ../DragonBonesJS --check
for vm in lua5.4 luajit; do
  for suite in geom math baseobject models worldclock events config animationdata displaydata armaturedata constraintdata skindata dragonbonesdata boundingbox dataparser objectatlas structural geometryparser binaryarrays curveframes specialframes deformframes timelines animationparser armatureparser globalentry binaryutf8 binarytimeline binaryanimation binarygeometry binaryviews; do
    node tests/${suite}_differential.js ../DragonBonesJS "$vm"
  done
done
```

Consultar PR para evidência remota/SHA/merge/CI; não antecipar resultados futuros.
