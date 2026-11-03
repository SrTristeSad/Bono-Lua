# Curvas de easing do ObjectDataParser

Fonte única: `DragonBones/DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e`, arquivo `DragonBones/src/dragonBones/parser/ObjectDataParser.ts`.

## Recorte

Esta unidade porta **somente** `_getCurvePoint` e `_samplingEasingCurve`. São métodos auxiliares da futura leitura de quadros/timelines. Não implementa `_parseTweenFrame`, playback, armatures em runtime, renderizador LÖVE ou qualquer interface visual.

A implementação reproduz a fórmula de Bézier cúbica e os dois caminhos do original, determinados por `curve.length % 3 === 1`, incluindo a busca binária enquanto `higher - lower > 0.0001`, o `stepIndex` e os valores de retorno booleanos.

O adaptador `JSValue.at` lê índices zero-based dos arrays decodificados; os arrays internos do Lua usam posições a partir de um. As operações matemáticas seguem a mesma ordem do TypeScript fixado. A leitura de elemento ausente usa a coerção numérica `JSValue.number`, que produz NaN para `undefined`.

## Evidência

`node tests/curves_differential.js ../DragonBonesJS lua5.4`

`node tests/curves_differential.js ../DragonBonesJS luajit`

O teste extrai os **corpos reais** dos dois métodos da AST do TypeScript fixado e os transpila, sem copiar resultados esperados manualmente. Compara os bytes binary64 de pontos, amostras e estado auxiliar, os retornos e a quantidade de linhas. Há casos determinísticos regulares e com valores especiais.

A aprovação do CI deve ser confirmada no GitHub antes de atribuir equivalência demonstrada; mesmo com os dois testes aprovados, os 23 métodos restantes do parser e o backend gráfico continuam pendentes.
