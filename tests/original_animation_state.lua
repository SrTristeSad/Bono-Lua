-- Conformance tests for AnimationState in the pinned DragonBonesJS
-- DragonBones/src/dragonBones/animation/AnimationState.ts
-- revision 64b6c69ae35777c2404be68c9192e2c56906079e.
-- TimelineState.ts is not yet ported. Its 16 classes are replaced ONLY here
-- by contract test doubles; no production alternative timelines are shipped.
package.path="./?.lua;./?/init.lua;"..package.path
local Base=require("dragonbones.original.core.BaseObject")
local State=require("dragonbones.original.animation.AnimationState")
local Animation=require("dragonbones.original.animation.Animation")
local Blend=require("dragonbones.original.animation.BlendState")
local Armature=require("dragonbones.original.armature.Armature")
local ArmatureData=require("dragonbones.original.model.ArmatureData").ArmatureData
local AnimationData=require("dragonbones.original.model.AnimationData").AnimationData
local Config=require("dragonbones.original.model.AnimationConfig")
local Core=require("dragonbones.original.core.DragonBones")
local Events=require("dragonbones.original.event.EventObject")
local passed,failed,checks=0,0,0
local function eq(a,b)
  checks=checks+1;assert(a==b,tostring(a).." ~= "..tostring(b))
end
local function near(a,b)
  checks=checks+1
  assert(type(a)=="number" and type(b)=="number" and math.abs(a-b)<1e-7,
    tostring(a).." ~= "..tostring(b))
end
local function test(name,fn)
  local ok,err=pcall(fn)
  if ok then passed=passed+1;print("ok original.animation_state "..name)
  else failed=failed+1;print("not ok original.animation_state "..name..": "..tostring(err)) end
end
local classes={}
local names={
  "ActionTimelineState","ZOrderTimelineState",
  "IKConstraintTimelineState","BoneAllTimelineState","BoneTranslateTimelineState",
  "BoneRotateTimelineState","BoneScaleTimelineState","AlphaTimelineState",
  "SurfaceTimelineState","SlotDisplayTimelineState","SlotZIndexTimelineState",
  "SlotColorTimelineState","DeformTimelineState",
  "AnimationProgressTimelineState","AnimationWeightTimelineState",
  "AnimationParametersTimelineState"
}
for _,name in ipairs(names) do
  local C={}
  C.__index=C
  setmetatable(C,{__index=Base})
  C.new=function() return Base.new(C) end
  function C:_onClear()
    self.target=nil;self.displayFrame=nil
    self.playState=-1;self.currentPlayTimes=0;self.currentTime=0
    self.dirty=false;self.inits=0;self.updates={};self.blends={}
    self.fades=0;self.name=name
  end
  function C:init(armature,state,data)
    self.armature=armature;self.state=state;self.data=data
    self.inits=self.inits+1
    self.initDisplayFrame=self.displayFrame
  end
  function C:update(time)
    self.updates[#self.updates+1]=time
    self.currentTime=time
  end
  function C:blend(dirty)
    self.blends[#self.blends+1]=dirty
  end
  function C:fadeOut() self.fades=self.fades+1 end
  function C:setCurrentTime(t) self.currentTime=t end
  classes[name]=C
end
local key="dragonbones.original.animation.TimelineState"
local prev=package.loaded[key]
package.loaded[key]=classes
local function fixture()
  local a=Base.borrowObject(Armature)
  local model=Base.borrowObject(ArmatureData)
  model.name="arm"
  model.parent={name="db",cachedFrames={}}
  model.scale=1
  local proxy={events={},updates=0}
  function proxy:hasDBEventListener(name) return self.events[name] end
  function proxy:dbInit(v) self.owner=v end
  function proxy:dbUpdate() self.updates=self.updates+1 end
  function proxy:dbClear() end
  local dragon={objects={},events={}}
  function dragon:bufferObject(v) self.objects[#self.objects+1]=v end
  function dragon:bufferEvent(v) self.events[#self.events+1]=v end
  a:init(model,proxy,{},dragon)
  local data=Base.borrowObject(AnimationData)
  data.name="run";data.duration=2;data.frameCount=20
  data.playTimes=2;data.scale=1
  data.fadeInTime=0.1
  data.parent=model
  local config=Base.borrowObject(Config)
  config.animation="run";config.name=""
  config.playTimes=2;config.timeScale=1
  config.fadeInTime=0.5
  config.position=0
  config.duration=-1
  config.resetToPose=false
  config.pauseFadeIn=false
  config.actionEnabled=true
  return a,data,config,proxy,dragon
end
local function state()
  local a,data,cfg,proxy,dragon=fixture()
  local s=Base.borrowObject(State)
  s:init(a,data,cfg)
  return s,a,data,cfg,proxy,dragon
end
local function fakeBone(a,name,parent)
  local bone={name=name,parent=parent,_boneData={type=Core.BoneType.Bone},
    animationPose={},_cachedFrameIndices=nil}
  function bone:contains(other)
    local p=other.parent
    while p~=nil do
      if p==self then return true end
      p=p.parent
    end
    return false
  end
  function a:getBone(n)
    for _,b in ipairs(self._bones) do if b.name==n then return b end end
  end
  a._bones[#a._bones+1]=bone
  return bone
end

test("class identity and pooled field defaults",function()
  local s=Base.borrowObject(State)
  eq(State.toString(),"[class dragonBones.AnimationState]")
  eq(getmetatable(s),State)
  eq(s.actionEnabled,false);eq(s.additive,false);eq(s.displayControl,false)
  eq(s.resetToPose,false);eq(s.blendType,Core.AnimationBlendType.None)
  eq(s.playTimes,1);eq(s.layer,0);near(s.timeScale,1)
  near(s.weight,1);eq(s._timelineDirty,2)
  eq(s._playheadState,0);eq(s._fadeState,-1);eq(s._subFadeState,-1)
  eq(s._parent,nil);eq(s.animationData,nil)
  eq(#s._boneTimelines,0);eq(#s._slotTimelines,0)
  eq(#s._poseTimelines,0);eq(#s._boneMask,0)
end)
test("initialization borrows original ActionTimelineState contract",function()
  local s,a,data,cfg=state()
  eq(s._armature,a);eq(s.animationData,data)
  eq(s._actionTimeline.name,"ActionTimelineState")
  eq(s._actionTimeline.inits,1)
  eq(s._actionTimeline.data,data.actionTimeline)
  eq(s._actionTimeline.state,s)
  eq(s._zOrderTimeline,nil)
  eq(s.name,"run");eq(s.group,"")
end)
test("initialization guard preserves original data and action timeline",function()
  local s,a,data,cfg=state()
  local action=s._actionTimeline
  s:init({}, {}, {})
  eq(s._armature,a);eq(s._animationData,data)
  eq(s._actionTimeline,action)
end)
test("config maps all original public animation fields",function()
  local a,data,cfg=fixture()
  cfg.animation="walk";cfg.name="alias";cfg.layer=4;cfg.group="combat"
  cfg.timeScale=0.75;cfg.playTimes=5
  cfg.actionEnabled=false;cfg.additive=true
  cfg.displayControl=false;cfg.resetToPose=true
  cfg.weight=0.35;cfg.autoFadeOutTime=0.5
  data.blendType=Core.AnimationBlendType.E1D
  local s=Base.borrowObject(State);s:init(a,data,cfg)
  eq(s.name,"alias");eq(s.group,"combat")
  eq(s.layer,4);eq(s.playTimes,5);near(s.timeScale,0.75)
  eq(s.actionEnabled,false);eq(s.additive,true);eq(s.resetToPose,true)
  eq(s.blendType,Core.AnimationBlendType.E1D)
  near(s.weight,0.35);near(s.autoFadeOutTime,0.5)
end)
test("pauseFadeIn starts with playhead 2; false starts with 3",function()
  local a,data,cfg=fixture()
  cfg.pauseFadeIn=true
  local s=Base.borrowObject(State);s:init(a,data,cfg)
  eq(s._playheadState,2)
  cfg.pauseFadeIn=false
  local other=Base.borrowObject(State);other:init(a,data,cfg)
  eq(other._playheadState,3)
end)
test("negative timeScale and initial zero time use epsilon",function()
  local a,data,cfg=fixture()
  cfg.timeScale=-1
  local s=Base.borrowObject(State);s:init(a,data,cfg)
  near(s._time,-0.000001);near(s.totalTime,2)
end)
test("reverse with explicit position subtracts total duration",function()
  local a,data,cfg=fixture()
  cfg.timeScale=-2;cfg.position=0.7
  local s=Base.borrowObject(State);s:init(a,data,cfg)
  near(s._time,-1.3)
end)
test("explicit duration preserves offset and starts local time zero",function()
  local a,data,cfg=fixture()
  cfg.position=0.5;cfg.duration=1.25
  local s=Base.borrowObject(State);s:init(a,data,cfg)
  near(s._position,0.5);near(s._duration,1.25);near(s._time,0)
end)
test("zero fadeInTime uses source epsilon difference",function()
  local a,data,cfg=fixture()
  cfg.fadeInTime=0
  local s=Base.borrowObject(State);s:init(a,data,cfg)
  near(s._fadeProgress,0.999999)
end)
test("bone mask is copied by value at initialization",function()
  local a,data,cfg=fixture()
  cfg.boneMask[1]="root";cfg.boneMask[2]="hand"
  local s=Base.borrowObject(State);s:init(a,data,cfg)
  eq(s._boneMask[1],"root");eq(s._boneMask[2],"hand")
  cfg.boneMask[1]="new"
  eq(s._boneMask[1],"root")
end)
test("zOrder timeline initialized only if animationData carries it",function()
  local a,data,cfg=fixture()
  data.zOrderTimeline={type=Core.TimelineType.ZOrder}
  local s=Base.borrowObject(State);s:init(a,data,cfg)
  eq(s._zOrderTimeline.name,"ZOrderTimelineState")
  eq(s._zOrderTimeline.data,data.zOrderTimeline)
end)
test("isFade* getters follow three original fade states",function()
  local s=Base.borrowObject(State)
  eq(s.isFadeIn,true);eq(s.isFadeOut,false);eq(s.isFadeComplete,false)
  s._fadeState=0
  eq(s.isFadeComplete,true)
  s._fadeState=1
  eq(s.isFadeOut,true);eq(s.isFadeIn,false)
end)
test("play/stop match source bitwise playback state flags",function()
  local s=state()
  s._playheadState=3;s:stop();eq(s._playheadState,1)
  s:play();eq(s._playheadState,3)
  s._playheadState=2;s:stop();eq(s._playheadState,0)
end)
test("isPlaying derives playhead bit and action timeline status",function()
  local s=state()
  eq(s.isPlaying,true)
  s._actionTimeline.playState=1;eq(s.isPlaying,false)
  eq(s.isCompleted,true)
  s._actionTimeline.playState=-1
  s:stop();eq(s.isPlaying,false)
end)
test("currentPlayTimes, totalTime, currentTime and animationData getters",function()
  local s,a,data=state()
  s._actionTimeline.currentPlayTimes=4
  s._actionTimeline.currentTime=0.8
  near(s.currentTime,0.8)
  eq(s.currentPlayTimes,4)
  eq(s.animationData,data)
  near(s.totalTime,2)
end)
test("weight setter marks bone and blend timelines dirty only on change",function()
  local s=state()
  local a={dirty=false};local b={dirty=false};local c={dirty=false}
  s._boneTimelines={a};s._boneBlendTimelines={b};s._slotBlendTimelines={c}
  s.weight=0.4
  near(s.weight,0.4)
  eq(a.dirty,true);eq(b.dirty,true);eq(c.dirty,true)
  a.dirty=false
  s.weight=0.4;eq(a.dirty,false)
end)
test("currentTime setter wraps positive overshoot and invalidates selected timelines",function()
  local s=state()
  local b={playState=2};local sl={playState=2}
  s._boneTimelines={b};s._slotTimelines={sl}
  s.currentTime=5
  near(s._time,1);near(s.currentTime,1)
  eq(b.playState,-1);eq(sl.playState,-1)
end)
test("currentTime negative wraps using JS signed remainder",function()
  local s=state()
  s.currentTime=-0.25
  near(s.currentTime,1.75)
end)
test("currentTime epsilon protects final frame of last repetition",function()
  local s=state()
  s.playTimes=2
  s._actionTimeline.currentPlayTimes=1
  s.currentTime=2
  near(s.currentTime,1.999999)
end)
test("currentTime unchanged is a no-op",function()
  local s=state()
  s.currentTime=0
  eq(s._actionTimeline.currentTime,0)
end)
test("_advanceFadeTime forwards fade-in start/completion events when listened",function()
  local s,a,data,cfg,proxy,dragon=state()
  proxy.events[Events.FADE_IN]=true
  proxy.events[Events.FADE_IN_COMPLETE]=true
  s:_advanceFadeTime(0.5)
  eq(s._fadeState,0);eq(s._subFadeState,1)
  near(s._fadeProgress,1)
  eq(#dragon.events,2)
  eq(dragon.events[1].type,Events.FADE_IN)
  eq(dragon.events[2].type,Events.FADE_IN_COMPLETE)
  eq(dragon.events[1].animationState,s)
end)
test("_advanceFadeTime abs negative delta and interpolates fade progress",function()
  local s=state()
  s:_advanceFadeTime(-0.2)
  near(s._fadeTime,0.2);near(s._fadeProgress,0.4)
  eq(s._subFadeState,0)
end)
test("_advanceFadeTime nested child suppresses event emission",function()
  local s,a,data,cfg,proxy,dragon=state()
  proxy.events[Events.FADE_IN]=true
  proxy.events[Events.FADE_IN_COMPLETE]=true
  s._parent={}
  s:_advanceFadeTime(1)
  eq(#dragon.events,0)
end)
test("fadeOut pauses playhead by default and adjusts total time",function()
  local s=state()
  s._fadeProgress=0.5
  s:fadeOut(0.4)
  eq(s._fadeState,1);eq(s._subFadeState,-1)
  eq(s._playheadState,2)
  near(s.fadeTotalTime,0.8)
  near(s._fadeTime,0.4)
  eq(s.displayControl,false)
end)
test("fadeOut does not pause when explicitly requested",function()
  local s=state()
  s:fadeOut(0.4,false)
  eq(s._playheadState,3)
end)
test("fadeOut negative duration clamps to zero, preserving epsilon",function()
  local s=state()
  s._fadeProgress=1
  s:fadeOut(-5)
  near(s.fadeTotalTime,0)
  near(s._fadeProgress,0.000001)
end)
test("fadeOut ignored longer replacement when already fading",function()
  local s=state()
  s._fadeProgress=0.5
  s:fadeOut(1)
  local total=s.fadeTotalTime
  s:fadeOut(10)
  near(s.fadeTotalTime,total)
end)
test("fadeOut invokes all concrete timeline fade hooks",function()
  local s=state()
  local one=Base.borrowObject(classes.BoneAllTimelineState)
  local two=Base.borrowObject(classes.SlotDisplayTimelineState)
  local three=Base.borrowObject(classes.IKConstraintTimelineState)
  s._boneTimelines={one};s._slotTimelines={two}
  s._constraintTimelines={three}
  s:fadeOut(0.3)
  eq(one.fades,1);eq(two.fades,1);eq(three.fades,1)
end)
test("containsBoneMask empty mask includes all bones",function()
  local s=state()
  eq(s:containsBoneMask("root"),true)
  s._boneMask={"leg"}
  eq(s:containsBoneMask("root"),false)
  eq(s:containsBoneMask("leg"),true)
end)
test("addBoneMask recursive adds descendants, avoids duplicate",function()
  local s,a=state()
  local root=fakeBone(a,"root")
  fakeBone(a,"child",root)
  fakeBone(a,"other")
  s:addBoneMask("root")
  eq(#s._boneMask,2)
  eq(s._boneMask[1],"root");eq(s._boneMask[2],"child")
  s:addBoneMask("root");eq(#s._boneMask,2)
  eq(s._timelineDirty,1)
end)
test("addBoneMask nonrecursive includes only named bone",function()
  local s,a=state()
  local root=fakeBone(a,"root")
  fakeBone(a,"child",root)
  s:addBoneMask("root",false)
  eq(#s._boneMask,1);eq(s._boneMask[1],"root")
end)
test("addBoneMask unknown bone leaves mask and dirty unchanged",function()
  local s=state()
  s._timelineDirty=0
  s:addBoneMask("notfound")
  eq(#s._boneMask,0);eq(s._timelineDirty,0)
end)
test("removeBoneMask nonrecursive removes only one name",function()
  local s,a=state()
  fakeBone(a,"root");fakeBone(a,"other")
  s._boneMask={"root","other"}
  s:removeBoneMask("root",false)
  eq(#s._boneMask,1);eq(s._boneMask[1],"other")
end)
test("removeBoneMask with empty remaining mask selects non-descendants",function()
  local s,a=state()
  local root=fakeBone(a,"root")
  fakeBone(a,"child",root)
  fakeBone(a,"other")
  s._boneMask={"root"}
  s:removeBoneMask("root",true)
  eq(#s._boneMask,1)
  eq(s._boneMask[1],"other")
end)
test("removeAllBoneMask clears array and sets timelineDirty",function()
  local s=state()
  s._boneMask={"a","b"}
  local identity=s._boneMask
  s:removeAllBoneMask()
  eq(#s._boneMask,0);eq(s._boneMask,identity)
  eq(s._timelineDirty,1)
end)
test("addState with no timelines attaches parent only",function()
  local parent=state()
  local child=Base.borrowObject(State)
  parent:addState(child)
  eq(child._parent,parent)
  eq(#parent._animationTimelines,0)
end)
test("addState progress timeline sets position and disables resetToPose",function()
  local parent=state()
  parent.blendType=Core.AnimationBlendType.E1D
  parent.resetToPose=true
  local child=Base.borrowObject(State)
  local timeline={type=Core.TimelineType.AnimationProgress,x=3,y=4}
  parent:addState(child,{timeline})
  eq(#parent._animationTimelines,1)
  eq(parent._animationTimelines[1].name,"AnimationProgressTimelineState")
  eq(child.positionX,3);eq(child.positionY,4)
  near(child.weight,0)
  eq(child._parent,parent);eq(parent.resetToPose,false)
end)
test("addState weight/parameter timelines do not disable resetToPose",function()
  local parent=state()
  parent.resetToPose=true
  local child=Base.borrowObject(State)
  parent:addState(child,{
    {type=Core.TimelineType.AnimationWeight},
    {type=Core.TimelineType.AnimationParameter}
  })
  eq(#parent._animationTimelines,2)
  eq(parent.resetToPose,true)
end)
test("activeTimeline marks slot timelines dirty and rewinds their times",function()
  local s=state()
  local timeline={dirty=false,currentTime=7}
  s._slotTimelines={timeline}
  s:activeTimeline()
  eq(timeline.dirty,true);near(timeline.currentTime,-1)
end)
test("advanceTime updates action and completes fade then resets subFadeState",function()
  local s,a=state()
  s.actionEnabled=false
  s:advanceTime(0.6,0)
  near(s._time,0.6)
  eq(#s._actionTimeline.updates,1)
  eq(s._fadeState,0);eq(s._subFadeState,0)
  near(s._weightResult,1)
  eq(s._timelineDirty,0)
end)
test("advanceTime while paused does not move source time",function()
  local s=state()
  s:stop()
  s:advanceTime(0.2,0)
  near(s._time,0)
end)
test("advanceTime applies timeScale including negative playback",function()
  local s=state()
  s.timeScale=-2
  s:advanceTime(0.25,0)
  near(s._time,-0.5)
end)
test("advanceTime with zero weight updates action, skips zOrder and bone timelines",function()
  local s=state()
  s.weight=0
  s:advanceTime(0.2,30)
  eq(#s._actionTimeline.updates,1)
  eq(s._armature._cacheFrameIndex,-1)
end)
test("advanceTime with caching writes one cached frame and skips repeated frame",function()
  local s,a,data=state()
  s.actionEnabled=false
  s._fadeState=0;s._subFadeState=0;s._fadeProgress=1
  s:advanceTime(0.3,24)
  eq(a._cacheFrameIndex,7)
  eq(data.cachedFrames[8],true)
  s:advanceTime(0,24)
  eq(a._cacheFrameIndex,7)
end)
test("advanceTime applies boneBlend with real BlendState and timeline blend hook",function()
  local s,a=state()
  s._timelineDirty=0
  s._fadeState=0;s._subFadeState=0;s._fadeProgress=1
  local bone={name="root",animationPose={}}
  local blend=a.animation:getBlendState(Blend.BONE_ALPHA,"root",bone)
  local timeline=Base.borrowObject(classes.AlphaTimelineState)
  timeline.target=blend;timeline.playState=-1
  s._boneBlendTimelines={timeline}
  s:advanceTime(0.2,0)
  eq(#timeline.updates,1)
  eq(#timeline.blends,1)
  near(blend.blendWeight,1)
end)
test("advanceTime skips slot timelines whose displayController differs",function()
  local s=state()
  s._timelineDirty=0
  s._fadeState=0;s._subFadeState=0;s._fadeProgress=1
  local one=Base.borrowObject(classes.SlotDisplayTimelineState)
  one.target={displayController="other"}
  local two=Base.borrowObject(classes.SlotDisplayTimelineState)
  two.target={displayController=nil}
  s._slotTimelines={one,two}
  s:advanceTime(0.1,0)
  eq(#one.updates,0);eq(#two.updates,1)
end)
test("advanceTime pose timelines are recycled after fade-in completes",function()
  local s=state()
  s._timelineDirty=0
  s._fadeState=0;s._subFadeState=1
  local pose=Base.borrowObject(classes.SlotDisplayTimelineState)
  pose.target={displayController=nil}
  s._slotTimelines={pose};s._poseTimelines={pose}
  s:advanceTime(0.1,0)
  eq(#s._poseTimelines,0)
  eq(#s._slotTimelines,0)
  eq(pose._isInPool,true)
end)
test("advanceTime auto fadeOut when action timeline completes",function()
  local s=state()
  s._timelineDirty=0
  s.autoFadeOutTime=0.2
  s._fadeState=0;s._subFadeState=0;s._fadeProgress=1
  s._actionTimeline.playState=1
  s:advanceTime(0,0)
  eq(s._fadeState,1)
  eq(s.displayControl,false)
end)
test("_onClear recycles action, zOrder, and child state parent links",function()
  local s=state()
  local child=Base.borrowObject(State)
  child._parent=s
  local timeline=Base.borrowObject(classes.AnimationWeightTimelineState)
  timeline.target=child
  s._animationTimelines={timeline}
  local action=s._actionTimeline
  s:returnToPool()
  eq(action._isInPool,true)
  eq(timeline._isInPool,true)
  eq(child._parent,nil)
  eq(child._fadeState,1)
end)

package.loaded[key]=prev
print(("Original AnimationState.ts: %d passed, %d failed, %d assertions"):format(passed,failed,checks))
if failed>0 then os.exit(1) end
