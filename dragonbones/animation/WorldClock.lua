-- DragonBonesJS runtime pinned at 64b6c69ae35777c2404be68c9192e2c56906079e.
-- Copyright (c) 2012-2025 DragonBones team and other contributors.
-- MIT license: see LICENSE-DRAGONBONES.
-- Direct port of DragonBones/src/dragonBones/animation/WorldClock.ts.
--
-- A Lua table sentinel preserves JS array "null" entries (and therefore
-- compaction and mutation timing). "clock" uses metatable accessors to match
-- the original get/set, including recursive parent.add/remove behavior.
-- Platform time is epoch seconds, matching Date.getTime()/Date.now() * 0.001.
-- Stock Lua only exposes whole-second wall time; hosts may bind _now to a
-- millisecond-resolution wall-time provider. No monotonic LÖVE timer is silently
-- substituted for the original epoch clock. See docs/DIFFERENCES.md.
local WorldClock = {}
local NULL = {}
local function systemTime()
  return os.time() + 0.0
end
WorldClock._now = systemTime

-- Reentrant callbacks can shrink the list while an outer traversal retains
-- its original bound, then write beyond the new end. JS Array.length still
-- counts those undefined slots; Lua #/ipairs cannot represent that contract.
local function writeArray(array,index,value)
  if index>array.length then array.length=index end
  array[index]=value
end
local function resizeArray(array,length)
  if length<0 or length~=math.floor(length) or length>4294967295 then
    error("Invalid array length")
  end
  for index=array.length,length+1,-1 do array[index]=nil end
  array.length=length
end

function WorldClock.__index(self, key)
  if key == "clock" then
    return rawget(self, "_clock")
  end
  return rawget(WorldClock, key)
end

function WorldClock.__newindex(self, key, value)
  if key ~= "clock" then
    rawset(self, key, value)
    return
  end
  if rawequal(rawget(self, "_clock"), value) then
    return
  end
  local oldClock = rawget(self, "_clock")
  if oldClock ~= nil then
    oldClock:remove(self)
  end
  rawset(self, "_clock", value)
  if value ~= nil then
    value:add(self)
  end
end

function WorldClock.new(time)
  local clock = setmetatable({
    time = time == nil and 0.0 or time,
    timeScale = 1.0,
    _systemTime = WorldClock._now(),
    _animatebles = {length=0}
  }, WorldClock)
  return clock
end

function WorldClock:advanceTime(passedTime)
  if passedTime ~= passedTime then
    passedTime = 0.0
  end

  local currentTime = WorldClock._now()

  if passedTime < 0.0 then
    passedTime = currentTime - self._systemTime
  end

  self._systemTime = currentTime

  if self.timeScale ~= 1.0 then
    passedTime = passedTime * self.timeScale
  end

  if passedTime == 0.0 then
    return
  end

  if passedTime < 0.0 then
    self.time = self.time - passedTime
  else
    self.time = self.time + passedTime
  end

  local i, r, l = 1, 0, self._animatebles.length
  while i <= l do
    local animatable = self._animatebles[i]
    if not rawequal(animatable, NULL) then
      if r > 0 then
        writeArray(self._animatebles,i-r,animatable)
        writeArray(self._animatebles,i,NULL)
      end
      animatable:advanceTime(passedTime)
    else
      r = r + 1
    end
    i = i + 1
  end

  if r > 0 then
    l = self._animatebles.length
    while i <= l do
      local animatable = self._animatebles[i]
      if not rawequal(animatable, NULL) then
        writeArray(self._animatebles,i-r,animatable)
      else
        r = r + 1
      end
      i = i + 1
    end
    resizeArray(self._animatebles,self._animatebles.length-r)
  end
end

function WorldClock:contains(value)
  if rawequal(value, self) then
    return false
  end

  local ancestor = value
  while not rawequal(ancestor, self) and ancestor ~= nil do
    ancestor = ancestor.clock
  end
  return rawequal(ancestor, self)
end

function WorldClock:add(value)
  local found = false
  for index=1,self._animatebles.length do
    local animatable=self._animatebles[index]
    if rawequal(animatable, value) then
      found = true
      break
    end
  end
  if not found then
    writeArray(self._animatebles,self._animatebles.length+1,value)
    value.clock = self
  end
end

function WorldClock:remove(value)
  for index=1,self._animatebles.length do
    local animatable=self._animatebles[index]
    if rawequal(animatable, value) then
      self._animatebles[index] = NULL
      value.clock = nil
      break
    end
  end
end

-- Source behavior is intentionally unusual: clear only sets .clock = null.
-- It does not remove entries from the private _animatebles array.
function WorldClock:clear()
  local index=1
  while index<=self._animatebles.length do
    local animatable=self._animatebles[index]
    if not rawequal(animatable, NULL) then
      animatable.clock = nil
    end
    index=index+1
  end
end

return WorldClock
