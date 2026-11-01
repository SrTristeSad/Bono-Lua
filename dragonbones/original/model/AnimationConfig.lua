-- Direct port of DragonBones/src/dragonBones/model/AnimationConfig.ts
-- Upstream revision: 64b6c69ae35777c2404be68c9192e2c56906079e
-- Copyright (c) 2012-2025 DragonBones team and contributors.
-- Licensed under MIT; see LICENSE-DRAGONBONES.
--
-- The source declares one class: AnimationConfig. Only syntax, the class
-- representation, and the 1-based indexing of Lua arrays differ.
local BaseObject = require("dragonbones.original.core.BaseObject")
local Core = require("dragonbones.original.core.DragonBones")

local AnimationConfig = {}
AnimationConfig.__index = AnimationConfig
setmetatable(AnimationConfig, {__index = BaseObject})

function AnimationConfig.toString()
  return "[class dragonBones.AnimationConfig]"
end

function AnimationConfig.new()
  local self = BaseObject.new(AnimationConfig)
  -- readonly boneMask is constructed once per instance in TypeScript.
  self.boneMask = {}
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
  for i = #self.boneMask, 1, -1 do
    self.boneMask[i] = nil
  end
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

  -- JS: this.boneMask.length = value.boneMask.length;
  -- then copy the entries into the SAME destination array.
  -- A normal Lua sequence cannot contain JS 'holes'; masks here consist
  -- of strings, as described by the original Array<string> contract.
  local n = #value.boneMask
  for i = #self.boneMask, n + 1, -1 do
    self.boneMask[i] = nil
  end
  for i = 1, n do
    self.boneMask[i] = value.boneMask[i]
  end
end

return AnimationConfig
