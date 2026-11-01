# STATUS DO PORTE ORIGINAL — DragonBonesJS → Lua

## Fonte original fixa

Repositório: https://github.com/DragonBones/DragonBonesJS

Commit: 64b6c69ae35777c2404be68c9192e2c56906079e

Arquivos de origem: DragonBones/src/dragonBones/...

Licença: MIT, incluída em LICENSE-DRAGONBONES.

**A fonte fixada é do runtime DragonBonesJS, não do editor visual DragonBones completo.** A fonte do editor precisa ser identificada separadamente antes de prometer portar sua interface original.

## Implementações originais nesta fase

| Fonte original | Módulo Lua | Situação |
| --- | --- | --- |
| geom/Point.ts | dragonbones/original/geom/Point.lua | Portado, métodos testados |
| geom/Rectangle.ts | dragonbones/original/geom/Rectangle.lua | Portado, métodos testados |
| geom/Matrix.ts | dragonbones/original/geom/Matrix.lua | Portado, métodos e degenerações testados |
| geom/Transform.ts | dragonbones/original/geom/Transform.lua | Portado, operações e ângulos testados |
| geom/ColorTransform.ts | dragonbones/original/geom/ColorTransform.lua | Métodos, argumentos e retornos `void` portados; testes novos |
| core/BaseObject.ts | dragonbones/original/core/BaseObject.lua | Pool, `hashCode`, `setMaxCount`, `clearPool`, `borrowObject`, `returnToPool` portados; testes novos |
| animation/WorldClock.ts | dragonbones/original/animation/WorldClock.lua | Métodos e semântica de array nulo portados; 15 testes de comportamento incluídos |

Testes determinísticos: `tests/original_geom.lua`, `tests/original_core.lua` e `tests/original_worldclock.lua` (Lua 5.4 no GitHub Actions). Os novos testes cobrem reutilização LIFO, descarte e tamanho dos pools, contador de identidade, limpeza, valores negativos/NaN, retorno duplicado e todos os métodos de `ColorTransform`.

**Não se deve tratar estes testes locais como prova de equivalência 1:1 do runtime inteiro.** Falta um comparador diferencial exaustivo contra a execução do original. Diferenças de linguagem: classes TS vs tabelas/metatables Lua, deslocamento de arrays zero-based para um-based, semântica de resto assinada (`math.fmod`) e diferenças de stringificação em `toString`. `BaseObject` usa uma tabela de classe como chave de pool, em lugar de `String(object.constructor)`, pois Lua não dispõe dessa representação textual de construtor; subclasses fornecem `Class.new()` e chamam `BaseObject.new(Class)`. Preservam-se a sequência de operações, comportamento do pool e o incremento do `hashCode`, mas ainda falta validação diferencial abrangente contra o TypeScript executado. A mutabilidade e a ordem de cálculo foram mantidas no porte inicial.

### WorldClock.ts — fronteira técnica e testes

Fonte: `DragonBones/src/dragonBones/animation/WorldClock.ts` no commit fixado. `IAnimatable.ts` é uma interface TypeScript (contrato `advanceTime(passedTime)` e `clock`) e **não possui algoritmo para portar**; os testes usam objetos Lua que satisfazem exatamente esse contrato.

Porte inclui `constructor`, `advanceTime`, `contains`, `add`, `remove`, `clear` e getter/setter `clock`. Um sentinela Lua representa elementos `null` do array JavaScript para manter a compactação no mesmo estágio de `advanceTime`, inclusive ao inserir/remover objetos em callbacks. A peculiaridade do `clear()` original é preservada: ele zera referências de relógio, mas não remove diretamente os elementos da lista. Não há redesenho do algoritmo.

Diferença inevitável de plataforma: `Date.now()` do TypeScript fornece milissegundos; Lua padrão (`os.time()`) fornece resolução de segundos, e o host LÖVE usa `love.timer.getTime()` para alta resolução. A implementação permite substituir apenas a fonte de tempo `WorldClock._now` em testes determinísticos; o algoritmo de cálculo de tempo permanece o original. Como consequência, a precisão do modo de tempo automático em Lua 5.4 isolado ainda **não equivale ao relógio original**. A biblioteca `WorldClock` permanece isolada do protótipo anterior até que os demais módulos originais estejam prontos.


## Código que já existia antes deste porte

Arquivos como dragonbones/matrix.lua, parser.lua, animation.lua e atlas.lua eram uma implementação própria simplificada. **Não são portes fiéis**; permanecem funcionando para não quebrar a demonstração LÖVE, mas não contam como módulos originais reconstruídos. Só substituir essas rotas quando o porte fiel estiver completo, verificado e integrado.

## Continuidade obrigatória

1. Todos os cinco arquivos da pasta `geom/` foram portados inicialmente. Aumentar testes diferenciais com o original executado, incluindo números especiais.
2. `WorldClock.ts` foi examinado e portado depois de `IAnimatable.ts` (interface, contrato testado). Prosseguir com `core/DragonBones.ts` depois de portar as dependências de eventos (`EventObject.ts`, `IEventDispatcher.ts`) e modelos necessários, evitando criar stubs que mudem o comportamento.
3. Portar dados, parsers, fábricas, armaduras, animação, timelines, slots, malhas, FFD, IK e constraints na arquitetura do original. Mapear cada arquivo.
4. Conectar os módulos fiéis ao LÖVE somente como backend gráfico; ele não define a semântica do DragonBones.
5. Identificar a fonte e versão do editor GUI original e portar esse editor separadamente para Lua, conforme disponibilidade/licença.
6. **Somente então** discutir melhorias adicionais.

## Lote atual

Fonte examinada antes do porte: `geom/ColorTransform.ts` e `core/BaseObject.ts`, ambos do commit fixado. Branch de desenvolvimento: `port-original-core-pool`. Código integrado à `main` pelo [PR #3](https://github.com/SrTristeSad/Bono-Lua/pull/3), commit de integração [`73beb1d`](https://github.com/SrTristeSad/Bono-Lua/commit/73beb1d94637de254354707b82184f461074057a). A CI só prova os comportamentos expressamente testados, não uma equivalência 1:1 do runtime.

### Lote WorldClock

Branch: `port-original-worldclock`. Origem fixa: `animation/WorldClock.ts` e contrato `animation/IAnimatable.ts`. Destinos: `dragonbones/original/animation/WorldClock.lua` e `tests/original_worldclock.lua`. CI compara cenários definidos de tempo automático, `timeScale`, elementos removidos, repetição de adição, ancestrais, relógios aninhados e callbacks. Integração: [PR #4](https://github.com/SrTristeSad/Bono-Lua/pull/4), commit [77f5dee](https://github.com/SrTristeSad/Bono-Lua/commit/77f5dee46199a29024910ca80af6b3a3acee5ea3). Na execução do PR, passaram 22 testes do protótipo, 11 de geometria, 14 de core e 15 de WorldClock, além da verificação gráfica LÖVE. Falta comparação diferencial exaustiva executando o original.

Toda próxima fase deve registrar a comparação, os testes, pendências e o commit sem alterar os objetivos.
