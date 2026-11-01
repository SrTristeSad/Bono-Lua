-- Conformance checks for pinned DragonBonesJS:
-- armature/TransformObject.ts, model/CanvasData.ts,
-- model/ConstraintData.ts and model/TextureAtlasData.ts.
-- Concrete classes below are *test doubles* for the original abstract classes.
package.path="./?.lua;./?/init.lua;"..package.path
local BaseObject=require("dragonbones.original.core.BaseObject")
local Matrix=require("dragonbones.original.geom.Matrix")
local Transform=require("dragonbones.original.geom.Transform")
local Point=require("dragonbones.original.geom.Point")
local TransformObject=require("dragonbones.original.armature.TransformObject")
local CanvasData=require("dragonbones.original.model.CanvasData")
local Constraint=require("dragonbones.original.model.ConstraintData")
local Texture=require("dragonbones.original.model.TextureAtlasData")

local passed,failed=0,0
local function test(name,fn)
  local ok,err=pcall(fn)
  if ok then passed=passed+1;print("ok original.models "..name)
  else failed=failed+1;print("not ok original.models "..name..": "..tostring(err)) end
end
local function eq(actual,expected,tolerance)
  assert(type(actual)=="number" and type(expected)=="number")
  assert(math.abs(actual-expected)<=(tolerance or 1e-9),
    tostring(actual).." ~= "..tostring(expected))
end
local function fields(value,expected)
  for k,v in pairs(expected) do
    if type(v)=="number" then eq(value[k],v) else assert(value[k]==v,k) end
  end
end

local BoneTestClass={}
setmetatable(BoneTestClass,{__index=TransformObject})
-- TS inherits the abstract armature property getter. Lua subclass lookup must
-- preserve this inherited accessor; the future Bone port will do the same.
BoneTestClass.__index=function(self,key)
  if key=="armature" then return rawget(self,"_armature") end
  return BoneTestClass[key]
end
function BoneTestClass.new()
  return TransformObject.new(BoneTestClass)
end

local TextureTestClass={}
TextureTestClass.__index=TextureTestClass
setmetatable(TextureTestClass,{__index=Texture.TextureData})
function TextureTestClass.new()
  return Texture.TextureData.new(TextureTestClass)
end

local AtlasTestClass={}
AtlasTestClass.__index=AtlasTestClass
setmetatable(AtlasTestClass,{__index=Texture.TextureAtlasData})
function AtlasTestClass.new()
  return Texture.TextureAtlasData.new(AtlasTestClass)
end
function AtlasTestClass:createTexture()
  return BaseObject.borrowObject(TextureTestClass)
end

test("TransformObject shared helper instances are original geometry types",function()
  assert(getmetatable(TransformObject._helpMatrix)==Matrix)
  assert(getmetatable(TransformObject._helpTransform)==Transform)
  assert(getmetatable(TransformObject._helpPoint)==Point)
  assert(TransformObject._helpMatrix==TransformObject._helpMatrix)
end)
test("TransformObject initializes three transform objects and clear state",function()
  local bone=BaseObject.borrowObject(BoneTestClass)
  assert(getmetatable(bone.globalTransformMatrix)==Matrix)
  assert(getmetatable(bone.global)==Transform)
  assert(getmetatable(bone.offset)==Transform)
  assert(bone.globalTransformMatrix~=TransformObject._helpMatrix)
  assert(bone.origin==nil and bone.userData==nil)
  assert(bone._alpha==1 and bone._globalAlpha==1)
  assert(bone._globalDirty==false and bone.armature==nil)
  bone:returnToPool()
end)
test("TransformObject _onClear mutates existing field instances",function()
  local bone=BaseObject.borrowObject(BoneTestClass)
  local matrix,global,offset=bone.globalTransformMatrix,bone.global,bone.offset
  bone.globalTransformMatrix.tx=100
  bone.global.scaleX=7
  bone.offset.y=12
  bone.origin=Transform.new(1,2)
  bone.userData={x=3}
  bone._alpha=.3
  bone._globalAlpha=.7
  bone._armature={name="armature"}
  bone._globalDirty=true
  assert(bone.armature==bone._armature)
  assert(bone:_onClear()==nil)
  assert(bone.globalTransformMatrix==matrix and bone.global==global and bone.offset==offset)
  fields(matrix,{a=1,b=0,c=0,d=1,tx=0,ty=0})
  fields(global,{x=0,y=0,scaleX=1,scaleY=1,rotation=0,skew=0})
  fields(offset,{x=0,y=0,scaleX=1,scaleY=1,rotation=0,skew=0})
  assert(bone.origin==nil and bone.userData==nil and bone.armature==nil)
  assert(bone._globalDirty==false and bone._alpha==1 and bone._globalAlpha==1)
  bone:returnToPool()
end)
test("TransformObject updateGlobalTransform is lazy and returns void",function()
  local bone=BaseObject.borrowObject(BoneTestClass)
  local m=bone.globalTransformMatrix
  m.a=0;m.b=1;m.c=-1;m.d=0;m.tx=12;m.ty=14
  assert(bone:updateGlobalTransform()==nil)
  fields(bone.global,{x=0,y=0,rotation=0})
  bone._globalDirty=true
  assert(bone:updateGlobalTransform()==nil)
  fields(bone.global,{x=12,y=14,rotation=math.pi/2,scaleX=1,scaleY=1})
  assert(not bone._globalDirty)
  m.tx=999
  bone:updateGlobalTransform()
  assert(bone.global.x==12)
  bone:returnToPool()
end)
test("TransformObject returns to pool without reallocating geometry",function()
  local bone=BaseObject.borrowObject(BoneTestClass)
  local m,t,o=bone.globalTransformMatrix,bone.global,bone.offset
  local hash=bone.hashCode
  bone:returnToPool()
  local borrowed=BaseObject.borrowObject(BoneTestClass)
  assert(borrowed==bone and borrowed.hashCode==hash)
  assert(borrowed.globalTransformMatrix==m and borrowed.global==t and borrowed.offset==o)
  borrowed:returnToPool()
end)

test("CanvasData class name and clear values",function()
  assert(CanvasData.toString()=="[class dragonBones.CanvasData]")
  local c=BaseObject.borrowObject(CanvasData)
  fields(c,{hasBackground=false,color=0,x=0,y=0,width=0,height=0})
  c:returnToPool()
end)
test("CanvasData _onClear resets all mutable fields and retains pooled identity",function()
  local c=BaseObject.borrowObject(CanvasData)
  c.hasBackground=true;c.color=0xffffff;c.x=-2;c.y=4;c.width=128;c.height=256
  local hash=c.hashCode
  c:returnToPool()
  local next=BaseObject.borrowObject(CanvasData)
  assert(next==c and next.hashCode==hash and not next.hasBackground)
  fields(next,{color=0,x=0,y=0,width=0,height=0})
  next:returnToPool()
end)

test("IKConstraintData defaults match original ConstraintType.IK",function()
  local ik=BaseObject.borrowObject(Constraint.IKConstraintData)
  assert(Constraint.IKConstraintData.toString()=="[class dragonBones.IKConstraintData]")
  fields(ik,{order=0,name="",type=0,scaleEnabled=false,bendPositive=false,weight=1})
  assert(ik.target==nil and ik.root==nil and ik.bone==nil)
  ik:returnToPool()
end)
test("IKConstraintData clears base and specialized state",function()
  local ik=BaseObject.borrowObject(Constraint.IKConstraintData)
  ik.order=8;ik.name="ik";ik.type=1
  ik.target={};ik.root={};ik.bone={}
  ik.scaleEnabled=true;ik.bendPositive=true;ik.weight=.125
  ik:returnToPool()
  local next=BaseObject.borrowObject(Constraint.IKConstraintData)
  assert(next==ik and next.order==0 and next.name=="" and next.type==0)
  assert(next.target==nil and next.root==nil and next.bone==nil)
  assert(not next.scaleEnabled and not next.bendPositive and next.weight==1)
  next:returnToPool()
end)
test("PathConstraintData defaults include original enum values",function()
  local p=BaseObject.borrowObject(Constraint.PathConstraintData)
  assert(Constraint.PathConstraintData.toString()=="[class dragonBones.PathConstraintData]")
  fields(p,{order=0,name="",type=0,positionMode=0,spacingMode=1,rotateMode=1,
    position=0,spacing=0,rotateOffset=0,rotateMix=0,translateMix=0})
  assert(#p.bones==0 and p.pathSlot==nil and p.pathDisplayData==nil)
  p:returnToPool()
end)
test("PathConstraintData AddBone keeps identity and order",function()
  local p=BaseObject.borrowObject(Constraint.PathConstraintData)
  local a,b={name="a"},{name="b"}
  assert(p:AddBone(a)==nil)
  assert(p:AddBone(b)==nil)
  assert(p.bones[1]==a and p.bones[2]==b)
  p:returnToPool()
end)
test("PathConstraintData _onClear retains bones array identity and clears state",function()
  local p=BaseObject.borrowObject(Constraint.PathConstraintData)
  local bones=p.bones
  p:AddBone({})
  p.pathSlot={};p.pathDisplayData={}
  p.positionMode=1;p.spacingMode=2;p.rotateMode=2
  p.position=4;p.spacing=5;p.rotateOffset=6;p.rotateMix=7;p.translateMix=8
  p:returnToPool()
  assert(p.bones==bones and #bones==0)
  local next=BaseObject.borrowObject(Constraint.PathConstraintData)
  assert(next==p and next.bones==bones and #next.bones==0)
  assert(next.pathSlot==nil and next.pathDisplayData==nil)
  fields(next,{positionMode=0,spacingMode=1,rotateMode=1,position=0,spacing=0,
    rotateOffset=0,rotateMix=0,translateMix=0})
  next:returnToPool()
end)

test("TextureData.createRectangle creates independent original Rectangles",function()
  local a=Texture.TextureData.createRectangle()
  local b=Texture.TextureData.createRectangle()
  assert(getmetatable(a)==require("dragonbones.original.geom.Rectangle"))
  assert(a~=b)
end)
test("TextureData original region and metadata are cleared on borrow",function()
  local tex=BaseObject.borrowObject(TextureTestClass)
  assert(tex.rotated==false and tex.name=="" and tex.parent==nil and tex.frame==nil)
  fields(tex.region,{x=0,y=0,width=0,height=0})
  tex:returnToPool()
end)
test("TextureData.copyFrom mutates region and copies source parent reference",function()
  local source=BaseObject.borrowObject(TextureTestClass)
  local dest=BaseObject.borrowObject(TextureTestClass)
  source.rotated=true
  source.name="head"
  source.parent={name="source atlas"}
  fields(source.region,{x=0,y=0,width=0,height=0})
  source.region.x=10;source.region.y=20;source.region.width=30;source.region.height=40
  assert(dest:copyFrom(source)==nil)
  assert(dest.rotated and dest.name=="head" and dest.parent==source.parent)
  fields(dest.region,{x=10,y=20,width=30,height=40})
  dest:returnToPool();source:returnToPool()
end)
test("TextureData.copyFrom creates and removes optional frame",function()
  local source=BaseObject.borrowObject(TextureTestClass)
  local dest=BaseObject.borrowObject(TextureTestClass)
  source.frame=Texture.TextureData.createRectangle()
  source.frame.x=-3;source.frame.y=-4;source.frame.width=50;source.frame.height=60
  dest:copyFrom(source)
  assert(dest.frame~=nil and dest.frame~=source.frame)
  fields(dest.frame,{x=-3,y=-4,width=50,height=60})
  local oldFrame=dest.frame
  source.frame.width=20
  dest:copyFrom(source)
  assert(dest.frame==oldFrame and dest.frame.width==20)
  source.frame=nil
  dest:copyFrom(source)
  assert(dest.frame==nil)
  source:returnToPool();dest:returnToPool()
end)
test("TextureAtlasData default clear/reset and lookup missing returns nil",function()
  local atlas=BaseObject.borrowObject(AtlasTestClass)
  assert(not atlas.autoSearch and atlas.width==0 and atlas.height==0 and atlas.scale==1)
  assert(atlas.name=="" and atlas.imagePath=="" and atlas:getTexture("missing")==nil)
  assert(#atlas.textures==0)
  atlas:returnToPool()
end)
test("TextureAtlasData.addTexture sets parent and rejects duplicate key",function()
  local atlas=BaseObject.borrowObject(AtlasTestClass)
  local a=BaseObject.borrowObject(TextureTestClass)
  local b=BaseObject.borrowObject(TextureTestClass)
  a.name="arm";b.name="arm"
  assert(atlas:addTexture(a)==nil)
  assert(atlas:getTexture("arm")==a and a.parent==atlas)
  assert(atlas:addTexture(b)==nil)
  assert(atlas:getTexture("arm")==a and b.parent==nil)
  b:returnToPool()
  atlas:returnToPool()
end)
test("TextureAtlasData.clear returns nested textures to BaseObject pool",function()
  local atlas=BaseObject.borrowObject(AtlasTestClass)
  local t=BaseObject.borrowObject(TextureTestClass)
  t.name="body";atlas:addTexture(t)
  atlas.autoSearch=true;atlas.scale=2;atlas.width=100;atlas.height=64
  atlas.name="fixture";atlas.imagePath="fixture.png"
  local texMap=atlas.textures
  atlas:returnToPool()
  assert(atlas.textures==texMap and next(texMap)==nil)
  assert(t._isInPool==true and t.name=="" and t.parent==nil)
  local borrowed=BaseObject.borrowObject(AtlasTestClass)
  assert(borrowed==atlas and borrowed.scale==1 and borrowed.width==0 and borrowed.name=="")
  borrowed:returnToPool()
end)
test("TextureAtlasData.copyFrom clones textures with original parent semantics",function()
  local source=BaseObject.borrowObject(AtlasTestClass)
  local target=BaseObject.borrowObject(AtlasTestClass)
  source.autoSearch=true;source.scale=1.5;source.width=512;source.height=256
  source.name="source";source.imagePath="packed.png"
  local sourceTexture=BaseObject.borrowObject(TextureTestClass)
  sourceTexture.name="character";sourceTexture.rotated=true;sourceTexture.region.width=32
  source:addTexture(sourceTexture)
  local old=BaseObject.borrowObject(TextureTestClass)
  old.name="obsolete";target:addTexture(old)
  local map=target.textures
  assert(target:copyFrom(source)==nil)
  assert(map==target.textures and target:getTexture("obsolete")==nil)
  local copy=target:getTexture("character")
  assert(copy~=nil and copy~=sourceTexture and copy.name=="character")
  assert(copy.parent==source) -- upstream TextureData.copyFrom copies source.parent
  assert(copy.rotated and copy.region.width==32)
  assert(target.autoSearch and target.width==512 and target.height==256)
  assert(target.scale==1.5 and target.name=="source" and target.imagePath=="packed.png")
  -- The original pool can immediately reuse the discarded texture during copyFrom.
  assert(copy==old and not old._isInPool)
  target:returnToPool();source:returnToPool()
end)
test("TextureAtlasData.createTexture remains abstract without backend implementation",function()
  assert(type(Texture.TextureAtlasData.createTexture)=="function")
  local proxy=Texture.TextureAtlasData.new(Texture.TextureAtlasData)
  proxy:_onClear()
  assert(not pcall(function()proxy:createTexture()end))
end)

print(("Original transform/model port: %d passed, %d failed"):format(passed,failed))
if failed>0 then os.exit(1) end
