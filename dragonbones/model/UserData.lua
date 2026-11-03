-- Port from DragonBonesJS (commit 64b6c69ae35777c2404be68c9192e2c56906079e).
-- Copyright (c) 2012-2025 DragonBones team and other contributors.
-- MIT license: see LICENSE-DRAGONBONES.
-- Original file: DragonBones/src/dragonBones/model/UserData.ts
-- Classes: UserData, ActionData. Lua's BaseObject.new(Class) replaces TS new.
local BaseObject = require("dragonbones.core.BaseObject")

local JSArray = require("dragonbones.core.JSArray")

local ActionType = require("dragonbones.core.Enums").ActionType

local UserData = {}
UserData.__index = UserData
setmetatable(UserData, { __index = BaseObject })

function UserData.toString()
  return "[class dragonBones.UserData]"
end

function UserData.new()
  local self = BaseObject.new(UserData)
  self.ints = JSArray.new()
  self.floats = JSArray.new()
  self.strings = JSArray.new()
  return self
end

function UserData:_onClear()
  -- TS sets array.length = 0, preserving the arrays' identity.
  self.ints.length = 0
  self.floats.length = 0
  self.strings.length = 0
end

function UserData:addInt(value)
  local length = self.ints.length
  self.ints[length + 1] = value
  self.ints.length = length + 1
end

function UserData:addFloat(value)
  local length = self.floats.length
  self.floats[length + 1] = value
  self.floats.length = length + 1
end

function UserData:addString(value)
  local length = self.strings.length
  self.strings[length + 1] = value
  self.strings.length = length + 1
end

-- The original array positions are zero-based. Invalid positions return 0/"".
function UserData:getInt(index)
  index = index == nil and 0 or index
  if index >= 0 and index < self.ints.length then
    -- JS fractional property keys are not array positions. Test before +1:
    -- a tiny positive fraction can round to 1 when shifted in binary64.
    if index ~= math.floor(index) then return nil end
    return self.ints[index + 1]
  end
  return 0.0
end

function UserData:getFloat(index)
  index = index == nil and 0 or index
  if index >= 0 and index < self.floats.length then
    -- JS fractional property keys are not array positions. Test before +1:
    -- a tiny positive fraction can round to 1 when shifted in binary64.
    if index ~= math.floor(index) then return nil end
    return self.floats[index + 1]
  end
  return 0.0
end

function UserData:getString(index)
  index = index == nil and 0 or index
  if index >= 0 and index < self.strings.length then
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
