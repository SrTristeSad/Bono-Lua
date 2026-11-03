-- DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e
-- Copyright (c) 2012-2025 DragonBones team and other contributors.
-- MIT license: see LICENSE-DRAGONBONES.
-- Language adapter shared by string-key maps.
local JSMap = {}

-- Preserve JS own-string-key iteration without replacing the public map
-- table with an opaque proxy. New ordinary assignments record insertion order;
-- overwrites retain it, and delete/reinsert gets a new position.
local orders=setmetatable({},{__mode="k"})
function JSMap.new()
  local state={positions={},next=0}
  local map=setmetatable({}, {__newindex=function(t,key,value)
    if value~=nil then state.next=state.next+1;state.positions[key]=state.next end
    rawset(t,key,value)
  end})
  orders[map]=state
  return map
end
local function arrayIndex(key)
  if key~="0" and not key:match("^[1-9]%d*$") then return nil end
  local n=tonumber(key)
  if n and n<4294967295 then return n end
  return nil
end
function JSMap.keys(map)
  local state=orders[map]
  for key in pairs(state.positions) do if map[key]==nil then state.positions[key]=nil end end
  local keys={}
  for key in pairs(map) do keys[#keys+1]=key end
  table.sort(keys,function(a,b)
    local ai,bi=arrayIndex(a),arrayIndex(b)
    if ai~=nil and bi~=nil then return ai<bi end
    if ai~=nil then return true end
    if bi~=nil then return false end
    return state.positions[a]<state.positions[b]
  end)
  return keys
end
function JSMap.remove(map,key)
  map[key]=nil
  orders[map].positions[key]=nil
end

return JSMap
