# Adaptações e divergências

## Primeiro lote geométrico

| Aspecto | Original TS/JS | Representação Lua | Evidência/limite |
| --- | --- | --- | --- |
| Classes/construtor | new Point/Rectangle/ColorTransform | Tabelas/metatables e Class.new(...) | Mesmo estado numérico dos construtores nos testes |
| Argumento omitido | undefined aciona default | nil aciona default | Casos omitidos e com lacunas comparados |
| Métodos void | undefined | nil | Retorno verificado após copyFrom/clear/identity |
| Campos numéricos | number (binary64) | number Lua; inteiros exatos também possíveis em 5.4 | Comparação numérica exata, NaN/infinito/zero negativo explícitos |
| Cópia/limpeza | Mutação da instância, origem preservada | Mesma sequência de campos na implementação preservada | Estados e não mutação da origem comparados |

Lua não distingue automaticamente null de undefined. O contrato numérico TS não aceita null; não foi criada nem validada uma camada universal de compatibilidade JavaScript. Objetos com getters/setters arbitrários, Proxy, reflexão de protótipos e chamadas inválidas fora dos tipos TS não foram cobertos. A comparação trata registros simples com campos numéricos/ausentes.
Nenhuma divergência foi observada nas 1.384 operações do lote nas duas VMs. Isso não prova equivalência para entradas arbitrárias nem integração completa.

## Próximos módulos e plataformas

Ainda precisam de análise: índices zero, arrays esparsos e tipados, identidade de buffers, remainder, stringificação, relógio, eventos, hierarquias e APIs gráficas. Não adotar automaticamente adaptações do backup.
DEPENDENCIES.md registra APIs globais, referências não resolvidas e cinco declarações externas ausentes nos tsconfigs do commit fixado. Um backend LÖVE não será considerado prova de todas as integrações oficiais.

## Matrix e Transform

- `copyFromArray`: array Lua começa em 1, enquanto o offset público continua zero-based. Índices ausentes produzem nil, correspondente a undefined na transcrição de teste.
- `normalizeRadian`: math.fmod preserva o resto assinado do operador % JavaScript; não usar o operador % de Lua para esta função.
- `fromMatrix`: preservados atan(b/a), as duas ramificações por PI_Q e a recuperação dos sinais de escala anteriores; não substituído por atan2 ou outra decomposição.
- `Matrix.invert`: preservadas as degenerações distintas de matriz diagonal e de determinante zero, inclusive a manutenção peculiar do campo d na diagonal degenerada.
- `transformRectangle`: math.floor/math.ceil em Lua 5.4 podem retornar inteiro zero; wrappers mantêm -0 e ceil negativo próximo de zero como no Math original. A comparação adicional revelou e comprovou a necessidade.
- `toString`: JSNumberString é um adaptador Lua de representação numérica reaproveitado do backup, pois Lua tostring não usa as regras decimais de Number. Não participa das fórmulas do motor. As 158 strings do lote compararam exatamente; não há prova exaustiva de todos os binary64, locales ou chamadas fora dos tipos TS.
- Trigonometria: somente resultados não nulos de seno/cosseno/atan e sua decomposição aceitam `8 * 2^-52 * max(1, abs(esperado))`, por diferença de arredondamento entre V8 e libm. NaN, infinitos, sinais de zero, translações e demais operações permanecem exatos.

Sem divergências nos cenários numéricos/string executados após corrigir o zero assinado. Não foram validadas operações encadeadas arbitrárias sobre campos nil/undefined, objetos Proxy/getters, coerção geral de tipos JS ou inteiros Lua fora da representação canônica Number; esses limites não são uma declaração de equivalência irrestrita. Integração de armaduras, cache e GPU ainda pendente.

## BaseObject

- `new Subclass()` e inicializadores de campo TS são representados por `Subclass.new()` chamando `BaseObject.new(Subclass)`. Tabelas/metatables substituem protótipos; constructor é uma referência explícita na instância.
- `String(constructor)` usa `constructor.toString(constructor)` no contrato de classes Lua. O argumento explícito representa o receptor estático JS; os métodos originais retornam strings. Não usar identidade de tabela como chave, pois removeria colisões e compartilhamento observáveis no original.
- `_hashCode` inicia em 0.0 e incrementa em 1.0, preservando o comportamento binary64 inclusive perto de 2^53; campos estáticos, mapas e flags são observáveis.
- Uma lista auxiliar de chaves mantém a enumeração de pools: índices canônicos 0..2^32-2 em ordem numérica, depois outras strings na ordem de inserção. "-0" é string comum, não índice. Isso preserva efeitos anteriores a uma exceção de resize global; não substituir pelo pairs não ordenado.
- `Array.length = limite` só lança erro de comprimento fracionário quando ocorre uma redução real. Limites fracionários podem aceitar ceil(limite) objetos no retorno, conforme a condição original; não arredondar o limite antecipadamente. Clear/truncamento não mudam flags dos objetos removidos.
- console.warn é encaminhado a stderr com a mesma mensagem. Teste intercepta o canal de avisos em ambas as linguagens. Exceções são comparadas por categoria/efeitos, sem exigir stack traces idênticos.

38 cenários/1.211 operações passaram exatamente nas duas VMs. A comparação usa subclasses de teste exclusivamente para observar chamadas _onClear e identidade. Integração com subclasses reais será validada ao portá-las.
Limites explícitos: não emula Object.prototype para chaves como __proto__/constructor herdadas do objeto-mapa JS; não reproduz a reflexão genérica/PropertyDescriptors/Function.toString de classes sem o contrato estático do runtime; substituir mapas readonly ou manipular seus protótipos diretamente não foi coberto. Construtores cujo toString viola a assinatura string TS não foram tratados como equivalentes. Não declarar equivalência irrestrita de JavaScript a partir deste lote.
