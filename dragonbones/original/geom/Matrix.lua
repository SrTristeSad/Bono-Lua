-- Ported from DragonBonesJS, commit 64b6c69ae35777c2404be68c9192e2c56906079e.
-- Copyright (c) 2012-2025 DragonBones team and other contributors.
-- MIT license: see LICENSE-DRAGONBONES and original source.
-- This module follows the original class's methods, mutating self and preserving return values.
local Matrix = {}
Matrix.__index = Matrix
local jsNumberString=require("dragonbones.original.geom.JSNumberString").format

function Matrix.new(a, b, c, d, tx, ty)
  return setmetatable({
    a=a == nil and 1.0 or a,
    b=b == nil and 0.0 or b,
    c=c == nil and 0.0 or c,
    d=d == nil and 1.0 or d,
    tx=tx == nil and 0.0 or tx,
    ty=ty == nil and 0.0 or ty
  }, Matrix)
end

function Matrix:toString()
  return "[object dragonBones.Matrix] a:" .. jsNumberString(self.a)
    .. " b:" .. jsNumberString(self.b)
    .. " c:" .. jsNumberString(self.c)
    .. " d:" .. jsNumberString(self.d)
    .. " tx:" .. jsNumberString(self.tx)
    .. " ty:" .. jsNumberString(self.ty)
end

function Matrix:copyFrom(value)
  self.a, self.b, self.c, self.d = value.a, value.b, value.c, value.d
  self.tx, self.ty = value.tx, value.ty
  return self
end

-- The original TypeScript array offset starts at zero, whereas Lua uses 1.
function Matrix:copyFromArray(value, offset)
  local i = (offset == nil and 0 or offset) + 1
  self.a, self.b, self.c, self.d = value[i], value[i+1], value[i+2], value[i+3]
  self.tx, self.ty = value[i+4], value[i+5]
  return self
end

function Matrix:identity()
  self.a, self.d = 1.0, 1.0
  self.b, self.c = 0.0, 0.0
  self.tx, self.ty = 0.0, 0.0
  return self
end

-- Exact equation order from DragonBonesJS Matrix.concat (not standard
-- left-side affine composition: changing the order alters its semantics).
function Matrix:concat(value)
  local aA = self.a * value.a
  local bA = 0.0
  local cA = 0.0
  local dA = self.d * value.d
  local txA = self.tx * value.a + value.tx
  local tyA = self.ty * value.d + value.ty

  if self.b ~= 0.0 or self.c ~= 0.0 then
    aA = aA + self.b * value.c
    bA = bA + self.b * value.d
    cA = cA + self.c * value.a
    dA = dA + self.c * value.b
  end
  if value.b ~= 0.0 or value.c ~= 0.0 then
    bA = bA + self.a * value.b
    cA = cA + self.d * value.c
    txA = txA + self.ty * value.c
    tyA = tyA + self.tx * value.b
  end
  self.a, self.b, self.c, self.d = aA, bA, cA, dA
  self.tx, self.ty = txA, tyA
  return self
end

-- Preserve original degenerate cases, including its special diagonal case.
function Matrix:invert()
  local aA, bA, cA, dA = self.a, self.b, self.c, self.d
  local txA, tyA = self.tx, self.ty

  if bA == 0.0 and cA == 0.0 then
    self.b, self.c = 0.0, 0.0
    if aA == 0.0 or dA == 0.0 then
      self.a, self.b, self.tx, self.ty = 0.0, 0.0, 0.0, 0.0
    else
      aA, self.a = 1.0 / aA, 1.0 / aA
      dA, self.d = 1.0 / dA, 1.0 / dA
      self.tx = -aA * txA
      self.ty = -dA * tyA
    end
    return self
  end

  local determinant = aA * dA - bA * cA
  if determinant == 0.0 then
    self.a, self.d = 1.0, 1.0
    self.b, self.c = 0.0, 0.0
    self.tx, self.ty = 0.0, 0.0
    return self
  end

  determinant = 1.0 / determinant
  local k = dA * determinant
  self.a = k
  bA, self.b = -bA * determinant, -bA * determinant
  cA, self.c = -cA * determinant, -cA * determinant
  dA, self.d = aA * determinant, aA * determinant
  self.tx = -(k * txA + cA * tyA)
  self.ty = -(bA * txA + dA * tyA)
  return self
end

function Matrix:transformPoint(x, y, result, delta)
  result.x = self.a * x + self.c * y
  result.y = self.b * x + self.d * y
  if not delta then
    result.x = result.x + self.tx
    result.y = result.y + self.ty
  end
end

function Matrix:transformRectangle(rectangle, delta)
  local a,b,c,d = self.a,self.b,self.c,self.d
  local tx,ty = delta and 0.0 or self.tx, delta and 0.0 or self.ty
  local x,y = rectangle.x,rectangle.y
  local xMax,yMax = x+rectangle.width,y+rectangle.height

  local x0,y0 = a*x+c*y+tx,b*x+d*y+ty
  local x1,y1 = a*xMax+c*y+tx,b*xMax+d*y+ty
  local x2,y2 = a*xMax+c*yMax+tx,b*xMax+d*yMax+ty
  local x3,y3 = a*x+c*yMax+tx,b*x+d*yMax+ty

  local tmp = 0.0
  if x0>x1 then tmp=x0;x0=x1;x1=tmp end
  if x2>x3 then tmp=x2;x2=x3;x3=tmp end
  rectangle.x = math.floor(x0<x2 and x0 or x2)
  rectangle.width = math.ceil((x1>x3 and x1 or x3)-rectangle.x)
  if y0>y1 then tmp=y0;y0=y1;y1=tmp end
  if y2>y3 then tmp=y2;y2=y3;y3=tmp end
  rectangle.y = math.floor(y0<y2 and y0 or y2)
  rectangle.height = math.ceil((y1>y3 and y1 or y3)-rectangle.y)
end

return Matrix
