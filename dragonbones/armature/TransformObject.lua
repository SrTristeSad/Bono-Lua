-- DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e, TransformObject.ts.
-- Copyright (c) 2012-2025 DragonBones team and contributors; MIT.
local BaseObject = require('dragonbones.core.BaseObject')
local Matrix = require('dragonbones.geom.Matrix')
local Transform = require('dragonbones.geom.Transform')
local Point = require('dragonbones.geom.Point')
local TransformObject = {}
setmetatable(TransformObject, {__index=BaseObject})
TransformObject._helpMatrix = Matrix.new()
TransformObject._helpTransform = Transform.new()
TransformObject._helpPoint = Point.new()

-- Concrete subclasses delegate missing instance members to this function.
function TransformObject.__index(self, key)
  if key == 'armature' then return rawget(self, '_armature') end
  local member = rawget(TransformObject, key)
  if member ~= nil then return member end
  return BaseObject[key]
end
function TransformObject.__newindex(self, key, value)
  if key == 'armature' then error('Readonly property: armature') end
  rawset(self, key, value)
end
function TransformObject.new(classType)
  local object = BaseObject.new(classType or TransformObject)
  object.globalTransformMatrix = Matrix.new()
  object.global = Transform.new()
  object.offset = Transform.new()
  -- Other fields have no source initializers; pool borrowing calls _onClear.
  return object
end
function TransformObject:_onClear()
  self.globalTransformMatrix:identity()
  self.global:identity()
  self.offset:identity()
  self.origin = nil
  self.userData = nil
  self._globalDirty = false
  self._alpha = 1.0
  self._globalAlpha = 1.0
  self._armature = nil
end
function TransformObject:updateGlobalTransform()
  if self._globalDirty then
    self._globalDirty = false
    self.global:fromMatrix(self.globalTransformMatrix)
  end
end
return TransformObject
