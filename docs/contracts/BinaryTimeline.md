# Leitura de timeline binária

Fonte: BinaryDataParser.ts::_parseBinaryTimeline, DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e. O arquivo inteiro e o backup Lua foram lidos; o backup não serve como oracle.

Recebe tipo e offset numéricos, e opcionalmente TimelineData/AnimationTimelineData real. Usa `_timelineArrayBuffer` Uint16, `_frameArrayBuffer` Int16, `_animation` e `_data` reais. Offsets públicos em elementos base 0; acesso Lua base 1. Default nil/JSValue.NULL/UNDEFINED toma objeto do pool. Não aceita tabelas numéricas comuns como substituto de typed views na equivalência afirmada.

Primeiro publica tipo/offset e `_timeline`. Uma única keyframe define frameIndicesOffset=-1, sem tocar dados/animação. Demais contagens reservam animation.frameCount+1 posições no final de frameIndices; zero keys ou miss no cabeçalho produzem índices -1. O próximo frame vem do próximo offset no cabeçalho, não de duração presumida. O último usa frameCount-frameStart. Frames repetidos/decrescentes não são ordenados ou corrigidos.

Reserva length preserva lacunas, prefixo e ordem; atribui frameIndicesOffset só depois da reserva. Falha de length/contexto preserva `_timeline` e efeitos anteriores. Não há rollback/finally extra. Miss de typed view é undefined em JS; sua participação numérica vira NaN em Lua, sem erro de aritmética de nil. Sucesso limpa `_timeline`; timeline fornecida preserva classe e x/y. Não adiciona timeline a mapas de animação: isso cabe ao próximo override.

439 cenários/448 chamadas/6.585 colunas por VM, 12 exceções esperadas, tolerância zero. Teste executa TS fixado com DragonBonesData/AnimationData/TimelineData/pool reais e views nativas; Lua usa o mesmo arranjo de bytes compartilhados. Inclui frame extra, contagens 0/1/múltiplas/65535, segmentos existentes e holes, offsets fracionários/NaN/fora dos limites, falta de contexto, length fracionário/overflow, totais zero/negativos, append, alias mutation, subclasses e reutilização do pool. Dois mutantes (omitir frame extra e usar offset seguinte incorreto) são rejeitados.

Domínio: modelos/campos numéricos conforme TS, buffers finitos e loops finitos. Não afirma coerções arbitrárias, setters/proxies ou propriedades de protótipo. Não carrega DBDT nem avalia animação no runtime.
