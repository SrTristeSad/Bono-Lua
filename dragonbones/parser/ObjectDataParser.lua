-- Partial port: ObjectDataParser.ts, pinned DragonBonesJS
-- 64b6c69ae35777c2404be68c9192e2c56906079e.
-- Copyright (c) 2012-2025 DragonBones team and contributors; MIT.
-- Implemented: atlas, structures, geometry, binary views, curves and frame serializers.
-- Armature/global entrypoints remain absent; see docs/NEXT_STEPS.md.
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

-- Curve sampling follows the original bisection, including its last probe.
function ObjectDataParser:_getCurvePoint(x1,y1,x2,y2,x3,y3,x4,y4,t,result)
  local l_t=1.0-t
  local powA=l_t*l_t
  local powB=t*t
  local kA=l_t*powA
  local kB=3.0*t*powA
  local kC=3.0*l_t*powB
  local kD=t*powB
  result.x=kA*V.number(x1)+kB*V.number(x2)+kC*V.number(x3)+kD*V.number(x4)
  result.y=kA*V.number(y1)+kB*V.number(y2)+kC*V.number(y3)+kD*V.number(y4)
end

function ObjectDataParser:_samplingEasingCurve(curve,samples)
  local curveCount=V.number(V.get(curve,"length"))
  local omitted=curveCount%3==1
  local stepIndex=omitted and -2 or 0
  local length=samples.length
  for i=0,length-1 do
    local t=(i+1)/(length+1)
    if omitted then
      while true do
        local boundary=1
        if stepIndex+6<curveCount then boundary=V.at(curve,stepIndex+6) end
        if not (V.number(boundary)<t) then break end
        stepIndex=stepIndex+6
      end
    else
      while V.number(V.at(curve,stepIndex+6))<t do stepIndex=stepIndex+6 end
    end
    local isInCurve=not omitted or (stepIndex>=0 and stepIndex+6<curveCount)
    local x1,y1,x4,y4=0.0,0.0,1.0,1.0
    if isInCurve then
      x1=V.at(curve,stepIndex);y1=V.at(curve,stepIndex+1)
    end
    local x2,y2=V.at(curve,stepIndex+2),V.at(curve,stepIndex+3)
    local x3,y3=V.at(curve,stepIndex+4),V.at(curve,stepIndex+5)
    if isInCurve then x4=V.at(curve,stepIndex+6);y4=V.at(curve,stepIndex+7) end
    local lower,higher=0.0,1.0
    while higher-lower>0.0001 do
      local percentage=(higher+lower)*0.5
      self:_getCurvePoint(x1,y1,x2,y2,x3,y3,x4,y4,percentage,self._helpPoint)
      if t-self._helpPoint.x>0.0 then lower=percentage else higher=percentage end
    end
    samples[i+1]=self._helpPoint.y
  end
  return omitted
end

-- Math.round ties toward +infinity and preserves negative zero.
local function roundFrame(value)
  if value~=value or value==math.huge or value==-math.huge or value==0 then return value end
  local lower=math.floor(value)
  local rounded=value-lower>=0.5 and lower+1 or lower
  if rounded==0 and value<0 then return -0.0 end
  return rounded
end

local AnimationModels=require('dragonbones.model.AnimationData')
local function nullReference(value)return value==nil or rawequal(value,V.NULL) end
local function isActionFrame(value)
  local class=type(value)=="table" and getmetatable(value) or nil
  while class do
    if rawequal(class,ActionFrame) then return true end
    local meta=getmetatable(class)
    class=meta and type(meta.__index)=="table" and meta.__index or nil
  end
  return false
end

function ObjectDataParser:_parseTimeline(rawData,rawFrames,framesKey,timelineType,frameValueType,frameValueCount,frameParser,timeline)
  if not nullReference(rawData) and #framesKey>0 and V.has(rawData,framesKey) then
    rawFrames=V.get(rawData,framesKey)
  end
  if nullReference(rawFrames) then return nil end
  local keyFrameCount=V.number(V.get(rawFrames,"length"))
  if keyFrameCount==0 then return nil end
  local intStart=self._frameIntArray.length
  local floatStart=self._frameFloatArray.length
  local offset=self._timelineArray.length
  if nullReference(timeline) or rawequal(timeline,V.UNDEFINED) then timeline=Pool.borrowObject(AnimationModels.TimelineData) end
  timeline.type=timelineType;timeline.offset=offset
  self._frameValueType=frameValueType
  self._timeline=timeline
  self._timelineArray.length=self._timelineArray.length+5+keyFrameCount
  local b=Core.BinaryOffset
  if not nullReference(rawData) then
    workPut(self._timelineArray,offset+b.TimelineScale,roundFrame(ObjectDataParser._getNumber(rawData,DataParser.SCALE,1.0)*100))
    workPut(self._timelineArray,offset+b.TimelineOffset,roundFrame(ObjectDataParser._getNumber(rawData,DataParser.OFFSET,0.0)*100))
  else
    workPut(self._timelineArray,offset+b.TimelineScale,100)
    workPut(self._timelineArray,offset+b.TimelineOffset,0)
  end
  workPut(self._timelineArray,offset+b.TimelineKeyFrameCount,keyFrameCount)
  workPut(self._timelineArray,offset+b.TimelineFrameValueCount,frameValueCount)
  if self._frameValueType==0 then workPut(self._timelineArray,offset+b.TimelineFrameValueOffset,0)
  elseif self._frameValueType==1 then workPut(self._timelineArray,offset+b.TimelineFrameValueOffset,intStart-self._animation.frameIntOffset)
  elseif self._frameValueType==2 then workPut(self._timelineArray,offset+b.TimelineFrameValueOffset,floatStart-self._animation.frameFloatOffset) end
  local function at(index)
    if rawequal(rawFrames,self._actionFrames) then return workAt(rawFrames,index) end
    return V.at(rawFrames,index)
  end
  if keyFrameCount==1 then
    timeline.frameIndicesOffset=-1
    workPut(self._timelineArray,offset+b.TimelineFrameOffset,frameParser(self,at(0),0,0)-self._animation.frameOffset)
  else
    local total=self._animation.frameCount+1
    local indices=self._data.frameIndices
    local start=indices.length
    indices.length=indices.length+total
    timeline.frameIndicesOffset=start
    local i,iK,frameStart,frameCount=0,0,0,0
    while i<total do
      if frameStart+frameCount<=i and iK<keyFrameCount then
        local raw=at(iK);frameStart=i
        if iK==keyFrameCount-1 then frameCount=self._animation.frameCount-frameStart
        elseif isActionFrame(raw) then
          frameCount=self._actionFrames[iK+2].frameStart-frameStart
        else frameCount=ObjectDataParser._getNumber(raw,DataParser.DURATION,1) end
        workPut(self._timelineArray,offset+b.TimelineFrameOffset+iK,frameParser(self,raw,frameStart,frameCount)-self._animation.frameOffset)
        iK=iK+1
      end
      workPut(indices,start+i,iK-1)
      i=i+1
    end
  end
  self._timeline=nil
  return timeline
end

function ObjectDataParser:_parseAnimation(rawData)
  local Model=require("dragonbones.model.AnimationData")
  local Animation=Model.AnimationData
  local Timeline=Model.AnimationTimelineData
  local TT=Core.TimelineType
  local FV={Step=0,Int=1,Float=2}
  local animation=Pool.borrowObject(Animation)
  animation.blendType=DataParser._getAnimationBlendType(
    ObjectDataParser._getString(rawData,DataParser.BLEND_TYPE,""))
  animation.frameCount=ObjectDataParser._getNumber(rawData,DataParser.DURATION,0)
  animation.playTimes=ObjectDataParser._getNumber(
    rawData,DataParser.PLAY_TIMES,1)
  animation.duration=animation.frameCount/self._armature.frameRate
  animation.fadeInTime=ObjectDataParser._getNumber(
    rawData,DataParser.FADE_IN_TIME,0.0)
  animation.scale=ObjectDataParser._getNumber(rawData,DataParser.SCALE,1.0)
  animation.name=ObjectDataParser._getString(
    rawData,DataParser.NAME,DataParser.DEFAULT_NAME)
  if #animation.name==0 then animation.name=DataParser.DEFAULT_NAME end
  animation.frameIntOffset=self._frameIntArray.length
  animation.frameFloatOffset=self._frameFloatArray.length
  animation.frameOffset=self._frameArray.length
  self._animation=animation

  if V.has(rawData,DataParser.FRAME) then
    local frames=V.get(rawData,DataParser.FRAME)
    local count=V.number(V.get(frames,"length"))
    local i,frameStart=0,0
    while i<count do
      local frame=V.at(frames,i)
      self:_parseActionDataInFrame(frame,frameStart,nil,nil)
      frameStart=frameStart+ObjectDataParser._getNumber(frame,DataParser.DURATION,1)
      i=i+1
    end
  end
  if V.has(rawData,DataParser.Z_ORDER) then
    animation.zOrderTimeline=self:_parseTimeline(
      rawData[DataParser.Z_ORDER],nil,DataParser.FRAME,
      TT.ZOrder,FV.Step,0,self._parseZOrderFrame)
  end
  if V.has(rawData,DataParser.BONE) then
    for rawTimeline in V.iterator(V.get(rawData,DataParser.BONE)) do
      self:_parseBoneTimeline(rawTimeline)
    end
  end
  if V.has(rawData,DataParser.SLOT) then
    for rawTimeline in V.iterator(V.get(rawData,DataParser.SLOT)) do
      self:_parseSlotTimeline(rawTimeline)
    end
  end
  if V.has(rawData,DataParser.FFD) then
    for rawTimeline in V.iterator(V.get(rawData,DataParser.FFD)) do
      local skinName=ObjectDataParser._getString(rawTimeline,
        DataParser.SKIN,DataParser.DEFAULT_NAME)
      local slotName=ObjectDataParser._getString(rawTimeline,
        DataParser.SLOT,"")
      local displayName=ObjectDataParser._getString(rawTimeline,
        DataParser.NAME,"")
      if #skinName==0 then skinName=DataParser.DEFAULT_NAME end
      self._slot=self._armature:getSlot(slotName)
      self._mesh=self._armature:getMesh(skinName,slotName,displayName)
      if self._slot~=nil and self._mesh~=nil then
        local timeline=self:_parseTimeline(rawTimeline,nil,DataParser.FRAME,
          TT.SlotDeform,FV.Float,0,self._parseSlotDeformFrame)
        if timeline~=nil then
          animation:addSlotTimeline(slotName,timeline)
        end
        self._slot=nil
        self._mesh=nil
      end
    end
  end
  if V.has(rawData,DataParser.IK) then
    for rawTimeline in V.iterator(V.get(rawData,DataParser.IK)) do
      local name=ObjectDataParser._getString(rawTimeline,
        DataParser.NAME,"")
      if self._armature:getConstraint(name)~=nil then
        local timeline=self:_parseTimeline(rawTimeline,nil,DataParser.FRAME,
          TT.IKConstraint,FV.Int,2,self._parseIKConstraintFrame)
        if timeline~=nil then animation:addConstraintTimeline(name,timeline) end
      end
    end
  end
  if self._actionFrames.length>0 then
    animation.actionTimeline=self:_parseTimeline(
      nil,self._actionFrames,"",TT.Action,FV.Step,0,
      self._parseActionFrame)
    self._actionFrames.length=0
  end

  if V.has(rawData,DataParser.TIMELINE) then
    for rawTimeline in V.iterator(V.get(rawData,DataParser.TIMELINE)) do
      local kind=ObjectDataParser._getNumber(rawTimeline,
        DataParser.TYPE,TT.Action)
      local name=ObjectDataParser._getString(rawTimeline,DataParser.NAME,"")
      local timeline=nil
      if kind==TT.Action then
        -- Source TODO: no special generic Action timeline parsing.
      elseif kind==TT.SlotDisplay or kind==TT.SlotZIndex
          or kind==TT.BoneAlpha or kind==TT.SlotAlpha
          or kind==TT.AnimationProgress or kind==TT.AnimationWeight then
        if kind==TT.SlotDisplay then
          self._frameValueType=FV.Step
          self._frameValueScale=1.0
        else
          self._frameValueType=FV.Int
          if kind==TT.SlotZIndex then
            self._frameValueScale=1.0
          elseif kind==TT.AnimationProgress or kind==TT.AnimationWeight then
            self._frameValueScale=10000.0
          else
            self._frameValueScale=100.0
          end
        end
        if kind==TT.BoneAlpha or kind==TT.SlotAlpha
            or kind==TT.AnimationWeight then
          self._frameDefaultValue=1.0
        else
          self._frameDefaultValue=0.0
        end
        if kind==TT.AnimationProgress
            and animation.blendType~=Core.AnimationBlendType.None then
          timeline=Pool.borrowObject(Timeline)
          timeline.x=ObjectDataParser._getNumber(rawTimeline,DataParser.X,0.0)
          timeline.y=ObjectDataParser._getNumber(rawTimeline,DataParser.Y,0.0)
        end
        timeline=self:_parseTimeline(rawTimeline,nil,DataParser.FRAME,
          kind,self._frameValueType,1,self._parseSingleValueFrame,timeline)
      elseif kind==TT.BoneTranslate or kind==TT.BoneRotate
          or kind==TT.BoneScale or kind==TT.IKConstraint
          or kind==TT.AnimationParameter then
        if kind==TT.IKConstraint or kind==TT.AnimationParameter then
          self._frameValueType=FV.Int
          if kind==TT.AnimationParameter then
            self._frameValueScale=10000.0
          else
            self._frameValueScale=100.0
          end
        else
          if kind==TT.BoneRotate then
            self._frameValueScale=Transform.DEG_RAD
          else
            self._frameValueScale=1.0
          end
          self._frameValueType=FV.Float
        end
        if kind==TT.BoneScale or kind==TT.IKConstraint then
          self._frameDefaultValue=1.0
        else
          self._frameDefaultValue=0.0
        end
        timeline=self:_parseTimeline(rawTimeline,nil,DataParser.FRAME,
          kind,self._frameValueType,2,self._parseDoubleValueFrame)
      elseif kind==TT.ZOrder then
        -- Source TODO: no generic ZOrder timeline handling.
      elseif kind==TT.Surface then
        local surface=self._armature:getBone(name)
        if surface~=nil then
          self._geometry=V.get(surface,"geometry")
          timeline=self:_parseTimeline(rawTimeline,nil,DataParser.FRAME,
            kind,FV.Float,0,self._parseDeformFrame)
          self._geometry=nil
        end
      elseif kind==TT.SlotDeform then
        self._geometry=nil
        -- Pinned original iterates all skins and displays by object key.
        -- SkinData.NULL is the original null display placeholder in Lua.
        local SkinData=require("dragonbones.model.SkinData")
        for _,skinName in ipairs(JSMap.keys(self._armature.skins)) do
          local skin=self._armature.skins[skinName]
          for _,slotName in ipairs(JSMap.keys(skin.displays)) do
            local displays=skin.displays[slotName]
            local i=1
            while i<=displays.length do
              local display=workAt(displays,i-1)
              if not rawequal(display,SkinData.NULL) and V.get(display,"name")==name then
                self._geometry=V.get(display,"geometry")
                break
              end
              i=i+1
            end
          end
        end
        if not nullReference(self._geometry) then
          timeline=self:_parseTimeline(rawTimeline,nil,DataParser.FRAME,
            kind,FV.Float,0,self._parseDeformFrame)
          self._geometry=nil
        end
      elseif kind==TT.SlotColor then
        timeline=self:_parseTimeline(rawTimeline,nil,DataParser.FRAME,
          kind,FV.Int,1,self._parseSlotColorFrame)
      end

      if timeline~=nil then
        if kind==TT.Action or kind==TT.ZOrder then
          -- Source TODO.
        elseif kind==TT.BoneTranslate or kind==TT.BoneRotate
            or kind==TT.BoneScale or kind==TT.Surface
            or kind==TT.BoneAlpha then
          animation:addBoneTimeline(name,timeline)
        elseif kind==TT.SlotDisplay or kind==TT.SlotColor
            or kind==TT.SlotDeform or kind==TT.SlotZIndex
            or kind==TT.SlotAlpha then
          animation:addSlotTimeline(name,timeline)
        elseif kind==TT.IKConstraint then
          animation:addConstraintTimeline(name,timeline)
        elseif kind==TT.AnimationProgress or kind==TT.AnimationWeight
            or kind==TT.AnimationParameter then
          animation:addAnimationTimeline(name,timeline)
        end
      end
    end
  end
  self._animation=nil
  return animation
end

function ObjectDataParser:_parseBoneTimeline(rawData)
  local bone=self._armature:getBone(ObjectDataParser._getString(rawData,DataParser.NAME,""))
  if bone==nil then return end
  self._bone=bone;self._slot=self._armature:getSlot(self._bone.name)
  local function parse(key,kind,parser,count)
    local timeline=self:_parseTimeline(rawData,nil,key,kind,2,count,parser)
    if timeline~=nil then self._animation:addBoneTimeline(bone.name,timeline) end
  end
  local t=Core.TimelineType
  if V.has(rawData,DataParser.TRANSLATE_FRAME) then
    self._frameDefaultValue=0.0;self._frameValueScale=1.0
    parse(DataParser.TRANSLATE_FRAME,t.BoneTranslate,self._parseDoubleValueFrame,2)
  end
  if V.has(rawData,DataParser.ROTATE_FRAME) then
    self._frameDefaultValue=0.0;self._frameValueScale=1.0
    parse(DataParser.ROTATE_FRAME,t.BoneRotate,self._parseBoneRotateFrame,2)
  end
  if V.has(rawData,DataParser.SCALE_FRAME) then
    self._frameDefaultValue=1.0;self._frameValueScale=1.0
    parse(DataParser.SCALE_FRAME,t.BoneScale,self._parseBoneScaleFrame,2)
  end
  if V.has(rawData,DataParser.FRAME) then parse(DataParser.FRAME,t.BoneAll,self._parseBoneAllFrame,6) end
  self._bone=nil;self._slot=nil
end

function ObjectDataParser:_parseSlotTimeline(rawData)
  local slot=self._armature:getSlot(ObjectDataParser._getString(rawData,DataParser.NAME,""))
  if slot==nil then return end
  self._slot=slot
  local displayKey=V.has(rawData,DataParser.DISPLAY_FRAME) and DataParser.DISPLAY_FRAME or DataParser.FRAME
  local display=self:_parseTimeline(rawData,nil,displayKey,Core.TimelineType.SlotDisplay,0,0,self._parseSlotDisplayFrame)
  local colorKey=V.has(rawData,DataParser.COLOR_FRAME) and DataParser.COLOR_FRAME or DataParser.FRAME
  local color=self:_parseTimeline(rawData,nil,colorKey,Core.TimelineType.SlotColor,1,1,self._parseSlotColorFrame)
  if display~=nil then self._animation:addSlotTimeline(slot.name,display) end
  if color~=nil then self._animation:addSlotTimeline(slot.name,color) end
  self._slot=nil
end

function ObjectDataParser:_parseFrame(_rawData,frameStart,_frameCount)
  local offset=self._frameArray.length
  self._frameArray.length=offset+1
  workPut(self._frameArray,offset+Core.BinaryOffset.FramePosition,frameStart)
  return offset
end

function ObjectDataParser:_parseTweenFrame(rawData,frameStart,frameCount)
  local offset=self:_parseFrame(rawData,frameStart,frameCount)
  local array,binary,tween=self._frameArray,Core.BinaryOffset,Core.TweenType
  if frameCount>0 then
    if V.has(rawData,DataParser.CURVE) then
      local sampleCount=frameCount+1
      self._helpArray.length=sampleCount
      local omitted=self:_samplingEasingCurve(V.get(rawData,DataParser.CURVE),self._helpArray)
      array.length=array.length+1+1+self._helpArray.length
      workPut(array,offset+binary.FrameTweenType,tween.Curve)
      workPut(array,offset+binary.FrameTweenEasingOrCurveSampleCount,omitted and sampleCount or -sampleCount)
      for i=0,sampleCount-1 do
        workPut(array,offset+binary.FrameCurveSamples+i,roundFrame(V.number(workAt(self._helpArray,i))*10000.0))
      end
    else
      local noTween=-2.0
      local easing=noTween
      if V.has(rawData,DataParser.TWEEN_EASING) then
        easing=ObjectDataParser._getNumber(rawData,DataParser.TWEEN_EASING,noTween)
      end
      if easing==noTween then
        array.length=array.length+1;workPut(array,offset+binary.FrameTweenType,tween.None)
      elseif easing==0.0 then
        array.length=array.length+1;workPut(array,offset+binary.FrameTweenType,tween.Line)
      else
        array.length=array.length+1+1
        local kind,value
        if easing<0.0 then kind=tween.QuadIn;value=-easing*100.0
        elseif easing<=1.0 then kind=tween.QuadOut;value=easing*100.0
        else kind=tween.QuadInOut;value=easing*100.0-100.0 end
        workPut(array,offset+binary.FrameTweenType,kind)
        workPut(array,offset+binary.FrameTweenEasingOrCurveSampleCount,roundFrame(value))
      end
    end
  else
    array.length=array.length+1;workPut(array,offset+binary.FrameTweenType,tween.None)
  end
  return offset
end

function ObjectDataParser:_parseSingleValueFrame(rawData,frameStart,frameCount)
  local offset=0
  if self._frameValueType==0 then
    offset=self:_parseFrame(rawData,frameStart,frameCount)
    self._frameArray.length=self._frameArray.length+1
    workPut(self._frameArray,offset+1,ObjectDataParser._getNumber(rawData,DataParser.VALUE,self._frameDefaultValue))
  elseif self._frameValueType==1 or self._frameValueType==2 then
    offset=self:_parseTweenFrame(rawData,frameStart,frameCount)
    local array=self._frameValueType==1 and self._frameIntArray or self._frameFloatArray
    local valueOffset=array.length;array.length=valueOffset+1
    local value=ObjectDataParser._getNumber(rawData,DataParser.VALUE,self._frameDefaultValue)*self._frameValueScale
    if self._frameValueType==1 then value=roundFrame(value) end
    workPut(array,valueOffset,value)
  end
  return offset
end

function ObjectDataParser:_parseDoubleValueFrame(rawData,frameStart,frameCount)
  local offset=0
  if self._frameValueType==0 then
    offset=self:_parseFrame(rawData,frameStart,frameCount)
    self._frameArray.length=self._frameArray.length+2
    workPut(self._frameArray,offset+1,ObjectDataParser._getNumber(rawData,DataParser.X,self._frameDefaultValue))
    workPut(self._frameArray,offset+2,ObjectDataParser._getNumber(rawData,DataParser.Y,self._frameDefaultValue))
  elseif self._frameValueType==1 or self._frameValueType==2 then
    offset=self:_parseTweenFrame(rawData,frameStart,frameCount)
    local array=self._frameValueType==1 and self._frameIntArray or self._frameFloatArray
    local valueOffset=array.length;array.length=valueOffset+2
    local x=ObjectDataParser._getNumber(rawData,DataParser.X,self._frameDefaultValue)*self._frameValueScale
    if self._frameValueType==1 then x=roundFrame(x) end
    workPut(array,valueOffset,x)
    local y=ObjectDataParser._getNumber(rawData,DataParser.Y,self._frameDefaultValue)*self._frameValueScale
    if self._frameValueType==1 then y=roundFrame(y) end
    workPut(array,valueOffset+1,y)
  end
  return offset
end

function ObjectDataParser:_parseActionFrame(frame,frameStart,_frameCount)
  local offset=self._frameArray.length
  local count=frame.actions.length
  self._frameArray.length=self._frameArray.length+1+1+count
  workPut(self._frameArray,offset+Core.BinaryOffset.FramePosition,frameStart)
  workPut(self._frameArray,offset+Core.BinaryOffset.FramePosition+1,count)
  for i=0,count-1 do
    workPut(self._frameArray,offset+Core.BinaryOffset.FramePosition+2+i,workAt(frame.actions,i))
  end
  return offset
end

function ObjectDataParser:_parseZOrderFrame(rawData,frameStart,frameCount)
  local offset=self:_parseFrame(rawData,frameStart,frameCount)
  if V.has(rawData,DataParser.Z_ORDER) then
    local raw=V.get(rawData,DataParser.Z_ORDER)
    local length=V.number(V.get(raw,"length"))
    if length>0 then
      local slotCount=self._armature.sortedSlots.length
      local unchanged,zOrders=JSArray.new(),JSArray.new()
      unchanged.length=slotCount-length/2
      zOrders.length=slotCount
      for i=1,unchanged.length do unchanged[i]=0 end
      for i=1,slotCount do zOrders[i]=-1 end
      local originalIndex,unchangedIndex=0,0
      for i=0,length-1,2 do
        local slotIndex=V.at(raw,i)
        local zOffset=V.at(raw,i+1)
        while originalIndex~=slotIndex do
          workPut(unchanged,unchangedIndex,originalIndex)
          unchangedIndex=unchangedIndex+1;originalIndex=originalIndex+1
        end
        local index
        if type(zOffset)=="string" then
          index=V.string(originalIndex)..zOffset
          local n=tonumber(index)
          if n and V.string(n)==index then index=n end
        else index=originalIndex+V.number(zOffset) end
        if type(index)=="number" and index>=0 and index<=4294967294 and index==math.floor(index) then
          workPut(zOrders,index,originalIndex)
        else zOrders[V.string(index)]=originalIndex end
        originalIndex=originalIndex+1
      end
      while originalIndex<slotCount do
        workPut(unchanged,unchangedIndex,originalIndex)
        unchangedIndex=unchangedIndex+1;originalIndex=originalIndex+1
      end
      self._frameArray.length=self._frameArray.length+1+slotCount
      workPut(self._frameArray,offset+1,slotCount)
      for i=slotCount-1,0,-1 do
        local value=workAt(zOrders,i)
        if value==-1 then unchangedIndex=unchangedIndex-1;value=workAt(unchanged,unchangedIndex) end
        workPut(self._frameArray,offset+2+i,V.truthy(value) and value or 0)
      end
      return offset
    end
  end
  self._frameArray.length=self._frameArray.length+1
  workPut(self._frameArray,offset+1,0)
  return offset
end

local function frameRotation(self,rotation,frameStart)
  if frameStart~=0 then
    if self._prevClockwise==0 then
      rotation=self._prevRotation+Transform.normalizeRadian(rotation-self._prevRotation)
    else
      local decrease
      if self._prevClockwise>0 then decrease=rotation>=self._prevRotation
      else decrease=rotation<=self._prevRotation end
      if decrease then
        self._prevClockwise=self._prevClockwise>0 and self._prevClockwise-1 or self._prevClockwise+1
      end
      rotation=self._prevRotation+rotation-self._prevRotation+Transform.PI_D*self._prevClockwise
    end
  end
  return rotation
end

function ObjectDataParser:_parseBoneAllFrame(rawData,frameStart,frameCount)
  self._helpTransform:identity()
  if V.has(rawData,DataParser.TRANSFORM) then
    self:_parseTransform(V.get(rawData,DataParser.TRANSFORM),self._helpTransform,1.0)
  end
  local rotation=frameRotation(self,self._helpTransform.rotation,frameStart)
  self._prevClockwise=ObjectDataParser._getNumber(rawData,DataParser.TWEEN_ROTATE,0.0)
  self._prevRotation=rotation
  local offset=self:_parseTweenFrame(rawData,frameStart,frameCount)
  local values=self._frameFloatArray;local start=values.length
  values.length=values.length+6
  workPut(values,start,self._helpTransform.x)
  workPut(values,start+1,self._helpTransform.y)
  workPut(values,start+2,rotation)
  workPut(values,start+3,self._helpTransform.skew)
  workPut(values,start+4,self._helpTransform.scaleX)
  workPut(values,start+5,self._helpTransform.scaleY)
  self:_parseActionDataInFrame(rawData,frameStart,self._bone,self._slot)
  return offset
end

function ObjectDataParser:_parseBoneTranslateFrame(rawData,frameStart,frameCount)
  local offset=self:_parseTweenFrame(rawData,frameStart,frameCount)
  local values=self._frameFloatArray;local start=values.length;values.length=values.length+2
  workPut(values,start,ObjectDataParser._getNumber(rawData,DataParser.X,0.0))
  workPut(values,start+1,ObjectDataParser._getNumber(rawData,DataParser.Y,0.0))
  return offset
end

function ObjectDataParser:_parseBoneRotateFrame(rawData,frameStart,frameCount)
  local rotation=ObjectDataParser._getNumber(rawData,DataParser.ROTATE,0.0)*Transform.DEG_RAD
  rotation=frameRotation(self,rotation,frameStart)
  self._prevClockwise=ObjectDataParser._getNumber(rawData,DataParser.CLOCK_WISE,0)
  self._prevRotation=rotation
  local offset=self:_parseTweenFrame(rawData,frameStart,frameCount)
  local values=self._frameFloatArray;local start=values.length;values.length=values.length+2
  workPut(values,start,rotation)
  workPut(values,start+1,ObjectDataParser._getNumber(rawData,DataParser.SKEW,0.0)*Transform.DEG_RAD)
  return offset
end

function ObjectDataParser:_parseBoneScaleFrame(rawData,frameStart,frameCount)
  local offset=self:_parseTweenFrame(rawData,frameStart,frameCount)
  local values=self._frameFloatArray;local start=values.length;values.length=values.length+2
  workPut(values,start,ObjectDataParser._getNumber(rawData,DataParser.X,1.0))
  workPut(values,start+1,ObjectDataParser._getNumber(rawData,DataParser.Y,1.0))
  return offset
end

function ObjectDataParser:_parseSlotDisplayFrame(rawData,frameStart,frameCount)
  local offset=self:_parseFrame(rawData,frameStart,frameCount)
  self._frameArray.length=self._frameArray.length+1
  local key=V.has(rawData,DataParser.VALUE) and DataParser.VALUE or DataParser.DISPLAY_INDEX
  workPut(self._frameArray,offset+1,ObjectDataParser._getNumber(rawData,key,0))
  self:_parseActionDataInFrame(rawData,frameStart,self._slot.parent,self._slot)
  return offset
end

function ObjectDataParser:_parseSlotColorFrame(rawData,frameStart,frameCount)
  local offset=self:_parseTweenFrame(rawData,frameStart,frameCount)
  local colorOffset=-1
  if V.has(rawData,DataParser.VALUE) or V.has(rawData,DataParser.COLOR) then
    local key=V.has(rawData,DataParser.VALUE) and DataParser.VALUE or DataParser.COLOR
    local rawColor=V.get(rawData,key)
    -- The original for-in skips null/undefined and boxes primitives.
    local enumerable=type(rawColor)=="table" and next(rawColor)~=nil
      or type(rawColor)=="string" and V.get(rawColor,"length")>0
    if enumerable then
      self:_parseColorTransform(rawColor,self._helpColorTransform)
      colorOffset=self._colorArray.length
      self._colorArray.length=self._colorArray.length+8
      local c=self._helpColorTransform
      local values={c.alphaMultiplier*100,c.redMultiplier*100,c.greenMultiplier*100,c.blueMultiplier*100,
        c.alphaOffset,c.redOffset,c.greenOffset,c.blueOffset}
      for i=1,8 do workPut(self._colorArray,colorOffset+i-1,roundFrame(values[i])) end
    end
  end
  if colorOffset<0 then
    if self._defaultColorOffset<0 then
      colorOffset=self._colorArray.length;self._defaultColorOffset=colorOffset
      self._colorArray.length=self._colorArray.length+8
      local values={100,100,100,100,0,0,0,0}
      for i=1,8 do workPut(self._colorArray,colorOffset+i-1,values[i]) end
    end
    colorOffset=self._defaultColorOffset
  end
  local start=self._frameIntArray.length
  self._frameIntArray.length=self._frameIntArray.length+1
  workPut(self._frameIntArray,start,colorOffset)
  return offset
end

local function deformComponent(raw,index,offset)
  if raw==nil or rawequal(raw,V.NULL) then return 0.0 end
  if index<offset or index-offset>=V.number(V.get(raw,"length")) then return 0.0 end
  return V.at(raw,index-offset)
end

local function deformHeader(self,geometry,frameFloatOffset)
  local start=self._frameIntArray.length
  local b=Core.BinaryOffset
  self._frameIntArray.length=self._frameIntArray.length+5
  workPut(self._frameIntArray,start+b.DeformVertexOffset,geometry.offset)
  workPut(self._frameIntArray,start+b.DeformCount,self._frameFloatArray.length-frameFloatOffset)
  workPut(self._frameIntArray,start+b.DeformValueCount,self._frameFloatArray.length-frameFloatOffset)
  workPut(self._frameIntArray,start+b.DeformValueOffset,0)
  workPut(self._frameIntArray,start+b.DeformFloatOffset,frameFloatOffset-self._animation.frameFloatOffset)
  workPut(self._timelineArray,self._timeline.offset+b.TimelineFrameValueCount,start-self._animation.frameIntOffset)
end

function ObjectDataParser:_parseSlotDeformFrame(rawData,frameStart,frameCount)
  local floatStart=self._frameFloatArray.length
  local frameOffset=self:_parseTweenFrame(rawData,frameStart,frameCount)
  local rawVertices
  if V.has(rawData,DataParser.VERTICES) then rawVertices=V.get(rawData,DataParser.VERTICES) end
  local offset=ObjectDataParser._getNumber(rawData,DataParser.OFFSET,0)
  local geometry=self._mesh.geometry
  local vertexCount=V.number(workAt(self._intArray,geometry.offset+Core.BinaryOffset.GeometryVertexCount))
  local meshName=self._mesh.parent.name.."_"..self._slot.name.."_"..self._mesh.name
  local weight=geometry.weight
  local iB,iV=0,0
  if weight~=nil then
    local pose=self._weightSlotPose[meshName]
    self._helpMatrixA:copyFromArray(matrixArray(pose),0)
    self._frameFloatArray.length=self._frameFloatArray.length+weight.count*2
    iB=weight.offset+Core.BinaryOffset.WeigthBoneIndices+weight.bones.length
  else self._frameFloatArray.length=self._frameFloatArray.length+vertexCount*2 end
  local i=0
  while i<vertexCount*2 do
    local x=deformComponent(rawVertices,i,offset)
    local y=deformComponent(rawVertices,i+1,offset)
    if weight~=nil then
      local bonePoses=self._weightBonePoses[meshName]
      local boneCount=V.number(workAt(self._intArray,iB));iB=iB+1
      self._helpMatrixA:transformPoint(V.number(x),V.number(y),self._helpPoint,true)
      x,y=self._helpPoint.x,self._helpPoint.y
      local j=0
      while j<boneCount do
        local boneIndex=V.number(workAt(self._intArray,iB));iB=iB+1
        self._helpMatrixB:copyFromArray(matrixArray(bonePoses),boneIndex*7+1)
        self._helpMatrixB:invert()
        self._helpMatrixB:transformPoint(x,y,self._helpPoint,true)
        workPut(self._frameFloatArray,floatStart+iV,self._helpPoint.x);iV=iV+1
        workPut(self._frameFloatArray,floatStart+iV,self._helpPoint.y);iV=iV+1
        j=j+1
      end
    else
      workPut(self._frameFloatArray,floatStart+i,x)
      workPut(self._frameFloatArray,floatStart+i+1,y)
    end
    i=i+2
  end
  if frameStart==0 then deformHeader(self,geometry,floatStart) end
  return frameOffset
end

function ObjectDataParser:_parseDeformFrame(rawData,frameStart,frameCount)
  local floatStart=self._frameFloatArray.length
  local frameOffset=self:_parseTweenFrame(rawData,frameStart,frameCount)
  local rawVertices
  if V.has(rawData,DataParser.VERTICES) then rawVertices=V.get(rawData,DataParser.VERTICES)
  elseif V.has(rawData,DataParser.VALUE) then rawVertices=V.get(rawData,DataParser.VALUE) end
  local offset=ObjectDataParser._getNumber(rawData,DataParser.OFFSET,0)
  local geometry=self._geometry
  local vertexCount=V.number(workAt(self._intArray,geometry.offset+Core.BinaryOffset.GeometryVertexCount))
  if geometry.weight~=nil then
    -- Literal TODO in the pinned original; do not invent weighted output.
  else
    self._frameFloatArray.length=self._frameFloatArray.length+vertexCount*2
    local i=0
    while i<vertexCount*2 do
      local x=deformComponent(rawVertices,i,offset)
      local y=deformComponent(rawVertices,i+1,offset)
      workPut(self._frameFloatArray,floatStart+i,x)
      workPut(self._frameFloatArray,floatStart+i+1,y)
      i=i+2
    end
  end
  if frameStart==0 then deformHeader(self,geometry,floatStart) end
  return frameOffset
end

function ObjectDataParser:_parseIKConstraintFrame(rawData,frameStart,frameCount)
  local offset=self:_parseTweenFrame(rawData,frameStart,frameCount)
  local start=self._frameIntArray.length
  self._frameIntArray.length=self._frameIntArray.length+2
  workPut(self._frameIntArray,start,ObjectDataParser._getBoolean(rawData,DataParser.BEND_POSITIVE,true) and 1 or 0)
  workPut(self._frameIntArray,start+1,roundFrame(ObjectDataParser._getNumber(rawData,DataParser.WEIGHT,1.0)*100.0))
  return offset
end

function ObjectDataParser:_parseActionDataInFrame(rawData,frameStart,bone,slot)
  local keys={DataParser.EVENT,DataParser.SOUND,DataParser.ACTION,DataParser.EVENTS,DataParser.ACTIONS}
  local types={Core.ActionType.Frame,Core.ActionType.Sound,Core.ActionType.Play,Core.ActionType.Frame,Core.ActionType.Play}
  for i=1,5 do
    if V.has(rawData,keys[i]) then self:_mergeActionFrame(V.get(rawData,keys[i]),frameStart,types[i],bone,slot) end
  end
end

function ObjectDataParser:_mergeActionFrame(rawData,frameStart,typeCode,bone,slot)
  local actionOffset=self._armature.actions.length
  local actions=self:_parseActionData(rawData,typeCode,bone,slot)
  local frameIndex,frame=0,nil
  local i=1
  while i<=actions.length do self._armature:addAction(actions[i],false);i=i+1 end
  local frames=self._actionFrames
  if frames.length==0 then
    local initial=ActionFrame.new();initial.frameStart=0;frames[1]=initial
  end
  i=1
  while i<=frames.length do
    local each=frames[i]
    if each.frameStart==frameStart then frame=each;break
    elseif each.frameStart>frameStart then break end
    frameIndex=frameIndex+1;i=i+1
  end
  if frame==nil then
    frame=ActionFrame.new();frame.frameStart=frameStart
    local length=frames.length
    for j=length,frameIndex+1,-1 do frames[j+1]=frames[j] end
    frames[frameIndex+1]=frame
  end
  i=0
  while i<actions.length do frame.actions[frame.actions.length+1]=actionOffset+i;i=i+1 end
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
