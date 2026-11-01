-- Direct port of the DisplayFrame class (lines 27-139) from
-- DragonBones/src/dragonBones/armature/Slot.ts
-- Pinned DragonBonesJS revision 64b6c69ae35777c2404be68c9192e2c56906079e.
-- Copyright (c) 2012-2025 DragonBones team and other contributors.
-- MIT license: see LICENSE-DRAGONBONES.
--
-- This is specifically the DisplayFrame class. The separate abstract Slot
-- class in the same TypeScript file has NOT been ported by this module.
local BaseObject = require("dragonbones.original.core.BaseObject")
local Core = require("dragonbones.original.core.DragonBones")

local DisplayFrame = {}
DisplayFrame.__index = DisplayFrame
setmetatable(DisplayFrame, { __index = BaseObject })

function DisplayFrame.toString()
  return "[class dragonBones.DisplayFrame]"
end

function DisplayFrame.new()
  local object = BaseObject.new(DisplayFrame)
  -- TypeScript's readonly Array<number> field initializer runs once, not
  -- again on each return to pool. Lua's 1-based indices are adapted only at
  -- the data boundary, so this is an ordinary sequential Lua array.
  object.deformVertices = {}
  return object
end

function DisplayFrame:_onClear()
  self.rawDisplayData = nil
  self.displayData = nil
  self.textureData = nil
  self.display = nil
  for i = #self.deformVertices, 1, -1 do
    self.deformVertices[i] = nil
  end
end

function DisplayFrame:updateDeformVertices()
  if self.rawDisplayData == nil or #self.deformVertices ~= 0 then
    return
  end

  local rawGeometryData
  if self.rawDisplayData.type == Core.DisplayType.Mesh then
    rawGeometryData = self.rawDisplayData.geometry
  elseif self.rawDisplayData.type == Core.DisplayType.Path then
    rawGeometryData = self.rawDisplayData.geometry
  else
    return
  end

  local vertexCount = 0
  if rawGeometryData.weight ~= nil then
    vertexCount = rawGeometryData.weight.count * 2
  else
    -- Original JS reads intArray[offset + GeometryVertexCount].
    -- The existing original model port stores binary arrays as Lua 1-based.
    vertexCount = rawGeometryData.data.intArray[
      rawGeometryData.offset + Core.BinaryOffset.GeometryVertexCount + 1
    ] * 2
  end

  -- Preserve the original zero-filled count, including zero-length geometry.
  for i = 1, vertexCount do
    self.deformVertices[i] = 0.0
  end
end

function DisplayFrame:getGeometryData()
  if self.displayData ~= nil then
    if self.displayData.type == Core.DisplayType.Mesh then
      return self.displayData.geometry
    end
    if self.displayData.type == Core.DisplayType.Path then
      return self.displayData.geometry
    end
  end

  if self.rawDisplayData ~= nil then
    if self.rawDisplayData.type == Core.DisplayType.Mesh then
      return self.rawDisplayData.geometry
    end
    if self.rawDisplayData.type == Core.DisplayType.Path then
      return self.rawDisplayData.geometry
    end
  end

  return nil
end

function DisplayFrame:getBoundingBox()
  if self.displayData ~= nil
      and self.displayData.type == Core.DisplayType.BoundingBox then
    return self.displayData.boundingBox
  end

  if self.rawDisplayData ~= nil
      and self.rawDisplayData.type == Core.DisplayType.BoundingBox then
    return self.rawDisplayData.boundingBox
  end

  return nil
end

function DisplayFrame:getTextureData()
  if self.displayData ~= nil then
    if self.displayData.type == Core.DisplayType.Image then
      return self.displayData.texture
    end
    if self.displayData.type == Core.DisplayType.Mesh then
      return self.displayData.texture
    end
  end

  if self.textureData ~= nil then
    return self.textureData
  end

  if self.rawDisplayData ~= nil then
    if self.rawDisplayData.type == Core.DisplayType.Image then
      return self.rawDisplayData.texture
    end
    if self.rawDisplayData.type == Core.DisplayType.Mesh then
      return self.rawDisplayData.texture
    end
  end

  return nil
end

return DisplayFrame
