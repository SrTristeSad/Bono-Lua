-- Port of Pixi/4.x PixiFactory.ts at 64b6c69ae35777c2404be68c9192e2c56906079e.
-- Copyright (c) DragonBones contributors. MIT: LICENSE-DRAGONBONES.
local BaseFactory=require('dragonbones.factory.BaseFactory')
local Pool=require('dragonbones.core.BaseObject')
local Armature=require('dragonbones.armature.Armature')
local Slot=require('dragonbones.love.Slot')
local Atlas=require('dragonbones.love.TextureAtlasData').TextureAtlasData
local Display=require('dragonbones.love.Display')
local ArmatureDisplay=require('dragonbones.love.ArmatureDisplay')
local Core=require('dragonbones.core.DragonBones')
local truthy=require('dragonbones.parser.JSValue').truthy
local Factory={}
function Factory.__index(self,key)
  if key=='soundEventManager'then return self._dragonBones.eventManager end
  return rawget(Factory,key)or BaseFactory.__index(self,key)
end
function Factory.__newindex(self,key,value)
  if key=='soundEventManager'then error('Readonly property: '..key)end
  BaseFactory.__newindex(self,key,value)
end
setmetatable(Factory,{__index=function(_,key)
  if key=='factory'then
    if not Factory._factory then Factory._factory=Factory.new()end
    return Factory._factory
  end
  return BaseFactory[key]
end,__newindex=function(_,key,value)
  if key=='factory'then error('Readonly property: factory')end
  rawset(Factory,key,value)
end})
function Factory.new(dataParser,core)
  -- Preserve the adapter's existing Factory.new(core) injection form.
  if getmetatable(dataParser)==Core or(type(dataParser)=='table'and type(dataParser.advanceTime)=='function'and dataParser.clock~=nil)then
    core=dataParser;dataParser=nil
  end
  local self=BaseFactory.new(dataParser,Factory)
  if not core then
    if not Factory._dragonBonesInstance then Factory._dragonBonesInstance=Core.new(ArmatureDisplay.new())end
    core=Factory._dragonBonesInstance
  end
  self._dragonBones=core
  return self
end
-- Host ticker bridge: elapsed milliseconds are supplied by LÖVE integration.
function Factory._clockHandler(passedTime,elapsedMS)
  Factory._dragonBonesInstance:advanceTime(elapsedMS*passedTime*.001)
end
-- LÖVE supplies seconds; call once per frame for each distinct core.
function Factory:update(deltaSeconds)self._dragonBones:advanceTime(deltaSeconds)end
function Factory:_isSupportMesh()return true end
function Factory:_buildTextureAtlasData(atlas,image)
  if atlas==nil then return Pool.borrowObject(Atlas)end
  atlas.renderTexture=image;return atlas
end
function Factory:_buildArmature(packageData)
  local armature=Pool.borrowObject(Armature)
  local display=ArmatureDisplay.new()
  armature:init(packageData.armature,display,display,self._dragonBones)
  return armature
end
function Factory:_buildSlot(_,slotData,armature)
  local slot=Pool.borrowObject(Slot)
  slot:init(slotData,armature,Display.new('sprite'),Display.new('mesh'))
  return slot
end
function Factory:buildArmatureDisplay(name,dataName,skinName,atlasName)
  local armature=self:buildArmature(name,truthy(dataName)and dataName or'',
    truthy(skinName)and skinName or'',truthy(atlasName)and atlasName or'')
  if armature then self._dragonBones.clock:add(armature);return armature.display end
end
function Factory:getTextureDisplay(name,atlasName)
  local texture=self:_getTextureData(atlasName~=nil and atlasName or'',name)
  if texture and texture.renderTexture then
    local display=Display.new('sprite');display.texture=texture.renderTexture;return display
  end
end
return Factory
