-- Partial, source-faithful port of ObjectDataParser from DragonBonesJS.
-- Origin: DragonBones/src/dragonBones/parser/ObjectDataParser.ts
-- Revision: 64b6c69ae35777c2404be68c9192e2c56906079e (MIT).
-- Copyright (c) 2012-2025 DragonBones team and other contributors.
-- LICENSE-DRAGONBONES contains the upstream license.
--
-- This module ports the original data coercion, Bézier sampling, actions,
-- transformations, color transforms, and COMPLETE texture atlas parser.
-- DragonBones armature parsing is NOT IMPLEMENTED YET: deliberately no fake
-- parseDragonBonesData() is published. See docs/PORTING_STATUS.md.
local DataParser=require("dragonbones.original.parser.DataParser")
local Core=require("dragonbones.original.core.DragonBones")
local Pool=require("dragonbones.original.core.BaseObject")
local UserModels=require("dragonbones.original.model.UserData")
local Textures=require("dragonbones.original.model.TextureAtlasData")
local Matrix=require("dragonbones.original.geom.Matrix")
local Transform=require("dragonbones.original.geom.Transform")
local ColorTransform=require("dragonbones.original.geom.ColorTransform")
local Point=require("dragonbones.original.geom.Point")

local ObjectDataParser={}
ObjectDataParser.__index=ObjectDataParser
setmetatable(ObjectDataParser,{__index=DataParser})
ObjectDataParser.FrameValueType={Step=0,Int=1,Float=2}

local function get(raw,key)
  return raw~=nil and raw[key] or nil
end
-- The original looks for properties with JS "key in rawData" rather than
-- comparing rawData[key] against null. Nil cannot express a present JS null.
local function toJSString(value)
  local kind=type(value)
  if kind=="boolean" then return value and "true" or "false" end
  if kind=="string" then return value end
  if kind=="table" then
    -- Ordinary JSON objects are JS objects. Numeric indexed tables stand in
    -- for arrays; there is no custom JS prototype/toString override in JSON.
    if #value>0 then
      local items={}
      for i,v in ipairs(value) do items[i]=toJSString(v) end
      return table.concat(items,",")
    end
    return "[object Object]"
  end
  return tostring(value)
end
local function jsNumber(value)
  if type(value)=="number" then return value end
  if type(value)=="boolean" then return value and 1 or 0 end
  if value==nil then return 0 end
  local s=toJSString(value)
  if s:match("^%s*$") then return 0 end
  local n=tonumber(s)
  return n or 0
end
function ObjectDataParser._getBoolean(raw,key,defaultValue)
  local value=get(raw,key)
  if value==nil then return defaultValue end
  if type(value)=="boolean" then return value end
  if type(value)=="string" then
    return value~="0" and value~="NaN" and value~=""
      and value~="false" and value~="null" and value~="undefined"
  end
  -- The JS (!!value) branch: all arrays and objects are truthy.
  if type(value)=="table" then return true end
  return value~=0 and value==value
end
function ObjectDataParser._getNumber(raw,key,defaultValue)
  local value=get(raw,key)
  if value==nil or value=="NaN" then return defaultValue end
  return jsNumber(value)
end
function ObjectDataParser._getString(raw,key,defaultValue)
  local value=get(raw,key)
  if value==nil then return defaultValue end
  return toJSString(value)
end

local function clear(array)
  for i=#array,1,-1 do array[i]=nil end
end
function ObjectDataParser.new()
  local self=setmetatable({},ObjectDataParser)
  self._rawTextureAtlasIndex=0
  self._rawBones={}
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
  self._frameValueType=ObjectDataParser.FrameValueType.Step
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
  self._helpArray={}
  self._intArray={}
  self._floatArray={}
  self._frameIntArray={}
  self._frameFloatArray={}
  self._frameArray={}
  self._timelineArray={}
  self._colorArray={}
  self._cacheRawMeshes={}
  self._cacheMeshes={}
  self._actionFrames={}
  self._weightSlotPose={}
  self._weightBonePoses={}
  self._cacheBones={}
  self._slotChildActions={}
  return self
end

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
local function curveAt(curve,index)
  return curve[index+1]
end
function ObjectDataParser:_samplingEasingCurve(curve,samples)
  local count=#curve
  if count%3==1 then
    local stepIndex=-2
    for i=0,#samples-1 do
      local t=(i+1)/(#samples+1)
      while ((stepIndex+6<count and curveAt(curve,stepIndex+6)) or 1)<t do
        stepIndex=stepIndex+6
      end
      local isInCurve=stepIndex>=0 and stepIndex+6<count
      local x1=isInCurve and curveAt(curve,stepIndex) or 0.0
      local y1=isInCurve and curveAt(curve,stepIndex+1) or 0.0
      local x2=curveAt(curve,stepIndex+2)
      local y2=curveAt(curve,stepIndex+3)
      local x3=curveAt(curve,stepIndex+4)
      local y3=curveAt(curve,stepIndex+5)
      local x4=isInCurve and curveAt(curve,stepIndex+6) or 1.0
      local y4=isInCurve and curveAt(curve,stepIndex+7) or 1.0
      local lower,higher=0.0,1.0
      while higher-lower>0.0001 do
        local percentage=(higher+lower)*0.5
        self:_getCurvePoint(x1,y1,x2,y2,x3,y3,x4,y4,percentage,self._helpPoint)
        if t-self._helpPoint.x>0 then lower=percentage
        else higher=percentage end
      end
      samples[i+1]=self._helpPoint.y
    end
    return true
  else
    local stepIndex=0
    for i=0,#samples-1 do
      local t=(i+1)/(#samples+1)
      while curveAt(curve,stepIndex+6)<t do stepIndex=stepIndex+6 end
      local x1=curveAt(curve,stepIndex)
      local y1=curveAt(curve,stepIndex+1)
      local x2=curveAt(curve,stepIndex+2)
      local y2=curveAt(curve,stepIndex+3)
      local x3=curveAt(curve,stepIndex+4)
      local y3=curveAt(curve,stepIndex+5)
      local x4=curveAt(curve,stepIndex+6)
      local y4=curveAt(curve,stepIndex+7)
      local lower,higher=0.0,1.0
      while higher-lower>0.0001 do
        local percentage=(higher+lower)*0.5
        self:_getCurvePoint(x1,y1,x2,y2,x3,y3,x4,y4,percentage,self._helpPoint)
        if t-self._helpPoint.x>0 then lower=percentage
        else higher=percentage end
      end
      samples[i+1]=self._helpPoint.y
    end
    return false
  end
end

local ActionFrame={}
ActionFrame.__index=ActionFrame
function ActionFrame.new()
  return setmetatable({frameStart=0,actions={}},ActionFrame)
end
ObjectDataParser.ActionFrame=ActionFrame

function ObjectDataParser:_parseActionData(raw,typeCode,bone,slot)
  local actions={}
  if type(raw)=="string" then
    local action=Pool.borrowObject(UserModels.ActionData)
    action.type=typeCode
    action.name=raw
    action.bone=bone
    action.slot=slot
    actions[1]=action
  elseif type(raw)=="table" then
    for _,entry in ipairs(raw) do
      local action=Pool.borrowObject(UserModels.ActionData)
      if get(entry,DataParser.GOTO_AND_PLAY)~=nil then
        action.type=Core.ActionType.Play
        action.name=ObjectDataParser._getString(entry,DataParser.GOTO_AND_PLAY,"")
      else
        if type(get(entry,DataParser.TYPE))=="string" then
          action.type=DataParser._getActionType(entry[DataParser.TYPE])
        else
          action.type=ObjectDataParser._getNumber(entry,DataParser.TYPE,typeCode)
        end
        action.name=ObjectDataParser._getString(entry,DataParser.NAME,"")
      end
      if get(entry,DataParser.BONE)~=nil then
        local name=ObjectDataParser._getString(entry,DataParser.BONE,"")
        action.bone=self._armature:getBone(name)
      else action.bone=bone end
      if get(entry,DataParser.SLOT)~=nil then
        local name=ObjectDataParser._getString(entry,DataParser.SLOT,"")
        action.slot=self._armature:getSlot(name)
      else action.slot=slot end
      local user=nil
      if get(entry,DataParser.INTS)~=nil then
        user=Pool.borrowObject(UserModels.UserData)
        for _,v in ipairs(entry[DataParser.INTS]) do user:addInt(v) end
      end
      if get(entry,DataParser.FLOATS)~=nil then
        if user==nil then user=Pool.borrowObject(UserModels.UserData) end
        for _,v in ipairs(entry[DataParser.FLOATS]) do user:addFloat(v) end
      end
      if get(entry,DataParser.STRINGS)~=nil then
        if user==nil then user=Pool.borrowObject(UserModels.UserData) end
        for _,v in ipairs(entry[DataParser.STRINGS]) do user:addString(v) end
      end
      action.data=user
      actions[#actions+1]=action
    end
  end
  return actions
end
function ObjectDataParser:_mergeActionFrame(raw,frameStart,typeCode,bone,slot)
  local offset=#self._armature.actions
  local actions=self:_parseActionData(raw,typeCode,bone,slot)
  for _,a in ipairs(actions) do self._armature:addAction(a,false) end
  if #self._actionFrames==0 then
    local initial=ActionFrame.new()
    initial.frameStart=0
    self._actionFrames[1]=initial
  end
  local insertAt=#self._actionFrames+1
  local frame=nil
  for i,each in ipairs(self._actionFrames) do
    if each.frameStart==frameStart then
      frame=each
      break
    elseif each.frameStart>frameStart then
      insertAt=i
      break
    end
  end
  if frame==nil then
    frame=ActionFrame.new()
    frame.frameStart=frameStart
    table.insert(self._actionFrames,insertAt,frame)
  end
  for i=0,#actions-1 do
    frame.actions[#frame.actions+1]=offset+i
  end
end
function ObjectDataParser:_parseActionDataInFrame(raw,frameStart,bone,slot)
  for _,entry in ipairs({
    {DataParser.EVENT,Core.ActionType.Frame},
    {DataParser.SOUND,Core.ActionType.Sound},
    {DataParser.ACTION,Core.ActionType.Play},
    {DataParser.EVENTS,Core.ActionType.Frame},
    {DataParser.ACTIONS,Core.ActionType.Play}
  }) do
    local key,typeCode=entry[1],entry[2]
    if get(raw,key)~=nil then
      self:_mergeActionFrame(raw[key],frameStart,typeCode,bone,slot)
    end
  end
end

function ObjectDataParser:_parseTransform(raw,transform,scale)
  transform.x=ObjectDataParser._getNumber(raw,DataParser.X,0.0)*scale
  transform.y=ObjectDataParser._getNumber(raw,DataParser.Y,0.0)*scale
  if get(raw,DataParser.ROTATE)~=nil or get(raw,DataParser.SKEW)~=nil then
    transform.rotation=Transform.normalizeRadian(
      ObjectDataParser._getNumber(raw,DataParser.ROTATE,0.0)*Transform.DEG_RAD)
    transform.skew=Transform.normalizeRadian(
      ObjectDataParser._getNumber(raw,DataParser.SKEW,0.0)*Transform.DEG_RAD)
  elseif get(raw,DataParser.SKEW_X)~=nil or get(raw,DataParser.SKEW_Y)~=nil then
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

function ObjectDataParser:parseTextureAtlasData(raw,atlas,scale)
  if scale==nil then scale=1.0 end
  if raw==nil then
    local queued=self._rawTextureAtlases
    if queued==nil or #queued==0 then return false end
    local nextAtlas=queued[self._rawTextureAtlasIndex+1]
    self._rawTextureAtlasIndex=self._rawTextureAtlasIndex+1
    self:parseTextureAtlasData(nextAtlas,atlas,scale)
    if self._rawTextureAtlasIndex>=#queued then
      self._rawTextureAtlasIndex=0
      self._rawTextureAtlases=nil
    end
    return true
  end
  atlas.width=ObjectDataParser._getNumber(raw,DataParser.WIDTH,0)
  atlas.height=ObjectDataParser._getNumber(raw,DataParser.HEIGHT,0)
  atlas.scale=scale==1.0 and 1.0/
    ObjectDataParser._getNumber(raw,DataParser.SCALE,1.0) or scale
  atlas.name=ObjectDataParser._getString(raw,DataParser.NAME,"")
  atlas.imagePath=ObjectDataParser._getString(raw,DataParser.IMAGE_PATH,"")
  if get(raw,DataParser.SUB_TEXTURE)~=nil then
    for _,entry in ipairs(raw[DataParser.SUB_TEXTURE]) do
      local frameWidth=ObjectDataParser._getNumber(entry,DataParser.FRAME_WIDTH,-1.0)
      local frameHeight=ObjectDataParser._getNumber(entry,DataParser.FRAME_HEIGHT,-1.0)
      local texture=atlas:createTexture()
      texture.rotated=ObjectDataParser._getBoolean(entry,DataParser.ROTATED,false)
      texture.name=ObjectDataParser._getString(entry,DataParser.NAME,"")
      texture.region.x=ObjectDataParser._getNumber(entry,DataParser.X,0)
      texture.region.y=ObjectDataParser._getNumber(entry,DataParser.Y,0)
      texture.region.width=ObjectDataParser._getNumber(entry,DataParser.WIDTH,0)
      texture.region.height=ObjectDataParser._getNumber(entry,DataParser.HEIGHT,0)
      if frameWidth>0.0 and frameHeight>0.0 then
        texture.frame=Textures.TextureData.createRectangle()
        texture.frame.x=ObjectDataParser._getNumber(entry,DataParser.FRAME_X,0)
        texture.frame.y=ObjectDataParser._getNumber(entry,DataParser.FRAME_Y,0)
        texture.frame.width=frameWidth
        texture.frame.height=frameHeight
      end
      atlas:addTexture(texture)
    end
  end
  return true
end

local instance=nil
function ObjectDataParser.getInstance()
  if instance==nil then instance=ObjectDataParser.new() end
  return instance
end
return ObjectDataParser
