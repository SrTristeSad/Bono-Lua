-- DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e, armature/Constraint.ts.
-- Copyright (c) 2012-2025 DragonBones team and contributors; MIT.
-- IK solver only. PathConstraint and Animation remain separate pending units.
local Constraint = require('dragonbones.armature.Constraint')
local Transform = require('dragonbones.geom.Transform')
local function atan2(y,x)
  if math.atan2 then return math.atan2(y,x) end
  return math.atan(y,x)
end
local IKConstraint = {}
IKConstraint.__index = function(self, key)
  return rawget(IKConstraint, key) or Constraint.__index(self, key)
end
IKConstraint.__newindex = Constraint.__newindex
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
    local rX = -(dY * 1.0) * r
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


return IKConstraint
