# Dependências e fronteiras de plataforma

Fonte única: DragonBones/DragonBonesJS@`64b6c69ae35777c2404be68c9192e2c56906079e`. Gerado por `node tools/dependencies.js ../DragonBonesJS`.

Resolução de símbolos TypeScript 2.4.2 por pacote/tsconfig, separando versões dos backends. Arquivos lidos de blobs Git. Bibliotecas padrão do compilador são infraestrutura de análise. As arestas incluem usos em tipos e em execução; não equivalem à ordem de inicialização. Símbolos dinâmicos e nomes não resolvidos permanecem explicitamente pendentes, sem inventar APIs Lua. Esta análise não valida comportamento.

A auditoria de inventário é completa quanto aos caminhos, declarações e referências estáticas disponíveis. A fidelidade dos contratos externos será verificada nas etapas 09/10, sem bloquear o porte das classes geom independentes.

## Entradas externas ausentes no commit

- `Egret/4.x/tsconfig.json` solicita `Egret/4.x/libs/egret.d.ts`.
- `Hilo/1.x/tsconfig.json` solicita `Hilo/1.x/libs/hilo.d.ts`.
- `Phaser/2.x/tsconfig.json` solicita `Phaser/2.x/libs/phaser.d.ts`.
- `Pixi/4.x/tsconfig.json` solicita `Pixi/4.x/libs/pixi.js.d.ts`.
- `ThreeJS/Current/tsconfig.json` solicita `ThreeJS/Current/node_modules/@types/three/index.d.ts`.

## Dependências por arquivo autoral TypeScript

### `Cocos/1.x/src/dragonBones/cocos/CocosArmatureComponent.ts`

- Contexto isolado: `Cocos/1.x/tsconfig.json`.
- Arquivos autorais resolvidos: `Cocos/1.x/src/dragonBones/cocos/CocosAsset.ts`, `DragonBones/src/dragonBones/animation/Animation.ts`, `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/armature/IArmatureProxy.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/event/EventObject.ts`, `DragonBones/src/dragonBones/event/IEventDispatcher.ts`.
- Declarações externas/distribuídas: `Cocos/1.x/libs/creator.d.ts`.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `cc.Component`, `cc.Event`, `cc.Event.EventCustom`, `cc.Float`, `cc.Integer`, `cc.String`, `cc._decorator`.

### `Cocos/1.x/src/dragonBones/cocos/CocosAsset.ts`

- Contexto isolado: `Cocos/1.x/tsconfig.json`.
- Arquivos autorais resolvidos: nenhuma.
- Declarações externas/distribuídas: `Cocos/1.x/libs/creator.d.ts`.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `cc.Asset`, `cc.String`, `cc.Texture2D`, `cc._decorator`.

### `Cocos/1.x/src/dragonBones/cocos/CocosFactory.ts`

- Contexto isolado: `Cocos/1.x/tsconfig.json`.
- Arquivos autorais resolvidos: `Cocos/1.x/src/dragonBones/cocos/CocosArmatureComponent.ts`, `Cocos/1.x/src/dragonBones/cocos/CocosSlot.ts`, `Cocos/1.x/src/dragonBones/cocos/CocosTextureAtlasData.ts`, `DragonBones/src/dragonBones/animation/WorldClock.ts`, `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/armature/Slot.ts`, `DragonBones/src/dragonBones/armature/TransformObject.ts`, `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/factory/BaseFactory.ts`, `DragonBones/src/dragonBones/model/ArmatureData.ts`, `DragonBones/src/dragonBones/model/DisplayData.ts`, `DragonBones/src/dragonBones/model/DragonBonesData.ts`, `DragonBones/src/dragonBones/model/SkinData.ts`, `DragonBones/src/dragonBones/parser/DataParser.ts`.
- Declarações externas/distribuídas: `Cocos/1.x/libs/creator.d.ts`.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `cc.Component`, `cc.Node`, `cc.Sprite`, `cc._decorator`, `cc.find`, `cc.game`, `cc.game.addPersistRootNode`, `console.warn`.

### `Cocos/1.x/src/dragonBones/cocos/CocosSlot.ts`

- Contexto isolado: `Cocos/1.x/tsconfig.json`.
- Arquivos autorais resolvidos: `Cocos/1.x/src/dragonBones/cocos/CocosTextureAtlasData.ts`, `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/armature/Bone.ts`, `DragonBones/src/dragonBones/armature/Slot.ts`, `DragonBones/src/dragonBones/armature/Surface.ts`, `DragonBones/src/dragonBones/armature/TransformObject.ts`, `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/geom/ColorTransform.ts`, `DragonBones/src/dragonBones/geom/Matrix.ts`, `DragonBones/src/dragonBones/geom/Rectangle.ts`, `DragonBones/src/dragonBones/geom/Transform.ts`, `DragonBones/src/dragonBones/model/ArmatureData.ts`, `DragonBones/src/dragonBones/model/DisplayData.ts`, `DragonBones/src/dragonBones/model/DragonBonesData.ts`, `DragonBones/src/dragonBones/model/TextureAtlasData.ts`.
- Declarações externas/distribuídas: `Cocos/1.x/libs/creator.d.ts`.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `cc.BlendFunc`, `cc.Sprite`, `cc.rect`, `cc.size`.

### `Cocos/1.x/src/dragonBones/cocos/CocosTextureAtlasData.ts`

- Contexto isolado: `Cocos/1.x/tsconfig.json`.
- Arquivos autorais resolvidos: `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/geom/Rectangle.ts`, `DragonBones/src/dragonBones/model/TextureAtlasData.ts`.
- Declarações externas/distribuídas: `Cocos/1.x/libs/creator.d.ts`.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `cc.SpriteFrame`, `cc.rect`, `cc.size`, `cc.v2`.

### `Cocos/Demos/assets/Script/AnimationBase.ts`

- Contexto isolado: `Cocos/Demos/tsconfig.json`.
- Arquivos autorais resolvidos: nenhuma.
- Declarações externas/distribuídas: `Cocos/Demos/creator.d.ts`, `Cocos/Demos/declaration/dragonBones.d.ts`.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `Math.max`, `Math.min`, `cc.Component`, `cc.Node`, `cc.Node.EventType`, `cc.Node.EventType.TOUCH_END`, `cc.Node.EventType.TOUCH_MOVE`, `cc.Node.EventType.TOUCH_START`, `cc._decorator`, `cc._decorator.ccclass`, `cc.loader`, `cc.loader.getRes`, `cc.loader.load`, `cc.url`, `cc.url.raw`, `console.log`, `dragonBones.CocosFactory`, `dragonBones.CocosFactory.factory`, `dragonBones.EventObject`, `dragonBones.EventObject.COMPLETE`, `dragonBones.EventObject.FADE_IN`, `dragonBones.EventObject.FADE_IN_COMPLETE`, `dragonBones.EventObject.FADE_OUT`, `dragonBones.EventObject.FADE_OUT_COMPLETE`, `dragonBones.EventObject.FRAME_EVENT`, `dragonBones.EventObject.LOOP_COMPLETE`, `dragonBones.EventObject.START`.

### `Cocos/Demos/assets/Script/AnimationLayer.ts`

- Contexto isolado: `Cocos/Demos/tsconfig.json`.
- Arquivos autorais resolvidos: nenhuma.
- Declarações externas/distribuídas: `Cocos/Demos/creator.d.ts`, `Cocos/Demos/declaration/dragonBones.d.ts`.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `cc.Component`, `cc._decorator`, `cc._decorator.ccclass`, `cc.loader`, `cc.loader.getRes`, `cc.loader.load`, `cc.url`, `cc.url.raw`, `dragonBones.CocosFactory`, `dragonBones.CocosFactory.factory`, `dragonBones.EventObject`, `dragonBones.EventObject.LOOP_COMPLETE`.

### `Cocos/Demos/assets/Script/BoneOffset.ts`

- Contexto isolado: `Cocos/Demos/tsconfig.json`.
- Arquivos autorais resolvidos: nenhuma.
- Declarações externas/distribuídas: `Cocos/Demos/creator.d.ts`, `Cocos/Demos/declaration/dragonBones.d.ts`.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `Math.PI`, `Math.atan2`, `Math.random`, `Math.sqrt`, `cc.Canvas`, `cc.Component`, `cc._decorator`, `cc._decorator.ccclass`, `cc.loader`, `cc.loader.getRes`, `cc.loader.load`, `cc.url`, `cc.url.raw`, `dragonBones.CocosFactory`, `dragonBones.CocosFactory.factory`, `dragonBones.EventObject`, `dragonBones.EventObject.COMPLETE`.

### `Cocos/Demos/assets/Script/BoundingBox.ts`

- Contexto isolado: `Cocos/Demos/tsconfig.json`.
- Arquivos autorais resolvidos: `Cocos/Demos/assets/Script/DragHelper.ts`.
- Declarações externas/distribuídas: `Cocos/Demos/creator.d.ts`, `Cocos/Demos/declaration/dragonBones.d.ts`.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `Math.atan2`, `Math.sqrt`, `cc.Component`, `cc._decorator`, `cc._decorator.ccclass`, `cc.loader`, `cc.loader.getRes`, `cc.loader.load`, `cc.url`, `cc.url.raw`, `cc.v2`, `dragonBones.CocosFactory`, `dragonBones.CocosFactory.factory`.

### `Cocos/Demos/assets/Script/CoreElement.ts`

- Contexto isolado: `Cocos/Demos/tsconfig.json`.
- Arquivos autorais resolvidos: nenhuma.
- Declarações externas/distribuídas: `Cocos/Demos/creator.d.ts`, `Cocos/Demos/declaration/dragonBones.d.ts`.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `Math.PI`, `Math.abs`, `Math.atan2`, `Math.cos`, `Math.random`, `Math.sin`, `cc.Canvas`, `cc.Component`, `cc.Node`, `cc.Node.EventType`, `cc.Node.EventType.MOUSE_MOVE`, `cc.Node.EventType.TOUCH_END`, `cc.Node.EventType.TOUCH_START`, `cc.SystemEvent`, `cc.SystemEvent.EventType`, `cc.SystemEvent.EventType.KEY_DOWN`, `cc.SystemEvent.EventType.KEY_UP`, `cc._decorator`, `cc._decorator.ccclass`, `cc.loader`, `cc.loader.getRes`, `cc.loader.load`, `cc.systemEvent`, `cc.systemEvent.on`, `cc.url`, `cc.url.raw`, `cc.v2`, `dragonBones.CocosFactory`, `dragonBones.CocosFactory.factory`, `dragonBones.CocosFactory.factory.buildArmature`, `dragonBones.CocosFactory.factory.buildArmatureComponent`, `dragonBones.CocosFactory.factory.getArmatureData`, `dragonBones.CocosFactory.factory.replaceSkin`, `dragonBones.EventObject`, `dragonBones.EventObject.COMPLETE`, `dragonBones.EventObject.FADE_IN_COMPLETE`, `dragonBones.EventObject.FADE_OUT_COMPLETE`, `dragonBones.EventObject.FRAME_EVENT`, `dragonBones.Transform`, `dragonBones.Transform.RAD_DEG`.

### `Cocos/Demos/assets/Script/DragHelper.ts`

- Contexto isolado: `Cocos/Demos/tsconfig.json`.
- Arquivos autorais resolvidos: nenhuma.
- Declarações externas/distribuídas: `Cocos/Demos/creator.d.ts`, `Cocos/Demos/declaration/dragonBones.d.ts`.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `cc.Node`, `cc.Node.EventType`, `cc.Node.EventType.TOUCH_END`, `cc.Node.EventType.TOUCH_MOVE`, `cc.Node.EventType.TOUCH_START`, `cc.v2`, `dragonBones.CocosArmatureComponent`.

### `Cocos/Demos/assets/Script/DragonBonesEvent.ts`

- Contexto isolado: `Cocos/Demos/tsconfig.json`.
- Arquivos autorais resolvidos: nenhuma.
- Declarações externas/distribuídas: `Cocos/Demos/creator.d.ts`, `Cocos/Demos/declaration/dragonBones.d.ts`.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `cc.Component`, `cc.Node`, `cc.Node.EventType`, `cc.Node.EventType.TOUCH_START`, `cc._decorator`, `cc._decorator.ccclass`, `cc.loader`, `cc.loader.getRes`, `cc.loader.load`, `cc.url`, `cc.url.raw`, `console.log`, `dragonBones.CocosFactory`, `dragonBones.CocosFactory.factory`, `dragonBones.EventObject`, `dragonBones.EventObject.COMPLETE`, `dragonBones.EventObject.SOUND_EVENT`.

### `Cocos/Demos/assets/Script/EyeTracking.ts`

- Contexto isolado: `Cocos/Demos/tsconfig.json`.
- Arquivos autorais resolvidos: nenhuma.
- Declarações externas/distribuídas: `Cocos/Demos/creator.d.ts`, `Cocos/Demos/declaration/dragonBones.d.ts`.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `Math.max`, `Math.min`, `Math.sin`, `cc.Component`, `cc.Node`, `cc.Node.EventType`, `cc.Node.EventType.MOUSE_MOVE`, `cc._decorator`, `cc._decorator.ccclass`, `cc.loader`, `cc.loader.getRes`, `cc.loader.load`, `cc.url`, `cc.url.raw`, `cc.v2`, `dragonBones.CocosFactory`, `dragonBones.CocosFactory.factory`.

### `Cocos/Demos/assets/Script/HelloDragonBones.ts`

- Contexto isolado: `Cocos/Demos/tsconfig.json`.
- Arquivos autorais resolvidos: nenhuma.
- Declarações externas/distribuídas: `Cocos/Demos/creator.d.ts`, `Cocos/Demos/declaration/dragonBones.d.ts`.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `cc.Component`, `cc._decorator`, `cc._decorator.ccclass`, `cc.loader`, `cc.loader.getRes`, `cc.loader.load`, `cc.url`, `cc.url.raw`, `dragonBones.CocosFactory`, `dragonBones.CocosFactory.factory`.

### `Cocos/Demos/assets/Script/InverseKinematics.ts`

- Contexto isolado: `Cocos/Demos/tsconfig.json`.
- Arquivos autorais resolvidos: `Cocos/Demos/assets/Script/DragHelper.ts`.
- Declarações externas/distribuídas: `Cocos/Demos/creator.d.ts`, `Cocos/Demos/declaration/dragonBones.d.ts`.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `Math.PI`, `Math.abs`, `Math.atan2`, `Math.max`, `Math.min`, `Math.sin`, `Math.tan`, `cc.Component`, `cc.Node`, `cc.Node.EventType`, `cc.Node.EventType.MOUSE_MOVE`, `cc._decorator`, `cc._decorator.ccclass`, `cc.loader`, `cc.loader.getRes`, `cc.loader.load`, `cc.url`, `cc.url.raw`, `cc.v2`, `dragonBones.CocosFactory`, `dragonBones.CocosFactory.factory`, `dragonBones.Transform`, `dragonBones.Transform.DEG_RAD`, `dragonBones.Transform.normalizeRadian`.

### `Cocos/Demos/assets/Script/MultiTextureAltas.ts`

- Contexto isolado: `Cocos/Demos/tsconfig.json`.
- Arquivos autorais resolvidos: nenhuma.
- Declarações externas/distribuídas: `Cocos/Demos/creator.d.ts`, `Cocos/Demos/declaration/dragonBones.d.ts`.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `cc.Component`, `cc.Node`, `cc.Node.EventType`, `cc.Node.EventType.TOUCH_START`, `cc._decorator`, `cc._decorator.ccclass`, `cc.loader`, `cc.loader.getRes`, `cc.loader.load`, `cc.url`, `cc.url.raw`, `dragonBones.CocosFactory`, `dragonBones.CocosFactory.factory`.

### `Cocos/Demos/assets/Script/PerformanceTest.ts`

- Contexto isolado: `Cocos/Demos/tsconfig.json`.
- Arquivos autorais resolvidos: nenhuma.
- Declarações externas/distribuídas: `Cocos/Demos/creator.d.ts`, `Cocos/Demos/declaration/dragonBones.d.ts`.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `Math.ceil`, `Math.floor`, `cc.Canvas`, `cc.Component`, `cc.Label`, `cc.Node`, `cc.Node.EventType`, `cc.Node.EventType.TOUCH_END`, `cc.Node.EventType.TOUCH_START`, `cc._decorator`, `cc._decorator.ccclass`, `cc.loader`, `cc.loader.getRes`, `cc.loader.load`, `cc.url`, `cc.url.raw`, `dragonBones.BaseObject`, `dragonBones.BaseObject.clearPool`, `dragonBones.CocosFactory`, `dragonBones.CocosFactory.factory`, `dragonBones.CocosFactory.factory.clear`.

### `Cocos/Demos/assets/Script/ReplaceAnimation.ts`

- Contexto isolado: `Cocos/Demos/tsconfig.json`.
- Arquivos autorais resolvidos: nenhuma.
- Declarações externas/distribuídas: `Cocos/Demos/creator.d.ts`, `Cocos/Demos/declaration/dragonBones.d.ts`.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `cc.Component`, `cc.Node`, `cc.Node.EventType`, `cc.Node.EventType.TOUCH_START`, `cc._decorator`, `cc._decorator.ccclass`, `cc.loader`, `cc.loader.getRes`, `cc.loader.load`, `cc.url`, `cc.url.raw`, `dragonBones.CocosFactory`, `dragonBones.CocosFactory.factory`.

### `Cocos/Demos/assets/Script/ReplaceSkin.ts`

- Contexto isolado: `Cocos/Demos/tsconfig.json`.
- Arquivos autorais resolvidos: nenhuma.
- Declarações externas/distribuídas: `Cocos/Demos/creator.d.ts`, `Cocos/Demos/declaration/dragonBones.d.ts`.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `Math.floor`, `Math.random`, `cc.Component`, `cc.Node`, `cc.Node.EventType`, `cc.Node.EventType.TOUCH_START`, `cc._decorator`, `cc._decorator.ccclass`, `cc.loader`, `cc.loader.getRes`, `cc.loader.load`, `cc.url`, `cc.url.raw`, `dragonBones.CocosFactory`, `dragonBones.CocosFactory.factory`, `dragonBones.EventObject`, `dragonBones.EventObject.LOOP_COMPLETE`.

### `Cocos/Demos/assets/Script/ReplaceSlotDisplay.ts`

- Contexto isolado: `Cocos/Demos/tsconfig.json`.
- Arquivos autorais resolvidos: nenhuma.
- Declarações externas/distribuídas: `Cocos/Demos/creator.d.ts`, `Cocos/Demos/declaration/dragonBones.d.ts`.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `cc.Component`, `cc.Label`, `cc.Node`, `cc.Node.EventType`, `cc.Node.EventType.TOUCH_START`, `cc._decorator`, `cc._decorator.ccclass`, `cc.loader`, `cc.loader.getRes`, `cc.loader.load`, `cc.url`, `cc.url.raw`, `dragonBones.CocosFactory`, `dragonBones.CocosFactory.factory`.

### `Cocos/Demos/assets/Script/Test.ts`

- Contexto isolado: `Cocos/Demos/tsconfig.json`.
- Arquivos autorais resolvidos: nenhuma.
- Declarações externas/distribuídas: `Cocos/Demos/creator.d.ts`, `Cocos/Demos/declaration/dragonBones.d.ts`.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `cc.Component`, `cc._decorator`, `cc._decorator.ccclass`, `cc.loader`, `cc.loader.getRes`, `cc.loader.load`, `cc.url`, `cc.url.raw`, `dragonBones.CocosFactory`, `dragonBones.CocosFactory.factory`.

### `DragonBones/src/dragonBones/animation/Animation.ts`

- Contexto isolado: `DragonBones/tsconfig.json`.
- Arquivos autorais resolvidos: `DragonBones/src/dragonBones/animation/AnimationState.ts`, `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/armature/Bone.ts`, `DragonBones/src/dragonBones/armature/Slot.ts`, `DragonBones/src/dragonBones/armature/TransformObject.ts`, `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/model/AnimationConfig.ts`, `DragonBones/src/dragonBones/model/AnimationData.ts`, `DragonBones/src/dragonBones/model/ArmatureData.ts`, `DragonBones/src/dragonBones/model/DisplayData.ts`, `DragonBones/src/dragonBones/model/DragonBonesData.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `console.warn`.

### `DragonBones/src/dragonBones/animation/AnimationState.ts`

- Contexto isolado: `DragonBones/tsconfig.json`.
- Arquivos autorais resolvidos: `DragonBones/src/dragonBones/animation/Animation.ts`, `DragonBones/src/dragonBones/animation/BaseTimelineState.ts`, `DragonBones/src/dragonBones/animation/TimelineState.ts`, `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/armature/Bone.ts`, `DragonBones/src/dragonBones/armature/Constraint.ts`, `DragonBones/src/dragonBones/armature/Slot.ts`, `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/event/EventObject.ts`, `DragonBones/src/dragonBones/event/IEventDispatcher.ts`, `DragonBones/src/dragonBones/geom/Transform.ts`, `DragonBones/src/dragonBones/model/AnimationConfig.ts`, `DragonBones/src/dragonBones/model/AnimationData.ts`, `DragonBones/src/dragonBones/model/ArmatureData.ts`, `DragonBones/src/dragonBones/model/DisplayData.ts`, `DragonBones/src/dragonBones/model/DragonBonesData.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `Math.floor`.

### `DragonBones/src/dragonBones/animation/BaseTimelineState.ts`

- Contexto isolado: `DragonBones/tsconfig.json`.
- Arquivos autorais resolvidos: `DragonBones/src/dragonBones/animation/AnimationState.ts`, `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/model/AnimationData.ts`, `DragonBones/src/dragonBones/model/ArmatureData.ts`, `DragonBones/src/dragonBones/model/DragonBonesData.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `Math.PI`, `Math.cos`, `Math.floor`, `Math.pow`.

### `DragonBones/src/dragonBones/animation/IAnimatable.ts`

- Contexto isolado: `DragonBones/tsconfig.json`.
- Arquivos autorais resolvidos: `DragonBones/src/dragonBones/animation/WorldClock.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: nenhuma.

### `DragonBones/src/dragonBones/animation/TimelineState.ts`

- Contexto isolado: `DragonBones/tsconfig.json`.
- Arquivos autorais resolvidos: `DragonBones/src/dragonBones/animation/AnimationState.ts`, `DragonBones/src/dragonBones/animation/BaseTimelineState.ts`, `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/armature/Bone.ts`, `DragonBones/src/dragonBones/armature/Constraint.ts`, `DragonBones/src/dragonBones/armature/Slot.ts`, `DragonBones/src/dragonBones/armature/Surface.ts`, `DragonBones/src/dragonBones/armature/TransformObject.ts`, `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/event/EventObject.ts`, `DragonBones/src/dragonBones/event/IEventDispatcher.ts`, `DragonBones/src/dragonBones/geom/ColorTransform.ts`, `DragonBones/src/dragonBones/geom/Transform.ts`, `DragonBones/src/dragonBones/model/AnimationData.ts`, `DragonBones/src/dragonBones/model/ArmatureData.ts`, `DragonBones/src/dragonBones/model/ConstraintData.ts`, `DragonBones/src/dragonBones/model/DragonBonesData.ts`, `DragonBones/src/dragonBones/model/UserData.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `Math.floor`, `Math.pow`.

### `DragonBones/src/dragonBones/animation/WorldClock.ts`

- Contexto isolado: `DragonBones/tsconfig.json`.
- Arquivos autorais resolvidos: `DragonBones/src/dragonBones/animation/IAnimatable.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `Date.now`.

### `DragonBones/src/dragonBones/armature/Armature.ts`

- Contexto isolado: `DragonBones/tsconfig.json`.
- Arquivos autorais resolvidos: `DragonBones/src/dragonBones/animation/Animation.ts`, `DragonBones/src/dragonBones/animation/IAnimatable.ts`, `DragonBones/src/dragonBones/animation/WorldClock.ts`, `DragonBones/src/dragonBones/armature/Bone.ts`, `DragonBones/src/dragonBones/armature/Constraint.ts`, `DragonBones/src/dragonBones/armature/IArmatureProxy.ts`, `DragonBones/src/dragonBones/armature/Slot.ts`, `DragonBones/src/dragonBones/armature/TransformObject.ts`, `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/event/EventObject.ts`, `DragonBones/src/dragonBones/event/IEventDispatcher.ts`, `DragonBones/src/dragonBones/model/ArmatureData.ts`, `DragonBones/src/dragonBones/model/TextureAtlasData.ts`, `DragonBones/src/dragonBones/model/UserData.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `console.warn`.

### `DragonBones/src/dragonBones/armature/Bone.ts`

- Contexto isolado: `DragonBones/tsconfig.json`.
- Arquivos autorais resolvidos: `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/armature/Constraint.ts`, `DragonBones/src/dragonBones/armature/Slot.ts`, `DragonBones/src/dragonBones/armature/Surface.ts`, `DragonBones/src/dragonBones/armature/TransformObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/geom/Matrix.ts`, `DragonBones/src/dragonBones/geom/Transform.ts`, `DragonBones/src/dragonBones/model/ArmatureData.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `Math.PI`.

### `DragonBones/src/dragonBones/armature/Constraint.ts`

- Contexto isolado: `DragonBones/tsconfig.json`.
- Arquivos autorais resolvidos: `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/armature/Bone.ts`, `DragonBones/src/dragonBones/armature/Slot.ts`, `DragonBones/src/dragonBones/armature/TransformObject.ts`, `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/geom/Matrix.ts`, `DragonBones/src/dragonBones/geom/Point.ts`, `DragonBones/src/dragonBones/geom/Transform.ts`, `DragonBones/src/dragonBones/model/ArmatureData.ts`, `DragonBones/src/dragonBones/model/ConstraintData.ts`, `DragonBones/src/dragonBones/model/DisplayData.ts`, `DragonBones/src/dragonBones/model/DragonBonesData.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `Math.PI`, `Math.atan2`, `Math.cos`, `Math.sin`, `Math.sqrt`.

### `DragonBones/src/dragonBones/armature/IArmatureProxy.ts`

- Contexto isolado: `DragonBones/tsconfig.json`.
- Arquivos autorais resolvidos: `DragonBones/src/dragonBones/animation/Animation.ts`, `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/event/IEventDispatcher.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: nenhuma.

### `DragonBones/src/dragonBones/armature/Slot.ts`

- Contexto isolado: `DragonBones/tsconfig.json`.
- Arquivos autorais resolvidos: `DragonBones/src/dragonBones/animation/Animation.ts`, `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/armature/Bone.ts`, `DragonBones/src/dragonBones/armature/Surface.ts`, `DragonBones/src/dragonBones/armature/TransformObject.ts`, `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/event/EventObject.ts`, `DragonBones/src/dragonBones/geom/ColorTransform.ts`, `DragonBones/src/dragonBones/geom/Matrix.ts`, `DragonBones/src/dragonBones/geom/Point.ts`, `DragonBones/src/dragonBones/geom/Rectangle.ts`, `DragonBones/src/dragonBones/geom/Transform.ts`, `DragonBones/src/dragonBones/model/ArmatureData.ts`, `DragonBones/src/dragonBones/model/BoundingBoxData.ts`, `DragonBones/src/dragonBones/model/DisplayData.ts`, `DragonBones/src/dragonBones/model/DragonBonesData.ts`, `DragonBones/src/dragonBones/model/SkinData.ts`, `DragonBones/src/dragonBones/model/TextureAtlasData.ts`, `DragonBones/src/dragonBones/model/UserData.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `Math.atan2`, `Math.cos`, `Math.sin`.

### `DragonBones/src/dragonBones/armature/Surface.ts`

- Contexto isolado: `DragonBones/tsconfig.json`.
- Arquivos autorais resolvidos: `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/armature/Bone.ts`, `DragonBones/src/dragonBones/armature/Constraint.ts`, `DragonBones/src/dragonBones/armature/TransformObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/geom/Matrix.ts`, `DragonBones/src/dragonBones/geom/Point.ts`, `DragonBones/src/dragonBones/geom/Transform.ts`, `DragonBones/src/dragonBones/model/ArmatureData.ts`, `DragonBones/src/dragonBones/model/DisplayData.ts`, `DragonBones/src/dragonBones/model/DragonBonesData.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `Math.PI`, `Math.atan2`, `Math.floor`, `Math.sqrt`.

### `DragonBones/src/dragonBones/armature/TransformObject.ts`

- Contexto isolado: `DragonBones/tsconfig.json`.
- Arquivos autorais resolvidos: `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/geom/Matrix.ts`, `DragonBones/src/dragonBones/geom/Point.ts`, `DragonBones/src/dragonBones/geom/Transform.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: nenhuma.

### `DragonBones/src/dragonBones/core/BaseObject.ts`

- Contexto isolado: `DragonBones/tsconfig.json`.
- Arquivos autorais resolvidos: `DragonBones/src/dragonBones/core/DragonBones.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `console.warn`.

### `DragonBones/src/dragonBones/core/DragonBones.ts`

- Contexto isolado: `DragonBones/tsconfig.json`.
- Arquivos autorais resolvidos: `DragonBones/src/dragonBones/animation/WorldClock.ts`, `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/event/EventObject.ts`, `DragonBones/src/dragonBones/event/IEventDispatcher.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `Date.now`, `console.assert`, `console.info`, `console.warn`.

### `DragonBones/src/dragonBones/event/EventObject.ts`

- Contexto isolado: `DragonBones/tsconfig.json`.
- Arquivos autorais resolvidos: `DragonBones/src/dragonBones/animation/AnimationState.ts`, `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/armature/Bone.ts`, `DragonBones/src/dragonBones/armature/Slot.ts`, `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/event/IEventDispatcher.ts`, `DragonBones/src/dragonBones/model/ArmatureData.ts`, `DragonBones/src/dragonBones/model/UserData.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: nenhuma.

### `DragonBones/src/dragonBones/event/IEventDispatcher.ts`

- Contexto isolado: `DragonBones/tsconfig.json`.
- Arquivos autorais resolvidos: `DragonBones/src/dragonBones/event/EventObject.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: nenhuma.

### `DragonBones/src/dragonBones/factory/BaseFactory.ts`

- Contexto isolado: `DragonBones/tsconfig.json`.
- Arquivos autorais resolvidos: `DragonBones/src/dragonBones/animation/Animation.ts`, `DragonBones/src/dragonBones/animation/WorldClock.ts`, `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/armature/Bone.ts`, `DragonBones/src/dragonBones/armature/Constraint.ts`, `DragonBones/src/dragonBones/armature/Slot.ts`, `DragonBones/src/dragonBones/armature/Surface.ts`, `DragonBones/src/dragonBones/armature/TransformObject.ts`, `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/event/EventObject.ts`, `DragonBones/src/dragonBones/model/AnimationData.ts`, `DragonBones/src/dragonBones/model/ArmatureData.ts`, `DragonBones/src/dragonBones/model/ConstraintData.ts`, `DragonBones/src/dragonBones/model/DisplayData.ts`, `DragonBones/src/dragonBones/model/DragonBonesData.ts`, `DragonBones/src/dragonBones/model/SkinData.ts`, `DragonBones/src/dragonBones/model/TextureAtlasData.ts`, `DragonBones/src/dragonBones/parser/BinaryDataParser.ts`, `DragonBones/src/dragonBones/parser/DataParser.ts`, `DragonBones/src/dragonBones/parser/ObjectDataParser.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `console.warn`.

### `DragonBones/src/dragonBones/geom/ColorTransform.ts`

- Contexto isolado: `DragonBones/tsconfig.json`.
- Arquivos autorais resolvidos: nenhuma.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: nenhuma.

### `DragonBones/src/dragonBones/geom/Matrix.ts`

- Contexto isolado: `DragonBones/tsconfig.json`.
- Arquivos autorais resolvidos: nenhuma.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `Math.ceil`, `Math.floor`.

### `DragonBones/src/dragonBones/geom/Point.ts`

- Contexto isolado: `DragonBones/tsconfig.json`.
- Arquivos autorais resolvidos: nenhuma.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: nenhuma.

### `DragonBones/src/dragonBones/geom/Rectangle.ts`

- Contexto isolado: `DragonBones/tsconfig.json`.
- Arquivos autorais resolvidos: nenhuma.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: nenhuma.

### `DragonBones/src/dragonBones/geom/Transform.ts`

- Contexto isolado: `DragonBones/tsconfig.json`.
- Arquivos autorais resolvidos: `DragonBones/src/dragonBones/geom/Matrix.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `Math.PI`, `Math.atan`, `Math.cos`, `Math.sin`.

### `DragonBones/src/dragonBones/model/AnimationConfig.ts`

- Contexto isolado: `DragonBones/tsconfig.json`.
- Arquivos autorais resolvidos: `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: nenhuma.

### `DragonBones/src/dragonBones/model/AnimationData.ts`

- Contexto isolado: `DragonBones/tsconfig.json`.
- Arquivos autorais resolvidos: `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/model/ArmatureData.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `Math.ceil`, `Math.max`.

### `DragonBones/src/dragonBones/model/ArmatureData.ts`

- Contexto isolado: `DragonBones/tsconfig.json`.
- Arquivos autorais resolvidos: `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/geom/ColorTransform.ts`, `DragonBones/src/dragonBones/geom/Matrix.ts`, `DragonBones/src/dragonBones/geom/Rectangle.ts`, `DragonBones/src/dragonBones/geom/Transform.ts`, `DragonBones/src/dragonBones/model/AnimationData.ts`, `DragonBones/src/dragonBones/model/CanvasData.ts`, `DragonBones/src/dragonBones/model/ConstraintData.ts`, `DragonBones/src/dragonBones/model/DisplayData.ts`, `DragonBones/src/dragonBones/model/DragonBonesData.ts`, `DragonBones/src/dragonBones/model/SkinData.ts`, `DragonBones/src/dragonBones/model/UserData.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `console.warn`.

### `DragonBones/src/dragonBones/model/BoundingBoxData.ts`

- Contexto isolado: `DragonBones/tsconfig.json`.
- Arquivos autorais resolvidos: `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `Math.PI`, `Math.atan2`, `Math.sqrt`.

### `DragonBones/src/dragonBones/model/CanvasData.ts`

- Contexto isolado: `DragonBones/tsconfig.json`.
- Arquivos autorais resolvidos: `DragonBones/src/dragonBones/core/BaseObject.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: nenhuma.

### `DragonBones/src/dragonBones/model/ConstraintData.ts`

- Contexto isolado: `DragonBones/tsconfig.json`.
- Arquivos autorais resolvidos: `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/model/ArmatureData.ts`, `DragonBones/src/dragonBones/model/DisplayData.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: nenhuma.

### `DragonBones/src/dragonBones/model/DisplayData.ts`

- Contexto isolado: `DragonBones/tsconfig.json`.
- Arquivos autorais resolvidos: `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/geom/Point.ts`, `DragonBones/src/dragonBones/geom/Transform.ts`, `DragonBones/src/dragonBones/model/ArmatureData.ts`, `DragonBones/src/dragonBones/model/BoundingBoxData.ts`, `DragonBones/src/dragonBones/model/DragonBonesData.ts`, `DragonBones/src/dragonBones/model/SkinData.ts`, `DragonBones/src/dragonBones/model/TextureAtlasData.ts`, `DragonBones/src/dragonBones/model/UserData.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: nenhuma.

### `DragonBones/src/dragonBones/model/DragonBonesData.ts`

- Contexto isolado: `DragonBones/tsconfig.json`.
- Arquivos autorais resolvidos: `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/model/ArmatureData.ts`, `DragonBones/src/dragonBones/model/UserData.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `console.warn`.

### `DragonBones/src/dragonBones/model/SkinData.ts`

- Contexto isolado: `DragonBones/tsconfig.json`.
- Arquivos autorais resolvidos: `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/model/ArmatureData.ts`, `DragonBones/src/dragonBones/model/DisplayData.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: nenhuma.

### `DragonBones/src/dragonBones/model/TextureAtlasData.ts`

- Contexto isolado: `DragonBones/tsconfig.json`.
- Arquivos autorais resolvidos: `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/geom/Rectangle.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `console.warn`.

### `DragonBones/src/dragonBones/model/UserData.ts`

- Contexto isolado: `DragonBones/tsconfig.json`.
- Arquivos autorais resolvidos: `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/model/ArmatureData.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: nenhuma.

### `DragonBones/src/dragonBones/parser/BinaryDataParser.ts`

- Contexto isolado: `DragonBones/tsconfig.json`.
- Arquivos autorais resolvidos: `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/model/AnimationData.ts`, `DragonBones/src/dragonBones/model/ArmatureData.ts`, `DragonBones/src/dragonBones/model/ConstraintData.ts`, `DragonBones/src/dragonBones/model/DisplayData.ts`, `DragonBones/src/dragonBones/model/DragonBonesData.ts`, `DragonBones/src/dragonBones/parser/DataParser.ts`, `DragonBones/src/dragonBones/parser/ObjectDataParser.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `Float32Array.BYTES_PER_ELEMENT`, `Int16Array.BYTES_PER_ELEMENT`, `JSON.parse`, `Math.pow`, `String.fromCharCode`, `Uint16Array.BYTES_PER_ELEMENT`, `console.assert`.

### `DragonBones/src/dragonBones/parser/DataParser.ts`

- Contexto isolado: `DragonBones/tsconfig.json`.
- Arquivos autorais resolvidos: `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/model/DragonBonesData.ts`, `DragonBones/src/dragonBones/model/TextureAtlasData.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: nenhuma.

### `DragonBones/src/dragonBones/parser/ObjectDataParser.ts`

- Contexto isolado: `DragonBones/tsconfig.json`.
- Arquivos autorais resolvidos: `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/geom/ColorTransform.ts`, `DragonBones/src/dragonBones/geom/Matrix.ts`, `DragonBones/src/dragonBones/geom/Point.ts`, `DragonBones/src/dragonBones/geom/Rectangle.ts`, `DragonBones/src/dragonBones/geom/Transform.ts`, `DragonBones/src/dragonBones/model/AnimationData.ts`, `DragonBones/src/dragonBones/model/ArmatureData.ts`, `DragonBones/src/dragonBones/model/BoundingBoxData.ts`, `DragonBones/src/dragonBones/model/CanvasData.ts`, `DragonBones/src/dragonBones/model/ConstraintData.ts`, `DragonBones/src/dragonBones/model/DisplayData.ts`, `DragonBones/src/dragonBones/model/DragonBonesData.ts`, `DragonBones/src/dragonBones/model/SkinData.ts`, `DragonBones/src/dragonBones/model/TextureAtlasData.ts`, `DragonBones/src/dragonBones/model/UserData.ts`, `DragonBones/src/dragonBones/parser/DataParser.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `Float32Array.BYTES_PER_ELEMENT`, `Int16Array.BYTES_PER_ELEMENT`, `Math.floor`, `Math.round`, `Uint16Array.BYTES_PER_ELEMENT`, `console.assert`, `console.warn`.

### `Egret/4.x/src/dragonBones/egret/EgretArmatureDisplay.ts`

- Contexto isolado: `Egret/4.x/tsconfig.json`.
- Arquivos autorais resolvidos: `DragonBones/src/dragonBones/animation/Animation.ts`, `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/armature/Bone.ts`, `DragonBones/src/dragonBones/armature/IArmatureProxy.ts`, `DragonBones/src/dragonBones/armature/Slot.ts`, `DragonBones/src/dragonBones/armature/Surface.ts`, `DragonBones/src/dragonBones/armature/TransformObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/event/EventObject.ts`, `DragonBones/src/dragonBones/event/IEventDispatcher.ts`, `DragonBones/src/dragonBones/geom/Matrix.ts`, `DragonBones/src/dragonBones/geom/Rectangle.ts`, `DragonBones/src/dragonBones/model/ArmatureData.ts`, `DragonBones/src/dragonBones/model/BoundingBoxData.ts`, `DragonBones/src/dragonBones/model/TextureAtlasData.ts`, `Egret/4.x/src/dragonBones/egret/EgretFactory.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: `Bitmap`, `BitmapNode`, `Matrix`, `Mesh`, `MeshNode`, `Rectangle`, `Shape`, `Sprite`, `egret`, `sys`.
- Acessos a APIs externas/globais: `Math.max`, `egret.DisplayObjectContainer`, `egret.Event`, `egret.Event.create`, `egret.Event.release`, `egret.Rectangle`, `egret.Shape`, `egret.Sprite`, `egret.sys`, `egret.sys.GroupNode`.

### `Egret/4.x/src/dragonBones/egret/EgretFactory.ts`

- Contexto isolado: `Egret/4.x/tsconfig.json`.
- Arquivos autorais resolvidos: `DragonBones/src/dragonBones/animation/WorldClock.ts`, `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/armature/Slot.ts`, `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/factory/BaseFactory.ts`, `DragonBones/src/dragonBones/model/ArmatureData.ts`, `DragonBones/src/dragonBones/model/TextureAtlasData.ts`, `DragonBones/src/dragonBones/parser/DataParser.ts`, `Egret/4.x/src/dragonBones/egret/EgretArmatureDisplay.ts`, `Egret/4.x/src/dragonBones/egret/EgretSlot.ts`, `Egret/4.x/src/dragonBones/egret/EgretTextureAtlasData.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: `Bitmap`, `Texture`, `egret`.
- Acessos a APIs externas/globais: `console.warn`, `egret.Bitmap`, `egret.BitmapData`, `egret.Capabilities`, `egret.Capabilities.engineVersion`, `egret.Capabilities.engineVersion.substr`, `egret.Capabilities.renderMode`, `egret.Capabilities.runtimeType`, `egret.Mesh`, `egret.RuntimeType`, `egret.RuntimeType.NATIVE`, `egret.Texture`, `egret.getTimer`, `egret.startTick`.

### `Egret/4.x/src/dragonBones/egret/EgretSlot.ts`

- Contexto isolado: `Egret/4.x/tsconfig.json`.
- Arquivos autorais resolvidos: `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/armature/Bone.ts`, `DragonBones/src/dragonBones/armature/Slot.ts`, `DragonBones/src/dragonBones/armature/Surface.ts`, `DragonBones/src/dragonBones/armature/TransformObject.ts`, `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/geom/ColorTransform.ts`, `DragonBones/src/dragonBones/geom/Matrix.ts`, `DragonBones/src/dragonBones/geom/Rectangle.ts`, `DragonBones/src/dragonBones/model/ArmatureData.ts`, `DragonBones/src/dragonBones/model/DisplayData.ts`, `DragonBones/src/dragonBones/model/DragonBonesData.ts`, `DragonBones/src/dragonBones/model/TextureAtlasData.ts`, `Egret/4.x/src/dragonBones/egret/EgretArmatureDisplay.ts`, `Egret/4.x/src/dragonBones/egret/EgretFactory.ts`, `Egret/4.x/src/dragonBones/egret/EgretTextureAtlasData.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: `Bitmap`, `BitmapNode`, `ColorMatrixFilter`, `DisplayObject`, `GroupNode`, `Matrix`, `Mesh`, `MeshNode`, `egret`, `sys`.
- Acessos a APIs externas/globais: `egret.$TempMatrix`, `egret.$TempMatrix.identity`, `egret.BlendMode`, `egret.BlendMode.ADD`, `egret.BlendMode.ERASE`, `egret.BlendMode.NORMAL`, `egret.ColorMatrixFilter`, `egret.Matrix`, `egret.sys`, `egret.sys.BitmapNode`, `egret.sys.RenderNode`, `egret.sys.RenderNode.prototype`, `egret.sys.RenderNode.prototype.cleanBeforeRender`, `egret.sys.RenderNode.prototype.cleanBeforeRender.call`, `egret.sys.blendModeToNumber`.

### `Egret/4.x/src/dragonBones/egret/EgretTextureAtlasData.ts`

- Contexto isolado: `Egret/4.x/tsconfig.json`.
- Arquivos autorais resolvidos: `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/geom/Rectangle.ts`, `DragonBones/src/dragonBones/model/TextureAtlasData.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: `Texture`, `egret`.
- Acessos a APIs externas/globais: `egret.$TextureScaleFactor`, `egret.Texture`.

### `Egret/Demos/src/BaseDemo.ts`

- Contexto isolado: `Egret/Demos/tsconfig.json`.
- Arquivos autorais resolvidos: nenhuma.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: `Bitmap`, `RES`, `TextField`, `egret`.
- Acessos a APIs externas/globais: `Math.round`, `RES.ResourceItem`, `RES.ResourceItem.TYPE_BIN`, `RES.getRes`, `RES.getResByUrl`, `egret.Bitmap`, `egret.DisplayObjectContainer`, `egret.Event`, `egret.Event.ADDED_TO_STAGE`, `egret.HorizontalAlign`, `egret.HorizontalAlign.CENTER`, `egret.TextField`.

### `Egret/Demos/src/DragHelper.ts`

- Contexto isolado: `Egret/Demos/tsconfig.json`.
- Arquivos autorais resolvidos: nenhuma.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: `DisplayObject`, `EgretArmatureDisplay`, `Point`, `TouchEvent`, `dragonBones`, `egret`.
- Acessos a APIs externas/globais: `dragonBones.OffsetMode`, `dragonBones.OffsetMode.Override`, `egret.Point`, `egret.TouchEvent`, `egret.TouchEvent.TOUCH_BEGIN`, `egret.TouchEvent.TOUCH_END`, `egret.TouchEvent.TOUCH_MOVE`, `egret.TouchEvent.TOUCH_RELEASE_OUTSIDE`.

### `Egret/Demos/src/Main.ts`

- Contexto isolado: `Egret/Demos/tsconfig.json`.
- Arquivos autorais resolvidos: `Egret/Demos/src/demo/HelloDragonBones.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: `egret`.
- Acessos a APIs externas/globais: `egret.DisplayObjectContainer`.

### `Egret/Demos/src/demo/AnimationBase.ts`

- Contexto isolado: `Egret/Demos/tsconfig.json`.
- Arquivos autorais resolvidos: `Egret/Demos/src/BaseDemo.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: `EgretArmatureDisplay`, `EgretEvent`, `RES`, `TouchEvent`, `dragonBones`, `egret`.
- Acessos a APIs externas/globais: `Math.max`, `Math.min`, `RES.getRes`, `console.log`, `dragonBones.EgretFactory`, `dragonBones.EgretFactory.factory`, `dragonBones.EventObject`, `dragonBones.EventObject.COMPLETE`, `dragonBones.EventObject.FADE_IN`, `dragonBones.EventObject.FADE_IN_COMPLETE`, `dragonBones.EventObject.FADE_OUT`, `dragonBones.EventObject.FADE_OUT_COMPLETE`, `dragonBones.EventObject.FRAME_EVENT`, `dragonBones.EventObject.LOOP_COMPLETE`, `dragonBones.EventObject.START`, `egret.TouchEvent`, `egret.TouchEvent.TOUCH_BEGIN`, `egret.TouchEvent.TOUCH_END`, `egret.TouchEvent.TOUCH_MOVE`.

### `Egret/Demos/src/demo/AnimationLayer.ts`

- Contexto isolado: `Egret/Demos/tsconfig.json`.
- Arquivos autorais resolvidos: `Egret/Demos/src/BaseDemo.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: `EgretArmatureDisplay`, `EgretEvent`, `RES`, `dragonBones`.
- Acessos a APIs externas/globais: `RES.getRes`, `dragonBones.EgretFactory`, `dragonBones.EgretFactory.factory`, `dragonBones.EventObject`, `dragonBones.EventObject.LOOP_COMPLETE`.

### `Egret/Demos/src/demo/BoneOffset.ts`

- Contexto isolado: `Egret/Demos/tsconfig.json`.
- Arquivos autorais resolvidos: `Egret/Demos/src/BaseDemo.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: `EgretArmatureDisplay`, `EgretEvent`, `RES`, `dragonBones`.
- Acessos a APIs externas/globais: `Math.PI`, `Math.atan2`, `Math.random`, `Math.sqrt`, `RES.getRes`, `dragonBones.EgretFactory`, `dragonBones.EgretFactory.factory`, `dragonBones.EventObject`, `dragonBones.EventObject.COMPLETE`.

### `Egret/Demos/src/demo/BoundingBox.ts`

- Contexto isolado: `Egret/Demos/tsconfig.json`.
- Arquivos autorais resolvidos: `Egret/Demos/src/BaseDemo.ts`, `Egret/Demos/src/DragHelper.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: `Bone`, `EgretArmatureDisplay`, `Event`, `Point`, `RES`, `dragonBones`, `egret`.
- Acessos a APIs externas/globais: `Math.atan2`, `Math.sqrt`, `RES.getRes`, `dragonBones.EgretFactory`, `dragonBones.EgretFactory.factory`, `dragonBones.OffsetMode`, `dragonBones.OffsetMode.Override`, `egret.Event`, `egret.Event.ENTER_FRAME`, `egret.Point`.

### `Egret/Demos/src/demo/CoreElement.ts`

- Contexto isolado: `Egret/Demos/tsconfig.json`.
- Arquivos autorais resolvidos: `Egret/Demos/src/BaseDemo.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: `AnimationState`, `Armature`, `EgretArmatureDisplay`, `EgretEvent`, `Event`, `Point`, `RES`, `TouchEvent`, `dragonBones`, `egret`.
- Acessos a APIs externas/globais: `Math.PI`, `Math.abs`, `Math.atan2`, `Math.cos`, `Math.random`, `Math.sin`, `RES.getRes`, `document.addEventListener`, `dragonBones.EgretFactory`, `dragonBones.EgretFactory.factory`, `dragonBones.EgretFactory.factory.buildArmature`, `dragonBones.EgretFactory.factory.buildArmatureDisplay`, `dragonBones.EgretFactory.factory.getArmatureData`, `dragonBones.EgretFactory.factory.replaceSkin`, `dragonBones.EventObject`, `dragonBones.EventObject.COMPLETE`, `dragonBones.EventObject.FADE_IN_COMPLETE`, `dragonBones.EventObject.FADE_OUT_COMPLETE`, `dragonBones.EventObject.FRAME_EVENT`, `egret.Event`, `egret.Event.ENTER_FRAME`, `egret.Point`, `egret.TouchEvent`, `egret.TouchEvent.TOUCH_BEGIN`, `egret.TouchEvent.TOUCH_END`, `egret.sys`, `egret.sys.TouchHandler`, `egret.sys.TouchHandler.prototype`, `egret.sys.TouchHandler.prototype.onTouchMove`.

### `Egret/Demos/src/demo/DragonBonesEvent.ts`

- Contexto isolado: `Egret/Demos/tsconfig.json`.
- Arquivos autorais resolvidos: `Egret/Demos/src/BaseDemo.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: `EgretArmatureDisplay`, `EgretEvent`, `RES`, `dragonBones`, `egret`.
- Acessos a APIs externas/globais: `RES.getRes`, `console.log`, `dragonBones.EgretFactory`, `dragonBones.EgretFactory.factory`, `dragonBones.EventObject`, `dragonBones.EventObject.COMPLETE`, `dragonBones.EventObject.SOUND_EVENT`, `egret.TouchEvent`, `egret.TouchEvent.TOUCH_BEGIN`.

### `Egret/Demos/src/demo/EyeTracking.ts`

- Contexto isolado: `Egret/Demos/tsconfig.json`.
- Arquivos autorais resolvidos: `Egret/Demos/src/BaseDemo.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: `EgretArmatureDisplay`, `Event`, `Point`, `RES`, `dragonBones`, `egret`.
- Acessos a APIs externas/globais: `Math.max`, `Math.min`, `Math.sin`, `RES.getRes`, `dragonBones.EgretFactory`, `dragonBones.EgretFactory.factory`, `egret.Event`, `egret.Event.ENTER_FRAME`, `egret.Point`, `egret.sys`, `egret.sys.TouchHandler`, `egret.sys.TouchHandler.prototype`, `egret.sys.TouchHandler.prototype.onTouchMove`.

### `Egret/Demos/src/demo/HelloDragonBones.ts`

- Contexto isolado: `Egret/Demos/tsconfig.json`.
- Arquivos autorais resolvidos: `Egret/Demos/src/BaseDemo.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: `RES`, `dragonBones`.
- Acessos a APIs externas/globais: `RES.getRes`, `dragonBones.EgretFactory`, `dragonBones.EgretFactory.factory`.

### `Egret/Demos/src/demo/InverseKinematics.ts`

- Contexto isolado: `Egret/Demos/tsconfig.json`.
- Arquivos autorais resolvidos: `Egret/Demos/src/BaseDemo.ts`, `Egret/Demos/src/DragHelper.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: `AnimationState`, `Bone`, `EgretArmatureDisplay`, `Event`, `Point`, `RES`, `dragonBones`, `egret`.
- Acessos a APIs externas/globais: `Math.PI`, `Math.abs`, `Math.atan2`, `Math.max`, `Math.min`, `Math.sin`, `Math.tan`, `RES.getRes`, `dragonBones.EgretFactory`, `dragonBones.EgretFactory.factory`, `dragonBones.Transform`, `dragonBones.Transform.DEG_RAD`, `dragonBones.Transform.normalizeRadian`, `egret.Event`, `egret.Event.ENTER_FRAME`, `egret.Point`, `egret.sys`, `egret.sys.TouchHandler`, `egret.sys.TouchHandler.prototype`, `egret.sys.TouchHandler.prototype.onTouchMove`.

### `Egret/Demos/src/demo/MultiTextureAltas.ts`

- Contexto isolado: `Egret/Demos/tsconfig.json`.
- Arquivos autorais resolvidos: `Egret/Demos/src/BaseDemo.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: `EgretArmatureDisplay`, `RES`, `TouchEvent`, `dragonBones`, `egret`.
- Acessos a APIs externas/globais: `RES.getRes`, `dragonBones.EgretFactory`, `dragonBones.EgretFactory.factory`, `egret.TouchEvent`, `egret.TouchEvent.TOUCH_BEGIN`.

### `Egret/Demos/src/demo/PerformanceTest.ts`

- Contexto isolado: `Egret/Demos/tsconfig.json`.
- Arquivos autorais resolvidos: `Egret/Demos/src/BaseDemo.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: `EgretArmatureDisplay`, `Event`, `RES`, `TextField`, `TouchEvent`, `dragonBones`, `egret`.
- Acessos a APIs externas/globais: `Math.ceil`, `Math.floor`, `RES.getRes`, `dragonBones.BaseObject`, `dragonBones.BaseObject.clearPool`, `dragonBones.EgretFactory`, `dragonBones.EgretFactory.factory`, `dragonBones.EgretFactory.factory.clear`, `egret.Event`, `egret.Event.ENTER_FRAME`, `egret.TouchEvent`, `egret.TouchEvent.TOUCH_BEGIN`, `egret.TouchEvent.TOUCH_END`.

### `Egret/Demos/src/demo/ReplaceAnimation.ts`

- Contexto isolado: `Egret/Demos/tsconfig.json`.
- Arquivos autorais resolvidos: `Egret/Demos/src/BaseDemo.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: `EgretArmatureDisplay`, `RES`, `dragonBones`, `egret`.
- Acessos a APIs externas/globais: `RES.getRes`, `dragonBones.EgretFactory`, `dragonBones.EgretFactory.factory`, `egret.TouchEvent`, `egret.TouchEvent.TOUCH_END`.

### `Egret/Demos/src/demo/ReplaceSkin.ts`

- Contexto isolado: `Egret/Demos/tsconfig.json`.
- Arquivos autorais resolvidos: `Egret/Demos/src/BaseDemo.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: `EgretArmatureDisplay`, `EgretEvent`, `EgretFactory`, `RES`, `dragonBones`, `egret`.
- Acessos a APIs externas/globais: `Math.floor`, `Math.random`, `RES.getRes`, `dragonBones.EgretFactory`, `dragonBones.EgretFactory.factory`, `dragonBones.EventObject`, `dragonBones.EventObject.LOOP_COMPLETE`, `egret.TouchEvent`, `egret.TouchEvent.TOUCH_BEGIN`.

### `Egret/Demos/src/demo/ReplaceSlotDisplay.ts`

- Contexto isolado: `Egret/Demos/tsconfig.json`.
- Arquivos autorais resolvidos: `Egret/Demos/src/BaseDemo.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: `EgretArmatureDisplay`, `EgretFactory`, `RES`, `TextField`, `TouchEvent`, `dragonBones`, `egret`.
- Acessos a APIs externas/globais: `RES.getRes`, `dragonBones.EgretFactory`, `dragonBones.EgretFactory.factory`, `egret.TextField`, `egret.TouchEvent`, `egret.TouchEvent.TOUCH_BEGIN`.

### `Hilo/1.x/src/dragonBones/hilo/HiloArmatureDisplay.ts`

- Contexto isolado: `Hilo/1.x/tsconfig.json`.
- Arquivos autorais resolvidos: `DragonBones/src/dragonBones/animation/Animation.ts`, `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/armature/IArmatureProxy.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/event/EventObject.ts`, `DragonBones/src/dragonBones/event/IEventDispatcher.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: `Hilo`.
- Acessos a APIs externas/globais: `Hilo.Container`.

### `Hilo/1.x/src/dragonBones/hilo/HiloFactory.ts`

- Contexto isolado: `Hilo/1.x/tsconfig.json`.
- Arquivos autorais resolvidos: `DragonBones/src/dragonBones/animation/WorldClock.ts`, `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/armature/Slot.ts`, `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/factory/BaseFactory.ts`, `DragonBones/src/dragonBones/model/ArmatureData.ts`, `DragonBones/src/dragonBones/model/TextureAtlasData.ts`, `DragonBones/src/dragonBones/parser/DataParser.ts`, `Hilo/1.x/src/dragonBones/hilo/HiloArmatureDisplay.ts`, `Hilo/1.x/src/dragonBones/hilo/HiloSlot.ts`, `Hilo/1.x/src/dragonBones/hilo/HiloTextureAtlasData.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: `Bitmap`, `Hilo`.
- Acessos a APIs externas/globais: `Hilo.Bitmap`, `console.warn`.

### `Hilo/1.x/src/dragonBones/hilo/HiloSlot.ts`

- Contexto isolado: `Hilo/1.x/tsconfig.json`.
- Arquivos autorais resolvidos: `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/armature/Bone.ts`, `DragonBones/src/dragonBones/armature/Slot.ts`, `DragonBones/src/dragonBones/armature/TransformObject.ts`, `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/geom/ColorTransform.ts`, `DragonBones/src/dragonBones/geom/Matrix.ts`, `DragonBones/src/dragonBones/geom/Rectangle.ts`, `DragonBones/src/dragonBones/geom/Transform.ts`, `DragonBones/src/dragonBones/model/ArmatureData.ts`, `DragonBones/src/dragonBones/model/TextureAtlasData.ts`, `Hilo/1.x/src/dragonBones/hilo/HiloArmatureDisplay.ts`, `Hilo/1.x/src/dragonBones/hilo/HiloTextureAtlasData.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: `Bitmap`, `Hilo`, `View`.
- Acessos a APIs externas/globais: `Math.round`.

### `Hilo/1.x/src/dragonBones/hilo/HiloTextureAtlasData.ts`

- Contexto isolado: `Hilo/1.x/tsconfig.json`.
- Arquivos autorais resolvidos: `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/model/TextureAtlasData.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: nenhuma.

### `Hilo/Demos/src/AnimationBaseTest.ts`

- Contexto isolado: `Hilo/Demos/tsconfig.json`.
- Arquivos autorais resolvidos: `Hilo/Demos/src/BaseTest.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: `EventObject`, `Hilo`, `HiloArmatureDisplay`, `dragonBones`.
- Acessos a APIs externas/globais: `Hilo.event`, `Math.max`, `Math.min`, `console.log`, `dragonBones.EventObject`, `dragonBones.EventObject.COMPLETE`, `dragonBones.EventObject.FADE_IN`, `dragonBones.EventObject.FADE_IN_COMPLETE`, `dragonBones.EventObject.FADE_OUT`, `dragonBones.EventObject.FADE_OUT_COMPLETE`, `dragonBones.EventObject.FRAME_EVENT`, `dragonBones.EventObject.LOOP_COMPLETE`, `dragonBones.EventObject.START`, `dragonBones.HiloFactory`, `dragonBones.HiloFactory.factory`.

### `Hilo/Demos/src/BaseTest.ts`

- Contexto isolado: `Hilo/Demos/tsconfig.json`.
- Arquivos autorais resolvidos: nenhuma.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: `Hilo`, `Map`, `Stage`, `Text`, `Ticker`, `dragonBones`.
- Acessos a APIs externas/globais: `Hilo.Container`, `Hilo.Stage`, `Hilo.Text`, `Hilo.Ticker`, `Hilo.event`, `JSON.parse`, `document.createElement`, `document.getElementById`, `dragonBones.HiloFactory`, `dragonBones.HiloFactory.factory`, `dragonBones.HiloFactory.factory.dragonBones`.

### `Hilo/Demos/src/HelloDragonBones.ts`

- Contexto isolado: `Hilo/Demos/tsconfig.json`.
- Arquivos autorais resolvidos: `Hilo/Demos/src/BaseTest.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: `dragonBones`.
- Acessos a APIs externas/globais: `dragonBones.HiloFactory`, `dragonBones.HiloFactory.factory`.

### `Hilo/Demos/src/PerformanceTest.ts`

- Contexto isolado: `Hilo/Demos/tsconfig.json`.
- Arquivos autorais resolvidos: `Hilo/Demos/src/BaseTest.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: `Hilo`, `HiloArmatureDisplay`, `Text`, `dragonBones`.
- Acessos a APIs externas/globais: `Hilo.event`, `Math.ceil`, `Math.floor`, `dragonBones.BaseObject`, `dragonBones.BaseObject.clearPool`, `dragonBones.HiloFactory`, `dragonBones.HiloFactory.factory`, `dragonBones.HiloFactory.factory.clear`.

### `Hilo/Demos/src/ReplaceAnimation.ts`

- Contexto isolado: `Hilo/Demos/tsconfig.json`.
- Arquivos autorais resolvidos: `Hilo/Demos/src/BaseTest.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: `Hilo`, `HiloArmatureDisplay`, `dragonBones`.
- Acessos a APIs externas/globais: `Hilo.event`, `dragonBones.HiloFactory`, `dragonBones.HiloFactory.factory`.

### `Hilo/Demos/src/ReplaceSlotDisplay.ts`

- Contexto isolado: `Hilo/Demos/tsconfig.json`.
- Arquivos autorais resolvidos: `Hilo/Demos/src/BaseTest.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: `Hilo`, `HiloArmatureDisplay`, `HiloFactory`, `dragonBones`.
- Acessos a APIs externas/globais: `Hilo.event`, `dragonBones.HiloFactory`, `dragonBones.HiloFactory.factory`.

### `Hilo/Demos/src/SetBoneOffset.ts`

- Contexto isolado: `Hilo/Demos/tsconfig.json`.
- Arquivos autorais resolvidos: `Hilo/Demos/src/BaseTest.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: `EventObject`, `HiloArmatureDisplay`, `dragonBones`.
- Acessos a APIs externas/globais: `Math.PI`, `Math.atan2`, `Math.random`, `Math.sqrt`, `dragonBones.EventObject`, `dragonBones.EventObject.COMPLETE`, `dragonBones.HiloFactory`, `dragonBones.HiloFactory.factory`.

### `Phaser/2.x/src/dragonBones/phaser/PhaserArmatureDisplay.ts`

- Contexto isolado: `Phaser/2.x/tsconfig.json`.
- Arquivos autorais resolvidos: `DragonBones/src/dragonBones/animation/Animation.ts`, `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/armature/Bone.ts`, `DragonBones/src/dragonBones/armature/IArmatureProxy.ts`, `DragonBones/src/dragonBones/armature/Slot.ts`, `DragonBones/src/dragonBones/armature/TransformObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/event/EventObject.ts`, `DragonBones/src/dragonBones/event/IEventDispatcher.ts`, `DragonBones/src/dragonBones/geom/Matrix.ts`, `DragonBones/src/dragonBones/geom/Transform.ts`, `DragonBones/src/dragonBones/model/ArmatureData.ts`, `DragonBones/src/dragonBones/model/BoundingBoxData.ts`, `Phaser/2.x/src/dragonBones/phaser/PhaserFactory.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: `DisplayObject`, `Graphics`, `PIXI`, `Phaser`, `Signal`, `Sprite`.
- Acessos a APIs externas/globais: `Phaser.Graphics`, `Phaser.Signal`, `Phaser.Sprite`.

### `Phaser/2.x/src/dragonBones/phaser/PhaserFactory.ts`

- Contexto isolado: `Phaser/2.x/tsconfig.json`.
- Arquivos autorais resolvidos: `DragonBones/src/dragonBones/animation/WorldClock.ts`, `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/armature/Slot.ts`, `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/factory/BaseFactory.ts`, `DragonBones/src/dragonBones/model/ArmatureData.ts`, `DragonBones/src/dragonBones/parser/DataParser.ts`, `Phaser/2.x/src/dragonBones/phaser/PhaserArmatureDisplay.ts`, `Phaser/2.x/src/dragonBones/phaser/PhaserSlot.ts`, `Phaser/2.x/src/dragonBones/phaser/PhaserSlotDisplay.ts`, `Phaser/2.x/src/dragonBones/phaser/PhaserTextureAtlasData.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: `BaseTexture`, `Game`, `PIXI`, `Phaser`, `Sprite`.
- Acessos a APIs externas/globais: `Phaser.Cache`, `Phaser.Cache.DEFAULT`, `Phaser.Sprite`, `console.warn`.

### `Phaser/2.x/src/dragonBones/phaser/PhaserSlot.ts`

- Contexto isolado: `Phaser/2.x/tsconfig.json`.
- Arquivos autorais resolvidos: `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/armature/Bone.ts`, `DragonBones/src/dragonBones/armature/Slot.ts`, `DragonBones/src/dragonBones/armature/TransformObject.ts`, `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/geom/ColorTransform.ts`, `DragonBones/src/dragonBones/geom/Matrix.ts`, `DragonBones/src/dragonBones/geom/Transform.ts`, `DragonBones/src/dragonBones/model/ArmatureData.ts`, `DragonBones/src/dragonBones/model/TextureAtlasData.ts`, `Phaser/2.x/src/dragonBones/phaser/PhaserArmatureDisplay.ts`, `Phaser/2.x/src/dragonBones/phaser/PhaserSlotDisplay.ts`, `Phaser/2.x/src/dragonBones/phaser/PhaserTextureAtlasData.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: `DisplayObject`, `PIXI`, `Phaser`, `Sprite`.
- Acessos a APIs externas/globais: `Math.round`, `PIXI.Sprite`, `PIXI.blendModes`, `PIXI.blendModes.ADD`, `PIXI.blendModes.DARKEN`, `PIXI.blendModes.DIFFERENCE`, `PIXI.blendModes.HARD_LIGHT`, `PIXI.blendModes.LIGHTEN`, `PIXI.blendModes.MULTIPLY`, `PIXI.blendModes.NORMAL`, `PIXI.blendModes.OVERLAY`, `PIXI.blendModes.SCREEN`.

### `Phaser/2.x/src/dragonBones/phaser/PhaserSlotDisplay.ts`

- Contexto isolado: `Phaser/2.x/tsconfig.json`.
- Arquivos autorais resolvidos: `DragonBones/src/dragonBones/geom/Transform.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: `DisplayObjectContainer`, `PIXI`, `Phaser`.
- Acessos a APIs externas/globais: `Math.acos`, `Math.cos`, `Math.sin`, `Math.sqrt`, `Phaser.Image`, `Phaser.Math`, `Phaser.Math.HALF_PI`, `Phaser.Math.PI2`.

### `Phaser/2.x/src/dragonBones/phaser/PhaserTextureAtlasData.ts`

- Contexto isolado: `Phaser/2.x/tsconfig.json`.
- Arquivos autorais resolvidos: `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/geom/Rectangle.ts`, `DragonBones/src/dragonBones/model/TextureAtlasData.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: `BaseTexture`, `PIXI`, `Rectangle`, `Texture`.
- Acessos a APIs externas/globais: `PIXI.Rectangle`, `PIXI.Texture`.

### `Phaser/3.x/src/dragonBones/phaser/Factory.ts`

- Contexto isolado: `Phaser/3.x/tsconfig.json`.
- Arquivos autorais resolvidos: `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/armature/Slot.ts`, `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/factory/BaseFactory.ts`, `DragonBones/src/dragonBones/model/ArmatureData.ts`, `DragonBones/src/dragonBones/model/DragonBonesData.ts`, `DragonBones/src/dragonBones/model/TextureAtlasData.ts`, `DragonBones/src/dragonBones/parser/DataParser.ts`, `Phaser/3.x/src/dragonBones/phaser/display/ArmatureDisplay.ts`, `Phaser/3.x/src/dragonBones/phaser/display/Slot.ts`, `Phaser/3.x/src/dragonBones/phaser/display/TextureAtlasData.ts`.
- Declarações externas/distribuídas: `Phaser/3.x/types/phaser.d.ts`.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: nenhuma.

### `Phaser/3.x/src/dragonBones/phaser/display/ArmatureDisplay.ts`

- Contexto isolado: `Phaser/3.x/tsconfig.json`.
- Arquivos autorais resolvidos: `DragonBones/src/dragonBones/animation/Animation.ts`, `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/armature/IArmatureProxy.ts`, `DragonBones/src/dragonBones/armature/Slot.ts`, `DragonBones/src/dragonBones/event/EventObject.ts`, `DragonBones/src/dragonBones/event/IEventDispatcher.ts`, `DragonBones/src/dragonBones/geom/Rectangle.ts`, `DragonBones/src/dragonBones/model/TextureAtlasData.ts`, `Phaser/3.x/src/dragonBones/phaser/display/DisplayContainer.ts`, `Phaser/3.x/src/dragonBones/phaser/display/SlotMesh.ts`.
- Declarações externas/distribuídas: `Phaser/3.x/types/phaser.d.ts`.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `Phaser.Geom`, `Phaser.Geom.Rectangle`, `Phaser.Geom.Rectangle.Union`.

### `Phaser/3.x/src/dragonBones/phaser/display/DisplayContainer.ts`

- Contexto isolado: `Phaser/3.x/tsconfig.json`.
- Arquivos autorais resolvidos: `Phaser/3.x/src/dragonBones/phaser/util/TransformMatrix.ts`.
- Declarações externas/distribuídas: `Phaser/3.x/types/phaser.d.ts`.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `Phaser.GameObjects`, `Phaser.GameObjects.Container`, `Phaser.Math`, `Phaser.Math.Vector2`.

### `Phaser/3.x/src/dragonBones/phaser/display/Slot.ts`

- Contexto isolado: `Phaser/3.x/tsconfig.json`.
- Arquivos autorais resolvidos: `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/armature/Bone.ts`, `DragonBones/src/dragonBones/armature/Slot.ts`, `DragonBones/src/dragonBones/armature/Surface.ts`, `DragonBones/src/dragonBones/armature/TransformObject.ts`, `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/geom/ColorTransform.ts`, `DragonBones/src/dragonBones/geom/Matrix.ts`, `DragonBones/src/dragonBones/geom/Rectangle.ts`, `DragonBones/src/dragonBones/geom/Transform.ts`, `DragonBones/src/dragonBones/model/ArmatureData.ts`, `DragonBones/src/dragonBones/model/DisplayData.ts`, `DragonBones/src/dragonBones/model/DragonBonesData.ts`, `DragonBones/src/dragonBones/model/TextureAtlasData.ts`, `Phaser/3.x/src/dragonBones/phaser/display/DisplayContainer.ts`, `Phaser/3.x/src/dragonBones/phaser/display/SlotImage.ts`, `Phaser/3.x/src/dragonBones/phaser/display/SlotMesh.ts`, `Phaser/3.x/src/dragonBones/phaser/display/SlotSprite.ts`, `Phaser/3.x/src/dragonBones/phaser/display/TextureAtlasData.ts`.
- Declarações externas/distribuídas: `Phaser/3.x/types/phaser.d.ts`.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `Phaser.BlendModes`, `Phaser.BlendModes.ADD`, `Phaser.BlendModes.DARKEN`, `Phaser.BlendModes.DIFFERENCE`, `Phaser.BlendModes.HARD_LIGHT`, `Phaser.BlendModes.LIGHTEN`, `Phaser.BlendModes.MULTIPLY`, `Phaser.BlendModes.NORMAL`, `Phaser.BlendModes.OVERLAY`, `Phaser.BlendModes.SCREEN`, `console.warn`.

### `Phaser/3.x/src/dragonBones/phaser/display/SlotImage.ts`

- Contexto isolado: `Phaser/3.x/tsconfig.json`.
- Arquivos autorais resolvidos: `Phaser/3.x/src/dragonBones/phaser/util/SkewComponent.ts`.
- Declarações externas/distribuídas: `Phaser/3.x/types/phaser.d.ts`.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `Phaser.GameObjects`, `Phaser.GameObjects.Image`.

### `Phaser/3.x/src/dragonBones/phaser/display/SlotMesh.ts`

- Contexto isolado: `Phaser/3.x/tsconfig.json`.
- Arquivos autorais resolvidos: `Phaser/3.x/src/dragonBones/phaser/util/SkewComponent.ts`.
- Declarações externas/distribuídas: `Phaser/3.x/types/phaser.d.ts`.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `Phaser.GameObjects`, `Phaser.GameObjects.Mesh`.

### `Phaser/3.x/src/dragonBones/phaser/display/SlotSprite.ts`

- Contexto isolado: `Phaser/3.x/tsconfig.json`.
- Arquivos autorais resolvidos: `Phaser/3.x/src/dragonBones/phaser/util/SkewComponent.ts`.
- Declarações externas/distribuídas: `Phaser/3.x/types/phaser.d.ts`.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `Phaser.GameObjects`, `Phaser.GameObjects.Sprite`.

### `Phaser/3.x/src/dragonBones/phaser/display/TextureAtlasData.ts`

- Contexto isolado: `Phaser/3.x/tsconfig.json`.
- Arquivos autorais resolvidos: `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/geom/Rectangle.ts`, `DragonBones/src/dragonBones/model/TextureAtlasData.ts`.
- Declarações externas/distribuídas: `Phaser/3.x/types/phaser.d.ts`.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: nenhuma.

### `Phaser/3.x/src/dragonBones/phaser/pipeline/TextureTintPipeline.ts`

- Contexto isolado: `Phaser/3.x/tsconfig.json`.
- Arquivos autorais resolvidos: `Phaser/3.x/src/dragonBones/phaser/util/TransformMatrix.ts`.
- Declarações externas/distribuídas: `Phaser/3.x/types/phaser.d.ts`.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `Phaser.Renderer`, `Phaser.Renderer.WebGL`, `Phaser.Renderer.WebGL.Pipelines`, `Phaser.Renderer.WebGL.Pipelines.TextureTintPipeline`, `Phaser.Renderer.WebGL.Utils`, `Phaser.Renderer.WebGL.Utils.getTintAppendFloatAlpha`.

### `Phaser/3.x/src/dragonBones/phaser/plugin/DragonBonesFile.ts`

- Contexto isolado: `Phaser/3.x/tsconfig.json`.
- Arquivos autorais resolvidos: `Phaser/3.x/src/dragonBones/phaser/plugin/FileTypes.ts`.
- Declarações externas/distribuídas: `Phaser/3.x/types/phaser-plugin.d.ts`, `Phaser/3.x/types/phaser.d.ts`.
- Nomes sem resolução estática: `XHRSettingsObject`.
- Acessos a APIs externas/globais: `Phaser.Loader`, `Phaser.Loader.MultiFile`, `Phaser.Utils`, `Phaser.Utils.Objects`, `Phaser.Utils.Objects.GetFastValue`, `Phaser.Utils.Objects.IsPlainObject`.

### `Phaser/3.x/src/dragonBones/phaser/plugin/DragonBonesPlugin.ts`

- Contexto isolado: `Phaser/3.x/tsconfig.json`.
- Arquivos autorais resolvidos: `DragonBones/src/dragonBones/animation/WorldClock.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/model/DragonBonesData.ts`, `Phaser/3.x/src/dragonBones/phaser/Factory.ts`, `Phaser/3.x/src/dragonBones/phaser/display/ArmatureDisplay.ts`, `Phaser/3.x/src/dragonBones/phaser/display/SlotImage.ts`, `Phaser/3.x/src/dragonBones/phaser/display/SlotMesh.ts`, `Phaser/3.x/src/dragonBones/phaser/display/SlotSprite.ts`, `Phaser/3.x/src/dragonBones/phaser/pipeline/TextureTintPipeline.ts`, `Phaser/3.x/src/dragonBones/phaser/plugin/DragonBonesFile.ts`, `Phaser/3.x/src/dragonBones/phaser/util/EventDispatcher.ts`.
- Declarações externas/distribuídas: `Phaser/3.x/types/phaser.d.ts`.
- Nomes sem resolução estática: `XHRSettingsObject`.
- Acessos a APIs externas/globais: `Phaser.Plugins`, `Phaser.Plugins.ScenePlugin`, `Phaser.WEBGL`.

### `Phaser/3.x/src/dragonBones/phaser/plugin/FileTypes.ts`

- Contexto isolado: `Phaser/3.x/tsconfig.json`.
- Arquivos autorais resolvidos: nenhuma.
- Declarações externas/distribuídas: `Phaser/3.x/types/phaser.d.ts`.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `Phaser.Loader`, `Phaser.Loader.FileTypes`, `Phaser.Loader.FileTypes.BinaryFile`, `Phaser.Loader.FileTypes.ImageFile`, `Phaser.Loader.FileTypes.JSONFile`.

### `Phaser/3.x/src/dragonBones/phaser/util/EventDispatcher.ts`

- Contexto isolado: `Phaser/3.x/tsconfig.json`.
- Arquivos autorais resolvidos: `DragonBones/src/dragonBones/event/EventObject.ts`, `DragonBones/src/dragonBones/event/IEventDispatcher.ts`.
- Declarações externas/distribuídas: `Phaser/3.x/types/phaser.d.ts`.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `Phaser.Events`, `Phaser.Events.EventEmitter`.

### `Phaser/3.x/src/dragonBones/phaser/util/SkewComponent.ts`

- Contexto isolado: `Phaser/3.x/tsconfig.json`.
- Arquivos autorais resolvidos: nenhuma.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `Object.defineProperty`.

### `Phaser/3.x/src/dragonBones/phaser/util/TransformMatrix.ts`

- Contexto isolado: `Phaser/3.x/tsconfig.json`.
- Arquivos autorais resolvidos: nenhuma.
- Declarações externas/distribuídas: `Phaser/3.x/types/phaser.d.ts`.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `Math.PI`, `Math.abs`, `Math.atan2`, `Math.cos`, `Math.sin`, `Math.sqrt`, `Phaser.GameObjects`, `Phaser.GameObjects.Components`, `Phaser.GameObjects.Components.TransformMatrix`, `Phaser.Math`, `Phaser.Math.PI2`.

### `Phaser/Demos/src/AnimationBase.ts`

- Contexto isolado: `Phaser/Demos/tsconfig.json`.
- Arquivos autorais resolvidos: `Phaser/Demos/src/BaseDemo.ts`.
- Declarações externas/distribuídas: `Phaser/Demos/libs/dragonBones/dragonBones.d.ts`, `Phaser/Demos/libs/dragonBones/phaser-plugin.d.ts`, `Phaser/Demos/libs/phaser/phaser.d.ts`.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `Phaser.Math`, `Phaser.Math.Clamp`, `console.log`, `dragonBones.EventObject`, `dragonBones.EventObject.COMPLETE`, `dragonBones.EventObject.FADE_IN`, `dragonBones.EventObject.FADE_IN_COMPLETE`, `dragonBones.EventObject.FADE_OUT`, `dragonBones.EventObject.FADE_OUT_COMPLETE`, `dragonBones.EventObject.FRAME_EVENT`, `dragonBones.EventObject.LOOP_COMPLETE`, `dragonBones.EventObject.START`.

### `Phaser/Demos/src/AnimationLayer.ts`

- Contexto isolado: `Phaser/Demos/tsconfig.json`.
- Arquivos autorais resolvidos: `Phaser/Demos/src/BaseDemo.ts`.
- Declarações externas/distribuídas: `Phaser/Demos/libs/dragonBones/dragonBones.d.ts`, `Phaser/Demos/libs/dragonBones/phaser-plugin.d.ts`, `Phaser/Demos/libs/phaser/phaser.d.ts`.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `dragonBones.EventObject`, `dragonBones.EventObject.LOOP_COMPLETE`.

### `Phaser/Demos/src/BaseDemo.ts`

- Contexto isolado: `Phaser/Demos/tsconfig.json`.
- Arquivos autorais resolvidos: nenhuma.
- Declarações externas/distribuídas: `Phaser/Demos/libs/phaser/phaser.d.ts`.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `Phaser.Scene`.

### `Phaser/Demos/src/BoneOffset.ts`

- Contexto isolado: `Phaser/Demos/tsconfig.json`.
- Arquivos autorais resolvidos: `Phaser/Demos/src/BaseDemo.ts`.
- Declarações externas/distribuídas: `Phaser/Demos/libs/dragonBones/dragonBones.d.ts`, `Phaser/Demos/libs/dragonBones/phaser-plugin.d.ts`, `Phaser/Demos/libs/phaser/phaser.d.ts`.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `Math.PI`, `Math.atan2`, `Math.random`, `Math.sqrt`, `dragonBones.EventObject`, `dragonBones.EventObject.COMPLETE`.

### `Phaser/Demos/src/BoundingBox.ts`

- Contexto isolado: `Phaser/Demos/tsconfig.json`.
- Arquivos autorais resolvidos: `Phaser/Demos/src/BaseDemo.ts`, `Phaser/Demos/src/DragHelper.ts`.
- Declarações externas/distribuídas: `Phaser/Demos/libs/dragonBones/dragonBones.d.ts`, `Phaser/Demos/libs/dragonBones/phaser-plugin.d.ts`, `Phaser/Demos/libs/phaser/phaser.d.ts`.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `Math.atan2`, `Math.sqrt`, `Phaser.GameObjects`, `Phaser.GameObjects.Components`, `Phaser.GameObjects.Components.TransformMatrix`, `Phaser.Math`, `Phaser.Math.Vector2`, `console.log`, `dragonBones.OffsetMode`, `dragonBones.OffsetMode.Override`.

### `Phaser/Demos/src/CoreElement.ts`

- Contexto isolado: `Phaser/Demos/tsconfig.json`.
- Arquivos autorais resolvidos: `Phaser/Demos/src/BaseDemo.ts`.
- Declarações externas/distribuídas: `Phaser/Demos/libs/dragonBones/dragonBones.d.ts`, `Phaser/Demos/libs/dragonBones/phaser-plugin.d.ts`, `Phaser/Demos/libs/phaser/phaser.d.ts`.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `Math.PI`, `Math.abs`, `Math.atan2`, `Math.cos`, `Math.random`, `Math.sin`, `Phaser.GameObjects`, `Phaser.GameObjects.Components`, `Phaser.GameObjects.Components.TransformMatrix`, `Phaser.Math`, `Phaser.Math.Vector2`, `document.addEventListener`, `dragonBones.EventObject`, `dragonBones.EventObject.COMPLETE`, `dragonBones.EventObject.FADE_IN_COMPLETE`, `dragonBones.EventObject.FADE_OUT_COMPLETE`, `dragonBones.EventObject.FRAME_EVENT`.

### `Phaser/Demos/src/DragHelper.ts`

- Contexto isolado: `Phaser/Demos/tsconfig.json`.
- Arquivos autorais resolvidos: nenhuma.
- Declarações externas/distribuídas: `Phaser/Demos/libs/dragonBones/dragonBones.d.ts`, `Phaser/Demos/libs/phaser/phaser.d.ts`.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `Phaser.Math`, `Phaser.Math.Vector2`, `dragonBones.OffsetMode`, `dragonBones.OffsetMode.Override`.

### `Phaser/Demos/src/DragonBonesEvent.ts`

- Contexto isolado: `Phaser/Demos/tsconfig.json`.
- Arquivos autorais resolvidos: `Phaser/Demos/src/BaseDemo.ts`.
- Declarações externas/distribuídas: `Phaser/Demos/libs/dragonBones/dragonBones.d.ts`, `Phaser/Demos/libs/dragonBones/phaser-plugin.d.ts`, `Phaser/Demos/libs/phaser/phaser.d.ts`.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `dragonBones.EventObject`, `dragonBones.EventObject.COMPLETE`.

### `Phaser/Demos/src/HelloDragonBones.ts`

- Contexto isolado: `Phaser/Demos/tsconfig.json`.
- Arquivos autorais resolvidos: `Phaser/Demos/src/BaseDemo.ts`.
- Declarações externas/distribuídas: `Phaser/Demos/libs/dragonBones/dragonBones.d.ts`, `Phaser/Demos/libs/dragonBones/phaser-plugin.d.ts`, `Phaser/Demos/libs/phaser/phaser.d.ts`.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: nenhuma.

### `Phaser/Demos/src/InverseKinematics.ts`

- Contexto isolado: `Phaser/Demos/tsconfig.json`.
- Arquivos autorais resolvidos: `Phaser/Demos/src/BaseDemo.ts`, `Phaser/Demos/src/DragHelper.ts`.
- Declarações externas/distribuídas: `Phaser/Demos/libs/dragonBones/dragonBones.d.ts`, `Phaser/Demos/libs/dragonBones/phaser-plugin.d.ts`, `Phaser/Demos/libs/phaser/phaser.d.ts`.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `Math.PI`, `Math.abs`, `Math.atan2`, `Math.max`, `Math.min`, `Math.sin`, `Math.tan`, `Phaser.Math`, `Phaser.Math.Vector2`, `dragonBones.Transform`, `dragonBones.Transform.DEG_RAD`, `dragonBones.Transform.normalizeRadian`.

### `Phaser/Demos/src/PerformanceTest.ts`

- Contexto isolado: `Phaser/Demos/tsconfig.json`.
- Arquivos autorais resolvidos: `Phaser/Demos/src/BaseDemo.ts`.
- Declarações externas/distribuídas: `Phaser/Demos/libs/dragonBones/dragonBones.d.ts`, `Phaser/Demos/libs/dragonBones/phaser-plugin.d.ts`, `Phaser/Demos/libs/phaser/phaser.d.ts`.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `Math.ceil`, `Math.floor`, `dragonBones.BaseObject`, `dragonBones.BaseObject.clearPool`.

### `Phaser/Demos/src/ReplaceAnimation.ts`

- Contexto isolado: `Phaser/Demos/tsconfig.json`.
- Arquivos autorais resolvidos: `Phaser/Demos/src/BaseDemo.ts`.
- Declarações externas/distribuídas: `Phaser/Demos/libs/dragonBones/dragonBones.d.ts`, `Phaser/Demos/libs/dragonBones/phaser-plugin.d.ts`, `Phaser/Demos/libs/phaser/phaser.d.ts`.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: nenhuma.

### `Phaser/Demos/src/ReplaceSlotDisplay.ts`

- Contexto isolado: `Phaser/Demos/tsconfig.json`.
- Arquivos autorais resolvidos: `Phaser/Demos/src/BaseDemo.ts`.
- Declarações externas/distribuídas: `Phaser/Demos/libs/dragonBones/dragonBones.d.ts`, `Phaser/Demos/libs/dragonBones/phaser-plugin.d.ts`, `Phaser/Demos/libs/phaser/phaser.d.ts`.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `Phaser.GameObjects`, `Phaser.GameObjects.Text`, `dragonBones.phaser`, `dragonBones.phaser.util`, `dragonBones.phaser.util.extendSkew`.

### `Pixi/4.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`

- Contexto isolado: `Pixi/4.x/tsconfig.json`.
- Arquivos autorais resolvidos: `DragonBones/src/dragonBones/animation/Animation.ts`, `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/armature/Bone.ts`, `DragonBones/src/dragonBones/armature/IArmatureProxy.ts`, `DragonBones/src/dragonBones/armature/Slot.ts`, `DragonBones/src/dragonBones/armature/TransformObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/event/EventObject.ts`, `DragonBones/src/dragonBones/event/IEventDispatcher.ts`, `DragonBones/src/dragonBones/geom/Matrix.ts`, `DragonBones/src/dragonBones/geom/Transform.ts`, `DragonBones/src/dragonBones/model/ArmatureData.ts`, `DragonBones/src/dragonBones/model/BoundingBoxData.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: `Graphics`, `PIXI`, `Sprite`.
- Acessos a APIs externas/globais: `PIXI.Graphics`, `PIXI.Sprite`.

### `Pixi/4.x/src/dragonBones/pixi/PixiFactory.ts`

- Contexto isolado: `Pixi/4.x/tsconfig.json`.
- Arquivos autorais resolvidos: `DragonBones/src/dragonBones/animation/WorldClock.ts`, `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/armature/Slot.ts`, `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/factory/BaseFactory.ts`, `DragonBones/src/dragonBones/model/ArmatureData.ts`, `DragonBones/src/dragonBones/parser/DataParser.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiSlot.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiTextureAtlasData.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: `BaseTexture`, `PIXI`, `Sprite`.
- Acessos a APIs externas/globais: `PIXI.Sprite`, `PIXI.mesh`, `PIXI.mesh.Mesh`, `PIXI.mesh.Mesh.DRAW_MODES`, `PIXI.mesh.Mesh.DRAW_MODES.TRIANGLES`, `PIXI.ticker`, `PIXI.ticker.shared`, `PIXI.ticker.shared.add`, `PIXI.ticker.shared.elapsedMS`.

### `Pixi/4.x/src/dragonBones/pixi/PixiSlot.ts`

- Contexto isolado: `Pixi/4.x/tsconfig.json`.
- Arquivos autorais resolvidos: `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/armature/Bone.ts`, `DragonBones/src/dragonBones/armature/Slot.ts`, `DragonBones/src/dragonBones/armature/Surface.ts`, `DragonBones/src/dragonBones/armature/TransformObject.ts`, `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/geom/ColorTransform.ts`, `DragonBones/src/dragonBones/geom/Matrix.ts`, `DragonBones/src/dragonBones/geom/Rectangle.ts`, `DragonBones/src/dragonBones/geom/Transform.ts`, `DragonBones/src/dragonBones/model/ArmatureData.ts`, `DragonBones/src/dragonBones/model/DisplayData.ts`, `DragonBones/src/dragonBones/model/DragonBonesData.ts`, `DragonBones/src/dragonBones/model/TextureAtlasData.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/4.x/src/dragonBones/pixi/PixiTextureAtlasData.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: `DisplayObject`, `Mesh`, `PIXI`, `Sprite`, `mesh`.
- Acessos a APIs externas/globais: `Math.round`, `PIXI.BLEND_MODES`, `PIXI.BLEND_MODES.ADD`, `PIXI.BLEND_MODES.DARKEN`, `PIXI.BLEND_MODES.DIFFERENCE`, `PIXI.BLEND_MODES.HARD_LIGHT`, `PIXI.BLEND_MODES.LIGHTEN`, `PIXI.BLEND_MODES.MULTIPLY`, `PIXI.BLEND_MODES.NORMAL`, `PIXI.BLEND_MODES.OVERLAY`, `PIXI.BLEND_MODES.SCREEN`, `PIXI.Sprite`, `PIXI.VERSION`, `PIXI.mesh`, `PIXI.mesh.Mesh`.

### `Pixi/4.x/src/dragonBones/pixi/PixiTextureAtlasData.ts`

- Contexto isolado: `Pixi/4.x/tsconfig.json`.
- Arquivos autorais resolvidos: `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/geom/Rectangle.ts`, `DragonBones/src/dragonBones/model/TextureAtlasData.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: `BaseTexture`, `PIXI`, `Texture`.
- Acessos a APIs externas/globais: `PIXI.Rectangle`, `PIXI.Texture`.

### `Pixi/5.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`

- Contexto isolado: `Pixi/5.x/tsconfig.json`.
- Arquivos autorais resolvidos: `DragonBones/src/dragonBones/animation/Animation.ts`, `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/armature/Bone.ts`, `DragonBones/src/dragonBones/armature/IArmatureProxy.ts`, `DragonBones/src/dragonBones/armature/Slot.ts`, `DragonBones/src/dragonBones/armature/TransformObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/event/EventObject.ts`, `DragonBones/src/dragonBones/event/IEventDispatcher.ts`, `DragonBones/src/dragonBones/geom/Matrix.ts`, `DragonBones/src/dragonBones/geom/Transform.ts`, `DragonBones/src/dragonBones/model/ArmatureData.ts`, `DragonBones/src/dragonBones/model/BoundingBoxData.ts`.
- Declarações externas/distribuídas: `Pixi/5.x/libs/pixi.js-legacy.d.ts`.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `PIXI.Graphics`, `PIXI.Sprite`, `PIXI.Texture`, `PIXI.Texture.EMPTY`.

### `Pixi/5.x/src/dragonBones/pixi/PixiFactory.ts`

- Contexto isolado: `Pixi/5.x/tsconfig.json`.
- Arquivos autorais resolvidos: `DragonBones/src/dragonBones/animation/WorldClock.ts`, `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/armature/Slot.ts`, `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/factory/BaseFactory.ts`, `DragonBones/src/dragonBones/model/ArmatureData.ts`, `DragonBones/src/dragonBones/parser/DataParser.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiSlot.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiTextureAtlasData.ts`.
- Declarações externas/distribuídas: `Pixi/5.x/libs/pixi.js-legacy.d.ts`.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `PIXI.SimpleMesh`, `PIXI.Sprite`, `PIXI.Texture`, `PIXI.Texture.EMPTY`, `PIXI.Ticker`, `PIXI.Ticker.shared`, `PIXI.Ticker.shared.add`, `PIXI.settings`, `PIXI.settings.TARGET_FPMS`.

### `Pixi/5.x/src/dragonBones/pixi/PixiSlot.ts`

- Contexto isolado: `Pixi/5.x/tsconfig.json`.
- Arquivos autorais resolvidos: `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/armature/Bone.ts`, `DragonBones/src/dragonBones/armature/Slot.ts`, `DragonBones/src/dragonBones/armature/Surface.ts`, `DragonBones/src/dragonBones/armature/TransformObject.ts`, `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/geom/ColorTransform.ts`, `DragonBones/src/dragonBones/geom/Matrix.ts`, `DragonBones/src/dragonBones/geom/Transform.ts`, `DragonBones/src/dragonBones/model/ArmatureData.ts`, `DragonBones/src/dragonBones/model/DisplayData.ts`, `DragonBones/src/dragonBones/model/DragonBonesData.ts`, `DragonBones/src/dragonBones/model/TextureAtlasData.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/5.x/src/dragonBones/pixi/PixiTextureAtlasData.ts`.
- Declarações externas/distribuídas: `Pixi/5.x/libs/pixi.js-legacy.d.ts`.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `Math.round`, `PIXI.BLEND_MODES`, `PIXI.BLEND_MODES.ADD`, `PIXI.BLEND_MODES.DARKEN`, `PIXI.BLEND_MODES.DIFFERENCE`, `PIXI.BLEND_MODES.HARD_LIGHT`, `PIXI.BLEND_MODES.LIGHTEN`, `PIXI.BLEND_MODES.MULTIPLY`, `PIXI.BLEND_MODES.NORMAL`, `PIXI.BLEND_MODES.OVERLAY`, `PIXI.BLEND_MODES.SCREEN`, `PIXI.SimpleMesh`, `PIXI.Sprite`, `PIXI.VERSION`.

### `Pixi/5.x/src/dragonBones/pixi/PixiTextureAtlasData.ts`

- Contexto isolado: `Pixi/5.x/tsconfig.json`.
- Arquivos autorais resolvidos: `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/geom/Rectangle.ts`, `DragonBones/src/dragonBones/model/TextureAtlasData.ts`.
- Declarações externas/distribuídas: `Pixi/5.x/libs/pixi.js-legacy.d.ts`.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `PIXI.Rectangle`, `PIXI.Texture`.

### `Pixi/8.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`

- Contexto isolado: `Pixi/8.x/tsconfig.json`.
- Arquivos autorais resolvidos: `DragonBones/src/dragonBones/armature/IArmatureProxy.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`.
- Declarações externas/distribuídas: `Pixi/8.x/libs/dragonBones.d.ts`, `Pixi/8.x/libs/pixi.js.d.ts`.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `BoundingBoxType.Ellipse`, `BoundingBoxType.Polygon`, `BoundingBoxType.Rectangle`, `DragonBones.debugDraw`, `PIXI.Container`, `PIXI.Graphics`.

### `Pixi/8.x/src/dragonBones/pixi/PixiDBBinParser.ts`

- Contexto isolado: `Pixi/8.x/tsconfig.json`.
- Arquivos autorais resolvidos: nenhuma.
- Declarações externas/distribuídas: `Pixi/8.x/libs/pixi.js.d.ts`.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `PIXI.ExtensionType`, `PIXI.ExtensionType.LoadParser`, `PIXI.LoaderParser`.

### `Pixi/8.x/src/dragonBones/pixi/PixiFactory.ts`

- Contexto isolado: `Pixi/8.x/tsconfig.json`.
- Arquivos autorais resolvidos: `Pixi/8.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiDBBinParser.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiSlot.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiTextureAtlasData.ts`.
- Declarações externas/distribuídas: `Pixi/8.x/libs/dragonBones.d.ts`, `Pixi/8.x/libs/pixi.js.d.ts`.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `BaseObject.borrowObject`, `PIXI.Assets`, `PIXI.Assets.loader`, `PIXI.Assets.loader.parsers`, `PIXI.Assets.loader.parsers.push`, `PIXI.MeshSimple`, `PIXI.Sprite`, `PIXI.Texture`, `PIXI.Texture.EMPTY`, `PIXI.Ticker`, `PIXI.Ticker.shared`, `PIXI.Ticker.shared.add`, `PIXI.Ticker.shared.elapsedMS`.

### `Pixi/8.x/src/dragonBones/pixi/PixiSlot.ts`

- Contexto isolado: `Pixi/8.x/tsconfig.json`.
- Arquivos autorais resolvidos: `DragonBones/src/dragonBones/armature/Surface.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiArmatureDisplay.ts`, `Pixi/8.x/src/dragonBones/pixi/PixiTextureAtlasData.ts`.
- Declarações externas/distribuídas: `Pixi/8.x/libs/dragonBones.d.ts`, `Pixi/8.x/libs/pixi.js.d.ts`.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `BaseObject.borrowObject`, `BinaryOffset.GeometryFloatOffset`, `BinaryOffset.GeometryTriangleCount`, `BinaryOffset.GeometryVertexCount`, `BinaryOffset.GeometryVertexIndices`, `BinaryOffset.WeigthBoneIndices`, `BinaryOffset.WeigthFloatOffset`, `BlendMode.Add`, `BlendMode.Darken`, `BlendMode.Difference`, `BlendMode.HardLight`, `BlendMode.Lighten`, `BlendMode.Multiply`, `BlendMode.Normal`, `BlendMode.Overlay`, `BlendMode.Screen`, `BoneType.Bone`, `Math.round`, `PIXI.MeshSimple`, `PIXI.Sprite`, `PIXI.VERSION`.

### `Pixi/8.x/src/dragonBones/pixi/PixiTextureAtlasData.ts`

- Contexto isolado: `Pixi/8.x/tsconfig.json`.
- Arquivos autorais resolvidos: nenhuma.
- Declarações externas/distribuídas: `Pixi/8.x/libs/dragonBones.d.ts`, `Pixi/8.x/libs/pixi.js.d.ts`.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `BaseObject.borrowObject`, `PIXI.Rectangle`, `PIXI.Texture`.

### `Pixi/Demos/4.x/src/AnimationBase.ts`

- Contexto isolado: `Pixi/Demos/4.x/tsconfig.json`.
- Arquivos autorais resolvidos: `Pixi/Demos/4.x/src/BaseDemo.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: `EventObject`, `InteractionEvent`, `PIXI`, `PixiArmatureDisplay`, `dragonBones`, `interaction`.
- Acessos a APIs externas/globais: `Math.max`, `Math.min`, `console.log`, `dragonBones.EventObject`, `dragonBones.EventObject.COMPLETE`, `dragonBones.EventObject.FADE_IN`, `dragonBones.EventObject.FADE_IN_COMPLETE`, `dragonBones.EventObject.FADE_OUT`, `dragonBones.EventObject.FADE_OUT_COMPLETE`, `dragonBones.EventObject.FRAME_EVENT`, `dragonBones.EventObject.LOOP_COMPLETE`, `dragonBones.EventObject.START`, `dragonBones.PixiFactory`, `dragonBones.PixiFactory.factory`.

### `Pixi/Demos/4.x/src/AnimationLayer.ts`

- Contexto isolado: `Pixi/Demos/4.x/tsconfig.json`.
- Arquivos autorais resolvidos: `Pixi/Demos/4.x/src/BaseDemo.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: `EventObject`, `PixiArmatureDisplay`, `dragonBones`.
- Acessos a APIs externas/globais: `dragonBones.EventObject`, `dragonBones.EventObject.LOOP_COMPLETE`, `dragonBones.PixiFactory`, `dragonBones.PixiFactory.factory`.

### `Pixi/Demos/4.x/src/BaseDemo.ts`

- Contexto isolado: `Pixi/Demos/4.x/tsconfig.json`.
- Arquivos autorais resolvidos: nenhuma.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: `Loader`, `Map`, `PIXI`, `Resource`, `Sprite`, `Text`, `dragonBones`, `loaders`.
- Acessos a APIs externas/globais: `PIXI.Container`, `PIXI.Sprite`, `PIXI.Text`, `PIXI.Texture`, `PIXI.Texture.EMPTY`, `PIXI.WebGLRenderer`, `PIXI.loader`, `PIXI.loader.add`, `PIXI.loader.load`, `PIXI.loader.once`, `PIXI.loaders`, `PIXI.loaders.Resource`, `PIXI.loaders.Resource.LOAD_TYPE`, `PIXI.loaders.Resource.LOAD_TYPE.XHR`, `PIXI.loaders.Resource.XHR_RESPONSE_TYPE`, `PIXI.loaders.Resource.XHR_RESPONSE_TYPE.BUFFER`, `PIXI.ticker`, `PIXI.ticker.shared`, `PIXI.ticker.shared.add`, `document.body`, `document.body.appendChild`.

### `Pixi/Demos/4.x/src/BoneOffset.ts`

- Contexto isolado: `Pixi/Demos/4.x/tsconfig.json`.
- Arquivos autorais resolvidos: `Pixi/Demos/4.x/src/BaseDemo.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: `EventObject`, `PixiArmatureDisplay`, `dragonBones`.
- Acessos a APIs externas/globais: `Math.PI`, `Math.atan2`, `Math.random`, `Math.sqrt`, `dragonBones.EventObject`, `dragonBones.EventObject.COMPLETE`, `dragonBones.PixiFactory`, `dragonBones.PixiFactory.factory`.

### `Pixi/Demos/4.x/src/BoundingBox.ts`

- Contexto isolado: `Pixi/Demos/4.x/tsconfig.json`.
- Arquivos autorais resolvidos: `Pixi/Demos/4.x/src/BaseDemo.ts`, `Pixi/Demos/4.x/src/DragHelper.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: `Bone`, `PIXI`, `PixiArmatureDisplay`, `Point`, `dragonBones`.
- Acessos a APIs externas/globais: `Math.atan2`, `Math.sqrt`, `PIXI.Point`, `PIXI.ticker`, `PIXI.ticker.shared`, `PIXI.ticker.shared.add`, `dragonBones.OffsetMode`, `dragonBones.OffsetMode.Override`, `dragonBones.PixiFactory`, `dragonBones.PixiFactory.factory`.

### `Pixi/Demos/4.x/src/CoreElement.ts`

- Contexto isolado: `Pixi/Demos/4.x/tsconfig.json`.
- Arquivos autorais resolvidos: `Pixi/Demos/4.x/src/BaseDemo.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: `AnimationState`, `Armature`, `EventObject`, `InteractionEvent`, `PIXI`, `PixiArmatureDisplay`, `Point`, `dragonBones`, `interaction`.
- Acessos a APIs externas/globais: `Math.PI`, `Math.abs`, `Math.atan2`, `Math.cos`, `Math.random`, `Math.sin`, `PIXI.Point`, `PIXI.ticker`, `PIXI.ticker.shared`, `PIXI.ticker.shared.add`, `document.addEventListener`, `dragonBones.EventObject`, `dragonBones.EventObject.COMPLETE`, `dragonBones.EventObject.FADE_IN_COMPLETE`, `dragonBones.EventObject.FADE_OUT_COMPLETE`, `dragonBones.EventObject.FRAME_EVENT`, `dragonBones.PixiFactory`, `dragonBones.PixiFactory.factory`, `dragonBones.PixiFactory.factory.buildArmature`, `dragonBones.PixiFactory.factory.buildArmatureDisplay`, `dragonBones.PixiFactory.factory.getArmatureData`, `dragonBones.PixiFactory.factory.replaceSkin`.

### `Pixi/Demos/4.x/src/DragHelper.ts`

- Contexto isolado: `Pixi/Demos/4.x/tsconfig.json`.
- Arquivos autorais resolvidos: nenhuma.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: `DisplayObject`, `InteractionEvent`, `PIXI`, `PixiArmatureDisplay`, `Point`, `dragonBones`, `interaction`.
- Acessos a APIs externas/globais: `PIXI.Point`, `dragonBones.OffsetMode`, `dragonBones.OffsetMode.Override`.

### `Pixi/Demos/4.x/src/DragonBonesEvent.ts`

- Contexto isolado: `Pixi/Demos/4.x/tsconfig.json`.
- Arquivos autorais resolvidos: `Pixi/Demos/4.x/src/BaseDemo.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: `EventObject`, `PixiArmatureDisplay`, `dragonBones`.
- Acessos a APIs externas/globais: `console.log`, `dragonBones.EventObject`, `dragonBones.EventObject.COMPLETE`, `dragonBones.EventObject.SOUND_EVENT`, `dragonBones.PixiFactory`, `dragonBones.PixiFactory.factory`.

### `Pixi/Demos/4.x/src/EyeTracking.ts`

- Contexto isolado: `Pixi/Demos/4.x/tsconfig.json`.
- Arquivos autorais resolvidos: `Pixi/Demos/4.x/src/BaseDemo.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: `InteractionEvent`, `PIXI`, `PixiArmatureDisplay`, `Point`, `dragonBones`, `interaction`.
- Acessos a APIs externas/globais: `Math.max`, `Math.min`, `Math.sin`, `PIXI.Point`, `PIXI.ticker`, `PIXI.ticker.shared`, `PIXI.ticker.shared.add`, `dragonBones.PixiFactory`, `dragonBones.PixiFactory.factory`.

### `Pixi/Demos/4.x/src/HelloDragonBones.ts`

- Contexto isolado: `Pixi/Demos/4.x/tsconfig.json`.
- Arquivos autorais resolvidos: `Pixi/Demos/4.x/src/BaseDemo.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: `dragonBones`.
- Acessos a APIs externas/globais: `dragonBones.PixiFactory`, `dragonBones.PixiFactory.factory`.

### `Pixi/Demos/4.x/src/InverseKinematics.ts`

- Contexto isolado: `Pixi/Demos/4.x/tsconfig.json`.
- Arquivos autorais resolvidos: `Pixi/Demos/4.x/src/BaseDemo.ts`, `Pixi/Demos/4.x/src/DragHelper.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: `AnimationState`, `Bone`, `InteractionEvent`, `PIXI`, `PixiArmatureDisplay`, `Point`, `dragonBones`, `interaction`.
- Acessos a APIs externas/globais: `Math.PI`, `Math.abs`, `Math.atan2`, `Math.max`, `Math.min`, `Math.sin`, `Math.tan`, `PIXI.Point`, `PIXI.ticker`, `PIXI.ticker.shared`, `PIXI.ticker.shared.add`, `dragonBones.PixiFactory`, `dragonBones.PixiFactory.factory`, `dragonBones.Transform`, `dragonBones.Transform.DEG_RAD`, `dragonBones.Transform.normalizeRadian`.

### `Pixi/Demos/4.x/src/MultiTextureAltas.ts`

- Contexto isolado: `Pixi/Demos/4.x/tsconfig.json`.
- Arquivos autorais resolvidos: `Pixi/Demos/4.x/src/BaseDemo.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: `InteractionEvent`, `PIXI`, `PixiArmatureDisplay`, `dragonBones`, `interaction`.
- Acessos a APIs externas/globais: `dragonBones.PixiFactory`, `dragonBones.PixiFactory.factory`.

### `Pixi/Demos/4.x/src/PerformanceTest.ts`

- Contexto isolado: `Pixi/Demos/4.x/tsconfig.json`.
- Arquivos autorais resolvidos: `Pixi/Demos/4.x/src/BaseDemo.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: `InteractionEvent`, `PIXI`, `PixiArmatureDisplay`, `Text`, `dragonBones`, `interaction`.
- Acessos a APIs externas/globais: `Math.ceil`, `Math.floor`, `PIXI.ticker`, `PIXI.ticker.shared`, `PIXI.ticker.shared.add`, `dragonBones.BaseObject`, `dragonBones.BaseObject.clearPool`, `dragonBones.PixiFactory`, `dragonBones.PixiFactory.factory`, `dragonBones.PixiFactory.factory.buildArmatureDisplay`, `dragonBones.PixiFactory.factory.clear`.

### `Pixi/Demos/4.x/src/ReplaceAnimation.ts`

- Contexto isolado: `Pixi/Demos/4.x/tsconfig.json`.
- Arquivos autorais resolvidos: `Pixi/Demos/4.x/src/BaseDemo.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: `PixiArmatureDisplay`, `dragonBones`.
- Acessos a APIs externas/globais: `dragonBones.PixiFactory`, `dragonBones.PixiFactory.factory`.

### `Pixi/Demos/4.x/src/ReplaceSkin.ts`

- Contexto isolado: `Pixi/Demos/4.x/tsconfig.json`.
- Arquivos autorais resolvidos: `Pixi/Demos/4.x/src/BaseDemo.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: `EventObject`, `PixiArmatureDisplay`, `PixiFactory`, `dragonBones`.
- Acessos a APIs externas/globais: `Math.floor`, `Math.random`, `dragonBones.EventObject`, `dragonBones.EventObject.LOOP_COMPLETE`, `dragonBones.PixiFactory`, `dragonBones.PixiFactory.factory`.

### `Pixi/Demos/4.x/src/ReplaceSlotDisplay.ts`

- Contexto isolado: `Pixi/Demos/4.x/tsconfig.json`.
- Arquivos autorais resolvidos: `Pixi/Demos/4.x/src/BaseDemo.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: `InteractionEvent`, `PIXI`, `PixiArmatureDisplay`, `PixiFactory`, `Text`, `dragonBones`, `interaction`.
- Acessos a APIs externas/globais: `PIXI.Text`, `dragonBones.PixiFactory`, `dragonBones.PixiFactory.factory`.

### `Pixi/Demos/8.x/src/AnimationBase.ts`

- Contexto isolado: `Pixi/Demos/8.x/tsconfig.json`.
- Arquivos autorais resolvidos: `Pixi/Demos/8.x/src/BaseDemo.ts`.
- Declarações externas/distribuídas: `Pixi/Demos/8.x/libs/dragonBones/dragonBones.d.ts`.
- Nomes sem resolução estática: `FederatedPointerEvent`, `PIXI`.
- Acessos a APIs externas/globais: `Math.max`, `Math.min`, `console.log`, `dragonBones.EventObject`, `dragonBones.EventObject.COMPLETE`, `dragonBones.EventObject.FADE_IN`, `dragonBones.EventObject.FADE_IN_COMPLETE`, `dragonBones.EventObject.FADE_OUT`, `dragonBones.EventObject.FADE_OUT_COMPLETE`, `dragonBones.EventObject.FRAME_EVENT`, `dragonBones.EventObject.LOOP_COMPLETE`, `dragonBones.EventObject.START`, `dragonBones.PixiFactory`, `dragonBones.PixiFactory.factory`.

### `Pixi/Demos/8.x/src/AnimationLayer.ts`

- Contexto isolado: `Pixi/Demos/8.x/tsconfig.json`.
- Arquivos autorais resolvidos: `Pixi/Demos/8.x/src/BaseDemo.ts`.
- Declarações externas/distribuídas: `Pixi/Demos/8.x/libs/dragonBones/dragonBones.d.ts`.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `dragonBones.EventObject`, `dragonBones.EventObject.LOOP_COMPLETE`, `dragonBones.PixiFactory`, `dragonBones.PixiFactory.factory`.

### `Pixi/Demos/8.x/src/BaseDemo.ts`

- Contexto isolado: `Pixi/Demos/8.x/tsconfig.json`.
- Arquivos autorais resolvidos: nenhuma.
- Declarações externas/distribuídas: `Pixi/Demos/8.x/libs/dragonBones/dragonBones.d.ts`.
- Nomes sem resolução estática: `Application`, `Container`, `PIXI`, `Resource`, `Sprite`, `Text`, `loaders`.
- Acessos a APIs externas/globais: `PIXI.Application`, `PIXI.Assets`, `PIXI.Assets.init`, `PIXI.Assets.loadBundle`, `PIXI.Container`, `PIXI.Sprite`, `PIXI.Text`, `PIXI.Texture`, `PIXI.Texture.EMPTY`, `PIXI.sayHello`, `document.body`, `document.body.appendChild`, `dragonBones.PixiFactory`, `dragonBones.PixiFactory.factory`.

### `Pixi/Demos/8.x/src/BoneOffset.ts`

- Contexto isolado: `Pixi/Demos/8.x/tsconfig.json`.
- Arquivos autorais resolvidos: `Pixi/Demos/8.x/src/BaseDemo.ts`.
- Declarações externas/distribuídas: `Pixi/Demos/8.x/libs/dragonBones/dragonBones.d.ts`.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `Math.PI`, `Math.atan2`, `Math.random`, `Math.sqrt`, `dragonBones.EventObject`, `dragonBones.EventObject.COMPLETE`, `dragonBones.PixiFactory`, `dragonBones.PixiFactory.factory`.

### `Pixi/Demos/8.x/src/BoundingBox.ts`

- Contexto isolado: `Pixi/Demos/8.x/tsconfig.json`.
- Arquivos autorais resolvidos: `Pixi/Demos/8.x/src/BaseDemo.ts`, `Pixi/Demos/8.x/src/DragHelper.ts`.
- Declarações externas/distribuídas: `Pixi/Demos/8.x/libs/dragonBones/dragonBones.d.ts`.
- Nomes sem resolução estática: `PIXI`, `Point`.
- Acessos a APIs externas/globais: `Math.atan2`, `Math.sqrt`, `PIXI.Point`, `PIXI.Ticker`, `PIXI.Ticker.shared`, `PIXI.Ticker.shared.add`, `dragonBones.PixiFactory`, `dragonBones.PixiFactory.factory`.

### `Pixi/Demos/8.x/src/CoreElement.ts`

- Contexto isolado: `Pixi/Demos/8.x/tsconfig.json`.
- Arquivos autorais resolvidos: `Pixi/Demos/8.x/src/BaseDemo.ts`.
- Declarações externas/distribuídas: `Pixi/Demos/8.x/libs/dragonBones/dragonBones.d.ts`.
- Nomes sem resolução estática: `InteractionEvent`, `PIXI`, `Point`, `interaction`.
- Acessos a APIs externas/globais: `Math.PI`, `Math.abs`, `Math.atan2`, `Math.cos`, `Math.random`, `Math.sin`, `PIXI.Point`, `PIXI.Ticker`, `PIXI.Ticker.shared`, `PIXI.Ticker.shared.add`, `document.addEventListener`, `dragonBones.EventObject`, `dragonBones.EventObject.COMPLETE`, `dragonBones.EventObject.FADE_IN_COMPLETE`, `dragonBones.EventObject.FADE_OUT_COMPLETE`, `dragonBones.EventObject.FRAME_EVENT`, `dragonBones.PixiFactory`, `dragonBones.PixiFactory.factory`, `dragonBones.PixiFactory.factory.buildArmature`, `dragonBones.PixiFactory.factory.buildArmatureDisplay`, `dragonBones.PixiFactory.factory.getArmatureData`, `dragonBones.PixiFactory.factory.replaceSkin`.

### `Pixi/Demos/8.x/src/DebugDragonBones.ts`

- Contexto isolado: `Pixi/Demos/8.x/tsconfig.json`.
- Arquivos autorais resolvidos: `Pixi/Demos/8.x/src/BaseDemo.ts`.
- Declarações externas/distribuídas: `Pixi/Demos/8.x/libs/dragonBones/dragonBones.d.ts`.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `dragonBones.PixiFactory`, `dragonBones.PixiFactory.factory`.

### `Pixi/Demos/8.x/src/DragHelper.ts`

- Contexto isolado: `Pixi/Demos/8.x/tsconfig.json`.
- Arquivos autorais resolvidos: nenhuma.
- Declarações externas/distribuídas: `Pixi/Demos/8.x/libs/dragonBones/dragonBones.d.ts`.
- Nomes sem resolução estática: `DisplayObject`, `InteractionEvent`, `PIXI`, `Point`, `interaction`.
- Acessos a APIs externas/globais: `PIXI.Point`.

### `Pixi/Demos/8.x/src/DragonBonesEvent.ts`

- Contexto isolado: `Pixi/Demos/8.x/tsconfig.json`.
- Arquivos autorais resolvidos: `Pixi/Demos/8.x/src/BaseDemo.ts`.
- Declarações externas/distribuídas: `Pixi/Demos/8.x/libs/dragonBones/dragonBones.d.ts`.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `console.log`, `dragonBones.EventObject`, `dragonBones.EventObject.COMPLETE`, `dragonBones.EventObject.SOUND_EVENT`, `dragonBones.PixiFactory`, `dragonBones.PixiFactory.factory`.

### `Pixi/Demos/8.x/src/EyeTracking.ts`

- Contexto isolado: `Pixi/Demos/8.x/tsconfig.json`.
- Arquivos autorais resolvidos: `Pixi/Demos/8.x/src/BaseDemo.ts`.
- Declarações externas/distribuídas: `Pixi/Demos/8.x/libs/dragonBones/dragonBones.d.ts`.
- Nomes sem resolução estática: `InteractionEvent`, `PIXI`, `Point`, `interaction`.
- Acessos a APIs externas/globais: `Math.max`, `Math.min`, `Math.sin`, `PIXI.Point`, `PIXI.Ticker`, `PIXI.Ticker.shared`, `PIXI.Ticker.shared.add`, `dragonBones.PixiFactory`, `dragonBones.PixiFactory.factory`.

### `Pixi/Demos/8.x/src/HelloDragonBones.ts`

- Contexto isolado: `Pixi/Demos/8.x/tsconfig.json`.
- Arquivos autorais resolvidos: `Pixi/Demos/8.x/src/BaseDemo.ts`.
- Declarações externas/distribuídas: `Pixi/Demos/8.x/libs/dragonBones/dragonBones.d.ts`.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `dragonBones.PixiFactory`, `dragonBones.PixiFactory.factory`.

### `Pixi/Demos/8.x/src/InverseKinematics.ts`

- Contexto isolado: `Pixi/Demos/8.x/tsconfig.json`.
- Arquivos autorais resolvidos: `Pixi/Demos/8.x/src/BaseDemo.ts`, `Pixi/Demos/8.x/src/DragHelper.ts`.
- Declarações externas/distribuídas: `Pixi/Demos/8.x/libs/dragonBones/dragonBones.d.ts`.
- Nomes sem resolução estática: `InteractionEvent`, `PIXI`, `Point`, `interaction`.
- Acessos a APIs externas/globais: `Math.PI`, `Math.abs`, `Math.atan2`, `Math.max`, `Math.min`, `Math.sin`, `Math.tan`, `PIXI.Point`, `PIXI.Ticker`, `PIXI.Ticker.shared`, `PIXI.Ticker.shared.add`, `dragonBones.PixiFactory`, `dragonBones.PixiFactory.factory`, `dragonBones.Transform`, `dragonBones.Transform.DEG_RAD`, `dragonBones.Transform.normalizeRadian`.

### `Pixi/Demos/8.x/src/MultiTextureAltas.ts`

- Contexto isolado: `Pixi/Demos/8.x/tsconfig.json`.
- Arquivos autorais resolvidos: `Pixi/Demos/8.x/src/BaseDemo.ts`.
- Declarações externas/distribuídas: `Pixi/Demos/8.x/libs/dragonBones/dragonBones.d.ts`.
- Nomes sem resolução estática: `InteractionEvent`, `PIXI`, `interaction`.
- Acessos a APIs externas/globais: `dragonBones.PixiFactory`, `dragonBones.PixiFactory.factory`.

### `Pixi/Demos/8.x/src/PerformanceTest.ts`

- Contexto isolado: `Pixi/Demos/8.x/tsconfig.json`.
- Arquivos autorais resolvidos: `Pixi/Demos/8.x/src/BaseDemo.ts`.
- Declarações externas/distribuídas: `Pixi/Demos/8.x/libs/dragonBones/dragonBones.d.ts`.
- Nomes sem resolução estática: `InteractionEvent`, `PIXI`, `Text`, `interaction`.
- Acessos a APIs externas/globais: `Math.ceil`, `Math.floor`, `PIXI.Ticker`, `PIXI.Ticker.shared`, `PIXI.Ticker.shared.add`, `dragonBones.BaseObject`, `dragonBones.BaseObject.clearPool`, `dragonBones.PixiFactory`, `dragonBones.PixiFactory.factory`, `dragonBones.PixiFactory.factory.buildArmatureDisplay`, `dragonBones.PixiFactory.factory.clear`.

### `Pixi/Demos/8.x/src/ReplaceAnimation.ts`

- Contexto isolado: `Pixi/Demos/8.x/tsconfig.json`.
- Arquivos autorais resolvidos: `Pixi/Demos/8.x/src/BaseDemo.ts`.
- Declarações externas/distribuídas: `Pixi/Demos/8.x/libs/dragonBones/dragonBones.d.ts`.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `dragonBones.PixiFactory`, `dragonBones.PixiFactory.factory`.

### `Pixi/Demos/8.x/src/ReplaceSkin.ts`

- Contexto isolado: `Pixi/Demos/8.x/tsconfig.json`.
- Arquivos autorais resolvidos: `Pixi/Demos/8.x/src/BaseDemo.ts`.
- Declarações externas/distribuídas: `Pixi/Demos/8.x/libs/dragonBones/dragonBones.d.ts`.
- Nomes sem resolução estática: nenhuma.
- Acessos a APIs externas/globais: `Math.floor`, `Math.random`, `dragonBones.EventObject`, `dragonBones.EventObject.LOOP_COMPLETE`, `dragonBones.PixiFactory`, `dragonBones.PixiFactory.factory`.

### `Pixi/Demos/8.x/src/ReplaceSlotDisplay.ts`

- Contexto isolado: `Pixi/Demos/8.x/tsconfig.json`.
- Arquivos autorais resolvidos: `Pixi/Demos/8.x/src/BaseDemo.ts`.
- Declarações externas/distribuídas: `Pixi/Demos/8.x/libs/dragonBones/dragonBones.d.ts`.
- Nomes sem resolução estática: `InteractionEvent`, `PIXI`, `Text`, `interaction`.
- Acessos a APIs externas/globais: `PIXI.Text`, `dragonBones.PixiFactory`, `dragonBones.PixiFactory.factory`.

### `ThreeJS/Current/src/dragonBones/three/ThreeArmatureDisplay.ts`

- Contexto isolado: `ThreeJS/Current/tsconfig.json`.
- Arquivos autorais resolvidos: `DragonBones/src/dragonBones/animation/Animation.ts`, `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/armature/IArmatureProxy.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/event/EventObject.ts`, `DragonBones/src/dragonBones/event/IEventDispatcher.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: `Group`, `THREE`.
- Acessos a APIs externas/globais: `THREE.Group`.

### `ThreeJS/Current/src/dragonBones/three/ThreeFactory.ts`

- Contexto isolado: `ThreeJS/Current/tsconfig.json`.
- Arquivos autorais resolvidos: `DragonBones/src/dragonBones/animation/WorldClock.ts`, `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/armature/Slot.ts`, `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/factory/BaseFactory.ts`, `DragonBones/src/dragonBones/model/ArmatureData.ts`, `DragonBones/src/dragonBones/model/TextureAtlasData.ts`, `DragonBones/src/dragonBones/parser/DataParser.ts`, `ThreeJS/Current/src/dragonBones/three/ThreeArmatureDisplay.ts`, `ThreeJS/Current/src/dragonBones/three/ThreeSlot.ts`, `ThreeJS/Current/src/dragonBones/three/ThreeTextureAtlasData.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: `Material`, `Sprite`, `THREE`, `Texture`.
- Acessos a APIs externas/globais: `THREE.DoubleSide`, `THREE.Face3`, `THREE.Geometry`, `THREE.Mesh`, `THREE.MeshBasicMaterial`, `THREE.Sprite`, `THREE.SpriteMaterial`, `THREE.Vector2`, `THREE.Vector3`.

### `ThreeJS/Current/src/dragonBones/three/ThreeSlot.ts`

- Contexto isolado: `ThreeJS/Current/tsconfig.json`.
- Arquivos autorais resolvidos: `DragonBones/src/dragonBones/armature/Armature.ts`, `DragonBones/src/dragonBones/armature/Bone.ts`, `DragonBones/src/dragonBones/armature/Slot.ts`, `DragonBones/src/dragonBones/armature/Surface.ts`, `DragonBones/src/dragonBones/armature/TransformObject.ts`, `DragonBones/src/dragonBones/core/DragonBones.ts`, `DragonBones/src/dragonBones/geom/ColorTransform.ts`, `DragonBones/src/dragonBones/geom/Matrix.ts`, `DragonBones/src/dragonBones/geom/Rectangle.ts`, `DragonBones/src/dragonBones/model/ArmatureData.ts`, `DragonBones/src/dragonBones/model/DisplayData.ts`, `DragonBones/src/dragonBones/model/DragonBonesData.ts`, `DragonBones/src/dragonBones/model/TextureAtlasData.ts`, `ThreeJS/Current/src/dragonBones/three/ThreeArmatureDisplay.ts`, `ThreeJS/Current/src/dragonBones/three/ThreeFactory.ts`, `ThreeJS/Current/src/dragonBones/three/ThreeTextureAtlasData.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: `Face3`, `Geometry`, `Mesh`, `MeshBasicMaterial`, `Object3D`, `THREE`, `Vector2`, `Vector3`.
- Acessos a APIs externas/globais: `THREE.AdditiveBlending`, `THREE.MeshBasicMaterial`.

### `ThreeJS/Current/src/dragonBones/three/ThreeTextureAtlasData.ts`

- Contexto isolado: `ThreeJS/Current/tsconfig.json`.
- Arquivos autorais resolvidos: `DragonBones/src/dragonBones/core/BaseObject.ts`, `DragonBones/src/dragonBones/model/TextureAtlasData.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: `MeshBasicMaterial`, `THREE`, `Texture`.
- Acessos a APIs externas/globais: nenhuma.

### `ThreeJS/Demos/src/BaseDemo.ts`

- Contexto isolado: `ThreeJS/Demos/tsconfig.json`.
- Arquivos autorais resolvidos: nenhuma.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: `Map`, `OrthographicCamera`, `Scene`, `Sprite`, `THREE`, `Texture`, `WebGLRenderer`, `dragonBones`.
- Acessos a APIs externas/globais: `THREE.DefaultLoadingManager`, `THREE.DefaultLoadingManager.onLoad`, `THREE.FileLoader`, `THREE.Group`, `THREE.OrthographicCamera`, `THREE.RepeatWrapping`, `THREE.Scene`, `THREE.Sprite`, `THREE.SpriteMaterial`, `THREE.TextureLoader`, `THREE.WebGLRenderer`, `document.body`, `document.body.appendChild`, `dragonBones.ThreeFactory`, `dragonBones.ThreeFactory.factory`, `dragonBones.ThreeFactory.factory.dragonBones`, `dragonBones.ThreeFactory.factory.dragonBones.advanceTime`.

### `ThreeJS/Demos/src/HelloDragonBones.ts`

- Contexto isolado: `ThreeJS/Demos/tsconfig.json`.
- Arquivos autorais resolvidos: `ThreeJS/Demos/src/BaseDemo.ts`.
- Declarações externas/distribuídas: nenhuma.
- Nomes sem resolução estática: `dragonBones`.
- Acessos a APIs externas/globais: `dragonBones.ThreeFactory`, `dragonBones.ThreeFactory.factory`.

## JavaScript autoral: imports e efeitos de plataforma

Os arquivos abaixo também pertencem ao escopo de inventário. As declarações e instruções de topo estão em UPSTREAM_INVENTORY.md. O inventário não os executa; plugins de editor/carregadores e ferramentas não são contados como classes do núcleo. Imports dinâmicos e contratos do host permanecem pendentes para as etapas de integração.

| Origem | require explícito | Dependências locais resolvidas no commit |
| --- | --- | --- |
| `Cocos/Demos/packages/dragonbones/editor/dragonbones-asset.js` | nenhum | nenhuma |
| `Cocos/Demos/packages/dragonbones/editor/dragonbones-meta.js` | './dragonbones-asset', './polyfills', 'fire-fs', 'fire-path', 'util' | `Cocos/Demos/packages/dragonbones/editor/dragonbones-asset.js`, `Cocos/Demos/packages/dragonbones/editor/polyfills.js` |
| `Cocos/Demos/packages/dragonbones/editor/polyfills.js` | 'util' | nenhuma |
| `Cocos/Demos/packages/dragonbones/main.js` | './editor/dragonbones-asset', './editor/dragonbones-meta', 'path' | `Cocos/Demos/packages/dragonbones/editor/dragonbones-asset.js`, `Cocos/Demos/packages/dragonbones/editor/dragonbones-meta.js` |
| `Cocos/Demos/packages/dragonbones/scene.js` | './editor/dragonbones-meta', 'electron' | `Cocos/Demos/packages/dragonbones/editor/dragonbones-meta.js` |
| `Egret/4.x/scripts/modify.js` | "fs" | nenhuma |
| `Egret/Demos/template/runtime/native_loader.js` | "launcher/native_require.js" | nenhuma |
| `Egret/Demos/template/runtime/native_require.js` | src | nenhuma |
| `Egret/Demos/template/runtime/runtime_loader.js` | "launcher/native_require.js" | nenhuma |
| `builds/build_base.js` | 'async', 'child_process', 'copy', 'del', 'download', 'fs', 'lodash', 'path' | nenhuma |
| `builds/build_egret.js` | './build_base', 'async', 'copy', 'debug', 'path', 'semver' | `builds/build_base.js` |
| `builds/build_hilo.js` | './build_base', 'async', 'copy', 'debug', 'path', 'semver' | `builds/build_base.js` |
| `builds/build_phaser.js` | './build_base', 'async', 'copy', 'debug', 'path', 'semver' | `builds/build_base.js` |
| `builds/build_pixi.js` | './build_base', 'async', 'copy', 'debug', 'path', 'semver' | `builds/build_base.js` |
| `builds/cli.js` | './index', 'debug', 'lodash', 'minimist', 'path', 'semver' | `builds/index.js` |
| `builds/index.js` | './build_egret', './build_hilo', './build_phaser', './build_pixi' | `builds/build_egret.js`, `builds/build_hilo.js`, `builds/build_phaser.js`, `builds/build_pixi.js` |
| `package.json.js` | 'fs', 'path' | nenhuma |

`package.json.js` é um gerador que escreve package.json (metadados 5.6.200 no script, distintos de 5.7.0 no JSON rastreado). Egret/4.x/scripts/modify.js reescreve o .d.ts gerado. Cocos/editor e seus entrypoints dependem de Editor/cc/Electron; os três carregadores Egret dependem do host nativo. Não executar esses efeitos durante a análise nem tratar seu suporte como implementado em Lua.

## Ferramentas Node.js (fora do runtime)

Os sete `builds/*.js` foram lidos no commit fixado e constam com classes, membros e imports no inventário.

| Arquivo | Responsabilidade e fronteira |
| --- | --- |
| builds/build_base.js | Cache, cópia/download de dependências, reescrita do tsconfig e execução tsc via filesystem/processos Node. `copyDeclear` base contém `calllback` no original; registrar, sem corrigir o upstream. |
| builds/build_egret.js | Seleção de versão Egret 4, fontes e cópia de egret.d.ts. |
| builds/build_hilo.js | Seleção Hilo 1; copyDeclear retorna antes da cópia no original. |
| builds/build_phaser.js | Seleção Phaser 2/CE e declarações Phaser/P2/Pixi. |
| builds/build_pixi.js | Seleção Pixi 4 e declarações pixi-typescript. |
| builds/index.js | Exporta as quatro classes de build. |
| builds/cli.js | Parse de argumentos, validação semver e despacho para as classes. |

Não são módulos de animação. Correspondência de distribuição Lua ainda pendente; não executar downloads dinâmicos dessas ferramentas como fonte de verdade do porte.
