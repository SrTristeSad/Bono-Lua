-- Ported from DragonBonesJS commit 64b6c69ae35777c2404be68c9192e2c56906079e
-- Copyright (c) 2012-2025 DragonBones team and other contributors.
-- MIT license: see LICENSE-DRAGONBONES.
-- Original: DragonBones/src/dragonBones/model/SkinData.ts
local BaseObject=require("dragonbones.core.BaseObject")
local JSArray=require("dragonbones.core.JSArray")
local JSMap=require("dragonbones.core.JSMap")
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
  self.displays=JSMap.new()
  return self
end
function SkinData:_onClear()
  for _,key in ipairs(JSMap.keys(self.displays)) do
    local slotDisplays=self.displays[key]
    if slotDisplays~=nil then
      local index=1
      while index<=slotDisplays.length do
        local display=slotDisplays[index]
        if not rawequal(display,SkinData.NULL) then display:returnToPool() end
        index=index+1
      end
      JSMap.remove(self.displays,key)
    end
  end
  self.name=""
  self.parent=nil
end
function SkinData:addDisplay(slotName,...)
  if self.displays[slotName]==nil then self.displays[slotName]=JSArray.new() end
  local value=...
  -- Explicit nil is JS null; an omitted argument is undefined and must fail
  -- after the list has been created, at the original parent assignment.
  if select("#",...)==0 then error("Display argument is undefined") end
  if value==nil then value=SkinData.NULL end
  if not rawequal(value,SkinData.NULL) then value.parent=self end
  local slotDisplays=self.displays[slotName]
  local length=slotDisplays.length
  slotDisplays[length+1]=value
  slotDisplays.length=length+1 -- Array.push length write, including overflow
end
function SkinData:getDisplay(slotName,displayName)
  local slotDisplays=self:getDisplays(slotName)
  if slotDisplays~=nil then
    local index=1
    while index<=slotDisplays.length do
      local display=slotDisplays[index]
      if not rawequal(display,SkinData.NULL) and display.name==displayName then return display end
      index=index+1
    end
  end
  return nil
end
function SkinData:getDisplays(slotName)
  return self.displays[slotName]
end
return SkinData
