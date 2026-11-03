-- DragonBonesJS original commit 64b6c69ae35777c2404be68c9192e2c56906079e
-- Copyright (c) 2012-2025 DragonBones team and other contributors.
-- MIT license: see LICENSE-DRAGONBONES.
-- Exact source: DragonBones/src/dragonBones/model/ConstraintData.ts
local BaseObject=require("dragonbones.core.BaseObject")
local Core=require("dragonbones.core.Enums")
local JSArray=require("dragonbones.core.JSArray")
local ConstraintData={}
ConstraintData.__index=ConstraintData
setmetatable(ConstraintData,{__index=BaseObject})

function ConstraintData.new(classType)
  return BaseObject.new(classType or ConstraintData)
end

function ConstraintData:_onClear()
  self.order=0
  self.name=""
  self.type=Core.ConstraintType.IK
  self.target=nil
  self.root=nil
  self.bone=nil
end

local IKConstraintData={}
IKConstraintData.__index=IKConstraintData
setmetatable(IKConstraintData,{__index=ConstraintData})

function IKConstraintData.toString()
  return "[class dragonBones.IKConstraintData]"
end

function IKConstraintData.new()
  return ConstraintData.new(IKConstraintData)
end

function IKConstraintData:_onClear()
  ConstraintData._onClear(self)
  self.scaleEnabled=false
  self.bendPositive=false
  self.weight=1.0
end

local PathConstraintData={}
PathConstraintData.__index=PathConstraintData
setmetatable(PathConstraintData,{__index=ConstraintData})

function PathConstraintData.toString()
  return "[class dragonBones.PathConstraintData]"
end

function PathConstraintData.new()
  local object=ConstraintData.new(PathConstraintData)
  object.bones=JSArray.new()
  return object
end

function PathConstraintData:_onClear()
  ConstraintData._onClear(self)
  -- The pinned source leaves type=ConstraintType.IK here; do not invent a Path reset.
  self.pathSlot=nil
  self.pathDisplayData=nil
  self.bones.length=0

  self.positionMode=Core.PositionMode.Fixed
  self.spacingMode=Core.SpacingMode.Fixed
  self.rotateMode=Core.RotateMode.Chain

  self.position=0.0
  self.spacing=0.0
  self.rotateOffset=0.0
  self.rotateMix=0.0
  self.translateMix=0.0
end

function PathConstraintData:AddBone(value)
  local length=self.bones.length
  self.bones[length+1]=value
  -- Array.push sets length after the property write, even at the uint32 limit.
  self.bones.length=length+1
end

return {
  ConstraintData=ConstraintData,
  IKConstraintData=IKConstraintData,
  PathConstraintData=PathConstraintData
}
