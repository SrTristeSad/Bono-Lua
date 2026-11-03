# Continuidade — Bono-Lua

## Objetivo permanente

Reconstruir em Lua DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e, preservando arquitetura, algoritmos e comportamentos. Destino único SrTristeSad/Bono-Lua. Comparação diferencial exigida; não declarar 100% com pendências.

## Base confirmada desta unidade

- Main 975b0312d984313e7645fcc8d0d10026e49205d7, PR #70 integrado; CI pós-merge 41651358553 aprovada.
- Backup backup/pre-integral-rebuild-20261103 em cd4206a8ac091b1b26ad02b9ee4bc6ec7f30eeeb, preservado.
- Branch port/model-display-data. Consultar PR/merge e CI posteriores antes de editar; não antecipar SHA futuro.
- Main acompanha checkpoints testados por autorização do proprietário. Não significa runtime completo.

## Unidade atual

Oito classes de DisplayData.ts em dragonbones/model/DisplayData.lua: GeometryData, DisplayData abstrata, ImageDisplayData, ArmatureDisplayData, MeshDisplayData, BoundingBoxDisplayData, PathDisplayData e WeightData. Original completo e Lua real do backup lidos. Executáveis reais BaseObject/Enums, Transform/Point e JSArray; testes também usam ActionData/UserData e TextureData reais.
Resultado final: 33 cenários, 1.117 operações, 10.053 colunas por VM Lua 5.4/LuaJIT, binary64 exato com NaN canonicalizado. Campos/identidades/compartilhamento/arrays/pools/ordem/falhas comparados. GeometryData não é poolável; base DisplayData não recebe chave concreta fictícia. Referências externas descritas em docs/contracts/DisplayDataReferences.md.
Falha real row 106: getter com offset sem inicialização lançava erro Lua em vez de undefined. Corrigido undefined numérico->NaN e índice validado depois de BinaryOffset, antes de base 1. Experimentos removendo essa validação e restaurando ipairs em ações falharam nas linhas 124/254; código restaurado e execuções finais refeitas.
Preservados shareFrom sem copiar data/inheritDeform/devolver peso anterior, peso próprio versus compartilhado, ações duplicadas/crescentes/esparsas e estado parcial em falhas. Bone refs/textures/skin/armature não são devolvidos; boundingBox é dono do contrato de retorno ainda não integrado ao modelo real.

## Pendências explícitas

- ArmatureData/BoneData/SurfaceData/SlotData ainda não portados; GeometryData agora está disponível para SurfaceData. ConstraintData/SkinData/DragonBonesData/BoundingBoxData reais continuam pendentes; registros de teste não substituem classes de produto.
- GeometryData.data.intArray é entrada Int16 já decodificada; não valida parser binário/typed arrays genéricos. Null/undefined de referências normalizam nil; holes/undefined por valor/length, sem descritores/proxies/Array.prototype ou coerções fora dos tipos declarados.
- Cache de AnimationData ainda usa parent de contrato no teste; integração real exige ArmatureData e seus bones/slots. Manter explícitos cacheFrames.length=aridade 1 e count zero reestendendo cachedFrames para 1.
- WorldClock._now padrão usa os.time em segundos de época com resolução de segundos. Fonte determinística não prova equivalência de tempo automático a Date em milissegundos.
- Parsers, armaduras, listeners/backend, constraints de runtime, timelines/blending/playback, factories, hit testing, deformação e GPU pendentes.

## Próxima unidade

1. Conferir main, backup, PRs/CI e ler status/mapa/decisões/diferenças/validação atuais.
2. Reler model/ArmatureData.ts completo e Lua real do backup. Dependências de construção agora incluem GeometryData real, Rectangle/Transform/ColorTransform existentes. Auditar referências remanescentes de ConstraintData/SkinData/DragonBonesData antes de definir integração.
3. Portar o lote conforme dependências reais, sem classes/constantes provisórias de produto. Exercitar sortedBones/sortedSlots e o cache de AnimationData com modelos reais quando disponíveis; não reclassificar provas de contrato como integração.
4. Atualizar progresso/inventário, testar, publicar PR, conferir CI e integrar checkpoint autorizado, mantendo pendências de plataforma e runtime explícitas.

## Reprodução

```sh
git fetch origin
git switch main
git log -1 --format=fuller
git ls-remote --heads origin main backup/pre-integral-rebuild-20261103 port/model-display-data
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
done
```

../DragonBonesJS deve estar no commit fixado. Consultar o PR do checkpoint para SHA final e CI pós-merge; não confiar apenas na memória da conversa.

Checkpoint remoto: PR #71, código ff97d497f1392f9142aab71fe57bead8e1a6e292. CI https://github.com/SrTristeSad/Bono-Lua/actions/runs/41664061129 aprovada nos jobs inventory, geometry (lua5.4) e geometry (luajit). Logs de ambas as VMs confirmaram nove suítes passed; novo lote 33 cenários/1.117 operações/10.053 colunas. Três artefatos conferidos no mesmo SHA. Consultar PR #71 para SHA final, merge e CI pós-merge; este registro não antecipa merge.
