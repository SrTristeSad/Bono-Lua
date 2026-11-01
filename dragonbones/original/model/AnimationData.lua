-- Direct port of DragonBonesJS:
-- DragonBones/src/dragonBones/model/AnimationData.ts
-- Commit: 64b6c69ae35777c2404be68c9192e2c56906079e
-- Copyright (c) 2012-2025 DragonBones team and other contributors.
-- MIT license: see LICENSE-DRAGONBONES.
--
-- All three classes from the source file are ported:
-- AnimationData, TimelineData, AnimationTimelineData.
-- Map tables and indexed Lua arrays translate TS objects and JS arrays.
local BaseObject = require("dragonbones.original.core.BaseObject")
local Core = require("dragonbones.original.core.DragonBones")

local function clearMapReturningTimelines(map)
  for name, timelines in pairs(map) do
    for _, timeline in ipairs(timelines) do
      timeline:returnToPool()
    end
    map[name] = nil
  end
end

local function clearMap(map)
  for name in pairs(map) do
    map[name] = nil
  end
end

local function clearArray(array)
  for i = #array, 1, -1 do
    array[i] = nil
  end
end

local function appendUnique(map, name, timeline)
  local timelines = map[name]
  if timelines == nil then
    timelines = {}
    map[name] = timelines
  end
  for _, item in ipairs(timelines) do
    if item == timeline then
      return
    end
  end
  timelines[#timelines + 1] = timeline
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
  self.cachedFrames = {length = 0}
  self.boneTimelines = {}
  self.slotTimelines = {}
  self.constraintTimelines = {}
  self.animationTimelines = {}
  self.boneCachedFrameIndices = {}
  self.slotCachedFrameIndices = {}
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
  for i = self.cachedFrames.length, 1, -1 do
    self.cachedFrames[i] = nil
  end
  self.cachedFrames.length = 0

  self.actionTimeline = nil
  self.zOrderTimeline = nil
  self.parent = nil
end

function AnimationData:cacheFrames(frameRate)
  if self.cacheFrameRate > 0.0 then -- TODO clear cache, upstream
    return
  end

  self.cacheFrameRate = math.max(math.ceil(frameRate * self.scale), 1.0)
  local cacheFrameCount = math.ceil(self.cacheFrameRate * self.duration) + 1
  self.cachedFrames.length = cacheFrameCount

  -- Important: the pinned original says "this.cacheFrames.length", NOT
  -- "this.cachedFrames.length". The former is a function with arity 1.
  -- Therefore only cachedFrames[0] is initialized to false and all other
  -- positions are *holes* (undefined). Preserve this upstream behavior.
  -- Lua's nil represents the missing values, and .length holds JS length.
  for i = 1, math.min(1, cacheFrameCount) do
    self.cachedFrames[i] = false
  end

  for _, bone in ipairs(self.parent.sortedBones) do
    local indices = {}
    for i = 1, cacheFrameCount do
      indices[i] = -1
    end
    self.boneCachedFrameIndices[bone.name] = indices
  end

  for _, slot in ipairs(self.parent.sortedSlots) do
    local indices = {}
    for i = 1, cacheFrameCount do
      indices[i] = -1
    end
    self.slotCachedFrameIndices[slot.name] = indices
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
