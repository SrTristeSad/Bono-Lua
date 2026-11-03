# Continuidade — Bono-Lua

## Objetivo permanente

Reconstruir em Lua DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e preservando arquitetura/algoritmos/comportamentos. Destino SrTristeSad/Bono-Lua. Não declarar completude com pendências.

## Base desta unidade

- main bc673135a8a92f1008f17e0cd7dbb2a14d0bf36f, PR #81, CI pós-merge 41735155177 aprovada.
- Backup backup/pre-integral-rebuild-20261103 em cd4206a8ac091b1b26ad02b9ee4bc6ec7f30eeeb conferido.
- Branch port/parser-curves-frames; conferir PR/SHA/CI/merge atuais. Main acompanha checkpoints testados por autorização do proprietário.

## Unidade implementada

Nove métodos TS e Lua do backup auditados: _getCurvePoint/_samplingEasingCurve/_parseFrame/_parseTweenFrame/_parseSingleValueFrame/_parseDoubleValueFrame/_parseActionFrame/_parseActionDataInFrame/_mergeActionFrame. Total 31/47 métodos; 16 ausentes, incluindo frames especializados/timelines/_parseAnimation/_parseArmature/parseDragonBonesData.

328 cenários/3.594 operações/71.880 colunas por VM Lua 5.4/LuaJIT, zero tolerância; 21 exceções esperadas. Contadores confirmam os nove métodos genuínos, 16 arquivos emitidos; modelos/ações/payloads/pool/finalização tipada reais. Inclui curvas nos dois formatos/segmentos/NaNs/holes, último probe, Step/Int/Float, Math.round (-0/ties/inteiros grandes), defaults/coerções/escala, reservas/erros parciais/overflow, merge/inserção/ordem de ações e serialização de offsets/bytes.

O backup lia valores cedo e preenchia reservas; não copiar essas diferenças. _parseSingle/Double leem valores depois do frame/tween/reserva; Step não aplica escala e tipo desconhecido não lê raw. Ações entram primeiro na armadura; frames agregam offsets base 0, inicial zero e identidade original. ActionFrame não é poolável. Mutantes de limiar da curva/leitura antecipada/zero negativo rejeitados; produto restaurado e testes finais refeitos. Vinte suítes na CI. Contrato contracts/CurveFrames.md.

## Próximo recorte

1. Conferir main/backup/PR/CI e ler estado/progresso/mapa/validação/decisões/diferenças.
2. Auditar serializers de frames especializados e dependências integrais: ZOrder, BoneAll/Translate/Rotate/Scale, SlotDisplay/Color, IK e deformações. Ler TS e Lua reais do backup antes de portar cada corpo; não fornecer métodos falsos para dependências ausentes.
3. Avançar _parseTimeline/_parseBoneTimeline/_parseSlotTimeline e depois _parseAnimation/_parseArmature/entrypoint com dependências completas e testes diferenciais integrados.
4. Atualizar inventário/docs, publicar PR, validar CI e integrar checkpoint autorizado.

## Pendências

16 métodos de ObjectDataParser; texto JSON/importação completa de armaduras/animações/DBDT, BinaryDataParser, locales especiais de DataParser, coerções/reflexão/proxies genéricos, controles de frame fora do contrato numérico TS, coeficientes de matriz fora do tipo numérico, Big Endian/payloads NaN arbitrários. Runtime Armature/Bone/Slot/Surface, solvers, deformação, playback/blending, factories, backend/LÖVE/GPU e contratos de engines. SkinData.NULL é truthy e distinto de raw JSValue.NULL. Loops ES5 indexados/UTF-16 (surrogates WTF-8 no Lua) preservados. Curvas/sortBones/clipping mantêm possíveis esperas originais; WorldClock ainda usa os.time com resolução de segundos.

## Reprodução

```sh
npm ci --ignore-scripts --no-audit --no-fund
node tools/inventory.js ../DragonBonesJS --check
node tools/dependencies.js ../DragonBonesJS --check
for vm in lua5.4 luajit; do
  for suite in geom math baseobject models worldclock events config animationdata displaydata armaturedata constraintdata skindata dragonbonesdata boundingbox dataparser objectatlas structural geometryparser binaryarrays curveframes; do
    node tests/${suite}_differential.js ../DragonBonesJS "$vm"
  done
done
```

Upstream fixado. Consultar PR para evidência remota/SHA/merge/CI; não antecipar resultados futuros.
