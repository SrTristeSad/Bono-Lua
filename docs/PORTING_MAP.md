# Correspondência de arquivos

A tabela integral está em UPSTREAM_INVENTORY.md e é regenerável; o estado por módulo vem de PORTING_PROGRESS.json. Dependências resolvidas e fronteiras externas: DEPENDENCIES.md.

| Origem | Destino proposto | Situação |
| --- | --- | --- |
| DragonBones/src/dragonBones/geom/Point.ts | dragonbones/geom/Point.lua | Implementado, validado isoladamente nos testes diferenciais |
| DragonBones/src/dragonBones/geom/Rectangle.ts | dragonbones/geom/Rectangle.lua | Implementado, validado isoladamente nos testes diferenciais |
| DragonBones/src/dragonBones/geom/ColorTransform.ts | dragonbones/geom/ColorTransform.lua | Implementado, validado isoladamente nos testes diferenciais |
| DragonBones/src/dragonBones/geom/Matrix.ts | dragonbones/geom/Matrix.lua | Implementado, validado isoladamente nos testes diferenciais |
| DragonBones/src/dragonBones/geom/Transform.ts | dragonbones/geom/Transform.lua | Implementado, validado isoladamente nos testes diferenciais |
| DragonBones/src/dragonBones/core/BaseObject.ts | dragonbones/core/BaseObject.lua | Implementado, comparado isoladamente com o original executado |
| DragonBones/src/dragonBones/model/CanvasData.ts | dragonbones/model/CanvasData.lua | Modelo e integração com pool comparados |
| DragonBones/src/dragonBones/model/TextureAtlasData.ts (duas classes) | dragonbones/model/TextureAtlasData.lua | Dados de atlas/textura e integração com pool comparados; backend gráfico pendente |
| DragonBones/src/dragonBones/animation/WorldClock.ts | dragonbones/animation/WorldClock.lua | Algoritmo comparado; precisão do relógio automático do host pendente |
| DragonBones/src/dragonBones/animation/IAnimatable.ts | docs/contracts/IAnimatable.md | Contrato de tipos documentado e exercitado; sem classe fictícia |
| DragonBones/src/dragonBones/core/DragonBones.ts | dragonbones/core/DragonBones.lua e core/Enums.lua | Núcleo de filas e 98 valores de enums comparados; shims JS documentados |
| DragonBones/src/dragonBones/event/EventObject.ts | dragonbones/event/EventObject.lua | Objeto de evento e conversão de ações comparados com pool real |
| DragonBones/src/dragonBones/model/UserData.ts (duas classes) | dragonbones/model/UserData.lua | UserData/ActionData e reciclagem de payload comparados |
| DragonBones/src/dragonBones/event/IEventDispatcher.ts | docs/contracts/IEventDispatcher.md | Contrato documentado; listeners/backend real pendentes |
| DragonBones/src/dragonBones/model/AnimationConfig.ts | dragonbones/model/AnimationConfig.lua | Defaults, cópia, máscaras esparsas/aliases e pool comparados; consumo por Animation/AnimationState pendente |
| DragonBones/src/dragonBones/model/AnimationData.ts (três classes) | dragonbones/model/AnimationData.lua | Dados/cache/timelines comparados; parent por contrato de teste, integração ArmatureData/playback pendente |
| Demais DragonBones/src/dragonBones/**/*.ts | dragonbones/**/*.lua | Inventariado; implementação/validação pendente |
| <engine>/<version>/src/dragonBones/**/*.ts | integrations/<mesmo caminho>.lua | Ausente; contratos de plataforma pendentes |
| Interfaces TS | Contratos Lua documentados/testados junto às classes | Sem algoritmos próprios; nenhuma simulação |
| Demos, recursos e arquivos gerados | Classificados individualmente no inventário | Não contados como runtime |
| builds/*.js | Ferramentas de distribuição do upstream | Catalogadas; necessidade de correspondência Lua a auditar |

Os caminhos reservados de integrações não afirmam que APIs JavaScript existem em Lua. A separação por engine/versão evita colidir classes com nomes idênticos.

JSNumberString.lua é adaptação de representação numérica da linguagem para os dois toString originais; não é uma classe adicional de runtime upstream.

JSArray.lua e JSMap.lua em dragonbones/core/ são adaptações de representação da linguagem, extraídas de AnimationConfig/TextureAtlasData e reutilizadas em AnimationData; não contam como classes upstream adicionais. A fronteira de leitura de parent está em docs/contracts/AnimationDataParent.md, sem classe de produto substituta.
