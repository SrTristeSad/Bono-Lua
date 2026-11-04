# Continuidade — Bono-Lua

## Objetivo permanente

Reconstruir em Lua DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e preservando arquitetura, algoritmos e comportamentos. Destino SrTristeSad/Bono-Lua. Não declarar motor completo com pendências.

## Base desta unidade

main 441d916307cd4a76284f77ade5150bde60aae783, PR #94, CI após merge 41786740712 aprovada. Backup backup/pre-integral-rebuild-20261103 em cd4206a8ac091b1b26ad02b9ee4bc6ec7f30eeeb. Branch port/dbdt-entry; consultar PR para SHA/merge/evidência final. Autorização do proprietário mantém main acompanhando checkpoints testados.

## Unidade implementada

BinaryDataParser agora 8/8 corpos, incluindo entrada DBDT e adaptação JSON. ObjectDataParser permanece 47/47 nos domínios documentados. Novo teste: 223 cenários (184 JSON/39 DBDT)/797 colunas por VM, 45 exceções esperadas, tolerância zero. Contrato contracts/DBDTEntry.md. CI com 32 suítes por VM.

Preservar Shared Buffer por referência, tag/Uint32/header views, decoder custom e ordem JSON antes de publicar campos binários. JSON usa JSMap/JSValue.array/NULL, binary64/-0 e WTF-8 para surrogates isolados. Não reintroduzir JSON do backup sem comparação: whitespace, overflow, null e Unicode divergiam. Não declarar motor completo com corpos presentes.

## Próximo recorte

1. Conferir main/backup/PR/CI, progresso, diferenças e contratos.
2. Auditar corpus de exportações upstream JSON/DBDT e ampliar comparação integrada antes de declarar compatibilidade geral. Conferir nomes/ordem/Unicode/versões, geometria e ownership com arquivos reais.
3. Auditar dependências do runtime (TransformObject/Bone/Surface/Slot/Armature) e definir primeira unidade portável sem backend; solvers/factories/playback continuam etapas próprias.
4. Atualizar inventário/docs, PR/CI e integrar checkpoint autorizado. Runtime/factories/backends permanecem etapas próprias.

## Pendências

Corpus de exportações reais e leitura externa; JSON sem promessa de profundidade ilimitada/locale alternativo; TODOs upstream, locales especiais, coerções/reflexão/proxies genéricos, contextos fora do domínio TS, Big Endian e payloads NaN arbitrários. Runtime Armature/Bone/Slot/Surface, solvers IK/Path, deformações, avaliação/playback/blending, factories, backend LÖVE/GPU e contratos de engines. WorldClock continua os.time com resolução de segundos; não relaxar tolerâncias anteriores.

## Reprodução

```sh
npm ci --ignore-scripts --no-audit --no-fund
node tools/inventory.js ../DragonBonesJS --check
node tools/dependencies.js ../DragonBonesJS --check
for vm in lua5.4 luajit; do
  for suite in geom math baseobject models worldclock events config animationdata displaydata armaturedata constraintdata skindata dragonbonesdata boundingbox dataparser objectatlas structural geometryparser binaryarrays curveframes specialframes deformframes timelines animationparser armatureparser globalentry binaryutf8 binarytimeline binaryanimation binarygeometry binaryviews dbdt; do
    node tests/${suite}_differential.js ../DragonBonesJS "$vm"
  done
done
```

Consultar PR para evidência remota/SHA/merge/CI; não antecipar resultados futuros.
