-- DragonBonesJS original commit 64b6c69ae35777c2404be68c9192e2c56906079e
-- Copyright (c) 2012-2025 DragonBones team and other contributors.
-- MIT license: see LICENSE-DRAGONBONES.
-- Exact source: DragonBones/src/dragonBones/model/ConstraintData.ts
local BaseObject=require("dragonbones.original.core.BaseObject")
local Core=require("dragonbones.original.core.DragonBones")
local ConstraintData={}
ConstraintData.__index=ConstraintData
setmetatable(ConstraintData,{__index=BaseObject})

function ConstraintData.new(classType)
  return BaseObject.new(classType)
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
  object.bones={}
  return object
end

function PathConstraintData:_onClear()
  ConstraintData._onClear(self)
  self.pathSlot=nil
  self.pathDisplayData=nil
  for i=#self.bones,1,-1 do
    self.bones[i]=nil
  end

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
  self.bones[#self.bones+1]=value
end

return {
  ConstraintData=ConstraintData,
  IKConstraintData=IKConstraintData,
  PathConstraintData=PathConstraintData
}
