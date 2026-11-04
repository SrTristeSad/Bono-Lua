# Slot — fundação parcial

Fonte: DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e, classe Slot de armature/Slot.ts. DisplayFrame é um módulo separado. O backup Lua cd4206a8 foi lido como referência de tradução; o oráculo executa o TS fixado.

## Implementado

Inicializadores de Slot.new(ConcreteClass), _onClear, _hasDisplay, _isBonesUpdate, _updateAlpha, _updateGlobalTransformMatrix, _setDisplayIndex, _setZOrder, _setColor, init, invalidUpdate, updateTransformAndMatrix, containsPoint, intersectsSegment e getDisplayFrameAt. Getters visible/displayFrameCount/name/slotData/boundingBoxData/rawDisplay/meshDisplay/parent e armature herdado; setters visible/displayFrameCount. Metamétodos de subclasses devem delegar Slot.__index/__newindex. Slot conserva toString abstrato herdado, sem chave concreta fictícia de pool.

Armature parcial recebe _addSlot (deduplicação por identidade) e getSlot. getSlots retorna o array vivo. Bone.visible e Armature.invalidUpdate agora são comparados também com slots não vazios. init publica estado/registro antes de _initDisplay/_onUpdateDisplay/_addDisplay, inclusive chamadas com null. Chamadas repetidas não reinicializam.

Os quatorze hooks gráficos permanecem abstratos e sem implementação no produto. Teste/exemplo usam subclasses observadoras locais que registram os cinco hooks chamados neste recorte; não desenham nem substituem Slot.update.

## Comportamento preservado

_onClear limpa a base antes de coletar displays, devolve frames antes de chamar disposers, deduplica displays por identidade (incluindo null) e descarta mesh/raw com isRelease=false. Os arrays/matriz/cor mantêm identidade. Frames não possuem os dados referenciados. Retornar Slot ao pool não devolve SlotData nem caixas de colisão ao pool.

A condição original `for (let i=prevCount-1; i < value; --i)` da redução de frames foi preservada. Para reduções inteiras não negativas, não há callback nem pooling: apenas truncamento. Comparações de display usam rawequal para manter ===/!== do TS mesmo quando referências Lua têm __eq. O teste inclui displays com __eq que retorna true para objetos distintos.

O teste mantém referências removidas para verificar esse efeito e as libera manualmente depois. Não tratar esse comportamento como correção autorizada do upstream.

_setDisplayIndex conserva índice negativo, limita superior pela quantidade, separa a guarda de animação e marca estado antes de possível erro de índice fracionário. _setZOrder sempre marca dirty, mesmo com valor igual. visible publica a flag antes do hook. _isBonesUpdate percorre além das entradas null no array lógico. _updateAlpha só marca cor quando o produto muda.

Transformação concatena matriz local e matriz do pai; isCache=false marca _globalDirty, isCache=true decompõe. Hit testing atualiza a matriz quando dirty, inverte coordenadas de entrada e retorna pontos/normais no espaço da armadura. Sem caixa retorna imediatamente false/0, sem limpar dirty. Outputs ausentes permanecem ausentes; outputs fornecidos preservam mutações/aliases originais nos cenários do teste.

## Domínio e pendências

1.448 cenários/56.472 colunas por VM, 120 falhas esperadas e 30 aproximações. Corpos testados com objetos iniciados pelo pool, campos numéricos binary64, comprimentos pequenos inteiros não negativos, referências opacas de display e ossos regulares reais. Null/undefined opcionais são nil; arrays públicos têm length e índices Lua base 1, getDisplayFrameAt/índice de display usam base 0. As classes observadoras locais usam pool limpo por cenário para não misturar closures de classes com a mesma chave toString; reuso dentro do cenário é comparado.

Hit testing: retângulo/elipse, matrizes identidade/escala/reflexão/rotação de eixo/shear/singularidade, sete segmentos e oito máscaras de outputs. Matrizes/flags/identidades/comprimentos/zeros são exatos; apenas pose decomposta e outputs matemáticos não nulos aceitam até 8*epsilon*max(1,abs(expected)). Nenhum budget numérico antigo foi alterado. Polígono/aliases de outputs e pai Surface não foram validados nesta integração; seus corpos originais permanecem, com testes próprios anteriores de modelos/Surface.

Slot.update, _updateDisplay, APIs públicas displayIndex/displayList/display/childArmature, replaceDisplay, animação e renderer ainda ausentes. Não escrever essas propriedades para simular implementação. Child Armature em _onClear exige Armature.dispose ainda pendente, portanto não está no domínio deste recorte. Callbacks reentrantes, falha em dispose, protótipos/proxies/coerções arbitrários, alocações enormes e uso antes de _onClear não são equivalência reivindicada.

Atualização posterior: _updateDisplayData e as três APIs de dados já estão portadas/comparadas; ver [SlotDisplayData.md](SlotDisplayData.md). As métricas acima documentam a fundação original.

Atualização posterior: corpos restantes de Slot, update/acessores/troca de objetos e suporte parcial a child Armature estão representados e comparados no recorte [SlotRuntime.md](SlotRuntime.md). As pendências e métricas acima descrevem a unidade original; Animation/backend e Armature.init/advanceTime continuam pendentes.
