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

Testes determinísticos: `tests/original_geom.lua` e `tests/original_core.lua` (Lua 5.4 no GitHub Actions). Os novos testes cobrem reutilização LIFO, descarte e tamanho dos pools, contador de identidade, limpeza, valores negativos/NaN, retorno duplicado e todos os métodos de `ColorTransform`.

**Não se deve tratar estes testes locais como prova de equivalência 1:1 do runtime inteiro.** Falta um comparador diferencial exaustivo contra a execução do original. Diferenças de linguagem: classes TS vs tabelas/metatables Lua, deslocamento de arrays zero-based para um-based, semântica de resto assinada (`math.fmod`) e diferenças de stringificação em `toString`. `BaseObject` usa uma tabela de classe como chave de pool, em lugar de `String(object.constructor)`, pois Lua não dispõe dessa representação textual de construtor; subclasses fornecem `Class.new()` e chamam `BaseObject.new(Class)`. Preservam-se a sequência de operações, comportamento do pool e o incremento do `hashCode`, mas ainda falta validação diferencial abrangente contra o TypeScript executado. A mutabilidade e a ordem de cálculo foram mantidas no porte inicial.

## Código que já existia antes deste porte

Arquivos como dragonbones/matrix.lua, parser.lua, animation.lua e atlas.lua eram uma implementação própria simplificada. **Não são portes fiéis**; permanecem funcionando para não quebrar a demonstração LÖVE, mas não contam como módulos originais reconstruídos. Só substituir essas rotas quando o porte fiel estiver completo, verificado e integrado.

## Continuidade obrigatória

1. Todos os cinco arquivos da pasta `geom/` foram portados inicialmente. Aumentar testes diferenciais com o original executado, incluindo números especiais.
2. Continuar o `core/` após `BaseObject` e mapear suas dependências reais antes de integrar `DragonBones.ts`; examinar eventos, relógio e modelos que dependem da base.
3. Portar dados, parsers, fábricas, armaduras, animação, timelines, slots, malhas, FFD, IK e constraints na arquitetura do original. Mapear cada arquivo.
4. Conectar os módulos fiéis ao LÖVE somente como backend gráfico; ele não define a semântica do DragonBones.
5. Identificar a fonte e versão do editor GUI original e portar esse editor separadamente para Lua, conforme disponibilidade/licença.
6. **Somente então** discutir melhorias adicionais.

## Lote atual

Fonte examinada antes do porte: `geom/ColorTransform.ts` e `core/BaseObject.ts`, ambos do commit fixado. Branch de desenvolvimento: `port-original-core-pool`. Código integrado à `main` pelo [PR #3](https://github.com/SrTristeSad/Bono-Lua/pull/3), commit de integração [`73beb1d`](https://github.com/SrTristeSad/Bono-Lua/commit/73beb1d94637de254354707b82184f461074057a). A CI só prova os comportamentos expressamente testados, não uma equivalência 1:1 do runtime.

Toda próxima fase deve registrar a comparação, os testes, pendências e o commit sem alterar os objetivos.
