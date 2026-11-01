-- Direct port of DragonBonesJS:
-- DragonBones/src/dragonBones/model/ArmatureData.ts
-- Commit: 64b6c69ae35777c2404be68c9192e2c56906079e
-- Copyright (c) 2012-2025 DragonBones team and other contributors.
-- MIT license: see LICENSE-DRAGONBONES.
--
-- All four classes from the original file are retained: ArmatureData,
-- BoneData, SurfaceData and SlotData. Arrays have Lua's 1-based indices;
-- public setCacheFrame/getCacheFrame offsets remain zero-based like TS.
local BaseObject = require("dragonbones.original.core.BaseObject")
local Core = require("dragonbones.original.core.DragonBones")
local Rectangle = require("dragonbones.original.geom.Rectangle")
local Transform = require("dragonbones.original.geom.Transform")
local ColorTransform = require("dragonbones.original.geom.ColorTransform")
local GeometryData = require("dragonbones.original.model.DisplayData").GeometryData

local function clearArray(array)
  for i = #array, 1, -1 do
    array[i] = nil
  end
end

-- Keep the original linear contains/indexOf semantics in sortedBones.
local function contains(array, value)
  for _, current in ipairs(array) do
    if current == value then return true end
  end
  return false
end

local function returnMapToPool(map)
  for name, object in pairs(map) do
    object:returnToPool()
    map[name] = nil
  end
end

local function warnDuplicate(label, name)
  -- The original calls console.warn; on Lua emit to stderr.
  io.stderr:write("Same " .. label .. ": " .. tostring(name) .. "\n")
end

local ArmatureData = {}
ArmatureData.__index = ArmatureData
setmetatable(ArmatureData, {__index = BaseObject})

function ArmatureData.toString()
  return "[class dragonBones.ArmatureData]"
end

function ArmatureData.new()
  local self = BaseObject.new(ArmatureData)
  -- TS instance field initializers run once per constructed object.
  self.aabb = Rectangle.new()
  self.animationNames = {}
  self.sortedBones = {}
  self.sortedSlots = {}
  self.defaultActions = {}
  self.actions = {}
  self.bones = {}
  self.slots = {}
  self.constraints = {}
  self.skins = {}
  self.animations = {}
  self.canvas = nil
  self.userData = nil
  return self
end

function ArmatureData:_onClear()
  for _, action in ipairs(self.defaultActions) do
    action:returnToPool()
  end
  for _, action in ipairs(self.actions) do
    action:returnToPool()
  end

  returnMapToPool(self.bones)
  returnMapToPool(self.slots)
  returnMapToPool(self.constraints)
  returnMapToPool(self.skins)
  returnMapToPool(self.animations)

  if self.canvas ~= nil then
    self.canvas:returnToPool()
  end
  if self.userData ~= nil then
    self.userData:returnToPool()
  end

  self.type = Core.ArmatureType.Armature
  self.frameRate = 0
  self.cacheFrameRate = 0
  self.scale = 1.0
  self.name = ""
  self.aabb:clear()
  clearArray(self.animationNames)
  clearArray(self.sortedBones)
  clearArray(self.sortedSlots)
  clearArray(self.defaultActions)
  clearArray(self.actions)
  self.defaultSkin = nil
  self.defaultAnimation = nil
  self.canvas = nil
  self.userData = nil
  self.parent = nil
end

-- Preserves the source's round-robin dependency sort, including the two
-- original waiting conditions (constraint target and parent bone).
-- The source itself does not detect cyclic dependencies. Neither do we.
function ArmatureData:sortBones()
  local total = #self.sortedBones
  if total <= 0 then
    return
  end

  local sortHelper = {}
  for i, bone in ipairs(self.sortedBones) do
    sortHelper[i] = bone
  end
  local index = 1
  local count = 0
  clearArray(self.sortedBones)

  while count < total do
    local bone = sortHelper[index]
    index = index + 1
    if index > total then index = 1 end

    if not contains(self.sortedBones, bone) then
      local flag = false
      for _, constraint in pairs(self.constraints) do
        if constraint.root == bone
          and not contains(self.sortedBones, constraint.target) then
          flag = true
          break
        end
      end

      if not flag and
          (bone.parent == nil or contains(self.sortedBones, bone.parent)) then
        self.sortedBones[#self.sortedBones+1] = bone
        count = count + 1
      end
    end
  end
end

function ArmatureData:cacheFrames(frameRate)
  if self.cacheFrameRate > 0 then -- TODO clear cache: original source
    return
  end

  self.cacheFrameRate = frameRate
  for _, animation in pairs(self.animations) do
    animation:cacheFrames(self.cacheFrameRate)
  end
end

function ArmatureData:setCacheFrame(globalTransformMatrix, transform)
  local dataArray = self.parent.cachedFrames
  local arrayOffset = #dataArray -- The returned offset remains zero-based.
  dataArray[arrayOffset+1] = globalTransformMatrix.a
  dataArray[arrayOffset+2] = globalTransformMatrix.b
  dataArray[arrayOffset+3] = globalTransformMatrix.c
  dataArray[arrayOffset+4] = globalTransformMatrix.d
  dataArray[arrayOffset+5] = globalTransformMatrix.tx
  dataArray[arrayOffset+6] = globalTransformMatrix.ty
  dataArray[arrayOffset+7] = transform.rotation
  dataArray[arrayOffset+8] = transform.skew
  dataArray[arrayOffset+9] = transform.scaleX
  dataArray[arrayOffset+10] = transform.scaleY
  return arrayOffset
end

function ArmatureData:getCacheFrame(globalTransformMatrix, transform, arrayOffset)
  local dataArray = self.parent.cachedFrames
  globalTransformMatrix.a = dataArray[arrayOffset+1]
  globalTransformMatrix.b = dataArray[arrayOffset+2]
  globalTransformMatrix.c = dataArray[arrayOffset+3]
  globalTransformMatrix.d = dataArray[arrayOffset+4]
  globalTransformMatrix.tx = dataArray[arrayOffset+5]
  globalTransformMatrix.ty = dataArray[arrayOffset+6]
  transform.rotation = dataArray[arrayOffset+7]
  transform.skew = dataArray[arrayOffset+8]
  transform.scaleX = dataArray[arrayOffset+9]
  transform.scaleY = dataArray[arrayOffset+10]
  transform.x = globalTransformMatrix.tx
  transform.y = globalTransformMatrix.ty
end

function ArmatureData:addBone(value)
  if self.bones[value.name] ~= nil then
    warnDuplicate("bone", value.name)
    return
  end
  self.bones[value.name] = value
  self.sortedBones[#self.sortedBones+1] = value
end

function ArmatureData:addSlot(value)
  if self.slots[value.name] ~= nil then
    warnDuplicate("slot", value.name)
    return
  end
  self.slots[value.name] = value
  self.sortedSlots[#self.sortedSlots+1] = value
end

function ArmatureData:addConstraint(value)
  if self.constraints[value.name] ~= nil then
    warnDuplicate("constraint", value.name)
    return
  end
  self.constraints[value.name] = value
end

function ArmatureData:addSkin(value)
  if self.skins[value.name] ~= nil then
    warnDuplicate("skin", value.name)
    return
  end
  value.parent = self
  self.skins[value.name] = value
  if self.defaultSkin == nil then
    self.defaultSkin = value
  end
  if value.name == "default" then
    self.defaultSkin = value
  end
end

function ArmatureData:addAnimation(value)
  if self.animations[value.name] ~= nil then
    warnDuplicate("animation", value.name)
    return
  end
  value.parent = self
  self.animations[value.name] = value
  self.animationNames[#self.animationNames+1] = value.name
  if self.defaultAnimation == nil then
    self.defaultAnimation = value
  end
end

function ArmatureData:addAction(value, isDefault)
  if isDefault then
    self.defaultActions[#self.defaultActions+1] = value
  else
    self.actions[#self.actions+1] = value
  end
end

function ArmatureData:getBone(boneName)
  return self.bones[boneName]
end

function ArmatureData:getSlot(slotName)
  return self.slots[slotName]
end

function ArmatureData:getConstraint(constraintName)
  return self.constraints[constraintName]
end

function ArmatureData:getSkin(skinName)
  return self.skins[skinName]
end

function ArmatureData:getMesh(skinName, slotName, meshName)
  local skin = self:getSkin(skinName)
  if skin == nil then return nil end
  return skin:getDisplay(slotName, meshName)
end

function ArmatureData:getAnimation(animationName)
  return self.animations[animationName]
end

local BoneData = {}
BoneData.__index = BoneData
setmetatable(BoneData, {__index = BaseObject})

function BoneData.toString()
  return "[class dragonBones.BoneData]"
end

function BoneData.new(classType)
  local self = BaseObject.new(classType or BoneData)
  self.transform = Transform.new()
  self.userData = nil
  return self
end

function BoneData:_onClear()
  if self.userData ~= nil then
    self.userData:returnToPool()
  end

  self.inheritTranslation = false
  self.inheritRotation = false
  self.inheritScale = false
  self.inheritReflection = false
  self.type = Core.BoneType.Bone
  self.length = 0.0
  self.alpha = 1.0
  self.name = ""
  self.transform:identity()
  self.userData = nil
  self.parent = nil
end

local SurfaceData = {}
SurfaceData.__index = SurfaceData
setmetatable(SurfaceData, {__index = BoneData})

function SurfaceData.toString()
  return "[class dragonBones.SurfaceData]"
end

function SurfaceData.new()
  local self = BoneData.new(SurfaceData)
  self.geometry = GeometryData.new()
  return self
end

function SurfaceData:_onClear()
  BoneData._onClear(self)
  self.type = Core.BoneType.Surface
  self.segmentX = 0
  self.segmentY = 0
  self.geometry:clear()
end

local SlotData = {}
SlotData.__index = SlotData
setmetatable(SlotData, {__index = BaseObject})

-- These are static fields/methods on the original SlotData class.
SlotData.DEFAULT_COLOR = ColorTransform.new()

function SlotData.createColor()
  return ColorTransform.new()
end

function SlotData.toString()
  return "[class dragonBones.SlotData]"
end

function SlotData.new()
  local self = BaseObject.new(SlotData)
  self.color = nil
  self.userData = nil
  return self
end

function SlotData:_onClear()
  if self.userData ~= nil then
    self.userData:returnToPool()
  end

  self.blendMode = Core.BlendMode.Normal
  self.displayIndex = 0
  self.zOrder = 0
  self.zIndex = 0
  self.alpha = 1.0
  self.name = ""
  -- Original does not pool the ColorTransform referenced by slot.color.
  self.color = nil
  self.userData = nil
  self.parent = nil
end

return {
  ArmatureData = ArmatureData,
  BoneData = BoneData,
  SurfaceData = SurfaceData,
  SlotData = SlotData
}
