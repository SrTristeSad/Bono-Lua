-- DragonBones/src/dragonBones/armature/Surface.ts, pinned at
-- 64b6c69ae35777c2404be68c9192e2c56906079e.
-- Copyright (c) 2012-2025 DragonBones team and other contributors.
-- MIT license: see LICENSE-DRAGONBONES.
-- Translation of every original method and every source branch, including
-- the source spelling "_matrixCahce" and the hull cache sizing peculiarity.
local BaseObject = require("dragonbones.original.core.BaseObject")
local TransformObject = require("dragonbones.original.armature.TransformObject")
local Bone = require("dragonbones.original.armature.Bone")
local Transform = require("dragonbones.original.geom.Transform")
local Core = require("dragonbones.original.core.DragonBones")

local Surface = {}
setmetatable(Surface, { __index = Bone })
Surface.__newindex = Bone.__newindex
function Surface.__index(self, key)
  return rawget(Surface, key) or Bone.__index(self, key)
end

-- The JS index is zero-based. Lua tables carry an explicit .length because
-- sparse arrays and undefined entries cannot use Lua's # operator reliably.
local function at(array, index)
  return array[index + 1]
end
local function put(array, index, value)
  array[index + 1] = value
  if index + 1 > array.length then array.length = index + 1 end
end
local function resize(array, length)
  for index in pairs(array) do
    if type(index) == "number" and index > length then array[index] = nil end
  end
  array.length = length
end

function Surface.toString()
  return "[class dragonBones.Surface]"
end

function Surface.new()
  local object = TransformObject.new(Surface)
  object.animationPose = Transform.new()
  object._vertices = { length = 0 }
  object._deformVertices = { length = 0 }
  object._hullCache = { length = 0 }
  object._matrixCahce = { length = 0 }
  return object
end

function Surface:_onClear()
  Bone._onClear(self)
  self._dX = 0.0
  self._dY = 0.0
  self._k = 0.0
  self._kX = 0.0
  self._kY = 0.0
  resize(self._vertices, 0)
  resize(self._deformVertices, 0)
  resize(self._matrixCahce, 0)
  resize(self._hullCache, 0)
  self._bone = nil
end

local atan2 = math.atan2 or function(y, x) return math.atan(y, x) end

function Surface:_getAffineTransform(x, y, lX, lY,
    aX, aY, bX, bY, cX, cY, transform, matrix, isDown)
  local dabX = bX - aX
  local dabY = bY - aY
  local dacX = cX - aX
  local dacY = cY - aY

  transform.rotation = atan2(dabY, dabX)
  transform.skew = atan2(dacY, dacX) - math.pi * 0.5 - transform.rotation
  if isDown then
    transform.rotation = transform.rotation + math.pi
  end

  transform.scaleX = math.sqrt(dabX * dabX + dabY * dabY) / lX
  transform.scaleY = math.sqrt(dacX * dacX + dacY * dacY) / lY
  transform:toMatrix(matrix)
  transform.x = aX - (matrix.a * x + matrix.c * y)
  matrix.tx = transform.x
  transform.y = aY - (matrix.b * x + matrix.d * y)
  matrix.ty = transform.y
end

function Surface:_updateVertices()
  local data = self._armature.armatureData.parent
  local geometry = self._boneData.geometry
  local intArray = data.intArray
  local floatArray = data.floatArray
  local vertexCount = at(intArray, geometry.offset + Core.BinaryOffset.GeometryVertexCount)
  local verticesOffset = at(intArray, geometry.offset + Core.BinaryOffset.GeometryFloatOffset)
  local vertices = self._vertices
  local animationVertices = self._deformVertices

  if self._parent ~= nil then
    if self._parent._boneData.type == Core.BoneType.Surface then
      for i = 0, vertexCount - 1 do
        local iD = i * 2
        local x = at(floatArray, verticesOffset + iD) + at(animationVertices, iD)
        local y = at(floatArray, verticesOffset + iD + 1) + at(animationVertices, iD + 1)
        local matrix = self._parent:_getGlobalTransformMatrix(x, y)
        put(vertices, iD, matrix.a * x + matrix.c * y + matrix.tx)
        put(vertices, iD + 1, matrix.b * x + matrix.d * y + matrix.ty)
      end
    else
      local parentMatrix = self._parent.globalTransformMatrix
      for i = 0, vertexCount - 1 do
        local iD = i * 2
        local x = at(floatArray, verticesOffset + iD) + at(animationVertices, iD)
        local y = at(floatArray, verticesOffset + iD + 1) + at(animationVertices, iD + 1)
        put(vertices, iD, parentMatrix.a * x + parentMatrix.c * y + parentMatrix.tx)
        put(vertices, iD + 1, parentMatrix.b * x + parentMatrix.d * y + parentMatrix.ty)
      end
    end
  else
    for i = 0, vertexCount - 1 do
      local iD = i * 2
      put(vertices, iD, at(floatArray, verticesOffset + iD) + at(animationVertices, iD))
      put(vertices, iD + 1, at(floatArray, verticesOffset + iD + 1) + at(animationVertices, iD + 1))
    end
  end
end

function Surface:_updateGlobalTransformMatrix(isCache)
  -- The TS expression "isCache;" is intentionally a no-op.
  local segmentXD = self._boneData.segmentX * 2
  local lastIndex = self._vertices.length - 2
  local lA = 200.0
  local raX, raY = at(self._vertices, 0), at(self._vertices, 1)
  local rbX, rbY = at(self._vertices, segmentXD), at(self._vertices, segmentXD + 1)
  local rcX, rcY = at(self._vertices, lastIndex), at(self._vertices, lastIndex + 1)
  local rdX, rdY = at(self._vertices, lastIndex - segmentXD), at(self._vertices, lastIndex - segmentXD + 1)
  local dacX = raX + (rcX - raX) * 0.5
  local dacY = raY + (rcY - raY) * 0.5
  local dbdX = rbX + (rdX - rbX) * 0.5
  local dbdY = rbY + (rdY - rbY) * 0.5
  local aX = dacX + (dbdX - dacX) * 0.5
  local aY = dacY + (dbdY - dacY) * 0.5
  local bX = rbX + (rcX - rbX) * 0.5
  local bY = rbY + (rcY - rbY) * 0.5
  local cX = rdX + (rcX - rdX) * 0.5
  local cY = rdY + (rcY - rdY) * 0.5
  -- Original TODO interpolation deliberately not rewritten.
  self:_getAffineTransform(0.0, 0.0, lA, lA,
    aX, aY, bX, bY, cX, cY, self.global, self.globalTransformMatrix, false)
  self._globalDirty = false
end

function Surface:_getGlobalTransformMatrix(x, y)
  local lA = 200.0
  local lB = 1000.0
  if x < -lB or lB < x or y < -lB or lB < y then
    return self.globalTransformMatrix
  end

  local isDown = false
  local surfaceData = self._boneData
  local segmentX, segmentY = surfaceData.segmentX, surfaceData.segmentY
  local segmentXD = surfaceData.segmentX * 2
  local dX, dY = self._dX, self._dY
  local indexX = math.floor((x + lA) / dX)
  local indexY = math.floor((y + lA) / dY)
  local matrixIndex = 0
  local pX = indexX * dX - lA
  local pY = indexY * dY - lA
  local matrices = self._matrixCahce
  local helpMatrix = Surface._helpMatrix
  local vertices = self._vertices

  if x < -lA then
    if y < -lA or y >= lA then return self.globalTransformMatrix end
    -- Left.
    isDown = y > self._kX * (x + lA) + pY
    matrixIndex = ((segmentX * segmentY + segmentX + segmentY + segmentY + indexY) * 2 + (isDown and 1 or 0)) * 7
    if (at(matrices, matrixIndex) or -1.0) > 0.0 then
      helpMatrix:copyFromArray(matrices, matrixIndex + 1)
    else
      local vertexIndex = indexY * (segmentXD + 2)
      local ddX = at(self._hullCache, 4)
      local ddY = at(self._hullCache, 5)
      local sX = at(self._hullCache, 2) - (segmentY - indexY) * ddX
      local sY = at(self._hullCache, 3) - (segmentY - indexY) * ddY
      if isDown then
        self:_getAffineTransform(-lA, pY + dY, lB - lA, dY,
          at(vertices, vertexIndex + segmentXD + 2),
          at(vertices, vertexIndex + segmentXD + 3),
          sX + ddX, sY + ddY,
          at(vertices, vertexIndex), at(vertices, vertexIndex + 1),
          Surface._helpTransform, helpMatrix, true)
      else
        self:_getAffineTransform(-lB, pY, lB - lA, dY,
          sX, sY,
          at(vertices, vertexIndex), at(vertices, vertexIndex + 1),
          sX + ddX, sY + ddY,
          Surface._helpTransform, helpMatrix, false)
      end
    end

  elseif x >= lA then
    if y < -lA or y >= lA then return self.globalTransformMatrix end
    -- Right.
    isDown = y > self._kX * (x - lB) + pY
    matrixIndex = ((segmentX * segmentY + segmentX + indexY) * 2 + (isDown and 1 or 0)) * 7
    if (at(matrices, matrixIndex) or -1.0) > 0.0 then
      helpMatrix:copyFromArray(matrices, matrixIndex + 1)
    else
      local vertexIndex = (indexY + 1) * (segmentXD + 2) - 2
      local ddX = at(self._hullCache, 4)
      local ddY = at(self._hullCache, 5)
      local sX = at(self._hullCache, 0) + indexY * ddX
      local sY = at(self._hullCache, 1) + indexY * ddY
      if isDown then
        self:_getAffineTransform(lB, pY + dY, lB - lA, dY,
          sX + ddX, sY + ddY,
          at(vertices, vertexIndex + segmentXD + 2),
          at(vertices, vertexIndex + segmentXD + 3),
          sX, sY, Surface._helpTransform, helpMatrix, true)
      else
        self:_getAffineTransform(lA, pY, lB - lA, dY,
          at(vertices, vertexIndex), at(vertices, vertexIndex + 1),
          sX, sY,
          at(vertices, vertexIndex + segmentXD + 2),
          at(vertices, vertexIndex + segmentXD + 3),
          Surface._helpTransform, helpMatrix, false)
      end
    end

  elseif y < -lA then
    if x < -lA or x >= lA then return self.globalTransformMatrix end
    -- Up.
    isDown = y > self._kY * (x - pX - dX) - lB
    matrixIndex = ((segmentX * segmentY + indexX) * 2 + (isDown and 1 or 0)) * 7
    if (at(matrices, matrixIndex) or -1.0) > 0.0 then
      helpMatrix:copyFromArray(matrices, matrixIndex + 1)
    else
      local vertexIndex = indexX * 2
      local ddX = at(self._hullCache, 10)
      local ddY = at(self._hullCache, 11)
      local sX = at(self._hullCache, 8) + indexX * ddX
      local sY = at(self._hullCache, 9) + indexX * ddY
      if isDown then
        self:_getAffineTransform(pX + dX, -lA, dX, lB - lA,
          at(vertices, vertexIndex + 2),
          at(vertices, vertexIndex + 3),
          at(vertices, vertexIndex), at(vertices, vertexIndex + 1),
          sX + ddX, sY + ddY,
          Surface._helpTransform, helpMatrix, true)
      else
        self:_getAffineTransform(pX, -lB, dX, lB - lA,
          sX, sY,
          sX + ddX, sY + ddY,
          at(vertices, vertexIndex), at(vertices, vertexIndex + 1),
          Surface._helpTransform, helpMatrix, false)
      end
    end

  elseif y >= lA then
    if x < -lA or x >= lA then return self.globalTransformMatrix end
    -- Down.
    isDown = y > self._kY * (x - pX - dX) + lA
    matrixIndex = ((segmentX * segmentY + segmentX + segmentY + indexX) * 2 + (isDown and 1 or 0)) * 7
    if (at(matrices, matrixIndex) or -1.0) > 0.0 then
      helpMatrix:copyFromArray(matrices, matrixIndex + 1)
    else
      local vertexIndex = segmentY * (segmentXD + 2) + indexX * 2
      local ddX = at(self._hullCache, 10)
      local ddY = at(self._hullCache, 11)
      local sX = at(self._hullCache, 6) - (segmentX - indexX) * ddX
      local sY = at(self._hullCache, 7) - (segmentX - indexX) * ddY
      if isDown then
        self:_getAffineTransform(pX + dX, lB, dX, lB - lA,
          sX + ddX, sY + ddY,
          sX, sY,
          at(vertices, vertexIndex + 2), at(vertices, vertexIndex + 3),
          Surface._helpTransform, helpMatrix, true)
      else
        self:_getAffineTransform(pX, lA, dX, lB - lA,
          at(vertices, vertexIndex), at(vertices, vertexIndex + 1),
          at(vertices, vertexIndex + 2), at(vertices, vertexIndex + 3),
          sX, sY, Surface._helpTransform, helpMatrix, false)
      end
    end

  else
    -- Center.
    isDown = y > self._k * (x - pX - dX) + pY
    matrixIndex = ((segmentX * indexY + indexX) * 2 + (isDown and 1 or 0)) * 7
    if (at(matrices, matrixIndex) or -1.0) > 0.0 then
      helpMatrix:copyFromArray(matrices, matrixIndex + 1)
    else
      local vertexIndex = indexX * 2 + indexY * (segmentXD + 2)
      if isDown then
        self:_getAffineTransform(pX + dX, pY + dY, dX, dY,
          at(vertices, vertexIndex + segmentXD + 4),
          at(vertices, vertexIndex + segmentXD + 5),
          at(vertices, vertexIndex + segmentXD + 2),
          at(vertices, vertexIndex + segmentXD + 3),
          at(vertices, vertexIndex + 2), at(vertices, vertexIndex + 3),
          Surface._helpTransform, helpMatrix, true)
      else
        self:_getAffineTransform(pX, pY, dX, dY,
          at(vertices, vertexIndex), at(vertices, vertexIndex + 1),
          at(vertices, vertexIndex + 2), at(vertices, vertexIndex + 3),
          at(vertices, vertexIndex + segmentXD + 2),
          at(vertices, vertexIndex + segmentXD + 3),
          Surface._helpTransform, helpMatrix, false)
      end
    end
  end

  -- Original writes the 7 cache values after computing a cache miss.
  if not ((at(matrices, matrixIndex) or -1.0) > 0.0) then
    put(matrices, matrixIndex, 1.0)
    put(matrices, matrixIndex + 1, helpMatrix.a)
    put(matrices, matrixIndex + 2, helpMatrix.b)
    put(matrices, matrixIndex + 3, helpMatrix.c)
    put(matrices, matrixIndex + 4, helpMatrix.d)
    put(matrices, matrixIndex + 5, helpMatrix.tx)
    put(matrices, matrixIndex + 6, helpMatrix.ty)
  end
  return helpMatrix
end

function Surface:init(surfaceData, armatureValue)
  if self._boneData ~= nil then return end
  Bone.init(self, surfaceData, armatureValue)

  local segmentX = surfaceData.segmentX
  local segmentY = surfaceData.segmentY
  local vertexCount = at(self._armature.armatureData.parent.intArray,
    surfaceData.geometry.offset + Core.BinaryOffset.GeometryVertexCount)
  local lB = 1000.0
  local lA = 200.0
  self._dX = lA * 2.0 / segmentX
  self._dY = lA * 2.0 / segmentY
  self._k = -self._dY / self._dX
  self._kX = -self._dY / (lB - lA)
  self._kY = -(lB - lA) / self._dX
  resize(self._vertices, vertexCount * 2)
  resize(self._deformVertices, vertexCount * 2)
  resize(self._matrixCahce, (segmentX * segmentY + segmentX * 2 + segmentY * 2) * 2 * 7)
  resize(self._hullCache, 10)
  for i = 0, vertexCount * 2 - 1 do
    put(self._deformVertices, i, 0.0)
  end
  if self._parent ~= nil then
    if self._parent.boneData.type == Core.BoneType.Bone then
      self._bone = self._parent
    else
      self._bone = self._parent._bone
    end
  end
end

function Surface:update(cacheFrameIndex)
  if cacheFrameIndex >= 0 and self._cachedFrameIndices ~= nil then
    local cachedFrameIndex = self._cachedFrameIndices[cacheFrameIndex + 1]
    if cachedFrameIndex ~= nil and cachedFrameIndex >= 0 and self._cachedFrameIndex == cachedFrameIndex then
      self._transformDirty = false
    elseif cachedFrameIndex ~= nil and cachedFrameIndex >= 0 then
      self._transformDirty = true
      self._cachedFrameIndex = cachedFrameIndex
    else
      if self._hasConstraint then
        for _, constraint in ipairs(self._armature._constraints) do
          if constraint._root == self then constraint:update() end
        end
      end
      if self._transformDirty or (self._parent ~= nil and self._parent._childrenTransformDirty) then
        self._transformDirty = true
        self._cachedFrameIndex = -1
      elseif self._cachedFrameIndex >= 0 then
        self._transformDirty = false
        self._cachedFrameIndices[cacheFrameIndex + 1] = self._cachedFrameIndex
      else
        self._transformDirty = true
        self._cachedFrameIndex = -1
      end
    end
  else
    if self._hasConstraint then
      for _, constraint in ipairs(self._armature._constraints) do
        if constraint._root == self then constraint:update() end
      end
    end
    if self._transformDirty or (self._parent ~= nil and self._parent._childrenTransformDirty) then
      cacheFrameIndex = -1
      self._transformDirty = true
      self._cachedFrameIndex = -1
    end
  end

  if self._transformDirty then
    self._transformDirty = false
    self._childrenTransformDirty = true
    for i = 0, self._matrixCahce.length - 1, 7 do
      put(self._matrixCahce, i, -1.0)
    end
    self:_updateVertices()
    if self._cachedFrameIndex < 0 then
      local isCache = cacheFrameIndex >= 0
      if self._localDirty then self:_updateGlobalTransformMatrix(isCache) end
      if isCache and self._cachedFrameIndices ~= nil then
        local index = self._armature._armatureData:setCacheFrame(self.globalTransformMatrix, self.global)
        self._cachedFrameIndices[cacheFrameIndex + 1] = index
        self._cachedFrameIndex = index
      end
    else
      self._armature._armatureData:getCacheFrame(self.globalTransformMatrix, self.global, self._cachedFrameIndex)
    end

    local lB = 1000.0
    local lA = 200.0
    local ddX = 2 * self.global.x
    local ddY = 2 * self.global.y
    local helpPoint = Surface._helpPoint
    self.globalTransformMatrix:transformPoint(lB, -lA, helpPoint)
    put(self._hullCache, 0, helpPoint.x)
    put(self._hullCache, 1, helpPoint.y)
    put(self._hullCache, 2, ddX - helpPoint.x)
    put(self._hullCache, 3, ddY - helpPoint.y)
    self.globalTransformMatrix:transformPoint(0.0, self._dY, helpPoint, true)
    put(self._hullCache, 4, helpPoint.x)
    put(self._hullCache, 5, helpPoint.y)
    self.globalTransformMatrix:transformPoint(lA, lB, helpPoint)
    put(self._hullCache, 6, helpPoint.x)
    put(self._hullCache, 7, helpPoint.y)
    put(self._hullCache, 8, ddX - helpPoint.x)
    put(self._hullCache, 9, ddY - helpPoint.y)
    self.globalTransformMatrix:transformPoint(self._dX, 0.0, helpPoint, true)
    put(self._hullCache, 10, helpPoint.x)
    put(self._hullCache, 11, helpPoint.y)
  elseif self._childrenTransformDirty then
    self._childrenTransformDirty = false
  end
  self._localDirty = true
end

return Surface
