-- Conformance tests for pinned DragonBonesJS:
-- model/UserData.ts, event/EventObject.ts, core/DragonBones.ts.
-- Lua-only test doubles implement IEventDispatcher and Armature contracts;
-- these doubles are NOT runtime substitutes or new production modules.
package.path="./?.lua;./?/init.lua;"..package.path
local BaseObject=require("dragonbones.original.core.BaseObject")
local modules=require("dragonbones.original.model.UserData")
local UserData,ActionData=modules.UserData,modules.ActionData
local EventObject=require("dragonbones.original.event.EventObject")
local DragonBones=require("dragonbones.original.core.DragonBones")
local passed,failed=0,0
local function test(name,fn)
  local ok,err=pcall(fn)
  if ok then
    passed=passed+1
    print("ok original.events "..name)
  else
    failed=failed+1
    print("not ok original.events "..name..": "..tostring(err))
  end
end
local function dispatcher()
  local result={received={},listeners={}}
  function result:hasDBEventListener(kind) return self.listeners[kind] == true end
  function result:dispatchDBEvent(kind,event)
    self.received[#self.received+1]={kind=kind,event=event}
    if self.callback then self.callback(kind,event) end
  end
  function result:addDBEventListener(kind) self.listeners[kind]=true end
  function result:removeDBEventListener(kind) self.listeners[kind]=nil end
  return result
end
local function armature(bridge,active)
  local result={
    _armatureData=(active==false and nil or {}),
    eventDispatcher=bridge,bones={},slots={}
  }
  function result:getBone(name) return self.bones[name] end
  function result:getSlot(name) return self.slots[name] end
  return result
end
local function event(kind,arm)
  local ev=BaseObject.borrowObject(EventObject)
  ev.type=kind
  ev.armature=arm
  return ev
end

test("UserData original class identifier and empty defaults",function()
  assert(UserData.toString()=="[class dragonBones.UserData]")
  local data=BaseObject.borrowObject(UserData)
  assert(#data.ints==0 and #data.floats==0 and #data.strings==0)
  assert(data:getInt()==0 and data:getFloat()==0 and data:getString()=="")
  data:returnToPool()
end)
test("UserData add/get preserve zero-based index and values",function()
  local data=BaseObject.borrowObject(UserData)
  assert(data:addInt(-14)==nil and data:addInt(37)==nil)
  assert(data:addFloat(3.5)==nil and data:addFloat(-2.25)==nil)
  assert(data:addString("a")==nil and data:addString("Ω")==nil)
  assert(data:getInt()==-14 and data:getInt(1)==37)
  assert(data:getFloat()==3.5 and data:getFloat(1)==-2.25)
  assert(data:getString()=="a" and data:getString(1)=="Ω")
  assert(data:getInt(-1)==0 and data:getInt(2)==0)
  assert(data:getFloat(7)==0 and data:getString(3)=="")
  data:returnToPool()
end)
test("UserData _onClear retains its arrays and clears on pool return",function()
  local data=BaseObject.borrowObject(UserData)
  local ints,floats,strings=data.ints,data.floats,data.strings
  data:addInt(8);data:addFloat(9);data:addString("c")
  data:returnToPool()
  assert(data.ints==ints and data.floats==floats and data.strings==strings)
  assert(#ints==0 and #floats==0 and #strings==0)
  assert(BaseObject.borrowObject(UserData)==data)
end)
test("ActionData default type and all reference fields",function()
  assert(ActionData.toString()=="[class dragonBones.ActionData]")
  local a=BaseObject.borrowObject(ActionData)
  assert(a.type==DragonBones.ActionType.Play and a.name=="")
  assert(a.bone==nil and a.slot==nil and a.data==nil)
  a:returnToPool()
end)
test("ActionData _onClear returns nested UserData to original pool",function()
  local d=BaseObject.borrowObject(UserData)
  d:addInt(123)
  local action=BaseObject.borrowObject(ActionData)
  action.type=DragonBones.ActionType.Sound
  action.name="thud"
  action.bone={name="shoulder"}
  action.slot={name="shield"}
  action.data=d
  action:returnToPool()
  assert(action.type==0 and action.name=="")
  assert(action.bone==nil and action.slot==nil and action.data==nil)
  local received=BaseObject.borrowObject(UserData)
  assert(received==d and #received.ints==0)
end)
test("EventObject static event strings and identity",function()
  assert(EventObject.toString()=="[class dragonBones.EventObject]")
  assert(EventObject.START=="start")
  assert(EventObject.LOOP_COMPLETE=="loopComplete")
  assert(EventObject.COMPLETE=="complete")
  assert(EventObject.FADE_IN=="fadeIn")
  assert(EventObject.FADE_IN_COMPLETE=="fadeInComplete")
  assert(EventObject.FADE_OUT=="fadeOut")
  assert(EventObject.FADE_OUT_COMPLETE=="fadeOutComplete")
  assert(EventObject.FRAME_EVENT=="frameEvent")
  assert(EventObject.SOUND_EVENT=="soundEvent")
end)
test("EventObject _onClear resets every field with void return",function()
  local e=BaseObject.borrowObject(EventObject)
  e.time=10;e.type="frameEvent";e.name="x"
  e.armature={};e.bone={};e.slot={}
  e.animationState={};e.actionData={};e.data={}
  assert(e:_onClear()==nil)
  assert(e.time==0 and e.type=="" and e.name=="")
  for _,key in ipairs({"armature","bone","slot","animationState","actionData","data"}) do
    assert(e[key]==nil,key)
  end
  e:returnToPool()
end)
test("actionDataToInstance maps Play and Frame to frameEvent",function()
  for _,kind in ipairs({DragonBones.ActionType.Play,DragonBones.ActionType.Frame}) do
    local a=armature(dispatcher())
    local d=BaseObject.borrowObject(ActionData)
    d.type=kind;d.name="hit"
    local e=BaseObject.borrowObject(EventObject)
    assert(EventObject.actionDataToInstance(d,e,a)==nil)
    assert(e.type==EventObject.FRAME_EVENT)
    assert(e.name=="hit" and e.armature==a and e.actionData==d)
    assert(e.bone==nil and e.slot==nil and e.data==nil)
    e:returnToPool();d:returnToPool()
  end
end)
test("actionDataToInstance maps Sound and unknown to soundEvent",function()
  for _,kind in ipairs({DragonBones.ActionType.Sound,42}) do
    local a=armature(dispatcher())
    local d=BaseObject.borrowObject(ActionData)
    d.type=kind
    local e=BaseObject.borrowObject(EventObject)
    EventObject.actionDataToInstance(d,e,a)
    assert(e.type==EventObject.SOUND_EVENT)
    e:returnToPool();d:returnToPool()
  end
end)
test("actionDataToInstance maps bone, slot and UserData by reference",function()
  local a=armature(dispatcher())
  a.bones.palm={name="palm"}
  a.slots.ring={name="ring"}
  local data=BaseObject.borrowObject(UserData)
  local action=BaseObject.borrowObject(ActionData)
  action.type=10;action.name="jingle";action.bone={name="palm"}
  action.slot={name="ring"};action.data=data
  local e=BaseObject.borrowObject(EventObject)
  EventObject.actionDataToInstance(action,e,a)
  assert(e.bone==a.bones.palm and e.slot==a.slots.ring)
  assert(e.data==data and e.actionData==action)
  e:returnToPool();action:returnToPool()
end)
test("DragonBones original version, flags and enum values",function()
  assert(DragonBones.VERSION=="5.7.000")
  assert(DragonBones.yDown==true and not DragonBones.debug and not DragonBones.debugDraw)
  assert(DragonBones.BinaryOffset.WeigthBoneCount==0)
  assert(DragonBones.BinaryOffset.FrameCurveSamples==3)
  assert(DragonBones.DisplayType.Mesh==2)
  assert(DragonBones.BlendMode.Subtract==13)
  assert(DragonBones.TweenType.QuadInOut==5)
  assert(DragonBones.TimelineType.SlotZIndex==23)
  assert(DragonBones.TimelineType.IKConstraint==30)
  assert(DragonBones.OffsetMode.Override==2)
  assert(DragonBones.AnimationFadeOutMode.Single==5)
  assert(DragonBones.ConstraintType.Path==1)
  assert(DragonBones.RotateMode.ChainScale==2)
end)
test("DragonBones constructor exposes original clock and eventManager",function()
  local manager=dispatcher()
  local d=DragonBones.new(manager)
  assert(d.eventManager==manager and d.clock~=nil)
  assert(d.clock.time==0 and d.clock.timeScale==1)
  assert(#d._events==0 and #d._objects==0)
end)
test("bufferEvent and bufferObject deduplicate by identity",function()
  local d=DragonBones.new(dispatcher())
  local e=event(EventObject.START,armature(dispatcher()))
  d:bufferEvent(e);d:bufferEvent(e)
  d:bufferObject(e);d:bufferObject(e)
  assert(#d._events==1 and #d._objects==1)
  d._events={};d._objects={}
  e:returnToPool()
end)
test("DragonBones dispatches frame events only to armature dispatcher",function()
  local bridge,global=dispatcher(),dispatcher()
  local d=DragonBones.new(global)
  local a=armature(bridge)
  local e=event(EventObject.FRAME_EVENT,a)
  assert(d:bufferEvent(e)==nil)
  d:advanceTime(.1)
  assert(#bridge.received==1 and bridge.received[1].event==e)
  assert(#global.received==0 and #d._events==0)
  assert(#d._objects==1)
  d:advanceTime(.1)
  assert(#d._objects==0 and e._isInPool==true)
end)
test("DragonBones routes soundEvent both to armature and global manager",function()
  local bridge,global=dispatcher(),dispatcher()
  local d=DragonBones.new(global)
  local e=event(EventObject.SOUND_EVENT,armature(bridge))
  d:bufferEvent(e)
  d:advanceTime(.1)
  assert(#bridge.received==1 and #global.received==1)
  assert(bridge.received[1].event==e and global.received[1].event==e)
  d:advanceTime(0)
end)
test("DragonBones ignores events from disposed armature, still recycles",function()
  local bridge=dispatcher()
  local d=DragonBones.new(dispatcher())
  local a=armature(bridge)
  a._armatureData=nil
  local e=event(EventObject.START,a)
  d:bufferEvent(e)
  d:advanceTime(.1)
  assert(#bridge.received==0)
  assert(#d._objects==1 and #d._events==0)
  d:advanceTime(.1)
  assert(e._isInPool)
end)
test("buffered event inside a frame dispatcher executes in same advanceTime",function()
  local bridge=dispatcher()
  local d=DragonBones.new(dispatcher())
  local a=armature(bridge)
  local first=event(EventObject.FRAME_EVENT,a)
  local second=event(EventObject.COMPLETE,a)
  bridge.callback=function(_,e)
    if e==first then d:bufferEvent(second) end
  end
  d:bufferEvent(first)
  d:advanceTime(.2)
  assert(#bridge.received==2)
  assert(bridge.received[1].event==first and bridge.received[2].event==second)
  assert(#d._objects==2 and #d._events==0)
  d:advanceTime(.2)
end)
test("clock callbacks buffer fresh events before dispatch and next-tick recycling",function()
  local bridge=dispatcher()
  local d=DragonBones.new(dispatcher())
  local a=armature(bridge)
  local actor={clock=nil}
  function actor:advanceTime()
    local ev=event(EventObject.START,a)
    d:bufferEvent(ev)
  end
  d.clock:add(actor)
  d:advanceTime(.1)
  assert(#bridge.received==1 and #d._objects==1)
  local first=bridge.received[1].event
  assert(not first._isInPool)
  d:advanceTime(.2)
  assert(#bridge.received==2 and #d._objects==1)
  -- The old event is recycled before the clock updates. Its memory can
  -- therefore be reborrowed by the callback during that same frame.
  assert(bridge.received[2].event==first)
end)
test("re-buffering an event already buffered as object does not duplicate pool entries",function()
  local bridge=dispatcher()
  local d=DragonBones.new(dispatcher())
  local a=armature(bridge)
  local ev=event(EventObject.COMPLETE,a)
  bridge.callback=function(_,e)
    d:bufferObject(e)
    d:bufferObject(e)
  end
  d:bufferEvent(ev)
  d:bufferEvent(ev)
  d:advanceTime(.1)
  assert(#bridge.received==1 and #d._objects==1)
  d:advanceTime(.1)
end)

print(("Original event/core port: %d passed, %d failed"):format(passed,failed))
if failed>0 then os.exit(1) end
