# Continuidade — Bono-Lua

## Objetivo permanente

Reconstruir em Lua DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e, preservando arquitetura, algoritmos e comportamentos. Destino único SrTristeSad/Bono-Lua. Comparação diferencial exigida; não declarar 100% com pendências.

## Base confirmada desta unidade

- Main bc74a1a5206fe41c13717200613e81f4f65035f9, PR #68 integrado; CI pós-merge 41635078122 aprovada.
- Backup backup/pre-integral-rebuild-20261103 em cd4206a8ac091b1b26ad02b9ee4bc6ec7f30eeeb, preservado.
- Branch port/model-animation-config. Consultar PR/merge e CI posteriores antes de editar; não antecipar SHA futuro.
- Main acompanha checkpoints testados conforme autorização do proprietário. Isso não significa runtime completo.

## Unidade atual

AnimationConfig em dragonbones/model/AnimationConfig.lua. Original e Lua real do backup lidos; usa BaseObject e Enums reais. Preservados new sem defaults antecipados, clear/toString, todos os 21 campos e ordem de copyFrom, incluindo timeScale=-100.0.
Máscara permanece a mesma tabela durante cópia/limpeza, com entradas base 1 e length lógico, incluindo posições sem valor. Para adicionar: m[m.length+1]=nome; para dimensionar: m.length=n; para delete JS: rawset(m,index,nil), sem estender length. #/ipairs/table.insert não substituem length em máscaras esparsas.
Testes finais reais: 30 cenários, 1.293 operações e 10.344 colunas por VM Lua 5.4/LuaJIT, números binary64 exatos com NaN canonicalizado. Máscaras, aliases, pool, erros de length/limite e leituras/falhas de origem comparados. Experimento restaurando # em copyFrom foi rejeitado na linha 61; produto restaurado e execuções finais refeitas. Driver delete corrigido para rawset(...,nil), sem mudar expectativas originais.

## Pendências explícitas

- Consumo de AnimationConfig por Animation/AnimationState e armaduras reais ainda não implementado/validado. Tipos apagados e probes não contam como classes portadas.
- WorldClock._now padrão usa os.time em segundos de época com resolução de segundos. Provider determinístico não prova equivalência da fonte automática real a Date em milissegundos. Não substituir por timer monotônico com outra origem.
- Listeners/Armature/backend real, parsers, constraints, timelines/blending, factories e GPU pendentes.
- UserData mantém arrays densos; AnimationConfig tem length lógico. Máscara normaliza holes/undefined por valor/comprimento, sem descritores/proxies/protótipos JS. Manipulação que burle metadados, reflexão genérica e distinção universal null/undefined não são equivalência declarada.

## Próxima unidade

1. Conferir main, backup, PRs/CI e ler estado/mapa/decisões/diferenças/validação atuais.
2. Auditar model/AnimationData.ts completo e Lua real do backup. O relatório aponta BaseObject/core/ArmatureData; distinguir referências de tipo das operações reais de cache que acessam parent.
3. Definir o recorte conforme dependências reais: TimelineData/AnimationTimelineData são classes no mesmo arquivo; AnimationData tem cache, mapas e acesso a ArmatureData. Não introduzir ArmatureData ou constantes provisórias de produto para contornar dependências. Auditar ArmatureData antes de decidir integração.
4. Atualizar progresso/inventário, testar, publicar PR, verificar CI e integrar checkpoint autorizado. Manter precisão do tempo e demais pendências explícitas.

## Reprodução

```sh
git fetch origin
git switch main
git log -1 --format=fuller
git ls-remote --heads origin main backup/pre-integral-rebuild-20261103 port/model-animation-config
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
done
```

../DragonBonesJS deve estar no commit fixado. Consultar o PR do checkpoint para SHA final e CI pós-merge; não confiar apenas na memória da conversa.

Checkpoint remoto: PR #69, código 52b1ded46b858d3bfd941c399e182bc0a3239d3d. CI https://github.com/SrTristeSad/Bono-Lua/actions/runs/41645915590 aprovada nos jobs inventory, geometry (lua5.4) e geometry (luajit). Logs de ambas as VMs confirmaram sete suítes passed, incluindo AnimationConfig com 30 cenários/1.293 operações/10.344 colunas/21 campos escalares. Três artefatos conferidos no mesmo SHA. Consultar PR #69 para SHA final, merge e CI pós-merge; este registro não antecipa merge.
