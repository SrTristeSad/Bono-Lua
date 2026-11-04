# Continuidade — Bono-Lua

## Objetivo permanente

Reconstruir em Lua DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e preservando arquitetura, algoritmos e comportamentos. Destino SrTristeSad/Bono-Lua. Não declarar motor completo com pendências.

## Base desta unidade

main 235edef2811f3ec26227b21acd44bff876019cfd, PR #90, CI após merge 41774942858 aprovada. Backup backup/pre-integral-rebuild-20261103 em cd4206a8ac091b1b26ad02b9ee4bc6ec7f30eeeb. Branch port/binary-timelines; consultar PR para SHA/merge/evidência final. Autorização do proprietário mantém main acompanhando checkpoints testados.

## Unidade implementada

BinaryDataParser agora 4/8 métodos: helpers, singleton e _parseBinaryTimeline. ObjectDataParser permanece 47/47 corpos nos domínios documentados. Comparação nova: 439 cenários/448 chamadas/6.585 colunas por VM Lua 5.4/LuaJIT, 12 exceções esperadas, tolerância zero, modelos/pool/views reais. Contrato contracts/BinaryTimeline.md. CI com 28 suítes por VM.

Preservar length/holes de frameIndices, prefixo existente, frame final extra, offsets em elementos base 0, undefined numérico como NaN, reserva antes de frameIndicesOffset e contexto retido em falhas. Sucesso limpa _timeline; keyframe única dispensa contexto de dados/animação. Não confundir herança de entrada ObjectDataParser com suporte DBDT.

## Próximo recorte

1. Conferir main/backup/PR/CI, progresso, diferenças e contratos.
2. Portar o override binário _parseAnimation usando _parseBinaryTimeline e modelos reais. Comparar grupos bone/slot/constraint e timelines genéricas, offsets, ownership, TODOs e falhas parciais.
3. Portar _parseGeometry e _parseArray binários; só depois fechar entrada DBDT com Uint32/header length/JSON interno e decoder custom original.
4. Atualizar inventário/docs, PR/CI e integrar checkpoint autorizado. Runtime/factories/backends permanecem etapas próprias.

## Pendências

Quatro métodos binários restantes e DBDT/JSON interno/leitura externa; TODOs upstream, locales especiais, coerções/reflexão/proxies genéricos, contextos fora do domínio TS, Big Endian e payloads NaN arbitrários. Runtime Armature/Bone/Slot/Surface, solvers IK/Path, deformações, avaliação/playback/blending, factories, backend LÖVE/GPU e contratos de engines. WorldClock continua os.time com resolução de segundos; não relaxar tolerâncias anteriores.

## Reprodução

```sh
npm ci --ignore-scripts --no-audit --no-fund
node tools/inventory.js ../DragonBonesJS --check
node tools/dependencies.js ../DragonBonesJS --check
for vm in lua5.4 luajit; do
  for suite in geom math baseobject models worldclock events config animationdata displaydata armaturedata constraintdata skindata dragonbonesdata boundingbox dataparser objectatlas structural geometryparser binaryarrays curveframes specialframes deformframes timelines animationparser armatureparser globalentry binaryutf8 binarytimeline; do
    node tests/${suite}_differential.js ../DragonBonesJS "$vm"
  done
done
```

Consultar PR para evidência remota/SHA/merge/CI; não antecipar resultados futuros.
