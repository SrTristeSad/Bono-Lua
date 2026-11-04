-- Partial port of Slot.ts, DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e.
-- Copyright (c) 2012-2025 DragonBones team and contributors; MIT.
-- All Slot bodies are represented; renderer hooks remain abstract.
-- Child Animation execution requires the future Animation runtime; see contract.
local BaseObject = require('dragonbones.core.BaseObject')
local TransformObject = require('dragonbones.armature.TransformObject')
local DisplayFrame = require('dragonbones.armature.DisplayFrame')
local Core = require('dragonbones.core.Enums')
local Matrix = require('dragonbones.geom.Matrix')
local ColorTransform = require('dragonbones.geom.ColorTransform')
local Array = require('dragonbones.core.JSArray')
local SkinData = require('dragonbones.model.SkinData')
local DragonBones = require('dragonbones.core.DragonBones')
local EventObject = require('dragonbones.event.EventObject')
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
local function nonNull(value,fallback)
  if value ~= nil then return value end
  return fallback
end
local function setDisplay(self,value)
  if rawequal(self._display,value) then return end
  if self._displayFrames.length == 0 then
    self.displayFrameCount = 1
    self._displayIndex = 0
  end
  self:replaceDisplay(value,self._displayIndex)
end
function Slot.__index(self,key)
  if key=='displayIndex' then return self._displayIndex end
  if key=='display' then return self._display end
  if key=='childArmature' then return self._childArmature end
  if key=='displayList' then
    local displays = Array.new()
    local i = 1
    while i <= self._displayFrames.length do
      displays[displays.length+1] = self._displayFrames[i].display
      i = i + 1
    end
    return displays
  end
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
  elseif key=='displayIndex' then self:_setDisplayIndex(value);self:update(-1)
  elseif key=='displayList' then
    self.displayFrameCount = value.length
    local i = 1
    while i <= value.length do self:replaceDisplay(value[i],i-1);i=i+1 end
  elseif key=='display' then setDisplay(self,value)
  elseif key=='childArmature' then
    if not rawequal(self._childArmature,value) then self.display=value end
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

function Slot:_updateDisplayData()
  local prevDisplayFrame = self._displayFrame
  local prevGeometryData = self._geometryData
  local prevTextureData = self._textureData
  local rawDisplayData, displayData = nil, nil

  self._displayFrame = nil
  self._geometryData = nil
  self._boundingBoxData = nil
  self._textureData = nil
  if self._displayIndex >= 0 and self._displayIndex < self._displayFrames.length then
    self._displayFrame = displayAt(self, self._displayIndex)
    rawDisplayData = self._displayFrame.rawDisplayData
    displayData = self._displayFrame.displayData
    self._geometryData = self._displayFrame:getGeometryData()
    self._boundingBoxData = self._displayFrame:getBoundingBox()
    self._textureData = self._displayFrame:getTextureData()
  end

  if not rawequal(self._displayFrame,prevDisplayFrame)
      or not rawequal(self._geometryData,prevGeometryData)
      or not rawequal(self._textureData,prevTextureData) then
    if self._geometryData == nil and self._textureData ~= nil then
      local imageDisplayData =
        (displayData ~= nil and displayData.type == Core.DisplayType.Image)
        and displayData or rawDisplayData
      local scale = self._textureData.parent.scale * self._armature._armatureData.scale
      local frame = self._textureData.frame
      self._pivotX = imageDisplayData.pivot.x
      self._pivotY = imageDisplayData.pivot.y
      local rect = frame or self._textureData.region
      local width, height = rect.width, rect.height
      if self._textureData.rotated and frame == nil then
        width, height = rect.height, rect.width
      end
      self._pivotX = self._pivotX * (width * scale)
      self._pivotY = self._pivotY * (height * scale)
      if frame ~= nil then
        self._pivotX = self._pivotX + frame.x * scale
        self._pivotY = self._pivotY + frame.y * scale
      end
      if rawDisplayData ~= nil and not rawequal(imageDisplayData,rawDisplayData) then
        rawDisplayData.transform:toMatrix(Slot._helpMatrix)
        Slot._helpMatrix:invert()
        Slot._helpMatrix:transformPoint(0.0, 0.0, Slot._helpPoint)
        self._pivotX = self._pivotX - Slot._helpPoint.x
        self._pivotY = self._pivotY - Slot._helpPoint.y

        imageDisplayData.transform:toMatrix(Slot._helpMatrix)
        Slot._helpMatrix:invert()
        Slot._helpMatrix:transformPoint(0.0, 0.0, Slot._helpPoint)
        self._pivotX = self._pivotX + Slot._helpPoint.x
        self._pivotY = self._pivotY + Slot._helpPoint.y
      end
      if not DragonBones.yDown then
        self._pivotY = (self._textureData.rotated
          and self._textureData.region.width or self._textureData.region.height)
          * scale - self._pivotY
      end
    else
      self._pivotX = 0.0
      self._pivotY = 0.0
    end

    if rawDisplayData ~= nil then
      self.origin = rawDisplayData.transform
    elseif displayData ~= nil then
      self.origin = displayData.transform
    else
      self.origin = nil
    end
    if self.origin ~= nil then
      self.global:copyFrom(self.origin):add(self.offset):toMatrix(self._localMatrix)
    else
      self.global:copyFrom(self.offset):toMatrix(self._localMatrix)
    end

    if not rawequal(self._geometryData,prevGeometryData) then
      self._geometryDirty = true
      self._verticesDirty = true
      if self._geometryData ~= nil then
        self._geometryBones.length = 0
        if self._geometryData.weight ~= nil then
          local bones = self._geometryData.weight.bones
          local length = bones.length
          for i = 1, length do
            self._geometryBones[self._geometryBones.length + 1] =
              self._armature:getBone(bones[i].name)
          end
        end
      else
        self._geometryBones.length = 0
        self._geometryData = nil
      end
    end
    self._textureDirty = not rawequal(self._textureData,prevTextureData)
    self._transformDirty = true
  end
end

local function replacementIndex(self,index)
  if index == nil then index = -1 end
  if index < 0 then
    index = self._displayIndex < 0 and 0 or self._displayIndex
  elseif index >= self._displayFrames.length then
    return nil
  end
  return index
end

function Slot:replaceRawDisplayData(displayData,index)
  index = replacementIndex(self,index)
  if index == nil then return end
  local frame = displayAt(self,index)
  if not rawequal(frame.rawDisplayData,displayData) then
    frame.deformVertices.length = 0
    frame.rawDisplayData = displayData
    if frame.rawDisplayData == nil then
      local skin = self._armature._armatureData.defaultSkin
      if skin ~= nil then
        local defaults = skin:getDisplays(self._slotData.name)
        if defaults ~= nil and index < defaults.length then
          local fallback = defaults[index + 1]
          if rawequal(fallback,SkinData.NULL) then frame.rawDisplayData = nil
          else frame.rawDisplayData = fallback end
        end
      end
    end
    if index == self._displayIndex then self._displayDataDirty = true end
  end
end

function Slot:replaceDisplayData(displayData,index)
  index = replacementIndex(self,index)
  if index == nil then return end
  local frame = displayAt(self,index)
  if not rawequal(frame.displayData,displayData) and not rawequal(frame.rawDisplayData,displayData) then
    frame.displayData = displayData
    if index == self._displayIndex then self._displayDataDirty = true end
  end
end

function Slot:replaceTextureData(textureData,index)
  index = replacementIndex(self,index)
  if index == nil then return end
  local frame = displayAt(self,index)
  if not rawequal(frame.textureData,textureData) then
    frame.textureData = textureData
    if index == self._displayIndex then self._displayDataDirty = true end
  end
end

function Slot:_updateDisplay()
  local prevDisplay = nonNull(self._display,self._rawDisplay)
  local prevChildArmature = self._childArmature

  if self._displayFrame ~= nil then
    self._display = self._displayFrame.display
    if self._display ~= nil and isArmature(self._display) then
      self._childArmature = self._display
      self._display = self._childArmature.display
    else
      self._childArmature = nil
    end
  else
    self._display = nil
    self._childArmature = nil
  end

  local currentDisplay = nonNull(self._display,self._rawDisplay)
  if not rawequal(currentDisplay,prevDisplay) then
    self._textureDirty = true
    self._visibleDirty = true
    self._blendModeDirty = true
    self._colorDirty = true
    self._transformDirty = true
    self:_onUpdateDisplay()
    self:_replaceDisplay(prevDisplay)
  end

  if not rawequal(self._childArmature,prevChildArmature) then
    if prevChildArmature ~= nil then
      prevChildArmature._parent = nil
      prevChildArmature.clock = nil
      if prevChildArmature.inheritAnimation then
        prevChildArmature.animation:reset()
      end
    end

    if self._childArmature ~= nil then
      self._childArmature._parent = self
      self._childArmature.clock = self._armature.clock
      if self._childArmature.inheritAnimation then
        if self._childArmature.cacheFrameRate == 0 then
          local cacheFrameRate = self._armature.cacheFrameRate
          if cacheFrameRate ~= 0 then
            self._childArmature.cacheFrameRate = cacheFrameRate
          end
        end
        if self._displayFrame ~= nil then
          local actions = nil
          local currentData = nonNull(self._displayFrame.displayData,self._displayFrame.rawDisplayData)
          if currentData ~= nil and currentData.type == Core.DisplayType.Armature then
            actions = currentData.actions
          end
          if actions ~= nil and actions.length > 0 then
            local i = 1
            while i <= actions.length do
              local action = actions[i]
              local eventObject = BaseObject.borrowObject(EventObject)
              EventObject.actionDataToInstance(action, eventObject, self._armature)
              eventObject.slot = self
              self._armature:_bufferAction(eventObject, false)
              i = i + 1
            end
          else
            self._childArmature.animation:play()
          end
        end
      end
    end
  end
end

function Slot:replaceDisplay(value, index)
  index = replacementIndex(self, index)
  if index == nil then return end
  local displayFrame = displayAt(self, index)
  if not rawequal(displayFrame.display,value) then
    local prevDisplay = displayFrame.display
    displayFrame.display = value
    if prevDisplay ~= nil and not rawequal(prevDisplay,self._rawDisplay)
        and not rawequal(prevDisplay,self._meshDisplay) and not self:_hasDisplay(prevDisplay) then
      if isArmature(prevDisplay) then
        -- The original intentionally does not dispose replaced armatures.
      else
        self:_disposeDisplay(prevDisplay, true)
      end
    end
    if value ~= nil and not rawequal(value,self._rawDisplay) and not rawequal(value,self._meshDisplay)
        and not self:_hasDisplay(prevDisplay) and not isArmature(value) then
      self:_initDisplay(value, true)
    end
    if index == self._displayIndex then self._displayDirty = true end
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

function Slot:update(cacheFrameIndex)
  if self._displayDataDirty then
    self:_updateDisplayData()
    self._displayDataDirty = false
  end
  if self._displayDirty then
    self:_updateDisplay()
    self._displayDirty = false
  end
  if self._geometryDirty or self._textureDirty then
    if self._display == nil or rawequal(self._display,self._rawDisplay)
        or rawequal(self._display,self._meshDisplay) then self:_updateFrame() end
    self._geometryDirty = false
    self._textureDirty = false
  end
  if self._display == nil then return end
  if self._visibleDirty then
    self:_updateVisible()
    self._visibleDirty = false
  end
  if self._blendModeDirty then
    self:_updateBlendMode()
    self._blendModeDirty = false
  end
  if self._colorDirty then
    self:_updateColor()
    self._colorDirty = false
  end
  if self._zOrderDirty then
    self:_updateZOrder()
    self._zOrderDirty = false
  end

  if self._geometryData ~= nil and rawequal(self._display,self._meshDisplay) then
    local isSkinned = self._geometryData.weight ~= nil
    local isSurface = self._parent._boneData.type ~= Core.BoneType.Bone
    if self._verticesDirty
        or (isSkinned and self:_isBonesUpdate())
        or (isSurface and self._parent._childrenTransformDirty) then
      self._verticesDirty = false
      self:_updateMesh()
    end
    if isSkinned or isSurface then return end
  end

  if cacheFrameIndex >= 0 and self._cachedFrameIndices ~= nil then
    local cached = self._cachedFrameIndices[cacheFrameIndex + 1]
    if cached ~= nil and cached >= 0 and self._cachedFrameIndex == cached then
      self._transformDirty = false
    elseif cached ~= nil and cached >= 0 then
      self._transformDirty = true
      self._cachedFrameIndex = cached
    elseif self._transformDirty or self._parent._childrenTransformDirty then
      self._transformDirty = true
      self._cachedFrameIndex = -1
    elseif self._cachedFrameIndex >= 0 then
      self._transformDirty = false
      self._cachedFrameIndices[cacheFrameIndex + 1] = self._cachedFrameIndex
    else
      self._transformDirty = true
      self._cachedFrameIndex = -1
    end
  elseif self._transformDirty or self._parent._childrenTransformDirty then
    cacheFrameIndex = -1
    self._transformDirty = true
    self._cachedFrameIndex = -1
  end

  if self._transformDirty then
    if self._cachedFrameIndex < 0 then
      local isCache = cacheFrameIndex >= 0
      self:_updateGlobalTransformMatrix(isCache)
      if isCache and self._cachedFrameIndices ~= nil then
        local index = self._armature._armatureData:setCacheFrame(
          self.globalTransformMatrix, self.global)
        self._cachedFrameIndices[cacheFrameIndex + 1] = index
        self._cachedFrameIndex = index
      end
    else
      self._armature._armatureData:getCacheFrame(
        self.globalTransformMatrix, self.global, self._cachedFrameIndex)
    end
    self:_updateTransform()
    self._transformDirty = false
  end
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

function Slot:getDisplay() return self._display end
function Slot:setDisplay(value) self.display=value end

return Slot
