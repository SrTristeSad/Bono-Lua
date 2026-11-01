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
