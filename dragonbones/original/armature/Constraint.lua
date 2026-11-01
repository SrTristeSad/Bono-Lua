-- Direct port of DragonBones/src/dragonBones/armature/Constraint.ts
-- DragonBonesJS commit 64b6c69ae35777c2404be68c9192e2c56906079e.
-- Copyright (c) 2012-2025 DragonBones team and other contributors.
-- MIT license: see LICENSE-DRAGONBONES.
-- Retains original IK and path constraint algorithms, including source TODOs.
local BaseObject = require("dragonbones.original.core.BaseObject")
local Matrix = require("dragonbones.original.geom.Matrix")
local Transform = require("dragonbones.original.geom.Transform")
local Point = require("dragonbones.original.geom.Point")
local Core = require("dragonbones.original.core.DragonBones")

-- JS array indices are zero based, and arrays may be sparse.
-- .length is stored separately from Lua's table length for exact sizing.
local function get(array, index)
  return array[index + 1]
end
local function put(array, index, value)
  array[index + 1] = value
  if index + 1 > array.length then array.length = index + 1 end
end
local function resize(array, length)
  for k in pairs(array) do
    if type(k) == "number" and k > length then array[k] = nil end
  end
  array.length = length
end
local function array(initial)
  local result = { length = 0 }
  if initial ~= nil then put(result, 0, initial) end
  return result
end
local function atan2(y, x)
  if math.atan2 then return math.atan2(y, x) end
  return math.atan(y, x)
end
local function jsRemainder(a, b)
  return math.fmod(a, b)
end

local Constraint = {}
Constraint.__index = function(self, key)
  if key == "name" then return self._constraintData.name end
  return rawget(Constraint, key) or BaseObject[key]
end
setmetatable(Constraint, { __index = BaseObject })

Constraint._helpMatrix = Matrix.new()
Constraint._helpTransform = Transform.new()
Constraint._helpPoint = Point.new()

-- TS abstract base has no direct public constructor. Subclasses use this
-- allocation path to preserve BaseObject field initialization and pooling.
function Constraint.new(classType)
  return BaseObject.new(classType)
end

function Constraint:_onClear()
  self._armature = nil
  self._target = nil
  self._root = nil
  self._bone = nil
end

-- No fake implementations of the three abstract methods init/update/
-- invalidUpdate in the base type: they are defined only by subclasses.
local IKConstraint = {}
IKConstraint.__index = function(self, key)
  return rawget(IKConstraint, key) or Constraint.__index(self, key)
end
setmetatable(IKConstraint, { __index = Constraint })

function IKConstraint.toString()
  return "[class dragonBones.IKConstraint]"
end
function IKConstraint.new()
  return Constraint.new(IKConstraint)
end
function IKConstraint:_onClear()
  Constraint._onClear(self)
  -- Original _scaleEnabled is a commented TODO, not a field.
  self._bendPositive = false
  self._weight = 1.0
  self._constraintData = nil
end

function IKConstraint:_computeA()
  local ikGlobal = self._target.global
  local global = self._root.global
  local globalTransformMatrix = self._root.globalTransformMatrix
  local radian = atan2(ikGlobal.y - global.y, ikGlobal.x - global.x)
  if global.scaleX < 0.0 then radian = radian + math.pi end
  global.rotation = global.rotation +
    Transform.normalizeRadian(radian - global.rotation) * self._weight
  global:toMatrix(globalTransformMatrix)
end

function IKConstraint:_computeB()
  local boneLength = self._bone._boneData.length
  local parent = self._root
  local ikGlobal = self._target.global
  local parentGlobal = parent.global
  local global = self._bone.global
  local globalTransformMatrix = self._bone.globalTransformMatrix

  local x = globalTransformMatrix.a * boneLength
  local y = globalTransformMatrix.b * boneLength
  local lLL = x * x + y * y
  local lL = math.sqrt(lLL)
  local dX = global.x - parentGlobal.x
  local dY = global.y - parentGlobal.y
  local lPP = dX * dX + dY * dY
  local lP = math.sqrt(lPP)
  local rawRadian = global.rotation
  local rawParentRadian = parentGlobal.rotation
  local rawRadianA = atan2(dY, dX)

  dX = ikGlobal.x - parentGlobal.x
  dY = ikGlobal.y - parentGlobal.y
  local lTT = dX * dX + dY * dY
  local lT = math.sqrt(lTT)

  local radianA = 0.0
  if lL + lP <= lT or lT + lL <= lP or lT + lP <= lL then
    radianA = atan2(ikGlobal.y - parentGlobal.y, ikGlobal.x - parentGlobal.x)
    if lL + lP <= lT then
      -- Empty branch in pinned original, deliberately preserved.
    elseif lP < lL then
      radianA = radianA + math.pi
    end
  else
    local h = (lPP - lLL + lTT) / (2.0 * lTT)
    local r = math.sqrt(lPP - h * h * lTT) / lT
    local hX = parentGlobal.x + (dX * h)
    local hY = parentGlobal.y + (dY * h)
    local rX = -dY * r
    local rY = dX * r
    local isPPR = false
    local parentParent = parent.parent
    if parentParent ~= nil then
      local parentParentMatrix = parentParent.globalTransformMatrix
      isPPR = parentParentMatrix.a * parentParentMatrix.d -
        parentParentMatrix.b * parentParentMatrix.c < 0.0
    end

    if isPPR ~= self._bendPositive then
      global.x = hX - rX
      global.y = hY - rY
    else
      global.x = hX + rX
      global.y = hY + rY
    end
    radianA = atan2(global.y - parentGlobal.y, global.x - parentGlobal.x)
  end

  local dR = Transform.normalizeRadian(radianA - rawRadianA)
  parentGlobal.rotation = rawParentRadian + dR * self._weight
  parentGlobal:toMatrix(parent.globalTransformMatrix)
  local currentRadianA = rawRadianA + dR * self._weight
  global.x = parentGlobal.x + math.cos(currentRadianA) * lP
  global.y = parentGlobal.y + math.sin(currentRadianA) * lP

  local radianB = atan2(ikGlobal.y - global.y, ikGlobal.x - global.x)
  if global.scaleX < 0.0 then radianB = radianB + math.pi end
  global.rotation = parentGlobal.rotation + rawRadian - rawParentRadian +
    Transform.normalizeRadian(radianB - dR - rawRadian) * self._weight
  global:toMatrix(globalTransformMatrix)
end

function IKConstraint:init(constraintData, armature)
  if self._constraintData ~= nil then return end
  self._constraintData = constraintData
  self._armature = armature
  self._target = self._armature:getBone(self._constraintData.target.name)
  self._root = self._armature:getBone(self._constraintData.root.name)
  self._bone = self._constraintData.bone ~= nil and
    self._armature:getBone(self._constraintData.bone.name) or nil
  self._bendPositive = self._constraintData.bendPositive
  self._weight = self._constraintData.weight
  self._root._hasConstraint = true
end
function IKConstraint:update()
  self._root:updateByConstraint()
  if self._bone ~= nil then
    self._bone:updateByConstraint()
    self:_computeB()
  else
    self:_computeA()
  end
end
function IKConstraint:invalidUpdate()
  self._root:invalidUpdate()
  if self._bone ~= nil then self._bone:invalidUpdate() end
end

local PathConstraint = {}
PathConstraint.__index = function(self, key)
  return rawget(PathConstraint, key) or Constraint.__index(self, key)
end
setmetatable(PathConstraint, { __index = Constraint })

function PathConstraint.toString()
  return "[class dragonBones.PathConstraint]"
end
function PathConstraint.new()
  local obj = Constraint.new(PathConstraint)
  obj._bones = array()
  obj._spaces = array()
  obj._positions = array()
  obj._curves = array()
  obj._boneLengths = array()
  obj._pathGlobalVertices = array()
  -- The pinned source initializes _segments to [10], not Array(10).
  obj._segments = array(10)
  return obj
end
function PathConstraint:_onClear()
  Constraint._onClear(self)
  self.dirty = false
  self.pathOffset = 0
  self.position = 0.0
  self.spacing = 0.0
  self.rotateOffset = 0.0
  self.rotateMix = 1.0
  self.translateMix = 1.0
  self._pathSlot = nil
  resize(self._bones, 0)
  resize(self._spaces, 0)
  resize(self._positions, 0)
  resize(self._curves, 0)
  resize(self._boneLengths, 0)
  resize(self._pathGlobalVertices, 0)
  -- Original does not clear or resize _segments in _onClear.
end

function PathConstraint:_updatePathVertices(verticesData)
  local armature = self._armature
  local dragonBonesData = armature.armatureData.parent
  local scale = armature.armatureData.scale
  local intArray = dragonBonesData.intArray
  local floatArray = dragonBonesData.floatArray
  local pathOffset = verticesData.offset
  local pathVertexCount = get(intArray, pathOffset + Core.BinaryOffset.GeometryVertexCount)
  local pathVertexOffset = get(intArray, pathOffset + Core.BinaryOffset.GeometryFloatOffset)
  resize(self._pathGlobalVertices, pathVertexCount * 2)
  local weightData = verticesData.weight

  if weightData == nil then
    local parentBone = self._pathSlot.parent
    parentBone:updateByConstraint()
    local matrix = parentBone.globalTransformMatrix

    -- Source deliberately increments i by 2 and iV by 2, hence only half
    -- the pathVertexCount entries are written in this nonweighted branch.
    local iV = pathVertexOffset
    for i = 0, pathVertexCount - 1, 2 do
      local vx = get(floatArray, iV) * scale; iV = iV + 1
      local vy = get(floatArray, iV) * scale; iV = iV + 1
      local x = matrix.a * vx + matrix.c * vy + matrix.tx
      local y = matrix.b * vx + matrix.d * vy + matrix.ty
      put(self._pathGlobalVertices, i, x)
      put(self._pathGlobalVertices, i + 1, y)
    end
    return
  end

  local bones = self._pathSlot._geometryBones
  local weightBoneCount = #weightData.bones
  local weightOffset = weightData.offset
  local floatOffset = get(intArray, weightOffset + Core.BinaryOffset.WeigthFloatOffset)
  local iV = floatOffset
  local iB = weightOffset + Core.BinaryOffset.WeigthBoneIndices + weightBoneCount
  local iW = 0

  for i = 0, pathVertexCount - 1 do
    local vertexBoneCount = get(intArray, iB)
    iB = iB + 1
    local xG, yG = 0.0, 0.0
    for ii = 0, vertexBoneCount - 1 do
      local boneIndex = get(intArray, iB)
      iB = iB + 1
      local bone = get(bones, boneIndex)
      if bone ~= nil then
        bone:updateByConstraint()
        local matrix = bone.globalTransformMatrix
        local weight = get(floatArray, iV); iV = iV + 1
        local vx = get(floatArray, iV) * scale; iV = iV + 1
        local vy = get(floatArray, iV) * scale; iV = iV + 1
        xG = xG + (matrix.a * vx + matrix.c * vy + matrix.tx) * weight
        yG = yG + (matrix.b * vx + matrix.d * vy + matrix.ty) * weight
      end
    end
    put(self._pathGlobalVertices, iW, xG); iW = iW + 1
    put(self._pathGlobalVertices, iW, yG); iW = iW + 1
  end
end

function PathConstraint:_computeVertices(start, count, offset, out)
  -- Preserve the source loop bounds: i < count, not i < offset+count.
  local iW = start
  for i = offset, count - 1, 2 do
    put(out, i, get(self._pathGlobalVertices, iW)); iW = iW + 1
    put(out, i + 1, get(self._pathGlobalVertices, iW)); iW = iW + 1
  end
end

function PathConstraint:addCurvePosition(t, x1, y1, cx1, cy1, cx2, cy2,
    x2, y2, out, offset, tangents)
  if t == 0 then
    put(out, offset, x1)
    put(out, offset + 1, y1)
    put(out, offset + 2, 0)
    return
  end
  if t == 1 then
    put(out, offset, x2)
    put(out, offset + 1, y2)
    put(out, offset + 2, 0)
    return
  end

  local mt = 1 - t
  local mt2 = mt * mt
  local t2 = t * t
  local a = mt2 * mt
  local b = mt2 * t * 3
  local c = mt * t2 * 3
  local d = t * t2
  local x = a * x1 + b * cx1 + c * cx2 + d * x2
  local y = a * y1 + b * cy1 + c * cy2 + d * y2

  put(out, offset, x)
  put(out, offset + 1, y)
  if tangents then
    put(out, offset + 2, atan2(y - (a * y1 + b * cy1 + c * cy2),
      x - (a * x1 + b * cx1 + c * cx2)))
  else
    put(out, offset + 2, 0)
  end
end

function PathConstraint:_computeBezierCurve(pathDisplayDta, spaceCount,
    tangents, percentPosition, percentSpacing)
  local armature = self._armature
  local intArray = armature.armatureData.parent.intArray
  local vertexCount = get(intArray,
    pathDisplayDta.geometry.offset + Core.BinaryOffset.GeometryVertexCount)
  local positions = self._positions
  local spaces = self._spaces
  local isClosed = pathDisplayDta.closed
  local curveVertices = array()
  local verticesLength = vertexCount * 2
  local curveCount = verticesLength / 6
  local preCurve = -1
  local position = self.position

  resize(positions, spaceCount * 3 + 2)
  local pathLength = 0.0

  if not pathDisplayDta.constantSpeed then
    local lenghts = pathDisplayDta.curveLengths -- misspelling preserved.
    curveCount = curveCount - (isClosed and 1 or 2)
    pathLength = get(lenghts, curveCount)
    if percentPosition then position = position * pathLength end
    if percentSpacing then
      for i = 0, spaceCount - 1 do
        put(spaces, i, get(spaces, i) * pathLength)
      end
    end

    resize(curveVertices, 8)
    local o, curve = 0, 0
    for i = 0, spaceCount - 1 do
      local space = get(spaces, i)
      position = position + space
      local skip = false
      if isClosed then
        position = jsRemainder(position, pathLength)
        if position < 0 then position = position + pathLength end
        curve = 0
      elseif position < 0 or position > pathLength then
        -- Both source TODO branches skip without writing a position.
        skip = true
      end

      if not skip then
      local percent = 0.0
      while true do
        local len = get(lenghts, curve)
        if position > len then
          curve = curve + 1
        else
          if curve == 0 then
            percent = position / len
          else
            local preLen = get(lenghts, curve - 1)
            percent = (position - preLen) / (len - preLen)
          end
          break
        end
      end
      if curve ~= preCurve then
        preCurve = curve
        if isClosed and curve == curveCount then
          self:_computeVertices(verticesLength - 4, 4, 0, curveVertices)
          self:_computeVertices(0, 4, 4, curveVertices)
        else
          self:_computeVertices(curve * 6 + 2, 8, 0, curveVertices)
        end
      end

      self:addCurvePosition(percent,
        get(curveVertices, 0), get(curveVertices, 1),
        get(curveVertices, 2), get(curveVertices, 3),
        get(curveVertices, 4), get(curveVertices, 5),
        get(curveVertices, 6), get(curveVertices, 7),
        positions, o, tangents)
      end
      o = o + 3
    end
    return
  end

  if isClosed then
    verticesLength = verticesLength + 2
    resize(curveVertices, vertexCount)
    self:_computeVertices(2, verticesLength - 4, 0, curveVertices)
    self:_computeVertices(0, 2, verticesLength - 4, curveVertices)
    put(curveVertices, verticesLength - 2, get(curveVertices, 0))
    put(curveVertices, verticesLength - 1, get(curveVertices, 1))
  else
    curveCount = curveCount - 1
    verticesLength = verticesLength - 4
    resize(curveVertices, verticesLength)
    self:_computeVertices(2, verticesLength, 0, curveVertices)
  end

  -- Source intentionally computes its own 4-step curve approximation.
  local curves = array()
  resize(curves, curveCount)
  pathLength = 0
  local x1, y1 = get(curveVertices, 0), get(curveVertices, 1)
  local cx1, cy1, cx2, cy2, x2, y2 = 0, 0, 0, 0, 0, 0
  local tmpx, tmpy, dddfx, dddfy, ddfx, ddfy, dfx, dfy
  local w = 2
  for i = 0, curveCount - 1 do
    cx1 = get(curveVertices, w)
    cy1 = get(curveVertices, w + 1)
    cx2 = get(curveVertices, w + 2)
    cy2 = get(curveVertices, w + 3)
    x2 = get(curveVertices, w + 4)
    y2 = get(curveVertices, w + 5)
    tmpx = (x1 - cx1 * 2 + cx2) * 0.1875
    tmpy = (y1 - cy1 * 2 + cy2) * 0.1875
    dddfx = ((cx1 - cx2) * 3 - x1 + x2) * 0.09375
    dddfy = ((cy1 - cy2) * 3 - y1 + y2) * 0.09375
    ddfx = tmpx * 2 + dddfx
    ddfy = tmpy * 2 + dddfy
    dfx = (cx1 - x1) * 0.75 + tmpx + dddfx * 0.16666667
    dfy = (cy1 - y1) * 0.75 + tmpy + dddfy * 0.16666667
    pathLength = pathLength + math.sqrt(dfx * dfx + dfy * dfy)
    dfx = dfx + ddfx; dfy = dfy + ddfy
    ddfx = ddfx + dddfx; ddfy = ddfy + dddfy
    pathLength = pathLength + math.sqrt(dfx * dfx + dfy * dfy)
    dfx = dfx + ddfx; dfy = dfy + ddfy
    pathLength = pathLength + math.sqrt(dfx * dfx + dfy * dfy)
    dfx = dfx + ddfx + dddfx; dfy = dfy + ddfy + dddfy
    pathLength = pathLength + math.sqrt(dfx * dfx + dfy * dfy)
    put(curves, i, pathLength)
    x1, y1 = x2, y2
    w = w + 6
  end

  if percentPosition then position = position * pathLength end
  if percentSpacing then
    for i = 0, spaceCount - 1 do put(spaces, i, get(spaces, i) * pathLength) end
  end

  local segments = self._segments
  local curveLength = 0
  local o, curve, segment = 0, 0, 0
  for i = 0, spaceCount - 1 do
    local space = get(spaces, i)
    position = position + space
    local p = position
    if isClosed then
      p = jsRemainder(p, pathLength)
      if p < 0 then p = p + pathLength end
      curve = 0
    elseif p < 0 or p > pathLength then
      goto continue_constant
    end
    while true do
      local length = get(curves, curve)
      if p > length then
        curve = curve + 1
      else
        if curve == 0 then
          p = p / length
        else
          local prev = get(curves, curve - 1)
          p = (p - prev) / (length - prev)
        end
        break
      end
    end

    if curve ~= preCurve then
      preCurve = curve
      local ii = curve * 6
      x1 = get(curveVertices, ii)
      y1 = get(curveVertices, ii + 1)
      cx1 = get(curveVertices, ii + 2)
      cy1 = get(curveVertices, ii + 3)
      cx2 = get(curveVertices, ii + 4)
      cy2 = get(curveVertices, ii + 5)
      x2 = get(curveVertices, ii + 6)
      y2 = get(curveVertices, ii + 7)
      tmpx = (x1 - cx1 * 2 + cx2) * 0.03
      tmpy = (y1 - cy1 * 2 + cy2) * 0.03
      dddfx = ((cx1 - cx2) * 3 - x1 + x2) * 0.006
      dddfy = ((cy1 - cy2) * 3 - y1 + y2) * 0.006
      ddfx = tmpx * 2 + dddfx
      ddfy = tmpy * 2 + dddfy
      dfx = (cx1 - x1) * 0.3 + tmpx + dddfx * 0.16666667
      dfy = (cy1 - y1) * 0.3 + tmpy + dddfy * 0.16666667
      curveLength = math.sqrt(dfx * dfx + dfy * dfy)
      put(segments, 0, curveLength)
      for j = 1, 7 do
        dfx = dfx + ddfx
        dfy = dfy + ddfy
        ddfx = ddfx + dddfx
        ddfy = ddfy + dddfy
        curveLength = curveLength + math.sqrt(dfx * dfx + dfy * dfy)
        put(segments, j, curveLength)
      end
      dfx = dfx + ddfx; dfy = dfy + ddfy
      curveLength = curveLength + math.sqrt(dfx * dfx + dfy * dfy)
      put(segments, 8, curveLength)
      dfx = dfx + ddfx + dddfx; dfy = dfy + ddfy + dddfy
      curveLength = curveLength + math.sqrt(dfx * dfx + dfy * dfy)
      put(segments, 9, curveLength)
      segment = 0
    end

    p = p * curveLength
    while true do
      local length = get(segments, segment)
      if p > length then
        segment = segment + 1
      else
        if segment == 0 then
          p = p / length
        else
          local prev = get(segments, segment - 1)
          p = segment + (p - prev) / (length - prev)
        end
        break
      end
    end
    self:addCurvePosition(p * 0.1, x1, y1, cx1, cy1, cx2, cy2, x2, y2,
      positions, o, tangents)
    ::continue_constant::
    o = o + 3
  end
end

function PathConstraint:init(constraintData, armature)
  -- No duplicate-init guard in the original PathConstraint.
  self._constraintData = constraintData
  self._armature = armature
  local data = constraintData
  self.pathOffset = data.pathDisplayData.geometry.offset
  self.position = data.position
  self.spacing = data.spacing
  self.rotateOffset = data.rotateOffset
  self.rotateMix = data.rotateMix
  self.translateMix = data.translateMix

  self._root = self._armature:getBone(data.root.name)
  self._target = self._armature:getBone(data.target.name)
  self._pathSlot = self._armature:getSlot(data.pathSlot.name)
  for _, boneData in ipairs(data.bones) do
    local bone = self._armature:getBone(boneData.name)
    if bone ~= nil then put(self._bones, self._bones.length, bone) end
  end
  if data.rotateMode == Core.RotateMode.ChainScale then
    resize(self._boneLengths, self._bones.length)
  end
  self._root._hasConstraint = true
end

function PathConstraint:update()
  local pathSlot = self._pathSlot
  if pathSlot._geometryData == nil or pathSlot._geometryData.offset ~= self.pathOffset then
    return
  end
  local constraintData = self._constraintData
  local isPathVerticeDirty = false
  if self._root._childrenTransformDirty then
    self:_updatePathVertices(pathSlot._geometryData)
    isPathVerticeDirty = true
  elseif pathSlot._verticesDirty or pathSlot:_isBonesUpdate() then
    self:_updatePathVertices(pathSlot._geometryData)
    pathSlot._verticesDirty = false
    isPathVerticeDirty = true
  end
  if not isPathVerticeDirty and not self.dirty then return end

  local positionMode = constraintData.positionMode
  local spacingMode = constraintData.spacingMode
  local rotateMode = constraintData.rotateMode
  local bones = self._bones
  local isLengthMode = spacingMode == Core.SpacingMode.Length
  local isChainScaleMode = rotateMode == Core.RotateMode.ChainScale
  local isTangentMode = rotateMode == Core.RotateMode.Tangent
  local boneCount = bones.length
  local spacesCount = isTangentMode and boneCount or boneCount + 1
  local spacing = self.spacing
  local spaces = self._spaces
  resize(spaces, spacesCount)

  if isChainScaleMode or isLengthMode then
    put(spaces, 0, 0)
    for i = 0, spacesCount - 2 do
      local bone = get(bones, i)
      bone:updateByConstraint()
      local boneLength = bone._boneData.length
      local matrix = bone.globalTransformMatrix
      local x = boneLength * matrix.a
      local y = boneLength * matrix.b
      local len = math.sqrt(x * x + y * y)
      if isChainScaleMode then put(self._boneLengths, i, len) end
      put(spaces, i + 1, (boneLength + spacing) * len / boneLength)
    end
  else
    for i = 0, spacesCount - 1 do put(spaces, i, spacing) end
  end

  self:_computeBezierCurve(pathSlot._displayFrame.rawDisplayData, spacesCount,
    isTangentMode, positionMode == Core.PositionMode.Percent,
    spacingMode == Core.SpacingMode.Percent)
  local positions = self._positions
  local rotateOffset = self.rotateOffset
  local boneX, boneY = get(positions, 0), get(positions, 1)
  local tip
  if rotateOffset == 0 then
    tip = rotateMode == Core.RotateMode.Chain
  else
    tip = false
    local bone = pathSlot.parent
    if bone ~= nil then
      local matrix = bone.globalTransformMatrix
      rotateOffset = rotateOffset * ((matrix.a * matrix.d - matrix.b * matrix.c > 0)
        and Transform.DEG_RAD or -Transform.DEG_RAD)
    end
  end

  local rotateMix = self.rotateMix
  local translateMix = self.translateMix
  local p = 3
  for i = 0, boneCount - 1 do
    local bone = get(bones, i)
    bone:updateByConstraint()
    local matrix = bone.globalTransformMatrix
    matrix.tx = matrix.tx + (boneX - matrix.tx) * translateMix
    matrix.ty = matrix.ty + (boneY - matrix.ty) * translateMix
    local x, y = get(positions, p), get(positions, p + 1)
    -- Missing JS Array entries convert to NaN in numeric expressions.
    -- Lua nil would throw instead; preserve JS propagation, not a zero fallback.
    if x == nil then x = 0.0 / 0.0 end
    if y == nil then y = 0.0 / 0.0 end
    if boneX == nil then boneX = 0.0 / 0.0 end
    if boneY == nil then boneY = 0.0 / 0.0 end
    local dx, dy = x - boneX, y - boneY
    if isChainScaleMode then
      local lenght = get(self._boneLengths, i)
      local s = (math.sqrt(dx * dx + dy * dy) / lenght - 1) * rotateMix + 1
      matrix.a = matrix.a * s
      matrix.b = matrix.b * s
    end
    boneX, boneY = x, y
    if rotateMix > 0 then
      local a, b, c, d = matrix.a, matrix.b, matrix.c, matrix.d
      local r, cos, sin
      if isTangentMode then r = get(positions, p - 1)
      else r = atan2(dy, dx) end
      r = r - atan2(b, a)
      if tip then
        cos = math.cos(r)
        sin = math.sin(r)
        local length = bone._boneData.length
        boneX = boneX + (length * (cos * a - sin * b) - dx) * rotateMix
        boneY = boneY + (length * (sin * a + cos * b) - dy) * rotateMix
      else
        r = r + rotateOffset
      end
      if r > Transform.PI then r = r - Transform.PI_D
      elseif r < -Transform.PI then r = r + Transform.PI_D end
      r = r * rotateMix
      cos = math.cos(r)
      sin = math.sin(r)
      matrix.a = cos * a - sin * b
      matrix.b = sin * a + cos * b
      matrix.c = cos * c - sin * d
      matrix.d = sin * c + cos * d
    end
    bone.global:fromMatrix(matrix)
    p = p + 3
  end
  self.dirty = false
end

function PathConstraint:invalidUpdate()
  -- Empty in original.
end

return {
  Constraint = Constraint,
  IKConstraint = IKConstraint,
  PathConstraint = PathConstraint,
}
