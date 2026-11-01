-- DragonBonesJS original commit 64b6c69ae35777c2404be68c9192e2c56906079e
-- Copyright (c) 2012-2025 DragonBones team and other contributors.
-- MIT license: see LICENSE-DRAGONBONES.
-- Exact source: DragonBones/src/dragonBones/armature/TransformObject.ts
-- Abstract TransformObject: subclasses provide a class table to .new(Class).
local BaseObject=require("dragonbones.original.core.BaseObject")
local Matrix=require("dragonbones.original.geom.Matrix")
local Transform=require("dragonbones.original.geom.Transform")
local Point=require("dragonbones.original.geom.Point")

local TransformObject={}
TransformObject.__index=TransformObject
setmetatable(TransformObject,{__index=BaseObject})

TransformObject._helpMatrix=Matrix.new()
TransformObject._helpTransform=Transform.new()
TransformObject._helpPoint=Point.new()

-- Lua translation of TS instance field initializers before _onClear.
function TransformObject.new(classType)
  local object=BaseObject.new(classType)
  object.globalTransformMatrix=Matrix.new()
  object.global=Transform.new()
  object.offset=Transform.new()
  return object
end

function TransformObject:_onClear()
  self.globalTransformMatrix:identity()
  self.global:identity()
  self.offset:identity()
  self.origin=nil
  self.userData=nil

  self._globalDirty=false
  self._alpha=1.0
  self._globalAlpha=1.0
  self._armature=nil
end

function TransformObject:updateGlobalTransform()
  if self._globalDirty then
    self._globalDirty=false
    self.global:fromMatrix(self.globalTransformMatrix)
  end
end

-- Original TS readonly armature getter.
function TransformObject.__index(self,key)
  if key=="armature" then return rawget(self,"_armature") end
  return rawget(TransformObject,key) or BaseObject[key]
end

return TransformObject
