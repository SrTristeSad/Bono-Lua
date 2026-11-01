-- Port from DragonBonesJS (commit 64b6c69ae35777c2404be68c9192e2c56906079e).
-- Copyright (c) 2012-2025 DragonBones team and other contributors.
-- MIT license: see LICENSE-DRAGONBONES.
-- Original file: DragonBones/src/dragonBones/event/EventObject.ts
-- Event types and actionDataToInstance are ported directly.
-- Armature, Bone and Slot are original object contracts; this module does not
-- create substitute runtime objects before those classes are ported.
local BaseObject = require("dragonbones.original.core.BaseObject")
local EventObject = {}
EventObject.__index = EventObject
setmetatable(EventObject, { __index = BaseObject })

EventObject.START = "start"
EventObject.LOOP_COMPLETE = "loopComplete"
EventObject.COMPLETE = "complete"
EventObject.FADE_IN = "fadeIn"
EventObject.FADE_IN_COMPLETE = "fadeInComplete"
EventObject.FADE_OUT = "fadeOut"
EventObject.FADE_OUT_COMPLETE = "fadeOutComplete"
EventObject.FRAME_EVENT = "frameEvent"
EventObject.SOUND_EVENT = "soundEvent"

function EventObject.actionDataToInstance(data, instance, armature)
  -- ActionType.Play = 0 and ActionType.Frame = 10, from core/DragonBones.ts.
  if data.type == 0 then
    instance.type = EventObject.FRAME_EVENT
  else
    instance.type = data.type == 10 and EventObject.FRAME_EVENT or EventObject.SOUND_EVENT
  end

  instance.name = data.name
  instance.armature = armature
  instance.actionData = data
  instance.data = data.data

  if data.bone ~= nil then
    instance.bone = armature:getBone(data.bone.name)
  end

  if data.slot ~= nil then
    instance.slot = armature:getSlot(data.slot.name)
  end
end

function EventObject.toString()
  return "[class dragonBones.EventObject]"
end

function EventObject.new()
  return BaseObject.new(EventObject)
end

function EventObject:_onClear()
  self.time = 0.0
  self.type = ""
  self.name = ""
  self.armature = nil
  self.bone = nil
  self.slot = nil
  self.animationState = nil
  self.actionData = nil
  self.data = nil
end

return EventObject
