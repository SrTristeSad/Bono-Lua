-- AnimationState.ts, DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e.
-- Copyright (c) 2012-2025 DragonBones contributors; MIT.
local BaseObject=require('dragonbones.core.BaseObject')
local BlendState={
  BONE_TRANSFORM='boneTransform',BONE_ALPHA='boneAlpha',SURFACE='surface',
  SLOT_DEFORM='slotDeform',SLOT_ALPHA='slotAlpha',SLOT_Z_INDEX='slotZIndex',
}
BlendState.__index=BlendState
setmetatable(BlendState,{__index=BaseObject})
function BlendState.toString()return '[class dragonBones.BlendState]'end
function BlendState.new()return BaseObject.new(BlendState)end
function BlendState:_onClear()
  self:reset()
  self.target=nil
end
function BlendState:update(animationState)
  local animationLayer=animationState.layer
  local animationWeight=animationState._weightResult
  if self.dirty>0 then
    if self.leftWeight>0.0 then
      if self.layer~=animationLayer then
        if self.layerWeight>=self.leftWeight then
          self.dirty=self.dirty+1
          self.layer=animationLayer
          self.leftWeight=0.0
          self.blendWeight=0.0
          return false
        end
        self.layer=animationLayer
        self.leftWeight=self.leftWeight-self.layerWeight
        self.layerWeight=0.0
      end
      animationWeight=animationWeight*self.leftWeight
      self.dirty=self.dirty+1
      self.blendWeight=animationWeight
      self.layerWeight=self.layerWeight+self.blendWeight
      return true
    end
    return false
  end
  self.dirty=self.dirty+1
  self.layer=animationLayer
  self.leftWeight=1.0
  self.blendWeight=animationWeight
  self.layerWeight=animationWeight
  return true
end
function BlendState:reset()
  self.dirty=0
  self.layer=0
  self.leftWeight=0.0
  self.layerWeight=0.0
  self.blendWeight=0.0
end
return BlendState
