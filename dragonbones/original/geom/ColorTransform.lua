-- DragonBonesJS commit 64b6c69ae35777c2404be68c9192e2c56906079e
-- Copyright (c) 2012-2025 DragonBones team and other contributors.
-- Port under the MIT License; see LICENSE-DRAGONBONES.
-- Direct port of DragonBones/src/dragonBones/geom/ColorTransform.ts.
local ColorTransform = {}
ColorTransform.__index = ColorTransform

function ColorTransform.new(
  alphaMultiplier, redMultiplier, greenMultiplier, blueMultiplier,
  alphaOffset, redOffset, greenOffset, blueOffset)
  return setmetatable({
    alphaMultiplier=alphaMultiplier == nil and 1.0 or alphaMultiplier,
    redMultiplier=redMultiplier == nil and 1.0 or redMultiplier,
    greenMultiplier=greenMultiplier == nil and 1.0 or greenMultiplier,
    blueMultiplier=blueMultiplier == nil and 1.0 or blueMultiplier,
    alphaOffset=alphaOffset == nil and 0 or alphaOffset,
    redOffset=redOffset == nil and 0 or redOffset,
    greenOffset=greenOffset == nil and 0 or greenOffset,
    blueOffset=blueOffset == nil and 0 or blueOffset
  }, ColorTransform)
end

function ColorTransform:copyFrom(value)
  self.alphaMultiplier = value.alphaMultiplier
  self.redMultiplier = value.redMultiplier
  self.greenMultiplier = value.greenMultiplier
  self.blueMultiplier = value.blueMultiplier
  self.alphaOffset = value.alphaOffset
  self.redOffset = value.redOffset
  self.greenOffset = value.greenOffset
  self.blueOffset = value.blueOffset
end

function ColorTransform:identity()
  self.alphaMultiplier = 1.0
  self.redMultiplier = 1.0
  self.greenMultiplier = 1.0
  self.blueMultiplier = 1.0
  self.alphaOffset = 0
  self.redOffset = 0
  self.greenOffset = 0
  self.blueOffset = 0
end

return ColorTransform
