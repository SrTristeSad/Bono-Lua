# Continuidade — Bono-Lua

## Objetivo permanente

Reconstruir em Lua DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e preservando arquitetura, algoritmos e comportamentos. Destino SrTristeSad/Bono-Lua. Não declarar motor completo com pendências.

## Base desta unidade

main 1fb162edc71ef42452a277b6d1c05a0f231df0d4, PR #92, CI após merge 41784255228 aprovada. Backup backup/pre-integral-rebuild-20261103 em cd4206a8ac091b1b26ad02b9ee4bc6ec7f30eeeb. Branch port/binary-geometry; consultar PR para SHA/merge/evidência final. Autorização do proprietário mantém main acompanhando checkpoints testados.

## Unidade implementada

BinaryDataParser agora 6/8 métodos: helpers, singleton, timeline, animação e geometria binárias. ObjectDataParser permanece 47/47 nos domínios documentados. Novo teste: 238 cenários/4.284 colunas por VM, três exceções esperadas, tolerância zero. Contrato contracts/BinaryGeometry.md. CI com 30 suítes por VM.

Preservar peso -1, correção +65536 apenas abaixo de -1, duplicatas/undefined em bones, contagens e publicação tardia de geometry.weight. Reparse não limpa peso anterior; falhas mantêm alocações parciais. Limpeza/compartilhamento usam GeometryData real. Limites anteriores de grupos JSMap, listas JSValue.array, offsets numéricos e TODOs/órfãos permanecem.

## Próximo recorte

1. Conferir main/backup/PR/CI, progresso, diferenças e contratos.
2. Portar _parseArray binário: segmentos, limites/alinhamento, aliases, cores opcionais e publicação em ordem. Usar SharedBinaryBuffer real, sem cópia do buffer.
3. Depois fechar entrada DBDT com Uint32/header length/JSON interno e decoder custom original.
4. Atualizar inventário/docs, PR/CI e integrar checkpoint autorizado. Runtime/factories/backends permanecem etapas próprias.

## Pendências

Dois métodos binários restantes e DBDT/JSON interno/leitura externa; TODOs upstream, locales especiais, coerções/reflexão/proxies genéricos, contextos fora do domínio TS, Big Endian e payloads NaN arbitrários. Runtime Armature/Bone/Slot/Surface, solvers IK/Path, deformações, avaliação/playback/blending, factories, backend LÖVE/GPU e contratos de engines. WorldClock continua os.time com resolução de segundos; não relaxar tolerâncias anteriores.

## Reprodução

```sh
npm ci --ignore-scripts --no-audit --no-fund
node tools/inventory.js ../DragonBonesJS --check
node tools/dependencies.js ../DragonBonesJS --check
for vm in lua5.4 luajit; do
  for suite in geom math baseobject models worldclock events config animationdata displaydata armaturedata constraintdata skindata dragonbonesdata boundingbox dataparser objectatlas structural geometryparser binaryarrays curveframes specialframes deformframes timelines animationparser armatureparser globalentry binaryutf8 binarytimeline binaryanimation binarygeometry; do
    node tests/${suite}_differential.js ../DragonBonesJS "$vm"
  done
done
```

Consultar PR para evidência remota/SHA/merge/CI; não antecipar resultados futuros.
