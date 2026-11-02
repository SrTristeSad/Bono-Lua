-- DragonBonesJS BaseFactory.ts, original source 168-329 and 701-718.
-- Pinned commit 64b6c69ae35777c2404be68c9192e2c56906079e.
-- Renderer methods are implemented ONLY by this test subclass. The
-- production BaseFactory still requires a real platform backend.
package.path="./?.lua;./?/init.lua;"..package.path
local Factory=require("dragonbones.original.factory.BaseFactory")
local Pool=require("dragonbones.original.core.BaseObject")
local Armature=require("dragonbones.original.armature.Armature")
local Slot=require("dragonbones.original.armature.Slot")
local Bone=require("dragonbones.original.armature.Bone")
local Surface=require("dragonbones.original.armature.Surface")
local Constraint=require("dragonbones.original.armature.Constraint")
local Core=require("dragonbones.original.core.DragonBones")
local Displays=require("dragonbones.original.model.DisplayData")
local Skin=require("dragonbones.original.model.SkinData")
local passed,failed,checks=0,0,0
local function eq(a,b)
  checks=checks+1
  assert(a==b,tostring(a).." ~= "..tostring(b))
end
local function test(name,fn)
  local ok,err=pcall(fn)
  if ok then
    passed=passed+1
    print("ok original.basefactory_build "..name)
  else
    failed=failed+1
    print("not ok original.basefactory_build "..name..": "..tostring(err))
  end
end
local TestSlot={}
TestSlot.__index=function(self,key)
  return rawget(TestSlot,key) or Slot.__index(self,key)
end
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
  "_updateTransform","_identityTransform"
}
for _,name in ipairs(hooks) do
  TestSlot[name]=function(self,...)
    self.calls[#self.calls+1]={name=name,args={...}}
  end
end

local function sampleRaw(withSlots)
  local arm={
    name="rig",
    bone={{name="root"},{name="hand",parent="root"},
      {name="target"}} -- IK target independent of constrained root
  }
  if withSlots~=false then
    arm.slot={{name="body",parent="hand",displayIndex=0},
      {name="empty",parent="root",displayIndex=-1}}
    arm.skin={{
      name="default",slot={{
        name="body",display={
          {name="face",type="image",path="face"},
          {name="mesh",type="mesh",path="mesh",
            vertices={0,0,1,0,1,1},triangles={0,1,2},
            uvs={0,0,1,0,1,1}}
        }
      }}
    },{
      name="blue",slot={{
        name="body",display={{name="blue",type="image",path="blue"}}
      }}
    }}
  end
  return {version="5.5",name="data",frameRate=24,armature={arm}}
end
local function backend(raw)
  local factory=Factory.new()
  factory._dragonBones=Core.new({dispatchDBEvent=function() end})
  factory.buildLog={}
  factory._buildArmature=function(self,pkg)
    self.buildLog[#self.buildLog+1]="armature"
    local result=Pool.borrowObject(Armature)
    local proxy={dbInit=function() end, dbUpdate=function() end,
      dbClear=function() end,dispatchDBEvent=function() end}
    result:init(pkg.armature,proxy,{},self._dragonBones)
    return result
  end
  factory._buildSlot=function(self,pkg,data,arm)
    self.buildLog[#self.buildLog+1]="slot:"..data.name
    local result=Pool.borrowObject(TestSlot)
    result:init(data,arm,{name="raw-display"},{name="mesh-display"})
    return result
  end
  factory._buildTextureAtlasData=function()
    error("texture atlas not used in this suite")
  end
  local data=Factory._objectParser:parseDragonBonesData(raw or sampleRaw())
  factory:addDragonBonesData(data,"pack")
  return factory,data,data:getArmature("rig")
end
local function prepare(raw,skinName,textureName)
  local factory,data,model=backend(raw)
  local pkg=Factory.BuildArmaturePackage.new()
  eq(factory:_fillBuildArmaturePackage(pkg,"pack","rig",
    skinName or "",textureName or ""),true)
  local runtime=factory:_buildArmature(pkg)
  return factory,data,model,pkg,runtime
end
local function frame(slot,index)
  return slot:getDisplayFrameAt(index or 0)
end

test("original Bone and Surface classes are available for construction",function()
  eq(type(Bone.init),"function")
  eq(type(Surface.init),"function")
  eq(type(Constraint.IKConstraint.init),"function")
  eq(type(Constraint.PathConstraint.init),"function")
end)
test("BaseFactory retains three abstract platform entry points",function()
  local f=Factory.new()
  eq(pcall(function() f:_buildArmature({}) end),false)
  eq(pcall(function() f:_buildSlot({},{},{}) end),false)
  eq(pcall(function() f:_buildTextureAtlasData(nil,nil) end),false)
end)
test("buildBones creates real Bones in sorted data order",function()
  local f,data,model,pkg,runtime=prepare()
  f:_buildBones(pkg,runtime)
  eq(#runtime:getBones(),3)
  eq(runtime:getBones()[1].name,model.sortedBones[1].name)
  eq(runtime:getBone("root").boneData,model:getBone("root"))
  eq(runtime:getBone("hand").parent,runtime:getBone("root"))
end)
test("buildBones works with zero bones",function()
  local raw=sampleRaw(false)
  raw.armature[1].bone={}
  local f,d,m,pkg,runtime=prepare(raw)
  f:_buildBones(pkg,runtime)
  eq(#runtime:getBones(),0)
end)
test("buildBones detects and constructs original Surface instead of Bone",function()
  local raw=sampleRaw(false)
  raw.armature[1].bone={{name="root"},
    {name="cloth",type="surface",vertices={0,0,1,1}}}
  local f,d,m,pkg,runtime=prepare(raw)
  f:_buildBones(pkg,runtime)
  eq(getmetatable(runtime:getBone("cloth")),Surface)
  eq(getmetatable(runtime:getBone("root")),Bone)
end)
test("buildSlots returns early when no default skin",function()
  local f,d,m,pkg,runtime=prepare(sampleRaw(false))
  f:_buildBones(pkg,runtime)
  f:_buildSlots(pkg,runtime)
  eq(#runtime:getSlots(),0)
end)
test("buildSlots returns early when selected package skin is nil",function()
  local f,d,m,pkg,runtime=prepare()
  f:_buildBones(pkg,runtime)
  pkg.skin=nil
  f:_buildSlots(pkg,runtime)
  eq(#runtime:getSlots(),0)
end)
test("buildSlots attaches original Slot subclass and raw display data",function()
  local f,d,m,pkg,runtime=prepare()
  f:_buildBones(pkg,runtime)
  f:_buildSlots(pkg,runtime)
  local s=runtime:getSlot("body")
  eq(getmetatable(s),TestSlot)
  eq(s.parent,runtime:getBone("hand"))
  eq(s.displayFrameCount,2)
  eq(frame(s,0).rawDisplayData.name,"face")
  eq(frame(s,1).rawDisplayData.name,"mesh")
end)
test("buildSlots maps Image and Mesh displays to the backend handles",function()
  local f,d,m,pkg,runtime=prepare()
  f:_buildBones(pkg,runtime)
  f:_buildSlots(pkg,runtime)
  local s=runtime:getSlot("body")
  eq(frame(s,0).display,s.rawDisplay)
  eq(frame(s,1).display,s.meshDisplay)
end)
test("buildSlots selects z-order and initial display index from SlotData",function()
  local f,d,m,pkg,runtime=prepare()
  f:_buildBones(pkg,runtime)
  f:_buildSlots(pkg,runtime)
  eq(runtime:getSlot("body").displayIndex,0)
  eq(runtime:getSlot("empty").displayIndex,-1)
  eq(#runtime:getSlots(),2)
end)
test("selected alternate skin overrides defaults for matching slot only",function()
  local f,d,m,pkg,runtime=prepare(nil,"blue")
  f:_buildBones(pkg,runtime)
  f:_buildSlots(pkg,runtime)
  local s=runtime:getSlot("body")
  eq(s.displayFrameCount,1)
  eq(frame(s,0).rawDisplayData.name,"blue")
  eq(runtime:getSlot("empty").displayFrameCount,0)
end)
test("skin overlay does not mutate original default skin displays",function()
  local f,d,m,pkg,runtime=prepare(nil,"blue")
  f:_buildBones(pkg,runtime)
  f:_buildSlots(pkg,runtime)
  eq(#m.defaultSkin:getDisplays("body"),2)
  eq(m.defaultSkin:getDisplays("body")[1].name,"face")
end)
test("textureAtlasName explicitly replaces per-display texture data",function()
  local f,d,m,pkg,runtime=prepare(nil,nil,"atlasKey")
  f:_buildBones(pkg,runtime)
  local a={getTexture=function(self,name)
    return {name=name,atlas="atlasKey"} end}
  f:addTextureAtlasData(a,"atlasKey")
  f:_buildSlots(pkg,runtime)
  eq(frame(runtime:getSlot("body"),0).textureData.name,"face")
  eq(frame(runtime:getSlot("body"),1).textureData.name,"mesh")
end)
test("getSlotDisplay looks up textures under DragonBones package name",function()
  local f,d,m,pkg,runtime=prepare()
  f:_buildBones(pkg,runtime)
  local tex={name="face"}
  local atlas={getTexture=function(self,name)
    if name=="face" then return tex end
  end}
  f:addTextureAtlasData(atlas,"pack")
  local img=m.defaultSkin:getDisplay("body","face")
  local s={rawDisplay={name="raw"},meshDisplay={name="mesh"}}
  eq(f:_getSlotDisplay(pkg,img,s),s.rawDisplay)
  eq(img.texture,tex)
end)
test("getSlotDisplay retains previously selected texture",function()
  local f,d,m,pkg,runtime=prepare()
  local img=m.defaultSkin:getDisplay("body","face")
  local tex={name="old"}
  img.texture=tex
  local s={rawDisplay={},meshDisplay={}}
  eq(f:_getSlotDisplay(pkg,img,s),s.rawDisplay)
  eq(img.texture,tex)
end)
test("getSlotDisplay chooses raw display when platform does not support mesh",function()
  local f,d,m,pkg,runtime=prepare()
  local mesh=m.defaultSkin:getDisplay("body","mesh")
  f._isSupportMesh=function() return false end
  local s={rawDisplay={name="raw"},meshDisplay={name="mesh"}}
  eq(f:_getSlotDisplay(pkg,mesh,s),s.rawDisplay)
end)
test("getSlotDisplay chooses mesh display for supported mesh",function()
  local f,d,m,pkg,runtime=prepare()
  local mesh=m.defaultSkin:getDisplay("body","mesh")
  local s={rawDisplay={name="raw"},meshDisplay={name="mesh"}}
  eq(f:_getSlotDisplay(pkg,mesh,s),s.meshDisplay)
end)
test("getSlotDisplay returns nil for bounding box display",function()
  local f,d,m,pkg,runtime=prepare()
  local bbox=Pool.borrowObject(Displays.BoundingBoxDisplayData)
  local s={rawDisplay={name="raw"},meshDisplay={name="mesh"}}
  eq(f:_getSlotDisplay(pkg,bbox,s),nil)
end)
test("getSlotDisplay with nil package resolves atlas through display parent chain",function()
  local f,d,m,pkg,runtime=prepare()
  local img=m.defaultSkin:getDisplay("body","face")
  local tex={name="fromData"}
  f:addTextureAtlasData({getTexture=function() return tex end},"data")
  eq(f:_getSlotDisplay(nil,img,{rawDisplay="raw"}),"raw")
  eq(img.texture,tex)
end)
test("buildChildArmature passes path and package names to buildArmature",function()
  local f,d,m,pkg,runtime=prepare()
  local seen={}
  f.buildArmature=function(self,...)
    for i=1,select("#",...) do seen[i]=select(i,...) end
    return nil
  end
  local display=Pool.borrowObject(Displays.ArmatureDisplayData)
  display.path="child"
  eq(f:_buildChildArmature(pkg,nil,display),nil)
  eq(seen[1],"child")
  eq(seen[2],"pack")
  eq(seen[3],"")
  eq(seen[4],"")
end)
test("buildChildArmature without package uses source empty defaults",function()
  local f,d,m,pkg,runtime=prepare()
  local args={}
  f.buildArmature=function(self,a,b,c,d) args={a,b,c,d};return nil end
  local display=Pool.borrowObject(Displays.ArmatureDisplayData)
  display.path="child"
  f:_buildChildArmature(nil,nil,display)
  eq(args[1],"child")
  eq(args[2],"")
  eq(args[3],"")
  eq(args[4],"")
end)
test("getSlotDisplay Armature branch respects missing child",function()
  local f,d,m,pkg,runtime=prepare()
  f._buildChildArmature=function() return nil end
  local display=Pool.borrowObject(Displays.ArmatureDisplayData)
  display.path="missing"
  eq(f:_getSlotDisplay(pkg,display,{rawDisplay="raw"}),nil)
  eq(display.armature,nil)
end)
test("buildConstraints instantiates actual IKConstraint and binds bones",function()
  local raw=sampleRaw(false)
  raw.armature[1].ik={{
    name="ik",bone="hand",target="target",chain=1
  }}
  local f,d,m,pkg,runtime=prepare(raw)
  f:_buildBones(pkg,runtime)
  f:_buildConstraints(pkg,runtime)
  eq(#runtime._constraints,1)
  local ik=runtime._constraints[1]
  eq(getmetatable(ik),Constraint.IKConstraint)
  eq(ik._root,runtime:getBone("root"))
  eq(ik._bone,runtime:getBone("hand"))
  eq(ik._target,runtime:getBone("target"))
end)
test("buildConstraints with no constraints creates none",function()
  local f,d,m,pkg,runtime=prepare(sampleRaw(false))
  f:_buildBones(pkg,runtime)
  f:_buildConstraints(pkg,runtime)
  eq(#runtime._constraints,0)
end)
test("buildConstraints unknown type takes original IK fallback",function()
  local f,d,m,pkg,runtime=prepare(sampleRaw(false))
  f:_buildBones(pkg,runtime)
  local constraint={type=999,name="fallback",root=m:getBone("root"),
    target=m:getBone("target"),bone=nil,bendPositive=true,weight=0.5}
  m.constraints.fallback=constraint
  f:_buildConstraints(pkg,runtime)
  eq(getmetatable(runtime._constraints[1]),Constraint.IKConstraint)
  eq(runtime._constraints[1]._weight,0.5)
end)
test("buildConstraints original PathConstraint initialises its target and slot",function()
  local f,d,m,pkg,runtime=prepare()
  f:_buildBones(pkg,runtime)
  f:_buildSlots(pkg,runtime)
  m.constraints.path={
    type=Core.ConstraintType.Path,
    root=m:getBone("root"),target=m:getBone("target"),
    pathSlot=m:getSlot("body"),pathDisplayData={geometry={offset=4}},
    bones={m:getBone("hand")},position=3,spacing=1,rotateOffset=0,
    rotateMix=0.6,translateMix=0.8,rotateMode=Core.RotateMode.Chain
  }
  f:_buildConstraints(pkg,runtime)
  local c=runtime._constraints[1]
  eq(getmetatable(c),Constraint.PathConstraint)
  eq(c.pathOffset,4)
  eq(c._pathSlot,runtime:getSlot("body"))
  eq(c._root,runtime:getBone("root"))
end)
test("buildArmature unknown name returns nil without calling backend",function()
  local f,d,m=backend()
  eq(f:buildArmature("missing","pack"),nil)
  eq(#f.buildLog,0)
end)
test("buildArmature constructs actual runtime armature and its three Bones",function()
  local f,d,m=backend(sampleRaw(false))
  local a=f:buildArmature("rig","pack")
  eq(getmetatable(a),Armature)
  eq(a.armatureData,m)
  eq(#a:getBones(),3)
  eq(a:getBone("hand").parent,a:getBone("root"))
  eq(#a:getSlots(),0)
end)
test("buildArmature performs original invalidUpdate/advanceTime zero",function()
  local f,d,m=backend(sampleRaw(false))
  local a=f:buildArmature("rig","pack")
  eq(a._lockUpdate,false)
  eq(#a:getBones(),3)
  eq(#f.buildLog,1)
  eq(f.buildLog[1],"armature")
end)
test("buildArmature with real Slot subclass builds images and initializes pose",function()
  local f,d,m=backend()
  local a=f:buildArmature("rig","pack")
  eq(#a:getBones(),3)
  eq(#a:getSlots(),2)
  eq(a:getSlot("body").displayFrameCount,2)
  eq(frame(a:getSlot("body"),0).rawDisplayData.name,"face")
  eq(a._lockUpdate,false)
end)
test("buildArmature selects alternative skin in the public entry point",function()
  local f,d,m=backend()
  local a=f:buildArmature("rig","pack","blue")
  eq(a:getSlot("body").displayFrameCount,1)
  eq(frame(a:getSlot("body"),0).rawDisplayData.name,"blue")
end)
test("buildArmature does not invent a backend when abstract methods not supplied",function()
  local f=Factory.new()
  local d=require("dragonbones.original.parser.ObjectDataParser").new()
    :parseDragonBonesData(sampleRaw(false))
  f:addDragonBonesData(d,"pack")
  local ok=pcall(function() f:buildArmature("rig","pack") end)
  eq(ok,false)
end)

print(("Original BaseFactory construction: %d passed, %d failed, %d assertions")
  :format(passed,failed,checks))
if failed>0 then os.exit(1) end
