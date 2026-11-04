# DisplayFrame

Fonte: DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e, classe DisplayFrame em armature/Slot.ts. Módulo: dragonbones.armature.DisplayFrame. Não representa a outra classe Slot do mesmo arquivo.

Use BaseObject.borrowObject(DisplayFrame), atribua rawDisplayData/displayData/textureData/display e chame os métodos originais. O frame não possui os dados nem o display: _onClear apenas remove referências e trunca deformVertices, preservando a identidade do array. Não devolve os modelos ao pool.

getGeometryData e getBoundingBox preferem o substituto somente quando seu tipo é compatível; a ausência do payload nesse tipo retorna nil, sem fallback. getTextureData prefere Image/Mesh substituto, inclusive quando sua textura é nil; depois considera textureData explícita e Image/Mesh bruto. Path não fornece textura.

updateDeformVertices usa somente a geometria bruta Mesh/Path. Retorna imediatamente se não há rawDisplayData ou se o array já tem length diferente de zero, inclusive arrays só com holes. Geometria ponderada aloca weight.count*2; outra geometria lê intArray[offset+GeometryVertexCount]*2. Atribui length antes de preencher zeros; erro não antecipa nem limpa o estado. Valores não numéricos ausentes na aritmética viram NaN; JSArray rejeita length inválido. Array público Lua base 1, offset binário base 0.

Domínio validado: objetos reais do modelo iniciados/limpos via pool, referências opcionais null/undefined normalizadas nil, contagens pequenas inteiras, erros de count/offset/data descritos na suíte, e buffers esparsos. TextureData é construído e limpo diretamente no teste porque é abstrato para o pool; nenhuma classe gráfica fictícia foi adicionada. Não abrange proxies, getter com efeitos colaterais, coerções arbitrárias, alocações enormes ou uso antes de _onClear. readonly TypeScript não é bloqueio runtime do array.

2.304 cenários/32.256 colunas por VM, 192 falhas esperadas, comparação textual exata incluindo identidades lógicas, holes e zero assinado. O oráculo executa o upstream fixado, não o backup Lua. Exemplo displayframe exercita view Int16 real; teste diferencial usa Int16Array TS e array Lua decodificado.
