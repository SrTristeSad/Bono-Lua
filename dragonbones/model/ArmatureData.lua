-- Direct port of DragonBonesJS:
-- DragonBones/src/dragonBones/model/ArmatureData.ts
-- Commit: 64b6c69ae35777c2404be68c9192e2c56906079e
-- Copyright (c) 2012-2025 DragonBones team and other contributors.
-- MIT license: see LICENSE-DRAGONBONES.
--
-- All four classes from the original file are retained: ArmatureData,
-- BoneData, SurfaceData and SlotData. Arrays have Lua's 1-based indices;
-- public setCacheFrame/getCacheFrame offsets remain zero-based like TS.
local BaseObject = require("dragonbones.core.BaseObject")
local Core = require("dragonbones.core.Enums")
local Rectangle = require("dragonbones.geom.Rectangle")
local Transform = require("dragonbones.geom.Transform")
local ColorTransform = require("dragonbones.geom.ColorTransform")
local GeometryData = require("dragonbones.model.DisplayData").GeometryData

local JSArray = require("dragonbones.core.JSArray")
local JSMap = require("dragonbones.core.JSMap")

local function clearArray(array) array.length = 0 end
local function returnArrayToPool(array)
  local index = 1
  while index <= array.length do
    array[index]:returnToPool()
    index = index + 1
  end
end
local function contains(array, value)
  for index = 1, array.length do
    local current = array[index]
    -- indexOf skips holes. Entries in these model lists are object references.
    if current ~= nil and rawequal(current, value) then return true end
  end
  return false
end
local function returnMapToPool(map)
  for _,name in ipairs(JSMap.keys(map)) do
    local object = map[name]
    if object ~= nil then
      object:returnToPool()
      JSMap.remove(map,name)
    end
  end
end

-- The getters expose both JS null and undefined as nil, but their strict-null
-- branches must differ. State belongs to the instance, not a global registry.
local NULL, UNDEFINED = {}, {}
local function initializeReferences(self, keys)
  local state = {}
  for _,key in ipairs(keys) do state[key] = UNDEFINED end
  rawset(self,"_referenceState",state)
end
local function reference(self,key)
  local value = rawget(self,"_referenceState")[key]
  if rawequal(value,NULL) or rawequal(value,UNDEFINED) then return nil end
  return value
end
local function setReference(self,key,value)
  rawget(self,"_referenceState")[key] = value == nil and NULL or value
end
local function isNullReference(self,key)
  local state = rawget(self,"_referenceState")
  if state ~= nil then return rawequal(state[key],NULL) end
  return self[key] == nil -- boundary records use nil for an explicit null
end
local function numberOrNaN(value)
  if value == nil then return 0/0 end
  return value
end
local function arrayAtZero(array,index)
  if array == nil then error("Cached frame array is absent") end
  if index ~= index or index < 0 or index == math.huge or index ~= math.floor(index) then return nil end
  return array[index+1]
end

local function warnDuplicate(label, name)
  -- The original calls console.warn; on Lua emit to stderr.
  io.stderr:write("Same " .. label .. ": " .. tostring(name) .. "\n")
end

local ArmatureData = {}
function ArmatureData.__index(self,key)
  if key == "defaultSkin" or key == "defaultAnimation" then return reference(self,key) end
  return ArmatureData[key]
end
function ArmatureData.__newindex(self,key,value)
  if key == "defaultSkin" or key == "defaultAnimation" then setReference(self,key,value)
  else rawset(self,key,value) end
end
setmetatable(ArmatureData, {__index = BaseObject})

function ArmatureData.toString()
  return "[class dragonBones.ArmatureData]"
end

function ArmatureData.new()
  local self = BaseObject.new(ArmatureData)
  initializeReferences(self,{"defaultSkin","defaultAnimation"})
  -- TS instance field initializers run once per constructed object.
  self.aabb = Rectangle.new()
  self.animationNames = JSArray.new()
  self.sortedBones = JSArray.new()
  self.sortedSlots = JSArray.new()
  self.defaultActions = JSArray.new()
  self.actions = JSArray.new()
  self.bones = JSMap.new()
  self.slots = JSMap.new()
  self.constraints = JSMap.new()
  self.skins = JSMap.new()
  self.animations = JSMap.new()
  self.canvas = nil
  self.userData = nil
  return self
end

function ArmatureData:_onClear()
  returnArrayToPool(self.defaultActions)
  returnArrayToPool(self.actions)

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
  local total = self.sortedBones.length
  if total <= 0 then
    return
  end

  local sortHelper = JSArray.new()
  sortHelper.length = total
  for i=1,total do sortHelper[i] = self.sortedBones[i] end
  local index = 1
  local count = 0
  clearArray(self.sortedBones)

  while count < total do
    local bone = sortHelper[index]
    index = index + 1
    if index > total then index = 1 end

    if not contains(self.sortedBones, bone) then
      local flag = false
      for _,name in ipairs(JSMap.keys(self.constraints)) do
        local constraint = self.constraints[name]
        if constraint ~= nil and rawequal(constraint.root, bone)
          and not contains(self.sortedBones, constraint.target) then
          flag = true
          break
        end
      end

      if not flag and
          (isNullReference(bone,"parent") or contains(self.sortedBones, bone.parent)) then
        self.sortedBones[self.sortedBones.length+1] = bone
        count = count + 1
      end
    end
  end
end

function ArmatureData:cacheFrames(frameRate)
  if numberOrNaN(self.cacheFrameRate) > 0 then -- TODO clear cache: original source
    return
  end

  self.cacheFrameRate = frameRate
  for _,name in ipairs(JSMap.keys(self.animations)) do
    local animation = self.animations[name]
    if animation ~= nil then animation:cacheFrames(self.cacheFrameRate) end
  end
end

function ArmatureData:setCacheFrame(globalTransformMatrix, transform)
  local dataArray = self.parent.cachedFrames
  local arrayOffset = dataArray.length -- The returned offset remains zero-based.
  dataArray.length = dataArray.length + 10
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
  arrayOffset = numberOrNaN(arrayOffset)
  globalTransformMatrix.a = arrayAtZero(dataArray,arrayOffset)
  globalTransformMatrix.b = arrayAtZero(dataArray,arrayOffset+1)
  globalTransformMatrix.c = arrayAtZero(dataArray,arrayOffset+2)
  globalTransformMatrix.d = arrayAtZero(dataArray,arrayOffset+3)
  globalTransformMatrix.tx = arrayAtZero(dataArray,arrayOffset+4)
  globalTransformMatrix.ty = arrayAtZero(dataArray,arrayOffset+5)
  transform.rotation = arrayAtZero(dataArray,arrayOffset+6)
  transform.skew = arrayAtZero(dataArray,arrayOffset+7)
  transform.scaleX = arrayAtZero(dataArray,arrayOffset+8)
  transform.scaleY = arrayAtZero(dataArray,arrayOffset+9)
  transform.x = globalTransformMatrix.tx
  transform.y = globalTransformMatrix.ty
end

function ArmatureData:addBone(value)
  if self.bones[value.name] ~= nil then
    warnDuplicate("bone", value.name)
    return
  end
  self.bones[value.name] = value
  self.sortedBones[self.sortedBones.length+1] = value
end

function ArmatureData:addSlot(value)
  if self.slots[value.name] ~= nil then
    warnDuplicate("slot", value.name)
    return
  end
  self.slots[value.name] = value
  self.sortedSlots[self.sortedSlots.length+1] = value
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
  if isNullReference(self,"defaultSkin") then
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
  self.animationNames[self.animationNames.length+1] = value.name
  if isNullReference(self,"defaultAnimation") then
    self.defaultAnimation = value
  end
end

function ArmatureData:addAction(value, isDefault)
  if isDefault then
    self.defaultActions[self.defaultActions.length+1] = value
  else
    self.actions[self.actions.length+1] = value
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
function BoneData.__index(self,key)
  if key == "parent" then return reference(self,key) end
  return BoneData[key]
end
function BoneData.__newindex(self,key,value)
  if key == "parent" then setReference(self,key,value)
  else rawset(self,key,value) end
end
setmetatable(BoneData, {__index = BaseObject})

function BoneData.toString()
  return "[class dragonBones.BoneData]"
end

function BoneData.new(classType)
  local self = BaseObject.new(classType or BoneData)
  initializeReferences(self,{"parent"})
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
function SurfaceData.__index(self,key)
  local value = rawget(SurfaceData,key)
  if value ~= nil then return value end
  return BoneData.__index(self,key)
end
SurfaceData.__newindex = BoneData.__newindex
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
