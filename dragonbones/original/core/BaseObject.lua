-- DragonBonesJS commit 64b6c69ae35777c2404be68c9192e2c56906079e
-- Copyright (c) 2012-2025 DragonBones team and other contributors.
-- Port under the MIT License; see LICENSE-DRAGONBONES.
-- Direct behavioral port of DragonBones/src/dragonBones/core/BaseObject.ts.
-- Lua has neither TS abstract classes nor "new constructor"; subclasses provide
-- a zero-argument Class.new() returning BaseObject.new(Class).
-- A Lua class table is used as the pool key (rather than String(constructor)),
-- avoiding JavaScript's possible constructor-source-name collisions.
local BaseObject = {}
BaseObject.__index = BaseObject

local hashCode = 0
local defaultMaxCount = 3000
local maxCountMap = {}
local poolsMap = {}

local function truncatePool(pool, maxCount)
  if #pool > maxCount then
    -- JavaScript Array.length rejects fractional lengths on actual resize.
    if maxCount ~= math.floor(maxCount) then
      error("Invalid array length")
    end
    for i=#pool,maxCount+1,-1 do
      pool[i] = nil
    end
  end
end

local function returnObject(object)
  local classType = getmetatable(object)
  local maxCount = maxCountMap[classType]
  if maxCount == nil then maxCount = defaultMaxCount end
  local pool = poolsMap[classType]
  if pool == nil then
    pool = {}
    poolsMap[classType] = pool
  end
  if #pool < maxCount then
    if not object._isInPool then
      object._isInPool = true
      pool[#pool+1] = object
    else
      -- Original: console.warn("The object is already in the pool.")
      io.stderr:write("The object is already in the pool.\n")
    end
  end
end

-- Lua equivalent to the TS BaseObject field initializer and implicit new().
function BaseObject.new(objectConstructor)
  assert(type(objectConstructor)=="table", "BaseObject subclass must be a class table")
  local object = setmetatable({
    hashCode=hashCode,
    _isInPool=false
  }, objectConstructor)
  hashCode = hashCode + 1
  return object
end

-- Original BaseObject.toString() is an abstract-class guard that throws.
function BaseObject.toString()
  error("DragonBones BaseObject.toString is abstract")
end

function BaseObject.setMaxCount(objectConstructor, maxCount)
  if maxCount < 0 or maxCount ~= maxCount then
    maxCount = 0
  end

  if objectConstructor ~= nil then
    local pool = poolsMap[objectConstructor]
    if pool ~= nil and #pool > maxCount then
      truncatePool(pool, maxCount)
    end
    maxCountMap[objectConstructor] = maxCount
  else
    defaultMaxCount = maxCount
    for classType, pool in pairs(poolsMap) do
      if #pool > maxCount then
        truncatePool(pool, maxCount)
      end
      if maxCountMap[classType] ~= nil then
        maxCountMap[classType] = maxCount
      end
    end
  end
end

function BaseObject.clearPool(objectConstructor)
  if objectConstructor ~= nil then
    local pool = poolsMap[objectConstructor]
    if pool ~= nil and #pool > 0 then
      for i=#pool,1,-1 do pool[i]=nil end
    end
  else
    for _, pool in pairs(poolsMap) do
      for i=#pool,1,-1 do pool[i]=nil end
    end
  end
end

function BaseObject.borrowObject(objectConstructor)
  local pool = poolsMap[objectConstructor]
  if pool ~= nil and #pool > 0 then
    local object = table.remove(pool)
    object._isInPool = false
    return object
  end

  -- Original: const object = new objectConstructor(); object._onClear()
  assert(type(objectConstructor)=="table" and type(objectConstructor.new)=="function",
    "objectConstructor.new must construct a BaseObject subclass")
  local object = objectConstructor.new()
  object:_onClear()
  return object
end

function BaseObject:returnToPool()
  self:_onClear()
  returnObject(self)
end

return BaseObject
