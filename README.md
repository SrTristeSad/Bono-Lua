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

Reconstrução em `rebuild/integral-20261103`, [PR #63 em rascunho](https://github.com/SrTristeSad/Bono-Lua/pull/63). A main e o backup `backup/pre-integral-rebuild-20261103` preservam o estado anterior (`cd4206a8`). A reconstrução incompleta permanece isolada, sem merge.

Inventário de 1.203 caminhos e declarações autorais catalogado. Dependências estáticas e fronteiras de APIs estão em [DEPENDENCIES.md](docs/DEPENDENCIES.md). Primeiro lote Lua: `Point`, `Rectangle` e `ColorTransform`; a situação e as evidências reais constam em [PORTING_STATUS.md](docs/PORTING_STATUS.md) e [VALIDATION.md](docs/VALIDATION.md). O motor completo ainda está pendente.

Para continuar, leia [NEXT_STEPS.md](docs/NEXT_STEPS.md), [UPSTREAM_INVENTORY.md](docs/UPSTREAM_INVENTORY.md) e [PORTING_MAP.md](docs/PORTING_MAP.md).

Licença e atribuição DragonBones: [LICENSE-DRAGONBONES](LICENSE-DRAGONBONES).
