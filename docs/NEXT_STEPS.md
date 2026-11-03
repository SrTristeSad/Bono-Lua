# Continuidade — Bono-Lua

## Objetivo permanente

Reconstruir o DragonBonesJS oficial em Lua com equivalência funcional integral demonstrada por testes contra o original executado. Preservar arquitetura, algoritmos, contratos e peculiaridades. Não substituir o motor, não mudar de upstream e não declarar 100% enquanto houver pendências.

## Estado confirmado antes desta unidade

- Último commit remoto confirmado ao iniciar: `f7f3060207b93807669f054692b29f59a79d4eb8`.
- Branch de trabalho: `rebuild/integral-20261103`; PR #63 em rascunho, sem merge.
- Main e backup `backup/pre-integral-rebuild-20261103`: `cd4206a8ac091b1b26ad02b9ee4bc6ec7f30eeeb`.
- Upstream: `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Para o checkpoint desta unidade, consultar o HEAD remoto e o PR #63 após a publicação; nunca inventar SHA futuro.

## Trabalho atual

- Etapa 00 concluída; inventário de arquivos/declarações e resolução estática disponíveis.
- Portados e comparados isoladamente: Point, Rectangle, ColorTransform em dragonbones/geom/.
- Lua 5.4.8 e LuaJIT: 1.384 operações e 8.288 campos por VM aprovados, tolerância zero.
- Oráculo: TS genuíno do commit fixado, compilado apenas na infraestrutura de testes.
- Fronteiras externas: cinco declarações de engines ausentes e referências dinâmicas documentadas em DEPENDENCIES.md.
- Integração de runtime/GPU: pendente; motor completo ausente.

## Próxima unidade

1. Conferir main, backup, branch, PR e CI no GitHub; ler estes documentos e o código real novamente.
2. Abrir Matrix.ts no commit fixado e Matrix.lua do backup; comparar todas as condições e retornos antes de reaproveitar qualquer código.
3. Portar Matrix para dragonbones/geom/Matrix.lua; testar todos os métodos, degenerações, concatenação, retângulos, copyFromArray e toString contra o original executado. Não omitir números especiais ou aumentar tolerâncias para esconder diferenças.
4. Depois seguir Transform.ts, suas constantes, normalizeRadian, fromMatrix e toMatrix. A ordem por dependência é Matrix antes de Transform; as três classes independentes já estão presentes.
5. Atualizar PORTING_PROGRESS.json, regenerar inventário e relatórios, publicar commit no mesmo PR e confirmar CI. Não fazer merge da reconstrução incompleta.

## Reprodução

```sh
git fetch origin
git switch rebuild/integral-20261103
git log -1 --format=fuller
git ls-remote --heads origin main backup/pre-integral-rebuild-20261103 rebuild/integral-20261103
npm ci --ignore-scripts --no-audit --no-fund
node tools/inventory.js ../DragonBonesJS --check
node tools/dependencies.js ../DragonBonesJS --check
node tests/geom_differential.js ../DragonBonesJS lua5.4
node tests/geom_differential.js ../DragonBonesJS luajit
```

O checkout ../DragonBonesJS deve estar no commit fixado. Não depender de resumos da conversa para afirmar implementação ou testes.
