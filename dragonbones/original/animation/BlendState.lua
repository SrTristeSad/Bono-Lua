-- Direct port of BlendState from
-- DragonBones/src/dragonBones/animation/AnimationState.ts (second class).
-- Fixed DragonBonesJS commit 64b6c69ae35777c2404be68c9192e2c56906079e.
-- Copyright (c) 2012-2025 DragonBones team and other contributors.
-- MIT license: see LICENSE-DRAGONBONES.
--
-- Note: the pinned original has NO separate BlendState.ts file.
-- The accompanying AnimationState class is not implemented by this module.
local BaseObject = require("dragonbones.original.core.BaseObject")

local BlendState = {}
BlendState.__index = BlendState
setmetatable(BlendState, { __index = BaseObject })

BlendState.BONE_TRANSFORM = "boneTransform"
BlendState.BONE_ALPHA = "boneAlpha"
BlendState.SURFACE = "surface"
BlendState.SLOT_DEFORM = "slotDeform"
BlendState.SLOT_ALPHA = "slotAlpha"
BlendState.SLOT_Z_INDEX = "slotZIndex"

function BlendState.toString()
  return "[class dragonBones.BlendState]"
end

function BlendState.new()
  return BaseObject.new(BlendState)
end

function BlendState:_onClear()
  self:reset()
  self.target = nil
end

function BlendState:update(animationState)
  local animationLayer = animationState.layer
  local animationWeight = animationState._weightResult

  if self.dirty > 0 then
    if self.leftWeight > 0.0 then
      if self.layer ~= animationLayer then
        if self.layerWeight >= self.leftWeight then
          self.dirty = self.dirty + 1
          self.layer = animationLayer
          self.leftWeight = 0.0
          self.blendWeight = 0.0

          return false
        end

        self.layer = animationLayer
        self.leftWeight = self.leftWeight - self.layerWeight
        self.layerWeight = 0.0
      end

      animationWeight = animationWeight * self.leftWeight
      self.dirty = self.dirty + 1
      self.blendWeight = animationWeight
      self.layerWeight = self.layerWeight + self.blendWeight

      return true
    end

    return false
  end

  self.dirty = self.dirty + 1
  self.layer = animationLayer
  self.leftWeight = 1.0
  self.blendWeight = animationWeight
  self.layerWeight = animationWeight

  return true
end

function BlendState:reset()
  self.dirty = 0
  self.layer = 0
  self.leftWeight = 0.0
  self.layerWeight = 0.0
  self.blendWeight = 0.0
end

return BlendState
