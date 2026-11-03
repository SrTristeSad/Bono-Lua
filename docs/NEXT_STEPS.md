# Continuidade — Bono-Lua

## Objetivo permanente

Reconstruir em Lua DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e preservando arquitetura/algoritmos/comportamentos. Destino SrTristeSad/Bono-Lua. Não declarar completude com pendências.

## Base desta unidade

- main 147bc53a4c87788e44138f6e0b90d3ebf4c72dd7, PR #84, CI pós-merge 41740725798 aprovada.
- Backup backup/pre-integral-rebuild-20261103 em cd4206a8ac091b1b26ad02b9ee4bc6ec7f30eeeb conferido.
- Branch port/parser-deform-frames; conferir PR/SHA/CI/merge atuais. Main acompanha checkpoints testados por autorização do proprietário.

## Unidade implementada

_parseSlotDeformFrame/_parseDeformFrame e helpers antigos lidos integralmente. Total 41/47; seis ausentes: _parseTimeline/_parseBoneTimeline/_parseSlotTimeline/_parseAnimation/_parseArmature/parseDragonBonesData.

117 cenários/5.773 operações/127.006 colunas por VM Lua 5.4/LuaJIT, zero tolerância; 26 exceções esperadas. Contadores genuínos: 143 slot/131 genérico. Geometry/WeightData/meshes/bones/skins/Matrix/AnimationData/TimelineData/pool e finalização tipada reais, com contexto de animação/timeline semeado em teste. Sem parseTimeline ou entrypoint falsos.

Mantidos VERTICES/VALUE distintos, null/undefined/holes e curto-circuito por offset, reservas sem zeros, transformações delta por poses e índices indiretos, headers só no primeiro frame com contagens finais/offsets relativos e estado parcial em erros. Genérico ponderado mantém TODO upstream sem floats novos. Não introduzir multiplicação por pesos ou preencher reservas antecipadamente. Mutantes de delta/offset relativo/TODO rejeitados, código restaurado e testes finais refeitos; 22 suítes na CI. Contrato contracts/DeformFrames.md.

NaN Float32 mantém sinal/payload normalizado somente no snapshot de observação, em ambos os lados, conforme unidade anterior; demais valores/bytes exatos. Não ampliar a equivalência de bits arbitrários ou reflexão/coerções genéricas.

## Próximo recorte

1. Conferir main/backup/PR/CI e ler estado/progresso/mapa/validação/decisões/diferenças.
2. Auditar _parseTimeline/_parseBoneTimeline/_parseSlotTimeline integralmente no TS e Lua reais do backup. Usar callbacks/ActionFrame/AnimationData/TimelineData/frames/arrays reais já disponíveis, mantendo frameIndices, offsets, reservas e efeitos parciais originais.
3. Depois avançar _parseAnimation/_parseArmature/entrypoint com dependências completas e testes diferenciais integrados. Não inventar resultados para métodos ausentes.
4. Atualizar inventário/docs, publicar PR, validar CI e integrar checkpoint autorizado.

## Pendências

Seis métodos de ObjectDataParser; texto JSON/importação completa de armaduras/animações/DBDT, BinaryDataParser, TODO ponderado upstream do genérico, locales especiais, coerções/reflexão/proxies genéricos, controles/contexto fora dos tipos/offsets TS, coeficientes de matriz não numéricos, Big Endian/payloads NaN arbitrários. Runtime Armature/Bone/Slot/Surface, solvers, aplicação de deformações, playback/blending, factories, backend/LÖVE/GPU e contratos de engines. SkinData.NULL é truthy e distinto de raw JSValue.NULL. Loops ES5 indexados/UTF-16 (surrogates WTF-8 no Lua) preservados. Curvas/ZOrder/sortBones/clipping mantêm possíveis esperas originais; WorldClock ainda usa os.time com resolução de segundos.

## Reprodução

```sh
npm ci --ignore-scripts --no-audit --no-fund
node tools/inventory.js ../DragonBonesJS --check
node tools/dependencies.js ../DragonBonesJS --check
for vm in lua5.4 luajit; do
  for suite in geom math baseobject models worldclock events config animationdata displaydata armaturedata constraintdata skindata dragonbonesdata boundingbox dataparser objectatlas structural geometryparser binaryarrays curveframes specialframes deformframes; do
    node tests/${suite}_differential.js ../DragonBonesJS "$vm"
  done
done
```

Upstream fixado. Consultar PR para evidência remota/SHA/merge/CI; não antecipar resultados futuros.
