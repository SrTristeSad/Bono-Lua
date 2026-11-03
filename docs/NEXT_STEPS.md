# Continuidade

- Último commit de base confirmado: `cd4206a8ac091b1b26ad02b9ee4bc6ec7f30eeeb`.
- Backup: `backup/pre-integral-rebuild-20261103` no mesmo SHA.
- Trabalho: `rebuild/integral-20261103`. Para o último commit publicado desta branch, consultar `git ls-remote` e a página do PR; não registrar como confirmado um SHA ainda não criado.
- Upstream fixado: `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Última etapa preparada: 00. Inventário estrutural de 01 gerado; auditoria semântica ainda pendente.
- Arquivos em desenvolvimento: tools/inventory.js e documentos de rastreabilidade.
- Testes executados: geração AST; conferir VALIDATION.md e CI do PR para verificações adicionais.
- Runtime traduzido/testado nesta branch: nenhum.
- Divergências conhecidas: relações de dependência ainda candidatas, contratos de plataforma e código de topo pendentes de revisão.

## Próxima unidade

1. Ler todos estes documentos e o estado remoto/main/PRs/CI antes de alterar.
2. Auditar os candidatos de dependências e contratos externos de cada integração no commit fixado. Incluir funções atribuídas a exports e código de topo das ferramentas, não apenas declarações nomeadas.
3. Completar auditoria de 01 antes de iniciar tradução.
4. Em 02, ler integralmente os cinco arquivos geom originais e os Lua correspondentes no backup; preservar qualquer implementação demonstravelmente equivalente. Criar oráculo executando código upstream e comparar Lua 5.4/LuaJIT com entradas equivalentes.

## Comandos

```sh
git fetch origin
git switch rebuild/integral-20261103
git log -1 --format=fuller
git ls-remote --heads origin main backup/pre-integral-rebuild-20261103 rebuild/integral-20261103
npm install --ignore-scripts --no-audit --no-fund
node tools/inventory.js ../DragonBonesJS --check
```

Não fazer merge da reconstrução incompleta. Não declarar etapa 01 integralmente auditada nem equivalência integral com base no inventário.
