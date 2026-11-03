# Continuidade — Bono-Lua

## Objetivo permanente

Reconstruir em Lua DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e preservando arquitetura, algoritmos e comportamentos. Destino único SrTristeSad/Bono-Lua. Comparação diferencial exigida; não declarar completude com pendências.

## Base desta unidade

- main 0a156d2eac8df3b1908da5cd95c67b7fafd23c46, PR #74 integrado, CI pós-merge 41681556890 aprovada.
- Backup remoto backup/pre-integral-rebuild-20261103 em cd4206a8ac091b1b26ad02b9ee4bc6ec7f30eeeb conferido intacto.
- Unidade port/model-dragonbones-data; conferir PR/SHA/CI/merge atuais antes de editar. Main acompanha checkpoints testados por autorização do proprietário.

## Unidade implementada

DragonBonesData.ts e Lua integral do backup lidos. dragonbones/model/DragonBonesData.lua mantém inicializadores, mapa em ordem, arrays lógicos com identidade/length/extras, ownership das armaduras/userData, stage/buffers não proprietários. Não traz setBinaryBuffer/_binaryBuffer do backup ausentes na fonte TS; parser/typed views têm contrato próprio pendente.

32 cenários, 851 operações e 11.063 colunas por VM Lua 5.4/LuaJIT, binary64 exato com NaN canonicalizado. DragonBonesData/ArmatureData/SkinData/displays/geometria/pesos/AnimationData reais; cache Matrix/Transform com offset público zero-based. Buffers/views JS genuínos no oráculo versus valores Lua já decodificados de fronteira, sem implementação de typed views. Experimentos de trocar array público e inserir mapa antes de parent foram rejeitados; código restaurado e resultados finais refeitos.

## Próxima unidade

1. Conferir main, backup, PRs e CI. Ler estado/progresso/mapa/validação/decisões/diferenças.
2. Auditar model/BoundingBoxData.ts completo e Lua real do backup; preservar todos os tipos de bounding boxes, interseções, retornos, normais e casos limites.
3. Testar contra TS executado com modelos de display reais, sem confundir dados de hit testing com backend gráfico.
4. Atualizar inventário/documentação, publicar PR, conferir CI e integrar checkpoint autorizado.

## Pendências

- BoundingBoxData e parsers/ArrayBuffer/typed views reais. Referências de buffers neste modelo não provam decodificação/compartilhamento binário.
- Armature/Bone/Slot/Surface de runtime, solvers IK/Path, deformação, playback/timelines/blending, factories, backend/LÖVE/GPU e contratos de engines.
- SkinData.NULL é truthy em Lua; consumidores devem reconhecer marcador por identidade. Não usar if display como equivalente ao JS.
- Mapas não emulam Object.prototype; descritores/proxies/coerções genéricas não são equivalência declarada. Referências JS null/undefined normalizam nil, salvo decisões estritas já documentadas.
- sortBones conserva esperas originais; testes usam grafos acíclicos, sem detector/timeout no produto.
- WorldClock._now usa os.time com resolução de segundos; testes determinísticos não provam precisão automática equivalente ao Date em ms.

## Reprodução

```sh
npm ci --ignore-scripts --no-audit --no-fund
node tools/inventory.js ../DragonBonesJS --check
node tools/dependencies.js ../DragonBonesJS --check
for vm in lua5.4 luajit; do
  for suite in geom math baseobject models worldclock events config animationdata displaydata armaturedata constraintdata skindata dragonbonesdata; do
    node tests/${suite}_differential.js ../DragonBonesJS "$vm"
  done
done
```

Upstream deve estar no commit fixado. CI preserva transcrições/JSON por VM. Consultar PR para SHA final, merge e CI pós-merge; não antecipar evidências futuras.
