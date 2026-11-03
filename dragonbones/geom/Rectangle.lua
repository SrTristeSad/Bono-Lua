-- Ported from DragonBonesJS, commit 64b6c69ae35777c2404be68c9192e2c56906079e.
-- Copyright (c) 2012-2025 DragonBones team and other contributors.
-- MIT license: see LICENSE-DRAGONBONES and original source.
-- This module follows the original class's methods, mutating self and preserving return values.
local Rectangle = {}
Rectangle.__index = Rectangle

function Rectangle.new(x, y, width, height)
  return setmetatable({
    x=x == nil and 0.0 or x,
    y=y == nil and 0.0 or y,
    width=width == nil and 0.0 or width,
    height=height == nil and 0.0 or height
  }, Rectangle)
end

function Rectangle:copyFrom(value)
  self.x = value.x
  self.y = value.y
  self.width = value.width
  self.height = value.height
end

function Rectangle:clear()
  self.x = 0.0
  self.y = 0.0
  self.width = 0.0
  self.height = 0.0
end

return Rectangle
