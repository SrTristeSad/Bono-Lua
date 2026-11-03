# Consultas locais de BoundingBoxData

Fonte: model/BoundingBoxData.ts de DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e. Produto: dragonbones/model/BoundingBoxData.lua; quatro classes exportadas por esse módulo, usando BaseObject real.

| API | Observação preservada |
| --- | --- |
| RectangleBoundingBoxData.containsPoint | AABB centrado na origem, bordas inclusas |
| rectangleIntersectsSegment | Cohen–Sutherland, contagens -1/0/1/2/3; quando A interior, pointB.y recebe xB como no original |
| EllipseBoundingBoxData.toString | Nome original [class dragonBones.EllipseData] |
| ellipseIntersectsSegment | Usa d=widthH/heightH; mantém fórmula original inclusive centro não zero; não recalcula normais de duas interseções se outputs correspondentes ausentes |
| polygonIntersectsSegment | Perturba eixos iguais por 0.000001 e arestas por 0.0001; sem pointB para na primeira interseção; com múltiplas, retorna count+1 |
| PolygonBoundingBoxData.containsPoint | Usa x/y como mínimo e width/height diretamente como máximos, conforme TS |
| PolygonBoundingBoxData.intersectsSegment | Broad phase usa x+width/y+height, conforme TS, seguido do método estático |

Argumentos numéricos seguem o contrato number upstream. Saídas são tabelas x/y mutáveis (Point real no teste) ou nil. Nil nas saídas equivale a null/default omitido. Mesma tabela pode ocupar mais de uma saída; ordem de escrita/aliases e efeitos parciais em falhas são preservados. Uma chamada sem interseção pode deixar valores anteriores nas saídas; eles não são resetados preventivamente.

vertices é JSArray numérico com índices Lua base 1 e `.length` lógico; não usar #/ipairs em algoritmos com holes. Clear esvazia length preservando objeto e extras. Campos crus ausentes e holes entram nas operações numéricas como NaN; não há defaults adiantados antes de borrow/clear. O construtor de Polygon só cria vertices, além de BaseObject.

Comparação: contagens/booleans/campos/pontos exatos; só componentes não nulas derivadas de atan2 (também quando mantidas entre chamadas ou escritas em destino compartilhado) admitem 8*epsilon*max(1,abs(expected)). NaN canonicalizado; sinal do zero exato. Isso reconhece diferenças V8/libm, não altera algoritmos nem aplica epsilon para decidir interseções.

BoundingBoxDisplayData é proprietário de boundingBox; o clear devolve a forma ao pool. Essa cadeia é testada com skin/armadura/global reais. São consultas no sistema local; Slot/Armature de runtime, transformações mundiais, parser e backend ainda precisam de implementação/validação próprias. Nenhuma proteção contra não terminação em clipping com bounds invertidos foi acrescentada à fonte.
