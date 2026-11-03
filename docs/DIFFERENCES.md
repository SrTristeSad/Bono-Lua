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
