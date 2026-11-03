-- DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e
-- Copyright (c) 2012-2025 DragonBones team and other contributors.
-- MIT license: see LICENSE-DRAGONBONES.
-- Language adapter: logical JS array length with Lua 1-based entries.
local JSArray = {}

-- Lua sequences have no reliable length after holes. Keep the source length
-- separately while retaining a normal public table and 1-based mask entries.
-- Named properties survive length truncation, as they do on a JS Array.
function JSArray.new()
  local length = 0
  return setmetatable({}, {
    __index = function(_, key)
      if key == "length" then return length end
    end,
    __newindex = function(mask, key, value)
      if key == "length" then
        if type(value) ~= "number" or value < 0 or value ~= math.floor(value)
          or value > 4294967295 then error("Invalid array length") end
        if value < length then
          for index in pairs(mask) do
            if type(index) == "number" and index >= 1 and index <= 4294967295
              and index == math.floor(index) and index > value then
              rawset(mask, index, nil)
            end
          end
        end
        length = value == 0 and 0 or value
      else
        if type(key) == "number" and key >= 1 and key <= 4294967295
          and key == math.floor(key) and key > length then length = key end
        rawset(mask, key, value)
      end
    end
  })
end

return JSArray
