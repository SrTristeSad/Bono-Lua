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
local JsonNull=require("dragonbones.json").null

local ObjectDataParser={}
ObjectDataParser.__index=ObjectDataParser
setmetatable(ObjectDataParser,{__index=DataParser})
ObjectDataParser.FrameValueType={Step=0,Int=1,Float=2}

local function get(raw,key)
  if raw==nil then return nil end
  return raw[key]
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
  if value==JsonNull then return false end
  if type(value)=="boolean" then return value end
  if type(value)=="string" then
    return value~="0" and value~="NaN" and value~=""
      and value~="false" and value~="null" and value~="undefined"
  end
  -- The JS (!!value) branch: all arrays and objects are truthy.
  if type(value)=="table" then return true end
  return value~=0
end
function ObjectDataParser._getNumber(raw,key,defaultValue)
  local value=get(raw,key)
  if value==nil or value==JsonNull or value=="NaN" then return defaultValue end
  return jsNumber(value)
end
function ObjectDataParser._getString(raw,key,defaultValue)
  local value=get(raw,key)
  if value==nil then return defaultValue end
  if value==JsonNull then return "null" end
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


-- Structural model parsing from ObjectDataParser.ts, lines 473-877.
-- Geometry serialization (_parseGeometry) remains an original-method
-- dependency, not a replacement. Mesh, Path and Surface call it when used.
local ArmatureModels=require("dragonbones.original.model.ArmatureData")
local ConstraintModels=require("dragonbones.original.model.ConstraintData")
local DisplayModels=require("dragonbones.original.model.DisplayData")
local BoundingModels=require("dragonbones.original.model.BoundingBoxData")
local SkinData=require("dragonbones.original.model.SkinData")

function ObjectDataParser:_parseBone(raw)
  local kind
  if type(get(raw,DataParser.TYPE))=="string" then
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
    if get(raw,DataParser.TRANSFORM)~=nil then
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
  if chain>0 and bone.parent~=nil then
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
  if defaultSkin==nil then return nil end
  local display=defaultSkin:getDisplay(target.name,
    ObjectDataParser._getString(raw,DataParser.TARGET_DISPLAY,target.name))
  if display==nil or getmetatable(display)~=DisplayModels.PathDisplayData then
    return nil
  end
  local bones=get(raw,DataParser.BONES)
  if bones==nil or bones==JsonNull or #bones==0 then return nil end
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
  for _,name in ipairs(bones) do
    local bone=self._armature:getBone(name)
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
  if type(get(raw,DataParser.BLEND_MODE))=="string" then
    slot.blendMode=DataParser._getBlendMode(raw[DataParser.BLEND_MODE])
  else
    slot.blendMode=ObjectDataParser._getNumber(raw,DataParser.BLEND_MODE,Core.BlendMode.Normal)
  end
  if get(raw,DataParser.COLOR)~=nil then
    slot.color=ArmatureModels.SlotData.createColor()
    self:_parseColorTransform(raw[DataParser.COLOR],slot.color)
  else
    slot.color=ArmatureModels.SlotData.DEFAULT_COLOR
  end
  if get(raw,DataParser.ACTIONS)~=nil then
    self._slotChildActions[slot.name]=self:_parseActionData(
      raw[DataParser.ACTIONS],Core.ActionType.Play,nil,nil)
  end
  return slot
end

function ObjectDataParser:_parseSkin(raw)
  local skin=Pool.borrowObject(SkinData)
  skin.name=ObjectDataParser._getString(raw,DataParser.NAME,DataParser.DEFAULT_NAME)
  if #skin.name==0 then skin.name=DataParser.DEFAULT_NAME end
  if get(raw,DataParser.SLOT)~=nil then
    self._skin=skin
    for _,rawSlot in ipairs(raw[DataParser.SLOT]) do
      local name=ObjectDataParser._getString(rawSlot,DataParser.NAME,"")
      local slot=self._armature:getSlot(name)
      if slot~=nil then
        self._slot=slot
        if get(rawSlot,DataParser.DISPLAY)~=nil then
          for _,rawDisplay in ipairs(rawSlot[DataParser.DISPLAY]) do
            if rawDisplay~=false and rawDisplay~=JsonNull and rawDisplay~=nil then
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

function ObjectDataParser:_parseDisplay(raw)
  local name=ObjectDataParser._getString(raw,DataParser.NAME,"")
  local path=ObjectDataParser._getString(raw,DataParser.PATH,"")
  local kind=Core.DisplayType.Image
  if type(get(raw,DataParser.TYPE))=="string" then
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
    if get(raw,DataParser.ACTIONS)~=nil then
      for _,action in ipairs(self:_parseActionData(
          raw[DataParser.ACTIONS],Core.ActionType.Play,nil,nil)) do
        display:addAction(action)
      end
    elseif self._slot~=nil and self._slotChildActions[self._slot.name]~=nil then
      local displays=self._skin:getDisplays(self._slot.name)
      if (displays==nil and self._slot.displayIndex==0)
          or (displays~=nil and self._slot.displayIndex==#displays) then
        for _,action in ipairs(self._slotChildActions[self._slot.name]) do
          display:addAction(action)
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
    if get(raw,DataParser.SHARE)~=nil then
      display.geometry.data=self._data
      self._cacheRawMeshes[#self._cacheRawMeshes+1]=raw
      self._cacheMeshes[#self._cacheMeshes+1]=display
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
    local lengths=get(raw,DataParser.LENGTHS)
    display=Pool.borrowObject(DisplayModels.PathDisplayData)
    display.closed=ObjectDataParser._getBoolean(raw,DataParser.CLOSED,false)
    display.constantSpeed=ObjectDataParser._getBoolean(raw,DataParser.CONSTANT_SPEED,false)
    display.name=name
    display.path=#path>0 and path or name
    for i,v in ipairs(lengths) do display.curveLengths[i]=v end
    self:_parsePath(raw,display)
  end
  if display~=nil and get(raw,DataParser.TRANSFORM)~=nil then
    self:_parseTransform(raw[DataParser.TRANSFORM],
      display.transform,self._armature.scale)
  end
  return display
end

function ObjectDataParser:_parsePath(raw,display)
  self:_parseGeometry(raw,display.geometry)
end

function ObjectDataParser:_parsePivot(raw,display)
  if get(raw,DataParser.PIVOT)~=nil then
    local pivot=raw[DataParser.PIVOT]
    display.pivot.x=ObjectDataParser._getNumber(pivot,DataParser.X,0.0)
    display.pivot.y=ObjectDataParser._getNumber(pivot,DataParser.Y,0.0)
  else
    display.pivot.x=0.5
    display.pivot.y=0.5
  end
end

function ObjectDataParser:_parseMesh(raw,mesh)
  self:_parseGeometry(raw,mesh.geometry)
  if get(raw,DataParser.WEIGHTS)~=nil then
    local name=self._skin.name.."_"..self._slot.name.."_"..mesh.name
    self._weightSlotPose[name]=raw[DataParser.SLOT_POSE]
    self._weightBonePoses[name]=raw[DataParser.BONE_POSE]
  end
end

function ObjectDataParser:_parseBoundingBox(raw)
  local kind=Core.BoundingBoxType.Rectangle
  if type(get(raw,DataParser.SUB_TYPE))=="string" then
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
    if kind==Core.BoundingBoxType.Rectangle or kind==Core.BoundingBoxType.Ellipse then
      bounding.width=ObjectDataParser._getNumber(raw,DataParser.WIDTH,0)
      bounding.height=ObjectDataParser._getNumber(raw,DataParser.HEIGHT,0)
    end
  end
  return bounding
end

function ObjectDataParser:_parsePolygonBoundingBox(raw)
  local bounding=Pool.borrowObject(BoundingModels.PolygonBoundingBoxData)
  if get(raw,DataParser.VERTICES)~=nil then
    local scale=self._armature.scale
    local vertices=raw[DataParser.VERTICES]
    local result=bounding.vertices
    for i=1,#vertices,2 do
      local x=vertices[i]*scale
      local y=vertices[i+1]*scale
      result[i]=x
      result[i+1]=y
      if i==1 then
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
    io.stderr:write("Data error.\\n Please reexport DragonBones Data to fixed the bug.\\n")
  end
  return bounding
end

-- ObjectDataParser.ts: _parseGeometry (lines 2065-2201) and
-- _parseArray (lines 2203-2213). Preserve original array offsets as
-- zero-based values; all Lua array reads and writes add one.
local function zeroAt(array,offset)
  return array[offset+1]
end
local function zeroPut(array,offset,value)
  array[offset+1]=value
end
local function extend(array,length)
  -- JS sets Array.length before assigning indexed elements; typed arrays
  -- later coerce unset holes to 0. Initialize those holes at reservation.
  for index=#array+1,length do array[index]=0 end
end
local function indexOf(array,value)
  for index,item in ipairs(array) do
    if item==value then return index-1 end
  end
  return -1
end

function ObjectDataParser:_parseGeometry(rawData,geometry)
  local rawVertices=rawData[DataParser.VERTICES]
  local vertexCount=math.floor(#rawVertices/2)
  local triangleCount=0
  local geometryOffset=#self._intArray
  local verticesOffset=#self._floatArray
  local intArray=self._intArray
  local floatArray=self._floatArray
  local offsets=Core.BinaryOffset
  geometry.offset=geometryOffset
  geometry.data=self._data

  extend(intArray,#intArray+4)
  zeroPut(intArray,geometryOffset+offsets.GeometryVertexCount,vertexCount)
  zeroPut(intArray,geometryOffset+offsets.GeometryFloatOffset,verticesOffset)
  zeroPut(intArray,geometryOffset+offsets.GeometryWeightOffset,-1)

  extend(floatArray,#floatArray+vertexCount*2)
  for i=0,vertexCount*2-1 do
    zeroPut(floatArray,verticesOffset+i,rawVertices[i+1])
  end

  if get(rawData,DataParser.TRIANGLES)~=nil then
    local triangles=rawData[DataParser.TRIANGLES]
    triangleCount=math.floor(#triangles/3)
    extend(intArray,#intArray+triangleCount*3)
    for i=0,triangleCount*3-1 do
      zeroPut(intArray,geometryOffset+offsets.GeometryVertexIndices+i,
        triangles[i+1])
    end
  end
  zeroPut(intArray,geometryOffset+offsets.GeometryTriangleCount,triangleCount)

  if get(rawData,DataParser.UVS)~=nil then
    local uvs=rawData[DataParser.UVS]
    local uvOffset=verticesOffset+vertexCount*2
    extend(floatArray,#floatArray+vertexCount*2)
    for i=0,vertexCount*2-1 do
      zeroPut(floatArray,uvOffset+i,uvs[i+1])
    end
  end

  if get(rawData,DataParser.WEIGHTS)~=nil then
    local rawWeights=rawData[DataParser.WEIGHTS]
    -- Kept verbatim: upstream evaluates floor(length-vertexCount) / 2,
    -- rather than floor((length-vertexCount) / 2).
    local weightCount=math.floor(#rawWeights-vertexCount)/2
    local weightOffset=#intArray
    local floatOffset=#floatArray
    local weightBoneCount=0
    local sortedBones=self._armature.sortedBones
    local weight=Pool.borrowObject(DisplayModels.WeightData)
    weight.count=weightCount
    weight.offset=weightOffset

    extend(intArray,#intArray+2+weightBoneCount+vertexCount+weightCount)
    zeroPut(intArray,weightOffset+offsets.WeigthFloatOffset,floatOffset)

    if get(rawData,DataParser.BONE_POSE)~=nil then
      local slotPose=rawData[DataParser.SLOT_POSE]
      local bonePoses=rawData[DataParser.BONE_POSE]
      local indices={}
      weightBoneCount=math.floor(#bonePoses/7)
      for i=0,weightBoneCount-1 do
        local rawIndex=bonePoses[i*7+1]
        local bone=self._rawBones[rawIndex+1]
        weight:addBone(bone)
        indices[i+1]=rawIndex
        zeroPut(intArray,weightOffset+offsets.WeigthBoneIndices+i,
          indexOf(sortedBones,bone))
      end
      extend(floatArray,#floatArray+weightCount*3)
      self._helpMatrixA:copyFromArray(slotPose,0)
      local iW=0
      local iB=weightOffset+offsets.WeigthBoneIndices+weightBoneCount
      local iV=floatOffset
      for i=0,vertexCount-1 do
        local iD=i*2
        local vertexBoneCount=rawWeights[iW+1]
        zeroPut(intArray,iB,vertexBoneCount)
        iB=iB+1
        iW=iW+1
        local x=zeroAt(floatArray,verticesOffset+iD)
        local y=zeroAt(floatArray,verticesOffset+iD+1)
        self._helpMatrixA:transformPoint(x,y,self._helpPoint)
        x,y=self._helpPoint.x,self._helpPoint.y
        for _=1,vertexBoneCount do
          local rawBoneIndex=rawWeights[iW+1]
          iW=iW+1
          local boneIndex=indexOf(indices,rawBoneIndex)
          self._helpMatrixB:copyFromArray(bonePoses,boneIndex*7+1)
          self._helpMatrixB:invert()
          self._helpMatrixB:transformPoint(x,y,self._helpPoint)
          zeroPut(intArray,iB,boneIndex)
          iB=iB+1
          zeroPut(floatArray,iV,rawWeights[iW+1]);iV=iV+1
          zeroPut(floatArray,iV,self._helpPoint.x);iV=iV+1
          zeroPut(floatArray,iV,self._helpPoint.y);iV=iV+1
          iW=iW+1
        end
      end
    else
      local rawBones=rawData[DataParser.BONES]
      weightBoneCount=#rawBones
      for i=0,weightBoneCount-1 do
        local bone=self._rawBones[rawBones[i+1]+1]
        weight:addBone(bone)
        zeroPut(intArray,weightOffset+offsets.WeigthBoneIndices+i,
          indexOf(sortedBones,bone))
      end
      extend(floatArray,#floatArray+weightCount*3)
      -- The upstream loops over weightCount here, not vertexCount.
      local iW,iV=0,0
      local iB=weightOffset+offsets.WeigthBoneIndices+weightBoneCount
      local iF=floatOffset
      for _=1,weightCount do
        local vertexBoneCount=rawWeights[iW+1]
        iW=iW+1
        zeroPut(intArray,iB,vertexBoneCount)
        iB=iB+1
        for _=1,vertexBoneCount do
          local boneIndex=rawWeights[iW+1];iW=iW+1
          local boneWeight=rawWeights[iW+1];iW=iW+1
          local x=rawVertices[iV+1];iV=iV+1
          local y=rawVertices[iV+1];iV=iV+1
          zeroPut(intArray,iB,indexOf(rawBones,boneIndex));iB=iB+1
          zeroPut(floatArray,iF,boneWeight);iF=iF+1
          zeroPut(floatArray,iF,x);iF=iF+1
          zeroPut(floatArray,iF,y);iF=iF+1
        end
      end
    end
    geometry.weight=weight
  end
end

function ObjectDataParser:_parseArray(_rawData)
  -- Preserve the identities of the seven original reusable JS arrays.
  clear(self._intArray)
  clear(self._floatArray)
  clear(self._frameIntArray)
  clear(self._frameFloatArray)
  clear(self._frameArray)
  clear(self._timelineArray)
  clear(self._colorArray)
end

-- ObjectDataParser.ts _modifyArray (source lines 2215-2292).
-- The source constructs one ArrayBuffer with seven typed views. Lua has no
-- standard shared mutable ArrayBuffer; a byte string plus seven numeric
-- typed-view snapshots preserves the original byte layout at finalization.
-- See PORTING_STATUS for the explicit post-finalization aliasing limitation.
local function truncNumber(value)
  if type(value)=="boolean" then value=value and 1 or 0 end
  if value==nil or value==JsonNull then return 0 end
  if type(value)~="number" then
    if type(value)=="string" then
      if value:match("^%s*$") then return 0 end
      value=tonumber(value) or 0
    else return 0 end
  end
  if value~=value or value==math.huge or value==-math.huge then return 0 end
  if value<0 then return math.ceil(value) end
  return math.floor(value)
end
local function uint16(value)
  return truncNumber(value)%65536
end
local function pack16(value,isUnsigned)
  local n=uint16(value)
  local decoded=n
  if not isUnsigned and n>=32768 then decoded=n-65536 end
  return string.char(n%256,math.floor(n/256)),decoded
end
local function roundTiesEven(value)
  local lower=math.floor(value)
  local fractional=value-lower
  if fractional>0.5 or (fractional==0.5 and lower%2~=0) then
    return lower+1
  end
  return lower
end
local function float32Bits(value)
  if type(value)=="boolean" then value=value and 1 or 0 end
  if value==nil or value==JsonNull then value=0 end
  if type(value)~="number" then value=tonumber(value) or 0 end
  local sign=(value<0 or (value==0 and 1/value==-math.huge)) and 1 or 0
  local signBits=sign*2147483648
  if value~=value then
    return 2143289344,0/0 -- canonical quiet NaN (payload is unspecified in JS).
  end
  if value==math.huge or value==-math.huge then
    return signBits+2139095040,sign==1 and -math.huge or math.huge
  end
  local magnitude=math.abs(value)
  if magnitude==0 then return signBits,sign==1 and -0.0 or 0.0 end
  local exponentBits,mantissa,quantized
  if magnitude<2^-126 then
    mantissa=roundTiesEven(magnitude/2^-149)
    if mantissa==0 then
      quantized=0
      exponentBits=0
    elseif mantissa>=8388608 then
      exponentBits=1
      mantissa=0
      quantized=2^-126
    else
      exponentBits=0
      quantized=mantissa*2^-149
    end
  else
    local exponent=math.floor(math.log(magnitude)/math.log(2))
    local power=2^exponent
    local normalized=magnitude/power
    while normalized<1 do exponent=exponent-1;normalized=normalized*2 end
    while normalized>=2 do exponent=exponent+1;normalized=normalized/2 end
    mantissa=roundTiesEven((normalized-1)*8388608)
    if mantissa==8388608 then
      exponent=exponent+1
      mantissa=0
    end
    if exponent>127 then
      return signBits+2139095040,sign==1 and -math.huge or math.huge
    end
    exponentBits=exponent+127
    quantized=(1+mantissa/8388608)*2^exponent
  end
  local bits=signBits+exponentBits*8388608+mantissa
  return bits,sign==1 and -quantized or quantized
end
local function pack32(value)
  local bits,decoded=float32Bits(value)
  local a=bits%256
  bits=math.floor(bits/256)
  local b=bits%256
  bits=math.floor(bits/256)
  local c=bits%256
  local d=math.floor(bits/256)
  return string.char(a,b,c,d),decoded
end
local function appendTyped(source,kind,segments)
  local result={}
  for i=1,#source do
    local bytes,decoded
    if kind=="float32" then
      bytes,decoded=pack32(source[i])
    else
      bytes,decoded=pack16(source[i],kind=="uint16")
    end
    result[i]=decoded
    segments[#segments+1]=bytes
  end
  return result
end
function ObjectDataParser:_modifyArray()
  -- Original parity checks use element counts, not byte lengths. Preserve
  -- the upstream fifth condition (timeline length controls color padding).
  if #self._intArray%2~=0 then
    self._intArray[#self._intArray+1]=0
  end
  if #self._frameIntArray%2~=0 then
    self._frameIntArray[#self._frameIntArray+1]=0
  end
  if #self._frameArray%2~=0 then
    self._frameArray[#self._frameArray+1]=0
  end
  if #self._timelineArray%2~=0 then
    self._timelineArray[#self._timelineArray+1]=0
  end
  if #self._timelineArray%2~=0 then
    self._colorArray[#self._colorArray+1]=0
  end

  local data=self._data
  local segments={}
  data.intArray=appendTyped(self._intArray,"int16",segments)
  data.floatArray=appendTyped(self._floatArray,"float32",segments)
  data.frameIntArray=appendTyped(self._frameIntArray,"int16",segments)
  data.frameFloatArray=appendTyped(self._frameFloatArray,"float32",segments)
  data.frameArray=appendTyped(self._frameArray,"int16",segments)
  data.timelineArray=appendTyped(self._timelineArray,"uint16",segments)
  data.colorArray=appendTyped(self._colorArray,"int16",segments)
  data.binary=table.concat(segments)
  self._defaultColorOffset=-1
end


-- Source: ObjectDataParser.ts _parseArmature (lines 285-472) and
-- parseDragonBonesData (lines 2294-2353), same pinned original revision.
-- The source invokes _parseAnimation for any animation collection; that
-- method has NOT been ported. Keep the call and reject missing dependencies
-- naturally, rather than silently dropping animation data.
local DragonBonesData=require("dragonbones.original.model.DragonBonesData")
local CanvasData=require("dragonbones.original.model.CanvasData")

function ObjectDataParser:_parseArmature(rawData,scale)
  local armature=Pool.borrowObject(ArmatureModels.ArmatureData)
  armature.name=ObjectDataParser._getString(rawData,DataParser.NAME,"")
  armature.frameRate=ObjectDataParser._getNumber(
    rawData,DataParser.FRAME_RATE,self._data.frameRate)
  armature.scale=scale
  if type(get(rawData,DataParser.TYPE))=="string" then
    armature.type=DataParser._getArmatureType(rawData[DataParser.TYPE])
  else
    armature.type=ObjectDataParser._getNumber(
      rawData,DataParser.TYPE,Core.ArmatureType.Armature)
  end
  if armature.frameRate==0 then armature.frameRate=24 end
  self._armature=armature

  if get(rawData,DataParser.CANVAS)~=nil then
    local rawCanvas=rawData[DataParser.CANVAS]
    local canvas=Pool.borrowObject(CanvasData)
    canvas.hasBackground=get(rawCanvas,DataParser.COLOR)~=nil
    canvas.color=ObjectDataParser._getNumber(rawCanvas,DataParser.COLOR,0)
    canvas.x=ObjectDataParser._getNumber(rawCanvas,DataParser.X,0)*armature.scale
    canvas.y=ObjectDataParser._getNumber(rawCanvas,DataParser.Y,0)*armature.scale
    canvas.width=ObjectDataParser._getNumber(
      rawCanvas,DataParser.WIDTH,0)*armature.scale
    canvas.height=ObjectDataParser._getNumber(
      rawCanvas,DataParser.HEIGHT,0)*armature.scale
    armature.canvas=canvas
  end

  if get(rawData,DataParser.AABB)~=nil then
    local aabb=rawData[DataParser.AABB]
    armature.aabb.x=ObjectDataParser._getNumber(
      aabb,DataParser.X,0)*armature.scale
    armature.aabb.y=ObjectDataParser._getNumber(
      aabb,DataParser.Y,0)*armature.scale
    armature.aabb.width=ObjectDataParser._getNumber(
      aabb,DataParser.WIDTH,0)*armature.scale
    armature.aabb.height=ObjectDataParser._getNumber(
      aabb,DataParser.HEIGHT,0)*armature.scale
  end

  if get(rawData,DataParser.BONE)~=nil then
    for _,rawBone in ipairs(rawData[DataParser.BONE]) do
      local parentName=ObjectDataParser._getString(
        rawBone,DataParser.PARENT,"")
      local bone=self:_parseBone(rawBone)
      if #parentName>0 then
        local parent=armature:getBone(parentName)
        if parent~=nil then
          bone.parent=parent
        else
          if self._cacheBones[parentName]==nil then
            self._cacheBones[parentName]={}
          end
          local pending=self._cacheBones[parentName]
          pending[#pending+1]=bone
        end
      end
      local waiting=self._cacheBones[bone.name]
      if waiting~=nil then
        for _,child in ipairs(waiting) do child.parent=bone end
        self._cacheBones[bone.name]=nil
      end
      armature:addBone(bone)
      self._rawBones[#self._rawBones+1]=bone
    end
  end

  if get(rawData,DataParser.IK)~=nil then
    for _,rawIK in ipairs(rawData[DataParser.IK]) do
      local constraint=self:_parseIKConstraint(rawIK)
      if constraint~=nil then armature:addConstraint(constraint) end
    end
  end
  armature:sortBones()

  if get(rawData,DataParser.SLOT)~=nil then
    for i,rawSlot in ipairs(rawData[DataParser.SLOT]) do
      armature:addSlot(self:_parseSlot(rawSlot,i-1))
    end
  end
  if get(rawData,DataParser.SKIN)~=nil then
    for _,rawSkin in ipairs(rawData[DataParser.SKIN]) do
      armature:addSkin(self:_parseSkin(rawSkin))
    end
  end
  if get(rawData,DataParser.PATH_CONSTRAINT)~=nil then
    for _,rawPath in ipairs(rawData[DataParser.PATH_CONSTRAINT]) do
      local constraint=self:_parsePathConstraint(rawPath)
      if constraint~=nil then armature:addConstraint(constraint) end
    end
  end

  -- The upstream source uses getMesh(skinName, "", shareName) with a
  -- TODO about slot selection. Retain that behavior even if it misses a mesh.
  for i,rawMesh in ipairs(self._cacheRawMeshes) do
    local shareName=ObjectDataParser._getString(
      rawMesh,DataParser.SHARE,"")
    if #shareName>0 then
      local skinName=ObjectDataParser._getString(
        rawMesh,DataParser.SKIN,DataParser.DEFAULT_NAME)
      if #skinName==0 then skinName=DataParser.DEFAULT_NAME end
      local shared=armature:getMesh(skinName,"",shareName)
      if shared~=nil then
        self._cacheMeshes[i].geometry:shareFrom(shared.geometry)
      end
    end
  end

  if get(rawData,DataParser.ANIMATION)~=nil then
    for _,rawAnimation in ipairs(rawData[DataParser.ANIMATION]) do
      -- Original call, not a replacement: _parseAnimation will be ported
      -- from ObjectDataParser.ts before animated skeletons can load.
      local animation=self:_parseAnimation(rawAnimation)
      armature:addAnimation(animation)
    end
  end

  if get(rawData,DataParser.DEFAULT_ACTIONS)~=nil then
    local actions=self:_parseActionData(
      rawData[DataParser.DEFAULT_ACTIONS],Core.ActionType.Play,nil,nil)
    for _,action in ipairs(actions) do
      armature:addAction(action,true)
      if action.type==Core.ActionType.Play then
        local animation=armature:getAnimation(action.name)
        if animation~=nil then armature.defaultAnimation=animation end
      end
    end
  end
  if get(rawData,DataParser.ACTIONS)~=nil then
    local actions=self:_parseActionData(
      rawData[DataParser.ACTIONS],Core.ActionType.Play,nil,nil)
    for _,action in ipairs(actions) do
      armature:addAction(action,false)
    end
  end

  clear(self._rawBones)
  clear(self._cacheRawMeshes)
  clear(self._cacheMeshes)
  self._armature=nil
  for key in pairs(self._weightSlotPose) do
    self._weightSlotPose[key]=nil
  end
  for key in pairs(self._weightBonePoses) do
    self._weightBonePoses[key]=nil
  end
  for key in pairs(self._cacheBones) do
    self._cacheBones[key]=nil
  end
  for key in pairs(self._slotChildActions) do
    self._slotChildActions[key]=nil
  end
  return armature
end

function ObjectDataParser:parseDragonBonesData(rawData,scale)
  if scale==nil then scale=1 end
  assert(rawData~=nil,"Data error.")
  local version=ObjectDataParser._getString(
    rawData,DataParser.VERSION,"")
  local compatible=ObjectDataParser._getString(
    rawData,DataParser.COMPATIBLE_VERSION,"")
  local supported=false
  for _,candidate in ipairs(DataParser.DATA_VERSIONS) do
    if version==candidate or compatible==candidate then
      supported=true
      break
    end
  end
  if not supported then
    io.stderr:write(
      "Nonsupport data version: "..version..
      "\nPlease convert DragonBones data to support version.\n"..
      "Read more: https://github.com/DragonBones/Tools/\n")
    return nil
  end

  local data=Pool.borrowObject(DragonBonesData)
  data.version=version
  data.name=ObjectDataParser._getString(rawData,DataParser.NAME,"")
  data.frameRate=ObjectDataParser._getNumber(
    rawData,DataParser.FRAME_RATE,24)
  if data.frameRate==0 then data.frameRate=24 end

  if get(rawData,DataParser.ARMATURE)~=nil then
    self._data=data
    self:_parseArray(rawData)
    for _,rawArmature in ipairs(rawData[DataParser.ARMATURE]) do
      data:addArmature(self:_parseArmature(rawArmature,scale))
    end
    if data.binary==nil then self:_modifyArray() end
    if get(rawData,DataParser.STAGE)~=nil then
      data.stage=data:getArmature(ObjectDataParser._getString(
        rawData,DataParser.STAGE,""))
    elseif #data.armatureNames>0 then
      data.stage=data:getArmature(data.armatureNames[1])
    end
    self._data=nil
  end

  if get(rawData,DataParser.TEXTURE_ATLAS)~=nil then
    self._rawTextureAtlases=rawData[DataParser.TEXTURE_ATLAS]
  end
  return data
end

local instance=nil
function ObjectDataParser.getInstance()
  if instance==nil then instance=ObjectDataParser.new() end
  return instance
end
return ObjectDataParser
