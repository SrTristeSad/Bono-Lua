-- Ported from DragonBonesJS commit 64b6c69ae35777c2404be68c9192e2c56906079e
-- Copyright (c) 2012-2025 DragonBones team and other contributors.
-- MIT license: see LICENSE-DRAGONBONES.
-- Original: DragonBones/src/dragonBones/model/DisplayData.ts
-- All original classes/methods in this file are represented below.
local BaseObject=require("dragonbones.core.BaseObject")
local Core=require("dragonbones.core.Enums")
local Transform=require("dragonbones.geom.Transform")
local Point=require("dragonbones.geom.Point")
local JSArray=require("dragonbones.core.JSArray")

-- GeometryData is NOT a BaseObject in the source.
local GeometryData={}
-- intArray is an already-decoded Int16Array boundary, represented base 1.
-- Validate the JS index before shifting: tiny fractions can round to 1 in Lua.
local function geometryCount(self, binaryOffset)
  local intArray=self.data.intArray
  local offset=self.offset
  if offset==nil then offset=0/0 end -- undefined in numeric addition -> NaN
  local index=offset+binaryOffset
  if intArray==nil then error("GeometryData intArray is absent") end
  if index~=index or index<0 or index==math.huge or index~=math.floor(index) then
    return nil
  end
  return intArray[index+1]
end
function GeometryData.__index(self,key)
  if key=="vertexCount" then
    return geometryCount(self,Core.BinaryOffset.GeometryVertexCount)
  elseif key=="triangleCount" then
    return geometryCount(self,Core.BinaryOffset.GeometryTriangleCount)
  end
  return rawget(GeometryData,key)
end
function GeometryData.__newindex(self,key,value)
  if key=="vertexCount" or key=="triangleCount" then
    error("Readonly property: "..key)
  end
  rawset(self,key,value)
end
function GeometryData.new()
  return setmetatable({weight=nil},GeometryData)
end
function GeometryData:clear()
  if not self.isShared and self.weight~=nil then
    self.weight:returnToPool()
  end
  self.isShared=false
  self.inheritDeform=false
  self.offset=0
  self.data=nil
  self.weight=nil
end
function GeometryData:shareFrom(value)
  self.isShared=true
  self.offset=value.offset
  self.weight=value.weight
end

local DisplayData={}
DisplayData.__index=DisplayData
setmetatable(DisplayData,{__index=BaseObject})

-- Abstract class: subclasses call DisplayData.new(ConcreteClass).
function DisplayData.new(classType)
  local self=BaseObject.new(classType or DisplayData)
  self.transform=Transform.new()
  return self
end
function DisplayData:_onClear()
  self.name=""
  self.path=""
  self.transform:identity()
  self.parent=nil
end

local ImageDisplayData={}
ImageDisplayData.__index=ImageDisplayData
setmetatable(ImageDisplayData,{__index=DisplayData})
function ImageDisplayData.toString()
  return "[class dragonBones.ImageDisplayData]"
end
function ImageDisplayData.new()
  local self=DisplayData.new(ImageDisplayData)
  self.pivot=Point.new()
  return self
end
function ImageDisplayData:_onClear()
  DisplayData._onClear(self)
  self.type=Core.DisplayType.Image
  self.pivot:clear()
  self.texture=nil
end

local ArmatureDisplayData={}
ArmatureDisplayData.__index=ArmatureDisplayData
setmetatable(ArmatureDisplayData,{__index=DisplayData})
function ArmatureDisplayData.toString()
  return "[class dragonBones.ArmatureDisplayData]"
end
function ArmatureDisplayData.new()
  local self=DisplayData.new(ArmatureDisplayData)
  self.actions=JSArray.new()
  return self
end
function ArmatureDisplayData:_onClear()
  DisplayData._onClear(self)
  local index=1
  while index<=self.actions.length do
    self.actions[index]:returnToPool()
    index=index+1
  end
  self.type=Core.DisplayType.Armature
  self.inheritAnimation=false
  self.actions.length=0
  self.armature=nil
end
function ArmatureDisplayData:addAction(value)
  self.actions[self.actions.length+1]=value
end

local MeshDisplayData={}
MeshDisplayData.__index=MeshDisplayData
setmetatable(MeshDisplayData,{__index=DisplayData})
function MeshDisplayData.toString()
  return "[class dragonBones.MeshDisplayData]"
end
function MeshDisplayData.new()
  local self=DisplayData.new(MeshDisplayData)
  self.geometry=GeometryData.new()
  return self
end
function MeshDisplayData:_onClear()
  DisplayData._onClear(self)
  self.type=Core.DisplayType.Mesh
  self.geometry:clear()
  self.texture=nil
end

local BoundingBoxDisplayData={}
BoundingBoxDisplayData.__index=BoundingBoxDisplayData
setmetatable(BoundingBoxDisplayData,{__index=DisplayData})
function BoundingBoxDisplayData.toString()
  return "[class dragonBones.BoundingBoxDisplayData]"
end
function BoundingBoxDisplayData.new()
  return DisplayData.new(BoundingBoxDisplayData)
end
function BoundingBoxDisplayData:_onClear()
  DisplayData._onClear(self)
  if self.boundingBox~=nil then
    self.boundingBox:returnToPool()
  end
  self.type=Core.DisplayType.BoundingBox
  self.boundingBox=nil
end

local PathDisplayData={}
PathDisplayData.__index=PathDisplayData
setmetatable(PathDisplayData,{__index=DisplayData})
function PathDisplayData.toString()
  return "[class dragonBones.PathDisplayData]"
end
function PathDisplayData.new()
  local self=DisplayData.new(PathDisplayData)
  self.geometry=GeometryData.new()
  self.curveLengths=JSArray.new()
  return self
end
function PathDisplayData:_onClear()
  DisplayData._onClear(self)
  self.type=Core.DisplayType.Path
  self.closed=false
  self.constantSpeed=false
  self.geometry:clear()
  self.curveLengths.length=0
end

local WeightData={}
WeightData.__index=WeightData
setmetatable(WeightData,{__index=BaseObject})
function WeightData.toString()
  return "[class dragonBones.WeightData]"
end
function WeightData.new()
  local self=BaseObject.new(WeightData)
  self.bones=JSArray.new()
  return self
end
function WeightData:_onClear()
  self.count=0
  self.offset=0
  self.bones.length=0
end
function WeightData:addBone(value)
  self.bones[self.bones.length+1]=value
end

return {
  GeometryData=GeometryData,
  DisplayData=DisplayData,
  ImageDisplayData=ImageDisplayData,
  ArmatureDisplayData=ArmatureDisplayData,
  MeshDisplayData=MeshDisplayData,
  BoundingBoxDisplayData=BoundingBoxDisplayData,
  PathDisplayData=PathDisplayData,
  WeightData=WeightData
}
