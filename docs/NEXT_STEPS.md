# Continuidade — Bono-Lua

## Objetivo permanente

Reconstruir em Lua DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e preservando arquitetura, algoritmos e comportamentos. Destino SrTristeSad/Bono-Lua. Não declarar motor completo com pendências.

## Base desta unidade

main cdce4fbcc2eb5bce454721e9bf51e72978e90f1d, PR #91, CI após merge 41777366483 aprovada. Backup backup/pre-integral-rebuild-20261103 em cd4206a8ac091b1b26ad02b9ee4bc6ec7f30eeeb. Branch port/binary-animation; consultar PR para SHA/merge/evidência final. Autorização do proprietário mantém main acompanhando checkpoints testados.

## Unidade implementada

BinaryDataParser agora 5/8 métodos: helpers, singleton, _parseBinaryTimeline e override _parseAnimation. ObjectDataParser permanece 47/47 nos domínios documentados. Novo teste: 243 cenários/468 chamadas de timeline/3.159 colunas por VM, 32 exceções esperadas, tolerância zero. Contrato contracts/BinaryAnimation.md. CI com 29 suítes por VM.

Preservar grupos JSMap ordenados e listas JSValue.array, offsets de cabeçalho, UNDEFINED numérico como NaN, publicação/registro imediato e estado retido em falhas. TODOs genéricos Action/ZOrder e órfãos permanecem como upstream. _animation limpa só no sucesso.

## Próximo recorte

1. Conferir main/backup/PR/CI, progresso, diferenças e contratos.
2. Portar _parseGeometry binário: pesos, correção de offsets negativos, contagem/bones e integração com modelos/views reais.
3. Portar _parseArray binário; só depois fechar entrada DBDT com Uint32/header length/JSON interno e decoder custom original.
4. Atualizar inventário/docs, PR/CI e integrar checkpoint autorizado. Runtime/factories/backends permanecem etapas próprias.

## Pendências

Três métodos binários restantes e DBDT/JSON interno/leitura externa; TODOs upstream, locales especiais, coerções/reflexão/proxies genéricos, contextos fora do domínio TS, Big Endian e payloads NaN arbitrários. Runtime Armature/Bone/Slot/Surface, solvers IK/Path, deformações, avaliação/playback/blending, factories, backend LÖVE/GPU e contratos de engines. WorldClock continua os.time com resolução de segundos; não relaxar tolerâncias anteriores.

## Reprodução

```sh
npm ci --ignore-scripts --no-audit --no-fund
node tools/inventory.js ../DragonBonesJS --check
node tools/dependencies.js ../DragonBonesJS --check
for vm in lua5.4 luajit; do
  for suite in geom math baseobject models worldclock events config animationdata displaydata armaturedata constraintdata skindata dragonbonesdata boundingbox dataparser objectatlas structural geometryparser binaryarrays curveframes specialframes deformframes timelines animationparser armatureparser globalentry binaryutf8 binarytimeline binaryanimation; do
    node tests/${suite}_differential.js ../DragonBonesJS "$vm"
  done
done
```

Consultar PR para evidência remota/SHA/merge/CI; não antecipar resultados futuros.
