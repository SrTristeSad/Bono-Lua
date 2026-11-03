-- Partial port: ObjectDataParser.ts, pinned DragonBonesJS
-- 64b6c69ae35777c2404be68c9192e2c56906079e.
-- Copyright (c) 2012-2025 DragonBones team and contributors; MIT.
-- Implemented: initializers, helpers, atlas, structures, geometry and binary views.
-- Armature/animation entrypoints remain absent; see docs/NEXT_STEPS.md.
local DataParser=require('dragonbones.parser.DataParser')
local V=require('dragonbones.parser.JSValue')
local Shared=require('dragonbones.parser.SharedBinaryBuffer')
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


-- Original ObjectDataParser.ts: cubic Bezier point and easing-curve sampling.
-- Curve indices below are the zero-based DragonBonesJS indices; V.at maps
-- decoded arrays to Lua's one-based storage without changing the algorithm.
function ObjectDataParser:_getCurvePoint(x1,y1,x2,y2,x3,y3,x4,y4,t,result)
  local l_t=1.0-t
  local powA=l_t*l_t
  local powB=t*t
  local kA=l_t*powA
  local kB=3.0*t*powA
  local kC=3.0*l_t*powB
  local kD=t*powB
  result.x=kA*x1+kB*x2+kC*x3+kD*x4
  result.y=kA*y1+kB*y2+kC*y3+kD*y4
end

function ObjectDataParser:_samplingEasingCurve(curve,samples)
  local curveCount=V.number(V.get(curve,'length'))
  local sampleCount=samples.length
  local function numberAt(index) return V.number(V.at(curve,index)) end
  if curveCount%3==1 then
    local stepIndex=-2
    for i=0,sampleCount-1 do
      local t=(i+1)/(sampleCount+1)
      while (stepIndex+6<curveCount and numberAt(stepIndex+6) or 1)<t do
        stepIndex=stepIndex+6
      end
      local isInCurve=stepIndex>=0 and stepIndex+6<curveCount
      local x1=isInCurve and numberAt(stepIndex) or 0.0
      local y1=isInCurve and numberAt(stepIndex+1) or 0.0
      local x2=numberAt(stepIndex+2)
      local y2=numberAt(stepIndex+3)
      local x3=numberAt(stepIndex+4)
      local y3=numberAt(stepIndex+5)
      local x4=isInCurve and numberAt(stepIndex+6) or 1.0
      local y4=isInCurve and numberAt(stepIndex+7) or 1.0
      local lower,higher=0.0,1.0
      while higher-lower>0.0001 do
        local percentage=(higher+lower)*0.5
        self:_getCurvePoint(x1,y1,x2,y2,x3,y3,x4,y4,percentage,self._helpPoint)
        if t-self._helpPoint.x>0.0 then lower=percentage
        else higher=percentage end
      end
      samples[i+1]=self._helpPoint.y
    end
    return true
  else
    local stepIndex=0
    for i=0,sampleCount-1 do
      local t=(i+1)/(sampleCount+1)
      while numberAt(stepIndex+6)<t do stepIndex=stepIndex+6 end
      local x1=numberAt(stepIndex)
      local y1=numberAt(stepIndex+1)
      local x2=numberAt(stepIndex+2)
      local y2=numberAt(stepIndex+3)
      local x3=numberAt(stepIndex+4)
      local y3=numberAt(stepIndex+5)
      local x4=numberAt(stepIndex+6)
      local y4=numberAt(stepIndex+7)
      local lower,higher=0.0,1.0
      while higher-lower>0.0001 do
        local percentage=(higher+lower)*0.5
        self:_getCurvePoint(x1,y1,x2,y2,x3,y3,x4,y4,percentage,self._helpPoint)
        if t-self._helpPoint.x>0.0 then lower=percentage
        else higher=percentage end
      end
      samples[i+1]=self._helpPoint.y
    end
    return false
  end
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
local Pool=require('dragonbones.core.BaseObject')
local Core=require('dragonbones.core.Enums')
local ArmatureModels=require('dragonbones.model.ArmatureData')
local ConstraintModels=require('dragonbones.model.ConstraintData')
local UserModels=require('dragonbones.model.UserData')
local DisplayModels=require('dragonbones.model.DisplayData')
local BoundingModels=require('dragonbones.model.BoundingBoxData')
local function instanceOf(value,class)
 if type(value)~='table' then return false end
 local current=value.constructor
 while current do
  if rawequal(current,class) then return true end
  local meta=getmetatable(current);current=meta and type(meta.__index)=='table' and meta.__index or nil
 end
 return false
end

function ObjectDataParser:_parseTransform(raw,transform,scale)
  transform.x=ObjectDataParser._getNumber(raw,DataParser.X,0.0)*scale
  transform.y=ObjectDataParser._getNumber(raw,DataParser.Y,0.0)*scale
  if V.has(raw,DataParser.ROTATE) or V.has(raw,DataParser.SKEW) then
    transform.rotation=Transform.normalizeRadian(
      ObjectDataParser._getNumber(raw,DataParser.ROTATE,0.0)*Transform.DEG_RAD)
    transform.skew=Transform.normalizeRadian(
      ObjectDataParser._getNumber(raw,DataParser.SKEW,0.0)*Transform.DEG_RAD)
  elseif V.has(raw,DataParser.SKEW_X) or V.has(raw,DataParser.SKEW_Y) then
    transform.rotation=Transform.normalizeRadian(
      ObjectDataParser._getNumber(raw,DataParser.SKEW_Y,0.0)*Transform.DEG_RAD)
    transform.skew=Transform.normalizeRadian(
      ObjectDataParser._getNumber(raw,DataParser.SKEW_X,0.0)*Transform.DEG_RAD)
      -transform.rotation
  end
  transform.scaleX=ObjectDataParser._getNumber(raw,DataParser.SCALE_X,1.0)
  transform.scaleY=ObjectDataParser._getNumber(raw,DataParser.SCALE_Y,1.0)
end
function ObjectDataParser:_parseColorTransform(raw,color)
  color.alphaMultiplier=ObjectDataParser._getNumber(raw,DataParser.ALPHA_MULTIPLIER,100)*0.01
  color.redMultiplier=ObjectDataParser._getNumber(raw,DataParser.RED_MULTIPLIER,100)*0.01
  color.greenMultiplier=ObjectDataParser._getNumber(raw,DataParser.GREEN_MULTIPLIER,100)*0.01
  color.blueMultiplier=ObjectDataParser._getNumber(raw,DataParser.BLUE_MULTIPLIER,100)*0.01
  color.alphaOffset=ObjectDataParser._getNumber(raw,DataParser.ALPHA_OFFSET,0)
  color.redOffset=ObjectDataParser._getNumber(raw,DataParser.RED_OFFSET,0)
  color.greenOffset=ObjectDataParser._getNumber(raw,DataParser.GREEN_OFFSET,0)
  color.blueOffset=ObjectDataParser._getNumber(raw,DataParser.BLUE_OFFSET,0)
end

function ObjectDataParser:_parsePivot(raw,display)
  if V.has(raw,DataParser.PIVOT) then
    local pivot=raw[DataParser.PIVOT]
    display.pivot.x=ObjectDataParser._getNumber(pivot,DataParser.X,0.0)
    display.pivot.y=ObjectDataParser._getNumber(pivot,DataParser.Y,0.0)
  else
    display.pivot.x=0.5
    display.pivot.y=0.5
  end
end

function ObjectDataParser:_parseIKConstraint(raw)
  local bone=self._armature:getBone(ObjectDataParser._getString(raw,DataParser.BONE,""))
  if bone==nil then return nil end
  local target=self._armature:getBone(ObjectDataParser._getString(raw,DataParser.TARGET,""))
  if target==nil then return nil end
  local chain=ObjectDataParser._getNumber(raw,DataParser.CHAIN,0)
  local c=Pool.borrowObject(ConstraintModels.IKConstraintData)
  c.scaleEnabled=ObjectDataParser._getBoolean(raw,DataParser.SCALE,false)
  c.bendPositive=ObjectDataParser._getBoolean(raw,DataParser.BEND_POSITIVE,true)
  c.weight=ObjectDataParser._getNumber(raw,DataParser.WEIGHT,1.0)
  c.name=ObjectDataParser._getString(raw,DataParser.NAME,"")
  c.type=Core.ConstraintType.IK
  c.target=target
  if chain>0 and not ArmatureModels._isNullReference(bone,"parent") then
    c.root=bone.parent
    c.bone=bone
  else
    c.root=bone
    c.bone=nil
  end
  return c
end

function ObjectDataParser:_parsePathConstraint(raw)
  local target=self._armature:getSlot(ObjectDataParser._getString(raw,DataParser.TARGET,""))
  if target==nil then return nil end
  local defaultSkin=self._armature.defaultSkin
  if ArmatureModels._isNullReference(self._armature,"defaultSkin") then return nil end
  local display=defaultSkin:getDisplay(target.name,
    ObjectDataParser._getString(raw,DataParser.TARGET_DISPLAY,target.name))
  if display==nil or not instanceOf(display,DisplayModels.PathDisplayData) then
    return nil
  end
  local bones=V.get(raw,DataParser.BONES)
  if rawequal(bones,V.NULL) or V.get(bones,"length")==0 then return nil end
  local c=Pool.borrowObject(ConstraintModels.PathConstraintData)
  c.name=ObjectDataParser._getString(raw,DataParser.NAME,"")
  c.type=Core.ConstraintType.Path
  c.pathSlot=target
  c.pathDisplayData=display
  c.target=target.parent
  c.positionMode=DataParser._getPositionMode(
    ObjectDataParser._getString(raw,DataParser.POSITION_MODE,""))
  c.spacingMode=DataParser._getSpacingMode(
    ObjectDataParser._getString(raw,DataParser.SPACING_MODE,""))
  c.rotateMode=DataParser._getRotateMode(
    ObjectDataParser._getString(raw,DataParser.ROTATE_MODE,""))
  c.position=ObjectDataParser._getNumber(raw,DataParser.POSITION,0)
  c.spacing=ObjectDataParser._getNumber(raw,DataParser.SPACING,0)
  c.rotateOffset=ObjectDataParser._getNumber(raw,DataParser.ROTATE_OFFSET,0)
  c.rotateMix=ObjectDataParser._getNumber(raw,DataParser.ROTATE_MIX,1)
  c.translateMix=ObjectDataParser._getNumber(raw,DataParser.TRANSLATE_MIX,1)
  for name in V.iterator(bones) do
    local bone=self._armature:getBone(V.string(name))
    if bone~=nil then
      c:AddBone(bone)
      if c.root==nil then c.root=bone end
    end
  end
  return c
end

function ObjectDataParser:_parseSlot(raw,zOrder)
  local slot=Pool.borrowObject(ArmatureModels.SlotData)
  slot.displayIndex=ObjectDataParser._getNumber(raw,DataParser.DISPLAY_INDEX,0)
  slot.zOrder=zOrder
  slot.zIndex=ObjectDataParser._getNumber(raw,DataParser.Z_INDEX,0)
  slot.alpha=ObjectDataParser._getNumber(raw,DataParser.ALPHA,1.0)
  slot.name=ObjectDataParser._getString(raw,DataParser.NAME,"")
  slot.parent=self._armature:getBone(ObjectDataParser._getString(raw,DataParser.PARENT,""))
  if type(V.get(raw,DataParser.BLEND_MODE))=="string" then
    slot.blendMode=DataParser._getBlendMode(raw[DataParser.BLEND_MODE])
  else
    slot.blendMode=ObjectDataParser._getNumber(raw,DataParser.BLEND_MODE,Core.BlendMode.Normal)
  end
  if V.has(raw,DataParser.COLOR) then
    slot.color=ArmatureModels.SlotData.createColor()
    self:_parseColorTransform(raw[DataParser.COLOR],slot.color)
  else
    slot.color=ArmatureModels.SlotData.DEFAULT_COLOR
  end
  if V.has(raw,DataParser.ACTIONS) then
    self._slotChildActions[slot.name]=self:_parseActionData(
      raw[DataParser.ACTIONS],Core.ActionType.Play,nil,nil)
  end
  return slot
end

function ObjectDataParser:_parseActionData(raw,typeCode,bone,slot)
  local actions=JSArray.new()
  if type(raw)=="string" then
    local action=Pool.borrowObject(UserModels.ActionData)
    action.type=typeCode
    action.name=raw
    action.bone=bone
    action.slot=slot
    actions[1]=action
  elseif V.isArray(raw) then
    for entry in V.iterator(raw) do
      local action=Pool.borrowObject(UserModels.ActionData)
      if V.has(entry,DataParser.GOTO_AND_PLAY) then
        action.type=Core.ActionType.Play
        action.name=ObjectDataParser._getString(entry,DataParser.GOTO_AND_PLAY,"")
      else
        if type(V.get(entry,DataParser.TYPE))=="string" then
          action.type=DataParser._getActionType(entry[DataParser.TYPE])
        else
          action.type=ObjectDataParser._getNumber(entry,DataParser.TYPE,typeCode)
        end
        action.name=ObjectDataParser._getString(entry,DataParser.NAME,"")
      end
      if V.has(entry,DataParser.BONE) then
        local name=ObjectDataParser._getString(entry,DataParser.BONE,"")
        action.bone=self._armature:getBone(name)
      else action.bone=bone end
      if V.has(entry,DataParser.SLOT) then
        local name=ObjectDataParser._getString(entry,DataParser.SLOT,"")
        action.slot=self._armature:getSlot(name)
      else action.slot=slot end
      local user=nil
      if V.has(entry,DataParser.INTS) then
        user=Pool.borrowObject(UserModels.UserData)
        for v in V.iterator(entry[DataParser.INTS]) do
          if rawequal(v,V.UNDEFINED) then user:addInt(nil) else user:addInt(v) end
        end
      end
      if V.has(entry,DataParser.FLOATS) then
        if user==nil then user=Pool.borrowObject(UserModels.UserData) end
        for v in V.iterator(entry[DataParser.FLOATS]) do
          if rawequal(v,V.UNDEFINED) then user:addFloat(nil) else user:addFloat(v) end
        end
      end
      if V.has(entry,DataParser.STRINGS) then
        if user==nil then user=Pool.borrowObject(UserModels.UserData) end
        for v in V.iterator(entry[DataParser.STRINGS]) do
          if rawequal(v,V.UNDEFINED) then user:addString(nil) else user:addString(v) end
        end
      end
      action.data=user
      actions[actions.length+1]=action
    end
  end
  return actions
end
function ObjectDataParser:_parseBoundingBox(raw)
  local kind=Core.BoundingBoxType.Rectangle
  if type(V.get(raw,DataParser.SUB_TYPE))=="string" then
    kind=DataParser._getBoundingBoxType(raw[DataParser.SUB_TYPE])
  else
    kind=ObjectDataParser._getNumber(raw,DataParser.SUB_TYPE,kind)
  end
  local bounding=nil
  if kind==Core.BoundingBoxType.Rectangle then
    bounding=Pool.borrowObject(BoundingModels.RectangleBoundingBoxData)
  elseif kind==Core.BoundingBoxType.Ellipse then
    bounding=Pool.borrowObject(BoundingModels.EllipseBoundingBoxData)
  elseif kind==Core.BoundingBoxType.Polygon then
    bounding=self:_parsePolygonBoundingBox(raw)
  end
  if bounding~=nil then
    bounding.color=ObjectDataParser._getNumber(raw,DataParser.COLOR,0x000000)
    if bounding.type==Core.BoundingBoxType.Rectangle or bounding.type==Core.BoundingBoxType.Ellipse then
      bounding.width=ObjectDataParser._getNumber(raw,DataParser.WIDTH,0)
      bounding.height=ObjectDataParser._getNumber(raw,DataParser.HEIGHT,0)
    end
  end
  return bounding
end

function ObjectDataParser:_parsePolygonBoundingBox(raw)
  local bounding=Pool.borrowObject(BoundingModels.PolygonBoundingBoxData)
  if V.has(raw,DataParser.VERTICES) then
    local scale=self._armature.scale
    local vertices=raw[DataParser.VERTICES]
    local result=bounding.vertices
    result.length=V.number(V.get(vertices,"length"))
    local length=V.number(V.get(vertices,"length"))
    for i=0,length-1,2 do
      local x=V.number(V.at(vertices,i))*V.number(scale)
      local y=V.number(V.at(vertices,i+1))*V.number(scale)
      result[i+1]=x
      result[i+2]=y
      if i==0 then
        bounding.x=x
        bounding.y=y
        bounding.width=x
        bounding.height=y
      else
        if x<bounding.x then bounding.x=x
        elseif x>bounding.width then bounding.width=x end
        if y<bounding.y then bounding.y=y
        elseif y>bounding.height then bounding.height=y end
      end
    end
    bounding.width=bounding.width-bounding.x
    bounding.height=bounding.height-bounding.y
  else
    io.stderr:write("Data error.\n Please reexport DragonBones Data to fixed the bug.\n")
  end
  return bounding
end

local SkinData=require('dragonbones.model.SkinData')
local function clearWork(array)array.length=0 end
local function workAt(array,index)
 if array==nil then error('Array is absent') end
 if type(index)=='number' and index>=0 and index<=4294967294 and index==math.floor(index) then
  local value=array[index+1];return value==nil and V.UNDEFINED or value
 end
 local value=array[V.string(index)];return value==nil and V.UNDEFINED or value
end
local function workPut(array,index,value)array[index+1]=value end
local function indexOf(array,value,raw)
 if raw and not V.isArray(array) then error('Array.indexOf unavailable') end
 local length=raw and V.number(V.get(array,'length')) or array.length
 for index=0,length-1 do
  local current=raw and V.at(array,index) or workAt(array,index)
  local defined=raw and V.isArray(array) and array[index+1]~=nil or (not raw and array[index+1]~=nil)
  if defined and type(current)==type(value) and rawequal(current,value) then return index end
 end
 return -1
end
local function matrixArray(raw)
 V.object(raw) -- Preserve failure before assigning any Matrix fields.
 return setmetatable({},{__index=function(_,key)
  local value=V.at(raw,key-1);if rawequal(value,V.UNDEFINED) then return nil end;return value
 end})
end

function ObjectDataParser:_parseGeometry(rawData,geometry)
  local rawVertices=V.get(rawData,DataParser.VERTICES)
  local vertexCount=math.floor(V.number(V.get(rawVertices,"length"))/2)
  local triangleCount=0
  local geometryOffset=self._intArray.length
  local verticesOffset=self._floatArray.length
  local intArray=self._intArray
  local floatArray=self._floatArray
  local offsets=Core.BinaryOffset
  geometry.offset=geometryOffset
  geometry.data=self._data

  intArray.length=intArray.length+4
  workPut(intArray,geometryOffset+offsets.GeometryVertexCount,vertexCount)
  workPut(intArray,geometryOffset+offsets.GeometryFloatOffset,verticesOffset)
  workPut(intArray,geometryOffset+offsets.GeometryWeightOffset,-1)

  floatArray.length=floatArray.length+vertexCount*2
  for i=0,vertexCount*2-1 do
    workPut(floatArray,verticesOffset+i,V.at(rawVertices,i))
  end

  if V.has(rawData,DataParser.TRIANGLES) then
    local triangles=V.get(rawData,DataParser.TRIANGLES)
    triangleCount=math.floor(V.number(V.get(triangles,"length"))/3)
    intArray.length=intArray.length+triangleCount*3
    for i=0,triangleCount*3-1 do
      workPut(intArray,geometryOffset+offsets.GeometryVertexIndices+i,
        V.at(triangles,i))
    end
  end
  workPut(intArray,geometryOffset+offsets.GeometryTriangleCount,triangleCount)

  if V.has(rawData,DataParser.UVS) then
    local uvs=V.get(rawData,DataParser.UVS)
    local uvOffset=verticesOffset+vertexCount*2
    floatArray.length=floatArray.length+vertexCount*2
    for i=0,vertexCount*2-1 do
      workPut(floatArray,uvOffset+i,V.at(uvs,i))
    end
  end

  if V.has(rawData,DataParser.WEIGHTS) then
    local rawWeights=V.get(rawData,DataParser.WEIGHTS)
    -- Kept verbatim: upstream evaluates floor(length-vertexCount) / 2,
    -- rather than floor((length-vertexCount) / 2).
    local weightCount=math.floor(V.number(V.get(rawWeights,"length"))-vertexCount)/2
    local weightOffset=intArray.length
    local floatOffset=floatArray.length
    local weightBoneCount=0
    local sortedBones=self._armature.sortedBones
    local weight=Pool.borrowObject(DisplayModels.WeightData)
    weight.count=weightCount
    weight.offset=weightOffset

    intArray.length=intArray.length+2+weightBoneCount+vertexCount+weightCount
    workPut(intArray,weightOffset+offsets.WeigthFloatOffset,floatOffset)

    if V.has(rawData,DataParser.BONE_POSE) then
      local slotPose=V.get(rawData,DataParser.SLOT_POSE)
      local bonePoses=V.get(rawData,DataParser.BONE_POSE)
      local indices=JSArray.new()
      weightBoneCount=math.floor(V.number(V.get(bonePoses,"length"))/7)
      indices.length=weightBoneCount
      for i=0,weightBoneCount-1 do
        local rawIndex=V.at(bonePoses,i*7)
        local bone=workAt(self._rawBones,rawIndex)
        weight:addBone(bone)
        indices[i+1]=rawIndex
        workPut(intArray,weightOffset+offsets.WeigthBoneIndices+i,
          indexOf(sortedBones,bone))
      end
      floatArray.length=floatArray.length+weightCount*3
      self._helpMatrixA:copyFromArray(matrixArray(slotPose),0)
      local iW=0
      local iB=weightOffset+offsets.WeigthBoneIndices+weightBoneCount
      local iV=floatOffset
      for i=0,vertexCount-1 do
        local iD=i*2
        local vertexBoneCount=V.at(rawWeights,iW)
        workPut(intArray,iB,vertexBoneCount)
        iB=iB+1
        iW=iW+1
        local x=V.number(workAt(floatArray,verticesOffset+iD))
        local y=V.number(workAt(floatArray,verticesOffset+iD+1))
        self._helpMatrixA:transformPoint(x,y,self._helpPoint)
        x,y=self._helpPoint.x,self._helpPoint.y
        local j=0
        while j<V.number(vertexBoneCount) do
          j=j+1
          local rawBoneIndex=V.at(rawWeights,iW)
          iW=iW+1
          local boneIndex=indexOf(indices,rawBoneIndex)
          self._helpMatrixB:copyFromArray(matrixArray(bonePoses),boneIndex*7+1)
          self._helpMatrixB:invert()
          self._helpMatrixB:transformPoint(x,y,self._helpPoint)
          workPut(intArray,iB,boneIndex)
          iB=iB+1
          workPut(floatArray,iV,V.at(rawWeights,iW));iV=iV+1
          workPut(floatArray,iV,self._helpPoint.x);iV=iV+1
          workPut(floatArray,iV,self._helpPoint.y);iV=iV+1
          iW=iW+1
        end
      end
    else
      local rawBones=V.get(rawData,DataParser.BONES)
      weightBoneCount=V.number(V.get(rawBones,"length"))
      for i=0,weightBoneCount-1 do
        local bone=workAt(self._rawBones,V.at(rawBones,i))
        weight:addBone(bone)
        workPut(intArray,weightOffset+offsets.WeigthBoneIndices+i,
          indexOf(sortedBones,bone))
      end
      floatArray.length=floatArray.length+weightCount*3
      -- The upstream loops over weightCount here, not vertexCount.
      local iW,iV=0,0
      local iB=weightOffset+offsets.WeigthBoneIndices+weightBoneCount
      local iF=floatOffset
      local i=0
      while i<weightCount do
        i=i+1
        local vertexBoneCount=V.at(rawWeights,iW)
        iW=iW+1
        workPut(intArray,iB,vertexBoneCount)
        iB=iB+1
        local j=0
        while j<V.number(vertexBoneCount) do
          j=j+1
          local boneIndex=V.at(rawWeights,iW);iW=iW+1
          local boneWeight=V.at(rawWeights,iW);iW=iW+1
          local x=V.at(rawVertices,iV);iV=iV+1
          local y=V.at(rawVertices,iV);iV=iV+1
          workPut(intArray,iB,indexOf(rawBones,boneIndex,true));iB=iB+1
          workPut(floatArray,iF,boneWeight);iF=iF+1
          workPut(floatArray,iF,x);iF=iF+1
          workPut(floatArray,iF,y);iF=iF+1
        end
      end
    end
    geometry.weight=weight
  end
end


function ObjectDataParser:_parseArray(_rawData)
  -- Preserve the identities of the seven original reusable JS arrays.
  clearWork(self._intArray)
  clearWork(self._floatArray)
  clearWork(self._frameIntArray)
  clearWork(self._frameFloatArray)
  clearWork(self._frameArray)
  clearWork(self._timelineArray)
  clearWork(self._colorArray)
end

-- Original _modifyArray: align working arrays, allocate one buffer, copy,
-- then publish all seven views. Public view offsets remain zero-based bytes.
function ObjectDataParser:_modifyArray()
  local function pad(array)
    local n=array.length
    if n%2~=0 then array[n+1]=0;array.length=n+1 end
  end
  pad(self._intArray)
  pad(self._frameIntArray)
  pad(self._frameArray)
  pad(self._timelineArray)
  -- The pinned source checks the already aligned timeline a second time.
  -- In particular, it does not pad an odd color array.
  if self._timelineArray.length%2~=0 then
    local n=self._colorArray.length;self._colorArray[n+1]=0;self._colorArray.length=n+1
  end
  local names={"intArray","floatArray","frameIntArray","frameFloatArray","frameArray","timelineArray","colorArray"}
  local kinds={"int16","float32","int16","float32","int16","uint16","int16"}
  local lengths,total={},0
  for i,name in ipairs(names) do
    lengths[i]=self["_"..name].length*(kinds[i]=="float32" and 4 or 2)
    total=total+lengths[i]
  end
  local binary=Shared.new(string.rep("\0",total))
  local views,offset={},0
  for i=1,7 do
    views[i]=Shared.view(binary,offset,lengths[i],kinds[i]);offset=offset+lengths[i]
  end
  for i,name in ipairs(names) do
    local source=self["_"..name];local length=source.length
    for j=1,length do views[i][j]=source[j] end
  end
  self._data.binary=binary
  for i,name in ipairs(names) do self._data[name]=views[i] end
  self._defaultColorOffset=-1
end

function ObjectDataParser:_parseBone(raw)
  local kind
  if type(V.get(raw,DataParser.TYPE))=="string" then
    kind=DataParser._getBoneType(raw[DataParser.TYPE])
  else
    kind=ObjectDataParser._getNumber(raw,DataParser.TYPE,Core.BoneType.Bone)
  end
  if kind==Core.BoneType.Bone then
    local scale=self._armature.scale
    local bone=Pool.borrowObject(ArmatureModels.BoneData)
    bone.inheritTranslation=ObjectDataParser._getBoolean(raw,DataParser.INHERIT_TRANSLATION,true)
    bone.inheritRotation=ObjectDataParser._getBoolean(raw,DataParser.INHERIT_ROTATION,true)
    bone.inheritScale=ObjectDataParser._getBoolean(raw,DataParser.INHERIT_SCALE,true)
    bone.inheritReflection=ObjectDataParser._getBoolean(raw,DataParser.INHERIT_REFLECTION,true)
    bone.length=ObjectDataParser._getNumber(raw,DataParser.LENGTH,0)*scale
    bone.alpha=ObjectDataParser._getNumber(raw,DataParser.ALPHA,1.0)
    bone.name=ObjectDataParser._getString(raw,DataParser.NAME,"")
    if V.has(raw,DataParser.TRANSFORM) then
      self:_parseTransform(raw[DataParser.TRANSFORM],bone.transform,scale)
    end
    return bone
  end
  local surface=Pool.borrowObject(ArmatureModels.SurfaceData)
  surface.alpha=ObjectDataParser._getNumber(raw,DataParser.ALPHA,1.0)
  surface.name=ObjectDataParser._getString(raw,DataParser.NAME,"")
  surface.segmentX=ObjectDataParser._getNumber(raw,DataParser.SEGMENT_X,0)
  surface.segmentY=ObjectDataParser._getNumber(raw,DataParser.SEGMENT_Y,0)
  self:_parseGeometry(raw,surface.geometry)
  return surface
end

function ObjectDataParser:_parsePath(raw,display)
  self:_parseGeometry(raw,display.geometry)
end

function ObjectDataParser:_parseMesh(raw,mesh)
  self:_parseGeometry(raw,mesh.geometry)
  if V.has(raw,DataParser.WEIGHTS) then
    local name=self._skin.name.."_"..self._slot.name.."_"..mesh.name
    self._weightSlotPose[name]=V.get(raw,DataParser.SLOT_POSE)
    self._weightBonePoses[name]=V.get(raw,DataParser.BONE_POSE)
  end
end

function ObjectDataParser:_parseDisplay(raw)
  local name=ObjectDataParser._getString(raw,DataParser.NAME,"")
  local path=ObjectDataParser._getString(raw,DataParser.PATH,"")
  local kind=Core.DisplayType.Image
  if type(V.get(raw,DataParser.TYPE))=="string" then
    kind=DataParser._getDisplayType(raw[DataParser.TYPE])
  else
    kind=ObjectDataParser._getNumber(raw,DataParser.TYPE,kind)
  end
  local display=nil
  if kind==Core.DisplayType.Image then
    display=Pool.borrowObject(DisplayModels.ImageDisplayData)
    display.name=name
    display.path=#path>0 and path or name
    self:_parsePivot(raw,display)
  elseif kind==Core.DisplayType.Armature then
    display=Pool.borrowObject(DisplayModels.ArmatureDisplayData)
    display.name=name
    display.path=#path>0 and path or name
    display.inheritAnimation=true
    if V.has(raw,DataParser.ACTIONS) then
      local actions=self:_parseActionData(raw[DataParser.ACTIONS],Core.ActionType.Play,nil,nil)
      local i=1
      while i<=actions.length do
        local action=actions[i]
        display:addAction(action)
        i=i+1
      end
    elseif self._slotChildActions[self._slot.name]~=nil then
      local displays=self._skin:getDisplays(self._slot.name)
      if (displays==nil and self._slot.displayIndex==0)
          or (displays~=nil and self._slot.displayIndex==displays.length) then
        local actions=self._slotChildActions[self._slot.name]
        local i=1
        while i<=actions.length do
          local action=actions[i]
          display:addAction(action)
          i=i+1
        end
        self._slotChildActions[self._slot.name]=nil
      end
    end
  elseif kind==Core.DisplayType.Mesh then
    display=Pool.borrowObject(DisplayModels.MeshDisplayData)
    display.geometry.inheritDeform=ObjectDataParser._getBoolean(
      raw,DataParser.INHERIT_DEFORM,true)
    display.name=name
    display.path=#path>0 and path or name
    if V.has(raw,DataParser.SHARE) then
      display.geometry.data=self._data
      self._cacheRawMeshes[self._cacheRawMeshes.length+1]=raw
      self._cacheMeshes[self._cacheMeshes.length+1]=display
    else
      self:_parseMesh(raw,display)
    end
  elseif kind==Core.DisplayType.BoundingBox then
    local bounding=self:_parseBoundingBox(raw)
    if bounding~=nil then
      display=Pool.borrowObject(DisplayModels.BoundingBoxDisplayData)
      display.name=name
      display.path=#path>0 and path or name
      display.boundingBox=bounding
    end
  elseif kind==Core.DisplayType.Path then
    local lengths=V.get(raw,DataParser.LENGTHS)
    display=Pool.borrowObject(DisplayModels.PathDisplayData)
    display.closed=ObjectDataParser._getBoolean(raw,DataParser.CLOSED,false)
    display.constantSpeed=ObjectDataParser._getBoolean(raw,DataParser.CONSTANT_SPEED,false)
    display.name=name
    display.path=#path>0 and path or name
    display.curveLengths.length=V.number(V.get(lengths,"length"))
    local length=V.number(V.get(lengths,"length"))
    for i=0,length-1 do display.curveLengths[i+1]=V.at(lengths,i) end
    self:_parsePath(raw,display)
  end
  if display~=nil and V.has(raw,DataParser.TRANSFORM) then
    self:_parseTransform(raw[DataParser.TRANSFORM],
      display.transform,self._armature.scale)
  end
  return display
end

function ObjectDataParser:_parseSkin(raw)
  local skin=Pool.borrowObject(SkinData)
  skin.name=ObjectDataParser._getString(raw,DataParser.NAME,DataParser.DEFAULT_NAME)
  if #skin.name==0 then skin.name=DataParser.DEFAULT_NAME end
  if V.has(raw,DataParser.SLOT) then
    self._skin=skin
    for rawSlot in V.iterator(raw[DataParser.SLOT]) do
      local name=ObjectDataParser._getString(rawSlot,DataParser.NAME,"")
      local slot=self._armature:getSlot(name)
      if slot~=nil then
        self._slot=slot
        if V.has(rawSlot,DataParser.DISPLAY) then
          for rawDisplay in V.iterator(rawSlot[DataParser.DISPLAY]) do
            if V.truthy(rawDisplay) then
              skin:addDisplay(name,self:_parseDisplay(rawDisplay))
            else
              skin:addDisplay(name,nil)
            end
          end
        end
        self._slot=nil
      end
    end
    self._skin=nil
  end
  return skin
end

return ObjectDataParser
