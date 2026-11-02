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
    self._deformCount=#self.target.target._deformVertices
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

local AlphaTimelineState=klass("AlphaTimelineState",Single)
function AlphaTimelineState:_onArriveAtFrame()
  Single._onArriveAtFrame(self)
  if self._timelineData==nil then self._result=1.0 end
end
function AlphaTimelineState:init(a,s,d)
  Single.init(self,a,s,d)
  self._valueOffset=self._animationData.frameIntOffset
  self._valueScale=0.01
  self._valueArray=self._animationData.parent.parent.frameIntArray
end
function AlphaTimelineState:blend(isDirty)
  local blend=self.target
  local target=blend.target
  local weight=blend.blendWeight
  if blend.dirty>1 then
    target._alpha=target._alpha+self._result*weight
    if target._alpha>1.0 then target._alpha=1.0 end
  else
    target._alpha=self._result*weight
  end
  if isDirty or self.dirty then
    self.dirty=false
    self._armature._alphaDirty=true
  end
end

local SlotDisplayTimelineState=klass("SlotDisplayTimelineState",T)
function SlotDisplayTimelineState:_onArriveAtFrame()
  if self.playState>=0 then
    local slot=self.target
    local index=self._timelineData~=nil
      and at(self._frameArray,self._frameOffset+1)
      or slot._slotData.displayIndex
    if slot.displayIndex~=index then slot:_setDisplayIndex(index,true) end
  end
end
function SlotDisplayTimelineState:_onUpdateFrame() end

local SlotColorTimelineState=klass("SlotColorTimelineState",TW)
function SlotColorTimelineState.new()
  local o=TW.new(SlotColorTimelineState)
  o._current={0,0,0,0,0,0,0,0}
  o._difference={0,0,0,0,0,0,0,0}
  o._result={0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0}
  return o
end
function SlotColorTimelineState:_onArriveAtFrame()
  TW._onArriveAtFrame(self)
  if self._timelineData~=nil then
    local db=self._animationData.parent.parent
    local colors=db.colorArray
    local ints=db.frameIntArray
    local valueOffset=self._animationData.frameIntOffset+
      self._frameValueOffset+self._frameIndex
    local colorOffset=at(ints,valueOffset)
    if colorOffset<0 then colorOffset=colorOffset+65536 end
    if self._isTween then
      for i=0,7 do set(self._current,i,at(colors,colorOffset+i)) end
      if self._frameIndex==self._frameCount-1 then
        colorOffset=at(ints,self._animationData.frameIntOffset+self._frameValueOffset)
      else
        colorOffset=at(ints,valueOffset+1)
      end
      if colorOffset<0 then colorOffset=colorOffset+65536 end
      for i=0,7 do
        set(self._difference,i,at(colors,colorOffset+i)-at(self._current,i))
      end
    else
      for i=0,7 do
        local value=at(colors,colorOffset+i)
        set(self._result,i,i<4 and value*0.01 or value)
      end
    end
  else
    local color=self.target.slotData.color
    self._result[1]=color.alphaMultiplier
    self._result[2]=color.redMultiplier
    self._result[3]=color.greenMultiplier
    self._result[4]=color.blueMultiplier
    self._result[5]=color.alphaOffset
    self._result[6]=color.redOffset
    self._result[7]=color.greenOffset
    self._result[8]=color.blueOffset
  end
end
function SlotColorTimelineState:_onUpdateFrame()
  TW._onUpdateFrame(self)
  if self._isTween then
    for i=0,7 do
      local result=at(self._current,i)+at(self._difference,i)*self._tweenProgress
      set(self._result,i,i<4 and result*0.01 or result)
    end
  end
end
function SlotColorTimelineState:fadeOut()
  self._isTween=false
end
local colorFields={
  "alphaMultiplier","redMultiplier","greenMultiplier","blueMultiplier",
  "alphaOffset","redOffset","greenOffset","blueOffset"
}
function SlotColorTimelineState:update(passedTime)
  TW.update(self,passedTime)
  if self._isTween or self.dirty then
    local slot=self.target
    local result=slot._colorTransform
    local different=false
    for i,field in ipairs(colorFields) do
      if result[field]~=self._result[i] then different=true;break end
    end
    if self._animationState._fadeState~=0
      or self._animationState._subFadeState~=0 then
      if different then
        local fade=self._animationState._fadeProgress^4
        for i,field in ipairs(colorFields) do
          result[field]=result[field]+(self._result[i]-result[field])*fade
        end
        slot._colorDirty=true
      end
    elseif self.dirty then
      self.dirty=false
      if different then
        for i,field in ipairs(colorFields) do result[field]=self._result[i] end
        slot._colorDirty=true
      end
    end
  end
end

local SlotZIndexTimelineState=klass("SlotZIndexTimelineState",Single)
function SlotZIndexTimelineState:_onArriveAtFrame()
  Single._onArriveAtFrame(self)
  if self._timelineData==nil then
    self._result=self.target.target.slotData.zIndex
  end
end
function SlotZIndexTimelineState:init(a,s,d)
  Single.init(self,a,s,d)
  self._valueOffset=self._animationData.frameIntOffset
  self._valueArray=self._animationData.parent.parent.frameIntArray
end
function SlotZIndexTimelineState:blend(isDirty)
  local blend=self.target
  local slot=blend.target
  local weight=blend.blendWeight
  if blend.dirty>1 then
    slot._zIndex=slot._zIndex+self._result*weight
  else
    slot._zIndex=self._result*weight
  end
  if isDirty or self.dirty then
    self.dirty=false
    self._armature._zIndexDirty=true
  end
end
