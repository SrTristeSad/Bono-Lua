-- Armature.ts, DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e.
-- Copyright (c) 2012-2025 DragonBones team and contributors; MIT.
-- Original bodies ported in the domains documented in ArmatureRuntime.md.
local BaseObject = require('dragonbones.core.BaseObject')
local Array = require('dragonbones.core.JSArray')
local number = require('dragonbones.parser.JSValue').number
local Armature = {}
setmetatable(Armature, {__index=BaseObject})
local ActionType=require('dragonbones.core.Enums').ActionType
local function each(a)local i=0;return function()i=i+1;if i<=a.length then return i,a[i]end end end
local function score(s)return s._zIndex*1000+s._zOrder end
function Armature._onSortSlots(a,b)return score(a)>score(b) and 1 or -1 end

function Armature.toString() return '[class dragonBones.Armature]' end
function Armature.__index(self,key)
  if key=='proxy' then return self._proxy end
  if key=='replacedTexture' then return self._replacedTexture end
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
  elseif key=="replacedTexture" then
    if self._replacedTexture==value then return end
    if self._replaceTextureAtlasData~=nil then
      self._replaceTextureAtlasData:returnToPool()
      self._replaceTextureAtlasData=nil
    end
    self._replacedTexture=value
    for _,slot in each(self._slots) do
      slot:invalidUpdate()
      slot:update(-1)
    end
  elseif key=='flipX' or key=='flipY' then
    local field=key=='flipX' and '_flipX' or '_flipY'
    if self[field]==value then return end
    self[field]=value
    self:invalidUpdate()
  elseif key=='proxy' or key=='eventDispatcher' or key=='name' or key=='armatureData' or key=='display' or key=='animation' or key=='parent' then error('Readonly property: '..key)
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
function Armature:init(armatureData,proxy,display,dragonBones)
  if self._armatureData~=nil then return end
  self._armatureData=armatureData
  local Animation=require("dragonbones.animation.Animation")
  self._animation=BaseObject.borrowObject(Animation)
  self._proxy=proxy
  self._display=display
  self._dragonBones=dragonBones
  self._proxy:dbInit(self)
  self._animation:init(self)
  self._animation.animations=self._armatureData.animations
end
-- Source comparator returns -1 for ties. Lua table.sort expects a strict
-- comparator, so insertion sort retains the original comparator direction.
-- Equal-key ordering is differential-tested for three slots; larger
-- non-strict comparator runs remain engine-dependent (see ArmatureRuntime.md).
local function sortSlots(items)
  for i=2,items.length do
    local v=items[i]
    local j=i-1
    while j>=1 and Armature._onSortSlots(v,items[j])<0 do
      items[j+1]=items[j]
      j=j-1
    end
    items[j+1]=v
  end
end
function Armature:advanceTime(passedTime)
  if self._lockUpdate then return end
  self._lockUpdate=true
  if self._armatureData==nil then
    io.stderr:write("The armature has been disposed.\n")
    return
  elseif self._armatureData.parent==nil then
    io.stderr:write("The armature data has been disposed.\nPlease make sure dispose armature before call factory.clear().\n")
    return
  end
  local previous=self._cacheFrameIndex
  self._animation:advanceTime(passedTime)
  if self._slotsDirty or self._zIndexDirty then
    sortSlots(self._slots)
    if self._zIndexDirty then
      for i=1,self._slots.length do self._slots[i]:_setZOrder(i-1)end
    end
    self._slotsDirty=false
    self._zIndexDirty=false
  end
  if self._alphaDirty then
    self._alphaDirty=false
    self._globalAlpha=self._alpha*(self._parent~=nil
      and self._parent._globalAlpha or 1.0)
    for _,b in each(self._bones) do b:_updateAlpha() end
    for _,s in each(self._slots) do s:_updateAlpha() end
  end
  if self._cacheFrameIndex<0 or self._cacheFrameIndex~=previous then
    for i=1,self._bones.length do self._bones[i]:update(self._cacheFrameIndex)end
    for i=1,self._slots.length do self._slots[i]:update(self._cacheFrameIndex)end
  end
  if self._actions.length>0 then
    for _,action in each(self._actions) do
      local data=action.actionData
      if data~=nil and data.type==ActionType.Play then
        if action.slot~=nil then
          local child=action.slot.childArmature
          if child~=nil then child.animation:fadeIn(data.name) end
        elseif action.bone~=nil then
          for _,slot in each(self:getSlots()) do
            if slot.parent==action.bone then
              local child=slot.childArmature
              if child~=nil then child.animation:fadeIn(data.name) end
            end
          end
        else
          self._animation:fadeIn(data.name)
        end
      end
      action:returnToPool()
    end
    self._actions.length=0
  end
  self._lockUpdate=false
  self._proxy:dbUpdate()
end
function Armature:containsPoint(x,y)
  for _,slot in each(self._slots) do
    if slot:containsPoint(x,y) then return slot end
  end
  return nil
end
function Armature:intersectsSegment(xA,yA,xB,yB,pointA,pointB,normals)
  local vertical=xA==xB
  local dMin,dMax=0.0,0.0
  local intXA,intYA,intXB,intYB=0.0,0.0,0.0,0.0
  local intAN,intBN=0.0,0.0
  local intSlotA,intSlotB=nil,nil
  for _,slot in each(self._slots) do
    local count=slot:intersectsSegment(xA,yA,xB,yB,pointA,pointB,normals)
    if count>0 then
      if pointA~=nil or pointB~=nil then
        if pointA~=nil then
          local d=vertical and (pointA.y-yA) or (pointA.x-xA)
          if d<0.0 then d=-d end
          if intSlotA==nil or d<dMin then
            dMin=d
            intXA,intYA=pointA.x,pointA.y
            intSlotA=slot
            if normals~=nil then intAN=normals.x end
          end
        end
        if pointB~=nil then
          -- Source deliberately uses x for B even for vertical segments.
          local d=pointB.x-xA
          if d<0.0 then d=-d end
          if intSlotB==nil or d>dMax then
            dMax=d
            intXB,intYB=pointB.x,pointB.y
            intSlotB=slot
            if normals~=nil then intBN=normals.y end
          end
        end
      else intSlotA=slot;break end
    end
  end
  if intSlotA~=nil and pointA~=nil then
    pointA.x=intXA;pointA.y=intYA
    if normals~=nil then normals.x=intAN end
  end
  if intSlotB~=nil and pointB~=nil then
    pointB.x=intXB;pointB.y=intYB
    if normals~=nil then normals.y=intBN end
  end
  return intSlotA
end
function Armature:getBoneByDisplay(display)
  local slot=self:getSlotByDisplay(display)
  return slot~=nil and slot.parent or nil
end
function Armature:getSlotByDisplay(display)
  if display~=nil then
    for _,s in each(self._slots) do
      if s.display==display then return s end
    end
  end
  return nil
end
function Armature:getDisplay() return self._display end
return Armature
