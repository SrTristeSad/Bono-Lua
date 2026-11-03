-- Ported from DragonBonesJS, commit 64b6c69ae35777c2404be68c9192e2c56906079e.
-- Copyright (c) 2012-2025 DragonBones team and other contributors.
-- MIT license: see LICENSE-DRAGONBONES and original source.
-- This module follows the original class's methods, mutating self and preserving return values.
local Point = {}
Point.__index = Point

function Point.new(x, y)
  return setmetatable({x=x == nil and 0.0 or x, y=y == nil and 0.0 or y}, Point)
end

function Point:copyFrom(value)
  self.x = value.x
  self.y = value.y
end

function Point:clear()
  self.x = 0.0
  self.y = 0.0
end

return Point
