-- Partial AnimationState from AnimationState.ts; real lifecycle/seek/weight APIs.
-- DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e; MIT.
-- advanceTime and automatic bone/slot/constraint timeline construction remain absent.
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
local EventObject=require('dragonbones.event.EventObject')
local number=require('dragonbones.parser.JSValue').number
local Type=Core.TimelineType
local function uint32(value)
  value=number(value)
  if value~=value or value==math.huge or value==-math.huge or value==0 then return 0 end
  value=value<0 and math.ceil(value)or math.floor(value)
  return value%4294967296
end
local function bitAnd1(value)return uint32(value)%2 end
local function bitAnd2(value)return math.floor(uint32(value)/2)%2*2 end
local function bitOr1(value)
  value=uint32(value)
  if value%2==0 then value=value+1 end
  if value>=2147483648 then value=value-4294967296 end
  return value
end
local function has(a,value)
  for _,item in each(a)do if item==value then return true end end
  return false
end
local function erase(a,value)
  for i=1,a.length do
    if a[i]==value then
      for j=i,a.length-1 do a[j]=a[j+1]end
      a.length=a.length-1
      return true
    end
  end
  return false
end
local function borrowTimeline(name,target,armature,state,data,into)
  local class
  if name=='ActionTimelineState'then class=require('dragonbones.animation.ActionTimelineState')
  elseif name=='ZOrderTimelineState'then class=require('dragonbones.animation.ConstraintOrderTimelineState').ZOrderTimelineState
  else class=require('dragonbones.animation.AnimationTimelineState')[name]end
  local timeline=BaseObject.borrowObject(class)
  if target~=nil then timeline.target=target end
  timeline:init(armature,state,data)
  if into~=nil then into[into.length+1]=timeline end
  return timeline
end
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
  if key=='isFadeIn'then return number(self._fadeState)<0 end
  if key=='isFadeOut'then return number(self._fadeState)>0 end
  if key=='isFadeComplete'then return self._fadeState==0 end
  if key=='isPlaying'then return bitAnd2(self._playheadState)~=0 and self._actionTimeline.playState<=0 end
  if key=='isCompleted'then return self._actionTimeline.playState>0 end
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
  elseif key=="currentPlayTimes" or key=="totalTime" or key=="animationData"
      or key=="isFadeIn" or key=="isFadeOut" or key=="isFadeComplete"
      or key=="isPlaying" or key=="isCompleted" then
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

function AnimationState:_advanceFadeTime(passedTime)
  local isFadeOut=self._fadeState>0
  if self._subFadeState<0 then
    self._subFadeState=0
    local active=self._parent==nil and self.actionEnabled
    if active then
      local event=isFadeOut and EventObject.FADE_OUT or EventObject.FADE_IN
      if self._armature.eventDispatcher:hasDBEventListener(event) then
        local evt=BaseObject.borrowObject(EventObject)
        evt.type=event
        evt.armature=self._armature
        evt.animationState=self
        self._armature._dragonBones:bufferEvent(evt)
      end
    end
  end

  if passedTime<0 then passedTime=-passedTime end
  self._fadeTime=self._fadeTime+passedTime
  if self._fadeTime>=self.fadeTotalTime then
    self._subFadeState=1
    self._fadeProgress=isFadeOut and 0.0 or 1.0
  elseif self._fadeTime>0 then
    self._fadeProgress=isFadeOut
      and (1.0-self._fadeTime/self.fadeTotalTime)
      or (self._fadeTime/self.fadeTotalTime)
  else
    self._fadeProgress=isFadeOut and 1.0 or 0.0
  end

  if self._subFadeState>0 then
    if not isFadeOut then
      self._playheadState=bitOr1(self._playheadState)
      self._fadeState=0
    end
    local active=self._parent==nil and self.actionEnabled
    if active then
      local event=isFadeOut and EventObject.FADE_OUT_COMPLETE
        or EventObject.FADE_IN_COMPLETE
      if self._armature.eventDispatcher:hasDBEventListener(event) then
        local evt=BaseObject.borrowObject(EventObject)
        evt.type=event
        evt.armature=self._armature
        evt.animationState=self
        self._armature._dragonBones:bufferEvent(evt)
      end
    end
  end
end

function AnimationState:init(armature,animationData,config)
  if self._armature~=nil then return end
  self._armature=armature
  self._animationData=animationData

  self.resetToPose=config.resetToPose
  self.additive=config.additive
  self.displayControl=config.displayControl
  self.actionEnabled=config.actionEnabled
  self.blendType=animationData.blendType
  self.layer=config.layer
  self.playTimes=config.playTimes
  self.timeScale=config.timeScale
  self.fadeTotalTime=config.fadeInTime
  self.autoFadeOutTime=config.autoFadeOutTime
  self.name=#config.name>0 and config.name or config.animation
  self.group=config.group
  self._weight=config.weight

  self._playheadState=config.pauseFadeIn and 2 or 3
  if config.duration<0.0 then
    self._position=0.0
    self._duration=animationData.duration
    if config.position~=0.0 then
      if self.timeScale>=0.0 then self._time=config.position
      else self._time=config.position-self._duration end
    else
      self._time=0.0
    end
  else
    self._position=config.position
    self._duration=config.duration
    self._time=0.0
  end

  if self.timeScale<0.0 and self._time==0.0 then
    self._time=-0.000001
  end
  if self.fadeTotalTime<=0.0 then self._fadeProgress=0.999999 end

  if config.boneMask.length>0 then
    self._boneMask.length=config.boneMask.length
    for i,name in each(config.boneMask) do self._boneMask[i]=name end
  end

  self._actionTimeline=borrowTimeline("ActionTimelineState",nil,
    armature,self,animationData.actionTimeline,nil)
  self._actionTimeline.currentTime=self._time
  if self._actionTimeline.currentTime<0.0 then
    self._actionTimeline.currentTime=
      self._duration-self._actionTimeline.currentTime
  end
  if animationData.zOrderTimeline~=nil then
    self._zOrderTimeline=borrowTimeline("ZOrderTimelineState",nil,
      armature,self,animationData.zOrderTimeline,nil)
  end
end

function AnimationState:play()
  self._playheadState=3
end

function AnimationState:stop()
  self._playheadState=bitAnd1(self._playheadState)
end

function AnimationState:fadeOut(fadeOutTime,pausePlayhead)
  if pausePlayhead==nil then pausePlayhead=true end
  if fadeOutTime<0.0 then fadeOutTime=0.0 end
  if pausePlayhead then self._playheadState=bitAnd2(self._playheadState) end
  if self._fadeState>0 then
    if fadeOutTime>self.fadeTotalTime-self._fadeTime then return end
  else
    self._fadeState=1
    self._subFadeState=-1
    if fadeOutTime<=0.0 or self._fadeProgress<=0.0 then
      self._fadeProgress=0.000001
    end
    for _,timeline in each(self._boneTimelines) do timeline:fadeOut() end
    for _,timeline in each(self._boneBlendTimelines) do timeline:fadeOut() end
    for _,timeline in each(self._slotTimelines) do timeline:fadeOut() end
    for _,timeline in each(self._slotBlendTimelines) do timeline:fadeOut() end
    for _,timeline in each(self._constraintTimelines) do timeline:fadeOut() end
    for _,timeline in each(self._animationTimelines) do
      timeline:fadeOut()
      timeline.target:fadeOut(999999.0,true)
    end
  end
  self.displayControl=false
  self.fadeTotalTime=self._fadeProgress>0.000001
    and fadeOutTime/self._fadeProgress or 0.0
  self._fadeTime=self.fadeTotalTime*(1.0-self._fadeProgress)
end

function AnimationState:containsBoneMask(name)
  return self._boneMask.length==0 or has(self._boneMask,name)
end

function AnimationState:addBoneMask(name,recursive)
  if recursive==nil then recursive=true end
  local currentBone=self._armature:getBone(name)
  if currentBone==nil then return end
  if not has(self._boneMask,name) then
    self._boneMask[self._boneMask.length+1]=name
  end
  if recursive then
    for _,bone in each(self._armature:getBones()) do
      if not has(self._boneMask,bone.name) and currentBone:contains(bone) then
        self._boneMask[self._boneMask.length+1]=bone.name
      end
    end
  end
  self._timelineDirty=1
end

function AnimationState:removeBoneMask(name,recursive)
  if recursive==nil then recursive=true end
  erase(self._boneMask,name)
  if recursive then
    local currentBone=self._armature:getBone(name)
    if currentBone~=nil then
      local bones=self._armature:getBones()
      if self._boneMask.length>0 then
        for _,bone in each(bones) do
          if has(self._boneMask,bone.name) and currentBone:contains(bone) then
            erase(self._boneMask,bone.name)
          end
        end
      else
        for _,bone in each(bones) do
          if bone~=currentBone and not currentBone:contains(bone) then
            self._boneMask[self._boneMask.length+1]=bone.name
          end
        end
      end
    end
  end
  self._timelineDirty=1
end

function AnimationState:removeAllBoneMask()
  clear(self._boneMask)
  self._timelineDirty=1
end

function AnimationState:addState(child,timelineDatas)
  if timelineDatas~=nil then
    for _,data in each(timelineDatas) do
      if data.type==Type.AnimationProgress then
        borrowTimeline("AnimationProgressTimelineState",child,self._armature,self,data,self._animationTimelines)
        if self.blendType~=Core.AnimationBlendType.None then
          child.positionX=data.x
          child.positionY=data.y
          child.weight=0.0
        end
        child._parent=self
        self.resetToPose=false
      elseif data.type==Type.AnimationWeight then
        borrowTimeline("AnimationWeightTimelineState",child,self._armature,self,data,self._animationTimelines)
      elseif data.type==Type.AnimationParameter then
        borrowTimeline("AnimationParametersTimelineState",child,self._armature,self,data,self._animationTimelines)
      end
    end
  end
  if child._parent==nil then child._parent=self end
end

function AnimationState:activeTimeline()
  for _,timeline in each(self._slotTimelines) do
    timeline.dirty=true
    timeline.currentTime=-1.0
  end
end
return AnimationState
