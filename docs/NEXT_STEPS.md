# Continuidade — Bono-Lua

## Objetivo permanente

Reconstruir em Lua DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e preservando arquitetura/algoritmos/comportamentos. Destino SrTristeSad/Bono-Lua. Não declarar completude com pendências.

## Base desta unidade

- main 0d285dae5b9492b52dfbc30b9d728c5a14c7ea34, PR #86, CI pós-merge 41746583709 aprovada.
- Backup backup/pre-integral-rebuild-20261103 em cd4206a8ac091b1b26ad02b9ee4bc6ec7f30eeeb conferido.
- Branch port/parser-animation; conferir PR/SHA/CI/merge atuais. Main acompanha checkpoints testados por autorização do proprietário.

## Unidade implementada

_parseAnimation integral TS e Lua do backup auditados. Total 45/47; _parseArmature/parseDragonBonesData ausentes.

172 cenários/15.997 operações/447.916 colunas por VM Lua 5.4/LuaJIT, zero tolerância e 28 exceções esperadas; 194 chamadas genuínas. AnimationData é criado pelo método, sem objeto substituto. Legacy e todos os tipos genéricos, AnimationTimelineData blend, SurfaceData/meshes/pesos/poses/constraints/timelines/ações/maps/pool/bytes reais. 24 suítes na CI; contrato contracts/AnimationParser.md.

Preservar ordem dos ramos, offsets antes dos frames, ações consumidas antes das genéricas, length capturado só no primeiro loop, órfãos de blend vazio/erro, contexto FFD em continue e busca SlotDeform por ordem JS/último match entre skins/slots. Codecs legado/genérico de rotação/IK e TODOs Action/ZOrder/SlotDisplay genéricos não foram harmonizados. _animation só limpa no sucesso; retorno não registra na armadura. Mutantes de escala/limpeza de ações/first match rejeitados, código restaurado e testes finais refeitos.

Transcript ~72 MiB exigiu transporte 128 MiB/30s, sem mudar comparação. NaN Float32 só normalizado no snapshot; demais limites e TODO ponderado do deform genérico mantidos.

## Próximo recorte

1. Conferir main/backup/PR/CI e ler estado/progresso/mapa/validação/decisões/diferenças.
2. Auditar _parseArmature inteiro em TS/Lua reais: metadados, bones/parents/slots/constraints/skins, meshes compartilhadas/caches, sort e animações, defaultActions/canvas/aabb/contexto/ordem de limpeza. Usar os modelos/parsers reais já disponíveis; não inventar implementação para dependências ausentes.
3. Depois parseDragonBonesData precisa de versão/compatibilidade, ownership, parsing de múltiplas armaduras, stage/atlas e finalização. JSON texto/DBDT/entrypoint completo não devem ser declarados antes dessa prova.
4. Atualizar inventário/docs, publicar PR, validar CI e integrar checkpoint autorizado.

## Pendências

Dois métodos de ObjectDataParser; texto JSON/importação global/armaduras/DBDT, BinaryDataParser, TODOs upstream (Action/ZOrder/SlotDisplay genéricos e deform ponderado), locales especiais, coerções/reflexão/proxies genéricos, controles/contexto fora dos tipos/offsets TS, length arbitrário de rawFrames, coeficientes de matriz não numéricos, Big Endian/payloads NaN arbitrários. Runtime Armature/Bone/Slot/Surface, solvers, aplicação de deformações, avaliação de timelines/playback/blending, factories, backend/LÖVE/GPU e contratos de engines. SkinData.NULL distinto de raw JSValue.NULL; ES5 indexado/UTF-16/WTF-8 preservados. Curvas/ZOrder/sortBones/clipping mantêm possíveis esperas originais; WorldClock usa os.time com resolução de segundos.

## Reprodução

```sh
npm ci --ignore-scripts --no-audit --no-fund
node tools/inventory.js ../DragonBonesJS --check
node tools/dependencies.js ../DragonBonesJS --check
for vm in lua5.4 luajit; do
  for suite in geom math baseobject models worldclock events config animationdata displaydata armaturedata constraintdata skindata dragonbonesdata boundingbox dataparser objectatlas structural geometryparser binaryarrays curveframes specialframes deformframes timelines animationparser; do
    node tests/${suite}_differential.js ../DragonBonesJS "$vm"
  done
done
```

Upstream fixado. Consultar PR para evidência remota/SHA/merge/CI; não antecipar resultados futuros.
