# Continuidade — Bono-Lua

## Objetivo permanente

Reconstruir em Lua o DragonBonesJS oficial fixado em 64b6c69ae35777c2404be68c9192e2c56906079e, preservando arquitetura, algoritmos e comportamentos. Destino único SrTristeSad/Bono-Lua. Demonstrar equivalência por execução diferencial; não declarar 100% com pendências.

## Estado confirmado ao iniciar

- Main 92c010556009b4e9c516217062f0d40a90652d14; PR #65 integrado, CI pós-merge 41581381619 aprovada.
- Backup anterior backup/pre-integral-rebuild-20261103 em cd4206a8ac091b1b26ad02b9ee4bc6ec7f30eeeb, intacto.
- Branch desta unidade port/model-canvas-textures, criada dessa main. Checkpoint de código `eef0e925c11bb80295c539b16e23654de2522b0f`, PR #66; CI 41583478829 aprovada nos três jobs, logs e artefatos conferidos. Para merge e commits documentais posteriores, consultar GitHub; não antecipar SHA futuro.
- O proprietário autorizou checkpoints testados na main. Isso não representa motor completo; testar e confirmar CI antes de integrar.

## Trabalho atual

Cinco classes geométricas e BaseObject já portados. Modelos novos: CanvasData, TextureAtlasData e TextureData, em dragonbones/model/.
Comparação de modelos com BaseObject/Rectangle reais: 18 cenários, 639 operações e 5.751 colunas por VM, aprovada localmente em Lua 5.4.8 e LuaJIT. Scalars numéricos comparados por bytes binary64, NaN canonicalizado, demais tipos distinguidos. Referências parent JS undefined/null e resultado ausente de getTexture convertem para nil, de forma explícita.
Campos não inicializados do construtor preservados; limpeza/reset, identidades de region/frame/mapa, cópia mantendo parent de origem, duplicatas, reciclagem e falha parcial da factory validadas no escopo dos testes. As duas subclasses de backend existem só no teste, sem renderização.
Corrigida ordem de enumeração do mapa de texturas após o oráculo mostrar identidades de pool divergentes com pairs. Metadados de inserção mantêm a tabela pública e sua identidade. Limites de Object.prototype/reflexão estão registrados em DIFFERENCES.md.

## Próxima unidade

1. Conferir main, backup, PRs e CI; ler status/mapa/validação/decisões/inventário e os códigos reais dos dois repositórios antes de alterar.
2. Abrir animation/WorldClock.ts e IAnimatable.ts no commit fixado e WorldClock.lua real do backup. WorldClock depende do contrato IAnimatable e prepara core/DragonBones; sua fonte externa de tempo é Date.now.
3. Portar WorldClock em dragonbones/animation/WorldClock.lua sem substituir o algoritmo de lista/compactação, callbacks, hierarquia clock ou tempo negativo/automático. Comparar com o original executado nas duas VMs usando uma fonte de tempo de teste determinística; documentar qualquer precisão/fonte de host que ainda não seja equivalente.
4. Depois continuar as dependências reais do core/DragonBones, eventos e modelos, sem inventar constantes/objetos para contornar módulos ausentes.
5. Atualizar PORTING_PROGRESS.json e inventário, testar, publicar PR, confirmar CI e integrar checkpoint. Parsers, armaduras, constraints, animação completa, factories e GPU continuam pendentes.

## Reprodução

```sh
git fetch origin
git switch port/model-canvas-textures
git log -1 --format=fuller
git ls-remote --heads origin main backup/pre-integral-rebuild-20261103 port/model-canvas-textures
npm ci --ignore-scripts --no-audit --no-fund
node tools/inventory.js ../DragonBonesJS --check
node tools/dependencies.js ../DragonBonesJS --check
node tests/geom_differential.js ../DragonBonesJS lua5.4
node tests/math_differential.js ../DragonBonesJS lua5.4
node tests/baseobject_differential.js ../DragonBonesJS lua5.4
node tests/models_differential.js ../DragonBonesJS lua5.4
node tests/geom_differential.js ../DragonBonesJS luajit
node tests/math_differential.js ../DragonBonesJS luajit
node tests/baseobject_differential.js ../DragonBonesJS luajit
node tests/models_differential.js ../DragonBonesJS luajit
```

O checkout ../DragonBonesJS deve estar no commit fixado; o teste usa blobs Git. A memória da conversa não substitui códigos, SHAs e evidências publicados.
