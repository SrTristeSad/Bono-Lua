-- Source conformance: DragonBonesJS armature/Slot.ts (abstract Slot class).
-- Commit: 64b6c69ae35777c2404be68c9192e2c56906079e
package.path = "./?.lua;./?/init.lua;" .. package.path
local Base = require("dragonbones.original.core.BaseObject")
local Slot = require("dragonbones.original.armature.Slot")
local Frame = require("dragonbones.original.armature.DisplayFrame")
local Bone = require("dragonbones.original.armature.Bone")
local Core = require("dragonbones.original.core.DragonBones")
local Models = require("dragonbones.original.model.ArmatureData")
local Displays = require("dragonbones.original.model.DisplayData")
local Bounding = require("dragonbones.original.model.BoundingBoxData")
local Skin = require("dragonbones.original.model.SkinData")
local Color = require("dragonbones.original.geom.ColorTransform")
local passed, failed, checks = 0,0,0
local function eq(a,b) checks=checks+1; assert(a==b,tostring(a).." ~= "..tostring(b)) end
local function near(a,b) checks=checks+1;assert(a and b and math.abs(a-b)<1e-7,tostring(a).." ~= "..tostring(b)) end
local function test(label,action)
  local ok,err=pcall(action)
  if ok then passed=passed+1;print("ok original.slot "..label)
  else failed=failed+1;print("not ok original.slot "..label..": "..tostring(err)) end
end

-- Only the original abstract renderer hooks are implemented in a TEST subclass.
-- The product Slot module contains NO invented LÖVE platform implementation.
local TestSlot={}
TestSlot.__index=function(self,key) return rawget(TestSlot,key) or Slot.__index(self,key) end
TestSlot.__newindex=Slot.__newindex
setmetatable(TestSlot,{__index=Slot})
function TestSlot.new()
  local self=Slot.new(TestSlot)
  self.calls={}
  return self
end
function TestSlot:_onClear()
  Slot._onClear(self)
  self.calls={}
end
local hooks={
"_initDisplay","_disposeDisplay","_onUpdateDisplay","_addDisplay",
"_replaceDisplay","_removeDisplay","_updateZOrder","_updateVisible",
"_updateBlendMode","_updateColor","_updateFrame","_updateMesh",
"_updateTransform","_identityTransform",
}
for _,name in ipairs(hooks) do
  TestSlot[name]=function(self,...)
    self.calls[#self.calls+1]={name=name,args={...}}
  end
end
local function calls(s,name)
  local count=0
  for _,entry in ipairs(s.calls) do if entry.name==name then count=count+1 end end
  return count
end
local function new()
  return Base.borrowObject(TestSlot)
end
local function fixture()
  local a={bones={},slots={},_globalAlpha=0.8,flipX=false,flipY=false,
    cacheFrameRate=0,clock={},_constraints={}}
  a._armatureData=Base.borrowObject(Models.ArmatureData)
  a._armatureData.parent={cachedFrames={}}
  a._armatureData.scale=1
  function a:getBone(name) return self.bones[name] end
  function a:getSlot(name) return self.slots[name] end
  function a:_addBone(value) self.bones[value.name]=value end
  function a:_addSlot(value) self.slots[value.name]=value end
  function a:getSlots() return {} end
  local boneData=Base.borrowObject(Models.BoneData)
  boneData.name="root"
  local b=Base.borrowObject(Bone);b:init(boneData,a)
  local slotData=Base.borrowObject(Models.SlotData)
  slotData.name="slot";slotData.parent=boneData
  slotData.color=Color.new()
  slotData.zOrder=2;slotData.zIndex=3;slotData.alpha=0.6
  local s=new()
  local raw,mesh={id="raw"},{id="mesh"}
  s:init(slotData,a,raw,mesh)
  return s,a,b,raw,mesh,slotData
end
local function image(pivotX,pivotY,texture)
  local d=Base.borrowObject(Displays.ImageDisplayData)
  d.pivot.x=pivotX or 0;d.pivot.y=pivotY or 0
  d.texture=texture
  return d
end
local function tex(w,h,rotated,frame)
  return {parent={scale=1},rotated=rotated or false,
    region={x=0,y=0,width=w,height=h},frame=frame}
end
local function meshData(weight)
  return {type=Core.DisplayType.Mesh,geometry={weight=weight},transform=Displays.ImageDisplayData.new().transform}
end
local function frame(s,index)
  return s:getDisplayFrameAt(index or 0)
end

test("abstract class has no renderer implementations and accepts subclass",function()
  eq(Slot._initDisplay,nil)
  eq(Slot._disposeDisplay,nil)
  eq(Slot._updateMesh,nil)
  eq(Slot._updateVisible,nil)
  eq(#hooks,14)
  local s=new()
  eq(getmetatable(s),TestSlot)
  eq(type(s.update),"function")
  eq(type(s.updateGlobalTransform),"function")
end)
test("initial fields match Slot.ts and retain distinct matrices",function()
  local s=new()
  eq(s.visible,true);eq(s.displayIndex,-1)
  eq(s.displayFrameCount,0);eq(s._animationDisplayIndex,-1)
  eq(s._cachedFrameIndex,-1);eq(s._blendMode,Core.BlendMode.Normal)
  eq(s._pivotX,0);eq(s._pivotY,0)
  eq(s._transformDirty,false);eq(s._geometryDirty,false)
  eq(s._textureDirty,false);eq(s._displayDirty,false)
  eq(s._colorDirty,false);eq(s._zOrderDirty,false)
  eq(s._display,nil);eq(s._childArmature,nil)
  eq(#s._displayFrames,0);eq(#s._geometryBones,0)
end)
test("init resolves parent and invokes concrete renderer hooks",function()
  local s,a,b,raw,mesh,d=fixture()
  eq(s.parent,b);eq(s.armature,a);eq(s.slotData,d)
  eq(s.rawDisplay,raw);eq(s.meshDisplay,mesh)
  eq(s._alpha,0.6)
  eq(s._zOrder,2);eq(s._zIndex,3)
  eq(s.name,"slot");eq(a.slots.slot,s)
  eq(calls(s,"_initDisplay"),2)
  eq(calls(s,"_onUpdateDisplay"),1)
  eq(calls(s,"_addDisplay"),1)
end)
test("init guard does not repeat calls or overwrite slot",function()
  local s,a,b,raw,mesh,d=fixture()
  s:init({name="second"},a,nil,nil)
  eq(s.slotData,d);eq(calls(s,"_initDisplay"),2)
end)
test("init equal raw and mesh initializes display only once",function()
  local s=new()
  local _,a,b,raw,mesh,d=fixture()
  s:init(d,a,raw,raw)
  eq(calls(s,"_initDisplay"),1)
end)
test("visible setter calls render hook only for transitions",function()
  local s=fixture()
  s.visible=false
  eq(s.visible,false);eq(calls(s,"_updateVisible"),1)
  s.visible=false;eq(calls(s,"_updateVisible"),1)
  s.visible=true;eq(calls(s,"_updateVisible"),2)
end)
test("displayFrameCount grows by borrowing independent DisplayFrames",function()
  local s=fixture()
  s.displayFrameCount=3
  eq(s.displayFrameCount,3)
  eq(getmetatable(frame(s,0)),Frame)
  assert(frame(s,0)~=frame(s,1))
  eq(frame(s,2).display,nil)
end)
test("frame-count shrink keeps original source's inverted loop condition",function()
  local s=fixture()
  s.displayFrameCount=3
  local discarded=frame(s,2)
  s.displayFrameCount=1
  eq(s.displayFrameCount,1)
  eq(discarded._isInPool,false)
  eq(calls(s,"_disposeDisplay"),0)
end)
test("displayFrameAt uses JS zero-based indexing",function()
  local s=fixture();s.displayFrameCount=2
  eq(s:getDisplayFrameAt(0),s._displayFrames[1])
  eq(s:getDisplayFrameAt(1),s._displayFrames[2])
  eq(s:getDisplayFrameAt(2),nil)
end)
test("displayList returns a new array rather than the internal frames",function()
  local s=fixture();s.displayFrameCount=2
  s:replaceDisplay("a",0)
  s:replaceDisplay("b",1)
  local displays=s.displayList
  eq(displays[1],"a");eq(displays[2],"b")
  displays[1]="z"
  eq(frame(s,0).display,"a")
end)
test("displayList setter populates frames and invokes replacement semantics",function()
  local s=fixture();s.displayList={"first","second"}
  eq(s.displayFrameCount,2)
  eq(frame(s,0).display,"first");eq(frame(s,1).display,"second")
end)
test("display property creates first frame with display index zero",function()
  local s=fixture()
  s.display={id="custom"}
  eq(s.displayFrameCount,1);eq(s.displayIndex,0)
  eq(frame(s,0).display.id,"custom")
  eq(calls(s,"_initDisplay"),3)
end)
test("display getter and deprecated alias return currently selected display",function()
  local s=fixture();s.display="custom"
  s:update(-1)
  eq(s.display,"custom")
  eq(s:getDisplay(),"custom")
  s:setDisplay("new")
  eq(frame(s,0).display,"new")
end)
test("_hasDisplay scans each frame by identity",function()
  local s=fixture();s.displayFrameCount=2
  local d={id="shared"}
  s:replaceDisplay(d,0)
  eq(s:_hasDisplay(d),true)
  eq(s:_hasDisplay({id="shared"}),false)
  eq(s:_hasDisplay(nil),true)
end)
test("replacement of custom display disposes old one when no other reference",function()
  local s=fixture();s.displayFrameCount=1
  s:replaceDisplay("old",0)
  s:replaceDisplay("new",0)
  eq(calls(s,"_disposeDisplay"),1)
  eq(calls(s,"_initDisplay"),4)
end)
test("replacement shared display is not disposed until last reference",function()
  local s=fixture();s.displayFrameCount=2
  local obj={name="shared"}
  s:replaceDisplay(obj,0);s:replaceDisplay(obj,1)
  s:replaceDisplay(nil,0)
  eq(calls(s,"_disposeDisplay"),0)
  s:replaceDisplay(nil,1)
  eq(calls(s,"_disposeDisplay"),1)
end)
test("replacement of raw or mesh display never initializes it again",function()
  local s,a,b,raw,mesh=fixture()
  s.displayFrameCount=2
  s:replaceDisplay(raw,0);s:replaceDisplay(mesh,1)
  eq(calls(s,"_initDisplay"),2)
end)
test("all replace methods ignore out-of-range positive index",function()
  local s=fixture()
  s:replaceDisplay("x",3)
  s:replaceTextureData({},2)
  s:replaceRawDisplayData({},1)
  s:replaceDisplayData({},0)
  eq(s.displayFrameCount,0)
  eq(calls(s,"_initDisplay"),2)
end)
test("_setDisplayIndex clips high indices and tracks animation index separately",function()
  local s=fixture();s.displayFrameCount=2
  s:_setDisplayIndex(11,true)
  eq(s.displayIndex,1);eq(s._animationDisplayIndex,11)
  eq(s._displayDataDirty,true)
  s:_setDisplayIndex(0,false)
  eq(s._animationDisplayIndex,11)
  eq(s.displayIndex,0)
end)
test("displayIndex setter calls update immediately",function()
  local s=fixture();s.displayFrameCount=1
  s:replaceDisplay("custom",0)
  s.displayIndex=0
  eq(s._displayDataDirty,false)
  eq(s.display,"custom")
  eq(calls(s,"_replaceDisplay"),1)
end)
test("_setZOrder returns true even on unchanged input",function()
  local s=fixture()
  eq(s:_setZOrder(2),true)
  eq(s._zOrderDirty,true)
  eq(s:_setZOrder(2),true)
end)
test("_setColor copies values and marks dirty",function()
  local s=fixture()
  local c=Color.new(0.3,0.2,0.5,0.4,1,2,3,4)
  eq(s:_setColor(c),true)
  near(s._colorTransform.redMultiplier,0.2)
  eq(s._colorDirty,true)
end)
test("_updateAlpha derives multiplier from parent and sets colorDirty only on change",function()
  local s,a,b=fixture()
  b._globalAlpha=0.5
  s:_updateAlpha()
  near(s._globalAlpha,0.3)
  eq(s._colorDirty,true)
  s._colorDirty=false
  s:_updateAlpha()
  eq(s._colorDirty,false)
end)
test("_isBonesUpdate considers geometry bone children dirtiness",function()
  local s,a,b=fixture()
  s._geometryBones={b}
  eq(s:_isBonesUpdate(),false)
  b._childrenTransformDirty=true
  eq(s:_isBonesUpdate(),true)
end)
test("_updateDisplayData sets local matrix/origin for image",function()
  local s,a,b=fixture()
  s.displayFrameCount=1
  local d=image(0.25,0.5,tex(100,60))
  d.transform.x=10;d.transform.y=5
  frame(s).rawDisplayData=d
  s:_setDisplayIndex(0)
  s:_updateDisplayData()
  eq(s.origin,d.transform)
  near(s._pivotX,25);near(s._pivotY,30)
  near(s._localMatrix.tx,10);near(s._localMatrix.ty,5)
end)
test("rotated texture swaps source dimensions for pivot",function()
  local s=fixture();s.displayFrameCount=1
  frame(s).rawDisplayData=image(0.25,0.5,tex(100,60,true))
  s:_setDisplayIndex(0);s:_updateDisplayData()
  near(s._pivotX,15);near(s._pivotY,50)
end)
test("frame rectangle applies texture scale and frame offsets",function()
  local s=fixture();s.displayFrameCount=1
  local t=tex(100,60,false,{x=10,y=5,width=20,height=40})
  t.parent.scale=2
  frame(s).rawDisplayData=image(0.5,0.25,t)
  s:_setDisplayIndex(0);s:_updateDisplayData()
  near(s._pivotX,40);near(s._pivotY,30)
end)
test("yDown false reverses pivot using raw region height",function()
  local old=Core.yDown
  local ok,err=pcall(function()
    Core.yDown=false
    local s=fixture();s.displayFrameCount=1
    frame(s).rawDisplayData=image(0.25,0.5,tex(100,60))
    s:_setDisplayIndex(0);s:_updateDisplayData()
    near(s._pivotY,30)
  end)
  Core.yDown=old
  assert(ok,err)
end)
test("_updateDisplayData builds geometry bones from weight descriptors",function()
  local s,a,b=fixture();s.displayFrameCount=1
  local d=Base.borrowObject(Displays.MeshDisplayData)
  d.geometry.weight={bones={b.boneData}}
  frame(s).rawDisplayData=d
  s:_setDisplayIndex(0);s:_updateDisplayData()
  eq(s._geometryData,d.geometry)
  eq(s._geometryBones[1],b)
  eq(s._geometryDirty,true)
  eq(s._verticesDirty,true)
  near(s._pivotX,0)
end)
test("_updateDisplayData clears geometry when selected image replaces mesh",function()
  local s,a,b=fixture();s.displayFrameCount=1
  local mesh=Base.borrowObject(Displays.MeshDisplayData)
  frame(s).rawDisplayData=mesh
  s:_setDisplayIndex(0);s:_updateDisplayData()
  eq(s._geometryData,mesh.geometry)
  frame(s).rawDisplayData=Base.borrowObject(Displays.ImageDisplayData)
  s:_updateDisplayData()
  eq(s._geometryData,nil)
  eq(#s._geometryBones,0)
end)
test("replaceRawDisplayData resets deformation and falls back to default skin",function()
  local s,a=fixture();s.displayFrameCount=1
  local skin=Base.borrowObject(Skin)
  local fallback=image()
  skin:addDisplay("slot",fallback)
  a._armatureData.defaultSkin=skin
  frame(s).rawDisplayData=image()
  frame(s).deformVertices={9,9,9}
  s:_setDisplayIndex(0)
  s:replaceRawDisplayData(nil,0)
  eq(frame(s).rawDisplayData,fallback)
  eq(#frame(s).deformVertices,0)
  eq(s._displayDataDirty,true)
end)
test("replaceDisplayData refuses same raw display object",function()
  local s=fixture();s.displayFrameCount=1
  local d=image()
  frame(s).rawDisplayData=d
  s:replaceDisplayData(d,0)
  eq(frame(s).displayData,nil)
end)
test("replaceTextureData updates dirty flag only for active frame",function()
  local s=fixture();s.displayFrameCount=2
  s:_setDisplayIndex(0)
  s._displayDataDirty=false
  s:replaceTextureData({},1)
  eq(s._displayDataDirty,false)
  s:replaceTextureData({},0)
  eq(s._displayDataDirty,true)
end)
test("_updateDisplay chooses custom display and renderer replacement",function()
  local s=fixture();s.displayFrameCount=1
  local custom={id=1}
  frame(s).display=custom
  s:_setDisplayIndex(0)
  s:_updateDisplay()
  eq(s.display,custom)
  eq(calls(s,"_replaceDisplay"),1)
  eq(s._visibleDirty,true);eq(s._blendModeDirty,true)
end)
test("update skips display hooks if no display is currently active",function()
  local s=fixture();s.displayFrameCount=1
  frame(s).rawDisplayData=image()
  s:_setDisplayIndex(0)
  s:update(-1)
  eq(s.display,nil)
  eq(calls(s,"_updateTransform"),0)
end)
test("update applies flagged renderer hooks once per frame",function()
  local s=fixture();s.display="custom";s:update(-1)
  s._visibleDirty=true;s._blendModeDirty=true
  s._colorDirty=true;s._zOrderDirty=true;s._transformDirty=true
  s:update(-1)
  eq(calls(s,"_updateVisible"),1)
  eq(calls(s,"_updateBlendMode"),1)
  eq(calls(s,"_updateColor"),1)
  eq(calls(s,"_updateZOrder"),1)
  eq(calls(s,"_updateTransform"),1)
  s:update(-1);eq(calls(s,"_updateTransform"),1)
end)
test("update dirty skinned mesh calls _updateMesh and returns before transforms",function()
  local s,a,b,raw,mesh=fixture()
  s.display=mesh;s:update(-1)
  s._geometryData={weight={}}
  s._verticesDirty=true
  s._transformDirty=true
  s:update(-1)
  eq(calls(s,"_updateMesh"),1)
  eq(calls(s,"_updateTransform"),0)
end)
test("update rigid mesh propagates to parent transform",function()
  local s,a,b,raw,mesh=fixture()
  s.display=mesh;s:update(-1)
  s._geometryData={weight=nil}
  s._verticesDirty=true;s._transformDirty=true
  b.globalTransformMatrix.tx=25
  s:update(-1)
  eq(calls(s,"_updateMesh"),1)
  eq(calls(s,"_updateTransform"),1)
  near(s.globalTransformMatrix.tx,25)
end)
test("cache first update writes ArmatureData cache frame with zero offset",function()
  local s,a,b=fixture()
  s.display="custom";s:update(-1)
  s._cachedFrameIndices={}
  s:invalidUpdate();s:update(0)
  eq(s._cachedFrameIndex,0)
  eq(s._cachedFrameIndices[1],0)
  eq(#a._armatureData.parent.cachedFrames,10)
end)
test("cache same frame index does not update transform again",function()
  local s,a,b=fixture()
  s.display="custom";s:update(-1)
  s._cachedFrameIndices={}
  s:invalidUpdate();s:update(0)
  local n=calls(s,"_updateTransform")
  s:invalidUpdate();s:update(0)
  eq(calls(s,"_updateTransform"),n)
end)
test("cache different stored index reloads matrix from ArmatureData",function()
  local s,a,b=fixture()
  s.display="custom";s:update(-1)
  a._armatureData.parent.cachedFrames={1,0,0,1,40,60,0,0,1,1}
  s._cachedFrameIndices={[1]=0}
  s:update(0)
  near(s.global.x,40);near(s.global.y,60)
end)
test("updateTransformAndMatrix updates only on transformDirty",function()
  local s,a,b=fixture()
  b.globalTransformMatrix.tx=50
  s._transformDirty=true
  s:updateTransformAndMatrix()
  eq(s._transformDirty,false)
  eq(s._globalDirty,true)
  near(s.globalTransformMatrix.tx,50)
  s:updateTransformAndMatrix()
end)
test("containsPoint returns false when no box set",function()
  local s=fixture()
  eq(s:containsPoint(0,0),false)
end)
test("containsPoint applies global transform inverse before rectangle test",function()
  local s,a,b=fixture()
  local rect=Base.borrowObject(Bounding.RectangleBoundingBoxData)
  rect.width=10;rect.height=20
  s._boundingBoxData=rect
  b.globalTransformMatrix.tx=20
  s._transformDirty=true
  eq(s:containsPoint(21,1),true)
  eq(s:containsPoint(30,1),false)
end)
test("intersectsSegment returns zero for missing box",function()
  local s=fixture()
  eq(s:intersectsSegment(0,0,1,1),0)
end)
test("intersectsSegment local coordinates and output transforms",function()
  local s,a,b=fixture()
  local rect=Base.borrowObject(Bounding.RectangleBoundingBoxData)
  rect.width=10;rect.height=10
  s._boundingBoxData=rect
  b.globalTransformMatrix.tx=20
  s._transformDirty=true
  local p1,p2,normal={x=0,y=0},{x=0,y=0},{x=0,y=0}
  local n=s:intersectsSegment(10,0,30,0,p1,p2,normal)
  eq(n,3)
  near(p1.x,15);near(p2.x,25)
end)
test("returnToPool disposes custom displays once and keeps local matrix identity",function()
  local s,a,b,raw,mesh=fixture()
  s.displayFrameCount=2
  local shared={id="x"}
  frame(s,0).display=shared;frame(s,1).display=shared
  local matrix=s._localMatrix
  s:returnToPool()
  eq(calls(s,"_disposeDisplay"),0) -- calls reset by test subclass _onClear.
  local other=Base.borrowObject(TestSlot)
  eq(other,s)
  eq(other._localMatrix,matrix)
  eq(other.displayIndex,-1)
  eq(other.displayFrameCount,0)
end)

print(("Original Slot.ts Slot: %d passed, %d failed, %d assertions"):format(passed,failed,checks))
if failed>0 then os.exit(1) end
