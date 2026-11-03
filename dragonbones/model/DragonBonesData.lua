-- Ported from DragonBonesJS commit 64b6c69ae35777c2404be68c9192e2c56906079e
-- Copyright (c) 2012-2025 DragonBones team and other contributors.
-- MIT license: see LICENSE-DRAGONBONES.
-- Original: DragonBones/src/dragonBones/model/DragonBonesData.ts
local BaseObject=require("dragonbones.core.BaseObject")
local JSArray=require("dragonbones.core.JSArray")
local JSMap=require("dragonbones.core.JSMap")
local DragonBonesData={}
DragonBonesData.__index=DragonBonesData
setmetatable(DragonBonesData,{__index=BaseObject})

function DragonBonesData.toString()
  return "[class dragonBones.DragonBonesData]"
end
function DragonBonesData.new()
  local self=BaseObject.new(DragonBonesData)
  self.frameIndices=JSArray.new()
  self.cachedFrames=JSArray.new()
  self.armatureNames=JSArray.new()
  self.armatures=JSMap.new()
  self.userData=nil -- Original initializer is null, unlike other references.
  return self
end
function DragonBonesData:_onClear()
  for _,key in ipairs(JSMap.keys(self.armatures)) do
    local armature=self.armatures[key]
    if armature~=nil then
      armature:returnToPool()
      JSMap.remove(self.armatures,key)
    end
  end
  if self.userData~=nil then self.userData:returnToPool() end
  self.autoSearch=false
  self.frameRate=0
  self.version=""
  self.name=""
  self.stage=nil
  self.frameIndices.length=0
  self.cachedFrames.length=0
  self.armatureNames.length=0
  -- Buffer/view references are stored unchanged. Decoding and typed views
  -- belong to the parser boundary; this class does not create them in TS.
  self.binary=nil
  self.intArray=nil
  self.floatArray=nil
  self.frameIntArray=nil
  self.frameFloatArray=nil
  self.frameArray=nil
  self.timelineArray=nil
  self.colorArray=nil
  self.userData=nil
end
function DragonBonesData:addArmature(value)
  if self.armatures[value.name]~=nil then
    io.stderr:write("Same armature: "..tostring(value.name).."\n")
    return
  end
  value.parent=self
  self.armatures[value.name]=value
  local length=self.armatureNames.length
  self.armatureNames[length+1]=value.name
  self.armatureNames.length=length+1
end
function DragonBonesData:getArmature(armatureName)
  return self.armatures[armatureName]
end
return DragonBonesData
