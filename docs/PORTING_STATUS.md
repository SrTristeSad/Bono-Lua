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
| armature/TransformObject.ts | dragonbones/original/armature/TransformObject.lua | Classe-base abstrata, getters e transformações geométricas portados, testes em subclasses somente de teste |
| model/CanvasData.ts | dragonbones/original/model/CanvasData.lua | Campos originais, limpeza e pool portados |
| model/ConstraintData.ts | dragonbones/original/model/ConstraintData.lua | Classes `ConstraintData`, `IKConstraintData`, `PathConstraintData`, enums e limpeza dos ossos portados |
| model/TextureAtlasData.ts | dragonbones/original/model/TextureAtlasData.lua | Classes abstratas `TextureAtlasData` e `TextureData`, métodos de cópia, atributos, regiões, frames e pool portados |
| model/DisplayData.ts | dragonbones/original/model/DisplayData.lua | `GeometryData`, `DisplayData`, Image, Armature, Mesh, BoundingBox, Path e WeightData; classes, limpeza, getters e pool portados |
| model/SkinData.ts | dragonbones/original/model/SkinData.lua | Mapa de displays por slot, busca, associação parent, nulos e limpeza com pool |
| model/DragonBonesData.ts | dragonbones/original/model/DragonBonesData.lua | Metadados, arrays, mapa de armaduras, add/get, reciclagem e referências binárias |
| model/ArmatureData.ts | dragonbones/original/model/ArmatureData.lua | Quatro classes originais: `ArmatureData`, `BoneData`, `SurfaceData`, `SlotData`; ordenação, caches, associação de dados e limpeza |

Testes determinísticos: `tests/original_geom.lua`, `tests/original_core.lua`, `tests/original_worldclock.lua`, `tests/original_events.lua` e `tests/original_transform_models.lua` e `tests/original_display_skin_data.lua` (Lua 5.4 no GitHub Actions). Os novos testes cobrem reutilização LIFO, descarte e tamanho dos pools, contador de identidade, limpeza, valores negativos/NaN, retorno duplicado e todos os métodos de `ColorTransform`.

**Não se deve tratar estes testes locais como prova de equivalência 1:1 do runtime inteiro.** Falta um comparador diferencial exaustivo contra a execução do original. Diferenças de linguagem: classes TS vs tabelas/metatables Lua, deslocamento de arrays zero-based para um-based, semântica de resto assinada (`math.fmod`) e diferenças de stringificação em `toString`. `BaseObject` usa uma tabela de classe como chave de pool, em lugar de `String(object.constructor)`, pois Lua não dispõe dessa representação textual de construtor; subclasses fornecem `Class.new()` e chamam `BaseObject.new(Class)`. Preservam-se a sequência de operações, comportamento do pool e o incremento do `hashCode`, mas ainda falta validação diferencial abrangente contra o TypeScript executado. A mutabilidade e a ordem de cálculo foram mantidas no porte inicial.

### WorldClock.ts — fronteira técnica e testes

Fonte: `DragonBones/src/dragonBones/animation/WorldClock.ts` no commit fixado. `IAnimatable.ts` é uma interface TypeScript (contrato `advanceTime(passedTime)` e `clock`) e **não possui algoritmo para portar**; os testes usam objetos Lua que satisfazem exatamente esse contrato.

Porte inclui `constructor`, `advanceTime`, `contains`, `add`, `remove`, `clear` e getter/setter `clock`. Um sentinela Lua representa elementos `null` do array JavaScript para manter a compactação no mesmo estágio de `advanceTime`, inclusive ao inserir/remover objetos em callbacks. A peculiaridade do `clear()` original é preservada: ele zera referências de relógio, mas não remove diretamente os elementos da lista. Não há redesenho do algoritmo.

Diferença inevitável de plataforma: `Date.now()` do TypeScript fornece milissegundos; Lua padrão (`os.time()`) fornece resolução de segundos, e o host LÖVE usa `love.timer.getTime()` para alta resolução. A implementação permite substituir apenas a fonte de tempo `WorldClock._now` em testes determinísticos; o algoritmo de cálculo de tempo permanece o original. Como consequência, a precisão do modo de tempo automático em Lua 5.4 isolado ainda **não equivale ao relógio original**. A biblioteca `WorldClock` permanece isolada do protótipo anterior até que os demais módulos originais estejam prontos.



### Portes de eventos e núcleo DragonBones

Fonte exata no commit fixado: `model/UserData.ts` (classes `UserData` e `ActionData`), `event/EventObject.ts` e `core/DragonBones.ts`. A interface `event/IEventDispatcher.ts` define somente o contrato de quatro métodos, sem implementação compartilhada para portar. Os testes usam objetos que implementam esse contrato; **não foi criada uma implementação substituta no motor**.

O `DragonBones.ts` porta os enums numéricos da fonte, a versão 5.7.000, `advanceTime`, `bufferEvent`, `bufferObject`, `clock` e `eventManager`. A fila processa também eventos incluídos pelos handlers durante o despacho, encaminha eventos sonoros ao gerenciador global e adia a devolução de objetos ao pool para o próximo ciclo, conforme o original. `EventObject` conserva `actionDataToInstance`, a associação com ossos/slots e a limpeza de referências. `UserData` conserva arrays e indexação pública original a partir de zero; `ActionData` devolve seus dados aninhados ao pool.

**Diferenças técnicas:** a implementação usa metatables Lua em vez de herança TypeScript, e mapas/tabelas de enums em vez de enums TypeScript eliminados na compilação. O despacho de eventos espera o contrato original do `Armature`, ainda não portado; o teste usa dublês limitados ao contrato e não os contabiliza como porte. Os shims globais exclusivos do ambiente JS (CommonJS/AMD, console e `__extends`) **não são usados no runtime Lua**. Ainda faltam conformidade diferencial executando código TypeScript original, tratamento de edge cases de ciclos de eventos e as classes completas de Armature, Bone e Slot.

### Lote — TransformObject e modelos dependentes de armadura

Fonte inspecionada no commit fixado: `armature/TransformObject.ts`, `model/CanvasData.ts`, `model/ConstraintData.ts` e `model/TextureAtlasData.ts`. Cada arquivo foi portado **inteiro** para seus módulos em `dragonbones/original/`, sem implementar atalhos no runtime antigo. As classes abstratas (`TransformObject`, `ConstraintData`, `TextureAtlasData` e `TextureData`) continuam abstratas; os testes utilizam subclasses privadas, sem incluí-las no produto como substitutas.

A transformação global preserva a propriedade `_globalDirty` e só decompõe a matriz quando `updateGlobalTransform()` é chamado com esse sinal ativo. `ConstraintData.ts` inclui a classe básica e as subclasses IK e Path, com método `AddBone` preservado com maiúsculas. `TextureAtlasData.ts` inclui `TextureData.createRectangle`, `copyFrom`, `addTexture`, `getTexture`, `createTexture` abstrato e devolução dos objetos de textura ao pool; preserva inclusive a referência a `source.parent` ao copiar `TextureData`, sem corrigi-la por conta própria.

Diferenças de linguagem: propriedades `readonly` e getters TypeScript são representados por campos e metatables Lua; subclasses em Lua devem encaminhar a propriedade herdada `armature`. A implementação de `createTexture` depende da futura implementação de plataforma, como a classe abstrata original; ausência de backend provoca erro explícito. `console.warn` é adaptado para `io.stderr`. Contagens de arrays Lua começam em 1, sem alterar a ordem dos dados.

Testes: `tests/original_transform_models.lua`, **21 cenários** cobrindo identidades, mutabilidade, casos de limpeza, IK/Path, frames recortados, duplicatas de textura e pool. Não é uma demonstração de equivalência binária com os runtimes Cocos/Pixi; ainda faltam testes diferenciais contra a execução TypeScript do commit fixado, além de Bone/Slot/Armature completos.

Branch do lote: `port-original-transform-models`. Integrado pelo [PR #6](https://github.com/SrTristeSad/Bono-Lua/pull/6), commit [d026762](https://github.com/SrTristeSad/Bono-Lua/commit/d026762ca8faf5fbb558760b8520d6a191162f26). A CI do PR aprovou **102 testes Lua** (81 existentes + 21 novos) e a verificação gráfica do LÖVE; ainda não há comparação diferencial exaustiva com o TypeScript executado.


### Lote de dados de exibição, skin e projeto

Fonte examinada: `model/DisplayData.ts`, `model/SkinData.ts` e `model/DragonBonesData.ts` no mesmo commit fixado. Portes: `dragonbones/original/model/DisplayData.lua`, `SkinData.lua` e `DragonBonesData.lua`. Arquivo `DisplayData.ts` inclui **oito classes** (`GeometryData`, a base abstrata `DisplayData`, `ImageDisplayData`, `ArmatureDisplayData`, `MeshDisplayData`, `BoundingBoxDisplayData`, `PathDisplayData`, `WeightData`), todos os campos com inicialização, os métodos de limpeza e acesso, e a semântica de posse de `WeightData` (peso compartilhado não retorna ao pool ao limpar o objeto que o compartilha).

`SkinData` preserva a ordem da lista de displays por slot, a associação `display.parent` e a reciclagem de cada display não nulo. **Diferença Lua inevitável:** para manter uma posição de display explicitamente `null` dentro de um array sequencial, usa `SkinData.NULL` como sentinela; nenhuma outra ação deve tratá-la como display real. `DragonBonesData` preserva os mapas, campos de arrays binários tipados como referências ainda não inicializadas, nomes de armaduras ordenados e a sequência de limpeza e reciclagem. A interpretação do buffer binário DBBIN ainda depende do porte futuro do parser correspondente.

Testes: `tests/original_display_skin_data.lua`, **27 cenários** de construtores, subclasses, enum de display, geometria binária, pesos compartilhados, arrays nulos, troca de parent, cópias, mapas e descarte. Verificam comportamentos estáticos; **ainda não comprovam uma comparação diferencial 1:1 executando TypeScript e Lua**.

Branch: `port-original-display-skin-data`. Integrado pelo [PR #7](https://github.com/SrTristeSad/Bono-Lua/pull/7), commit [4d334b3](https://github.com/SrTristeSad/Bono-Lua/commit/4d334b3fe655d7232c5d367eddb4bae99621185c). A CI do PR aprovou **129 testes Lua** (102 anteriores + 27 novos), a verificação de sintaxe e o teste gráfico LÖVE. Comparação diferencial completa com o TypeScript original ainda pendente.

### Lote: ArmatureData.ts — classes e métodos originais

Fonte integral verificada: `DragonBones/src/dragonBones/model/ArmatureData.ts` do commit `64b6c69ae35777c2404be68c9192e2c56906079e` (688 linhas). Destino: `dragonbones/original/model/ArmatureData.lua`. O arquivo reúne **quatro classes**: `ArmatureData`, `BoneData`, `SurfaceData`, `SlotData`. Todas as classes e métodos de instância presentes no arquivo foram traduzidos. A classe `SurfaceData` usa o `GeometryData` portado anteriormente.

`ArmatureData` preserva o algoritmo circular de `sortBones` para esperar ossos pais e alvos de constraints, sem substituir por ordenação topológica própria. O original não trata ciclos sem saída: **não foi acrescentada detecção de ciclos**, pois seria uma mudança de algoritmo. Implementados `cacheFrames`, `setCacheFrame` e `getCacheFrame` com dez valores por entrada; offsets públicos de cache continuam iniciando em **zero**, mesmo que as posições dos arrays Lua iniciem em um. São preservadas as cinco tabelas de acesso, listas ordenadas, seleções padrão, funções de inclusão com checagem de duplicatas e getters originais. `BoneData`, `SurfaceData` e `SlotData` preservam inicializações, hierarquia e `_onClear`/devolução ao pool; `SlotData.DEFAULT_COLOR` e `createColor` são originais.

Testes: `tests/original_armature_data.lua` cobre **19 cenários** de valores padrão, ordenação pai/constraint, cache e offsets, duplicatas, skins e animações padrão, associações parentais, devolução aninhada ao pool e identidade de objetos. A classe `AnimationData.ts` ainda não foi portadа: os testes usam um objeto mínimo *somente no teste*, para verificar os métodos `cacheFrames` e `returnToPool` chamados a partir de `ArmatureData`. Nenhum stub foi incluído na implementação de produção.

**Pendências:** port de `AnimationData.ts`, além de `Bone.ts`, `Slot.ts` e `Armature.ts` (classes do runtime, distintas dos dados); comparação diferencial executando TypeScript original ainda não existe. Adaptações de Lua: metatables como classes, `nil` para `null`, `io.stderr` para `console.warn`, índices Lua base 1. Fonte, licenciamento MIT e comportamento de dependências permanecem registrados.

Branch de trabalho: `port-original-armature-data`. Resultado de CI/PR e SHA serão atualizados após a integração.

## Código que já existia antes deste porte

Arquivos como dragonbones/matrix.lua, parser.lua, animation.lua e atlas.lua eram uma implementação própria simplificada. **Não são portes fiéis**; permanecem funcionando para não quebrar a demonstração LÖVE, mas não contam como módulos originais reconstruídos. Só substituir essas rotas quando o porte fiel estiver completo, verificado e integrado.

## Continuidade obrigatória

1. Todos os cinco arquivos da pasta `geom/` foram portados inicialmente. Aumentar testes diferenciais com o original executado, incluindo números especiais.
2. `ArmatureData.ts` agora possui porte inicial de suas quatro classes. A próxima dependência do runtime é `AnimationData.ts` (e seus tipos de timeline), seguida da análise de `Bone.ts`, `Slot.ts` e `Armature.ts` em ordem de dependências. Evitar substitutos simplificados.
3. Portar dados, parsers, fábricas, armaduras, animação, timelines, slots, malhas, FFD, IK e constraints na arquitetura do original. Mapear cada arquivo.
4. Conectar os módulos fiéis ao LÖVE somente como backend gráfico; ele não define a semântica do DragonBones.
5. Identificar a fonte e versão do editor GUI original e portar esse editor separadamente para Lua, conforme disponibilidade/licença.
6. **Somente então** discutir melhorias adicionais.

## Lote atual

Fonte examinada antes do porte: `geom/ColorTransform.ts` e `core/BaseObject.ts`, ambos do commit fixado. Branch de desenvolvimento: `port-original-core-pool`. Código integrado à `main` pelo [PR #3](https://github.com/SrTristeSad/Bono-Lua/pull/3), commit de integração [`73beb1d`](https://github.com/SrTristeSad/Bono-Lua/commit/73beb1d94637de254354707b82184f461074057a). A CI só prova os comportamentos expressamente testados, não uma equivalência 1:1 do runtime.

### Lote WorldClock

Branch: `port-original-worldclock`. Origem fixa: `animation/WorldClock.ts` e contrato `animation/IAnimatable.ts`. Destinos: `dragonbones/original/animation/WorldClock.lua` e `tests/original_worldclock.lua`. CI compara cenários definidos de tempo automático, `timeScale`, elementos removidos, repetição de adição, ancestrais, relógios aninhados e callbacks. Integração: [PR #4](https://github.com/SrTristeSad/Bono-Lua/pull/4), commit [77f5dee](https://github.com/SrTristeSad/Bono-Lua/commit/77f5dee46199a29024910ca80af6b3a3acee5ea3). Na execução do PR, passaram 22 testes do protótipo, 11 de geometria, 14 de core e 15 de WorldClock, além da verificação gráfica LÖVE. Falta comparação diferencial exaustiva executando o original.

### Lote eventos e núcleo

Branch de trabalho: `port-original-events-core`; código: `dragonbones/original/{model/UserData,event/EventObject,core/DragonBones}.lua`; testes: `tests/original_events.lua`. Integrado pelo [PR #5](https://github.com/SrTristeSad/Bono-Lua/pull/5), commit [8728a05](https://github.com/SrTristeSad/Bono-Lua/commit/8728a057202c902816c32b9aca4b3fc0dde8ef60). A CI do PR aprovou 22 testes do protótipo, 11 geométricos, 14 do core anterior, 15 do WorldClock e 19 dos eventos (81 no total), além da captura e do teste de pixels LÖVE. Não há teste diferencial completo executando o original.

Toda próxima fase deve registrar a comparação, os testes, pendências e o commit sem alterar os objetivos.
