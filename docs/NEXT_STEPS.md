# Continuidade — Bono-Lua

## Objetivo permanente

Reconstruir em Lua DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e, preservando arquitetura, algoritmos e comportamentos. Destino único SrTristeSad/Bono-Lua. Comparação diferencial exigida; não declarar 100% com pendências.

## Base confirmada desta unidade

- Main 2e25e30c388a324aa314363038e98ceca649858e, PR #73 integrado; CI pós-merge 41677323508 aprovada.
- Backup backup/pre-integral-rebuild-20261103 em cd4206a8ac091b1b26ad02b9ee4bc6ec7f30eeeb, preservado.
- Branch port/model-skin-data. Consultar PR/merge e CI posteriores antes de editar; não antecipar SHA futuro.
- Main acompanha checkpoints testados por autorização do proprietário. Não significa runtime completo.

## Unidade atual

SkinData em dragonbones/model/SkinData.lua, com BaseObject/JSArray/JSMap e modelos de display/armadura reais. TS completo e Lua real do backup lidos. Construtor só cria displays; não antecipar name/parent.
Resultado final: 29 cenários, 814 operações, 8.140 colunas por VM Lua 5.4/LuaJIT, binary64 exato com NaN canonicalizado. Skin/armadura/displays/geometria/pesos e ações/UserData reais; callbacks/setters só observam instâncias, sem skin stub. Cinco sequências determinísticas de 80 operações.
Listas: SkinData.NULL representa null explícito por rawequal; nil lido dentro de length é undefined/hole e produz erro no lookup/clear. addDisplay(slot,nil) é null explícito; argumento omitido representa undefined e falha após criar lista. Consumidores de getDisplays devem reconhecer o marcador truthy, conforme docs/contracts/SkinDataLists.md, sem usar if value como se equivalesse ao JS.
Preservados parent antes do push, leitura da lista depois do setter, ordem canônica/inserção, duplicatas/compartilhamento e retorno repetido. Chave criada em callback durante clear pode sobreviver à enumeração e ao retorno/reuso do pool, como no original executado. getMesh não ganha filtro de tipo além do cast TS apagado.
Experimentos com ipairs e argumento omitido tratado como null falharam em rows 65/77; código restaurado e execuções finais refeitas. Overflow conserva parent/propriedade não índice antes de RangeError; falhas de peso/display/skin/armadura mantêm estado parcial.

## Pendências explícitas

- DragonBonesData global ainda é fronteira de armazenamento em outros testes; classe real, buffers tipados/parsers e BoundingBoxData pendentes.
- Modelos de skin não implementam seleção/renderização de skins no runtime. Armature/Bone/Slot/Surface de runtime, solvers IK/Path, deformação, playback/timelines/blending, factories/backend/GPU continuam pendentes.
- Mapas não emulam Object.prototype; hole/undefined próprios normalizam descritores por valor/length, distinguindo null explícito. Refs fora de listas normalizam null/undefined para nil; proxies/coerções/reflexão genéricos e rawset que burle metadados não são equivalência declarada.
- sortBones conserva esperas originais por pai/alvo; testes só executam grafos acíclicos, sem detector de ciclos/timeout no produto.
- WorldClock._now usa os.time em segundos de época com resolução de segundos; testes determinísticos não provam tempo automático equivalente ao Date em milissegundos.

## Próxima unidade

1. Conferir main, backup, PRs/CI e ler estado/mapa/decisões/diferenças/validação atuais.
2. Auditar model/DragonBonesData.ts completo e Lua real do backup. Definir representação de arrays numéricos/mapa de armaduras e referências a buffers tipados conforme o original; não inventar parser/binário ou antecipar defaults.
3. Exercitar DragonBonesData com ArmatureData/SkinData/displays reais para substituir armazenamento global e cadeia de ownership por integração efetiva. Manter claros os limites de buffers já decodificados versus parsing/typed arrays completos.
4. Atualizar progresso/inventário, testar, publicar PR, conferir CI e integrar checkpoint autorizado, mantendo as demais pendências explícitas.

## Reprodução

```sh
git fetch origin
git switch main
git log -1 --format=fuller
git ls-remote --heads origin main backup/pre-integral-rebuild-20261103 port/model-skin-data
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
  node tests/constraintdata_differential.js ../DragonBonesJS "$vm"
  node tests/skindata_differential.js ../DragonBonesJS "$vm"
done
```

../DragonBonesJS deve estar no commit fixado. Consultar o PR do checkpoint para SHA final e CI pós-merge; não confiar apenas na memória da conversa.


Checkpoint remoto: PR #74, código c5e6490abc9e67b7a9fafb94c5838944b047bbc3. CI https://github.com/SrTristeSad/Bono-Lua/actions/runs/41680927368 aprovada: inventory, geometry (lua5.4) e geometry (luajit). Logs confirmaram doze suítes passed em ambas as VMs; SkinData: 29 cenários/814 operações/8.140 colunas. Três artefatos conferidos no mesmo SHA. Consultar PR #74 para SHA final, merge e CI pós-merge; este registro não antecipa merge.
