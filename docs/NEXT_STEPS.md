# Continuidade — Bono-Lua

## Objetivo permanente

Reconstruir em Lua DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e preservando arquitetura/algoritmos/comportamentos. Destino SrTristeSad/Bono-Lua. Não declarar completude com pendências.

## Base desta unidade

- main 117237f4b88b10e9dd3c25c452f01df2a1a95e53, PR #83, CI pós-merge 41738114130 aprovada.
- Backup backup/pre-integral-rebuild-20261103 em cd4206a8ac091b1b26ad02b9ee4bc6ec7f30eeeb conferido.
- Branch port/parser-specialized-frames; conferir PR/SHA/CI/merge atuais. Main acompanha checkpoints testados por autorização do proprietário.

## Unidade implementada

Oito métodos TS e Lua do backup auditados: _parseZOrderFrame/_parseBoneAllFrame/_parseBoneTranslateFrame/_parseBoneRotateFrame/_parseBoneScaleFrame/_parseSlotDisplayFrame/_parseSlotColorFrame/_parseIKConstraintFrame. Total 39/47; 8 ausentes: _parseSlotDeformFrame/_parseDeformFrame/_parseTimeline/_parseBoneTimeline/_parseSlotTimeline/_parseAnimation/_parseArmature/parseDragonBonesData.

203 cenários/7.577 operações/159.117 colunas por VM Lua 5.4/LuaJIT, zero tolerância; 39 exceções esperadas. Contadores confirmam oito corpos genuínos e modelos/Transform/ações/payloads/pool/finalização tipada reais. Rotação em sequência com voltas/normalizeRadian e estado antes de falha, reservas/valores parciais/overflow, ZOrder e slots reais, displays/ações e cores explícitas versus cache/defaults/primitivos/precedência/erros.

Sem simplificar expressão de rotação, preencher reservas ou adiar estado. BoneAll guarda seis floats antes de ações; SlotDisplay usa slot.parent depois do índice. Cor default define cache antes de reservar, _modifyArray redefine cache e _parseArray não. Mutantes de cache/voltas/ordem de leitura rejeitados; produto restaurado e testes finais refeitos. 21 suítes na CI. Contrato contracts/SpecializedFrames.md.

Infinitos geram NaN aritmético com sinal/payload do host; o adaptador já exclui equivalência desses bits arbitrários. A suíte normaliza somente células Float32 NaN num snapshot separado, em ambos os lados, sem alterar memória/views originais. Demais bytes, valores e sinal do zero exatos. Testes/contratos anteriores preservados.

## Próximo recorte

1. Conferir main/backup/PR/CI e ler estado/progresso/mapa/validação/decisões/diferenças.
2. Auditar _parseSlotDeformFrame/_parseDeformFrame integralmente, com GeometryData/WeightData, matrizes/poses e arrays reais. O ramo TODO do upstream não autoriza inventar comportamento novo; respeitar offsets e estado parcial originais.
3. Avançar _parseTimeline/_parseBoneTimeline/_parseSlotTimeline e depois _parseAnimation/_parseArmature/entrypoint com dependências completas e testes diferenciais integrados.
4. Atualizar inventário/docs, publicar PR, validar CI e integrar checkpoint autorizado.

## Pendências

8 métodos de ObjectDataParser; texto JSON/importação completa de armaduras/animações/DBDT, BinaryDataParser, locales especiais de DataParser, coerções/reflexão/proxies genéricos, controles de frame fora do contrato numérico TS, coeficientes de matriz fora do tipo numérico, Big Endian/payloads NaN arbitrários. Runtime Armature/Bone/Slot/Surface, solvers, deformação, playback/blending, factories, backend/LÖVE/GPU e contratos de engines. SkinData.NULL é truthy e distinto de raw JSValue.NULL. Loops ES5 indexados/UTF-16 (surrogates WTF-8 no Lua) preservados. Curvas/ZOrder/sortBones/clipping mantêm possíveis esperas originais; WorldClock ainda usa os.time com resolução de segundos.

## Reprodução

```sh
npm ci --ignore-scripts --no-audit --no-fund
node tools/inventory.js ../DragonBonesJS --check
node tools/dependencies.js ../DragonBonesJS --check
for vm in lua5.4 luajit; do
  for suite in geom math baseobject models worldclock events config animationdata displaydata armaturedata constraintdata skindata dragonbonesdata boundingbox dataparser objectatlas structural geometryparser binaryarrays curveframes specialframes; do
    node tests/${suite}_differential.js ../DragonBonesJS "$vm"
  done
done
```

Upstream fixado. Consultar PR para evidência remota/SHA/merge/CI; não antecipar resultados futuros.
