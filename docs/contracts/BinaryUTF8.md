# Helpers de BinaryDataParser

Fonte: DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e, BinaryDataParser.ts. Parcial: 3 de 8 métodos. `new()` herda estado real de ObjectDataParser e deixa os cinco campos binários sem valor, como as declarações TS sem inicializadores. `getInstance()` mantém singleton próprio.

`_decodeUTF8` recebe view uint8 com `.length` e índices Lua base 1. Não recebe string bruta. Preserva o algoritmo custom original: omite NUL e leads inválidos, não descarrega sequências incompletas no EOF, reprocessa continuação inválida e usa o último byte para sequências completas inválidas. Não substituir por um decoder UTF-8 padrão. Lua armazena escalares em UTF-8; a prova compara unidades UTF-16 com o JS original executado.

Shared.view(buffer, offset, byteLength, 'uint8') usa unidade de um byte, offsets base 0, comprimento em bytes e validação explícita do adaptador. Escritas convertem e truncam módulo 256, inclusive antes de ignorar índice inválido. Views compartilham Buffer; snapshots antigos permanecem imutáveis. Não se afirma emulação geral dos overloads ToIndex de TypedArray. Os sete segmentos de DragonBonesData permanecem os mesmos.

Teste binaryutf8_differential: 67.083 operações/134.166 colunas, tolerância zero; todos os 256 bytes isolados, 65.536 pares, fronteiras escalares, truncamentos, sequências inválidas, 1.024 sequências determinísticas, intervalos, coerções, limites, metadados e aliases. O oracle compila e executa a classe TS fixada; não contém decoder manual substituto.

Faltam cinco métodos binários, JSON interno e leitura DBDT. Os métodos herdados de ObjectDataParser não são overrides binários e sua entrada pública não aceita DBDT.
