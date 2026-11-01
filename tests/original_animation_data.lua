-- Conformance tests for model/AnimationData.ts at pinned DragonBonesJS commit:
-- 64b6c69ae35777c2404be68c9192e2c56906079e.
package.path="./?.lua;./?/init.lua;"..package.path
local Base=require("dragonbones.original.core.BaseObject")
local C=require("dragonbones.original.model.AnimationData")
local Animation,Timeline,AnimationTimeline=C.AnimationData,C.TimelineData,C.AnimationTimelineData
local A=require("dragonbones.original.model.ArmatureData")
local Armature,Bone,Slot=A.ArmatureData,A.BoneData,A.SlotData
local Core=require("dragonbones.original.core.DragonBones")
local passed,failed=0,0
local function test(label,fn)
  local ok,err=pcall(fn)
  if ok then passed=passed+1;print("ok original.animation_data "..label)
  else failed=failed+1;print("not ok original.animation_data "..label..": "..tostring(err)) end
end
local function equal(actual,expected)
  assert(actual==expected,tostring(actual).." != "..tostring(expected))
end
local function makeArmature()
  local arm=Base.borrowObject(Armature)
  local root=Base.borrowObject(Bone);root.name="root"
  local child=Base.borrowObject(Bone);child.name="child";child.parent=root
  local face=Base.borrowObject(Slot);face.name="face";face.parent=root
  arm:addBone(root);arm:addBone(child);arm:addSlot(face)
  return arm
end
local function makeAnimation(arm,name)
  local data=Base.borrowObject(Animation)
  data.name=name or "walk"
  arm:addAnimation(data)
  return data
end

test("three original classes and toString names",function()
  equal(Animation.toString(),"[class dragonBones.AnimationData]")
  equal(Timeline.toString(),"[class dragonBones.TimelineData]")
  equal(AnimationTimeline.toString(),"[class dragonBones.AnimationTimelineData]")
end)

test("AnimationData defaults after borrow",function()
  local d=Base.borrowObject(Animation)
  for _,name in ipairs({"frameIntOffset","frameFloatOffset","frameOffset",
    "blendType","frameCount","playTimes","duration","fadeInTime","cacheFrameRate"}) do
    equal(d[name],0)
  end
  equal(d.scale,1)
  equal(d.name,"")
  equal(d.cachedFrames.length,0)
  assert(next(d.boneTimelines)==nil and next(d.slotTimelines)==nil)
  assert(next(d.constraintTimelines)==nil and next(d.animationTimelines)==nil)
  assert(next(d.boneCachedFrameIndices)==nil and next(d.slotCachedFrameIndices)==nil)
  assert(d.actionTimeline==nil and d.zOrderTimeline==nil and d.parent==nil)
  d:returnToPool()
end)

test("AnimationData field initializer collections are distinct per instance",function()
  local a,b=Base.borrowObject(Animation),Base.borrowObject(Animation)
  for _,key in ipairs({"cachedFrames","boneTimelines","slotTimelines",
    "constraintTimelines","animationTimelines","boneCachedFrameIndices",
    "slotCachedFrameIndices"}) do
    assert(a[key]~=b[key],key)
  end
  a:returnToPool();b:returnToPool()
end)

test("TimelineData returns baseline type and offsets",function()
  local timeline=Base.borrowObject(Timeline)
  equal(timeline.type,Core.TimelineType.BoneAll)
  equal(timeline.offset,0)
  equal(timeline.frameIndicesOffset,-1)
  timeline.type=Core.TimelineType.SlotDisplay
  timeline.offset=42;timeline.frameIndicesOffset=5
  timeline:returnToPool()
  local fresh=Base.borrowObject(Timeline)
  assert(fresh==timeline)
  equal(fresh.type,Core.TimelineType.BoneAll)
  equal(fresh.offset,0)
  equal(fresh.frameIndicesOffset,-1)
  fresh:returnToPool()
end)

test("AnimationTimelineData invokes parent clear and resets x/y",function()
  local t=Base.borrowObject(AnimationTimeline)
  equal(t.type,Core.TimelineType.BoneAll)
  equal(t.x,0);equal(t.y,0)
  t.type=Core.TimelineType.AnimationProgress
  t.offset=200;t.frameIndicesOffset=9;t.x=3.25;t.y=-7.5
  t:returnToPool()
  local nextOne=Base.borrowObject(AnimationTimeline)
  assert(nextOne==t)
  equal(nextOne.type,Core.TimelineType.BoneAll)
  equal(nextOne.offset,0)
  equal(nextOne.frameIndicesOffset,-1)
  equal(nextOne.x,0);equal(nextOne.y,0)
  nextOne:returnToPool()
end)

test("addBoneTimeline deduplicates by identity, not by type or contents",function()
  local d=Base.borrowObject(Animation)
  local one,two=Base.borrowObject(Timeline),Base.borrowObject(Timeline)
  one.type=10;two.type=10
  assert(d:addBoneTimeline("arm",one)==nil)
  d:addBoneTimeline("arm",one)
  d:addBoneTimeline("arm",two)
  local list=d:getBoneTimelines("arm")
  assert(#list==2 and list[1]==one and list[2]==two)
  assert(d:getBoneTimelines("missing")==nil)
  d:returnToPool()
  assert(one._isInPool and two._isInPool)
end)

test("all four timeline maps use independent lists and original getter names",function()
  local d=Base.borrowObject(Animation)
  local a,b,c,e=Base.borrowObject(Timeline),Base.borrowObject(Timeline),
    Base.borrowObject(Timeline),Base.borrowObject(Timeline)
  d:addBoneTimeline("same",a);d:addSlotTimeline("same",b)
  d:addConstraintTimeline("same",c);d:addAnimationTimeline("same",e)
  assert(d:getBoneTimelines("same")[1]==a)
  assert(d:getSlotTimelines("same")[1]==b)
  assert(d:getConstraintTimelines("same")[1]==c)
  assert(d:getAnimationTimelines("same")[1]==e)
  assert(d:getSlotTimelines("unknown")==nil)
  assert(d:getConstraintTimelines("unknown")==nil)
  assert(d:getAnimationTimelines("unknown")==nil)
  assert(d:getBoneTimelines("same")~=d:getSlotTimelines("same"))
  d:returnToPool()
end)

test("cacheFrames computes ceil(frameRate * scale) and extra trailing frame",function()
  local arm=makeArmature()
  local d=makeAnimation(arm)
  d.scale=.5;d.duration=2.25
  assert(d:cacheFrames(24)==nil)
  equal(d.cacheFrameRate,12)
  equal(d.cachedFrames.length,28) -- ceil(12*2.25) + 1
  for _,name in ipairs({"root","child"}) do
    local indices=d:getBoneCachedFrameIndices(name)
    equal(#indices,28)
    for _,v in ipairs(indices) do equal(v,-1) end
  end
  local slot=d:getSlotCachedFrameIndices("face")
  equal(#slot,28)
  for _,v in ipairs(slot) do equal(v,-1) end
  assert(d:getBoneCachedFrameIndices("missing")==nil)
  assert(d:getSlotCachedFrameIndices("missing")==nil)
  arm:returnToPool()
end)

test("cacheFrames preserves upstream cacheFrames.length typo and array holes",function()
  local arm=makeArmature()
  local d=makeAnimation(arm)
  d.duration=.25
  d:cacheFrames(20)
  equal(d.cachedFrames.length,6)
  assert(d.cachedFrames[1]==false)
  for i=2,d.cachedFrames.length do
    assert(d.cachedFrames[i]==nil, "upstream has uninitialized array hole")
  end
  arm:returnToPool()
end)

test("cacheFrames clamp to 1 for zero frame rate and fractional scale",function()
  local arm=makeArmature()
  local d=makeAnimation(arm)
  d.scale=.1;d.duration=.25
  d:cacheFrames(0)
  equal(d.cacheFrameRate,1)
  equal(d.cachedFrames.length,2)
  equal(#d:getBoneCachedFrameIndices("root"),2)
  arm:returnToPool()
end)

test("cacheFrames returns without changing any arrays if already initialized",function()
  local arm=makeArmature()
  local d=makeAnimation(arm)
  d.duration=1
  d:cacheFrames(10)
  local frames=d.cachedFrames
  local indices=d:getBoneCachedFrameIndices("root")
  indices[1]=42
  d:cacheFrames(30)
  equal(d.cacheFrameRate,10)
  assert(d.cachedFrames==frames and d:getBoneCachedFrameIndices("root")==indices)
  equal(d.cachedFrames.length,11)
  equal(indices[1],42)
  arm:returnToPool()
end)

test("cacheFrames when duration is zero reserves one frame",function()
  local arm=makeArmature()
  local d=makeAnimation(arm)
  d:cacheFrames(60)
  equal(d.cacheFrameRate,60)
  equal(d.cachedFrames.length,1)
  assert(d.cachedFrames[1]==false)
  equal(#d:getBoneCachedFrameIndices("root"),1)
  arm:returnToPool()
end)

test("AnimationData._onClear returns action and zOrder timelines once",function()
  local d=Base.borrowObject(Animation)
  local action=Base.borrowObject(Timeline)
  local zorder=Base.borrowObject(Timeline)
  d.actionTimeline=action;d.zOrderTimeline=zorder
  d:returnToPool()
  assert(action._isInPool and zorder._isInPool)
  assert(d.actionTimeline==nil and d.zOrderTimeline==nil)
end)

test("AnimationData._onClear frees four timeline categories",function()
  local d=Base.borrowObject(Animation)
  local list={}
  for _,method in ipairs({"addBoneTimeline","addSlotTimeline",
    "addConstraintTimeline","addAnimationTimeline"}) do
    local a,b=Base.borrowObject(Timeline),Base.borrowObject(AnimationTimeline)
    d[method](d,"first",a);d[method](d,"first",b)
    list[#list+1]=a;list[#list+1]=b
  end
  local maps={d.boneTimelines,d.slotTimelines,d.constraintTimelines,d.animationTimelines}
  d:returnToPool()
  for _,timeline in ipairs(list) do assert(timeline._isInPool) end
  for _,map in ipairs(maps) do assert(next(map)==nil) end
end)

test("AnimationData._onClear retains all collections and clears frame indices",function()
  local arm=makeArmature()
  local d=makeAnimation(arm)
  d.duration=.5
  d:cacheFrames(10)
  local frames,bones,slots=d.cachedFrames,d.boneCachedFrameIndices,d.slotCachedFrameIndices
  local names={d.boneTimelines,d.slotTimelines,d.constraintTimelines,d.animationTimelines}
  d.frameIntOffset=12;d.frameFloatOffset=13;d.frameOffset=14
  d.blendType=Core.AnimationBlendType.E1D;d.frameCount=16
  d.playTimes=3;d.fadeInTime=.75
  d:returnToPool()
  assert(d.cachedFrames==frames and d.boneCachedFrameIndices==bones)
  assert(d.slotCachedFrameIndices==slots)
  for _,map in ipairs(names) do assert(next(map)==nil) end
  assert(next(bones)==nil and next(slots)==nil)
  equal(frames.length,0)
  assert(frames[1]==nil)
  equal(d.frameIntOffset,0);equal(d.frameFloatOffset,0);equal(d.frameOffset,0)
  equal(d.blendType,Core.AnimationBlendType.None);equal(d.frameCount,0)
  equal(d.playTimes,0);equal(d.duration,0);equal(d.scale,1)
  equal(d.fadeInTime,0);equal(d.cacheFrameRate,0)
  assert(d.parent==nil)
  -- Remove recycled AnimationData reference from the armature before cleaning it:
  -- the test deliberately calls returnToPool directly here.
  arm.animations[d.name]=nil
  arm:returnToPool()
end)

test("ArmatureData.cacheFrames delegates to actual ported AnimationData",function()
  local arm=makeArmature()
  local d=makeAnimation(arm)
  d.duration=1.5;d.scale=.5
  arm:cacheFrames(20)
  equal(arm.cacheFrameRate,20)
  equal(d.cacheFrameRate,10)
  equal(d.cachedFrames.length,16)
  arm:returnToPool()
end)

print(("Original AnimationData.ts: %d passed, %d failed"):format(passed,failed))
if failed>0 then os.exit(1) end
