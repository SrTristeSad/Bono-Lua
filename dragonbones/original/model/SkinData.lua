-- Ported from DragonBonesJS commit 64b6c69ae35777c2404be68c9192e2c56906079e
-- Copyright (c) 2012-2025 DragonBones team and other contributors.
-- MIT license: see LICENSE-DRAGONBONES.
-- Original: DragonBones/src/dragonBones/model/SkinData.ts
local BaseObject=require("dragonbones.original.core.BaseObject")
local SkinData={}
SkinData.__index=SkinData
setmetatable(SkinData,{__index=BaseObject})

-- A Lua array cannot retain a JavaScript null at a numerical slot. This
-- sentinel is the Lua representation of the original DisplayData | null.
-- It is NOT a renderable display and must not be passed to BaseObject.
SkinData.NULL={}

function SkinData.toString()
  return "[class dragonBones.SkinData]"
end
function SkinData.new()
  local self=BaseObject.new(SkinData)
  self.displays={}
  return self
end
function SkinData:_onClear()
  for key,slotDisplays in pairs(self.displays) do
    for _,display in ipairs(slotDisplays) do
      if display~=SkinData.NULL then
        display:returnToPool()
      end
    end
    self.displays[key]=nil
  end
  self.name=""
  self.parent=nil
end
function SkinData:addDisplay(slotName,value)
  if self.displays[slotName]==nil then
    self.displays[slotName]={}
  end
  if value~=nil and value~=SkinData.NULL then
    value.parent=self
  end
  local slotDisplays=self.displays[slotName]
  slotDisplays[#slotDisplays+1]=value==nil and SkinData.NULL or value
end
function SkinData:getDisplay(slotName,displayName)
  local slotDisplays=self:getDisplays(slotName)
  if slotDisplays~=nil then
    for _,display in ipairs(slotDisplays) do
      if display~=SkinData.NULL and display.name==displayName then
        return display
      end
    end
  end
  return nil
end
function SkinData:getDisplays(slotName)
  return self.displays[slotName]
end
return SkinData
