-- Partial port: ObjectDataParser.ts, pinned DragonBonesJS
-- 64b6c69ae35777c2404be68c9192e2c56906079e.
-- Copyright (c) 2012-2025 DragonBones team and contributors; MIT.
-- Implemented: initializers, value helpers, atlas parsing and singleton.
-- Armature/animation/geometry parsing methods are still absent, not stubs.
local DataParser=require('dragonbones.parser.DataParser')
local V=require('dragonbones.parser.JSValue')
local Textures=require('dragonbones.model.TextureAtlasData')
local JSArray=require('dragonbones.core.JSArray')
local JSMap=require('dragonbones.core.JSMap')
local Matrix=require('dragonbones.geom.Matrix')
local Transform=require('dragonbones.geom.Transform')
local ColorTransform=require('dragonbones.geom.ColorTransform')
local Point=require('dragonbones.geom.Point')
local ObjectDataParser={}
ObjectDataParser.__index=ObjectDataParser
setmetatable(ObjectDataParser,{__index=DataParser})
function ObjectDataParser._getBoolean(raw,key,defaultValue)
 if V.has(raw,key) then
  local value=V.get(raw,key)
  if type(value)=='boolean' then return value end
  if type(value)=='string' then return value~='0' and value~='NaN' and value~='' and value~='false' and value~='null' and value~='undefined' end
  return V.truthy(value)
 end
 return defaultValue
end
function ObjectDataParser._getNumber(raw,key,defaultValue)
 if V.has(raw,key) then
  local value=V.get(raw,key)
  if rawequal(value,V.NULL) or value=='NaN' then return defaultValue end
  local result=V.number(value);if not V.truthy(result) then return 0 end;return result
 end
 return defaultValue
end
function ObjectDataParser._getString(raw,key,defaultValue)
 if V.has(raw,key) then return V.string(V.get(raw,key)) end
 return defaultValue
end
function ObjectDataParser.new()
  local self=setmetatable({},ObjectDataParser)
  self._rawTextureAtlasIndex=0
  self._rawBones=JSArray.new()
  self._data=nil
  self._armature=nil
  self._bone=nil
  self._geometry=nil
  self._slot=nil
  self._skin=nil
  self._mesh=nil
  self._animation=nil
  self._timeline=nil
  self._rawTextureAtlases=nil
  self._frameValueType=0
  self._defaultColorOffset=-1
  self._prevClockwise=0
  self._prevRotation=0.0
  self._frameDefaultValue=0.0
  self._frameValueScale=1.0
  self._helpMatrixA=Matrix.new()
  self._helpMatrixB=Matrix.new()
  self._helpTransform=Transform.new()
  self._helpColorTransform=ColorTransform.new()
  self._helpPoint=Point.new()
  self._helpArray=JSArray.new()
  self._intArray=JSArray.new()
  self._floatArray=JSArray.new()
  self._frameIntArray=JSArray.new()
  self._frameFloatArray=JSArray.new()
  self._frameArray=JSArray.new()
  self._timelineArray=JSArray.new()
  self._colorArray=JSArray.new()
  self._cacheRawMeshes=JSArray.new()
  self._cacheMeshes=JSArray.new()
  self._actionFrames=JSArray.new()
  self._weightSlotPose=JSMap.new()
  self._weightBonePoses=JSMap.new()
  self._cacheBones=JSMap.new()
  self._slotChildActions=JSMap.new()
  return self
end

function ObjectDataParser:parseTextureAtlasData(...)
 local raw,atlas,scale=...
 if select('#',...)==0 then raw=V.UNDEFINED end
 if scale==nil or rawequal(scale,V.UNDEFINED) then scale=1.0 end
 if rawequal(raw,V.UNDEFINED) then io.stderr:write('Assertion failed\n') end
 if raw==nil or rawequal(raw,V.NULL) then
  local queue=self._rawTextureAtlases
  if queue==nil or V.get(queue,'length')==0 then return false end
  local index=self._rawTextureAtlasIndex
  self._rawTextureAtlasIndex=index+1 -- post-increment happens before recursive parsing
  local nextAtlas=V.at(queue,index)
  self:parseTextureAtlasData(nextAtlas,atlas,scale)
  if self._rawTextureAtlasIndex>=V.number(V.get(self._rawTextureAtlases,'length')) then self._rawTextureAtlasIndex=0;self._rawTextureAtlases=nil end
  return true
 end
 atlas.width=ObjectDataParser._getNumber(raw,DataParser.WIDTH,0)
 atlas.height=ObjectDataParser._getNumber(raw,DataParser.HEIGHT,0)
 if scale==1.0 then atlas.scale=1.0/ObjectDataParser._getNumber(raw,DataParser.SCALE,1.0) else atlas.scale=scale end
 atlas.name=ObjectDataParser._getString(raw,DataParser.NAME,'')
 atlas.imagePath=ObjectDataParser._getString(raw,DataParser.IMAGE_PATH,'')
 if V.has(raw,DataParser.SUB_TEXTURE) then
  local rawTextures=V.get(raw,DataParser.SUB_TEXTURE)
  local length=V.number(V.get(rawTextures,'length'));local index=0
  while index<length do
   local entry=V.at(rawTextures,index)
   local frameWidth=ObjectDataParser._getNumber(entry,DataParser.FRAME_WIDTH,-1.0)
   local frameHeight=ObjectDataParser._getNumber(entry,DataParser.FRAME_HEIGHT,-1.0)
   local texture=atlas:createTexture()
   texture.rotated=ObjectDataParser._getBoolean(entry,DataParser.ROTATED,false)
   texture.name=ObjectDataParser._getString(entry,DataParser.NAME,'')
   texture.region.x=ObjectDataParser._getNumber(entry,DataParser.X,0.0)
   texture.region.y=ObjectDataParser._getNumber(entry,DataParser.Y,0.0)
   texture.region.width=ObjectDataParser._getNumber(entry,DataParser.WIDTH,0.0)
   texture.region.height=ObjectDataParser._getNumber(entry,DataParser.HEIGHT,0.0)
   if frameWidth>0.0 and frameHeight>0.0 then
    texture.frame=Textures.TextureData.createRectangle()
    texture.frame.x=ObjectDataParser._getNumber(entry,DataParser.FRAME_X,0.0)
    texture.frame.y=ObjectDataParser._getNumber(entry,DataParser.FRAME_Y,0.0)
    texture.frame.width=frameWidth;texture.frame.height=frameHeight
   end
   atlas:addTexture(texture)
   index=index+1
  end
 end
 return true
end
ObjectDataParser._objectDataParserInstance=nil
function ObjectDataParser.getInstance()
 if ObjectDataParser._objectDataParserInstance==nil then ObjectDataParser._objectDataParserInstance=ObjectDataParser.new() end
 return ObjectDataParser._objectDataParserInstance
end
local ActionFrame={};ActionFrame.__index=ActionFrame
function ActionFrame.new()return setmetatable({frameStart=0,actions=JSArray.new()},ActionFrame) end
ObjectDataParser.ActionFrame=ActionFrame -- second class exported by the source file
return ObjectDataParser
