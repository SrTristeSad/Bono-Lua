-- ActionTimelineState, TimelineState.ts.
-- DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e; MIT.
local Pool=require('dragonbones.core.BaseObject')
local Core=require('dragonbones.core.Enums')
local Event=require('dragonbones.event.EventObject')
local T=require('dragonbones.animation.BaseTimelineState').TimelineState
local BO,Action=Core.BinaryOffset,Core.ActionType
local function at(a,i)
  local value=a[i+1]
  if value==nil then return 0/0 end -- Undefined numeric reads propagate as NaN.
  return value
end
local function klass(name,parent)
  local c={};c.__index=c;setmetatable(c,{__index=parent})
  c.toString=function()return '[class dragonBones.'..name..']'end
  c.new=function()return parent.new(c)end
  return c
end
local ActionTimelineState=klass("ActionTimelineState",T)
function ActionTimelineState:_onCrossFrame(frameIndex)
  local dispatcher=self._armature.eventDispatcher
  if self._animationState.actionEnabled then
    local frameOffset=self._animationData.frameOffset+
      at(self._timelineArray,self._timelineData.offset+BO.TimelineFrameOffset+frameIndex)
    local count=at(self._frameArray,frameOffset+1)
    local actions=self._animationData.parent.actions
    for i=0,count-1 do
      local idx=at(self._frameArray,frameOffset+2+i)
      local action=at(actions,idx)
      if action.type==Action.Play then
        local obj=Pool.borrowObject(Event)
        obj.time=at(self._frameArray,frameOffset)/self._frameRate
        obj.animationState=self._animationState
        Event.actionDataToInstance(action,obj,self._armature)
        self._armature:_bufferAction(obj,true)
      else
        local kind=action.type==Action.Frame and Event.FRAME_EVENT
          or Event.SOUND_EVENT
        if action.type==Action.Sound or dispatcher:hasDBEventListener(kind) then
          local obj=Pool.borrowObject(Event)
          obj.time=at(self._frameArray,frameOffset)/self._frameRate
          obj.animationState=self._animationState
          Event.actionDataToInstance(action,obj,self._armature)
          self._armature._dragonBones:bufferEvent(obj)
        end
      end
    end
  end
end
function ActionTimelineState:_onArriveAtFrame() end
function ActionTimelineState:_onUpdateFrame() end
local function bufferEvent(self,typeName)
  local obj=Pool.borrowObject(Event)
  obj.type=typeName
  obj.armature=self._armature
  obj.animationState=self._animationState
  return obj
end
function ActionTimelineState:update(passedTime)
  local prevState=self.playState
  local prevPlayTimes=self.currentPlayTimes
  local prevTime=self.currentTime
  if self:_setCurrentTime(passedTime) then
    local active=self._animationState._parent==nil
      and self._animationState.actionEnabled
    local dispatcher=self._armature.eventDispatcher
    if prevState<0 then
      if self.playState~=prevState then
        if self._animationState.displayControl
          and self._animationState.resetToPose then
          self._armature:_sortZOrder(nil,0)
        end
        if active and dispatcher:hasDBEventListener(Event.START) then
          self._armature._dragonBones:bufferEvent(bufferEvent(self,Event.START))
        end
      else
        return
      end
    end
    local reverse=self._animationState.timeScale<0.0
    local loopEvent=nil
    local completeEvent=nil
    if active and self.currentPlayTimes~=prevPlayTimes then
      if dispatcher:hasDBEventListener(Event.LOOP_COMPLETE) then
        loopEvent=bufferEvent(self,Event.LOOP_COMPLETE)
      end
      if self.playState>0 and dispatcher:hasDBEventListener(Event.COMPLETE) then
        completeEvent=bufferEvent(self,Event.COMPLETE)
      end
    end
    if self._frameCount>1 then
      local data=self._timelineData
      local frameIndex=at(self._frameIndices,
        data.frameIndicesOffset+math.floor(self.currentTime*self._frameRate))
      if self._frameIndex~=frameIndex then
        local crossed=self._frameIndex
        self._frameIndex=frameIndex
        if self._timelineArray~=nil then
          self._frameOffset=self._animationData.frameOffset+
            at(self._timelineArray,data.offset+BO.TimelineFrameOffset+self._frameIndex)
          if reverse then
            if crossed<0 then
              crossed=at(self._frameIndices,
                data.frameIndicesOffset+math.floor(prevTime*self._frameRate))
              if self.currentPlayTimes==prevPlayTimes and crossed==frameIndex then
                crossed=-1
              end
            end
            while crossed>=0 do
              local offset=self._animationData.frameOffset+
                at(self._timelineArray,data.offset+BO.TimelineFrameOffset+crossed)
              local pos=at(self._frameArray,offset)/self._frameRate
              if self._position<=pos and pos<=self._position+self._duration then
                self:_onCrossFrame(crossed)
              end
              if loopEvent~=nil and crossed==0 then
                self._armature._dragonBones:bufferEvent(loopEvent)
                loopEvent=nil
              end
              crossed=crossed>0 and crossed-1 or self._frameCount-1
              if crossed==frameIndex then break end
            end
          else
            if crossed<0 then
              crossed=at(self._frameIndices,
                data.frameIndicesOffset+math.floor(prevTime*self._frameRate))
              local offset=self._animationData.frameOffset+
                at(self._timelineArray,data.offset+BO.TimelineFrameOffset+crossed)
              local pos=at(self._frameArray,offset)/self._frameRate
              if self.currentPlayTimes==prevPlayTimes then
                if prevTime<=pos then
                  crossed=crossed>0 and crossed-1 or self._frameCount-1
                elseif crossed==frameIndex then crossed=-1 end
              end
            end
            while crossed>=0 do
              crossed=crossed<self._frameCount-1 and crossed+1 or 0
              local offset=self._animationData.frameOffset+
                at(self._timelineArray,data.offset+BO.TimelineFrameOffset+crossed)
              local pos=at(self._frameArray,offset)/self._frameRate
              if self._position<=pos and pos<=self._position+self._duration then
                self:_onCrossFrame(crossed)
              end
              if loopEvent~=nil and crossed==0 then
                self._armature._dragonBones:bufferEvent(loopEvent)
                loopEvent=nil
              end
              if crossed==frameIndex then break end
            end
          end
        end
      end
    elseif self._frameIndex<0 then
      self._frameIndex=0
      if self._timelineData~=nil then
        self._frameOffset=self._animationData.frameOffset+
          at(self._timelineArray,self._timelineData.offset+BO.TimelineFrameOffset)
        local pos=at(self._frameArray,self._frameOffset)/self._frameRate
        if self.currentPlayTimes==prevPlayTimes then
          if prevTime<=pos then self:_onCrossFrame(self._frameIndex) end
        elseif self._position<=pos then
          if not reverse and loopEvent~=nil then
            self._armature._dragonBones:bufferEvent(loopEvent)
            loopEvent=nil
          end
          self:_onCrossFrame(self._frameIndex)
        end
      end
    end
    if loopEvent~=nil then self._armature._dragonBones:bufferEvent(loopEvent) end
    if completeEvent~=nil then
      self._armature._dragonBones:bufferEvent(completeEvent)
    end
  end
end
function ActionTimelineState:setCurrentTime(value)
  self:_setCurrentTime(value)
  self._frameIndex=-1
end

return ActionTimelineState
