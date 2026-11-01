-- Conformance scenarios for all five classes from BaseTimelineState.ts.
-- DragonBonesJS pinned at 64b6c69ae35777c2404be68c9192e2c56906079e.
-- Source-level contracts only; these tests do not claim TS runtime equivalence.
package.path="./?.lua;./?/init.lua;"..package.path
local Base=require("dragonbones.original.core.BaseObject")
local Types=require("dragonbones.original.core.DragonBones")
local M=require("dragonbones.original.animation.BaseTimelineState")
local Timeline=M.TimelineState
local Tween=M.TweenTimelineState
local Single=M.SingleValueTimelineState
local Double=M.DoubleValueTimelineState
local Multiple=M.MutilpleValueTimelineState
local passed,failed,checks=0,0,0
local function eq(a,b)
  checks=checks+1
  assert(a==b,tostring(a).." ~= "..tostring(b))
end
local function near(a,b)
  checks=checks+1
  assert(type(a)=="number" and type(b)=="number" and math.abs(a-b)<1e-7,
    tostring(a).." ~= "..tostring(b))
end
local function test(name,fn)
  local ok,err=pcall(fn)
  if ok then passed=passed+1;print("ok original.base_timeline "..name)
  else failed=failed+1;print("not ok original.base_timeline "..name..": "..tostring(err)) end
end
local function concrete(parent)
  local C={}
  C.__index=C
  setmetatable(C,{__index=parent})
  function C.new() return parent.new(C) end
  if parent==Timeline then
    function C:_onArriveAtFrame() self.arrivals=(self.arrivals or 0)+1 end
    function C:_onUpdateFrame() self.updates=(self.updates or 0)+1 end
  end
  return C
end
local T=concrete(Timeline)
local TW=concrete(Tween)
local S=concrete(Single)
local D=concrete(Double)
local V=concrete(Multiple)
-- The source does not implement abstract frame callbacks on TimelineState.
local function ctx(count)
  if count==nil then count=2 end
  local db={
    frameArray={0,Types.TweenType.Line,0,10,Types.TweenType.None,0},
    frameIndices={},timelineArray={100,0,count,0,0,0,3}
  }
  for i=0,40 do db.frameIndices[i+1]=i<10 and 0 or 1 end
  local armData={frameRate=10,parent=db}
  local animData={parent=armData,frameOffset=0,duration=2}
  local action=nil
  local state={animationData=animData,_actionTimeline=action,
    _position=0,_duration=2,_playheadState=3,playTimes=1,currentPlayTimes=0}
  local timelineData={offset=0,frameIndicesOffset=0}
  return state,timelineData,db,animData
end
local function ready(class,count)
  local state,td,db,animData=ctx(count)
  local t=Base.borrowObject(class)
  t:init({},state,td)
  return t,state,td,db,animData
end
local function withSingle(values,scale)
  local t,state,td,db=ready(S)
  t._valueArray=values or {10,30}
  t._valueScale=scale or 1
  return t,state,td,db
end
local function withDouble(values,scale)
  local t,state,td,db=ready(D)
  t._valueArray=values or {2,4,10,20}
  t._valueScale=scale or 1
  return t,state,td,db
end
local function withMultiple(values,scale,count)
  local t,state,td,db=ready(V)
  t._valueCount=count or 3
  t._valueArray=values or {1,2,3,5,6,7}
  t._valueScale=scale or 1
  return t,state,td,db
end

test("five source classes exported with original spellings",function()
  eq(type(Timeline),"table");eq(type(Tween),"table")
  eq(type(Single),"table");eq(type(Double),"table")
  eq(type(Multiple),"table")
  eq(M.MutilpleValueTimelineState,Multiple)
  eq(M.MultipleValueTimelineState,nil)
end)
test("abstract base does not invent concrete frame hooks",function()
  eq(Timeline._onArriveAtFrame,nil)
  eq(Timeline._onUpdateFrame,nil)
  eq(type(Timeline.update),"function")
  eq(type(Tween._onArriveAtFrame),"function")
end)
test("all classes resolve BaseObject methods through Lua inheritance",function()
  for _,cls in ipairs({T,TW,S,D,V}) do
    local x=Base.borrowObject(cls)
    eq(getmetatable(x),cls)
    eq(type(x.returnToPool),"function")
    x:returnToPool()
  end
end)
test("timeline initial state uses original defaults",function()
  local t=Base.borrowObject(T)
  eq(t.dirty,false);eq(t.playState,-1)
  eq(t.currentPlayTimes,0);near(t.currentTime,-1)
  eq(t.target,nil);eq(t._isTween,false)
  eq(t._frameIndex,-1);eq(t._frameCount,0)
  eq(t._animationData,nil);eq(t._actionTimeline,nil)
  near(t._timeScale,1);near(t._timeOffset,0)
  near(t._duration,0);near(t._position,0)
end)
test("tween class initializes easing fields",function()
  local t=Base.borrowObject(TW)
  eq(t._tweenType,Types.TweenType.None)
  eq(t._curveCount,0);near(t._tweenEasing,0)
  near(t._tweenProgress,0);near(t._valueScale,1)
  near(t._frameDurationR,0)
end)
test("scalar subclasses initialize their value fields",function()
  local s=Base.borrowObject(S)
  near(s._current,0);near(s._difference,0);near(s._result,0)
  local d=Base.borrowObject(D)
  for _,key in ipairs({"_currentA","_currentB","_differenceA",
      "_differenceB","_resultA","_resultB"}) do near(d[key],0) end
end)
test("multiple-value constructor keeps a private array for each instance",function()
  local a,b=Base.borrowObject(V),Base.borrowObject(V)
  eq(a._valueCount,0);eq(b._valueCount,0)
  assert(a._rd~=b._rd)
  eq(#a._rd,0)
end)
test("init reads zero-based source arrays and timeline offsets",function()
  local t,state,td,db,anim=ready(T)
  eq(t._animationState,state);eq(t._animationData,anim)
  eq(t._timelineData,td)
  eq(t._frameArray,db.frameArray)
  eq(t._timelineArray,db.timelineArray)
  eq(t._frameIndices,db.frameIndices)
  eq(t._frameCount,2)
  near(t._frameRate,10);near(t._frameRateR,0.1)
  near(t._timeScale,1);near(t._timeOffset,0)
end)
test("init leaves arrays and count untouched for pose timeline",function()
  local state=ctx()
  local t=Base.borrowObject(T)
  t:init({},state,nil)
  eq(t._timelineData,nil)
  eq(t._frameArray,nil)
  eq(t._frameCount,0)
  near(t._duration,2)
end)
test("init distinguishes action timeline from dependent timeline",function()
  local state,td=ctx()
  local t=Base.borrowObject(T)
  state._actionTimeline=t
  t:init({},state,td)
  eq(t._actionTimeline,nil)
  local dependent=Base.borrowObject(T)
  dependent:init({},state,td)
  eq(dependent._actionTimeline,t)
end)
test("init uses source timeline scale and offset factors",function()
  local state,td,db=ctx()
  db.timelineArray[1]=200
  db.timelineArray[2]=25
  local t=Base.borrowObject(T)
  t:init({},state,td)
  near(t._timeScale,0.5)
  near(t._timeOffset,0.25)
end)
test("setCurrentTime begins playing, increments time and resets frame",function()
  local t=ready(T)
  t._frameIndex=5
  eq(t:_setCurrentTime(0.5),true)
  eq(t.playState,0);eq(t.currentPlayTimes,0)
  near(t.currentTime,0.5)
  eq(t._frameIndex,-1)
end)
test("setCurrentTime identical time does not trigger a new frame",function()
  local t=ready(T)
  eq(t:_setCurrentTime(0.5),true)
  t._frameIndex=1
  eq(t:_setCurrentTime(0.5),false)
  eq(t._frameIndex,1)
end)
test("setCurrentTime wraps time when loop never terminates",function()
  local t,state=ready(T)
  state.playTimes=0
  t:_setCurrentTime(5.5)
  near(t.currentTime,1.5)
  eq(t.currentPlayTimes,2);eq(t.playState,0)
end)
test("setCurrentTime handles negative time reversing into duration",function()
  local t,state=ready(T)
  state.playTimes=0
  t:_setCurrentTime(-0.5)
  near(t.currentTime,1.5)
  eq(t.currentPlayTimes,0)
end)
test("setCurrentTime negative time at exact loop boundary returns duration",function()
  local t,state=ready(T)
  state.playTimes=0
  t:_setCurrentTime(-2)
  near(t.currentTime,2)
  eq(t.currentPlayTimes,1)
end)
test("setCurrentTime positive endpoint adds original epsilon on completion",function()
  local t,state=ready(T)
  state.playTimes=2
  t:_setCurrentTime(4)
  eq(t.playState,1)
  eq(t.currentPlayTimes,2)
  near(t.currentTime,2.000001)
end)
test("setCurrentTime reverse completion ends at zero",function()
  local t,state=ready(T)
  state.playTimes=2
  t:_setCurrentTime(-4)
  eq(t.playState,1)
  near(t.currentTime,0)
end)
test("setCurrentTime remains uncompleted if playback head is paused",function()
  local t,state=ready(T)
  state._playheadState=1
  t:_setCurrentTime(2)
  eq(t.playState,-1)
  near(t.currentTime,2)
end)
test("setCurrentTime applies local timeScale, offset and position",function()
  local t,state=ready(T)
  state.playTimes=0
  t._timeScale=0.5
  t._timeOffset=0.1
  t._position=0.2
  t:_setCurrentTime(1)
  near(t.currentTime,0.9)
end)
test("dependent timeline with one frame follows action playState",function()
  local t,state=ready(T,1)
  local action={playState=0,currentTime=0.75,currentPlayTimes=5}
  t._actionTimeline=action
  eq(t:_setCurrentTime(0),true)
  eq(t.playState,-1);eq(t.currentPlayTimes,1)
  near(t.currentTime,0.75)
  action.playState=1
  action.currentTime=0.8
  t:_setCurrentTime(0)
  eq(t.playState,1)
end)
test("dependent timeline with multiple frames synchronizes action timeline",function()
  local t=ready(T)
  t._actionTimeline={playState=0,currentTime=1.2,currentPlayTimes=3}
  t:_setCurrentTime(0)
  eq(t.playState,0);eq(t.currentPlayTimes,3)
  near(t.currentTime,1.2)
end)
test("dependent scaled timeline instead recomputes its own currentTime",function()
  local t,state=ready(T)
  state.playTimes=0
  t._actionTimeline={playState=0,currentTime=1.9,currentPlayTimes=0}
  t._timeScale=0.5
  t:_setCurrentTime(1)
  near(t.currentTime,0.5)
end)
test("frame indices and frame-offset table are read as zero-based",function()
  local t=ready(T)
  t:update(0.25)
  eq(t._frameIndex,0);eq(t._frameOffset,0)
  eq(t.arrivals,1);eq(t.updates,nil)
  t:update(1.25)
  eq(t._frameIndex,1);eq(t._frameOffset,3)
  eq(t.arrivals,2)
end)
test("update first frame of pose timeline even without binary data",function()
  local state=ctx()
  local t=Base.borrowObject(T)
  t:init({},state,nil)
  t:update(0.1)
  eq(t._frameIndex,0)
  eq(t.arrivals,1)
end)
test("update does not re-arrive when frame index unchanged",function()
  local t=ready(T)
  t:update(0.2)
  t:update(0.4)
  eq(t.arrivals,1)
end)
test("update invokes update callback only for tween or dirty",function()
  local t=ready(T)
  t:update(0.1)
  eq(t.updates,nil)
  t.dirty=true
  t:update(0.2)
  eq(t.updates,1)
  t:update(0.3)
  eq(t.updates,2)
end)
test("fadeOut turns dirty flag off without touching currentTime",function()
  local t=ready(T)
  t.dirty=true
  t.currentTime=0.3
  t:fadeOut()
  eq(t.dirty,false)
  near(t.currentTime,0.3)
end)
test("abstract blend intentionally has no output",function()
  local t=Base.borrowObject(T)
  eq(t:blend(true),nil)
  eq(t.dirty,false)
end)
test("quad-in easing is blended by easing amount",function()
  near(Tween._getEasingValue(Types.TweenType.QuadIn,0.5,1),0.25)
  near(Tween._getEasingValue(Types.TweenType.QuadIn,0.5,0.5),0.375)
  near(Tween._getEasingValue(Types.TweenType.QuadIn,0.5,0),0.5)
end)
test("quad-out easing uses 1-(1-p)^2",function()
  near(Tween._getEasingValue(Types.TweenType.QuadOut,0.5,1),0.75)
end)
test("quad-in-out easing uses cosine",function()
  near(Tween._getEasingValue(Types.TweenType.QuadInOut,0.5,1),0.5)
  near(Tween._getEasingValue(Types.TweenType.QuadInOut,0.25,1),
    0.5*(1-math.cos(math.pi*0.25)))
end)
test("line and none easing return unchanged progress",function()
  near(Tween._getEasingValue(Types.TweenType.Line,0.37,7),0.37)
  near(Tween._getEasingValue(Types.TweenType.None,0.37,7),0.37)
end)
test("curve easing clamps both ends",function()
  near(Tween._getEasingCurveValue(-0.2,{5000},1,0),0)
  near(Tween._getEasingCurveValue(1.4,{5000},1,0),1)
end)
test("curve easing samples curve with omitted endpoints",function()
  local sample={2500,7500}
  near(Tween._getEasingCurveValue(0.5,sample,2,0),0.5)
  near(Tween._getEasingCurveValue(1/6,sample,2,0),0.125)
end)
test("curve easing honors explicit offset to samples",function()
  local sample={9999,2500,7500}
  near(Tween._getEasingCurveValue(0.5,sample,2,1),0.5)
end)
test("tween arrival enables linear interpolation and calculates frame duration",function()
  local t=ready(TW)
  t:update(0.5)
  eq(t._tweenType,Types.TweenType.Line)
  eq(t._isTween,true)
  near(t._framePosition,0)
  near(t._frameDurationR,1)
  near(t._tweenProgress,0.5)
end)
test("tween last frame becomes non-tween on final play",function()
  local t=ready(TW)
  t:update(1.5)
  eq(t._isTween,false)
  eq(t.dirty,true)
end)
test("tween last frame can interpolate back to beginning on infinite loop",function()
  local t,state,td,db=ready(TW)
  state.playTimes=0
  db.frameArray[5]=Types.TweenType.Line
  t:update(1.5)
  eq(t._isTween,true)
  near(t._framePosition,1)
  near(t._frameDurationR,1)
  near(t._tweenProgress,0.5)
end)
test("tween non-tween frame marks dirty",function()
  local t,state,td,db=ready(TW)
  db.frameArray[2]=Types.TweenType.None
  t:update(0.5)
  eq(t._isTween,false);eq(t.dirty,true)
end)
test("tween quadratic easing from binary data",function()
  local t,state,td,db=ready(TW)
  db.frameArray[2]=Types.TweenType.QuadIn
  db.frameArray[3]=100
  t:update(0.5)
  near(t._tweenProgress,0.25)
  near(t._tweenEasing,1)
end)
test("tween curve easing reads samples from frame array",function()
  local t,state,td,db=ready(TW)
  db.frameArray={0,Types.TweenType.Curve,2,2500,7500,10,Types.TweenType.None,0}
  db.timelineArray[7]=5
  t:update(0.5)
  near(t._tweenProgress,0.5)
end)
test("single value interpolates two samples",function()
  local t=withSingle()
  t:update(0.5)
  near(t._result,20)
  near(t._difference,20)
end)
test("single value scaled interpolation",function()
  local t=withSingle({10,30},0.1)
  t:update(0.5)
  near(t._result,2)
  near(t._current,1)
end)
test("single value frame without tween copies current sample",function()
  local t,state,td,db=withSingle()
  db.frameArray[2]=Types.TweenType.None
  t:update(0.5)
  near(t._result,10)
end)
test("single value wraps last frame to first for infinite animation",function()
  local t,state,td,db=withSingle()
  state.playTimes=0
  db.frameArray[5]=Types.TweenType.Line
  t:update(1.5)
  near(t._result,20)
end)
test("single value on pose timeline resets result to zero",function()
  local state=ctx()
  local t=Base.borrowObject(S)
  t:init({},state,nil)
  t._result=99
  t:update(0.4)
  near(t._result,0)
end)
test("double value interpolation reads two values per frame",function()
  local t=withDouble()
  t:update(0.5)
  near(t._resultA,6)
  near(t._resultB,12)
end)
test("double value interpolation honors scale",function()
  local t=withDouble({2,4,10,20},0.5)
  t:update(0.5)
  near(t._resultA,3)
  near(t._resultB,6)
end)
test("double value static frame reads both coordinates",function()
  local t,state,td,db=withDouble()
  db.frameArray[2]=Types.TweenType.None
  t:update(0.2)
  near(t._resultA,2);near(t._resultB,4)
end)
test("double value on pose timeline resets both results",function()
  local state=ctx()
  local t=Base.borrowObject(D)
  t:init({},state,nil)
  t._resultA=10;t._resultB=20
  t:update(0.2)
  near(t._resultA,0);near(t._resultB,0)
end)
test("multiple value allocates and interpolates three output samples",function()
  local t=withMultiple()
  t:update(0.5)
  near(t._rd[1],3);near(t._rd[2],4);near(t._rd[3],5)
  near(t._rd[4],4);near(t._rd[5],4);near(t._rd[6],4)
end)
test("multiple value interpolation scales differences and values",function()
  local t=withMultiple({1,2,3,5,6,7},2)
  t:update(0.5)
  near(t._rd[1],6);near(t._rd[2],8);near(t._rd[3],10)
  near(t._rd[4],8)
end)
test("multiple value static frame copies values",function()
  local t,state,td,db=withMultiple()
  db.frameArray[2]=Types.TweenType.None
  t:update(0.2)
  near(t._rd[1],1);near(t._rd[2],2);near(t._rd[3],3)
end)
test("multiple value pose zeroes rd first half",function()
  local state=ctx()
  local t=Base.borrowObject(V)
  t:init({},state,nil)
  t._valueCount=3
  t:update(0.2)
  near(t._rd[1],0);near(t._rd[2],0);near(t._rd[3],0)
end)
test("multiple value empty count preserves empty arrays",function()
  local t=withMultiple({},1,0)
  t:update(0.2)
  eq(#t._rd,0)
end)
test("multiple array is cleared in place on return to pool",function()
  local t=withMultiple()
  t:update(0.5)
  local rd=t._rd
  eq(#rd,6)
  t:returnToPool()
  local other=Base.borrowObject(V)
  eq(other,t)
  eq(other._rd,rd)
  eq(#rd,0)
  other:returnToPool()
end)

print(("Original BaseTimelineState.ts: %d passed, %d failed, %d assertions"):format(passed,failed,checks))
if failed>0 then os.exit(1) end
