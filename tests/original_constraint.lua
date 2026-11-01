-- DragonBonesJS original Constraint.ts tests: pinned revision
-- 64b6c69ae35777c2404be68c9192e2c56906079e.
-- Armature and Slot are test-only contract objects, never production stubs.
package.path = "./?.lua;./?/init.lua;" .. package.path
local Base = require("dragonbones.original.core.BaseObject")
local Core = require("dragonbones.original.core.DragonBones")
local Bone = require("dragonbones.original.armature.Bone")
local Model = require("dragonbones.original.model.ArmatureData")
local Constraint = require("dragonbones.original.armature.Constraint")
local Data = require("dragonbones.original.model.ConstraintData")
local Matrix = require("dragonbones.original.geom.Matrix")
local Transform = require("dragonbones.original.geom.Transform")
local passed, failed = 0, 0

local function test(name, fn)
  local ok, err = pcall(fn)
  if ok then passed=passed+1;print("ok original.constraint "..name)
  else failed=failed+1;print("not ok original.constraint "..name..": "..tostring(err)) end
end
local function eq(a,b)
  assert(a==b,tostring(a).." ~= "..tostring(b))
end
local function near(a,b,epsilon)
  assert(a~=nil and b~=nil and math.abs(a-b)<=(epsilon or 1e-8),
    tostring(a).." ~= "..tostring(b))
end
local function values(...)
  local a={length=select("#",...)}
  for i=1,a.length do a[i]=select(i,...) end
  return a
end
local function g(a,i) return a[i+1] end
local function set(a,i,v)
  a[i+1]=v
  if a.length < i+1 then a.length=i+1 end
end
local function armature()
  local data=Base.borrowObject(Model.ArmatureData)
  data.scale=1
  data.parent={intArray=values(9,0,0),floatArray=values(0,0),cachedFrames={}}
  local a={armatureData=data,_armatureData=data,bones={},slots={},_constraints={},
    flipX=false,flipY=false,_globalAlpha=1}
  function a:_addBone(b) self.bones[#self.bones+1]=b end
  function a:getBone(name) return self.bones[name] end
  function a:getSlot(name) return self.slots[name] end
  function a:getSlots() return {} end
  return a
end
local function bone(a,name,x,y,angle,length,parent)
  local d=Base.borrowObject(Model.BoneData)
  d.name=name
  d.length=length or 0
  d.parent=parent and parent.boneData or nil
  local b=Base.borrowObject(Bone)
  -- Real Bone.init calls Armature._addBone but this test's keyed lookup
  -- can be populated via the same _addBone contract.
  a._addBone=function(self,item) self.bones[item.name]=item end
  b:init(d,a)
  b.global.x=x or 0
  b.global.y=y or 0
  b.global.rotation=angle or 0
  b.global:toMatrix(b.globalTransformMatrix)
  return b
end
local function ik(a,root,target,child,weight,bend)
  local d=Base.borrowObject(Data.IKConstraintData)
  d.name="ik"
  d.root=root.boneData
  d.target=target.boneData
  d.bone=child and child.boneData or nil
  d.weight=weight==nil and 1 or weight
  d.bendPositive=bend==nil and false or bend
  local c=Base.borrowObject(Constraint.IKConstraint)
  c:init(d,a)
  return c,d
end
local function path(a,root,target,pathSlot,bones)
  local d=Base.borrowObject(Data.PathConstraintData)
  d.name="path"
  d.root=root.boneData
  d.target=target.boneData
  d.pathSlot={name="slot"}
  d.pathDisplayData={geometry={offset=0}}
  d.position=0
  d.spacing=0
  d.rotateOffset=0
  d.rotateMix=1
  d.translateMix=1
  for _,b in ipairs(bones or {}) do d:AddBone(b.boneData) end
  pathSlot._geometryData={offset=0,weight=nil}
  pathSlot._displayFrame={rawDisplayData={geometry={offset=0},
    closed=false,constantSpeed=false,curveLengths=values(100,100)}}
  a.slots.slot=pathSlot
  local c=Base.borrowObject(Constraint.PathConstraint)
  c:init(d,a)
  return c,d
end
local function setupPath(vertexCount)
  local a=armature()
  set(a.armatureData.parent.intArray,0,vertexCount or 9)
  set(a.armatureData.parent.intArray,2,0)
  local root=bone(a,"root",0,0)
  local target=bone(a,"target",40,10)
  local follow=bone(a,"follow",1,0,0,10)
  local slot={parent=root,_geometryData={offset=0,weight=nil},
    _verticesDirty=false,_geometryBones=values()}
  function slot:_isBonesUpdate() return false end
  local c,d=path(a,root,target,slot,{follow})
  -- Source _computeBezierCurve expects a populated curve coordinate buffer;
  -- this test fixture models data after the path-geometry update contract.
  local buf={length=vertexCount*2}
  for i=0,vertexCount-1 do
    set(buf,i*2,i*10)
    set(buf,i*2+1,0)
  end
  c._pathGlobalVertices=buf
  return c,d,a,root,target,follow,slot
end

test("three original classes, inheritance, helper references and abstract methods",function()
  local c=Constraint.Constraint
  local i=Base.borrowObject(Constraint.IKConstraint)
  local p=Base.borrowObject(Constraint.PathConstraint)
  eq(Constraint.IKConstraint.toString(),"[class dragonBones.IKConstraint]")
  eq(Constraint.PathConstraint.toString(),"[class dragonBones.PathConstraint]")
  assert(getmetatable(i)==Constraint.IKConstraint)
  assert(getmetatable(p)==Constraint.PathConstraint)
  eq(c.init,nil);eq(c.update,nil);eq(c.invalidUpdate,nil)
  assert(getmetatable(c._helpMatrix)==Matrix)
  assert(getmetatable(c._helpTransform)==Transform)
  eq(i._bendPositive,false);eq(i._weight,1)
  eq(p.rotateMix,1);eq(p.translateMix,1)
  eq(p._segments.length,1);eq(p._segments[1],10)
  i:returnToPool();p:returnToPool()
end)
test("base _onClear touches exactly original four references",function()
  local c=Constraint.Constraint.new(Constraint.Constraint)
  c._armature={};c._target={};c._root={};c._bone={}
  c._constraintData={name="kept"}
  c:_onClear()
  eq(c._armature,nil);eq(c._target,nil);eq(c._root,nil);eq(c._bone,nil)
  eq(c.name,"kept")
end)
test("IK init resolves target/root/child by name, honors guard",function()
  local a=armature()
  local root=bone(a,"root")
  local child=bone(a,"child")
  local target=bone(a,"target")
  local c,d=ik(a,root,target,child,0.375,true)
  eq(c.name,"ik")
  eq(c._root,root);eq(c._target,target);eq(c._bone,child)
  eq(c._weight,0.375);eq(c._bendPositive,true)
  eq(root._hasConstraint,true)
  c:init({name="replacement"},a)
  eq(c._constraintData,d)
end)
test("IK single-bone rotates root toward target at full weight",function()
  local a=armature()
  local root=bone(a,"root",0,0,0)
  local target=bone(a,"target",0,10)
  local c=ik(a,root,target)
  c:update()
  near(root.global.rotation,math.pi/2)
  near(root.globalTransformMatrix.a,0)
  near(root.globalTransformMatrix.b,1)
end)
test("IK single-bone interpolates angle by weight",function()
  local a=armature()
  local root=bone(a,"root",0,0,0)
  local target=bone(a,"target",0,10)
  local c=ik(a,root,target,nil,0.5)
  c:update()
  near(root.global.rotation,math.pi/4)
end)
test("IK negative root scale adds PI to target angle",function()
  local a=armature()
  local root=bone(a,"root",0,0,0)
  root.global.scaleX=-1
  local target=bone(a,"target",10,0)
  local c=ik(a,root,target)
  c:update()
  near(math.abs(root.global.rotation),math.pi)
end)
test("IK single bone invalidUpdate sets root dirty but not target",function()
  local a=armature()
  local root=bone(a,"root")
  local target=bone(a,"target")
  local c=ik(a,root,target)
  c:invalidUpdate()
  eq(root._transformDirty,true)
  eq(target._transformDirty,false)
end)
test("IK two-bone update changes parent and child orientations",function()
  local a=armature()
  local root=bone(a,"root",0,0)
  local child=bone(a,"child",10,0,0,10,root)
  local target=bone(a,"target",12,8)
  local c=ik(a,root,target,child,1,false)
  c:update()
  assert(root.global.rotation==root.global.rotation)
  assert(child.global.rotation==child.global.rotation)
  assert(math.abs(root.global.rotation)>0.01)
  assert(math.abs(child.global.rotation)>0.01)
end)
test("IK two-bone bendPositive inverts elbow direction",function()
  local function solve(bend)
    local a=armature()
    local root=bone(a,"root",0,0)
    local child=bone(a,"child",10,0,0,10,root)
    local target=bone(a,"target",12,8)
    local c=ik(a,root,target,child,1,bend)
    c:update()
    return root.global.rotation,child.global.y
  end
  local angle1,y1=solve(false)
  local angle2,y2=solve(true)
  assert(angle1*angle2<0)
  assert(y1*y2<0)
end)
test("IK unreachable target keeps bones aligned with target direction",function()
  local a=armature()
  local root=bone(a,"root",0,0)
  local child=bone(a,"child",10,0,0,10,root)
  local target=bone(a,"target",50,0)
  local c=ik(a,root,target,child,1,false)
  c:update()
  near(root.global.rotation,0)
  near(child.global.y,0)
end)
test("IK zero weight leaves parent untouched",function()
  local a=armature()
  local root=bone(a,"root",0,0)
  local child=bone(a,"child",10,0,0,10,root)
  local target=bone(a,"target",12,8)
  local c=ik(a,root,target,child,0,false)
  c:update()
  near(root.global.rotation,0)
end)
test("IK reflected grandparent alters elbow selection",function()
  local function solve(reflect)
    local a=armature()
    local grand=bone(a,"grand")
    if reflect then grand.globalTransformMatrix.a=-1 end
    local root=bone(a,"root",0,0,0,0,grand)
    local child=bone(a,"child",10,0,0,10,root)
    local target=bone(a,"target",12,8)
    local c=ik(a,root,target,child,1,false)
    c:update()
    return root.global.rotation
  end
  assert(solve(false)*solve(true)<0)
end)
test("IK two-bone invalidation propagates to both bones",function()
  local a=armature()
  local root=bone(a,"root")
  local child=bone(a,"child")
  local target=bone(a,"target")
  local c=ik(a,root,target,child)
  c:invalidUpdate()
  eq(root._transformDirty,true);eq(child._transformDirty,true)
end)
test("Path defaults retain original segments and reset arrays",function()
  local c=Base.borrowObject(Constraint.PathConstraint)
  local a=c._bones
  local s=c._segments
  set(c._spaces,4,22);set(c._boneLengths,0,17)
  set(c._segments,9,71)
  c:returnToPool()
  local b=Base.borrowObject(Constraint.PathConstraint)
  eq(b,c)
  eq(b._bones,a);eq(b._segments,s)
  eq(b._spaces.length,0);eq(b._boneLengths.length,0)
  eq(b._segments.length,10);eq(b._segments[10],71)
  eq(b.pathOffset,0);eq(b.position,0)
  eq(b.dirty,false)
  b:returnToPool()
end)
test("Path init records parameters and resolves only present bones",function()
  local c,d,a,root,target,follow=setupPath(9)
  eq(c._root,root);eq(c._target,target)
  eq(c._bones.length,1);eq(g(c._bones,0),follow)
  eq(c._pathSlot,a.slots.slot)
  eq(c.pathOffset,0)
  eq(root._hasConstraint,true)
  eq(c.name,"path")
end)
test("Path init is not guarded, duplicate calls append the same bones",function()
  local c,d,a=setupPath(9)
  c:init(d,a)
  eq(c._bones.length,2)
  eq(g(c._bones,1),g(c._bones,0))
end)
test("Path _computeVertices uses the pinned loop bound, not offset+count",function()
  local c=setupPath(9)
  local dest=values()
  c:_computeVertices(2,8,4,dest)
  eq(dest.length,8)
  near(g(dest,4),10)
  near(g(dest,5),0)
  near(g(dest,6),20)
  near(g(dest,7),0)
  eq(g(dest,8),nil)
end)
test("Path addCurvePosition t=0 and t=1 writes endpoint and zero tangent",function()
  local c=setupPath(9)
  local out=values()
  c:addCurvePosition(0,1,2,3,4,5,6,7,8,out,0,true)
  eq(g(out,0),1);eq(g(out,1),2);eq(g(out,2),0)
  c:addCurvePosition(1,1,2,3,4,5,6,7,8,out,3,true)
  eq(g(out,3),7);eq(g(out,4),8);eq(g(out,5),0)
end)
test("Path addCurvePosition samples exact cubic formula and tangent",function()
  local c=setupPath(9)
  local out=values()
  c:addCurvePosition(0.5,0,0,0,10,10,10,10,0,out,0,false)
  near(g(out,0),5);near(g(out,1),7.5);eq(g(out,2),0)
  c:addCurvePosition(0.5,0,0,0,10,10,10,10,0,out,3,true)
  near(g(out,3),5);near(g(out,4),7.5)
  assert(g(out,5)==g(out,5))
end)
test("Path nonconstant curve samples and default fixed spacing",function()
  local c,d=setupPath(9)
  set(c._spaces,0,0);set(c._spaces,1,20)
  c.position=10
  c:_computeBezierCurve({geometry={offset=0},closed=false,
    constantSpeed=false,curveLengths=values(100,100)},2,false,false,false)
  eq(c._positions.length,8)
  assert(g(c._positions,0)~=nil)
  assert(g(c._positions,3)~=nil)
end)
test("Path nonconstant out-of-range positions remain sparse",function()
  local c=setupPath(9)
  set(c._spaces,0,0);set(c._spaces,1,1)
  c.position=-200
  c:_computeBezierCurve({geometry={offset=0},closed=false,
    constantSpeed=false,curveLengths=values(100,100)},2,false,false,false)
  eq(c._positions.length,8)
  eq(g(c._positions,0),nil)
  eq(g(c._positions,3),nil)
end)
test("Path nonconstant closed wrapping uses signed remainder and recovery",function()
  local c=setupPath(9)
  set(c._spaces,0,0)
  c.position=-5
  c:_computeBezierCurve({geometry={offset=0},closed=true,
    constantSpeed=false,curveLengths=values(100,100,100)},1,false,false,false)
  assert(g(c._positions,0)~=nil)
end)
test("Path constantSpeed uses source curve-length integration",function()
  local c=setupPath(9)
  set(c._spaces,0,0)
  c.position=0
  c:_computeBezierCurve({geometry={offset=0},closed=false,
    constantSpeed=true,curveLengths=values()},1,false,false,false)
  assert(g(c._positions,0)~=nil)
  assert(c._segments.length==10)
end)
test("Path weightless vertices preserve original i+=2 behavior",function()
  local c,d,a,root,target,follow,slot=setupPath(4)
  -- Geometry: 4 vertices, only iterations i=0 and i=2 are computed.
  a.armatureData.parent.floatArray=values(10,20,30,40,50,60,70,80)
  -- A new JS array starts sparse; reset the prefilled fixture before the call.
  c._pathGlobalVertices={length=0}
  c:_updatePathVertices(slot._geometryData)
  eq(c._pathGlobalVertices.length,8)
  near(g(c._pathGlobalVertices,0),10)
  near(g(c._pathGlobalVertices,1),20)
  near(g(c._pathGlobalVertices,2),30)
  near(g(c._pathGlobalVertices,3),40)
  eq(g(c._pathGlobalVertices,4),nil)
  eq(g(c._pathGlobalVertices,7),nil)
end)
test("Path nonweighted rewrite retains existing values at untouched indices",function()
  local c,d,a,root,target,follow,slot=setupPath(4)
  local previous=g(c._pathGlobalVertices,6)
  a.armatureData.parent.floatArray=values(10,20,30,40,50,60,70,80)
  c:_updatePathVertices(slot._geometryData)
  eq(g(c._pathGlobalVertices,6),previous)
end)
test("Path weighted vertices multiply bone matrices and weights",function()
  local c,d,a,root,target,follow,slot=setupPath(2)
  a.armatureData.parent.intArray=values(2,0,0,0,0,1,1,0,1,0)
  -- source weight offset=3, floats start=0, geometry offset=0
  -- iB = 3+2+1 = 6, vertex 0: one bone index 0, vertex 1 same.
  a.armatureData.parent.floatArray=values(0.5,10,20,0.5,30,40)
  local geom={offset=0,weight={offset=3,bones={root.boneData}}}
  slot._geometryBones=values(root)
  c:_updatePathVertices(geom)
  near(g(c._pathGlobalVertices,0),5)
  near(g(c._pathGlobalVertices,1),10)
  near(g(c._pathGlobalVertices,2),15)
  near(g(c._pathGlobalVertices,3),20)
end)
test("Path invalidUpdate is intentionally empty",function()
  local c=setupPath(9)
  c.dirty=false
  eq(c:invalidUpdate(),nil)
  eq(c.dirty,false)
end)
test("Path update returns for missing and mismatched geometry",function()
  local c,d,a,root,target,follow,slot=setupPath(9)
  slot._geometryData=nil
  eq(c:update(),nil)
  slot._geometryData={offset=55}
  eq(c:update(),nil)
  eq(follow.globalTransformMatrix.tx,1)
end)
test("Path update returns when neither dirty flag is set",function()
  local c,d,a,root,target,follow,slot=setupPath(9)
  c.dirty=false;root._childrenTransformDirty=false
  slot._verticesDirty=false
  eq(c:update(),nil)
  eq(c.dirty,false)
  eq(follow.globalTransformMatrix.tx,1)
end)
test("Path update moves one bone along path with fixed spacing and zero rotateMix",function()
  local c,d,a,root,target,follow,slot=setupPath(9)
  c.dirty=true
  d.rotateMode=Core.RotateMode.Tangent
  d.positionMode=Core.PositionMode.Fixed
  d.spacingMode=Core.SpacingMode.Fixed
  c.position=10;c.spacing=0;c.rotateMix=0;c.translateMix=1
  c:update()
  eq(c.dirty,false)
  assert(follow.globalTransformMatrix.tx ~= 1)
end)
test("Path update with tangent and positive rotateMix adjusts orientation",function()
  local c,d,a,root,target,follow,slot=setupPath(9)
  c.dirty=true
  d.rotateMode=Core.RotateMode.Tangent
  c.position=10;c.spacing=0
  c:update()
  eq(c.dirty,false)
  assert(follow.globalTransformMatrix.a==follow.globalTransformMatrix.a)
end)

print(("Original Constraint.ts: %d passed, %d failed"):format(passed,failed))
if failed>0 then os.exit(1) end
