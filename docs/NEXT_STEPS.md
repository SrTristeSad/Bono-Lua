# Continuidade — Bono-Lua

## Objetivo permanente

Reconstruir o DragonBonesJS oficial em Lua, preservando arquitetura, algoritmos, contratos e peculiaridades, com equivalência demonstrada por testes contra o original executado. Fonte fixa: 64b6c69ae35777c2404be68c9192e2c56906079e. Destino único: SrTristeSad/Bono-Lua. Não declarar 100% com pendências.

## Estado confirmado ao iniciar esta unidade

- O proprietário solicitou “atualizar o main e continua”; autorizado integrar checkpoints testados do porte em andamento, sem afirmar motor completo.
- PR #63 integrado; main confirmada em 71929d98cbb0461eab99d83e6fa7e0a3c4bf0584.
- Backup anterior: backup/pre-integral-rebuild-20261103 em cd4206a8ac091b1b26ad02b9ee4bc6ec7f30eeeb; intacto.
- Branch desta unidade: port/geom-matrix-transform, criada da main confirmada.
- Checkpoint de código desta unidade: `7414985a8a9464f736a54f411b49e86cfebf035e`, PR #64; CI 41579761219 confirmada com três jobs aprovados, logs e artefatos conferidos. Para o merge e commits documentais posteriores, consultar main/PR/CI no GitHub; não inventar SHA futuro.

## Trabalho efetivo

Cinco classes em dragonbones/geom/: Point, Rectangle, ColorTransform, Matrix, Transform, com JSNumberString como adaptação da representação numérica dos toString.
Primeiro lote: 1.384 operações / 8.288 campos por VM. Lote Matrix/Transform: 2.463 casos / 12.231 números / 158 strings por VM, aprovado localmente em Lua 5.4.8 e LuaJIT; CI do checkpoint de código aprovada nos três jobs (41579761219); resultado pós-merge deve ser conferido na main.
Todos os métodos declarados de Matrix/Transform entram nos cenários; não há prova de todos os binary64/locales/objetos dinâmicos ou integração completa. Corrigida perda de -0 em transformRectangle; 52 comparações trigonométricas locais usam o limite predefinido em DIFFERENCES.md.
Inventário e dependências: relatórios regeneráveis, 1.203 caminhos, 192 unidades autorais e 241 classes; cinco declarações externas de engines ausentes registradas.

## Próxima unidade

1. Verificar main, branch, backup, PRs e CI no GitHub. Ler status, mapa, decisões, validação, inventário e os códigos reais dos dois repositórios antes de alterar.
2. Abrir core/BaseObject.ts no commit fixado e o Lua correspondente do backup cd4206a8; comparar pool, hashCode, limites, duplicatas, limpeza e herança.
3. Portar BaseObject para dragonbones/core/BaseObject.lua e comparar com o original executado nas duas VMs. Não inventar chave de classe/pool sem documentar a diferença de representação.
4. Seguir core/modelos na ordem real das dependências; WorldClock/DragonBones exigem os contratos correspondentes. Nunca confundir doubles de teste com módulos de produto.
5. Atualizar progresso/relatórios, publicar branch e PR, confirmar CI e integrar somente checkpoints validados conforme autorização do proprietário. O resto do motor permanece pendente.

## Comandos

```sh
git fetch origin
git switch port/geom-matrix-transform
git log -1 --format=fuller
git ls-remote --heads origin main backup/pre-integral-rebuild-20261103 port/geom-matrix-transform
npm ci --ignore-scripts --no-audit --no-fund
node tools/inventory.js ../DragonBonesJS --check
node tools/dependencies.js ../DragonBonesJS --check
node tests/geom_differential.js ../DragonBonesJS lua5.4
node tests/geom_differential.js ../DragonBonesJS luajit
node tests/math_differential.js ../DragonBonesJS lua5.4
node tests/math_differential.js ../DragonBonesJS luajit
```

O checkout ../DragonBonesJS deve estar no commit fixado. Resultados antigos só contam depois de conferir os SHAs e reexecutar o que a alteração exige.
