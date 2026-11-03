# Continuidade — Bono-Lua

## Objetivo permanente

Reconstruir em Lua DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e, preservando arquitetura, algoritmos e comportamentos. Destino único SrTristeSad/Bono-Lua. Comparação diferencial exigida; não declarar 100% com pendências.

## Base confirmada desta unidade

- Main b45b575d6a61fec17068f78f700a22b1bf9799b0, PR #69 integrado; CI pós-merge 41646190037 aprovada.
- Backup backup/pre-integral-rebuild-20261103 em cd4206a8ac091b1b26ad02b9ee4bc6ec7f30eeeb, preservado.
- Branch port/model-animation-data. Consultar PR/merge e CI posteriores antes de editar; não antecipar SHA futuro.
- Main acompanha checkpoints testados por autorização do proprietário. Não significa runtime completo.

## Unidade atual

AnimationData/TimelineData/AnimationTimelineData em dragonbones/model/AnimationData.lua com BaseObject/Enums reais. TS integrais e Lua reais de AnimationData/ArmatureData lidos. Parent só é lido por sortedBones/sortedSlots/name; contratos em docs/contracts/AnimationDataParent.md. Registros/getters de parent somente no teste, sem ArmatureData fictício de produto.
JSArray/JSMap extraídos de AnimationConfig/TextureAtlasData para reutilizar length lógico e ordem própria JS. Ambas as regressões passaram novamente nas duas VMs (config 30/1.293/10.344; models 18/639/5.751).
Lote final AnimationData: 39 cenários, 1.084 operações, 11.924 colunas por VM Lua 5.4/LuaJIT, binary64 exato com NaN canonicalizado. Campos/identidades/mapas/listas/cache/pools/ordem/falhas comparados. Parent e listas podem falhar durante leitura; estado parcial e sequência preservados.
Peculiaridade original: cacheFrames.length é aridade 1 da função. Só posição JS 0 vira false; count zero ainda cresce cachedFrames para length=1, mas índices por bone/slot ficam vazios. Não preencher tudo nem usar math.min(1,count). Experimentos temporários com clamp e == do backup foram rejeitados; código restaurado antes dos testes finais. Raw new em cache exige interpretar campos numéricos undefined como NaN, preservando atualização do rate e RangeError, sem erro Lua precoce.

## Pendências explícitas

- ArmatureData/BoneData/SurfaceData/SlotData não portados. A auditoria mostrou GeometryData de DisplayData instanciado por SurfaceData, além de sort, constraints/skins e cache de dez componentes em DragonBonesData. Parent de teste não valida isso.
- Mapas não emulam Object.prototype. Holes/undefined normalizam por valor/length, refs null/undefined por nil; descritores/proxies/reflexão genérica e redefinição de Function.length não são equivalência declarada.
- WorldClock._now padrão usa os.time em segundos de época com resolução de segundos. Fonte determinística não comprova equivalência da fonte automática real a Date em milissegundos.
- Parsers, armaduras, listeners/backend, constraints, timelines/blending/playback, factories e GPU pendentes.

## Próxima unidade

1. Conferir main, backup, PRs/CI; ler status/mapa/decisões/diferenças/validação atuais.
2. Auditar model/DisplayData.ts completo e Lua real do backup, especialmente GeometryData/WeightData e dependências executáveis. Definir o lote a partir dos originais, sem classes/constantes provisórias de produto.
3. Preparar ArmatureData depois das dependências reais. Só declarar integração do cache de AnimationData quando exercitada com ArmatureData/BoneData/SlotData reais; manter a fronteira de teste explícita.
4. Atualizar progresso/inventário, testar, publicar PR, conferir CI e integrar checkpoint autorizado, mantendo precisão temporal e demais pendências.

## Reprodução

```sh
git fetch origin
git switch main
git log -1 --format=fuller
git ls-remote --heads origin main backup/pre-integral-rebuild-20261103 port/model-animation-data
npm ci --ignore-scripts --no-audit --no-fund
node tools/inventory.js ../DragonBonesJS --check
node tools/dependencies.js ../DragonBonesJS --check
for vm in lua5.4 luajit; do
  node tests/geom_differential.js ../DragonBonesJS "$vm"
  node tests/math_differential.js ../DragonBonesJS "$vm"
  node tests/baseobject_differential.js ../DragonBonesJS "$vm"
  node tests/models_differential.js ../DragonBonesJS "$vm"
  node tests/worldclock_differential.js ../DragonBonesJS "$vm"
  node tests/events_differential.js ../DragonBonesJS "$vm"
  node tests/config_differential.js ../DragonBonesJS "$vm"
  node tests/animationdata_differential.js ../DragonBonesJS "$vm"
done
```

../DragonBonesJS deve estar no commit fixado. Consultar PR do checkpoint para SHA final e CI pós-merge; não confiar apenas na memória da conversa.

Checkpoint remoto: PR #70, código 2b612757c2bfee0011db97cc3abea1a7de19625d. CI https://github.com/SrTristeSad/Bono-Lua/actions/runs/41650945111 aprovada nos jobs inventory, geometry (lua5.4) e geometry (luajit). Logs de ambas as VMs confirmaram oito suítes passed; novo lote 39 cenários/1.084 operações/11.924 colunas. Três artefatos conferidos no mesmo SHA. Consultar PR #70 para SHA final, merge e CI pós-merge; este registro não antecipa merge.
