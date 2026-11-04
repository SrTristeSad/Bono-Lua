-- DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e, armature/Constraint.ts.
-- Copyright (c) 2012-2025 DragonBones team and contributors; MIT.
-- Abstract Constraint base only; concrete IKConstraint is a separate module.
local BaseObject = require('dragonbones.core.BaseObject')
local Matrix = require('dragonbones.geom.Matrix')
local Transform = require('dragonbones.geom.Transform')
local Point = require('dragonbones.geom.Point')
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
  return BaseObject.new(classType or Constraint)
end

function Constraint.__newindex(self,key,value)
  if key == "name" then error("Readonly property: name") end
  rawset(self,key,value)
end

function Constraint:_onClear()
  self._armature = nil
  self._target = nil
  self._root = nil
  self._bone = nil
end

-- No fake implementations of the three abstract methods init/update/
-- invalidUpdate in the base type: they are defined only by subclasses.

return Constraint
