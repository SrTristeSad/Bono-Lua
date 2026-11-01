
-- DragonBones/src/dragonBones/armature/Armature.ts (DragonBonesJS)
-- Source commit: 64b6c69ae35777c2404be68c9192e2c56906079e
-- Copyright (c) 2012-2025 DragonBones team and other contributors.
-- MIT license: see LICENSE-DRAGONBONES.
-- Animation.ts has not yet been ported; init resolves the original class
-- at call time rather than adding a substitute to the application.
local BaseObject=require("dragonbones.original.core.BaseObject")
local Core=require("dragonbones.original.core.DragonBones")
local Armature={}
setmetatable(Armature,{__index=BaseObject})

local function clearArray(a) for i=#a,1,-1 do a[i]=nil end end
local function has(a,v)
  for _,item in ipairs(a) do if item==v then return true end end
  return false
end
local function score(s) return s._zIndex*1000+s._zOrder end

function Armature.toString() return "[class dragonBones.Armature]" end
function Armature._onSortSlots(a,b) return score(a)>score(b) and 1 or -1 end
function Armature.new()
  local o=BaseObject.new(Armature)
  o._bones={}
  o._slots={}
  o._constraints={}
  o._actions={}
  return o
end
function Armature.__index(self,key)
  if key=="flipX" then return self._flipX end
  if key=="flipY" then return self._flipY end
  if key=="cacheFrameRate" then return self._armatureData.cacheFrameRate end
  if key=="name" then return self._armatureData.name end
  if key=="armatureData" then return self._armatureData end
  if key=="animation" then return self._animation end
  if key=="proxy" or key=="eventDispatcher" then return self._proxy end
  if key=="display" then return self._display end
  if key=="replacedTexture" then return self._replacedTexture end
  if key=="clock" then return self._clock end
  if key=="parent" then return self._parent end
  return rawget(Armature,key) or BaseObject[key]
end
function Armature.__newindex(self,key,value)
  if key=="flipX" then
    if self._flipX==value then return end
    self._flipX=value
    self:invalidUpdate()
  elseif key=="flipY" then
    if self._flipY==value then return end
    self._flipY=value
    self:invalidUpdate()
  elseif key=="cacheFrameRate" then
    if self._armatureData.cacheFrameRate~=value then
      self._armatureData:cacheFrames(value)
      for _,slot in ipairs(self._slots) do
        local child=slot.childArmature
        if child~=nil then child.cacheFrameRate=value end
      end
    end
  elseif key=="replacedTexture" then
    if self._replacedTexture==value then return end
    if self._replaceTextureAtlasData~=nil then
      self._replaceTextureAtlasData:returnToPool()
      self._replaceTextureAtlasData=nil
    end
    self._replacedTexture=value
    for _,slot in ipairs(self._slots) do
      slot:invalidUpdate()
      slot:update(-1)
    end
  elseif key=="clock" then
    if self._clock==value then return end
    if self._clock~=nil then self._clock:remove(self) end
    self._clock=value
    if self._clock~=nil then self._clock:add(self) end
    for _,slot in ipairs(self._slots) do
      local child=slot.childArmature
      if child~=nil then child.clock=self._clock end
    end
  else rawset(self,key,value) end
end

function Armature:_onClear()
  if self._clock~=nil then self._clock:remove(self) end
  for _,b in ipairs(self._bones) do b:returnToPool() end
  for _,s in ipairs(self._slots) do s:returnToPool() end
  for _,c in ipairs(self._constraints) do c:returnToPool() end
  for _,a in ipairs(self._actions) do a:returnToPool() end
  if self._animation~=nil then self._animation:returnToPool() end
  if self._proxy~=nil then self._proxy:dbClear() end
  if self._replaceTextureAtlasData~=nil then
    self._replaceTextureAtlasData:returnToPool()
  end
  self.inheritAnimation=true
  self.userData=nil
  self._lockUpdate=false
  self._slotsDirty=true
  self._zOrderDirty=false
  self._zIndexDirty=false
  self._alphaDirty=true
  self._flipX=false
  self._flipY=false
  self._cacheFrameIndex=-1
  self._alpha=1.0
  self._globalAlpha=1.0
  clearArray(self._bones)
  clearArray(self._slots)
  clearArray(self._constraints)
  clearArray(self._actions)
  self._armatureData=nil
  self._animation=nil
  self._proxy=nil
  self._display=nil
  self._replaceTextureAtlasData=nil
  self._replacedTexture=nil
  self._dragonBones=nil
  self._clock=nil
  self._parent=nil
end

function Armature:_sortZOrder(slotIndices,offset)
  local data=self._armatureData.sortedSlots
  local isOriginal=slotIndices==nil
  if self._zOrderDirty or not isOriginal then
    for i=0,#data-1 do
      local index=isOriginal and i or slotIndices[offset+i+1]
      if index>=0 and index<#data then
        local slot=self:getSlot(data[index+1].name)
        if slot~=nil then slot:_setZOrder(i) end
      end
    end
    self._slotsDirty=true
    self._zOrderDirty=not isOriginal
  end
end
function Armature:_addBone(v)
  if not has(self._bones,v) then self._bones[#self._bones+1]=v end
end
function Armature:_addSlot(v)
  if not has(self._slots,v) then self._slots[#self._slots+1]=v end
end
function Armature:_addConstraint(v)
  if not has(self._constraints,v) then self._constraints[#self._constraints+1]=v end
end
function Armature:_bufferAction(v,append)
  if not has(self._actions,v) then
    if append then self._actions[#self._actions+1]=v
    else table.insert(self._actions,1,v) end
  end
end
function Armature:dispose()
  if self._armatureData~=nil then
    self._lockUpdate=true
    self._dragonBones:bufferObject(self)
  end
end
function Armature:init(armatureData,proxy,display,dragonBones)
  if self._armatureData~=nil then return end
  self._armatureData=armatureData
  local Animation=require("dragonbones.original.animation.Animation")
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
-- JS's engine-specific equal-key ordering remains unverified.
local function sortSlots(items)
  for i=2,#items do
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
      for i,slot in ipairs(self._slots) do slot:_setZOrder(i-1) end
    end
    self._slotsDirty=false
    self._zIndexDirty=false
  end
  if self._alphaDirty then
    self._alphaDirty=false
    self._globalAlpha=self._alpha*(self._parent~=nil
      and self._parent._globalAlpha or 1.0)
    for _,b in ipairs(self._bones) do b:_updateAlpha() end
    for _,s in ipairs(self._slots) do s:_updateAlpha() end
  end
  if self._cacheFrameIndex<0 or self._cacheFrameIndex~=previous then
    for _,b in ipairs(self._bones) do b:update(self._cacheFrameIndex) end
    for _,s in ipairs(self._slots) do s:update(self._cacheFrameIndex) end
  end
  if #self._actions>0 then
    for _,action in ipairs(self._actions) do
      local data=action.actionData
      if data~=nil and data.type==Core.ActionType.Play then
        if action.slot~=nil then
          local child=action.slot.childArmature
          if child~=nil then child.animation:fadeIn(data.name) end
        elseif action.bone~=nil then
          for _,slot in ipairs(self:getSlots()) do
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
    clearArray(self._actions)
  end
  self._lockUpdate=false
  self._proxy:dbUpdate()
end
function Armature:invalidUpdate(boneName,updateSlot)
  if boneName~=nil and #boneName>0 then
    local bone=self:getBone(boneName)
    if bone~=nil then
      bone:invalidUpdate()
      if updateSlot then
        for _,slot in ipairs(self._slots) do
          if slot.parent==bone then slot:invalidUpdate() end
        end
      end
    end
  else
    for _,bone in ipairs(self._bones) do bone:invalidUpdate() end
    if updateSlot then
      for _,slot in ipairs(self._slots) do slot:invalidUpdate() end
    end
  end
end
function Armature:containsPoint(x,y)
  for _,slot in ipairs(self._slots) do
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
  for _,slot in ipairs(self._slots) do
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
function Armature:getBone(name)
  for _,b in ipairs(self._bones) do if b.name==name then return b end end
  return nil
end
function Armature:getBoneByDisplay(display)
  local slot=self:getSlotByDisplay(display)
  return slot~=nil and slot.parent or nil
end
function Armature:getSlot(name)
  for _,s in ipairs(self._slots) do if s.name==name then return s end end
  return nil
end
function Armature:getSlotByDisplay(display)
  if display~=nil then
    for _,s in ipairs(self._slots) do
      if s.display==display then return s end
    end
  end
  return nil
end
function Armature:getBones() return self._bones end
function Armature:getSlots() return self._slots end
function Armature:getDisplay() return self._display end
return Armature
