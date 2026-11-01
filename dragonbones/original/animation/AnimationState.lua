-- Port of AnimationState, first class of DragonBones/src/dragonBones/animation/AnimationState.ts.
-- DragonBonesJS source commit 64b6c69ae35777c2404be68c9192e2c56906079e.
-- Copyright (c) 2012-2025 DragonBones team and other contributors.
-- MIT license: see LICENSE-DRAGONBONES.
--
-- BlendState is the other original class in that file and was separately
-- ported in BlendState.lua. TimelineState.ts and BaseTimelineState.ts are
-- original dependencies; they are required when the corresponding timelines
-- are constructed. No alternate timeline implementations are shipped.
local BaseObject=require("dragonbones.original.core.BaseObject")
local Core=require("dragonbones.original.core.DragonBones")
local BlendState=require("dragonbones.original.animation.BlendState")
local EventObject=require("dragonbones.original.event.EventObject")
local Type=Core.TimelineType
local Binary=Core.BinaryOffset

local AnimationState={}
setmetatable(AnimationState,{__index=BaseObject})
local function has(t,v)
  for _,item in ipairs(t) do if item==v then return true end end
  return false
end
local function indexOf(t,v)
  for i,item in ipairs(t) do if item==v then return i end end
  return nil
end
local function clear(t)
  for i=#t,1,-1 do t[i]=nil end
end
local function erase(t,v)
  local i=indexOf(t,v)
  if i~=nil then table.remove(t,i);return true end
  return false
end
local function addMap(map,key,item)
  if map[key]==nil then map[key]={} end
  map[key][#map[key]+1]=item
end
local function timelineClass(name)
  -- These names are the real exported classes of the pinned TimelineState.ts.
  local m=require("dragonbones.original.animation.TimelineState")
  local class=m[name]
  if class==nil then error("Missing original TimelineState class: "..name) end
  return class
end
local function borrowTimeline(name,target,armature,state,data,into,pose)
  local timeline=BaseObject.borrowObject(timelineClass(name))
  if target~=nil then timeline.target=target end
  timeline:init(armature,state,data)
  into[#into+1]=timeline
  if pose~=nil then pose[#pose+1]=timeline end
  return timeline
end
local function isArrayEmpty(a) return #a==0 end
local function bitAnd1(a) return a%2 end
local function bitAnd2(a) return math.floor(a/2)%2*2 end
local function bitOr1(a) return (a%2==1) and a or a+1 end
local function signedRemainder(x,y) return math.fmod(x,y) end
local function getZeroBased(a,index) return a[index+1] end

function AnimationState.toString()
  return "[class dragonBones.AnimationState]"
end
function AnimationState.new()
  local self=BaseObject.new(AnimationState)
  self._boneMask={}
  self._boneTimelines={}
  self._boneBlendTimelines={}
  self._slotTimelines={}
  self._slotBlendTimelines={}
  self._constraintTimelines={}
  self._animationTimelines={}
  self._poseTimelines={}
  return self
end

function AnimationState.__index(self,key)
  if key=="isFadeIn" then return self._fadeState<0 end
  if key=="isFadeOut" then return self._fadeState>0 end
  if key=="isFadeComplete" then return self._fadeState==0 end
  if key=="isPlaying" then
    return bitAnd2(self._playheadState)~=0 and self._actionTimeline.playState<=0
  end
  if key=="isCompleted" then return self._actionTimeline.playState>0 end
  if key=="currentPlayTimes" then return self._actionTimeline.currentPlayTimes end
  if key=="totalTime" then return self._duration end
  if key=="currentTime" then return self._actionTimeline.currentTime end
  if key=="weight" then return self._weight end
  if key=="animationData" then return self._animationData end
  return rawget(AnimationState,key) or BaseObject[key]
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
  for _,timeline in ipairs(self._boneTimelines) do timeline.playState=-1 end
  for _,timeline in ipairs(self._slotTimelines) do timeline.playState=-1 end
end
local function setWeight(self,value)
  if self._weight==value then return end
  self._weight=value
  for _,timeline in ipairs(self._boneTimelines) do timeline.dirty=true end
  for _,timeline in ipairs(self._boneBlendTimelines) do timeline.dirty=true end
  for _,timeline in ipairs(self._slotBlendTimelines) do timeline.dirty=true end
end
function AnimationState.__newindex(self,key,value)
  if key=="currentTime" then setCurrentTime(self,value)
  elseif key=="weight" then setWeight(self,value)
  else rawset(self,key,value) end
end

function AnimationState:_onClear()
  for _,timeline in ipairs(self._boneTimelines) do timeline:returnToPool() end
  for _,timeline in ipairs(self._boneBlendTimelines) do timeline:returnToPool() end
  for _,timeline in ipairs(self._slotTimelines) do timeline:returnToPool() end
  for _,timeline in ipairs(self._slotBlendTimelines) do timeline:returnToPool() end
  for _,timeline in ipairs(self._constraintTimelines) do timeline:returnToPool() end
  for _,timeline in ipairs(self._animationTimelines) do
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

function AnimationState:_updateTimelines()
  for _,constraint in ipairs(self._armature._constraints) do
    local data=self._animationData:getConstraintTimelines(constraint.name)
    if data~=nil then
      for _,entry in ipairs(data) do
        if entry.type==Type.IKConstraint then
          borrowTimeline("IKConstraintTimelineState",constraint,self._armature,self,entry,self._constraintTimelines)
        end
      end
    elseif self.resetToPose then
      borrowTimeline("IKConstraintTimelineState",constraint,self._armature,self,nil,
        self._constraintTimelines,self._poseTimelines)
    end
  end
end

function AnimationState:_updateBoneAndSlotTimelines()
  do
    local existing={}
    for _,timeline in ipairs(self._boneTimelines) do
      addMap(existing,timeline.target.target.name,timeline)
    end
    for _,timeline in ipairs(self._boneBlendTimelines) do
      addMap(existing,timeline.target.target.name,timeline)
    end
    for _,bone in ipairs(self._armature:getBones()) do
      local name=bone.name
      if self:containsBoneMask(name) then
        if existing[name]~=nil then
          existing[name]=nil
        else
          local datas=self._animationData:getBoneTimelines(name)
          local blend=self._armature.animation:getBlendState(BlendState.BONE_TRANSFORM,name,bone)
          if datas~=nil then
            for _,data in ipairs(datas) do
              local clazz={
                [Type.BoneAll]="BoneAllTimelineState",
                [Type.BoneTranslate]="BoneTranslateTimelineState",
                [Type.BoneRotate]="BoneRotateTimelineState",
                [Type.BoneScale]="BoneScaleTimelineState",
              }
              local nameOfClass=clazz[data.type]
              if nameOfClass~=nil then
                borrowTimeline(nameOfClass,blend,self._armature,self,data,self._boneTimelines)
              elseif data.type==Type.BoneAlpha then
                borrowTimeline("AlphaTimelineState",
                  self._armature.animation:getBlendState(BlendState.BONE_ALPHA,name,bone),
                  self._armature,self,data,self._boneBlendTimelines)
              elseif data.type==Type.Surface then
                borrowTimeline("SurfaceTimelineState",
                  self._armature.animation:getBlendState(BlendState.SURFACE,name,bone),
                  self._armature,self,data,self._boneBlendTimelines)
              end
            end
          elseif self.resetToPose then
            if bone._boneData.type==Core.BoneType.Bone then
              borrowTimeline("BoneAllTimelineState",blend,self._armature,self,nil,
                self._boneTimelines,self._poseTimelines)
            else
              borrowTimeline("SurfaceTimelineState",
                self._armature.animation:getBlendState(BlendState.SURFACE,name,bone),
                self._armature,self,nil,self._boneBlendTimelines,self._poseTimelines)
            end
          end
        end
      end
    end
    for _,group in pairs(existing) do
      for _,timeline in ipairs(group) do
        if erase(self._boneTimelines,timeline) then
          timeline:returnToPool()
        end
        if erase(self._boneBlendTimelines,timeline) then
          timeline:returnToPool()
        end
      end
    end
  end

  do
    local existing={}
    local ffdFlags={}
    for _,timeline in ipairs(self._slotTimelines) do
      addMap(existing,timeline.target.name,timeline)
    end
    for _,timeline in ipairs(self._slotBlendTimelines) do
      addMap(existing,timeline.target.target.name,timeline)
    end
    for _,slot in ipairs(self._armature:getSlots()) do
      if self:containsBoneMask(slot.parent.name) then
        local name=slot.name
        if existing[name]~=nil then
          existing[name]=nil
        else
          local displayIndexFlag=false
          local colorFlag=false
          clear(ffdFlags)
          local datas=self._animationData:getSlotTimelines(name)
          if datas~=nil then
            for _,data in ipairs(datas) do
              if data.type==Type.SlotDisplay then
                borrowTimeline("SlotDisplayTimelineState",slot,self._armature,self,data,self._slotTimelines)
                displayIndexFlag=true
              elseif data.type==Type.SlotZIndex then
                borrowTimeline("SlotZIndexTimelineState",
                  self._armature.animation:getBlendState(BlendState.SLOT_Z_INDEX,name,slot),
                  self._armature,self,data,self._slotBlendTimelines)
              elseif data.type==Type.SlotColor then
                borrowTimeline("SlotColorTimelineState",slot,self._armature,self,data,self._slotTimelines)
                colorFlag=true
              elseif data.type==Type.SlotDeform then
                local db=self._animationData.parent.parent
                local intOffset=self._animationData.frameIntOffset+
                  getZeroBased(db.timelineArray,data.offset+Binary.TimelineFrameValueCount)
                local geometryOffset=getZeroBased(db.frameIntArray,intOffset+Binary.DeformVertexOffset)
                if geometryOffset<0 then geometryOffset=geometryOffset+65536 end
                for i=0,slot.displayFrameCount-1 do
                  local frame=slot:getDisplayFrameAt(i)
                  local geometry=frame:getGeometryData()
                  if geometry~=nil and geometry.offset==geometryOffset then
                    local timeline=borrowTimeline("DeformTimelineState",
                      self._armature.animation:getBlendState(
                        BlendState.SLOT_DEFORM,frame.rawDisplayData.name,slot),
                      self._armature,self,data,self._slotBlendTimelines)
                    timeline.displayFrame=frame
                    -- TS sets displayFrame before calling init(); see note below.
                    frame:updateDeformVertices()
                    ffdFlags[#ffdFlags+1]=geometryOffset
                    break
                  end
                end
              elseif data.type==Type.SlotAlpha then
                borrowTimeline("AlphaTimelineState",
                  self._armature.animation:getBlendState(BlendState.SLOT_ALPHA,name,slot),
                  self._armature,self,data,self._slotBlendTimelines)
              end
            end
          end
          if self.resetToPose then
            if not displayIndexFlag then
              borrowTimeline("SlotDisplayTimelineState",slot,self._armature,self,nil,
                self._slotTimelines,self._poseTimelines)
            end
            if not colorFlag then
              borrowTimeline("SlotColorTimelineState",slot,self._armature,self,nil,
                self._slotTimelines,self._poseTimelines)
            end
            for i=0,slot.displayFrameCount-1 do
              local frame=slot:getDisplayFrameAt(i)
              if #frame.deformVertices>0 then
                local geometry=frame:getGeometryData()
                if geometry~=nil and not has(ffdFlags,geometry.offset) then
                  local timeline=borrowTimeline("DeformTimelineState",
                    self._armature.animation:getBlendState(BlendState.SLOT_DEFORM,name,slot),
                    self._armature,self,nil,self._slotBlendTimelines,self._poseTimelines)
                  timeline.displayFrame=frame
                end
              end
            end
          end
        end
      end
    end
    for _,group in pairs(existing) do
      for _,timeline in ipairs(group) do
        if erase(self._slotTimelines,timeline) then
          timeline:returnToPool()
        end
        if erase(self._slotBlendTimelines,timeline) then
          timeline:returnToPool()
        end
      end
    end
  end
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

  if #config.boneMask>0 then
    for i,name in ipairs(config.boneMask) do self._boneMask[i]=name end
  end

  self._actionTimeline=borrowTimeline("ActionTimelineState",nil,
    armature,self,animationData.actionTimeline,self._poseTimelines)
  -- In the source ActionTimelineState is not a pose timeline: remove from
  -- the temporary destination without recycling, preserving ownership.
  self._poseTimelines[#self._poseTimelines]=nil
  self._actionTimeline.currentTime=self._time
  if self._actionTimeline.currentTime<0.0 then
    self._actionTimeline.currentTime=
      self._duration-self._actionTimeline.currentTime
  end
  if animationData.zOrderTimeline~=nil then
    local holder={}
    self._zOrderTimeline=borrowTimeline("ZOrderTimelineState",nil,
      armature,self,animationData.zOrderTimeline,holder)
  end
end

function AnimationState:advanceTime(passedTime,cacheFrameRate)
  if self._fadeState~=0 or self._subFadeState~=0 then
    self:_advanceFadeTime(passedTime)
  end
  if self._playheadState==3 then
    if self.timeScale~=1.0 then passedTime=passedTime*self.timeScale end
    self._time=self._time+passedTime
  end

  if self._timelineDirty~=0 then
    if self._timelineDirty==2 then self:_updateTimelines() end
    self._timelineDirty=0
    self:_updateBoneAndSlotTimelines()
  end

  local isBlendDirty=self._fadeState~=0 or self._subFadeState==0
  local isCacheEnabled=self._fadeState==0 and cacheFrameRate>0.0
  local isUpdateTimeline=true
  local isUpdateBoneTimeline=true
  local time=self._time
  self._weightResult=self._weight*self._fadeProgress
  if self._parent~=nil then
    self._weightResult=self._weightResult*self._parent._weightResult
  end

  if self._actionTimeline.playState<=0 then
    self._actionTimeline:update(time)
  end
  if self._weight==0.0 then return end

  if isCacheEnabled then
    local interval=cacheFrameRate*2.0
    self._actionTimeline.currentTime=
      math.floor(self._actionTimeline.currentTime*interval)/interval
  end
  if self._zOrderTimeline~=nil and self._zOrderTimeline.playState<=0 then
    self._zOrderTimeline:update(time)
  end

  if isCacheEnabled then
    local cacheIndex=math.floor(self._actionTimeline.currentTime*cacheFrameRate)
    if self._armature._cacheFrameIndex==cacheIndex then
      isUpdateTimeline=false
      isUpdateBoneTimeline=false
    else
      self._armature._cacheFrameIndex=cacheIndex
      if self._animationData.cachedFrames[cacheIndex+1] then
        isUpdateBoneTimeline=false
      else
        self._animationData.cachedFrames[cacheIndex+1]=true
      end
    end
  end

  if isUpdateTimeline then
    local blended=false
    local previous=nil
    if isUpdateBoneTimeline then
      for _,timeline in ipairs(self._boneTimelines) do
        if timeline.playState<=0 then timeline:update(time) end
        if timeline.target~=previous then
          local blend=timeline.target
          blended=blend:update(self)
          previous=blend
          if blend.dirty==1 then
            local pose=blend.target.animationPose
            pose.x=0.0;pose.y=0.0
            pose.rotation=0.0;pose.skew=0.0
            pose.scaleX=1.0;pose.scaleY=1.0
          end
        end
        if blended then timeline:blend(isBlendDirty) end
      end
    end
    for _,timeline in ipairs(self._boneBlendTimelines) do
      if timeline.playState<=0 then timeline:update(time) end
      if timeline.target:update(self) then timeline:blend(isBlendDirty) end
    end
    if self.displayControl then
      for _,timeline in ipairs(self._slotTimelines) do
        if timeline.playState<=0 then
          local slot=timeline.target
          local controller=slot.displayController
          if controller==nil or controller==self.name or controller==self.group then
            timeline:update(time)
          end
        end
      end
    end
    for _,timeline in ipairs(self._slotBlendTimelines) do
      if timeline.playState<=0 then
        timeline:update(time)
        if timeline.target:update(self) then timeline:blend(isBlendDirty) end
      end
    end
    for _,timeline in ipairs(self._constraintTimelines) do
      if timeline.playState<=0 then timeline:update(time) end
    end

    if #self._animationTimelines>0 then
      local dL,dR=100.0,100.0
      local left,right=nil,nil
      for _,timeline in ipairs(self._animationTimelines) do
        if timeline.playState<=0 then timeline:update(time) end
        if self.blendType==Core.AnimationBlendType.E1D then
          local child=timeline.target
          local d=self.parameterX-child.positionX
          if d>=0 then
            if d<dL then dL=d;left=child end
          else
            if -d<dR then dR=-d;right=child end
          end
        end
      end
      if left~=nil then
        if self._activeChildA~=left then
          if self._activeChildA~=nil then self._activeChildA.weight=0.0 end
          self._activeChildA=left
          self._activeChildA:activeTimeline()
        end
        if self._activeChildB~=right then
          if self._activeChildB~=nil then self._activeChildB.weight=0.0 end
          self._activeChildB=right
        end
        left.weight=dR/(dL+dR)
        if right~=nil then right.weight=1.0-left.weight end
      end
    end
  end

  if self._fadeState==0 then
    if self._subFadeState>0 then
      self._subFadeState=0
      if #self._poseTimelines>0 then
        for _,timeline in ipairs(self._poseTimelines) do
          if erase(self._boneTimelines,timeline)
             or erase(self._boneBlendTimelines,timeline)
             or erase(self._slotTimelines,timeline)
             or erase(self._slotBlendTimelines,timeline)
             or erase(self._constraintTimelines,timeline) then
            timeline:returnToPool()
          end
        end
        clear(self._poseTimelines)
      end
    end
    if self._actionTimeline.playState>0 and self.autoFadeOutTime>=0.0 then
      self:fadeOut(self.autoFadeOutTime)
    end
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
    for _,timeline in ipairs(self._boneTimelines) do timeline:fadeOut() end
    for _,timeline in ipairs(self._boneBlendTimelines) do timeline:fadeOut() end
    for _,timeline in ipairs(self._slotTimelines) do timeline:fadeOut() end
    for _,timeline in ipairs(self._slotBlendTimelines) do timeline:fadeOut() end
    for _,timeline in ipairs(self._constraintTimelines) do timeline:fadeOut() end
    for _,timeline in ipairs(self._animationTimelines) do
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
  return #self._boneMask==0 or has(self._boneMask,name)
end

function AnimationState:addBoneMask(name,recursive)
  if recursive==nil then recursive=true end
  local currentBone=self._armature:getBone(name)
  if currentBone==nil then return end
  if not has(self._boneMask,name) then
    self._boneMask[#self._boneMask+1]=name
  end
  if recursive then
    for _,bone in ipairs(self._armature:getBones()) do
      if not has(self._boneMask,bone.name) and currentBone:contains(bone) then
        self._boneMask[#self._boneMask+1]=bone.name
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
      if #self._boneMask>0 then
        for _,bone in ipairs(bones) do
          if has(self._boneMask,bone.name) and currentBone:contains(bone) then
            erase(self._boneMask,bone.name)
          end
        end
      else
        for _,bone in ipairs(bones) do
          if bone~=currentBone and not currentBone:contains(bone) then
            self._boneMask[#self._boneMask+1]=bone.name
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
    for _,data in ipairs(timelineDatas) do
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
  for _,timeline in ipairs(self._slotTimelines) do
    timeline.dirty=true
    timeline.currentTime=-1.0
  end
end

return AnimationState
