-- Source-faithful animation and deform parser tests.
-- DragonBonesJS ObjectDataParser.ts at
-- 64b6c69ae35777c2404be68c9192e2c56906079e (MIT).
-- Exercises actual public parseDragonBonesData and original model classes.
package.path="./?.lua;./?/init.lua;"..package.path
local Parser=require("dragonbones.original.parser.ObjectDataParser")
local JSON=require("dragonbones.json")
local Core=require("dragonbones.original.core.DragonBones")
local Models=require("dragonbones.original.model.AnimationData")
local Display=require("dragonbones.original.model.DisplayData")
local TT=Core.TimelineType
local B=Core.BinaryOffset
local passed,failed,checks=0,0,0
local function eq(a,b)
  checks=checks+1
  assert(a==b,tostring(a).." ~= "..tostring(b))
end
local function near(a,b,eps)
  checks=checks+1
  assert(type(a)=="number" and type(b)=="number" and math.abs(a-b)<(eps or 1e-6),
    tostring(a).." ~= "..tostring(b))
end
local function test(name,fn)
  local ok,err=pcall(fn)
  if ok then passed=passed+1;print("ok original.animated_json "..name)
  else failed=failed+1;print("not ok original.animated_json "..name..": "..tostring(err)) end
end
local function document(animations)
  return {
    version="5.5",name="scene",frameRate=24,
    armature={{
      name="arm",frameRate=24,
      bone={{name="root"},{name="hand",parent="root"},{name="target"}},
      slot={{name="hand",parent="hand"},{name="other",parent="root"}},
      skin={{name="default",slot={{name="hand",display={{
        name="image",type="image"}}}}}},
      ik={{name="IK",bone="hand",target="target",chain=1}},
      animation=animations or {}
    }}
  }
end
local function parse(raw)
  return Parser.new():parseDragonBonesData(raw)
end
local function onlyAnimation(raw)
  local data=parse(document({raw}))
  return data,data:getArmature("arm"):getAnimation(raw.name or "default")
end
local function sourceFixture()
  local f=assert(io.open("tests/fixtures/personagem-minimo.json","rb"))
  local raw=JSON.decode(f:read("*a"));f:close()
  return raw
end
local function get(p,offset)
  return p[offset+1]
end

test("full authored DragonBones JSON with idle walk and swap imports unchanged",function()
  local data=parse(sourceFixture())
  local rig=data:getArmature("PersonagemA")
  eq(#rig.animationNames,3)
  eq(rig:getAnimation("idle").frameCount,24)
  eq(rig:getAnimation("walk").frameCount,48)
  eq(rig:getAnimation("swap").frameCount,24)
  eq(rig.defaultAnimation.name,"idle")
  eq(#rig:getAnimation("walk"):getBoneTimelines("upperArm"),2)
  eq(#rig:getAnimation("swap"):getSlotTimelines("upperArm"),1)
  eq(type(data.binary),"string")
  eq(#data.binary>0,true)
end)
test("animation metadata retains frame duration, play count and scale",function()
  local data,a=onlyAnimation({name="a",duration=36,playTimes=2,
    fadeInTime=0.4,scale=0.6})
  eq(a.frameCount,36)
  near(a.duration,1.5)
  eq(a.playTimes,2)
  near(a.fadeInTime,0.4)
  near(a.scale,0.6)
  eq(a.parent,data:getArmature("arm"))
end)
test("animation default name and playTimes use source values",function()
  local data,a=onlyAnimation({name="",duration=24})
  eq(a.name,"default")
  eq(a.playTimes,1)
  near(a.duration,1.0)
end)
test("animation buffers have independent offsets within a common document",function()
  local data=parse(document({
    {name="first",duration=10,bone={{name="root",
      translateFrame={{x=1,y=2}}}}},
    {name="second",duration=10,bone={{name="hand",
      rotateFrame={{rotate=90}}}}}
  }))
  local rig=data:getArmature("arm")
  local a=rig:getAnimation("first")
  local b=rig:getAnimation("second")
  eq(a.frameFloatOffset,0)
  eq(b.frameFloatOffset,2)
  eq(b.frameOffset>0,true)
  eq(b:getBoneTimelines("hand")[1].type,TT.BoneRotate)
end)
test("top-level animation frame events become a real action timeline",function()
  local data,a=onlyAnimation({name="a",duration=12,frame={
    {duration=6,event="start"},
    {duration=6,sound="hit"}
  }})
  eq(a.actionTimeline.type,TT.Action)
  eq(#data:getArmature("arm").actions,2)
  eq(data:getArmature("arm").actions[1].name,"start")
  eq(data:getArmature("arm").actions[2].type,Core.ActionType.Sound)
  eq(a.actionTimeline.frameIndicesOffset,0)
end)
test("animation event frame positions remain in frame indices",function()
  local data,a=onlyAnimation({name="a",duration=12,frame={
    {duration=4,event="first"},
    {duration=8,event="second"}
  }})
  local index=a.actionTimeline.frameIndicesOffset
  eq(get(data.frameIndices,index+3),0)
  eq(get(data.frameIndices,index+4),1)
end)
test("single animation event action timeline has zero-based action index",function()
  local data,a=onlyAnimation({name="a",duration=8,frame={
    {duration=8,event="tap"}
  }})
  local offset=a.actionTimeline.offset
  local frameOffset=a.frameOffset+
    get(data.timelineArray,offset+B.TimelineFrameOffset)
  eq(get(data.frameArray,frameOffset+1),1)
  eq(get(data.frameArray,frameOffset+2),0)
end)
test("zOrder timeline uses original frame positions and slot count",function()
  local data,a=onlyAnimation({name="a",duration=8,zOrder={frame={
    {duration=8,zOrder={0,1,1,-1}}
  }}})
  eq(a.zOrderTimeline.type,TT.ZOrder)
  local offset=a.frameOffset+
    get(data.timelineArray,a.zOrderTimeline.offset+B.TimelineFrameOffset)
  eq(get(data.frameArray,offset+1),2)
  eq(get(data.frameArray,offset+2),1)
  eq(get(data.frameArray,offset+3),0)
end)
test("legacy bone translate and rotate channels load from public parser",function()
  local data,a=onlyAnimation({name="a",duration=12,bone={{
    name="hand",translateFrame={{duration=6,x=4,y=5},{duration=6,x=8,y=9}},
    rotateFrame={{duration=6,rotate=170},{duration=6,rotate=-170}}
  }}})
  eq(#a:getBoneTimelines("hand"),2)
  eq(a:getBoneTimelines("hand")[1].type,TT.BoneTranslate)
  eq(a:getBoneTimelines("hand")[2].type,TT.BoneRotate)
  eq(#data.frameIndices,26)
  near(data.frameFloatArray[7],170*math.pi/180)
  near(data.frameFloatArray[9],190*math.pi/180)
end)
test("legacy slot display and color channels retain their own timeline",function()
  local data,a=onlyAnimation({name="a",duration=12,slot={{
    name="hand",displayFrame={{value=1}},
    colorFrame={{color={rM=55}}}
  }}})
  eq(#a:getSlotTimelines("hand"),2)
  eq(a:getSlotTimelines("hand")[1].type,TT.SlotDisplay)
  eq(a:getSlotTimelines("hand")[2].type,TT.SlotColor)
  eq(data.colorArray[2],55)
end)
test("IK timeline binds the actual named constraint",function()
  local data,a=onlyAnimation({name="a",duration=12,ik={{
    name="IK",frame={{bendPositive=false,weight=0.5}}
  }}})
  eq(#a:getConstraintTimelines("IK"),1)
  eq(a:getConstraintTimelines("IK")[1].type,TT.IKConstraint)
  eq(data.frameIntArray[1],0)
  eq(data.frameIntArray[2],50)
end)
test("unknown constraint timeline is skipped without allocations",function()
  local data,a=onlyAnimation({name="a",duration=12,ik={{
    name="MISSING",frame={{bendPositive=true}}
  }}})
  eq(a:getConstraintTimelines("MISSING"),nil)
  eq(#data.frameIntArray,0)
end)
test("missing FFD mesh does not create a bogus deform timeline",function()
  local data,a=onlyAnimation({name="a",duration=12,ffd={{
    slot="hand",name="missing",frame={{vertices={2,3}}}
  }}})
  eq(a:getSlotTimelines("hand"),nil)
end)
test("unweighted FFD mesh writes vertex deform data and five-value header",function()
  local raw=document({{name="a",duration=12,ffd={{
    skin="default",slot="hand",name="mesh",
    frame={{vertices={1,2,3,4},offset=0}}
  }}}})
  raw.armature[1].skin[1].slot[1].display={{
    type="mesh",name="mesh",vertices={0,0,4,0},
    uvs={0,0,1,0},triangles={}
  }}
  local data=parse(raw)
  local a=data:getArmature("arm"):getAnimation("a")
  local timeline=a:getSlotTimelines("hand")[1]
  eq(timeline.type,TT.SlotDeform)
  eq(#data.frameFloatArray,4)
  near(data.frameFloatArray[1],1)
  near(data.frameFloatArray[4],4)
  eq(data.frameIntArray[2],4)
  eq(data.frameIntArray[3],4)
end)
test("FFD fills missing vertices with zero preserving provided offset",function()
  local raw=document({{name="a",duration=12,ffd={{
    slot="hand",name="mesh",
    frame={{offset=2,vertices={7,8}}}
  }}}})
  raw.armature[1].skin[1].slot[1].display={{
    type="mesh",name="mesh",vertices={0,0,4,0,8,0},
    uvs={0,0,0.5,0,1,0},triangles={0,1,2}
  }}
  local data=parse(raw)
  eq(#data.frameFloatArray,6)
  near(data.frameFloatArray[1],0)
  near(data.frameFloatArray[2],0)
  near(data.frameFloatArray[3],7)
  near(data.frameFloatArray[4],8)
  near(data.frameFloatArray[5],0)
end)
test("FFD multiple frames retain one deform header and append frame values",function()
  local raw=document({{name="a",duration=12,ffd={{
    slot="hand",name="mesh",frame={
      {duration=6,vertices={1,2}},
      {duration=6,vertices={3,4}}
    }
  }}}})
  raw.armature[1].skin[1].slot[1].display={{
    type="mesh",name="mesh",vertices={0,0},uvs={0,0}
  }}
  local data=parse(raw)
  local anim=data:getArmature("arm"):getAnimation("a")
  local timeline=anim:getSlotTimelines("hand")[1]
  eq(timeline.frameIndicesOffset,0)
  eq(#data.frameFloatArray,4)
  eq(#data.frameIntArray,6) -- five deform values plus Int16 alignment.
  eq(data.frameIntArray[2],2)
  near(data.frameFloatArray[3],3)
end)
test("generic BoneAlpha timeline stores weighted 100-unit alpha",function()
  local data,a=onlyAnimation({name="a",duration=10,timeline={{
    type=TT.BoneAlpha,name="hand",frame={{value=0.25}}
  }}})
  eq(a:getBoneTimelines("hand")[1].type,TT.BoneAlpha)
  eq(data.frameIntArray[1],25)
end)
test("generic SlotZIndex timeline uses integer step scaling",function()
  local data,a=onlyAnimation({name="a",duration=10,timeline={{
    type=TT.SlotZIndex,name="hand",frame={{value=-3}}
  }}})
  eq(a:getSlotTimelines("hand")[1].type,TT.SlotZIndex)
  eq(data.frameIntArray[1],-3)
end)
test("generic AnimationWeight timeline uses 10000x multiplier and default one",function()
  local data,a=onlyAnimation({name="a",duration=10,timeline={{
    type=TT.AnimationWeight,name="child",frame={{}}
  }}})
  eq(a:getAnimationTimelines("child")[1].type,TT.AnimationWeight)
  eq(data.frameIntArray[1],10000)
end)
test("generic AnimationParameter timeline serializes both axes into int units",function()
  local data,a=onlyAnimation({name="a",duration=10,timeline={{
    type=TT.AnimationParameter,name="child",frame={{x=0.25,y=-0.4}}
  }}})
  eq(a:getAnimationTimelines("child")[1].type,TT.AnimationParameter)
  eq(data.frameIntArray[1],2500)
  eq(data.frameIntArray[2],-4000)
end)
test("generic BoneRotate uses degree to radian scale, not percent",function()
  local data,a=onlyAnimation({name="a",duration=10,timeline={{
    type=TT.BoneRotate,name="hand",frame={{x=90,y=45}}
  }}})
  eq(a:getBoneTimelines("hand")[1].type,TT.BoneRotate)
  near(data.frameFloatArray[1],math.pi/2)
  near(data.frameFloatArray[2],math.pi/4)
end)
test("generic SlotColor timeline stores color data through matching parser",function()
  local data,a=onlyAnimation({name="a",duration=10,timeline={{
    type=TT.SlotColor,name="hand",frame={{color={aM=60}}}
  }}})
  eq(a:getSlotTimelines("hand")[1].type,TT.SlotColor)
  eq(data.colorArray[1],60)
  eq(data.frameIntArray[1],0)
end)
test("generic AnimationProgress with blendType E1D uses AnimationTimelineData",function()
  local data,a=onlyAnimation({name="a",duration=10,blendType="1d",timeline={{
    type=TT.AnimationProgress,name="child",x=0.2,y=0.7,
    frame={{value=0.5}}
  }}})
  local tl=a:getAnimationTimelines("child")[1]
  eq(tl.type,TT.AnimationProgress)
  if a.blendType~=Core.AnimationBlendType.None then
    eq(getmetatable(tl),Models.AnimationTimelineData)
    near(tl.x,0.2);near(tl.y,0.7)
  end
end)
test("generic Action and ZOrder TODO branches remain unimplemented as original",function()
  local data,a=onlyAnimation({name="a",duration=10,timeline={{
    type=TT.Action,name="ignored",frame={{value=2}}},
    {type=TT.ZOrder,name="ignored",frame={{value=3}}}
  }})
  eq(a.actionTimeline,nil)
  eq(a.zOrderTimeline,nil)
  eq(#data.frameArray,0)
end)
test("generic unweighted Surface deformation dispatch uses original geometry",function()
  local raw=document({{name="a",duration=12,timeline={{
    type=TT.Surface,name="surface",frame={{vertices={2,3,4,5}}}
  }}}})
  raw.armature[1].bone[#raw.armature[1].bone+1]={
    name="surface",type="surface",vertices={0,0,1,1}
  }
  local data=parse(raw)
  local a=data:getArmature("arm"):getAnimation("a")
  eq(a:getBoneTimelines("surface")[1].type,TT.Surface)
  eq(#data.frameFloatArray,4)
  near(data.frameFloatArray[1],2)
  near(data.frameFloatArray[4],5)
end)
test("generic SlotDeform resolves mesh geometry by name across skins",function()
  local raw=document({{name="a",duration=10,timeline={{
    type=TT.SlotDeform,name="mesh",frame={{value={9,8}}}
  }}}})
  raw.armature[1].skin[1].slot[1].display={{
    type="mesh",name="mesh",vertices={0,0},uvs={0,0}
  }}
  local data=parse(raw)
  local a=data:getArmature("arm"):getAnimation("a")
  eq(a:getSlotTimelines("mesh")[1].type,TT.SlotDeform)
  near(data.frameFloatArray[1],9)
  near(data.frameFloatArray[2],8)
end)
test("multiple animations reset parser state but retain one DragonBonesData blob",function()
  local raw=document({
    {name="one",duration=12,bone={{name="hand",translateFrame={{x=1,y=2}}}}},
    {name="two",duration=12,bone={{name="hand",translateFrame={{x=3,y=4}}}}}
  })
  local p=Parser.new()
  local data=p:parseDragonBonesData(raw)
  local rig=data:getArmature("arm")
  eq(#rig.animationNames,2)
  eq(#data.frameFloatArray,4)
  eq(rig:getAnimation("one").frameFloatOffset,0)
  eq(rig:getAnimation("two").frameFloatOffset,2)
  eq(p._animation,nil)
  eq(p._armature,nil)
  eq(p._data,nil)
end)
print(("Original ObjectDataParser animated JSON: %d passed, %d failed, %d assertions")
  :format(passed,failed,checks))
if failed>0 then os.exit(1) end
