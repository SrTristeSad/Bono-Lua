# Continuidade — Bono-Lua

## Objetivo permanente

Reconstruir em Lua DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e, preservando arquitetura, algoritmos e comportamentos. Destino único SrTristeSad/Bono-Lua. Comparação diferencial exigida; não declarar 100% com pendências.

## Base confirmada desta unidade

- Main 57e7d48dc2c1e47cccc0fbd07db0b32297017c60, PR #72 integrado; CI pós-merge 41673223815 aprovada.
- Backup backup/pre-integral-rebuild-20261103 em cd4206a8ac091b1b26ad02b9ee4bc6ec7f30eeeb, preservado.
- Branch port/model-constraint-data. Consultar PR/merge e CI posteriores antes de editar; não antecipar SHA futuro.
- Main acompanha checkpoints testados por autorização do proprietário. Não significa runtime completo.

## Unidade atual

ConstraintData/IKConstraintData/PathConstraintData em dragonbones/model/ConstraintData.lua, com BaseObject/Enums/JSArray reais. TS integral e Lua real do backup lidos. Base abstrata permanece sem chave de pool concreta; construtores não antecipam defaults; Path só cria bones.
Resultado final: 23 cenários, 817 operações, 7.353 colunas por VM Lua 5.4/LuaJIT, binary64 exato com NaN canonicalizado. Campos, referências não proprietárias, aliases/length/pool, erros e integração com ArmatureData/bones/slots/path display reais comparados. Cinco sequências determinísticas de 80 operações.
Peculiaridade original preservada: Path._onClear mantém type=IK da base, sem reset para Path. AddBone mantém A maiúsculo e não ganha alias addBone. Em overflow de push, propriedade JS 4294967295 (Lua 4294967296) é escrita antes de length=2^32 falhar; ela sobrevive ao clear do length. Não remover a atribuição final de length nem iterar para devolver bones não proprietários.
Experimentos com reset de tipo inventado e remoção do passo final de length foram rejeitados nas linhas 30/107; código restaurado e testes finais refeitos. Nenhuma classe fictícia ou probe substitui constraints na nova suíte; a antiga suíte isolada armaturedata mantém seus probes.

## Pendências explícitas

- SkinData/DragonBonesData reais ainda são fronteiras de teste em outros modelos; BoundingBoxData/typed buffers/parsers pendentes.
- ConstraintData é modelo, não IKConstraint/PathConstraint de runtime. Solver, deformação, runtime Armature/Bone/Slot/Surface, playback, listeners/backend, factories/GPU pendentes.
- sortBones conserva esperas originais por pais/alvos; testes só executam grafos acíclicos, sem detector/timeout no produto. Timeout 10s do subprocesso é infraestrutura.
- Null/undefined de refs normalizam nil (com decisões estritas específicas já adaptadas em ArmatureData); holes/undefined por valor/length. Proxies/descritores/Object.prototype/rawset que burle metadados não são equivalência genérica.
- WorldClock._now usa os.time em segundos de época com resolução de segundos; testes determinísticos não comprovam tempo automático equivalente a Date em milissegundos.

## Próxima unidade

1. Conferir main, backup, PRs/CI e ler estado/mapa/decisões/diferenças/validação atuais.
2. Auditar model/SkinData.ts completo e Lua real do backup. Preservar parent dos displays, duplicatas, ordem, null explícito versus hole/undefined e regras de devolução. Não encerrar listas com ipairs nem tratar posições vazias como null silenciosamente.
3. Exercitar SkinData com ArmatureData e DisplayData reais para substituir a fronteira getDisplay/returnToPool. Depois preparar DragonBonesData e seus dados globais/typed buffers conforme dependências originais, sem stubs de produto.
4. Atualizar progresso/inventário, testar, publicar PR, conferir CI e integrar checkpoint autorizado, mantendo as demais pendências explícitas.

## Reprodução

```sh
git fetch origin
git switch main
git log -1 --format=fuller
git ls-remote --heads origin main backup/pre-integral-rebuild-20261103 port/model-constraint-data
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
done
```

../DragonBonesJS deve estar no commit fixado. Consultar o PR do checkpoint para SHA final e CI pós-merge; não confiar apenas na memória da conversa.

Checkpoint remoto: PR #73, código db0c8806dfb903427ff51c47cfae58733571a391. CI https://github.com/SrTristeSad/Bono-Lua/actions/runs/41676866452 aprovada nos jobs inventory, geometry (lua5.4) e geometry (luajit). Logs de ambas as VMs confirmaram onze suítes passed; novo lote 23 cenários/817 operações/7.353 colunas com integração de constraints reais. Três artefatos conferidos no mesmo SHA. Consultar PR #73 para SHA final, merge e CI pós-merge; este registro não antecipa merge.
