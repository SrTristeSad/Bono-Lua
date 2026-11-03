# Bono-Lua — porte integral do DragonBonesJS para Lua

## Objetivo central

**Reconstruir o Bono-Lua em Lua, seguindo a arquitetura, os algoritmos e os comportamentos do DragonBonesJS oficial, com equivalência funcional demonstrada por testes contra o original executado.**

- **Destino único:** [SrTristeSad/Bono-Lua](https://github.com/SrTristeSad/Bono-Lua).
- **Fonte única:** [DragonBones/DragonBonesJS](https://github.com/DragonBones/DragonBonesJS), commit fixado [`64b6c69ae35777c2404be68c9192e2c56906079e`](https://github.com/DragonBones/DragonBonesJS/commit/64b6c69ae35777c2404be68c9192e2c56906079e).
- **Produto:** runtime Lua; LÖVE será um adaptador gráfico separado. JavaScript/TypeScript é utilizado apenas na infraestrutura de análise e no oráculo de testes.
- **Escopo:** matemática, core/modelos, JSON/DBDT, armaduras/ossos/slots/surfaces, constraints IK/Path, animação/timelines/blending/eventos/cache, factories, malhas/pesos/FFD, atlas/skins e contratos das integrações oficiais.
- **Critério de conclusão:** todo comportamento obrigatório catalogado, implementado e validado; divergências conhecidas resolvidas. CI verde e contagem de arquivos não significam 100% de equivalência.

## Como vamos trabalhar

Ler o arquivo upstream fixado e a versão Lua antes de cada alteração. Preservar a lógica original; adaptar somente diferenças indispensáveis de linguagem, registrando-as. Comparar entradas, saídas, estados, retornos e efeitos colaterais com o original executado. Registrar testes reais, pendências e próximo passo no GitHub.

O comando completo está em [RECONSTRUCTION_SPEC.md](docs/RECONSTRUCTION_SPEC.md); a sequência de etapas, em [ROADMAP.md](docs/ROADMAP.md).

## Estado atual

O checkpoint inicial foi integrado na `main` pelo [PR #63](https://github.com/SrTristeSad/Bono-Lua/pull/63), por solicitação explícita do proprietário. A main acompanha o porte em andamento; isso não significa que o motor está completo. O estado anterior permanece em `backup/pre-integral-rebuild-20261103` (`cd4206a8`).

As classes geométricas foram integradas pelo [PR #64](https://github.com/SrTristeSad/Bono-Lua/pull/64), merge `ab660cc`, com CI pós-merge aprovada. Unidade atual: `port/core-baseobject`, construída sobre essa main. As cinco classes geométricas estão portadas: `Point`, `Rectangle`, `ColorTransform`, `Matrix` e `Transform`. Comparações isoladas contra o original foram executadas em Lua 5.4 e LuaJIT; integração completa ainda pendente.

Inventário de 1.203 caminhos e declarações autorais catalogado. Dependências estáticas e fronteiras de APIs estão em [DEPENDENCIES.md](docs/DEPENDENCIES.md); estado e evidências reais, em [PORTING_STATUS.md](docs/PORTING_STATUS.md) e [VALIDATION.md](docs/VALIDATION.md). `BaseObject` inicia o core em `dragonbones/core/`, preservando o pool e o ciclo de vida do original, com comparação diferencial nas duas VMs. O restante do runtime segue o [ROADMAP.md](docs/ROADMAP.md).

Para continuar, leia [NEXT_STEPS.md](docs/NEXT_STEPS.md), [UPSTREAM_INVENTORY.md](docs/UPSTREAM_INVENTORY.md) e [PORTING_MAP.md](docs/PORTING_MAP.md).

Licença e atribuição DragonBones: [LICENSE-DRAGONBONES](LICENSE-DRAGONBONES).
