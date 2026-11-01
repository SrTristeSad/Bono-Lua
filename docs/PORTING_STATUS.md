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

Testes locais determinísticos: tests/original_geom.lua, executados pelo GitHub Actions em Lua 5.4.

**Não se deve tratar estes testes locais como prova de equivalência 1:1 do runtime inteiro.** Falta um comparador diferencial exaustivo contra a execução do original. Diferenças de linguagem a documentar: classes TS vs tabelas/metatables Lua, deslocamento de arrays zero-based para um-based, semântica de resto assinada (math.fmod), e diferenças de stringificação de números em toString. A mutabilidade e a ordem de cálculo foram mantidas no porte inicial.

## Código que já existia antes deste porte

Arquivos como dragonbones/matrix.lua, parser.lua, animation.lua e atlas.lua eram uma implementação própria simplificada. **Não são portes fiéis**; permanecem funcionando para não quebrar a demonstração LÖVE, mas não contam como módulos originais reconstruídos. Só substituir essas rotas quando o porte fiel estiver completo, verificado e integrado.

## Continuidade obrigatória

1. Revisar todos os arquivos restantes da pasta geom da fonte fixada, se houver, e completar testes diferenciais de ponto, matriz, retângulo e transformação.
2. Mapear dependências e portar classes do core original (incluindo seus contratos de objetos e eventos) mantendo assinaturas e casos extremos.
3. Portar dados, parsers, fábricas, armaduras, animação, timelines, slots, malhas, FFD, IK e constraints na arquitetura do original. Mapear cada arquivo.
4. Conectar os módulos fiéis ao LÖVE somente como backend gráfico; ele não define a semântica do DragonBones.
5. Identificar a fonte e versão do editor GUI original e portar esse editor separadamente para Lua, conforme disponibilidade/licença.
6. **Somente então** discutir melhorias adicionais.

Toda próxima fase deve registrar a comparação, os testes, pendências e o commit sem alterar os objetivos.
