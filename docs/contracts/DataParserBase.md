# Base abstrata DataParser

Fonte: parser/DataParser.ts de DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e. Produto: dragonbones/parser/DataParser.lua.

| Parte | Contrato preservado |
| --- | --- |
| 132 constantes | Nomes/valores exatos, incluindo DRADON_BONES e DEFAULT_NAME |
| DATA_VERSION | Valor 5.6 capturado na inicialização, sem recalcular se outra constante for alterada depois |
| DATA_VERSIONS | 4.0, 4.5, 5.0, 5.5, 5.6 nessa ordem; 2.3 e 3.0 não são acrescentadas |
| _getArmatureType | stage/armature/movieclip; default Armature |
| _getBoneType | bone/surface; default Bone |
| _getPositionMode | percent/fixed; default Percent |
| _getSpacingMode | length/percent/fixed; default Length |
| _getRotateMode | tangent/chain/chainscale; default Tangent |
| _getDisplayType | image/mesh/armature/boundingbox/path; default Image |
| _getBoundingBoxType | rectangle/ellipse/polygon; default Rectangle |
| _getBlendMode | Os 14 nomes da fonte; default Normal |
| _getAnimationBlendType | none/1d; default None |
| _getActionType | play/frame/sound; default Play |

Os helpers recebem strings e ignoram caixa, sem remover espaços ou converter números/boolean/objetos em strings. Matching ASCII independe do locale C. Unicode Kelvin K baixa para k e pode formar darken; isso não transforma o módulo num serviço geral de Unicode. As três funções Position/Spacing/Rotate usam toLocaleLowerCase na fonte: comparação cobre o casing não túrquico/en-US; locales tr/az, por exemplo FIXED/CHAIN com I, têm regras diferentes e exigem adaptação do host ainda pendente. Strings Lua são transportadas como UTF-8 no teste, sem afirmar equivalência de surrogates UTF-16 isolados.

DATA_VERSIONS é JSArray base 1 com `.length` lógico. Alias herdado aponta para o mesmo array até sobrescrita na classe derivada; holes/length/extras e identidade de mutações são preservados. Constantes protected/readonly são acessíveis em tabela, como propriedades do emit JS; não são congeladas por novo comportamento no porte.

Assinaturas abstratas sem corpo upstream:

- parseDragonBonesData(rawData, scale) → DragonBonesData ou null.
- parseTextureAtlasData(rawData, textureAtlasData, scale) → boolean.

O módulo não implementa esses métodos e não devolve nil/false artificialmente. Subclasses futuras devem implementar os algoritmos reais. DataParser não é BaseObject, não tem pool ou construtor de runtime inventado. Os testes aplicam enums retornados a modelos reais e os devolvem ao pool; isso comprova consumo dos helpers, sem importar rawData nem validar JSON/DBDT, typed arrays, animação ou renderização.
