-- Partial port of Armature.ts, DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e.
-- Copyright (c) 2012-2025 DragonBones team and contributors; MIT.
-- Partial lifecycle/registry/clock/cache/action APIs; init/advanceTime remain absent.
local BaseObject = require('dragonbones.core.BaseObject')
local Array = require('dragonbones.core.JSArray')
local number = require('dragonbones.parser.JSValue').number
local Armature = {}
setmetatable(Armature, {__index=BaseObject})
function Armature.toString() return '[class dragonBones.Armature]' end
function Armature.__index(self,key)
  if key=='eventDispatcher' then return self._proxy end
  if key=='display' then return self._display end
  if key=='animation' then return self._animation end
  if key=='clock' then return self._clock end
  if key=='parent' then return self._parent end
  if key=='cacheFrameRate' then return self._armatureData.cacheFrameRate end
  if key=='flipX' then return rawget(self,'_flipX') end
  if key=='flipY' then return rawget(self,'_flipY') end
  if key=='name' then return self._armatureData.name end
  if key=='armatureData' then return rawget(self,'_armatureData') end
  return rawget(Armature,key) or BaseObject[key]
end
function Armature.__newindex(self,key,value)
  if key=='clock' then
    if rawequal(self._clock,value) then return end
    if self._clock ~= nil then self._clock:remove(self) end
    self._clock = value
    if self._clock ~= nil then self._clock:add(self) end
    local i = 1
    while i <= self._slots.length do
      local child = self._slots[i].childArmature
      if child ~= nil then child.clock = self._clock end
      i = i + 1
    end
  elseif key=='cacheFrameRate' then
    if self._armatureData.cacheFrameRate ~= value then
      self._armatureData:cacheFrames(value)
      local i = 1
      while i <= self._slots.length do
        local child = self._slots[i].childArmature
        if child ~= nil then child.cacheFrameRate = value end
        i = i + 1
      end
    end
  elseif key=='flipX' or key=='flipY' then
    local field=key=='flipX' and '_flipX' or '_flipY'
    if self[field]==value then return end
    self[field]=value
    self:invalidUpdate()
  elseif key=='eventDispatcher' or key=='name' or key=='armatureData' or key=='display' or key=='animation' or key=='parent' then error('Readonly property: '..key)
  else rawset(self,key,value) end
end
function Armature.new()
  local self=BaseObject.new(Armature)
  self._bones=Array.new();self._slots=Array.new()
  self._constraints=Array.new();self._actions=Array.new()
  -- Source's explicit null initializers map to nil; other fields are unset.
  return self
end
function Armature:_onClear()
  if self._clock~=nil then self._clock:remove(self) end
  for _,key in ipairs({'_bones','_slots','_constraints','_actions'}) do
    local array=self[key];local i=1
    while i<=array.length do array[i]:returnToPool();i=i+1 end
  end
  if self._animation~=nil then self._animation:returnToPool() end
  if self._proxy~=nil then self._proxy:dbClear() end
  if self._replaceTextureAtlasData~=nil then self._replaceTextureAtlasData:returnToPool() end
  self.inheritAnimation=true;self.userData=nil
  self._lockUpdate=false;self._slotsDirty=true;self._zOrderDirty=false
  self._zIndexDirty=false;self._alphaDirty=true;self._flipX=false;self._flipY=false
  self._cacheFrameIndex=-1;self._alpha=1.0;self._globalAlpha=1.0
  self._bones.length=0;self._slots.length=0;self._constraints.length=0;self._actions.length=0
  self._armatureData=nil;self._animation=nil;self._proxy=nil;self._display=nil
  self._replaceTextureAtlasData=nil;self._replacedTexture=nil
  self._dragonBones=nil;self._clock=nil;self._parent=nil
end
function Armature:_sortZOrder(slotIndices,offset)
  local slotDatas=self._armatureData.sortedSlots
  local isOriginal=slotIndices==nil
  if self._zOrderDirty or not isOriginal then
    local length=slotDatas.length
    for i=0,length-1 do
      local index=i
      if not isOriginal then index=number(slotIndices[offset+i+1]) end
      if not(index<0 or index>=length)then
        local data=slotDatas[index+1]
        local slot=self:getSlot(data.name)
        if slot~=nil then slot:_setZOrder(i)end
      end
    end
    self._slotsDirty=true
    self._zOrderDirty=not isOriginal
  end
end
function Armature:_addBone(value)
  local bones=self._bones
  for i=1,bones.length do if bones[i]==value then return end end
  bones[bones.length+1]=value
end
function Armature:_addSlot(value)
  local slots=self._slots
  for i=1,slots.length do if rawequal(slots[i],value) then return end end
  slots[slots.length+1]=value
end
function Armature:_addConstraint(value)
  for i=1,self._constraints.length do
    if rawequal(self._constraints[i],value) then return end
  end
  self._constraints[self._constraints.length+1]=value
end
function Armature:getSlot(name)
  local i=1
  while i<=self._slots.length do
    local slot=self._slots[i]
    if slot.name==name then return slot end
    i=i+1
  end
  return nil
end
function Armature:getBone(name)
  local i=1
  while i<=self._bones.length do
    local bone=self._bones[i]
    if bone.name==name then return bone end
    i=i+1
  end
  return nil
end
function Armature:getBones() return self._bones end
function Armature:getSlots() return self._slots end
function Armature:invalidUpdate(boneName,updateSlot)
  if boneName~=nil and #boneName>0 then
    local bone=self:getBone(boneName)
    if bone~=nil then
      bone:invalidUpdate()
      if updateSlot then
        local i=1
        while i<=self._slots.length do
          local slot=self._slots[i]
          if slot.parent==bone then slot:invalidUpdate() end
          i=i+1
        end
      end
    end
  else
    local i=1
    while i<=self._bones.length do self._bones[i]:invalidUpdate();i=i+1 end
    if updateSlot then
      i=1
      while i<=self._slots.length do self._slots[i]:invalidUpdate();i=i+1 end
    end
  end
end
function Armature:_bufferAction(action,append)
  for i=1,self._actions.length do if rawequal(self._actions[i],action) then return end end
  if append then self._actions[self._actions.length+1]=action
  else
    for i=self._actions.length,1,-1 do self._actions[i+1]=self._actions[i] end
    self._actions[1]=action
  end
end
function Armature:dispose()
  if self._armatureData ~= nil then
    self._lockUpdate=true
    self._dragonBones:bufferObject(self)
  end
end
return Armature
