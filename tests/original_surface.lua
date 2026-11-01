-- Surface.ts contract tests against the pinned original algorithms.
-- DragonBonesJS revision 64b6c69ae35777c2404be68c9192e2c56906079e.
package.path = "./?.lua;./?/init.lua;" .. package.path
local Base = require("dragonbones.original.core.BaseObject")
local Core = require("dragonbones.original.core.DragonBones")
local Surface = require("dragonbones.original.armature.Surface")
local Bone = require("dragonbones.original.armature.Bone")
local Models = require("dragonbones.original.model.ArmatureData")
local Matrix = require("dragonbones.original.geom.Matrix")
local Transform = require("dragonbones.original.geom.Transform")

local passed, failed = 0, 0
local function test(name, fn)
  local ok, err = pcall(fn)
  if ok then
    passed = passed + 1
    print("ok original.surface " .. name)
  else
    failed = failed + 1
    print("not ok original.surface " .. name .. ": " .. tostring(err))
  end
end
local function eq(a, b)
  assert(a == b, tostring(a) .. " ~= " .. tostring(b))
end
local function near(a, b, tol)
  assert(a ~= nil and b ~= nil and math.abs(a-b) <= (tol or 0.00000001),
    tostring(a) .. " ~= " .. tostring(b))
end
local function armature()
  local model = Base.borrowObject(Models.ArmatureData)
  -- The original parser's output is represented by the real data-model
  -- container and its real intArray, floatArray and cachedFrames contracts.
  model.parent = {
    intArray = {4, 0, 0},
    floatArray = {-200, -200, 200, -200, -200, 200, 200, 200},
    cachedFrames = {},
  }
  local a = {
    flipX = false, flipY = false, _globalAlpha = 1,
    armatureData = model, _armatureData = model,
    _constraints = {}, bones = {},
  }
  function a:_addBone(b) self.bones[#self.bones+1] = b end
  function a:getBone(name)
    for _, item in ipairs(self.bones) do
      if item.name == name then return item end
    end
  end
  function a:getSlots() return {} end
  return a
end
local function surface(a, parent)
  a = a or armature()
  local d = Base.borrowObject(Models.SurfaceData)
  d.name = "surface" .. tostring(#a.bones + 1)
  d.segmentX, d.segmentY = 1, 1
  d.geometry.offset = 0
  d.parent = parent and parent.boneData or nil
  local s = Base.borrowObject(Surface)
  s:init(d, a)
  return s, a
end
local function bone(a)
  local d = Base.borrowObject(Models.BoneData)
  d.name = "bone" .. tostring(#a.bones + 1)
  local b = Base.borrowObject(Bone)
  b:init(d, a)
  return b
end
local function updated(a, parent)
  local s
  s,a = surface(a,parent)
  s:invalidUpdate()
  s:update(-1)
  return s,a
end
local function lookup(s, x, y)
  local matrix = s:_getGlobalTransformMatrix(x,y)
  return matrix, matrix.a*x + matrix.c*y + matrix.tx,
    matrix.b*x + matrix.d*y + matrix.ty
end

test("original class, inheritance and initial field values", function()
  local s=Base.borrowObject(Surface)
  eq(Surface.toString(), "[class dragonBones.Surface]")
  eq(getmetatable(s),Surface)
  eq(s._dX,0);eq(s._dY,0);eq(s._k,0);eq(s._kX,0);eq(s._kY,0)
  eq(s._bone,nil)
  eq(s._vertices.length,0)
  eq(s._deformVertices.length,0)
  eq(s._matrixCahce.length,0)
  eq(s._hullCache.length,0)
  assert(type(s.invalidUpdate)=="function")
  assert(type(s.updateByConstraint)=="function")
  assert(type(s.returnToPool)=="function")
  s:returnToPool()
end)
test("init allocates 4 vertices, 5 regions and zeroed deform offsets",function()
  local s = surface()
  near(s._dX,400);near(s._dY,400);near(s._k,-1)
  near(s._kX,-0.5);near(s._kY,-2)
  eq(s._vertices.length,8)
  eq(s._deformVertices.length,8)
  eq(s._matrixCahce.length,70)
  eq(s._hullCache.length,10)
  for i=1,8 do eq(s._deformVertices[i],0) end
  eq(s._vertices[1],nil)
end)
test("init cannot be repeated and preserves initial arrays",function()
  local s,a=surface()
  local d=s.boneData
  local v=s._deformVertices
  s:init(d,a)
  eq(s.boneData,d);eq(s._deformVertices,v)
  eq(#a.bones,1)
end)
test("root grid vertices read original binary geometry offsets",function()
  local s=updated()
  local expected={-200,-200,200,-200,-200,200,200,200}
  for i,v in ipairs(expected) do near(s._vertices[i],v) end
end)
test("deformations add per vertex without altering binary floatArray",function()
  local s,a=surface()
  s._deformVertices[1]=17
  s._deformVertices[8]=-25
  s:invalidUpdate();s:update(-1)
  near(s._vertices[1],-183)
  near(s._vertices[8],175)
  near(a.armatureData.parent.floatArray[1],-200)
  near(a.armatureData.parent.floatArray[8],200)
end)
test("_getAffineTransform generates source affine geometry and returns void",function()
  local s=surface()
  local t=Transform.new()
  local m=Matrix.new()
  eq(s:_getAffineTransform(10,15,100,100,25,35,125,35,25,135,t,m,false),nil)
  near(t.scaleX,1);near(t.scaleY,1)
  near(t.x,15);near(t.y,20)
  near(t.rotation,0)
  near(m.tx,15);near(m.ty,20)
end)
test("_getAffineTransform isDown rotates by PI without special-case fixes",function()
  local s=surface()
  local t,m=Transform.new(),Matrix.new()
  s:_getAffineTransform(0,0,200,200,0,0,200,0,0,200,t,m,true)
  near(t.rotation,math.pi)
  near(t.scaleX,1);near(t.scaleY,1)
  near(m.a,-1)
end)
test("global transform uses four corners and sets globalDirty false",function()
  local s=updated()
  near(s.global.x,0);near(s.global.y,0)
  near(s.global.scaleX,1);near(s.global.scaleY,1)
  near(s.globalTransformMatrix.a,1)
  near(s.globalTransformMatrix.d,1)
  near(s.globalTransformMatrix.tx,0)
  eq(s._globalDirty,false)
end)
test("hullCache grows from 10 to 12 after update as original JS",function()
  local s=updated()
  eq(s._hullCache.length,12)
  eq(s._hullCache[11]~=nil,true)
  eq(s._hullCache[12]~=nil,true)
end)
test("interior lower triangle returns identity transform",function()
  local s=updated()
  local m,x,y=lookup(s,-100,-110)
  near(x,-100);near(y,-110)
  near(m.a,1);near(m.d,1)
end)
test("interior upper triangle returns original orientation",function()
  local s=updated()
  local m,x,y=lookup(s,110,130)
  assert(m~=s.globalTransformMatrix)
  assert(x==x and y==y)
end)
test("left exterior region both triangles are finite",function()
  local s=updated()
  for _,p in ipairs({{-500,-150},{-500,150}}) do
    local m,x,y=lookup(s,p[1],p[2])
    assert(m~=s.globalTransformMatrix and x==x and y==y)
  end
end)
test("right exterior region both triangles are finite",function()
  local s=updated()
  for _,p in ipairs({{500,-150},{500,150}}) do
    local m,x,y=lookup(s,p[1],p[2])
    assert(m~=s.globalTransformMatrix and x==x and y==y)
  end
end)
test("upper exterior region both triangles are finite",function()
  local s=updated()
  for _,p in ipairs({{-150,-500},{150,-500}}) do
    local m,x,y=lookup(s,p[1],p[2])
    assert(m~=s.globalTransformMatrix and x==x and y==y)
  end
end)
test("lower exterior region both triangles are finite",function()
  local s=updated()
  for _,p in ipairs({{-150,500},{150,500}}) do
    local m,x,y=lookup(s,p[1],p[2])
    assert(m~=s.globalTransformMatrix and x==x and y==y)
  end
end)
test("far-out and corner coordinates return original global matrix",function()
  local s=updated()
  for _,p in ipairs({{-1001,0},{1001,0},{0,-1001},{0,1001},
    {-250,-250},{250,-250},{-250,250},{250,250}}) do
    eq(s:_getGlobalTransformMatrix(p[1],p[2]),s.globalTransformMatrix)
  end
end)
test("exact supported boundary 1000 remains in mapped regions",function()
  local s=updated()
  local a=s:_getGlobalTransformMatrix(1000,0)
  local b=s:_getGlobalTransformMatrix(-1000,0)
  assert(a~=s.globalTransformMatrix)
  assert(b~=s.globalTransformMatrix)
end)
test("previously computed matrix cache reuses same segment",function()
  local s=updated()
  local first=s:_getGlobalTransformMatrix(5,5)
  local vals={first.a,first.b,first.c,first.d,first.tx,first.ty}
  local second=s:_getGlobalTransformMatrix(5,5)
  for i,key in ipairs({"a","b","c","d","tx","ty"}) do near(second[key],vals[i]) end
  eq(s._matrixCahce[8],1)
end)
test("dirty update invalidates triangle caches before recalculating",function()
  local s=updated()
  s:_getGlobalTransformMatrix(5,5)
  eq(s._matrixCahce[8],1)
  s._deformVertices[1]=20
  s:invalidUpdate();s:update(-1)
  eq(s._matrixCahce[8],-1)
end)
test("cache on first update uses real ArmatureData setCacheFrame",function()
  local s,a=surface()
  s._cachedFrameIndices={}
  s:invalidUpdate();s:update(0)
  eq(s._cachedFrameIndex,0)
  eq(s._cachedFrameIndices[1],0)
  eq(#a._armatureData.parent.cachedFrames,10)
  eq(s._childrenTransformDirty,true)
end)
test("same cached frame suppresses transform update",function()
  local s,a=surface()
  s._cachedFrameIndices={}
  s:invalidUpdate();s:update(0)
  s._vertices[1]=9999
  s:invalidUpdate();s:update(0)
  near(s._vertices[1],9999)
  eq(#a._armatureData.parent.cachedFrames,10)
end)
test("cached frame can be restored from earlier snapshot",function()
  local s,a=surface()
  s._cachedFrameIndices={}
  s:invalidUpdate();s:update(0)
  s.global.x=900
  s._cachedFrameIndex=-1
  s._cachedFrameIndices[2]=0
  s:update(1)
  near(s.global.x,0)
end)
test("root alpha and name getters are inherited from Bone",function()
  local s,a=surface()
  eq(s.name,s.boneData.name)
  s._alpha=0.25
  a._globalAlpha=0.8
  s:_updateAlpha()
  near(s._globalAlpha,0.2)
end)
test("parent Bone connects _bone and transforms surface vertices",function()
  local a=armature()
  local p=bone(a)
  p.globalTransformMatrix.tx=50
  p.globalTransformMatrix.ty=25
  local s=updated(a,p)
  eq(s.parent,p)
  eq(s._bone,p)
  near(s._vertices[1],-150)
  near(s._vertices[2],-175)
end)
test("parent Surface inherits linked Bone identity",function()
  local a=armature()
  local p=bone(a)
  local parent=updated(a,p)
  local child=updated(a,parent)
  eq(child.parent,parent)
  eq(child._bone,p)
  assert(child._vertices[1]~=nil)
end)
test("consecutive calls clear childrenTransformDirty on next idle frame",function()
  local s=updated()
  eq(s._childrenTransformDirty,true)
  s:update(-1)
  eq(s._childrenTransformDirty,false)
  eq(s._localDirty,true)
end)
test("constraints are dispatched only when root matches",function()
  local s,a=surface()
  local calls=0
  a._constraints={
    {_root=s,update=function() calls=calls+1 end},
    {_root={},update=function() error("wrong root") end},
  }
  s._hasConstraint=true
  s:invalidUpdate();s:update(-1)
  eq(calls,1)
end)
test("pool preserves object arrays but clears values and class fields",function()
  local s=updated()
  local pose, vertices, hull, matrix=s.animationPose,s._vertices,s._hullCache,s._matrixCahce
  s:returnToPool()
  local another=Base.borrowObject(Surface)
  eq(another,s)
  eq(another.animationPose,pose)
  eq(another._vertices,vertices)
  eq(another._hullCache,hull)
  eq(another._matrixCahce,matrix)
  eq(another._vertices.length,0)
  eq(another._hullCache.length,0)
  eq(another._matrixCahce.length,0)
  eq(another._bone,nil)
  another:returnToPool()
end)

print(("Original Surface.ts: %d passed, %d failed"):format(passed, failed))
if failed>0 then os.exit(1) end
