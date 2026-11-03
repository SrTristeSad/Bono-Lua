# Continuidade — Bono-Lua

## Objetivo permanente

Reconstruir em Lua DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e, preservando arquitetura, algoritmos e comportamentos. Destino único SrTristeSad/Bono-Lua. Comparação diferencial exigida; não declarar 100% com pendências.

## Base confirmada desta unidade

- Main 13ae3b1be3ed91e57a7215c01dd782d5b1df9b50, PR #71 integrado; CI pós-merge 41664512405 aprovada.
- Backup backup/pre-integral-rebuild-20261103 em cd4206a8ac091b1b26ad02b9ee4bc6ec7f30eeeb, preservado.
- Branch port/model-armature-data. Consultar PR/merge e CI posteriores antes de editar; não antecipar SHA futuro.
- Main acompanha checkpoints testados por autorização do proprietário. Não significa runtime completo.

## Unidade atual

ArmatureData/BoneData/SurfaceData/SlotData em dragonbones/model/ArmatureData.lua. TS e Lua do backup relidos integralmente; fontes TS de ConstraintData/SkinData/DragonBonesData também lidas para delimitar fronteiras. Construção usa BaseObject/Enums, Rectangle/Transform/ColorTransform e GeometryData reais.
Resultado final: 34 cenários, 1.079 operações, 15.106 colunas por VM Lua 5.4/LuaJIT, binary64 exato com NaN canonicalizado. Classes, campos/refs, identidades, listas/mapas, ordenação acíclica, callbacks/erros, pools e cache comparados.
Integração nova: AnimationData.cacheFrames percorre ArmatureData/BoneData/SurfaceData/SlotData reais. O registro de parent da suíte isolada anterior permanece teste isolado, não o suporte dessa integração. Outro registro parent.cachedFrames global ainda representa DragonBonesData em setCacheFrame/getCacheFrame.
Estado privado _referenceState distingue undefined do construtor e null após limpeza/atribuição nil em defaultSkin/defaultAnimation e BoneData.parent. Ambas leem nil externamente; decisões estritas preservadas. Não substituir por teste simples ==nil nem antecipar defaults. SurfaceData herda os acessores de parent.
Cache de transformações mantém offset base 0, resize de dez slots antes das leituras e x/y vindos de tx/ty. Índice efetivo de cada acesso é validado antes de +1, preservando casos subnormais. Experimentos com nil nas seleções padrão e sem validação do índice falharam nas linhas 56/372; código restaurado e execuções finais refeitas.

## Pendências explícitas

- ConstraintData/SkinData/DragonBonesData ainda são fronteiras de teste, detalhadas em docs/contracts/ArmatureDataReferences.md. Não são stubs de produto nem modelos portados. BoundingBoxData/typed buffers/parser também pendentes.
- sortBones mantém esperas originais por pai/constraint; não tem detector de ciclos ou limite novo. Testes usam grafos acíclicos; timeout 10s é do subprocesso de teste. Grafos que não terminam no original não são declarados resolvidos.
- Mapas não emulam Object.prototype; nil público não distingue universalmente null/undefined; rawset que burle acessores/metadados, descritores/proxies e arrays JS arbitrários não são equivalência declarada.
- WorldClock._now usa os.time em segundos de época com resolução de segundos; fonte determinística não prova equivalência de tempo automático a Date em milissegundos.
- Runtime Armature/Bone/Slot/Surface, solver de constraints, parsers, playback/timelines/blending, listeners/backend, factories, hit testing, deformação e GPU pendentes. Modelos de dados não completam runtime.

## Próxima unidade

1. Conferir main, backup, PRs/CI e ler status/mapa/decisões/diferenças/validação atuais.
2. Auditar model/ConstraintData.ts novamente e ler Lua real do backup. O arquivo tem base abstrata, IKConstraintData e PathConstraintData; referências BoneData/SlotData/PathDisplayData agora estão disponíveis. Preservar capitalização original AddBone e propriedade não proprietária dos vínculos/listas.
3. Depois preparar SkinData/DragonBonesData reais para substituir as fronteiras de display ownership/cache global com testes próprios. Em SkinData, null explícito em listas é diferente de hole/undefined; definir a adaptação conforme o original, sem encerrar silenciosamente a iteração.
4. Atualizar progresso/inventário, testar, publicar PR, conferir CI e integrar checkpoint autorizado, mantendo as demais pendências explícitas.

## Reprodução

```sh
git fetch origin
git switch main
git log -1 --format=fuller
git ls-remote --heads origin main backup/pre-integral-rebuild-20261103 port/model-armature-data
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
  node tests/displaydata_differential.js ../DragonBonesJS "$vm"
  node tests/armaturedata_differential.js ../DragonBonesJS "$vm"
done
```

../DragonBonesJS deve estar no commit fixado. Consultar o PR do checkpoint para SHA final e CI pós-merge; não confiar apenas na memória da conversa.

Checkpoint remoto: PR #72, código 5e77b9bf9454c3ea3e0b52190e8025adc252cea9. CI https://github.com/SrTristeSad/Bono-Lua/actions/runs/41672562343 aprovada nos jobs inventory, geometry (lua5.4) e geometry (luajit). Logs de ambas as VMs confirmaram dez suítes passed; novo lote 34 cenários/1.079 operações/15.106 colunas, incluindo cache com ArmatureData/BoneData/SurfaceData/SlotData reais. Três artefatos conferidos no mesmo SHA. Consultar PR #72 para SHA final, merge e CI pós-merge; este registro não antecipa merge.
