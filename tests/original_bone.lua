-- Conformance scenarios for DragonBonesJS armature/Bone.ts.
-- Source revision: 64b6c69ae35777c2404be68c9192e2c56906079e.
-- Only the Armature/Slot/Constraint/Surface contracts are simulated in tests;
-- no incomplete replacements are introduced into production modules.
package.path = "./?.lua;./?/init.lua;" .. package.path
local Base = require("dragonbones.original.core.BaseObject")
local Bone = require("dragonbones.original.armature.Bone")
local Model = require("dragonbones.original.model.ArmatureData")
local Core = require("dragonbones.original.core.DragonBones")
local Matrix = require("dragonbones.original.geom.Matrix")
local Transform = require("dragonbones.original.geom.Transform")
local passed, failed = 0, 0
local function test(name, fn)
  local ok, err = pcall(fn)
  if ok then
    passed = passed + 1
    print("ok original.bone " .. name)
  else
    failed = failed + 1
    print("not ok original.bone " .. name .. ": " .. tostring(err))
  end
end
local function eq(a, b) assert(a == b, tostring(a) .. " ~= " .. tostring(b)) end
local function near(a, b, tol)
  assert(math.abs(a - b) <= (tol or 0.00000001),
    tostring(a) .. " ~= " .. tostring(b))
end
local function data(name, parent)
  local result = Base.borrowObject(Model.BoneData)
  result.name = name or "root"
  result.parent = parent
  result.inheritTranslation = true
  result.inheritRotation = true
  result.inheritScale = true
  result.inheritReflection = false
  return result
end
local function armature()
  local model = Base.borrowObject(Model.ArmatureData)
  model.parent = { cachedFrames = {} }
  local a = {
    flipX = false, flipY = false, _globalAlpha = 0.7,
    _armatureData = model, _constraints = {}, slots = {}, bones = {},
  }
  function a:_addBone(value) self.bones[#self.bones + 1] = value end
  function a:getBone(name)
    for _, item in ipairs(self.bones) do
      if item.name == name then return item end
    end
    return nil
  end
  function a:getSlots() return self.slots end
  return a
end
local function newBone(a, d)
  local bone = Base.borrowObject(Bone)
  bone:init(d or data("root"), a)
  return bone
end

test("original identifier, defaults, initializers and inherited getters", function()
  local b = Base.borrowObject(Bone)
  eq(Bone.toString(), "[class dragonBones.Bone]")
  eq(getmetatable(b), Bone)
  eq(b.offsetMode, Core.OffsetMode.Additive)
  eq(b.visible, true)
  eq(b._transformDirty, false)
  eq(b._childrenTransformDirty, false)
  eq(b._localDirty, true)
  eq(b._hasConstraint, false)
  eq(b._cachedFrameIndex, -1)
  eq(b._boneData, nil)
  eq(b._parent, nil)
  eq(b._cachedFrameIndices, nil)
  eq(b.armature, nil)
  eq(b.boneData, nil)
  assert(getmetatable(b.animationPose) == Transform)
  assert(type(b.updateGlobalTransform) == "function")
  b:returnToPool()
end)

test("init links parent bone by name, sets alpha and origin by reference", function()
  local a = armature()
  local p = newBone(a, data("parent"))
  local d = data("child", p.boneData)
  d.alpha = 0.25
  d.transform.x = 12
  local b = newBone(a, d)
  eq(b.parent, p)
  eq(b.boneData, d)
  eq(b.origin, d.transform)
  eq(b.name, "child")
  eq(b.armature, a)
  eq(b._alpha, 0.25)
  eq(a.bones[2], b)
  b:init(data("ignored"), a)
  eq(#a.bones, 2)
  eq(b.name, "child")
end)

test("visible setter notifies only attached slots on changes", function()
  local a = armature()
  local b = newBone(a, data("a"))
  local another = newBone(a, data("b"))
  local s1, s2, s3 = {parent=b, count=0}, {parent=another, count=0}, {parent=b, count=0}
  for _, slot in ipairs({s1, s2, s3}) do
    function slot:_updateVisible() self.count = self.count + 1 end
  end
  a.slots = {s1, s2, s3}
  b.visible = false
  eq(b.visible, false)
  eq(s1.count, 1)
  eq(s2.count, 0)
  eq(s3.count, 1)
  b.visible = false
  eq(s1.count, 1)
  b.visible = true
  eq(s3.count, 2)
end)

test("contains rejects self and walks ancestor chain", function()
  local a = armature()
  local root = newBone(a, data("root"))
  local child = newBone(a, data("child", root.boneData))
  local leaf = newBone(a, data("leaf", child.boneData))
  eq(root:contains(root), false)
  eq(root:contains(child), true)
  eq(root:contains(leaf), true)
  eq(leaf:contains(root), false)
  eq(child:contains(leaf), true)
  eq(root:contains(nil), false)
end)

test("_updateAlpha chooses parent or armature global alpha", function()
  local a = armature()
  local root = newBone(a, data("root"))
  local child = newBone(a, data("child", root.boneData))
  root._alpha = 0.8
  child._alpha = 0.5
  root:_updateAlpha()
  child:_updateAlpha()
  near(root._globalAlpha, 0.56)
  near(child._globalAlpha, 0.28)
end)

test("root additive offset+origin+pose preserves all arithmetic and matrix", function()
  local a = armature()
  local d = data("r")
  local b = newBone(a, d)
  d.transform.x, d.transform.y = 2, 6
  d.transform.scaleX, d.transform.scaleY = 2, 3
  d.transform.rotation, d.transform.skew = 0.1, 0.2
  b.offset.x, b.offset.y = 4, 5
  b.offset.scaleX, b.offset.scaleY = 4, 5
  b.offset.rotation, b.offset.skew = 0.3, 0.4
  b.animationPose.x, b.animationPose.y = 7, 8
  b.animationPose.scaleX, b.animationPose.scaleY = 6, 7
  b.animationPose.rotation, b.animationPose.skew = 0.5, 0.6
  b:_updateGlobalTransformMatrix(false)
  near(b.global.x, 13)
  near(b.global.y, 19)
  near(b.global.scaleX, 48)
  near(b.global.scaleY, 105)
  near(b.global.rotation, 0.9)
  near(b.global.skew, 1.2)
  near(b.globalTransformMatrix.tx, 13)
  near(b.globalTransformMatrix.ty, 19)
end)

test("when origin is nil additive mode copies offset then adds pose", function()
  local a = armature()
  local b = newBone(a, data("r"))
  b.origin = nil
  b.offset.x, b.offset.y = 5, 6
  b.offset.scaleX = 2
  b.animationPose.x, b.animationPose.y = 7, 8
  b.animationPose.scaleX = 3
  b:_updateGlobalTransformMatrix(true)
  near(b.global.x, 12)
  near(b.global.y, 14)
  near(b.global.scaleX, 6)
end)

test("yDown false reverses origin offset y/angles, but not pose", function()
  local old = Core.yDown
  local ok, err = pcall(function()
    Core.yDown = false
    local a = armature()
    a.flipY = true -- with yDown=false this means no effective vertical reflection
    local d = data("r")
    local b = newBone(a, d)
    d.transform.y, d.transform.rotation, d.transform.skew = 100, 0.5, 0.4
    b.offset.y, b.offset.rotation, b.offset.skew = 9, 0.3, 0.2
    b.animationPose.y, b.animationPose.rotation, b.animationPose.skew = 4, 0.7, 0.6
    b:_updateGlobalTransformMatrix(false)
    near(b.global.y, 95)
    near(b.global.rotation, 0.9)
    near(b.global.skew, 0.8)
    b.origin = nil
    b:_updateGlobalTransformMatrix(false)
    near(b.global.y, -5)
    near(b.global.rotation, 0.4)
  end)
  Core.yDown = old
  assert(ok, err)
end)

test("None mode ignores offset and override mode ignores origin, pose and parent", function()
  local a = armature()
  local p = newBone(a, data("p"))
  local b = newBone(a, data("c", p.boneData))
  b.origin.x = 5
  b.offset.x = 100
  b.animationPose.x = 4
  b.offsetMode = Core.OffsetMode.None
  b:_updateGlobalTransformMatrix(false)
  near(b.global.x, 9)
  b.origin = nil
  b:_updateGlobalTransformMatrix(false)
  near(b.global.x, 4)
  b.offsetMode = Core.OffsetMode.Override
  b:_updateGlobalTransformMatrix(false)
  near(b.global.x, 100)
end)

test("root all four flip combinations retain source rotation/skew equations", function()
  for _, flags in ipairs({{false, false}, {true, false}, {false, true}, {true, true}}) do
    local a = armature()
    a.flipX, a.flipY = flags[1], flags[2]
    local b = newBone(a, data("r"))
    b.origin.x, b.origin.y = 4, 8
    b.origin.rotation, b.origin.skew = 0.3, 0.2
    b:_updateGlobalTransformMatrix(false)
    local fx = flags[1]
    local fy = flags[2] == Core.yDown
    near(b.global.x, fx and -4 or 4)
    near(b.global.y, fy and -8 or 8)
    local rotation = (fx and fy) and 0.3 + math.pi
      or (fx and (math.pi - 0.3) or (fy and -0.3 or 0.3))
    near(b.global.rotation, rotation)
    near(b.global.skew, (fx ~= fy) and (0.2 + math.pi) or 0.2)
  end
end)

test("inheritScale combines normal parent matrix and marks global dirty without cache", function()
  local a = armature()
  local p = newBone(a, data("p"))
  p.globalTransformMatrix.tx = 20
  p.globalTransformMatrix.ty = 30
  local b = newBone(a, data("c", p.boneData))
  b.origin.x, b.origin.y = 4, 6
  b:_updateGlobalTransformMatrix(false)
  near(b.globalTransformMatrix.tx, 24)
  near(b.globalTransformMatrix.ty, 36)
  near(b.global.x, 24)
  near(b.global.y, 36)
  eq(b._globalDirty, true)
  b:updateGlobalTransform()
  eq(b._globalDirty, false)
end)

test("inheritScale with cache decomposes result, not delayed dirty", function()
  local a = armature()
  local p = newBone(a, data("p"))
  p.globalTransformMatrix.tx = 9
  local b = newBone(a, data("c", p.boneData))
  b.origin.x = 5
  b:_updateGlobalTransformMatrix(true)
  near(b.global.x, 14)
  eq(b._globalDirty, false)
end)

test("inheritScale without inherited rotation subtracts parent rotation", function()
  local a = armature()
  local p = newBone(a, data("p"))
  p.global.rotation = 0.25
  local d = data("c", p.boneData)
  d.inheritRotation = false
  local b = newBone(a, d)
  b.origin.rotation = 0.6
  b:_updateGlobalTransformMatrix(false)
  near(b.global.rotation, 0.35)
end)

test("no inheritScale transforms only translation via parent affine matrix", function()
  local a = armature()
  local p = newBone(a, data("p"))
  p.globalTransformMatrix.a, p.globalTransformMatrix.d = 2, 3
  p.globalTransformMatrix.tx, p.globalTransformMatrix.ty = 10, 20
  local d = data("c", p.boneData)
  d.inheritScale, d.inheritRotation = false, false
  local b = newBone(a, d)
  b.origin.x, b.origin.y = 4, 5
  b:_updateGlobalTransformMatrix(false)
  near(b.global.x, 18)
  near(b.global.y, 35)
  near(b.global.scaleX, 1)
  near(b.global.scaleY, 1)
end)

test("no translation inheritance keeps local x/y, applies flips", function()
  local a = armature()
  a.flipX, a.flipY = true, false
  local p = newBone(a, data("p"))
  local d = data("c", p.boneData)
  d.inheritTranslation, d.inheritScale, d.inheritRotation = false, false, false
  local b = newBone(a, d)
  b.origin.x, b.origin.y = 4, 5
  b.origin.rotation = 0.3
  b:_updateGlobalTransformMatrix(false)
  near(b.global.x, -4)
  near(b.global.y, 5)
  near(b.global.rotation, math.pi - 0.3)
  near(b.global.skew, math.pi)
end)

test("negative determinant inheritance reflection branch adjusts angle/skew", function()
  local a = armature()
  local p = newBone(a, data("p"))
  p.globalTransformMatrix.a = -1
  p.global.scaleX = -1
  local d = data("c", p.boneData)
  d.inheritScale, d.inheritReflection = false, true
  local b = newBone(a, d)
  b.origin.rotation = 0.5
  b:_updateGlobalTransformMatrix(true)
  near(b.global.rotation, math.pi - 0.5)
  near(b.global.skew, math.pi)
end)

test("Surface parent with linked Bone applies sampled matrix and inherited scale", function()
  local a = armature()
  local p = newBone(a, data("surface"))
  p._boneData.type = Core.BoneType.Surface
  local linked = newBone(a, data("linked"))
  linked.global.scaleX, linked.global.scaleY = 3, 4
  local calls = 0
  function p:_getGlobalTransformMatrix(x, y)
    calls = calls + 1
    near(x, 2)
    near(y, 5)
    return Matrix.new(1, 0, 0, 1, 10, 20)
  end
  p._bone = linked
  local child = newBone(a, data("child", p.boneData))
  child.origin.x, child.origin.y = 2, 5
  child:_updateGlobalTransformMatrix(false)
  eq(calls, 1)
  near(child.global.x, 12)
  near(child.global.y, 25)
  near(child.global.scaleX, 3)
  near(child.global.scaleY, 4)
end)

test("Surface parent without linked bone goes through no-scale branch", function()
  local a = armature()
  local p = newBone(a, data("surface"))
  p._boneData.type = Core.BoneType.Surface
  function p:_getGlobalTransformMatrix(x, y)
    return Matrix.new(1, 0, 0, 1, 10, 20)
  end
  local b = newBone(a, data("child", p.boneData))
  b.origin.x, b.origin.y = 2, 3
  b:_updateGlobalTransformMatrix(false)
  near(b.global.x, 12)
  near(b.global.y, 23)
end)

test("cache: first update writes transform and index zero to real ArmatureData", function()
  local a = armature()
  local b = newBone(a, data("root"))
  b.origin.x, b.origin.y = 4, 8
  b._cachedFrameIndices = {}
  b:invalidUpdate()
  b:update(0)
  eq(b._cachedFrameIndex, 0)
  eq(b._cachedFrameIndices[1], 0)
  eq(#a._armatureData.parent.cachedFrames, 10)
  near(a._armatureData.parent.cachedFrames[5], 4)
  near(a._armatureData.parent.cachedFrames[6], 8)
  eq(b._transformDirty, false)
  eq(b._childrenTransformDirty, true)
  eq(b._localDirty, true)
end)

test("cache: same frame index skips recomputation even when transform dirtied", function()
  local a = armature()
  local b = newBone(a, data("r"))
  b._cachedFrameIndices = {}
  b:invalidUpdate()
  b:update(0)
  b.global.x = 123
  b:invalidUpdate()
  b:update(0)
  near(b.global.x, 123)
  eq(b._transformDirty, false)
  eq(#a._armatureData.parent.cachedFrames, 10)
end)

test("cache: existing different frame index restores matrix and transform", function()
  local a = armature()
  local b = newBone(a, data("r"))
  local other = newBone(a, data("other"))
  other.origin.x = 100
  other:invalidUpdate()
  other._cachedFrameIndices = {}
  other:update(0)
  b._cachedFrameIndices = {[1]=0}
  b.global.x = 50
  b:update(0)
  eq(b._cachedFrameIndex, 0)
  near(b.global.x, 100)
end)

test("cache: hole with an existing index fills same index without writing", function()
  local a = armature()
  local b = newBone(a, data("r"))
  b._cachedFrameIndex = 10
  b._cachedFrameIndices = {}
  b:update(2)
  eq(b._cachedFrameIndices[3], 10)
  eq(b._cachedFrameIndex, 10)
end)

test("cache: dirty parent forces child to invalidate cached state", function()
  local a = armature()
  local p = newBone(a, data("p"))
  local b = newBone(a, data("c", p.boneData))
  p._childrenTransformDirty = true
  b._cachedFrameIndex = 20
  b._cachedFrameIndices = {}
  b:update(1)
  eq(b._cachedFrameIndex, 0)
  eq(b._cachedFrameIndices[2], 0)
  eq(b._childrenTransformDirty, true)
end)

test("noncached dirty update clears transform dirty and children flag next update", function()
  local a = armature()
  local b = newBone(a, data("r"))
  b:invalidUpdate()
  b:update(-1)
  eq(b._transformDirty, false)
  eq(b._childrenTransformDirty, true)
  b:update(-1)
  eq(b._childrenTransformDirty, false)
end)

test("constraint callbacks are dispatched only to matching root", function()
  local a = armature()
  local b = newBone(a, data("r"))
  local other = newBone(a, data("o"))
  local count = 0
  a._constraints = {
    {_root=b, update=function() count=count+1 end},
    {_root=other, update=function() error("wrong constraint") end}
  }
  b._hasConstraint = true
  b:update(-1)
  eq(count, 1)
  b._cachedFrameIndices = {}
  b:update(3)
  eq(count, 2)
end)

test("updateByConstraint only evaluates once per local dirty period", function()
  local a = armature()
  local b = newBone(a, data("r"))
  b._transformDirty = true
  local calls = 0
  local original = b._updateGlobalTransformMatrix
  -- Test-only instrumentation of the instance method.
  b._updateGlobalTransformMatrix = function(self, cached)
    eq(cached, true)
    calls = calls + 1
    return original(self, cached)
  end
  b:updateByConstraint()
  eq(calls, 1)
  eq(b._localDirty, false)
  eq(b._transformDirty, true)
  b:updateByConstraint()
  eq(calls, 1)
end)

test("pool return resets fields without replacing animationPose", function()
  local b = Base.borrowObject(Bone)
  local pose = b.animationPose
  b.offsetMode = Core.OffsetMode.Override
  b.animationPose.rotation = 1
  b._visible = false
  b._cachedFrameIndex = 4
  b:returnToPool()
  local again = Base.borrowObject(Bone)
  eq(again, b)
  eq(again.animationPose, pose)
  eq(again.offsetMode, Core.OffsetMode.Additive)
  eq(again.visible, true)
  eq(again.animationPose.rotation, 0)
  eq(again._cachedFrameIndex, -1)
  eq(again._boneData, nil)
  again:returnToPool()
end)

print(("Original Bone.ts: %d passed, %d failed"):format(passed, failed))
if failed > 0 then os.exit(1) end
