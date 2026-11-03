# ObjectDataParser — atlas e helpers (parcial)

Fonte: parser/ObjectDataParser.ts de DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e. Produto dragonbones/parser/ObjectDataParser.lua; adaptação de linguagem em JSValue.lua. Não é um decoder JSON.

| Parte implementada | Contrato |
| --- | --- |
| _getBoolean | Chave ausente usa default; strings 0/NaN/vazia/false/null/undefined são falsas por igualdade literal; outros valores usam truthiness JS |
| _getNumber | Ausente/null/string exata NaN usam default; unary Number e fallback +0 para demais valores falsy/NaN, preservando infinito |
| _getString | Ausente usa default; null/undefined presentes produzem strings correspondentes; arrays usam join e números usam JSNumberString |
| parseTextureAtlasData | Preenche dimensões, escala, nome, imagePath, cria texturas/retângulos reais e insere no atlas; não escala regiões |
| new/getInstance | 38 inicializadores originais e singleton; instâncias não são BaseObject |
| ActionFrame | frameStart=0 e actions lógico vazio; exportado via ObjectDataParser.ActionFrame |

`TextureAtlasData`/`TextureData` são abstratas: um backend precisa implementar createTexture. Os testes fornecem subclasses mínimas sobre os modelos reais, sem renderização ou simulação do parser. Duplicata pode deixar textura criada fora do mapa/pool; preservar a fonte. Falhas não desfazem campos nem alocações anteriores. Frame existe apenas se frameWidth/frameHeight forem ambos positivos; raw scale só é invertida quando o argumento scale é exatamente 1.

Valores raw: use tabelas para objetos, JSValue.array() para arrays base 1/length, JSValue.NULL para null presente e JSValue.UNDEFINED para undefined presente. Nil em uma propriedade significa ausência. Não confundir estes marcadores com SkinData.NULL; um marcador raw não é display. JSON externo precisa ser decodificado e adaptado a essa representação. Não adivinhar arrays por # nem apagar null como se fosse ausência.

No argumento raw de parseTextureAtlasData, nil explícito/NULL significa consumir fila; ausência/UNDEFINED emite assert e segue para falha original. Escala nil/UNDEFINED significa default 1; null explícito usa o marcador. Fila privada é injetada em testes até parseDragonBonesData real existir; índice incrementa antes de recursão e só reseta após sucesso, lendo a fila atual. Não é uma API pública nova para enfileirar dados.

Coerções cobrem valores JSON-like, arrays e objetos simples, gramática decimal/Infinity/hex/bin/oct e whitespace ECMAScript. Não implementam funções/Symbol/BigInt, coerções customizadas, getters/proxies/descritores ou Object.prototype genérico. Uint/Float views e buffer binário têm contrato futuro próprio. Locales especiais de DataParser continuam pendentes.

## Métodos ainda ausentes (42 de 47)

_getCurvePoint, _samplingEasingCurve, _parseActionDataInFrame, _mergeActionFrame, _parseArmature, _parseBone, _parseIKConstraint, _parsePathConstraint, _parseSlot, _parseSkin, _parseDisplay, _parsePath, _parsePivot, _parseMesh, _parseBoundingBox, _parsePolygonBoundingBox, _parseAnimation, _parseTimeline, _parseBoneTimeline, _parseSlotTimeline, _parseFrame, _parseTweenFrame, _parseSingleValueFrame, _parseDoubleValueFrame, _parseActionFrame, _parseZOrderFrame, _parseBoneAllFrame, _parseBoneTranslateFrame, _parseBoneRotateFrame, _parseBoneScaleFrame, _parseSlotDisplayFrame, _parseSlotColorFrame, _parseSlotDeformFrame, _parseIKConstraintFrame, _parseActionData, _parseDeformFrame, _parseTransform, _parseColorTransform, _parseGeometry, _parseArray, _modifyArray, parseDragonBonesData.

Não há substitutos que retornem nil/false para esses métodos. Importação de armaduras/animações, geometria, timelines, compactação e parseDragonBonesData precisam das implementações originais e testes próprios antes de declarar parsing completo.
