# Correspondência de arquivos

A tabela integral está em UPSTREAM_INVENTORY.md e é regenerável.

| Origem | Destino proposto | Situação |
| --- | --- | --- |
| DragonBones/src/dragonBones/**/*.ts | dragonbones/**/*.lua | Ausente; inventariado |
| <engine>/<version>/src/dragonBones/**/*.ts | integrations/<mesmo caminho>.lua | Ausente; contratos de plataforma pendentes |
| Interfaces TS | Contratos Lua documentados/testados junto às classes | Sem algoritmos próprios; nenhuma simulação |
| Demos, recursos e arquivos gerados | Classificados individualmente no inventário | Não contados como runtime |
| builds/*.js | Ferramentas de distribuição do upstream | Catalogadas; necessidade de correspondência Lua a auditar |

Os caminhos reservados de integrações não afirmam que APIs JavaScript existem em Lua. A separação por engine/versão evita colidir classes com nomes idênticos.
