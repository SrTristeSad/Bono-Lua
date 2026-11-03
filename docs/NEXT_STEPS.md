# Continuidade — Bono-Lua

## Objetivo permanente

Reconstruir em Lua o DragonBonesJS oficial fixado em 64b6c69ae35777c2404be68c9192e2c56906079e, preservando arquitetura, algoritmos e comportamentos. Destino único SrTristeSad/Bono-Lua. Comparação diferencial exigida; não declarar 100% com pendências.

## Estado confirmado ao iniciar esta unidade

- Main 341df09f87faea5b5ab23fd22b21895d9c0ed9e7, PR #67 integrado; CI pós-merge 41586449745 aprovada.
- Backup backup/pre-integral-rebuild-20261103 em cd4206a8ac091b1b26ad02b9ee4bc6ec7f30eeeb, preservado.
- Branch port/core-events. Consultar PR/merge e CI posteriores no GitHub antes de editar; não antecipar SHA futuro.
- Main acompanha checkpoints testados conforme autorização do proprietário. Isso não significa runtime completo.

## Unidade atual

DragonBones.lua e Enums.lua no core, EventObject.lua, UserData.lua (UserData/ActionData), contrato IEventDispatcher/EventStringType documentado. Enums separados só para evitar ciclo de require; core reexporta a mesma fonte. Shims exclusivos JS documentados como fronteiras de linguagem, não plataformas implementadas.
Testes reais: 25 cenários, 1.147 operações, 16.058 colunas e 98 valores de enums por VM Lua 5.4/LuaJIT. Números binary64 exatos com NaN canonicalizado. Pool/clock/core/eventos/modelos reais; Armature/dispatcher/animatable são probes somente de teste. Comparados despacho, filas crescentes, reentrância, reciclagem adiada, identidade, falhas e payloads.
Falha real: índice subnormal de UserData arredondava ao primeiro elemento ao somar 1. Integralidade verificada antes do deslocamento; caso mantido. Experimento com == do backup nas filas foi rejeitado pelo teste; rawequal preservado e arquivo restaurado antes dos testes finais.

## Pendências explícitas

- Armature, três métodos de listeners de IEventDispatcher e backend real ainda não implementados/validados. Probes não contam como runtime.
- WorldClock._now padrão usa os.time em segundos de época com resolução de segundos. Provider determinístico não demonstra equivalência do relógio automático real a Date em milissegundos. Host pode fornecer fonte adequada; não substituir por timer monotônico com outra origem.
- Arrays de UserData são densos Lua/base 1, getters públicos base 0. Propriedades arbitrárias/esparsas/proxies JS, distinção universal null/undefined e reflexão genérica não são equivalência declarada.
- Parsers, armaduras, constraints, timelines/blending, factories e GPU continuam pendentes.

## Próxima unidade

1. Conferir main, backup, PRs e CI; ler status, mapa, decisões, diferenças e validação atuais.
2. Auditar model/AnimationConfig.ts completo e Lua real do backup. Conferir dependências estáticas e executáveis; BaseObject/enums agora estão disponíveis. Preparar comparação de defaults, copyFrom, arrays/aliases e pool sem usar testes antigos como evidência atual.
3. Escolher modelos seguintes conforme dependências reais; preparar Armature gradualmente sem classes/constantes provisórias de produto.
4. Atualizar progresso e inventário, testar, publicar PR, verificar CI e integrar checkpoint autorizado. Manter a pendência de precisão do tempo explícita.

## Reprodução

```sh
git fetch origin
git switch main
git log -1 --format=fuller
git ls-remote --heads origin main backup/pre-integral-rebuild-20261103 port/core-events
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
done
```

O checkout ../DragonBonesJS precisa estar no commit fixado. Consultar o PR do checkpoint para o SHA final e a CI pós-merge, sem confiar em memória da conversa.
