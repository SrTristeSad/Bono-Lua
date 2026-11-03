# Listas de displays de SkinData

Fonte: model/SkinData.ts em DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e. SkinData/ArmatureData e os displays são implementações reais; este documento descreve apenas a representação Lua indispensável para DisplayData | null.

| Valor na lista | Representação Lua | Comportamento |
| --- | --- | --- |
| DisplayData | Instância real do modelo | parent atribuído no add; devolução ao pool no clear |
| null explícito | SkinData.NULL, marcador único | Ignorado no lookup e no clear; não é um display ou objeto poolável |
| undefined / hole | Leitura nil dentro de length | Erro ao acessar name/returnToPool; não é tratado como null |

addDisplay(slotName, nil) adiciona null explícito; SkinData.NULL também é aceito. Omitir o segundo argumento representa undefined e lança erro depois de criar a lista vazia. Para leituras de getDisplays, comparar posições com rawequal(valor, SkinData.NULL); o marcador é truthy em Lua e não deve ser tratado como display por um consumidor.

```lua
skin:addDisplay("slot", nil)
local list = skin:getDisplays("slot")
assert(rawequal(list[1], SkinData.NULL))
list[2] = SkinData.NULL -- null explícito
rawset(list, 2, nil)    -- delete/hole; length permanece
```

As posições Lua são base 1 e length é lógico, não #/ipairs. Escrita nil em posição representa undefined/hole, não null explícito. O teste normaliza a distinção de descritores entre hole e undefined próprio, mas conserva o valor lido e a diferença de null. Não modificar o marcador ou burlar os metadados de array/mapa.

SkinData possui as referências nas listas e as devolve mesmo se repetidas ou compartilhadas entre skins; add não remove listas anteriores nem implementa contagem de referências. Falhas e callbacks preservam os efeitos e as entradas anteriores do original. getDisplay devolve o primeiro nome correspondente; getMesh de ArmatureData mantém o cast TS apagado e não acrescenta filtro de tipo.

A suíte skindata_differential usa modelos reais de armadura, skin, display, geometria/peso e ações/UserData. Probes só instrumentam callbacks e setters de parent em instâncias reais. Isso não implementa runtime de slots, seleção/renderização de skins, parsing, deformação ou GPU. Consumidores futuros das listas devem reconhecer explicitamente SkinData.NULL.
