# Continuidade — Bono-Lua

## Objetivo permanente

Reconstruir em Lua DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e preservando arquitetura, algoritmos e comportamentos. Destino único SrTristeSad/Bono-Lua. Não declarar completude com pendências.

## Base desta unidade

- main 771b932f065cce3570c8073a8529a2b130ed0f1e, PR #77 integrado, CI pós-merge 41693321632 aprovada.
- Backup backup/pre-integral-rebuild-20261103 em cd4206a8ac091b1b26ad02b9ee4bc6ec7f30eeeb conferido.
- Branch port/parser-object-atlas; consultar PR/SHA/CI/merge atuais. Main acompanha checkpoints testados por autorização do proprietário.

## Unidade implementada

ObjectDataParser parcial: três helpers, parseTextureAtlasData, getInstance, 38 inicializadores e ActionFrame. Recortes TS/Lua do backup auditados; arquivo inteiro enumerado estruturalmente (47 métodos/39 propriedades), sem afirmar auditoria semântica dos 42 métodos restantes. Não há parseDragonBonesData nem stubs. Lista em contracts/ObjectDataParserAtlas.md.

JSValue adapta objetos já decodificados, NULL/UNDEFINED explícitos, arrays marcados base 1/length e coerções primitivas; não decodifica JSON ou buffers. Helpers preservam presença, bools/NaN/zero, null versus undefined/defaults, String/Number e arrays vazios. Atlas/texturas/retângulos/pool reais; backend factory apenas no teste. Regiões não são multiplicadas pela escala. Fila privada injetada só no teste, pós-incremento antes da recursão, estado parcial e releitura do campo vivo preservados.

39 cenários/2.572 operações/28.292 colunas em Lua 5.4/LuaJIT; binary64 exato, NaN canonicalizado e sinal do zero exato. Inclui factory e conversão falhando após alocação, duplicatas/órfãos, frame, filas esparsas/null/undefined, comprimento capturado e mudança da fila em callback, singleton/ActionFrame. Mutantes de undefined como default e escala nas coordenadas rejeitados nas linhas 131/2.176; produto restaurado e testes finais refeitos. Dezesseis suítes na CI.

## Próximo recorte

1. Conferir main/backup/PRs/CI e ler estado/progresso/mapa/validação/decisões/diferenças.
2. Auditar os corpos TS/Lua estruturais de _parseArmature/_parseBone/_parseIKConstraint/_parsePathConstraint/_parseSlot/_parseSkin/_parseDisplay e dependências transitivas.
3. Portar blocos completos comparáveis com modelos reais; helpers de transform/color/ações e curvas devem seguir os originais quando necessários. Não fornecer entrypoint parseDragonBonesData sem suas dependências reais.
4. Manter granularidade de métodos: os 42 restantes estão ausentes; arquivo mapeado não significa parser completo. Depois do estrutural, animações/timelines/geometria e buffers exigem provas próprias.
5. Atualizar inventário/docs, publicar PR, validar CI e integrar checkpoint autorizado.

## Pendências

Texto JSON, parsing completo de armaduras/animações/DBDT, typed arrays/ArrayBuffer compartilhados, coerções JS/protótipos genéricos, locales especiais de DataParser. Runtime Armature/Bone/Slot/Surface, solvers, deformação, playback/blending, factories e backend/LÖVE/GPU continuam pendentes. SkinData.NULL é truthy; raw JSValue.NULL é outro marcador. sortBones e clipping mantêm possíveis esperas/não terminação originais; nenhum fallback novo. WorldClock ainda usa os.time com resolução de segundos, sem prova de precisão automática em ms.

## Reprodução

```sh
npm ci --ignore-scripts --no-audit --no-fund
node tools/inventory.js ../DragonBonesJS --check
node tools/dependencies.js ../DragonBonesJS --check
for vm in lua5.4 luajit; do
  for suite in geom math baseobject models worldclock events config animationdata displaydata armaturedata constraintdata skindata dragonbonesdata boundingbox dataparser objectatlas; do
    node tests/${suite}_differential.js ../DragonBonesJS "$vm"
  done
done
```

Upstream no commit fixado. Consultar PR para evidência remota/SHA/merge/CI; não antecipar resultados futuros.
