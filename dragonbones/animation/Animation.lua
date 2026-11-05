-- Partial Animation.ts, DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e; MIT.
-- Real lifecycle, blend registry and advanceTime; playConfig/facade APIs absent.
local BaseObject=require('dragonbones.core.BaseObject')
local Config=require('dragonbones.model.AnimationConfig')
local Blend=require('dragonbones.animation.BlendState')
local Array=require('dragonbones.core.JSArray')
local Map=require('dragonbones.core.JSMap')
local function each(a)local i=0;return function()i=i+1;if i<=a.length then return i,a[i]end end end
local Animation={};Animation.__index=Animation
setmetatable(Animation,{__index=BaseObject})
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

return Animation
