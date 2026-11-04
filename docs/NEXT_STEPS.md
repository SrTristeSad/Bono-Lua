# Continuidade — Bono-Lua

## Objetivo permanente

Reconstruir em Lua DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e preservando arquitetura/algoritmos/comportamentos. Destino SrTristeSad/Bono-Lua. Não declarar completude com pendências.

## Base desta unidade

- main 5d16e3da546a5511dcece6753c622748331d66e2, PR #88, CI pós-merge 41754763774 aprovada.
- Backup backup/pre-integral-rebuild-20261103 em cd4206a8ac091b1b26ad02b9ee4bc6ec7f30eeeb conferido.
- Branch port/parser-global-entry; conferir PR/SHA/CI/merge atuais. Main acompanha checkpoints testados por autorização do proprietário.

## Unidade implementada

parseDragonBonesData integral TS/Lua auditado: 47/47 corpos de ObjectDataParser presentes, com comparação nos recortes documentados. Não declarar motor completo/equivalência JS irrestrita. API recebe objeto decodificado, não texto JSON/DBDT.

90 cenários/4.285 operações/149.975 colunas por VM Lua 5.4/LuaJIT, zero tolerância, 23 exceções esperadas. 115 entradas/31 atlas/63 finalizações genuínas, 18 arquivos emitidos. Sem Data/Armature pré-semeados: grafo/ownership/views/frames/timelines/pool reais. Factory abstrata de textura concretizada só no teste, sem backend de produto. 26 suítes na CI; contrato contracts/GlobalObjectEntry.md.

Preservar OR de versões, version primária, diagnósticos não bloqueantes, ramo ARMATURE por presença, buffers vazios versus ausentes, binary truthy para skip, stage explícito versus primeiro nome, fila de atlas sem reiniciar índice e null interno distinto de undefined. Erros e ramo sem ARMATURE não limpam contexto anterior. Mutantes de compatibilidade/finalização/índice de atlas rejeitados, código restaurado e testes finais refeitos. NaN Float32 normalizado só no snapshot conforme contrato anterior.

## Próximo recorte

1. Conferir main/backup/PR/CI e ler estado/progresso/mapa/validação/decisões/diferenças.
2. Auditar BinaryDataParser integral TS/Lua do backup e suas fronteiras de plataforma: _inRange/_decodeUTF8/_parseBinaryTimeline/_parseAnimation/_parseGeometry/_parseArray/parseDragonBonesData/getInstance. Herda ObjectDataParser real; não inventar binário já decodificado como substituto.
3. Delimitar primeiro helpers de bytes/UTF-8/views e dependência JSON.parse do cabeçalho. SharedBinaryBuffer atual tem Int16/Uint16/Float32 little endian; Uint8/DataView, decodificação e JSON interno exigem representação/provas próprias. Não supor equivalência entre decoder custom upstream e biblioteca UTF-8 genérica.
4. Atualizar inventário/docs, publicar PR, validar CI e integrar checkpoint autorizado. Runtime/factories/backends seguem fronteiras separadas.

## Pendências

BinaryDataParser/DBDT/bytes/UTF-8/JSON interno e leitura externa de arquivos; TODOs upstream (slot vazio em share, Action/ZOrder/SlotDisplay genéricos e deform ponderado), locales especiais, coerções/reflexão/proxies genéricos, controles/contexto fora dos tipos/offsets TS, length arbitrário de rawFrames, coeficientes de matriz não numéricos, Big Endian/payloads NaN arbitrários. Runtime Armature/Bone/Slot/Surface, solvers, aplicação de deformações, avaliação de timelines/playback/blending, factories, backend/LÖVE/GPU e contratos de engines. SkinData.NULL distinto de raw JSValue.NULL; ES5 indexado/UTF-16/WTF-8 preservados. Curvas/ZOrder/sortBones/clipping mantêm possíveis esperas originais; WorldClock usa os.time com resolução de segundos.

## Reprodução

```sh
npm ci --ignore-scripts --no-audit --no-fund
node tools/inventory.js ../DragonBonesJS --check
node tools/dependencies.js ../DragonBonesJS --check
for vm in lua5.4 luajit; do
  for suite in geom math baseobject models worldclock events config animationdata displaydata armaturedata constraintdata skindata dragonbonesdata boundingbox dataparser objectatlas structural geometryparser binaryarrays curveframes specialframes deformframes timelines animationparser armatureparser globalentry binaryutf8; do
    node tests/${suite}_differential.js ../DragonBonesJS "$vm"
  done
done
```

Upstream fixado. Consultar PR para evidência remota/SHA/merge/CI; não antecipar resultados futuros.

Próximo passo após os helpers: auditar e portar `_parseBinaryTimeline`, preservando offsets, frameIndices e referências reais; depois overrides e cabeçalho DBDT/JSON. Uint8 e decoder custom já têm comparação própria; não repetir como pendência integral.
