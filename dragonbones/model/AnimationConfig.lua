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

local newMask = require("dragonbones.core.JSArray").new

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
