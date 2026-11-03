# Dependências estruturais de ObjectDataParser

Fonte única fixada: DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e. Nove corpos adicionais em ObjectDataParser.lua:

| Métodos | Consumo e estado |
| --- | --- |
| _parseTransform/_parseColorTransform | Transform/ColorTransform reais; ordem de atribuição e efeitos parciais preservados |
| _parsePivot | ImageDisplayData real, defaults 0.5 ou valores raw explícitos |
| _parseSlot | SlotData real, parent real, DEFAULT_COLOR ou cor nova, cache de ações |
| _parseActionData | ActionData/UserData reais; valores de payload preservados, refs e ownership originais |
| _parseIKConstraint | IKConstraintData real; root/bone dependem de chain e parent estritamente null |
| _parsePathConstraint | PathConstraintData real com slot/skin/path/bones reais; aceita subclasses de PathDisplayData |
| _parseBoundingBox/_parsePolygonBoundingBox | Três formas reais, polígonos escalados e AABB conforme fonte |

São dependências, não entrypoints de importação: o contexto _armature do teste é preenchido por modelos reais; _parseArmature/_parseBone/_parseSkin/_parseDisplay e geometria continuam ausentes. Não há objetos de modelo fictícios para completar chamadas.

UserData agora tem arrays JSArray base 1/length. Push de undefined é nil com length mantido; getters olham length, não #. Clear preserva identidade e extras. Null malformado em payload mantém o marcador raw de JSValue. ArmatureData._isNullReference é adaptador interno de linguagem para ler estado privado undefined/null; a API pública continua lendo nil para ambos.

For-of da fonte é executado pelo emit TS2.4 target ES5: loops por índice e length vivo, inclusive arrays semelhantes e strings UTF-16. O adaptador não introduz Symbol.iterator. Em strings não BMP, uma iteração pode produzir surrogate isolado: Lua o representa em WTF-8; o teste compara unidades UTF-16LE para não substituir por U+FFFD. Entradas comuns continuam UTF-8. Coerções/proxies/reflexão gerais e decodificação JSON/binária não são afirmadas.

Validação: 55 cenários/2.465 operações/27.115 colunas por VM, zero tolerância, incluindo alocações órfãs/erros e regressão de UserData. Contexto de parser não significa runtime/renderização. Faltam 33 de 47 métodos do arquivo.
