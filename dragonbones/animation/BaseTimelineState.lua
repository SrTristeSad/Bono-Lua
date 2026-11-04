-- Direct method-by-method port of the FIVE abstract classes in
-- DragonBones/src/dragonBones/animation/BaseTimelineState.ts.
-- DragonBonesJS revision 64b6c69ae35777c2404be68c9192e2c56906079e.
-- Copyright (c) 2012-2025 DragonBones team and other contributors.
-- Licensed under MIT; see LICENSE-DRAGONBONES.
--
-- These are abstract bases, not stand-ins for TimelineState.ts concrete types.
-- A concrete subclass overrides .new() and its abstract frame callbacks.
-- JS/typed-array indices are 0-based; Lua storage indices are +1.
local BaseObject = require("dragonbones.core.BaseObject")
local Core = require("dragonbones.core.Enums")
local Array = require("dragonbones.core.JSArray")
local number = require("dragonbones.parser.JSValue").number
local BO = Core.BinaryOffset
local TweenType = Core.TweenType

local function at(array,index)
  return array[index + 1]
end

local function clear(array)
  array.length=0
end

local TimelineState = {}
TimelineState.__index = TimelineState
setmetatable(TimelineState,{__index=BaseObject})

function TimelineState.new(class)
  return BaseObject.new(class or TimelineState)
end

function TimelineState:_onClear()
  self.dirty = false
  self.playState = -1
  self.currentPlayTimes = 0
  self.currentTime = -1.0
  self.target = nil

  self._isTween = false
  self._valueOffset = 0
  self._frameValueOffset = 0
  self._frameOffset = 0
  self._frameRate = 0
  self._frameCount = 0
  self._frameIndex = -1
  self._frameRateR = 0.0
  self._position = 0.0
  self._duration = 0.0
  self._timeScale = 1.0
  self._timeOffset = 0.0
  self._animationData = nil
  self._timelineData = nil
  self._armature = nil
  self._animationState = nil
  self._actionTimeline = nil
  self._timelineArray = nil
  self._frameArray = nil
  self._valueArray = nil
  self._frameIndices = nil
end

-- _onArriveAtFrame and _onUpdateFrame are abstract in the pinned original.

function TimelineState:_setCurrentTime(passedTime)
  local prevState = self.playState
  local prevPlayTimes = self.currentPlayTimes
  local prevTime = self.currentTime

  if self._actionTimeline ~= nil and self._frameCount <= 1 then
    self.playState = self._actionTimeline.playState >= 0 and 1 or -1
    self.currentPlayTimes = 1
    self.currentTime = self._actionTimeline.currentTime
  elseif self._actionTimeline == nil
      or self._timeScale ~= 1.0 or self._timeOffset ~= 0.0 then
    local playTimes = self._animationState.playTimes
    local totalTime = playTimes * self._duration

    passedTime = passedTime * self._timeScale
    if self._timeOffset ~= 0.0 then
      passedTime = passedTime + self._timeOffset * self._animationData.duration
    end

    if playTimes > 0 and
        (passedTime >= totalTime or passedTime <= -totalTime) then
      if self.playState <= 0 and self._animationState._playheadState == 3 then
        self.playState = 1
      end
      self.currentPlayTimes = playTimes
      if passedTime < 0.0 then
        self.currentTime = 0.0
      else
        self.currentTime = self.playState == 1
          and (self._duration + 0.000001) or self._duration
      end
    else
      if self.playState ~= 0 and self._animationState._playheadState == 3 then
        self.playState = 0
      end
      if passedTime < 0.0 then
        passedTime = -passedTime
        self.currentPlayTimes = math.floor(passedTime / self._duration)
        self.currentTime = self._duration - math.fmod(passedTime,self._duration)
      else
        self.currentPlayTimes = math.floor(passedTime / self._duration)
        self.currentTime = math.fmod(passedTime,self._duration)
      end
    end
    self.currentTime = self.currentTime + self._position
  else
    self.playState = self._actionTimeline.playState
    self.currentPlayTimes = self._actionTimeline.currentPlayTimes
    self.currentTime = self._actionTimeline.currentTime
  end

  if self.currentPlayTimes == prevPlayTimes and self.currentTime == prevTime then
    return false
  end
  if (prevState < 0 and self.playState ~= prevState)
      or (self.playState <= 0 and self.currentPlayTimes ~= prevPlayTimes) then
    self._frameIndex = -1
  end
  return true
end

function TimelineState:init(armature,animationState,timelineData)
  self._armature = armature
  self._animationState = animationState
  self._timelineData = timelineData
  self._actionTimeline = animationState._actionTimeline

  if self == self._actionTimeline then self._actionTimeline = nil end
  self._animationData = animationState.animationData
  self._frameRate = self._animationData.parent.frameRate
  self._frameRateR = 1.0 / self._frameRate
  self._position = animationState._position
  self._duration = animationState._duration

  if self._timelineData ~= nil then
    local dragonBonesData = self._animationData.parent.parent
    self._frameArray = dragonBonesData.frameArray
    self._timelineArray = dragonBonesData.timelineArray
    self._frameIndices = dragonBonesData.frameIndices
    local offset = self._timelineData.offset
    self._frameCount = at(self._timelineArray,offset+BO.TimelineKeyFrameCount)
    self._frameValueOffset = at(self._timelineArray,offset+BO.TimelineFrameValueOffset)
    self._timeScale = 100.0 / at(self._timelineArray,offset+BO.TimelineScale)
    self._timeOffset = at(self._timelineArray,offset+BO.TimelineOffset)*0.01
  end
end

function TimelineState:fadeOut()
  self.dirty = false
end

function TimelineState:update(passedTime)
  if self:_setCurrentTime(passedTime) then
    if self._frameCount > 1 then
      local timelineFrameIndex = math.floor(self.currentTime*self._frameRate)
      local frameIndex = at(self._frameIndices,
        self._timelineData.frameIndicesOffset+timelineFrameIndex)
      if self._frameIndex ~= frameIndex then
        self._frameIndex = frameIndex
        self._frameOffset = self._animationData.frameOffset
          + at(self._timelineArray,
            self._timelineData.offset+BO.TimelineFrameOffset+self._frameIndex)
        self:_onArriveAtFrame()
      end
    elseif self._frameIndex < 0 then
      self._frameIndex = 0
      if self._timelineData ~= nil then
        self._frameOffset = self._animationData.frameOffset
          + at(self._timelineArray,
            self._timelineData.offset+BO.TimelineFrameOffset)
      end
      self:_onArriveAtFrame()
    end

    if self._isTween or self.dirty then self:_onUpdateFrame() end
  end
end

function TimelineState:blend(_isDirty)
  -- Intentionally empty in the abstract original.
end

local TweenTimelineState = {}
TweenTimelineState.__index=TweenTimelineState
setmetatable(TweenTimelineState,{__index=TimelineState})

function TweenTimelineState.new(class)
  return TimelineState.new(class or TweenTimelineState)
end

function TweenTimelineState._getEasingValue(tweenType,progress,easing)
  local value=progress
  if tweenType==TweenType.QuadIn then
    value=progress^2
  elseif tweenType==TweenType.QuadOut then
    value=1.0-(1.0-progress)^2
  elseif tweenType==TweenType.QuadInOut then
    value=0.5*(1.0-math.cos(progress*math.pi))
  end
  return (value-progress)*easing+progress
end

function TweenTimelineState._getEasingCurveValue(progress,samples,count,offset)
  if progress<=0.0 then return 0.0 end
  if progress>=1.0 then return 1.0 end

  local isOmited=count>0 -- Original misspelling is preserved.
  local segmentCount=count+1
  local valueIndex=math.floor(progress*segmentCount)
  local fromValue,toValue=0.0,0.0
  if isOmited then
    fromValue=valueIndex==0 and 0.0 or at(samples,offset+valueIndex-1)
    toValue=valueIndex==segmentCount-1 and 10000.0
      or at(samples,offset+valueIndex)
  else
    fromValue=at(samples,offset+valueIndex-1)
    toValue=at(samples,offset+valueIndex)
  end
  fromValue,toValue=number(fromValue),number(toValue)
  return (fromValue+(toValue-fromValue)
    *(progress*segmentCount-valueIndex))*0.0001
end

function TweenTimelineState:_onClear()
  TimelineState._onClear(self)
  self._tweenType=TweenType.None
  self._curveCount=0
  self._framePosition=0.0
  self._frameDurationR=0.0
  self._tweenEasing=0.0
  self._tweenProgress=0.0
  self._valueScale=1.0
end

function TweenTimelineState:_onArriveAtFrame()
  if self._frameCount>1
      and (self._frameIndex~=self._frameCount-1
        or self._animationState.playTimes==0
        or self._animationState.currentPlayTimes
          < self._animationState.playTimes-1) then
    self._tweenType=at(self._frameArray,self._frameOffset+BO.FrameTweenType)
    self._isTween=self._tweenType~=TweenType.None
    if self._isTween then
      if self._tweenType==TweenType.Curve then
        self._curveCount=at(self._frameArray,
          self._frameOffset+BO.FrameTweenEasingOrCurveSampleCount)
      elseif self._tweenType~=TweenType.None
          and self._tweenType~=TweenType.Line then
        self._tweenEasing=at(self._frameArray,
          self._frameOffset+BO.FrameTweenEasingOrCurveSampleCount)*0.01
      end
    else
      self.dirty=true
    end

    self._framePosition=at(self._frameArray,self._frameOffset)*self._frameRateR
    if self._frameIndex==self._frameCount-1 then
      self._frameDurationR=1.0/(self._animationData.duration-self._framePosition)
    else
      local nextFrameOffset=self._animationData.frameOffset+
        at(self._timelineArray,
          self._timelineData.offset+BO.TimelineFrameOffset+self._frameIndex+1)
      local frameDuration=at(self._frameArray,nextFrameOffset)
        *self._frameRateR-self._framePosition
      if frameDuration>0 then
        self._frameDurationR=1.0/frameDuration
      else
        self._frameDurationR=0.0
      end
    end
  else
    self.dirty=true
    self._isTween=false
  end
end

function TweenTimelineState:_onUpdateFrame()
  if self._isTween then
    self.dirty=true
    self._tweenProgress=(self.currentTime-self._framePosition)
      *self._frameDurationR
    if self._tweenType==TweenType.Curve then
      self._tweenProgress=TweenTimelineState._getEasingCurveValue(
        self._tweenProgress,self._frameArray,self._curveCount,
        self._frameOffset+BO.FrameCurveSamples)
    elseif self._tweenType~=TweenType.Line then
      self._tweenProgress=TweenTimelineState._getEasingValue(
        self._tweenType,self._tweenProgress,self._tweenEasing)
    end
  end
end

local SingleValueTimelineState={}
SingleValueTimelineState.__index=SingleValueTimelineState
setmetatable(SingleValueTimelineState,{__index=TweenTimelineState})

function SingleValueTimelineState.new(class)
  return TweenTimelineState.new(class or SingleValueTimelineState)
end

function SingleValueTimelineState:_onClear()
  TweenTimelineState._onClear(self)
  self._current=0.0
  self._difference=0.0
  self._result=0.0
end

function SingleValueTimelineState:_onArriveAtFrame()
  TweenTimelineState._onArriveAtFrame(self)
  if self._timelineData~=nil then
    local scale=self._valueScale
    local values=self._valueArray
    local offset=self._valueOffset+self._frameValueOffset+self._frameIndex
    if self._isTween then
      local nextOffset=self._frameIndex==self._frameCount-1
        and (self._valueOffset+self._frameValueOffset) or (offset+1)
      if scale==1.0 then
        self._current=at(values,offset)
        self._difference=at(values,nextOffset)-self._current
      else
        self._current=at(values,offset)*scale
        self._difference=at(values,nextOffset)*scale-self._current
      end
    else
      self._result=at(values,offset)*scale
    end
  else
    self._result=0.0
  end
end

function SingleValueTimelineState:_onUpdateFrame()
  TweenTimelineState._onUpdateFrame(self)
  if self._isTween then
    self._result=self._current+self._difference*self._tweenProgress
  end
end

local DoubleValueTimelineState={}
DoubleValueTimelineState.__index=DoubleValueTimelineState
setmetatable(DoubleValueTimelineState,{__index=TweenTimelineState})

function DoubleValueTimelineState.new(class)
  return TweenTimelineState.new(class or DoubleValueTimelineState)
end

function DoubleValueTimelineState:_onClear()
  TweenTimelineState._onClear(self)
  self._currentA=0.0
  self._currentB=0.0
  self._differenceA=0.0
  self._differenceB=0.0
  self._resultA=0.0
  self._resultB=0.0
end

function DoubleValueTimelineState:_onArriveAtFrame()
  TweenTimelineState._onArriveAtFrame(self)
  if self._timelineData~=nil then
    local scale=self._valueScale
    local values=self._valueArray
    local offset=self._valueOffset+self._frameValueOffset+self._frameIndex*2
    if self._isTween then
      local nextOffset=self._frameIndex==self._frameCount-1
        and (self._valueOffset+self._frameValueOffset) or (offset+2)
      if scale==1.0 then
        self._currentA=at(values,offset)
        self._currentB=at(values,offset+1)
        self._differenceA=at(values,nextOffset)-self._currentA
        self._differenceB=at(values,nextOffset+1)-self._currentB
      else
        self._currentA=at(values,offset)*scale
        self._currentB=at(values,offset+1)*scale
        self._differenceA=at(values,nextOffset)*scale-self._currentA
        self._differenceB=at(values,nextOffset+1)*scale-self._currentB
      end
    else
      self._resultA=at(values,offset)*scale
      self._resultB=at(values,offset+1)*scale
    end
  else
    self._resultA=0.0
    self._resultB=0.0
  end
end

function DoubleValueTimelineState:_onUpdateFrame()
  TweenTimelineState._onUpdateFrame(self)
  if self._isTween then
    self._resultA=self._currentA+self._differenceA*self._tweenProgress
    self._resultB=self._currentB+self._differenceB*self._tweenProgress
  end
end

-- The spelling "Mutilple" belongs to the original DragonBonesJS API.
local MutilpleValueTimelineState={}
MutilpleValueTimelineState.__index=MutilpleValueTimelineState
setmetatable(MutilpleValueTimelineState,{__index=TweenTimelineState})

function MutilpleValueTimelineState.new(class)
  local object=TweenTimelineState.new(class or MutilpleValueTimelineState)
  object._rd=Array.new() -- Readonly array initializer in the original TypeScript.
  return object
end

function MutilpleValueTimelineState:_onClear()
  TweenTimelineState._onClear(self)
  self._valueCount=0
  clear(self._rd)
end

function MutilpleValueTimelineState:_onArriveAtFrame()
  TweenTimelineState._onArriveAtFrame(self)
  local count=self._valueCount
  local rd=self._rd
  if self._timelineData~=nil then
    local scale=self._valueScale
    local values=self._valueArray
    local offset=self._valueOffset+self._frameValueOffset+self._frameIndex*count
    if self._isTween then
      local nextOffset=self._frameIndex==self._frameCount-1
        and (self._valueOffset+self._frameValueOffset) or (offset+count)
      if scale==1.0 then
        for i=0,count-1 do
          rd[count+i+1]=at(values,nextOffset+i)-at(values,offset+i)
        end
      else
        for i=0,count-1 do
          rd[count+i+1]=(at(values,nextOffset+i)-at(values,offset+i))*scale
        end
      end
    elseif scale==1.0 then
      for i=0,count-1 do rd[i+1]=at(values,offset+i) end
    else
      for i=0,count-1 do rd[i+1]=at(values,offset+i)*scale end
    end
  else
    for i=0,count-1 do rd[i+1]=0.0 end
  end
end

function MutilpleValueTimelineState:_onUpdateFrame()
  TweenTimelineState._onUpdateFrame(self)
  if self._isTween then
    local count=self._valueCount
    local scale=self._valueScale
    local progress=self._tweenProgress
    local values=self._valueArray
    local rd=self._rd
    local offset=self._valueOffset+self._frameValueOffset+self._frameIndex*count
    if scale==1.0 then
      for i=0,count-1 do
        rd[i+1]=at(values,offset+i)+rd[count+i+1]*progress
      end
    else
      for i=0,count-1 do
        rd[i+1]=at(values,offset+i)*scale+rd[count+i+1]*progress
      end
    end
  end
end

return {
  TimelineState=TimelineState,
  TweenTimelineState=TweenTimelineState,
  SingleValueTimelineState=SingleValueTimelineState,
  DoubleValueTimelineState=DoubleValueTimelineState,
  MutilpleValueTimelineState=MutilpleValueTimelineState,
}
