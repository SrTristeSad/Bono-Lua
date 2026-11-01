-- Contract tests for DragonBones/src/dragonBones/model/AnimationConfig.ts
-- Original revision: 64b6c69ae35777c2404be68c9192e2c56906079e.
package.path = "./?.lua;./?/init.lua;" .. package.path
local Base = require("dragonbones.original.core.BaseObject")
local Config = require("dragonbones.original.model.AnimationConfig")
local Core = require("dragonbones.original.core.DragonBones")
local passed,failed=0,0
local function test(name,fn)
  local ok,err=pcall(fn)
  if ok then
    passed=passed+1
    print("ok original.animation_config "..name)
  else
    failed=failed+1
    print("not ok original.animation_config "..name..": "..tostring(err))
  end
end
local function eq(a,b)
  assert(a==b,tostring(a).." ~= "..tostring(b))
end
local function borrow()
  return Base.borrowObject(Config)
end
local defaults = {
  pauseFadeOut=true,
  fadeOutMode=Core.AnimationFadeOutMode.All,
  fadeOutTweenType=Core.TweenType.Line,
  fadeOutTime=-1.0,
  actionEnabled=true,
  additive=false,
  displayControl=true,
  pauseFadeIn=true,
  resetToPose=true,
  fadeInTweenType=Core.TweenType.Line,
  playTimes=-1,
  layer=0,
  position=0.0,
  duration=-1.0,
  timeScale=-100.0,
  weight=1.0,
  fadeInTime=-1.0,
  autoFadeOutTime=-1.0,
  name="",
  animation="",
  group=""
}
local function checkDefaults(o)
  for name,value in pairs(defaults) do
    eq(o[name],value)
  end
  eq(#o.boneMask,0)
end
local allNames = {
  "pauseFadeOut","fadeOutMode","fadeOutTweenType","fadeOutTime",
  "actionEnabled","additive","displayControl","pauseFadeIn",
  "resetToPose","fadeInTweenType","playTimes","layer","position",
  "duration","timeScale","weight","fadeInTime","autoFadeOutTime",
  "name","animation","group"
}
test("original class identifier and BaseObject inheritance",function()
  eq(Config.toString(),"[class dragonBones.AnimationConfig]")
  local o=borrow()
  assert(getmetatable(o)==Config)
  assert(type(o.returnToPool)=="function")
  o:returnToPool()
end)
test("all 21 original default fields including sentinel timeScale",function()
  local o=borrow()
  checkDefaults(o)
  eq(o.timeScale,-100.0)
  eq(o.fadeOutMode,4)
  eq(o.fadeInTweenType,1)
  o:returnToPool()
end)
test("constructor creates independent boneMask for each config",function()
  local a,b=borrow(),borrow()
  assert(a.boneMask~=b.boneMask)
  a.boneMask[1]="root"
  eq(#b.boneMask,0)
  a:returnToPool();b:returnToPool()
end)
test("clear() is void, resets all fields and boneMask in place",function()
  local o=borrow()
  local mask=o.boneMask
  for _,name in ipairs(allNames) do
    if type(o[name])=="number" then o[name]=23
    elseif type(o[name])=="string" then o[name]="changed"
    else o[name]=not o[name] end
  end
  o.boneMask={"a","b"} -- replaced to check current array, not former mask
  local current=o.boneMask
  assert(o:clear()==nil)
  checkDefaults(o)
  assert(o.boneMask==current)
  assert(o.boneMask~=mask)
  o:returnToPool()
end)
test("clear preserves mask identity when array already exists",function()
  local o=borrow()
  local mask=o.boneMask
  mask[1]="arm"
  mask[2]="leg"
  o:clear()
  assert(o.boneMask==mask)
  eq(#mask,0)
  o:returnToPool()
end)
test("copyFrom reproduces all 21 original property values",function()
  local source,dest=borrow(),borrow()
  for i,name in ipairs(allNames) do
    if type(source[name])=="number" then source[name]=i*0.125
    elseif type(source[name])=="boolean" then source[name]=not source[name]
    else source[name]="property-"..name end
  end
  assert(dest:copyFrom(source)==nil)
  for _,name in ipairs(allNames) do eq(dest[name],source[name]) end
  source:returnToPool();dest:returnToPool()
end)
test("copyFrom retains destination boneMask identity and order",function()
  local source,dest=borrow(),borrow()
  source.boneMask[1]="root"
  source.boneMask[2]="head"
  source.boneMask[3]="left"
  local original=dest.boneMask
  dest.boneMask[1]="stale"
  dest:copyFrom(source)
  assert(dest.boneMask==original)
  eq(dest.boneMask[1],"root");eq(dest.boneMask[2],"head");eq(dest.boneMask[3],"left")
  source:returnToPool();dest:returnToPool()
end)
test("copyFrom shrinks existing boneMask rather than appending",function()
  local source,dest=borrow(),borrow()
  dest.boneMask[1]="one"
  dest.boneMask[2]="two"
  dest.boneMask[3]="three"
  source.boneMask[1]="short"
  dest:copyFrom(source)
  eq(#dest.boneMask,1)
  eq(dest.boneMask[1],"short")
  assert(dest.boneMask[2]==nil and dest.boneMask[3]==nil)
  source:returnToPool();dest:returnToPool()
end)
test("copyFrom expands boneMask and copies entries by value",function()
  local source,dest=borrow(),borrow()
  source.boneMask[1]="one"
  source.boneMask[2]="two"
  dest:copyFrom(source)
  source.boneMask[1]="changed"
  eq(dest.boneMask[1],"one")
  eq(#dest.boneMask,2)
  source:returnToPool();dest:returnToPool()
end)
test("copyFrom empty boneMask removes all entries",function()
  local a,b=borrow(),borrow()
  a.boneMask[1]="head"
  a.boneMask[2]="body"
  a:copyFrom(b)
  eq(#a.boneMask,0)
  b:returnToPool();a:returnToPool()
end)
test("copyFrom self preserves values and mask entries",function()
  local a=borrow()
  a.name="idle"
  a.boneMask[1]="root"
  a.boneMask[2]="neck"
  a:copyFrom(a)
  eq(a.name,"idle")
  eq(a.boneMask[1],"root")
  eq(a.boneMask[2],"neck")
  a:returnToPool()
end)
test("copyFrom preserves unusual numeric values without normalization",function()
  local source,target=borrow(),borrow()
  source.timeScale=-42
  source.playTimes=0
  source.duration=0
  source.weight=0
  source.autoFadeOutTime=-12
  source.fadeInTime=.1875
  target:copyFrom(source)
  eq(target.timeScale,-42)
  eq(target.playTimes,0)
  eq(target.duration,0)
  eq(target.weight,0)
  eq(target.autoFadeOutTime,-12)
  eq(target.fadeInTime,.1875)
  source:returnToPool();target:returnToPool()
end)
test("copyFrom keeps fadeOutTweenType and fadeInTweenType distinct",function()
  local a,b=borrow(),borrow()
  a.fadeOutTweenType=Core.TweenType.QuadOut
  a.fadeInTweenType=Core.TweenType.QuadIn
  b:copyFrom(a)
  eq(b.fadeOutTweenType,Core.TweenType.QuadOut)
  eq(b.fadeInTweenType,Core.TweenType.QuadIn)
  a:returnToPool();b:returnToPool()
end)
test("copyFrom does not share any mutable array",function()
  local source,target=borrow(),borrow()
  source.boneMask[1]="x"
  target:copyFrom(source)
  assert(source.boneMask~=target.boneMask)
  target.boneMask[1]="y"
  eq(source.boneMask[1],"x")
  source:returnToPool();target:returnToPool()
end)
test("returnToPool applies _onClear before putting back",function()
  local a=borrow()
  local mask=a.boneMask
  local hash=a.hashCode
  a.name="edited"
  a.fadeInTime=200
  a.boneMask[1]="root"
  a:returnToPool()
  assert(a._isInPool)
  checkDefaults(a)
  local b=borrow()
  assert(b==a and b.hashCode==hash and b.boneMask==mask)
  assert(not b._isInPool)
  b:returnToPool()
end)
test("clear repeatedly is idempotent, without replacing collections",function()
  local a=borrow()
  local mask=a.boneMask
  for i=1,5 do
    a.name="x"
    a.boneMask[1]="bone"
    a:clear()
    checkDefaults(a)
    assert(a.boneMask==mask)
  end
  a:returnToPool()
end)
print(("Original AnimationConfig.ts: %d passed, %d failed"):format(passed,failed))
if failed>0 then os.exit(1) end
