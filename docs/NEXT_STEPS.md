# Continuidade — Bono-Lua

## Objetivo permanente

Reconstruir em Lua DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e preservando arquitetura/algoritmos/comportamentos. Destino SrTristeSad/Bono-Lua. Não declarar completude com pendências.

## Base desta unidade

- main 63b9b1286af24296e1bcc4b38d5d71eadc01fdf1, PR #87, CI pós-merge 41752378133 aprovada.
- Backup backup/pre-integral-rebuild-20261103 em cd4206a8ac091b1b26ad02b9ee4bc6ec7f30eeeb conferido.
- Branch port/parser-armature; conferir PR/SHA/CI/merge atuais. Main acompanha checkpoints testados por autorização do proprietário.

## Unidade implementada

_parseArmature TS e Lua do backup auditados integralmente. Total 46/47; parseDragonBonesData ausente.

79 cenários/3.670 operações/113.770 colunas por VM Lua 5.4/LuaJIT, zero tolerância, 24 exceções esperadas e 83 chamadas genuínas. 17 arquivos emitidos incluindo CanvasData, modelos/bones/skins/weights/constraints/AnimationData/timelines/ações/pool/finalização reais. CanvasData é recarregado por cenário para manter BaseObject/identidades corretos; sem stub. 25 suítes na CI; contrato contracts/ArmatureParser.md.

Preservar ordem metadados/canvas/aabb/bones/IK/sort/slots/skins/path/links/animações/defaultActions/actions. Pais futuros resolvidos por cache e rawBones na ordem original; share usa slot vazio literal (TODO) e ocorre antes de animações. Última defaultAction Play válida define defaultAnimation. Helpers só limpos no sucesso; erros/retry mantêm contexto/órfãos/caches. Não registra em DragonBonesData nem finaliza buffers automaticamente. Mutantes de parent/share/defaultAction rejeitados, código restaurado e testes finais refeitos. NaN Float32 só normalizado no snapshot conforme contrato anterior.

## Próximo recorte

1. Conferir main/backup/PR/CI e ler estado/progresso/mapa/validação/decisões/diferenças.
2. Auditar parseDragonBonesData integral TS/Lua reais: versão/compatibilidade/metadados, _parseArray, múltiplas armaduras/ownership, _modifyArray, stage/default, atlas/contexto e efeitos parciais em falhas. Usar _parseArmature real, sem fornecer árvore fictícia para o teste de entrada.
3. Distinguir API de objeto já decodificado de leitura de texto JSON/DBDT. Completar os métodos deste arquivo não significa runtime/factories/backends completos; manter TODOs e fronteiras documentados.
4. Atualizar inventário/docs, publicar PR, validar CI e integrar checkpoint autorizado.

## Pendências

parseDragonBonesData; texto JSON/importação global/DBDT, BinaryDataParser, TODOs upstream (slot vazio em share, Action/ZOrder/SlotDisplay genéricos e deform ponderado), locales especiais, coerções/reflexão/proxies genéricos, controles/contexto fora dos tipos/offsets TS, length arbitrário de rawFrames, coeficientes de matriz não numéricos, Big Endian/payloads NaN arbitrários. Runtime Armature/Bone/Slot/Surface, solvers, aplicação de deformações, avaliação de timelines/playback/blending, factories, backend/LÖVE/GPU e contratos de engines. SkinData.NULL distinto de raw JSValue.NULL; ES5 indexado/UTF-16/WTF-8 preservados. Curvas/ZOrder/sortBones/clipping mantêm possíveis esperas originais; WorldClock usa os.time com resolução de segundos.

## Reprodução

```sh
npm ci --ignore-scripts --no-audit --no-fund
node tools/inventory.js ../DragonBonesJS --check
node tools/dependencies.js ../DragonBonesJS --check
for vm in lua5.4 luajit; do
  for suite in geom math baseobject models worldclock events config animationdata displaydata armaturedata constraintdata skindata dragonbonesdata boundingbox dataparser objectatlas structural geometryparser binaryarrays curveframes specialframes deformframes timelines animationparser armatureparser; do
    node tests/${suite}_differential.js ../DragonBonesJS "$vm"
  done
done
```

Upstream fixado. Consultar PR para evidência remota/SHA/merge/CI; não antecipar resultados futuros.
