-- Partial port: ObjectDataParser.ts, pinned DragonBonesJS
-- 64b6c69ae35777c2404be68c9192e2c56906079e.
-- Copyright (c) 2012-2025 DragonBones team and contributors; MIT.
-- Implemented: initializers, helpers, atlas, structural dependencies and singleton.
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

return ObjectDataParser
