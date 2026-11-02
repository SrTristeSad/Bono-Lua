-- Ported from DragonBonesJS commit 64b6c69ae35777c2404be68c9192e2c56906079e
-- Copyright (c) 2012-2025 DragonBones team and other contributors.
-- MIT license: see LICENSE-DRAGONBONES.
-- Original: DragonBones/src/dragonBones/model/DragonBonesData.ts
-- Original ArrayBuffer is a shared mutable byte store with 1-based Lua views.
-- Reading binary returns current bytes as an immutable Lua string snapshot.
local BaseObject=require("dragonbones.original.core.BaseObject")
local DragonBonesData={}
-- Original binary is one mutable ArrayBuffer. Expose current bytes on
-- access while retaining the legacy Lua raw-byte-string read contract.
DragonBonesData.__index=function(self,key)
  if key=="binary" then
    local buffer=rawget(self,"_binaryBuffer")
    if buffer~=nil then return buffer:toString() end
  end
  return rawget(DragonBonesData,key) or BaseObject[key]
end
setmetatable(DragonBonesData,{__index=BaseObject})

function DragonBonesData.toString()
  return "[class dragonBones.DragonBonesData]"
end
function DragonBonesData.new()
  local self=BaseObject.new(DragonBonesData)
  self.frameIndices={}
  self.cachedFrames={}
  self.armatureNames={}
  self.armatures={}
  self.userData=nil
  return self
end
function DragonBonesData:_onClear()
  for key,armature in pairs(self.armatures) do
    armature:returnToPool()
    self.armatures[key]=nil
  end
  if self.userData~=nil then
    self.userData:returnToPool()
  end

  self.autoSearch=false
  self.frameRate=0
  self.version=""
  self.name=""
  self.stage=nil
  for i=#self.frameIndices,1,-1 do self.frameIndices[i]=nil end
  for i=#self.cachedFrames,1,-1 do self.cachedFrames[i]=nil end
  for i=#self.armatureNames,1,-1 do self.armatureNames[i]=nil end

  self.binary=nil
  self._binaryBuffer=nil
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
  self.armatureNames[#self.armatureNames+1]=value.name
end
function DragonBonesData:getArmature(armatureName)
  return self.armatures[armatureName]
end
return DragonBonesData
