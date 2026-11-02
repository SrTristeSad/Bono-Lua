-- Original concrete TimelineState.ts classes.
-- Source: DragonBones/DragonBonesJS at
-- 64b6c69ae35777c2404be68c9192e2c56906079e
-- DragonBones/src/dragonBones/animation/TimelineState.ts (1075 lines).
-- MIT license: see LICENSE-DRAGONBONES.
-- The 16 original classes are exported below; abstract bases are imported
-- unchanged from BaseTimelineState.lua. Only zero-based array indexing is
-- translated to Lua's one-based tables.
local Pool=require("dragonbones.original.core.BaseObject")
local Core=require("dragonbones.original.core.DragonBones")
local Event=require("dragonbones.original.event.EventObject")
local Transform=require("dragonbones.original.geom.Transform")
local Base=require("dragonbones.original.animation.BaseTimelineState")
local BO=Core.BinaryOffset
local Action=Core.ActionType
local T=Base.TimelineState
local TW=Base.TweenTimelineState
local Single=Base.SingleValueTimelineState
local Double=Base.DoubleValueTimelineState
local Multi=Base.MutilpleValueTimelineState
local function at(a,i) return a[i+1] end
local function set(a,i,v) a[i+1]=v end
local function klass(name,parent)
  local c={}
  c.__index=c
  setmetatable(c,{__index=parent})
  c.toString=function() return "[class dragonBones."..name.."]" end
  c.new=function() return parent.new(c) end
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

local ZOrderTimelineState=klass("ZOrderTimelineState",T)
function ZOrderTimelineState:_onArriveAtFrame()
  if self.playState>=0 then
    local count=at(self._frameArray,self._frameOffset+1)
    if count>0 then
      -- Source hands the entire underlying frame array and a zero-based
      -- offset, not a sliced or transformed slot-index list.
      self._armature:_sortZOrder(self._frameArray,self._frameOffset+2)
    else
      self._armature:_sortZOrder(nil,0)
    end
  end
end
function ZOrderTimelineState:_onUpdateFrame() end

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
