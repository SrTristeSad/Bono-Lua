-- Concrete TimelineState.ts conformance against the pinned DragonBonesJS source.
-- Commit 64b6c69ae35777c2404be68c9192e2c56906079e.
-- All 16 real concrete Lua classes are loaded; no contract timeline stubs.
package.path="./?.lua;./?/init.lua;"..package.path
local Pool=require("dragonbones.original.core.BaseObject")
local Core=require("dragonbones.original.core.DragonBones")
local Classes=require("dragonbones.original.animation.TimelineState")
local B=require("dragonbones.original.animation.BaseTimelineState")
local State=require("dragonbones.original.animation.AnimationState")
local Model=require("dragonbones.original.model.AnimationData")
local Armature=require("dragonbones.original.armature.Armature")
local ArmModel=require("dragonbones.original.model.ArmatureData")
local Color=require("dragonbones.original.geom.ColorTransform")
local Transform=require("dragonbones.original.geom.Transform")
local Event=require("dragonbones.original.event.EventObject")
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
local function check(name,fn)
  local ok,err=pcall(fn)
  if ok then passed=passed+1;print("ok original.concrete_timeline "..name)
  else failed=failed+1;print("not ok original.concrete_timeline "..name..": "..tostring(err)) end
end
local function fixture(className,withData)
  if withData==nil then withData=true end
  local data={
    frameArray={0,Core.TweenType.Line,0,10,Core.TweenType.None,0},
    timelineArray={100,0,2,0,0,0,3},
    frameIndices={},frameFloatArray={10,20,30,40,50,60,70,80,90,100,110,120},
    frameIntArray={100,200,300,400,500,600,700,800},
    colorArray={100,75,50,25,1,2,3,4,50,100,75,25,5,6,7,8}
  }
  for i=0,25 do data.frameIndices[i+1]=i<10 and 0 or 1 end
  local armModel={scale=2,frameRate=10,parent=data,actions={}}
  local animData={
    name="run",parent=armModel,frameOffset=0,frameFloatOffset=0,
    frameIntOffset=0,duration=2,frameCount=20
  }
  local actor={
    armatureData=armModel,_alphaDirty=false,_zIndexDirty=false,
    _cacheFrameIndex=-1, _constraints={},_slots={},_bones={},
    _bufferedActions={},_zsort={}, _dragonBones={buffered={}}
  }
  actor._dragonBones.bufferEvent=function(self,e)
    self.buffered[#self.buffered+1]=e
  end
  actor._bufferAction=function(self,evt,append)
    self._bufferedActions[#self._bufferedActions+1]=evt
  end
  actor._sortZOrder=function(self,arr,offset)
    self._zsort[#self._zsort+1]={arr,offset}
  end
  actor.eventDispatcher={hasDBEventListener=function() return true end}
  local state={
    animationData=animData,playTimes=1,currentPlayTimes=0,
    _position=0,_duration=2,_playheadState=3,
    timeScale=1,actionEnabled=true,displayControl=true,resetToPose=false,
    _parent=nil,_fadeState=0,_subFadeState=0,_fadeProgress=1
  }
  local td={offset=0,frameIndicesOffset=0}
  local timeline=Pool.borrowObject(Classes[className])
  timeline:init(actor,state,withData and td or nil)
  return timeline,actor,state,animData,data,td
end
local function blend(target,weight,dirty)
  return {target=target,blendWeight=weight or 1,dirty=dirty or 1}
end
local function bone()
  return {
    animationPose={x=0,y=0,rotation=0,skew=0,scaleX=1,scaleY=1},
    _transformDirty=false
  }
end

check("sixteen original concrete classes exported with source class names",function()
  local names={
    "ActionTimelineState","ZOrderTimelineState","BoneAllTimelineState",
    "BoneTranslateTimelineState","BoneRotateTimelineState","BoneScaleTimelineState",
    "SurfaceTimelineState","AlphaTimelineState","SlotDisplayTimelineState",
    "SlotColorTimelineState","SlotZIndexTimelineState","DeformTimelineState",
    "IKConstraintTimelineState","AnimationProgressTimelineState",
    "AnimationWeightTimelineState","AnimationParametersTimelineState"
  }
  eq(#names,16)
  for _,name in ipairs(names) do
    local c=Classes[name]
    eq(type(c),"table")
    eq(c.toString(),"[class dragonBones."..name.."]")
    local x=Pool.borrowObject(c)
    eq(getmetatable(x),c)
    eq(type(x.update),"function")
    x:returnToPool()
  end
end)
check("action timeline uses real abstract TimelineState and no fake callbacks",function()
  eq(getmetatable(Classes.ActionTimelineState).__index,B.TimelineState)
  eq(getmetatable(Classes.BoneTranslateTimelineState).__index,B.DoubleValueTimelineState)
  eq(getmetatable(Classes.DeformTimelineState).__index,B.MutilpleValueTimelineState)
end)
check("action timeline forwards Play actions to armature queue",function()
  local t,a,s,anim,d=fixture("ActionTimelineState")
  a.armatureData.actions={{type=Core.ActionType.Play,name="walk"}}
  d.frameArray[2]=1
  d.frameArray[3]=0
  t:_onCrossFrame(0)
  eq(#a._bufferedActions,1)
  eq(a._bufferedActions[1].name,"walk")
  eq(a._bufferedActions[1].animationState,s)
  near(a._bufferedActions[1].time,0)
end)
check("frame and sound events have proper event type and playback time",function()
  local t,a,s,anim,d=fixture("ActionTimelineState")
  a.armatureData.actions={
    {type=Core.ActionType.Frame,name="step"},
    {type=Core.ActionType.Sound,name="impact"}
  }
  d.frameArray[2]=2;d.frameArray[3]=0;d.frameArray[4]=1
  t:_onCrossFrame(0)
  eq(#a._dragonBones.buffered,2)
  eq(a._dragonBones.buffered[1].type,Event.FRAME_EVENT)
  eq(a._dragonBones.buffered[2].type,Event.SOUND_EVENT)
end)
check("frame events respect listener; sound events dispatch unconditionally",function()
  local t,a,s,anim,d=fixture("ActionTimelineState")
  a.eventDispatcher.hasDBEventListener=function() return false end
  a.armatureData.actions={
    {type=Core.ActionType.Frame,name="frame"},
    {type=Core.ActionType.Sound,name="sound"}
  }
  d.frameArray[2]=2;d.frameArray[3]=0;d.frameArray[4]=1
  t:_onCrossFrame(0)
  eq(#a._dragonBones.buffered,1)
  eq(a._dragonBones.buffered[1].name,"sound")
end)
check("action disabled suppresses all crossed frame actions",function()
  local t,a,s,anim,d=fixture("ActionTimelineState")
  s.actionEnabled=false
  a.armatureData.actions={{type=Core.ActionType.Play,name="x"}}
  d.frameArray[2]=1;d.frameArray[3]=0
  t:_onCrossFrame(0)
  eq(#a._bufferedActions,0)
end)
check("setCurrentTime rewinds action frame index to -1",function()
  local t=fixture("ActionTimelineState")
  t._frameIndex=1
  t:setCurrentTime(0.4)
  eq(t._frameIndex,-1)
  near(t.currentTime,0.4)
end)
check("ActionTimelineState.update buffers START when playback begins",function()
  local t,a=fixture("ActionTimelineState",false)
  t:update(0.25)
  eq(#a._dragonBones.buffered,1)
  eq(a._dragonBones.buffered[1].type,Event.START)
  near(t.currentTime,0.25)
end)
check("ActionTimelineState.update queues LOOP_COMPLETE before COMPLETE",function()
  local t,a=fixture("ActionTimelineState",false)
  t:update(0.1)
  t:update(2)
  local events=a._dragonBones.buffered
  eq(events[2].type,Event.LOOP_COMPLETE)
  eq(events[3].type,Event.COMPLETE)
end)
check("ZOrder timeline preserves backing array and zero-based offset",function()
  local t,a,s,anim,d=fixture("ZOrderTimelineState")
  t.playState=0
  t._frameOffset=0
  d.frameArray[2]=2
  t:_onArriveAtFrame()
  eq(a._zsort[1][1],d.frameArray)
  eq(a._zsort[1][2],2)
end)
check("ZOrder timeline zero-count requests original order",function()
  local t,a,s,anim,d=fixture("ZOrderTimelineState")
  t.playState=0
  d.frameArray[2]=0
  t:_onArriveAtFrame()
  eq(a._zsort[1][1],nil)
  eq(a._zsort[1][2],0)
end)
check("ZOrder timeline does nothing before animation starts",function()
  local t,a=fixture("ZOrderTimelineState")
  t:_onArriveAtFrame()
  eq(#a._zsort,0)
end)
check("BoneAll pose initializes x,y,rotation,skew to zero and scale to one",function()
  local t=fixture("BoneAllTimelineState",false)
  t:update(0.2)
  near(t._rd[1],0);near(t._rd[2],0)
  near(t._rd[5],1);near(t._rd[6],1)
end)
check("BoneAll blending writes pose including armature scale",function()
  local t,a=fixture("BoneAllTimelineState",false)
  local b=bone()
  t.target=blend(b,0.5,1)
  t._rd={2,4,0.5,0.75,1.5,0.5}
  t:blend(true)
  near(b.animationPose.x,2)
  near(b.animationPose.y,4)
  near(b.animationPose.rotation,0.25)
  near(b.animationPose.skew,0.375)
  near(b.animationPose.scaleX,1.25)
  near(b.animationPose.scaleY,0.75)
  eq(b._transformDirty,true)
end)
check("BoneAll later layer accumulates scale and transform",function()
  local t=fixture("BoneAllTimelineState",false)
  local b=bone()
  b.animationPose.x=3
  b.animationPose.scaleX=1.2
  t.target=blend(b,0.5,2)
  t._rd={2,0,0,0,1.4,1}
  t:blend(false)
  near(b.animationPose.x,5)
  near(b.animationPose.scaleX,1.4)
end)
check("BoneTranslate writes weighted positions and marks bone dirty",function()
  local t=fixture("BoneTranslateTimelineState")
  local b=bone()
  t.target=blend(b,0.25,1)
  t._resultA=12;t._resultB=20
  t.dirty=true;t:blend(false)
  near(b.animationPose.x,3)
  near(b.animationPose.y,5)
  eq(b._transformDirty,true)
  eq(t.dirty,false)
end)
check("BoneTranslate accumulates on second contributing animation",function()
  local t=fixture("BoneTranslateTimelineState")
  local b=bone()
  b.animationPose.x=7
  t.target=blend(b,0.5,2)
  t._resultA=6;t._resultB=4
  t:blend(false)
  near(b.animationPose.x,10)
  near(b.animationPose.y,2)
  eq(b._transformDirty,false)
end)
check("BoneRotate blend applies rotation and skew independently",function()
  local t=fixture("BoneRotateTimelineState")
  local b=bone()
  t.target=blend(b,0.5,1)
  t._resultA=2;t._resultB=-1
  t:blend(true)
  near(b.animationPose.rotation,1)
  near(b.animationPose.skew,-0.5)
end)
check("BoneRotate fadeOut normalizes both angles",function()
  local t=fixture("BoneRotateTimelineState")
  t._resultA=math.pi*3
  t._resultB=-math.pi*3
  t:fadeOut()
  near(t._resultA,Transform.normalizeRadian(math.pi*3))
  near(t._resultB,Transform.normalizeRadian(-math.pi*3))
  eq(t.dirty,false)
end)
check("BoneScale first contribution interpolates around unit scale",function()
  local t=fixture("BoneScaleTimelineState")
  local b=bone()
  t.target=blend(b,0.5,1)
  t._resultA=2;t._resultB=0.5
  t:blend(true)
  near(b.animationPose.scaleX,1.5)
  near(b.animationPose.scaleY,0.75)
end)
check("BoneScale pose uses unit values, not zero",function()
  local t=fixture("BoneScaleTimelineState",false)
  t:update(0.1)
  near(t._resultA,1);near(t._resultB,1)
end)
check("Alpha timeline blends percent values and clamps only accumulated alpha",function()
  local t,a=fixture("AlphaTimelineState")
  local target={_alpha=0}
  t.target=blend(target,0.5,1)
  t._result=0.8
  t:blend(true)
  near(target._alpha,0.4)
  eq(a._alphaDirty,true)
  t.target=blend(target,1,2)
  t._result=0.9
  t:blend(false)
  near(target._alpha,1)
end)
check("Alpha pose is fully opaque",function()
  local t=fixture("AlphaTimelineState",false)
  t:update(0.2)
  near(t._result,1)
end)
check("SlotDisplay timeline swaps active index when play state nonnegative",function()
  local t=fixture("SlotDisplayTimelineState")
  local slot={displayIndex=0,_slotData={displayIndex=2},changes={}}
  function slot:_setDisplayIndex(i,animated)
    self.changes[#self.changes+1]={i,animated}
    self.displayIndex=i
  end
  t.target=slot;t.playState=0
  t._frameOffset=0;t._frameArray={0,-1}
  t:_onArriveAtFrame()
  eq(slot.displayIndex,-1)
  eq(slot.changes[1][2],true)
end)
check("SlotDisplay pose uses original slotData.displayIndex",function()
  local t=fixture("SlotDisplayTimelineState",false)
  local slot={displayIndex=0,_slotData={displayIndex=3}}
  function slot:_setDisplayIndex(i) self.displayIndex=i end
  t.target=slot;t.playState=0
  t:_onArriveAtFrame()
  eq(slot.displayIndex,3)
end)
check("SlotColor pose copies eight original multiplier and offset channels",function()
  local t=fixture("SlotColorTimelineState",false)
  local color=Color.new()
  color.alphaMultiplier=0.5
  color.redMultiplier=0.3
  color.alphaOffset=12
  local slot={slotData={color=color},_colorTransform=Color.new()}
  t.target=slot
  t:update(0.2)
  near(t._result[1],0.5)
  near(t._result[2],0.3)
  near(t._result[5],12)
end)
check("SlotColor completed fade writes values and marks slot color dirty",function()
  local t,a,s=fixture("SlotColorTimelineState",false)
  local color=Color.new()
  color.alphaMultiplier=0.5
  color.redMultiplier=0.7
  local slot={slotData={color=color},_colorTransform=Color.new(),_colorDirty=false}
  t.target=slot
  s._fadeState=0;s._subFadeState=0
  t:update(0.3)
  near(slot._colorTransform.alphaMultiplier,0.5)
  near(slot._colorTransform.redMultiplier,0.7)
  eq(slot._colorDirty,true)
end)
check("SlotColor fading uses fadeProgress to the fourth power",function()
  local t,a,s=fixture("SlotColorTimelineState",false)
  local color=Color.new();color.alphaMultiplier=0
  local slot={slotData={color=color},_colorTransform=Color.new(),_colorDirty=false}
  t.target=slot;s._fadeState=-1;s._fadeProgress=0.5
  t:update(0.25)
  near(slot._colorTransform.alphaMultiplier,0.9375)
  eq(slot._colorDirty,true)
end)
check("SlotZIndex blends weighted result and signals armature",function()
  local t,a=fixture("SlotZIndexTimelineState")
  local slot={_zIndex=0}
  t.target=blend(slot,0.5,1)
  t._result=8
  t:blend(true)
  near(slot._zIndex,4)
  eq(a._zIndexDirty,true)
end)
check("SlotZIndex pose copies original slot data zIndex",function()
  local t=fixture("SlotZIndexTimelineState",false)
  local slot={slotData={zIndex=6}}
  t.target=blend(slot)
  t:update(0.2)
  near(t._result,6)
end)
check("Surface deform blends unchanged, animated and suffix channels",function()
  local t,a,s,anim,d=fixture("SurfaceTimelineState")
  t._deformCount=5;t._deformOffset=1;t._valueCount=2
  t._sameValueOffset=0
  t._valueArray={10,20,30,40}
  t._rd={3,4}
  local target={_deformVertices={0,0,0,0,0},_transformDirty=false}
  t.target=blend(target,0.5,1)
  t:blend(true)
  near(target._deformVertices[1],5)
  near(target._deformVertices[2],1.5)
  near(target._deformVertices[3],2)
  near(target._deformVertices[4],10)
  near(target._deformVertices[5],15)
  eq(target._transformDirty,true)
end)
check("Surface pose without float array resets vertex deviations only",function()
  local t=fixture("SurfaceTimelineState",false)
  local target={_deformVertices={10,20,30},_transformDirty=false}
  t.target=blend(target,0.3,1)
  t._valueArray=nil;t._deformCount=3
  t:blend(false)
  near(target._deformVertices[1],0)
  near(target._deformVertices[3],0)
end)
check("Deform blends FFD and marks slot verticesDirty for active geometry",function()
  local t=fixture("DeformTimelineState")
  local geometry={}
  local frame={deformVertices={0,0,0,0}}
  function frame:getGeometryData() return geometry end
  local slot={_geometryData=geometry,_verticesDirty=false}
  t.displayFrame=frame
  t.target=blend(slot,0.5,1)
  t._deformCount=4;t._deformOffset=1;t._valueCount=2
  t._sameValueOffset=0;t._valueArray={10,20,30}
  t._rd={4,8}
  t:blend(true)
  near(frame.deformVertices[1],5)
  near(frame.deformVertices[2],2)
  near(frame.deformVertices[3],4)
  near(frame.deformVertices[4],10)
  eq(slot._verticesDirty,true)
end)
check("Deform skips vertex dirty when active geometry differs",function()
  local t=fixture("DeformTimelineState")
  local frame={deformVertices={1}}
  function frame:getGeometryData() return {} end
  local slot={_geometryData={}}
  t.displayFrame=frame;t.target=blend(slot,1,1)
  t._valueArray=nil;t._deformCount=1
  t:blend(true)
  eq(frame.deformVertices[1],0)
  eq(slot._verticesDirty,nil)
end)
check("IKConstraint pose restores original constraint parameters",function()
  local t=fixture("IKConstraintTimelineState",false)
  local c={_constraintData={bendPositive=true,weight=0.75},dirty=0}
  function c:invalidUpdate() self.dirty=self.dirty+1 end
  t.target=c;t:update(0.25)
  eq(c._bendPositive,true)
  near(c._weight,0.75)
  eq(c.dirty,1)
end)
check("IKConstraint animated frame uses _current fields like original",function()
  local t=fixture("IKConstraintTimelineState")
  local c={dirty=0}
  function c:invalidUpdate() self.dirty=self.dirty+1 end
  t.target=c;t._currentA=-1;t._currentB=0.4
  t._timelineData={}
  t:_onUpdateFrame()
  eq(c._bendPositive,false)
  near(c._weight,0.4)
end)
check("child AnimationProgress updates child currentTime only with parent",function()
  local t=fixture("AnimationProgressTimelineState")
  local child={_parent=true,totalTime=4,currentTime=0}
  t.target=child
  t._result=0.25;t._isTween=false
  t:_onUpdateFrame()
  near(child.currentTime,1)
  eq(t.dirty,false)
  child._parent=nil
  t._result=0.75;t:_onUpdateFrame()
  near(child.currentTime,1)
end)
check("child AnimationWeight updates child weight only with parent",function()
  local t=fixture("AnimationWeightTimelineState")
  local child={_parent=true,weight=1}
  t.target=child
  t._result=0.4;t:_onUpdateFrame()
  near(child.weight,0.4)
  eq(t.dirty,false)
end)
check("child AnimationParameters updates parameterX/Y independently",function()
  local t=fixture("AnimationParametersTimelineState")
  local child={_parent=true,parameterX=0,parameterY=0}
  t.target=child
  t._resultA=0.3;t._resultB=-0.6
  t:_onUpdateFrame()
  near(child.parameterX,0.3)
  near(child.parameterY,-0.6)
end)
check("pool reborrow clears concrete deform fields and frame reference",function()
  local t=Pool.borrowObject(Classes.DeformTimelineState)
  t.displayFrame={}
  t._deformCount=10
  t:returnToPool()
  local reused=Pool.borrowObject(Classes.DeformTimelineState)
  eq(reused,t);eq(reused.displayFrame,nil);eq(reused._deformCount,0)
  reused:returnToPool()
end)
check("real AnimationState.init now constructs real ActionTimelineState",function()
  local arm=Pool.borrowObject(Armature)
  local model=Pool.borrowObject(ArmModel.ArmatureData)
  model.name="arm";model.frameRate=24
  model.parent={name="db",frameArray={},timelineArray={},
    frameIndices={},frameIntArray={},frameFloatArray={},cachedFrames={}}
  local proxy={hasDBEventListener=function() return false end}
  function proxy:dbInit(a) self.owner=a end
  function proxy:dbUpdate() end
  function proxy:dbClear() end
  local dragon={bufferObject=function() end,bufferEvent=function() end}
  arm:init(model,proxy,{},dragon)
  local data=Pool.borrowObject(Model.AnimationData)
  data.parent=model;data.name="idle"
  data.duration=2;data.frameCount=48;data.playTimes=1
  arm.animation.animations={idle=data}
  local state=arm.animation:play("idle",1)
  eq(getmetatable(state),State)
  eq(getmetatable(state._actionTimeline),Classes.ActionTimelineState)
  arm:advanceTime(0.1)
  eq(state._actionTimeline.playState,0)
  eq(arm._lockUpdate,false)
end)

print(("Original TimelineState.ts: %d passed, %d failed, %d assertions"):format(passed,failed,checks))
if failed>0 then os.exit(1) end
