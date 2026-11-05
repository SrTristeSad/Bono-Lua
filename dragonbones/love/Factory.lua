-- LÖVE bridge for the pinned BaseFactory hooks; animation stays in the core runtime.
local BaseFactory=require('dragonbones.factory.BaseFactory')
local Pool=require('dragonbones.core.BaseObject')
local Armature=require('dragonbones.armature.Armature')
local Slot=require('dragonbones.love.Slot')
local Atlas=require('dragonbones.love.TextureAtlasData').TextureAtlasData
local Display=require('dragonbones.love.Display')
local Core=require('dragonbones.core.DragonBones')
local Factory={__newindex=BaseFactory.__newindex}
Factory.__index=function(self,key)return rawget(Factory,key)or BaseFactory.__index(self,key)end
setmetatable(Factory,{__index=BaseFactory})
function Factory.new(core)
  local self=BaseFactory.new(nil,Factory)
  if core==nil then
    local sound={};function sound:dispatchDBEvent()end
    core=Core.new(sound)
  end
  self._dragonBones=core
  return self
end
function Factory:_isSupportMesh()return false end
function Factory:_buildTextureAtlasData(atlas,image)
  if atlas==nil then return Pool.borrowObject(Atlas)end
  atlas.renderTexture=image;return atlas
end
function Factory:_buildArmature(packageData)
  local armature=Pool.borrowObject(Armature)
  local display=Display.new()
  display.armature=armature
  local proxy={}
  function proxy:dbInit()end
  function proxy:dbUpdate()end
  function proxy:dbClear()display.armature=nil;display.children={}end
  function proxy:hasDBEventListener(kind)
    return display.onEvent~=nil
  end
  function proxy:dispatchDBEvent(kind,event)
    if display.onEvent then display.onEvent(kind,event)end
  end
  armature:init(packageData.armature,proxy,display,self._dragonBones)
  return armature
end
function Factory:_buildSlot(_,slotData,armature)
  local slot=Pool.borrowObject(Slot)
  slot:init(slotData,armature,Display.new('sprite'),Display.new('unsupported-mesh'))
  return slot
end
return Factory
