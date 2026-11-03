-- Direct port of DragonBonesJS:
-- DragonBones/src/dragonBones/model/AnimationData.ts
-- Commit: 64b6c69ae35777c2404be68c9192e2c56906079e
-- Copyright (c) 2012-2025 DragonBones team and other contributors.
-- MIT license: see LICENSE-DRAGONBONES.
--
-- All three classes from the source file are ported:
-- AnimationData, TimelineData, AnimationTimelineData.
-- Map tables and indexed Lua arrays translate TS objects and JS arrays.
local BaseObject = require("dragonbones.core.BaseObject")
local Core = require("dragonbones.core.Enums")

local JSArray = require("dragonbones.core.JSArray")
local JSMap = require("dragonbones.core.JSMap")

local function clearMapReturningTimelines(map)
  for _, name in ipairs(JSMap.keys(map)) do
    local timelines = map[name]
    if timelines ~= nil then
      local index = 1
      while index <= timelines.length do
        timelines[index]:returnToPool()
        index = index + 1
      end
      JSMap.remove(map, name)
    end
  end
end

local function clearMap(map)
  for _, name in ipairs(JSMap.keys(map)) do JSMap.remove(map, name) end
end

local function appendUnique(map, name, timeline)
  local timelines = map[name]
  if timelines == nil then
    timelines = JSArray.new()
    map[name] = timelines
  end
  for index = 1, timelines.length do
    if rawequal(timelines[index], timeline) then return end
  end
  timelines[timelines.length + 1] = timeline
end

local AnimationData = {}
AnimationData.__index = AnimationData
setmetatable(AnimationData, {__index = BaseObject})

function AnimationData.toString()
  return "[class dragonBones.AnimationData]"
end

function AnimationData.new()
  local self = BaseObject.new(AnimationData)
  -- Original JS array length is a separate writable property; this one
  -- contains deliberate holes after cacheFrames(), so # cannot represent it.
  self.cachedFrames = JSArray.new()
  self.boneTimelines = JSMap.new()
  self.slotTimelines = JSMap.new()
  self.constraintTimelines = JSMap.new()
  self.animationTimelines = JSMap.new()
  self.boneCachedFrameIndices = JSMap.new()
  self.slotCachedFrameIndices = JSMap.new()
  self.actionTimeline = nil
  self.zOrderTimeline = nil
  return self
end

function AnimationData:_onClear()
  clearMapReturningTimelines(self.boneTimelines)
  clearMapReturningTimelines(self.slotTimelines)
  clearMapReturningTimelines(self.constraintTimelines)
  clearMapReturningTimelines(self.animationTimelines)

  clearMap(self.boneCachedFrameIndices)
  clearMap(self.slotCachedFrameIndices)

  if self.actionTimeline ~= nil then
    self.actionTimeline:returnToPool()
  end
  if self.zOrderTimeline ~= nil then
    self.zOrderTimeline:returnToPool()
  end

  self.frameIntOffset = 0
  self.frameFloatOffset = 0
  self.frameOffset = 0
  self.blendType = Core.AnimationBlendType.None
  self.frameCount = 0
  self.playTimes = 0
  self.duration = 0.0
  self.scale = 1.0
  self.fadeInTime = 0.0
  self.cacheFrameRate = 0.0
  self.name = ""

  -- TS: cachedFrames.length = 0; preserve this array's identity.
  self.cachedFrames.length = 0

  self.actionTimeline = nil
  self.zOrderTimeline = nil
  self.parent = nil
end

-- Numeric fields without TS initializers read as undefined before borrow.
-- In JS numeric arithmetic/comparison that value becomes NaN, not a Lua error.
local function numberOrNaN(value)
  if value == nil then return 0/0 end
  return value
end

function AnimationData:cacheFrames(frameRate)
  if numberOrNaN(self.cacheFrameRate) > 0.0 then -- TODO clear cache, upstream
    return
  end

  local rate = math.ceil(numberOrNaN(frameRate) * numberOrNaN(self.scale))
  -- Math.max propagates NaN; LuaJIT math.max need not do so.
  self.cacheFrameRate = rate ~= rate and rate or math.max(rate, 1.0)
  local cacheFrameCount = math.ceil(self.cacheFrameRate * numberOrNaN(self.duration)) + 1
  self.cachedFrames.length = cacheFrameCount

  -- Pinned source uses this.cacheFrames.length: the function has arity 1.
  -- This assignment occurs even for count 0, extending cachedFrames to 1.
  -- Do not initialize every slot or clamp the loop to cacheFrameCount.
  self.cachedFrames[1] = false

  local bones = self.parent.sortedBones
  local index = 1
  while index <= bones.length do
    local bone = bones[index]
    local indices = JSArray.new()
    indices.length = cacheFrameCount
    for i = 1, cacheFrameCount do
      indices[i] = -1
    end
    self.boneCachedFrameIndices[bone.name] = indices
    index = index + 1
  end

  local slots = self.parent.sortedSlots
  index = 1
  while index <= slots.length do
    local slot = slots[index]
    local indices = JSArray.new()
    indices.length = cacheFrameCount
    for i = 1, cacheFrameCount do
      indices[i] = -1
    end
    self.slotCachedFrameIndices[slot.name] = indices
    index = index + 1
  end
end

function AnimationData:addBoneTimeline(timelineName, timeline)
  appendUnique(self.boneTimelines, timelineName, timeline)
end

function AnimationData:addSlotTimeline(timelineName, timeline)
  appendUnique(self.slotTimelines, timelineName, timeline)
end

function AnimationData:addConstraintTimeline(timelineName, timeline)
  appendUnique(self.constraintTimelines, timelineName, timeline)
end

function AnimationData:addAnimationTimeline(timelineName, timeline)
  appendUnique(self.animationTimelines, timelineName, timeline)
end

function AnimationData:getBoneTimelines(timelineName)
  return self.boneTimelines[timelineName]
end

function AnimationData:getSlotTimelines(timelineName)
  return self.slotTimelines[timelineName]
end

function AnimationData:getConstraintTimelines(timelineName)
  return self.constraintTimelines[timelineName]
end

function AnimationData:getAnimationTimelines(timelineName)
  return self.animationTimelines[timelineName]
end

function AnimationData:getBoneCachedFrameIndices(boneName)
  return self.boneCachedFrameIndices[boneName]
end

function AnimationData:getSlotCachedFrameIndices(slotName)
  return self.slotCachedFrameIndices[slotName]
end

local TimelineData = {}
TimelineData.__index = TimelineData
setmetatable(TimelineData, {__index = BaseObject})

function TimelineData.toString()
  return "[class dragonBones.TimelineData]"
end

function TimelineData.new(classType)
  return BaseObject.new(classType or TimelineData)
end

function TimelineData:_onClear()
  self.type = Core.TimelineType.BoneAll
  self.offset = 0
  self.frameIndicesOffset = -1
end

local AnimationTimelineData = {}
AnimationTimelineData.__index = AnimationTimelineData
setmetatable(AnimationTimelineData, {__index = TimelineData})

function AnimationTimelineData.toString()
  return "[class dragonBones.AnimationTimelineData]"
end

function AnimationTimelineData.new()
  return TimelineData.new(AnimationTimelineData)
end

function AnimationTimelineData:_onClear()
  TimelineData._onClear(self)
  self.x = 0.0
  self.y = 0.0
end

return {
  AnimationData = AnimationData,
  TimelineData = TimelineData,
  AnimationTimelineData = AnimationTimelineData
}
