-- Port from DragonBonesJS (commit 64b6c69ae35777c2404be68c9192e2c56906079e).
-- Copyright (c) 2012-2025 DragonBones team and other contributors.
-- MIT license: see LICENSE-DRAGONBONES.
-- Original file: DragonBones/src/dragonBones/core/DragonBones.ts
-- All const enums and runtime DragonBones class, excluding JS-only global
-- shims (console, AMD/CommonJS, Date.now fallback, TS inheritance polyfill).
local WorldClock = require("dragonbones.animation.WorldClock")
local EventObject = require("dragonbones.event.EventObject")

local DragonBones = {}
DragonBones.__index = DragonBones

local Enums = require("dragonbones.core.Enums")
for name, values in pairs(Enums) do DragonBones[name] = values end

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

  -- Source uses a growing indexed loop: newly buffered events are processed
  -- during this dispatch before the array is cleared.
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
    if rawequal(eventObject, value) then return end
  end
  self._events[#self._events+1] = value
end

function DragonBones:bufferObject(object)
  for _, value in ipairs(self._objects) do
    if rawequal(value, object) then return end
  end
  self._objects[#self._objects+1] = object
end

-- Original readonly accessors; the Lua class exposes them through __index.
function DragonBones.__index(self, key)
  if key == "clock" then return rawget(self, "_clock") end
  if key == "eventManager" then return rawget(self, "_eventManager") end
  return rawget(DragonBones, key)
end

-- Getter-only properties reject assignment, as the original accessors do.
function DragonBones.__newindex(self, key, value)
  if key == "clock" or key == "eventManager" then error("Readonly property: " .. key) end
  rawset(self, key, value)
end

return DragonBones
