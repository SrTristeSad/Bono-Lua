-- Port of DragonBones/src/dragonBones/animation/Animation.ts (960 lines).
-- Source: DragonBonesJS commit 64b6c69ae35777c2404be68c9192e2c56906079e.
-- Copyright (c) 2012-2025 DragonBones team and other contributors.
-- MIT license: see LICENSE-DRAGONBONES.
-- AnimationState and BlendState are separate classes declared in the SAME
-- original AnimationState.ts file. BlendState.lua is now ported; the full
-- AnimationState class remains a deferred dependency of playConfig().
local BaseObject=require("dragonbones.original.core.BaseObject")
local Core=require("dragonbones.original.core.DragonBones")
local Config=require("dragonbones.original.model.AnimationConfig")
local Mode=Core.AnimationFadeOutMode
local Animation={}
Animation.__index=function(self,key)
  if key=="isPlaying" then
    for _,state in ipairs(self._animationStates) do
      if state.isPlaying then return true end
    end
    return false
  end
  if key=="isCompleted" then
    for _,state in ipairs(self._animationStates) do
      if not state.isCompleted then return false end
    end
    return #self._animationStates>0
  end
  if key=="lastAnimationName" then
    return self._lastAnimationState~=nil and self._lastAnimationState.name or ""
  end
  if key=="animationNames" then return self._animationNames end
  if key=="animations" then return self._animations end
  if key=="animationConfig" then
    self._animationConfig:clear()
    return self._animationConfig
  end
  if key=="lastAnimationState" then return self._lastAnimationState end
  return rawget(Animation,key) or BaseObject[key]
end
Animation.__newindex=function(self,key,value)
  if key=="animations" then
    -- Source copies enumerable keys into existing map and keeps its identity.
    if self._animations==value then return end
    for i=#self._animationNames,1,-1 do self._animationNames[i]=nil end
    for name in pairs(self._animations) do self._animations[name]=nil end
    for name,data in pairs(value) do
      self._animationNames[#self._animationNames+1]=name
      self._animations[name]=data
    end
  else rawset(self,key,value) end
end
setmetatable(Animation,{__index=BaseObject})

local function clearArray(a)
  for i=#a,1,-1 do a[i]=nil end
end
local function clearMap(map)
  for k in pairs(map) do map[k]=nil end
end
local function indexOf(a,item)
  for i,v in ipairs(a) do if v==item then return i end end
  return nil
end
local function jsMod(a,b) return math.fmod(a,b) end

function Animation.toString() return "[class dragonBones.Animation]" end

function Animation.new()
  local self=BaseObject.new(Animation)
  self._animationNames={}
  self._animationStates={}
  self._animations={}
  self._blendStates={}
  return self
end

function Animation:_onClear()
  for _,state in ipairs(self._animationStates) do state:returnToPool() end
  clearMap(self._animations)
  for k,states in pairs(self._blendStates) do
    for _,blend in pairs(states) do blend:returnToPool() end
    self._blendStates[k]=nil
  end
  if self._animationConfig~=nil then self._animationConfig:returnToPool() end
  self.timeScale=1.0
  self._animationDirty=false
  self._inheritTimeScale=1.0
  clearArray(self._animationNames)
  clearArray(self._animationStates)
  self._armature=nil
  self._animationConfig=nil
  self._lastAnimationState=nil
end

function Animation:_fadeOut(animationConfig)
  local mode=animationConfig.fadeOutMode
  if mode==Mode.Single or mode==Core.AnimationFadeOutMode.None then return end
  for _,state in ipairs(self._animationStates) do
    if state._parent==nil then
      local match=mode==Mode.All
        or (mode==Mode.SameLayer and state.layer==animationConfig.layer)
        or (mode==Mode.SameGroup and state.group==animationConfig.group)
        or (mode==Mode.SameLayerAndGroup
          and state.layer==animationConfig.layer and state.group==animationConfig.group)
      if match then state:fadeOut(animationConfig.fadeOutTime,animationConfig.pauseFadeOut) end
    end
  end
end

function Animation:init(armature)
  if self._armature~=nil then return end
  self._armature=armature
  self._animationConfig=BaseObject.borrowObject(Config)
end

function Animation:advanceTime(passedTime)
  if passedTime<0.0 then passedTime=-passedTime end
  if self._armature.inheritAnimation and self._armature._parent~=nil then
    self._inheritTimeScale=
      self._armature._parent._armature.animation._inheritTimeScale*self.timeScale
  else
    self._inheritTimeScale=self.timeScale
  end
  if self._inheritTimeScale~=1.0 then
    passedTime=passedTime*self._inheritTimeScale
  end
  for _,blendStates in pairs(self._blendStates) do
    for _,blend in pairs(blendStates) do blend:reset() end
  end
  local count=#self._animationStates
  if count==1 then
    local state=self._animationStates[1]
    if state._fadeState>0 and state._subFadeState>0 then
      self._armature._dragonBones:bufferObject(state)
      clearArray(self._animationStates)
      self._lastAnimationState=nil
    else
      local data=state.animationData
      local cacheRate=data.cacheFrameRate
      if self._animationDirty and cacheRate>0.0 then
        self._animationDirty=false
        for _,bone in ipairs(self._armature:getBones()) do
          bone._cachedFrameIndices=data:getBoneCachedFrameIndices(bone.name)
        end
        for _,slot in ipairs(self._armature:getSlots()) do
          if slot.displayFrameCount>0 then
            local raw=slot:getDisplayFrameAt(0).rawDisplayData
            if raw~=nil and raw.parent==self._armature.armatureData.defaultSkin then
              slot._cachedFrameIndices=data:getSlotCachedFrameIndices(slot.name)
            else
              slot._cachedFrameIndices=nil
            end
          else
            slot._cachedFrameIndices=nil
          end
        end
      end
      state:advanceTime(passedTime,cacheRate)
    end
  elseif count>1 then
    local removed=0
    for i=1,count do
      local state=self._animationStates[i]
      if state._fadeState>0 and state._subFadeState>0 then
        removed=removed+1
        self._armature._dragonBones:bufferObject(state)
        self._animationDirty=true
        if self._lastAnimationState==state then self._lastAnimationState=nil end
      else
        if removed>0 then self._animationStates[i-removed]=state end
        state:advanceTime(passedTime,0.0)
      end
      if i==count and removed>0 then
        for j=count,count-removed+1,-1 do self._animationStates[j]=nil end
        if self._lastAnimationState==nil and #self._animationStates>0 then
          self._lastAnimationState=self._animationStates[#self._animationStates]
        end
      end
    end
    self._armature._cacheFrameIndex=-1
  else
    self._armature._cacheFrameIndex=-1
  end
end

function Animation:reset()
  for _,state in ipairs(self._animationStates) do state:returnToPool() end
  self._animationDirty=false
  self._animationConfig:clear()
  clearArray(self._animationStates)
  self._lastAnimationState=nil
end

function Animation:stop(animationName)
  if animationName~=nil then
    local state=self:getState(animationName)
    if state~=nil then state:stop() end
  else
    for _,state in ipairs(self._animationStates) do state:stop() end
  end
end

function Animation:playConfig(config)
  local name=config.animation
  if self._animations[name]==nil then
    io.stderr:write("Non-existent animation.\nDragonBones name: "
      ..tostring(self._armature.armatureData.parent.name)
      .." Armature name: "..tostring(self._armature.name)
      .." Animation name: "..tostring(name).."\n")
    return nil
  end
  local data=self._animations[name]
  if config.fadeOutMode==Mode.Single then
    for _,state in ipairs(self._animationStates) do
      if state._fadeState<1 and state.layer==config.layer
          and state.animationData==data then
        return state
      end
    end
  end
  if #self._animationStates==0 then
    config.fadeInTime=0.0
  elseif config.fadeInTime<0.0 then
    config.fadeInTime=data.fadeInTime
  end
  if config.fadeOutTime<0.0 then config.fadeOutTime=config.fadeInTime end
  if config.timeScale<=-100.0 then config.timeScale=1.0/data.scale end
  if data.frameCount>0 then
    if config.position<0.0 then
      config.position=jsMod(config.position,data.duration)
      config.position=data.duration-config.position
    elseif config.position==data.duration then
      config.position=config.position-0.000001
    elseif config.position>data.duration then
      config.position=jsMod(config.position,data.duration)
    end
    if config.duration>0.0 and config.position+config.duration>data.duration then
      config.duration=data.duration-config.position
    end
    if config.playTimes<0 then config.playTimes=data.playTimes end
  else
    config.playTimes=1
    config.position=0.0
    if config.duration>0.0 then config.duration=0.0 end
  end
  if config.duration==0.0 then config.duration=-1.0 end

  self:_fadeOut(config)
  local State=require("dragonbones.original.animation.AnimationState")
  local state=BaseObject.borrowObject(State)
  state:init(self._armature,data,config)
  self._animationDirty=true
  self._armature._cacheFrameIndex=-1

  if #self._animationStates>0 then
    local added=false
    for i=1,#self._animationStates do
      if state.layer>self._animationStates[i].layer then
        table.insert(self._animationStates,i,state)
        added=true
        break
      elseif i<#self._animationStates
          and state.layer>self._animationStates[i+1].layer then
        table.insert(self._animationStates,i+1,state)
        added=true
        break
      end
    end
    if not added then self._animationStates[#self._animationStates+1]=state end
  else
    self._animationStates[#self._animationStates+1]=state
  end
  for _,slot in ipairs(self._armature:getSlots()) do
    local child=slot.childArmature
    if child~=nil and child.inheritAnimation
        and child.animation:hasAnimation(name)
        and child.animation:getState(name)==nil then
      child.animation:fadeIn(name)
    end
  end
  for childName,timelines in pairs(data.animationTimelines) do
    local childState=self:fadeIn(childName,0.0,1,state.layer,"",Mode.Single)
    if childState~=nil then
      childState.actionEnabled=false
      childState.resetToPose=false
      childState:stop()
      state:addState(childState,timelines)
      local index=indexOf(self._animationStates,state)
      local childIndex=indexOf(self._animationStates,childState)
      if childIndex<index then
        table.remove(self._animationStates,index)
        table.insert(self._animationStates,childIndex,state)
      end
    end
  end
  self._lastAnimationState=state
  return state
end

function Animation:play(name,playTimes)
  if playTimes==nil then playTimes=-1 end
  local config=self._animationConfig
  config:clear()
  config.resetToPose=true
  config.playTimes=playTimes
  config.fadeInTime=0.0
  config.animation=name~=nil and name or ""
  if name~=nil and #name>0 then
    self:playConfig(config)
  elseif self._lastAnimationState==nil then
    local default=self._armature.armatureData.defaultAnimation
    if default~=nil then
      config.animation=default.name
      self:playConfig(config)
    end
  elseif not self._lastAnimationState.isPlaying
      and not self._lastAnimationState.isCompleted then
    self._lastAnimationState:play()
  else
    config.animation=self._lastAnimationState.name
    self:playConfig(config)
  end
  return self._lastAnimationState
end

function Animation:fadeIn(name,fadeInTime,playTimes,layer,group,fadeOutMode)
  local config=self._animationConfig
  config:clear()
  config.fadeOutMode=fadeOutMode~=nil and fadeOutMode or Mode.SameLayerAndGroup
  config.playTimes=playTimes~=nil and playTimes or -1
  config.layer=layer~=nil and layer or 0
  config.fadeInTime=fadeInTime~=nil and fadeInTime or -1.0
  config.animation=name
  config.group=group~=nil and group or ""
  return self:playConfig(config)
end

function Animation:gotoAndPlayByTime(name,time,playTimes)
  local config=self._animationConfig;config:clear()
  config.resetToPose=true
  config.playTimes=playTimes~=nil and playTimes or -1
  config.position=time~=nil and time or 0.0
  config.fadeInTime=0.0
  config.animation=name
  return self:playConfig(config)
end
function Animation:gotoAndPlayByFrame(name,frame,playTimes)
  local config=self._animationConfig;config:clear()
  config.resetToPose=true
  config.playTimes=playTimes~=nil and playTimes or -1
  config.fadeInTime=0.0
  config.animation=name
  local data=self._animations[name]
  if data~=nil then
    config.position=data.frameCount>0 and
      data.duration*(frame~=nil and frame or 0)/data.frameCount or 0.0
  end
  return self:playConfig(config)
end
function Animation:gotoAndPlayByProgress(name,progress,playTimes)
  local config=self._animationConfig;config:clear()
  config.resetToPose=true
  config.playTimes=playTimes~=nil and playTimes or -1
  config.fadeInTime=0.0
  config.animation=name
  local data=self._animations[name]
  if data~=nil then
    local p=progress~=nil and progress or 0.0
    config.position=data.duration*(p>0 and p or 0.0)
  end
  return self:playConfig(config)
end
function Animation:gotoAndStopByTime(name,time)
  local state=self:gotoAndPlayByTime(name,time,1)
  if state~=nil then state:stop() end
  return state
end
function Animation:gotoAndStopByFrame(name,frame)
  local state=self:gotoAndPlayByFrame(name,frame,1)
  if state~=nil then state:stop() end
  return state
end
function Animation:gotoAndStopByProgress(name,progress)
  local state=self:gotoAndPlayByProgress(name,progress,1)
  if state~=nil then state:stop() end
  return state
end

function Animation:getBlendState(kind,name,target)
  local states=self._blendStates[kind]
  if states==nil then states={};self._blendStates[kind]=states end
  if states[name]==nil then
    local BlendState=require("dragonbones.original.animation.BlendState")
    states[name]=BaseObject.borrowObject(BlendState)
    states[name].target=target
  end
  return states[name]
end
function Animation:getState(name,layer)
  if layer==nil then layer=-1 end
  for i=#self._animationStates,1,-1 do
    local state=self._animationStates[i]
    if state.name==name and (layer<0 or state.layer==layer) then return state end
  end
  return nil
end
function Animation:hasAnimation(name)
  return self._animations[name]~=nil
end
function Animation:getStates() return self._animationStates end
return Animation
