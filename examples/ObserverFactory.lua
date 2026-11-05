-- Example backend: assembles real runtime objects and observes callbacks.
-- It does not upload textures or draw. A graphics backend replaces these hooks.
local BaseFactory=require('dragonbones.factory.BaseFactory')
local Pool=require('dragonbones.core.BaseObject')
local Armature=require('dragonbones.armature.Armature')
local Slot=require('dragonbones.armature.Slot')
local TextureTypes=require('dragonbones.model.TextureAtlasData')
local Atlas,Texture={},{}
Atlas.__index=Atlas;Texture.__index=Texture
setmetatable(Atlas,{__index=TextureTypes.TextureAtlasData})
setmetatable(Texture,{__index=TextureTypes.TextureData})
function Atlas.toString()return '[example.ObserverAtlas]'end
function Texture.toString()return '[example.ObserverTexture]'end
function Atlas.new()return TextureTypes.TextureAtlasData.new(Atlas)end
function Texture.new()return TextureTypes.TextureData.new(Texture)end
function Atlas:createTexture()return Pool.borrowObject(Texture)end
function Atlas:_onClear()
  TextureTypes.TextureAtlasData._onClear(self)
  self.backendTexture=nil
end
local ObserverSlot={__newindex=Slot.__newindex}
ObserverSlot.__index=function(self,key)return rawget(ObserverSlot,key)or Slot.__index(self,key)end
setmetatable(ObserverSlot,{__index=Slot})
function ObserverSlot.toString()return '[example.FactorySlot]'end
function ObserverSlot.new()return Slot.new(ObserverSlot)end
function ObserverSlot:_onClear()
  Slot._onClear(self)
  self._observerFactory=nil
end
for _,hook in ipairs({'_initDisplay','_disposeDisplay','_onUpdateDisplay','_addDisplay','_replaceDisplay','_removeDisplay','_updateZOrder','_updateVisible','_updateBlendMode','_updateColor','_updateFrame','_updateMesh','_updateTransform','_identityTransform'})do
  ObserverSlot[hook]=function(self)
    if self._observerFactory then
      self._observerFactory.callbacks=self._observerFactory.callbacks+1
    end
  end
end
local ObserverFactory={__newindex=BaseFactory.__newindex}
ObserverFactory.__index=function(self,key)return rawget(ObserverFactory,key)or BaseFactory.__index(self,key)end
setmetatable(ObserverFactory,{__index=BaseFactory})
function ObserverFactory.new(core)
  local self=BaseFactory.new(nil,ObserverFactory)
  self.callbacks=0;self.frames=0;self.events=0
  if core==nil then
    local sound={};function sound:dispatchDBEvent()end
    core=require('dragonbones.core.DragonBones').new(sound)
  end
  self._dragonBones=core
  return self
end
function ObserverFactory:_buildTextureAtlasData(atlas,texture)
  if atlas==nil then return Pool.borrowObject(Atlas)end
  atlas.backendTexture=texture
  return atlas
end
function ObserverFactory:_buildArmature(packageData)
  local armature=Pool.borrowObject(Armature)
  local factory=self
  local proxy={}
  function proxy:dbInit()end
  function proxy:dbUpdate()factory.frames=factory.frames+1 end
  function proxy:dbClear()end
  function proxy:hasDBEventListener()return true end
  function proxy:dispatchDBEvent()factory.events=factory.events+1 end
  armature:init(packageData.armature,proxy,{},self._dragonBones)
  return armature
end
function ObserverFactory:_buildSlot(_,slotData,armature)
  local slot=Pool.borrowObject(ObserverSlot)
  slot._observerFactory=self
  slot:init(slotData,armature,{}, {})
  return slot
end
return ObserverFactory
