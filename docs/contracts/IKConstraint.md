# Constraint e IKConstraint

Fonte: DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e, armature/Constraint.ts. TS integral e Lua do backup cd4206a8 lidos. Base em dragonbones.armature.Constraint, solver em dragonbones.armature.IKConstraint. PathConstraint é o terceiro tipo do mesmo TS e não foi implementado nesta unidade.

## Contrato

Constraint herda BaseObject, tem helpers estáticos próprios compartilhados por subclasses (distintos de TransformObject) e getter name somente leitura. Não há corpos fictícios para init/update/invalidUpdate abstratos. _onClear da base limpa armature/target/root/bone, mas NÃO _constraintData, exatamente como o source. IK._onClear também restaura peso=1/dobra=false e limpa data. Campos sem inicializador são nil antes da limpeza; domínio normal começa via BaseObject.borrowObject.

IK.init publica data/armature antes das buscas e copia peso/dobra antes de marcar _root._hasConstraint=true; init repetido retorna sem alterar estado. _addConstraint de Armature conserva identidade/deduplicação. init não registra sozinho, como no original: a montagem chama os dois métodos. Registro é não proprietário dos modelos; runtime pertence à armadura, dados pertencem a ArmatureData.

_computeA aponta root para target com atan2 e ajuste para scaleX negativo, usando normalizeRadian e peso sem clamp. _computeB mantém o algoritmo geométrico de dois ossos: alcance interno/externo, ramo vazio original, reflexão do avô, direção da dobra, mistura ponderada de ângulos e compensação dR inferior. Comprimentos zero/negativos e pesos fora de [0,1] não ganham validação ou correção nova. O TODO scaleEnabled permanece comentado/ignorado; não escalar os ossos artificialmente.

update chama updateByConstraint de root e, quando há bone, do segundo osso. Bone.update real dispara solver pelo registro e conserva _localDirty para não sobrescrever a solução com FK; cache hit/restore pode suprimir nova avaliação conforme o pin. invalidUpdate invalida root e bone, não target. O alvo precisa ser atualizado antes dos dependentes (a ordenação do parser/modelo e a montagem manual são explícitas). _onClear de IK não desmarca _hasConstraint no osso; a limpeza do Bone faz isso depois, conforme a ordem de ownership usada.

## Evidência

15.404 cenários/46.212 etapas/955.048 colunas, 32 exceções de etapas esperadas e 25.355 comparações aproximadas de componentes por VM Lua 5.4/LuaJIT local. 15.360 combinações abrangem chain 0/1, bend boolean, pesos -0,5/0/0,25/1/1,5, oito alvos (incluindo limites 2 e 18 para cadeia 10+8, alvo coincidente, interno e externo), quatro flips, dois eixos Y, avô ausente/positivo/refletido e quatro poses/comprimentos. Outros 44 casos cobrem APIs/erros/cache/limpeza/dados inválidos declarados. Compara matrizes/poses/flags/cache de root/bone/target/avô, referências, nome/weight/bend, helpers, deduplicação e limpeza/pool. NaN é comparado por categoria; payloads arbitrários não são prometidos.

Seis probes foram rejeitados, incluindo pular a avaliação com peso zero que altera flags em cadeia de dois ossos. Um caso de um osso com peso zero pode ser observacionalmente igual nesse probe; o teste discriminante é o índice 8448. Arquivo restaurado antes da reexecução integral das duas VMs. Seleção opcional para reprodução: `node tests/ik_differential.js ../DragonBonesJS lua5.4 14636` ou último argumento com nome de operação (por exemplo reinit). Sem seleção executa toda a grade.

## Comparação numérica específica de IK

Sem mudar o algoritmo nem os budgets de Bone/Transform/Surface, a integração precisa considerar propagação e condicionamento de atan2. No caso 14636 (dois ossos, peso 1,5, reflexão e alvo perto da junta), rotação superior difere cerca de 1,33e-15 entre V8/libm; coeficiente inferior difere cerca de 1,33e-14 (aproximadamente 60 epsilon absolutos na escala unitária). Em outro caso, coeficiente superior difere 8,33e-16 e, multiplicado pela distância 10, desloca o filho em 8,44e-15. Não usar apenas abs(coordenada final) quando há projeção/cancelamento.

Para cada etapa, o comparador usa somente o expected do TS:

- L = distância root→bone + norma da coluna X da matriz de bone vezes abs(bone.length).
- R = max(1, L, valores absolutos de x/y de root/bone/target).
- d = distância bone→target. Para dois ossos com d>0, g=min(8,max(1,abs(weight)*(1+L/d))); caso contrário g=1.
- Coordenadas de matriz/pose/cache: abs(delta) <= 8*epsilon*max(R,abs(expected)).
- Demais componentes derivados de root/bone e cópias em cache: abs(delta) <= 8*epsilon*g*max(1,abs(expected)). Ganho limitado: máximo 64 epsilon; pais/alvo não recebem ganho de IK.

Flags/referências/índices/comprimentos de arrays são exatos; pares de zeros com sinais diferentes e zero versus não zero não são aproximados. Cache e casos de falha mantêm a ordem/estado do original. O limite é uma evidência finita para os cenários declarados, não garantia universal em configurações arbitrariamente mal condicionadas. Não adaptar branch, atan2, normalizeRadian, raiz ou clamp para forçar igualdade de bibliotecas.

## Fronteiras

Objetos reais iniciados pelo pool; referências opcionais null/undefined normalizadas nil; campos numéricos binary64. Negação de dY promove zero inteiro Lua 5.4 por *1.0 para preservar semântica Number/-0; não usa +0 que apagaria o sinal. Não cobre reflexão/proxies/coerções arbitrários, callbacks de subclasses reentrantes, ciclos de dependências, casos extremos sem limite de condicionamento ou resolução automática de Animation/factory. IK com pai Surface ainda não está validado. Path solver, player e renderer continuam pendentes.

Exemplo ik_ske.json é uma fixture autoral, não uma exportação upstream reivindicada. examples/run.lua ik usa parser/ordenação/Bone/IK/Armature reais, libera runtime antes dos modelos e demonstra alcance no terminal sem renderer/player.
