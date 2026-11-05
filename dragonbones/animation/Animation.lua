-- Animation.ts, DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e; MIT.
-- Original bodies ported in the domains documented in AnimationFacade.md.
local BaseObject=require('dragonbones.core.BaseObject')
local Config=require('dragonbones.model.AnimationConfig')
local Blend=require('dragonbones.animation.BlendState')
local Array=require('dragonbones.core.JSArray')
local Map=require('dragonbones.core.JSMap')
local function each(a)local i=0;return function()i=i+1;if i<=a.length then return i,a[i]end end end
local Mode=require('dragonbones.core.Enums').AnimationFadeOutMode
local Animation={}
Animation.__index=function(self,key)
  if key=="isPlaying" then
    for _,state in each(self._animationStates) do
      if state.isPlaying then return true end
    end
    return false
  end
  if key=="isCompleted" then
    for _,state in each(self._animationStates) do
      if not state.isCompleted then return false end
    end
    return self._animationStates.length>0
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
    self._animationNames.length=0
    for _,name in ipairs(Map.keys(self._animations))do Map.remove(self._animations,name)end
    for _,name in ipairs(Map.keys(value))do
      self._animationNames[self._animationNames.length+1]=name
      self._animations[name]=value[name]
    end
  elseif key=='isPlaying' or key=='isCompleted' or key=='lastAnimationName'
      or key=='animationNames' or key=='animationConfig' or key=='lastAnimationState' then
    error('Readonly property: '..key)
  else rawset(self,key,value) end
end

setmetatable(Animation,{__index=BaseObject})
local function clearArray(a)a.length=0 end
local function indexOf(a,item)
  for i=1,a.length do if a[i]==item then return i end end
  return nil
end
local function insert(a,index,value)
  for i=a.length,index,-1 do a[i+1]=a[i]end
  a[index]=value
end
local function remove(a,index)
  for i=index,a.length-1 do a[i]=a[i+1]end
  a.length=a.length-1
end
local function jsMod(a,b)return math.fmod(a,b)end

function Animation.toString()return '[class dragonBones.Animation]'end
function Animation.new()
  local self=BaseObject.new(Animation)
  self._animationNames=Array.new();self._animationStates=Array.new()
  self._animations=Map.new();self._blendStates=Map.new()
  return self
end
function Animation:_onClear()
  local i=1;while i<=self._animationStates.length do self._animationStates[i]:returnToPool();i=i+1 end
  for _,key in ipairs(Map.keys(self._animations))do Map.remove(self._animations,key)end
  for _,key in ipairs(Map.keys(self._blendStates))do
    local states=self._blendStates[key]
    for _,name in ipairs(Map.keys(states))do states[name]:returnToPool()end
    Map.remove(self._blendStates,key)
  end
  if self._animationConfig~=nil then self._animationConfig:returnToPool()end
  self.timeScale=1.0;self._animationDirty=false;self._inheritTimeScale=1.0
  self._animationNames.length=0;self._animationStates.length=0
  self._armature=nil;self._animationConfig=nil;self._lastAnimationState=nil
end
function Animation:init(armature)
  if self._armature~=nil then return end
  self._armature=armature;self._animationConfig=BaseObject.borrowObject(Config)
end
function Animation:getBlendState(kind,name,target)
  if self._blendStates[kind]==nil then self._blendStates[kind]=Map.new()end
  local states=self._blendStates[kind]
  if states[name]==nil then states[name]=BaseObject.borrowObject(Blend);states[name].target=target end
  return states[name]
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
  for _,key in ipairs(Map.keys(self._blendStates))do
    local blendStates=self._blendStates[key]
    for _,name in ipairs(Map.keys(blendStates))do blendStates[name]:reset()end
  end
  local count=self._animationStates.length
  if count==1 then
    local state=self._animationStates[1]
    if state._fadeState>0 and state._subFadeState>0 then
      self._armature._dragonBones:bufferObject(state)
      self._animationStates.length=0
      self._lastAnimationState=nil
    else
      local data=state.animationData
      local cacheRate=data.cacheFrameRate
      if self._animationDirty and cacheRate>0.0 then
        self._animationDirty=false
        for _,bone in each(self._armature:getBones()) do
          bone._cachedFrameIndices=data:getBoneCachedFrameIndices(bone.name)
        end
        for _,slot in each(self._armature:getSlots()) do
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
        self._animationStates.length=count-removed
        if self._lastAnimationState==nil and self._animationStates.length>0 then
          self._lastAnimationState=self._animationStates[self._animationStates.length]
        end
      end
    end
    self._armature._cacheFrameIndex=-1
  else
    self._armature._cacheFrameIndex=-1
  end
end

function Animation:_fadeOut(animationConfig)
  local mode=animationConfig.fadeOutMode
  if mode==Mode.Single or mode==Mode.None then return end
  for _,state in each(self._animationStates) do
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

function Animation:reset()
  for _,state in each(self._animationStates) do state:returnToPool() end
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
    for _,state in each(self._animationStates) do state:stop() end
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
    for _,state in each(self._animationStates) do
      if state._fadeState<1 and state.layer==config.layer
          and state.animationData==data then
        return state
      end
    end
  end
  if self._animationStates.length==0 then
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
  local State=require("dragonbones.animation.AnimationState")
  local state=BaseObject.borrowObject(State)
  state:init(self._armature,data,config)
  self._animationDirty=true
  self._armature._cacheFrameIndex=-1

  if self._animationStates.length>0 then
    local added=false
    for i=1,self._animationStates.length do
      if state.layer>self._animationStates[i].layer then
        insert(self._animationStates,i,state)
        added=true
        break
      elseif i<self._animationStates.length
          and state.layer>self._animationStates[i+1].layer then
        insert(self._animationStates,i+1,state)
        added=true
        break
      end
    end
    if not added then self._animationStates[self._animationStates.length+1]=state end
  else
    self._animationStates[self._animationStates.length+1]=state
  end
  for _,slot in each(self._armature:getSlots()) do
    local child=slot.childArmature
    if child~=nil and child.inheritAnimation
        and child.animation:hasAnimation(name)
        and child.animation:getState(name)==nil then
      child.animation:fadeIn(name)
    end
  end
  for _,childName in ipairs(Map.keys(data.animationTimelines)) do
    local timelines=data.animationTimelines[childName]
    local childState=self:fadeIn(childName,0.0,1,state.layer,"",Mode.Single)
    if childState~=nil then
      childState.actionEnabled=false
      childState.resetToPose=false
      childState:stop()
      state:addState(childState,timelines)
      local index=indexOf(self._animationStates,state)
      local childIndex=indexOf(self._animationStates,childState)
      if childIndex<index then
        remove(self._animationStates,index)
        insert(self._animationStates,childIndex,state)
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

function Animation:getState(name,layer)
  if layer==nil then layer=-1 end
  for i=self._animationStates.length,1,-1 do
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
