-- Contract checks for pinned DragonBonesJS:
-- DragonBones/src/dragonBones/armature/Bone.ts
-- commit 64b6c69ae35777c2404be68c9192e2c56906079e
-- Armature/Slot/Surface dummies below are used ONLY in tests and implement
-- the exact original method contracts called by Bone.ts.
package.path="./?.lua;./?/init.lua;"..package.path
local Base=require("dragonbones.original.core.BaseObject")
local Bone=require("dragonbones.original.armature.Bone")
local Data=require("dragonbones.original.model.ArmatureData")
local Project=require("dragonbones.original.model.DragonBonesData")
local Core=require("dragonbones.original.core.DragonBones")
local Matrix=require("dragonbones.original.geom.Matrix")
local Transform=require("dragonbones.original.geom.Transform")

local passed,failed=0,0
local function test(name,fn)
  local ok,err=pcall(fn)
  if ok then passed=passed+1;print("ok original.bone "..name)
  else failed=failed+1;print("not ok original.bone "..name..": "..tostring(err)) end
end
local function eq(a,b)
  assert(a==b, tostring(a).." ~= "..tostring(b))
end
local function near(a,b)
  assert(type(a)=="number" and type(b)=="number"
    and math.abs(a-b)<1e-8,tostring(a).." ~= "..tostring(b))
end
local function rig()
  local project=Base.borrowObject(Project)
  local armatureData=Base.borrowObject(Data.ArmatureData)
  project:addArmature(armatureData)
  local a={
    flipX=false,flipY=false,_globalAlpha=.8,
    _constraints={},_armatureData=armatureData,
    bones={},slots={}
  }
  function a:_addBone(b)
    self.bones[b.name]=b
  end
  function a:getBone(name) return self.bones[name] end
  function a:getSlots() return self.slots end
  function a:dispose()
    -- BoneData is owned by the ArmatureData parent and cleared once.
    project:returnToPool()
  end
  return a
end
local function makeBone(a,name,parentData)
  local d=Base.borrowObject(Data.BoneData)
  d.name=name
  d.parent=parentData
  d.transform.x=2
  d.transform.y=3
  d.transform.rotation=0
  d.inheritTranslation=true
  d.inheritRotation=true
  d.inheritScale=true
  a._armatureData:addBone(d)
  local b=Base.borrowObject(Bone)
  b:init(d,a)
  return b,d
end
local function cleanup(a,...)
  for _,b in ipairs({...}) do
    b:returnToPool()
  end
  a:dispose()
end

test("Bone has original toString, defaults and inherited transforms",function()
  eq(Bone.toString(),"[class dragonBones.Bone]")
  local b=Base.borrowObject(Bone)
  eq(b.offsetMode,Core.OffsetMode.Additive)
  assert(getmetatable(b.animationPose)==Transform)
  assert(getmetatable(b.globalTransformMatrix)==Matrix)
  eq(b._cachedFrameIndex,-1)
  assert(b._localDirty and not b._transformDirty and not b._childrenTransformDirty)
  assert(not b._hasConstraint and b.visible)
  eq(b._alpha,1);eq(b._globalAlpha,1)
  assert(b._boneData==nil and b._parent==nil and b.armature==nil)
  assert(b._cachedFrameIndices==nil)
  b:returnToPool()
end)
test("init wires data, parent lookup, alpha, origin and armature registration",function()
  local a=rig()
  local root,rd=makeBone(a,"root")
  local child,cd=makeBone(a,"child",rd)
  cd.alpha=.5 -- init happens at construction; exercise alpha in separate check
  eq(root.name,"root")
  eq(child.parent,root)
  eq(child.armature,a)
  eq(child.boneData,cd)
  eq(child.origin,cd.transform)
  eq(a:getBone("child"),child)
  eq(root._alpha,1)
  cleanup(a,child,root)
end)
test("init is idempotent if BoneData already installed",function()
  local a=rig()
  local b,d=makeBone(a,"first")
  local other=Base.borrowObject(Data.BoneData);other.name="other"
  b:init(other,a)
  eq(b.boneData,d)
  eq(b.name,"first")
  other:returnToPool()
  cleanup(a,b)
end)
test("root additive transform combines origin, offset and animationPose",function()
  local a=rig()
  local b,d=makeBone(a,"root")
  d.transform.scaleX=2
  d.transform.scaleY=3
  b.offset.x=4;b.offset.y=5;b.offset.rotation=.2
  b.animationPose.x=7;b.animationPose.y=-2;b.animationPose.rotation=.1
  b.animationPose.scaleX=4
  b:_updateGlobalTransformMatrix(false)
  near(b.global.x,13);near(b.global.y,6)
  near(b.global.scaleX,8);near(b.global.scaleY,3)
  near(b.global.rotation,.3)
  near(b.globalTransformMatrix.tx,13);near(b.globalTransformMatrix.ty,6)
  cleanup(a,b)
end)
test("root uses None offsetMode: origin + animationPose only",function()
  local a=rig()
  local b=makeBone(a,"root")
  b.offsetMode=Core.OffsetMode.None
  b.offset.x=1000
  b.animationPose.x=5
  b:_updateGlobalTransformMatrix(false)
  near(b.global.x,7)
  near(b.global.y,3)
  cleanup(a,b)
end)
test("Override offsetMode ignores animationPose and disables parent inheritance",function()
  local a=rig()
  local parent,pd=makeBone(a,"parent")
  local child=makeBone(a,"child",pd)
  parent.globalTransformMatrix.tx=1000
  child.offsetMode=Core.OffsetMode.Override
  child.offset.x=13;child.offset.y=-7
  child.animationPose.x=500
  child:_updateGlobalTransformMatrix(false)
  near(child.global.x,13);near(child.global.y,-7)
  near(child.globalTransformMatrix.tx,13)
  cleanup(a,child,parent)
end)
test("root flip X, Y and both preserve original rotation and skew",function()
  local a=rig()
  local b=makeBone(a,"root")
  local oldYDown=Core.yDown
  local ok,err=pcall(function()
    b.offsetMode=Core.OffsetMode.Override
    b.offset.x=2;b.offset.y=3;b.offset.rotation=.25
    a.flipX=true;a.flipY=false
    b:_updateGlobalTransformMatrix(false)
    near(b.global.x,-2);near(b.global.y,3)
    near(b.global.rotation,math.pi-.25)
    a.flipX=false;a.flipY=true
    b:_updateGlobalTransformMatrix(false)
    near(b.global.x,2);near(b.global.y,-3)
    near(b.global.rotation,-.25)
    a.flipX=true;a.flipY=true
    b:_updateGlobalTransformMatrix(false)
    near(b.global.x,-2);near(b.global.y,-3)
    near(b.global.rotation,.25+math.pi)
    Core.yDown=false
    b.offset.y=4;b.offset.rotation=.2
    a.flipY=true
    a.flipX=false
    b:_updateGlobalTransformMatrix(false)
    near(b.global.y,-4)
    near(b.global.rotation,-.2)
  end)
  Core.yDown=oldYDown
  if not ok then error(err) end
  cleanup(a,b)
end)
test("parent inheritance includes transform matrix when scale is enabled",function()
  local a=rig()
  local parent,pd=makeBone(a,"parent")
  parent.global.x=10;parent.global.y=20
  parent.globalTransformMatrix.tx=10;parent.globalTransformMatrix.ty=20
  local child=makeBone(a,"child",pd)
  child:invalidUpdate()
  child:update(-1)
  near(child.globalTransformMatrix.tx,12)
  near(child.globalTransformMatrix.ty,23)
  assert(child._globalDirty)
  child:updateGlobalTransform()
  assert(not child._globalDirty)
  cleanup(a,child,parent)
end)
test("parent inherits translation but not scale when inheritScale=false",function()
  local a=rig()
  local parent,pd=makeBone(a,"parent")
  parent.globalTransformMatrix.tx=10
  parent.globalTransformMatrix.ty=20
  local child,cd=makeBone(a,"child",pd)
  cd.inheritScale=false;cd.inheritRotation=false
  child:_updateGlobalTransformMatrix(false)
  near(child.global.x,12);near(child.global.y,23)
  near(child.globalTransformMatrix.tx,12)
  cleanup(a,child,parent)
end)
test("inheritTranslation=false restores local matrix translation",function()
  local a=rig()
  local parent,pd=makeBone(a,"parent")
  parent.globalTransformMatrix.tx=100
  local child,cd=makeBone(a,"child",pd)
  cd.inheritTranslation=false
  child:_updateGlobalTransformMatrix(false)
  near(child.globalTransformMatrix.tx,2)
  near(child.global.x,2)
  cleanup(a,child,parent)
end)
test("inheritScale on Surface parent follows original _bone and matrix contract",function()
  local a=rig()
  local parent,pd=makeBone(a,"surface")
  pd.type=Core.BoneType.Surface
  parent._bone={global=Transform.new(0,0,0,0,2,3),
    updateGlobalTransform=function(self)self.updated=true end}
  function parent:_getGlobalTransformMatrix()
    return Matrix.new(1,0,0,1,100,200)
  end
  parent.global.rotation=.2
  local child,cd=makeBone(a,"child",pd)
  cd.inheritScale=true;cd.inheritTranslation=true;cd.inheritRotation=true
  child:_updateGlobalTransformMatrix(false)
  assert(parent._bone.updated)
  near(child.global.scaleX,2);near(child.global.scaleY,3)
  near(child.global.x,102);near(child.global.y,203)
  cleanup(a,child,parent)
end)
test("_updateAlpha uses parent globalAlpha or armature globalAlpha",function()
  local a=rig()
  local root,rd=makeBone(a,"root")
  local child,cd=makeBone(a,"child",rd)
  root._alpha=.5
  root:_updateAlpha()
  near(root._globalAlpha,.4)
  child._alpha=.25
  child:_updateAlpha()
  near(child._globalAlpha,.1)
  cleanup(a,child,root)
end)
test("contains checks ancestors but excludes self and unrelated bones",function()
  local a=rig()
  local root,rd=makeBone(a,"root")
  local child,cd=makeBone(a,"child",rd)
  local leaf=makeBone(a,"leaf",cd)
  local other=makeBone(a,"other")
  assert(root:contains(leaf) and child:contains(leaf))
  assert(not leaf:contains(root) and not root:contains(root))
  assert(not other:contains(leaf))
  cleanup(a,leaf,child,root,other)
end)
test("visible setter updates only slots attached to this bone",function()
  local a=rig()
  local root,rd=makeBone(a,"root")
  local other=makeBone(a,"other")
  local calls1,calls2=0,0
  a.slots={
    {parent=root,_updateVisible=function()calls1=calls1+1 end},
    {parent=other,_updateVisible=function()calls2=calls2+1 end}
  }
  root.visible=false
  eq(root.visible,false);eq(calls1,1);eq(calls2,0)
  root.visible=false
  eq(calls1,1)
  root.visible=true
  eq(calls1,2)
  cleanup(a,other,root)
end)
test("invalidUpdate and update update dirty flags and matrices once",function()
  local a=rig()
  local b=makeBone(a,"root")
  b:invalidUpdate()
  assert(b._transformDirty)
  b:update(-1)
  assert(not b._transformDirty and b._childrenTransformDirty and b._localDirty)
  near(b.globalTransformMatrix.tx,2)
  b:update(-1)
  assert(not b._childrenTransformDirty)
  cleanup(a,b)
end)
test("updateByConstraint updates at most once until next normal update",function()
  local a=rig()
  local b=makeBone(a,"root")
  b:invalidUpdate()
  b:updateByConstraint()
  assert(not b._localDirty and b._transformDirty)
  near(b.globalTransformMatrix.tx,2)
  b.offset.x=7
  b:updateByConstraint()
  near(b.globalTransformMatrix.tx,2)
  b:update(-1)
  assert(b._localDirty and not b._transformDirty)
  cleanup(a,b)
end)
test("constraints update only if _hasConstraint and root matches",function()
  local a=rig()
  local b=makeBone(a,"root")
  local other=makeBone(a,"other")
  local calls=0
  a._constraints={
    {_root=other,update=function()calls=calls+100 end},
    {_root=b,update=function()calls=calls+1 end}
  }
  b._hasConstraint=true
  b:update(-1)
  eq(calls,1)
  b._hasConstraint=false
  b:update(-1)
  eq(calls,1)
  cleanup(a,other,b)
end)
test("update cache miss stores 0-based offset and cache hit restores matrix",function()
  local a=rig()
  local b=makeBone(a,"root")
  b._cachedFrameIndices={-1,-1}
  b:invalidUpdate()
  b:update(0)
  eq(b._cachedFrameIndex,0)
  eq(b._cachedFrameIndices[1],0)
  eq(#a._armatureData.parent.cachedFrames,10)
  b.globalTransformMatrix.tx=999
  b._cachedFrameIndex=-1
  b:update(0)
  near(b.globalTransformMatrix.tx,2)
  eq(b._cachedFrameIndex,0)
  cleanup(a,b)
end)
test("update reuses previously calculated cache when different sample is unset",function()
  local a=rig()
  local b=makeBone(a,"root")
  b._cachedFrameIndices={-1,-1}
  b:invalidUpdate()
  b:update(0)
  eq(b._cachedFrameIndices[1],0)
  b:update(1)
  eq(b._cachedFrameIndices[2],0)
  eq(#a._armatureData.parent.cachedFrames,10)
  cleanup(a,b)
end)
test("returnToPool resets flags, geometry and animationPose in place",function()
  local a=rig()
  local b=makeBone(a,"root")
  local pose=b.animationPose
  local matrix=b.globalTransformMatrix
  b.animationPose.x=23
  b.offsetMode=Core.OffsetMode.Override
  b._cachedFrameIndices={1,2}
  b._visible=false
  b:returnToPool()
  eq(b.offsetMode,Core.OffsetMode.Additive)
  eq(b.animationPose.x,0)
  assert(b.animationPose==pose and b.globalTransformMatrix==matrix)
  assert(b._cachedFrameIndices==nil and b._boneData==nil and b._parent==nil)
  local reused=Base.borrowObject(Bone)
  assert(reused==b)
  -- The rig owns BoneData, not runtime Bone.
  a:dispose()
  reused:returnToPool()
end)
print(("Original Bone.ts: %d passed, %d failed"):format(passed,failed))
if failed>0 then os.exit(1) end
