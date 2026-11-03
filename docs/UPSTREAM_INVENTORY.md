# Inventário integral do upstream

Fonte: DragonBones/DragonBonesJS@`64b6c69ae35777c2404be68c9192e2c56906079e`. Gerado de blobs Git por `node tools/inventory.js ../DragonBonesJS`.

Todos os 1203 arquivos rastreados estão abaixo. 182 arquivos autorais TS/JS são examinados por AST, incluindo demonstrações e ferramentas. Declarações distribuídas e bundles não são novos módulos de runtime.

**Estado:** inventariado estruturalmente; implementação, validação diferencial e auditoria semântica pendentes. Dependências são candidatos por referência a identificadores: não representam grafo resolvido por type checker. Nomes duplicados podem incluir candidatos de outros backends. Referências externas e dependências dinâmicas exigem revisão manual.

| Origem | Categoria | Destino previsto | Estado |
| --- | --- | --- | --- |
| `.gitignore` | Configuração | — | Inventariado; pendente de auditoria |
| `.npmignore` | Configuração | — | Inventariado; pendente de auditoria |
| `Cocos/1.x/README.md` | Documentação | — | Inventariado; pendente de auditoria |
| `Cocos/1.x/libs/.gitkeep` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Cocos/1.x/libs/creator.d.ts` | Interface ou declaração de tipos | — | Inventariado; pendente de auditoria |
| `Cocos/1.x/out/dragonBones.d.ts` | Interface ou declaração de tipos | — | Inventariado; pendente de auditoria |
| `Cocos/1.x/out/dragonBones.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Cocos/1.x/out/dragonBones.min.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Cocos/1.x/package.json` | Configuração | — | Inventariado; pendente de auditoria |
| `Cocos/1.x/src/dragonBones/cocos/CocosArmatureComponent.ts` | Integração com motor gráfico | integrations/Cocos/1.x/src/dragonBones/cocos/CocosArmatureComponent.lua | Inventariado; pendente de auditoria |
| `Cocos/1.x/src/dragonBones/cocos/CocosAsset.ts` | Integração com motor gráfico | integrations/Cocos/1.x/src/dragonBones/cocos/CocosAsset.lua | Inventariado; pendente de auditoria |
| `Cocos/1.x/src/dragonBones/cocos/CocosFactory.ts` | Integração com motor gráfico | integrations/Cocos/1.x/src/dragonBones/cocos/CocosFactory.lua | Inventariado; pendente de auditoria |
| `Cocos/1.x/src/dragonBones/cocos/CocosSlot.ts` | Integração com motor gráfico | integrations/Cocos/1.x/src/dragonBones/cocos/CocosSlot.lua | Inventariado; pendente de auditoria |
| `Cocos/1.x/src/dragonBones/cocos/CocosTextureAtlasData.ts` | Integração com motor gráfico | integrations/Cocos/1.x/src/dragonBones/cocos/CocosTextureAtlasData.lua | Inventariado; pendente de auditoria |
| `Cocos/1.x/tsconfig.json` | Configuração | — | Inventariado; pendente de auditoria |
| `Cocos/1.x/tslint.json` | Configuração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/.gitignore` | Demonstração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/README.md` | Documentação | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/Scene.meta` | Configuração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/Scene/01.HelloDragonBones.fire` | Configuração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/Scene/01.HelloDragonBones.fire.meta` | Configuração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/Scene/02.AnimationBase.fire` | Configuração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/Scene/02.AnimationBase.fire.meta` | Configuração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/Scene/03.DragonBonesEvent.fire` | Configuração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/Scene/03.DragonBonesEvent.fire.meta` | Configuração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/Scene/04.AnimationLayer.fire` | Configuração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/Scene/04.AnimationLayer.fire.meta` | Configuração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/Scene/05.BoneOffset.fire` | Configuração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/Scene/05.BoneOffset.fire.meta` | Configuração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/Scene/06.InverseKinematics.fire` | Configuração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/Scene/06.InverseKinematics.fire.meta` | Configuração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/Scene/07.BoundingBox.fire` | Configuração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/Scene/07.BoundingBox.fire.meta` | Configuração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/Scene/08.MultiTextureAltas.fire` | Configuração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/Scene/08.MultiTextureAltas.fire.meta` | Configuração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/Scene/09.ReplaceSlotDisplay.fire` | Configuração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/Scene/09.ReplaceSlotDisplay.fire.meta` | Configuração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/Scene/10.ReplaceSkin.fire` | Configuração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/Scene/10.ReplaceSkin.fire.meta` | Configuração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/Scene/11.ReplaceAnimation.fire` | Configuração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/Scene/11.ReplaceAnimation.fire.meta` | Configuração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/Scene/12.CoreElement.fire` | Configuração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/Scene/12.CoreElement.fire.meta` | Configuração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/Scene/13.EyeTracking.fire` | Configuração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/Scene/13.EyeTracking.fire.meta` | Configuração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/Scene/14.PerformanceTest.fire` | Configuração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/Scene/14.PerformanceTest.fire.meta` | Configuração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/Scene/Test.fire` | Configuração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/Scene/Test.fire.meta` | Configuração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/Script.meta` | Configuração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/Script/AnimationBase.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/Script/AnimationBase.ts.meta` | Configuração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/Script/AnimationLayer.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/Script/AnimationLayer.ts.meta` | Configuração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/Script/BoneOffset.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/Script/BoneOffset.ts.meta` | Configuração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/Script/BoundingBox.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/Script/BoundingBox.ts.meta` | Configuração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/Script/CoreElement.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/Script/CoreElement.ts.meta` | Configuração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/Script/DragHelper.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/Script/DragHelper.ts.meta` | Configuração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/Script/DragonBonesEvent.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/Script/DragonBonesEvent.ts.meta` | Configuração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/Script/EyeTracking.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/Script/EyeTracking.ts.meta` | Configuração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/Script/HelloDragonBones.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/Script/HelloDragonBones.ts.meta` | Configuração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/Script/InverseKinematics.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/Script/InverseKinematics.ts.meta` | Configuração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/Script/MultiTextureAltas.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/Script/MultiTextureAltas.ts.meta` | Configuração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/Script/PerformanceTest.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/Script/PerformanceTest.ts.meta` | Configuração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/Script/ReplaceAnimation.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/Script/ReplaceAnimation.ts.meta` | Configuração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/Script/ReplaceSkin.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/Script/ReplaceSkin.ts.meta` | Configuração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/Script/ReplaceSlotDisplay.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/Script/ReplaceSlotDisplay.ts.meta` | Configuração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/Script/Test.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/Script/Test.ts.meta` | Configuração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources.meta` | Configuração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/background.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/background.png.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/bounding_box_tester.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/bounding_box_tester/bounding_box_tester_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/bounding_box_tester/bounding_box_tester_ske.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/bounding_box_tester/bounding_box_tester_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/bounding_box_tester/bounding_box_tester_tex.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/bounding_box_tester/bounding_box_tester_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/bounding_box_tester/bounding_box_tester_tex.png.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/bullet_01.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/bullet_01/bullet_01_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/bullet_01/bullet_01_ske.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/bullet_01/bullet_01_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/bullet_01/bullet_01_tex.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/bullet_01/bullet_01_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/bullet_01/bullet_01_tex.png.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/effect.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/effect/effect_sd_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/effect/effect_sd_tex.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/effect/effect_sd_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/effect/effect_sd_tex.png.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/effect/effect_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/effect/effect_ske.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/effect/effect_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/effect/effect_tex.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/effect/effect_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/effect/effect_tex.png.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/floor_board.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/floor_board/floor_board_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/floor_board/floor_board_ske.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/floor_board/floor_board_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/floor_board/floor_board_tex.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/floor_board/floor_board_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/floor_board/floor_board_tex.png.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/mecha_1002_101d_show.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/mecha_1002_101d_show/mecha_1002_101d_show_ske.dbbin` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/mecha_1002_101d_show/mecha_1002_101d_show_ske.dbbin.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/mecha_1002_101d_show/mecha_1002_101d_show_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/mecha_1002_101d_show/mecha_1002_101d_show_ske.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/mecha_1002_101d_show/mecha_1002_101d_show_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/mecha_1002_101d_show/mecha_1002_101d_show_tex.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/mecha_1002_101d_show/mecha_1002_101d_show_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/mecha_1002_101d_show/mecha_1002_101d_show_tex.png.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/mecha_1004d.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/mecha_1004d/mecha_1004d_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/mecha_1004d/mecha_1004d_ske.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/mecha_1004d/mecha_1004d_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/mecha_1004d/mecha_1004d_tex.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/mecha_1004d/mecha_1004d_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/mecha_1004d/mecha_1004d_tex.png.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/mecha_1004d_show.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/mecha_1004d_show/mecha_1004d_show_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/mecha_1004d_show/mecha_1004d_show_ske.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/mecha_1004d_show/mecha_1004d_show_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/mecha_1004d_show/mecha_1004d_show_tex.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/mecha_1004d_show/mecha_1004d_show_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/mecha_1004d_show/mecha_1004d_show_tex.png.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/mecha_1406.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/mecha_1406/mecha_1406_ske.dbbin` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/mecha_1406/mecha_1406_ske.dbbin.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/mecha_1406/mecha_1406_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/mecha_1406/mecha_1406_ske.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/mecha_1406/mecha_1406_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/mecha_1406/mecha_1406_tex.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/mecha_1406/mecha_1406_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/mecha_1406/mecha_1406_tex.png.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/mecha_1502b.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/mecha_1502b/mecha_1502b_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/mecha_1502b/mecha_1502b_ske.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/mecha_1502b/mecha_1502b_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/mecha_1502b/mecha_1502b_tex.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/mecha_1502b/mecha_1502b_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/mecha_1502b/mecha_1502b_tex.png.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/mecha_2903.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/mecha_2903/mecha_2903_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/mecha_2903/mecha_2903_ske.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/mecha_2903/mecha_2903_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/mecha_2903/mecha_2903_tex.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/mecha_2903/mecha_2903_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/mecha_2903/mecha_2903_tex.png.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/progress_bar.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/progress_bar/progress_bar_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/progress_bar/progress_bar_ske.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/progress_bar/progress_bar_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/progress_bar/progress_bar_tex.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/progress_bar/progress_bar_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/progress_bar/progress_bar_tex.png.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/shizuku.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/shizuku/shizuku.1024.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/shizuku/shizuku.1024/texture_00.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/shizuku/shizuku.1024/texture_00.png.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/shizuku/shizuku.1024/texture_01.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/shizuku/shizuku.1024/texture_01.png.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/shizuku/shizuku.1024/texture_02.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/shizuku/shizuku.1024/texture_02.png.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/shizuku/shizuku.1024/texture_03.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/shizuku/shizuku.1024/texture_03.png.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/shizuku/shizuku_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/shizuku/shizuku_ske.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/skin_1502b.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/skin_1502b/skin_1502b_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/skin_1502b/skin_1502b_ske.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/skin_1502b/skin_1502b_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/skin_1502b/skin_1502b_tex.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/skin_1502b/skin_1502b_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/skin_1502b/skin_1502b_tex.png.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/test.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/test/test_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/test/test_ske.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/test/test_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/test/test_tex.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/test/test_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/test/test_tex.png.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/weapon_1000.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/weapon_1000/weapon_1000_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/weapon_1000/weapon_1000_ske.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/weapon_1000/weapon_1000_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/weapon_1000/weapon_1000_tex.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/weapon_1000/weapon_1000_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/weapon_1000/weapon_1000_tex.png.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/weapon_1004_show.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/weapon_1004_show/weapon_1004_show_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/weapon_1004_show/weapon_1004_show_ske.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/weapon_1004_show/weapon_1004_show_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/weapon_1004_show/weapon_1004_show_tex.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/weapon_1004_show/weapon_1004_show_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/weapon_1004_show/weapon_1004_show_tex.png.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/body.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/body/body_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/body/body_ske.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/body/body_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/body/body_tex.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/body/body_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/body/body_tex.png.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/2010600a.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/2010600a/2010600a_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/2010600a/2010600a_ske.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/2010600a/2010600a_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/2010600a/2010600a_tex.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/2010600a/2010600a_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/2010600a/2010600a_tex.png.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/2010600a_1.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/2010600a_1/2010600a_1_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/2010600a_1/2010600a_1_ske.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/2010600a_1/2010600a_1_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/2010600a_1/2010600a_1_tex.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/2010600a_1/2010600a_1_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/2010600a_1/2010600a_1_tex.png.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/20208003.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/20208003/20208003_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/20208003/20208003_ske.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/20208003/20208003_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/20208003/20208003_tex.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/20208003/20208003_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/20208003/20208003_tex.png.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/20208003_1.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/20208003_1/20208003_1_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/20208003_1/20208003_1_ske.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/20208003_1/20208003_1_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/20208003_1/20208003_1_tex.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/20208003_1/20208003_1_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/20208003_1/20208003_1_tex.png.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/20208003_2.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/20208003_2/20208003_2_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/20208003_2/20208003_2_ske.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/20208003_2/20208003_2_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/20208003_2/20208003_2_tex.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/20208003_2/20208003_2_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/20208003_2/20208003_2_tex.png.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/20208003_3.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/20208003_3/20208003_3_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/20208003_3/20208003_3_ske.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/20208003_3/20208003_3_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/20208003_3/20208003_3_tex.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/20208003_3/20208003_3_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/20208003_3/20208003_3_tex.png.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/20405006.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/20405006/20405006_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/20405006/20405006_ske.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/20405006/20405006_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/20405006/20405006_tex.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/20405006/20405006_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/20405006/20405006_tex.png.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/20509005.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/20509005/20509005_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/20509005/20509005_ske.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/20509005/20509005_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/20509005/20509005_tex.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/20509005/20509005_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/20509005/20509005_tex.png.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/20703016.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/20703016/20703016_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/20703016/20703016_ske.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/20703016/20703016_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/20703016/20703016_tex.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/20703016/20703016_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/20703016/20703016_tex.png.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/20703016_1.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/20703016_1/20703016_1_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/20703016_1/20703016_1_ske.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/20703016_1/20703016_1_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/20703016_1/20703016_1_tex.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/20703016_1/20703016_1_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/20703016_1/20703016_1_tex.png.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/2080100c.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/2080100c/2080100c_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/2080100c/2080100c_ske.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/2080100c/2080100c_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/2080100c/2080100c_tex.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/2080100c/2080100c_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/2080100c/2080100c_tex.png.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/2080100e.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/2080100e/2080100e_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/2080100e/2080100e_ske.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/2080100e/2080100e_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/2080100e/2080100e_tex.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/2080100e/2080100e_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/2080100e/2080100e_tex.png.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/2080100e_1.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/2080100e_1/2080100e_1_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/2080100e_1/2080100e_1_ske.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/2080100e_1/2080100e_1_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/2080100e_1/2080100e_1_tex.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/2080100e_1/2080100e_1_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/2080100e_1/2080100e_1_tex.png.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/20803005.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/20803005/20803005_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/20803005/20803005_ske.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/20803005/20803005_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/20803005/20803005_tex.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/20803005/20803005_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/20803005/20803005_tex.png.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/2080500b.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/2080500b/2080500b_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/2080500b/2080500b_ske.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/2080500b/2080500b_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/2080500b/2080500b_tex.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/2080500b/2080500b_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/2080500b/2080500b_tex.png.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/2080500b_1.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/2080500b_1/2080500b_1_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/2080500b_1/2080500b_1_ske.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/2080500b_1/2080500b_1_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/2080500b_1/2080500b_1_tex.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/2080500b_1/2080500b_1_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit1/2080500b_1/2080500b_1_tex.png.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20106010.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20106010/20106010_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20106010/20106010_ske.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20106010/20106010_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20106010/20106010_tex.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20106010/20106010_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20106010/20106010_tex.png.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20106010_1.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20106010_1/20106010_1_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20106010_1/20106010_1_ske.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20106010_1/20106010_1_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20106010_1/20106010_1_tex.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20106010_1/20106010_1_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20106010_1/20106010_1_tex.png.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20208006.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20208006/20208006_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20208006/20208006_ske.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20208006/20208006_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20208006/20208006_tex.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20208006/20208006_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20208006/20208006_tex.png.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20208006_1.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20208006_1/20208006_1_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20208006_1/20208006_1_ske.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20208006_1/20208006_1_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20208006_1/20208006_1_tex.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20208006_1/20208006_1_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20208006_1/20208006_1_tex.png.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20208006_2.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20208006_2/20208006_2_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20208006_2/20208006_2_ske.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20208006_2/20208006_2_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20208006_2/20208006_2_tex.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20208006_2/20208006_2_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20208006_2/20208006_2_tex.png.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20208006_3.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20208006_3/20208006_3_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20208006_3/20208006_3_ske.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20208006_3/20208006_3_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20208006_3/20208006_3_tex.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20208006_3/20208006_3_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20208006_3/20208006_3_tex.png.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/2040600b.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/2040600b/2040600b_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/2040600b/2040600b_ske.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/2040600b/2040600b_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/2040600b/2040600b_tex.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/2040600b/2040600b_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/2040600b/2040600b_tex.png.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/2040600b_1.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/2040600b_1/2040600b_1_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/2040600b_1/2040600b_1_ske.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/2040600b_1/2040600b_1_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/2040600b_1/2040600b_1_tex.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/2040600b_1/2040600b_1_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/2040600b_1/2040600b_1_tex.png.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20509007.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20509007/20509007_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20509007/20509007_ske.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20509007/20509007_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20509007/20509007_tex.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20509007/20509007_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20509007/20509007_tex.png.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20703020.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20703020/20703020_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20703020/20703020_ske.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20703020/20703020_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20703020/20703020_tex.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20703020/20703020_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20703020/20703020_tex.png.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20703020_1.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20703020_1/20703020_1_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20703020_1/20703020_1_ske.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20703020_1/20703020_1_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20703020_1/20703020_1_tex.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20703020_1/20703020_1_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20703020_1/20703020_1_tex.png.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20801015.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20801015/20801015_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20801015/20801015_ske.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20801015/20801015_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20801015/20801015_tex.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20801015/20801015_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/20801015/20801015_tex.png.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/2080b003.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/2080b003/2080b003_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/2080b003/2080b003_ske.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/2080b003/2080b003_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/2080b003/2080b003_tex.json.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/2080b003/2080b003_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/assets/resources/you_xin/suit2/2080b003/2080b003_tex.png.meta` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/creator.d.ts` | Interface ou declaração de tipos | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/declaration/dragonBones.d.ts` | Interface ou declaração de tipos | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/jsconfig.json` | Demonstração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/packages/dragonbones/assets/dragonBones.js` | Demonstração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/packages/dragonbones/assets/dragonBones.js.meta` | Configuração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/packages/dragonbones/editor/dragonbones-asset.js` | Demonstração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/packages/dragonbones/editor/dragonbones-meta.js` | Demonstração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/packages/dragonbones/editor/polyfills.js` | Demonstração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/packages/dragonbones/main.js` | Demonstração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/packages/dragonbones/package.json` | Demonstração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/packages/dragonbones/scene.js` | Demonstração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/project.json` | Demonstração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/settings/builder.json` | Demonstração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/settings/builder.panel.json` | Demonstração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/settings/project.json` | Demonstração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/template-banner.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/template.json` | Demonstração | — | Inventariado; pendente de auditoria |
| `Cocos/Demos/tsconfig.json` | Demonstração | — | Inventariado; pendente de auditoria |
| `Cocos/README.md` | Documentação | — | Inventariado; pendente de auditoria |
| `DragonBones/README.md` | Documentação | — | Inventariado; pendente de auditoria |
| `DragonBones/package.json` | Configuração | — | Inventariado; pendente de auditoria |
| `DragonBones/src/dragonBones/animation/Animation.ts` | Código-fonte do núcleo | dragonbones/animation/Animation.lua | Inventariado; pendente de auditoria |
| `DragonBones/src/dragonBones/animation/AnimationState.ts` | Código-fonte do núcleo | dragonbones/animation/AnimationState.lua | Inventariado; pendente de auditoria |
| `DragonBones/src/dragonBones/animation/BaseTimelineState.ts` | Código-fonte do núcleo | dragonbones/animation/BaseTimelineState.lua | Inventariado; pendente de auditoria |
| `DragonBones/src/dragonBones/animation/IAnimatable.ts` | Interface ou declaração de tipos | dragonbones/animation/IAnimatable.lua | Inventariado; pendente de auditoria |
| `DragonBones/src/dragonBones/animation/TimelineState.ts` | Código-fonte do núcleo | dragonbones/animation/TimelineState.lua | Inventariado; pendente de auditoria |
| `DragonBones/src/dragonBones/animation/WorldClock.ts` | Código-fonte do núcleo | dragonbones/animation/WorldClock.lua | Inventariado; pendente de auditoria |
| `DragonBones/src/dragonBones/armature/Armature.ts` | Código-fonte do núcleo | dragonbones/armature/Armature.lua | Inventariado; pendente de auditoria |
| `DragonBones/src/dragonBones/armature/Bone.ts` | Código-fonte do núcleo | dragonbones/armature/Bone.lua | Inventariado; pendente de auditoria |
| `DragonBones/src/dragonBones/armature/Constraint.ts` | Código-fonte do núcleo | dragonbones/armature/Constraint.lua | Inventariado; pendente de auditoria |
| `DragonBones/src/dragonBones/armature/IArmatureProxy.ts` | Interface ou declaração de tipos | dragonbones/armature/IArmatureProxy.lua | Inventariado; pendente de auditoria |
| `DragonBones/src/dragonBones/armature/Slot.ts` | Código-fonte do núcleo | dragonbones/armature/Slot.lua | Inventariado; pendente de auditoria |
| `DragonBones/src/dragonBones/armature/Surface.ts` | Código-fonte do núcleo | dragonbones/armature/Surface.lua | Inventariado; pendente de auditoria |
| `DragonBones/src/dragonBones/armature/TransformObject.ts` | Código-fonte do núcleo | dragonbones/armature/TransformObject.lua | Inventariado; pendente de auditoria |
| `DragonBones/src/dragonBones/core/BaseObject.ts` | Código-fonte do núcleo | dragonbones/core/BaseObject.lua | Inventariado; pendente de auditoria |
| `DragonBones/src/dragonBones/core/DragonBones.ts` | Código-fonte do núcleo | dragonbones/core/DragonBones.lua | Inventariado; pendente de auditoria |
| `DragonBones/src/dragonBones/event/EventObject.ts` | Código-fonte do núcleo | dragonbones/event/EventObject.lua | Inventariado; pendente de auditoria |
| `DragonBones/src/dragonBones/event/IEventDispatcher.ts` | Interface ou declaração de tipos | dragonbones/event/IEventDispatcher.lua | Inventariado; pendente de auditoria |
| `DragonBones/src/dragonBones/factory/BaseFactory.ts` | Código-fonte do núcleo | dragonbones/factory/BaseFactory.lua | Inventariado; pendente de auditoria |
| `DragonBones/src/dragonBones/geom/ColorTransform.ts` | Código-fonte do núcleo | dragonbones/geom/ColorTransform.lua | Inventariado; pendente de auditoria |
| `DragonBones/src/dragonBones/geom/Matrix.ts` | Código-fonte do núcleo | dragonbones/geom/Matrix.lua | Inventariado; pendente de auditoria |
| `DragonBones/src/dragonBones/geom/Point.ts` | Código-fonte do núcleo | dragonbones/geom/Point.lua | Inventariado; pendente de auditoria |
| `DragonBones/src/dragonBones/geom/Rectangle.ts` | Código-fonte do núcleo | dragonbones/geom/Rectangle.lua | Inventariado; pendente de auditoria |
| `DragonBones/src/dragonBones/geom/Transform.ts` | Código-fonte do núcleo | dragonbones/geom/Transform.lua | Inventariado; pendente de auditoria |
| `DragonBones/src/dragonBones/model/AnimationConfig.ts` | Código-fonte do núcleo | dragonbones/model/AnimationConfig.lua | Inventariado; pendente de auditoria |
| `DragonBones/src/dragonBones/model/AnimationData.ts` | Código-fonte do núcleo | dragonbones/model/AnimationData.lua | Inventariado; pendente de auditoria |
| `DragonBones/src/dragonBones/model/ArmatureData.ts` | Código-fonte do núcleo | dragonbones/model/ArmatureData.lua | Inventariado; pendente de auditoria |
| `DragonBones/src/dragonBones/model/BoundingBoxData.ts` | Código-fonte do núcleo | dragonbones/model/BoundingBoxData.lua | Inventariado; pendente de auditoria |
| `DragonBones/src/dragonBones/model/CanvasData.ts` | Código-fonte do núcleo | dragonbones/model/CanvasData.lua | Inventariado; pendente de auditoria |
| `DragonBones/src/dragonBones/model/ConstraintData.ts` | Código-fonte do núcleo | dragonbones/model/ConstraintData.lua | Inventariado; pendente de auditoria |
| `DragonBones/src/dragonBones/model/DisplayData.ts` | Código-fonte do núcleo | dragonbones/model/DisplayData.lua | Inventariado; pendente de auditoria |
| `DragonBones/src/dragonBones/model/DragonBonesData.ts` | Código-fonte do núcleo | dragonbones/model/DragonBonesData.lua | Inventariado; pendente de auditoria |
| `DragonBones/src/dragonBones/model/SkinData.ts` | Código-fonte do núcleo | dragonbones/model/SkinData.lua | Inventariado; pendente de auditoria |
| `DragonBones/src/dragonBones/model/TextureAtlasData.ts` | Código-fonte do núcleo | dragonbones/model/TextureAtlasData.lua | Inventariado; pendente de auditoria |
| `DragonBones/src/dragonBones/model/UserData.ts` | Código-fonte do núcleo | dragonbones/model/UserData.lua | Inventariado; pendente de auditoria |
| `DragonBones/src/dragonBones/parser/BinaryDataParser.ts` | Código-fonte do núcleo | dragonbones/parser/BinaryDataParser.lua | Inventariado; pendente de auditoria |
| `DragonBones/src/dragonBones/parser/DataParser.ts` | Código-fonte do núcleo | dragonbones/parser/DataParser.lua | Inventariado; pendente de auditoria |
| `DragonBones/src/dragonBones/parser/ObjectDataParser.ts` | Código-fonte do núcleo | dragonbones/parser/ObjectDataParser.lua | Inventariado; pendente de auditoria |
| `DragonBones/tsconfig.json` | Configuração | — | Inventariado; pendente de auditoria |
| `DragonBones/tslint.json` | Configuração | — | Inventariado; pendente de auditoria |
| `Egret/4.x/README.md` | Documentação | — | Inventariado; pendente de auditoria |
| `Egret/4.x/libs/.gitkeep` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Egret/4.x/out/dragonBones.d.ts` | Interface ou declaração de tipos | — | Inventariado; pendente de auditoria |
| `Egret/4.x/out/dragonBones.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Egret/4.x/out/dragonBones.min.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Egret/4.x/package.json` | Configuração | — | Inventariado; pendente de auditoria |
| `Egret/4.x/scripts/modify.js` | Configuração | — | Inventariado; pendente de auditoria |
| `Egret/4.x/src/dragonBones/egret/EgretArmatureDisplay.ts` | Integração com motor gráfico | integrations/Egret/4.x/src/dragonBones/egret/EgretArmatureDisplay.lua | Inventariado; pendente de auditoria |
| `Egret/4.x/src/dragonBones/egret/EgretFactory.ts` | Integração com motor gráfico | integrations/Egret/4.x/src/dragonBones/egret/EgretFactory.lua | Inventariado; pendente de auditoria |
| `Egret/4.x/src/dragonBones/egret/EgretSlot.ts` | Integração com motor gráfico | integrations/Egret/4.x/src/dragonBones/egret/EgretSlot.lua | Inventariado; pendente de auditoria |
| `Egret/4.x/src/dragonBones/egret/EgretTextureAtlasData.ts` | Integração com motor gráfico | integrations/Egret/4.x/src/dragonBones/egret/EgretTextureAtlasData.lua | Inventariado; pendente de auditoria |
| `Egret/4.x/tsconfig.json` | Configuração | — | Inventariado; pendente de auditoria |
| `Egret/4.x/tslint.json` | Configuração | — | Inventariado; pendente de auditoria |
| `Egret/Demos/.wing/launch.json` | Demonstração | — | Inventariado; pendente de auditoria |
| `Egret/Demos/.wing/settings.json` | Demonstração | — | Inventariado; pendente de auditoria |
| `Egret/Demos/.wing/tasks.json` | Demonstração | — | Inventariado; pendente de auditoria |
| `Egret/Demos/README.md` | Documentação | — | Inventariado; pendente de auditoria |
| `Egret/Demos/egretProperties.json` | Demonstração | — | Inventariado; pendente de auditoria |
| `Egret/Demos/index.html` | Demonstração | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/background.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/bounding_box_tester/bounding_box_tester_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/bounding_box_tester/bounding_box_tester_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/bounding_box_tester/bounding_box_tester_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/bullet_01/bullet_01_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/bullet_01/bullet_01_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/bullet_01/bullet_01_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/effect/Dragon_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/effect/Dragon_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/effect/Dragon_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/effect/effect_sd_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/effect/effect_sd_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/effect/effect_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/effect/effect_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/effect/effect_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/floor_board/floor_board_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/floor_board/floor_board_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/floor_board/floor_board_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/mecha_1002_101d_show/mecha_1002_101d_show_ske.dbbin` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/mecha_1002_101d_show/mecha_1002_101d_show_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/mecha_1002_101d_show/mecha_1002_101d_show_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/mecha_1002_101d_show/mecha_1002_101d_show_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/mecha_1004d/mecha_1004d_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/mecha_1004d/mecha_1004d_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/mecha_1004d/mecha_1004d_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/mecha_1004d_show/mecha_1004d_show_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/mecha_1004d_show/mecha_1004d_show_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/mecha_1004d_show/mecha_1004d_show_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/mecha_1406/mecha_1406_ske.dbbin` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/mecha_1406/mecha_1406_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/mecha_1406/mecha_1406_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/mecha_1406/mecha_1406_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/mecha_1502b/mecha_1502b_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/mecha_1502b/mecha_1502b_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/mecha_1502b/mecha_1502b_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/mecha_2903/mecha_2903_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/mecha_2903/mecha_2903_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/mecha_2903/mecha_2903_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/progress_bar/progress_bar_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/progress_bar/progress_bar_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/progress_bar/progress_bar_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/shizuku/shizuku.1024/texture_00.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/shizuku/shizuku.1024/texture_01.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/shizuku/shizuku.1024/texture_02.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/shizuku/shizuku.1024/texture_03.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/shizuku/shizuku_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/skin_1502b/skin_1502b_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/skin_1502b/skin_1502b_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/skin_1502b/skin_1502b_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/weapon_1000/weapon_1000_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/weapon_1000/weapon_1000_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/weapon_1000/weapon_1000_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/weapon_1004_show/weapon_1004_show_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/weapon_1004_show/weapon_1004_show_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/weapon_1004_show/weapon_1004_show_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/you_xin/body/body_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/you_xin/body/body_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/you_xin/body/body_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/you_xin/suit1/2010600a_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/you_xin/suit1/2010600a_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/you_xin/suit1/2010600a_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/you_xin/suit1/20208003_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/you_xin/suit1/20208003_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/you_xin/suit1/20208003_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/you_xin/suit1/20509005_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/you_xin/suit1/20509005_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/you_xin/suit1/20509005_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/you_xin/suit1/20703016_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/you_xin/suit1/20703016_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/you_xin/suit1/20703016_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/you_xin/suit1/2080100e_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/you_xin/suit1/2080100e_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/you_xin/suit1/2080100e_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/you_xin/suit1/2080500b_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/you_xin/suit1/2080500b_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/you_xin/suit1/2080500b_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/you_xin/suit2/20106010_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/you_xin/suit2/20106010_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/you_xin/suit2/20106010_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/you_xin/suit2/20208006_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/you_xin/suit2/20208006_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/you_xin/suit2/20208006_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/you_xin/suit2/20509007_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/you_xin/suit2/20509007_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/you_xin/suit2/20509007_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/you_xin/suit2/20703020_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/you_xin/suit2/20703020_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/you_xin/suit2/20703020_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/you_xin/suit2/20801015_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/you_xin/suit2/20801015_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/you_xin/suit2/20801015_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/you_xin/suit2/2080b003_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/you_xin/suit2/2080b003_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/resource/you_xin/suit2/2080b003_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Egret/Demos/src/BaseDemo.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Egret/Demos/src/DragHelper.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Egret/Demos/src/Main.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Egret/Demos/src/demo/AnimationBase.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Egret/Demos/src/demo/AnimationLayer.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Egret/Demos/src/demo/BoneOffset.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Egret/Demos/src/demo/BoundingBox.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Egret/Demos/src/demo/CoreElement.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Egret/Demos/src/demo/DragonBonesEvent.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Egret/Demos/src/demo/EyeTracking.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Egret/Demos/src/demo/HelloDragonBones.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Egret/Demos/src/demo/InverseKinematics.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Egret/Demos/src/demo/MultiTextureAltas.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Egret/Demos/src/demo/PerformanceTest.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Egret/Demos/src/demo/ReplaceAnimation.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Egret/Demos/src/demo/ReplaceSkin.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Egret/Demos/src/demo/ReplaceSlotDisplay.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Egret/Demos/template/runtime/native_loader.js` | Demonstração | — | Inventariado; pendente de auditoria |
| `Egret/Demos/template/runtime/native_require.js` | Demonstração | — | Inventariado; pendente de auditoria |
| `Egret/Demos/template/runtime/runtime_loader.js` | Demonstração | — | Inventariado; pendente de auditoria |
| `Egret/Demos/template/web/index.html` | Demonstração | — | Inventariado; pendente de auditoria |
| `Egret/Demos/tsconfig.json` | Demonstração | — | Inventariado; pendente de auditoria |
| `Egret/Demos/wingProperties.json` | Demonstração | — | Inventariado; pendente de auditoria |
| `Egret/README.md` | Documentação | — | Inventariado; pendente de auditoria |
| `Hilo/1.x/README.md` | Documentação | — | Inventariado; pendente de auditoria |
| `Hilo/1.x/libs/.gitkeep` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Hilo/1.x/out/dragonBones.d.ts` | Interface ou declaração de tipos | — | Inventariado; pendente de auditoria |
| `Hilo/1.x/out/dragonBones.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Hilo/1.x/out/dragonBones.min.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Hilo/1.x/package.json` | Configuração | — | Inventariado; pendente de auditoria |
| `Hilo/1.x/src/dragonBones/hilo/HiloArmatureDisplay.ts` | Integração com motor gráfico | integrations/Hilo/1.x/src/dragonBones/hilo/HiloArmatureDisplay.lua | Inventariado; pendente de auditoria |
| `Hilo/1.x/src/dragonBones/hilo/HiloFactory.ts` | Integração com motor gráfico | integrations/Hilo/1.x/src/dragonBones/hilo/HiloFactory.lua | Inventariado; pendente de auditoria |
| `Hilo/1.x/src/dragonBones/hilo/HiloSlot.ts` | Integração com motor gráfico | integrations/Hilo/1.x/src/dragonBones/hilo/HiloSlot.lua | Inventariado; pendente de auditoria |
| `Hilo/1.x/src/dragonBones/hilo/HiloTextureAtlasData.ts` | Integração com motor gráfico | integrations/Hilo/1.x/src/dragonBones/hilo/HiloTextureAtlasData.lua | Inventariado; pendente de auditoria |
| `Hilo/1.x/tsconfig.json` | Configuração | — | Inventariado; pendente de auditoria |
| `Hilo/1.x/tslint.json` | Configuração | — | Inventariado; pendente de auditoria |
| `Hilo/Demos/README.md` | Documentação | — | Inventariado; pendente de auditoria |
| `Hilo/Demos/index.html` | Demonstração | — | Inventariado; pendente de auditoria |
| `Hilo/Demos/libs/dragonBones/.gitkeep` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Hilo/Demos/libs/hilo/.gitkeep` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Hilo/Demos/out/AnimationBaseTest.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Hilo/Demos/out/BaseTest.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Hilo/Demos/out/CoreElement.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Hilo/Demos/out/HelloDragonBones.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Hilo/Demos/out/PerformanceTest.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Hilo/Demos/out/ReplaceAnimation.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Hilo/Demos/out/ReplaceSlotDisplay.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Hilo/Demos/out/SetBoneOffset.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Hilo/Demos/package.json` | Demonstração | — | Inventariado; pendente de auditoria |
| `Hilo/Demos/resource/assets/animation_base_test_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Hilo/Demos/resource/assets/animation_base_test_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Hilo/Demos/resource/assets/animation_base_test_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Hilo/Demos/resource/assets/core_element/mecha_1502b_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Hilo/Demos/resource/assets/core_element/mecha_1502b_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Hilo/Demos/resource/assets/core_element/mecha_1502b_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Hilo/Demos/resource/assets/core_element/mecha_2903_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Hilo/Demos/resource/assets/core_element/mecha_2903_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Hilo/Demos/resource/assets/core_element/mecha_2903_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Hilo/Demos/resource/assets/core_element/skin_1502b_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Hilo/Demos/resource/assets/core_element/skin_1502b_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Hilo/Demos/resource/assets/core_element/skin_1502b_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Hilo/Demos/resource/assets/core_element/weapon_1000_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Hilo/Demos/resource/assets/core_element/weapon_1000_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Hilo/Demos/resource/assets/core_element/weapon_1000_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Hilo/Demos/resource/assets/dragon_boy_ske.dbbin` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Hilo/Demos/resource/assets/dragon_boy_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Hilo/Demos/resource/assets/dragon_boy_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Hilo/Demos/resource/assets/dragon_boy_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Hilo/Demos/resource/assets/effect_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Hilo/Demos/resource/assets/effect_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Hilo/Demos/resource/assets/effect_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Hilo/Demos/resource/assets/logo.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Hilo/Demos/resource/assets/replace_slot_display/main_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Hilo/Demos/resource/assets/replace_slot_display/main_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Hilo/Demos/resource/assets/replace_slot_display/main_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Hilo/Demos/resource/assets/replace_slot_display/replace_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Hilo/Demos/resource/assets/replace_slot_display/replace_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Hilo/Demos/resource/assets/replace_slot_display/replace_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Hilo/Demos/src/AnimationBaseTest.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Hilo/Demos/src/BaseTest.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Hilo/Demos/src/HelloDragonBones.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Hilo/Demos/src/PerformanceTest.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Hilo/Demos/src/ReplaceAnimation.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Hilo/Demos/src/ReplaceSlotDisplay.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Hilo/Demos/src/SetBoneOffset.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Hilo/Demos/tsconfig.json` | Demonstração | — | Inventariado; pendente de auditoria |
| `Hilo/Demos/tslint.json` | Demonstração | — | Inventariado; pendente de auditoria |
| `LICENSE` | Documentação | — | Inventariado; pendente de auditoria |
| `Phaser/2.x/README.md` | Documentação | — | Inventariado; pendente de auditoria |
| `Phaser/2.x/libs/.gitkeep` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Phaser/2.x/out/dragonBones.d.ts` | Interface ou declaração de tipos | — | Inventariado; pendente de auditoria |
| `Phaser/2.x/out/dragonBones.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Phaser/2.x/out/dragonBones.min.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Phaser/2.x/package.json` | Configuração | — | Inventariado; pendente de auditoria |
| `Phaser/2.x/src/dragonBones/phaser/PhaserArmatureDisplay.ts` | Integração com motor gráfico | integrations/Phaser/2.x/src/dragonBones/phaser/PhaserArmatureDisplay.lua | Inventariado; pendente de auditoria |
| `Phaser/2.x/src/dragonBones/phaser/PhaserFactory.ts` | Integração com motor gráfico | integrations/Phaser/2.x/src/dragonBones/phaser/PhaserFactory.lua | Inventariado; pendente de auditoria |
| `Phaser/2.x/src/dragonBones/phaser/PhaserSlot.ts` | Integração com motor gráfico | integrations/Phaser/2.x/src/dragonBones/phaser/PhaserSlot.lua | Inventariado; pendente de auditoria |
| `Phaser/2.x/src/dragonBones/phaser/PhaserSlotDisplay.ts` | Integração com motor gráfico | integrations/Phaser/2.x/src/dragonBones/phaser/PhaserSlotDisplay.lua | Inventariado; pendente de auditoria |
| `Phaser/2.x/src/dragonBones/phaser/PhaserTextureAtlasData.ts` | Integração com motor gráfico | integrations/Phaser/2.x/src/dragonBones/phaser/PhaserTextureAtlasData.lua | Inventariado; pendente de auditoria |
| `Phaser/2.x/tsconfig.json` | Configuração | — | Inventariado; pendente de auditoria |
| `Phaser/2.x/tslint.json` | Configuração | — | Inventariado; pendente de auditoria |
| `Phaser/3.x/README.md` | Documentação | — | Inventariado; pendente de auditoria |
| `Phaser/3.x/out/dragonBones.d.ts` | Interface ou declaração de tipos | — | Inventariado; pendente de auditoria |
| `Phaser/3.x/out/dragonBones.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Phaser/3.x/out/dragonBones.min.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Phaser/3.x/package-lock.json` | Configuração | — | Inventariado; pendente de auditoria |
| `Phaser/3.x/package.json` | Configuração | — | Inventariado; pendente de auditoria |
| `Phaser/3.x/src/dragonBones/phaser/Factory.ts` | Integração com motor gráfico | integrations/Phaser/3.x/src/dragonBones/phaser/Factory.lua | Inventariado; pendente de auditoria |
| `Phaser/3.x/src/dragonBones/phaser/display/ArmatureDisplay.ts` | Integração com motor gráfico | integrations/Phaser/3.x/src/dragonBones/phaser/display/ArmatureDisplay.lua | Inventariado; pendente de auditoria |
| `Phaser/3.x/src/dragonBones/phaser/display/DisplayContainer.ts` | Integração com motor gráfico | integrations/Phaser/3.x/src/dragonBones/phaser/display/DisplayContainer.lua | Inventariado; pendente de auditoria |
| `Phaser/3.x/src/dragonBones/phaser/display/Slot.ts` | Integração com motor gráfico | integrations/Phaser/3.x/src/dragonBones/phaser/display/Slot.lua | Inventariado; pendente de auditoria |
| `Phaser/3.x/src/dragonBones/phaser/display/SlotImage.ts` | Integração com motor gráfico | integrations/Phaser/3.x/src/dragonBones/phaser/display/SlotImage.lua | Inventariado; pendente de auditoria |
| `Phaser/3.x/src/dragonBones/phaser/display/SlotMesh.ts` | Integração com motor gráfico | integrations/Phaser/3.x/src/dragonBones/phaser/display/SlotMesh.lua | Inventariado; pendente de auditoria |
| `Phaser/3.x/src/dragonBones/phaser/display/SlotSprite.ts` | Integração com motor gráfico | integrations/Phaser/3.x/src/dragonBones/phaser/display/SlotSprite.lua | Inventariado; pendente de auditoria |
| `Phaser/3.x/src/dragonBones/phaser/display/TextureAtlasData.ts` | Integração com motor gráfico | integrations/Phaser/3.x/src/dragonBones/phaser/display/TextureAtlasData.lua | Inventariado; pendente de auditoria |
| `Phaser/3.x/src/dragonBones/phaser/pipeline/TextureTintPipeline.ts` | Integração com motor gráfico | integrations/Phaser/3.x/src/dragonBones/phaser/pipeline/TextureTintPipeline.lua | Inventariado; pendente de auditoria |
| `Phaser/3.x/src/dragonBones/phaser/plugin/DragonBonesFile.ts` | Integração com motor gráfico | integrations/Phaser/3.x/src/dragonBones/phaser/plugin/DragonBonesFile.lua | Inventariado; pendente de auditoria |
| `Phaser/3.x/src/dragonBones/phaser/plugin/DragonBonesPlugin.ts` | Integração com motor gráfico | integrations/Phaser/3.x/src/dragonBones/phaser/plugin/DragonBonesPlugin.lua | Inventariado; pendente de auditoria |
| `Phaser/3.x/src/dragonBones/phaser/plugin/FileTypes.ts` | Interface ou declaração de tipos | — | Inventariado; pendente de auditoria |
| `Phaser/3.x/src/dragonBones/phaser/util/EventDispatcher.ts` | Integração com motor gráfico | integrations/Phaser/3.x/src/dragonBones/phaser/util/EventDispatcher.lua | Inventariado; pendente de auditoria |
| `Phaser/3.x/src/dragonBones/phaser/util/SkewComponent.ts` | Integração com motor gráfico | integrations/Phaser/3.x/src/dragonBones/phaser/util/SkewComponent.lua | Inventariado; pendente de auditoria |
| `Phaser/3.x/src/dragonBones/phaser/util/TransformMatrix.ts` | Integração com motor gráfico | integrations/Phaser/3.x/src/dragonBones/phaser/util/TransformMatrix.lua | Inventariado; pendente de auditoria |
| `Phaser/3.x/tsconfig.json` | Configuração | — | Inventariado; pendente de auditoria |
| `Phaser/3.x/tslint.json` | Configuração | — | Inventariado; pendente de auditoria |
| `Phaser/3.x/types/phaser-plugin.d.ts` | Interface ou declaração de tipos | — | Inventariado; pendente de auditoria |
| `Phaser/3.x/types/phaser.d.ts` | Interface ou declaração de tipos | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/README.md` | Documentação | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/index.html` | Demonstração | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/libs/dragonBones/.gitkeep` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/libs/dragonBones/dragonBones.d.ts` | Interface ou declaração de tipos | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/libs/dragonBones/dragonBones.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/libs/dragonBones/dragonBones.min.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/libs/dragonBones/phaser-plugin.d.ts` | Interface ou declaração de tipos | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/libs/phaser/.gitkeep` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/libs/phaser/phaser.d.ts` | Interface ou declaração de tipos | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/libs/phaser/phaser.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/out/AnimationBase.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/out/AnimationLayer.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/out/BaseDemo.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/out/BoneOffset.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/out/BoundingBox.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/out/CoreElement.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/out/DragHelper.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/out/DragonBonesEvent.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/out/HelloDragonBones.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/out/InverseKinematics.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/out/PerformanceTest.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/out/ReplaceAnimation.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/out/ReplaceSlotDisplay.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/package.json` | Demonstração | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/background.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/bounding_box_tester/bounding_box_tester_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/bounding_box_tester/bounding_box_tester_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/bounding_box_tester/bounding_box_tester_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/bullet_01/bullet_01_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/bullet_01/bullet_01_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/bullet_01/bullet_01_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/floor_board/floor_board_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/floor_board/floor_board_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/floor_board/floor_board_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/mecha_1002_101d_show/mecha_1002_101d_show_ske.dbbin` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/mecha_1002_101d_show/mecha_1002_101d_show_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/mecha_1002_101d_show/mecha_1002_101d_show_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/mecha_1002_101d_show/mecha_1002_101d_show_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/mecha_1004d/mecha_1004d_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/mecha_1004d/mecha_1004d_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/mecha_1004d/mecha_1004d_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/mecha_1004d_show/mecha_1004d_show_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/mecha_1004d_show/mecha_1004d_show_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/mecha_1004d_show/mecha_1004d_show_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/mecha_1406/mecha_1406_ske.dbbin` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/mecha_1406/mecha_1406_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/mecha_1406/mecha_1406_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/mecha_1406/mecha_1406_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/mecha_1502b/mecha_1502b_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/mecha_1502b/mecha_1502b_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/mecha_1502b/mecha_1502b_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/mecha_2903/mecha_2903_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/mecha_2903/mecha_2903_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/mecha_2903/mecha_2903_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/progress_bar/progress_bar_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/progress_bar/progress_bar_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/progress_bar/progress_bar_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/skin_1502b/skin_1502b_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/skin_1502b/skin_1502b_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/skin_1502b/skin_1502b_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/weapon_1000/weapon_1000_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/weapon_1000/weapon_1000_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/weapon_1000/weapon_1000_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/weapon_1004_show/weapon_1004_show_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/weapon_1004_show/weapon_1004_show_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/weapon_1004_show/weapon_1004_show_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/body/body_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/body/body_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/body/body_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit1/2010600a/2010600a_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit1/2010600a/2010600a_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit1/2010600a/2010600a_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit1/2010600a_1/2010600a_1_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit1/2010600a_1/2010600a_1_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit1/2010600a_1/2010600a_1_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit1/20208003/20208003_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit1/20208003/20208003_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit1/20208003/20208003_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit1/20208003_1/20208003_1_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit1/20208003_1/20208003_1_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit1/20208003_1/20208003_1_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit1/20208003_2/20208003_2_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit1/20208003_2/20208003_2_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit1/20208003_2/20208003_2_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit1/20208003_3/20208003_3_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit1/20208003_3/20208003_3_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit1/20208003_3/20208003_3_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit1/20405006/20405006_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit1/20405006/20405006_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit1/20405006/20405006_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit1/20509005/20509005_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit1/20509005/20509005_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit1/20509005/20509005_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit1/20703016/20703016_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit1/20703016/20703016_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit1/20703016/20703016_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit1/20703016_1/20703016_1_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit1/20703016_1/20703016_1_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit1/20703016_1/20703016_1_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit1/2080100c/2080100c_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit1/2080100c/2080100c_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit1/2080100c/2080100c_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit1/2080100e/2080100e_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit1/2080100e/2080100e_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit1/2080100e/2080100e_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit1/2080100e_1/2080100e_1_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit1/2080100e_1/2080100e_1_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit1/2080100e_1/2080100e_1_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit1/20803005/20803005_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit1/20803005/20803005_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit1/20803005/20803005_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit1/2080500b/2080500b_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit1/2080500b/2080500b_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit1/2080500b/2080500b_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit1/2080500b_1/2080500b_1_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit1/2080500b_1/2080500b_1_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit1/2080500b_1/2080500b_1_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit2/20106010/20106010_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit2/20106010/20106010_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit2/20106010/20106010_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit2/20106010_1/20106010_1_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit2/20106010_1/20106010_1_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit2/20106010_1/20106010_1_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit2/20208006/20208006_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit2/20208006/20208006_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit2/20208006/20208006_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit2/20208006_1/20208006_1_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit2/20208006_1/20208006_1_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit2/20208006_1/20208006_1_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit2/20208006_2/20208006_2_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit2/20208006_2/20208006_2_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit2/20208006_2/20208006_2_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit2/20208006_3/20208006_3_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit2/20208006_3/20208006_3_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit2/20208006_3/20208006_3_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit2/2040600b/2040600b_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit2/2040600b/2040600b_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit2/2040600b/2040600b_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit2/2040600b_1/2040600b_1_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit2/2040600b_1/2040600b_1_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit2/2040600b_1/2040600b_1_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit2/20509007/20509007_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit2/20509007/20509007_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit2/20509007/20509007_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit2/20703020/20703020_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit2/20703020/20703020_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit2/20703020/20703020_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit2/20703020_1/20703020_1_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit2/20703020_1/20703020_1_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit2/20703020_1/20703020_1_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit2/20801015/20801015_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit2/20801015/20801015_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit2/20801015/20801015_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit2/2080b003/2080b003_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit2/2080b003/2080b003_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/resource/you_xin/suit2/2080b003/2080b003_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/src/AnimationBase.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/src/AnimationLayer.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/src/BaseDemo.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/src/BoneOffset.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/src/BoundingBox.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/src/CoreElement.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/src/DragHelper.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/src/DragonBonesEvent.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/src/HelloDragonBones.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/src/InverseKinematics.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/src/PerformanceTest.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/src/ReplaceAnimation.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/src/ReplaceSlotDisplay.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/tsconfig.json` | Demonstração | — | Inventariado; pendente de auditoria |
| `Phaser/Demos/tslint.json` | Demonstração | — | Inventariado; pendente de auditoria |
| `Phaser/README.md` | Documentação | — | Inventariado; pendente de auditoria |
| `Pixi/4.x/README.md` | Documentação | — | Inventariado; pendente de auditoria |
| `Pixi/4.x/libs/.gitkeep` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Pixi/4.x/out/dragonBones.d.ts` | Interface ou declaração de tipos | — | Inventariado; pendente de auditoria |
| `Pixi/4.x/out/dragonBones.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Pixi/4.x/out/dragonBones.min.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Pixi/4.x/package.json` | Configuração | — | Inventariado; pendente de auditoria |
| `Pixi/4.x/src/dragonBones/pixi/PixiArmatureDisplay.ts` | Integração com motor gráfico | integrations/Pixi/4.x/src/dragonBones/pixi/PixiArmatureDisplay.lua | Inventariado; pendente de auditoria |
| `Pixi/4.x/src/dragonBones/pixi/PixiFactory.ts` | Integração com motor gráfico | integrations/Pixi/4.x/src/dragonBones/pixi/PixiFactory.lua | Inventariado; pendente de auditoria |
| `Pixi/4.x/src/dragonBones/pixi/PixiSlot.ts` | Integração com motor gráfico | integrations/Pixi/4.x/src/dragonBones/pixi/PixiSlot.lua | Inventariado; pendente de auditoria |
| `Pixi/4.x/src/dragonBones/pixi/PixiTextureAtlasData.ts` | Integração com motor gráfico | integrations/Pixi/4.x/src/dragonBones/pixi/PixiTextureAtlasData.lua | Inventariado; pendente de auditoria |
| `Pixi/4.x/tsconfig.json` | Configuração | — | Inventariado; pendente de auditoria |
| `Pixi/4.x/tslint.json` | Configuração | — | Inventariado; pendente de auditoria |
| `Pixi/5.x/README.md` | Documentação | — | Inventariado; pendente de auditoria |
| `Pixi/5.x/libs/pixi.js-legacy.d.ts` | Interface ou declaração de tipos | — | Inventariado; pendente de auditoria |
| `Pixi/5.x/out/dragonBones.d.ts` | Interface ou declaração de tipos | — | Inventariado; pendente de auditoria |
| `Pixi/5.x/out/dragonBones.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Pixi/5.x/out/dragonBones.min.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Pixi/5.x/package-lock.json` | Configuração | — | Inventariado; pendente de auditoria |
| `Pixi/5.x/package.json` | Configuração | — | Inventariado; pendente de auditoria |
| `Pixi/5.x/src/dragonBones/pixi/PixiArmatureDisplay.ts` | Integração com motor gráfico | integrations/Pixi/5.x/src/dragonBones/pixi/PixiArmatureDisplay.lua | Inventariado; pendente de auditoria |
| `Pixi/5.x/src/dragonBones/pixi/PixiFactory.ts` | Integração com motor gráfico | integrations/Pixi/5.x/src/dragonBones/pixi/PixiFactory.lua | Inventariado; pendente de auditoria |
| `Pixi/5.x/src/dragonBones/pixi/PixiSlot.ts` | Integração com motor gráfico | integrations/Pixi/5.x/src/dragonBones/pixi/PixiSlot.lua | Inventariado; pendente de auditoria |
| `Pixi/5.x/src/dragonBones/pixi/PixiTextureAtlasData.ts` | Integração com motor gráfico | integrations/Pixi/5.x/src/dragonBones/pixi/PixiTextureAtlasData.lua | Inventariado; pendente de auditoria |
| `Pixi/5.x/tsconfig.json` | Configuração | — | Inventariado; pendente de auditoria |
| `Pixi/5.x/tslint.json` | Configuração | — | Inventariado; pendente de auditoria |
| `Pixi/8.x/README.md` | Documentação | — | Inventariado; pendente de auditoria |
| `Pixi/8.x/libs/dragonBones.d.ts` | Interface ou declaração de tipos | — | Inventariado; pendente de auditoria |
| `Pixi/8.x/libs/pixi.js.d.ts` | Interface ou declaração de tipos | — | Inventariado; pendente de auditoria |
| `Pixi/8.x/out/dragonBones.d.ts` | Interface ou declaração de tipos | — | Inventariado; pendente de auditoria |
| `Pixi/8.x/out/dragonBones.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Pixi/8.x/out/dragonBones.js.map` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Pixi/8.x/out/dragonBones.min.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Pixi/8.x/package-lock.json` | Configuração | — | Inventariado; pendente de auditoria |
| `Pixi/8.x/package.json` | Configuração | — | Inventariado; pendente de auditoria |
| `Pixi/8.x/src/dragonBones/pixi/PixiArmatureDisplay.ts` | Integração com motor gráfico | integrations/Pixi/8.x/src/dragonBones/pixi/PixiArmatureDisplay.lua | Inventariado; pendente de auditoria |
| `Pixi/8.x/src/dragonBones/pixi/PixiDBBinParser.ts` | Integração com motor gráfico | integrations/Pixi/8.x/src/dragonBones/pixi/PixiDBBinParser.lua | Inventariado; pendente de auditoria |
| `Pixi/8.x/src/dragonBones/pixi/PixiFactory.ts` | Integração com motor gráfico | integrations/Pixi/8.x/src/dragonBones/pixi/PixiFactory.lua | Inventariado; pendente de auditoria |
| `Pixi/8.x/src/dragonBones/pixi/PixiSlot.ts` | Integração com motor gráfico | integrations/Pixi/8.x/src/dragonBones/pixi/PixiSlot.lua | Inventariado; pendente de auditoria |
| `Pixi/8.x/src/dragonBones/pixi/PixiTextureAtlasData.ts` | Integração com motor gráfico | integrations/Pixi/8.x/src/dragonBones/pixi/PixiTextureAtlasData.lua | Inventariado; pendente de auditoria |
| `Pixi/8.x/tsconfig.json` | Configuração | — | Inventariado; pendente de auditoria |
| `Pixi/8.x/tslint.json` | Configuração | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/4.x/README.md` | Documentação | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/4.x/index.html` | Demonstração | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/4.x/libs/dragonBones/.gitkeep` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/4.x/libs/dragonBones/dragonBones.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/4.x/libs/pixi/.gitkeep` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/4.x/libs/pixi/pixi.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/4.x/out/AnimationBase.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/4.x/out/AnimationBaseTest.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/4.x/out/AnimationCopy.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/4.x/out/AnimationLayer.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/4.x/out/BaseDemo.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/4.x/out/BaseTest.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/4.x/out/BoneOffset.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/4.x/out/BoundingBox.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/4.x/out/CoreElement.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/4.x/out/DragHelper.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/4.x/out/DragonBonesEvent.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/4.x/out/EyeTracking.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/4.x/out/HelloDragonBones.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/4.x/out/InverseKinematics.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/4.x/out/MultiTextureAltas.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/4.x/out/PerformanceTest.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/4.x/out/ReplaceAnimation.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/4.x/out/ReplaceSkin.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/4.x/out/ReplaceSlotDisplay.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/4.x/out/SetBoneOffset.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/4.x/package.json` | Demonstração | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/4.x/resource/readme.txt` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/4.x/src/AnimationBase.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/4.x/src/AnimationLayer.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/4.x/src/BaseDemo.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/4.x/src/BoneOffset.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/4.x/src/BoundingBox.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/4.x/src/CoreElement.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/4.x/src/DragHelper.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/4.x/src/DragonBonesEvent.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/4.x/src/EyeTracking.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/4.x/src/HelloDragonBones.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/4.x/src/InverseKinematics.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/4.x/src/MultiTextureAltas.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/4.x/src/PerformanceTest.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/4.x/src/ReplaceAnimation.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/4.x/src/ReplaceSkin.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/4.x/src/ReplaceSlotDisplay.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/4.x/tsconfig.json` | Demonstração | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/4.x/tslint.json` | Demonstração | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/8.x/README.md` | Documentação | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/8.x/index.html` | Demonstração | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/8.x/libs/dragonBones/dragonBones.d.ts` | Interface ou declaração de tipos | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/8.x/libs/dragonBones/dragonBones.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/8.x/libs/dragonBones/dragonBones.js.map` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/8.x/libs/pixi/8.9.2/pixi.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/8.x/libs/pixi/8.9.2/pixi.js.map` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/8.x/out/AnimationBase.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/8.x/out/AnimationLayer.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/8.x/out/BaseDemo copy.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/8.x/out/BaseDemo.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/8.x/out/BoneOffset.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/8.x/out/BoundingBox.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/8.x/out/CoreElement.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/8.x/out/DebugDragonBones.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/8.x/out/DragHelper.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/8.x/out/DragonBonesEvent.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/8.x/out/EyeTracking.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/8.x/out/HelloDragonBones copy.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/8.x/out/HelloDragonBones.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/8.x/out/InverseKinematics.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/8.x/out/MultiTextureAltas.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/8.x/out/PerformanceTest.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/8.x/out/ReplaceAnimation.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/8.x/out/ReplaceSkin.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/8.x/out/ReplaceSlotDisplay.js` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/8.x/package.json` | Demonstração | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/8.x/resource/readme.txt` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/8.x/src/AnimationBase.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/8.x/src/AnimationLayer.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/8.x/src/BaseDemo.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/8.x/src/BoneOffset.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/8.x/src/BoundingBox.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/8.x/src/CoreElement.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/8.x/src/DebugDragonBones.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/8.x/src/DragHelper.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/8.x/src/DragonBonesEvent.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/8.x/src/EyeTracking.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/8.x/src/HelloDragonBones.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/8.x/src/InverseKinematics.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/8.x/src/MultiTextureAltas.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/8.x/src/PerformanceTest.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/8.x/src/ReplaceAnimation.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/8.x/src/ReplaceSkin.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/8.x/src/ReplaceSlotDisplay.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/8.x/tsconfig.json` | Demonstração | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/8.x/tslint.json` | Demonstração | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/background.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/bounding_box_tester/bounding_box_tester_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/bounding_box_tester/bounding_box_tester_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/bounding_box_tester/bounding_box_tester_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/bullet_01/bullet_01_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/bullet_01/bullet_01_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/bullet_01/bullet_01_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/effect/effect_sd_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/effect/effect_sd_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/effect/effect_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/effect/effect_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/effect/effect_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/floor_board/floor_board_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/floor_board/floor_board_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/floor_board/floor_board_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/mecha_1002_101d_show/mecha_1002_101d_show_ske.dbbin` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/mecha_1002_101d_show/mecha_1002_101d_show_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/mecha_1002_101d_show/mecha_1002_101d_show_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/mecha_1002_101d_show/mecha_1002_101d_show_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/mecha_1004d/mecha_1004d_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/mecha_1004d/mecha_1004d_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/mecha_1004d/mecha_1004d_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/mecha_1004d_show/mecha_1004d_show_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/mecha_1004d_show/mecha_1004d_show_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/mecha_1004d_show/mecha_1004d_show_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/mecha_1406/mecha_1406_ske.dbbin` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/mecha_1406/mecha_1406_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/mecha_1406/mecha_1406_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/mecha_1406/mecha_1406_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/mecha_1502b/mecha_1502b_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/mecha_1502b/mecha_1502b_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/mecha_1502b/mecha_1502b_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/mecha_2903/mecha_2903_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/mecha_2903/mecha_2903_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/mecha_2903/mecha_2903_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/progress_bar/progress_bar_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/progress_bar/progress_bar_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/progress_bar/progress_bar_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/shizuku/shizuku.1024/texture_00.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/shizuku/shizuku.1024/texture_01.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/shizuku/shizuku.1024/texture_02.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/shizuku/shizuku.1024/texture_03.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/shizuku/shizuku_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/skin_1502b/skin_1502b_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/skin_1502b/skin_1502b_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/skin_1502b/skin_1502b_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/weapon_1000/weapon_1000_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/weapon_1000/weapon_1000_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/weapon_1000/weapon_1000_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/weapon_1004_show/weapon_1004_show_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/weapon_1004_show/weapon_1004_show_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/weapon_1004_show/weapon_1004_show_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/body/body_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/body/body_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/body/body_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit1/2010600a/2010600a_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit1/2010600a/2010600a_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit1/2010600a/2010600a_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit1/2010600a_1/2010600a_1_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit1/2010600a_1/2010600a_1_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit1/2010600a_1/2010600a_1_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit1/20208003/20208003_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit1/20208003/20208003_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit1/20208003/20208003_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit1/20208003_1/20208003_1_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit1/20208003_1/20208003_1_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit1/20208003_1/20208003_1_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit1/20208003_2/20208003_2_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit1/20208003_2/20208003_2_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit1/20208003_2/20208003_2_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit1/20208003_3/20208003_3_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit1/20208003_3/20208003_3_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit1/20208003_3/20208003_3_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit1/20405006/20405006_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit1/20405006/20405006_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit1/20405006/20405006_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit1/20509005/20509005_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit1/20509005/20509005_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit1/20509005/20509005_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit1/20703016/20703016_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit1/20703016/20703016_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit1/20703016/20703016_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit1/20703016_1/20703016_1_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit1/20703016_1/20703016_1_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit1/20703016_1/20703016_1_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit1/2080100c/2080100c_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit1/2080100c/2080100c_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit1/2080100c/2080100c_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit1/2080100e/2080100e_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit1/2080100e/2080100e_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit1/2080100e/2080100e_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit1/2080100e_1/2080100e_1_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit1/2080100e_1/2080100e_1_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit1/2080100e_1/2080100e_1_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit1/20803005/20803005_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit1/20803005/20803005_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit1/20803005/20803005_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit1/2080500b/2080500b_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit1/2080500b/2080500b_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit1/2080500b/2080500b_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit1/2080500b_1/2080500b_1_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit1/2080500b_1/2080500b_1_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit1/2080500b_1/2080500b_1_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit2/20106010/20106010_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit2/20106010/20106010_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit2/20106010/20106010_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit2/20106010_1/20106010_1_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit2/20106010_1/20106010_1_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit2/20106010_1/20106010_1_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit2/20208006/20208006_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit2/20208006/20208006_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit2/20208006/20208006_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit2/20208006_1/20208006_1_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit2/20208006_1/20208006_1_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit2/20208006_1/20208006_1_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit2/20208006_2/20208006_2_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit2/20208006_2/20208006_2_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit2/20208006_2/20208006_2_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit2/20208006_3/20208006_3_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit2/20208006_3/20208006_3_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit2/20208006_3/20208006_3_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit2/2040600b/2040600b_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit2/2040600b/2040600b_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit2/2040600b/2040600b_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit2/2040600b_1/2040600b_1_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit2/2040600b_1/2040600b_1_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit2/2040600b_1/2040600b_1_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit2/20509007/20509007_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit2/20509007/20509007_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit2/20509007/20509007_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit2/20703020/20703020_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit2/20703020/20703020_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit2/20703020/20703020_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit2/20703020_1/20703020_1_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit2/20703020_1/20703020_1_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit2/20703020_1/20703020_1_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit2/20801015/20801015_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit2/20801015/20801015_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit2/20801015/20801015_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit2/2080b003/2080b003_ske.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit2/2080b003/2080b003_tex.json` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/Demos/resource/you_xin/suit2/2080b003/2080b003_tex.png` | Recurso gráfico ou dados | — | Inventariado; pendente de auditoria |
| `Pixi/README.md` | Documentação | — | Inventariado; pendente de auditoria |
| `README-zh_CN.md` | Documentação | — | Inventariado; pendente de auditoria |
| `README.md` | Documentação | — | Inventariado; pendente de auditoria |
| `ThreeJS/Current/README.md` | Documentação | — | Inventariado; pendente de auditoria |
| `ThreeJS/Current/libs/.gitkeep` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `ThreeJS/Current/package.json` | Configuração | — | Inventariado; pendente de auditoria |
| `ThreeJS/Current/src/dragonBones/three/ThreeArmatureDisplay.ts` | Integração com motor gráfico | integrations/ThreeJS/Current/src/dragonBones/three/ThreeArmatureDisplay.lua | Inventariado; pendente de auditoria |
| `ThreeJS/Current/src/dragonBones/three/ThreeFactory.ts` | Integração com motor gráfico | integrations/ThreeJS/Current/src/dragonBones/three/ThreeFactory.lua | Inventariado; pendente de auditoria |
| `ThreeJS/Current/src/dragonBones/three/ThreeSlot.ts` | Integração com motor gráfico | integrations/ThreeJS/Current/src/dragonBones/three/ThreeSlot.lua | Inventariado; pendente de auditoria |
| `ThreeJS/Current/src/dragonBones/three/ThreeTextureAtlasData.ts` | Integração com motor gráfico | integrations/ThreeJS/Current/src/dragonBones/three/ThreeTextureAtlasData.lua | Inventariado; pendente de auditoria |
| `ThreeJS/Current/tsconfig.json` | Configuração | — | Inventariado; pendente de auditoria |
| `ThreeJS/Current/tslint.json` | Configuração | — | Inventariado; pendente de auditoria |
| `ThreeJS/Demos/index.html` | Demonstração | — | Inventariado; pendente de auditoria |
| `ThreeJS/Demos/libs/dragonBones/.gitkeep` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `ThreeJS/Demos/libs/three/.gitkeep` | Arquivo gerado ou dependência distribuída | — | Inventariado; pendente de auditoria |
| `ThreeJS/Demos/package.json` | Demonstração | — | Inventariado; pendente de auditoria |
| `ThreeJS/Demos/src/BaseDemo.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `ThreeJS/Demos/src/HelloDragonBones.ts` | Demonstração | — | Inventariado; pendente de auditoria |
| `ThreeJS/Demos/tsconfig.json` | Demonstração | — | Inventariado; pendente de auditoria |
| `ThreeJS/Demos/tslint.json` | Demonstração | — | Inventariado; pendente de auditoria |
| `ThreeJS/README.md` | Documentação | — | Inventariado; pendente de auditoria |
| `builds/build_base.js` | Configuração (ferramenta de build executável) | — | Inventariado; pendente de auditoria |
| `builds/build_egret.js` | Configuração (ferramenta de build executável) | — | Inventariado; pendente de auditoria |
| `builds/build_hilo.js` | Configuração (ferramenta de build executável) | — | Inventariado; pendente de auditoria |
| `builds/build_phaser.js` | Configuração (ferramenta de build executável) | — | Inventariado; pendente de auditoria |
| `builds/build_pixi.js` | Configuração (ferramenta de build executável) | — | Inventariado; pendente de auditoria |
| `builds/cli.js` | Configuração (ferramenta de build executável) | — | Inventariado; pendente de auditoria |
| `builds/index.js` | Configuração (ferramenta de build executável) | — | Inventariado; pendente de auditoria |
| `docs/DragonBones_4.5_data_format_zh.md` | Documentação | — | Inventariado; pendente de auditoria |
| `docs/DragonBones_4.7_release_notes_zh.md` | Documentação | — | Inventariado; pendente de auditoria |
| `docs/DragonBones_5.0_data_format_zh.md` | Documentação | — | Inventariado; pendente de auditoria |
| `package.json` | Configuração | — | Inventariado; pendente de auditoria |
| `package.json.js` | Configuração | — | Inventariado; pendente de auditoria |

## Contratos por arquivo autoral

Métodos e propriedades incluem membros privados, estáticos, construtores, getters e setters declarados no arquivo; membros herdados são vinculados por `extends`/`implements`. Enumerações são listadas separadamente de classes. Assinaturas contêm inicializadores de campos e números de linha. Nenhuma presença no inventário comprova equivalência.

### `Cocos/1.x/src/dragonBones/cocos/CocosArmatureComponent.ts`

- Origem/commit: `Cocos/1.x/src/dragonBones/cocos/CocosArmatureComponent.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: integrations/Cocos/1.x/src/dragonBones/cocos/CocosArmatureComponent.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/1.x/src/dragonBones/cocos/CocosAsset.ts`, `DragonBones/src/dragonBones/animation/Animation.ts`, `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/armature/IArmatureProxy.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/event/EventObject.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `CocosArmatureComponent`

Herança: extends cc.Component; implements IArmatureProxy.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `dbInit` | método | `public dbInit(armature: Armature): void` | 66 |
| `dbClear` | método | `public dbClear(): void` | 70 |
| `dbUpdate` | método | `public dbUpdate(): void` | 76 |
| `dispose` | método | `public dispose(_isposeProxy: boolean = true): void` | 83 |
| `destroy` | método | `public destroy(): true` | 90 |
| `dispatchDBEvent` | método | `public dispatchDBEvent(type: EventStringType, eventObject: EventObject): void` | 103 |
| `hasDBEventListener` | método | `public hasDBEventListener(type: EventStringType): boolean` | 109 |
| `addDBEventListener` | método | `public addDBEventListener(type: EventStringType, listener: (event: cc.Event.EventCustom) => void, target: any): void` | 113 |
| `removeDBEventListener` | método | `public removeDBEventListener(type: EventStringType, listener: (event: cc.Event.EventCustom) => void, target: any): void` | 117 |
| `armature` | método | `public get armature(): Armature` | 121 |
| `animation` | método | `public get animation(): Animation` | 125 |
| `start` | método | `start()` | 199 |
| `debugDraw` | propriedade | `public debugDraw: boolean = false;` | 59 |
| `_debugDraw` | propriedade | `private _debugDraw: boolean = false;` | 60 |
| `_armature` | propriedade | `public _armature: Armature = null as any;` | 64 |
| `_armatureName` | propriedade | `@property public _armatureName: string = "";` | 132 |
| `_animationName` | propriedade | `@property public _animationName: string = "";` | 137 |
| `_dragonBonesAsset` | propriedade | `@property({ type: DragonBonesAsset, displayName: "DragonBones", tooltip: "DragonBones Asset", visible: true, }) public _dragonBonesAsset: DragonBonesAsset \| null = null;` | 143 |
| `_armatureNames` | propriedade | `@property({ type: [cc.String], displayName: "Armature", tooltip: "The armature name.", visible: true, editorOnly: true, serializable: false, }) public readonly _armatureNames: Array<string> = [];` | 153 |
| `_animationNames` | propriedade | `@property({ type: [cc.String], displayName: "Animation", tooltip: "The animation name.", visible: true, editorOnly: true, serializable: false, }) public readonly _animationNames: Array<string> = [];` | 165 |
| `_playTimes` | propriedade | `@property({ type: cc.Integer, displayName: "Play times", tooltip: "The animation play times.", visible: true, slide: true, range: [-1, 99, 1], }) public _playTimes: number = -1;` | 177 |
| `_timeScale` | propriedade | `@property({ type: cc.Float, displayName: "TimeScale", tooltip: "The animation play speed.", visible: true, slide: true, range: [-2, 2, 0.01], }) public _timeScale: number = 1.0;` | 189 |

### `Cocos/1.x/src/dragonBones/cocos/CocosAsset.ts`

- Origem/commit: `Cocos/1.x/src/dragonBones/cocos/CocosAsset.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: integrations/Cocos/1.x/src/dragonBones/cocos/CocosAsset.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: nenhuma declaração autoral identificada.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `DragonBonesAsset`

Herança: extends cc.Asset.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `dragonBonesData` | propriedade | `@property public readonly dragonBonesData: string \| ArrayBuffer = "";` | 34 |
| `textureAtlases` | propriedade | `@property([cc.String]) public readonly textureAtlases: string[] = [];` | 36 |
| `textures` | propriedade | `@property([cc.Texture2D]) public readonly textures: cc.Texture2D[] = [];` | 38 |

### `Cocos/1.x/src/dragonBones/cocos/CocosFactory.ts`

- Origem/commit: `Cocos/1.x/src/dragonBones/cocos/CocosFactory.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: integrations/Cocos/1.x/src/dragonBones/cocos/CocosFactory.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/1.x/src/dragonBones/cocos/CocosArmatureComponent.ts`, `Cocos/1.x/src/dragonBones/cocos/CocosSlot.ts`, `Cocos/1.x/src/dragonBones/cocos/CocosTextureAtlasData.ts`, `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/armature/Slot.ts`, `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/factory/BaseFactory.ts`, `DragonBones/src/dragonBones/model/ArmatureData.ts`, `DragonBones/src/dragonBones/model/DisplayData.ts`, `DragonBones/src/dragonBones/parser/DataParser.ts`, `Phaser/3.x/src/dragonBones/phaser/display/Slot.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `ClockHandler`

Herança: extends cc.Component.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `update` | método | `update(passedTime: number)` | 30 |

#### ClassDeclaration `CocosFactory`

Herança: extends BaseFactory.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `factory` | método | `public static get factory(): CocosFactory` | 57 |
| `constructor` | método | `public constructor(dataParser: DataParser \| null = null)` | 68 |
| `_isSupportMesh` | método | `protected _isSupportMesh(): boolean` | 103 |
| `_buildTextureAtlasData` | método | `protected _buildTextureAtlasData(textureAtlasData: CocosTextureAtlasData \| null, textureAtlas: cc.Texture2D \| null): CocosTextureAtlasData` | 113 |
| `_buildArmature` | método | `protected _buildArmature(dataPackage: BuildArmaturePackage): Armature` | 124 |
| `_buildChildArmature` | método | `protected _buildChildArmature(dataPackage: BuildArmaturePackage \| null, slot: Slot, displayData: ArmatureDisplayData): Armature \| null` | 143 |
| `_buildSlot` | método | `protected _buildSlot(_dataPackage: BuildArmaturePackage, slotData: SlotData, armature: Armature): Slot` | 190 |
| `buildArmatureComponent` | método | `public buildArmatureComponent(armatureName: string, dragonBonesName: string = "", skinName: string = "", textureAtlasName: string = "", node: cc.Node \| null = null): CocosArmatureComponent \| null` | 243 |
| `getTextureDisplay` | método | `public getTextureDisplay(textureName: string, textureAtlasName: string \| null = null): cc.Sprite \| null` | 268 |
| `soundEventManager` | método | `public get soundEventManager(): cc.Node` | 292 |
| `_dragonBonesInstance` | propriedade | `private static _dragonBonesInstance: DragonBones = null as any;` | 45 |
| `_factory` | propriedade | `private static _factory: CocosFactory \| null = null;` | 46 |
| `_node` | propriedade | `protected _node: cc.Node \| null = null;` | 65 |
| `_armatureNode` | propriedade | `protected _armatureNode: cc.Node \| null = null;` | 66 |

### `Cocos/1.x/src/dragonBones/cocos/CocosSlot.ts`

- Origem/commit: `Cocos/1.x/src/dragonBones/cocos/CocosSlot.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: integrations/Cocos/1.x/src/dragonBones/cocos/CocosSlot.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/1.x/src/dragonBones/cocos/CocosTextureAtlasData.ts`, `DragonBones/src/dragonBones/armature/Bone.ts`, `DragonBones/src/dragonBones/armature/Slot.ts`, `DragonBones/src/dragonBones/armature/Surface.ts`, `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/geom/Transform.ts`, `DragonBones/src/dragonBones/model/DisplayData.ts`, `Phaser/3.x/src/dragonBones/phaser/display/Slot.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `CocosSlot`

Herança: extends Slot.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 35 |
| `_onClear` | método | `protected _onClear(): void` | 43 |
| `_initDisplay` | método | `protected _initDisplay(_value: any, _isRetain: boolean): void` | 50 |
| `_disposeDisplay` | método | `protected _disposeDisplay(value: any, isRelease: boolean): void` | 53 |
| `_onUpdateDisplay` | método | `protected _onUpdateDisplay(): void` | 59 |
| `_addDisplay` | método | `protected _addDisplay(): void` | 63 |
| `_replaceDisplay` | método | `protected _replaceDisplay(value: any): void` | 68 |
| `_removeDisplay` | método | `protected _removeDisplay(): void` | 83 |
| `_updateZOrder` | método | `protected _updateZOrder(): void` | 87 |
| `_updateVisible` | método | `public _updateVisible(): void` | 97 |
| `_updateBlendMode` | método | `protected _updateBlendMode(): void` | 101 |
| `_updateColor` | método | `protected _updateColor(): void` | 152 |
| `_updateFrame` | método | `protected _updateFrame(): void` | 162 |
| `_updateMesh` | método | `protected _updateMesh(): void` | 287 |
| `_updateTransform` | método | `protected _updateTransform(): void` | 446 |
| `_identityTransform` | método | `protected _identityTransform(): void` | 485 |
| `_ccMeshDirty` | propriedade | `private _ccMeshDirty: boolean = false;` | 39 |
| `_textureScale` | propriedade | `private _textureScale: number;` | 40 |
| `_renderDisplay` | propriedade | `private _renderDisplay: cc.Node;` | 41 |

### `Cocos/1.x/src/dragonBones/cocos/CocosTextureAtlasData.ts`

- Origem/commit: `Cocos/1.x/src/dragonBones/cocos/CocosTextureAtlasData.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: integrations/Cocos/1.x/src/dragonBones/cocos/CocosTextureAtlasData.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/model/TextureAtlasData.ts`, `Phaser/3.x/src/dragonBones/phaser/display/TextureAtlasData.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `CocosTextureAtlasData`

Herança: extends TextureAtlasData.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 35 |
| `_onClear` | método | `protected _onClear(): void` | 41 |
| `createTexture` | método | `public createTexture(): TextureData` | 51 |
| `renderTexture` | método | `public get renderTexture(): cc.Texture2D \| null` | 64 |
| `renderTexture` | método | `public set renderTexture(value: cc.Texture2D \| null)` | 67 |
| `_renderTexture` | propriedade | `private _renderTexture: cc.Texture2D \| null = null;` | 39 |

#### ClassDeclaration `CocosTextureData`

Herança: extends TextureData.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 113 |
| `_onClear` | método | `protected _onClear(): void` | 119 |
| `renderTexture` | propriedade | `public renderTexture: cc.SpriteFrame \| null = null;` | 117 |

### `Cocos/Demos/assets/Script/AnimationBase.ts`

- Origem/commit: `Cocos/Demos/assets/Script/AnimationBase.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/1.x/src/dragonBones/cocos/CocosArmatureComponent.ts`, `Cocos/1.x/src/dragonBones/cocos/CocosFactory.ts`, `DragonBones/src/dragonBones/event/EventObject.ts`, `Egret/Demos/src/demo/AnimationBase.ts`, `Phaser/Demos/src/AnimationBase.ts`, `Pixi/Demos/4.x/src/AnimationBase.ts`, `Pixi/Demos/8.x/src/AnimationBase.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `AnimationBase`

Herança: extends cc.Component.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `start` | método | `start()` | 5 |
| `_touchHandler` | método | `private _touchHandler(event: cc.Event.EventTouch): void` | 37 |
| `_animationEventHandler` | método | `private _animationEventHandler(event: cc.Event.EventCustom): void` | 58 |
| `_armatureComponent` | propriedade | `private _armatureComponent: dragonBones.CocosArmatureComponent;` | 3 |

### `Cocos/Demos/assets/Script/AnimationLayer.ts`

- Origem/commit: `Cocos/Demos/assets/Script/AnimationLayer.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/1.x/src/dragonBones/cocos/CocosArmatureComponent.ts`, `Cocos/1.x/src/dragonBones/cocos/CocosFactory.ts`, `DragonBones/src/dragonBones/event/EventObject.ts`, `Egret/Demos/src/demo/AnimationLayer.ts`, `Phaser/Demos/src/AnimationLayer.ts`, `Pixi/Demos/4.x/src/AnimationLayer.ts`, `Pixi/Demos/8.x/src/AnimationLayer.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `AnimationLayer`

Herança: extends cc.Component.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `start` | método | `start()` | 5 |
| `_animationEventHandler` | método | `private _animationEventHandler(event: cc.Event.EventCustom): void` | 26 |
| `_armatureComponent` | propriedade | `private _armatureComponent: dragonBones.CocosArmatureComponent;` | 3 |

### `Cocos/Demos/assets/Script/BoneOffset.ts`

- Origem/commit: `Cocos/Demos/assets/Script/BoneOffset.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/1.x/src/dragonBones/cocos/CocosArmatureComponent.ts`, `Cocos/1.x/src/dragonBones/cocos/CocosFactory.ts`, `DragonBones/src/dragonBones/event/EventObject.ts`, `Egret/Demos/src/demo/BoneOffset.ts`, `Phaser/Demos/src/BoneOffset.ts`, `Pixi/Demos/4.x/src/BoneOffset.ts`, `Pixi/Demos/8.x/src/BoneOffset.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `BoneOffset`

Herança: extends cc.Component.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `start` | método | `start()` | 3 |
| `_animationEventHandler` | método | `private _animationEventHandler(event: cc.Event.EventCustom): void` | 27 |
| `_moveTo` | método | `private _moveTo(armatureComponent: dragonBones.CocosArmatureComponent): void` | 32 |

### `Cocos/Demos/assets/Script/BoundingBox.ts`

- Origem/commit: `Cocos/Demos/assets/Script/BoundingBox.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/1.x/src/dragonBones/cocos/CocosArmatureComponent.ts`, `Cocos/1.x/src/dragonBones/cocos/CocosFactory.ts`, `Cocos/Demos/assets/Script/DragHelper.ts`, `DragonBones/src/dragonBones/armature/Bone.ts`, `Egret/Demos/src/DragHelper.ts`, `Egret/Demos/src/demo/BoundingBox.ts`, `Phaser/Demos/src/BoundingBox.ts`, `Phaser/Demos/src/DragHelper.ts`, `Pixi/Demos/4.x/src/BoundingBox.ts`, `Pixi/Demos/4.x/src/DragHelper.ts`, `Pixi/Demos/8.x/src/BoundingBox.ts`, `Pixi/Demos/8.x/src/DragHelper.ts`.
- Importações externas: "./DragHelper".

#### ClassDeclaration `BoundingBox`

Herança: extends cc.Component.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `start` | método | `start()` | 16 |
| `update` | método | `update()` | 61 |
| `_helpPointA` | propriedade | `private readonly _helpPointA: cc.Vec2 = cc.v2();` | 4 |
| `_helpPointB` | propriedade | `private readonly _helpPointB: cc.Vec2 = cc.v2();` | 5 |
| `_helpPointC` | propriedade | `private readonly _helpPointC: cc.Vec2 = cc.v2();` | 6 |
| `_armatureComponent` | propriedade | `private _armatureComponent: dragonBones.CocosArmatureComponent;` | 8 |
| `_boundingBoxTester` | propriedade | `private _boundingBoxTester: dragonBones.CocosArmatureComponent;` | 9 |
| `_targetA` | propriedade | `private _targetA: dragonBones.CocosArmatureComponent;` | 10 |
| `_targetB` | propriedade | `private _targetB: dragonBones.CocosArmatureComponent;` | 11 |
| `_line` | propriedade | `private _line: dragonBones.Bone;` | 12 |
| `_pointA` | propriedade | `private _pointA: dragonBones.Bone;` | 13 |
| `_pointB` | propriedade | `private _pointB: dragonBones.Bone;` | 14 |

### `Cocos/Demos/assets/Script/CoreElement.ts`

- Origem/commit: `Cocos/Demos/assets/Script/CoreElement.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/1.x/src/dragonBones/cocos/CocosArmatureComponent.ts`, `Cocos/1.x/src/dragonBones/cocos/CocosFactory.ts`, `Cocos/Demos/assets/Script/DragHelper.ts`, `DragonBones/src/dragonBones/animation/AnimationState.ts`, `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/event/EventObject.ts`, `DragonBones/src/dragonBones/geom/Transform.ts`, `Egret/Demos/src/DragHelper.ts`, `Egret/Demos/src/demo/CoreElement.ts`, `Phaser/Demos/src/CoreElement.ts`, `Phaser/Demos/src/DragHelper.ts`, `Pixi/Demos/4.x/src/CoreElement.ts`, `Pixi/Demos/4.x/src/DragHelper.ts`, `Pixi/Demos/8.x/src/CoreElement.ts`, `Pixi/Demos/8.x/src/DragHelper.ts`.
- Importações externas: "./DragHelper".

#### ClassDeclaration `Game`

Herança: extends cc.Component.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `start` | método | `start()` | 18 |
| `update` | método | `update()` | 54 |
| `_touchHandler` | método | `private _touchHandler(event: cc.Event.EventTouch): void` | 68 |
| `_keyHandler` | método | `private _keyHandler(event: KeyboardEvent): void` | 79 |
| `_updateMove` | método | `private _updateMove(dir: number): void` | 126 |
| `addBullet` | método | `public addBullet(bullet: Bullet): void` | 141 |
| `GROUND` | propriedade | `public static GROUND: number;` | 9 |
| `G` | propriedade | `public static G: number = -0.6;` | 10 |
| `instance` | propriedade | `public static instance: Game;` | 11 |
| `_left` | propriedade | `private _left: boolean = false;` | 13 |
| `_right` | propriedade | `private _right: boolean = false;` | 14 |
| `_player` | propriedade | `private _player: Mecha;` | 15 |
| `_bullets` | propriedade | `private readonly _bullets: Array<Bullet> = [];` | 16 |

#### ClassDeclaration `Mecha`

Herança: nenhuma explícita.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 181 |
| `move` | método | `public move(dir: number): void` | 205 |
| `jump` | método | `public jump(): void` | 214 |
| `squat` | método | `public squat(isSquating: boolean): void` | 228 |
| `attack` | método | `public attack(isAttacking: boolean): void` | 237 |
| `switchWeaponL` | método | `public switchWeaponL(): void` | 245 |
| `switchWeaponR` | método | `public switchWeaponR(): void` | 265 |
| `switchSkin` | método | `public switchSkin(): void` | 285 |
| `aim` | método | `public aim(x: number, y: number): void` | 293 |
| `update` | método | `public update(): void` | 298 |
| `_animationEventHandler` | método | `private _animationEventHandler(event: EventType): void` | 304 |
| `_frameEventHandler` | método | `private _frameEventHandler(event: EventType): void` | 344 |
| `_fire` | método | `private _fire(firePoint: PointType): void` | 356 |
| `_updateAnimation` | método | `private _updateAnimation(): void` | 362 |
| `_updatePosition` | método | `private _updatePosition(): void` | 413 |
| `_updateAim` | método | `private _updateAim(): void` | 449 |
| `_updateAttack` | método | `private _updateAttack(): void` | 502 |
| `JUMP_SPEED` | propriedade | `private static readonly JUMP_SPEED: number = 20;` | 147 |
| `NORMALIZE_MOVE_SPEED` | propriedade | `private static readonly NORMALIZE_MOVE_SPEED: number = 3.6;` | 148 |
| `MAX_MOVE_SPEED_FRONT` | propriedade | `private static readonly MAX_MOVE_SPEED_FRONT: number = Mecha.NORMALIZE_MOVE_SPEED * 1.4;` | 149 |
| `MAX_MOVE_SPEED_BACK` | propriedade | `private static readonly MAX_MOVE_SPEED_BACK: number = Mecha.NORMALIZE_MOVE_SPEED * 1.0;` | 150 |
| `NORMAL_ANIMATION_GROUP` | propriedade | `private static readonly NORMAL_ANIMATION_GROUP: string = "normal";` | 151 |
| `AIM_ANIMATION_GROUP` | propriedade | `private static readonly AIM_ANIMATION_GROUP: string = "aim";` | 152 |
| `ATTACK_ANIMATION_GROUP` | propriedade | `private static readonly ATTACK_ANIMATION_GROUP: string = "attack";` | 153 |
| `WEAPON_L_LIST` | propriedade | `private static readonly WEAPON_L_LIST: Array<string> = ["weapon_1502b_l", "weapon_1005", "weapon_1005b", "weapon_1005c", "weapon_1005d", "weapon_1005e", ""];` | 154 |
| `WEAPON_R_LIST` | propriedade | `private static readonly WEAPON_R_LIST: Array<string> = ["weapon_1502b_r", "weapon_1005", "weapon_1005b", "weapon_1005c", "weapon_1005d", ""];` | 155 |
| `SKINS` | propriedade | `private static readonly SKINS: Array<string> = ["mecha_1502b", "skin_a", "skin_b", "skin_c"];` | 156 |
| `_isJumpingA` | propriedade | `private _isJumpingA: boolean = false;` | 158 |
| `_isSquating` | propriedade | `private _isSquating: boolean = false;` | 159 |
| `_isAttackingA` | propriedade | `private _isAttackingA: boolean = false;` | 160 |
| `_isAttackingB` | propriedade | `private _isAttackingB: boolean = false;` | 161 |
| `_weaponRIndex` | propriedade | `private _weaponRIndex: number = 0;` | 162 |
| `_weaponLIndex` | propriedade | `private _weaponLIndex: number = 0;` | 163 |
| `_skinIndex` | propriedade | `private _skinIndex: number = 0;` | 164 |
| `_faceDir` | propriedade | `private _faceDir: number = 1;` | 165 |
| `_aimDir` | propriedade | `private _aimDir: number = 0;` | 166 |
| `_moveDir` | propriedade | `private _moveDir: number = 0;` | 167 |
| `_aimRadian` | propriedade | `private _aimRadian: number = 0.0;` | 168 |
| `_speedX` | propriedade | `private _speedX: number = 0.0;` | 169 |
| `_speedY` | propriedade | `private _speedY: number = 0.0;` | 170 |
| `_armature` | propriedade | `private _armature: dragonBones.Armature;` | 171 |
| `_armatureComponent` | propriedade | `private _armatureComponent: ArmatureComponentType;` | 172 |
| `_weaponL` | propriedade | `private _weaponL: dragonBones.Armature \| null = null;` | 173 |
| `_weaponR` | propriedade | `private _weaponR: dragonBones.Armature \| null = null;` | 174 |
| `_aimState` | propriedade | `private _aimState: dragonBones.AnimationState \| null = null;` | 175 |
| `_walkState` | propriedade | `private _walkState: dragonBones.AnimationState \| null = null;` | 176 |
| `_attackState` | propriedade | `private _attackState: dragonBones.AnimationState \| null = null;` | 177 |
| `_target` | propriedade | `private readonly _target: PointType = cc.v2();` | 178 |
| `_helpPoint` | propriedade | `private readonly _helpPoint: PointType = cc.v2();` | 179 |

#### ClassDeclaration `Bullet`

Herança: nenhuma explícita.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor(armatureName: string, effectArmatureName: string \| null, radian: number, speed: number, position: PointType)` | 525 |
| `update` | método | `public update(): boolean` | 554 |
| `_speedX` | propriedade | `private _speedX: number = 0.0;` | 519 |
| `_speedY` | propriedade | `private _speedY: number = 0.0;` | 520 |
| `_armatureComponent` | propriedade | `private _armatureComponent: ArmatureComponentType;` | 522 |
| `_effecComponent` | propriedade | `private _effecComponent: ArmatureComponentType \| null = null;` | 523 |

### `Cocos/Demos/assets/Script/DragHelper.ts`

- Origem/commit: `Cocos/Demos/assets/Script/DragHelper.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/1.x/src/dragonBones/cocos/CocosArmatureComponent.ts`, `Egret/Demos/src/DragHelper.ts`, `Phaser/Demos/src/DragHelper.ts`, `Pixi/Demos/4.x/src/DragHelper.ts`, `Pixi/Demos/8.x/src/DragHelper.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `DragHelper`

Herança: nenhuma explícita.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `getInstance` | método | `public static getInstance(): DragHelper` | 3 |
| `_dragHandler` | método | `private _dragHandler(event: cc.Event.EventTouch): void` | 10 |
| `_hold` | método | `private _hold(): void` | 63 |
| `enableDrag` | método | `public enableDrag(displayObject: cc.Node): void` | 66 |
| `disableDrag` | método | `public disableDrag(displayObject: cc.Node): void` | 75 |
| `_instance` | propriedade | `private static _instance: DragHelper = new DragHelper();` | 2 |
| `_dragOffset` | propriedade | `private readonly _dragOffset: cc.Vec2 = cc.v2();` | 7 |
| `_dragDisplayObject` | propriedade | `private _dragDisplayObject: cc.Node \| null = null;` | 8 |

### `Cocos/Demos/assets/Script/DragonBonesEvent.ts`

- Origem/commit: `Cocos/Demos/assets/Script/DragonBonesEvent.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/1.x/src/dragonBones/cocos/CocosArmatureComponent.ts`, `Cocos/1.x/src/dragonBones/cocos/CocosFactory.ts`, `DragonBones/src/dragonBones/event/EventObject.ts`, `Egret/Demos/src/demo/DragonBonesEvent.ts`, `Phaser/Demos/src/DragonBonesEvent.ts`, `Pixi/Demos/4.x/src/DragonBonesEvent.ts`, `Pixi/Demos/8.x/src/DragonBonesEvent.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `DragonBonesEvent`

Herança: extends cc.Component.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `start` | método | `start()` | 5 |
| `_soundEventHandler` | método | `private _soundEventHandler(event: cc.Event.EventCustom): void` | 31 |
| `_animationEventHandler` | método | `private _animationEventHandler(event: cc.Event.EventCustom): void` | 36 |
| `_armatureComponent` | propriedade | `private _armatureComponent: dragonBones.CocosArmatureComponent;` | 3 |

### `Cocos/Demos/assets/Script/EyeTracking.ts`

- Origem/commit: `Cocos/Demos/assets/Script/EyeTracking.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/1.x/src/dragonBones/cocos/CocosArmatureComponent.ts`, `Cocos/1.x/src/dragonBones/cocos/CocosFactory.ts`, `Egret/Demos/src/demo/EyeTracking.ts`, `Pixi/Demos/4.x/src/EyeTracking.ts`, `Pixi/Demos/8.x/src/EyeTracking.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `EyeTracking`

Herança: extends cc.Component.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `start` | método | `start()` | 21 |
| `update` | método | `update(): void` | 56 |
| `_setTarget` | método | `private _setTarget(x: number, y: number)` | 125 |
| `_scale` | propriedade | `private _scale: number = 0.3;` | 3 |
| `_target` | propriedade | `private readonly _target: cc.Vec2 = cc.v2();` | 4 |
| `_animationNames` | propriedade | `private readonly _animationNames: string[] = [ "PARAM_ANGLE_X", "PARAM_ANGLE_Y", "PARAM_ANGLE_Z", "PARAM_EYE_BALL_X", "PARAM_EYE_BALL_Y", "PARAM_BODY_X", "PARAM_BODY_Y", "PARAM_BODY_Z", "PARAM_BODY_ANGLE_X", "PARAM_BODY_ANGLE_Y", "PARAM_BODY_ANGLE_Z", "PARAM_BREATH", ];` | 5 |
| `_armatureComponent` | propriedade | `private _armatureComponent: dragonBones.CocosArmatureComponent;` | 19 |

### `Cocos/Demos/assets/Script/HelloDragonBones.ts`

- Origem/commit: `Cocos/Demos/assets/Script/HelloDragonBones.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/1.x/src/dragonBones/cocos/CocosFactory.ts`, `Egret/Demos/src/demo/HelloDragonBones.ts`, `Hilo/Demos/src/HelloDragonBones.ts`, `Phaser/Demos/src/HelloDragonBones.ts`, `Pixi/Demos/4.x/src/HelloDragonBones.ts`, `Pixi/Demos/8.x/src/HelloDragonBones.ts`, `ThreeJS/Demos/src/HelloDragonBones.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `HelloDragonBones`

Herança: extends cc.Component.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `start` | método | `start()` | 20 |

### `Cocos/Demos/assets/Script/InverseKinematics.ts`

- Origem/commit: `Cocos/Demos/assets/Script/InverseKinematics.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/1.x/src/dragonBones/cocos/CocosArmatureComponent.ts`, `Cocos/1.x/src/dragonBones/cocos/CocosFactory.ts`, `Cocos/Demos/assets/Script/DragHelper.ts`, `DragonBones/src/dragonBones/animation/AnimationState.ts`, `DragonBones/src/dragonBones/armature/Bone.ts`, `DragonBones/src/dragonBones/geom/Transform.ts`, `Egret/Demos/src/DragHelper.ts`, `Egret/Demos/src/demo/InverseKinematics.ts`, `Phaser/Demos/src/DragHelper.ts`, `Phaser/Demos/src/InverseKinematics.ts`, `Pixi/Demos/4.x/src/DragHelper.ts`, `Pixi/Demos/4.x/src/InverseKinematics.ts`, `Pixi/Demos/8.x/src/DragHelper.ts`, `Pixi/Demos/8.x/src/InverseKinematics.ts`.
- Importações externas: "./DragHelper".

#### ClassDeclaration `InverseKinematics`

Herança: extends cc.Component.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `start` | método | `start()` | 18 |
| `update` | método | `update()` | 63 |
| `_updateAim` | método | `private _updateAim(): void` | 72 |
| `_updateFoot` | método | `private _updateFoot(): void` | 96 |
| `_faceDir` | propriedade | `private _faceDir: number = 0;` | 5 |
| `_aimRadian` | propriedade | `private _aimRadian: number = 0.0;` | 6 |
| `_offsetRotation` | propriedade | `private _offsetRotation: number = 0.0;` | 7 |
| `_target` | propriedade | `private readonly _target: cc.Vec2 = cc.v2();` | 8 |
| `_armatureComponent` | propriedade | `private _armatureComponent: dragonBones.CocosArmatureComponent;` | 9 |
| `_floorBoard` | propriedade | `private _floorBoard: dragonBones.CocosArmatureComponent;` | 10 |
| `_chestBone` | propriedade | `private _chestBone: dragonBones.Bone;` | 11 |
| `_leftFootBone` | propriedade | `private _leftFootBone: dragonBones.Bone;` | 12 |
| `_rightFootBone` | propriedade | `private _rightFootBone: dragonBones.Bone;` | 13 |
| `_circleBone` | propriedade | `private _circleBone: dragonBones.Bone;` | 14 |
| `_floorBoardBone` | propriedade | `private _floorBoardBone: dragonBones.Bone;` | 15 |
| `_aimState` | propriedade | `private _aimState: dragonBones.AnimationState;` | 16 |

### `Cocos/Demos/assets/Script/MultiTextureAltas.ts`

- Origem/commit: `Cocos/Demos/assets/Script/MultiTextureAltas.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/1.x/src/dragonBones/cocos/CocosArmatureComponent.ts`, `Cocos/1.x/src/dragonBones/cocos/CocosFactory.ts`, `Egret/Demos/src/demo/MultiTextureAltas.ts`, `Pixi/Demos/4.x/src/MultiTextureAltas.ts`, `Pixi/Demos/8.x/src/MultiTextureAltas.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `MultiTextureAltas`

Herança: extends cc.Component.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `start` | método | `start()` | 8 |
| `_changeAnimation` | método | `private _changeAnimation(): void` | 55 |
| `_armatureComponentA` | propriedade | `private _armatureComponentA: dragonBones.CocosArmatureComponent;` | 3 |
| `_armatureComponentB` | propriedade | `private _armatureComponentB: dragonBones.CocosArmatureComponent;` | 4 |
| `_armatureComponentC` | propriedade | `private _armatureComponentC: dragonBones.CocosArmatureComponent;` | 5 |
| `_armatureComponentD` | propriedade | `private _armatureComponentD: dragonBones.CocosArmatureComponent;` | 6 |

### `Cocos/Demos/assets/Script/PerformanceTest.ts`

- Origem/commit: `Cocos/Demos/assets/Script/PerformanceTest.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/1.x/src/dragonBones/cocos/CocosArmatureComponent.ts`, `Cocos/1.x/src/dragonBones/cocos/CocosFactory.ts`, `DragonBones/src/dragonBones/core/BaseObject.ts`, `Egret/Demos/src/demo/PerformanceTest.ts`, `Hilo/Demos/src/PerformanceTest.ts`, `Phaser/Demos/src/PerformanceTest.ts`, `Pixi/Demos/4.x/src/PerformanceTest.ts`, `Pixi/Demos/8.x/src/PerformanceTest.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `PerformanceTest`

Herança: extends cc.Component.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `start` | método | `start()` | 9 |
| `update` | método | `update()` | 29 |
| `_touchHandler` | método | `private _touchHandler(event: cc.Event.EventTouch): void` | 49 |
| `_addArmature` | método | `private _addArmature(): void` | 64 |
| `_removeArmature` | método | `private _removeArmature(): void` | 80 |
| `_resetPosition` | método | `private _resetPosition(): void` | 95 |
| `_updateText` | método | `private _updateText(): void` | 122 |
| `_addingArmature` | propriedade | `private _addingArmature: boolean = false;` | 3 |
| `_removingArmature` | propriedade | `private _removingArmature: boolean = false;` | 4 |
| `_resources` | propriedade | `private readonly _resources: string[] = [];` | 5 |
| `_armatures` | propriedade | `private readonly _armatures: dragonBones.CocosArmatureComponent[] = [];` | 6 |
| `_text` | propriedade | `private _text: cc.Label;` | 7 |

### `Cocos/Demos/assets/Script/ReplaceAnimation.ts`

- Origem/commit: `Cocos/Demos/assets/Script/ReplaceAnimation.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/1.x/src/dragonBones/cocos/CocosArmatureComponent.ts`, `Cocos/1.x/src/dragonBones/cocos/CocosFactory.ts`, `Cocos/Demos/assets/Script/ReplaceSlotDisplay.ts`, `Egret/Demos/src/demo/ReplaceSlotDisplay.ts`, `Hilo/Demos/src/ReplaceSlotDisplay.ts`, `Phaser/Demos/src/ReplaceSlotDisplay.ts`, `Pixi/Demos/4.x/src/ReplaceSlotDisplay.ts`, `Pixi/Demos/8.x/src/ReplaceSlotDisplay.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `ReplaceSlotDisplay`

Herança: extends cc.Component.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `start` | método | `start()` | 8 |
| `_changeAnimation` | método | `private _changeAnimation(): void` | 49 |
| `_armatureComponentA` | propriedade | `private _armatureComponentA: dragonBones.CocosArmatureComponent;` | 3 |
| `_armatureComponentB` | propriedade | `private _armatureComponentB: dragonBones.CocosArmatureComponent;` | 4 |
| `_armatureComponentC` | propriedade | `private _armatureComponentC: dragonBones.CocosArmatureComponent;` | 5 |
| `_armatureComponentD` | propriedade | `private _armatureComponentD: dragonBones.CocosArmatureComponent;` | 6 |

### `Cocos/Demos/assets/Script/ReplaceSkin.ts`

- Origem/commit: `Cocos/Demos/assets/Script/ReplaceSkin.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/1.x/src/dragonBones/cocos/CocosArmatureComponent.ts`, `Cocos/1.x/src/dragonBones/cocos/CocosFactory.ts`, `DragonBones/src/dragonBones/event/EventObject.ts`, `Egret/Demos/src/demo/ReplaceSkin.ts`, `Pixi/Demos/4.x/src/ReplaceSkin.ts`, `Pixi/Demos/8.x/src/ReplaceSkin.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `ReplaceSkin`

Herança: extends cc.Component.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `start` | método | `start()` | 8 |
| `_animationEventHandler` | método | `private _animationEventHandler(event: cc.Event.EventCustom): void` | 103 |
| `_randomReplaceSkin` | método | `private _randomReplaceSkin(): void` | 111 |
| `_replaceSuitIndex` | propriedade | `private _replaceSuitIndex: number = 0;` | 3 |
| `_suitConfigs` | propriedade | `private readonly _suitConfigs: string[][] = [];` | 4 |
| `_replaceSuitParts` | propriedade | `private readonly _replaceSuitParts: string[] = [];` | 5 |
| `_armatureComponent` | propriedade | `private _armatureComponent: dragonBones.CocosArmatureComponent;` | 6 |

### `Cocos/Demos/assets/Script/ReplaceSlotDisplay.ts`

- Origem/commit: `Cocos/Demos/assets/Script/ReplaceSlotDisplay.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/1.x/src/dragonBones/cocos/CocosArmatureComponent.ts`, `Cocos/1.x/src/dragonBones/cocos/CocosFactory.ts`, `Cocos/Demos/assets/Script/ReplaceAnimation.ts`, `Egret/Demos/src/demo/ReplaceSlotDisplay.ts`, `Hilo/Demos/src/ReplaceSlotDisplay.ts`, `Phaser/Demos/src/ReplaceSlotDisplay.ts`, `Pixi/Demos/4.x/src/ReplaceSlotDisplay.ts`, `Pixi/Demos/8.x/src/ReplaceSlotDisplay.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `ReplaceSlotDisplay`

Herança: extends cc.Component.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `start` | método | `start()` | 10 |
| `_replaceDisplay` | método | `private _replaceDisplay(type: number): void` | 48 |
| `WEAPON_RIGHT_LIST` | propriedade | `private static readonly WEAPON_RIGHT_LIST: string[] = ["weapon_1004_r", "weapon_1004b_r", "weapon_1004c_r", "weapon_1004d_r", "weapon_1004e_r"];` | 3 |
| `_leftWeaponIndex` | propriedade | `private _leftWeaponIndex: number = 0;` | 5 |
| `_rightWeaponIndex` | propriedade | `private _rightWeaponIndex: number = 0;` | 6 |
| `_armatureComponent` | propriedade | `private _armatureComponent: dragonBones.CocosArmatureComponent;` | 7 |
| `_logoText` | propriedade | `private _logoText: cc.Node;` | 8 |

### `Cocos/Demos/assets/Script/Test.ts`

- Origem/commit: `Cocos/Demos/assets/Script/Test.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/1.x/src/dragonBones/cocos/CocosFactory.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `Test`

Herança: extends cc.Component.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `start` | método | `start()` | 3 |

### `DragonBones/src/dragonBones/animation/Animation.ts`

- Origem/commit: `DragonBones/src/dragonBones/animation/Animation.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: dragonbones/animation/Animation.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/animation/AnimationState.ts`, `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/model/AnimationConfig.ts`, `DragonBones/src/dragonBones/model/AnimationData.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `Animation`

Herança: extends BaseObject.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 39 |
| `_onClear` | método | `protected _onClear(): void` | 68 |
| `_fadeOut` | método | `private _fadeOut(animationConfig: AnimationConfig): void` | 102 |
| `init` | método | `public init(armature: Armature): void` | 161 |
| `advanceTime` | método | `public advanceTime(passedTime: number): void` | 172 |
| `reset` | método | `public reset(): void` | 280 |
| `stop` | método | `public stop(animationName: string \| null = null): void` | 304 |
| `playConfig` | método | `public playConfig(animationConfig: AnimationConfig): AnimationState \| null` | 337 |
| `play` | método | `public play(animationName: string \| null = null, playTimes: number = -1): AnimationState \| null` | 506 |
| `fadeIn` | método | `public fadeIn( animationName: string, fadeInTime: number = -1.0, playTimes: number = -1, layer: number = 0, group: string \| null = null, fadeOutMode: AnimationFadeOutMode = AnimationFadeOutMode.SameLayerAndGroup ): AnimationState \| null` | 567 |
| `gotoAndPlayByTime` | método | `public gotoAndPlayByTime(animationName: string, time: number = 0.0, playTimes: number = -1): AnimationState \| null` | 599 |
| `gotoAndPlayByFrame` | método | `public gotoAndPlayByFrame(animationName: string, frame: number = 0, playTimes: number = -1): AnimationState \| null` | 627 |
| `gotoAndPlayByProgress` | método | `public gotoAndPlayByProgress(animationName: string, progress: number = 0.0, playTimes: number = -1): AnimationState \| null` | 659 |
| `gotoAndStopByTime` | método | `public gotoAndStopByTime(animationName: string, time: number = 0.0): AnimationState \| null` | 689 |
| `gotoAndStopByFrame` | método | `public gotoAndStopByFrame(animationName: string, frame: number = 0): AnimationState \| null` | 713 |
| `gotoAndStopByProgress` | método | `public gotoAndStopByProgress(animationName: string, progress: number = 0.0): AnimationState \| null` | 737 |
| `getBlendState` | método | `public getBlendState(type: string, name: string, target: BaseObject): BlendState` | 748 |
| `getState` | método | `public getState(animationName: string, layer: number = -1): AnimationState \| null` | 787 |
| `hasAnimation` | método | `public hasAnimation(animationName: string): boolean` | 812 |
| `getStates` | método | `public getStates(): ReadonlyArray<AnimationState>` | 825 |
| `isPlaying` | método | `public get isPlaying(): boolean` | 840 |
| `isCompleted` | método | `public get isCompleted(): boolean` | 861 |
| `lastAnimationName` | método | `public get lastAnimationName(): string` | 882 |
| `animationNames` | método | `public get animationNames(): ReadonlyArray<string>` | 895 |
| `animations` | método | `public get animations(): Map<AnimationData>` | 908 |
| `animations` | método | `public set animations(value: Map<AnimationData>)` | 911 |
| `animationConfig` | método | `public get animationConfig(): AnimationConfig` | 939 |
| `lastAnimationState` | método | `public get lastAnimationState(): AnimationState \| null` | 955 |
| `timeScale` | propriedade | `public timeScale: number;` | 54 |
| `_animationDirty` | propriedade | `private _animationDirty: boolean;` | 58 |
| `_inheritTimeScale` | propriedade | `private _inheritTimeScale: number;` | 59 |
| `_animationNames` | propriedade | `private readonly _animationNames: Array<string> = [];` | 60 |
| `_animationStates` | propriedade | `private readonly _animationStates: Array<AnimationState> = [];` | 61 |
| `_animations` | propriedade | `private readonly _animations: Map<AnimationData> = {};` | 62 |
| `_blendStates` | propriedade | `private readonly _blendStates: Map<Map<BlendState>> = {};` | 63 |
| `_armature` | propriedade | `private _armature: Armature;` | 64 |
| `_animationConfig` | propriedade | `private _animationConfig: AnimationConfig = null as any;` | 65 |
| `_lastAnimationState` | propriedade | `private _lastAnimationState: AnimationState \| null;` | 66 |

### `DragonBones/src/dragonBones/animation/AnimationState.ts`

- Origem/commit: `DragonBones/src/dragonBones/animation/AnimationState.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: dragonbones/animation/AnimationState.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/animation/BaseTimelineState.ts`, `DragonBones/src/dragonBones/animation/TimelineState.ts`, `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/armature/Bone.ts`, `DragonBones/src/dragonBones/armature/Constraint.ts`, `DragonBones/src/dragonBones/armature/Slot.ts`, `DragonBones/src/dragonBones/armature/Surface.ts`, `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/event/EventObject.ts`, `DragonBones/src/dragonBones/model/AnimationConfig.ts`, `DragonBones/src/dragonBones/model/AnimationData.ts`, `Phaser/3.x/src/dragonBones/phaser/display/Slot.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `AnimationState`

Herança: extends BaseObject.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 39 |
| `_onClear` | método | `protected _onClear(): void` | 251 |
| `_updateTimelines` | método | `private _updateTimelines(): void` | 337 |
| `_updateBoneAndSlotTimelines` | método | `private _updateBoneAndSlotTimelines(): void` | 369 |
| `_advanceFadeTime` | método | `private _advanceFadeTime(passedTime: number): void` | 667 |
| `init` | método | `public init(armature: Armature, animationData: AnimationData, animationConfig: AnimationConfig): void` | 725 |
| `advanceTime` | método | `public advanceTime(passedTime: number, cacheFrameRate: number): void` | 808 |
| `play` | método | `public play(): void` | 1081 |
| `stop` | método | `public stop(): void` | 1094 |
| `fadeOut` | método | `public fadeOut(fadeOutTime: number, pausePlayhead: boolean = true): void` | 1111 |
| `containsBoneMask` | método | `public containsBoneMask(boneName: string): boolean` | 1177 |
| `addBoneMask` | método | `public addBoneMask(boneName: string, recursive: boolean = true): void` | 1194 |
| `removeBoneMask` | método | `public removeBoneMask(boneName: string, recursive: boolean = true): void` | 1228 |
| `removeAllBoneMask` | método | `public removeAllBoneMask(): void` | 1272 |
| `addState` | método | `public addState(animationState: AnimationState, timelineDatas: TimelineData[] \| null = null)` | 1279 |
| `activeTimeline` | método | `public activeTimeline(): void` | 1330 |
| `isFadeIn` | método | `public get isFadeIn(): boolean` | 1346 |
| `isFadeOut` | método | `public get isFadeOut(): boolean` | 1359 |
| `isFadeComplete` | método | `public get isFadeComplete(): boolean` | 1372 |
| `isPlaying` | método | `public get isPlaying(): boolean` | 1385 |
| `isCompleted` | método | `public get isCompleted(): boolean` | 1398 |
| `currentPlayTimes` | método | `public get currentPlayTimes(): number` | 1411 |
| `totalTime` | método | `public get totalTime(): number` | 1424 |
| `currentTime` | método | `public get currentTime(): number` | 1437 |
| `currentTime` | método | `public set currentTime(value: number)` | 1440 |
| `weight` | método | `public get weight(): number` | 1493 |
| `weight` | método | `public set weight(value: number)` | 1496 |
| `animationData` | método | `public get animationData(): AnimationData` | 1521 |
| `actionEnabled` | propriedade | `public actionEnabled: boolean;` | 45 |
| `additive` | propriedade | `public additive: boolean;` | 49 |
| `displayControl` | propriedade | `public displayControl: boolean;` | 66 |
| `resetToPose` | propriedade | `public resetToPose: boolean;` | 81 |
| `blendType` | propriedade | `public blendType: AnimationBlendType;` | 85 |
| `playTimes` | propriedade | `public playTimes: number;` | 96 |
| `layer` | propriedade | `public layer: number;` | 113 |
| `timeScale` | propriedade | `public timeScale: number;` | 130 |
| `parameterX` | propriedade | `public parameterX: number;` | 134 |
| `parameterY` | propriedade | `public parameterY: number;` | 138 |
| `positionX` | propriedade | `public positionX: number;` | 142 |
| `positionY` | propriedade | `public positionY: number;` | 146 |
| `autoFadeOutTime` | propriedade | `public autoFadeOutTime: number;` | 161 |
| `fadeTotalTime` | propriedade | `public fadeTotalTime: number;` | 165 |
| `name` | propriedade | `public name: string;` | 178 |
| `group` | propriedade | `public group: string;` | 193 |
| `_timelineDirty` | propriedade | `private _timelineDirty: number;` | 194 |
| `_playheadState` | propriedade | `public _playheadState: number;` | 199 |
| `_fadeState` | propriedade | `public _fadeState: number;` | 204 |
| `_subFadeState` | propriedade | `public _subFadeState: number;` | 209 |
| `_position` | propriedade | `public _position: number;` | 213 |
| `_duration` | propriedade | `public _duration: number;` | 217 |
| `_weight` | propriedade | `private _weight: number;` | 218 |
| `_fadeTime` | propriedade | `private _fadeTime: number;` | 219 |
| `_time` | propriedade | `private _time: number;` | 220 |
| `_fadeProgress` | propriedade | `public _fadeProgress: number;` | 224 |
| `_weightResult` | propriedade | `public _weightResult: number;` | 228 |
| `_boneMask` | propriedade | `private readonly _boneMask: Array<string> = [];` | 229 |
| `_boneTimelines` | propriedade | `private readonly _boneTimelines: Array<TimelineState> = [];` | 230 |
| `_boneBlendTimelines` | propriedade | `private readonly _boneBlendTimelines: Array<TimelineState> = [];` | 231 |
| `_slotTimelines` | propriedade | `private readonly _slotTimelines: Array<TimelineState> = [];` | 232 |
| `_slotBlendTimelines` | propriedade | `private readonly _slotBlendTimelines: Array<TimelineState> = [];` | 233 |
| `_constraintTimelines` | propriedade | `private readonly _constraintTimelines: Array<TimelineState> = [];` | 234 |
| `_animationTimelines` | propriedade | `private readonly _animationTimelines: Array<TimelineState> = [];` | 235 |
| `_poseTimelines` | propriedade | `private readonly _poseTimelines: Array<TimelineState> = [];` | 236 |
| `_animationData` | propriedade | `private _animationData: AnimationData;` | 237 |
| `_armature` | propriedade | `private _armature: Armature;` | 238 |
| `_actionTimeline` | propriedade | `public _actionTimeline: ActionTimelineState = null as any;` | 242 |
| `_zOrderTimeline` | propriedade | `private _zOrderTimeline: ZOrderTimelineState \| null = null;` | 243 |
| `_activeChildA` | propriedade | `private _activeChildA: AnimationState \| null;` | 244 |
| `_activeChildB` | propriedade | `private _activeChildB: AnimationState \| null;` | 245 |
| `_parent` | propriedade | `public _parent: AnimationState \| null;` | 249 |

#### ClassDeclaration `BlendState`

Herança: extends BaseObject.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 1536 |
| `_onClear` | método | `protected _onClear(): void` | 1547 |
| `update` | método | `public update(animationState: AnimationState): boolean` | 1553 |
| `reset` | método | `public reset(): void` | 1594 |
| `BONE_TRANSFORM` | propriedade | `public static readonly BONE_TRANSFORM: string = "boneTransform";` | 1529 |
| `BONE_ALPHA` | propriedade | `public static readonly BONE_ALPHA: string = "boneAlpha";` | 1530 |
| `SURFACE` | propriedade | `public static readonly SURFACE: string = "surface";` | 1531 |
| `SLOT_DEFORM` | propriedade | `public static readonly SLOT_DEFORM: string = "slotDeform";` | 1532 |
| `SLOT_ALPHA` | propriedade | `public static readonly SLOT_ALPHA: string = "slotAlpha";` | 1533 |
| `SLOT_Z_INDEX` | propriedade | `public static readonly SLOT_Z_INDEX: string = "slotZIndex";` | 1534 |
| `dirty` | propriedade | `public dirty: number;` | 1540 |
| `layer` | propriedade | `public layer: number;` | 1541 |
| `leftWeight` | propriedade | `public leftWeight: number;` | 1542 |
| `layerWeight` | propriedade | `public layerWeight: number;` | 1543 |
| `blendWeight` | propriedade | `public blendWeight: number;` | 1544 |
| `target` | propriedade | `public target: BaseObject;` | 1545 |

### `DragonBones/src/dragonBones/animation/BaseTimelineState.ts`

- Origem/commit: `DragonBones/src/dragonBones/animation/BaseTimelineState.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: dragonbones/animation/BaseTimelineState.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/animation/AnimationState.ts`, `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/model/AnimationData.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `TimelineState`

Herança: extends BaseObject.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `_onClear` | método | `protected _onClear(): void` | 59 |
| `_onArriveAtFrame` | método | `protected abstract _onArriveAtFrame(): void;` | 89 |
| `_onUpdateFrame` | método | `protected abstract _onUpdateFrame(): void;` | 90 |
| `_setCurrentTime` | método | `protected _setCurrentTime(passedTime: number): boolean` | 92 |
| `init` | método | `public init(armature: Armature, animationState: AnimationState, timelineData: TimelineData \| null): void` | 163 |
| `fadeOut` | método | `public fadeOut(): void` | 193 |
| `update` | método | `public update(passedTime: number): void` | 197 |
| `blend` | método | `public blend(_isDirty: boolean): void` | 226 |
| `dirty` | propriedade | `public dirty: boolean;` | 28 |
| `playState` | propriedade | `public playState: number;` | 32 |
| `currentPlayTimes` | propriedade | `public currentPlayTimes: number;` | 33 |
| `currentTime` | propriedade | `public currentTime: number;` | 34 |
| `target` | propriedade | `public target: BaseObject;` | 35 |
| `_isTween` | propriedade | `protected _isTween: boolean;` | 37 |
| `_valueOffset` | propriedade | `protected _valueOffset: number;` | 38 |
| `_frameValueOffset` | propriedade | `protected _frameValueOffset: number;` | 39 |
| `_frameOffset` | propriedade | `protected _frameOffset: number;` | 40 |
| `_frameRate` | propriedade | `protected _frameRate: number;` | 41 |
| `_frameCount` | propriedade | `protected _frameCount: number;` | 42 |
| `_frameIndex` | propriedade | `protected _frameIndex: number;` | 43 |
| `_frameRateR` | propriedade | `protected _frameRateR: number;` | 44 |
| `_position` | propriedade | `protected _position: number;` | 45 |
| `_duration` | propriedade | `protected _duration: number;` | 46 |
| `_timeScale` | propriedade | `protected _timeScale: number;` | 47 |
| `_timeOffset` | propriedade | `protected _timeOffset: number;` | 48 |
| `_animationData` | propriedade | `protected _animationData: AnimationData;` | 49 |
| `_timelineData` | propriedade | `protected _timelineData: TimelineData \| null;` | 50 |
| `_armature` | propriedade | `protected _armature: Armature;` | 51 |
| `_animationState` | propriedade | `protected _animationState: AnimationState;` | 52 |
| `_actionTimeline` | propriedade | `protected _actionTimeline: TimelineState;` | 53 |
| `_timelineArray` | propriedade | `protected _timelineArray: Array<number> \| Uint16Array;` | 54 |
| `_frameArray` | propriedade | `protected _frameArray: Array<number> \| Int16Array;` | 55 |
| `_valueArray` | propriedade | `protected _valueArray: Array<number> \| Int16Array \| Float32Array;` | 56 |
| `_frameIndices` | propriedade | `protected _frameIndices: Array<number>;` | 57 |

#### ClassDeclaration `TweenTimelineState`

Herança: extends TimelineState.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `_getEasingValue` | método | `private static _getEasingValue(tweenType: TweenType, progress: number, easing: number): number` | 233 |
| `_getEasingCurveValue` | método | `private static _getEasingCurveValue(progress: number, samples: Array<number> \| Int16Array, count: number, offset: number): number` | 253 |
| `_onClear` | método | `protected _onClear(): void` | 287 |
| `_onArriveAtFrame` | método | `protected _onArriveAtFrame(): void` | 299 |
| `_onUpdateFrame` | método | `protected _onUpdateFrame(): void` | 346 |
| `_tweenType` | propriedade | `protected _tweenType: TweenType;` | 279 |
| `_curveCount` | propriedade | `protected _curveCount: number;` | 280 |
| `_framePosition` | propriedade | `protected _framePosition: number;` | 281 |
| `_frameDurationR` | propriedade | `protected _frameDurationR: number;` | 282 |
| `_tweenEasing` | propriedade | `protected _tweenEasing: number;` | 283 |
| `_tweenProgress` | propriedade | `protected _tweenProgress: number;` | 284 |
| `_valueScale` | propriedade | `protected _valueScale: number;` | 285 |

#### ClassDeclaration `SingleValueTimelineState`

Herança: extends TweenTimelineState.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `_onClear` | método | `protected _onClear(): void` | 368 |
| `_onArriveAtFrame` | método | `protected _onArriveAtFrame(): void` | 376 |
| `_onUpdateFrame` | método | `protected _onUpdateFrame(): void` | 408 |
| `_current` | propriedade | `protected _current: number;` | 364 |
| `_difference` | propriedade | `protected _difference: number;` | 365 |
| `_result` | propriedade | `protected _result: number;` | 366 |

#### ClassDeclaration `DoubleValueTimelineState`

Herança: extends TweenTimelineState.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `_onClear` | método | `protected _onClear(): void` | 427 |
| `_onArriveAtFrame` | método | `protected _onArriveAtFrame(): void` | 438 |
| `_onUpdateFrame` | método | `protected _onUpdateFrame(): void` | 476 |
| `_currentA` | propriedade | `protected _currentA: number;` | 420 |
| `_currentB` | propriedade | `protected _currentB: number;` | 421 |
| `_differenceA` | propriedade | `protected _differenceA: number;` | 422 |
| `_differenceB` | propriedade | `protected _differenceB: number;` | 423 |
| `_resultA` | propriedade | `protected _resultA: number;` | 424 |
| `_resultB` | propriedade | `protected _resultB: number;` | 425 |

#### ClassDeclaration `MutilpleValueTimelineState`

Herança: extends TweenTimelineState.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `_onClear` | método | `protected _onClear(): void` | 492 |
| `_onArriveAtFrame` | método | `protected _onArriveAtFrame(): void` | 499 |
| `_onUpdateFrame` | método | `protected _onUpdateFrame(): void` | 545 |
| `_valueCount` | propriedade | `protected _valueCount: number;` | 489 |
| `_rd` | propriedade | `protected readonly _rd: Array<number> = [];` | 490 |

### `DragonBones/src/dragonBones/animation/IAnimatable.ts`

- Origem/commit: `DragonBones/src/dragonBones/animation/IAnimatable.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: dragonbones/animation/IAnimatable.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/animation/WorldClock.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### InterfaceDeclaration `IAnimatable`

Herança: nenhuma explícita.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `advanceTime` | método | `advanceTime(passedTime: number): void;` | 53 |
| `clock` | propriedade | `clock: WorldClock \| null;` | 74 |

### `DragonBones/src/dragonBones/animation/TimelineState.ts`

- Origem/commit: `DragonBones/src/dragonBones/animation/TimelineState.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: dragonbones/animation/TimelineState.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/animation/AnimationState.ts`, `DragonBones/src/dragonBones/animation/BaseTimelineState.ts`, `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/armature/Bone.ts`, `DragonBones/src/dragonBones/armature/Constraint.ts`, `DragonBones/src/dragonBones/armature/Slot.ts`, `DragonBones/src/dragonBones/armature/Surface.ts`, `DragonBones/src/dragonBones/armature/TransformObject.ts`, `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/event/EventObject.ts`, `DragonBones/src/dragonBones/geom/Transform.ts`, `DragonBones/src/dragonBones/model/AnimationData.ts`, `DragonBones/src/dragonBones/model/ConstraintData.ts`, `Phaser/3.x/src/dragonBones/phaser/display/Slot.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `ActionTimelineState`

Herança: extends TimelineState.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 28 |
| `_onCrossFrame` | método | `private _onCrossFrame(frameIndex: number): void` | 32 |
| `_onArriveAtFrame` | método | `protected _onArriveAtFrame(): void` | 66 |
| `_onUpdateFrame` | método | `protected _onUpdateFrame(): void` | 67 |
| `update` | método | `public update(passedTime: number): void` | 69 |
| `setCurrentTime` | método | `public setCurrentTime(value: number): void` | 261 |

#### ClassDeclaration `ZOrderTimelineState`

Herança: extends TimelineState.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 270 |
| `_onArriveAtFrame` | método | `protected _onArriveAtFrame(): void` | 274 |
| `_onUpdateFrame` | método | `protected _onUpdateFrame(): void` | 286 |

#### ClassDeclaration `BoneAllTimelineState`

Herança: extends MutilpleValueTimelineState.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 292 |
| `_onArriveAtFrame` | método | `protected _onArriveAtFrame(): void` | 296 |
| `init` | método | `public init(armature: Armature, animationState: AnimationState, timelineData: TimelineData \| null): void` | 310 |
| `fadeOut` | método | `public fadeOut(): void` | 318 |
| `blend` | método | `public blend(isDirty: boolean): void` | 324 |

#### ClassDeclaration `BoneTranslateTimelineState`

Herança: extends DoubleValueTimelineState.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 360 |
| `init` | método | `public init(armature: Armature, animationState: AnimationState, timelineData: TimelineData \| null): void` | 364 |
| `blend` | método | `public blend(isDirty: boolean): void` | 372 |

#### ClassDeclaration `BoneRotateTimelineState`

Herança: extends DoubleValueTimelineState.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 401 |
| `_onArriveAtFrame` | método | `protected _onArriveAtFrame(): void` | 405 |
| `init` | método | `public init(armature: Armature, animationState: AnimationState, timelineData: TimelineData \| null): void` | 414 |
| `fadeOut` | método | `public fadeOut(): void` | 421 |
| `blend` | método | `public blend(isDirty: boolean): void` | 427 |

#### ClassDeclaration `BoneScaleTimelineState`

Herança: extends DoubleValueTimelineState.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 456 |
| `_onArriveAtFrame` | método | `protected _onArriveAtFrame(): void` | 460 |
| `init` | método | `public init(armature: Armature, animationState: AnimationState, timelineData: TimelineData \| null): void` | 469 |
| `blend` | método | `public blend(isDirty: boolean): void` | 476 |

#### ClassDeclaration `SurfaceTimelineState`

Herança: extends MutilpleValueTimelineState.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 505 |
| `_onClear` | método | `protected _onClear(): void` | 513 |
| `init` | método | `public init(armature: Armature, animationState: AnimationState, timelineData: TimelineData \| null): void` | 521 |
| `blend` | método | `public blend(isDirty: boolean): void` | 542 |
| `_deformCount` | propriedade | `private _deformCount: number;` | 509 |
| `_deformOffset` | propriedade | `private _deformOffset: number;` | 510 |
| `_sameValueOffset` | propriedade | `private _sameValueOffset: number;` | 511 |

#### ClassDeclaration `AlphaTimelineState`

Herança: extends SingleValueTimelineState.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 592 |
| `_onArriveAtFrame` | método | `protected _onArriveAtFrame(): void` | 596 |
| `init` | método | `public init(armature: Armature, animationState: AnimationState, timelineData: TimelineData \| null): void` | 604 |
| `blend` | método | `public blend(isDirty: boolean): void` | 612 |

#### ClassDeclaration `SlotDisplayTimelineState`

Herança: extends TimelineState.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 637 |
| `_onArriveAtFrame` | método | `protected _onArriveAtFrame(): void` | 641 |
| `_onUpdateFrame` | método | `protected _onUpdateFrame(): void` | 652 |

#### ClassDeclaration `SlotColorTimelineState`

Herança: extends TweenTimelineState.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 659 |
| `_onArriveAtFrame` | método | `protected _onArriveAtFrame(): void` | 667 |
| `_onUpdateFrame` | método | `protected _onUpdateFrame(): void` | 736 |
| `fadeOut` | método | `public fadeOut(): void` | 751 |
| `update` | método | `public update(passedTime: number): void` | 755 |
| `_current` | propriedade | `private readonly _current: Array<number> = [0, 0, 0, 0, 0, 0, 0, 0];` | 663 |
| `_difference` | propriedade | `private readonly _difference: Array<number> = [0, 0, 0, 0, 0, 0, 0, 0];` | 664 |
| `_result` | propriedade | `private readonly _result: Array<number> = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];` | 665 |

#### ClassDeclaration `SlotZIndexTimelineState`

Herança: extends SingleValueTimelineState.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 816 |
| `_onArriveAtFrame` | método | `protected _onArriveAtFrame(): void` | 820 |
| `init` | método | `public init(armature: Armature, animationState: AnimationState, timelineData: TimelineData \| null): void` | 830 |
| `blend` | método | `public blend(isDirty: boolean): void` | 837 |

#### ClassDeclaration `DeformTimelineState`

Herança: extends MutilpleValueTimelineState.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 859 |
| `_onClear` | método | `protected _onClear(): void` | 869 |
| `init` | método | `public init(armature: Armature, animationState: AnimationState, timelineData: TimelineData \| null): void` | 879 |
| `blend` | método | `public blend(isDirty: boolean): void` | 908 |
| `displayFrame` | propriedade | `public displayFrame: DisplayFrame;` | 863 |
| `_deformCount` | propriedade | `private _deformCount: number;` | 865 |
| `_deformOffset` | propriedade | `private _deformOffset: number;` | 866 |
| `_sameValueOffset` | propriedade | `private _sameValueOffset: number;` | 867 |

#### ClassDeclaration `IKConstraintTimelineState`

Herança: extends DoubleValueTimelineState.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 961 |
| `_onUpdateFrame` | método | `protected _onUpdateFrame(): void` | 965 |
| `init` | método | `public init(armature: Armature, animationState: AnimationState, timelineData: TimelineData \| null): void` | 984 |

#### ClassDeclaration `AnimationProgressTimelineState`

Herança: extends SingleValueTimelineState.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 996 |
| `_onUpdateFrame` | método | `protected _onUpdateFrame(): void` | 1000 |
| `init` | método | `public init(armature: Armature, animationState: AnimationState, timelineData: TimelineData \| null): void` | 1011 |

#### ClassDeclaration `AnimationWeightTimelineState`

Herança: extends SingleValueTimelineState.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 1023 |
| `_onUpdateFrame` | método | `protected _onUpdateFrame(): void` | 1027 |
| `init` | método | `public init(armature: Armature, animationState: AnimationState, timelineData: TimelineData \| null): void` | 1038 |

#### ClassDeclaration `AnimationParametersTimelineState`

Herança: extends DoubleValueTimelineState.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 1050 |
| `_onUpdateFrame` | método | `protected _onUpdateFrame(): void` | 1054 |
| `init` | método | `public init(armature: Armature, animationState: AnimationState, timelineData: TimelineData \| null): void` | 1066 |

### `DragonBones/src/dragonBones/animation/WorldClock.ts`

- Origem/commit: `DragonBones/src/dragonBones/animation/WorldClock.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: dragonbones/animation/WorldClock.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/animation/IAnimatable.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `WorldClock`

Herança: implements IAnimatable.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor(time: number = 0.0)` | 81 |
| `advanceTime` | método | `public advanceTime(passedTime: number): void` | 97 |
| `contains` | método | `public contains(value: IAnimatable): boolean` | 168 |
| `add` | método | `public add(value: IAnimatable): void` | 192 |
| `remove` | método | `public remove(value: IAnimatable): void` | 210 |
| `clear` | método | `public clear(): void` | 227 |
| `clock` | método | `public get clock(): WorldClock \| null` | 237 |
| `clock` | método | `public set clock(value: WorldClock \| null)` | 240 |
| `time` | propriedade | `public time: number = 0.0;` | 49 |
| `timeScale` | propriedade | `public timeScale: number = 1.0;` | 64 |
| `_systemTime` | propriedade | `private _systemTime: number = 0.0;` | 66 |
| `_animatebles` | propriedade | `private readonly _animatebles: Array<IAnimatable \| null> = [];` | 67 |
| `_clock` | propriedade | `private _clock: WorldClock \| null = null;` | 68 |

### `DragonBones/src/dragonBones/armature/Armature.ts`

- Origem/commit: `DragonBones/src/dragonBones/armature/Armature.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: dragonbones/armature/Armature.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/animation/Animation.ts`, `DragonBones/src/dragonBones/animation/IAnimatable.ts`, `DragonBones/src/dragonBones/animation/WorldClock.ts`, `DragonBones/src/dragonBones/armature/Bone.ts`, `DragonBones/src/dragonBones/armature/Constraint.ts`, `DragonBones/src/dragonBones/armature/IArmatureProxy.ts`, `DragonBones/src/dragonBones/armature/Slot.ts`, `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/event/EventObject.ts`, `DragonBones/src/dragonBones/event/IEventDispatcher.ts`, `DragonBones/src/dragonBones/model/ArmatureData.ts`, `DragonBones/src/dragonBones/model/TextureAtlasData.ts`, `Phaser/3.x/src/dragonBones/phaser/display/Slot.ts`, `Phaser/3.x/src/dragonBones/phaser/display/TextureAtlasData.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `Armature`

Herança: extends BaseObject; implements IAnimatable.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 43 |
| `_onSortSlots` | método | `private static _onSortSlots(a: Slot, b: Slot): number` | 46 |
| `_onClear` | método | `protected _onClear(): void` | 122 |
| `_sortZOrder` | método | `public _sortZOrder(slotIndices: Array<number> \| Int16Array \| null, offset: number): void` | 185 |
| `_addBone` | método | `public _addBone(value: Bone): void` | 211 |
| `_addSlot` | método | `public _addSlot(value: Slot): void` | 219 |
| `_addConstraint` | método | `public _addConstraint(value: Constraint): void` | 227 |
| `_bufferAction` | método | `public _bufferAction(action: EventObject, append: boolean): void` | 235 |
| `dispose` | método | `public dispose(): void` | 265 |
| `init` | método | `public init( armatureData: ArmatureData, proxy: IArmatureProxy, display: any, dragonBones: DragonBones ): void` | 274 |
| `advanceTime` | método | `public advanceTime(passedTime: number): void` | 295 |
| `invalidUpdate` | método | `public invalidUpdate(boneName: string \| null = null, updateSlot: boolean = false): void` | 406 |
| `containsPoint` | método | `public containsPoint(x: number, y: number): Slot \| null` | 451 |
| `intersectsSegment` | método | `public intersectsSegment( xA: number, yA: number, xB: number, yB: number, intersectionPointA: { x: number, y: number } \| null = null, intersectionPointB: { x: number, y: number } \| null = null, normalRadians: { x: number, y: number } \| null = null ): Slot \| null` | 490 |
| `getBone` | método | `public getBone(name: string): Bone \| null` | 589 |
| `getBoneByDisplay` | método | `public getBoneByDisplay(display: any): Bone \| null` | 612 |
| `getSlot` | método | `public getSlot(name: string): Slot \| null` | 631 |
| `getSlotByDisplay` | método | `public getSlotByDisplay(display: any): Slot \| null` | 654 |
| `getBones` | método | `public getBones(): Array<Bone>` | 677 |
| `getSlots` | método | `public getSlots(): Array<Slot>` | 692 |
| `flipX` | método | `public get flipX(): boolean` | 705 |
| `flipX` | método | `public set flipX(value: boolean)` | 708 |
| `flipY` | método | `public get flipY(): boolean` | 726 |
| `flipY` | método | `public set flipY(value: boolean)` | 729 |
| `cacheFrameRate` | método | `public get cacheFrameRate(): number` | 765 |
| `cacheFrameRate` | método | `public set cacheFrameRate(value: number)` | 768 |
| `name` | método | `public get name(): string` | 791 |
| `armatureData` | método | `public get armatureData(): ArmatureData` | 806 |
| `animation` | método | `public get animation(): Animation` | 821 |
| `proxy` | método | `public get proxy(): IArmatureProxy` | 827 |
| `eventDispatcher` | método | `public get eventDispatcher(): IEventDispatcher` | 840 |
| `display` | método | `public get display(): any` | 857 |
| `replacedTexture` | método | `public get replacedTexture(): any` | 863 |
| `replacedTexture` | método | `public set replacedTexture(value: any)` | 866 |
| `clock` | método | `public get clock(): WorldClock \| null` | 886 |
| `clock` | método | `public set clock(value: WorldClock \| null)` | 889 |
| `parent` | método | `public get parent(): Slot \| null` | 924 |
| `getDisplay` | método | `public getDisplay(): any` | 937 |
| `inheritAnimation` | propriedade | `public inheritAnimation: boolean;` | 63 |
| `userData` | propriedade | `public userData: any;` | 67 |
| `_lockUpdate` | propriedade | `public _lockUpdate: boolean;` | 71 |
| `_slotsDirty` | propriedade | `private _slotsDirty: boolean;` | 72 |
| `_zOrderDirty` | propriedade | `private _zOrderDirty: boolean;` | 73 |
| `_zIndexDirty` | propriedade | `public _zIndexDirty: boolean;` | 77 |
| `_alphaDirty` | propriedade | `public _alphaDirty: boolean;` | 81 |
| `_flipX` | propriedade | `private _flipX: boolean;` | 82 |
| `_flipY` | propriedade | `private _flipY: boolean;` | 83 |
| `_cacheFrameIndex` | propriedade | `public _cacheFrameIndex: number;` | 87 |
| `_alpha` | propriedade | `private _alpha: number;` | 88 |
| `_globalAlpha` | propriedade | `public _globalAlpha: number;` | 92 |
| `_bones` | propriedade | `private readonly _bones: Array<Bone> = [];` | 93 |
| `_slots` | propriedade | `private readonly _slots: Array<Slot> = [];` | 94 |
| `_constraints` | propriedade | `public readonly _constraints: Array<Constraint> = [];` | 98 |
| `_actions` | propriedade | `private readonly _actions: Array<EventObject> = [];` | 99 |
| `_armatureData` | propriedade | `public _armatureData: ArmatureData;` | 103 |
| `_animation` | propriedade | `private _animation: Animation = null as any;` | 104 |
| `_proxy` | propriedade | `private _proxy: IArmatureProxy = null as any;` | 105 |
| `_display` | propriedade | `private _display: any;` | 106 |
| `_replaceTextureAtlasData` | propriedade | `public _replaceTextureAtlasData: TextureAtlasData \| null = null;` | 110 |
| `_replacedTexture` | propriedade | `private _replacedTexture: any;` | 111 |
| `_dragonBones` | propriedade | `public _dragonBones: DragonBones;` | 115 |
| `_clock` | propriedade | `private _clock: WorldClock \| null = null;` | 116 |
| `_parent` | propriedade | `public _parent: Slot \| null;` | 120 |

### `DragonBones/src/dragonBones/armature/Bone.ts`

- Origem/commit: `DragonBones/src/dragonBones/armature/Bone.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: dragonbones/armature/Bone.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/armature/Surface.ts`, `DragonBones/src/dragonBones/armature/TransformObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/geom/Transform.ts`, `DragonBones/src/dragonBones/model/ArmatureData.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `Bone`

Herança: extends TransformObject.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 44 |
| `_onClear` | método | `protected _onClear(): void` | 92 |
| `_updateGlobalTransformMatrix` | método | `protected _updateGlobalTransformMatrix(isCache: boolean): void` | 109 |
| `_updateAlpha` | método | `public _updateAlpha()` | 334 |
| `init` | método | `public init(boneData: BoneData, armatureValue: Armature): void` | 345 |
| `update` | método | `public update(cacheFrameIndex: number): void` | 365 |
| `updateByConstraint` | método | `public updateByConstraint(): void` | 445 |
| `invalidUpdate` | método | `public invalidUpdate(): void` | 481 |
| `contains` | método | `public contains(value: Bone): boolean` | 496 |
| `boneData` | método | `public get boneData(): BoneData` | 518 |
| `visible` | método | `public get visible(): boolean` | 535 |
| `visible` | método | `public set visible(value: boolean)` | 538 |
| `name` | método | `public get name(): string` | 561 |
| `parent` | método | `public get parent(): Bone \| null` | 574 |
| `offsetMode` | propriedade | `public offsetMode: OffsetMode;` | 59 |
| `animationPose` | propriedade | `public readonly animationPose: Transform = new Transform();` | 63 |
| `_transformDirty` | propriedade | `public _transformDirty: boolean;` | 67 |
| `_childrenTransformDirty` | propriedade | `public _childrenTransformDirty: boolean;` | 71 |
| `_localDirty` | propriedade | `protected _localDirty: boolean;` | 72 |
| `_hasConstraint` | propriedade | `public _hasConstraint: boolean;` | 76 |
| `_visible` | propriedade | `protected _visible: boolean;` | 77 |
| `_cachedFrameIndex` | propriedade | `protected _cachedFrameIndex: number;` | 78 |
| `_boneData` | propriedade | `public _boneData: BoneData;` | 82 |
| `_parent` | propriedade | `protected _parent: Bone \| null;` | 86 |
| `_cachedFrameIndices` | propriedade | `public _cachedFrameIndices: Array<number> \| null;` | 90 |

### `DragonBones/src/dragonBones/armature/Constraint.ts`

- Origem/commit: `DragonBones/src/dragonBones/armature/Constraint.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: dragonbones/armature/Constraint.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/armature/Bone.ts`, `DragonBones/src/dragonBones/armature/Slot.ts`, `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/geom/Matrix.ts`, `DragonBones/src/dragonBones/geom/Point.ts`, `DragonBones/src/dragonBones/geom/Transform.ts`, `DragonBones/src/dragonBones/model/ConstraintData.ts`, `DragonBones/src/dragonBones/model/DisplayData.ts`, `Phaser/3.x/src/dragonBones/phaser/display/Slot.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `Constraint`

Herança: extends BaseObject.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `_onClear` | método | `protected _onClear(): void` | 49 |
| `init` | método | `public abstract init(constraintData: ConstraintData, armature: Armature): void;` | 56 |
| `update` | método | `public abstract update(): void;` | 57 |
| `invalidUpdate` | método | `public abstract invalidUpdate(): void;` | 58 |
| `name` | método | `public get name(): string` | 60 |
| `_helpMatrix` | propriedade | `protected static readonly _helpMatrix: Matrix = new Matrix();` | 28 |
| `_helpTransform` | propriedade | `protected static readonly _helpTransform: Transform = new Transform();` | 29 |
| `_helpPoint` | propriedade | `protected static readonly _helpPoint: Point = new Point();` | 30 |
| `_constraintData` | propriedade | `public _constraintData: ConstraintData;` | 35 |
| `_armature` | propriedade | `protected _armature: Armature;` | 36 |
| `_target` | propriedade | `public _target: Bone;` | 41 |
| `_root` | propriedade | `public _root: Bone;` | 46 |
| `_bone` | propriedade | `protected _bone: Bone \| null;` | 47 |

#### ClassDeclaration `IKConstraint`

Herança: extends Constraint.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 68 |
| `_onClear` | método | `protected _onClear(): void` | 84 |
| `_computeA` | método | `private _computeA(): void` | 93 |
| `_computeB` | método | `private _computeB(): void` | 107 |
| `init` | método | `public init(constraintData: ConstraintData, armature: Armature): void` | 185 |
| `update` | método | `public update(): void` | 206 |
| `invalidUpdate` | método | `public invalidUpdate(): void` | 218 |
| `_bendPositive` | propriedade | `public _bendPositive: boolean;` | 77 |
| `_weight` | propriedade | `public _weight: number;` | 82 |

#### ClassDeclaration `PathConstraint`

Herança: extends Constraint.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 251 |
| `_onClear` | método | `protected _onClear(): void` | 255 |
| `_updatePathVertices` | método | `protected _updatePathVertices(verticesData: GeometryData): void` | 278 |
| `_computeVertices` | método | `protected _computeVertices(start: number, count: number, offset: number, out: Array<number>): void` | 349 |
| `_computeBezierCurve` | método | `protected _computeBezierCurve(pathDisplayDta: PathDisplayData, spaceCount: number, tangents: boolean, percentPosition: boolean, percentSpacing: boolean): void` | 357 |
| `addCurvePosition` | método | `private addCurvePosition(t: number, x1: number, y1: number, cx1: number, cy1: number, cx2: number, cy2: number, x2: number, y2: number, out: Array<number>, offset: number, tangents: boolean)` | 599 |
| `init` | método | `public init(constraintData: ConstraintData, armature: Armature): void` | 636 |
| `update` | método | `public update(): void` | 670 |
| `invalidUpdate` | método | `public invalidUpdate(): void` | 831 |
| `dirty` | propriedade | `public dirty: boolean;` | 232 |
| `pathOffset` | propriedade | `public pathOffset: number;` | 233 |
| `position` | propriedade | `public position: number;` | 234 |
| `spacing` | propriedade | `public spacing: number;` | 235 |
| `rotateOffset` | propriedade | `public rotateOffset: number;` | 236 |
| `rotateMix` | propriedade | `public rotateMix: number;` | 237 |
| `translateMix` | propriedade | `public translateMix: number;` | 238 |
| `_pathSlot` | propriedade | `private _pathSlot: Slot;` | 240 |
| `_bones` | propriedade | `private _bones: Array<Bone> = [];` | 241 |
| `_spaces` | propriedade | `private _spaces: Array<number> = [];` | 243 |
| `_positions` | propriedade | `private _positions: Array<number> = [];` | 244 |
| `_curves` | propriedade | `private _curves: Array<number> = [];` | 245 |
| `_boneLengths` | propriedade | `private _boneLengths: Array<number> = [];` | 246 |
| `_pathGlobalVertices` | propriedade | `private _pathGlobalVertices: Array<number> = [];` | 248 |
| `_segments` | propriedade | `private _segments: Array<number> = [10];` | 249 |

### `DragonBones/src/dragonBones/armature/IArmatureProxy.ts`

- Origem/commit: `DragonBones/src/dragonBones/armature/IArmatureProxy.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: dragonbones/armature/IArmatureProxy.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/animation/Animation.ts`, `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/event/IEventDispatcher.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### InterfaceDeclaration `IArmatureProxy`

Herança: extends IEventDispatcher.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `dbInit` | método | `dbInit(armature: Armature): void;` | 40 |
| `dbClear` | método | `dbClear(): void;` | 44 |
| `dbUpdate` | método | `dbUpdate(): void;` | 48 |
| `dispose` | método | `dispose(disposeProxy: boolean): void;` | 69 |
| `armature` | propriedade | `readonly armature: Armature;` | 80 |
| `animation` | propriedade | `readonly animation: Animation;` | 91 |

### `DragonBones/src/dragonBones/armature/Slot.ts`

- Origem/commit: `DragonBones/src/dragonBones/armature/Slot.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: dragonbones/armature/Slot.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/Demos/assets/Script/BoundingBox.ts`, `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/armature/Bone.ts`, `DragonBones/src/dragonBones/armature/Surface.ts`, `DragonBones/src/dragonBones/armature/TransformObject.ts`, `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/event/EventObject.ts`, `DragonBones/src/dragonBones/geom/ColorTransform.ts`, `DragonBones/src/dragonBones/geom/Matrix.ts`, `DragonBones/src/dragonBones/model/ArmatureData.ts`, `DragonBones/src/dragonBones/model/BoundingBoxData.ts`, `DragonBones/src/dragonBones/model/DisplayData.ts`, `DragonBones/src/dragonBones/model/TextureAtlasData.ts`, `DragonBones/src/dragonBones/model/UserData.ts`, `Egret/Demos/src/demo/BoundingBox.ts`, `Phaser/3.x/src/dragonBones/phaser/display/Slot.ts`, `Phaser/3.x/src/dragonBones/phaser/display/TextureAtlasData.ts`, `Phaser/Demos/src/BoundingBox.ts`, `Pixi/Demos/4.x/src/BoundingBox.ts`, `Pixi/Demos/8.x/src/BoundingBox.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `DisplayFrame`

Herança: extends BaseObject.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 28 |
| `_onClear` | método | `protected _onClear(): void` | 38 |
| `updateDeformVertices` | método | `public updateDeformVertices(): void` | 46 |
| `getGeometryData` | método | `public getGeometryData(): GeometryData \| null` | 76 |
| `getBoundingBox` | método | `public getBoundingBox(): BoundingBoxData \| null` | 100 |
| `getTextureData` | método | `public getTextureData(): TextureData \| null` | 112 |
| `rawDisplayData` | propriedade | `public rawDisplayData: DisplayData \| null;` | 32 |
| `displayData` | propriedade | `public displayData: DisplayData \| null;` | 33 |
| `textureData` | propriedade | `public textureData: TextureData \| null;` | 34 |
| `display` | propriedade | `public display: any \| Armature \| null;` | 35 |
| `deformVertices` | propriedade | `public readonly deformVertices: Array<number> = [];` | 36 |

#### ClassDeclaration `Slot`

Herança: extends TransformObject.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `_onClear` | método | `protected _onClear(): void` | 261 |
| `_initDisplay` | método | `protected abstract _initDisplay(value: any, isRetain: boolean): void;` | 332 |
| `_disposeDisplay` | método | `protected abstract _disposeDisplay(value: any, isRelease: boolean): void;` | 333 |
| `_onUpdateDisplay` | método | `protected abstract _onUpdateDisplay(): void;` | 334 |
| `_addDisplay` | método | `protected abstract _addDisplay(): void;` | 335 |
| `_replaceDisplay` | método | `protected abstract _replaceDisplay(value: any): void;` | 336 |
| `_removeDisplay` | método | `protected abstract _removeDisplay(): void;` | 337 |
| `_updateZOrder` | método | `protected abstract _updateZOrder(): void;` | 338 |
| `_updateVisible` | método | `public abstract _updateVisible(): void;` | 342 |
| `_updateBlendMode` | método | `protected abstract _updateBlendMode(): void;` | 343 |
| `_updateColor` | método | `protected abstract _updateColor(): void;` | 344 |
| `_updateFrame` | método | `protected abstract _updateFrame(): void;` | 345 |
| `_updateMesh` | método | `protected abstract _updateMesh(): void;` | 346 |
| `_updateTransform` | método | `protected abstract _updateTransform(): void;` | 347 |
| `_identityTransform` | método | `protected abstract _identityTransform(): void;` | 348 |
| `_hasDisplay` | método | `protected _hasDisplay(display: any): boolean` | 350 |
| `_isBonesUpdate` | método | `public _isBonesUpdate(): boolean` | 362 |
| `_updateAlpha` | método | `public _updateAlpha()` | 374 |
| `_updateDisplayData` | método | `protected _updateDisplayData(): void` | 383 |
| `_updateDisplay` | método | `protected _updateDisplay(): void` | 503 |
| `_updateGlobalTransformMatrix` | método | `protected _updateGlobalTransformMatrix(isCache: boolean): void` | 583 |
| `_setDisplayIndex` | método | `public _setDisplayIndex(value: number, isAnimation: boolean = false): void` | 598 |
| `_setZOrder` | método | `public _setZOrder(value: number): boolean` | 618 |
| `_setColor` | método | `public _setColor(value: ColorTransform): boolean` | 631 |
| `init` | método | `public init(slotData: SlotData, armatureValue: Armature, rawDisplay: any, meshDisplay: any): void` | 639 |
| `update` | método | `public update(cacheFrameIndex: number): void` | 678 |
| `invalidUpdate` | método | `public invalidUpdate(): void` | 795 |
| `updateTransformAndMatrix` | método | `public updateTransformAndMatrix(): void` | 804 |
| `replaceRawDisplayData` | método | `public replaceRawDisplayData(displayData: DisplayData \| null, index: number = -1): void` | 813 |
| `replaceDisplayData` | método | `public replaceDisplayData(displayData: DisplayData \| null, index: number = -1): void` | 843 |
| `replaceTextureData` | método | `public replaceTextureData(textureData: TextureData \| null, index: number = -1): void` | 863 |
| `replaceDisplay` | método | `public replaceDisplay(value: any \| Armature \| null, index: number = -1): void` | 883 |
| `containsPoint` | método | `public containsPoint(x: number, y: number): boolean` | 941 |
| `intersectsSegment` | método | `public intersectsSegment( xA: number, yA: number, xB: number, yB: number, intersectionPointA: { x: number, y: number } \| null = null, intersectionPointB: { x: number, y: number } \| null = null, normalRadians: { x: number, y: number } \| null = null ): number` | 984 |
| `getDisplayFrameAt` | método | `public getDisplayFrameAt(index: number): DisplayFrame` | 1042 |
| `visible` | método | `public get visible(): boolean` | 1057 |
| `visible` | método | `public set visible(value: boolean)` | 1060 |
| `displayFrameCount` | método | `public get displayFrameCount(): number` | 1071 |
| `displayFrameCount` | método | `public set displayFrameCount(value: number)` | 1074 |
| `displayIndex` | método | `public get displayIndex(): number` | 1114 |
| `displayIndex` | método | `public set displayIndex(value: number)` | 1117 |
| `name` | método | `public get name(): string` | 1133 |
| `displayList` | método | `public get displayList(): Array<any>` | 1146 |
| `displayList` | método | `public set displayList(value: Array<any>)` | 1154 |
| `slotData` | método | `public get slotData(): SlotData` | 1173 |
| `boundingBoxData` | método | `public get boundingBoxData(): BoundingBoxData \| null` | 1186 |
| `rawDisplay` | método | `public get rawDisplay(): any` | 1192 |
| `meshDisplay` | método | `public get meshDisplay(): any` | 1198 |
| `display` | método | `public get display(): any` | 1221 |
| `display` | método | `public set display(value: any)` | 1224 |
| `childArmature` | método | `public get childArmature(): Armature \| null` | 1265 |
| `childArmature` | método | `public set childArmature(value: Armature \| null)` | 1268 |
| `parent` | método | `public get parent(): Bone` | 1285 |
| `getDisplay` | método | `public getDisplay(): any` | 1299 |
| `setDisplay` | método | `public setDisplay(value: any)` | 1312 |
| `displayController` | propriedade | `public displayController: string \| null;` | 183 |
| `_displayDataDirty` | propriedade | `protected _displayDataDirty: boolean;` | 184 |
| `_displayDirty` | propriedade | `protected _displayDirty: boolean;` | 185 |
| `_geometryDirty` | propriedade | `protected _geometryDirty: boolean;` | 186 |
| `_textureDirty` | propriedade | `protected _textureDirty: boolean;` | 187 |
| `_visibleDirty` | propriedade | `protected _visibleDirty: boolean;` | 188 |
| `_blendModeDirty` | propriedade | `protected _blendModeDirty: boolean;` | 189 |
| `_zOrderDirty` | propriedade | `protected _zOrderDirty: boolean;` | 190 |
| `_colorDirty` | propriedade | `public _colorDirty: boolean;` | 194 |
| `_verticesDirty` | propriedade | `public _verticesDirty: boolean;` | 198 |
| `_transformDirty` | propriedade | `protected _transformDirty: boolean;` | 199 |
| `_visible` | propriedade | `protected _visible: boolean;` | 200 |
| `_blendMode` | propriedade | `protected _blendMode: BlendMode;` | 201 |
| `_displayIndex` | propriedade | `protected _displayIndex: number;` | 202 |
| `_animationDisplayIndex` | propriedade | `protected _animationDisplayIndex: number;` | 203 |
| `_cachedFrameIndex` | propriedade | `protected _cachedFrameIndex: number;` | 204 |
| `_zOrder` | propriedade | `public _zOrder: number;` | 208 |
| `_zIndex` | propriedade | `public _zIndex: number;` | 212 |
| `_pivotX` | propriedade | `public _pivotX: number;` | 216 |
| `_pivotY` | propriedade | `public _pivotY: number;` | 220 |
| `_localMatrix` | propriedade | `protected readonly _localMatrix: Matrix = new Matrix();` | 221 |
| `_colorTransform` | propriedade | `public readonly _colorTransform: ColorTransform = new ColorTransform();` | 225 |
| `_displayFrames` | propriedade | `public readonly _displayFrames: Array<DisplayFrame> = [];` | 229 |
| `_geometryBones` | propriedade | `public readonly _geometryBones: Array<Bone \| null> = [];` | 233 |
| `_slotData` | propriedade | `public _slotData: SlotData;` | 237 |
| `_displayFrame` | propriedade | `public _displayFrame: DisplayFrame \| null;` | 241 |
| `_geometryData` | propriedade | `public _geometryData: GeometryData \| null;` | 245 |
| `_boundingBoxData` | propriedade | `protected _boundingBoxData: BoundingBoxData \| null;` | 246 |
| `_textureData` | propriedade | `protected _textureData: TextureData \| null;` | 247 |
| `_rawDisplay` | propriedade | `protected _rawDisplay: any = null;` | 248 |
| `_meshDisplay` | propriedade | `protected _meshDisplay: any = null;` | 249 |
| `_display` | propriedade | `protected _display: any \| null = null;` | 250 |
| `_childArmature` | propriedade | `protected _childArmature: Armature \| null;` | 251 |
| `_parent` | propriedade | `protected _parent: Bone;` | 255 |
| `_cachedFrameIndices` | propriedade | `public _cachedFrameIndices: Array<number> \| null;` | 259 |

### `DragonBones/src/dragonBones/armature/Surface.ts`

- Origem/commit: `DragonBones/src/dragonBones/armature/Surface.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: dragonbones/armature/Surface.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/armature/Bone.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/geom/Matrix.ts`, `DragonBones/src/dragonBones/geom/Transform.ts`, `DragonBones/src/dragonBones/model/ArmatureData.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `Surface`

Herança: extends Bone.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 28 |
| `_onClear` | método | `protected _onClear(): void` | 51 |
| `_getAffineTransform` | método | `private _getAffineTransform( x: number, y: number, lX: number, lY: number, aX: number, aY: number, bX: number, bY: number, cX: number, cY: number, transform: Transform, matrix: Matrix, isDown: boolean ): void` | 66 |
| `_updateVertices` | método | `private _updateVertices(): void` | 90 |
| `_updateGlobalTransformMatrix` | método | `protected _updateGlobalTransformMatrix(isCache: boolean): void` | 133 |
| `_getGlobalTransformMatrix` | método | `public _getGlobalTransformMatrix(x: number, y: number): Matrix` | 165 |
| `init` | método | `public init(surfaceData: SurfaceData, armatureValue: Armature): void` | 442 |
| `update` | método | `public update(cacheFrameIndex: number): void` | 481 |
| `_dX` | propriedade | `private _dX: number;` | 32 |
| `_dY` | propriedade | `private _dY: number;` | 33 |
| `_k` | propriedade | `private _k: number;` | 34 |
| `_kX` | propriedade | `private _kX: number;` | 35 |
| `_kY` | propriedade | `private _kY: number;` | 36 |
| `_vertices` | propriedade | `public readonly _vertices: Array<number> = [];` | 38 |
| `_deformVertices` | propriedade | `public readonly _deformVertices: Array<number> = [];` | 39 |
| `_hullCache` | propriedade | `private readonly _hullCache: Array<number> = [];` | 43 |
| `_matrixCahce` | propriedade | `private readonly _matrixCahce: Array<number> = [];` | 47 |
| `_bone` | propriedade | `public _bone: Bone \| null;` | 49 |

### `DragonBones/src/dragonBones/armature/TransformObject.ts`

- Origem/commit: `DragonBones/src/dragonBones/armature/TransformObject.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: dragonbones/armature/TransformObject.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/geom/Matrix.ts`, `DragonBones/src/dragonBones/geom/Point.ts`, `DragonBones/src/dragonBones/geom/Transform.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `TransformObject`

Herança: extends BaseObject.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `_onClear` | método | `protected _onClear(): void` | 100 |
| `updateGlobalTransform` | método | `public updateGlobalTransform(): void` | 135 |
| `armature` | método | `public get armature(): Armature` | 151 |
| `_helpMatrix` | propriedade | `protected static readonly _helpMatrix: Matrix = new Matrix();` | 37 |
| `_helpTransform` | propriedade | `protected static readonly _helpTransform: Transform = new Transform();` | 38 |
| `_helpPoint` | propriedade | `protected static readonly _helpPoint: Point = new Point();` | 39 |
| `globalTransformMatrix` | propriedade | `public readonly globalTransformMatrix: Matrix = new Matrix();` | 50 |
| `global` | propriedade | `public readonly global: Transform = new Transform();` | 63 |
| `offset` | propriedade | `public readonly offset: Transform = new Transform();` | 76 |
| `origin` | propriedade | `public origin: Transform \| null;` | 80 |
| `userData` | propriedade | `public userData: any;` | 84 |
| `_globalDirty` | propriedade | `protected _globalDirty: boolean;` | 85 |
| `_alpha` | propriedade | `public _alpha: number;` | 89 |
| `_globalAlpha` | propriedade | `public _globalAlpha: number;` | 93 |
| `_armature` | propriedade | `public _armature: Armature;` | 97 |

### `DragonBones/src/dragonBones/core/BaseObject.ts`

- Origem/commit: `DragonBones/src/dragonBones/core/BaseObject.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: dragonbones/core/BaseObject.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/core/DragonBones.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `BaseObject`

Herança: nenhuma explícita.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `_returnObject` | método | `private static _returnObject(object: BaseObject): void` | 42 |
| `toString` | método | `public static toString(): string` | 59 |
| `setMaxCount` | método | `public static setMaxCount(objectConstructor: (typeof BaseObject) \| null, maxCount: number): void` | 76 |
| `clearPool` | método | `public static clearPool(objectConstructor: (typeof BaseObject) \| null = null): void` | 117 |
| `borrowObject` | método | `public static borrowObject<T extends BaseObject>(objectConstructor: { new(): T; }): T` | 144 |
| `_onClear` | método | `protected abstract _onClear(): void;` | 170 |
| `returnToPool` | método | `public returnToPool(): void` | 181 |
| `_hashCode` | propriedade | `private static _hashCode: number = 0;` | 37 |
| `_defaultMaxCount` | propriedade | `private static _defaultMaxCount: number = 3000;` | 38 |
| `_maxCountMap` | propriedade | `private static readonly _maxCountMap: Map<number> = {};` | 39 |
| `_poolsMap` | propriedade | `private static readonly _poolsMap: Map<Array<BaseObject>> = {};` | 40 |
| `hashCode` | propriedade | `public readonly hashCode: number = BaseObject._hashCode++;` | 167 |
| `_isInPool` | propriedade | `private _isInPool: boolean = false;` | 168 |

### `DragonBones/src/dragonBones/core/DragonBones.ts`

- Origem/commit: `DragonBones/src/dragonBones/core/DragonBones.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: dragonbones/core/DragonBones.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/Demos/assets/Script/BoundingBox.ts`, `DragonBones/src/dragonBones/animation/WorldClock.ts`, `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/armature/Bone.ts`, `DragonBones/src/dragonBones/armature/Constraint.ts`, `DragonBones/src/dragonBones/armature/Surface.ts`, `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/event/EventObject.ts`, `DragonBones/src/dragonBones/event/IEventDispatcher.ts`, `DragonBones/src/dragonBones/geom/Rectangle.ts`, `Egret/Demos/src/demo/BoundingBox.ts`, `Phaser/Demos/src/BoundingBox.ts`, `Pixi/Demos/4.x/src/BoundingBox.ts`, `Pixi/Demos/8.x/src/BoundingBox.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### EnumDeclaration `BinaryOffset`

Herança: nenhuma explícita.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `WeigthBoneCount` | propriedade | `WeigthBoneCount = 0` | 28 |
| `WeigthFloatOffset` | propriedade | `WeigthFloatOffset = 1` | 29 |
| `WeigthBoneIndices` | propriedade | `WeigthBoneIndices = 2` | 30 |
| `GeometryVertexCount` | propriedade | `GeometryVertexCount = 0` | 32 |
| `GeometryTriangleCount` | propriedade | `GeometryTriangleCount = 1` | 33 |
| `GeometryFloatOffset` | propriedade | `GeometryFloatOffset = 2` | 34 |
| `GeometryWeightOffset` | propriedade | `GeometryWeightOffset = 3` | 35 |
| `GeometryVertexIndices` | propriedade | `GeometryVertexIndices = 4` | 36 |
| `TimelineScale` | propriedade | `TimelineScale = 0` | 38 |
| `TimelineOffset` | propriedade | `TimelineOffset = 1` | 39 |
| `TimelineKeyFrameCount` | propriedade | `TimelineKeyFrameCount = 2` | 40 |
| `TimelineFrameValueCount` | propriedade | `TimelineFrameValueCount = 3` | 41 |
| `TimelineFrameValueOffset` | propriedade | `TimelineFrameValueOffset = 4` | 42 |
| `TimelineFrameOffset` | propriedade | `TimelineFrameOffset = 5` | 43 |
| `FramePosition` | propriedade | `FramePosition = 0` | 45 |
| `FrameTweenType` | propriedade | `FrameTweenType = 1` | 46 |
| `FrameTweenEasingOrCurveSampleCount` | propriedade | `FrameTweenEasingOrCurveSampleCount = 2` | 47 |
| `FrameCurveSamples` | propriedade | `FrameCurveSamples = 3` | 48 |
| `DeformVertexOffset` | propriedade | `DeformVertexOffset = 0` | 50 |
| `DeformCount` | propriedade | `DeformCount = 1` | 51 |
| `DeformValueCount` | propriedade | `DeformValueCount = 2` | 52 |
| `DeformValueOffset` | propriedade | `DeformValueOffset = 3` | 53 |
| `DeformFloatOffset` | propriedade | `DeformFloatOffset = 4` | 54 |

#### EnumDeclaration `ArmatureType`

Herança: nenhuma explícita.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `Armature` | propriedade | `Armature = 0` | 60 |
| `MovieClip` | propriedade | `MovieClip = 1` | 61 |
| `Stage` | propriedade | `Stage = 2` | 62 |

#### EnumDeclaration `BoneType`

Herança: nenhuma explícita.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `Bone` | propriedade | `Bone = 0` | 68 |
| `Surface` | propriedade | `Surface = 1` | 69 |

#### EnumDeclaration `DisplayType`

Herança: nenhuma explícita.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `Image` | propriedade | `Image = 0` | 75 |
| `Armature` | propriedade | `Armature = 1` | 76 |
| `Mesh` | propriedade | `Mesh = 2` | 77 |
| `BoundingBox` | propriedade | `BoundingBox = 3` | 78 |
| `Path` | propriedade | `Path = 4` | 79 |

#### EnumDeclaration `BoundingBoxType`

Herança: nenhuma explícita.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `Rectangle` | propriedade | `Rectangle = 0` | 92 |
| `Ellipse` | propriedade | `Ellipse = 1` | 93 |
| `Polygon` | propriedade | `Polygon = 2` | 94 |

#### EnumDeclaration `ActionType`

Herança: nenhuma explícita.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `Play` | propriedade | `Play = 0` | 100 |
| `Frame` | propriedade | `Frame = 10` | 101 |
| `Sound` | propriedade | `Sound = 11` | 102 |

#### EnumDeclaration `BlendMode`

Herança: nenhuma explícita.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `Normal` | propriedade | `Normal = 0` | 108 |
| `Add` | propriedade | `Add = 1` | 109 |
| `Alpha` | propriedade | `Alpha = 2` | 110 |
| `Darken` | propriedade | `Darken = 3` | 111 |
| `Difference` | propriedade | `Difference = 4` | 112 |
| `Erase` | propriedade | `Erase = 5` | 113 |
| `HardLight` | propriedade | `HardLight = 6` | 114 |
| `Invert` | propriedade | `Invert = 7` | 115 |
| `Layer` | propriedade | `Layer = 8` | 116 |
| `Lighten` | propriedade | `Lighten = 9` | 117 |
| `Multiply` | propriedade | `Multiply = 10` | 118 |
| `Overlay` | propriedade | `Overlay = 11` | 119 |
| `Screen` | propriedade | `Screen = 12` | 120 |
| `Subtract` | propriedade | `Subtract = 13` | 121 |

#### EnumDeclaration `TweenType`

Herança: nenhuma explícita.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `None` | propriedade | `None = 0` | 127 |
| `Line` | propriedade | `Line = 1` | 128 |
| `Curve` | propriedade | `Curve = 2` | 129 |
| `QuadIn` | propriedade | `QuadIn = 3` | 130 |
| `QuadOut` | propriedade | `QuadOut = 4` | 131 |
| `QuadInOut` | propriedade | `QuadInOut = 5` | 132 |

#### EnumDeclaration `TimelineType`

Herança: nenhuma explícita.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `Action` | propriedade | `Action = 0` | 138 |
| `ZOrder` | propriedade | `ZOrder = 1` | 139 |
| `BoneAll` | propriedade | `BoneAll = 10` | 141 |
| `BoneTranslate` | propriedade | `BoneTranslate = 11` | 142 |
| `BoneRotate` | propriedade | `BoneRotate = 12` | 143 |
| `BoneScale` | propriedade | `BoneScale = 13` | 144 |
| `Surface` | propriedade | `Surface = 50` | 146 |
| `BoneAlpha` | propriedade | `BoneAlpha = 60` | 147 |
| `SlotDisplay` | propriedade | `SlotDisplay = 20` | 149 |
| `SlotColor` | propriedade | `SlotColor = 21` | 150 |
| `SlotDeform` | propriedade | `SlotDeform = 22` | 151 |
| `SlotZIndex` | propriedade | `SlotZIndex = 23` | 152 |
| `SlotAlpha` | propriedade | `SlotAlpha = 24` | 153 |
| `IKConstraint` | propriedade | `IKConstraint = 30` | 155 |
| `AnimationProgress` | propriedade | `AnimationProgress = 40` | 157 |
| `AnimationWeight` | propriedade | `AnimationWeight = 41` | 158 |
| `AnimationParameter` | propriedade | `AnimationParameter = 42` | 159 |

#### EnumDeclaration `OffsetMode`

Herança: nenhuma explícita.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `None` | propriedade | `None` | 172 |
| `Additive` | propriedade | `Additive` | 173 |
| `Override` | propriedade | `Override` | 174 |

#### EnumDeclaration `AnimationFadeOutMode`

Herança: nenhuma explícita.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `SameLayer` | propriedade | `SameLayer = 1` | 195 |
| `SameGroup` | propriedade | `SameGroup = 2` | 204 |
| `SameLayerAndGroup` | propriedade | `SameLayerAndGroup = 3` | 213 |
| `All` | propriedade | `All = 4` | 222 |
| `Single` | propriedade | `Single = 5` | 231 |

#### EnumDeclaration `AnimationBlendType`

Herança: nenhuma explícita.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `None` | propriedade | `None` | 237 |
| `E1D` | propriedade | `E1D` | 238 |

#### EnumDeclaration `AnimationBlendMode`

Herança: nenhuma explícita.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `Additive` | propriedade | `Additive` | 244 |
| `Override` | propriedade | `Override` | 245 |

#### EnumDeclaration `ConstraintType`

Herança: nenhuma explícita.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `IK` | propriedade | `IK` | 251 |
| `Path` | propriedade | `Path` | 252 |

#### EnumDeclaration `PositionMode`

Herança: nenhuma explícita.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `Fixed` | propriedade | `Fixed` | 258 |
| `Percent` | propriedade | `Percent` | 259 |

#### EnumDeclaration `SpacingMode`

Herança: nenhuma explícita.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `Length` | propriedade | `Length` | 265 |
| `Fixed` | propriedade | `Fixed` | 266 |
| `Percent` | propriedade | `Percent` | 267 |

#### EnumDeclaration `RotateMode`

Herança: nenhuma explícita.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `Tangent` | propriedade | `Tangent` | 273 |
| `Chain` | propriedade | `Chain` | 274 |
| `ChainScale` | propriedade | `ChainScale` | 275 |

#### InterfaceDeclaration `Map`

Herança: nenhuma explícita.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | propriedade | `[key: string]: T;` | 281 |

#### ClassDeclaration `DragonBones`

Herança: nenhuma explícita.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor(eventManager: IEventDispatcher)` | 298 |
| `advanceTime` | método | `public advanceTime(passedTime: number): void` | 304 |
| `bufferEvent` | método | `public bufferEvent(value: EventObject): void` | 334 |
| `bufferObject` | método | `public bufferObject(object: BaseObject): void` | 340 |
| `clock` | método | `public get clock(): WorldClock` | 346 |
| `eventManager` | método | `public get eventManager(): IEventDispatcher` | 350 |
| `VERSION` | propriedade | `public static readonly VERSION: string = "5.7.000";` | 287 |
| `yDown` | propriedade | `public static yDown: boolean = true;` | 289 |
| `debug` | propriedade | `public static debug: boolean = false;` | 290 |
| `debugDraw` | propriedade | `public static debugDraw: boolean = false;` | 291 |
| `_clock` | propriedade | `private readonly _clock: WorldClock = new WorldClock();` | 293 |
| `_events` | propriedade | `private readonly _events: Array<EventObject> = [];` | 294 |
| `_objects` | propriedade | `private readonly _objects: Array<BaseObject> = [];` | 295 |
| `_eventManager` | propriedade | `private _eventManager: IEventDispatcher = null as any;` | 296 |

#### FunctionDeclaration `r`

Herança: nenhuma explícita.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `r` | método | `function r(this: any)` | 371 |

### `DragonBones/src/dragonBones/event/EventObject.ts`

- Origem/commit: `DragonBones/src/dragonBones/event/EventObject.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: dragonbones/event/EventObject.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/animation/AnimationState.ts`, `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/armature/Bone.ts`, `DragonBones/src/dragonBones/armature/Slot.ts`, `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/model/UserData.ts`, `Phaser/3.x/src/dragonBones/phaser/display/Slot.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `EventObject`

Herança: extends BaseObject.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `actionDataToInstance` | método | `public static actionDataToInstance(data: ActionData, instance: EventObject, armature: Armature): void` | 139 |
| `toString` | método | `public static toString(): string` | 161 |
| `_onClear` | método | `protected _onClear(): void` | 270 |
| `START` | propriedade | `public static readonly START: string = "start";` | 46 |
| `LOOP_COMPLETE` | propriedade | `public static readonly LOOP_COMPLETE: string = "loopComplete";` | 57 |
| `COMPLETE` | propriedade | `public static readonly COMPLETE: string = "complete";` | 68 |
| `FADE_IN` | propriedade | `public static readonly FADE_IN: string = "fadeIn";` | 79 |
| `FADE_IN_COMPLETE` | propriedade | `public static readonly FADE_IN_COMPLETE: string = "fadeInComplete";` | 90 |
| `FADE_OUT` | propriedade | `public static readonly FADE_OUT: string = "fadeOut";` | 101 |
| `FADE_OUT_COMPLETE` | propriedade | `public static readonly FADE_OUT_COMPLETE: string = "fadeOutComplete";` | 112 |
| `FRAME_EVENT` | propriedade | `public static readonly FRAME_EVENT: string = "frameEvent";` | 123 |
| `SOUND_EVENT` | propriedade | `public static readonly SOUND_EVENT: string = "soundEvent";` | 134 |
| `time` | propriedade | `public time: number;` | 174 |
| `type` | propriedade | `public type: EventStringType;` | 185 |
| `name` | propriedade | `public name: string;` | 196 |
| `armature` | propriedade | `public armature: Armature;` | 209 |
| `bone` | propriedade | `public bone: Bone \| null;` | 222 |
| `slot` | propriedade | `public slot: Slot \| null;` | 235 |
| `animationState` | propriedade | `public animationState: AnimationState;` | 248 |
| `actionData` | propriedade | `public actionData: ActionData \| null;` | 252 |
| `data` | propriedade | `public data: UserData \| null;` | 268 |

### `DragonBones/src/dragonBones/event/IEventDispatcher.ts`

- Origem/commit: `DragonBones/src/dragonBones/event/IEventDispatcher.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: dragonbones/event/IEventDispatcher.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/event/EventObject.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### InterfaceDeclaration `IEventDispatcher`

Herança: nenhuma explícita.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `hasDBEventListener` | método | `hasDBEventListener(type: EventStringType): boolean;` | 56 |
| `dispatchDBEvent` | método | `dispatchDBEvent(type: EventStringType, eventObject: EventObject): void;` | 73 |
| `addDBEventListener` | método | `addDBEventListener(type: EventStringType, listener: Function, thisObject: any): void;` | 90 |
| `removeDBEventListener` | método | `removeDBEventListener(type: EventStringType, listener: Function, thisObject: any): void;` | 107 |

### `DragonBones/src/dragonBones/factory/BaseFactory.ts`

- Origem/commit: `DragonBones/src/dragonBones/factory/BaseFactory.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: dragonbones/factory/BaseFactory.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/Demos/assets/Script/BoundingBox.ts`, `DragonBones/src/dragonBones/animation/WorldClock.ts`, `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/armature/Bone.ts`, `DragonBones/src/dragonBones/armature/Constraint.ts`, `DragonBones/src/dragonBones/armature/Slot.ts`, `DragonBones/src/dragonBones/armature/Surface.ts`, `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/event/EventObject.ts`, `DragonBones/src/dragonBones/model/AnimationData.ts`, `DragonBones/src/dragonBones/model/ArmatureData.ts`, `DragonBones/src/dragonBones/model/DisplayData.ts`, `DragonBones/src/dragonBones/model/DragonBonesData.ts`, `DragonBones/src/dragonBones/model/SkinData.ts`, `DragonBones/src/dragonBones/model/TextureAtlasData.ts`, `DragonBones/src/dragonBones/parser/BinaryDataParser.ts`, `DragonBones/src/dragonBones/parser/DataParser.ts`, `DragonBones/src/dragonBones/parser/ObjectDataParser.ts`, `Egret/Demos/src/demo/BoundingBox.ts`, `Phaser/3.x/src/dragonBones/phaser/display/Slot.ts`, `Phaser/3.x/src/dragonBones/phaser/display/TextureAtlasData.ts`, `Phaser/Demos/src/BoundingBox.ts`, `Pixi/Demos/4.x/src/BoundingBox.ts`, `Pixi/Demos/8.x/src/BoundingBox.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `BaseFactory`

Herança: nenhuma explícita.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor(dataParser: DataParser \| null = null)` | 68 |
| `_isSupportMesh` | método | `protected _isSupportMesh(): boolean` | 80 |
| `_getTextureData` | método | `protected _getTextureData(textureAtlasName: string, textureName: string): TextureData \| null` | 84 |
| `_fillBuildArmaturePackage` | método | `protected _fillBuildArmaturePackage( dataPackage: BuildArmaturePackage, dragonBonesName: string, armatureName: string, skinName: string, textureAtlasName: string ): boolean` | 110 |
| `_buildBones` | método | `protected _buildBones(dataPackage: BuildArmaturePackage, armature: Armature): void` | 168 |
| `_buildSlots` | método | `protected _buildSlots(dataPackage: BuildArmaturePackage, armature: Armature): void` | 177 |
| `_buildConstraints` | método | `protected _buildConstraints(dataPackage: BuildArmaturePackage, armature: Armature): void` | 226 |
| `_buildChildArmature` | método | `protected _buildChildArmature(dataPackage: BuildArmaturePackage \| null, _slot: Slot, displayData: ArmatureDisplayData): Armature \| null` | 254 |
| `_getSlotDisplay` | método | `protected _getSlotDisplay(dataPackage: BuildArmaturePackage \| null, displayData: DisplayData, slot: Slot): any` | 258 |
| `_buildTextureAtlasData` | método | `protected abstract _buildTextureAtlasData(textureAtlasData: TextureAtlasData \| null, textureAtlas: any): TextureAtlasData;` | 324 |
| `_buildArmature` | método | `protected abstract _buildArmature(dataPackage: BuildArmaturePackage): Armature;` | 325 |
| `_buildSlot` | método | `protected abstract _buildSlot(dataPackage: BuildArmaturePackage, slotData: SlotData, armature: Armature): Slot;` | 326 |
| `parseDragonBonesData` | método | `public parseDragonBonesData(rawData: any, name: string \| null = null, scale: number = 1.0): DragonBonesData \| null` | 353 |
| `parseTextureAtlasData` | método | `public parseTextureAtlasData(rawData: any, textureAtlas: any, name: string \| null = null, scale: number = 1.0): TextureAtlasData` | 402 |
| `updateTextureAtlases` | método | `public updateTextureAtlases(textureAtlases: Array<any>, name: string): void` | 424 |
| `getDragonBonesData` | método | `public getDragonBonesData(name: string): DragonBonesData \| null` | 456 |
| `addDragonBonesData` | método | `public addDragonBonesData(data: DragonBonesData, name: string \| null = null): void` | 481 |
| `removeDragonBonesData` | método | `public removeDragonBonesData(name: string, disposeData: boolean = true): void` | 516 |
| `getTextureAtlasData` | método | `public getTextureAtlasData(name: string): Array<TextureAtlasData> \| null` | 545 |
| `addTextureAtlasData` | método | `public addTextureAtlasData(data: TextureAtlasData, name: string \| null = null): void` | 570 |
| `removeTextureAtlasData` | método | `public removeTextureAtlasData(name: string, disposeData: boolean = true): void` | 599 |
| `getArmatureData` | método | `public getArmatureData(name: string, dragonBonesName: string = ""): ArmatureData \| null` | 627 |
| `clear` | método | `public clear(disposeData: boolean = true): void` | 647 |
| `buildArmature` | método | `public buildArmature(armatureName: string, dragonBonesName: string = "", skinName: string = "", textureAtlasName: string = ""): Armature \| null` | 701 |
| `replaceDisplay` | método | `public replaceDisplay(slot: Slot, displayData: DisplayData \| null, displayIndex: number = -1): void` | 720 |
| `replaceSlotDisplay` | método | `public replaceSlotDisplay( dragonBonesName: string, armatureName: string, slotName: string, displayName: string, slot: Slot, displayIndex: number = -1 ): boolean` | 783 |
| `replaceSlotDisplayList` | método | `public replaceSlotDisplayList( dragonBonesName: string \| null, armatureName: string, slotName: string, slot: Slot ): boolean` | 800 |
| `replaceSkin` | método | `public replaceSkin(armature: Armature, skin: SkinData, isOverride: boolean = false, exclude: Array<string> \| null = null): boolean` | 860 |
| `replaceAnimation` | método | `public replaceAnimation(armature: Armature, armatureData: ArmatureData, isOverride: boolean = true): boolean` | 939 |
| `getAllDragonBonesData` | método | `public getAllDragonBonesData(): Map<DragonBonesData>` | 988 |
| `getAllTextureAtlasData` | método | `public getAllTextureAtlasData(): Map<Array<TextureAtlasData>>` | 994 |
| `clock` | método | `public get clock(): WorldClock` | 1007 |
| `dragonBones` | método | `public get dragonBones(): DragonBones` | 1013 |
| `_objectParser` | propriedade | `protected static _objectParser: ObjectDataParser = null as any;` | 47 |
| `_binaryParser` | propriedade | `protected static _binaryParser: BinaryDataParser = null as any;` | 48 |
| `autoSearch` | propriedade | `public autoSearch: boolean = false;` | 52 |
| `_dragonBonesDataMap` | propriedade | `protected readonly _dragonBonesDataMap: Map<DragonBonesData> = {};` | 54 |
| `_textureAtlasDataMap` | propriedade | `protected readonly _textureAtlasDataMap: Map<Array<TextureAtlasData>> = {};` | 55 |
| `_dragonBones` | propriedade | `protected _dragonBones: DragonBones = null as any;` | 56 |
| `_dataParser` | propriedade | `protected _dataParser: DataParser = null as any;` | 57 |

#### ClassDeclaration `BuildArmaturePackage`

Herança: nenhuma explícita.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `dataName` | propriedade | `public dataName: string = "";` | 1021 |
| `textureAtlasName` | propriedade | `public textureAtlasName: string = "";` | 1022 |
| `data` | propriedade | `public data: DragonBonesData;` | 1023 |
| `armature` | propriedade | `public armature: ArmatureData;` | 1024 |
| `skin` | propriedade | `public skin: SkinData \| null = null;` | 1025 |

### `DragonBones/src/dragonBones/geom/ColorTransform.ts`

- Origem/commit: `DragonBones/src/dragonBones/geom/ColorTransform.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: dragonbones/geom/ColorTransform.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: nenhuma declaração autoral identificada.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `ColorTransform`

Herança: nenhuma explícita.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor( alphaMultiplier: number = 1.0, redMultiplier: number = 1.0, greenMultiplier: number = 1.0, blueMultiplier: number = 1.0, alphaOffset: number = 0, redOffset: number = 0, greenOffset: number = 0, blueOffset: number = 0 )` | 37 |
| `copyFrom` | método | `public copyFrom(value: ColorTransform): void` | 51 |
| `identity` | método | `public identity(): void` | 62 |
| `alphaMultiplier` | propriedade | `public alphaMultiplier: number;` | 28 |
| `redMultiplier` | propriedade | `public redMultiplier: number;` | 29 |
| `greenMultiplier` | propriedade | `public greenMultiplier: number;` | 30 |
| `blueMultiplier` | propriedade | `public blueMultiplier: number;` | 31 |
| `alphaOffset` | propriedade | `public alphaOffset: number;` | 32 |
| `redOffset` | propriedade | `public redOffset: number;` | 33 |
| `greenOffset` | propriedade | `public greenOffset: number;` | 34 |
| `blueOffset` | propriedade | `public blueOffset: number;` | 35 |

### `DragonBones/src/dragonBones/geom/Matrix.ts`

- Origem/commit: `DragonBones/src/dragonBones/geom/Matrix.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: dragonbones/geom/Matrix.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: nenhuma declaração autoral identificada.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `Matrix`

Herança: nenhuma explícita.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor( a: number = 1.0, b: number = 0.0, c: number = 0.0, d: number = 1.0, tx: number = 0.0, ty: number = 0.0 )` | 116 |
| `toString` | método | `public toString(): string` | 129 |
| `copyFrom` | método | `public copyFrom(value: Matrix): Matrix` | 135 |
| `copyFromArray` | método | `public copyFromArray(value: Array<number>, offset: number = 0): Matrix` | 148 |
| `identity` | método | `public identity(): Matrix` | 170 |
| `concat` | método | `public concat(value: Matrix): Matrix` | 189 |
| `invert` | método | `public invert(): Matrix` | 230 |
| `transformPoint` | método | `public transformPoint(x: number, y: number, result: { x: number, y: number }, delta: boolean = false): void` | 290 |
| `transformRectangle` | método | `public transformRectangle(rectangle: { x: number, y: number, width: number, height: number }, delta: boolean = false): void` | 302 |
| `a` | propriedade | `public a: number;` | 47 |
| `b` | propriedade | `public b: number;` | 60 |
| `c` | propriedade | `public c: number;` | 73 |
| `d` | propriedade | `public d: number;` | 86 |
| `tx` | propriedade | `public tx: number;` | 99 |
| `ty` | propriedade | `public ty: number;` | 112 |

### `DragonBones/src/dragonBones/geom/Point.ts`

- Origem/commit: `DragonBones/src/dragonBones/geom/Point.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: dragonbones/geom/Point.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: nenhuma declaração autoral identificada.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `Point`

Herança: nenhuma explícita.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor(x: number = 0.0, y: number = 0.0)` | 75 |
| `copyFrom` | método | `public copyFrom(value: Point): void` | 82 |
| `clear` | método | `public clear(): void` | 89 |
| `x` | propriedade | `public x: number;` | 47 |
| `y` | propriedade | `public y: number;` | 60 |

### `DragonBones/src/dragonBones/geom/Rectangle.ts`

- Origem/commit: `DragonBones/src/dragonBones/geom/Rectangle.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: dragonbones/geom/Rectangle.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: nenhuma declaração autoral identificada.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `Rectangle`

Herança: nenhuma explícita.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor( x: number = 0.0, y: number = 0.0, width: number = 0.0, height: number = 0.0 )` | 98 |
| `copyFrom` | método | `public copyFrom(value: Rectangle): void` | 110 |
| `clear` | método | `public clear(): void` | 119 |
| `x` | propriedade | `public x: number;` | 55 |
| `y` | propriedade | `public y: number;` | 68 |
| `width` | propriedade | `public width: number;` | 81 |
| `height` | propriedade | `public height: number;` | 94 |

### `DragonBones/src/dragonBones/geom/Transform.ts`

- Origem/commit: `DragonBones/src/dragonBones/geom/Transform.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: dragonbones/geom/Transform.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/geom/Matrix.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `Transform`

Herança: nenhuma explícita.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `normalizeRadian` | método | `public static normalizeRadian(value: number): number` | 62 |
| `constructor` | método | `public constructor(x: number = 0.0, y: number = 0.0, skew: number = 0.0, rotation: number = 0.0, scaleX: number = 1.0, scaleY: number = 1.0)` | 137 |
| `toString` | método | `public toString(): string` | 146 |
| `copyFrom` | método | `public copyFrom(value: Transform): Transform` | 152 |
| `identity` | método | `public identity(): Transform` | 165 |
| `add` | método | `public add(value: Transform): Transform` | 175 |
| `minus` | método | `public minus(value: Transform): Transform` | 188 |
| `fromMatrix` | método | `public fromMatrix(matrix: Matrix): Transform` | 201 |
| `toMatrix` | método | `public toMatrix(matrix: Matrix): Transform` | 230 |
| `PI` | propriedade | `public static readonly PI: number = Math.PI;` | 38 |
| `PI_D` | propriedade | `public static readonly PI_D: number = Math.PI * 2.0;` | 42 |
| `PI_H` | propriedade | `public static readonly PI_H: number = Math.PI / 2.0;` | 46 |
| `PI_Q` | propriedade | `public static readonly PI_Q: number = Math.PI / 4.0;` | 50 |
| `RAD_DEG` | propriedade | `public static readonly RAD_DEG: number = 180.0 / Math.PI;` | 54 |
| `DEG_RAD` | propriedade | `public static readonly DEG_RAD: number = Math.PI / 180.0;` | 58 |
| `x` | propriedade | `public x: number;` | 78 |
| `y` | propriedade | `public y: number;` | 89 |
| `skew` | propriedade | `public skew: number;` | 100 |
| `rotation` | propriedade | `public rotation: number;` | 111 |
| `scaleX` | propriedade | `public scaleX: number;` | 122 |
| `scaleY` | propriedade | `public scaleY: number;` | 133 |

### `DragonBones/src/dragonBones/model/AnimationConfig.ts`

- Origem/commit: `DragonBones/src/dragonBones/model/AnimationConfig.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: dragonbones/model/AnimationConfig.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `AnimationConfig`

Herança: extends BaseObject.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 41 |
| `_onClear` | método | `protected _onClear(): void` | 277 |
| `clear` | método | `public clear(): void` | 305 |
| `copyFrom` | método | `public copyFrom(value: AnimationConfig): void` | 311 |
| `pauseFadeOut` | propriedade | `public pauseFadeOut: boolean;` | 47 |
| `fadeOutMode` | propriedade | `public fadeOutMode: AnimationFadeOutMode;` | 62 |
| `fadeOutTweenType` | propriedade | `public fadeOutTweenType: TweenType;` | 66 |
| `fadeOutTime` | propriedade | `public fadeOutTime: number;` | 70 |
| `pauseFadeIn` | propriedade | `public pauseFadeIn: boolean;` | 74 |
| `actionEnabled` | propriedade | `public actionEnabled: boolean;` | 78 |
| `additive` | propriedade | `public additive: boolean;` | 82 |
| `displayControl` | propriedade | `public displayControl: boolean;` | 99 |
| `resetToPose` | propriedade | `public resetToPose: boolean;` | 114 |
| `fadeInTweenType` | propriedade | `public fadeInTweenType: TweenType;` | 118 |
| `playTimes` | propriedade | `public playTimes: number;` | 129 |
| `layer` | propriedade | `public layer: number;` | 146 |
| `position` | propriedade | `public position: number;` | 159 |
| `duration` | propriedade | `public duration: number;` | 174 |
| `timeScale` | propriedade | `public timeScale: number;` | 191 |
| `weight` | propriedade | `public weight: number;` | 204 |
| `fadeInTime` | propriedade | `public fadeInTime: number;` | 219 |
| `autoFadeOutTime` | propriedade | `public autoFadeOutTime: number;` | 234 |
| `name` | propriedade | `public name: string;` | 245 |
| `animation` | propriedade | `public animation: string;` | 256 |
| `group` | propriedade | `public group: string;` | 271 |
| `boneMask` | propriedade | `public readonly boneMask: Array<string> = [];` | 275 |

### `DragonBones/src/dragonBones/model/AnimationData.ts`

- Origem/commit: `DragonBones/src/dragonBones/model/AnimationData.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: dragonbones/model/AnimationData.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/model/ArmatureData.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `AnimationData`

Herança: extends BaseObject.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 35 |
| `_onClear` | método | `protected _onClear(): void` | 161 |
| `cacheFrames` | método | `public cacheFrames(frameRate: number): void` | 235 |
| `addBoneTimeline` | método | `public addBoneTimeline(timelineName: string, timeline: TimelineData): void` | 269 |
| `addSlotTimeline` | método | `public addSlotTimeline(timelineName: string, timeline: TimelineData): void` | 278 |
| `addConstraintTimeline` | método | `public addConstraintTimeline(timelineName: string, timeline: TimelineData): void` | 287 |
| `addAnimationTimeline` | método | `public addAnimationTimeline(timelineName: string, timeline: TimelineData): void` | 296 |
| `getBoneTimelines` | método | `public getBoneTimelines(timelineName: string): Array<TimelineData> \| null` | 305 |
| `getSlotTimelines` | método | `public getSlotTimelines(timelineName: string): Array<TimelineData> \| null` | 311 |
| `getConstraintTimelines` | método | `public getConstraintTimelines(timelineName: string): Array<TimelineData> \| null` | 317 |
| `getAnimationTimelines` | método | `public getAnimationTimelines(timelineName: string): Array<TimelineData> \| null` | 323 |
| `getBoneCachedFrameIndices` | método | `public getBoneCachedFrameIndices(boneName: string): Array<number> \| null` | 329 |
| `getSlotCachedFrameIndices` | método | `public getSlotCachedFrameIndices(slotName: string): Array<number> \| null` | 335 |
| `frameIntOffset` | propriedade | `public frameIntOffset: number;` | 42 |
| `frameFloatOffset` | propriedade | `public frameFloatOffset: number;` | 47 |
| `frameOffset` | propriedade | `public frameOffset: number;` | 52 |
| `blendType` | propriedade | `public blendType: AnimationBlendType;` | 56 |
| `frameCount` | propriedade | `public frameCount: number;` | 67 |
| `playTimes` | propriedade | `public playTimes: number;` | 78 |
| `duration` | propriedade | `public duration: number;` | 89 |
| `scale` | propriedade | `public scale: number;` | 93 |
| `fadeInTime` | propriedade | `public fadeInTime: number;` | 104 |
| `cacheFrameRate` | propriedade | `public cacheFrameRate: number;` | 108 |
| `name` | propriedade | `public name: string;` | 119 |
| `cachedFrames` | propriedade | `public readonly cachedFrames: Array<boolean> = [];` | 123 |
| `boneTimelines` | propriedade | `public readonly boneTimelines: Map<Array<TimelineData>> = {};` | 127 |
| `slotTimelines` | propriedade | `public readonly slotTimelines: Map<Array<TimelineData>> = {};` | 131 |
| `constraintTimelines` | propriedade | `public readonly constraintTimelines: Map<Array<TimelineData>> = {};` | 135 |
| `animationTimelines` | propriedade | `public readonly animationTimelines: Map<Array<TimelineData>> = {};` | 139 |
| `boneCachedFrameIndices` | propriedade | `public readonly boneCachedFrameIndices: Map<Array<number>> = {};` | 143 |
| `slotCachedFrameIndices` | propriedade | `public readonly slotCachedFrameIndices: Map<Array<number>> = {};` | 147 |
| `actionTimeline` | propriedade | `public actionTimeline: TimelineData \| null = null;` | 151 |
| `zOrderTimeline` | propriedade | `public zOrderTimeline: TimelineData \| null = null;` | 155 |
| `parent` | propriedade | `public parent: ArmatureData;` | 159 |

#### ClassDeclaration `TimelineData`

Herança: extends BaseObject.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 343 |
| `_onClear` | método | `protected _onClear(): void` | 351 |
| `type` | propriedade | `public type: TimelineType;` | 347 |
| `offset` | propriedade | `public offset: number;` | 348 |
| `frameIndicesOffset` | propriedade | `public frameIndicesOffset: number;` | 349 |

#### ClassDeclaration `AnimationTimelineData`

Herança: extends TimelineData.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 361 |
| `_onClear` | método | `protected _onClear(): void` | 368 |
| `x` | propriedade | `public x: number;` | 365 |
| `y` | propriedade | `public y: number;` | 366 |

### `DragonBones/src/dragonBones/model/ArmatureData.ts`

- Origem/commit: `DragonBones/src/dragonBones/model/ArmatureData.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: dragonbones/model/ArmatureData.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/armature/Bone.ts`, `DragonBones/src/dragonBones/armature/Surface.ts`, `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/geom/ColorTransform.ts`, `DragonBones/src/dragonBones/geom/Matrix.ts`, `DragonBones/src/dragonBones/geom/Rectangle.ts`, `DragonBones/src/dragonBones/geom/Transform.ts`, `DragonBones/src/dragonBones/model/AnimationData.ts`, `DragonBones/src/dragonBones/model/CanvasData.ts`, `DragonBones/src/dragonBones/model/ConstraintData.ts`, `DragonBones/src/dragonBones/model/DisplayData.ts`, `DragonBones/src/dragonBones/model/DragonBonesData.ts`, `DragonBones/src/dragonBones/model/SkinData.ts`, `DragonBones/src/dragonBones/model/UserData.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `ArmatureData`

Herança: extends BaseObject.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 35 |
| `_onClear` | método | `protected _onClear(): void` | 158 |
| `sortBones` | método | `public sortBones(): void` | 225 |
| `cacheFrames` | método | `public cacheFrames(frameRate: number): void` | 269 |
| `setCacheFrame` | método | `public setCacheFrame(globalTransformMatrix: Matrix, transform: Transform): number` | 282 |
| `getCacheFrame` | método | `public getCacheFrame(globalTransformMatrix: Matrix, transform: Transform, arrayOffset: number): void` | 303 |
| `addBone` | método | `public addBone(value: BoneData): void` | 321 |
| `addSlot` | método | `public addSlot(value: SlotData): void` | 333 |
| `addConstraint` | método | `public addConstraint(value: ConstraintData): void` | 345 |
| `addSkin` | método | `public addSkin(value: SkinData): void` | 356 |
| `addAnimation` | método | `public addAnimation(value: AnimationData): void` | 375 |
| `addAction` | método | `public addAction(value: ActionData, isDefault: boolean): void` | 391 |
| `getBone` | método | `public getBone(boneName: string): BoneData \| null` | 411 |
| `getSlot` | método | `public getSlot(slotName: string): SlotData \| null` | 426 |
| `getConstraint` | método | `public getConstraint(constraintName: string): ConstraintData \| null` | 432 |
| `getSkin` | método | `public getSkin(skinName: string): SkinData \| null` | 447 |
| `getMesh` | método | `public getMesh(skinName: string, slotName: string, meshName: string): MeshDisplayData \| null` | 453 |
| `getAnimation` | método | `public getAnimation(animationName: string): AnimationData \| null` | 473 |
| `type` | propriedade | `public type: ArmatureType;` | 41 |
| `frameRate` | propriedade | `public frameRate: number;` | 52 |
| `cacheFrameRate` | propriedade | `public cacheFrameRate: number;` | 56 |
| `scale` | propriedade | `public scale: number;` | 60 |
| `name` | propriedade | `public name: string;` | 71 |
| `aabb` | propriedade | `public readonly aabb: Rectangle = new Rectangle();` | 75 |
| `animationNames` | propriedade | `public readonly animationNames: Array<string> = [];` | 86 |
| `sortedBones` | propriedade | `public readonly sortedBones: Array<BoneData> = [];` | 90 |
| `sortedSlots` | propriedade | `public readonly sortedSlots: Array<SlotData> = [];` | 94 |
| `defaultActions` | propriedade | `public readonly defaultActions: Array<ActionData> = [];` | 98 |
| `actions` | propriedade | `public readonly actions: Array<ActionData> = [];` | 102 |
| `bones` | propriedade | `public readonly bones: Map<BoneData> = {};` | 106 |
| `slots` | propriedade | `public readonly slots: Map<SlotData> = {};` | 110 |
| `constraints` | propriedade | `public readonly constraints: Map<ConstraintData> = {};` | 114 |
| `skins` | propriedade | `public readonly skins: Map<SkinData> = {};` | 118 |
| `animations` | propriedade | `public readonly animations: Map<AnimationData> = {};` | 122 |
| `defaultSkin` | propriedade | `public defaultSkin: SkinData \| null;` | 133 |
| `defaultAnimation` | propriedade | `public defaultAnimation: AnimationData \| null;` | 144 |
| `canvas` | propriedade | `public canvas: CanvasData \| null = null;` | 148 |
| `userData` | propriedade | `public userData: UserData \| null = null;` | 152 |
| `parent` | propriedade | `public parent: DragonBonesData;` | 156 |

#### ClassDeclaration `BoneData`

Herança: extends BaseObject.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 488 |
| `_onClear` | método | `protected _onClear(): void` | 557 |
| `inheritTranslation` | propriedade | `public inheritTranslation: boolean;` | 494 |
| `inheritRotation` | propriedade | `public inheritRotation: boolean;` | 498 |
| `inheritScale` | propriedade | `public inheritScale: boolean;` | 502 |
| `inheritReflection` | propriedade | `public inheritReflection: boolean;` | 506 |
| `type` | propriedade | `public type: BoneType;` | 510 |
| `length` | propriedade | `public length: number;` | 521 |
| `alpha` | propriedade | `public alpha: number;` | 525 |
| `name` | propriedade | `public name: string;` | 536 |
| `transform` | propriedade | `public readonly transform: Transform = new Transform();` | 540 |
| `userData` | propriedade | `public userData: UserData \| null = null;` | 544 |
| `parent` | propriedade | `public parent: BoneData \| null;` | 555 |

#### ClassDeclaration `SurfaceData`

Herança: extends BoneData.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 579 |
| `_onClear` | método | `protected _onClear(): void` | 587 |
| `segmentX` | propriedade | `public segmentX: number;` | 583 |
| `segmentY` | propriedade | `public segmentY: number;` | 584 |
| `geometry` | propriedade | `public readonly geometry: GeometryData = new GeometryData();` | 585 |

#### ClassDeclaration `SlotData`

Herança: extends BaseObject.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `createColor` | método | `public static createColor(): ColorTransform` | 614 |
| `toString` | método | `public static toString(): string` | 618 |
| `_onClear` | método | `protected _onClear(): void` | 672 |
| `DEFAULT_COLOR` | propriedade | `public static readonly DEFAULT_COLOR: ColorTransform = new ColorTransform();` | 610 |
| `blendMode` | propriedade | `public blendMode: BlendMode;` | 624 |
| `displayIndex` | propriedade | `public displayIndex: number;` | 628 |
| `zOrder` | propriedade | `public zOrder: number;` | 632 |
| `zIndex` | propriedade | `public zIndex: number;` | 636 |
| `alpha` | propriedade | `public alpha: number;` | 640 |
| `name` | propriedade | `public name: string;` | 651 |
| `color` | propriedade | `public color: ColorTransform = null as any;` | 655 |
| `userData` | propriedade | `public userData: UserData \| null = null;` | 659 |
| `parent` | propriedade | `public parent: BoneData;` | 670 |

### `DragonBones/src/dragonBones/model/BoundingBoxData.ts`

- Origem/commit: `DragonBones/src/dragonBones/model/BoundingBoxData.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: dragonbones/model/BoundingBoxData.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/geom/Rectangle.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `BoundingBoxData`

Herança: extends BaseObject.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `_onClear` | método | `protected _onClear(): void` | 65 |
| `containsPoint` | método | `public abstract containsPoint(pX: number, pY: number): boolean;` | 80 |
| `intersectsSegment` | método | `public abstract intersectsSegment( xA: number, yA: number, xB: number, yB: number, intersectionPointA: { x: number, y: number } \| null, intersectionPointB: { x: number, y: number } \| null, normalRadians: { x: number, y: number } \| null ): number;` | 91 |
| `type` | propriedade | `public type: BoundingBoxType;` | 51 |
| `color` | propriedade | `public color: number;` | 55 |
| `width` | propriedade | `public width: number;` | 59 |
| `height` | propriedade | `public height: number;` | 63 |

#### EnumDeclaration `OutCode`

Herança: nenhuma explícita.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `InSide` | propriedade | `InSide = 0` | 109 |
| `Left` | propriedade | `Left = 1` | 110 |
| `Right` | propriedade | `Right = 2` | 111 |
| `Top` | propriedade | `Top = 4` | 112 |
| `Bottom` | propriedade | `Bottom = 8` | 113 |

#### ClassDeclaration `RectangleBoundingBoxData`

Herança: extends BoundingBoxData.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 126 |
| `_computeOutCode` | método | `private static _computeOutCode(x: number, y: number, xMin: number, yMin: number, xMax: number, yMax: number): number` | 132 |
| `rectangleIntersectsSegment` | método | `public static rectangleIntersectsSegment( xA: number, yA: number, xB: number, yB: number, xMin: number, yMin: number, xMax: number, yMax: number, intersectionPointA: { x: number, y: number } \| null = null, intersectionPointB: { x: number, y: number } \| null = null, normalRadians: { x: number, y: number } \| null = null ): number` | 154 |
| `_onClear` | método | `protected _onClear(): void` | 298 |
| `containsPoint` | método | `public containsPoint(pX: number, pY: number): boolean` | 306 |
| `intersectsSegment` | método | `public intersectsSegment( xA: number, yA: number, xB: number, yB: number, intersectionPointA: { x: number, y: number } \| null = null, intersectionPointB: { x: number, y: number } \| null = null, normalRadians: { x: number, y: number } \| null = null ): number` | 320 |

#### ClassDeclaration `EllipseBoundingBoxData`

Herança: extends BoundingBoxData.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 348 |
| `ellipseIntersectsSegment` | método | `public static ellipseIntersectsSegment( xA: number, yA: number, xB: number, yB: number, xC: number, yC: number, widthH: number, heightH: number, intersectionPointA: { x: number, y: number } \| null = null, intersectionPointB: { x: number, y: number } \| null = null, normalRadians: { x: number, y: number } \| null = null ): number` | 354 |
| `_onClear` | método | `protected _onClear(): void` | 458 |
| `containsPoint` | método | `public containsPoint(pX: number, pY: number): boolean` | 466 |
| `intersectsSegment` | método | `public intersectsSegment( xA: number, yA: number, xB: number, yB: number, intersectionPointA: { x: number, y: number } \| null = null, intersectionPointB: { x: number, y: number } \| null = null, normalRadians: { x: number, y: number } \| null = null ): number` | 481 |

#### ClassDeclaration `PolygonBoundingBoxData`

Herança: extends BoundingBoxData.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 507 |
| `polygonIntersectsSegment` | método | `public static polygonIntersectsSegment( xA: number, yA: number, xB: number, yB: number, vertices: Array<number>, intersectionPointA: { x: number, y: number } \| null = null, intersectionPointB: { x: number, y: number } \| null = null, normalRadians: { x: number, y: number } \| null = null ): number` | 513 |
| `_onClear` | método | `protected _onClear(): void` | 677 |
| `containsPoint` | método | `public containsPoint(pX: number, pY: number): boolean` | 688 |
| `intersectsSegment` | método | `public intersectsSegment( xA: number, yA: number, xB: number, yB: number, intersectionPointA: { x: number, y: number } \| null = null, intersectionPointB: { x: number, y: number } \| null = null, normalRadians: { x: number, y: number } \| null = null ): number` | 711 |
| `x` | propriedade | `public x: number;` | 660 |
| `y` | propriedade | `public y: number;` | 664 |
| `vertices` | propriedade | `public readonly vertices: Array<number> = [];` | 675 |

### `DragonBones/src/dragonBones/model/CanvasData.ts`

- Origem/commit: `DragonBones/src/dragonBones/model/CanvasData.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: dragonbones/model/CanvasData.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/core/BaseObject.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `CanvasData`

Herança: extends BaseObject.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 28 |
| `_onClear` | método | `protected _onClear(): void` | 39 |
| `hasBackground` | propriedade | `public hasBackground: boolean;` | 32 |
| `color` | propriedade | `public color: number;` | 33 |
| `x` | propriedade | `public x: number;` | 34 |
| `y` | propriedade | `public y: number;` | 35 |
| `width` | propriedade | `public width: number;` | 36 |
| `height` | propriedade | `public height: number;` | 37 |

### `DragonBones/src/dragonBones/model/ConstraintData.ts`

- Origem/commit: `DragonBones/src/dragonBones/model/ConstraintData.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: dragonbones/model/ConstraintData.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/model/ArmatureData.ts`, `DragonBones/src/dragonBones/model/DisplayData.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `ConstraintData`

Herança: extends BaseObject.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `_onClear` | método | `protected _onClear(): void` | 35 |
| `order` | propriedade | `public order: number;` | 28 |
| `name` | propriedade | `public name: string;` | 29 |
| `type` | propriedade | `public type: ConstraintType;` | 30 |
| `target` | propriedade | `public target: BoneData;` | 31 |
| `root` | propriedade | `public root: BoneData;` | 32 |
| `bone` | propriedade | `public bone: BoneData \| null;` | 33 |

#### ClassDeclaration `IKConstraintData`

Herança: extends ConstraintData.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 48 |
| `_onClear` | método | `protected _onClear(): void` | 56 |
| `scaleEnabled` | propriedade | `public scaleEnabled: boolean;` | 52 |
| `bendPositive` | propriedade | `public bendPositive: boolean;` | 53 |
| `weight` | propriedade | `public weight: number;` | 54 |

#### ClassDeclaration `PathConstraintData`

Herança: extends ConstraintData.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 68 |
| `_onClear` | método | `protected _onClear() : void` | 86 |
| `AddBone` | método | `public AddBone(value : BoneData) : void` | 104 |
| `pathSlot` | propriedade | `public pathSlot : SlotData;` | 72 |
| `pathDisplayData` | propriedade | `public pathDisplayData : PathDisplayData;` | 73 |
| `bones` | propriedade | `public bones : Array<BoneData> = [];` | 74 |
| `positionMode` | propriedade | `public positionMode : PositionMode;` | 76 |
| `spacingMode` | propriedade | `public spacingMode : SpacingMode;` | 77 |
| `rotateMode` | propriedade | `public rotateMode : RotateMode;` | 78 |
| `position` | propriedade | `public position : number;` | 80 |
| `spacing` | propriedade | `public spacing : number;` | 81 |
| `rotateOffset` | propriedade | `public rotateOffset : number;` | 82 |
| `rotateMix` | propriedade | `public rotateMix : number;` | 83 |
| `translateMix` | propriedade | `public translateMix : number;` | 84 |

### `DragonBones/src/dragonBones/model/DisplayData.ts`

- Origem/commit: `DragonBones/src/dragonBones/model/DisplayData.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: dragonbones/model/DisplayData.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/Demos/assets/Script/BoundingBox.ts`, `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/geom/Point.ts`, `DragonBones/src/dragonBones/geom/Transform.ts`, `DragonBones/src/dragonBones/model/ArmatureData.ts`, `DragonBones/src/dragonBones/model/BoundingBoxData.ts`, `DragonBones/src/dragonBones/model/DragonBonesData.ts`, `DragonBones/src/dragonBones/model/SkinData.ts`, `DragonBones/src/dragonBones/model/TextureAtlasData.ts`, `DragonBones/src/dragonBones/model/UserData.ts`, `Egret/Demos/src/demo/BoundingBox.ts`, `Phaser/3.x/src/dragonBones/phaser/display/TextureAtlasData.ts`, `Phaser/Demos/src/BoundingBox.ts`, `Pixi/Demos/4.x/src/BoundingBox.ts`, `Pixi/Demos/8.x/src/BoundingBox.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `GeometryData`

Herança: nenhuma explícita.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `clear` | método | `public clear(): void` | 34 |
| `shareFrom` | método | `public shareFrom(value: GeometryData): void` | 46 |
| `vertexCount` | método | `public get vertexCount(): number` | 52 |
| `triangleCount` | método | `public get triangleCount(): number` | 57 |
| `isShared` | propriedade | `public isShared: boolean;` | 28 |
| `inheritDeform` | propriedade | `public inheritDeform: boolean;` | 29 |
| `offset` | propriedade | `public offset: number;` | 30 |
| `data` | propriedade | `public data: DragonBonesData;` | 31 |
| `weight` | propriedade | `public weight: WeightData \| null = null;` | 32 |

#### ClassDeclaration `DisplayData`

Herança: extends BaseObject.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `_onClear` | método | `protected _onClear(): void` | 72 |
| `type` | propriedade | `public type: DisplayType;` | 66 |
| `name` | propriedade | `public name: string;` | 67 |
| `path` | propriedade | `public path: string;` | 68 |
| `transform` | propriedade | `public readonly transform: Transform = new Transform();` | 69 |
| `parent` | propriedade | `public parent: SkinData;` | 70 |

#### ClassDeclaration `ImageDisplayData`

Herança: extends DisplayData.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 83 |
| `_onClear` | método | `protected _onClear(): void` | 90 |
| `pivot` | propriedade | `public readonly pivot: Point = new Point();` | 87 |
| `texture` | propriedade | `public texture: TextureData \| null;` | 88 |

#### ClassDeclaration `ArmatureDisplayData`

Herança: extends DisplayData.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 102 |
| `_onClear` | método | `protected _onClear(): void` | 110 |
| `addAction` | método | `public addAction(value: ActionData): void` | 125 |
| `inheritAnimation` | propriedade | `public inheritAnimation: boolean;` | 106 |
| `actions` | propriedade | `public readonly actions: Array<ActionData> = [];` | 107 |
| `armature` | propriedade | `public armature: ArmatureData \| null;` | 108 |

#### ClassDeclaration `MeshDisplayData`

Herança: extends DisplayData.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 133 |
| `_onClear` | método | `protected _onClear(): void` | 140 |
| `geometry` | propriedade | `public readonly geometry: GeometryData = new GeometryData();` | 137 |
| `texture` | propriedade | `public texture: TextureData \| null;` | 138 |

#### ClassDeclaration `BoundingBoxDisplayData`

Herança: extends DisplayData.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 152 |
| `_onClear` | método | `protected _onClear(): void` | 158 |
| `boundingBox` | propriedade | `public boundingBox: BoundingBoxData \| null = null;` | 156 |

#### ClassDeclaration `PathDisplayData`

Herança: extends DisplayData.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 173 |
| `_onClear` | método | `protected _onClear(): void` | 181 |
| `closed` | propriedade | `public closed: boolean;` | 176 |
| `constantSpeed` | propriedade | `public constantSpeed: boolean;` | 177 |
| `geometry` | propriedade | `public readonly geometry: GeometryData = new GeometryData();` | 178 |
| `curveLengths` | propriedade | `public readonly curveLengths: Array<number> = [];` | 179 |

#### ClassDeclaration `WeightData`

Herança: extends BaseObject.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 195 |
| `_onClear` | método | `protected _onClear(): void` | 203 |
| `addBone` | método | `public addBone(value: BoneData): void` | 209 |
| `count` | propriedade | `public count: number;` | 199 |
| `offset` | propriedade | `public offset: number;` | 200 |
| `bones` | propriedade | `public readonly bones: Array<BoneData> = [];` | 201 |

### `DragonBones/src/dragonBones/model/DragonBonesData.ts`

- Origem/commit: `DragonBones/src/dragonBones/model/DragonBonesData.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: dragonbones/model/DragonBonesData.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/model/ArmatureData.ts`, `DragonBones/src/dragonBones/model/UserData.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `DragonBonesData`

Herança: extends BaseObject.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 39 |
| `_onClear` | método | `protected _onClear(): void` | 145 |
| `addArmature` | método | `public addArmature(value: ArmatureData): void` | 177 |
| `getArmature` | método | `public getArmature(armatureName: string): ArmatureData \| null` | 199 |
| `autoSearch` | propriedade | `public autoSearch: boolean;` | 45 |
| `frameRate` | propriedade | `public frameRate: number;` | 56 |
| `version` | propriedade | `public version: string;` | 67 |
| `name` | propriedade | `public name: string;` | 80 |
| `stage` | propriedade | `public stage: ArmatureData \| null;` | 84 |
| `frameIndices` | propriedade | `public readonly frameIndices: Array<number> = [];` | 88 |
| `cachedFrames` | propriedade | `public readonly cachedFrames: Array<number> = [];` | 92 |
| `armatureNames` | propriedade | `public readonly armatureNames: Array<string> = [];` | 103 |
| `armatures` | propriedade | `public readonly armatures: Map<ArmatureData> = {};` | 107 |
| `binary` | propriedade | `public binary: ArrayBuffer;` | 111 |
| `intArray` | propriedade | `public intArray: Int16Array;` | 115 |
| `floatArray` | propriedade | `public floatArray: Float32Array;` | 119 |
| `frameIntArray` | propriedade | `public frameIntArray: Int16Array;` | 123 |
| `frameFloatArray` | propriedade | `public frameFloatArray: Float32Array;` | 127 |
| `frameArray` | propriedade | `public frameArray: Int16Array;` | 131 |
| `timelineArray` | propriedade | `public timelineArray: Uint16Array;` | 135 |
| `colorArray` | propriedade | `public colorArray: Int16Array \| Uint16Array;` | 139 |
| `userData` | propriedade | `public userData: UserData \| null = null;` | 143 |

### `DragonBones/src/dragonBones/model/SkinData.ts`

- Origem/commit: `DragonBones/src/dragonBones/model/SkinData.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: dragonbones/model/SkinData.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/model/ArmatureData.ts`, `DragonBones/src/dragonBones/model/DisplayData.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `SkinData`

Herança: extends BaseObject.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 35 |
| `_onClear` | método | `protected _onClear(): void` | 58 |
| `addDisplay` | método | `public addDisplay(slotName: string, value: DisplayData \| null): void` | 77 |
| `getDisplay` | método | `public getDisplay(slotName: string, displayName: string): DisplayData \| null` | 92 |
| `getDisplays` | método | `public getDisplays(slotName: string): Array<DisplayData \| null> \| null` | 107 |
| `name` | propriedade | `public name: string;` | 48 |
| `displays` | propriedade | `public readonly displays: Map<Array<DisplayData \| null>> = {};` | 52 |
| `parent` | propriedade | `public parent: ArmatureData;` | 56 |

### `DragonBones/src/dragonBones/model/TextureAtlasData.ts`

- Origem/commit: `DragonBones/src/dragonBones/model/TextureAtlasData.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: dragonbones/model/TextureAtlasData.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/geom/Rectangle.ts`, `Phaser/3.x/src/dragonBones/phaser/display/TextureAtlasData.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `TextureAtlasData`

Herança: extends BaseObject.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `_onClear` | método | `protected _onClear(): void` | 78 |
| `copyFrom` | método | `public copyFrom(value: TextureAtlasData): void` | 95 |
| `createTexture` | método | `public abstract createTexture(): TextureData;` | 119 |
| `addTexture` | método | `public addTexture(value: TextureData): void` | 123 |
| `getTexture` | método | `public getTexture(textureName: string): TextureData \| null` | 135 |
| `autoSearch` | propriedade | `public autoSearch: boolean;` | 38 |
| `width` | propriedade | `public width: number;` | 42 |
| `height` | propriedade | `public height: number;` | 46 |
| `scale` | propriedade | `public scale: number;` | 50 |
| `name` | propriedade | `public name: string;` | 61 |
| `imagePath` | propriedade | `public imagePath: string;` | 72 |
| `textures` | propriedade | `public readonly textures: Map<TextureData> = {};` | 76 |

#### ClassDeclaration `TextureData`

Herança: extends BaseObject.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `createRectangle` | método | `public static createRectangle(): Rectangle` | 143 |
| `_onClear` | método | `protected _onClear(): void` | 153 |
| `copyFrom` | método | `public copyFrom(value: TextureData): void` | 161 |
| `rotated` | propriedade | `public rotated: boolean;` | 147 |
| `name` | propriedade | `public name: string;` | 148 |
| `region` | propriedade | `public readonly region: Rectangle = new Rectangle();` | 149 |
| `parent` | propriedade | `public parent: TextureAtlasData;` | 150 |
| `frame` | propriedade | `public frame: Rectangle \| null = null;` | 151 |

### `DragonBones/src/dragonBones/model/UserData.ts`

- Origem/commit: `DragonBones/src/dragonBones/model/UserData.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: dragonbones/model/UserData.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/model/ArmatureData.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `UserData`

Herança: extends BaseObject.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 35 |
| `_onClear` | método | `protected _onClear(): void` | 72 |
| `addInt` | método | `public addInt(value: number): void` | 80 |
| `addFloat` | método | `public addFloat(value: number): void` | 86 |
| `addString` | método | `public addString(value: string): void` | 92 |
| `getInt` | método | `public getInt(index: number = 0): number` | 105 |
| `getFloat` | método | `public getFloat(index: number = 0): number` | 118 |
| `getString` | método | `public getString(index: number = 0): string` | 131 |
| `ints` | propriedade | `public readonly ints: Array<number> = [];` | 48 |
| `floats` | propriedade | `public readonly floats: Array<number> = [];` | 59 |
| `strings` | propriedade | `public readonly strings: Array<string> = [];` | 70 |

#### ClassDeclaration `ActionData`

Herança: extends BaseObject.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 139 |
| `_onClear` | método | `protected _onClear(): void` | 149 |
| `type` | propriedade | `public type: ActionType;` | 143 |
| `name` | propriedade | `public name: string;` | 144 |
| `bone` | propriedade | `public bone: BoneData \| null;` | 145 |
| `slot` | propriedade | `public slot: SlotData \| null;` | 146 |
| `data` | propriedade | `public data: UserData \| null = null;` | 147 |

### `DragonBones/src/dragonBones/parser/BinaryDataParser.ts`

- Origem/commit: `DragonBones/src/dragonBones/parser/BinaryDataParser.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: dragonbones/parser/BinaryDataParser.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/armature/Constraint.ts`, `DragonBones/src/dragonBones/armature/Surface.ts`, `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/model/AnimationData.ts`, `DragonBones/src/dragonBones/model/DisplayData.ts`, `DragonBones/src/dragonBones/model/DragonBonesData.ts`, `DragonBones/src/dragonBones/parser/DataParser.ts`, `DragonBones/src/dragonBones/parser/ObjectDataParser.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `BinaryDataParser`

Herança: extends ObjectDataParser.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `_inRange` | método | `private _inRange(a: number, min: number, max: number): boolean` | 34 |
| `_decodeUTF8` | método | `private _decodeUTF8(data: Uint8Array): string` | 38 |
| `_parseBinaryTimeline` | método | `private _parseBinaryTimeline(type: TimelineType, offset: number, timelineData: TimelineData \| null = null): TimelineData` | 141 |
| `_parseAnimation` | método | `protected _parseAnimation(rawData: any): AnimationData` | 186 |
| `_parseGeometry` | método | `protected _parseGeometry(rawData: any, geometry: GeometryData): void` | 331 |
| `_parseArray` | método | `protected _parseArray(rawData: any): void` | 367 |
| `parseDragonBonesData` | método | `public parseDragonBonesData(rawData: any, scale: number = 1): DragonBonesData \| null` | 394 |
| `getInstance` | método | `public static getInstance(): BinaryDataParser` | 430 |
| `_binaryOffset` | propriedade | `private _binaryOffset: number;` | 28 |
| `_binary` | propriedade | `private _binary: ArrayBuffer;` | 29 |
| `_intArrayBuffer` | propriedade | `private _intArrayBuffer: Int16Array;` | 30 |
| `_frameArrayBuffer` | propriedade | `private _frameArrayBuffer: Int16Array;` | 31 |
| `_timelineArrayBuffer` | propriedade | `private _timelineArrayBuffer: Uint16Array;` | 32 |
| `_binaryDataParserInstance` | propriedade | `private static _binaryDataParserInstance: BinaryDataParser \| null = null;` | 419 |

### `DragonBones/src/dragonBones/parser/DataParser.ts`

- Origem/commit: `DragonBones/src/dragonBones/parser/DataParser.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: dragonbones/parser/DataParser.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/Demos/assets/Script/BoundingBox.ts`, `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/armature/Bone.ts`, `DragonBones/src/dragonBones/armature/Surface.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/geom/Rectangle.ts`, `DragonBones/src/dragonBones/model/DragonBonesData.ts`, `DragonBones/src/dragonBones/model/TextureAtlasData.ts`, `Egret/Demos/src/demo/BoundingBox.ts`, `Phaser/3.x/src/dragonBones/phaser/display/TextureAtlasData.ts`, `Phaser/Demos/src/BoundingBox.ts`, `Pixi/Demos/4.x/src/BoundingBox.ts`, `Pixi/Demos/8.x/src/BoundingBox.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `DataParser`

Herança: nenhuma explícita.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `_getArmatureType` | método | `protected static _getArmatureType(value: string): ArmatureType` | 182 |
| `_getBoneType` | método | `protected static _getBoneType(value: string): BoneType` | 198 |
| `_getPositionMode` | método | `protected static _getPositionMode(value: string): PositionMode` | 211 |
| `_getSpacingMode` | método | `protected static _getSpacingMode(value: string): SpacingMode` | 224 |
| `_getRotateMode` | método | `protected static _getRotateMode(value: string): RotateMode` | 240 |
| `_getDisplayType` | método | `protected static _getDisplayType(value: string): DisplayType` | 256 |
| `_getBoundingBoxType` | método | `protected static _getBoundingBoxType(value: string): BoundingBoxType` | 278 |
| `_getBlendMode` | método | `protected static _getBlendMode(value: string): BlendMode` | 294 |
| `_getAnimationBlendType` | método | `protected static _getAnimationBlendType(value: string): AnimationBlendType` | 343 |
| `_getActionType` | método | `protected static _getActionType(value: string): ActionType` | 356 |
| `parseDragonBonesData` | método | `public abstract parseDragonBonesData(rawData: any, scale: number): DragonBonesData \| null;` | 372 |
| `parseTextureAtlasData` | método | `public abstract parseTextureAtlasData(rawData: any, textureAtlasData: TextureAtlasData, scale: number): boolean;` | 373 |
| `DATA_VERSION_2_3` | propriedade | `protected static readonly DATA_VERSION_2_3: string = "2.3";` | 28 |
| `DATA_VERSION_3_0` | propriedade | `protected static readonly DATA_VERSION_3_0: string = "3.0";` | 29 |
| `DATA_VERSION_4_0` | propriedade | `protected static readonly DATA_VERSION_4_0: string = "4.0";` | 30 |
| `DATA_VERSION_4_5` | propriedade | `protected static readonly DATA_VERSION_4_5: string = "4.5";` | 31 |
| `DATA_VERSION_5_0` | propriedade | `protected static readonly DATA_VERSION_5_0: string = "5.0";` | 32 |
| `DATA_VERSION_5_5` | propriedade | `protected static readonly DATA_VERSION_5_5: string = "5.5";` | 33 |
| `DATA_VERSION_5_6` | propriedade | `protected static readonly DATA_VERSION_5_6: string = "5.6";` | 34 |
| `DATA_VERSION` | propriedade | `protected static readonly DATA_VERSION: string = DataParser.DATA_VERSION_5_6;` | 35 |
| `DATA_VERSIONS` | propriedade | `protected static readonly DATA_VERSIONS: Array<string> = [ DataParser.DATA_VERSION_4_0, DataParser.DATA_VERSION_4_5, DataParser.DATA_VERSION_5_0, DataParser.DATA_VERSION_5_5, DataParser.DATA_VERSION_5_6 ];` | 37 |
| `TEXTURE_ATLAS` | propriedade | `protected static readonly TEXTURE_ATLAS: string = "textureAtlas";` | 45 |
| `SUB_TEXTURE` | propriedade | `protected static readonly SUB_TEXTURE: string = "SubTexture";` | 46 |
| `FORMAT` | propriedade | `protected static readonly FORMAT: string = "format";` | 47 |
| `IMAGE_PATH` | propriedade | `protected static readonly IMAGE_PATH: string = "imagePath";` | 48 |
| `WIDTH` | propriedade | `protected static readonly WIDTH: string = "width";` | 49 |
| `HEIGHT` | propriedade | `protected static readonly HEIGHT: string = "height";` | 50 |
| `ROTATED` | propriedade | `protected static readonly ROTATED: string = "rotated";` | 51 |
| `FRAME_X` | propriedade | `protected static readonly FRAME_X: string = "frameX";` | 52 |
| `FRAME_Y` | propriedade | `protected static readonly FRAME_Y: string = "frameY";` | 53 |
| `FRAME_WIDTH` | propriedade | `protected static readonly FRAME_WIDTH: string = "frameWidth";` | 54 |
| `FRAME_HEIGHT` | propriedade | `protected static readonly FRAME_HEIGHT: string = "frameHeight";` | 55 |
| `DRADON_BONES` | propriedade | `protected static readonly DRADON_BONES: string = "dragonBones";` | 57 |
| `USER_DATA` | propriedade | `protected static readonly USER_DATA: string = "userData";` | 58 |
| `ARMATURE` | propriedade | `protected static readonly ARMATURE: string = "armature";` | 59 |
| `CANVAS` | propriedade | `protected static readonly CANVAS: string = "canvas";` | 60 |
| `BONE` | propriedade | `protected static readonly BONE: string = "bone";` | 61 |
| `SURFACE` | propriedade | `protected static readonly SURFACE: string = "surface";` | 62 |
| `SLOT` | propriedade | `protected static readonly SLOT: string = "slot";` | 63 |
| `CONSTRAINT` | propriedade | `protected static readonly CONSTRAINT: string = "constraint";` | 64 |
| `SKIN` | propriedade | `protected static readonly SKIN: string = "skin";` | 65 |
| `DISPLAY` | propriedade | `protected static readonly DISPLAY: string = "display";` | 66 |
| `FRAME` | propriedade | `protected static readonly FRAME: string = "frame";` | 67 |
| `IK` | propriedade | `protected static readonly IK: string = "ik";` | 68 |
| `PATH_CONSTRAINT` | propriedade | `protected static readonly PATH_CONSTRAINT: string = "path";` | 69 |
| `ANIMATION` | propriedade | `protected static readonly ANIMATION: string = "animation";` | 71 |
| `TIMELINE` | propriedade | `protected static readonly TIMELINE: string = "timeline";` | 72 |
| `FFD` | propriedade | `protected static readonly FFD: string = "ffd";` | 73 |
| `TRANSLATE_FRAME` | propriedade | `protected static readonly TRANSLATE_FRAME: string = "translateFrame";` | 74 |
| `ROTATE_FRAME` | propriedade | `protected static readonly ROTATE_FRAME: string = "rotateFrame";` | 75 |
| `SCALE_FRAME` | propriedade | `protected static readonly SCALE_FRAME: string = "scaleFrame";` | 76 |
| `DISPLAY_FRAME` | propriedade | `protected static readonly DISPLAY_FRAME: string = "displayFrame";` | 77 |
| `COLOR_FRAME` | propriedade | `protected static readonly COLOR_FRAME: string = "colorFrame";` | 78 |
| `DEFAULT_ACTIONS` | propriedade | `protected static readonly DEFAULT_ACTIONS: string = "defaultActions";` | 79 |
| `ACTIONS` | propriedade | `protected static readonly ACTIONS: string = "actions";` | 80 |
| `EVENTS` | propriedade | `protected static readonly EVENTS: string = "events";` | 81 |
| `INTS` | propriedade | `protected static readonly INTS: string = "ints";` | 83 |
| `FLOATS` | propriedade | `protected static readonly FLOATS: string = "floats";` | 84 |
| `STRINGS` | propriedade | `protected static readonly STRINGS: string = "strings";` | 85 |
| `TRANSFORM` | propriedade | `protected static readonly TRANSFORM: string = "transform";` | 87 |
| `PIVOT` | propriedade | `protected static readonly PIVOT: string = "pivot";` | 88 |
| `AABB` | propriedade | `protected static readonly AABB: string = "aabb";` | 89 |
| `COLOR` | propriedade | `protected static readonly COLOR: string = "color";` | 90 |
| `VERSION` | propriedade | `protected static readonly VERSION: string = "version";` | 92 |
| `COMPATIBLE_VERSION` | propriedade | `protected static readonly COMPATIBLE_VERSION: string = "compatibleVersion";` | 93 |
| `FRAME_RATE` | propriedade | `protected static readonly FRAME_RATE: string = "frameRate";` | 94 |
| `TYPE` | propriedade | `protected static readonly TYPE: string = "type";` | 95 |
| `SUB_TYPE` | propriedade | `protected static readonly SUB_TYPE: string = "subType";` | 96 |
| `NAME` | propriedade | `protected static readonly NAME: string = "name";` | 97 |
| `PARENT` | propriedade | `protected static readonly PARENT: string = "parent";` | 98 |
| `TARGET` | propriedade | `protected static readonly TARGET: string = "target";` | 99 |
| `STAGE` | propriedade | `protected static readonly STAGE: string = "stage";` | 100 |
| `SHARE` | propriedade | `protected static readonly SHARE: string = "share";` | 101 |
| `PATH` | propriedade | `protected static readonly PATH: string = "path";` | 102 |
| `LENGTH` | propriedade | `protected static readonly LENGTH: string = "length";` | 103 |
| `DISPLAY_INDEX` | propriedade | `protected static readonly DISPLAY_INDEX: string = "displayIndex";` | 104 |
| `Z_ORDER` | propriedade | `protected static readonly Z_ORDER: string = "zOrder";` | 105 |
| `Z_INDEX` | propriedade | `protected static readonly Z_INDEX: string = "zIndex";` | 106 |
| `BLEND_MODE` | propriedade | `protected static readonly BLEND_MODE: string = "blendMode";` | 107 |
| `INHERIT_TRANSLATION` | propriedade | `protected static readonly INHERIT_TRANSLATION: string = "inheritTranslation";` | 108 |
| `INHERIT_ROTATION` | propriedade | `protected static readonly INHERIT_ROTATION: string = "inheritRotation";` | 109 |
| `INHERIT_SCALE` | propriedade | `protected static readonly INHERIT_SCALE: string = "inheritScale";` | 110 |
| `INHERIT_REFLECTION` | propriedade | `protected static readonly INHERIT_REFLECTION: string = "inheritReflection";` | 111 |
| `INHERIT_ANIMATION` | propriedade | `protected static readonly INHERIT_ANIMATION: string = "inheritAnimation";` | 112 |
| `INHERIT_DEFORM` | propriedade | `protected static readonly INHERIT_DEFORM: string = "inheritDeform";` | 113 |
| `SEGMENT_X` | propriedade | `protected static readonly SEGMENT_X: string = "segmentX";` | 114 |
| `SEGMENT_Y` | propriedade | `protected static readonly SEGMENT_Y: string = "segmentY";` | 115 |
| `BEND_POSITIVE` | propriedade | `protected static readonly BEND_POSITIVE: string = "bendPositive";` | 116 |
| `CHAIN` | propriedade | `protected static readonly CHAIN: string = "chain";` | 117 |
| `WEIGHT` | propriedade | `protected static readonly WEIGHT: string = "weight";` | 118 |
| `BLEND_TYPE` | propriedade | `protected static readonly BLEND_TYPE: string = "blendType";` | 120 |
| `FADE_IN_TIME` | propriedade | `protected static readonly FADE_IN_TIME: string = "fadeInTime";` | 121 |
| `PLAY_TIMES` | propriedade | `protected static readonly PLAY_TIMES: string = "playTimes";` | 122 |
| `SCALE` | propriedade | `protected static readonly SCALE: string = "scale";` | 123 |
| `OFFSET` | propriedade | `protected static readonly OFFSET: string = "offset";` | 124 |
| `POSITION` | propriedade | `protected static readonly POSITION: string = "position";` | 125 |
| `DURATION` | propriedade | `protected static readonly DURATION: string = "duration";` | 126 |
| `TWEEN_EASING` | propriedade | `protected static readonly TWEEN_EASING: string = "tweenEasing";` | 127 |
| `TWEEN_ROTATE` | propriedade | `protected static readonly TWEEN_ROTATE: string = "tweenRotate";` | 128 |
| `TWEEN_SCALE` | propriedade | `protected static readonly TWEEN_SCALE: string = "tweenScale";` | 129 |
| `CLOCK_WISE` | propriedade | `protected static readonly CLOCK_WISE: string = "clockwise";` | 130 |
| `CURVE` | propriedade | `protected static readonly CURVE: string = "curve";` | 131 |
| `SOUND` | propriedade | `protected static readonly SOUND: string = "sound";` | 132 |
| `EVENT` | propriedade | `protected static readonly EVENT: string = "event";` | 133 |
| `ACTION` | propriedade | `protected static readonly ACTION: string = "action";` | 134 |
| `X` | propriedade | `protected static readonly X: string = "x";` | 136 |
| `Y` | propriedade | `protected static readonly Y: string = "y";` | 137 |
| `SKEW_X` | propriedade | `protected static readonly SKEW_X: string = "skX";` | 138 |
| `SKEW_Y` | propriedade | `protected static readonly SKEW_Y: string = "skY";` | 139 |
| `SCALE_X` | propriedade | `protected static readonly SCALE_X: string = "scX";` | 140 |
| `SCALE_Y` | propriedade | `protected static readonly SCALE_Y: string = "scY";` | 141 |
| `VALUE` | propriedade | `protected static readonly VALUE: string = "value";` | 142 |
| `ROTATE` | propriedade | `protected static readonly ROTATE: string = "rotate";` | 143 |
| `SKEW` | propriedade | `protected static readonly SKEW: string = "skew";` | 144 |
| `ALPHA` | propriedade | `protected static readonly ALPHA: string = "alpha";` | 145 |
| `ALPHA_OFFSET` | propriedade | `protected static readonly ALPHA_OFFSET: string = "aO";` | 147 |
| `RED_OFFSET` | propriedade | `protected static readonly RED_OFFSET: string = "rO";` | 148 |
| `GREEN_OFFSET` | propriedade | `protected static readonly GREEN_OFFSET: string = "gO";` | 149 |
| `BLUE_OFFSET` | propriedade | `protected static readonly BLUE_OFFSET: string = "bO";` | 150 |
| `ALPHA_MULTIPLIER` | propriedade | `protected static readonly ALPHA_MULTIPLIER: string = "aM";` | 151 |
| `RED_MULTIPLIER` | propriedade | `protected static readonly RED_MULTIPLIER: string = "rM";` | 152 |
| `GREEN_MULTIPLIER` | propriedade | `protected static readonly GREEN_MULTIPLIER: string = "gM";` | 153 |
| `BLUE_MULTIPLIER` | propriedade | `protected static readonly BLUE_MULTIPLIER: string = "bM";` | 154 |
| `UVS` | propriedade | `protected static readonly UVS: string = "uvs";` | 156 |
| `VERTICES` | propriedade | `protected static readonly VERTICES: string = "vertices";` | 157 |
| `TRIANGLES` | propriedade | `protected static readonly TRIANGLES: string = "triangles";` | 158 |
| `WEIGHTS` | propriedade | `protected static readonly WEIGHTS: string = "weights";` | 159 |
| `SLOT_POSE` | propriedade | `protected static readonly SLOT_POSE: string = "slotPose";` | 160 |
| `BONE_POSE` | propriedade | `protected static readonly BONE_POSE: string = "bonePose";` | 161 |
| `BONES` | propriedade | `protected static readonly BONES: string = "bones";` | 163 |
| `POSITION_MODE` | propriedade | `protected static readonly POSITION_MODE: string = "positionMode";` | 164 |
| `SPACING_MODE` | propriedade | `protected static readonly SPACING_MODE: string = "spacingMode";` | 165 |
| `ROTATE_MODE` | propriedade | `protected static readonly ROTATE_MODE: string = "rotateMode";` | 166 |
| `SPACING` | propriedade | `protected static readonly SPACING: string = "spacing";` | 167 |
| `ROTATE_OFFSET` | propriedade | `protected static readonly ROTATE_OFFSET: string = "rotateOffset";` | 168 |
| `ROTATE_MIX` | propriedade | `protected static readonly ROTATE_MIX: string = "rotateMix";` | 169 |
| `TRANSLATE_MIX` | propriedade | `protected static readonly TRANSLATE_MIX: string = "translateMix";` | 170 |
| `TARGET_DISPLAY` | propriedade | `protected static readonly TARGET_DISPLAY: string = "targetDisplay";` | 172 |
| `CLOSED` | propriedade | `protected static readonly CLOSED: string = "closed";` | 173 |
| `CONSTANT_SPEED` | propriedade | `protected static readonly CONSTANT_SPEED: string = "constantSpeed";` | 174 |
| `VERTEX_COUNT` | propriedade | `protected static readonly VERTEX_COUNT: string = "vertexCount";` | 175 |
| `LENGTHS` | propriedade | `protected static readonly LENGTHS: string = "lengths";` | 176 |
| `GOTO_AND_PLAY` | propriedade | `protected static readonly GOTO_AND_PLAY: string = "gotoAndPlay";` | 178 |
| `DEFAULT_NAME` | propriedade | `protected static readonly DEFAULT_NAME: string = "default";` | 180 |

### `DragonBones/src/dragonBones/parser/ObjectDataParser.ts`

- Origem/commit: `DragonBones/src/dragonBones/parser/ObjectDataParser.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: dragonbones/parser/ObjectDataParser.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/Demos/assets/Script/BoundingBox.ts`, `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/armature/Bone.ts`, `DragonBones/src/dragonBones/armature/Constraint.ts`, `DragonBones/src/dragonBones/armature/Surface.ts`, `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/geom/ColorTransform.ts`, `DragonBones/src/dragonBones/geom/Matrix.ts`, `DragonBones/src/dragonBones/geom/Point.ts`, `DragonBones/src/dragonBones/geom/Rectangle.ts`, `DragonBones/src/dragonBones/geom/Transform.ts`, `DragonBones/src/dragonBones/model/AnimationData.ts`, `DragonBones/src/dragonBones/model/ArmatureData.ts`, `DragonBones/src/dragonBones/model/BoundingBoxData.ts`, `DragonBones/src/dragonBones/model/CanvasData.ts`, `DragonBones/src/dragonBones/model/ConstraintData.ts`, `DragonBones/src/dragonBones/model/DisplayData.ts`, `DragonBones/src/dragonBones/model/DragonBonesData.ts`, `DragonBones/src/dragonBones/model/SkinData.ts`, `DragonBones/src/dragonBones/model/TextureAtlasData.ts`, `DragonBones/src/dragonBones/model/UserData.ts`, `DragonBones/src/dragonBones/parser/DataParser.ts`, `Egret/Demos/src/demo/BoundingBox.ts`, `Phaser/3.x/src/dragonBones/phaser/display/TextureAtlasData.ts`, `Phaser/Demos/src/BoundingBox.ts`, `Pixi/Demos/4.x/src/BoundingBox.ts`, `Pixi/Demos/8.x/src/BoundingBox.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### EnumDeclaration `FrameValueType`

Herança: nenhuma explícita.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `Step` | propriedade | `Step` | 28 |
| `Int` | propriedade | `Int` | 29 |
| `Float` | propriedade | `Float` | 30 |

#### ClassDeclaration `ObjectDataParser`

Herança: extends DataParser.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `_getBoolean` | método | `protected static _getBoolean(rawData: any, key: string, defaultValue: boolean): boolean` | 36 |
| `_getNumber` | método | `protected static _getNumber(rawData: any, key: string, defaultValue: number): number` | 66 |
| `_getString` | método | `protected static _getString(rawData: any, key: string, defaultValue: string): string` | 79 |
| `_getCurvePoint` | método | `private _getCurvePoint(x1: number, y1: number, x2: number, y2: number, x3: number, y3: number, x4: number, y4: number, t: number, result: Point): void` | 134 |
| `_samplingEasingCurve` | método | `private _samplingEasingCurve(curve: Array<number>, samples: Array<number>): boolean` | 147 |
| `_parseActionDataInFrame` | método | `private _parseActionDataInFrame(rawData: any, frameStart: number, bone: BoneData \| null, slot: SlotData \| null): void` | 223 |
| `_mergeActionFrame` | método | `private _mergeActionFrame(rawData: any, frameStart: number, type: ActionType, bone: BoneData \| null, slot: SlotData \| null): void` | 245 |
| `_parseArmature` | método | `protected _parseArmature(rawData: any, scale: number): ArmatureData` | 285 |
| `_parseBone` | método | `protected _parseBone(rawData: any): BoneData` | 473 |
| `_parseIKConstraint` | método | `protected _parseIKConstraint(rawData: any): ConstraintData \| null` | 511 |
| `_parsePathConstraint` | método | `protected _parsePathConstraint(rawData: any): ConstraintData \| null` | 543 |
| `_parseSlot` | método | `protected _parseSlot(rawData: any, zOrder: number): SlotData` | 593 |
| `_parseSkin` | método | `protected _parseSkin(rawData: any): SkinData` | 624 |
| `_parseDisplay` | método | `protected _parseDisplay(rawData: any): DisplayData \| null` | 665 |
| `_parsePath` | método | `protected _parsePath(rawData: any, display: PathDisplayData)` | 765 |
| `_parsePivot` | método | `protected _parsePivot(rawData: any, display: ImageDisplayData): void` | 769 |
| `_parseMesh` | método | `protected _parseMesh(rawData: any, mesh: MeshDisplayData): void` | 781 |
| `_parseBoundingBox` | método | `protected _parseBoundingBox(rawData: any): BoundingBoxData \| null` | 793 |
| `_parsePolygonBoundingBox` | método | `protected _parsePolygonBoundingBox(rawData: any): PolygonBoundingBoxData` | 829 |
| `_parseAnimation` | método | `protected _parseAnimation(rawData: any): AnimationData` | 878 |
| `_parseTimeline` | método | `protected _parseTimeline( rawData: any, rawFrames: Array<any> \| null, framesKey: string, timelineType: TimelineType, frameValueType: FrameValueType, frameValueCount: number, frameParser: (rawData: any, frameStart: number, frameCount: number) => number, timeline: TimelineData \| null = null ): TimelineData \| null` | 1210 |
| `_parseBoneTimeline` | método | `protected _parseBoneTimeline(rawData: any): void` | 1312 |
| `_parseSlotTimeline` | método | `protected _parseSlotTimeline(rawData: any): void` | 1379 |
| `_parseFrame` | método | `protected _parseFrame(rawData: any, frameStart: number, frameCount: number): number` | 1430 |
| `_parseTweenFrame` | método | `protected _parseTweenFrame(rawData: any, frameStart: number, frameCount: number): number` | 1443 |
| `_parseSingleValueFrame` | método | `protected _parseSingleValueFrame(rawData: any, frameStart: number, frameCount: number): number` | 1499 |
| `_parseDoubleValueFrame` | método | `protected _parseDoubleValueFrame(rawData: any, frameStart: number, frameCount: number): number` | 1529 |
| `_parseActionFrame` | método | `protected _parseActionFrame(frame: ActionFrame, frameStart: number, frameCount: number): number` | 1562 |
| `_parseZOrderFrame` | método | `protected _parseZOrderFrame(rawData: any, frameStart: number, frameCount: number): number` | 1579 |
| `_parseBoneAllFrame` | método | `protected _parseBoneAllFrame(rawData: any, frameStart: number, frameCount: number): number` | 1638 |
| `_parseBoneTranslateFrame` | método | `protected _parseBoneTranslateFrame(rawData: any, frameStart: number, frameCount: number): number` | 1676 |
| `_parseBoneRotateFrame` | método | `protected _parseBoneRotateFrame(rawData: any, frameStart: number, frameCount: number): number` | 1686 |
| `_parseBoneScaleFrame` | método | `protected _parseBoneScaleFrame(rawData: any, frameStart: number, frameCount: number): number` | 1715 |
| `_parseSlotDisplayFrame` | método | `protected _parseSlotDisplayFrame(rawData: any, frameStart: number, frameCount: number): number` | 1725 |
| `_parseSlotColorFrame` | método | `protected _parseSlotColorFrame(rawData: any, frameStart: number, frameCount: number): number` | 1741 |
| `_parseSlotDeformFrame` | método | `protected _parseSlotDeformFrame(rawData: any, frameStart: number, frameCount: number): number` | 1790 |
| `_parseIKConstraintFrame` | método | `protected _parseIKConstraintFrame(rawData: any, frameStart: number, frameCount: number): number` | 1876 |
| `_parseActionData` | método | `protected _parseActionData(rawData: any, type: ActionType, bone: BoneData \| null, slot: SlotData \| null): Array<ActionData>` | 1886 |
| `_parseDeformFrame` | método | `protected _parseDeformFrame(rawData: any, frameStart: number, frameCount: number): number` | 1975 |
| `_parseTransform` | método | `protected _parseTransform(rawData: any, transform: Transform, scale: number): void` | 2037 |
| `_parseColorTransform` | método | `protected _parseColorTransform(rawData: any, color: ColorTransform): void` | 2054 |
| `_parseGeometry` | método | `protected _parseGeometry(rawData: any, geometry: GeometryData): void` | 2065 |
| `_parseArray` | método | `protected _parseArray(rawData: any): void` | 2203 |
| `_modifyArray` | método | `protected _modifyArray(): void` | 2215 |
| `parseDragonBonesData` | método | `public parseDragonBonesData(rawData: any, scale: number = 1): DragonBonesData \| null` | 2294 |
| `parseTextureAtlasData` | método | `public parseTextureAtlasData(rawData: any, textureAtlasData: TextureAtlasData, scale: number = 1.0): boolean` | 2354 |
| `getInstance` | método | `public static getInstance(): ObjectDataParser` | 2421 |
| `_rawTextureAtlasIndex` | propriedade | `protected _rawTextureAtlasIndex: number = 0;` | 94 |
| `_rawBones` | propriedade | `protected readonly _rawBones: Array<BoneData> = [];` | 95 |
| `_data` | propriedade | `protected _data: DragonBonesData = null as any;` | 96 |
| `_armature` | propriedade | `protected _armature: ArmatureData = null as any;` | 97 |
| `_bone` | propriedade | `protected _bone: BoneData = null as any;` | 98 |
| `_geometry` | propriedade | `protected _geometry: GeometryData = null as any;` | 99 |
| `_slot` | propriedade | `protected _slot: SlotData = null as any;` | 100 |
| `_skin` | propriedade | `protected _skin: SkinData = null as any;` | 101 |
| `_mesh` | propriedade | `protected _mesh: MeshDisplayData = null as any;` | 102 |
| `_animation` | propriedade | `protected _animation: AnimationData = null as any;` | 103 |
| `_timeline` | propriedade | `protected _timeline: TimelineData = null as any;` | 104 |
| `_rawTextureAtlases` | propriedade | `protected _rawTextureAtlases: Array<any> \| null = null;` | 105 |
| `_frameValueType` | propriedade | `private _frameValueType: FrameValueType = FrameValueType.Step;` | 107 |
| `_defaultColorOffset` | propriedade | `private _defaultColorOffset: number = -1;` | 108 |
| `_prevClockwise` | propriedade | `private _prevClockwise: number = 0;` | 109 |
| `_prevRotation` | propriedade | `private _prevRotation: number = 0.0;` | 110 |
| `_frameDefaultValue` | propriedade | `private _frameDefaultValue: number = 0.0;` | 111 |
| `_frameValueScale` | propriedade | `private _frameValueScale: number = 1.0;` | 112 |
| `_helpMatrixA` | propriedade | `private readonly _helpMatrixA: Matrix = new Matrix();` | 113 |
| `_helpMatrixB` | propriedade | `private readonly _helpMatrixB: Matrix = new Matrix();` | 114 |
| `_helpTransform` | propriedade | `private readonly _helpTransform: Transform = new Transform();` | 115 |
| `_helpColorTransform` | propriedade | `private readonly _helpColorTransform: ColorTransform = new ColorTransform();` | 116 |
| `_helpPoint` | propriedade | `private readonly _helpPoint: Point = new Point();` | 117 |
| `_helpArray` | propriedade | `private readonly _helpArray: Array<number> = [];` | 118 |
| `_intArray` | propriedade | `private readonly _intArray: Array<number> = [];` | 119 |
| `_floatArray` | propriedade | `private readonly _floatArray: Array<number> = [];` | 120 |
| `_frameIntArray` | propriedade | `private readonly _frameIntArray: Array<number> = [];` | 121 |
| `_frameFloatArray` | propriedade | `private readonly _frameFloatArray: Array<number> = [];` | 122 |
| `_frameArray` | propriedade | `private readonly _frameArray: Array<number> = [];` | 123 |
| `_timelineArray` | propriedade | `private readonly _timelineArray: Array<number> = [];` | 124 |
| `_colorArray` | propriedade | `private readonly _colorArray: Array<number> = [];` | 125 |
| `_cacheRawMeshes` | propriedade | `private readonly _cacheRawMeshes: Array<any> = [];` | 126 |
| `_cacheMeshes` | propriedade | `private readonly _cacheMeshes: Array<MeshDisplayData> = [];` | 127 |
| `_actionFrames` | propriedade | `private readonly _actionFrames: Array<ActionFrame> = [];` | 128 |
| `_weightSlotPose` | propriedade | `private readonly _weightSlotPose: Map<Array<number>> = {};` | 129 |
| `_weightBonePoses` | propriedade | `private readonly _weightBonePoses: Map<Array<number>> = {};` | 130 |
| `_cacheBones` | propriedade | `private readonly _cacheBones: Map<Array<BoneData>> = {};` | 131 |
| `_slotChildActions` | propriedade | `private readonly _slotChildActions: Map<Array<ActionData>> = {};` | 132 |
| `_objectDataParserInstance` | propriedade | `private static _objectDataParserInstance: ObjectDataParser \| null = null;` | 2410 |

#### ClassDeclaration `ActionFrame`

Herança: nenhuma explícita.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `frameStart` | propriedade | `public frameStart: number = 0;` | 2433 |
| `actions` | propriedade | `public readonly actions: Array<number> = [];` | 2434 |

### `Egret/4.x/src/dragonBones/egret/EgretArmatureDisplay.ts`

- Origem/commit: `Egret/4.x/src/dragonBones/egret/EgretArmatureDisplay.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: integrations/Egret/4.x/src/dragonBones/egret/EgretArmatureDisplay.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/animation/Animation.ts`, `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/armature/Bone.ts`, `DragonBones/src/dragonBones/armature/IArmatureProxy.ts`, `DragonBones/src/dragonBones/armature/Surface.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/event/EventObject.ts`, `DragonBones/src/dragonBones/geom/Matrix.ts`, `DragonBones/src/dragonBones/geom/Rectangle.ts`, `DragonBones/src/dragonBones/model/ArmatureData.ts`, `DragonBones/src/dragonBones/model/BoundingBoxData.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `EgretEvent`

Herança: extends egret.Event.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `eventObject` | método | `public get eventObject(): EventObject` | 48 |

#### ClassDeclaration `EgretArmatureDisplay`

Herança: extends egret.DisplayObjectContainer; implements IArmatureProxy.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `_cleanBeforeRender` | método | `private static _cleanBeforeRender(): void` | 56 |
| `dbInit` | método | `public dbInit(armature: Armature): void` | 76 |
| `dbClear` | método | `public dbClear(): void` | 87 |
| `dbUpdate` | método | `public dbUpdate(): void` | 95 |
| `dispose` | método | `public dispose(disposeProxy: boolean = true): void` | 232 |
| `dispatchDBEvent` | método | `public dispatchDBEvent(type: EventStringType, eventObject: EventObject): void` | 244 |
| `hasDBEventListener` | método | `public hasDBEventListener(type: EventStringType): boolean` | 253 |
| `addDBEventListener` | método | `public addDBEventListener(type: EventStringType, listener: (event: EgretEvent) => void, target: any): void` | 259 |
| `removeDBEventListener` | método | `public removeDBEventListener(type: EventStringType, listener: (event: EgretEvent) => void, target: any): void` | 265 |
| `disableBatch` | método | `public disableBatch(): void` | 283 |
| `armature` | método | `public get armature(): Armature` | 318 |
| `animation` | método | `public get animation(): Animation` | 324 |
| `$measureContentBounds` | método | `$measureContentBounds(bounds: egret.Rectangle): void` | 330 |
| `debugDraw` | propriedade | `public debugDraw: boolean = false;` | 60 |
| `_batchEnabled` | propriedade | `public _batchEnabled: boolean = !(global["nativeRender"] \|\| global["bricks"]);` | 64 |
| `_childDirty` | propriedade | `public _childDirty: boolean = true;` | 68 |
| `_debugDraw` | propriedade | `private _debugDraw: boolean = false;` | 69 |
| `_armature` | propriedade | `private _armature: Armature = null as any;` | 70 |
| `_bounds` | propriedade | `private _bounds: egret.Rectangle \| null = null;` | 71 |
| `_debugDrawer` | propriedade | `private _debugDrawer: egret.Sprite \| null = null;` | 72 |

### `Egret/4.x/src/dragonBones/egret/EgretFactory.ts`

- Origem/commit: `Egret/4.x/src/dragonBones/egret/EgretFactory.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: integrations/Egret/4.x/src/dragonBones/egret/EgretFactory.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/armature/Slot.ts`, `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/factory/BaseFactory.ts`, `DragonBones/src/dragonBones/model/ArmatureData.ts`, `DragonBones/src/dragonBones/parser/DataParser.ts`, `Egret/4.x/src/dragonBones/egret/EgretArmatureDisplay.ts`, `Egret/4.x/src/dragonBones/egret/EgretSlot.ts`, `Egret/4.x/src/dragonBones/egret/EgretTextureAtlasData.ts`, `Phaser/3.x/src/dragonBones/phaser/display/Slot.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `EgretFactory`

Herança: extends BaseFactory.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `_clockHandler` | método | `private static _clockHandler(time: number): boolean` | 44 |
| `factory` | método | `public static get factory(): EgretFactory` | 63 |
| `constructor` | método | `public constructor(dataParser: DataParser \| null = null)` | 73 |
| `_isSupportMesh` | método | `protected _isSupportMesh(): boolean` | 87 |
| `_buildTextureAtlasData` | método | `protected _buildTextureAtlasData(textureAtlasData: EgretTextureAtlasData \| null, textureAtlas: egret.Texture \| HTMLImageElement \| null): EgretTextureAtlasData` | 97 |
| `_buildArmature` | método | `protected _buildArmature(dataPackage: BuildArmaturePackage): Armature` | 116 |
| `_buildSlot` | método | `protected _buildSlot(_dataPackage: BuildArmaturePackage, slotData: SlotData, armature: Armature): Slot` | 128 |
| `buildArmatureDisplay` | método | `public buildArmatureDisplay(armatureName: string, dragonBonesName: string = "", skinName: string = "", textureAtlasName: string = ""): EgretArmatureDisplay \| null` | 171 |
| `getTextureDisplay` | método | `public getTextureDisplay(textureName: string, textureAtlasName: string \| null = null): egret.Bitmap \| null` | 195 |
| `soundEventManager` | método | `public get soundEventManager(): EgretArmatureDisplay` | 220 |
| `_time` | propriedade | `private static _time: number = 0.0;` | 40 |
| `_dragonBonesInstance` | propriedade | `private static _dragonBonesInstance: DragonBones = null as any;` | 41 |
| `_factory` | propriedade | `private static _factory: EgretFactory \| null = null;` | 42 |

### `Egret/4.x/src/dragonBones/egret/EgretSlot.ts`

- Origem/commit: `Egret/4.x/src/dragonBones/egret/EgretSlot.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: integrations/Egret/4.x/src/dragonBones/egret/EgretSlot.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/armature/Bone.ts`, `DragonBones/src/dragonBones/armature/Slot.ts`, `DragonBones/src/dragonBones/armature/Surface.ts`, `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/geom/Matrix.ts`, `DragonBones/src/dragonBones/model/ArmatureData.ts`, `DragonBones/src/dragonBones/model/DisplayData.ts`, `Egret/4.x/src/dragonBones/egret/EgretArmatureDisplay.ts`, `Egret/4.x/src/dragonBones/egret/EgretTextureAtlasData.ts`, `Phaser/3.x/src/dragonBones/phaser/display/Slot.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `EgretSlot`

Herança: extends Slot.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 35 |
| `init` | método | `public init(slotData: SlotData, armatureValue: Armature, rawDisplay: any, meshDisplay: any): void` | 60 |
| `_onClear` | método | `protected _onClear(): void` | 71 |
| `_initDisplay` | método | `protected _initDisplay(value: any, isRetain: boolean): void` | 79 |
| `_disposeDisplay` | método | `protected _disposeDisplay(value: any, isRelease: boolean): void` | 86 |
| `_onUpdateDisplay` | método | `protected _onUpdateDisplay(): void` | 93 |
| `_addDisplay` | método | `protected _addDisplay(): void` | 116 |
| `_replaceDisplay` | método | `protected _replaceDisplay(value: any): void` | 125 |
| `_removeDisplay` | método | `protected _removeDisplay(): void` | 140 |
| `_updateZOrder` | método | `protected _updateZOrder(): void` | 150 |
| `_updateVisible` | método | `public _updateVisible(): void` | 174 |
| `_updateBlendMode` | método | `protected _updateBlendMode(): void` | 186 |
| `_updateColor` | método | `protected _updateColor(): void` | 210 |
| `_updateFrame` | método | `protected _updateFrame(): void` | 267 |
| `_updateMesh` | método | `protected _updateMesh(): void` | 436 |
| `_updateTransform` | método | `protected _updateTransform(): void` | 540 |
| `_identityTransform` | método | `protected _identityTransform(): void` | 544 |
| `_updateTransformV4` | método | `private _updateTransformV4(): void` | 561 |
| `_updateTransformV5` | método | `private _updateTransformV5(): void` | 592 |
| `transformUpdateEnabled` | propriedade | `public transformUpdateEnabled: boolean = false;` | 52 |
| `_armatureDisplay` | propriedade | `private _armatureDisplay: EgretArmatureDisplay = null as any;` | 54 |
| `_renderDisplay` | propriedade | `private _renderDisplay: egret.DisplayObject = null as any;` | 55 |
| `_colorFilter` | propriedade | `private _colorFilter: egret.ColorMatrixFilter \| null = null;` | 56 |

### `Egret/4.x/src/dragonBones/egret/EgretTextureAtlasData.ts`

- Origem/commit: `Egret/4.x/src/dragonBones/egret/EgretTextureAtlasData.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: integrations/Egret/4.x/src/dragonBones/egret/EgretTextureAtlasData.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/model/TextureAtlasData.ts`, `Phaser/3.x/src/dragonBones/phaser/display/TextureAtlasData.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `EgretTextureAtlasData`

Herança: extends TextureAtlasData.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 36 |
| `_onClear` | método | `protected _onClear(): void` | 46 |
| `createTexture` | método | `public createTexture(): TextureData` | 59 |
| `renderTexture` | método | `public get renderTexture(): egret.Texture \| null` | 72 |
| `renderTexture` | método | `public set renderTexture(value: egret.Texture \| null)` | 75 |
| `disposeEnabled` | propriedade | `public disposeEnabled: boolean;` | 42 |
| `_renderTexture` | propriedade | `private _renderTexture: egret.Texture \| null = null;` | 44 |

#### ClassDeclaration `EgretTextureData`

Herança: extends TextureData.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 132 |
| `_onClear` | método | `protected _onClear(): void` | 138 |
| `renderTexture` | propriedade | `public renderTexture: egret.Texture \| null = null;` | 136 |

### `Egret/Demos/src/BaseDemo.ts`

- Origem/commit: `Egret/Demos/src/BaseDemo.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Phaser/Demos/src/BaseDemo.ts`, `Pixi/Demos/4.x/src/BaseDemo.ts`, `Pixi/Demos/8.x/src/BaseDemo.ts`, `ThreeJS/Demos/src/BaseDemo.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `BaseDemo`

Herança: extends egret.DisplayObjectContainer.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 9 |
| `_onStart` | método | `protected abstract _onStart(): void;` | 22 |
| `_updateLoadingText` | método | `private _updateLoadingText(text: string): void` | 24 |
| `_loadResources` | método | `protected _loadResources(): void` | 30 |
| `createText` | método | `public createText(string: string): egret.TextField` | 60 |
| `stageWidth` | método | `public get stageWidth(): number` | 73 |
| `stageHeight` | método | `public get stageHeight(): number` | 77 |
| `BACKGROUND_URL` | propriedade | `private static BACKGROUND_URL: string = "resource/background.png";` | 2 |
| `_loadCount` | propriedade | `protected _loadCount: number = 0;` | 3 |
| `_loadingText` | propriedade | `protected readonly _loadingText: egret.TextField = new egret.TextField();` | 4 |
| `_background` | propriedade | `protected readonly _background: egret.Bitmap = new egret.Bitmap();` | 5 |
| `_resources` | propriedade | `protected readonly _resources: string[] = [];` | 6 |
| `_resourceMap` | propriedade | `protected readonly _resourceMap: any = {};` | 7 |

### `Egret/Demos/src/DragHelper.ts`

- Origem/commit: `Egret/Demos/src/DragHelper.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/Demos/assets/Script/DragHelper.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/geom/Point.ts`, `Egret/4.x/src/dragonBones/egret/EgretArmatureDisplay.ts`, `Phaser/Demos/src/DragHelper.ts`, `Pixi/Demos/4.x/src/DragHelper.ts`, `Pixi/Demos/8.x/src/DragHelper.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `DragHelper`

Herança: nenhuma explícita.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `getInstance` | método | `public static getInstance(): DragHelper` | 3 |
| `enableDrag` | método | `public enableDrag(displayObject: egret.DisplayObject): void` | 11 |
| `disableDrag` | método | `public disableDrag(displayObject: egret.DisplayObject): void` | 18 |
| `_dragHandler` | método | `private _dragHandler(event: egret.TouchEvent): void` | 24 |
| `_instance` | propriedade | `private static _instance: DragHelper = new DragHelper();` | 2 |
| `_helpPoint` | propriedade | `private readonly _helpPoint: egret.Point = new egret.Point();` | 7 |
| `_dragOffset` | propriedade | `private readonly _dragOffset: egret.Point = new egret.Point();` | 8 |
| `_dragDisplayObject` | propriedade | `private _dragDisplayObject: egret.DisplayObject \| null = null;` | 9 |

### `Egret/Demos/src/Main.ts`

- Origem/commit: `Egret/Demos/src/Main.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/Demos/assets/Script/HelloDragonBones.ts`, `Egret/Demos/src/demo/HelloDragonBones.ts`, `Hilo/Demos/src/HelloDragonBones.ts`, `Phaser/Demos/src/HelloDragonBones.ts`, `Pixi/Demos/4.x/src/HelloDragonBones.ts`, `Pixi/Demos/8.x/src/HelloDragonBones.ts`, `ThreeJS/Demos/src/HelloDragonBones.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `Main`

Herança: extends egret.DisplayObjectContainer.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 2 |

### `Egret/Demos/src/demo/AnimationBase.ts`

- Origem/commit: `Egret/Demos/src/demo/AnimationBase.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/Demos/assets/Script/AnimationBase.ts`, `DragonBones/src/dragonBones/event/EventObject.ts`, `Egret/4.x/src/dragonBones/egret/EgretArmatureDisplay.ts`, `Egret/4.x/src/dragonBones/egret/EgretFactory.ts`, `Egret/Demos/src/BaseDemo.ts`, `Phaser/Demos/src/AnimationBase.ts`, `Phaser/Demos/src/BaseDemo.ts`, `Pixi/Demos/4.x/src/AnimationBase.ts`, `Pixi/Demos/4.x/src/BaseDemo.ts`, `Pixi/Demos/8.x/src/AnimationBase.ts`, `Pixi/Demos/8.x/src/BaseDemo.ts`, `ThreeJS/Demos/src/BaseDemo.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `AnimationBase`

Herança: extends BaseDemo.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 4 |
| `_onStart` | método | `protected _onStart(): void` | 14 |
| `_touchHandler` | método | `private _touchHandler(event: egret.TouchEvent): void` | 41 |
| `_animationEventHandler` | método | `private _animationEventHandler(event: dragonBones.EgretEvent): void` | 63 |
| `_armatureDisplay` | propriedade | `private _armatureDisplay: dragonBones.EgretArmatureDisplay;` | 2 |

### `Egret/Demos/src/demo/AnimationLayer.ts`

- Origem/commit: `Egret/Demos/src/demo/AnimationLayer.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/Demos/assets/Script/AnimationLayer.ts`, `DragonBones/src/dragonBones/event/EventObject.ts`, `Egret/4.x/src/dragonBones/egret/EgretArmatureDisplay.ts`, `Egret/4.x/src/dragonBones/egret/EgretFactory.ts`, `Egret/Demos/src/BaseDemo.ts`, `Phaser/Demos/src/AnimationLayer.ts`, `Phaser/Demos/src/BaseDemo.ts`, `Pixi/Demos/4.x/src/AnimationLayer.ts`, `Pixi/Demos/4.x/src/BaseDemo.ts`, `Pixi/Demos/8.x/src/AnimationLayer.ts`, `Pixi/Demos/8.x/src/BaseDemo.ts`, `ThreeJS/Demos/src/BaseDemo.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `AnimationLayer`

Herança: extends BaseDemo.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 4 |
| `_onStart` | método | `protected _onStart(): void` | 14 |
| `_animationEventHandler` | método | `private _animationEventHandler(event:dragonBones.EgretEvent): void` | 28 |
| `_armatureDisplay` | propriedade | `private _armatureDisplay: dragonBones.EgretArmatureDisplay;` | 2 |

### `Egret/Demos/src/demo/BoneOffset.ts`

- Origem/commit: `Egret/Demos/src/demo/BoneOffset.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/Demos/assets/Script/BoneOffset.ts`, `DragonBones/src/dragonBones/event/EventObject.ts`, `Egret/4.x/src/dragonBones/egret/EgretArmatureDisplay.ts`, `Egret/4.x/src/dragonBones/egret/EgretFactory.ts`, `Egret/Demos/src/BaseDemo.ts`, `Phaser/Demos/src/BaseDemo.ts`, `Phaser/Demos/src/BoneOffset.ts`, `Pixi/Demos/4.x/src/BaseDemo.ts`, `Pixi/Demos/4.x/src/BoneOffset.ts`, `Pixi/Demos/8.x/src/BaseDemo.ts`, `Pixi/Demos/8.x/src/BoneOffset.ts`, `ThreeJS/Demos/src/BaseDemo.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `BoneOffset`

Herança: extends BaseDemo.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 2 |
| `_onStart` | método | `protected _onStart(): void` | 12 |
| `_animationHandler` | método | `private _animationHandler(event: dragonBones.EgretEvent): void` | 28 |
| `_moveTo` | método | `private _moveTo(armatureDisplay: dragonBones.EgretArmatureDisplay): void` | 32 |

### `Egret/Demos/src/demo/BoundingBox.ts`

- Origem/commit: `Egret/Demos/src/demo/BoundingBox.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/Demos/assets/Script/BoundingBox.ts`, `Cocos/Demos/assets/Script/DragHelper.ts`, `DragonBones/src/dragonBones/armature/Bone.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/geom/Point.ts`, `Egret/4.x/src/dragonBones/egret/EgretArmatureDisplay.ts`, `Egret/4.x/src/dragonBones/egret/EgretFactory.ts`, `Egret/Demos/src/BaseDemo.ts`, `Egret/Demos/src/DragHelper.ts`, `Phaser/Demos/src/BaseDemo.ts`, `Phaser/Demos/src/BoundingBox.ts`, `Phaser/Demos/src/DragHelper.ts`, `Pixi/Demos/4.x/src/BaseDemo.ts`, `Pixi/Demos/4.x/src/BoundingBox.ts`, `Pixi/Demos/4.x/src/DragHelper.ts`, `Pixi/Demos/8.x/src/BaseDemo.ts`, `Pixi/Demos/8.x/src/BoundingBox.ts`, `Pixi/Demos/8.x/src/DragHelper.ts`, `ThreeJS/Demos/src/BaseDemo.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `BoundingBox`

Herança: extends BaseDemo.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 14 |
| `_onStart` | método | `protected _onStart(): void` | 27 |
| `_enterFrameHandler` | método | `private _enterFrameHandler(event: egret.Event): void` | 65 |
| `_helpPointA` | propriedade | `private readonly _helpPointA: egret.Point = new egret.Point();` | 2 |
| `_helpPointB` | propriedade | `private readonly _helpPointB: egret.Point = new egret.Point();` | 3 |
| `_helpPointC` | propriedade | `private readonly _helpPointC: egret.Point = new egret.Point();` | 4 |
| `_armatureDisplay` | propriedade | `private _armatureDisplay: dragonBones.EgretArmatureDisplay;` | 6 |
| `_boundingBoxTester` | propriedade | `private _boundingBoxTester: dragonBones.EgretArmatureDisplay;` | 7 |
| `_targetA` | propriedade | `private _targetA: dragonBones.EgretArmatureDisplay;` | 8 |
| `_targetB` | propriedade | `private _targetB: dragonBones.EgretArmatureDisplay;` | 9 |
| `_line` | propriedade | `private _line: dragonBones.Bone;` | 10 |
| `_pointA` | propriedade | `private _pointA: dragonBones.Bone;` | 11 |
| `_pointB` | propriedade | `private _pointB: dragonBones.Bone;` | 12 |

### `Egret/Demos/src/demo/CoreElement.ts`

- Origem/commit: `Egret/Demos/src/demo/CoreElement.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/Demos/assets/Script/CoreElement.ts`, `DragonBones/src/dragonBones/animation/AnimationState.ts`, `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/event/EventObject.ts`, `DragonBones/src/dragonBones/geom/Point.ts`, `Egret/4.x/src/dragonBones/egret/EgretArmatureDisplay.ts`, `Egret/4.x/src/dragonBones/egret/EgretFactory.ts`, `Egret/Demos/src/BaseDemo.ts`, `Phaser/Demos/src/BaseDemo.ts`, `Phaser/Demos/src/CoreElement.ts`, `Pixi/Demos/4.x/src/BaseDemo.ts`, `Pixi/Demos/4.x/src/CoreElement.ts`, `Pixi/Demos/8.x/src/BaseDemo.ts`, `Pixi/Demos/8.x/src/CoreElement.ts`, `ThreeJS/Demos/src/BaseDemo.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `Game`

Herança: extends BaseDemo.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 16 |
| `_onStart` | método | `protected _onStart(): void` | 32 |
| `_touchHandler` | método | `private _touchHandler(event: egret.TouchEvent): void` | 60 |
| `_keyHandler` | método | `private _keyHandler(event: KeyboardEvent): void` | 71 |
| `_enterFrameHandler` | método | `private _enterFrameHandler(event: egret.Event): void` | 118 |
| `_updateMove` | método | `private _updateMove(dir: number): void` | 132 |
| `addBullet` | método | `public addBullet(bullet: Bullet): void` | 147 |
| `GROUND` | propriedade | `public static GROUND: number;` | 7 |
| `G` | propriedade | `public static G: number = 0.6;` | 8 |
| `instance` | propriedade | `public static instance: Game;` | 9 |
| `_left` | propriedade | `private _left: boolean = false;` | 11 |
| `_right` | propriedade | `private _right: boolean = false;` | 12 |
| `_player` | propriedade | `private _player: Mecha;` | 13 |
| `_bullets` | propriedade | `private readonly _bullets: Array<Bullet> = [];` | 14 |

#### ClassDeclaration `Mecha`

Herança: nenhuma explícita.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 187 |
| `move` | método | `public move(dir: number): void` | 211 |
| `jump` | método | `public jump(): void` | 220 |
| `squat` | método | `public squat(isSquating: boolean): void` | 234 |
| `attack` | método | `public attack(isAttacking: boolean): void` | 243 |
| `switchWeaponL` | método | `public switchWeaponL(): void` | 251 |
| `switchWeaponR` | método | `public switchWeaponR(): void` | 271 |
| `switchSkin` | método | `public switchSkin(): void` | 291 |
| `aim` | método | `public aim(x: number, y: number): void` | 299 |
| `update` | método | `public update(): void` | 304 |
| `_animationEventHandler` | método | `private _animationEventHandler(event: EventType): void` | 310 |
| `_frameEventHandler` | método | `private _frameEventHandler(event: EventType): void` | 348 |
| `_fire` | método | `private _fire(firePoint: PointType): void` | 356 |
| `_updateAnimation` | método | `private _updateAnimation(): void` | 362 |
| `_updatePosition` | método | `private _updatePosition(): void` | 413 |
| `_updateAim` | método | `private _updateAim(): void` | 446 |
| `_updateAttack` | método | `private _updateAttack(): void` | 499 |
| `JUMP_SPEED` | propriedade | `private static readonly JUMP_SPEED: number = 20;` | 153 |
| `NORMALIZE_MOVE_SPEED` | propriedade | `private static readonly NORMALIZE_MOVE_SPEED: number = 3.6;` | 154 |
| `MAX_MOVE_SPEED_FRONT` | propriedade | `private static readonly MAX_MOVE_SPEED_FRONT: number = Mecha.NORMALIZE_MOVE_SPEED * 1.4;` | 155 |
| `MAX_MOVE_SPEED_BACK` | propriedade | `private static readonly MAX_MOVE_SPEED_BACK: number = Mecha.NORMALIZE_MOVE_SPEED * 1.0;` | 156 |
| `NORMAL_ANIMATION_GROUP` | propriedade | `private static readonly NORMAL_ANIMATION_GROUP: string = "normal";` | 157 |
| `AIM_ANIMATION_GROUP` | propriedade | `private static readonly AIM_ANIMATION_GROUP: string = "aim";` | 158 |
| `ATTACK_ANIMATION_GROUP` | propriedade | `private static readonly ATTACK_ANIMATION_GROUP: string = "attack";` | 159 |
| `WEAPON_L_LIST` | propriedade | `private static readonly WEAPON_L_LIST: Array<string> = ["weapon_1502b_l", "weapon_1005", "weapon_1005b", "weapon_1005c", "weapon_1005d", "weapon_1005e", ""];` | 160 |
| `WEAPON_R_LIST` | propriedade | `private static readonly WEAPON_R_LIST: Array<string> = ["weapon_1502b_r", "weapon_1005", "weapon_1005b", "weapon_1005c", "weapon_1005d", ""];` | 161 |
| `SKINS` | propriedade | `private static readonly SKINS: Array<string> = ["mecha_1502b", "skin_a", "skin_b", "skin_c"];` | 162 |
| `_isJumpingA` | propriedade | `private _isJumpingA: boolean = false;` | 164 |
| `_isSquating` | propriedade | `private _isSquating: boolean = false;` | 165 |
| `_isAttackingA` | propriedade | `private _isAttackingA: boolean = false;` | 166 |
| `_isAttackingB` | propriedade | `private _isAttackingB: boolean = false;` | 167 |
| `_weaponRIndex` | propriedade | `private _weaponRIndex: number = 0;` | 168 |
| `_weaponLIndex` | propriedade | `private _weaponLIndex: number = 0;` | 169 |
| `_skinIndex` | propriedade | `private _skinIndex: number = 0;` | 170 |
| `_faceDir` | propriedade | `private _faceDir: number = 1;` | 171 |
| `_aimDir` | propriedade | `private _aimDir: number = 0;` | 172 |
| `_moveDir` | propriedade | `private _moveDir: number = 0;` | 173 |
| `_aimRadian` | propriedade | `private _aimRadian: number = 0.0;` | 174 |
| `_speedX` | propriedade | `private _speedX: number = 0.0;` | 175 |
| `_speedY` | propriedade | `private _speedY: number = 0.0;` | 176 |
| `_armature` | propriedade | `private _armature: dragonBones.Armature;` | 177 |
| `_armatureDisplay` | propriedade | `private _armatureDisplay: ArmatureDisplayType;` | 178 |
| `_weaponL` | propriedade | `private _weaponL: dragonBones.Armature \| null = null;` | 179 |
| `_weaponR` | propriedade | `private _weaponR: dragonBones.Armature \| null = null;` | 180 |
| `_aimState` | propriedade | `private _aimState: dragonBones.AnimationState \| null = null;` | 181 |
| `_walkState` | propriedade | `private _walkState: dragonBones.AnimationState \| null = null;` | 182 |
| `_attackState` | propriedade | `private _attackState: dragonBones.AnimationState \| null = null;` | 183 |
| `_target` | propriedade | `private readonly _target: PointType = new egret.Point();` | 184 |
| `_helpPoint` | propriedade | `private readonly _helpPoint: PointType = new egret.Point();` | 185 |

#### ClassDeclaration `Bullet`

Herança: nenhuma explícita.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor(armatureName: string, effectArmatureName: string \| null, radian: number, speed: number, position: PointType)` | 522 |
| `update` | método | `public update(): boolean` | 551 |
| `_speedX` | propriedade | `private _speedX: number = 0.0;` | 516 |
| `_speedY` | propriedade | `private _speedY: number = 0.0;` | 517 |
| `_armatureDisplay` | propriedade | `private _armatureDisplay: ArmatureDisplayType;` | 519 |
| `_effecDisplay` | propriedade | `private _effecDisplay: ArmatureDisplayType \| null = null;` | 520 |

### `Egret/Demos/src/demo/DragonBonesEvent.ts`

- Origem/commit: `Egret/Demos/src/demo/DragonBonesEvent.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/Demos/assets/Script/DragonBonesEvent.ts`, `DragonBones/src/dragonBones/event/EventObject.ts`, `Egret/4.x/src/dragonBones/egret/EgretArmatureDisplay.ts`, `Egret/4.x/src/dragonBones/egret/EgretFactory.ts`, `Egret/Demos/src/BaseDemo.ts`, `Phaser/Demos/src/BaseDemo.ts`, `Phaser/Demos/src/DragonBonesEvent.ts`, `Pixi/Demos/4.x/src/BaseDemo.ts`, `Pixi/Demos/4.x/src/DragonBonesEvent.ts`, `Pixi/Demos/8.x/src/BaseDemo.ts`, `Pixi/Demos/8.x/src/DragonBonesEvent.ts`, `ThreeJS/Demos/src/BaseDemo.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `DragonBonesEvent`

Herança: extends BaseDemo.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 4 |
| `_onStart` | método | `protected _onStart(): void` | 14 |
| `_soundEventHandler` | método | `private _soundEventHandler(event: dragonBones.EgretEvent): void` | 35 |
| `_animationEventHandler` | método | `private _animationEventHandler(event: dragonBones.EgretEvent): void` | 40 |
| `_armatureDisplay` | propriedade | `private _armatureDisplay: dragonBones.EgretArmatureDisplay;` | 2 |

### `Egret/Demos/src/demo/EyeTracking.ts`

- Origem/commit: `Egret/Demos/src/demo/EyeTracking.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/Demos/assets/Script/EyeTracking.ts`, `DragonBones/src/dragonBones/geom/Point.ts`, `Egret/4.x/src/dragonBones/egret/EgretArmatureDisplay.ts`, `Egret/4.x/src/dragonBones/egret/EgretFactory.ts`, `Egret/Demos/src/BaseDemo.ts`, `Phaser/Demos/src/BaseDemo.ts`, `Pixi/Demos/4.x/src/BaseDemo.ts`, `Pixi/Demos/4.x/src/EyeTracking.ts`, `Pixi/Demos/8.x/src/BaseDemo.ts`, `Pixi/Demos/8.x/src/EyeTracking.ts`, `ThreeJS/Demos/src/BaseDemo.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `EyeTracking`

Herança: extends BaseDemo.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 20 |
| `_onStart` | método | `protected _onStart(): void` | 32 |
| `_setTarget` | método | `private _setTarget(x: number, y: number)` | 63 |
| `_enterFrameHandler` | método | `protected _enterFrameHandler(_event: egret.Event): void` | 68 |
| `_scale` | propriedade | `private _scale: number = 0.3;` | 2 |
| `_target` | propriedade | `private readonly _target: egret.Point = new egret.Point();` | 3 |
| `_animationNames` | propriedade | `private readonly _animationNames: string[] = [ "PARAM_ANGLE_X", "PARAM_ANGLE_Y", "PARAM_ANGLE_Z", "PARAM_EYE_BALL_X", "PARAM_EYE_BALL_Y", "PARAM_BODY_X", "PARAM_BODY_Y", "PARAM_BODY_Z", "PARAM_BODY_ANGLE_X", "PARAM_BODY_ANGLE_Y", "PARAM_BODY_ANGLE_Z", "PARAM_BREATH", ];` | 4 |
| `_armatureDisplay` | propriedade | `private _armatureDisplay: dragonBones.EgretArmatureDisplay;` | 18 |

### `Egret/Demos/src/demo/HelloDragonBones.ts`

- Origem/commit: `Egret/Demos/src/demo/HelloDragonBones.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/Demos/assets/Script/HelloDragonBones.ts`, `Egret/4.x/src/dragonBones/egret/EgretFactory.ts`, `Egret/Demos/src/BaseDemo.ts`, `Hilo/Demos/src/HelloDragonBones.ts`, `Phaser/Demos/src/BaseDemo.ts`, `Phaser/Demos/src/HelloDragonBones.ts`, `Pixi/Demos/4.x/src/BaseDemo.ts`, `Pixi/Demos/4.x/src/HelloDragonBones.ts`, `Pixi/Demos/8.x/src/BaseDemo.ts`, `Pixi/Demos/8.x/src/HelloDragonBones.ts`, `ThreeJS/Demos/src/BaseDemo.ts`, `ThreeJS/Demos/src/HelloDragonBones.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `HelloDragonBones`

Herança: extends BaseDemo.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 19 |
| `_onStart` | método | `protected _onStart(): void` | 30 |

### `Egret/Demos/src/demo/InverseKinematics.ts`

- Origem/commit: `Egret/Demos/src/demo/InverseKinematics.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/Demos/assets/Script/DragHelper.ts`, `Cocos/Demos/assets/Script/InverseKinematics.ts`, `DragonBones/src/dragonBones/animation/AnimationState.ts`, `DragonBones/src/dragonBones/armature/Bone.ts`, `DragonBones/src/dragonBones/geom/Point.ts`, `DragonBones/src/dragonBones/geom/Transform.ts`, `Egret/4.x/src/dragonBones/egret/EgretArmatureDisplay.ts`, `Egret/4.x/src/dragonBones/egret/EgretFactory.ts`, `Egret/Demos/src/BaseDemo.ts`, `Egret/Demos/src/DragHelper.ts`, `Phaser/Demos/src/BaseDemo.ts`, `Phaser/Demos/src/DragHelper.ts`, `Phaser/Demos/src/InverseKinematics.ts`, `Pixi/Demos/4.x/src/BaseDemo.ts`, `Pixi/Demos/4.x/src/DragHelper.ts`, `Pixi/Demos/4.x/src/InverseKinematics.ts`, `Pixi/Demos/8.x/src/BaseDemo.ts`, `Pixi/Demos/8.x/src/DragHelper.ts`, `Pixi/Demos/8.x/src/InverseKinematics.ts`, `ThreeJS/Demos/src/BaseDemo.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `InverseKinematics`

Herança: extends BaseDemo.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 15 |
| `_onStart` | método | `protected _onStart(): void` | 28 |
| `_enterFrameHandler` | método | `private _enterFrameHandler(event: egret.Event): void` | 69 |
| `_updateAim` | método | `private _updateAim(): void` | 74 |
| `_updateFoot` | método | `private _updateFoot(): void` | 98 |
| `_faceDir` | propriedade | `private _faceDir: number = 0;` | 2 |
| `_aimRadian` | propriedade | `private _aimRadian: number = 0.0;` | 3 |
| `_offsetRotation` | propriedade | `private _offsetRotation: number = 0.0;` | 4 |
| `_target` | propriedade | `private readonly _target: egret.Point = new egret.Point();` | 5 |
| `_armatureDisplay` | propriedade | `private _armatureDisplay: dragonBones.EgretArmatureDisplay;` | 6 |
| `_floorBoard` | propriedade | `private _floorBoard: dragonBones.EgretArmatureDisplay;` | 7 |
| `_chestBone` | propriedade | `private _chestBone: dragonBones.Bone;` | 8 |
| `_leftFootBone` | propriedade | `private _leftFootBone: dragonBones.Bone;` | 9 |
| `_rightFootBone` | propriedade | `private _rightFootBone: dragonBones.Bone;` | 10 |
| `_circleBone` | propriedade | `private _circleBone: dragonBones.Bone;` | 11 |
| `_floorBoardBone` | propriedade | `private _floorBoardBone: dragonBones.Bone;` | 12 |
| `_aimState` | propriedade | `private _aimState: dragonBones.AnimationState;` | 13 |

### `Egret/Demos/src/demo/MultiTextureAltas.ts`

- Origem/commit: `Egret/Demos/src/demo/MultiTextureAltas.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/Demos/assets/Script/MultiTextureAltas.ts`, `Egret/4.x/src/dragonBones/egret/EgretArmatureDisplay.ts`, `Egret/4.x/src/dragonBones/egret/EgretFactory.ts`, `Egret/Demos/src/BaseDemo.ts`, `Phaser/Demos/src/BaseDemo.ts`, `Pixi/Demos/4.x/src/BaseDemo.ts`, `Pixi/Demos/4.x/src/MultiTextureAltas.ts`, `Pixi/Demos/8.x/src/BaseDemo.ts`, `Pixi/Demos/8.x/src/MultiTextureAltas.ts`, `ThreeJS/Demos/src/BaseDemo.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `MultiTextureAltas`

Herança: extends BaseDemo.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 7 |
| `_onStart` | método | `protected _onStart(): void` | 19 |
| `_changeAnimation` | método | `private _changeAnimation(): void` | 52 |
| `_armatureDisplayA` | propriedade | `private _armatureDisplayA: dragonBones.EgretArmatureDisplay;` | 2 |
| `_armatureDisplayB` | propriedade | `private _armatureDisplayB: dragonBones.EgretArmatureDisplay;` | 3 |
| `_armatureDisplayC` | propriedade | `private _armatureDisplayC: dragonBones.EgretArmatureDisplay;` | 4 |
| `_armatureDisplayD` | propriedade | `private _armatureDisplayD: dragonBones.EgretArmatureDisplay;` | 5 |

### `Egret/Demos/src/demo/PerformanceTest.ts`

- Origem/commit: `Egret/Demos/src/demo/PerformanceTest.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/Demos/assets/Script/PerformanceTest.ts`, `DragonBones/src/dragonBones/core/BaseObject.ts`, `Egret/4.x/src/dragonBones/egret/EgretArmatureDisplay.ts`, `Egret/4.x/src/dragonBones/egret/EgretFactory.ts`, `Egret/Demos/src/BaseDemo.ts`, `Hilo/Demos/src/PerformanceTest.ts`, `Phaser/Demos/src/BaseDemo.ts`, `Phaser/Demos/src/PerformanceTest.ts`, `Pixi/Demos/4.x/src/BaseDemo.ts`, `Pixi/Demos/4.x/src/PerformanceTest.ts`, `Pixi/Demos/8.x/src/BaseDemo.ts`, `Pixi/Demos/8.x/src/PerformanceTest.ts`, `ThreeJS/Demos/src/BaseDemo.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `PerformanceTest`

Herança: extends BaseDemo.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 7 |
| `_onStart` | método | `protected _onStart(): void` | 17 |
| `_enterFrameHandler` | método | `private _enterFrameHandler(event: egret.Event): void` | 32 |
| `_touchHandler` | método | `private _touchHandler(event: egret.TouchEvent): void` | 52 |
| `_addArmature` | método | `private _addArmature(): void` | 67 |
| `_removeArmature` | método | `private _removeArmature(): void` | 83 |
| `_resetPosition` | método | `private _resetPosition(): void` | 98 |
| `_updateText` | método | `private _updateText(): void` | 122 |
| `_addingArmature` | propriedade | `private _addingArmature: boolean = false;` | 2 |
| `_removingArmature` | propriedade | `private _removingArmature: boolean = false;` | 3 |
| `_armatures` | propriedade | `private readonly _armatures: Array<dragonBones.EgretArmatureDisplay> = [];` | 4 |
| `_text` | propriedade | `private _text: egret.TextField;` | 5 |

### `Egret/Demos/src/demo/ReplaceAnimation.ts`

- Origem/commit: `Egret/Demos/src/demo/ReplaceAnimation.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Egret/4.x/src/dragonBones/egret/EgretArmatureDisplay.ts`, `Egret/4.x/src/dragonBones/egret/EgretFactory.ts`, `Egret/Demos/src/BaseDemo.ts`, `Hilo/Demos/src/ReplaceAnimation.ts`, `Phaser/Demos/src/BaseDemo.ts`, `Phaser/Demos/src/ReplaceAnimation.ts`, `Pixi/Demos/4.x/src/BaseDemo.ts`, `Pixi/Demos/4.x/src/ReplaceAnimation.ts`, `Pixi/Demos/8.x/src/BaseDemo.ts`, `Pixi/Demos/8.x/src/ReplaceAnimation.ts`, `ThreeJS/Demos/src/BaseDemo.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `ReplaceAnimation`

Herança: extends BaseDemo.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 7 |
| `_onStart` | método | `protected _onStart(): void` | 17 |
| `_changeAnimation` | método | `private _changeAnimation(): void` | 53 |
| `_armatureDisplayA` | propriedade | `private _armatureDisplayA: dragonBones.EgretArmatureDisplay;` | 2 |
| `_armatureDisplayB` | propriedade | `private _armatureDisplayB: dragonBones.EgretArmatureDisplay;` | 3 |
| `_armatureDisplayC` | propriedade | `private _armatureDisplayC: dragonBones.EgretArmatureDisplay;` | 4 |
| `_armatureDisplayD` | propriedade | `private _armatureDisplayD: dragonBones.EgretArmatureDisplay;` | 5 |

### `Egret/Demos/src/demo/ReplaceSkin.ts`

- Origem/commit: `Egret/Demos/src/demo/ReplaceSkin.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/Demos/assets/Script/ReplaceSkin.ts`, `DragonBones/src/dragonBones/event/EventObject.ts`, `Egret/4.x/src/dragonBones/egret/EgretArmatureDisplay.ts`, `Egret/4.x/src/dragonBones/egret/EgretFactory.ts`, `Egret/Demos/src/BaseDemo.ts`, `Phaser/Demos/src/BaseDemo.ts`, `Pixi/Demos/4.x/src/BaseDemo.ts`, `Pixi/Demos/4.x/src/ReplaceSkin.ts`, `Pixi/Demos/8.x/src/BaseDemo.ts`, `Pixi/Demos/8.x/src/ReplaceSkin.ts`, `ThreeJS/Demos/src/BaseDemo.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `ReplaceSkin`

Herança: extends BaseDemo.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 8 |
| `_onStart` | método | `protected _onStart(): void` | 52 |
| `_animationEventHandler` | método | `private _animationEventHandler(event: dragonBones.EgretEvent): void` | 89 |
| `_randomReplaceSkin` | método | `private _randomReplaceSkin(): void` | 105 |
| `_replaceSuitIndex` | propriedade | `private _replaceSuitIndex: number = 0;` | 2 |
| `_factory` | propriedade | `private readonly _factory: dragonBones.EgretFactory = dragonBones.EgretFactory.factory;` | 3 |
| `_suitConfigs` | propriedade | `private readonly _suitConfigs: string[][] = [];` | 4 |
| `_replaceSuitParts` | propriedade | `private readonly _replaceSuitParts: string[] = [];` | 5 |
| `_armatureDisplay` | propriedade | `private _armatureDisplay: dragonBones.EgretArmatureDisplay;` | 6 |

### `Egret/Demos/src/demo/ReplaceSlotDisplay.ts`

- Origem/commit: `Egret/Demos/src/demo/ReplaceSlotDisplay.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/Demos/assets/Script/ReplaceAnimation.ts`, `Cocos/Demos/assets/Script/ReplaceSlotDisplay.ts`, `Egret/4.x/src/dragonBones/egret/EgretArmatureDisplay.ts`, `Egret/4.x/src/dragonBones/egret/EgretFactory.ts`, `Egret/Demos/src/BaseDemo.ts`, `Hilo/Demos/src/ReplaceSlotDisplay.ts`, `Phaser/Demos/src/BaseDemo.ts`, `Phaser/Demos/src/ReplaceSlotDisplay.ts`, `Pixi/Demos/4.x/src/BaseDemo.ts`, `Pixi/Demos/4.x/src/ReplaceSlotDisplay.ts`, `Pixi/Demos/8.x/src/BaseDemo.ts`, `Pixi/Demos/8.x/src/ReplaceSlotDisplay.ts`, `ThreeJS/Demos/src/BaseDemo.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `ReplaceSlotDisplay`

Herança: extends BaseDemo.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 10 |
| `_onStart` | método | `protected _onStart(): void` | 23 |
| `_replaceDisplay` | método | `private _replaceDisplay(type: number): void` | 52 |
| `WEAPON_RIGHT_LIST` | propriedade | `private static readonly WEAPON_RIGHT_LIST: string[] = ["weapon_1004_r", "weapon_1004b_r", "weapon_1004c_r", "weapon_1004d_r", "weapon_1004e_r"];` | 2 |
| `_leftWeaponIndex` | propriedade | `private _leftWeaponIndex: number = 0;` | 4 |
| `_rightWeaponIndex` | propriedade | `private _rightWeaponIndex: number = 0;` | 5 |
| `_factory` | propriedade | `private readonly _factory: dragonBones.EgretFactory = dragonBones.EgretFactory.factory;` | 6 |
| `_armatureDisplay` | propriedade | `private _armatureDisplay: dragonBones.EgretArmatureDisplay;` | 7 |
| `_logoText` | propriedade | `private _logoText: egret.TextField;` | 8 |

### `Hilo/1.x/src/dragonBones/hilo/HiloArmatureDisplay.ts`

- Origem/commit: `Hilo/1.x/src/dragonBones/hilo/HiloArmatureDisplay.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: integrations/Hilo/1.x/src/dragonBones/hilo/HiloArmatureDisplay.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/animation/Animation.ts`, `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/armature/IArmatureProxy.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/event/EventObject.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `HiloArmatureDisplay`

Herança: extends Hilo.Container; implements IArmatureProxy.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `dbInit` | método | `public dbInit(armature: Armature): void` | 37 |
| `dbClear` | método | `public dbClear(): void` | 43 |
| `dbUpdate` | método | `public dbUpdate(): void` | 49 |
| `dispose` | método | `public dispose(disposeProxy: boolean = true): void` | 59 |
| `dispatchDBEvent` | método | `public dispatchDBEvent(type: EventStringType, eventObject: EventObject): void` | 71 |
| `hasDBEventListener` | método | `public hasDBEventListener(type: EventStringType): boolean` | 77 |
| `addDBEventListener` | método | `public addDBEventListener(type: EventStringType, listener: (event: EventObject) => void, target: any): void` | 86 |
| `removeDBEventListener` | método | `public removeDBEventListener(type: EventStringType, listener: (event: EventObject) => void, target: any): void` | 95 |
| `armature` | método | `public get armature(): Armature` | 103 |
| `animation` | método | `public get animation(): Animation` | 109 |
| `hasEvent` | método | `public hasEvent(type: EventStringType): boolean` | 116 |
| `addEvent` | método | `public addEvent(type: EventStringType, listener: (event: EventObject) => void, target: any): void` | 122 |
| `removeEvent` | método | `public removeEvent(type: EventStringType, listener: (event: EventObject) => void, target: any): void` | 128 |
| `debugDraw` | propriedade | `public debugDraw: boolean = false;` | 31 |
| `_debugDraw` | propriedade | `private _debugDraw: boolean = false;` | 32 |
| `_armature` | propriedade | `private _armature: Armature = null as any;` | 33 |

### `Hilo/1.x/src/dragonBones/hilo/HiloFactory.ts`

- Origem/commit: `Hilo/1.x/src/dragonBones/hilo/HiloFactory.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: integrations/Hilo/1.x/src/dragonBones/hilo/HiloFactory.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/armature/Slot.ts`, `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/factory/BaseFactory.ts`, `DragonBones/src/dragonBones/model/ArmatureData.ts`, `DragonBones/src/dragonBones/parser/DataParser.ts`, `Hilo/1.x/src/dragonBones/hilo/HiloArmatureDisplay.ts`, `Hilo/1.x/src/dragonBones/hilo/HiloSlot.ts`, `Hilo/1.x/src/dragonBones/hilo/HiloTextureAtlasData.ts`, `Phaser/3.x/src/dragonBones/phaser/display/Slot.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `HiloFactory`

Herança: extends BaseFactory.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `_createDragonBones` | método | `private static _createDragonBones(): DragonBones` | 39 |
| `factory` | método | `public static get factory(): HiloFactory` | 58 |
| `constructor` | método | `public constructor(dataParser: DataParser \| null = null)` | 68 |
| `_isSupportMesh` | método | `protected _isSupportMesh(): boolean` | 78 |
| `_buildTextureAtlasData` | método | `protected _buildTextureAtlasData(textureAtlasData: HiloTextureAtlasData \| null, textureAtlas: HTMLImageElement \| null): HiloTextureAtlasData` | 84 |
| `_buildArmature` | método | `protected _buildArmature(dataPackage: BuildArmaturePackage): Armature` | 95 |
| `_buildSlot` | método | `protected _buildSlot(dataPackage: BuildArmaturePackage, slotData: SlotData, armature: Armature): Slot` | 107 |
| `buildArmatureDisplay` | método | `public buildArmatureDisplay(armatureName: string, dragonBonesName: string = "", skinName: string = "", textureAtlasName: string = ""): HiloArmatureDisplay \| null` | 151 |
| `getTextureDisplay` | método | `public getTextureDisplay(textureName: string, textureAtlasName: string \| null = null): Hilo.Bitmap \| null` | 175 |
| `soundEventManager` | método | `public get soundEventManager(): HiloArmatureDisplay` | 201 |
| `_dragonBonesInstance` | propriedade | `private static _dragonBonesInstance: DragonBones = null as any;` | 36 |
| `_factory` | propriedade | `private static _factory: HiloFactory = null as any;` | 37 |

### `Hilo/1.x/src/dragonBones/hilo/HiloSlot.ts`

- Origem/commit: `Hilo/1.x/src/dragonBones/hilo/HiloSlot.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: integrations/Hilo/1.x/src/dragonBones/hilo/HiloSlot.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/armature/Slot.ts`, `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/geom/Transform.ts`, `Hilo/1.x/src/dragonBones/hilo/HiloArmatureDisplay.ts`, `Hilo/1.x/src/dragonBones/hilo/HiloTextureAtlasData.ts`, `Phaser/3.x/src/dragonBones/phaser/display/Slot.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `HiloSlot`

Herança: extends Slot.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 36 |
| `_onClear` | método | `protected _onClear(): void` | 43 |
| `_initDisplay` | método | `protected _initDisplay(value: any, isRetain: boolean): void` | 50 |
| `_disposeDisplay` | método | `protected _disposeDisplay(value: any, isRelease: boolean): void` | 57 |
| `_onUpdateDisplay` | método | `protected _onUpdateDisplay(): void` | 64 |
| `_addDisplay` | método | `protected _addDisplay(): void` | 68 |
| `_replaceDisplay` | método | `protected _replaceDisplay(value: any): void` | 73 |
| `_removeDisplay` | método | `protected _removeDisplay(): void` | 82 |
| `_updateZOrder` | método | `protected _updateZOrder(): void` | 86 |
| `_updateVisible` | método | `public _updateVisible(): void` | 98 |
| `_updateBlendMode` | método | `protected _updateBlendMode(): void` | 102 |
| `_updateColor` | método | `protected _updateColor(): void` | 106 |
| `_updateFrame` | método | `protected _updateFrame(): void` | 113 |
| `_updateMesh` | método | `protected _updateMesh(): void` | 161 |
| `_updateTransform` | método | `protected _updateTransform(): void` | 165 |
| `_identityTransform` | método | `protected _identityTransform(): void` | 190 |
| `_textureScale` | propriedade | `private _textureScale: number;` | 40 |
| `_renderDisplay` | propriedade | `private _renderDisplay: Hilo.View;` | 41 |

### `Hilo/1.x/src/dragonBones/hilo/HiloTextureAtlasData.ts`

- Origem/commit: `Hilo/1.x/src/dragonBones/hilo/HiloTextureAtlasData.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: integrations/Hilo/1.x/src/dragonBones/hilo/HiloTextureAtlasData.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/model/TextureAtlasData.ts`, `Phaser/3.x/src/dragonBones/phaser/display/TextureAtlasData.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `HiloTextureAtlasData`

Herança: extends TextureAtlasData.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 36 |
| `_onClear` | método | `protected _onClear(): void` | 42 |
| `createTexture` | método | `public createTexture(): TextureData` | 54 |
| `renderTexture` | método | `public get renderTexture(): HTMLImageElement \| null` | 67 |
| `renderTexture` | método | `public set renderTexture(value: HTMLImageElement \| null)` | 70 |
| `_renderTexture` | propriedade | `private _renderTexture: HTMLImageElement \| null = null;` | 40 |

#### ClassDeclaration `HiloTextureData`

Herança: extends TextureData.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 82 |

### `Hilo/Demos/src/AnimationBaseTest.ts`

- Origem/commit: `Hilo/Demos/src/AnimationBaseTest.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/event/EventObject.ts`, `Hilo/1.x/src/dragonBones/hilo/HiloArmatureDisplay.ts`, `Hilo/1.x/src/dragonBones/hilo/HiloFactory.ts`, `Hilo/Demos/src/BaseTest.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `AnimationBaseTest`

Herança: extends BaseTest.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 5 |
| `_onStart` | método | `protected _onStart(): void` | 15 |
| `_animationEventHandler` | método | `private _animationEventHandler(event: any): void` | 72 |
| `_isTouched` | propriedade | `private _isTouched: boolean = false;` | 2 |
| `_armatureDisplay` | propriedade | `private _armatureDisplay: dragonBones.HiloArmatureDisplay;` | 3 |

### `Hilo/Demos/src/BaseTest.ts`

- Origem/commit: `Hilo/Demos/src/BaseTest.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/core/DragonBones.ts`, `Hilo/1.x/src/dragonBones/hilo/HiloFactory.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `BaseTest`

Herança: extends Hilo.Container.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 13 |
| `_onStart` | método | `protected abstract _onStart(): void;` | 32 |
| `_loadResources` | método | `protected _loadResources(): void` | 34 |
| `tick` | método | `public tick(): void` | 90 |
| `createText` | método | `public createText(string: string): Hilo.Text` | 93 |
| `stageWidth` | método | `public get stageWidth(): number` | 107 |
| `stageHeight` | método | `public get stageHeight(): number` | 111 |
| `_stage` | propriedade | `protected readonly _stage: Hilo.Stage = new Hilo.Stage({ renderType: "webgl", container: document.getElementById("hilo-container"), width: 1136, height: 640 });` | 2 |
| `_ticker` | propriedade | `protected readonly _ticker: Hilo.Ticker = new Hilo.Ticker(60);` | 8 |
| `_resources` | propriedade | `protected readonly _resources: string[] = [];` | 10 |
| `_hiloResources` | propriedade | `protected readonly _hiloResources: dragonBones.Map<any> = {};` | 11 |

### `Hilo/Demos/src/HelloDragonBones.ts`

- Origem/commit: `Hilo/Demos/src/HelloDragonBones.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/Demos/assets/Script/HelloDragonBones.ts`, `Egret/Demos/src/demo/HelloDragonBones.ts`, `Hilo/1.x/src/dragonBones/hilo/HiloFactory.ts`, `Hilo/Demos/src/BaseTest.ts`, `Phaser/Demos/src/HelloDragonBones.ts`, `Pixi/Demos/4.x/src/HelloDragonBones.ts`, `Pixi/Demos/8.x/src/HelloDragonBones.ts`, `ThreeJS/Demos/src/HelloDragonBones.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `HelloDragonBones`

Herança: extends BaseTest.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 19 |
| `_onStart` | método | `protected _onStart(): void` | 30 |

### `Hilo/Demos/src/PerformanceTest.ts`

- Origem/commit: `Hilo/Demos/src/PerformanceTest.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/Demos/assets/Script/PerformanceTest.ts`, `DragonBones/src/dragonBones/core/BaseObject.ts`, `Egret/Demos/src/demo/PerformanceTest.ts`, `Hilo/1.x/src/dragonBones/hilo/HiloArmatureDisplay.ts`, `Hilo/1.x/src/dragonBones/hilo/HiloFactory.ts`, `Hilo/Demos/src/BaseTest.ts`, `Phaser/Demos/src/PerformanceTest.ts`, `Pixi/Demos/4.x/src/PerformanceTest.ts`, `Pixi/Demos/8.x/src/PerformanceTest.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `PerformanceTest`

Herança: extends BaseTest.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 7 |
| `tick` | método | `public tick(): void` | 17 |
| `_onStart` | método | `protected _onStart(): void` | 37 |
| `_addArmature` | método | `private _addArmature(): void` | 58 |
| `_removeArmature` | método | `private _removeArmature(): void` | 74 |
| `_resetPosition` | método | `private _resetPosition(): void` | 89 |
| `_updateText` | método | `private _updateText(): void` | 112 |
| `_addingArmature` | propriedade | `private _addingArmature: boolean = false;` | 2 |
| `_removingArmature` | propriedade | `private _removingArmature: boolean = false;` | 3 |
| `_armatures` | propriedade | `private readonly _armatures: Array<dragonBones.HiloArmatureDisplay> = [];` | 4 |
| `_text` | propriedade | `private _text: Hilo.Text;` | 5 |

### `Hilo/Demos/src/ReplaceAnimation.ts`

- Origem/commit: `Hilo/Demos/src/ReplaceAnimation.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Egret/Demos/src/demo/ReplaceAnimation.ts`, `Hilo/1.x/src/dragonBones/hilo/HiloArmatureDisplay.ts`, `Hilo/1.x/src/dragonBones/hilo/HiloFactory.ts`, `Hilo/Demos/src/BaseTest.ts`, `Phaser/Demos/src/ReplaceAnimation.ts`, `Pixi/Demos/4.x/src/ReplaceAnimation.ts`, `Pixi/Demos/8.x/src/ReplaceAnimation.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `ReplaceAnimation`

Herança: extends BaseTest.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 7 |
| `_onStart` | método | `protected _onStart(): void` | 17 |
| `_replaceAnimation` | método | `private _replaceAnimation(): void` | 53 |
| `_armatureDisplayA` | propriedade | `private _armatureDisplayA: dragonBones.HiloArmatureDisplay;` | 2 |
| `_armatureDisplayB` | propriedade | `private _armatureDisplayB: dragonBones.HiloArmatureDisplay;` | 3 |
| `_armatureDisplayC` | propriedade | `private _armatureDisplayC: dragonBones.HiloArmatureDisplay;` | 4 |
| `_armatureDisplayD` | propriedade | `private _armatureDisplayD: dragonBones.HiloArmatureDisplay;` | 5 |

### `Hilo/Demos/src/ReplaceSlotDisplay.ts`

- Origem/commit: `Hilo/Demos/src/ReplaceSlotDisplay.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/Demos/assets/Script/ReplaceAnimation.ts`, `Cocos/Demos/assets/Script/ReplaceSlotDisplay.ts`, `Egret/Demos/src/demo/ReplaceSlotDisplay.ts`, `Hilo/1.x/src/dragonBones/hilo/HiloArmatureDisplay.ts`, `Hilo/1.x/src/dragonBones/hilo/HiloFactory.ts`, `Hilo/Demos/src/BaseTest.ts`, `Phaser/Demos/src/ReplaceSlotDisplay.ts`, `Pixi/Demos/4.x/src/ReplaceSlotDisplay.ts`, `Pixi/Demos/8.x/src/ReplaceSlotDisplay.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `ReplaceSlotDisplay`

Herança: extends BaseTest.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 12 |
| `_onStart` | método | `protected _onStart(): void` | 25 |
| `_replaceDisplay` | método | `private _replaceDisplay(): void` | 46 |
| `_displayIndex` | propriedade | `private _displayIndex: number = 0;` | 2 |
| `_replaceDisplays` | propriedade | `private readonly _replaceDisplays: string[] = [ // Replace normal display. "display0002", "display0003", "display0004", "display0005", "display0006", "display0007", "display0008", "display0009", "display0010", // Replace mesh display. "meshA", "meshB", "meshC", ];` | 3 |
| `_factory` | propriedade | `private readonly _factory: dragonBones.HiloFactory = dragonBones.HiloFactory.factory;` | 9 |
| `_armatureDisplay` | propriedade | `private _armatureDisplay: dragonBones.HiloArmatureDisplay;` | 10 |

### `Hilo/Demos/src/SetBoneOffset.ts`

- Origem/commit: `Hilo/Demos/src/SetBoneOffset.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/event/EventObject.ts`, `Hilo/1.x/src/dragonBones/hilo/HiloArmatureDisplay.ts`, `Hilo/1.x/src/dragonBones/hilo/HiloFactory.ts`, `Hilo/Demos/src/BaseTest.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `SetBoneOffset`

Herança: extends BaseTest.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 2 |
| `_onStart` | método | `protected _onStart(): void` | 12 |
| `_moveTo` | método | `private _moveTo(armatureDisplay: dragonBones.HiloArmatureDisplay): void` | 29 |

### `Phaser/2.x/src/dragonBones/phaser/PhaserArmatureDisplay.ts`

- Origem/commit: `Phaser/2.x/src/dragonBones/phaser/PhaserArmatureDisplay.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: integrations/Phaser/2.x/src/dragonBones/phaser/PhaserArmatureDisplay.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/animation/Animation.ts`, `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/armature/IArmatureProxy.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/event/EventObject.ts`, `DragonBones/src/dragonBones/geom/Rectangle.ts`, `DragonBones/src/dragonBones/model/BoundingBoxData.ts`, `Phaser/2.x/src/dragonBones/phaser/PhaserFactory.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `PhaserArmatureDisplay`

Herança: extends Phaser.Sprite; implements IArmatureProxy.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 40 |
| `_getChildByName` | método | `private _getChildByName(container: Phaser.Sprite, name: string): PIXI.DisplayObject \| null` | 44 |
| `dbInit` | método | `public dbInit(armature: Armature): void` | 56 |
| `dbClear` | método | `public dbClear(): void` | 62 |
| `dbUpdate` | método | `public dbUpdate(): void` | 83 |
| `dispose` | método | `public dispose(disposeProxy: boolean = true): void` | 192 |
| `destroy` | método | `public destroy(): void` | 203 |
| `dispatchDBEvent` | método | `public dispatchDBEvent(type: EventStringType, eventObject: EventObject): void` | 209 |
| `hasDBEventListener` | método | `public hasDBEventListener(type: EventStringType): boolean` | 220 |
| `addDBEventListener` | método | `public addDBEventListener(type: EventStringType, listener: (event: EventObject) => void, target: any): void` | 226 |
| `removeDBEventListener` | método | `public removeDBEventListener(type: EventStringType, listener: (event: EventObject) => void, target: any): void` | 237 |
| `armature` | método | `public get armature(): Armature` | 246 |
| `animation` | método | `public get animation(): Animation` | 252 |
| `hasEvent` | método | `public hasEvent(type: EventStringType): boolean` | 259 |
| `addEvent` | método | `public addEvent(type: EventStringType, listener: (event: EventObject) => void, target: any): void` | 265 |
| `removeEvent` | método | `public removeEvent(type: EventStringType, listener: (event: EventObject) => void, target: any): void` | 271 |
| `debugDraw` | propriedade | `public debugDraw: boolean = false;` | 32 |
| `_debugDraw` | propriedade | `private _debugDraw: boolean = false;` | 33 |
| `_armature` | propriedade | `private _armature: Armature = null as any;` | 34 |
| `_signals` | propriedade | `private readonly _signals: Map<Phaser.Signal> = {};` | 35 |
| `_debugDrawer` | propriedade | `private _debugDrawer: Phaser.Sprite \| null = null;` | 36 |

### `Phaser/2.x/src/dragonBones/phaser/PhaserFactory.ts`

- Origem/commit: `Phaser/2.x/src/dragonBones/phaser/PhaserFactory.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: integrations/Phaser/2.x/src/dragonBones/phaser/PhaserFactory.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/Demos/assets/Script/CoreElement.ts`, `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/armature/Slot.ts`, `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/factory/BaseFactory.ts`, `DragonBones/src/dragonBones/model/ArmatureData.ts`, `DragonBones/src/dragonBones/parser/DataParser.ts`, `Egret/Demos/src/demo/CoreElement.ts`, `Phaser/2.x/src/dragonBones/phaser/PhaserArmatureDisplay.ts`, `Phaser/2.x/src/dragonBones/phaser/PhaserSlot.ts`, `Phaser/2.x/src/dragonBones/phaser/PhaserSlotDisplay.ts`, `Phaser/2.x/src/dragonBones/phaser/PhaserTextureAtlasData.ts`, `Phaser/3.x/src/dragonBones/phaser/display/Slot.ts`, `Phaser/Demos/src/CoreElement.ts`, `Pixi/Demos/4.x/src/CoreElement.ts`, `Pixi/Demos/8.x/src/CoreElement.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `PhaserFactory`

Herança: extends BaseFactory.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `init` | método | `public static init(game: Phaser.Game): void` | 43 |
| `factory` | método | `public static get factory(): PhaserFactory` | 62 |
| `constructor` | método | `public constructor(dataParser: DataParser \| null = null)` | 72 |
| `_isSupportMesh` | método | `protected _isSupportMesh(): boolean` | 78 |
| `_buildTextureAtlasData` | método | `protected _buildTextureAtlasData(textureAtlasData: PhaserTextureAtlasData \| null, textureAtlas: PIXI.BaseTexture \| null): PhaserTextureAtlasData` | 84 |
| `_buildArmature` | método | `protected _buildArmature(dataPackage: BuildArmaturePackage): Armature` | 95 |
| `_buildSlot` | método | `protected _buildSlot(dataPackage: BuildArmaturePackage, slotData: SlotData, armature: Armature): Slot` | 107 |
| `buildArmatureDisplay` | método | `public buildArmatureDisplay(armatureName: string, dragonBonesName: string = "", skinName: string = "", textureAtlasName: string = ""): PhaserArmatureDisplay \| null` | 151 |
| `getTextureDisplay` | método | `public getTextureDisplay(textureName: string, textureAtlasName: string \| null = null): Phaser.Sprite \| null` | 175 |
| `soundEventManager` | método | `public get soundEventManager(): PhaserArmatureDisplay` | 195 |
| `_game` | propriedade | `public static _game: Phaser.Game = null as any;` | 39 |
| `_dragonBonesInstance` | propriedade | `private static _dragonBonesInstance: DragonBones = null as any;` | 40 |
| `_factory` | propriedade | `private static _factory: PhaserFactory = null as any;` | 41 |

### `Phaser/2.x/src/dragonBones/phaser/PhaserSlot.ts`

- Origem/commit: `Phaser/2.x/src/dragonBones/phaser/PhaserSlot.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: integrations/Phaser/2.x/src/dragonBones/phaser/PhaserSlot.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/armature/Slot.ts`, `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `Phaser/2.x/src/dragonBones/phaser/PhaserArmatureDisplay.ts`, `Phaser/2.x/src/dragonBones/phaser/PhaserSlotDisplay.ts`, `Phaser/2.x/src/dragonBones/phaser/PhaserTextureAtlasData.ts`, `Phaser/3.x/src/dragonBones/phaser/display/Slot.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `PhaserSlot`

Herança: extends Slot.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 36 |
| `_onClear` | método | `protected _onClear(): void` | 43 |
| `_initDisplay` | método | `protected _initDisplay(value: any, isRetain: boolean): void` | 50 |
| `_disposeDisplay` | método | `protected _disposeDisplay(value: any, isRelease: boolean): void` | 57 |
| `_onUpdateDisplay` | método | `protected _onUpdateDisplay(): void` | 65 |
| `_addDisplay` | método | `protected _addDisplay(): void` | 69 |
| `_replaceDisplay` | método | `protected _replaceDisplay(value: any): void` | 74 |
| `_removeDisplay` | método | `protected _removeDisplay(): void` | 83 |
| `_updateZOrder` | método | `protected _updateZOrder(): void` | 87 |
| `_updateVisible` | método | `public _updateVisible(): void` | 99 |
| `_updateBlendMode` | método | `protected _updateBlendMode(): void` | 103 |
| `_updateColor` | método | `protected _updateColor(): void` | 149 |
| `_updateFrame` | método | `protected _updateFrame(): void` | 160 |
| `_updateMesh` | método | `protected _updateMesh(): void` | 208 |
| `_updateTransform` | método | `protected _updateTransform(): void` | 212 |
| `_identityTransform` | método | `protected _identityTransform(): void` | 235 |
| `_textureScale` | propriedade | `private _textureScale: number;` | 40 |
| `_renderDisplay` | propriedade | `private _renderDisplay: PIXI.DisplayObject;` | 41 |

### `Phaser/2.x/src/dragonBones/phaser/PhaserSlotDisplay.ts`

- Origem/commit: `Phaser/2.x/src/dragonBones/phaser/PhaserSlotDisplay.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: integrations/Phaser/2.x/src/dragonBones/phaser/PhaserSlotDisplay.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/geom/Transform.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `PhaserSlotDisplay`

Herança: extends Phaser.Image.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `updateTransform` | método | `public updateTransform(parent: PIXI.DisplayObjectContainer)` | 41 |

### `Phaser/2.x/src/dragonBones/phaser/PhaserTextureAtlasData.ts`

- Origem/commit: `Phaser/2.x/src/dragonBones/phaser/PhaserTextureAtlasData.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: integrations/Phaser/2.x/src/dragonBones/phaser/PhaserTextureAtlasData.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/geom/Rectangle.ts`, `DragonBones/src/dragonBones/model/TextureAtlasData.ts`, `Phaser/3.x/src/dragonBones/phaser/display/TextureAtlasData.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `PhaserTextureAtlasData`

Herança: extends TextureAtlasData.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 36 |
| `_onClear` | método | `protected _onClear(): void` | 42 |
| `createTexture` | método | `public createTexture(): TextureData` | 54 |
| `renderTexture` | método | `public get renderTexture(): PIXI.BaseTexture \| null` | 67 |
| `renderTexture` | método | `public set renderTexture(value: PIXI.BaseTexture \| null)` | 70 |
| `_renderTexture` | propriedade | `private _renderTexture: PIXI.BaseTexture \| null = null;` | 40 |

#### ClassDeclaration `PhaserTextureData`

Herança: extends TextureData.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 101 |
| `_onClear` | método | `protected _onClear(): void` | 107 |
| `renderTexture` | propriedade | `public renderTexture: PIXI.Texture \| null = null;` | 105 |

### `Phaser/3.x/src/dragonBones/phaser/Factory.ts`

- Origem/commit: `Phaser/3.x/src/dragonBones/phaser/Factory.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: integrations/Phaser/3.x/src/dragonBones/phaser/Factory.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/armature/Slot.ts`, `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/factory/BaseFactory.ts`, `DragonBones/src/dragonBones/model/ArmatureData.ts`, `DragonBones/src/dragonBones/model/DragonBonesData.ts`, `DragonBones/src/dragonBones/model/TextureAtlasData.ts`, `DragonBones/src/dragonBones/parser/DataParser.ts`, `Phaser/3.x/src/dragonBones/phaser/display/ArmatureDisplay.ts`, `Phaser/3.x/src/dragonBones/phaser/display/Slot.ts`, `Phaser/3.x/src/dragonBones/phaser/display/TextureAtlasData.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `Factory`

Herança: extends BaseFactory.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `constructor(dragonBones: DragonBones, scene: Phaser.Scene, dataParser?: DataParser)` | 6 |
| `_isSupportMesh` | método | `protected _isSupportMesh(): boolean` | 12 |
| `_buildTextureAtlasData` | método | `protected _buildTextureAtlasData(textureAtlasData: display.TextureAtlasData, textureAtlas: Phaser.Textures.Texture): TextureAtlasData` | 16 |
| `_buildArmature` | método | `protected _buildArmature(dataPackage: BuildArmaturePackage): Armature` | 25 |
| `_buildSlot` | método | `protected _buildSlot(dataPackage: BuildArmaturePackage, slotData: SlotData, armature: Armature): Slot` | 37 |
| `buildArmatureDisplay` | método | `buildArmatureDisplay(armatureName: string, dragonBonesName: string, skinName: string = "", textureAtlasName: string = "", textureScale = 1.0): display.ArmatureDisplay` | 47 |
| `buildDragonBonesData` | método | `buildDragonBonesData(dragonBonesName: string, textureScale = 1.0): DragonBonesData` | 57 |
| `soundEventManager` | método | `public get soundEventManager(): display.ArmatureDisplay` | 81 |
| `_scene` | propriedade | `protected _scene: Phaser.Scene;` | 3 |
| `_dragonBones` | propriedade | `protected _dragonBones: DragonBones;` | 4 |

### `Phaser/3.x/src/dragonBones/phaser/display/ArmatureDisplay.ts`

- Origem/commit: `Phaser/3.x/src/dragonBones/phaser/display/ArmatureDisplay.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: integrations/Phaser/3.x/src/dragonBones/phaser/display/ArmatureDisplay.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/animation/Animation.ts`, `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/armature/IArmatureProxy.ts`, `DragonBones/src/dragonBones/event/EventObject.ts`, `DragonBones/src/dragonBones/geom/Rectangle.ts`, `Phaser/3.x/src/dragonBones/phaser/display/DisplayContainer.ts`, `Phaser/3.x/src/dragonBones/phaser/display/SlotMesh.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `ArmatureDisplay`

Herança: extends DisplayContainer; implements IArmatureProxy.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `constructor(scene: Phaser.Scene)` | 6 |
| `dbInit` | método | `dbInit(armature: Armature): void` | 10 |
| `dbClear` | método | `dbClear(): void` | 14 |
| `dbUpdate` | método | `dbUpdate(): void` | 21 |
| `dispose` | método | `dispose(disposeProxy: boolean): void` | 27 |
| `destroy` | método | `destroy(): void` | 33 |
| `dispatchDBEvent` | método | `dispatchDBEvent(type: EventStringType, eventObject: EventObject): void` | 37 |
| `hasDBEventListener` | método | `hasDBEventListener(type: EventStringType): boolean` | 41 |
| `addDBEventListener` | método | `addDBEventListener(type: EventStringType, listener: (event: EventObject) => void, scope?: any): void` | 45 |
| `removeDBEventListener` | método | `removeDBEventListener(type: EventStringType, listener: (event: EventObject) => void, scope?: any): void` | 49 |
| `armature` | método | `get armature(): Armature` | 53 |
| `animation` | método | `get animation(): Animation` | 57 |
| `getBounds` | método | `getBounds(output?: Phaser.Geom.Rectangle):Phaser.Geom.Rectangle` | 61 |
| `debugDraw` | propriedade | `debugDraw = false;` | 3 |
| `_armature` | propriedade | `private _armature: Armature;` | 4 |

### `Phaser/3.x/src/dragonBones/phaser/display/DisplayContainer.ts`

- Origem/commit: `Phaser/3.x/src/dragonBones/phaser/display/DisplayContainer.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: integrations/Phaser/3.x/src/dragonBones/phaser/display/DisplayContainer.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/geom/Point.ts`, `Phaser/3.x/src/dragonBones/phaser/util/TransformMatrix.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `DisplayContainer`

Herança: extends Phaser.GameObjects.Container.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `constructor(scene: Phaser.Scene, x?: number, y?: number, children?: Phaser.GameObjects.GameObject[])` | 8 |
| `pointToContainer` | método | `pointToContainer(source: Phaser.Math.Vector2 \| Phaser.Geom.Point \| { x?: number, y?: number}, output?: Phaser.Math.Vector2 \| Phaser.Geom.Point \| { x?: number, y?: number}): Phaser.Math.Vector2 \| Phaser.Geom.Point \| { x?: number, y?: number}` | 13 |
| `skewX` | método | `get skewX(): number` | 33 |
| `skewX` | método | `set skewX(v: number)` | 37 |
| `skewY` | método | `get skewY(): number` | 41 |
| `skewY` | método | `set skewY(v: number)` | 45 |
| `setSkew` | método | `setSkew(sx: number, sy?: number): this` | 49 |
| `_skewX` | propriedade | `private _skewX = 0;` | 4 |
| `_skewY` | propriedade | `private _skewY = 0;` | 5 |
| `tempTransformMatrix` | propriedade | `private tempTransformMatrix: util.TransformMatrix;` | 6 |

### `Phaser/3.x/src/dragonBones/phaser/display/Slot.ts`

- Origem/commit: `Phaser/3.x/src/dragonBones/phaser/display/Slot.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: integrations/Phaser/3.x/src/dragonBones/phaser/display/Slot.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/armature/Bone.ts`, `DragonBones/src/dragonBones/armature/Slot.ts`, `DragonBones/src/dragonBones/armature/Surface.ts`, `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/model/DisplayData.ts`, `DragonBones/src/dragonBones/model/TextureAtlasData.ts`, `Phaser/3.x/src/dragonBones/phaser/display/DisplayContainer.ts`, `Phaser/3.x/src/dragonBones/phaser/display/SlotImage.ts`, `Phaser/3.x/src/dragonBones/phaser/display/SlotMesh.ts`, `Phaser/3.x/src/dragonBones/phaser/display/SlotSprite.ts`, `Phaser/3.x/src/dragonBones/phaser/display/TextureAtlasData.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `Slot`

Herança: extends dragonBones.Slot.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `static toString(): string` | 3 |
| `_onClear` | método | `protected _onClear(): void` | 10 |
| `_initDisplay` | método | `protected _initDisplay(rawDisplay: any, isRetain: boolean): void` | 20 |
| `_disposeDisplay` | método | `protected _disposeDisplay(prevDisplay: any, isRelease: boolean): void` | 23 |
| `_onUpdateDisplay` | método | `protected _onUpdateDisplay(): void` | 27 |
| `_addDisplay` | método | `protected _addDisplay(): void` | 32 |
| `_replaceDisplay` | método | `protected _replaceDisplay(prevDisplay: any): void` | 36 |
| `_removeDisplay` | método | `protected _removeDisplay(): void` | 47 |
| `_updateDisplayData` | método | `protected _updateDisplayData(): void` | 52 |
| `_updateZOrder` | método | `protected _updateZOrder(): void` | 60 |
| `_updateVisible` | método | `_updateVisible(): void` | 65 |
| `_updateBlendMode` | método | `protected _updateBlendMode(): void` | 69 |
| `_updateColor` | método | `protected _updateColor(): void` | 106 |
| `_updateFrame` | método | `protected _updateFrame(): void` | 121 |
| `_updateMesh` | método | `protected _updateMesh(): void` | 215 |
| `_updateTransform` | método | `protected _updateTransform(): void` | 303 |
| `_identityTransform` | método | `protected _identityTransform(): void` | 314 |
| `_textureScale` | propriedade | `private _textureScale: number;` | 7 |
| `_renderDisplay` | propriedade | `private _renderDisplay: SlotImage \| SlotSprite \| SlotMesh \| DisplayContainer;` | 8 |

### `Phaser/3.x/src/dragonBones/phaser/display/SlotImage.ts`

- Origem/commit: `Phaser/3.x/src/dragonBones/phaser/display/SlotImage.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: integrations/Phaser/3.x/src/dragonBones/phaser/display/SlotImage.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: nenhuma declaração autoral identificada.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `SlotImage`

Herança: extends Phaser.GameObjects.Image.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `constructor(scene: Phaser.Scene, x: number, y: number, texture?: string, frame?: string \| number)` | 3 |

### `Phaser/3.x/src/dragonBones/phaser/display/SlotMesh.ts`

- Origem/commit: `Phaser/3.x/src/dragonBones/phaser/display/SlotMesh.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: integrations/Phaser/3.x/src/dragonBones/phaser/display/SlotMesh.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: nenhuma declaração autoral identificada.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `SlotMesh`

Herança: extends Phaser.GameObjects.Mesh.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `constructor(scene: Phaser.Scene, x: number, y: number, vertices: number[], uv: number[], colors: number[], alphas: number[], texture: string, frame?: string \| integer)` | 7 |
| `setTint` | método | `setTint(topLeft?: integer, topRight?: integer, bottomLeft?: integer, bottomRight?: integer)` | 12 |
| `updateVertices` | método | `updateVertices()` | 16 |
| `fakeIndices` | propriedade | `fakeIndices: Uint16Array;` | 3 |
| `fakeVertices` | propriedade | `fakeVertices: Uint16Array;` | 4 |
| `fakeUvs` | propriedade | `fakeUvs: Uint16Array;` | 5 |

### `Phaser/3.x/src/dragonBones/phaser/display/SlotSprite.ts`

- Origem/commit: `Phaser/3.x/src/dragonBones/phaser/display/SlotSprite.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: integrations/Phaser/3.x/src/dragonBones/phaser/display/SlotSprite.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: nenhuma declaração autoral identificada.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `SlotSprite`

Herança: extends Phaser.GameObjects.Sprite.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `constructor(scene: Phaser.Scene, x: number, y: number, texture?: string, frame?: string \| number)` | 3 |

### `Phaser/3.x/src/dragonBones/phaser/display/TextureAtlasData.ts`

- Origem/commit: `Phaser/3.x/src/dragonBones/phaser/display/TextureAtlasData.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: integrations/Phaser/3.x/src/dragonBones/phaser/display/TextureAtlasData.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/model/TextureAtlasData.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `TextureAtlasData`

Herança: extends dragonBones.TextureAtlasData.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `static toString(): string` | 3 |
| `_onClear` | método | `protected _onClear(): void` | 9 |
| `createTexture` | método | `createTexture(): TextureData` | 18 |
| `renderTexture` | método | `get renderTexture(): Phaser.Textures.Texture` | 22 |
| `renderTexture` | método | `set renderTexture(value: Phaser.Textures.Texture)` | 27 |
| `_renderTexture` | propriedade | `private _renderTexture: Phaser.Textures.Texture = null;` | 7 |

#### ClassDeclaration `TextureData`

Herança: extends dragonBones.TextureData.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `static toString(): string` | 54 |
| `_onClear` | método | `protected _onClear(): void` | 60 |
| `renderTexture` | propriedade | `renderTexture: Phaser.Textures.Frame = null;` | 58 |

### `Phaser/3.x/src/dragonBones/phaser/pipeline/TextureTintPipeline.ts`

- Origem/commit: `Phaser/3.x/src/dragonBones/phaser/pipeline/TextureTintPipeline.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: integrations/Phaser/3.x/src/dragonBones/phaser/pipeline/TextureTintPipeline.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Phaser/3.x/src/dragonBones/phaser/util/TransformMatrix.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `TextureTintPipeline`

Herança: extends Phaser.Renderer.WebGL.Pipelines.TextureTintPipeline.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `constructor(config: any)` | 7 |
| `batchSprite` | método | `batchSprite(sprite: Phaser.GameObjects.Image \| Phaser.GameObjects.Sprite, camera: Phaser.Cameras.Scene2D.Camera, parentTransformMatrix: Phaser.GameObjects.Components.TransformMatrix): void` | 14 |
| `_tempMatrix1` | propriedade | `private _tempMatrix1: util.TransformMatrix;` | 3 |
| `_tempMatrix2` | propriedade | `private _tempMatrix2: util.TransformMatrix;` | 4 |
| `_tempMatrix3` | propriedade | `private _tempMatrix3: util.TransformMatrix;` | 5 |

### `Phaser/3.x/src/dragonBones/phaser/plugin/DragonBonesFile.ts`

- Origem/commit: `Phaser/3.x/src/dragonBones/phaser/plugin/DragonBonesFile.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: integrations/Phaser/3.x/src/dragonBones/phaser/plugin/DragonBonesFile.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: nenhuma declaração autoral identificada.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `DragonBonesFile`

Herança: extends Phaser.Loader.MultiFile.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `constructor(loader: Phaser.Loader.LoaderPlugin, key: string \| object, textureURL?: string, atlasURL?: string, boneURL?: string, textureXhrSettings?: XHRSettingsObject, atlasXhrSettings?: XHRSettingsObject, boneXhrSettings?: XHRSettingsObject)` | 3 |
| `addToCache` | método | `addToCache(): void` | 77 |

### `Phaser/3.x/src/dragonBones/phaser/plugin/DragonBonesPlugin.ts`

- Origem/commit: `Phaser/3.x/src/dragonBones/phaser/plugin/DragonBonesPlugin.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: integrations/Phaser/3.x/src/dragonBones/phaser/plugin/DragonBonesPlugin.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/model/DragonBonesData.ts`, `Phaser/3.x/src/dragonBones/phaser/Factory.ts`, `Phaser/3.x/src/dragonBones/phaser/display/ArmatureDisplay.ts`, `Phaser/3.x/src/dragonBones/phaser/display/SlotImage.ts`, `Phaser/3.x/src/dragonBones/phaser/display/SlotMesh.ts`, `Phaser/3.x/src/dragonBones/phaser/display/SlotSprite.ts`, `Phaser/3.x/src/dragonBones/phaser/pipeline/TextureTintPipeline.ts`, `Phaser/3.x/src/dragonBones/phaser/plugin/DragonBonesFile.ts`, `Phaser/3.x/src/dragonBones/phaser/util/EventDispatcher.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `DragonBonesScenePlugin`

Herança: extends Phaser.Plugins.ScenePlugin.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `constructor(scene: Phaser.Scene, pluginManager: Phaser.Plugins.PluginManager)` | 6 |
| `createArmature` | método | `createArmature(armature: string, dragonBones?: string, skinName?: string, atlasTextureName?: string, textureScale = 1.0): display.ArmatureDisplay` | 27 |
| `createDragonBones` | método | `createDragonBones(dragonBonesName: string, textureScale = 1.0): DragonBonesData` | 36 |
| `factory` | método | `get factory(): Factory` | 40 |
| `createSlotDisplayPlaceholder` | método | `createSlotDisplayPlaceholder(): display.SlotImage \| display.SlotSprite` | 53 |
| `boot` | método | `boot(): void` | 57 |
| `start` | método | `start(): void` | 62 |
| `update` | método | `private update(time: number, delta: number): void` | 69 |
| `shutdown` | método | `shutdown(): void` | 73 |
| `destroy` | método | `destroy(): void` | 80 |
| `createMeshDisplayPlaceholder` | método | `createMeshDisplayPlaceholder(): Phaser.GameObjects.Mesh` | 92 |
| `_dbInst` | propriedade | `protected _dbInst: dragonBones.DragonBones;` | 3 |
| `_factory` | propriedade | `protected _factory: Factory;` | 4 |

### `Phaser/3.x/src/dragonBones/phaser/plugin/FileTypes.ts`

- Origem/commit: `Phaser/3.x/src/dragonBones/phaser/plugin/FileTypes.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: nenhuma declaração autoral identificada.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### InterfaceDeclaration `FileTypeClass`

Herança: nenhuma explícita.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `new (... args: any[]): Phaser.Loader.File;` | 3 |

### `Phaser/3.x/src/dragonBones/phaser/util/EventDispatcher.ts`

- Origem/commit: `Phaser/3.x/src/dragonBones/phaser/util/EventDispatcher.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: integrations/Phaser/3.x/src/dragonBones/phaser/util/EventDispatcher.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/event/EventObject.ts`, `DragonBones/src/dragonBones/event/IEventDispatcher.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `EventDispatcher`

Herança: extends Phaser.Events.EventEmitter; implements IEventDispatcher.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `hasDBEventListener` | método | `hasDBEventListener(type: EventStringType): boolean` | 3 |
| `dispatchDBEvent` | método | `dispatchDBEvent(type: EventStringType, eventObject: EventObject): void` | 7 |
| `addDBEventListener` | método | `addDBEventListener(type: EventStringType, listener: (e: EventObject) => void, thisObject?: any): void` | 11 |
| `removeDBEventListener` | método | `removeDBEventListener(type: EventStringType, listener: (e: EventObject) => void, thisObject?: any): void` | 15 |

### `Phaser/3.x/src/dragonBones/phaser/util/SkewComponent.ts`

- Origem/commit: `Phaser/3.x/src/dragonBones/phaser/util/SkewComponent.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: integrations/Phaser/3.x/src/dragonBones/phaser/util/SkewComponent.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: nenhuma declaração autoral identificada.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

Sem classes/interfaces/enums/funções nomeadas declaradas. Revisar instruções de topo, exports e callbacks no arquivo original.

### `Phaser/3.x/src/dragonBones/phaser/util/TransformMatrix.ts`

- Origem/commit: `Phaser/3.x/src/dragonBones/phaser/util/TransformMatrix.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: integrations/Phaser/3.x/src/dragonBones/phaser/util/TransformMatrix.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: nenhuma declaração autoral identificada.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `TransformMatrix`

Herança: extends Phaser.GameObjects.Components.TransformMatrix.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `constructor(a?: number, b?: number, c?: number, d?: number, tx?: number, ty?: number)` | 3 |
| `decomposeMatrix` | método | `decomposeMatrix(): any` | 9 |
| `applyITRSC` | método | `applyITRSC(x: number, y: number, rotation: number, scaleX: number, scaleY: number, skewX: number, skewY: number): this` | 44 |
| `skewX` | método | `get skewX(): number` | 56 |
| `skewY` | método | `get skewY(): number` | 60 |

### `Phaser/Demos/src/AnimationBase.ts`

- Origem/commit: `Phaser/Demos/src/AnimationBase.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/Demos/assets/Script/AnimationBase.ts`, `DragonBones/src/dragonBones/event/EventObject.ts`, `Egret/Demos/src/BaseDemo.ts`, `Egret/Demos/src/demo/AnimationBase.ts`, `Phaser/3.x/src/dragonBones/phaser/display/ArmatureDisplay.ts`, `Phaser/Demos/src/BaseDemo.ts`, `Pixi/Demos/4.x/src/AnimationBase.ts`, `Pixi/Demos/4.x/src/BaseDemo.ts`, `Pixi/Demos/8.x/src/AnimationBase.ts`, `Pixi/Demos/8.x/src/BaseDemo.ts`, `ThreeJS/Demos/src/BaseDemo.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `AnimationBase`

Herança: extends BaseDemo.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 4 |
| `preload` | método | `preload(): void` | 8 |
| `create` | método | `create(): void` | 19 |
| `_inputDown` | método | `private _inputDown(): void` | 44 |
| `_inputUp` | método | `private _inputUp(): void` | 50 |
| `update` | método | `public update(): void` | 55 |
| `_animationEventHandler` | método | `private _animationEventHandler(event: dragonBones.EventObject): void` | 63 |
| `_armatureDisplay` | propriedade | `private _armatureDisplay: dragonBones.phaser.display.ArmatureDisplay;` | 2 |
| `_isTouched` | propriedade | `private _isTouched: boolean = false;` | 42 |

### `Phaser/Demos/src/AnimationLayer.ts`

- Origem/commit: `Phaser/Demos/src/AnimationLayer.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/Demos/assets/Script/AnimationLayer.ts`, `DragonBones/src/dragonBones/event/EventObject.ts`, `Egret/Demos/src/BaseDemo.ts`, `Egret/Demos/src/demo/AnimationLayer.ts`, `Phaser/3.x/src/dragonBones/phaser/display/ArmatureDisplay.ts`, `Phaser/Demos/src/BaseDemo.ts`, `Pixi/Demos/4.x/src/AnimationLayer.ts`, `Pixi/Demos/4.x/src/BaseDemo.ts`, `Pixi/Demos/8.x/src/AnimationLayer.ts`, `Pixi/Demos/8.x/src/BaseDemo.ts`, `ThreeJS/Demos/src/BaseDemo.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `AnimationLayer`

Herança: extends BaseDemo.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 4 |
| `preload` | método | `preload(): void` | 8 |
| `create` | método | `create(): void` | 18 |
| `_animationEventHandler` | método | `private _animationEventHandler(event: dragonBones.EventObject): void` | 28 |
| `_armatureDisplay` | propriedade | `private _armatureDisplay: dragonBones.phaser.display.ArmatureDisplay;` | 2 |

### `Phaser/Demos/src/BaseDemo.ts`

- Origem/commit: `Phaser/Demos/src/BaseDemo.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Egret/Demos/src/BaseDemo.ts`, `Pixi/Demos/4.x/src/BaseDemo.ts`, `Pixi/Demos/8.x/src/BaseDemo.ts`, `ThreeJS/Demos/src/BaseDemo.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `BaseDemo`

Herança: extends Phaser.Scene.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `preload` | método | `preload(): void` | 6 |
| `create` | método | `create(): void` | 10 |
| `createText` | método | `public createText(str: string): Phaser.GameObjects.Text` | 14 |
| `BACKGROUND_URL` | propriedade | `private static BACKGROUND_URL: string = "resource/background.png";` | 4 |

### `Phaser/Demos/src/BoneOffset.ts`

- Origem/commit: `Phaser/Demos/src/BoneOffset.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/Demos/assets/Script/BoneOffset.ts`, `DragonBones/src/dragonBones/event/EventObject.ts`, `Egret/Demos/src/BaseDemo.ts`, `Egret/Demos/src/demo/BoneOffset.ts`, `Phaser/3.x/src/dragonBones/phaser/display/ArmatureDisplay.ts`, `Phaser/Demos/src/BaseDemo.ts`, `Pixi/Demos/4.x/src/BaseDemo.ts`, `Pixi/Demos/4.x/src/BoneOffset.ts`, `Pixi/Demos/8.x/src/BaseDemo.ts`, `Pixi/Demos/8.x/src/BoneOffset.ts`, `ThreeJS/Demos/src/BaseDemo.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `BoneOffset`

Herança: extends BaseDemo.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 2 |
| `preload` | método | `preload(): void` | 6 |
| `create` | método | `create(): void` | 16 |
| `_animationHandler` | método | `private _animationHandler(event: dragonBones.EventObject): void` | 30 |
| `_moveTo` | método | `private _moveTo(armatureDisplay: dragonBones.phaser.display.ArmatureDisplay): void` | 34 |

### `Phaser/Demos/src/BoundingBox.ts`

- Origem/commit: `Phaser/Demos/src/BoundingBox.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/Demos/assets/Script/BoundingBox.ts`, `Cocos/Demos/assets/Script/DragHelper.ts`, `DragonBones/src/dragonBones/armature/Bone.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `Egret/Demos/src/BaseDemo.ts`, `Egret/Demos/src/DragHelper.ts`, `Egret/Demos/src/demo/BoundingBox.ts`, `Phaser/3.x/src/dragonBones/phaser/display/ArmatureDisplay.ts`, `Phaser/3.x/src/dragonBones/phaser/util/TransformMatrix.ts`, `Phaser/Demos/src/BaseDemo.ts`, `Phaser/Demos/src/DragHelper.ts`, `Pixi/Demos/4.x/src/BaseDemo.ts`, `Pixi/Demos/4.x/src/BoundingBox.ts`, `Pixi/Demos/4.x/src/DragHelper.ts`, `Pixi/Demos/8.x/src/BaseDemo.ts`, `Pixi/Demos/8.x/src/BoundingBox.ts`, `Pixi/Demos/8.x/src/DragHelper.ts`, `ThreeJS/Demos/src/BaseDemo.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `BoundingBox`

Herança: extends BaseDemo.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 15 |
| `preload` | método | `preload(): void` | 19 |
| `create` | método | `create(): void` | 35 |
| `update` | método | `update(time: number, delta: number): void` | 72 |
| `_helpPointA` | propriedade | `private readonly _helpPointA: Phaser.Math.Vector2 = new Phaser.Math.Vector2();` | 2 |
| `_helpPointB` | propriedade | `private readonly _helpPointB: Phaser.Math.Vector2 = new Phaser.Math.Vector2();` | 3 |
| `_helpPointC` | propriedade | `private readonly _helpPointC: Phaser.Math.Vector2 = new Phaser.Math.Vector2();` | 4 |
| `_helperMatrix` | propriedade | `private _helperMatrix: Phaser.GameObjects.Components.TransformMatrix = new Phaser.GameObjects.Components.TransformMatrix();` | 5 |
| `_armatureDisplay` | propriedade | `private _armatureDisplay: dragonBones.phaser.display.ArmatureDisplay;` | 7 |
| `_boundingBoxTester` | propriedade | `private _boundingBoxTester: dragonBones.phaser.display.ArmatureDisplay;` | 8 |
| `_targetA` | propriedade | `private _targetA: dragonBones.phaser.display.ArmatureDisplay;` | 9 |
| `_targetB` | propriedade | `private _targetB: dragonBones.phaser.display.ArmatureDisplay;` | 10 |
| `_line` | propriedade | `private _line: dragonBones.Bone;` | 11 |
| `_pointA` | propriedade | `private _pointA: dragonBones.Bone;` | 12 |
| `_pointB` | propriedade | `private _pointB: dragonBones.Bone;` | 13 |

### `Phaser/Demos/src/CoreElement.ts`

- Origem/commit: `Phaser/Demos/src/CoreElement.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/Demos/assets/Script/CoreElement.ts`, `DragonBones/src/dragonBones/animation/AnimationState.ts`, `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/event/EventObject.ts`, `Egret/Demos/src/BaseDemo.ts`, `Egret/Demos/src/demo/CoreElement.ts`, `Phaser/3.x/src/dragonBones/phaser/display/ArmatureDisplay.ts`, `Phaser/3.x/src/dragonBones/phaser/util/TransformMatrix.ts`, `Phaser/Demos/src/BaseDemo.ts`, `Pixi/Demos/4.x/src/BaseDemo.ts`, `Pixi/Demos/4.x/src/CoreElement.ts`, `Pixi/Demos/8.x/src/BaseDemo.ts`, `Pixi/Demos/8.x/src/CoreElement.ts`, `ThreeJS/Demos/src/BaseDemo.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `Game`

Herança: extends BaseDemo.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 16 |
| `preload` | método | `preload(): void` | 20 |
| `create` | método | `create(): void` | 28 |
| `update` | método | `update(time: number, delta: number): void` | 44 |
| `_inputDown` | método | `private _inputDown(): void` | 59 |
| `_inputUp` | método | `private _inputUp(): void` | 63 |
| `_keyHandler` | método | `private _keyHandler(event: KeyboardEvent): void` | 67 |
| `_updateMove` | método | `private _updateMove(dir: number): void` | 114 |
| `addBullet` | método | `public addBullet(bullet: Bullet): void` | 129 |
| `GROUND` | propriedade | `public static GROUND: number;` | 7 |
| `G` | propriedade | `public static G: number = 0.6;` | 8 |
| `instance` | propriedade | `public static instance: Game;` | 9 |
| `_left` | propriedade | `private _left: boolean = false;` | 11 |
| `_right` | propriedade | `private _right: boolean = false;` | 12 |
| `_player` | propriedade | `private _player: Mecha;` | 13 |
| `_bullets` | propriedade | `private readonly _bullets: Bullet[] = [];` | 14 |

#### ClassDeclaration `Mecha`

Herança: nenhuma explícita.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor(scene: Phaser.Scene)` | 172 |
| `move` | método | `public move(dir: number): void` | 194 |
| `jump` | método | `public jump(): void` | 203 |
| `squat` | método | `public squat(isSquating: boolean): void` | 217 |
| `attack` | método | `public attack(isAttacking: boolean): void` | 226 |
| `switchWeaponL` | método | `public switchWeaponL(): void` | 234 |
| `switchWeaponR` | método | `public switchWeaponR(): void` | 249 |
| `switchSkin` | método | `public switchSkin(): void` | 264 |
| `aim` | método | `public aim(x: number, y: number): void` | 272 |
| `update` | método | `public update(): void` | 277 |
| `_animationEventHandler` | método | `private _animationEventHandler(event: EventType): void` | 283 |
| `_frameEventHandler` | método | `private _frameEventHandler(event: EventType): void` | 321 |
| `_fire` | método | `private _fire(firePoint: PointType): void` | 328 |
| `_updateAnimation` | método | `private _updateAnimation(): void` | 334 |
| `_updatePosition` | método | `private _updatePosition(): void` | 385 |
| `_updateAim` | método | `private _updateAim(): void` | 422 |
| `_updateAttack` | método | `private _updateAttack(): void` | 475 |
| `JUMP_SPEED` | propriedade | `private static readonly JUMP_SPEED: number = 20;` | 135 |
| `NORMALIZE_MOVE_SPEED` | propriedade | `private static readonly NORMALIZE_MOVE_SPEED: number = 3.6;` | 136 |
| `MAX_MOVE_SPEED_FRONT` | propriedade | `private static readonly MAX_MOVE_SPEED_FRONT: number = Mecha.NORMALIZE_MOVE_SPEED * 1.4;` | 137 |
| `MAX_MOVE_SPEED_BACK` | propriedade | `private static readonly MAX_MOVE_SPEED_BACK: number = Mecha.NORMALIZE_MOVE_SPEED * 1.0;` | 138 |
| `NORMAL_ANIMATION_GROUP` | propriedade | `private static readonly NORMAL_ANIMATION_GROUP: string = "normal";` | 139 |
| `AIM_ANIMATION_GROUP` | propriedade | `private static readonly AIM_ANIMATION_GROUP: string = "aim";` | 140 |
| `ATTACK_ANIMATION_GROUP` | propriedade | `private static readonly ATTACK_ANIMATION_GROUP: string = "attack";` | 141 |
| `WEAPON_L_LIST` | propriedade | `private static readonly WEAPON_L_LIST: string[] = ["weapon_1502b_l", "weapon_1005", "weapon_1005b", "weapon_1005c", "weapon_1005d", "weapon_1005e"];` | 142 |
| `WEAPON_R_LIST` | propriedade | `private static readonly WEAPON_R_LIST: string[] = ["weapon_1502b_r", "weapon_1005", "weapon_1005b", "weapon_1005c", "weapon_1005d"];` | 143 |
| `SKINS` | propriedade | `private static readonly SKINS: string[] = ["mecha_1502b", "skin_a", "skin_b", "skin_c"];` | 144 |
| `_isJumpingA` | propriedade | `private _isJumpingA: boolean = false;` | 146 |
| `_isSquating` | propriedade | `private _isSquating: boolean = false;` | 147 |
| `_isAttackingA` | propriedade | `private _isAttackingA: boolean = false;` | 148 |
| `_isAttackingB` | propriedade | `private _isAttackingB: boolean = false;` | 149 |
| `_weaponRIndex` | propriedade | `private _weaponRIndex: number = 0;` | 150 |
| `_weaponLIndex` | propriedade | `private _weaponLIndex: number = 0;` | 151 |
| `_skinIndex` | propriedade | `private _skinIndex: number = 0;` | 152 |
| `_faceDir` | propriedade | `private _faceDir: number = 1;` | 153 |
| `_aimDir` | propriedade | `private _aimDir: number = 0;` | 154 |
| `_moveDir` | propriedade | `private _moveDir: number = 0;` | 155 |
| `_aimRadian` | propriedade | `private _aimRadian: number = 0.0;` | 156 |
| `_speedX` | propriedade | `private _speedX: number = 0.0;` | 157 |
| `_speedY` | propriedade | `private _speedY: number = 0.0;` | 158 |
| `_armature` | propriedade | `private _armature: dragonBones.Armature;` | 159 |
| `_armatureDisplay` | propriedade | `private _armatureDisplay: ArmatureDisplayType;` | 160 |
| `_weaponL` | propriedade | `private _weaponL: dragonBones.Armature;` | 161 |
| `_weaponR` | propriedade | `private _weaponR: dragonBones.Armature;` | 162 |
| `_aimState` | propriedade | `private _aimState: dragonBones.AnimationState = null;` | 163 |
| `_walkState` | propriedade | `private _walkState: dragonBones.AnimationState = null;` | 164 |
| `_attackState` | propriedade | `private _attackState: dragonBones.AnimationState = null;` | 165 |
| `_target` | propriedade | `private readonly _target: PointType = new Phaser.Math.Vector2();` | 166 |
| `_helpPoint` | propriedade | `private readonly _helpPoint: PointType = new Phaser.Math.Vector2();` | 167 |
| `_helperMatrix` | propriedade | `private _helperMatrix: Phaser.GameObjects.Components.TransformMatrix = new Phaser.GameObjects.Components.TransformMatrix();` | 168 |
| `scene` | propriedade | `private scene: Phaser.Scene;` | 170 |

#### ClassDeclaration `Bullet`

Herança: nenhuma explícita.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor(scene: Phaser.Scene, armatureName: string, effectArmatureName: string, radian: number, speed: number, position: PointType)` | 499 |
| `update` | método | `public update(): boolean` | 525 |
| `_speedX` | propriedade | `private _speedX: number = 0.0;` | 492 |
| `_speedY` | propriedade | `private _speedY: number = 0.0;` | 493 |
| `scene` | propriedade | `private scene: Phaser.Scene;` | 494 |
| `_armatureDisplay` | propriedade | `private _armatureDisplay: ArmatureDisplayType;` | 496 |
| `_effecDisplay` | propriedade | `private _effecDisplay: ArmatureDisplayType = null;` | 497 |

### `Phaser/Demos/src/DragHelper.ts`

- Origem/commit: `Phaser/Demos/src/DragHelper.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/Demos/assets/Script/DragHelper.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `Egret/Demos/src/DragHelper.ts`, `Phaser/3.x/src/dragonBones/phaser/display/ArmatureDisplay.ts`, `Pixi/Demos/4.x/src/DragHelper.ts`, `Pixi/Demos/8.x/src/DragHelper.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `DragHelper`

Herança: nenhuma explícita.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `getInstance` | método | `public static getInstance(): DragHelper` | 3 |
| `enableDrag` | método | `public enableDrag(scene: Phaser.Scene, displayObject: Phaser.GameObjects.GameObject): void` | 11 |
| `disableDrag` | método | `public disableDrag(scene: Phaser.Scene, displayObject: Phaser.GameObjects.Sprite): void` | 18 |
| `_dragStartHandler` | método | `private _dragStartHandler(displayObject: Phaser.GameObjects.GameObject, pointer: Phaser.Input.Pointer, dragX: number, dragY: number): void` | 25 |
| `_dragStopHandler` | método | `private _dragStopHandler(pointer: Phaser.Input.Pointer, dragX: number, dragY: number, dropped: boolean): void` | 52 |
| `_dragHandler` | método | `private _dragHandler(pointer: Phaser.Input.Pointer, localX: number, localY: number): void` | 61 |
| `_instance` | propriedade | `private static _instance: DragHelper = new DragHelper();` | 2 |
| `_helpPoint` | propriedade | `private readonly _helpPoint: Phaser.Math.Vector2 = new Phaser.Math.Vector2();` | 7 |
| `_dragOffset` | propriedade | `private readonly _dragOffset: Phaser.Math.Vector2 = new Phaser.Math.Vector2();` | 8 |
| `_dragDisplayObject` | propriedade | `private _dragDisplayObject: Phaser.GameObjects.GameObject = null;` | 9 |

### `Phaser/Demos/src/DragonBonesEvent.ts`

- Origem/commit: `Phaser/Demos/src/DragonBonesEvent.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/Demos/assets/Script/DragonBonesEvent.ts`, `DragonBones/src/dragonBones/event/EventObject.ts`, `Egret/Demos/src/BaseDemo.ts`, `Egret/Demos/src/demo/DragonBonesEvent.ts`, `Phaser/3.x/src/dragonBones/phaser/display/ArmatureDisplay.ts`, `Phaser/Demos/src/BaseDemo.ts`, `Pixi/Demos/4.x/src/BaseDemo.ts`, `Pixi/Demos/4.x/src/DragonBonesEvent.ts`, `Pixi/Demos/8.x/src/BaseDemo.ts`, `Pixi/Demos/8.x/src/DragonBonesEvent.ts`, `ThreeJS/Demos/src/BaseDemo.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `DragonBonesEvent`

Herança: extends BaseDemo.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 4 |
| `preload` | método | `preload(): void` | 8 |
| `create` | método | `create(): void` | 19 |
| `_animationEventHandler` | método | `private _animationEventHandler(event: dragonBones.EventObject): void` | 37 |
| `_armatureDisplay` | propriedade | `private _armatureDisplay: dragonBones.phaser.display.ArmatureDisplay;` | 2 |

### `Phaser/Demos/src/HelloDragonBones.ts`

- Origem/commit: `Phaser/Demos/src/HelloDragonBones.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/Demos/assets/Script/HelloDragonBones.ts`, `Egret/Demos/src/BaseDemo.ts`, `Egret/Demos/src/demo/HelloDragonBones.ts`, `Hilo/Demos/src/HelloDragonBones.ts`, `Phaser/Demos/src/BaseDemo.ts`, `Pixi/Demos/4.x/src/BaseDemo.ts`, `Pixi/Demos/4.x/src/HelloDragonBones.ts`, `Pixi/Demos/8.x/src/BaseDemo.ts`, `Pixi/Demos/8.x/src/HelloDragonBones.ts`, `ThreeJS/Demos/src/BaseDemo.ts`, `ThreeJS/Demos/src/HelloDragonBones.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `HelloDragonBones`

Herança: extends BaseDemo.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 3 |
| `preload` | método | `preload(): void` | 7 |
| `create` | método | `create(): void` | 21 |

### `Phaser/Demos/src/InverseKinematics.ts`

- Origem/commit: `Phaser/Demos/src/InverseKinematics.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/Demos/assets/Script/DragHelper.ts`, `Cocos/Demos/assets/Script/InverseKinematics.ts`, `DragonBones/src/dragonBones/animation/AnimationState.ts`, `DragonBones/src/dragonBones/armature/Bone.ts`, `DragonBones/src/dragonBones/geom/Transform.ts`, `Egret/Demos/src/BaseDemo.ts`, `Egret/Demos/src/DragHelper.ts`, `Egret/Demos/src/demo/InverseKinematics.ts`, `Phaser/3.x/src/dragonBones/phaser/display/ArmatureDisplay.ts`, `Phaser/Demos/src/BaseDemo.ts`, `Phaser/Demos/src/DragHelper.ts`, `Pixi/Demos/4.x/src/BaseDemo.ts`, `Pixi/Demos/4.x/src/DragHelper.ts`, `Pixi/Demos/4.x/src/InverseKinematics.ts`, `Pixi/Demos/8.x/src/BaseDemo.ts`, `Pixi/Demos/8.x/src/DragHelper.ts`, `Pixi/Demos/8.x/src/InverseKinematics.ts`, `ThreeJS/Demos/src/BaseDemo.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `InverseKinematics`

Herança: extends BaseDemo.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 15 |
| `preload` | método | `preload(): void` | 19 |
| `create` | método | `create(): void` | 36 |
| `update` | método | `update(time: number, delta: number): void` | 63 |
| `_updateAim` | método | `private _updateAim(): void` | 75 |
| `_updateFoot` | método | `private _updateFoot(): void` | 99 |
| `_faceDir` | propriedade | `private _faceDir: number = 0;` | 2 |
| `_aimRadian` | propriedade | `private _aimRadian: number = 0.0;` | 3 |
| `_offsetRotation` | propriedade | `private _offsetRotation: number = 0.0;` | 4 |
| `_target` | propriedade | `private readonly _target: Phaser.Math.Vector2 = new Phaser.Math.Vector2();` | 5 |
| `_armatureDisplay` | propriedade | `private _armatureDisplay: dragonBones.phaser.display.ArmatureDisplay;` | 6 |
| `_floorBoard` | propriedade | `private _floorBoard: dragonBones.phaser.display.ArmatureDisplay;` | 7 |
| `_chestBone` | propriedade | `private _chestBone: dragonBones.Bone;` | 8 |
| `_leftFootBone` | propriedade | `private _leftFootBone: dragonBones.Bone;` | 9 |
| `_rightFootBone` | propriedade | `private _rightFootBone: dragonBones.Bone;` | 10 |
| `_circleBone` | propriedade | `private _circleBone: dragonBones.Bone;` | 11 |
| `_floorBoardBone` | propriedade | `private _floorBoardBone: dragonBones.Bone;` | 12 |
| `_aimState` | propriedade | `private _aimState: dragonBones.AnimationState;` | 13 |

### `Phaser/Demos/src/PerformanceTest.ts`

- Origem/commit: `Phaser/Demos/src/PerformanceTest.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/Demos/assets/Script/PerformanceTest.ts`, `DragonBones/src/dragonBones/core/BaseObject.ts`, `Egret/Demos/src/BaseDemo.ts`, `Egret/Demos/src/demo/PerformanceTest.ts`, `Hilo/Demos/src/PerformanceTest.ts`, `Phaser/3.x/src/dragonBones/phaser/display/ArmatureDisplay.ts`, `Phaser/Demos/src/BaseDemo.ts`, `Pixi/Demos/4.x/src/BaseDemo.ts`, `Pixi/Demos/4.x/src/PerformanceTest.ts`, `Pixi/Demos/8.x/src/BaseDemo.ts`, `Pixi/Demos/8.x/src/PerformanceTest.ts`, `ThreeJS/Demos/src/BaseDemo.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `PerformanceTest`

Herança: extends BaseDemo.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 8 |
| `preload` | método | `preload(): void` | 12 |
| `create` | método | `create(): void` | 26 |
| `update` | método | `update(time: number, delta: number): void` | 46 |
| `_inputDown` | método | `private _inputDown(pointer: Phaser.Input.Pointer): void` | 69 |
| `_inputUp` | método | `private _inputUp(): void` | 75 |
| `_addArmature` | método | `private _addArmature(): void` | 80 |
| `_removeArmature` | método | `private _removeArmature(): void` | 89 |
| `_resetPosition` | método | `private _resetPosition(): void` | 103 |
| `_updateText` | método | `private _updateText(): void` | 128 |
| `_addingArmature` | propriedade | `private _addingArmature: boolean = false;` | 2 |
| `_removingArmature` | propriedade | `private _removingArmature: boolean = false;` | 3 |
| `_armatures` | propriedade | `private readonly _armatures: Array<dragonBones.phaser.display.ArmatureDisplay> = [];` | 4 |
| `_text` | propriedade | `private _text: Phaser.GameObjects.Text;` | 5 |
| `_perfText` | propriedade | `private _perfText: Phaser.GameObjects.Text;` | 6 |

### `Phaser/Demos/src/ReplaceAnimation.ts`

- Origem/commit: `Phaser/Demos/src/ReplaceAnimation.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Egret/Demos/src/BaseDemo.ts`, `Egret/Demos/src/demo/ReplaceAnimation.ts`, `Hilo/Demos/src/ReplaceAnimation.ts`, `Phaser/3.x/src/dragonBones/phaser/display/ArmatureDisplay.ts`, `Phaser/Demos/src/BaseDemo.ts`, `Pixi/Demos/4.x/src/BaseDemo.ts`, `Pixi/Demos/4.x/src/ReplaceAnimation.ts`, `Pixi/Demos/8.x/src/BaseDemo.ts`, `Pixi/Demos/8.x/src/ReplaceAnimation.ts`, `ThreeJS/Demos/src/BaseDemo.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `ReplaceAnimation`

Herança: extends BaseDemo.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 7 |
| `preload` | método | `preload(): void` | 11 |
| `create` | método | `create(): void` | 22 |
| `_changeAnimation` | método | `private _changeAnimation(): void` | 56 |
| `_armatureDisplayA` | propriedade | `private _armatureDisplayA: dragonBones.phaser.display.ArmatureDisplay;` | 2 |
| `_armatureDisplayB` | propriedade | `private _armatureDisplayB: dragonBones.phaser.display.ArmatureDisplay;` | 3 |
| `_armatureDisplayC` | propriedade | `private _armatureDisplayC: dragonBones.phaser.display.ArmatureDisplay;` | 4 |
| `_armatureDisplayD` | propriedade | `private _armatureDisplayD: dragonBones.phaser.display.ArmatureDisplay;` | 5 |

### `Phaser/Demos/src/ReplaceSlotDisplay.ts`

- Origem/commit: `Phaser/Demos/src/ReplaceSlotDisplay.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/Demos/assets/Script/ReplaceAnimation.ts`, `Cocos/Demos/assets/Script/ReplaceSlotDisplay.ts`, `Egret/Demos/src/BaseDemo.ts`, `Egret/Demos/src/demo/ReplaceSlotDisplay.ts`, `Hilo/Demos/src/ReplaceSlotDisplay.ts`, `Phaser/3.x/src/dragonBones/phaser/Factory.ts`, `Phaser/3.x/src/dragonBones/phaser/display/ArmatureDisplay.ts`, `Phaser/Demos/src/BaseDemo.ts`, `Pixi/Demos/4.x/src/BaseDemo.ts`, `Pixi/Demos/4.x/src/ReplaceSlotDisplay.ts`, `Pixi/Demos/8.x/src/BaseDemo.ts`, `Pixi/Demos/8.x/src/ReplaceSlotDisplay.ts`, `ThreeJS/Demos/src/BaseDemo.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `ReplaceSlotDisplay`

Herança: extends BaseDemo.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 10 |
| `preload` | método | `preload(): void` | 14 |
| `create` | método | `create(): void` | 31 |
| `_replaceDisplay` | método | `private _replaceDisplay(type: number): void` | 57 |
| `WEAPON_RIGHT_LIST` | propriedade | `private static readonly WEAPON_RIGHT_LIST: string[] = ["weapon_1004_r", "weapon_1004b_r", "weapon_1004c_r", "weapon_1004d_r", "weapon_1004e_r"];` | 2 |
| `_leftWeaponIndex` | propriedade | `private _leftWeaponIndex: number = 0;` | 4 |
| `_rightWeaponIndex` | propriedade | `private _rightWeaponIndex: number = 0;` | 5 |
| `_factory` | propriedade | `private _factory: dragonBones.phaser.Factory = null;` | 6 |
| `_armatureDisplay` | propriedade | `private _armatureDisplay: dragonBones.phaser.display.ArmatureDisplay;` | 7 |
| `_logoText` | propriedade | `private _logoText: Phaser.GameObjects.Text;` | 8 |

### `Pixi/4.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`

- Origem/commit: `Pixi/4.x/src/dragonBones/pixi/PixiArmatureDisplay.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: integrations/Pixi/4.x/src/dragonBones/pixi/PixiArmatureDisplay.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/animation/Animation.ts`, `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/armature/IArmatureProxy.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/event/EventObject.ts`, `DragonBones/src/dragonBones/geom/Rectangle.ts`, `DragonBones/src/dragonBones/model/BoundingBoxData.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `PixiArmatureDisplay`

Herança: extends PIXI.Sprite; implements IArmatureProxy.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `dbInit` | método | `public dbInit(armature: Armature): void` | 40 |
| `dbClear` | método | `public dbClear(): void` | 46 |
| `dbUpdate` | método | `public dbUpdate(): void` | 59 |
| `dispose` | método | `public dispose(disposeProxy: boolean = true): void` | 167 |
| `destroy` | método | `public destroy(): void` | 178 |
| `dispatchDBEvent` | método | `public dispatchDBEvent(type: EventStringType, eventObject: EventObject): void` | 184 |
| `hasDBEventListener` | método | `public hasDBEventListener(type: EventStringType): boolean` | 190 |
| `addDBEventListener` | método | `public addDBEventListener(type: EventStringType, listener: (event: EventObject) => void, target: any): void` | 196 |
| `removeDBEventListener` | método | `public removeDBEventListener(type: EventStringType, listener: (event: EventObject) => void, target: any): void` | 202 |
| `armature` | método | `public get armature(): Armature` | 208 |
| `animation` | método | `public get animation(): Animation` | 214 |
| `debugDraw` | propriedade | `public debugDraw: boolean = false;` | 32 |
| `_debugDraw` | propriedade | `private _debugDraw: boolean = false;` | 33 |
| `_armature` | propriedade | `private _armature: Armature = null as any;` | 35 |
| `_debugDrawer` | propriedade | `private _debugDrawer: PIXI.Sprite \| null = null;` | 36 |

### `Pixi/4.x/src/dragonBones/pixi/PixiFactory.ts`

- Origem/commit: `Pixi/4.x/src/dragonBones/pixi/PixiFactory.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: integrations/Pixi/4.x/src/dragonBones/pixi/PixiFactory.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/armature/Slot.ts`, `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/factory/BaseFactory.ts`, `DragonBones/src/dragonBones/model/ArmatureData.ts`, `DragonBones/src/dragonBones/parser/DataParser.ts`, `Phaser/3.x/src/dragonBones/phaser/display/Slot.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiSlot.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiTextureAtlasData.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiSlot.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiTextureAtlasData.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiSlot.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiTextureAtlasData.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `PixiFactory`

Herança: extends BaseFactory.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `_clockHandler` | método | `private static _clockHandler(passedTime: number): void` | 38 |
| `factory` | método | `public static get factory(): PixiFactory` | 51 |
| `constructor` | método | `public constructor(dataParser: DataParser \| null = null)` | 61 |
| `_buildTextureAtlasData` | método | `protected _buildTextureAtlasData(textureAtlasData: PixiTextureAtlasData \| null, textureAtlas: PIXI.BaseTexture \| null): PixiTextureAtlasData` | 73 |
| `_buildArmature` | método | `protected _buildArmature(dataPackage: BuildArmaturePackage): Armature` | 84 |
| `_buildSlot` | método | `protected _buildSlot(_dataPackage: BuildArmaturePackage, slotData: SlotData, armature: Armature): Slot` | 96 |
| `buildArmatureDisplay` | método | `public buildArmatureDisplay(armatureName: string, dragonBonesName: string = "", skinName: string = "", textureAtlasName: string = ""): PixiArmatureDisplay \| null` | 137 |
| `getTextureDisplay` | método | `public getTextureDisplay(textureName: string, textureAtlasName: string \| null = null): PIXI.Sprite \| null` | 161 |
| `soundEventManager` | método | `public get soundEventManager(): PixiArmatureDisplay` | 181 |
| `_dragonBonesInstance` | propriedade | `private static _dragonBonesInstance: DragonBones = null as any;` | 36 |
| `_factory` | propriedade | `private static _factory: PixiFactory = null as any;` | 37 |

### `Pixi/4.x/src/dragonBones/pixi/PixiSlot.ts`

- Origem/commit: `Pixi/4.x/src/dragonBones/pixi/PixiSlot.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: integrations/Pixi/4.x/src/dragonBones/pixi/PixiSlot.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/armature/Bone.ts`, `DragonBones/src/dragonBones/armature/Slot.ts`, `DragonBones/src/dragonBones/armature/Surface.ts`, `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/model/DisplayData.ts`, `Phaser/3.x/src/dragonBones/phaser/display/Slot.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiTextureAtlasData.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiSlot.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiTextureAtlasData.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiSlot.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiTextureAtlasData.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `PixiSlot`

Herança: extends Slot.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 36 |
| `_onClear` | método | `protected _onClear(): void` | 43 |
| `_initDisplay` | método | `protected _initDisplay(value: any, isRetain: boolean): void` | 51 |
| `_disposeDisplay` | método | `protected _disposeDisplay(value: any, isRelease: boolean): void` | 58 |
| `_onUpdateDisplay` | método | `protected _onUpdateDisplay(): void` | 66 |
| `_addDisplay` | método | `protected _addDisplay(): void` | 70 |
| `_replaceDisplay` | método | `protected _replaceDisplay(value: any): void` | 75 |
| `_removeDisplay` | método | `protected _removeDisplay(): void` | 84 |
| `_updateZOrder` | método | `protected _updateZOrder(): void` | 88 |
| `_updateVisible` | método | `public _updateVisible(): void` | 100 |
| `_updateBlendMode` | método | `protected _updateBlendMode(): void` | 104 |
| `_updateColor` | método | `protected _updateColor(): void` | 150 |
| `_updateFrame` | método | `protected _updateFrame(): void` | 161 |
| `_updateMesh` | método | `protected _updateMesh(): void` | 267 |
| `_updateTransform` | método | `protected _updateTransform(): void` | 354 |
| `_updateTransformV3` | método | `protected _updateTransformV3(): void` | 358 |
| `_updateTransformV4` | método | `protected _updateTransformV4(): void` | 381 |
| `_identityTransform` | método | `protected _identityTransform(): void` | 404 |
| `_textureScale` | propriedade | `private _textureScale: number;` | 40 |
| `_renderDisplay` | propriedade | `private _renderDisplay: PIXI.DisplayObject;` | 41 |

### `Pixi/4.x/src/dragonBones/pixi/PixiTextureAtlasData.ts`

- Origem/commit: `Pixi/4.x/src/dragonBones/pixi/PixiTextureAtlasData.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: integrations/Pixi/4.x/src/dragonBones/pixi/PixiTextureAtlasData.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/geom/Rectangle.ts`, `DragonBones/src/dragonBones/model/TextureAtlasData.ts`, `Phaser/3.x/src/dragonBones/phaser/display/TextureAtlasData.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiTextureAtlasData.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiTextureAtlasData.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `PixiTextureAtlasData`

Herança: extends TextureAtlasData.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 36 |
| `_onClear` | método | `protected _onClear(): void` | 42 |
| `createTexture` | método | `public createTexture(): TextureData` | 54 |
| `renderTexture` | método | `public get renderTexture(): PIXI.BaseTexture \| null` | 67 |
| `renderTexture` | método | `public set renderTexture(value: PIXI.BaseTexture \| null)` | 70 |
| `_renderTexture` | propriedade | `private _renderTexture: PIXI.BaseTexture \| null = null;` | 40 |

#### ClassDeclaration `PixiTextureData`

Herança: extends TextureData.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 102 |
| `_onClear` | método | `protected _onClear(): void` | 108 |
| `renderTexture` | propriedade | `public renderTexture: PIXI.Texture \| null = null;` | 106 |

### `Pixi/5.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`

- Origem/commit: `Pixi/5.x/src/dragonBones/pixi/PixiArmatureDisplay.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: integrations/Pixi/5.x/src/dragonBones/pixi/PixiArmatureDisplay.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/animation/Animation.ts`, `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/armature/IArmatureProxy.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/event/EventObject.ts`, `DragonBones/src/dragonBones/geom/Rectangle.ts`, `DragonBones/src/dragonBones/model/BoundingBoxData.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `PixiArmatureDisplay`

Herança: extends PIXI.Sprite; implements IArmatureProxy.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `dbInit` | método | `public dbInit(armature: Armature): void` | 40 |
| `dbClear` | método | `public dbClear(): void` | 46 |
| `dbUpdate` | método | `public dbUpdate(): void` | 59 |
| `dispose` | método | `public dispose(disposeProxy: boolean = true): void` | 167 |
| `destroy` | método | `public destroy(): void` | 178 |
| `dispatchDBEvent` | método | `public dispatchDBEvent(type: EventStringType, eventObject: EventObject): void` | 184 |
| `hasDBEventListener` | método | `public hasDBEventListener(type: EventStringType): boolean` | 190 |
| `addDBEventListener` | método | `public addDBEventListener(type: EventStringType, listener: (event: EventObject) => void, target: any): void` | 198 |
| `removeDBEventListener` | método | `public removeDBEventListener(type: EventStringType, listener: (event: EventObject) => void, target: any): void` | 204 |
| `armature` | método | `public get armature(): Armature` | 210 |
| `animation` | método | `public get animation(): Animation` | 216 |
| `debugDraw` | propriedade | `public debugDraw: boolean = false;` | 32 |
| `_debugDraw` | propriedade | `private _debugDraw: boolean = false;` | 33 |
| `_armature` | propriedade | `private _armature: Armature = null as any;` | 35 |
| `_debugDrawer` | propriedade | `private _debugDrawer: PIXI.Sprite \| null = null;` | 36 |

### `Pixi/5.x/src/dragonBones/pixi/PixiFactory.ts`

- Origem/commit: `Pixi/5.x/src/dragonBones/pixi/PixiFactory.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: integrations/Pixi/5.x/src/dragonBones/pixi/PixiFactory.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/armature/Slot.ts`, `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/factory/BaseFactory.ts`, `DragonBones/src/dragonBones/model/ArmatureData.ts`, `DragonBones/src/dragonBones/parser/DataParser.ts`, `Phaser/3.x/src/dragonBones/phaser/display/Slot.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiSlot.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiTextureAtlasData.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiSlot.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiTextureAtlasData.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiSlot.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiTextureAtlasData.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `PixiFactory`

Herança: extends BaseFactory.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `_clockHandler` | método | `private static _clockHandler(passedTime: number): void` | 38 |
| `advanceTime` | método | `public static advanceTime(passedTime: number): void` | 45 |
| `factory` | método | `public static get factory(): PixiFactory` | 64 |
| `newInstance` | método | `public static newInstance(useSharedTicker = true): PixiFactory` | 77 |
| `constructor` | método | `public constructor(dataParser: DataParser \| null = null, useSharedTicker = true)` | 87 |
| `_buildTextureAtlasData` | método | `protected _buildTextureAtlasData(textureAtlasData: PixiTextureAtlasData \| null, textureAtlas: PIXI.BaseTexture \| null): PixiTextureAtlasData` | 101 |
| `_buildArmature` | método | `protected _buildArmature(dataPackage: BuildArmaturePackage): Armature` | 112 |
| `_buildSlot` | método | `protected _buildSlot(_dataPackage: BuildArmaturePackage, slotData: SlotData, armature: Armature): Slot` | 124 |
| `buildArmatureDisplay` | método | `public buildArmatureDisplay(armatureName: string, dragonBonesName: string = "", skinName: string = "", textureAtlasName: string = ""): PixiArmatureDisplay \| null` | 165 |
| `getTextureDisplay` | método | `public getTextureDisplay(textureName: string, textureAtlasName: string \| null = null): PIXI.Sprite \| null` | 189 |
| `soundEventManager` | método | `public get soundEventManager(): PixiArmatureDisplay` | 209 |
| `_dragonBonesInstance` | propriedade | `private static _dragonBonesInstance: DragonBones = null as any;` | 36 |
| `_factory` | propriedade | `private static _factory: PixiFactory = null as any;` | 37 |
| `useSharedTicker` | propriedade | `public static useSharedTicker: boolean = true;` | 52 |

### `Pixi/5.x/src/dragonBones/pixi/PixiSlot.ts`

- Origem/commit: `Pixi/5.x/src/dragonBones/pixi/PixiSlot.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: integrations/Pixi/5.x/src/dragonBones/pixi/PixiSlot.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/armature/Bone.ts`, `DragonBones/src/dragonBones/armature/Slot.ts`, `DragonBones/src/dragonBones/armature/Surface.ts`, `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/model/DisplayData.ts`, `Phaser/3.x/src/dragonBones/phaser/display/Slot.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiSlot.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiTextureAtlasData.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiTextureAtlasData.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiSlot.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiTextureAtlasData.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `PixiSlot`

Herança: extends Slot.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 36 |
| `_onClear` | método | `protected _onClear(): void` | 43 |
| `_initDisplay` | método | `protected _initDisplay(value: any, isRetain: boolean): void` | 51 |
| `_disposeDisplay` | método | `protected _disposeDisplay(value: any, isRelease: boolean): void` | 58 |
| `_onUpdateDisplay` | método | `protected _onUpdateDisplay(): void` | 66 |
| `_addDisplay` | método | `protected _addDisplay(): void` | 70 |
| `_replaceDisplay` | método | `protected _replaceDisplay(value: any): void` | 75 |
| `_removeDisplay` | método | `protected _removeDisplay(): void` | 84 |
| `_updateZOrder` | método | `protected _updateZOrder(): void` | 88 |
| `_updateVisible` | método | `public _updateVisible(): void` | 100 |
| `_updateBlendMode` | método | `protected _updateBlendMode(): void` | 104 |
| `_updateColor` | método | `protected _updateColor(): void` | 150 |
| `_updateFrame` | método | `protected _updateFrame(): void` | 161 |
| `_updateMesh` | método | `protected _updateMesh(): void` | 265 |
| `_updateTransform` | método | `protected _updateTransform(): void` | 352 |
| `_updateTransformV3` | método | `protected _updateTransformV3(): void` | 356 |
| `_updateTransformV4` | método | `protected _updateTransformV4(): void` | 379 |
| `_identityTransform` | método | `protected _identityTransform(): void` | 402 |
| `_textureScale` | propriedade | `private _textureScale: number;` | 40 |
| `_renderDisplay` | propriedade | `private _renderDisplay: PIXI.DisplayObject;` | 41 |

### `Pixi/5.x/src/dragonBones/pixi/PixiTextureAtlasData.ts`

- Origem/commit: `Pixi/5.x/src/dragonBones/pixi/PixiTextureAtlasData.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: integrations/Pixi/5.x/src/dragonBones/pixi/PixiTextureAtlasData.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/geom/Rectangle.ts`, `DragonBones/src/dragonBones/model/TextureAtlasData.ts`, `Phaser/3.x/src/dragonBones/phaser/display/TextureAtlasData.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiTextureAtlasData.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiTextureAtlasData.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `PixiTextureAtlasData`

Herança: extends TextureAtlasData.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 36 |
| `_onClear` | método | `protected _onClear(): void` | 42 |
| `createTexture` | método | `public createTexture(): TextureData` | 54 |
| `renderTexture` | método | `public get renderTexture(): PIXI.BaseTexture \| null` | 67 |
| `renderTexture` | método | `public set renderTexture(value: PIXI.BaseTexture \| null)` | 70 |
| `_renderTexture` | propriedade | `private _renderTexture: PIXI.BaseTexture \| null = null;` | 40 |

#### ClassDeclaration `PixiTextureData`

Herança: extends TextureData.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 102 |
| `_onClear` | método | `protected _onClear(): void` | 108 |
| `renderTexture` | propriedade | `public renderTexture: PIXI.Texture \| null = null;` | 106 |

### `Pixi/8.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`

- Origem/commit: `Pixi/8.x/src/dragonBones/pixi/PixiArmatureDisplay.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: integrations/Pixi/8.x/src/dragonBones/pixi/PixiArmatureDisplay.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/animation/Animation.ts`, `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/armature/IArmatureProxy.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/event/EventObject.ts`, `DragonBones/src/dragonBones/geom/Rectangle.ts`, `DragonBones/src/dragonBones/model/BoundingBoxData.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `PixiArmatureDisplay`

Herança: extends PIXI.Container; implements IArmatureProxy.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `dbInit` | método | `public dbInit(armature: Armature): void` | 40 |
| `dbClear` | método | `public dbClear(): void` | 46 |
| `dbUpdate` | método | `public dbUpdate(): void` | 59 |
| `dispose` | método | `public dispose(disposeProxy: boolean = true): void` | 168 |
| `destroy` | método | `public destroy(): void` | 179 |
| `dispatchDBEvent` | método | `public dispatchDBEvent(type: EventStringType, eventObject: EventObject): void` | 185 |
| `hasDBEventListener` | método | `public hasDBEventListener(type: EventStringType): boolean` | 191 |
| `addDBEventListener` | método | `public addDBEventListener(type: EventStringType, listener: (event: EventObject) => void, target: any): void` | 199 |
| `removeDBEventListener` | método | `public removeDBEventListener(type: EventStringType, listener: (event: EventObject) => void, target: any): void` | 205 |
| `armature` | método | `public get armature(): Armature` | 211 |
| `animation` | método | `public get animation(): Animation` | 217 |
| `debugDraw` | propriedade | `public debugDraw: boolean = false;` | 32 |
| `_debugDraw` | propriedade | `private _debugDraw: boolean = false;` | 33 |
| `_armature` | propriedade | `private _armature: Armature = null as any;` | 35 |
| `_debugDrawer` | propriedade | `private _debugDrawer: PIXI.Container \| null = null;` | 36 |

### `Pixi/8.x/src/dragonBones/pixi/PixiDBBinParser.ts`

- Origem/commit: `Pixi/8.x/src/dragonBones/pixi/PixiDBBinParser.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: integrations/Pixi/8.x/src/dragonBones/pixi/PixiDBBinParser.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: nenhuma declaração autoral identificada.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `PixiDBBinParser`

Herança: implements PIXI.LoaderParser<ArrayBuffer>.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `constructor()` | 5 |
| `test` | método | `test(url: string): boolean` | 13 |
| `load` | método | `load(url: string): Promise<ArrayBuffer>` | 17 |
| `parse` | método | `parse(asset: ArrayBuffer): any` | 21 |
| `extension` | propriedade | `public extension: PIXI.ExtensionMetadataDetails;` | 3 |
| `name` | propriedade | `public name: string = 'dbbin-loader';` | 4 |

### `Pixi/8.x/src/dragonBones/pixi/PixiFactory.ts`

- Origem/commit: `Pixi/8.x/src/dragonBones/pixi/PixiFactory.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: integrations/Pixi/8.x/src/dragonBones/pixi/PixiFactory.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/armature/Slot.ts`, `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/factory/BaseFactory.ts`, `DragonBones/src/dragonBones/model/ArmatureData.ts`, `DragonBones/src/dragonBones/parser/DataParser.ts`, `Phaser/3.x/src/dragonBones/phaser/display/Slot.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiSlot.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiTextureAtlasData.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiSlot.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiTextureAtlasData.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiDBBinParser.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiSlot.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiTextureAtlasData.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `PixiFactory`

Herança: extends BaseFactory.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `_clockHandler` | método | `private static _clockHandler(ticker: PIXI.Ticker): void` | 38 |
| `advanceTime` | método | `public static advanceTime(passedTime: number): void` | 46 |
| `factory` | método | `public static get factory(): PixiFactory` | 65 |
| `newInstance` | método | `public static newInstance(useSharedTicker = true): PixiFactory` | 78 |
| `constructor` | método | `public constructor(dataParser: DataParser \| null = null, useSharedTicker = true)` | 88 |
| `_buildTextureAtlasData` | método | `protected _buildTextureAtlasData(textureAtlasData: PixiTextureAtlasData \| null, textureAtlas: PIXI.TextureSource \| null): PixiTextureAtlasData` | 103 |
| `_buildArmature` | método | `protected _buildArmature(dataPackage: BuildArmaturePackage): Armature` | 114 |
| `_buildSlot` | método | `protected _buildSlot(_dataPackage: BuildArmaturePackage, slotData: SlotData, armature: Armature): Slot` | 126 |
| `buildArmatureDisplay` | método | `public buildArmatureDisplay(armatureName: string, dragonBonesName: string = "", skinName: string = "", textureAtlasName: string = ""): PixiArmatureDisplay \| null` | 167 |
| `getTextureDisplay` | método | `public getTextureDisplay(textureName: string, textureAtlasName: string \| null = null): PIXI.Sprite \| null` | 191 |
| `soundEventManager` | método | `public get soundEventManager(): PixiArmatureDisplay` | 211 |
| `_dragonBonesInstance` | propriedade | `private static _dragonBonesInstance: DragonBones = null as any;` | 36 |
| `_factory` | propriedade | `private static _factory: PixiFactory = null as any;` | 37 |
| `useSharedTicker` | propriedade | `public static useSharedTicker: boolean = true;` | 53 |

### `Pixi/8.x/src/dragonBones/pixi/PixiSlot.ts`

- Origem/commit: `Pixi/8.x/src/dragonBones/pixi/PixiSlot.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: integrations/Pixi/8.x/src/dragonBones/pixi/PixiSlot.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/armature/Bone.ts`, `DragonBones/src/dragonBones/armature/Slot.ts`, `DragonBones/src/dragonBones/armature/Surface.ts`, `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/model/DisplayData.ts`, `Phaser/3.x/src/dragonBones/phaser/display/Slot.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiSlot.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiTextureAtlasData.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiSlot.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiTextureAtlasData.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiTextureAtlasData.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `PixiSlot`

Herança: extends Slot.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 36 |
| `_onClear` | método | `protected _onClear(): void` | 43 |
| `_initDisplay` | método | `protected _initDisplay(value: any, isRetain: boolean): void` | 51 |
| `_disposeDisplay` | método | `protected _disposeDisplay(value: any, isRelease: boolean): void` | 58 |
| `_onUpdateDisplay` | método | `protected _onUpdateDisplay(): void` | 66 |
| `_addDisplay` | método | `protected _addDisplay(): void` | 70 |
| `_replaceDisplay` | método | `protected _replaceDisplay(value: any): void` | 75 |
| `_removeDisplay` | método | `protected _removeDisplay(): void` | 84 |
| `_updateZOrder` | método | `protected _updateZOrder(): void` | 88 |
| `_updateVisible` | método | `public _updateVisible(): void` | 100 |
| `_updateBlendMode` | método | `protected _updateBlendMode(): void` | 104 |
| `_updateColor` | método | `protected _updateColor(): void` | 150 |
| `_updateFrame` | método | `protected _updateFrame(): void` | 161 |
| `_updateMesh` | método | `protected _updateMesh(): void` | 265 |
| `_updateTransform` | método | `protected _updateTransform(): void` | 352 |
| `_updateTransformV3` | método | `protected _updateTransformV3(): void` | 356 |
| `_updateTransformV4` | método | `protected _updateTransformV4(): void` | 382 |
| `_identityTransform` | método | `protected _identityTransform(): void` | 407 |
| `_textureScale` | propriedade | `private _textureScale: number;` | 40 |
| `_renderDisplay` | propriedade | `private _renderDisplay: PIXI.Container \| PIXI.Sprite \| PIXI.MeshSimple;` | 41 |

### `Pixi/8.x/src/dragonBones/pixi/PixiTextureAtlasData.ts`

- Origem/commit: `Pixi/8.x/src/dragonBones/pixi/PixiTextureAtlasData.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: integrations/Pixi/8.x/src/dragonBones/pixi/PixiTextureAtlasData.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/geom/Rectangle.ts`, `DragonBones/src/dragonBones/model/TextureAtlasData.ts`, `Phaser/3.x/src/dragonBones/phaser/display/TextureAtlasData.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiTextureAtlasData.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiTextureAtlasData.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `PixiTextureAtlasData`

Herança: extends TextureAtlasData.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 36 |
| `_onClear` | método | `protected _onClear(): void` | 42 |
| `createTexture` | método | `public createTexture(): TextureData` | 54 |
| `renderTexture` | método | `public get renderTexture(): PIXI.TextureSource \| null` | 67 |
| `renderTexture` | método | `public set renderTexture(value: PIXI.TextureSource \| null)` | 70 |
| `_renderTexture` | propriedade | `private _renderTexture: PIXI.TextureSource \| null = null;` | 40 |

#### ClassDeclaration `PixiTextureData`

Herança: extends TextureData.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 102 |
| `_onClear` | método | `protected _onClear(): void` | 108 |
| `renderTexture` | propriedade | `public renderTexture: PIXI.Texture \| null = null;` | 106 |

### `Pixi/Demos/4.x/src/AnimationBase.ts`

- Origem/commit: `Pixi/Demos/4.x/src/AnimationBase.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/Demos/assets/Script/AnimationBase.ts`, `DragonBones/src/dragonBones/event/EventObject.ts`, `Egret/Demos/src/BaseDemo.ts`, `Egret/Demos/src/demo/AnimationBase.ts`, `Phaser/Demos/src/AnimationBase.ts`, `Phaser/Demos/src/BaseDemo.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/Demos/4.x/src/BaseDemo.ts`, `Pixi/Demos/8.x/src/AnimationBase.ts`, `Pixi/Demos/8.x/src/BaseDemo.ts`, `ThreeJS/Demos/src/BaseDemo.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `AnimationBase`

Herança: extends BaseDemo.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 4 |
| `_onStart` | método | `protected _onStart(): void` | 14 |
| `_touchHandler` | método | `private _touchHandler(event: PIXI.interaction.InteractionEvent): void` | 46 |
| `_animationEventHandler` | método | `private _animationEventHandler(event: dragonBones.EventObject): void` | 73 |
| `_armatureDisplay` | propriedade | `private _armatureDisplay: dragonBones.PixiArmatureDisplay;` | 2 |
| `_isTouched` | propriedade | `private _isTouched: boolean = false;` | 45 |

### `Pixi/Demos/4.x/src/AnimationLayer.ts`

- Origem/commit: `Pixi/Demos/4.x/src/AnimationLayer.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/Demos/assets/Script/AnimationLayer.ts`, `DragonBones/src/dragonBones/event/EventObject.ts`, `Egret/Demos/src/BaseDemo.ts`, `Egret/Demos/src/demo/AnimationLayer.ts`, `Phaser/Demos/src/AnimationLayer.ts`, `Phaser/Demos/src/BaseDemo.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/Demos/4.x/src/BaseDemo.ts`, `Pixi/Demos/8.x/src/AnimationLayer.ts`, `Pixi/Demos/8.x/src/BaseDemo.ts`, `ThreeJS/Demos/src/BaseDemo.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `AnimationLayer`

Herança: extends BaseDemo.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 4 |
| `_onStart` | método | `protected _onStart(): void` | 14 |
| `_animationEventHandler` | método | `private _animationEventHandler(event: dragonBones.EventObject): void` | 28 |
| `_armatureDisplay` | propriedade | `private _armatureDisplay: dragonBones.PixiArmatureDisplay;` | 2 |

### `Pixi/Demos/4.x/src/BaseDemo.ts`

- Origem/commit: `Pixi/Demos/4.x/src/BaseDemo.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/core/DragonBones.ts`, `Egret/Demos/src/BaseDemo.ts`, `Phaser/Demos/src/BaseDemo.ts`, `Pixi/Demos/8.x/src/BaseDemo.ts`, `ThreeJS/Demos/src/BaseDemo.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `BaseDemo`

Herança: extends PIXI.Container.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 8 |
| `_onStart` | método | `protected abstract _onStart(): void;` | 22 |
| `_renderHandler` | método | `protected _renderHandler(deltaTime: number): void` | 24 |
| `_startRenderTick` | método | `protected _startRenderTick(): void` | 28 |
| `_loadResources` | método | `protected _loadResources(): void` | 32 |
| `createText` | método | `public createText(string: string): PIXI.Text` | 58 |
| `stageWidth` | método | `public get stageWidth(): number` | 70 |
| `stageHeight` | método | `public get stageHeight(): number` | 74 |
| `BACKGROUND_URL` | propriedade | `private static BACKGROUND_URL: string = "resource/background.png";` | 2 |
| `_renderer` | propriedade | `protected readonly _renderer = new PIXI.WebGLRenderer(1136, 640);` | 3 |
| `_background` | propriedade | `protected readonly _background: PIXI.Sprite = new PIXI.Sprite(PIXI.Texture.EMPTY);` | 4 |
| `_resources` | propriedade | `protected readonly _resources: string[] = [];` | 5 |
| `_pixiResources` | propriedade | `protected _pixiResources: dragonBones.Map<PIXI.loaders.Resource>;` | 6 |

### `Pixi/Demos/4.x/src/BoneOffset.ts`

- Origem/commit: `Pixi/Demos/4.x/src/BoneOffset.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/Demos/assets/Script/BoneOffset.ts`, `DragonBones/src/dragonBones/event/EventObject.ts`, `Egret/Demos/src/BaseDemo.ts`, `Egret/Demos/src/demo/BoneOffset.ts`, `Phaser/Demos/src/BaseDemo.ts`, `Phaser/Demos/src/BoneOffset.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/Demos/4.x/src/BaseDemo.ts`, `Pixi/Demos/8.x/src/BaseDemo.ts`, `Pixi/Demos/8.x/src/BoneOffset.ts`, `ThreeJS/Demos/src/BaseDemo.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `BoneOffset`

Herança: extends BaseDemo.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 2 |
| `_onStart` | método | `protected _onStart(): void` | 12 |
| `_animationHandler` | método | `private _animationHandler(event: dragonBones.EventObject): void` | 28 |
| `_moveTo` | método | `private _moveTo(armatureDisplay: dragonBones.PixiArmatureDisplay): void` | 32 |

### `Pixi/Demos/4.x/src/BoundingBox.ts`

- Origem/commit: `Pixi/Demos/4.x/src/BoundingBox.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/Demos/assets/Script/BoundingBox.ts`, `Cocos/Demos/assets/Script/DragHelper.ts`, `DragonBones/src/dragonBones/armature/Bone.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/geom/Point.ts`, `Egret/Demos/src/BaseDemo.ts`, `Egret/Demos/src/DragHelper.ts`, `Egret/Demos/src/demo/BoundingBox.ts`, `Phaser/Demos/src/BaseDemo.ts`, `Phaser/Demos/src/BoundingBox.ts`, `Phaser/Demos/src/DragHelper.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/Demos/4.x/src/BaseDemo.ts`, `Pixi/Demos/4.x/src/DragHelper.ts`, `Pixi/Demos/8.x/src/BaseDemo.ts`, `Pixi/Demos/8.x/src/BoundingBox.ts`, `Pixi/Demos/8.x/src/DragHelper.ts`, `ThreeJS/Demos/src/BaseDemo.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `BoundingBox`

Herança: extends BaseDemo.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 14 |
| `_onStart` | método | `protected _onStart(): void` | 27 |
| `_enterFrameHandler` | método | `private _enterFrameHandler(deltaTime: number): void` | 69 |
| `_helpPointA` | propriedade | `private readonly _helpPointA: PIXI.Point = new PIXI.Point();` | 2 |
| `_helpPointB` | propriedade | `private readonly _helpPointB: PIXI.Point = new PIXI.Point();` | 3 |
| `_helpPointC` | propriedade | `private readonly _helpPointC: PIXI.Point = new PIXI.Point();` | 4 |
| `_armatureDisplay` | propriedade | `private _armatureDisplay: dragonBones.PixiArmatureDisplay;` | 6 |
| `_boundingBoxTester` | propriedade | `private _boundingBoxTester: dragonBones.PixiArmatureDisplay;` | 7 |
| `_targetA` | propriedade | `private _targetA: dragonBones.PixiArmatureDisplay;` | 8 |
| `_targetB` | propriedade | `private _targetB: dragonBones.PixiArmatureDisplay;` | 9 |
| `_line` | propriedade | `private _line: dragonBones.Bone;` | 10 |
| `_pointA` | propriedade | `private _pointA: dragonBones.Bone;` | 11 |
| `_pointB` | propriedade | `private _pointB: dragonBones.Bone;` | 12 |

### `Pixi/Demos/4.x/src/CoreElement.ts`

- Origem/commit: `Pixi/Demos/4.x/src/CoreElement.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/Demos/assets/Script/CoreElement.ts`, `DragonBones/src/dragonBones/animation/AnimationState.ts`, `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/event/EventObject.ts`, `DragonBones/src/dragonBones/geom/Point.ts`, `Egret/Demos/src/BaseDemo.ts`, `Egret/Demos/src/demo/CoreElement.ts`, `Phaser/Demos/src/BaseDemo.ts`, `Phaser/Demos/src/CoreElement.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/Demos/4.x/src/BaseDemo.ts`, `Pixi/Demos/8.x/src/BaseDemo.ts`, `Pixi/Demos/8.x/src/CoreElement.ts`, `ThreeJS/Demos/src/BaseDemo.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `Game`

Herança: extends BaseDemo.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 16 |
| `_onStart` | método | `protected _onStart(): void` | 32 |
| `_touchHandler` | método | `private _touchHandler(event: PIXI.interaction.InteractionEvent): void` | 60 |
| `_keyHandler` | método | `private _keyHandler(event: KeyboardEvent): void` | 71 |
| `_enterFrameHandler` | método | `private _enterFrameHandler(deltaTime: number): void` | 118 |
| `_updateMove` | método | `private _updateMove(dir: number): void` | 132 |
| `addBullet` | método | `public addBullet(bullet: Bullet): void` | 147 |
| `GROUND` | propriedade | `public static GROUND: number;` | 7 |
| `G` | propriedade | `public static G: number = 0.6;` | 8 |
| `instance` | propriedade | `public static instance: Game;` | 9 |
| `_left` | propriedade | `private _left: boolean = false;` | 11 |
| `_right` | propriedade | `private _right: boolean = false;` | 12 |
| `_player` | propriedade | `private _player: Mecha;` | 13 |
| `_bullets` | propriedade | `private readonly _bullets: Array<Bullet> = [];` | 14 |

#### ClassDeclaration `Mecha`

Herança: nenhuma explícita.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 187 |
| `move` | método | `public move(dir: number): void` | 206 |
| `jump` | método | `public jump(): void` | 215 |
| `squat` | método | `public squat(isSquating: boolean): void` | 229 |
| `attack` | método | `public attack(isAttacking: boolean): void` | 238 |
| `switchWeaponL` | método | `public switchWeaponL(): void` | 246 |
| `switchWeaponR` | método | `public switchWeaponR(): void` | 257 |
| `switchSkin` | método | `public switchSkin(): void` | 268 |
| `aim` | método | `public aim(x: number, y: number): void` | 276 |
| `update` | método | `public update(): void` | 281 |
| `_animationEventHandler` | método | `private _animationEventHandler(event: EventType): void` | 287 |
| `_frameEventHandler` | método | `private _frameEventHandler(event: EventType): void` | 325 |
| `_fire` | método | `private _fire(firePoint: PointType): void` | 336 |
| `_updateAnimation` | método | `private _updateAnimation(): void` | 342 |
| `_updatePosition` | método | `private _updatePosition(): void` | 393 |
| `_updateAim` | método | `private _updateAim(): void` | 426 |
| `_updateAttack` | método | `private _updateAttack(): void` | 479 |
| `JUMP_SPEED` | propriedade | `private static readonly JUMP_SPEED: number = 20;` | 153 |
| `NORMALIZE_MOVE_SPEED` | propriedade | `private static readonly NORMALIZE_MOVE_SPEED: number = 3.6;` | 154 |
| `MAX_MOVE_SPEED_FRONT` | propriedade | `private static readonly MAX_MOVE_SPEED_FRONT: number = Mecha.NORMALIZE_MOVE_SPEED * 1.4;` | 155 |
| `MAX_MOVE_SPEED_BACK` | propriedade | `private static readonly MAX_MOVE_SPEED_BACK: number = Mecha.NORMALIZE_MOVE_SPEED * 1.0;` | 156 |
| `NORMAL_ANIMATION_GROUP` | propriedade | `private static readonly NORMAL_ANIMATION_GROUP: string = "normal";` | 157 |
| `AIM_ANIMATION_GROUP` | propriedade | `private static readonly AIM_ANIMATION_GROUP: string = "aim";` | 158 |
| `ATTACK_ANIMATION_GROUP` | propriedade | `private static readonly ATTACK_ANIMATION_GROUP: string = "attack";` | 159 |
| `WEAPON_L_LIST` | propriedade | `private static readonly WEAPON_L_LIST: Array<string> = ["weapon_1502b_l", "weapon_1005", "weapon_1005b", "weapon_1005c", "weapon_1005d", "weapon_1005e"];` | 160 |
| `WEAPON_R_LIST` | propriedade | `private static readonly WEAPON_R_LIST: Array<string> = ["weapon_1502b_r", "weapon_1005", "weapon_1005b", "weapon_1005c", "weapon_1005d"];` | 161 |
| `SKINS` | propriedade | `private static readonly SKINS: Array<string> = ["mecha_1502b", "skin_a", "skin_b", "skin_c"];` | 162 |
| `_isJumpingA` | propriedade | `private _isJumpingA: boolean = false;` | 164 |
| `_isSquating` | propriedade | `private _isSquating: boolean = false;` | 165 |
| `_isAttackingA` | propriedade | `private _isAttackingA: boolean = false;` | 166 |
| `_isAttackingB` | propriedade | `private _isAttackingB: boolean = false;` | 167 |
| `_weaponRIndex` | propriedade | `private _weaponRIndex: number = 0;` | 168 |
| `_weaponLIndex` | propriedade | `private _weaponLIndex: number = 0;` | 169 |
| `_skinIndex` | propriedade | `private _skinIndex: number = 0;` | 170 |
| `_faceDir` | propriedade | `private _faceDir: number = 1;` | 171 |
| `_aimDir` | propriedade | `private _aimDir: number = 0;` | 172 |
| `_moveDir` | propriedade | `private _moveDir: number = 0;` | 173 |
| `_aimRadian` | propriedade | `private _aimRadian: number = 0.0;` | 174 |
| `_speedX` | propriedade | `private _speedX: number = 0.0;` | 175 |
| `_speedY` | propriedade | `private _speedY: number = 0.0;` | 176 |
| `_armature` | propriedade | `private _armature: dragonBones.Armature;` | 177 |
| `_armatureDisplay` | propriedade | `private _armatureDisplay: ArmatureDisplayType;` | 178 |
| `_weaponL` | propriedade | `private _weaponL: dragonBones.Armature;` | 179 |
| `_weaponR` | propriedade | `private _weaponR: dragonBones.Armature;` | 180 |
| `_aimState` | propriedade | `private _aimState: dragonBones.AnimationState \| null = null;` | 181 |
| `_walkState` | propriedade | `private _walkState: dragonBones.AnimationState \| null = null;` | 182 |
| `_attackState` | propriedade | `private _attackState: dragonBones.AnimationState \| null = null;` | 183 |
| `_target` | propriedade | `private readonly _target: PointType = new PIXI.Point();` | 184 |
| `_helpPoint` | propriedade | `private readonly _helpPoint: PointType = new PIXI.Point();` | 185 |

#### ClassDeclaration `Bullet`

Herança: nenhuma explícita.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor(armatureName: string, effectArmatureName: string \| null, radian: number, speed: number, position: PointType)` | 502 |
| `update` | método | `public update(): boolean` | 531 |
| `_speedX` | propriedade | `private _speedX: number = 0.0;` | 496 |
| `_speedY` | propriedade | `private _speedY: number = 0.0;` | 497 |
| `_armatureDisplay` | propriedade | `private _armatureDisplay: ArmatureDisplayType;` | 499 |
| `_effecDisplay` | propriedade | `private _effecDisplay: ArmatureDisplayType \| null = null;` | 500 |

### `Pixi/Demos/4.x/src/DragHelper.ts`

- Origem/commit: `Pixi/Demos/4.x/src/DragHelper.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/Demos/assets/Script/DragHelper.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/geom/Point.ts`, `Egret/Demos/src/DragHelper.ts`, `Phaser/Demos/src/DragHelper.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/Demos/8.x/src/DragHelper.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `DragHelper`

Herança: nenhuma explícita.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `getInstance` | método | `public static getInstance(): DragHelper` | 3 |
| `enableDrag` | método | `public enableDrag(displayObject: PIXI.DisplayObject): void` | 13 |
| `disableDrag` | método | `public disableDrag(displayObject: PIXI.DisplayObject): void` | 21 |
| `_dragHandler` | método | `private _dragHandler(event: PIXI.interaction.InteractionEvent): void` | 28 |
| `_instance` | propriedade | `private static _instance: DragHelper = new DragHelper();` | 2 |
| `stage` | propriedade | `public stage: PIXI.DisplayObject;` | 7 |
| `_helpPoint` | propriedade | `private readonly _helpPoint: PIXI.Point = new PIXI.Point();` | 9 |
| `_dragOffset` | propriedade | `private readonly _dragOffset: PIXI.Point = new PIXI.Point();` | 10 |
| `_dragDisplayObject` | propriedade | `private _dragDisplayObject: PIXI.DisplayObject \| null = null;` | 11 |

### `Pixi/Demos/4.x/src/DragonBonesEvent.ts`

- Origem/commit: `Pixi/Demos/4.x/src/DragonBonesEvent.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/Demos/assets/Script/DragonBonesEvent.ts`, `DragonBones/src/dragonBones/event/EventObject.ts`, `Egret/Demos/src/BaseDemo.ts`, `Egret/Demos/src/demo/DragonBonesEvent.ts`, `Phaser/Demos/src/BaseDemo.ts`, `Phaser/Demos/src/DragonBonesEvent.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/Demos/4.x/src/BaseDemo.ts`, `Pixi/Demos/8.x/src/BaseDemo.ts`, `Pixi/Demos/8.x/src/DragonBonesEvent.ts`, `ThreeJS/Demos/src/BaseDemo.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `DragonBonesEvent`

Herança: extends BaseDemo.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 4 |
| `_onStart` | método | `protected _onStart(): void` | 14 |
| `_soundEventHandler` | método | `private _soundEventHandler(event: dragonBones.EventObject): void` | 38 |
| `_animationEventHandler` | método | `private _animationEventHandler(event: dragonBones.EventObject): void` | 42 |
| `_armatureDisplay` | propriedade | `private _armatureDisplay: dragonBones.PixiArmatureDisplay;` | 2 |

### `Pixi/Demos/4.x/src/EyeTracking.ts`

- Origem/commit: `Pixi/Demos/4.x/src/EyeTracking.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/Demos/assets/Script/EyeTracking.ts`, `DragonBones/src/dragonBones/geom/Point.ts`, `Egret/Demos/src/BaseDemo.ts`, `Egret/Demos/src/demo/EyeTracking.ts`, `Phaser/Demos/src/BaseDemo.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/Demos/4.x/src/BaseDemo.ts`, `Pixi/Demos/8.x/src/BaseDemo.ts`, `Pixi/Demos/8.x/src/EyeTracking.ts`, `ThreeJS/Demos/src/BaseDemo.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `EyeTracking`

Herança: extends BaseDemo.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 20 |
| `_onStart` | método | `protected _onStart(): void` | 32 |
| `_touchHandler` | método | `private _touchHandler(event: PIXI.interaction.InteractionEvent): void` | 60 |
| `_setTarget` | método | `private _setTarget(x: number, y: number)` | 64 |
| `_enterFrameHandler` | método | `protected _enterFrameHandler(deltaTime: number): void` | 69 |
| `_scale` | propriedade | `private _scale: number = 0.3;` | 2 |
| `_target` | propriedade | `private readonly _target: PIXI.Point = new PIXI.Point();` | 3 |
| `_animationNames` | propriedade | `private readonly _animationNames: string[] = [ "PARAM_ANGLE_X", "PARAM_ANGLE_Y", "PARAM_ANGLE_Z", "PARAM_EYE_BALL_X", "PARAM_EYE_BALL_Y", "PARAM_BODY_X", "PARAM_BODY_Y", "PARAM_BODY_Z", "PARAM_BODY_ANGLE_X", "PARAM_BODY_ANGLE_Y", "PARAM_BODY_ANGLE_Z", "PARAM_BREATH", ];` | 4 |
| `_armatureDisplay` | propriedade | `private _armatureDisplay: dragonBones.PixiArmatureDisplay;` | 18 |

### `Pixi/Demos/4.x/src/HelloDragonBones.ts`

- Origem/commit: `Pixi/Demos/4.x/src/HelloDragonBones.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/Demos/assets/Script/HelloDragonBones.ts`, `Egret/Demos/src/BaseDemo.ts`, `Egret/Demos/src/demo/HelloDragonBones.ts`, `Hilo/Demos/src/HelloDragonBones.ts`, `Phaser/Demos/src/BaseDemo.ts`, `Phaser/Demos/src/HelloDragonBones.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/Demos/4.x/src/BaseDemo.ts`, `Pixi/Demos/8.x/src/BaseDemo.ts`, `Pixi/Demos/8.x/src/HelloDragonBones.ts`, `ThreeJS/Demos/src/BaseDemo.ts`, `ThreeJS/Demos/src/HelloDragonBones.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `HelloDragonBones`

Herança: extends BaseDemo.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 19 |
| `_onStart` | método | `protected _onStart(): void` | 30 |

### `Pixi/Demos/4.x/src/InverseKinematics.ts`

- Origem/commit: `Pixi/Demos/4.x/src/InverseKinematics.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/Demos/assets/Script/DragHelper.ts`, `Cocos/Demos/assets/Script/InverseKinematics.ts`, `DragonBones/src/dragonBones/animation/AnimationState.ts`, `DragonBones/src/dragonBones/armature/Bone.ts`, `DragonBones/src/dragonBones/geom/Point.ts`, `DragonBones/src/dragonBones/geom/Transform.ts`, `Egret/Demos/src/BaseDemo.ts`, `Egret/Demos/src/DragHelper.ts`, `Egret/Demos/src/demo/InverseKinematics.ts`, `Phaser/Demos/src/BaseDemo.ts`, `Phaser/Demos/src/DragHelper.ts`, `Phaser/Demos/src/InverseKinematics.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/Demos/4.x/src/BaseDemo.ts`, `Pixi/Demos/4.x/src/DragHelper.ts`, `Pixi/Demos/8.x/src/BaseDemo.ts`, `Pixi/Demos/8.x/src/DragHelper.ts`, `Pixi/Demos/8.x/src/InverseKinematics.ts`, `ThreeJS/Demos/src/BaseDemo.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `InverseKinematics`

Herança: extends BaseDemo.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 15 |
| `_onStart` | método | `protected _onStart(): void` | 28 |
| `_enterFrameHandler` | método | `private _enterFrameHandler(deltaTime: number): void` | 71 |
| `_updateAim` | método | `private _updateAim(): void` | 76 |
| `_updateFoot` | método | `private _updateFoot(): void` | 100 |
| `_faceDir` | propriedade | `private _faceDir: number = 0;` | 2 |
| `_aimRadian` | propriedade | `private _aimRadian: number = 0.0;` | 3 |
| `_offsetRotation` | propriedade | `private _offsetRotation: number = 0.0;` | 4 |
| `_target` | propriedade | `private readonly _target: PIXI.Point = new PIXI.Point();` | 5 |
| `_armatureDisplay` | propriedade | `private _armatureDisplay: dragonBones.PixiArmatureDisplay;` | 6 |
| `_floorBoard` | propriedade | `private _floorBoard: dragonBones.PixiArmatureDisplay;` | 7 |
| `_chestBone` | propriedade | `private _chestBone: dragonBones.Bone;` | 8 |
| `_leftFootBone` | propriedade | `private _leftFootBone: dragonBones.Bone;` | 9 |
| `_rightFootBone` | propriedade | `private _rightFootBone: dragonBones.Bone;` | 10 |
| `_circleBone` | propriedade | `private _circleBone: dragonBones.Bone;` | 11 |
| `_floorBoardBone` | propriedade | `private _floorBoardBone: dragonBones.Bone;` | 12 |
| `_aimState` | propriedade | `private _aimState: dragonBones.AnimationState;` | 13 |

### `Pixi/Demos/4.x/src/MultiTextureAltas.ts`

- Origem/commit: `Pixi/Demos/4.x/src/MultiTextureAltas.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/Demos/assets/Script/MultiTextureAltas.ts`, `Egret/Demos/src/BaseDemo.ts`, `Egret/Demos/src/demo/MultiTextureAltas.ts`, `Phaser/Demos/src/BaseDemo.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/Demos/4.x/src/BaseDemo.ts`, `Pixi/Demos/8.x/src/BaseDemo.ts`, `Pixi/Demos/8.x/src/MultiTextureAltas.ts`, `ThreeJS/Demos/src/BaseDemo.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `MultiTextureAltas`

Herança: extends BaseDemo.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 7 |
| `_onStart` | método | `protected _onStart(): void` | 19 |
| `_changeAnimation` | método | `private _changeAnimation(): void` | 55 |
| `_armatureDisplayA` | propriedade | `private _armatureDisplayA: dragonBones.PixiArmatureDisplay;` | 2 |
| `_armatureDisplayB` | propriedade | `private _armatureDisplayB: dragonBones.PixiArmatureDisplay;` | 3 |
| `_armatureDisplayC` | propriedade | `private _armatureDisplayC: dragonBones.PixiArmatureDisplay;` | 4 |
| `_armatureDisplayD` | propriedade | `private _armatureDisplayD: dragonBones.PixiArmatureDisplay;` | 5 |

### `Pixi/Demos/4.x/src/PerformanceTest.ts`

- Origem/commit: `Pixi/Demos/4.x/src/PerformanceTest.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/Demos/assets/Script/PerformanceTest.ts`, `DragonBones/src/dragonBones/core/BaseObject.ts`, `Egret/Demos/src/BaseDemo.ts`, `Egret/Demos/src/demo/PerformanceTest.ts`, `Hilo/Demos/src/PerformanceTest.ts`, `Phaser/Demos/src/BaseDemo.ts`, `Phaser/Demos/src/PerformanceTest.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/Demos/4.x/src/BaseDemo.ts`, `Pixi/Demos/8.x/src/BaseDemo.ts`, `Pixi/Demos/8.x/src/PerformanceTest.ts`, `ThreeJS/Demos/src/BaseDemo.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `PerformanceTest`

Herança: extends BaseDemo.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 7 |
| `_onStart` | método | `protected _onStart(): void` | 17 |
| `_enterFrameHandler` | método | `private _enterFrameHandler(deltaTime: number): void` | 35 |
| `_touchHandler` | método | `private _touchHandler(event: PIXI.interaction.InteractionEvent): void` | 55 |
| `_addArmature` | método | `private _addArmature(): void` | 72 |
| `_removeArmature` | método | `private _removeArmature(): void` | 88 |
| `_resetPosition` | método | `private _resetPosition(): void` | 103 |
| `_updateText` | método | `private _updateText(): void` | 127 |
| `_addingArmature` | propriedade | `private _addingArmature: boolean = false;` | 2 |
| `_removingArmature` | propriedade | `private _removingArmature: boolean = false;` | 3 |
| `_armatures` | propriedade | `private readonly _armatures: Array<dragonBones.PixiArmatureDisplay> = [];` | 4 |
| `_text` | propriedade | `private _text: PIXI.Text;` | 5 |

### `Pixi/Demos/4.x/src/ReplaceAnimation.ts`

- Origem/commit: `Pixi/Demos/4.x/src/ReplaceAnimation.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Egret/Demos/src/BaseDemo.ts`, `Egret/Demos/src/demo/ReplaceAnimation.ts`, `Hilo/Demos/src/ReplaceAnimation.ts`, `Phaser/Demos/src/BaseDemo.ts`, `Phaser/Demos/src/ReplaceAnimation.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/Demos/4.x/src/BaseDemo.ts`, `Pixi/Demos/8.x/src/BaseDemo.ts`, `Pixi/Demos/8.x/src/ReplaceAnimation.ts`, `ThreeJS/Demos/src/BaseDemo.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `ReplaceAnimation`

Herança: extends BaseDemo.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 7 |
| `_onStart` | método | `protected _onStart(): void` | 17 |
| `_changeAnimation` | método | `private _changeAnimation(): void` | 56 |
| `_armatureDisplayA` | propriedade | `private _armatureDisplayA: dragonBones.PixiArmatureDisplay;` | 2 |
| `_armatureDisplayB` | propriedade | `private _armatureDisplayB: dragonBones.PixiArmatureDisplay;` | 3 |
| `_armatureDisplayC` | propriedade | `private _armatureDisplayC: dragonBones.PixiArmatureDisplay;` | 4 |
| `_armatureDisplayD` | propriedade | `private _armatureDisplayD: dragonBones.PixiArmatureDisplay;` | 5 |

### `Pixi/Demos/4.x/src/ReplaceSkin.ts`

- Origem/commit: `Pixi/Demos/4.x/src/ReplaceSkin.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/Demos/assets/Script/ReplaceSkin.ts`, `DragonBones/src/dragonBones/event/EventObject.ts`, `Egret/Demos/src/BaseDemo.ts`, `Egret/Demos/src/demo/ReplaceSkin.ts`, `Phaser/Demos/src/BaseDemo.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/Demos/4.x/src/BaseDemo.ts`, `Pixi/Demos/8.x/src/BaseDemo.ts`, `Pixi/Demos/8.x/src/ReplaceSkin.ts`, `ThreeJS/Demos/src/BaseDemo.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `ReplaceSkin`

Herança: extends BaseDemo.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 8 |
| `_onStart` | método | `protected _onStart(): void` | 69 |
| `_animationEventHandler` | método | `private _animationEventHandler(event: dragonBones.EventObject): void` | 109 |
| `_randomReplaceSkin` | método | `private _randomReplaceSkin(): void` | 117 |
| `_replaceSuitIndex` | propriedade | `private _replaceSuitIndex: number = 0;` | 2 |
| `_factory` | propriedade | `private readonly _factory: dragonBones.PixiFactory = dragonBones.PixiFactory.factory;` | 3 |
| `_suitConfigs` | propriedade | `private readonly _suitConfigs: string[][] = [];` | 4 |
| `_replaceSuitParts` | propriedade | `private readonly _replaceSuitParts: string[] = [];` | 5 |
| `_armatureDisplay` | propriedade | `private _armatureDisplay: dragonBones.PixiArmatureDisplay;` | 6 |

### `Pixi/Demos/4.x/src/ReplaceSlotDisplay.ts`

- Origem/commit: `Pixi/Demos/4.x/src/ReplaceSlotDisplay.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/Demos/assets/Script/ReplaceAnimation.ts`, `Cocos/Demos/assets/Script/ReplaceSlotDisplay.ts`, `Egret/Demos/src/BaseDemo.ts`, `Egret/Demos/src/demo/ReplaceSlotDisplay.ts`, `Hilo/Demos/src/ReplaceSlotDisplay.ts`, `Phaser/Demos/src/BaseDemo.ts`, `Phaser/Demos/src/ReplaceSlotDisplay.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/Demos/4.x/src/BaseDemo.ts`, `Pixi/Demos/8.x/src/BaseDemo.ts`, `Pixi/Demos/8.x/src/ReplaceSlotDisplay.ts`, `ThreeJS/Demos/src/BaseDemo.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `ReplaceSlotDisplay`

Herança: extends BaseDemo.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 10 |
| `_onStart` | método | `protected _onStart(): void` | 23 |
| `_replaceDisplay` | método | `private _replaceDisplay(type: number): void` | 55 |
| `WEAPON_RIGHT_LIST` | propriedade | `private static readonly WEAPON_RIGHT_LIST: string[] = ["weapon_1004_r", "weapon_1004b_r", "weapon_1004c_r", "weapon_1004d_r", "weapon_1004e_r"];` | 2 |
| `_leftWeaponIndex` | propriedade | `private _leftWeaponIndex: number = 0;` | 4 |
| `_rightWeaponIndex` | propriedade | `private _rightWeaponIndex: number = 0;` | 5 |
| `_factory` | propriedade | `private readonly _factory: dragonBones.PixiFactory = dragonBones.PixiFactory.factory;` | 6 |
| `_armatureDisplay` | propriedade | `private _armatureDisplay: dragonBones.PixiArmatureDisplay;` | 7 |
| `_logoText` | propriedade | `private _logoText: PIXI.Text;` | 8 |

### `Pixi/Demos/8.x/src/AnimationBase.ts`

- Origem/commit: `Pixi/Demos/8.x/src/AnimationBase.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/Demos/assets/Script/AnimationBase.ts`, `DragonBones/src/dragonBones/event/EventObject.ts`, `Egret/Demos/src/BaseDemo.ts`, `Egret/Demos/src/demo/AnimationBase.ts`, `Phaser/Demos/src/AnimationBase.ts`, `Phaser/Demos/src/BaseDemo.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/Demos/4.x/src/AnimationBase.ts`, `Pixi/Demos/4.x/src/BaseDemo.ts`, `Pixi/Demos/8.x/src/BaseDemo.ts`, `ThreeJS/Demos/src/BaseDemo.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `AnimationBase`

Herança: extends BaseDemo.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 4 |
| `_onStart` | método | `protected _onStart(): void` | 14 |
| `_touchHandler` | método | `private _touchHandler(event: PIXI.FederatedPointerEvent): void` | 46 |
| `_animationEventHandler` | método | `private _animationEventHandler(event: dragonBones.EventObject): void` | 76 |
| `_armatureDisplay` | propriedade | `private _armatureDisplay: dragonBones.PixiArmatureDisplay;` | 2 |
| `_isTouched` | propriedade | `private _isTouched: boolean = false;` | 45 |

### `Pixi/Demos/8.x/src/AnimationLayer.ts`

- Origem/commit: `Pixi/Demos/8.x/src/AnimationLayer.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/Demos/assets/Script/AnimationLayer.ts`, `DragonBones/src/dragonBones/event/EventObject.ts`, `Egret/Demos/src/BaseDemo.ts`, `Egret/Demos/src/demo/AnimationLayer.ts`, `Phaser/Demos/src/AnimationLayer.ts`, `Phaser/Demos/src/BaseDemo.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/Demos/4.x/src/AnimationLayer.ts`, `Pixi/Demos/4.x/src/BaseDemo.ts`, `Pixi/Demos/8.x/src/BaseDemo.ts`, `ThreeJS/Demos/src/BaseDemo.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `AnimationLayer`

Herança: extends BaseDemo.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 4 |
| `_onStart` | método | `protected _onStart(): void` | 14 |
| `_animationEventHandler` | método | `private _animationEventHandler(event: dragonBones.EventObject): void` | 28 |
| `_armatureDisplay` | propriedade | `private _armatureDisplay: dragonBones.PixiArmatureDisplay;` | 2 |

### `Pixi/Demos/8.x/src/BaseDemo.ts`

- Origem/commit: `Pixi/Demos/8.x/src/BaseDemo.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/core/DragonBones.ts`, `Egret/Demos/src/BaseDemo.ts`, `Phaser/Demos/src/BaseDemo.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/Demos/4.x/src/BaseDemo.ts`, `ThreeJS/Demos/src/BaseDemo.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `BaseDemo`

Herança: nenhuma explícita.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 11 |
| `init` | método | `public async init()` | 17 |
| `_onStart` | método | `protected abstract _onStart(): void;` | 30 |
| `_loadResources` | método | `protected _loadResources(): void` | 32 |
| `addChild` | método | `public addChild(child: PIXI.Container): PIXI.Container` | 55 |
| `removeChild` | método | `public removeChild(child: PIXI.Container): PIXI.Container` | 58 |
| `createText` | método | `public createText(string: string): PIXI.Text` | 62 |
| `stageWidth` | método | `public get stageWidth(): number` | 74 |
| `stageHeight` | método | `public get stageHeight(): number` | 78 |
| `addListener` | método | `public addListener(event: string, handler: (...args: any)=> void, thisObj: any): void` | 81 |
| `interactive` | método | `public set interactive(value: boolean)` | 84 |
| `x` | método | `public get x()` | 87 |
| `y` | método | `public get y()` | 90 |
| `BACKGROUND_URL` | propriedade | `private static BACKGROUND_URL: string = "resource/background.png";` | 3 |
| `_background` | propriedade | `protected readonly _background: PIXI.Sprite = new PIXI.Sprite(PIXI.Texture.EMPTY);` | 5 |
| `_resources` | propriedade | `protected readonly _resources: string[] = [];` | 6 |
| `_pixiResources` | propriedade | `protected _pixiResources: dragonBones.Map<PIXI.loaders.Resource>;` | 7 |
| `armatureContainer` | propriedade | `protected armatureContainer: PIXI.Container = new PIXI.Container();` | 8 |
| `app` | propriedade | `public app: PIXI.Application;` | 10 |

### `Pixi/Demos/8.x/src/BoneOffset.ts`

- Origem/commit: `Pixi/Demos/8.x/src/BoneOffset.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/Demos/assets/Script/BoneOffset.ts`, `DragonBones/src/dragonBones/event/EventObject.ts`, `Egret/Demos/src/BaseDemo.ts`, `Egret/Demos/src/demo/BoneOffset.ts`, `Phaser/Demos/src/BaseDemo.ts`, `Phaser/Demos/src/BoneOffset.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/Demos/4.x/src/BaseDemo.ts`, `Pixi/Demos/4.x/src/BoneOffset.ts`, `Pixi/Demos/8.x/src/BaseDemo.ts`, `ThreeJS/Demos/src/BaseDemo.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `BoneOffset`

Herança: extends BaseDemo.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 2 |
| `_onStart` | método | `protected _onStart(): void` | 12 |
| `_animationHandler` | método | `private _animationHandler(event: dragonBones.EventObject): void` | 28 |
| `_moveTo` | método | `private _moveTo(armatureDisplay: dragonBones.PixiArmatureDisplay): void` | 32 |

### `Pixi/Demos/8.x/src/BoundingBox.ts`

- Origem/commit: `Pixi/Demos/8.x/src/BoundingBox.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/Demos/assets/Script/BoundingBox.ts`, `Cocos/Demos/assets/Script/DragHelper.ts`, `DragonBones/src/dragonBones/armature/Bone.ts`, `DragonBones/src/dragonBones/geom/Point.ts`, `Egret/Demos/src/BaseDemo.ts`, `Egret/Demos/src/DragHelper.ts`, `Egret/Demos/src/demo/BoundingBox.ts`, `Phaser/Demos/src/BaseDemo.ts`, `Phaser/Demos/src/BoundingBox.ts`, `Phaser/Demos/src/DragHelper.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/Demos/4.x/src/BaseDemo.ts`, `Pixi/Demos/4.x/src/BoundingBox.ts`, `Pixi/Demos/4.x/src/DragHelper.ts`, `Pixi/Demos/8.x/src/BaseDemo.ts`, `Pixi/Demos/8.x/src/DragHelper.ts`, `ThreeJS/Demos/src/BaseDemo.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `BoundingBox`

Herança: extends BaseDemo.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 14 |
| `_onStart` | método | `protected _onStart(): void` | 27 |
| `_enterFrameHandler` | método | `private _enterFrameHandler(deltaTime: number): void` | 69 |
| `_helpPointA` | propriedade | `private readonly _helpPointA: PIXI.Point = new PIXI.Point();` | 2 |
| `_helpPointB` | propriedade | `private readonly _helpPointB: PIXI.Point = new PIXI.Point();` | 3 |
| `_helpPointC` | propriedade | `private readonly _helpPointC: PIXI.Point = new PIXI.Point();` | 4 |
| `_armatureDisplay` | propriedade | `private _armatureDisplay: dragonBones.PixiArmatureDisplay;` | 6 |
| `_boundingBoxTester` | propriedade | `private _boundingBoxTester: dragonBones.PixiArmatureDisplay;` | 7 |
| `_targetA` | propriedade | `private _targetA: dragonBones.PixiArmatureDisplay;` | 8 |
| `_targetB` | propriedade | `private _targetB: dragonBones.PixiArmatureDisplay;` | 9 |
| `_line` | propriedade | `private _line: dragonBones.Bone;` | 10 |
| `_pointA` | propriedade | `private _pointA: dragonBones.Bone;` | 11 |
| `_pointB` | propriedade | `private _pointB: dragonBones.Bone;` | 12 |

### `Pixi/Demos/8.x/src/CoreElement.ts`

- Origem/commit: `Pixi/Demos/8.x/src/CoreElement.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/Demos/assets/Script/CoreElement.ts`, `DragonBones/src/dragonBones/animation/AnimationState.ts`, `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/event/EventObject.ts`, `DragonBones/src/dragonBones/geom/Point.ts`, `Egret/Demos/src/BaseDemo.ts`, `Egret/Demos/src/demo/CoreElement.ts`, `Phaser/Demos/src/BaseDemo.ts`, `Phaser/Demos/src/CoreElement.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/Demos/4.x/src/BaseDemo.ts`, `Pixi/Demos/4.x/src/CoreElement.ts`, `Pixi/Demos/8.x/src/BaseDemo.ts`, `ThreeJS/Demos/src/BaseDemo.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `Game`

Herança: extends BaseDemo.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 16 |
| `_onStart` | método | `protected _onStart(): void` | 32 |
| `_touchHandler` | método | `private _touchHandler(event: PIXI.interaction.InteractionEvent): void` | 60 |
| `_keyHandler` | método | `private _keyHandler(event: KeyboardEvent): void` | 71 |
| `_enterFrameHandler` | método | `private _enterFrameHandler(deltaTime: number): void` | 118 |
| `_updateMove` | método | `private _updateMove(dir: number): void` | 132 |
| `addBullet` | método | `public addBullet(bullet: Bullet): void` | 147 |
| `GROUND` | propriedade | `public static GROUND: number;` | 7 |
| `G` | propriedade | `public static G: number = 0.6;` | 8 |
| `instance` | propriedade | `public static instance: Game;` | 9 |
| `_left` | propriedade | `private _left: boolean = false;` | 11 |
| `_right` | propriedade | `private _right: boolean = false;` | 12 |
| `_player` | propriedade | `private _player: Mecha;` | 13 |
| `_bullets` | propriedade | `private readonly _bullets: Array<Bullet> = [];` | 14 |

#### ClassDeclaration `Mecha`

Herança: nenhuma explícita.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 187 |
| `move` | método | `public move(dir: number): void` | 206 |
| `jump` | método | `public jump(): void` | 215 |
| `squat` | método | `public squat(isSquating: boolean): void` | 229 |
| `attack` | método | `public attack(isAttacking: boolean): void` | 238 |
| `switchWeaponL` | método | `public switchWeaponL(): void` | 246 |
| `switchWeaponR` | método | `public switchWeaponR(): void` | 257 |
| `switchSkin` | método | `public switchSkin(): void` | 268 |
| `aim` | método | `public aim(x: number, y: number): void` | 276 |
| `update` | método | `public update(): void` | 281 |
| `_animationEventHandler` | método | `private _animationEventHandler(event: EventType): void` | 287 |
| `_frameEventHandler` | método | `private _frameEventHandler(event: EventType): void` | 325 |
| `_fire` | método | `private _fire(firePoint: PointType): void` | 336 |
| `_updateAnimation` | método | `private _updateAnimation(): void` | 342 |
| `_updatePosition` | método | `private _updatePosition(): void` | 393 |
| `_updateAim` | método | `private _updateAim(): void` | 426 |
| `_updateAttack` | método | `private _updateAttack(): void` | 479 |
| `JUMP_SPEED` | propriedade | `private static readonly JUMP_SPEED: number = 20;` | 153 |
| `NORMALIZE_MOVE_SPEED` | propriedade | `private static readonly NORMALIZE_MOVE_SPEED: number = 3.6;` | 154 |
| `MAX_MOVE_SPEED_FRONT` | propriedade | `private static readonly MAX_MOVE_SPEED_FRONT: number = Mecha.NORMALIZE_MOVE_SPEED * 1.4;` | 155 |
| `MAX_MOVE_SPEED_BACK` | propriedade | `private static readonly MAX_MOVE_SPEED_BACK: number = Mecha.NORMALIZE_MOVE_SPEED * 1.0;` | 156 |
| `NORMAL_ANIMATION_GROUP` | propriedade | `private static readonly NORMAL_ANIMATION_GROUP: string = "normal";` | 157 |
| `AIM_ANIMATION_GROUP` | propriedade | `private static readonly AIM_ANIMATION_GROUP: string = "aim";` | 158 |
| `ATTACK_ANIMATION_GROUP` | propriedade | `private static readonly ATTACK_ANIMATION_GROUP: string = "attack";` | 159 |
| `WEAPON_L_LIST` | propriedade | `private static readonly WEAPON_L_LIST: Array<string> = ["weapon_1502b_l", "weapon_1005", "weapon_1005b", "weapon_1005c", "weapon_1005d", "weapon_1005e"];` | 160 |
| `WEAPON_R_LIST` | propriedade | `private static readonly WEAPON_R_LIST: Array<string> = ["weapon_1502b_r", "weapon_1005", "weapon_1005b", "weapon_1005c", "weapon_1005d"];` | 161 |
| `SKINS` | propriedade | `private static readonly SKINS: Array<string> = ["mecha_1502b", "skin_a", "skin_b", "skin_c"];` | 162 |
| `_isJumpingA` | propriedade | `private _isJumpingA: boolean = false;` | 164 |
| `_isSquating` | propriedade | `private _isSquating: boolean = false;` | 165 |
| `_isAttackingA` | propriedade | `private _isAttackingA: boolean = false;` | 166 |
| `_isAttackingB` | propriedade | `private _isAttackingB: boolean = false;` | 167 |
| `_weaponRIndex` | propriedade | `private _weaponRIndex: number = 0;` | 168 |
| `_weaponLIndex` | propriedade | `private _weaponLIndex: number = 0;` | 169 |
| `_skinIndex` | propriedade | `private _skinIndex: number = 0;` | 170 |
| `_faceDir` | propriedade | `private _faceDir: number = 1;` | 171 |
| `_aimDir` | propriedade | `private _aimDir: number = 0;` | 172 |
| `_moveDir` | propriedade | `private _moveDir: number = 0;` | 173 |
| `_aimRadian` | propriedade | `private _aimRadian: number = 0.0;` | 174 |
| `_speedX` | propriedade | `private _speedX: number = 0.0;` | 175 |
| `_speedY` | propriedade | `private _speedY: number = 0.0;` | 176 |
| `_armature` | propriedade | `private _armature: dragonBones.Armature;` | 177 |
| `_armatureDisplay` | propriedade | `private _armatureDisplay: ArmatureDisplayType;` | 178 |
| `_weaponL` | propriedade | `private _weaponL: dragonBones.Armature;` | 179 |
| `_weaponR` | propriedade | `private _weaponR: dragonBones.Armature;` | 180 |
| `_aimState` | propriedade | `private _aimState: dragonBones.AnimationState \| null = null;` | 181 |
| `_walkState` | propriedade | `private _walkState: dragonBones.AnimationState \| null = null;` | 182 |
| `_attackState` | propriedade | `private _attackState: dragonBones.AnimationState \| null = null;` | 183 |
| `_target` | propriedade | `private readonly _target: PointType = new PIXI.Point();` | 184 |
| `_helpPoint` | propriedade | `private readonly _helpPoint: PointType = new PIXI.Point();` | 185 |

#### ClassDeclaration `Bullet`

Herança: nenhuma explícita.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor(armatureName: string, effectArmatureName: string \| null, radian: number, speed: number, position: PointType)` | 502 |
| `update` | método | `public update(): boolean` | 531 |
| `_speedX` | propriedade | `private _speedX: number = 0.0;` | 496 |
| `_speedY` | propriedade | `private _speedY: number = 0.0;` | 497 |
| `_armatureDisplay` | propriedade | `private _armatureDisplay: ArmatureDisplayType;` | 499 |
| `_effecDisplay` | propriedade | `private _effecDisplay: ArmatureDisplayType \| null = null;` | 500 |

### `Pixi/Demos/8.x/src/DebugDragonBones.ts`

- Origem/commit: `Pixi/Demos/8.x/src/DebugDragonBones.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Egret/Demos/src/BaseDemo.ts`, `Phaser/Demos/src/BaseDemo.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/Demos/4.x/src/BaseDemo.ts`, `Pixi/Demos/8.x/src/BaseDemo.ts`, `ThreeJS/Demos/src/BaseDemo.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `DebugDragonBones`

Herança: extends BaseDemo.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 19 |
| `_onStart` | método | `protected _onStart(): void` | 27 |

### `Pixi/Demos/8.x/src/DragHelper.ts`

- Origem/commit: `Pixi/Demos/8.x/src/DragHelper.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/Demos/assets/Script/DragHelper.ts`, `DragonBones/src/dragonBones/geom/Point.ts`, `Egret/Demos/src/DragHelper.ts`, `Phaser/Demos/src/DragHelper.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/Demos/4.x/src/DragHelper.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `DragHelper`

Herança: nenhuma explícita.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `getInstance` | método | `public static getInstance(): DragHelper` | 3 |
| `enableDrag` | método | `public enableDrag(displayObject: PIXI.DisplayObject): void` | 13 |
| `disableDrag` | método | `public disableDrag(displayObject: PIXI.DisplayObject): void` | 21 |
| `_dragHandler` | método | `private _dragHandler(event: PIXI.interaction.InteractionEvent): void` | 28 |
| `_instance` | propriedade | `private static _instance: DragHelper = new DragHelper();` | 2 |
| `stage` | propriedade | `public stage: PIXI.DisplayObject;` | 7 |
| `_helpPoint` | propriedade | `private readonly _helpPoint: PIXI.Point = new PIXI.Point();` | 9 |
| `_dragOffset` | propriedade | `private readonly _dragOffset: PIXI.Point = new PIXI.Point();` | 10 |
| `_dragDisplayObject` | propriedade | `private _dragDisplayObject: PIXI.DisplayObject \| null = null;` | 11 |

### `Pixi/Demos/8.x/src/DragonBonesEvent.ts`

- Origem/commit: `Pixi/Demos/8.x/src/DragonBonesEvent.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/Demos/assets/Script/DragonBonesEvent.ts`, `DragonBones/src/dragonBones/event/EventObject.ts`, `Egret/Demos/src/BaseDemo.ts`, `Egret/Demos/src/demo/DragonBonesEvent.ts`, `Phaser/Demos/src/BaseDemo.ts`, `Phaser/Demos/src/DragonBonesEvent.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/Demos/4.x/src/BaseDemo.ts`, `Pixi/Demos/4.x/src/DragonBonesEvent.ts`, `Pixi/Demos/8.x/src/BaseDemo.ts`, `ThreeJS/Demos/src/BaseDemo.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `DragonBonesEvent`

Herança: extends BaseDemo.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 4 |
| `_onStart` | método | `protected _onStart(): void` | 14 |
| `_soundEventHandler` | método | `private _soundEventHandler(event: dragonBones.EventObject): void` | 38 |
| `_animationEventHandler` | método | `private _animationEventHandler(event: dragonBones.EventObject): void` | 42 |
| `_armatureDisplay` | propriedade | `private _armatureDisplay: dragonBones.PixiArmatureDisplay;` | 2 |

### `Pixi/Demos/8.x/src/EyeTracking.ts`

- Origem/commit: `Pixi/Demos/8.x/src/EyeTracking.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/Demos/assets/Script/EyeTracking.ts`, `DragonBones/src/dragonBones/geom/Point.ts`, `Egret/Demos/src/BaseDemo.ts`, `Egret/Demos/src/demo/EyeTracking.ts`, `Phaser/Demos/src/BaseDemo.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/Demos/4.x/src/BaseDemo.ts`, `Pixi/Demos/4.x/src/EyeTracking.ts`, `Pixi/Demos/8.x/src/BaseDemo.ts`, `ThreeJS/Demos/src/BaseDemo.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `EyeTracking`

Herança: extends BaseDemo.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 20 |
| `_onStart` | método | `protected _onStart(): void` | 32 |
| `_touchHandler` | método | `private _touchHandler(event: PIXI.interaction.InteractionEvent): void` | 60 |
| `_setTarget` | método | `private _setTarget(x: number, y: number)` | 64 |
| `_enterFrameHandler` | método | `protected _enterFrameHandler(deltaTime: number): void` | 69 |
| `_scale` | propriedade | `private _scale: number = 0.3;` | 2 |
| `_target` | propriedade | `private readonly _target: PIXI.Point = new PIXI.Point();` | 3 |
| `_animationNames` | propriedade | `private readonly _animationNames: string[] = [ "PARAM_ANGLE_X", "PARAM_ANGLE_Y", "PARAM_ANGLE_Z", "PARAM_EYE_BALL_X", "PARAM_EYE_BALL_Y", "PARAM_BODY_X", "PARAM_BODY_Y", "PARAM_BODY_Z", "PARAM_BODY_ANGLE_X", "PARAM_BODY_ANGLE_Y", "PARAM_BODY_ANGLE_Z", "PARAM_BREATH", ];` | 4 |
| `_armatureDisplay` | propriedade | `private _armatureDisplay: dragonBones.PixiArmatureDisplay;` | 18 |

### `Pixi/Demos/8.x/src/HelloDragonBones.ts`

- Origem/commit: `Pixi/Demos/8.x/src/HelloDragonBones.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/Demos/assets/Script/HelloDragonBones.ts`, `Egret/Demos/src/BaseDemo.ts`, `Egret/Demos/src/demo/HelloDragonBones.ts`, `Hilo/Demos/src/HelloDragonBones.ts`, `Phaser/Demos/src/BaseDemo.ts`, `Phaser/Demos/src/HelloDragonBones.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/Demos/4.x/src/BaseDemo.ts`, `Pixi/Demos/4.x/src/HelloDragonBones.ts`, `Pixi/Demos/8.x/src/BaseDemo.ts`, `ThreeJS/Demos/src/BaseDemo.ts`, `ThreeJS/Demos/src/HelloDragonBones.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `HelloDragonBones`

Herança: extends BaseDemo.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 19 |
| `_onStart` | método | `protected _onStart(): void` | 37 |

### `Pixi/Demos/8.x/src/InverseKinematics.ts`

- Origem/commit: `Pixi/Demos/8.x/src/InverseKinematics.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/Demos/assets/Script/DragHelper.ts`, `Cocos/Demos/assets/Script/InverseKinematics.ts`, `DragonBones/src/dragonBones/animation/AnimationState.ts`, `DragonBones/src/dragonBones/armature/Bone.ts`, `DragonBones/src/dragonBones/geom/Point.ts`, `DragonBones/src/dragonBones/geom/Transform.ts`, `Egret/Demos/src/BaseDemo.ts`, `Egret/Demos/src/DragHelper.ts`, `Egret/Demos/src/demo/InverseKinematics.ts`, `Phaser/Demos/src/BaseDemo.ts`, `Phaser/Demos/src/DragHelper.ts`, `Phaser/Demos/src/InverseKinematics.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/Demos/4.x/src/BaseDemo.ts`, `Pixi/Demos/4.x/src/DragHelper.ts`, `Pixi/Demos/4.x/src/InverseKinematics.ts`, `Pixi/Demos/8.x/src/BaseDemo.ts`, `Pixi/Demos/8.x/src/DragHelper.ts`, `ThreeJS/Demos/src/BaseDemo.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `InverseKinematics`

Herança: extends BaseDemo.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 15 |
| `_onStart` | método | `protected _onStart(): void` | 28 |
| `_enterFrameHandler` | método | `private _enterFrameHandler(deltaTime: number): void` | 71 |
| `_updateAim` | método | `private _updateAim(): void` | 76 |
| `_updateFoot` | método | `private _updateFoot(): void` | 100 |
| `_faceDir` | propriedade | `private _faceDir: number = 0;` | 2 |
| `_aimRadian` | propriedade | `private _aimRadian: number = 0.0;` | 3 |
| `_offsetRotation` | propriedade | `private _offsetRotation: number = 0.0;` | 4 |
| `_target` | propriedade | `private readonly _target: PIXI.Point = new PIXI.Point();` | 5 |
| `_armatureDisplay` | propriedade | `private _armatureDisplay: dragonBones.PixiArmatureDisplay;` | 6 |
| `_floorBoard` | propriedade | `private _floorBoard: dragonBones.PixiArmatureDisplay;` | 7 |
| `_chestBone` | propriedade | `private _chestBone: dragonBones.Bone;` | 8 |
| `_leftFootBone` | propriedade | `private _leftFootBone: dragonBones.Bone;` | 9 |
| `_rightFootBone` | propriedade | `private _rightFootBone: dragonBones.Bone;` | 10 |
| `_circleBone` | propriedade | `private _circleBone: dragonBones.Bone;` | 11 |
| `_floorBoardBone` | propriedade | `private _floorBoardBone: dragonBones.Bone;` | 12 |
| `_aimState` | propriedade | `private _aimState: dragonBones.AnimationState;` | 13 |

### `Pixi/Demos/8.x/src/MultiTextureAltas.ts`

- Origem/commit: `Pixi/Demos/8.x/src/MultiTextureAltas.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/Demos/assets/Script/MultiTextureAltas.ts`, `Egret/Demos/src/BaseDemo.ts`, `Egret/Demos/src/demo/MultiTextureAltas.ts`, `Phaser/Demos/src/BaseDemo.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/Demos/4.x/src/BaseDemo.ts`, `Pixi/Demos/4.x/src/MultiTextureAltas.ts`, `Pixi/Demos/8.x/src/BaseDemo.ts`, `ThreeJS/Demos/src/BaseDemo.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `MultiTextureAltas`

Herança: extends BaseDemo.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 7 |
| `_onStart` | método | `protected _onStart(): void` | 19 |
| `_changeAnimation` | método | `private _changeAnimation(): void` | 55 |
| `_armatureDisplayA` | propriedade | `private _armatureDisplayA: dragonBones.PixiArmatureDisplay;` | 2 |
| `_armatureDisplayB` | propriedade | `private _armatureDisplayB: dragonBones.PixiArmatureDisplay;` | 3 |
| `_armatureDisplayC` | propriedade | `private _armatureDisplayC: dragonBones.PixiArmatureDisplay;` | 4 |
| `_armatureDisplayD` | propriedade | `private _armatureDisplayD: dragonBones.PixiArmatureDisplay;` | 5 |

### `Pixi/Demos/8.x/src/PerformanceTest.ts`

- Origem/commit: `Pixi/Demos/8.x/src/PerformanceTest.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/Demos/assets/Script/PerformanceTest.ts`, `DragonBones/src/dragonBones/core/BaseObject.ts`, `Egret/Demos/src/BaseDemo.ts`, `Egret/Demos/src/demo/PerformanceTest.ts`, `Hilo/Demos/src/PerformanceTest.ts`, `Phaser/Demos/src/BaseDemo.ts`, `Phaser/Demos/src/PerformanceTest.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/Demos/4.x/src/BaseDemo.ts`, `Pixi/Demos/4.x/src/PerformanceTest.ts`, `Pixi/Demos/8.x/src/BaseDemo.ts`, `ThreeJS/Demos/src/BaseDemo.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `PerformanceTest`

Herança: extends BaseDemo.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 7 |
| `_onStart` | método | `protected _onStart(): void` | 17 |
| `_enterFrameHandler` | método | `private _enterFrameHandler(deltaTime: number): void` | 35 |
| `_touchHandler` | método | `private _touchHandler(event: PIXI.interaction.InteractionEvent): void` | 55 |
| `_addArmature` | método | `private _addArmature(): void` | 74 |
| `_removeArmature` | método | `private _removeArmature(): void` | 90 |
| `_resetPosition` | método | `private _resetPosition(): void` | 105 |
| `_updateText` | método | `private _updateText(): void` | 129 |
| `_addingArmature` | propriedade | `private _addingArmature: boolean = false;` | 2 |
| `_removingArmature` | propriedade | `private _removingArmature: boolean = false;` | 3 |
| `_armatures` | propriedade | `private readonly _armatures: Array<dragonBones.PixiArmatureDisplay> = [];` | 4 |
| `_text` | propriedade | `private _text: PIXI.Text;` | 5 |

### `Pixi/Demos/8.x/src/ReplaceAnimation.ts`

- Origem/commit: `Pixi/Demos/8.x/src/ReplaceAnimation.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Egret/Demos/src/BaseDemo.ts`, `Egret/Demos/src/demo/ReplaceAnimation.ts`, `Hilo/Demos/src/ReplaceAnimation.ts`, `Phaser/Demos/src/BaseDemo.ts`, `Phaser/Demos/src/ReplaceAnimation.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/Demos/4.x/src/BaseDemo.ts`, `Pixi/Demos/4.x/src/ReplaceAnimation.ts`, `Pixi/Demos/8.x/src/BaseDemo.ts`, `ThreeJS/Demos/src/BaseDemo.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `ReplaceAnimation`

Herança: extends BaseDemo.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 7 |
| `_onStart` | método | `protected _onStart(): void` | 17 |
| `_changeAnimation` | método | `private _changeAnimation(): void` | 56 |
| `_armatureDisplayA` | propriedade | `private _armatureDisplayA: dragonBones.PixiArmatureDisplay;` | 2 |
| `_armatureDisplayB` | propriedade | `private _armatureDisplayB: dragonBones.PixiArmatureDisplay;` | 3 |
| `_armatureDisplayC` | propriedade | `private _armatureDisplayC: dragonBones.PixiArmatureDisplay;` | 4 |
| `_armatureDisplayD` | propriedade | `private _armatureDisplayD: dragonBones.PixiArmatureDisplay;` | 5 |

### `Pixi/Demos/8.x/src/ReplaceSkin.ts`

- Origem/commit: `Pixi/Demos/8.x/src/ReplaceSkin.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/Demos/assets/Script/ReplaceSkin.ts`, `DragonBones/src/dragonBones/event/EventObject.ts`, `Egret/Demos/src/BaseDemo.ts`, `Egret/Demos/src/demo/ReplaceSkin.ts`, `Phaser/Demos/src/BaseDemo.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/Demos/4.x/src/BaseDemo.ts`, `Pixi/Demos/4.x/src/ReplaceSkin.ts`, `Pixi/Demos/8.x/src/BaseDemo.ts`, `ThreeJS/Demos/src/BaseDemo.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `ReplaceSkin`

Herança: extends BaseDemo.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 8 |
| `_onStart` | método | `protected _onStart(): void` | 69 |
| `_animationEventHandler` | método | `private _animationEventHandler(event: dragonBones.EventObject): void` | 109 |
| `_randomReplaceSkin` | método | `private _randomReplaceSkin(): void` | 117 |
| `_replaceSuitIndex` | propriedade | `private _replaceSuitIndex: number = 0;` | 2 |
| `_factory` | propriedade | `private readonly _factory: dragonBones.PixiFactory = dragonBones.PixiFactory.factory;` | 3 |
| `_suitConfigs` | propriedade | `private readonly _suitConfigs: string[][] = [];` | 4 |
| `_replaceSuitParts` | propriedade | `private readonly _replaceSuitParts: string[] = [];` | 5 |
| `_armatureDisplay` | propriedade | `private _armatureDisplay: dragonBones.PixiArmatureDisplay;` | 6 |

### `Pixi/Demos/8.x/src/ReplaceSlotDisplay.ts`

- Origem/commit: `Pixi/Demos/8.x/src/ReplaceSlotDisplay.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/Demos/assets/Script/ReplaceAnimation.ts`, `Cocos/Demos/assets/Script/ReplaceSlotDisplay.ts`, `Egret/Demos/src/BaseDemo.ts`, `Egret/Demos/src/demo/ReplaceSlotDisplay.ts`, `Hilo/Demos/src/ReplaceSlotDisplay.ts`, `Phaser/Demos/src/BaseDemo.ts`, `Phaser/Demos/src/ReplaceSlotDisplay.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiFactory.ts`, `Pixi/Demos/4.x/src/BaseDemo.ts`, `Pixi/Demos/4.x/src/ReplaceSlotDisplay.ts`, `Pixi/Demos/8.x/src/BaseDemo.ts`, `ThreeJS/Demos/src/BaseDemo.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `ReplaceSlotDisplay`

Herança: extends BaseDemo.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 10 |
| `_onStart` | método | `protected _onStart(): void` | 23 |
| `_replaceDisplay` | método | `private _replaceDisplay(type: number): void` | 55 |
| `WEAPON_RIGHT_LIST` | propriedade | `private static readonly WEAPON_RIGHT_LIST: string[] = ["weapon_1004_r", "weapon_1004b_r", "weapon_1004c_r", "weapon_1004d_r", "weapon_1004e_r"];` | 2 |
| `_leftWeaponIndex` | propriedade | `private _leftWeaponIndex: number = 0;` | 4 |
| `_rightWeaponIndex` | propriedade | `private _rightWeaponIndex: number = 0;` | 5 |
| `_factory` | propriedade | `private readonly _factory: dragonBones.PixiFactory = dragonBones.PixiFactory.factory;` | 6 |
| `_armatureDisplay` | propriedade | `private _armatureDisplay: dragonBones.PixiArmatureDisplay;` | 7 |
| `_logoText` | propriedade | `private _logoText: PIXI.Text;` | 8 |

### `ThreeJS/Current/src/dragonBones/three/ThreeArmatureDisplay.ts`

- Origem/commit: `ThreeJS/Current/src/dragonBones/three/ThreeArmatureDisplay.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: integrations/ThreeJS/Current/src/dragonBones/three/ThreeArmatureDisplay.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/animation/Animation.ts`, `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/armature/IArmatureProxy.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/event/EventObject.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `ThreeArmatureDisplay`

Herança: extends THREE.Group; implements IArmatureProxy.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `dbInit` | método | `public dbInit(armature: Armature): void` | 39 |
| `dbClear` | método | `public dbClear(): void` | 45 |
| `dbUpdate` | método | `public dbUpdate(): void` | 55 |
| `dispose` | método | `public dispose(disposeProxy: boolean = true): void` | 74 |
| `dispatchDBEvent` | método | `public dispatchDBEvent(type: EventStringType, eventObject: EventObject): void` | 85 |
| `hasDBEventListener` | método | `public hasDBEventListener(type: EventStringType): boolean` | 93 |
| `addDBEventListener` | método | `public addDBEventListener(type: EventStringType, listener: (event: EventObject) => void, target: any): void` | 100 |
| `removeDBEventListener` | método | `public removeDBEventListener(type: EventStringType, listener: (event: EventObject) => void, target: any): void` | 107 |
| `armature` | método | `public get armature(): Armature` | 115 |
| `animation` | método | `public get animation(): Animation` | 121 |
| `hasEvent` | método | `public hasEvent(type: EventStringType): boolean` | 128 |
| `addEvent` | método | `public addEvent(type: EventStringType, listener: (event: EventObject) => void, target: any): void` | 134 |
| `removeEvent` | método | `public removeEvent(type: EventStringType, listener: (event: EventObject) => void, target: any): void` | 140 |
| `debugDraw` | propriedade | `public debugDraw: boolean = false;` | 31 |
| `_debugDraw` | propriedade | `private _debugDraw: boolean = false;` | 32 |
| `_armature` | propriedade | `private _armature: Armature = null as any;` | 34 |
| `_debugDrawer` | propriedade | `private _debugDrawer: THREE.Group \| null = null;` | 35 |

### `ThreeJS/Current/src/dragonBones/three/ThreeFactory.ts`

- Origem/commit: `ThreeJS/Current/src/dragonBones/three/ThreeFactory.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: integrations/ThreeJS/Current/src/dragonBones/three/ThreeFactory.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/armature/Slot.ts`, `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/factory/BaseFactory.ts`, `DragonBones/src/dragonBones/model/ArmatureData.ts`, `DragonBones/src/dragonBones/model/TextureAtlasData.ts`, `DragonBones/src/dragonBones/parser/DataParser.ts`, `Phaser/3.x/src/dragonBones/phaser/display/Slot.ts`, `Phaser/3.x/src/dragonBones/phaser/display/TextureAtlasData.ts`, `ThreeJS/Current/src/dragonBones/three/ThreeArmatureDisplay.ts`, `ThreeJS/Current/src/dragonBones/three/ThreeSlot.ts`, `ThreeJS/Current/src/dragonBones/three/ThreeTextureAtlasData.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `ThreeFactory`

Herança: extends BaseFactory.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `_createDragonBones` | método | `private static _createDragonBones(): DragonBones` | 53 |
| `create` | método | `public static create<T>(type: string): T` | 62 |
| `release` | método | `public static release(object: any, type: string): void` | 91 |
| `factory` | método | `public static get factory(): ThreeFactory` | 117 |
| `constructor` | método | `public constructor(dataParser: DataParser \| null = null)` | 127 |
| `_buildTextureAtlasData` | método | `protected _buildTextureAtlasData(textureAtlasData: ThreeTextureAtlasData \| null, textureAtlas: THREE.Texture \| null): TextureAtlasData` | 137 |
| `_buildArmature` | método | `protected _buildArmature(dataPackage: BuildArmaturePackage): Armature` | 157 |
| `_buildSlot` | método | `protected _buildSlot(dataPackage: BuildArmaturePackage, slotData: SlotData, armature: Armature): Slot` | 169 |
| `buildArmatureDisplay` | método | `public buildArmatureDisplay(armatureName: string, dragonBonesName: string = "", skinName: string = "", textureAtlasName: string = ""): ThreeArmatureDisplay \| null` | 214 |
| `getTextureDisplay` | método | `public getTextureDisplay(textureName: string, textureAtlasName: string \| null = null): THREE.Sprite \| null` | 238 |
| `soundEventManager` | método | `public get soundEventManager(): ThreeArmatureDisplay` | 264 |
| `POOL_TYPE_VECTOR2` | propriedade | `public static readonly POOL_TYPE_VECTOR2: string = "POOL_TYPE_VECTOR2";` | 38 |
| `POOL_TYPE_VECTOR3` | propriedade | `public static readonly POOL_TYPE_VECTOR3: string = "POOL_TYPE_VECTOR3";` | 42 |
| `POOL_TYPE_FACE3` | propriedade | `public static readonly POOL_TYPE_FACE3: string = "POOL_TYPE_FACE3";` | 46 |
| `_emptyMaterial` | propriedade | `private static readonly _emptyMaterial: THREE.Material = new THREE.MeshBasicMaterial();` | 48 |
| `_pools` | propriedade | `private static readonly _pools: Map<Array<any>> = {};` | 49 |
| `_dragonBonesInstance` | propriedade | `private static _dragonBonesInstance: DragonBones = null as any;` | 50 |
| `_factory` | propriedade | `private static _factory: ThreeFactory = null as any;` | 51 |

### `ThreeJS/Current/src/dragonBones/three/ThreeSlot.ts`

- Origem/commit: `ThreeJS/Current/src/dragonBones/three/ThreeSlot.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: integrations/ThreeJS/Current/src/dragonBones/three/ThreeSlot.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/armature/Bone.ts`, `DragonBones/src/dragonBones/armature/Slot.ts`, `DragonBones/src/dragonBones/armature/Surface.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/model/DisplayData.ts`, `Phaser/3.x/src/dragonBones/phaser/display/Slot.ts`, `ThreeJS/Current/src/dragonBones/three/ThreeArmatureDisplay.ts`, `ThreeJS/Current/src/dragonBones/three/ThreeFactory.ts`, `ThreeJS/Current/src/dragonBones/three/ThreeTextureAtlasData.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `ThreeSlot`

Herança: extends Slot.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 35 |
| `_onClear` | método | `protected _onClear(): void` | 46 |
| `_clearGeometry` | método | `private _clearGeometry(geometry: THREE.Geometry): void` | 57 |
| `_initDisplay` | método | `protected _initDisplay(value: any, isRetain: boolean): void` | 81 |
| `_disposeDisplay` | método | `protected _disposeDisplay(value: any, isRelease: boolean): void` | 88 |
| `_onUpdateDisplay` | método | `protected _onUpdateDisplay(): void` | 97 |
| `_addDisplay` | método | `protected _addDisplay(): void` | 102 |
| `_replaceDisplay` | método | `protected _replaceDisplay(value: any): void` | 107 |
| `_removeDisplay` | método | `protected _removeDisplay(): void` | 114 |
| `_updateZOrder` | método | `protected _updateZOrder(): void` | 118 |
| `_updateVisible` | método | `public _updateVisible(): void` | 124 |
| `_updateBlendMode` | método | `protected _updateBlendMode(): void` | 128 |
| `_updateColor` | método | `protected _updateColor(): void` | 191 |
| `_updateFrame` | método | `protected _updateFrame(): void` | 233 |
| `_updateMesh` | método | `protected _updateMesh(): void` | 392 |
| `_updateTransform` | método | `protected _updateTransform(): void` | 487 |
| `_identityTransform` | método | `protected _identityTransform(): void` | 499 |
| `RAW_UVS` | propriedade | `public static readonly RAW_UVS: Array<number> = [0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 1.0, 1.0];` | 39 |
| `RAW_INDICES` | propriedade | `public static readonly RAW_INDICES: Array<number> = [0, 1, 2, 3, 2, 1];` | 40 |
| `_renderDisplay` | propriedade | `private _renderDisplay: THREE.Object3D;` | 42 |
| `_material` | propriedade | `private _material: THREE.MeshBasicMaterial \| null = null;` | 43 |

### `ThreeJS/Current/src/dragonBones/three/ThreeTextureAtlasData.ts`

- Origem/commit: `ThreeJS/Current/src/dragonBones/three/ThreeTextureAtlasData.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: integrations/ThreeJS/Current/src/dragonBones/three/ThreeTextureAtlasData.lua. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/model/TextureAtlasData.ts`, `Phaser/3.x/src/dragonBones/phaser/display/TextureAtlasData.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `ThreeTextureAtlasData`

Herança: extends TextureAtlasData.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 35 |
| `_onClear` | método | `protected _onClear(): void` | 44 |
| `createTexture` | método | `public createTexture(): TextureData` | 62 |
| `renderTexture` | método | `public get renderTexture(): THREE.Texture \| null` | 75 |
| `renderTexture` | método | `public set renderTexture(value: THREE.Texture \| null)` | 78 |
| `material` | propriedade | `public material: THREE.MeshBasicMaterial = null as any;` | 41 |
| `_renderTexture` | propriedade | `private _renderTexture: THREE.Texture \| null = null;` | 42 |

#### ClassDeclaration `ThreeTextureData`

Herança: extends TextureData.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `toString` | método | `public static toString(): string` | 90 |

### `ThreeJS/Demos/src/BaseDemo.ts`

- Origem/commit: `ThreeJS/Demos/src/BaseDemo.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/core/DragonBones.ts`, `Egret/Demos/src/BaseDemo.ts`, `Phaser/Demos/src/BaseDemo.ts`, `Pixi/Demos/4.x/src/BaseDemo.ts`, `Pixi/Demos/8.x/src/BaseDemo.ts`, `ThreeJS/Current/src/dragonBones/three/ThreeFactory.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `BaseDemo`

Herança: extends THREE.Group.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 11 |
| `_onStart` | método | `protected abstract _onStart(): void;` | 31 |
| `_startTick` | método | `protected _startTick(): void` | 33 |
| `_loadResources` | método | `protected _loadResources(): void` | 43 |
| `stageWidth` | método | `public get stageWidth(): number` | 91 |
| `stageHeight` | método | `public get stageHeight(): number` | 95 |
| `BACKGROUND_URL` | propriedade | `private static readonly BACKGROUND_URL: string = "resource/background.png";` | 2 |
| `_scene` | propriedade | `private readonly _scene: THREE.Scene = new THREE.Scene();` | 3 |
| `_camera` | propriedade | `private readonly _camera: THREE.OrthographicCamera = new THREE.OrthographicCamera(-0.5, 0.5, -0.5, 0.5, -1000, 1000);` | 4 |
| `_renderer` | propriedade | `private readonly _renderer: THREE.WebGLRenderer = new THREE.WebGLRenderer({ antialias: true });` | 5 |
| `_background` | propriedade | `private readonly _background: THREE.Sprite = new THREE.Sprite();` | 7 |
| `_resources` | propriedade | `protected readonly _resources: string[] = [BaseDemo.BACKGROUND_URL];` | 8 |
| `_loadedResources` | propriedade | `protected readonly _loadedResources: dragonBones.Map<any \| ArrayBuffer \| THREE.Texture> = {};` | 9 |

### `ThreeJS/Demos/src/HelloDragonBones.ts`

- Origem/commit: `ThreeJS/Demos/src/HelloDragonBones.ts` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `Cocos/Demos/assets/Script/HelloDragonBones.ts`, `Egret/Demos/src/BaseDemo.ts`, `Egret/Demos/src/demo/HelloDragonBones.ts`, `Hilo/Demos/src/HelloDragonBones.ts`, `Phaser/Demos/src/BaseDemo.ts`, `Phaser/Demos/src/HelloDragonBones.ts`, `Pixi/Demos/4.x/src/BaseDemo.ts`, `Pixi/Demos/4.x/src/HelloDragonBones.ts`, `Pixi/Demos/8.x/src/BaseDemo.ts`, `Pixi/Demos/8.x/src/HelloDragonBones.ts`, `ThreeJS/Current/src/dragonBones/three/ThreeFactory.ts`, `ThreeJS/Demos/src/BaseDemo.ts`.
- Importações externas: nenhuma importação explícita; APIs globais ainda exigem auditoria.

#### ClassDeclaration `HelloDragonBones`

Herança: extends BaseDemo.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `public constructor()` | 19 |
| `_onStart` | método | `protected _onStart(): void` | 30 |

### `builds/build_base.js`

- Origem/commit: `builds/build_base.js` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: nenhuma declaração autoral identificada.
- Importações externas: 'async', 'child_process', 'copy', 'del', 'download', 'fs', 'lodash', 'path'.

#### ClassDeclaration `BuildBase`

Herança: nenhuma explícita.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `constructor (config)` | 33 |
| `clearCache` | método | `clearCache (callback)` | 49 |
| `rewriteOutFile` | método | `rewriteOutFile (outFolder, tsconfigPath)` | 67 |
| `download` | método | `download (callback)` | 83 |
| `compile` | método | `compile (callback)` | 96 |
| `build` | método | `build (callback)` | 112 |
| `checkVersion` | método | `get checkVersion ()` | 151 |
| `copySrcPath` | método | `get copySrcPath ()` | 161 |
| `downloadUrl` | método | `get downloadUrl ()` | 170 |
| `copyDeclear` | método | `copyDeclear (callback)` | 179 |

### `builds/build_egret.js`

- Origem/commit: `builds/build_egret.js` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `builds/build_base.js`.
- Importações externas: './build_base', 'async', 'copy', 'debug', 'path', 'semver'.

#### ClassDeclaration `BuildEgret`

Herança: extends BuildBase.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `constructor (config)` | 15 |
| `checkVersion` | método | `get checkVersion ()` | 24 |
| `copySrcPath` | método | `get copySrcPath ()` | 32 |
| `downloadUrl` | método | `get downloadUrl ()` | 44 |
| `copyDeclear` | método | `copyDeclear (callback)` | 52 |

### `builds/build_hilo.js`

- Origem/commit: `builds/build_hilo.js` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `builds/build_base.js`.
- Importações externas: './build_base', 'async', 'copy', 'debug', 'path', 'semver'.

#### ClassDeclaration `BuildHilo`

Herança: extends BuildBase.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `constructor (config)` | 15 |
| `checkVersion` | método | `get checkVersion ()` | 24 |
| `copySrcPath` | método | `get copySrcPath ()` | 32 |
| `downloadUrl` | método | `get downloadUrl ()` | 44 |
| `copyDeclear` | método | `copyDeclear (callback)` | 52 |

### `builds/build_phaser.js`

- Origem/commit: `builds/build_phaser.js` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `builds/build_base.js`.
- Importações externas: './build_base', 'async', 'copy', 'debug', 'path', 'semver'.

#### ClassDeclaration `BuildPhaser`

Herança: extends BuildBase.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `constructor (config)` | 15 |
| `checkVersion` | método | `get checkVersion ()` | 24 |
| `copySrcPath` | método | `get copySrcPath ()` | 32 |
| `downloadUrl` | método | `get downloadUrl ()` | 44 |
| `copyDeclear` | método | `copyDeclear (callback)` | 58 |

### `builds/build_pixi.js`

- Origem/commit: `builds/build_pixi.js` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `builds/build_base.js`.
- Importações externas: './build_base', 'async', 'copy', 'debug', 'path', 'semver'.

#### ClassDeclaration `BuildPixi`

Herança: extends BuildBase.

| Membro | Tipo | Assinatura original | Linha |
| --- | --- | --- | --- |
| `constructor` | método | `constructor (config)` | 15 |
| `checkVersion` | método | `get checkVersion ()` | 24 |
| `copySrcPath` | método | `get copySrcPath ()` | 32 |
| `downloadUrl` | método | `get downloadUrl ()` | 44 |
| `copyDeclear` | método | `copyDeclear (callback)` | 53 |

### `builds/cli.js`

- Origem/commit: `builds/cli.js` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `DragonBones/src/dragonBones/core/DragonBones.ts`, `builds/build_egret.js`, `builds/build_hilo.js`, `builds/build_phaser.js`, `builds/build_pixi.js`.
- Importações externas: './index', 'debug', 'lodash', 'minimist', 'path', 'semver'.

Sem classes/interfaces/enums/funções nomeadas declaradas. Revisar instruções de topo, exports e callbacks no arquivo original.

### `builds/index.js`

- Origem/commit: `builds/index.js` @ `64b6c69ae35777c2404be68c9192e2c56906079e`.
- Destino: —. Ausente nesta reconstrução antes de iniciar o porte.
- Estado: pendente; testes: não executados; diferenças: ainda não auditadas.
- Dependências candidatas: `builds/build_egret.js`, `builds/build_hilo.js`, `builds/build_phaser.js`, `builds/build_pixi.js`.
- Importações externas: './build_egret', './build_hilo', './build_phaser', './build_pixi'.

Sem classes/interfaces/enums/funções nomeadas declaradas. Revisar instruções de topo, exports e callbacks no arquivo original.
