# Continuidade — Bono-Lua

## Objetivo permanente

Reconstruir em Lua o DragonBonesJS oficial fixado em 64b6c69ae35777c2404be68c9192e2c56906079e, preservando arquitetura, algoritmos e comportamentos. Destino único SrTristeSad/Bono-Lua. Equivalência precisa de execução diferencial; não declarar 100% com pendências.

## Estado confirmado ao iniciar

- Main e9ed0c9903e21dc749b034c138d0974c59518f3c; PR #66 integrado; CI pós-merge 41583759197 aprovada.
- Backup backup/pre-integral-rebuild-20261103 em cd4206a8ac091b1b26ad02b9ee4bc6ec7f30eeeb, intacto.
- Branch desta unidade port/animation-worldclock. Consultar checkpoint/PR/merge e CI posteriores no GitHub; não antecipar SHA futuro.
- Main recebe checkpoints testados conforme autorização do proprietário. Não confundir isso com runtime completo.

## Trabalho atual

WorldClock em dragonbones/animation/WorldClock.lua e IAnimatable em docs/contracts/IAnimatable.md. A interface não vira uma classe fictícia.
Execuções locais: 28 cenários, 1.633 operações e 11.431 colunas por VM (Lua 5.4.8/LuaJIT), binary64 exato com NaN canonicalizado, fonte Date determinística. Campos, lista/length/null/undefined, hierarquia, callbacks, ordem e efeitos parciais de erro comparados.
Corrigidos __eq interferindo na identidade e ipairs encerrando clear antes de undefined criado por reentrância; length lógico e erros de resize preservam o original.
**Pendência conhecida:** default _now usa os.time em segundos de época, resolução de segundos. A fonte real do modo automático não está comprovada equivalente a Date em milissegundos. _now recebe função que devolve segundos de época com resolução adequada; não usar timer monotônico de LÖVE como se tivesse a mesma origem. O teste preflight confere essa distinção de origem, sem alegar precisão real de milissegundos.
Cinco classes geométricas, BaseObject e três modelos de dados já estão presentes; integração de Armature/renderização continua pendente.

## Próxima unidade

1. Conferir main, backup, PRs e CI; ler status/mapa/validação/decisões/inventário e os códigos reais antes de editar.
2. Ler core/DragonBones.ts inteiro (incluindo enums e shims JS), event/EventObject.ts, model/UserData.ts e event/IEventDispatcher.ts no commit fixado, comparando com o Lua real do backup.
3. Determinar a carga dos módulos/enums Lua para respeitar dependências e a referência original sem constantes fictícias. Portar fila/retorno de objetos e despacho de eventos com WorldClock/BaseObject reais e comparação diferencial. Probes de Armature/dispatcher apenas no teste não contam como produto portado.
4. Manter explícito o bloqueio da fonte de tempo automática: não declarar resolvido por injetar tempo determinístico nos testes.
5. Atualizar progresso/relatórios, testar, publicar PR, confirmar CI e integrar checkpoint autorizado. Parsers/armaduras/constraints/animação/factories/GPU e auditoria integral permanecem pendentes.

## Reprodução

```sh
git fetch origin
git switch port/animation-worldclock
git log -1 --format=fuller
git ls-remote --heads origin main backup/pre-integral-rebuild-20261103 port/animation-worldclock
npm ci --ignore-scripts --no-audit --no-fund
node tools/inventory.js ../DragonBonesJS --check
node tools/dependencies.js ../DragonBonesJS --check
node tests/geom_differential.js ../DragonBonesJS lua5.4
node tests/math_differential.js ../DragonBonesJS lua5.4
node tests/baseobject_differential.js ../DragonBonesJS lua5.4
node tests/models_differential.js ../DragonBonesJS lua5.4
node tests/worldclock_differential.js ../DragonBonesJS lua5.4
node tests/geom_differential.js ../DragonBonesJS luajit
node tests/math_differential.js ../DragonBonesJS luajit
node tests/baseobject_differential.js ../DragonBonesJS luajit
node tests/models_differential.js ../DragonBonesJS luajit
node tests/worldclock_differential.js ../DragonBonesJS luajit
```

O checkout ../DragonBonesJS deve estar no commit fixado. A memória da conversa não substitui código, SHAs e evidências no GitHub.
