-- Port from DragonBonesJS (commit 64b6c69ae35777c2404be68c9192e2c56906079e).
-- Copyright (c) 2012-2025 DragonBones team and other contributors.
-- MIT license: see LICENSE-DRAGONBONES.
-- Original file: DragonBones/src/dragonBones/core/DragonBones.ts
-- All const enums and runtime DragonBones class, excluding JS-only global
-- shims (console, AMD/CommonJS, Date.now fallback, TS inheritance polyfill).
local WorldClock = require("dragonbones.original.animation.WorldClock")
local EventObject = require("dragonbones.original.event.EventObject")

local DragonBones = {}
DragonBones.__index = DragonBones

-- TS const enum values are compile-time numbers. Lua tables preserve the
-- original names and numerical values without creating alternate semantics.
DragonBones.BinaryOffset = {
  WeigthBoneCount=0, WeigthFloatOffset=1, WeigthBoneIndices=2,
  GeometryVertexCount=0, GeometryTriangleCount=1, GeometryFloatOffset=2,
  GeometryWeightOffset=3, GeometryVertexIndices=4,
  TimelineScale=0, TimelineOffset=1, TimelineKeyFrameCount=2,
  TimelineFrameValueCount=3, TimelineFrameValueOffset=4, TimelineFrameOffset=5,
  FramePosition=0, FrameTweenType=1, FrameTweenEasingOrCurveSampleCount=2,
  FrameCurveSamples=3,
  DeformVertexOffset=0, DeformCount=1, DeformValueCount=2,
  DeformValueOffset=3, DeformFloatOffset=4
}
DragonBones.ArmatureType = { Armature=0, MovieClip=1, Stage=2 }
DragonBones.BoneType = { Bone=0, Surface=1 }
DragonBones.DisplayType = { Image=0, Armature=1, Mesh=2, BoundingBox=3, Path=4 }
DragonBones.BoundingBoxType = { Rectangle=0, Ellipse=1, Polygon=2 }
DragonBones.ActionType = { Play=0, Frame=10, Sound=11 }
DragonBones.BlendMode = {
  Normal=0, Add=1, Alpha=2, Darken=3, Difference=4, Erase=5,
  HardLight=6, Invert=7, Layer=8, Lighten=9, Multiply=10,
  Overlay=11, Screen=12, Subtract=13
}
DragonBones.TweenType = { None=0, Line=1, Curve=2, QuadIn=3, QuadOut=4, QuadInOut=5 }
DragonBones.TimelineType = {
  Action=0, ZOrder=1, BoneAll=10, BoneTranslate=11, BoneRotate=12, BoneScale=13,
  Surface=50, BoneAlpha=60, SlotDisplay=20, SlotColor=21,
  SlotDeform=22, SlotZIndex=23, SlotAlpha=24, IKConstraint=30,
  AnimationProgress=40, AnimationWeight=41, AnimationParameter=42
}
DragonBones.OffsetMode = { None=0, Additive=1, Override=2 }
DragonBones.AnimationFadeOutMode = {
  SameLayer=1, SameGroup=2, SameLayerAndGroup=3, All=4, Single=5
}
DragonBones.AnimationBlendType = { None=0, E1D=1 }
DragonBones.AnimationBlendMode = { Additive=0, Override=1 }
DragonBones.ConstraintType = { IK=0, Path=1 }
DragonBones.PositionMode = { Fixed=0, Percent=1 }
DragonBones.SpacingMode = { Length=0, Fixed=1, Percent=2 }
DragonBones.RotateMode = { Tangent=0, Chain=1, ChainScale=2 }

DragonBones.VERSION = "5.7.000"
DragonBones.yDown = true
DragonBones.debug = false
DragonBones.debugDraw = false

function DragonBones.new(eventManager)
  local self = setmetatable({
    _clock = WorldClock.new(),
    _events = {},
    _objects = {},
    _eventManager = eventManager
  }, DragonBones)

  -- Original console.info is informational, not a change to the runtime.
  print("DragonBones: " .. DragonBones.VERSION
    .. "\nWebsite: http://www.loongbones.app/"
    .. "\nSource and Demo: https://github.com/DragonBones/")
  return self
end

function DragonBones:advanceTime(passedTime)
  if #self._objects > 0 then
    for _, object in ipairs(self._objects) do
      object:returnToPool()
    end
    for i=#self._objects,1,-1 do self._objects[i] = nil end
  end

  self._clock:advanceTime(passedTime)

  -- Use a growing loop, not ipairs: events buffered by handlers in the
  -- same dispatch are processed before the array is cleared, as in TS.
  if #self._events > 0 then
    local i = 1
    while i <= #self._events do
      local eventObject = self._events[i]
      local armature = eventObject.armature

      if armature._armatureData ~= nil then
        armature.eventDispatcher:dispatchDBEvent(eventObject.type, eventObject)
        if eventObject.type == EventObject.SOUND_EVENT then
          self._eventManager:dispatchDBEvent(eventObject.type, eventObject)
        end
      end

      self:bufferObject(eventObject)
      i = i + 1
    end

    for k=#self._events,1,-1 do self._events[k] = nil end
  end
end

function DragonBones:bufferEvent(value)
  for _, eventObject in ipairs(self._events) do
    if eventObject == value then return end
  end
  self._events[#self._events+1] = value
end

function DragonBones:bufferObject(object)
  for _, value in ipairs(self._objects) do
    if value == object then return end
  end
  self._objects[#self._objects+1] = object
end

-- Original readonly accessors; the Lua class exposes them through __index.
function DragonBones.__index(self, key)
  if key == "clock" then return rawget(self, "_clock") end
  if key == "eventManager" then return rawget(self, "_eventManager") end
  return rawget(DragonBones, key)
end

return DragonBones
