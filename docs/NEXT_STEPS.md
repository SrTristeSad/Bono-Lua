# Continuidade — Bono-Lua

## Objetivo permanente

Reconstruir em Lua DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e preservando arquitetura/algoritmos/comportamentos. Destino SrTristeSad/Bono-Lua. Não declarar completude com pendências.

## Base desta unidade

- main a2a3fe7216a8445351be86967db4e5c13fb59bb0, PR #79, CI pós-merge 41700176642 aprovada.
- Backup backup/pre-integral-rebuild-20261103 em cd4206a8ac091b1b26ad02b9ee4bc6ec7f30eeeb conferido.
- Branch port/parser-geometry-skins; conferir PR/SHA/CI/merge atuais. Main acompanha checkpoints testados por autorização do proprietário.

## Unidade implementada

Sete corpos TS/Lua do backup auditados: _parseGeometry/_parseArray/_parseBone/_parsePath/_parseMesh/_parseDisplay/_parseSkin; dependências reais, sem stubs. Total 21/47 métodos; 26 ausentes, incluindo _parseArmature, animações/timelines, _modifyArray e parseDragonBonesData.

53 cenários/2.498 operações/34.972 colunas por VM Lua 5.4/LuaJIT, binary64 exato/NaN canonicalizado/zero assinado exato. Modelos e matrizes reais, poses com/sem bonePose, estado de arrays/offsets/caches/órfãos/erros e cadeia de retorno. Matriz propaga undefined como NaN em invert/transformPoint; math_differential anterior passou nas duas VMs (2.463/12.231/158, mesmas 52 diferenças trig previstas). Marcadores raw e SkinData.NULL distintos.

Mantidos holes em reservas, floor(length−vertexCount)/2, reserva anterior a weightBoneCount e loop weightCount sem poses. Mutantes do loop e floor rejeitados nas linhas 331/890; produto restaurado e testes finais refeitos. SHARE fica deferido, caches guardam refs; ações seguem comprimento vivo/índice de display e erros conservam _skin/_slot. Teste liga arrays ao modelo global só como armazenamento já decodificado; não existe finalização binária. Ver contracts/GeometryParser.md. Dezoito suítes na CI.

## Próximo recorte

1. Conferir main/backup/PRs/CI e ler estado/progresso/mapa/validação/decisões/diferenças.
2. Auditar _modifyArray integral e Lua do backup, inclusive buffer compartilhado, alinhamento e as sete views. Não copiar bytes independentemente quando a fonte compartilha memória.
3. Implementar representação ArrayBuffer/views e coerções/endianness/alinhamento/Float32/Int16/Uint16 com testes de bytes e aliasing contra o original; integrar DragonBonesData e geometria reais.
4. Depois, curvas/frames/timelines/animações e _parseArmature/entrypoint exigem dependências completas. Métodos ausentes não devem receber resultados fabricados.
5. Atualizar inventário/docs, publicar PR, validar CI e integrar checkpoint autorizado.

## Pendências

26 métodos de ObjectDataParser; texto JSON/importação completa de armaduras/animações/DBDT, typed arrays/ArrayBuffer, locales especiais de DataParser, coerções/reflexão/proxies genéricos (incluindo coeficientes de matriz fora do tipo numérico). Runtime Armature/Bone/Slot/Surface, solvers, deformação, playback/blending, factories, backend/LÖVE/GPU e contratos de engines. SkinData.NULL é truthy e distinto do raw JSValue.NULL. Loops ES5 indexados/UTF-16 (surrogates WTF-8 no Lua) preservados. sortBones/clipping mantêm possíveis esperas originais; WorldClock ainda usa os.time com resolução de segundos.

## Reprodução

```sh
npm ci --ignore-scripts --no-audit --no-fund
node tools/inventory.js ../DragonBonesJS --check
node tools/dependencies.js ../DragonBonesJS --check
for vm in lua5.4 luajit; do
  for suite in geom math baseobject models worldclock events config animationdata displaydata armaturedata constraintdata skindata dragonbonesdata boundingbox dataparser objectatlas structural geometryparser; do
    node tests/${suite}_differential.js ../DragonBonesJS "$vm"
  done
done
```

Upstream fixado. Consultar PR para evidência remota/SHA/merge/CI; não antecipar resultados futuros.
