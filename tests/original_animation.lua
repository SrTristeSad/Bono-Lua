-- Original animation/Animation.ts conformance, pinned DragonBonesJS
-- 64b6c69ae35777c2404be68c9192e2c56906079e.
-- AnimationState and BlendState are test-only contract classes here.
package.path="./?.lua;./?/init.lua;"..package.path
local Base=require("dragonbones.original.core.BaseObject")
local Animation=require("dragonbones.original.animation.Animation")
local Config=require("dragonbones.original.model.AnimationConfig")
local AnimData=require("dragonbones.original.model.AnimationData").AnimationData
local Armature=require("dragonbones.original.armature.Armature")
local ArmatureData=require("dragonbones.original.model.ArmatureData").ArmatureData
local Core=require("dragonbones.original.core.DragonBones")
local Mode=Core.AnimationFadeOutMode
local passed,failed,assertions=0,0,0
local function eq(a,b)
  assertions=assertions+1
  assert(a==b,tostring(a).." ~= "..tostring(b))
end
local function near(a,b)
  assertions=assertions+1
  assert(a~=nil and b~=nil and math.abs(a-b)<1e-6,tostring(a).." ~= "..tostring(b))
end
local function test(name,fn)
  local ok,err=pcall(fn)
  if ok then passed=passed+1;print("ok original.animation "..name)
  else failed=failed+1;print("not ok original.animation "..name..": "..tostring(err)) end
end
local State={}
State.__index=function(self,key)
  if key=="animationData" then return self._animationData end
  if key=="isPlaying" then return self._playing end
  if key=="isCompleted" then return self._completed end
  return rawget(State,key) or Base[key]
end
setmetatable(State,{__index=Base})
function State.new() return Base.new(State) end
function State:_onClear()
  self._parent=nil
  self._fadeState=0;self._subFadeState=0
  self._playing=true;self._completed=false
  self._animationData=nil
  self.name="";self.layer=0;self.group=""
  self.advanced={};self.fades={};self.children={}
  self.stops=0;self.plays=0
end
function State:init(armature,data,config)
  self._armature=armature
  self._animationData=data
  self.name=config.animation
  self.layer=config.layer
  self.group=config.group
  self.position=config.position
  self.duration=config.duration
  self.timeScale=config.timeScale
  self.playTimes=config.playTimes
  self.fadeInTime=config.fadeInTime
  self.fadeOutTime=config.fadeOutTime
  self.resetToPose=config.resetToPose
  self.actionEnabled=config.actionEnabled
end
function State:advanceTime(t,cacheRate)
  self.advanced[#self.advanced+1]={time=t,rate=cacheRate}
end
function State:fadeOut(time,pause)
  self.fades[#self.fades+1]={time=time,pause=pause}
end
function State:stop() self.stops=self.stops+1;self._playing=false end
function State:play() self.plays=self.plays+1;self._playing=true end
function State:addState(other,timelines)
  self.children[#self.children+1]={other,timelines}
  other._parent=self
end
local Blend={}
Blend.__index=Blend
setmetatable(Blend,{__index=Base})
function Blend.new() return Base.new(Blend) end
function Blend:_onClear() self.target=nil;self.resets=0 end
function Blend:reset() self.resets=self.resets+1 end
package.loaded["dragonbones.original.animation.AnimationState"]=State
package.loaded["dragonbones.original.animation.BlendState"]=Blend
local function data(name,frames,duration)
  local d=Base.borrowObject(AnimData)
  d.name=name
  d.frameCount=frames==nil and 20 or frames
  d.duration=duration==nil and 2 or duration
  d.scale=2
  d.playTimes=3
  d.fadeInTime=0.4
  return d
end
local function fixture()
  local a=Base.borrowObject(Armature)
  local model=Base.borrowObject(ArmatureData)
  model.parent={name="TestDragon",cachedFrames={}}
  model.name="TestArmature"
  local dragon={objects={}}
  function dragon:bufferObject(v) self.objects[#self.objects+1]=v end
  local proxy={initialized=false}
  function proxy:dbInit() self.initialized=true end
  function proxy:dbUpdate() end
  function proxy:dbClear() end
  a:init(model,proxy,{},dragon)
  return a.animation,a,model,dragon
end
local function register(animation,name,frames,duration)
  local d=data(name,frames,duration)
  local map={}
  for k,v in pairs(animation.animations) do map[k]=v end
  map[name]=d
  animation.animations=map
  return d
end
local function freshAnimation()
  local animation=Base.borrowObject(Animation)
  local holder={inheritAnimation=true,_parent=nil,_cacheFrameIndex=-1}
  local model=Base.borrowObject(ArmatureData)
  model.parent={name="DB",cachedFrames={}};model.name="armature"
  holder.armatureData=model;holder.name=model.name
  holder._dragonBones={objects={}}
  function holder._dragonBones:bufferObject(v) self.objects[#self.objects+1]=v end
  function holder:getBones() return self.bones or {} end
  function holder:getSlots() return self.slots or {} end
  animation:init(holder)
  return animation,holder
end

test("class name, zeroed initial arrays and default timescale",function()
  local a=Base.borrowObject(Animation)
  eq(Animation.toString(),"[class dragonBones.Animation]")
  eq(a.timeScale,1);eq(a._animationDirty,false)
  eq(a._inheritTimeScale,1)
  eq(#a._animationStates,0);eq(#a._animationNames,0)
  eq(next(a._animations),nil);eq(next(a._blendStates),nil)
  eq(a._animationConfig,nil)
  eq(a.isPlaying,false);eq(a.isCompleted,false)
  eq(a.lastAnimationName,"")
end)
test("real Armature.init now resolves real Animation and borrows AnimationConfig",function()
  local animation,a,model,dragon=fixture()
  eq(getmetatable(animation),Animation)
  eq(a.animation,animation)
  eq(animation._armature,a)
  eq(getmetatable(animation._animationConfig),Config)
  eq(a._proxy.initialized,true)
end)
test("init guard refuses replacement of armature/config",function()
  local anim,a=fixture()
  local config=anim._animationConfig
  anim:init({})
  eq(anim._armature,a);eq(anim._animationConfig,config)
end)
test("animations setter copies object map and retains old identity",function()
  local anim=freshAnimation()
  local map=anim.animations
  local d=data("idle")
  anim.animations={idle=d}
  eq(anim.animations,map);eq(map.idle,d)
  eq(anim.animationNames[1],"idle")
  eq(anim:hasAnimation("idle"),true)
  eq(anim:hasAnimation("walk"),false)
  local names=anim.animationNames
  anim.animations={jump=d}
  eq(anim.animationNames,names);eq(#names,1)
  eq(names[1],"jump");eq(map.idle,nil);eq(map.jump,d)
end)
test("animations setter identical map does not change names",function()
  local anim=freshAnimation()
  anim.animations={idle=data("idle")}
  local names=anim.animationNames
  anim.animations=anim.animations
  eq(anim.animationNames,names);eq(names[1],"idle")
end)
test("animationConfig getter clears previous values on every access",function()
  local anim=freshAnimation()
  local cfg=anim.animationConfig
  cfg.animation="run";cfg.layer=4
  eq(anim.animationConfig,cfg)
  eq(cfg.animation,"");eq(cfg.layer,0)
end)
test("empty advanceTime resets armature cache and uses absolute time",function()
  local anim,arm=freshAnimation()
  arm._cacheFrameIndex=8
  anim:advanceTime(-0.25)
  eq(arm._cacheFrameIndex,-1)
end)
test("inherited time scale multiplies parent inherited scale",function()
  local anim,arm=freshAnimation()
  local p={_armature={animation={_inheritTimeScale=0.5}}}
  arm._parent=p
  anim.timeScale=2
  anim:advanceTime(-1)
  near(anim._inheritTimeScale,1)
  arm._parent=nil
  anim:advanceTime(1)
  near(anim._inheritTimeScale,2)
end)
test("blend states are reused, assigned target, and reset by advanceTime",function()
  local anim=freshAnimation()
  local target={}
  local a=anim:getBlendState("bone","root",target)
  eq(getmetatable(a),Blend)
  eq(a.target,target)
  eq(anim:getBlendState("bone","root",{}),a)
  anim:advanceTime(0.1)
  eq(a.resets,1)
end)
test("reset clears all states, retains config identity and zeroes last state",function()
  local anim=freshAnimation()
  local state=Base.borrowObject(State)
  anim._animationStates[1]=state
  anim._lastAnimationState=state
  anim._animationDirty=true
  local config=anim._animationConfig
  config.animation="walk"
  anim:reset()
  eq(state._isInPool,true)
  eq(#anim._animationStates,0)
  eq(anim._lastAnimationState,nil)
  eq(anim._animationDirty,false)
  eq(anim._animationConfig,config)
  eq(config.animation,"")
end)
test("stop nil pauses every state, specific name stops only selected",function()
  local anim=freshAnimation()
  local one=Base.borrowObject(State)
  local two=Base.borrowObject(State)
  one.name="walk";two.name="run"
  anim._animationStates={one,two}
  anim:stop("walk")
  eq(one.stops,1);eq(two.stops,0)
  anim:stop()
  eq(one.stops,2);eq(two.stops,1)
end)
test("getState searches from most recent and supports layer filtering",function()
  local anim=freshAnimation()
  local a=Base.borrowObject(State);a.name="run";a.layer=0
  local b=Base.borrowObject(State);b.name="run";b.layer=1
  anim._animationStates={a,b}
  eq(anim:getState("run"),b)
  eq(anim:getState("run",0),a)
  eq(anim:getState("none"),nil)
  eq(anim:getStates(),anim._animationStates)
end)
test("isPlaying, isCompleted and lastAnimationName use current states",function()
  local anim=freshAnimation()
  local s=Base.borrowObject(State)
  s.name="idle"
  anim._animationStates={s};anim._lastAnimationState=s
  eq(anim.isPlaying,true);eq(anim.isCompleted,false)
  eq(anim.lastAnimationName,"idle")
  s._playing=false;s._completed=true
  eq(anim.isPlaying,false);eq(anim.isCompleted,true)
end)
test("_fadeOut respects SameLayer and ignores nested states",function()
  local anim=freshAnimation()
  local a,b,c=Base.borrowObject(State),Base.borrowObject(State),Base.borrowObject(State)
  a.layer=1;b.layer=2;c.layer=1;c._parent={}
  anim._animationStates={a,b,c}
  anim:_fadeOut({fadeOutMode=Mode.SameLayer,layer=1,fadeOutTime=0.3,pauseFadeOut=true})
  eq(#a.fades,1);eq(#b.fades,0);eq(#c.fades,0)
  eq(a.fades[1].pause,true)
end)
test("_fadeOut respects group, layer+group, All and Single TODO",function()
  local anim=freshAnimation()
  local a,b=Base.borrowObject(State),Base.borrowObject(State)
  a.group="x";a.layer=1;b.group="y";b.layer=2
  anim._animationStates={a,b}
  local cfg={fadeOutMode=Mode.SameGroup,group="x",layer=2,fadeOutTime=1}
  anim:_fadeOut(cfg)
  eq(#a.fades,1);eq(#b.fades,0)
  cfg.fadeOutMode=Mode.SameLayerAndGroup
  anim:_fadeOut(cfg)
  eq(#a.fades,1);eq(#b.fades,0)
  cfg.fadeOutMode=Mode.Single;anim:_fadeOut(cfg)
  eq(#a.fades,1);eq(#b.fades,0)
  cfg.fadeOutMode=Mode.All;anim:_fadeOut(cfg)
  eq(#a.fades,2);eq(#b.fades,1)
end)
test("single state advance uses its cache frame rate and time scale",function()
  local anim,arm=freshAnimation()
  local state=Base.borrowObject(State)
  state._animationData={cacheFrameRate=24}
  anim._animationStates={state};anim.timeScale=0.5
  anim:advanceTime(-2)
  near(state.advanced[1].time,1)
  eq(state.advanced[1].rate,24)
end)
test("single faded state is buffered and last state cleared",function()
  local anim,arm=freshAnimation()
  local state=Base.borrowObject(State)
  state._fadeState=1;state._subFadeState=1
  anim._animationStates={state};anim._lastAnimationState=state
  anim:advanceTime(1)
  eq(#anim._animationStates,0)
  eq(anim._lastAnimationState,nil)
  eq(arm._dragonBones.objects[1],state)
end)
test("cache indices assigned to bones and only default-skin slots",function()
  local anim,arm=freshAnimation()
  local state=Base.borrowObject(State)
  local skin={}
  arm.armatureData.defaultSkin=skin
  local data={cacheFrameRate=24}
  function data:getBoneCachedFrameIndices(name) return {name} end
  function data:getSlotCachedFrameIndices(name) return {name} end
  state._animationData=data
  anim._animationStates={state};anim._animationDirty=true
  local bone={name="root"}
  local slot={name="body",displayFrameCount=1}
  function slot:getDisplayFrameAt() return {rawDisplayData={parent=skin}} end
  local extra={name="other",displayFrameCount=0}
  arm.bones={bone};arm.slots={slot,extra}
  anim:advanceTime(0.5)
  eq(bone._cachedFrameIndices[1],"root")
  eq(slot._cachedFrameIndices[1],"body")
  eq(extra._cachedFrameIndices,nil)
  eq(anim._animationDirty,false)
end)
test("multiple states compact faded ones, force zero cache and maintain last",function()
  local anim,arm=freshAnimation()
  local a,b,c=Base.borrowObject(State),Base.borrowObject(State),Base.borrowObject(State)
  a._fadeState=1;a._subFadeState=1
  a._animationData={cacheFrameRate=10}
  b._animationData={cacheFrameRate=11}
  c._animationData={cacheFrameRate=12}
  anim._animationStates={a,b,c};anim._lastAnimationState=a
  arm._cacheFrameIndex=19
  anim:advanceTime(0.5)
  eq(#anim._animationStates,2)
  eq(anim._animationStates[1],b);eq(anim._animationStates[2],c)
  eq(anim._lastAnimationState,c)
  eq(arm._cacheFrameIndex,-1)
  eq(b.advanced[1].rate,0);eq(c.advanced[1].rate,0)
end)
test("playConfig returns nil for unknown animation",function()
  local anim=freshAnimation()
  local config=anim.animationConfig
  config.animation="missing"
  eq(anim:playConfig(config),nil)
  eq(#anim._animationStates,0)
end)
test("playConfig borrows original AnimationState via contract test",function()
  local anim,arm=freshAnimation()
  local source=register(anim,"run")
  local config=anim.animationConfig
  config.animation="run"
  local state=anim:playConfig(config)
  eq(getmetatable(state),State)
  eq(state.animationData,source)
  eq(state.name,"run")
  near(config.fadeInTime,0)
  near(config.fadeOutTime,0)
  near(config.timeScale,0.5)
  eq(config.playTimes,3)
  eq(anim.lastAnimationState,state)
  eq(arm._cacheFrameIndex,-1)
end)
test("playConfig Single mode returns same active state on same layer",function()
  local anim=freshAnimation()
  register(anim,"run")
  local one=anim:fadeIn("run",0,1,2,"",Mode.Single)
  local two=anim:fadeIn("run",0,1,2,"",Mode.Single)
  eq(one,two)
  eq(#anim._animationStates,1)
end)
test("playConfig applies frame duration overflow and exact endpoint epsilon",function()
  local anim=freshAnimation()
  register(anim,"jump",10,2)
  local config=anim.animationConfig
  config.animation="jump";config.position=2;config.duration=10
  anim:playConfig(config)
  near(config.position,1.999999)
  near(config.duration,0.000001)
end)
test("playConfig wraps positive position beyond duration",function()
  local anim=freshAnimation()
  register(anim,"jump",10,2)
  local config=anim.animationConfig
  config.animation="jump";config.position=5
  anim:playConfig(config)
  near(config.position,1)
end)
test("playConfig uses signed JS remainder for negative position",function()
  local anim=freshAnimation()
  register(anim,"jump",10,2)
  local config=anim.animationConfig
  config.animation="jump";config.position=-0.5
  anim:playConfig(config)
  near(config.position,2.5)
end)
test("playConfig static animation resets position and forces one play",function()
  local anim=freshAnimation()
  register(anim,"still",0,0)
  local config=anim.animationConfig
  config.animation="still";config.position=4;config.duration=2
  anim:playConfig(config)
  near(config.position,0)
  eq(config.duration,-1);eq(config.playTimes,1)
end)
test("playConfig inserts higher layer before lower layer",function()
  local anim=freshAnimation()
  register(anim,"run");register(anim,"jump")
  local low=anim:fadeIn("run",0,1,0,"",Mode.Single)
  local high=anim:fadeIn("jump",0,1,2,"",Mode.Single)
  eq(anim._animationStates[1],high)
  eq(anim._animationStates[2],low)
end)
test("play plays default animation or resumes last paused state",function()
  local anim,arm=freshAnimation()
  local d=register(anim,"idle")
  arm.armatureData.defaultAnimation=d
  local state=anim:play()
  eq(state.name,"idle")
  state._playing=false;state._completed=false
  local res=anim:play()
  eq(res,state);eq(state.plays,1)
end)
test("play with explicit name triggers new state and returns last",function()
  local anim=freshAnimation()
  register(anim,"run")
  local state=anim:play("run",2)
  eq(state.name,"run");eq(state.playTimes,2)
end)
test("fadeIn honors explicit group, layer and fade out mode",function()
  local anim=freshAnimation()
  register(anim,"run")
  local state=anim:fadeIn("run",0.8,2,4,"friends",Mode.Single)
  eq(state.layer,4);eq(state.group,"friends")
  eq(state.playTimes,2)
  -- Source clamps first animation's fadeInTime to zero.
  near(state.fadeInTime,0)
end)
test("gotoAndPlayByFrame computes source frame fraction",function()
  local anim=freshAnimation()
  register(anim,"run",20,2)
  local state=anim:gotoAndPlayByFrame("run",5,1)
  near(state.position,0.5)
end)
test("gotoAndPlayByProgress clamps only negative progress",function()
  local anim=freshAnimation()
  register(anim,"run",20,2)
  local state=anim:gotoAndPlayByProgress("run",0.25,1)
  near(state.position,0.5)
end)
test("gotoAndStopByTime starts then stops, preserving returned state",function()
  local anim=freshAnimation()
  register(anim,"run")
  local s=anim:gotoAndStopByTime("run",0.75)
  near(s.position,0.75);eq(s.stops,1)
end)
test("gotoAndStopByFrame starts then stops",function()
  local anim=freshAnimation()
  register(anim,"run")
  local s=anim:gotoAndStopByFrame("run",10)
  near(s.position,1);eq(s.stops,1)
end)
test("gotoAndStopByProgress starts then stops",function()
  local anim=freshAnimation()
  register(anim,"run")
  local s=anim:gotoAndStopByProgress("run",0.25)
  near(s.position,0.5);eq(s.stops,1)
end)
test("playConfig recursively creates animation sub-state from animationTimelines",function()
  local anim=freshAnimation()
  register(anim,"child")
  local parentData=register(anim,"parent")
  local timelines={{id=1}}
  parentData.animationTimelines.child=timelines
  local parent=anim:fadeIn("parent",0,1,0,"",Mode.Single)
  eq(parent.name,"parent")
  eq(#parent.children,1)
  eq(parent.children[1][1].name,"child")
  eq(parent.children[1][2],timelines)
  eq(parent.children[1][1].actionEnabled,false)
  eq(parent.children[1][1].resetToPose,false)
  eq(parent.children[1][1].stops,1)
end)
test("_onClear returns states, blends and animationConfig to pools",function()
  local anim=freshAnimation()
  local state=Base.borrowObject(State)
  anim._animationStates={state}
  local blend=anim:getBlendState("bone","root",{})
  local config=anim._animationConfig
  anim:returnToPool()
  eq(state._isInPool,true);eq(blend._isInPool,true)
  eq(config._isInPool,true)
  local nextAnim=Base.borrowObject(Animation)
  eq(anim,nextAnim)
  eq(#nextAnim._animationStates,0)
  eq(next(nextAnim._blendStates),nil)
  eq(nextAnim._animationConfig,nil)
end)
print(("Original Animation.ts: %d passed, %d failed, %d assertions"):format(passed,failed,assertions))
if failed>0 then os.exit(1) end
