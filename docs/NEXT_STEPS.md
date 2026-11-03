# Continuidade — Bono-Lua

## Objetivo permanente

Reconstruir o DragonBonesJS oficial em Lua, preservando arquitetura, algoritmos e comportamentos, com equivalência funcional comprovada por execução diferencial. Fonte: DragonBones/DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e. Destino único: SrTristeSad/Bono-Lua. Não declarar 100% com pendências.

## Estado confirmado ao iniciar

- Main: ab660cc740ae3d430ef283ea2eb07c78de58d658; PR #64 integrado; CI pós-merge 41579955766 aprovada.
- Backup anterior: backup/pre-integral-rebuild-20261103 em cd4206a8ac091b1b26ad02b9ee4bc6ec7f30eeeb; preservado.
- Unidade atual: branch port/core-baseobject criada dessa main. Para o checkpoint publicado, PR e merge desta unidade, conferir GitHub antes de continuar; não antecipar SHA futuro.
- O proprietário autorizou manter a main atualizada com checkpoints testados; isso não significa motor completo. CI pertinente deve passar antes de integrar.

## Trabalho efetivo

Cinco classes geométricas presentes e comparadas nas duas VMs. BaseObject implementado em dragonbones/core/BaseObject.lua, com inicializadores, hashCode, limites, pools por string, borrow/return/clear, flags e avisos.
BaseObject: 38 cenários, 1.211 operações e 12.110 colunas de transcrição aprovadas localmente em Lua 5.4.8 e LuaJIT, comparação exata. Testes incluem colisões de chave de construtor, herança/receptor de toString, LIFO, duplicatas, limite padrão de 3000 com 3002 objetos, limites fracionários, efeitos parciais de erro, nested/throwing clear, strings numéricas e hashCode perto de 2^53.
Subclasses de teste são apenas probes de contrato; nenhum modelo real portado nesta unidade. Limites de compatibilidade JS genérica e protótipos estão explícitos em DIFFERENCES.md. Não atribuir cobertura exaustiva ou integração completa.

## Próxima unidade

1. Conferir main, backup, PRs e CI; ler status, mapa, decisões, validação, inventário e códigos reais antes de editar.
2. Abrir model/CanvasData.ts no commit fixado e sua versão Lua real no backup cd4206a8. Dependência autoral única: BaseObject, já portado.
3. Portar CanvasData em dragonbones/model/CanvasData.lua e comparar construtor/campos/_onClear/toString e integração real de borrow/return/limites/reutilização com o original executado.
4. Depois seguir core/modelos por dependências. UserData/ActionData e eventos requerem analisar enums/contratos do core; não adicionar constantes ou implementações fictícias para contornar dependências.
5. Atualizar PORTING_PROGRESS.json, regenerar inventário, executar testes, publicar branch/PR, confirmar CI e integrar checkpoint conforme autorização. Animação, parsing, armaduras, constraints, factories e GPU continuam pendentes.

## Reprodução

```sh
git fetch origin
git switch port/core-baseobject
git log -1 --format=fuller
git ls-remote --heads origin main backup/pre-integral-rebuild-20261103 port/core-baseobject
npm ci --ignore-scripts --no-audit --no-fund
node tools/inventory.js ../DragonBonesJS --check
node tools/dependencies.js ../DragonBonesJS --check
node tests/geom_differential.js ../DragonBonesJS lua5.4
node tests/math_differential.js ../DragonBonesJS lua5.4
node tests/baseobject_differential.js ../DragonBonesJS lua5.4
node tests/geom_differential.js ../DragonBonesJS luajit
node tests/math_differential.js ../DragonBonesJS luajit
node tests/baseobject_differential.js ../DragonBonesJS luajit
```

O checkout ../DragonBonesJS deve estar no commit fixado; os testes leem blobs Git. A memória da conversa não substitui os SHAs/códigos/evidências publicados.
