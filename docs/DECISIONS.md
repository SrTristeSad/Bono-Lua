# Decisões rastreáveis

## 2026-11-03 — reconstrução isolada

Autorização: comando mestre anexado pelo proprietário e instrução para executá-lo.
Backup confirmado de `cd4206a8ac091b1b26ad02b9ee4bc6ec7f30eeeb` antes de remover qualquer arquivo antigo.
Nenhuma exclusão na main, nenhum force push, nenhum merge automático.

## Inventário reprodutível antes do porte

TypeScript 2.4.2 é dependência de desenvolvimento para leitura sintática; não integra o produto Lua. O runtime não foi reescrito em JS.
O gerador lê exclusivamente o commit `64b6c69ae35777c2404be68c9192e2c56906079e` por Git.
Dependências por identificadores são marcadas candidatas: não há afirmação de resolução de símbolos ou completude semântica.
O inventário e o backup preservam a possibilidade de auditar e reaproveitar implementações equivalentes após comprovação.
