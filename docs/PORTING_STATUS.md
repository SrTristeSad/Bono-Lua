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
| model/UserData.ts | dragonbones/original/model/UserData.lua | `UserData` e `ActionData` portados, inclusive ciclo de vida no pool |
| event/EventObject.ts | dragonbones/original/event/EventObject.lua | Constantes, `actionDataToInstance` e `_onClear` portados |
| core/DragonBones.ts | dragonbones/original/core/DragonBones.lua | Enums, fila de eventos, buffer de objetos e integração com `WorldClock` portados |

Testes determinísticos: `tests/original_geom.lua`, `tests/original_core.lua` e `tests/original_worldclock.lua` e `tests/original_events.lua` (Lua 5.4 no GitHub Actions). Os novos testes cobrem reutilização LIFO, descarte e tamanho dos pools, contador de identidade, limpeza, valores negativos/NaN, retorno duplicado e todos os métodos de `ColorTransform`.

**Não se deve tratar estes testes locais como prova de equivalência 1:1 do runtime inteiro.** Falta um comparador diferencial exaustivo contra a execução do original. Diferenças de linguagem: classes TS vs tabelas/metatables Lua, deslocamento de arrays zero-based para um-based, semântica de resto assinada (`math.fmod`) e diferenças de stringificação em `toString`. `BaseObject` usa uma tabela de classe como chave de pool, em lugar de `String(object.constructor)`, pois Lua não dispõe dessa representação textual de construtor; subclasses fornecem `Class.new()` e chamam `BaseObject.new(Class)`. Preservam-se a sequência de operações, comportamento do pool e o incremento do `hashCode`, mas ainda falta validação diferencial abrangente contra o TypeScript executado. A mutabilidade e a ordem de cálculo foram mantidas no porte inicial.

### WorldClock.ts — fronteira técnica e testes

Fonte: `DragonBones/src/dragonBones/animation/WorldClock.ts` no commit fixado. `IAnimatable.ts` é uma interface TypeScript (contrato `advanceTime(passedTime)` e `clock`) e **não possui algoritmo para portar**; os testes usam objetos Lua que satisfazem exatamente esse contrato.

Porte inclui `constructor`, `advanceTime`, `contains`, `add`, `remove`, `clear` e getter/setter `clock`. Um sentinela Lua representa elementos `null` do array JavaScript para manter a compactação no mesmo estágio de `advanceTime`, inclusive ao inserir/remover objetos em callbacks. A peculiaridade do `clear()` original é preservada: ele zera referências de relógio, mas não remove diretamente os elementos da lista. Não há redesenho do algoritmo.

Diferença inevitável de plataforma: `Date.now()` do TypeScript fornece milissegundos; Lua padrão (`os.time()`) fornece resolução de segundos, e o host LÖVE usa `love.timer.getTime()` para alta resolução. A implementação permite substituir apenas a fonte de tempo `WorldClock._now` em testes determinísticos; o algoritmo de cálculo de tempo permanece o original. Como consequência, a precisão do modo de tempo automático em Lua 5.4 isolado ainda **não equivale ao relógio original**. A biblioteca `WorldClock` permanece isolada do protótipo anterior até que os demais módulos originais estejam prontos.



### Portes de eventos e núcleo DragonBones

Fonte exata no commit fixado: `model/UserData.ts` (classes `UserData` e `ActionData`), `event/EventObject.ts` e `core/DragonBones.ts`. A interface `event/IEventDispatcher.ts` define somente o contrato de quatro métodos, sem implementação compartilhada para portar. Os testes usam objetos que implementam esse contrato; **não foi criada uma implementação substituta no motor**.

O `DragonBones.ts` porta os enums numéricos da fonte, a versão 5.7.000, `advanceTime`, `bufferEvent`, `bufferObject`, `clock` e `eventManager`. A fila processa também eventos incluídos pelos handlers durante o despacho, encaminha eventos sonoros ao gerenciador global e adia a devolução de objetos ao pool para o próximo ciclo, conforme o original. `EventObject` conserva `actionDataToInstance`, a associação com ossos/slots e a limpeza de referências. `UserData` conserva arrays e indexação pública original a partir de zero; `ActionData` devolve seus dados aninhados ao pool.

**Diferenças técnicas:** a implementação usa metatables Lua em vez de herança TypeScript, e mapas/tabelas de enums em vez de enums TypeScript eliminados na compilação. O despacho de eventos espera o contrato original do `Armature`, ainda não portado; o teste usa dublês limitados ao contrato e não os contabiliza como porte. Os shims globais exclusivos do ambiente JS (CommonJS/AMD, console e `__extends`) **não são usados no runtime Lua**. Ainda faltam conformidade diferencial executando código TypeScript original, tratamento de edge cases de ciclos de eventos e as classes completas de Armature, Bone e Slot.

## Código que já existia antes deste porte

Arquivos como dragonbones/matrix.lua, parser.lua, animation.lua e atlas.lua eram uma implementação própria simplificada. **Não são portes fiéis**; permanecem funcionando para não quebrar a demonstração LÖVE, mas não contam como módulos originais reconstruídos. Só substituir essas rotas quando o porte fiel estiver completo, verificado e integrado.

## Continuidade obrigatória

1. Todos os cinco arquivos da pasta `geom/` foram portados inicialmente. Aumentar testes diferenciais com o original executado, incluindo números especiais.
2. `WorldClock.ts`, `EventObject.ts`, `UserData.ts` e `core/DragonBones.ts` já têm portes iniciais em Lua. Prosseguir pelas dependências originais de armadura, osso, slot e dados de animação, sem criar stubs produtivos que mudem a semântica.
3. Portar dados, parsers, fábricas, armaduras, animação, timelines, slots, malhas, FFD, IK e constraints na arquitetura do original. Mapear cada arquivo.
4. Conectar os módulos fiéis ao LÖVE somente como backend gráfico; ele não define a semântica do DragonBones.
5. Identificar a fonte e versão do editor GUI original e portar esse editor separadamente para Lua, conforme disponibilidade/licença.
6. **Somente então** discutir melhorias adicionais.

## Lote atual

Fonte examinada antes do porte: `geom/ColorTransform.ts` e `core/BaseObject.ts`, ambos do commit fixado. Branch de desenvolvimento: `port-original-core-pool`. Código integrado à `main` pelo [PR #3](https://github.com/SrTristeSad/Bono-Lua/pull/3), commit de integração [`73beb1d`](https://github.com/SrTristeSad/Bono-Lua/commit/73beb1d94637de254354707b82184f461074057a). A CI só prova os comportamentos expressamente testados, não uma equivalência 1:1 do runtime.

### Lote WorldClock

Branch: `port-original-worldclock`. Origem fixa: `animation/WorldClock.ts` e contrato `animation/IAnimatable.ts`. Destinos: `dragonbones/original/animation/WorldClock.lua` e `tests/original_worldclock.lua`. CI compara cenários definidos de tempo automático, `timeScale`, elementos removidos, repetição de adição, ancestrais, relógios aninhados e callbacks. Integração: [PR #4](https://github.com/SrTristeSad/Bono-Lua/pull/4), commit [77f5dee](https://github.com/SrTristeSad/Bono-Lua/commit/77f5dee46199a29024910ca80af6b3a3acee5ea3). Na execução do PR, passaram 22 testes do protótipo, 11 de geometria, 14 de core e 15 de WorldClock, além da verificação gráfica LÖVE. Falta comparação diferencial exaustiva executando o original.

### Lote eventos e núcleo

Branch de trabalho: `port-original-events-core`; código: `dragonbones/original/{model/UserData,event/EventObject,core/DragonBones}.lua`; testes: `tests/original_events.lua`. O registro de integração e SHA deve ser atualizado após a CI e o merge.

Toda próxima fase deve registrar a comparação, os testes, pendências e o commit sem alterar os objetivos.
