-- Ported from DragonBonesJS, commit 64b6c69ae35777c2404be68c9192e2c56906079e.
-- Copyright (c) 2012-2025 DragonBones team and other contributors.
-- MIT license: see LICENSE-DRAGONBONES and original source.
-- This module follows the original class's methods, mutating self and preserving return values.
local Transform = {}
Transform.__index = Transform
local jsNumberString=require("dragonbones.geom.JSNumberString").format

Transform.PI = math.pi
Transform.PI_D = math.pi * 2.0
Transform.PI_H = math.pi / 2.0
Transform.PI_Q = math.pi / 4.0
Transform.RAD_DEG = 180.0 / math.pi
Transform.DEG_RAD = math.pi / 180.0

function Transform.normalizeRadian(value)
  -- JavaScript % returns a signed remainder; Lua's % does not.
  value = math.fmod(value + math.pi, math.pi * 2.0)
  value = value + (value > 0.0 and -math.pi or math.pi)
  return value
end

function Transform.new(x, y, skew, rotation, scaleX, scaleY)
  return setmetatable({
    x=x == nil and 0.0 or x,
    y=y == nil and 0.0 or y,
    skew=skew == nil and 0.0 or skew,
    rotation=rotation == nil and 0.0 or rotation,
    scaleX=scaleX == nil and 1.0 or scaleX,
    scaleY=scaleY == nil and 1.0 or scaleY
  }, Transform)
end

function Transform:toString()
  return "[object dragonBones.Transform] x:" .. jsNumberString(self.x)
    .. " y:" .. jsNumberString(self.y)
    .. " skewX:" .. jsNumberString(self.skew * 180.0 / math.pi)
    .. " skewY:" .. jsNumberString(self.rotation * 180.0 / math.pi)
    .. " scaleX:" .. jsNumberString(self.scaleX)
    .. " scaleY:" .. jsNumberString(self.scaleY)
end

function Transform:copyFrom(value)
  self.x, self.y, self.skew = value.x, value.y, value.skew
  self.rotation, self.scaleX, self.scaleY = value.rotation, value.scaleX, value.scaleY
  return self
end

function Transform:identity()
  self.x, self.y = 0.0, 0.0
  self.skew, self.rotation = 0.0, 0.0
  self.scaleX, self.scaleY = 1.0, 1.0
  return self
end

function Transform:add(value)
  self.x, self.y = self.x+value.x, self.y+value.y
  self.skew, self.rotation = self.skew+value.skew, self.rotation+value.rotation
  self.scaleX, self.scaleY = self.scaleX*value.scaleX, self.scaleY*value.scaleY
  return self
end

function Transform:minus(value)
  self.x, self.y = self.x-value.x, self.y-value.y
  self.skew, self.rotation = self.skew-value.skew, self.rotation-value.rotation
  self.scaleX, self.scaleY = self.scaleX/value.scaleX, self.scaleY/value.scaleY
  return self
end

-- Preserve the original atan(b/a) decomposition, including scale-sign handling.
function Transform:fromMatrix(matrix)
  local backupScaleX,backupScaleY = self.scaleX,self.scaleY
  local PI_Q = Transform.PI_Q
  self.x,self.y = matrix.tx,matrix.ty
  self.rotation = math.atan(matrix.b / matrix.a)
  local skewX = math.atan(-matrix.c / matrix.d)
  self.scaleX = (self.rotation > -PI_Q and self.rotation < PI_Q)
    and matrix.a / math.cos(self.rotation) or matrix.b / math.sin(self.rotation)
  self.scaleY = (skewX > -PI_Q and skewX < PI_Q)
    and matrix.d / math.cos(skewX) or -matrix.c / math.sin(skewX)

  if backupScaleX >= 0.0 and self.scaleX < 0.0 then
    self.scaleX = -self.scaleX
    self.rotation = self.rotation - math.pi
  end
  if backupScaleY >= 0.0 and self.scaleY < 0.0 then
    self.scaleY = -self.scaleY
    skewX = skewX - math.pi
  end
  self.skew = skewX - self.rotation
  return self
end

function Transform:toMatrix(matrix)
  if self.rotation == 0.0 then
    matrix.a,matrix.b = 1.0,0.0
  else
    matrix.a,matrix.b = math.cos(self.rotation),math.sin(self.rotation)
  end
  if self.skew == 0.0 then
    matrix.c,matrix.d = -matrix.b,matrix.a
  else
    matrix.c = -math.sin(self.skew+self.rotation)
    matrix.d = math.cos(self.skew+self.rotation)
  end
  if self.scaleX ~= 1.0 then
    matrix.a,matrix.b = matrix.a*self.scaleX,matrix.b*self.scaleX
  end
  if self.scaleY ~= 1.0 then
    matrix.c,matrix.d = matrix.c*self.scaleY,matrix.d*self.scaleY
  end
  matrix.tx,matrix.ty = self.x,self.y
  return self
end

return Transform
