-- Original DragonBonesJS Armature.ts contract tests.
-- Source: 64b6c69ae35777c2404be68c9192e2c56906079e.
package.path="./?.lua;./?/init.lua;"..package.path
local Base=require("dragonbones.original.core.BaseObject")
local Armature=require("dragonbones.original.armature.Armature")
local Bone=require("dragonbones.original.armature.Bone")
local Model=require("dragonbones.original.model.ArmatureData")
local Core=require("dragonbones.original.core.DragonBones")
local WorldClock=require("dragonbones.original.animation.WorldClock")
local passed,failed,assertions=0,0,0
local function eq(a,b)
  assertions=assertions+1
  assert(a==b,tostring(a).." ~= "..tostring(b))
end
local function near(a,b)
  assertions=assertions+1
  assert(a~=nil and b~=nil and math.abs(a-b)<1e-7,tostring(a).." ~= "..tostring(b))
end
local function test(name,action)
  local ok,err=pcall(action)
  if ok then passed=passed+1;print("ok original.armature "..name)
  else failed=failed+1;print("not ok original.armature "..name..": "..tostring(err)) end
end
local function new() return Base.borrowObject(Armature) end
local function fixture()
  local a=new()
  local data=Base.borrowObject(Model.ArmatureData)
  data.name="human"
  data.parent={cachedFrames={}}
  a._armatureData=data
  local proxy={updated=0,cleared=0}
  function proxy:dbUpdate() self.updated=self.updated+1 end
  function proxy:dbClear() self.cleared=self.cleared+1 end
  local animation={time={},fades={}}
  function animation:advanceTime(dt) self.time[#self.time+1]=dt end
  function animation:fadeIn(name) self.fades[#self.fades+1]=name end
  a._animation=animation
  a._proxy=proxy
  local dragon={buffered={}}
  function dragon:bufferObject(v) self.buffered[#self.buffered+1]=v end
  a._dragonBones=dragon
  return a,data,animation,proxy,dragon
end
local function rawBone(name,parent)
  local b={name=name,parent=parent,_globalAlpha=1,dirty=0,updates={},alphas=0}
  function b:invalidUpdate() self.dirty=self.dirty+1 end
  function b:_updateAlpha() self.alphas=self.alphas+1 end
  function b:update(index) self.updates[#self.updates+1]=index end
  function b:returnToPool() self.pooled=true end
  return b
end
local function rawSlot(name,parent,display,zIndex,zOrder)
  local s={name=name,parent=parent,display=display,childArmature=nil,
    _zIndex=zIndex or 0,_zOrder=zOrder or 0,dirty=0,
    updateIndices={},alphas=0,zOrders={}}
  function s:invalidUpdate() self.dirty=self.dirty+1 end
  function s:_updateAlpha() self.alphas=self.alphas+1 end
  function s:update(index) self.updateIndices[#self.updateIndices+1]=index end
  function s:_setZOrder(v)
    self._zOrder=v
    self.zOrders[#self.zOrders+1]=v
  end
  function s:containsPoint(x,y) return self.pointHit==true end
  function s:intersectsSegment(xA,yA,xB,yB,pA,pB,normals)
    if self.intersectCount~=nil then
      if pA~=nil then pA.x=self.startX;pA.y=self.startY end
      if pB~=nil then pB.x=self.endX;pB.y=self.endY end
      if normals~=nil then normals.x=self.startN;normals.y=self.endN end
    end
    return self.intersectCount or 0
  end
  function s:returnToPool() self.pooled=true end
  return s
end
local function action(name,scopeType,scope,actionType)
  local a={actionData={name=name,type=actionType or Core.ActionType.Play},
    bone=nil,slot=nil,returns=0}
  if scopeType=="bone" then a.bone=scope end
  if scopeType=="slot" then a.slot=scope end
  function a:returnToPool() self.returns=self.returns+1 end
  return a
end
test("source static toString and nonstandard equal-key comparator",function()
  eq(Armature.toString(),"[class dragonBones.Armature]")
  eq(Armature._onSortSlots({_zIndex=2,_zOrder=5},{_zIndex=1,_zOrder=90}),1)
  eq(Armature._onSortSlots({_zIndex=0,_zOrder=1},{_zIndex=1,_zOrder=0}),-1)
  eq(Armature._onSortSlots({_zIndex=0,_zOrder=3},{_zIndex=0,_zOrder=3}),-1)
end)
test("object fields initialized exactly as source _onClear",function()
  local a=new()
  eq(a.inheritAnimation,true);eq(a._lockUpdate,false)
  eq(a._slotsDirty,true);eq(a._zOrderDirty,false)
  eq(a._zIndexDirty,false);eq(a._alphaDirty,true)
  eq(a.flipX,false);eq(a.flipY,false)
  eq(a._cacheFrameIndex,-1)
  near(a._alpha,1);near(a._globalAlpha,1)
  eq(#a._bones,0);eq(#a._slots,0)
  eq(#a._constraints,0);eq(#a._actions,0)
  eq(a._armatureData,nil);eq(a.clock,nil)
  eq(a._proxy,nil);eq(a._animation,nil)
end)
test("getters return original backing fields and existing array references",function()
  local a,data,animation,proxy=fixture()
  local display={}
  a._display=display
  eq(a.name,"human");eq(a.armatureData,data)
  eq(a.animation,animation);eq(a.proxy,proxy)
  eq(a.eventDispatcher,proxy);eq(a.display,display)
  eq(a:getDisplay(),display)
  eq(a:getBones(),a._bones)
  eq(a:getSlots(),a._slots)
  eq(a.parent,nil)
end)
test("add bone, slot, constraint disallows exact duplicate references",function()
  local a=fixture()
  local b=rawBone("a")
  local s=rawSlot("s",b)
  local c={}
  a:_addBone(b);a:_addBone(b)
  a:_addSlot(s);a:_addSlot(s)
  a:_addConstraint(c);a:_addConstraint(c)
  eq(#a:getBones(),1);eq(#a:getSlots(),1)
  eq(#a._constraints,1)
end)
test("distinct objects with same name are not deduplicated",function()
  local a=fixture()
  a:_addBone(rawBone("a"));a:_addBone(rawBone("a"))
  eq(#a:getBones(),2)
  eq(a:getBone("a"),a._bones[1])
end)
test("lookup bone and slot by name, including missing names",function()
  local a=fixture()
  local b1=rawBone("root")
  local b2=rawBone("child",b1)
  local s1=rawSlot("hair",b1)
  local s2=rawSlot("hand",b2)
  a:_addBone(b1);a:_addBone(b2)
  a:_addSlot(s1);a:_addSlot(s2)
  eq(a:getBone("root"),b1);eq(a:getBone("child"),b2)
  eq(a:getSlot("hair"),s1);eq(a:getSlot("hand"),s2)
  eq(a:getBone("other"),nil);eq(a:getSlot("other"),nil)
end)
test("getSlotByDisplay ignores nil, compares exact identity",function()
  local a=fixture()
  local d={}
  local s=rawSlot("s",nil,d)
  a:_addSlot(s)
  eq(a:getSlotByDisplay(d),s)
  eq(a:getSlotByDisplay({}),nil)
  eq(a:getSlotByDisplay(nil),nil)
end)
test("getBoneByDisplay resolves parent through slot",function()
  local a=fixture()
  local b=rawBone("p")
  local display={}
  a:_addSlot(rawSlot("s",b,display))
  eq(a:getBoneByDisplay(display),b)
  eq(a:getBoneByDisplay({}),nil)
end)
test("flip setters invalidate all bones only when changed",function()
  local a=fixture()
  local b1=rawBone("one")
  local b2=rawBone("two")
  a:_addBone(b1);a:_addBone(b2)
  a.flipX=true;eq(a.flipX,true)
  eq(b1.dirty,1);eq(b2.dirty,1)
  a.flipX=true;eq(b1.dirty,1)
  a.flipY=true;eq(a.flipY,true)
  eq(b1.dirty,2);eq(b2.dirty,2)
end)
test("invalidUpdate targets named bone without slots by default",function()
  local a=fixture()
  local b1=rawBone("one");local b2=rawBone("two")
  local s1=rawSlot("s",b1)
  a:_addBone(b1);a:_addBone(b2);a:_addSlot(s1)
  a:invalidUpdate("one")
  eq(b1.dirty,1);eq(b2.dirty,0);eq(s1.dirty,0)
end)
test("invalidUpdate named bone optionally updates only attached slots",function()
  local a=fixture()
  local b1=rawBone("one");local b2=rawBone("two")
  local s1=rawSlot("s1",b1);local s2=rawSlot("s2",b2)
  a:_addBone(b1);a:_addBone(b2);a:_addSlot(s1);a:_addSlot(s2)
  a:invalidUpdate("one",true)
  eq(s1.dirty,1);eq(s2.dirty,0)
  eq(b1.dirty,1);eq(b2.dirty,0)
end)
test("invalidUpdate unknown name does not affect anything",function()
  local a=fixture();local b=rawBone("one");a:_addBone(b)
  a:invalidUpdate("missing",true);eq(b.dirty,0)
end)
test("invalidUpdate empty name means all bones, optional all slots",function()
  local a=fixture()
  local b=rawBone("one");local s=rawSlot("s",b)
  a:_addBone(b);a:_addSlot(s)
  a:invalidUpdate("",false);eq(b.dirty,1);eq(s.dirty,0)
  a:invalidUpdate(nil,true);eq(b.dirty,2);eq(s.dirty,1)
end)
test("_sortZOrder ignores null indices unless dirty and preserves sortedSlots",function()
  local a,data=fixture()
  local b=rawBone("p")
  local s1=rawSlot("s1",b);local s2=rawSlot("s2",b)
  a:_addSlot(s1);a:_addSlot(s2)
  data.sortedSlots={{name="s1"},{name="s2"}}
  a._slotsDirty=false
  a:_sortZOrder(nil,0)
  eq(#s1.zOrders,0);eq(a._slotsDirty,false)
end)
test("_sortZOrder original ordering on flag forces zero based zOrder",function()
  local a,data=fixture()
  local s1=rawSlot("s1");local s2=rawSlot("s2")
  a:_addSlot(s1);a:_addSlot(s2)
  data.sortedSlots={{name="s1"},{name="s2"}}
  a._zOrderDirty=true
  a:_sortZOrder(nil,0)
  eq(s1._zOrder,0);eq(s2._zOrder,1)
  eq(a._zOrderDirty,false);eq(a._slotsDirty,true)
end)
test("_sortZOrder custom indexed order including buffer offset",function()
  local a,data=fixture()
  local s1=rawSlot("s1");local s2=rawSlot("s2")
  a:_addSlot(s1);a:_addSlot(s2)
  data.sortedSlots={{name="s1"},{name="s2"}}
  a:_sortZOrder({123,1,0},1)
  eq(s2._zOrder,0);eq(s1._zOrder,1)
  eq(a._zOrderDirty,true)
end)
test("_sortZOrder ignores indexes outside source array",function()
  local a,data=fixture()
  local s1=rawSlot("s1")
  a:_addSlot(s1)
  data.sortedSlots={{name="s1"}}
  a:_sortZOrder({-1},0)
  eq(#s1.zOrders,0)
end)
test("_bufferAction appends/unshifts and rejects repeated identity",function()
  local a=fixture()
  local x,y,z=action("x"),action("y"),action("z")
  a:_bufferAction(x,true);a:_bufferAction(y,false)
  a:_bufferAction(z,true);a:_bufferAction(y,false)
  eq(a._actions[1],y);eq(a._actions[2],x)
  eq(a._actions[3],z);eq(#a._actions,3)
end)
test("dispose buffers once per call and immediately locks animation",function()
  local a,data,anim,proxy,dragon=fixture()
  a:dispose()
  eq(a._lockUpdate,true)
  eq(dragon.buffered[1],a)
  a:advanceTime(1.0)
  eq(#anim.time,0)
end)
test("dispose when data is nil does nothing",function()
  local a=new()
  a:dispose()
  eq(a._lockUpdate,false)
end)
test("advanceTime warns and leaves lock true on absent data, as source",function()
  local a=new()
  a:advanceTime(0.1)
  eq(a._lockUpdate,true)
end)
test("advanceTime warns and leaves lock true on disposed parent data",function()
  local a,data=fixture()
  data.parent=nil
  a:advanceTime(0.1)
  eq(a._lockUpdate,true)
end)
test("advanceTime calls animation, bone, slot, proxy and alpha",function()
  local a,data,anim,proxy=fixture()
  local b=rawBone("b");local s=rawSlot("s",b)
  a:_addBone(b);a:_addSlot(s)
  a:advanceTime(0.25)
  eq(anim.time[1],0.25)
  eq(b.updates[1],-1);eq(s.updateIndices[1],-1)
  eq(b.alphas,1);eq(s.alphas,1)
  eq(proxy.updated,1);eq(a._lockUpdate,false)
  near(a._globalAlpha,1)
end)
test("advanceTime sorts slots by zIndex*1000+zOrder",function()
  local a=fixture()
  local low=rawSlot("low",nil,nil,0,9)
  local high=rawSlot("high",nil,nil,1,0)
  a:_addSlot(high);a:_addSlot(low)
  a:advanceTime(1)
  eq(a:getSlots()[1],low)
  eq(a:getSlots()[2],high)
end)
test("zIndexDirty forces sequential zOrders following sorted slots",function()
  local a=fixture()
  local s1=rawSlot("s1",nil,nil,1,6)
  local s2=rawSlot("s2",nil,nil,0,9)
  a:_addSlot(s1);a:_addSlot(s2)
  a._zIndexDirty=true
  a:advanceTime(0.1)
  eq(a:getSlots()[1],s2)
  eq(s2._zOrder,0);eq(s1._zOrder,1)
  eq(a._slotsDirty,false);eq(a._zIndexDirty,false)
end)
test("unchanged cache index skips bones and slots after first frame",function()
  local a,data,anim=fixture()
  local b=rawBone("b");local s=rawSlot("s",b)
  a:_addBone(b);a:_addSlot(s)
  a._cacheFrameIndex=5
  a:advanceTime(0.1)
  a:advanceTime(0.2)
  eq(#b.updates,0);eq(#s.updateIndices,0)
  eq(#anim.time,2)
end)
test("cache index change during animation forces updates",function()
  local a,data,anim=fixture()
  local b=rawBone("b");local s=rawSlot("s",b)
  a:_addBone(b);a:_addSlot(s)
  function anim:advanceTime(dt)
    self.time[#self.time+1]=dt
    a._cacheFrameIndex=8
  end
  a:advanceTime(0.1)
  eq(b.updates[1],8)
  eq(s.updateIndices[1],8)
end)
test("parent slot alpha multiplies own alpha during advanceTime",function()
  local a=fixture()
  a._alpha=0.5
  a._parent={_globalAlpha=0.4}
  a:advanceTime(0.1)
  near(a._globalAlpha,0.2)
end)
test("play action without scope fades armature animation",function()
  local a,data,anim=fixture()
  local ac=action("run")
  a:_bufferAction(ac,true)
  a:advanceTime(0.1)
  eq(anim.fades[1],"run")
  eq(ac.returns,1);eq(#a._actions,0)
end)
test("play action attached to slot fades only child armature",function()
  local a,data,anim=fixture()
  local child={animation={fades={}}}
  function child.animation:fadeIn(name) self.fades[#self.fades+1]=name end
  local s=rawSlot("s");s.childArmature=child
  local ac=action("jump","slot",s)
  a:_bufferAction(ac,false)
  a:advanceTime(0.1)
  eq(child.animation.fades[1],"jump")
  eq(#anim.fades,0);eq(ac.returns,1)
end)
test("play action scoped to bone fades all matching child slots",function()
  local a,data,anim=fixture()
  local b=rawBone("root");a:_addBone(b)
  local child={animation={count=0}}
  function child.animation:fadeIn(name) self.count=self.count+1 end
  local s1=rawSlot("a",b);s1.childArmature=child
  local s2=rawSlot("b",b);s2.childArmature=child
  local s3=rawSlot("c",rawBone("other"));s3.childArmature=child
  a:_addSlot(s1);a:_addSlot(s2);a:_addSlot(s3)
  a:_bufferAction(action("hit","bone",b),true)
  a:advanceTime(0.1)
  eq(child.animation.count,2)
end)
test("non-Play action does not fade, but returns action to pool",function()
  local a,data,anim=fixture()
  local ac=action("f",nil,nil,Core.ActionType.Frame)
  a:_bufferAction(ac,true);a:advanceTime(0.1)
  eq(#anim.fades,0);eq(ac.returns,1)
end)
test("containsPoint returns first intersecting slot",function()
  local a=fixture()
  local s1=rawSlot("a");local s2=rawSlot("b")
  s1.pointHit=true;s2.pointHit=true
  a:_addSlot(s1);a:_addSlot(s2)
  eq(a:containsPoint(0,0),s1)
  s1.pointHit=false;eq(a:containsPoint(0,0),s2)
end)
test("containsPoint returns nil when no hit",function()
  local a=fixture();a:_addSlot(rawSlot("a"))
  eq(a:containsPoint(0,0),nil)
end)
test("intersectsSegment without outputs returns first matching slot",function()
  local a=fixture()
  local s1=rawSlot("first");local s2=rawSlot("second")
  s1.intersectCount=3;s2.intersectCount=3
  a:_addSlot(s1);a:_addSlot(s2)
  eq(a:intersectsSegment(0,0,10,10),s1)
end)
test("intersectsSegment chooses nearest beginning among slots",function()
  local a=fixture()
  local farther=rawSlot("far")
  farther.intersectCount=3;farther.startX=8;farther.startY=0
  farther.endX=9;farther.endY=0
  local closer=rawSlot("near")
  closer.intersectCount=3;closer.startX=2;closer.startY=0
  closer.endX=4;closer.endY=0
  a:_addSlot(farther);a:_addSlot(closer)
  local pA,pB={x=0,y=0},{x=0,y=0}
  eq(a:intersectsSegment(0,0,10,0,pA,pB),closer)
  eq(pA.x,2);eq(pB.x,9)
end)
test("intersectsSegment uses Y for vertical first-point comparison",function()
  local a=fixture()
  local f=rawSlot("far");f.intersectCount=1
  f.startX=1;f.startY=6
  local n=rawSlot("near");n.intersectCount=1
  n.startX=1;n.startY=2
  a:_addSlot(f);a:_addSlot(n)
  local p={x=0,y=0}
  eq(a:intersectsSegment(1,0,1,10,p),n)
  near(p.y,2)
end)
test("replacedTexture invalidates slots, clears cached atlas",function()
  local a=fixture()
  local s=rawSlot("s");a:_addSlot(s)
  local old={returns=0}
  function old:returnToPool() self.returns=self.returns+1 end
  a._replaceTextureAtlasData=old
  local tx={}
  a.replacedTexture=tx
  eq(a.replacedTexture,tx)
  eq(old.returns,1);eq(a._replaceTextureAtlasData,nil)
  eq(s.dirty,1);eq(s.updateIndices[1],-1)
  a.replacedTexture=tx
  eq(s.dirty,1)
end)
test("clock setter removes old and adds new, including child inheritance",function()
  local a=fixture()
  local child=new()
  local s=rawSlot("s");s.childArmature=child
  a:_addSlot(s)
  local first=WorldClock.new()
  local second=WorldClock.new()
  a.clock=first
  eq(a.clock,first);eq(child.clock,first)
  a.clock=second
  eq(a.clock,second);eq(child.clock,second)
  a.clock=nil
  eq(a.clock,nil);eq(child.clock,nil)
end)
test("cacheFrameRate setter propagates rate to children",function()
  local a,data=fixture()
  local child=new()
  local childData=Base.borrowObject(Model.ArmatureData)
  child._armatureData=childData
  a:_addSlot(rawSlot("slot"))
  a._slots[1].childArmature=child
  a.cacheFrameRate=24
  eq(data.cacheFrameRate,24)
  eq(childData.cacheFrameRate,24)
end)
test("_onClear recycles bones, slots, constraints, actions and proxy",function()
  local a,data,animation,proxy=fixture()
  local b=rawBone("b");local s=rawSlot("s")
  local c={pooled=false}
  function c:returnToPool() self.pooled=true end
  local ac=action("a")
  a:_addBone(b);a:_addSlot(s);a:_addConstraint(c)
  a:_bufferAction(ac,true)
  function animation:returnToPool() self.pooled=true end
  a:returnToPool()
  eq(b.pooled,true);eq(s.pooled,true)
  eq(c.pooled,true);eq(ac.returns,1)
  eq(animation.pooled,true);eq(proxy.cleared,1)
end)
test("reuse of pooled armature retains array identity",function()
  local a=new()
  local bones,slots,actions,constraints=a._bones,a._slots,a._actions,a._constraints
  a:returnToPool()
  local b=new()
  eq(b,a);eq(b._bones,bones);eq(b._slots,slots)
  eq(b._actions,actions);eq(b._constraints,constraints)
  b:returnToPool()
end)
test("init borrows Animation class, runs proxy/animation init and attaches original data",function()
  local modulePath="dragonbones.original.animation.Animation"
  local previous=package.loaded[modulePath]
  local FakeAnimation={};FakeAnimation.__index=FakeAnimation
  setmetatable(FakeAnimation,{__index=Base})
  function FakeAnimation.new() return Base.new(FakeAnimation) end
  function FakeAnimation:_onClear() self.owner=nil;self.animations=nil end
  function FakeAnimation:init(owner) self.owner=owner end
  package.loaded[modulePath]=FakeAnimation
  local ok,err=pcall(function()
    local a=new()
    local data=Base.borrowObject(Model.ArmatureData)
    data.animations={idle={name="idle"}}
    local proxy={count=0}
    function proxy:dbInit(owner) self.count=self.count+1;self.owner=owner end
    local display={}
    local dragonBones={}
    a:init(data,proxy,display,dragonBones)
    eq(a.armatureData,data)
    eq(a.animation.owner,a)
    eq(a.animation.animations,data.animations)
    eq(a.proxy,proxy);eq(proxy.owner,a)
    eq(proxy.count,1)
    eq(a.display,display);eq(a._dragonBones,dragonBones)
    a:init(data,proxy,display,dragonBones)
    eq(proxy.count,1)
  end)
  package.loaded[modulePath]=previous
  assert(ok,err)
end)

test("actual ported Bone can be initialized and updated inside real Armature",function()
  local a,data,animation,proxy=fixture()
  local boneData=Base.borrowObject(Model.BoneData)
  boneData.name="real_root"
  boneData.alpha=0.8
  local b=Base.borrowObject(Bone)
  b:init(boneData,a)
  eq(a:getBone("real_root"),b)
  eq(b.armature,a)
  a._alpha=0.5
  b:invalidUpdate()
  a:advanceTime(1/60)
  near(a._globalAlpha,0.5)
  near(b._globalAlpha,0.4)
  eq(b._transformDirty,false)
  eq(proxy.updated,1)
end)

print(("Original Armature.ts: %d passed, %d failed, %d assertions"):format(passed,failed,assertions))
if failed>0 then os.exit(1) end
