# IArmatureProxy

Interface de DragonBones/src/dragonBones/armature/IArmatureProxy.ts no pin 64b6c69ae35777c2404be68c9192e2c56906079e. Não tem corpo executável para converter. Estende IEventDispatcher e exige dbInit(armature), dbClear(), dbUpdate(), dispose(disposeProxy), armature e animation readonly.

O backend LÖVE agora fornece a implementação real em dragonbones/love/ArmatureDisplay.lua, portada de PixiArmatureDisplay. Armature.init usa a mesma instância como proxy e display. Armature controla dbInit/dbUpdate/dbClear e a devolução ao pool; dispose no proxy não antecipa a liberação dos modelos. Getters e eventos seguem o contrato de [PublicFactory.md](PublicFactory.md).
