-- Partial AnimationState from AnimationState.ts; real lifecycle/seek/weight APIs.
-- DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e; MIT.
-- init, advanceTime, fade and timeline construction remain absent.
local BaseObject=require('dragonbones.core.BaseObject')
local Core=require('dragonbones.core.Enums')
local Array=require('dragonbones.core.JSArray')
local AnimationState={}
setmetatable(AnimationState,{__index=BaseObject})
local function each(a)
  local i=0
  return function()
    i=i+1
    if i<=a.length then return i,a[i] end
  end
end
local function clear(a)a.length=0 end
local function signedRemainder(x,y)return math.fmod(x,y)end
function AnimationState.toString()return '[class dragonBones.AnimationState]'end
function AnimationState.new()
  local self=BaseObject.new(AnimationState)
  for _,key in ipairs({'_boneMask','_boneTimelines','_boneBlendTimelines','_slotTimelines',
      '_slotBlendTimelines','_constraintTimelines','_animationTimelines','_poseTimelines'})do
    self[key]=Array.new()
  end
  return self
end
function AnimationState.__index(self,key)
  if key=='currentPlayTimes' then return self._actionTimeline.currentPlayTimes end
  if key=='totalTime' then return self._duration end
  if key=='currentTime' then return self._actionTimeline.currentTime end
  if key=='weight' then return self._weight end
  if key=='animationData' then return self._animationData end
  return rawget(AnimationState,key)or BaseObject[key]
end
local function setCurrentTime(self,value)
  local times=self._actionTimeline.currentPlayTimes
    - (self._actionTimeline.playState>0 and 1 or 0)
  if value<0 or self._duration<value then
    value=signedRemainder(value,self._duration)+times*self._duration
    if value<0 then value=value+self._duration end
  end
  if self.playTimes>0 and times==self.playTimes-1
    and value==self._duration and self._parent==nil then
    value=self._duration-0.000001
  end
  if self._time==value then return end
  self._time=value
  self._actionTimeline:setCurrentTime(self._time)
  if self._zOrderTimeline~=nil then self._zOrderTimeline.playState=-1 end
  for _,timeline in each(self._boneTimelines) do timeline.playState=-1 end
  for _,timeline in each(self._slotTimelines) do timeline.playState=-1 end
end
local function setWeight(self,value)
  if self._weight==value then return end
  self._weight=value
  for _,timeline in each(self._boneTimelines) do timeline.dirty=true end
  for _,timeline in each(self._boneBlendTimelines) do timeline.dirty=true end
  for _,timeline in each(self._slotBlendTimelines) do timeline.dirty=true end
end
function AnimationState.__newindex(self,key,value)
  if key=="currentTime" then setCurrentTime(self,value)
  elseif key=="weight" then setWeight(self,value)
  elseif key=="currentPlayTimes" or key=="totalTime" or key=="animationData" then
    error("Readonly property: "..key)
  else rawset(self,key,value) end
end

function AnimationState:_onClear()
  for _,timeline in each(self._boneTimelines) do timeline:returnToPool() end
  for _,timeline in each(self._boneBlendTimelines) do timeline:returnToPool() end
  for _,timeline in each(self._slotTimelines) do timeline:returnToPool() end
  for _,timeline in each(self._slotBlendTimelines) do timeline:returnToPool() end
  for _,timeline in each(self._constraintTimelines) do timeline:returnToPool() end
  for _,timeline in each(self._animationTimelines) do
    local child=timeline.target
    if child._parent==self then
      child._fadeState=1
      child._subFadeState=1
      child._parent=nil
    end
    timeline:returnToPool()
  end
  if self._actionTimeline~=nil then self._actionTimeline:returnToPool() end
  if self._zOrderTimeline~=nil then self._zOrderTimeline:returnToPool() end

  self.actionEnabled=false
  self.additive=false
  self.displayControl=false
  self.resetToPose=false
  self.blendType=Core.AnimationBlendType.None
  self.playTimes=1
  self.layer=0
  self.timeScale=1.0
  self._weight=1.0
  self.parameterX=0.0
  self.parameterY=0.0
  self.positionX=0.0
  self.positionY=0.0
  self.autoFadeOutTime=0.0
  self.fadeTotalTime=0.0
  self.name=""
  self.group=""
  self._timelineDirty=2
  self._playheadState=0
  self._fadeState=-1
  self._subFadeState=-1
  self._position=0.0
  self._duration=0.0
  self._fadeTime=0.0
  self._time=0.0
  self._fadeProgress=0.0
  self._weightResult=0.0
  clear(self._boneMask)
  clear(self._boneTimelines)
  clear(self._boneBlendTimelines)
  clear(self._slotTimelines)
  clear(self._slotBlendTimelines)
  clear(self._constraintTimelines)
  clear(self._animationTimelines)
  clear(self._poseTimelines)
  self._animationData=nil
  self._armature=nil
  self._actionTimeline=nil
  self._zOrderTimeline=nil
  self._activeChildA=nil
  self._activeChildB=nil
  self._parent=nil
end

return AnimationState
