-- DragonBonesJS original commit 64b6c69ae35777c2404be68c9192e2c56906079e
-- Copyright (c) 2012-2025 DragonBones team and other contributors.
-- MIT license: see LICENSE-DRAGONBONES.
-- Exact source: DragonBones/src/dragonBones/model/CanvasData.ts
local BaseObject=require("dragonbones.original.core.BaseObject")
local CanvasData={}
CanvasData.__index=CanvasData
setmetatable(CanvasData,{__index=BaseObject})

function CanvasData.toString()
  return "[class dragonBones.CanvasData]"
end

function CanvasData.new()
  return BaseObject.new(CanvasData)
end

function CanvasData:_onClear()
  self.hasBackground=false
  self.color=0x000000
  self.x=0
  self.y=0
  self.width=0
  self.height=0
end

return CanvasData
