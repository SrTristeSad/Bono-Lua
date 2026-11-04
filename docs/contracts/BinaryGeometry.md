# Geometria binária

Fonte: BinaryDataParser.ts::_parseGeometry, DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e. Método original e backup Lua lidos; teste executa TS fixado com modelos e pool genuínos.

Recebe raw offset em elementos base 0 e GeometryData real. Primeiro publica offset/data; então lê _intArrayBuffer Int16. Peso -1 significa ausência e preserva o peso anterior. Qualquer offset menor que -1 recebe +65536, corrigindo a faixa assinada sem transformar -1 em índice válido.

Peso existente não é retornado ao pool ao substituir. Aloca WeightData novo, lê vertexCount/boneCount, adiciona referências de _rawBones e soma contagens por vértice, pulando seus índices. Mantém duplicatas, valores negativos e dados truncados conforme original. Só publica geometry.weight ao terminar. Falha durante addBone mantém geometria e peso anterior, deixando a nova alocação parcial sem owner. Não acrescenta rollback. clear/compartilhamento seguem GeometryData real.

Índices Lua base 1; offsets públicos em elementos base 0. Miss numérico de typed view vira NaN. Bone ausente/fora dos limites é JSValue.UNDEFINED, preservando célula undefined explícita em WeightData.bones; não fabricar BoneData nem trocar por null. Offset raw ausente também permanece UNDEFINED. Coerção de offsets string por concatenação JS e acesso a getters GeometryData com offset não numérico ficam fora da equivalência afirmada; nada alterado nesses getters.

238 cenários/4.284 colunas por VM Lua 5.4/LuaJIT, três falhas esperadas, tolerância zero. Offsets 0/12/32767/32768/65534/65535, segmentos sobrepostos, 0/1/3 vértices/bones, alias mutável, ausência de contexto/cabeçalho, limites/truncamento/NaN, pesos anteriores, duplicatas/holes, reparse, falha injetada em addBone e em retorno ao pool, limpeza própria/compartilhada e bytes inalterados. Captura alocações reais para observar peso parcial/órfão; injeções chamam ou interrompem o método real, não substituem o parser. Dois mutantes (sentinela -1 tratada como offset válido e contagem de influências incorreta) rejeitados.

Domínio finito de modelos/campos TS e buffers Int16 reais. Sem coerções/reflexão/proxies genéricos ou garantia de recuperação de dados corrompidos. 6/8 métodos binários: faltam _parseArray e parseDragonBonesData com DBDT/JSON. Runtime/factories/backends continuam pendentes.
