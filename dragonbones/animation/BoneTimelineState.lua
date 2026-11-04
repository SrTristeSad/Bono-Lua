-- Four bone transformation classes from TimelineState.ts.
-- DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e; MIT.
local Base=require('dragonbones.animation.BaseTimelineState')
local Transform=require('dragonbones.geom.Transform')
local Double=Base.DoubleValueTimelineState
local Multi=Base.MutilpleValueTimelineState
local function at(a,i) return a[i+1] end
local function set(a,i,v) a[i+1]=v end
local function klass(name,parent)
  local c={};c.__index=c;setmetatable(c,{__index=parent})
  c.toString=function() return '[class dragonBones.'..name..']' end
  c.new=function() return parent.new(c) end
  return c
end
local BoneAllTimelineState=klass("BoneAllTimelineState",Multi)
function BoneAllTimelineState:_onArriveAtFrame()
  Multi._onArriveAtFrame(self)
  if self._isTween and self._frameIndex==self._frameCount-1 then
    set(self._rd,2,Transform.normalizeRadian(at(self._rd,2)))
    set(self._rd,3,Transform.normalizeRadian(at(self._rd,3)))
  end
  if self._timelineData==nil then
    set(self._rd,4,1.0);set(self._rd,5,1.0)
  end
end
function BoneAllTimelineState:init(armature,state,data)
  Multi.init(self,armature,state,data)
  self._valueOffset=self._animationData.frameFloatOffset
  self._valueCount=6
  self._valueArray=self._animationData.parent.parent.frameFloatArray
end
function BoneAllTimelineState:fadeOut()
  self.dirty=false
  set(self._rd,2,Transform.normalizeRadian(at(self._rd,2)))
  set(self._rd,3,Transform.normalizeRadian(at(self._rd,3)))
end
function BoneAllTimelineState:blend(isDirty)
  local scale=self._armature.armatureData.scale
  local rd=self._rd
  local blend=self.target
  local bone=blend.target
  local weight=blend.blendWeight
  local pose=bone.animationPose
  if blend.dirty>1 then
    pose.x=pose.x+at(rd,0)*weight*scale
    pose.y=pose.y+at(rd,1)*weight*scale
    pose.rotation=pose.rotation+at(rd,2)*weight
    pose.skew=pose.skew+at(rd,3)*weight
    pose.scaleX=pose.scaleX+(at(rd,4)-1.0)*weight
    pose.scaleY=pose.scaleY+(at(rd,5)-1.0)*weight
  else
    pose.x=at(rd,0)*weight*scale
    pose.y=at(rd,1)*weight*scale
    pose.rotation=at(rd,2)*weight
    pose.skew=at(rd,3)*weight
    pose.scaleX=(at(rd,4)-1.0)*weight+1.0
    pose.scaleY=(at(rd,5)-1.0)*weight+1.0
  end
  if isDirty or self.dirty then
    self.dirty=false
    bone._transformDirty=true
  end
end

local BoneTranslateTimelineState=klass("BoneTranslateTimelineState",Double)
function BoneTranslateTimelineState:init(a,s,d)
  Double.init(self,a,s,d)
  self._valueOffset=self._animationData.frameFloatOffset
  self._valueScale=self._armature.armatureData.scale
  self._valueArray=self._animationData.parent.parent.frameFloatArray
end
function BoneTranslateTimelineState:blend(isDirty)
  local blend=self.target
  local bone=blend.target
  local weight=blend.blendWeight
  local result=bone.animationPose
  if blend.dirty>1 then
    result.x=result.x+self._resultA*weight
    result.y=result.y+self._resultB*weight
  elseif weight~=1.0 then
    result.x=self._resultA*weight
    result.y=self._resultB*weight
  else
    result.x=self._resultA
    result.y=self._resultB
  end
  if isDirty or self.dirty then
    self.dirty=false
    bone._transformDirty=true
  end
end

local BoneRotateTimelineState=klass("BoneRotateTimelineState",Double)
function BoneRotateTimelineState:_onArriveAtFrame()
  Double._onArriveAtFrame(self)
  if self._isTween and self._frameIndex==self._frameCount-1 then
    self._differenceA=Transform.normalizeRadian(self._differenceA)
    self._differenceB=Transform.normalizeRadian(self._differenceB)
  end
end
function BoneRotateTimelineState:init(a,s,d)
  Double.init(self,a,s,d)
  self._valueOffset=self._animationData.frameFloatOffset
  self._valueArray=self._animationData.parent.parent.frameFloatArray
end
function BoneRotateTimelineState:fadeOut()
  self.dirty=false
  self._resultA=Transform.normalizeRadian(self._resultA)
  self._resultB=Transform.normalizeRadian(self._resultB)
end
function BoneRotateTimelineState:blend(isDirty)
  local blend=self.target
  local bone=blend.target
  local weight=blend.blendWeight
  local result=bone.animationPose
  if blend.dirty>1 then
    result.rotation=result.rotation+self._resultA*weight
    result.skew=result.skew+self._resultB*weight
  elseif weight~=1.0 then
    result.rotation=self._resultA*weight
    result.skew=self._resultB*weight
  else
    result.rotation=self._resultA
    result.skew=self._resultB
  end
  if isDirty or self.dirty then
    self.dirty=false
    bone._transformDirty=true
  end
end

local BoneScaleTimelineState=klass("BoneScaleTimelineState",Double)
function BoneScaleTimelineState:_onArriveAtFrame()
  Double._onArriveAtFrame(self)
  if self._timelineData==nil then
    self._resultA=1.0
    self._resultB=1.0
  end
end
function BoneScaleTimelineState:init(a,s,d)
  Double.init(self,a,s,d)
  self._valueOffset=self._animationData.frameFloatOffset
  self._valueArray=self._animationData.parent.parent.frameFloatArray
end
function BoneScaleTimelineState:blend(isDirty)
  local blend=self.target
  local bone=blend.target
  local weight=blend.blendWeight
  local result=bone.animationPose
  if blend.dirty>1 then
    result.scaleX=result.scaleX+(self._resultA-1.0)*weight
    result.scaleY=result.scaleY+(self._resultB-1.0)*weight
  elseif weight~=1.0 then
    result.scaleX=(self._resultA-1.0)*weight+1.0
    result.scaleY=(self._resultB-1.0)*weight+1.0
  else
    result.scaleX=self._resultA
    result.scaleY=self._resultB
  end
  if isDirty or self.dirty then
    self.dirty=false
    bone._transformDirty=true
  end
end

return {
  BoneAllTimelineState=BoneAllTimelineState,
  BoneTranslateTimelineState=BoneTranslateTimelineState,
  BoneRotateTimelineState=BoneRotateTimelineState,
  BoneScaleTimelineState=BoneScaleTimelineState,
}
