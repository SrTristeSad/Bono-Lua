-- Original ObjectDataParser.ts generic timeline and frame methods:
-- DragonBonesJS 64b6c69ae35777c2404be68c9192e2c56906079e
-- Source lines 1210-1311, 1430-1637. Lua5.4 + LuaJIT conformance.
package.path="./?.lua;./?/init.lua;"..package.path
local Pool=require("dragonbones.original.core.BaseObject")
local Parser=require("dragonbones.original.parser.ObjectDataParser")
local Model=require("dragonbones.original.model.AnimationData")
local Arm=require("dragonbones.original.model.ArmatureData")
local DB=require("dragonbones.original.model.DragonBonesData")
local Core=require("dragonbones.original.core.DragonBones")
local F=Parser.FrameValueType
local B=Core.BinaryOffset
local TT=Core.TimelineType
local Tween=Core.TweenType
local passed,failed,checks=0,0,0
local function eq(a,b)
  checks=checks+1
  assert(a==b,tostring(a).." ~= "..tostring(b))
end
local function near(a,b)
  checks=checks+1
  assert(type(a)=="number" and type(b)=="number"
    and math.abs(a-b)<1e-7,tostring(a).." ~= "..tostring(b))
end
local function test(name,fn)
  local ok,err=pcall(fn)
  if ok then passed=passed+1;print("ok original.parser_timeline "..name)
  else failed=failed+1
    print("not ok original.parser_timeline "..name..": "..tostring(err)) end
end
local function fixture(frameCount)
  local p=Parser.new()
  p._data=Pool.borrowObject(DB)
  p._armature=Pool.borrowObject(Arm.ArmatureData)
  p._armature.frameRate=10
  local animation=Pool.borrowObject(Model.AnimationData)
  animation.frameCount=frameCount or 10
  animation.frameIntOffset=0
  animation.frameFloatOffset=0
  animation.frameOffset=0
  p._animation=animation
  return p,animation
end
local function parse(p,raw,framesKey,t,valueType,count,parser,timeline)
  return p:_parseTimeline(raw,nil,framesKey or "frame",t or TT.BoneTranslate,
    valueType or F.Float,count or 2,parser or p._parseDoubleValueFrame,timeline)
end
local function val(p,i) return p._timelineArray[i+1] end
local function ix(p,i) return p._data.frameIndices[i+1] end

test("parseFrame stores zero-based offset and given starting frame",function()
  local p=fixture()
  eq(p:_parseFrame({},4,12),0)
  eq(p._frameArray[1],4)
  eq(p:_parseFrame({},9,0),1)
  eq(p._frameArray[2],9)
end)
test("no tween is encoded as FrameTweenType.None",function()
  local p=fixture()
  p:_parseTweenFrame({},2,3)
  eq(#p._frameArray,2)
  eq(p._frameArray[1],2)
  eq(p._frameArray[2],Tween.None)
end)
test("zero duration prevents easing regardless of tweenEasing",function()
  local p=fixture()
  p:_parseTweenFrame({tweenEasing=1},0,0)
  eq(p._frameArray[2],Tween.None)
end)
test("explicit zero easing yields linear interpolation",function()
  local p=fixture()
  p:_parseTweenFrame({tweenEasing=0},0,4)
  eq(p._frameArray[2],Tween.Line)
  eq(#p._frameArray,2)
end)
test("negative easing yields QuadIn with exact percentage",function()
  local p=fixture()
  p:_parseTweenFrame({tweenEasing=-0.35},3,4)
  eq(p._frameArray[2],Tween.QuadIn)
  eq(p._frameArray[3],35)
end)
test("positive easing up to one uses QuadOut",function()
  local p=fixture()
  p:_parseTweenFrame({tweenEasing=0.75},3,4)
  eq(p._frameArray[2],Tween.QuadOut)
  eq(p._frameArray[3],75)
end)
test("easing greater than one uses QuadInOut minus 100",function()
  local p=fixture()
  p:_parseTweenFrame({tweenEasing=1.25},3,4)
  eq(p._frameArray[2],Tween.QuadInOut)
  eq(p._frameArray[3],25)
end)
test("special easing -2 means the original No Tween sentinel",function()
  local p=fixture()
  p:_parseTweenFrame({tweenEasing=-2},0,10)
  eq(p._frameArray[2],Tween.None)
end)
test("negative-half tie in JS Math.round rounds towards positive infinity",function()
  local p=fixture()
  p:_parseTweenFrame({tweenEasing=-0.005},0,10)
  eq(p._frameArray[3],1)
end)
test("curve easing samples and encodes 10k fixed point",function()
  local p=fixture()
  p:_parseTweenFrame({curve={1/3,1/3,2/3,2/3}},0,2)
  eq(p._frameArray[2],Tween.Curve)
  eq(p._frameArray[3],3)
  near(p._frameArray[4],2500)
  near(p._frameArray[5],5000)
  near(p._frameArray[6],7500)
end)
test("curve easing with explicit endpoints marks negative sample count",function()
  local p=fixture()
  p:_parseTweenFrame({curve={0,0,1/3,1/3,2/3,2/3,1,1}},0,2)
  eq(p._frameArray[2],Tween.Curve)
  eq(p._frameArray[3],-3)
end)
test("subsequent frames append after previous frame's extra values",function()
  local p=fixture()
  local first=p:_parseTweenFrame({tweenEasing=-0.5},0,4)
  local second=p:_parseTweenFrame({tweenEasing=0},4,2)
  eq(first,0)
  eq(second,3)
  eq(p._frameArray[4],4)
  eq(p._frameArray[5],Tween.Line)
end)
test("step single value writes value beside position",function()
  local p=fixture()
  p._frameValueType=F.Step
  p._frameDefaultValue=2
  eq(p:_parseSingleValueFrame({},3,0),0)
  eq(p._frameArray[1],3)
  eq(p._frameArray[2],2)
  eq(#p._frameIntArray,0)
end)
test("integer single value applies frame scale and JS rounding",function()
  local p=fixture()
  p._frameValueType=F.Int
  p._frameValueScale=100
  p:_parseSingleValueFrame({value=0.125,tweenEasing=0},0,4)
  eq(p._frameIntArray[1],13)
  eq(p._frameArray[2],Tween.Line)
end)
test("float single value stores non-rounded scaled quantity",function()
  local p=fixture()
  p._frameValueType=F.Float
  p._frameValueScale=math.pi/180
  p:_parseSingleValueFrame({value=90},0,4)
  near(p._frameFloatArray[1],math.pi/2)
end)
test("step double value writes both x and y into frameArray",function()
  local p=fixture()
  p._frameValueType=F.Step
  p._frameDefaultValue=-3
  p:_parseDoubleValueFrame({x=5},2,0)
  eq(p._frameArray[1],2)
  eq(p._frameArray[2],5)
  eq(p._frameArray[3],-3)
end)
test("integer double values round negative halves per Math.round",function()
  local p=fixture()
  p._frameValueType=F.Int
  p._frameValueScale=10
  p:_parseDoubleValueFrame({x=-0.15,y=0.15},0,4)
  eq(p._frameIntArray[1],-1)
  eq(p._frameIntArray[2],2)
end)
test("float double value stores x/y and uses default without truncation",function()
  local p=fixture()
  p._frameValueType=F.Float
  p._frameDefaultValue=4
  p._frameValueScale=2
  p:_parseDoubleValueFrame({x=1.25},1,4)
  near(p._frameFloatArray[1],2.5)
  near(p._frameFloatArray[2],8)
end)
test("action frame stores action count and zero-based action indices",function()
  local p=fixture()
  local a=Parser.ActionFrame.new()
  a.actions={0,7,2}
  p:_parseActionFrame(a,5,2)
  eq(#p._frameArray,5)
  eq(p._frameArray[1],5)
  eq(p._frameArray[2],3)
  eq(p._frameArray[3],0)
  eq(p._frameArray[4],7)
  eq(p._frameArray[5],2)
end)
test("zOrder without any slot permutation writes zero count",function()
  local p=fixture()
  p:_parseZOrderFrame({},0,0)
  eq(p._frameArray[1],0)
  eq(p._frameArray[2],0)
end)
test("zOrder simple swap translates original slot ordering",function()
  local p=fixture()
  p._armature.sortedSlots={{name="a"},{name="b"},{name="c"}}
  p:_parseZOrderFrame({zOrder={0,1,1,-1}},4,6)
  eq(p._frameArray[1],4)
  eq(p._frameArray[2],3)
  eq(p._frameArray[3],1)
  eq(p._frameArray[4],0)
  eq(p._frameArray[5],2)
end)
test("timeline with no keyframes returns nil and does not allocate",function()
  local p=fixture()
  eq(parse(p,{frame={}}),nil)
  eq(#p._timelineArray,0)
  eq(#p._frameArray,0)
end)
test("timeline without frame key returns nil and does not allocate",function()
  local p=fixture()
  eq(parse(p,{}),nil)
  eq(#p._data.frameIndices,0)
end)
test("single frame timeline has no frameIndices and offset zero",function()
  local p=fixture()
  local t=parse(p,{frame={{value=5}}},"frame",TT.BoneAlpha,F.Int,1,
    p._parseSingleValueFrame)
  eq(getmetatable(t),Model.TimelineData)
  eq(t.type,TT.BoneAlpha)
  eq(t.offset,0)
  eq(t.frameIndicesOffset,-1)
  eq(val(p,B.TimelineScale),100)
  eq(val(p,B.TimelineOffset),0)
  eq(val(p,B.TimelineKeyFrameCount),1)
  eq(val(p,B.TimelineFrameValueCount),1)
  eq(val(p,B.TimelineFrameValueOffset),0)
  eq(val(p,B.TimelineFrameOffset),0)
  eq(p._frameIntArray[1],5)
  eq(#p._data.frameIndices,0)
  eq(p._timeline,nil)
end)
test("two-frame timeline maps every animation frame plus endpoint",function()
  local p=fixture(10)
  local t=parse(p,{frame={{duration=4,x=1,y=2},{duration=6,x=3,y=4}}},
    "frame",TT.BoneTranslate,F.Float,2)
  eq(t.frameIndicesOffset,0)
  eq(#p._data.frameIndices,11)
  for i=0,3 do eq(ix(p,i),0) end
  for i=4,10 do eq(ix(p,i),1) end
  eq(p._frameFloatArray[1],1)
  eq(p._frameFloatArray[2],2)
  eq(p._frameFloatArray[3],3)
  eq(p._frameFloatArray[4],4)
  eq(val(p,B.TimelineFrameOffset),0)
  eq(val(p,B.TimelineFrameOffset+1),2)
end)
test("timeline offsets grow across multiple timeline channels",function()
  local p=fixture(10)
  p._frameIntArray={3,4}
  p._frameFloatArray={11,12,13}
  p._frameArray={7,8,9,10}
  p._animation.frameOffset=2
  p._animation.frameIntOffset=1
  p._animation.frameFloatOffset=2
  local a=parse(p,{frame={{value=2}}},"frame",TT.BoneAlpha,
    F.Int,1,p._parseSingleValueFrame)
  eq(a.offset,0)
  eq(val(p,B.TimelineFrameValueOffset),1)
  eq(val(p,B.TimelineFrameOffset),2)
  local b=parse(p,{frame={{x=2,y=4}}},"frame",
    TT.BoneTranslate,F.Float,2,p._parseDoubleValueFrame)
  eq(b.offset,6)
  eq(val(p,b.offset+B.TimelineFrameValueOffset),1)
  eq(val(p,b.offset+B.TimelineFrameOffset),4)
end)
test("timeline scale and offset use original integer percentage",function()
  local p=fixture()
  local t=parse(p,{scale=1.255,offset=-0.055,
    frame={{value=1}}},"frame",TT.BoneAlpha,F.Int,1,
    p._parseSingleValueFrame)
  eq(val(p,t.offset+B.TimelineScale),125)
  eq(val(p,t.offset+B.TimelineOffset),-5)
end)
test("multiple timelines each have independent index mapping offsets",function()
  local p=fixture(6)
  local a=parse(p,{frame={{duration=2,value=1},{duration=4,value=3}}},
    "frame",TT.SlotAlpha,F.Int,1,p._parseSingleValueFrame)
  local b=parse(p,{frame={{duration=4,value=1},{duration=2,value=3}}},
    "frame",TT.BoneAlpha,F.Int,1,p._parseSingleValueFrame)
  eq(a.frameIndicesOffset,0)
  eq(b.frameIndicesOffset,7)
  eq(#p._data.frameIndices,14)
  eq(ix(p,2),1)
  eq(ix(p,7+2),0)
end)
test("one frame parser callback receives last frame count zero",function()
  local p=fixture()
  local seen={}
  local function fn(self,raw,at,count)
    seen={self,raw,at,count}
    return self:_parseFrame(raw,at,count)
  end
  local data={frame={{tag="one"}}}
  parse(p,data,"frame",TT.Action,F.Step,0,fn)
  eq(seen[1],p)
  eq(seen[2],data.frame[1])
  eq(seen[3],0);eq(seen[4],0)
end)
test("ActionFrame timeline computes per-frame lengths from action positions",function()
  local p=fixture(10)
  local first=Parser.ActionFrame.new()
  first.frameStart=0;first.actions={0}
  local second=Parser.ActionFrame.new()
  second.frameStart=6;second.actions={1}
  p._actionFrames={first,second}
  local t=p:_parseTimeline(nil,p._actionFrames,"",TT.Action,F.Step,0,
    p._parseActionFrame)
  eq(t.frameIndicesOffset,0)
  eq(ix(p,5),0)
  eq(ix(p,6),1)
  eq(p._frameArray[1],0)
  eq(p._frameArray[2],1)
  eq(p._frameArray[4],6)
end)
test("preallocated timeline is reused and its type/offset replaced",function()
  local p=fixture()
  local t=Pool.borrowObject(Model.AnimationTimelineData)
  t.x=0.7
  local parsed=p:_parseTimeline({frame={{value=2}}},nil,"frame",
    TT.AnimationProgress,F.Int,1,p._parseSingleValueFrame,t)
  eq(parsed,t)
  eq(getmetatable(parsed),Model.AnimationTimelineData)
  eq(parsed.x,0.7)
  eq(parsed.type,TT.AnimationProgress)
end)
test("timeline with explicit rawFrames and empty key bypasses rawData field",function()
  local p=fixture()
  local t=p:_parseTimeline({scale=0.5},{{value=3}},"",
    TT.AnimationWeight,F.Int,1,p._parseSingleValueFrame)
  eq(t.type,TT.AnimationWeight)
  eq(val(p,B.TimelineScale),50)
end)
print(("Original ObjectDataParser timeline: %d passed, %d failed, %d assertions")
  :format(passed,failed,checks))
if failed>0 then os.exit(1) end
