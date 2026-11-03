# Continuidade — Bono-Lua

## Objetivo permanente

Reconstruir em Lua DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e preservando arquitetura/algoritmos/comportamentos. Destino SrTristeSad/Bono-Lua. Não declarar completude com pendências.

## Base desta unidade

- main ff2db0ed4c5a54850354a2c5a0fbeb9a20935ed9, PR #78, CI pós-merge 41696197476 aprovada.
- Backup backup/pre-integral-rebuild-20261103 em cd4206a8ac091b1b26ad02b9ee4bc6ec7f30eeeb conferido.
- Branch port/parser-structural-primitives; conferir PR/SHA/CI/merge atuais. Main acompanha checkpoints testados por autorização do proprietário.

## Unidade implementada

Nove corpos TS/Lua do backup auditados e portados: _parseTransform/_parseColorTransform/_parsePivot/_parseIKConstraint/_parsePathConstraint/_parseSlot/_parseActionData/_parseBoundingBox/_parsePolygonBoundingBox. ObjectDataParser totaliza 14/47 métodos; 33 ainda ausentes. Não há bone/display/skin/armature/entrypoint fictício. Dependências reais de geometria/animação motivaram delimitação do recorte.

55 cenários/2.465 operações/27.115 colunas em Lua 5.4/LuaJIT, binary64 exato/NaN canonicalizado/sinal do zero exato. Modelos e pool reais; observação de todas as alocações, inclusive órfãs. Events anterior passou nas duas VMs após UserData migrar arrays para JSArray/length e preservar payloads esparsos. Adaptador interno ArmatureData._isNullReference conserva ramos parent/defaultSkin undefined versus null. Mutantes de parent~=nil e AABB width=max foram rejeitados nas linhas 306/192; produto restaurado e testes finais refeitos.

JSValue.iterator segue emit TS2.4/ES5, indexação/length vivo de arrays/array-like e unidades UTF-16 de strings. Surrogates isolados são WTF-8 em Lua; transporte de saída do teste é UTF-16LE, fixtures de entrada UTF-8 e arrays do realm da VM (instanceof Array). Não confundir com iterator ES2015. Ver contracts/StructuralParser.md. Dezessete suítes na CI.

## Próximo recorte

1. Conferir main/backup/PRs/CI e ler estado/progresso/mapa/validação/decisões/diferenças.
2. Auditar _parseGeometry integral TS/Lua e dependências (pesos, poses, matrizes, offsets, _rawBones e _data reais); não substituir geometria por stub.
3. Portar dependências completas para Surface/Mesh/Path; depois _parseBone, _parseMesh/_parsePath/_parseDisplay/_parseSkin. _parseArmature depende também de animações, cache e estado: mapear antes de expor entrypoint.
4. Typed arrays/buffers compartilhados e compactação exigem implementação/provas próprias. Marcar métodos ausentes sem devolver resultados fabricados.
5. Atualizar inventário/docs, publicar PR, validar CI e integrar checkpoint autorizado.

## Pendências

33 métodos de ObjectDataParser; texto JSON/importação completa de armaduras/animações/DBDT, typed arrays/ArrayBuffer, locales especiais de DataParser, coerções/reflexão/proxies genéricos. Runtime Armature/Bone/Slot/Surface, solvers, deformação, playback/blending, factories, backend/LÖVE/GPU e contratos de engines. SkinData.NULL é truthy e distinto do raw JSValue.NULL. sortBones/clipping mantêm possíveis esperas/não terminação originais. WorldClock usa os.time com resolução de segundos, sem precisão automática em ms comprovada.

## Reprodução

```sh
npm ci --ignore-scripts --no-audit --no-fund
node tools/inventory.js ../DragonBonesJS --check
node tools/dependencies.js ../DragonBonesJS --check
for vm in lua5.4 luajit; do
  for suite in geom math baseobject models worldclock events config animationdata displaydata armaturedata constraintdata skindata dragonbonesdata boundingbox dataparser objectatlas structural; do
    node tests/${suite}_differential.js ../DragonBonesJS "$vm"
  done
done
```

Upstream fixado. Consultar PR para evidências remotas/SHA/merge/CI, sem antecipar resultados futuros.
