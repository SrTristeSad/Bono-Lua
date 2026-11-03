-- Direct port of DragonBones/src/dragonBones/model/AnimationConfig.ts
-- Upstream revision: 64b6c69ae35777c2404be68c9192e2c56906079e
-- Copyright (c) 2012-2025 DragonBones team and contributors.
-- Licensed under MIT; see LICENSE-DRAGONBONES.
--
-- The source declares one class: AnimationConfig. Only syntax, the class
-- representation, and the 1-based indexing of Lua arrays differ.
-- boneMask.length is explicit, including sparse positions.
local BaseObject = require("dragonbones.core.BaseObject")
local Core = require("dragonbones.core.Enums")

local AnimationConfig = {}
AnimationConfig.__index = AnimationConfig
setmetatable(AnimationConfig, {__index = BaseObject})

function AnimationConfig.toString()
  return "[class dragonBones.AnimationConfig]"
end

-- Lua sequences have no reliable length after holes. Keep the source length
-- separately while retaining a normal public table and 1-based mask entries.
-- Named properties survive length truncation, as they do on a JS Array.
local function newMask()
  local length = 0
  return setmetatable({}, {
    __index = function(_, key)
      if key == "length" then return length end
    end,
    __newindex = function(mask, key, value)
      if key == "length" then
        if type(value) ~= "number" or value < 0 or value ~= math.floor(value)
          or value > 4294967295 then error("Invalid array length") end
        if value < length then
          for index in pairs(mask) do
            if type(index) == "number" and index >= 1 and index <= 4294967295
              and index == math.floor(index) and index > value then
              rawset(mask, index, nil)
            end
          end
        end
        length = value == 0 and 0 or value
      else
        if type(key) == "number" and key >= 1 and key <= 4294967295
          and key == math.floor(key) and key > length then length = key end
        rawset(mask, key, value)
      end
    end
  })
end

function AnimationConfig.new()
  local self = BaseObject.new(AnimationConfig)
  -- readonly boneMask is constructed once per instance in TypeScript.
  self.boneMask = newMask()
  return self
end

function AnimationConfig:_onClear()
  self.pauseFadeOut = true
  self.fadeOutMode = Core.AnimationFadeOutMode.All
  self.fadeOutTweenType = Core.TweenType.Line
  self.fadeOutTime = -1.0

  self.actionEnabled = true
  self.additive = false
  self.displayControl = true
  self.pauseFadeIn = true
  self.resetToPose = true
  self.fadeInTweenType = Core.TweenType.Line
  self.playTimes = -1
  self.layer = 0
  self.position = 0.0
  self.duration = -1.0
  self.timeScale = -100.0
  self.weight = 1.0
  self.fadeInTime = -1.0
  self.autoFadeOutTime = -1.0
  self.name = ""
  self.animation = ""
  self.group = ""
  self.boneMask.length = 0
end

function AnimationConfig:clear()
  self:_onClear()
end

function AnimationConfig:copyFrom(value)
  -- Copy assignment order follows original method, including the
  -- intentionally distinct fadeOutTweenType and fadeInTweenType fields.
  self.pauseFadeOut = value.pauseFadeOut
  self.fadeOutMode = value.fadeOutMode
  self.autoFadeOutTime = value.autoFadeOutTime
  self.fadeOutTweenType = value.fadeOutTweenType

  self.actionEnabled = value.actionEnabled
  self.additive = value.additive
  self.displayControl = value.displayControl
  self.pauseFadeIn = value.pauseFadeIn
  self.resetToPose = value.resetToPose
  self.playTimes = value.playTimes
  self.layer = value.layer
  self.position = value.position
  self.duration = value.duration
  self.timeScale = value.timeScale
  self.fadeInTime = value.fadeInTime
  self.fadeOutTime = value.fadeOutTime
  self.fadeInTweenType = value.fadeInTweenType
  self.weight = value.weight
  self.name = value.name
  self.animation = value.animation
  self.group = value.group

  self.boneMask.length = value.boneMask.length
  for i = 1, self.boneMask.length do
    self.boneMask[i] = value.boneMask[i]
  end
end

return AnimationConfig
