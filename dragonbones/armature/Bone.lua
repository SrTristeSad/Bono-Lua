-- Faithful algorithmic port of DragonBones/src/dragonBones/armature/Bone.ts
-- Pinned DragonBonesJS revision 64b6c69ae35777c2404be68c9192e2c56906079e
-- Copyright (c) 2012-2025 DragonBones team and other contributors.
-- MIT License: see LICENSE-DRAGONBONES.
-- Armature registry is real but partial; Surface/solvers/slots are pending.
-- See contracts/BoneRuntime.md for the compared domain.
local BaseObject = require("dragonbones.core.BaseObject")
local TransformObject = require("dragonbones.armature.TransformObject")
local Transform = require("dragonbones.geom.Transform")
local DragonBones = require("dragonbones.core.DragonBones")

local Bone = {}
setmetatable(Bone, { __index = TransformObject })

-- Model the original property accessors without storing shadow fields.
-- An absent visible field is intentional: all writes go through the setter.
function Bone.__index(self, key)
  if key == 'boneData' then return rawget(self, '_boneData') end
  if key == 'visible' then return rawget(self, '_visible') end
  if key == 'name' then return self._boneData.name end
  if key == 'parent' then return rawget(self, '_parent') end
  local member = rawget(Bone, key)
  if member ~= nil then return member end
  return TransformObject.__index(self, key)
end
function Bone.__newindex(self, key, value)
  if key == 'visible' then
    if self._visible == value then return end
    self._visible = value
    local slots = self._armature:getSlots()
    local i = 1
    while i <= slots.length do
      local slot = slots[i]
      if slot.parent == self then slot:_updateVisible() end
      i = i + 1
    end
  elseif key == 'boneData' or key == 'name' or key == 'parent' then
    error('Readonly property: '..key)
  else
    TransformObject.__newindex(self, key, value)
  end
end

function Bone.toString()
  return "[class dragonBones.Bone]"
end

function Bone.new()
  local object = TransformObject.new(Bone)
  object.animationPose = Transform.new()
  return object
end

function Bone:_onClear()
  TransformObject._onClear(self)

  self.offsetMode = DragonBones.OffsetMode.Additive
  self.animationPose:identity()

  self._transformDirty = false
  self._childrenTransformDirty = false
  self._localDirty = true
  self._hasConstraint = false
  self._visible = true
  self._cachedFrameIndex = -1
  self._boneData = nil
  self._parent = nil
  self._cachedFrameIndices = nil
end

function Bone:_updateGlobalTransformMatrix(isCache)
  -- Keep source calculation order. Float promotion in unary minus preserves
  -- JS negative zero even when a Lua 5.4 caller assigned an integer zero.
  local boneData = self._boneData
  local global = self.global
  local globalTransformMatrix = self.globalTransformMatrix
  local origin = self.origin
  local offset = self.offset
  local animationPose = self.animationPose
  local parent = self._parent

  local flipX = self._armature.flipX
  local flipY = self._armature.flipY == DragonBones.yDown
  local inherit = parent ~= nil
  local rotation = 0.0

  if self.offsetMode == DragonBones.OffsetMode.Additive then
    if origin ~= nil then
      global.x = origin.x + offset.x + animationPose.x
      global.scaleX = origin.scaleX * offset.scaleX * animationPose.scaleX
      global.scaleY = origin.scaleY * offset.scaleY * animationPose.scaleY

      if DragonBones.yDown then
        global.y = origin.y + offset.y + animationPose.y
        global.skew = origin.skew + offset.skew + animationPose.skew
        global.rotation = origin.rotation + offset.rotation + animationPose.rotation
      else
        global.y = origin.y - offset.y + animationPose.y
        global.skew = origin.skew - offset.skew + animationPose.skew
        global.rotation = origin.rotation - offset.rotation + animationPose.rotation
      end
    else
      global:copyFrom(offset)
      if not DragonBones.yDown then
        global.y = -(global.y * 1.0)
        global.skew = -(global.skew * 1.0)
        global.rotation = -(global.rotation * 1.0)
      end
      global:add(animationPose)
    end
  elseif self.offsetMode == DragonBones.OffsetMode.None then
    if origin ~= nil then
      global:copyFrom(origin):add(animationPose)
    else
      global:copyFrom(animationPose)
    end
  else
    inherit = false
    global:copyFrom(offset)
    if not DragonBones.yDown then
      global.y = -(global.y * 1.0)
      global.skew = -(global.skew * 1.0)
      global.rotation = -(global.rotation * 1.0)
    end
  end

  if inherit then
    local isSurface = parent._boneData.type == DragonBones.BoneType.Surface
    local surfaceBone = isSurface and parent._bone or nil
    local parentMatrix = isSurface
      and parent:_getGlobalTransformMatrix(global.x, global.y)
      or parent.globalTransformMatrix

    if boneData.inheritScale and (not isSurface or surfaceBone ~= nil) then
      if isSurface then
        if boneData.inheritRotation then
          global.rotation = global.rotation + parent.global.rotation
        end

        surfaceBone:updateGlobalTransform()
        global.scaleX = global.scaleX * surfaceBone.global.scaleX
        global.scaleY = global.scaleY * surfaceBone.global.scaleY
        parentMatrix:transformPoint(global.x, global.y, global)
        global:toMatrix(globalTransformMatrix)

        if boneData.inheritTranslation then
          global.x = globalTransformMatrix.tx
          global.y = globalTransformMatrix.ty
        else
          globalTransformMatrix.tx = global.x
          globalTransformMatrix.ty = global.y
        end
      else
        if not boneData.inheritRotation then
          parent:updateGlobalTransform()
          if flipX and flipY then
            rotation = global.rotation - (parent.global.rotation + math.pi)
          elseif flipX then
            rotation = global.rotation + parent.global.rotation + math.pi
          elseif flipY then
            rotation = global.rotation + parent.global.rotation
          else
            rotation = global.rotation - parent.global.rotation
          end
          global.rotation = rotation
        end

        global:toMatrix(globalTransformMatrix)
        globalTransformMatrix:concat(parentMatrix)

        if boneData.inheritTranslation then
          global.x = globalTransformMatrix.tx
          global.y = globalTransformMatrix.ty
        else
          globalTransformMatrix.tx = global.x
          globalTransformMatrix.ty = global.y
        end

        if isCache then
          global:fromMatrix(globalTransformMatrix)
        else
          self._globalDirty = true
        end
      end
    else
      if boneData.inheritTranslation then
        local x = global.x
        local y = global.y
        global.x = parentMatrix.a * x + parentMatrix.c * y + parentMatrix.tx
        global.y = parentMatrix.b * x + parentMatrix.d * y + parentMatrix.ty
      else
        if flipX then global.x = -(global.x * 1.0) end
        if flipY then global.y = -(global.y * 1.0) end
      end

      if boneData.inheritRotation then
        parent:updateGlobalTransform()
        if parent.global.scaleX < 0.0 then
          rotation = global.rotation + parent.global.rotation + math.pi
        else
          rotation = global.rotation + parent.global.rotation
        end

        if parentMatrix.a * parentMatrix.d - parentMatrix.b * parentMatrix.c < 0.0 then
          rotation = rotation - global.rotation * 2.0
          if flipX ~= flipY or boneData.inheritReflection then
            global.skew = global.skew + math.pi
          end
          if not DragonBones.yDown then
            global.skew = -(global.skew * 1.0)
          end
        end
        global.rotation = rotation
      elseif flipX or flipY then
        if flipX and flipY then
          rotation = global.rotation + math.pi
        else
          if flipX then
            rotation = math.pi - global.rotation
          else
            rotation = -(global.rotation * 1.0)
          end
          global.skew = global.skew + math.pi
        end
        global.rotation = rotation
      end

      global:toMatrix(globalTransformMatrix)
    end
  else
    if flipX or flipY then
      if flipX then global.x = -(global.x * 1.0) end
      if flipY then global.y = -(global.y * 1.0) end
      if flipX and flipY then
        rotation = global.rotation + math.pi
      else
        if flipX then
          rotation = math.pi - global.rotation
        else
          rotation = -(global.rotation * 1.0)
        end
        global.skew = global.skew + math.pi
      end
      global.rotation = rotation
    end
    global:toMatrix(globalTransformMatrix)
  end
end

function Bone:_updateAlpha()
  if self._parent ~= nil then
    self._globalAlpha = self._alpha * self._parent._globalAlpha
  else
    self._globalAlpha = self._alpha * self._armature._globalAlpha
  end
end

function Bone:init(boneData, armatureValue)
  if self._boneData ~= nil then return end
  self._boneData = boneData
  self._armature = armatureValue
  self._alpha = self._boneData.alpha

  if self._boneData.parent ~= nil then
    self._parent = self._armature:getBone(self._boneData.parent.name)
  end

  self._armature:_addBone(self)
  self.origin = self._boneData.transform
end

function Bone:update(cacheFrameIndex)
  if cacheFrameIndex >= 0 and self._cachedFrameIndices ~= nil then
    -- Index conversion only: JS cachedFrameIndices[0] == Lua [1].
    local cachedFrameIndex = self._cachedFrameIndices[cacheFrameIndex + 1]
    if cachedFrameIndex ~= nil and cachedFrameIndex >= 0 and self._cachedFrameIndex == cachedFrameIndex then
      self._transformDirty = false
    elseif cachedFrameIndex ~= nil and cachedFrameIndex >= 0 then
      self._transformDirty = true
      self._cachedFrameIndex = cachedFrameIndex
    else
      if self._hasConstraint then
        local i = 1
        while i <= self._armature._constraints.length do
          local constraint = self._armature._constraints[i]
          if constraint._root == self then constraint:update() end
          i = i + 1
        end
      end

      if self._transformDirty or (self._parent ~= nil and self._parent._childrenTransformDirty) then
        self._transformDirty = true
        self._cachedFrameIndex = -1
      elseif self._cachedFrameIndex >= 0 then
        self._transformDirty = false
        self._cachedFrameIndices[cacheFrameIndex + 1] = self._cachedFrameIndex
      else
        self._transformDirty = true
        self._cachedFrameIndex = -1
      end
    end
  else
    if self._hasConstraint then
      local i = 1
      while i <= self._armature._constraints.length do
        local constraint = self._armature._constraints[i]
        if constraint._root == self then constraint:update() end
        i = i + 1
      end
    end

    if self._transformDirty or (self._parent ~= nil and self._parent._childrenTransformDirty) then
      cacheFrameIndex = -1
      self._transformDirty = true
      self._cachedFrameIndex = -1
    end
  end

  if self._transformDirty then
    self._transformDirty = false
    self._childrenTransformDirty = true
    if self._cachedFrameIndex < 0 then
      local isCache = cacheFrameIndex >= 0
      if self._localDirty then
        self:_updateGlobalTransformMatrix(isCache)
      end
      if isCache and self._cachedFrameIndices ~= nil then
        local index = self._armature._armatureData:setCacheFrame(self.globalTransformMatrix, self.global)
        self._cachedFrameIndices[cacheFrameIndex + 1] = index
        self._cachedFrameIndex = index
      end
    else
      self._armature._armatureData:getCacheFrame(self.globalTransformMatrix, self.global, self._cachedFrameIndex)
    end
  elseif self._childrenTransformDirty then
    self._childrenTransformDirty = false
  end
  self._localDirty = true
end

function Bone:updateByConstraint()
  if self._localDirty then
    self._localDirty = false
    if self._transformDirty or (self._parent ~= nil and self._parent._childrenTransformDirty) then
      self:_updateGlobalTransformMatrix(true)
    end
    self._transformDirty = true
  end
end

function Bone:invalidUpdate()
  self._transformDirty = true
end

function Bone:contains(value)
  if value == self then return false end
  local ancestor = value
  while ancestor ~= self and ancestor ~= nil do
    ancestor = ancestor.parent
  end
  return ancestor == self
end

return Bone
