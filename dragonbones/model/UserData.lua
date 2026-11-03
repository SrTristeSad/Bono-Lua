-- Port from DragonBonesJS (commit 64b6c69ae35777c2404be68c9192e2c56906079e).
-- Copyright (c) 2012-2025 DragonBones team and other contributors.
-- MIT license: see LICENSE-DRAGONBONES.
-- Original file: DragonBones/src/dragonBones/model/UserData.ts
-- Classes: UserData, ActionData. Lua's BaseObject.new(Class) replaces TS new.
local BaseObject = require("dragonbones.core.BaseObject")

local ActionType = require("dragonbones.core.Enums").ActionType

local UserData = {}
UserData.__index = UserData
setmetatable(UserData, { __index = BaseObject })

function UserData.toString()
  return "[class dragonBones.UserData]"
end

function UserData.new()
  local self = BaseObject.new(UserData)
  self.ints = {}
  self.floats = {}
  self.strings = {}
  return self
end

function UserData:_onClear()
  -- TS sets array.length = 0, preserving the arrays' identity.
  for i = #self.ints, 1, -1 do self.ints[i] = nil end
  for i = #self.floats, 1, -1 do self.floats[i] = nil end
  for i = #self.strings, 1, -1 do self.strings[i] = nil end
end

function UserData:addInt(value)
  self.ints[#self.ints + 1] = value
end

function UserData:addFloat(value)
  self.floats[#self.floats + 1] = value
end

function UserData:addString(value)
  self.strings[#self.strings + 1] = value
end

-- The original array positions are zero-based. Invalid positions return 0/"".
function UserData:getInt(index)
  index = index == nil and 0 or index
  if index >= 0 and index < #self.ints then
    -- JS fractional property keys are not array positions. Test before +1:
    -- a tiny positive fraction can round to 1 when shifted in binary64.
    if index ~= math.floor(index) then return nil end
    return self.ints[index + 1]
  end
  return 0.0
end

function UserData:getFloat(index)
  index = index == nil and 0 or index
  if index >= 0 and index < #self.floats then
    -- JS fractional property keys are not array positions. Test before +1:
    -- a tiny positive fraction can round to 1 when shifted in binary64.
    if index ~= math.floor(index) then return nil end
    return self.floats[index + 1]
  end
  return 0.0
end

function UserData:getString(index)
  index = index == nil and 0 or index
  if index >= 0 and index < #self.strings then
    -- JS fractional property keys are not array positions. Test before +1:
    -- a tiny positive fraction can round to 1 when shifted in binary64.
    if index ~= math.floor(index) then return nil end
    return self.strings[index + 1]
  end
  return ""
end

local ActionData = {}
ActionData.__index = ActionData
setmetatable(ActionData, { __index = BaseObject })

function ActionData.toString()
  return "[class dragonBones.ActionData]"
end

function ActionData.new()
  local self = BaseObject.new(ActionData)
  return self
end

function ActionData:_onClear()
  if self.data ~= nil then
    self.data:returnToPool()
  end

  self.type = ActionType.Play
  self.name = ""
  self.bone = nil
  self.slot = nil
  self.data = nil
end

return { UserData = UserData, ActionData = ActionData }
