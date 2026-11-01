-- DragonBonesJS runtime pinned at 64b6c69ae35777c2404be68c9192e2c56906079e.
-- Copyright (c) 2012-2025 DragonBones team and other contributors.
-- MIT license: see LICENSE-DRAGONBONES.
-- Direct port of DragonBones/src/dragonBones/animation/WorldClock.ts.
--
-- A Lua table sentinel preserves JS array "null" entries (and therefore
-- compaction and mutation timing). "clock" uses metatable accessors to match
-- the original get/set, including recursive parent.add/remove behavior.
-- Date.now() platform adaptation: LÖVE timer if present; otherwise os.time()
-- (one-second resolution in stock Lua). See docs/PORTING_STATUS.md.

local WorldClock = {}
local NULL = {}

-- Date.now() equivalent is a platform boundary, NOT a different clock algorithm.
local function systemTime()
  if type(love) == "table" and type(love.timer) == "table"
      and type(love.timer.getTime) == "function" then
    return love.timer.getTime()
  end
  return os.time()
end

-- Injectable solely as a platform time source for deterministic conformance.
-- Production always uses the function above unless explicitly overridden.
WorldClock._now = systemTime

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
  if rawget(self, "_clock") == value then
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
    _animatebles = {}
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

  local i, r, l = 1, 0, #self._animatebles
  while i <= l do
    local animatable = self._animatebles[i]
    if animatable ~= NULL then
      if r > 0 then
        self._animatebles[i-r] = animatable
        self._animatebles[i] = NULL
      end
      animatable:advanceTime(passedTime)
    else
      r = r + 1
    end
    i = i + 1
  end

  if r > 0 then
    l = #self._animatebles
    while i <= l do
      local animatable = self._animatebles[i]
      if animatable ~= NULL then
        self._animatebles[i-r] = animatable
      else
        r = r + 1
      end
      i = i + 1
    end
    for index=l,l-r+1,-1 do
      self._animatebles[index] = nil
    end
  end
end

function WorldClock:contains(value)
  if value == self then
    return false
  end

  local ancestor = value
  while ancestor ~= self and ancestor ~= nil do
    ancestor = ancestor.clock
  end
  return ancestor == self
end

function WorldClock:add(value)
  local found = false
  for _,animatable in ipairs(self._animatebles) do
    if animatable == value then
      found = true
      break
    end
  end
  if not found then
    self._animatebles[#self._animatebles+1] = value
    value.clock = self
  end
end

function WorldClock:remove(value)
  for index,animatable in ipairs(self._animatebles) do
    if animatable == value then
      self._animatebles[index] = NULL
      value.clock = nil
      break
    end
  end
end

-- Source behavior is intentionally unusual: clear only sets .clock = null.
-- It does not remove entries from the private _animatebles array.
function WorldClock:clear()
  for _,animatable in ipairs(self._animatebles) do
    if animatable ~= NULL then
      animatable.clock = nil
    end
  end
end

return WorldClock
