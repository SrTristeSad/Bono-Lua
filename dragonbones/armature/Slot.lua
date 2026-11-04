-- Partial port of Slot.ts, DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e.
-- Copyright (c) 2012-2025 DragonBones team and contributors; MIT.
-- Foundation/lifecycle/transform/hit testing only. Display evaluation/update,
-- replacement and child-armature playback remain absent. Renderer hooks are abstract.
local BaseObject = require('dragonbones.core.BaseObject')
local TransformObject = require('dragonbones.armature.TransformObject')
local DisplayFrame = require('dragonbones.armature.DisplayFrame')
local Core = require('dragonbones.core.Enums')
local Matrix = require('dragonbones.geom.Matrix')
local ColorTransform = require('dragonbones.geom.ColorTransform')
local Array = require('dragonbones.core.JSArray')
local Armature = require('dragonbones.armature.Armature')
local Slot = {}
setmetatable(Slot,{__index=TransformObject})
local function normalAngle(y,x)
  if math.atan2 then return math.atan2(y,x) end
  return math.atan(y,x)
end
local function isArmature(value)
  if type(value)~='table' then return false end
  local class=getmetatable(value)
  while type(class)=='table' do
    if class==Armature then return true end
    local meta=getmetatable(class)
    class=meta and meta.__index
  end
  return false
end
local function displayAt(self,index)
  if index~=index or index<0 or index~=math.floor(index) then return nil end
  return self._displayFrames[index+1]
end
local function setDisplayFrameCount(self,value)
  local prevCount=self._displayFrames.length
  if prevCount<value then
    self._displayFrames.length=value
    for i=prevCount,value-1 do self._displayFrames[i+1]=BaseObject.borrowObject(DisplayFrame) end
  elseif prevCount>value then
    -- Preserve the upstream i < value condition (not i >= value).
    -- Integer reductions truncate without pooling the removed frames.
    local i=prevCount-1
    while i<value do
      self:replaceDisplay(nil,i)
      self._displayFrames[i+1]:returnToPool()
      i=i-1
    end
    self._displayFrames.length=value
  end
end
function Slot.__index(self,key)
  if key=='visible' then return self._visible end
  if key=='displayFrameCount' then return self._displayFrames.length end
  if key=='name' then return self._slotData.name end
  local refs={slotData='_slotData',boundingBoxData='_boundingBoxData',rawDisplay='_rawDisplay',meshDisplay='_meshDisplay',parent='_parent'}
  if refs[key] then return rawget(self,refs[key]) end
  local member=rawget(Slot,key)
  if member~=nil then return member end
  return TransformObject.__index(self,key)
end
function Slot.__newindex(self,key,value)
  if key=='visible' then
    if self._visible==value then return end
    self._visible=value
    self:_updateVisible()
  elseif key=='displayFrameCount' then setDisplayFrameCount(self,value)
  elseif key=='name' or key=='slotData' or key=='boundingBoxData' or key=='rawDisplay' or key=='meshDisplay' or key=='parent' then
    error('Readonly property: '..key)
  else TransformObject.__newindex(self,key,value) end
end
function Slot.new(concreteClass)
  local self=TransformObject.new(concreteClass or Slot)
  self._localMatrix=Matrix.new()
  self._colorTransform=ColorTransform.new()
  self._displayFrames=Array.new()
  self._geometryBones=Array.new()
  return self
end

function Slot:_onClear()
  TransformObject._onClear(self)
  local disposeDisplayList=Array.new()
  local i=1
  while i<=self._displayFrames.length do
    local frame=self._displayFrames[i]
    local display=frame.display
    if not rawequal(display,self._rawDisplay) and not rawequal(display,self._meshDisplay) then
      local found=false
      for j=1,disposeDisplayList.length do
        if rawequal(disposeDisplayList[j],display) then found=true;break end
      end
      if not found then
        local nextIndex=disposeDisplayList.length+1
        disposeDisplayList.length=nextIndex
        disposeDisplayList[nextIndex]=display
      end
    end
    frame:returnToPool()
    i=i+1
  end
  i=1
  while i<=disposeDisplayList.length do
    local display=disposeDisplayList[i]
    if isArmature(display) then display:dispose()
    else self:_disposeDisplay(display,true) end
    i=i+1
  end
  if self._meshDisplay ~= nil and not rawequal(self._meshDisplay,self._rawDisplay) then
    self:_disposeDisplay(self._meshDisplay, false)
  end
  if self._rawDisplay ~= nil then
    self:_disposeDisplay(self._rawDisplay, false)
  end

  self.displayController = nil
  self._displayDataDirty = false
  self._displayDirty = false
  self._geometryDirty = false
  self._textureDirty = false
  self._visibleDirty = false
  self._blendModeDirty = false
  self._zOrderDirty = false
  self._colorDirty = false
  self._verticesDirty = false
  self._transformDirty = false
  self._visible = true
  self._blendMode = Core.BlendMode.Normal
  self._displayIndex = -1
  self._animationDisplayIndex = -1
  self._zOrder = 0
  self._zIndex = 0
  self._cachedFrameIndex = -1
  self._pivotX = 0.0
  self._pivotY = 0.0
  self._localMatrix:identity()
  self._colorTransform:identity()
  self._displayFrames.length=0
  self._geometryBones.length=0
  self._slotData = nil
  self._displayFrame = nil
  self._geometryData = nil
  self._boundingBoxData = nil
  self._textureData = nil
  self._rawDisplay = nil
  self._meshDisplay = nil
  self._display = nil
  self._childArmature = nil
  self._parent = nil
  self._cachedFrameIndices = nil
end

-- The original contains 13 *abstract* platform hooks:
-- _initDisplay, _disposeDisplay, _onUpdateDisplay, _addDisplay,
-- _replaceDisplay, _removeDisplay, _updateZOrder, _updateVisible,
-- _updateBlendMode, _updateColor, _updateFrame, _updateMesh,
-- _updateTransform, _identityTransform. They intentionally have no bodies.

-- The fourteen renderer hooks declared abstract in TS have no bodies here.
function Slot:_hasDisplay(display)
  local i=1
  while i<=self._displayFrames.length do
    if rawequal(self._displayFrames[i].display,display) then return true end
    i=i+1
  end
  return false
end
function Slot:_isBonesUpdate()
  local i=1
  while i<=self._geometryBones.length do
    local bone=self._geometryBones[i]
    if bone~=nil and bone._childrenTransformDirty then return true end
    i=i+1
  end
  return false
end

function Slot:_updateAlpha()
  local globalAlpha = self._alpha * self._parent._globalAlpha
  if self._globalAlpha ~= globalAlpha then
    self._globalAlpha = globalAlpha
    self._colorDirty = true
  end
end

function Slot:_updateGlobalTransformMatrix(isCache)
  local parentMatrix = self._parent._boneData.type == Core.BoneType.Bone
    and self._parent.globalTransformMatrix
    or self._parent:_getGlobalTransformMatrix(self.global.x, self.global.y)
  self.globalTransformMatrix:copyFrom(self._localMatrix)
  self.globalTransformMatrix:concat(parentMatrix)
  if isCache then
    self.global:fromMatrix(self.globalTransformMatrix)
  else
    self._globalDirty = true
  end
end

function Slot:_setDisplayIndex(value, isAnimation)
  if isAnimation then
    if self._animationDisplayIndex == value then return end
    self._animationDisplayIndex = value
  end
  if self._displayIndex == value then return end
  self._displayIndex = value < self._displayFrames.length
    and value or (self._displayFrames.length - 1)
  self._displayDataDirty = true
  self._displayDirty = self._displayIndex < 0
    or not rawequal(self._display,displayAt(self, self._displayIndex).display)
end

function Slot:_setZOrder(value)
  -- Upstream intentionally has no short-circuit when value is unchanged.
  self._zOrder = value
  self._zOrderDirty = true
  return self._zOrderDirty
end

function Slot:_setColor(value)
  self._colorTransform:copyFrom(value)
  self._colorDirty = true
  return true
end

function Slot:init(slotData, armatureValue, rawDisplay, meshDisplay)
  if self._slotData ~= nil then return end
  self._slotData = slotData
  self._colorDirty = true
  self._blendModeDirty = true
  self._blendMode = self._slotData.blendMode
  self._zOrder = self._slotData.zOrder
  self._zIndex = self._slotData.zIndex
  self._alpha = self._slotData.alpha
  self._colorTransform:copyFrom(self._slotData.color)
  self._rawDisplay = rawDisplay
  self._meshDisplay = meshDisplay
  self._armature = armatureValue
  local slotParent = self._armature:getBone(self._slotData.parent.name)
  if slotParent ~= nil then self._parent = slotParent end
  self._armature:_addSlot(self)
  self:_initDisplay(self._rawDisplay, false)
  if not rawequal(self._rawDisplay,self._meshDisplay) then
    self:_initDisplay(self._meshDisplay, false)
  end
  self:_onUpdateDisplay()
  self:_addDisplay()
end

function Slot:invalidUpdate()
  self._displayDataDirty = true
  self._displayDirty = true
  self._transformDirty = true
end

function Slot:updateTransformAndMatrix()
  if self._transformDirty then
    self:_updateGlobalTransformMatrix(false)
    self._transformDirty = false
  end
end

function Slot:containsPoint(x, y)
  if self._boundingBoxData == nil then return false end
  self:updateTransformAndMatrix()
  Slot._helpMatrix:copyFrom(self.globalTransformMatrix)
  Slot._helpMatrix:invert()
  Slot._helpMatrix:transformPoint(x, y, Slot._helpPoint)
  return self._boundingBoxData:containsPoint(Slot._helpPoint.x, Slot._helpPoint.y)
end

function Slot:intersectsSegment(xA, yA, xB, yB, intersectionPointA,
    intersectionPointB, normalRadians)
  if self._boundingBoxData == nil then return 0 end
  self:updateTransformAndMatrix()
  Slot._helpMatrix:copyFrom(self.globalTransformMatrix)
  Slot._helpMatrix:invert()
  Slot._helpMatrix:transformPoint(xA, yA, Slot._helpPoint)
  xA, yA = Slot._helpPoint.x, Slot._helpPoint.y
  Slot._helpMatrix:transformPoint(xB, yB, Slot._helpPoint)
  xB, yB = Slot._helpPoint.x, Slot._helpPoint.y

  local intersectionCount = self._boundingBoxData:intersectsSegment(
    xA, yA, xB, yB, intersectionPointA, intersectionPointB, normalRadians)
  if intersectionCount > 0 then
    if intersectionCount == 1 or intersectionCount == 2 then
      if intersectionPointA ~= nil then
        self.globalTransformMatrix:transformPoint(
          intersectionPointA.x, intersectionPointA.y, intersectionPointA)
        if intersectionPointB ~= nil then
          intersectionPointB.x = intersectionPointA.x
          intersectionPointB.y = intersectionPointA.y
        end
      elseif intersectionPointB ~= nil then
        self.globalTransformMatrix:transformPoint(
          intersectionPointB.x, intersectionPointB.y, intersectionPointB)
      end
    else
      if intersectionPointA ~= nil then
        self.globalTransformMatrix:transformPoint(
          intersectionPointA.x, intersectionPointA.y, intersectionPointA)
      end
      if intersectionPointB ~= nil then
        self.globalTransformMatrix:transformPoint(
          intersectionPointB.x, intersectionPointB.y, intersectionPointB)
      end
    end
    if normalRadians ~= nil then
      self.globalTransformMatrix:transformPoint(
        math.cos(normalRadians.x), math.sin(normalRadians.x), Slot._helpPoint, true)
      normalRadians.x = normalAngle(Slot._helpPoint.y, Slot._helpPoint.x)
      self.globalTransformMatrix:transformPoint(
        math.cos(normalRadians.y), math.sin(normalRadians.y), Slot._helpPoint, true)
      normalRadians.y = normalAngle(Slot._helpPoint.y, Slot._helpPoint.x)
    end
  end
  return intersectionCount
end

function Slot:getDisplayFrameAt(index)
  return displayAt(self, index)
end

return Slot
