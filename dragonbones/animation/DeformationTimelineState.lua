-- SurfaceTimelineState and DeformTimelineState, TimelineState.ts.
-- DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e; MIT.
local Multi=require('dragonbones.animation.BaseTimelineState').MutilpleValueTimelineState
local BO=require('dragonbones.core.Enums').BinaryOffset
local number=require('dragonbones.parser.JSValue').number
local function at(a,i) return number(a[i+1]) end
local function set(a,i,v) a[i+1]=v end
local function klass(name,parent)
  local c={};c.__index=c;setmetatable(c,{__index=parent})
  c.toString=function() return '[class dragonBones.'..name..']' end
  c.new=function() return parent.new(c) end
  return c
end
local SurfaceTimelineState=klass("SurfaceTimelineState",Multi)
function SurfaceTimelineState:_onClear()
  Multi._onClear(self)
  self._deformCount=0
  self._deformOffset=0
  self._sameValueOffset=0
end
function SurfaceTimelineState:init(a,s,d)
  Multi.init(self,a,s,d)
  if self._timelineData~=nil then
    local db=self._animationData.parent.parent
    local ints=db.frameIntArray
    local offset=self._animationData.frameIntOffset+
      at(self._timelineArray,self._timelineData.offset+BO.TimelineFrameValueCount)
    self._valueOffset=self._animationData.frameFloatOffset
    self._valueCount=at(ints,offset+BO.DeformValueCount)
    self._deformCount=at(ints,offset+BO.DeformCount)
    self._deformOffset=at(ints,offset+BO.DeformValueOffset)
    self._sameValueOffset=at(ints,offset+BO.DeformFloatOffset)+
      self._animationData.frameFloatOffset
    self._valueScale=self._armature.armatureData.scale
    self._valueArray=db.frameFloatArray
    -- A JS array's length can exceed the populated entries; in this port
    -- the _rd read/write loops are indexed explicitly with the value count.
    self._rd.length=self._valueCount*2
  else
    self._deformCount=self.target.target._deformVertices.length
  end
end
function SurfaceTimelineState:blend(isDirty)
  local blend=self.target
  local surface=blend.target
  local weight=blend.blendWeight
  local result=surface._deformVertices
  local values=self._valueArray
  if values~=nil then
    local count=self._valueCount
    local offset=self._deformOffset
    local same=self._sameValueOffset
    local rd=self._rd
    for i=0,self._deformCount-1 do
      local value=0.0
      if i<offset then value=at(values,same+i)
      elseif i<offset+count then value=at(rd,i-offset)
      else value=at(values,same+i-count) end
      if blend.dirty>1 then
        set(result,i,at(result,i)+value*weight)
      else
        set(result,i,value*weight)
      end
    end
  elseif blend.dirty==1 then
    for i=0,self._deformCount-1 do set(result,i,0.0) end
  end
  if isDirty or self.dirty then
    self.dirty=false
    surface._transformDirty=true
  end
end

local DeformTimelineState=klass("DeformTimelineState",Multi)
function DeformTimelineState:_onClear()
  Multi._onClear(self)
  self.displayFrame=nil
  self._deformCount=0
  self._deformOffset=0
  self._sameValueOffset=0
end
function DeformTimelineState:init(a,s,d)
  Multi.init(self,a,s,d)
  if self._timelineData~=nil then
    local offset=self._animationData.frameIntOffset+
      at(self._timelineArray,self._timelineData.offset+BO.TimelineFrameValueCount)
    local db=self._animationData.parent.parent
    local ints=db.frameIntArray
    self._valueOffset=self._animationData.frameFloatOffset
    self._valueCount=at(ints,offset+BO.DeformValueCount)
    self._deformCount=at(ints,offset+BO.DeformCount)
    self._deformOffset=at(ints,offset+BO.DeformValueOffset)
    self._sameValueOffset=at(ints,offset+BO.DeformFloatOffset)
    if self._sameValueOffset<0 then
      self._sameValueOffset=self._sameValueOffset+65536
    end
    self._sameValueOffset=self._sameValueOffset+
      self._animationData.frameFloatOffset
    self._valueScale=self._armature.armatureData.scale
    self._valueArray=db.frameFloatArray
    self._rd.length=self._valueCount*2
  else
    self._deformCount=self.displayFrame.deformVertices.length
  end
end
function DeformTimelineState:blend(isDirty)
  local blend=self.target
  local slot=blend.target
  local weight=blend.blendWeight
  local result=self.displayFrame.deformVertices
  local values=self._valueArray
  if values~=nil then
    local count=self._valueCount
    local offset=self._deformOffset
    local same=self._sameValueOffset
    local rd=self._rd
    for i=0,self._deformCount-1 do
      local value=0.0
      if i<offset then value=at(values,same+i)
      elseif i<offset+count then value=at(rd,i-offset)
      else value=at(values,same+i-count) end
      if blend.dirty>1 then
        set(result,i,at(result,i)+value*weight)
      else
        set(result,i,value*weight)
      end
    end
  elseif blend.dirty==1 then
    for i=0,self._deformCount-1 do set(result,i,0.0) end
  end
  if isDirty or self.dirty then
    self.dirty=false
    if slot._geometryData==self.displayFrame:getGeometryData() then
      slot._verticesDirty=true
    end
  end
end

return {SurfaceTimelineState=SurfaceTimelineState,DeformTimelineState=DeformTimelineState}
