-- DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e
-- Source: DragonBones/src/dragonBones/core/BaseObject.ts
-- Copyright (c) 2012-2025 DragonBones team and other contributors.
-- MIT license: see LICENSE-DRAGONBONES.
local BaseObject = {}
BaseObject.__index = BaseObject
BaseObject._hashCode = 0.0
BaseObject._defaultMaxCount = 3000
BaseObject._maxCountMap = {}
BaseObject._poolsMap = {}

-- JS for..in on own pool keys visits array-index names first (ascending),
-- then other names in insertion order. Lua pairs does not have that order.
-- Keep this representation detail out of the pool operations themselves.
local poolKeys = {}
local function arrayIndex(key)
  if key ~= '0' and not key:match('^[1-9]%d*$') then return nil end
  local n = tonumber(key)
  if n and n >= 0 and n < 4294967295 and n == math.floor(n) then return n end
  return nil
end
local function orderedPoolKeys()
  local indices, strings = {}, {}
  for _,key in ipairs(poolKeys) do
    if arrayIndex(key) ~= nil then indices[#indices+1] = key
    else strings[#strings+1] = key end
  end
  table.sort(indices, function(a,b) return tonumber(a) < tonumber(b) end)
  for _,key in ipairs(strings) do indices[#indices+1] = key end
  return indices
end
local function classKey(constructor)
  -- Runtime classes provide the original static toString, or inherit the
  -- throwing BaseObject guard. Never substitute class-table identity here:
  -- the original intentionally/observably shares pools for equal strings.
  return constructor.toString(constructor)
end
local function truncate(pool, count)
  if count ~= math.floor(count) or count > 4294967295 then
    error('Invalid array length')
  end
  for i=#pool,count+1,-1 do pool[i] = nil end
end

function BaseObject._returnObject(object)
  local key = classKey(object.constructor)
  local maxCount = BaseObject._maxCountMap[key]
  if maxCount == nil then maxCount = BaseObject._defaultMaxCount end
  local pool = BaseObject._poolsMap[key]
  if pool == nil then
    pool = {}
    BaseObject._poolsMap[key] = pool
    poolKeys[#poolKeys+1] = key
  end
  if #pool < maxCount then
    if not object._isInPool then
      object._isInPool = true
      pool[#pool+1] = object
    else
      io.stderr:write('The object is already in the pool.\n')
    end
  end
end

function BaseObject.toString()
  error('DragonBones BaseObject.toString is abstract')
end

function BaseObject.setMaxCount(constructor, maxCount)
  if maxCount < 0 or maxCount ~= maxCount then maxCount = 0 end
  if constructor ~= nil then
    local key = classKey(constructor)
    local pool = BaseObject._poolsMap[key]
    if pool ~= nil and #pool > maxCount then truncate(pool, maxCount) end
    BaseObject._maxCountMap[key] = maxCount
  else
    BaseObject._defaultMaxCount = maxCount
    for _,key in ipairs(orderedPoolKeys()) do
      local pool = BaseObject._poolsMap[key]
      if #pool > maxCount then truncate(pool, maxCount) end
      if BaseObject._maxCountMap[key] ~= nil then
        BaseObject._maxCountMap[key] = maxCount
      end
    end
  end
end

function BaseObject.clearPool(constructor)
  if constructor ~= nil then
    local pool = BaseObject._poolsMap[classKey(constructor)]
    if pool ~= nil and #pool > 0 then
      for i=#pool,1,-1 do pool[i] = nil end
    end
  else
    for _,key in ipairs(orderedPoolKeys()) do
      local pool = BaseObject._poolsMap[key]
      for i=#pool,1,-1 do pool[i] = nil end
    end
  end
end

function BaseObject.borrowObject(constructor)
  local pool = BaseObject._poolsMap[classKey(constructor)]
  if pool ~= nil and #pool > 0 then
    local object = table.remove(pool)
    object._isInPool = false
    return object
  end
  local object = constructor.new()
  object:_onClear()
  return object
end

-- Lua constructor entry point for the TS field initializers. Subclasses
-- inherit BaseObject and call BaseObject.new(Class) from their own new().
function BaseObject.new(constructor)
  local object = setmetatable({hashCode=BaseObject._hashCode, _isInPool=false,
    constructor=constructor}, constructor)
  BaseObject._hashCode = BaseObject._hashCode + 1.0
  return object
end

function BaseObject:returnToPool()
  self:_onClear()
  BaseObject._returnObject(self)
end

return BaseObject
