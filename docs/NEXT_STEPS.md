# Continuidade — Bono-Lua

## Objetivo permanente

Reconstruir em Lua DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e preservando arquitetura/algoritmos/comportamentos. Destino SrTristeSad/Bono-Lua. Não declarar completude com pendências.

## Base desta unidade

- main f5de26e80ab7d3fb59b14619d5c8f5a724bd4a8b, PR #85, CI pós-merge 41743120707 aprovada.
- Backup backup/pre-integral-rebuild-20261103 em cd4206a8ac091b1b26ad02b9ee4bc6ec7f30eeeb conferido.
- Branch port/parser-timelines; conferir PR/SHA/CI/merge atuais. Main acompanha checkpoints testados por autorização do proprietário.

## Unidade implementada

_parseTimeline/_parseBoneTimeline/_parseSlotTimeline TS e Lua do backup auditados integralmente. Total 44/47; três ausentes: _parseAnimation/_parseArmature/parseDragonBonesData.

132 cenários/7.909 operações/213.543 colunas por VM Lua 5.4/LuaJIT, zero tolerância; 20 exceções esperadas. Contadores genuínos 200/8/8. Modelos/frames/callbacks/ações/geometrias/pesos/mapas/frameIndices/pool/finalização reais. Contexto AnimationData semeado em teste; sem _parseAnimation ou entrypoint falso.

Mantidos frames null/vazios antes de mutação, identidade de timeline fornecida, cinco campos/holes, offsets capturados/relativos, callback único start/count=0, último frame extra e índices progressivos, duração por cache _actionFrames e contexto retido em erros. Bone registra cada ramo imediatamente, Slot só registra depois de display/cor completos. Mutantes de frame extra/cache de ações/registro antecipado rejeitados; código restaurado e testes finais refeitos. 23 suítes na CI. Contrato contracts/Timelines.md. NaN Float32 normalizado somente no snapshot; limites anteriores preservados.

## Próximo recorte

1. Conferir main/backup/PR/CI e ler estado/progresso/mapa/validação/decisões/diferenças.
2. Auditar _parseAnimation integralmente em TS/Lua reais, incluindo todos os tipos de timeline, offsets iniciais, actions/zOrder, meshes/surfaces/IK e modelos/dependências. Usar serializers/dispatchers já disponíveis, sem callbacks ou resultados fictícios no produto.
3. Depois _parseArmature e parseDragonBonesData exigem auditoria própria de ordem/bones/slots/skins/constraints/meshes compartilhadas/limpeza e buffers; não declarar importação completa antes dos testes.
4. Atualizar inventário/docs, publicar PR, validar CI e integrar checkpoint autorizado.

## Pendências

Três métodos de ObjectDataParser; texto JSON/importação completa de armaduras/animações/DBDT, BinaryDataParser, TODO ponderado upstream do deform genérico, locales especiais, coerções/reflexão/proxies genéricos, controles/contexto fora dos tipos/offsets TS, length arbitrário de rawFrames, coeficientes de matriz não numéricos, Big Endian/payloads NaN arbitrários. Runtime Armature/Bone/Slot/Surface, solvers, aplicação de deformações, avaliação de timelines/playback/blending, factories, backend/LÖVE/GPU e contratos de engines. SkinData.NULL é truthy e distinto de raw JSValue.NULL. Loops ES5 indexados/UTF-16 (surrogates WTF-8 no Lua) preservados. Curvas/ZOrder/sortBones/clipping mantêm possíveis esperas originais; WorldClock ainda usa os.time com resolução de segundos.

## Reprodução

```sh
npm ci --ignore-scripts --no-audit --no-fund
node tools/inventory.js ../DragonBonesJS --check
node tools/dependencies.js ../DragonBonesJS --check
for vm in lua5.4 luajit; do
  for suite in geom math baseobject models worldclock events config animationdata displaydata armaturedata constraintdata skindata dragonbonesdata boundingbox dataparser objectatlas structural geometryparser binaryarrays curveframes specialframes deformframes timelines; do
    node tests/${suite}_differential.js ../DragonBonesJS "$vm"
  done
done
```

Upstream fixado. Consultar PR para evidência remota/SHA/merge/CI; não antecipar resultados futuros.
