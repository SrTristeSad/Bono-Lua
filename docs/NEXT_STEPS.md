# Continuidade — Bono-Lua

## Objetivo permanente

Reconstruir em Lua DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e preservando arquitetura, algoritmos e comportamentos. Destino SrTristeSad/Bono-Lua. Não declarar motor completo com pendências.

## Base desta unidade

main d0ecdd24f982159ee7eec49a57d80cb00290b4bb, PR #95, CI após merge 41789339464 aprovada. Backup backup/pre-integral-rebuild-20261103 em cd4206a8ac091b1b26ad02b9ee4bc6ec7f30eeeb. Branch test/upstream-export-corpus; consultar PR para SHA/merge/evidência final. Autorização do proprietário mantém main acompanhando checkpoints testados.

## Unidade implementada

Corpus esquelético upstream comparado: 74 blobs únicos (71 JSON/3 DBDT) em 181 caminhos, intactos e nas escalas 1/0,5. 148 cenários/1.924 colunas por VM, zero erros/tolerância. Contrato contracts/UpstreamCorpus.md; 33 suítes na CI. Nenhuma mudança no motor neste checkpoint. ObjectDataParser 47/47 e BinaryDataParser 8/8 corpos permanecem limitados aos domínios documentados.

Preservar leitura dos blobs por SHA/pin, contexto VM do oracle para JSON/ArrayBuffer, bytes exatos, metadados/aliases e pool após cleanup. Não afrouxar campos ou tolerâncias para contornar diferenças de transporte do teste. Manifesto distingue caminhos duplicados de conteúdos únicos.

## Próximo recorte

1. Conferir main/backup/PR/CI, progresso, diferenças e contratos.
2. Auditar TS e backup Lua de TransformObject e dependências antes de portar a primeira unidade do runtime. Conferir ciclos com Bone/Surface/Slot/Armature, sem inventar stubs de produto.
3. Delimitar unidade portável com comparação original executada. Solvers, avaliação de timelines, factories, backend e playback seguem etapas próprias.
4. Atualizar inventário/docs, PR/CI e integrar checkpoint autorizado. Runtime/factories/backends permanecem etapas próprias.

## Pendências

Exportações externas ao pin e leitura externa; JSON sem promessa de profundidade ilimitada/locale alternativo; TODOs upstream, locales especiais, coerções/reflexão/proxies genéricos, contextos fora do domínio TS, Big Endian e payloads NaN arbitrários. Runtime Armature/Bone/Slot/Surface, solvers IK/Path, deformações, avaliação/playback/blending, factories, backend LÖVE/GPU e contratos de engines. WorldClock continua os.time com resolução de segundos; não relaxar tolerâncias anteriores.

## Reprodução

```sh
npm ci --ignore-scripts --no-audit --no-fund
node tools/inventory.js ../DragonBonesJS --check
node tools/dependencies.js ../DragonBonesJS --check
for vm in lua5.4 luajit; do
  for suite in geom math baseobject models worldclock events config animationdata displaydata armaturedata constraintdata skindata dragonbonesdata boundingbox dataparser objectatlas structural geometryparser binaryarrays curveframes specialframes deformframes timelines animationparser armatureparser globalentry binaryutf8 binarytimeline binaryanimation binarygeometry binaryviews dbdt corpus; do
    node tests/${suite}_differential.js ../DragonBonesJS "$vm"
  done
done
```

Consultar PR para evidência remota/SHA/merge/CI; não antecipar resultados futuros.
