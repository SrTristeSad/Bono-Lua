# Validação

## Unidade inicial: preparação e inventário

Executado:

- Consulta GitHub dos dois repositórios e commit fixado.
- `git ls-remote --heads origin backup/pre-integral-rebuild-20261103`: backup no SHA registrado em PORTING_STATUS.md.
- `NODE_PATH=../tooling/node_modules node tools/inventory.js ../DragonBonesJS`: 1.203 arquivos, 182 unidades autorais, 240 classes; parser TypeScript 2.4.2 sem diagnósticos sintáticos nas unidades catalogadas.

- `NODE_PATH=../tooling/node_modules node tools/inventory.js ../DragonBonesJS --check`: comparação byte a byte aprovada, mesmas contagens.
- `git diff --check`: sem erros nos arquivos rastreados alterados.

Reprodução:

```sh
git clone https://github.com/DragonBones/DragonBonesJS.git ../DragonBonesJS
git -C ../DragonBonesJS checkout 64b6c69ae35777c2404be68c9192e2c56906079e
npm install --ignore-scripts --no-audit --no-fund
node tools/inventory.js ../DragonBonesJS --check
```

A verificação lê blobs Git, verifica o HEAD e compara o inventário completo byte a byte. Ela prova reprodutibilidade estrutural, não equivalência de runtime.
Lua 5.4, LuaJIT e LÖVE não estão instalados no ambiente local desta sessão. Testes de runtime/GPU não foram executados. Os resultados antigos ficam exclusivamente no backup.
## CI confirmada do checkpoint

PR: https://github.com/SrTristeSad/Bono-Lua/pull/63 (rascunho, sem merge).
Commit da branch: `eac7d2b83f09ff572bd751616ab4e7218373ddbf`.
Execução: https://github.com/SrTristeSad/Bono-Lua/actions/runs/41575623832. Job `inventory` (125718301492): `completed/success`.
Confirmados: instalação via lockfile, comparação exata dos blobs fixados e publicação do artefato `pinned-inventory-evidence`.
`node --check tools/inventory.js` também executado localmente com saída 0.
A aprovação é exclusivamente estrutural; não cobre runtime Lua nem GPU.

