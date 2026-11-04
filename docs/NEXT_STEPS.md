# Continuidade — Bono-Lua

## Objetivo permanente

Reconstruir em Lua DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e preservando arquitetura, algoritmos e comportamentos. Destino SrTristeSad/Bono-Lua. Não declarar motor completo com pendências.

## Base desta unidade

main 1d1ee912ebb2c579d8c79074a51dac264694d812, PR #96, CI após merge 41832504520 aprovada. Backup backup/pre-integral-rebuild-20261103 em cd4206a8ac091b1b26ad02b9ee4bc6ec7f30eeeb. Branch port/transform-object; consultar PR para SHA/merge/evidência final. Autorização do proprietário mantém main acompanhando checkpoints testados.

## Unidade implementada

Primeira base do runtime: TransformObject abstrato, com inicializadores, dois métodos e getter. 212 cenários/8.056 colunas por VM, 35 falhas esperadas e 27 aproximações trig na tolerância anterior de Transform. Contrato contracts/TransformObject.md. CI com 34 suítes por VM e exemplos inspect/transform executados. README agora fornece comandos simples para experimentar JSON/DBDT e a atualização da matriz sem Node/npm.

Preservar construção sem clear automático, identidade dos vetores/helpers, dirty limpo antes de decompor, getter somente leitura e estado parcial em falhas. Subclasses delegam __index/__newindex; não criar toString fictício na base abstrata. Armature ainda é referência opaca sem chamadas/stub. Corpus upstream anterior (74 blobs/181 caminhos/duas escalas) permanece validado, com limites registrados.

## Próximo recorte

1. Conferir main/backup/PR/CI, progresso, diferenças e contratos.
2. Auditar integralmente Bone TS/Lua do backup e dependências com TransformObject/Armature/Surface/constraints. Separar referências de dados e chamadas executáveis, sem stubs de produto.
3. Escolher próximo recorte real do runtime a partir dessa auditoria. Manter exemplos executáveis atualizados; solvers, avaliação de timelines, factories, backend e playback seguem etapas próprias.
4. Atualizar inventário/docs, PR/CI e integrar checkpoint autorizado. Runtime/factories/backends permanecem etapas próprias.

## Pendências

Exportações externas ao pin e leitura externa; JSON sem promessa de profundidade ilimitada/locale alternativo; TODOs upstream, locales especiais, coerções/reflexão/proxies genéricos, contextos fora do domínio TS, Big Endian e payloads NaN arbitrários. Runtime Armature/Bone/Slot/Surface, solvers IK/Path, deformações, avaliação/playback/blending, factories, backend LÖVE/GPU e contratos de engines. WorldClock continua os.time com resolução de segundos; não relaxar tolerâncias anteriores.

## Reprodução

```sh
npm ci --ignore-scripts --no-audit --no-fund
node tools/inventory.js ../DragonBonesJS --check
node tools/dependencies.js ../DragonBonesJS --check
for vm in lua5.4 luajit; do
  for suite in geom math baseobject models worldclock events config animationdata displaydata armaturedata constraintdata skindata dragonbonesdata boundingbox dataparser objectatlas structural geometryparser binaryarrays curveframes specialframes deformframes timelines animationparser armatureparser globalentry binaryutf8 binarytimeline binaryanimation binarygeometry binaryviews dbdt corpus transformobject; do
    node tests/${suite}_differential.js ../DragonBonesJS "$vm"
  done
done
```

Consultar PR para evidência remota/SHA/merge/CI; não antecipar resultados futuros.
