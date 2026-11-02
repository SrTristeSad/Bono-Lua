-- DragonBonesJS BaseFactory.ts, original source 719-981.
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


local function construct(raw)
  local f,data,model=backend(raw)
  return f,data,model,f:buildArmature("rig","pack")
end
local function modelDisplay(model,name)
  return model.defaultSkin:getDisplay("body",name)
end
local function extraImage(model,name)
  local obj=Pool.borrowObject(Displays.ImageDisplayData)
  obj.name=name
  obj.path=name
  obj.parent=model.defaultSkin
  return obj
end
local function extraMesh(model,name)
  local obj=Pool.borrowObject(Displays.MeshDisplayData)
  obj.name=name
  obj.path=name
  obj.parent=model.defaultSkin
  return obj
end
local function animationSet(rig)
  local out={}
  for name,d in pairs(rig.animation.animations) do out[name]=d end
  return out
end

test("all five original replacement entry points are implemented",function()
  for _,name in ipairs({"replaceDisplay","replaceSlotDisplay",
      "replaceSlotDisplayList","replaceSkin","replaceAnimation"}) do
    eq(type(Factory[name]),"function")
  end
end)
test("replaceDisplay changes current image without changing raw source",function()
  local f,data,m,rig=construct()
  local s=rig:getSlot("body")
  local raw=frame(s,0).rawDisplayData
  local img=extraImage(m,"extra")
  f:replaceDisplay(s,img)
  eq(frame(s,0).rawDisplayData,raw)
  eq(frame(s,0).displayData,img)
  eq(frame(s,0).display,s.rawDisplay)
  eq(s.displayFrameCount,2)
end)
test("replaceDisplay explicitly addresses frame index 1, preserving index 0",function()
  local f,data,m,rig=construct()
  local s=rig:getSlot("body")
  local initial=frame(s,0).display
  local mesh=frame(s,1).rawDisplayData
  f:replaceDisplay(s,extraMesh(m,"newmesh"),1)
  eq(frame(s,0).display,initial)
  eq(frame(s,1).rawDisplayData,mesh)
  eq(frame(s,1).display,s.meshDisplay)
end)
test("replaceDisplay image atop raw mesh uses mesh display backend handle",function()
  local f,data,m,rig=construct()
  local s=rig:getSlot("body")
  f:replaceDisplay(s,extraImage(m,"overmesh"),1)
  eq(frame(s,1).rawDisplayData.type,Core.DisplayType.Mesh)
  eq(frame(s,1).display,s.meshDisplay)
end)
test("replaceDisplay with nil clears current display only",function()
  local f,data,m,rig=construct()
  local s=rig:getSlot("body")
  f:replaceDisplay(s,nil)
  eq(frame(s,0).display,nil)
  eq(frame(s,0).rawDisplayData.name,"face")
  eq(frame(s,1).display,s.meshDisplay)
end)
test("replaceDisplay on hidden slot with negative index selects zero",function()
  local f,data,m,rig=construct()
  local s=rig:getSlot("empty")
  s.displayFrameCount=1
  f:replaceDisplay(s,extraImage(m,"hidden"),-1)
  eq(frame(s,0).display,s.rawDisplay)
  eq(s.displayIndex,-1)
end)
test("replaceDisplay caches image texture through original owning data path",function()
  local f,data,m,rig=construct()
  local s=rig:getSlot("body")
  local d=extraImage(m,"textureX")
  local texture={name="found"}
  f:addTextureAtlasData({getTexture=function(_,name)
    if name=="textureX" then return texture end
  end},"data")
  f:replaceDisplay(s,d)
  eq(d.texture,texture)
end)
test("replaceSlotDisplay returns false for unknown armature",function()
  local f,data,m,rig=construct()
  local slot=rig:getSlot("body")
  local before=frame(slot,0).display
  eq(f:replaceSlotDisplay("none","rig","body","face",slot),false)
  eq(frame(slot,0).display,before)
end)
test("replaceSlotDisplay returns false if source has no default skin",function()
  local f,data,m,rig=construct()
  local source=sampleRaw(false)
  source.armature[1].name="unskinned"
  f:addDragonBonesData(Factory._objectParser:parseDragonBonesData(source),"no-skin")
  eq(f:replaceSlotDisplay("no-skin","unskinned","body","face",
    rig:getSlot("body")),false)
end)
test("replaceSlotDisplay returns true for named image in default skin",function()
  local f,data,m,rig=construct()
  local s=rig:getSlot("body")
  eq(f:replaceSlotDisplay("pack","rig","body","face",s,1),true)
  eq(frame(s,1).displayData,modelDisplay(m,"face"))
  eq(frame(s,1).display,s.meshDisplay)
end)
test("replaceSlotDisplay returns true even if requested image is absent",function()
  local f,data,m,rig=construct()
  local s=rig:getSlot("body")
  eq(f:replaceSlotDisplay("pack","rig","body","missing",s),true)
  eq(frame(s,0).display,nil)
end)
test("replaceSlotDisplayList rejects unknown armature or slot",function()
  local f,data,m,rig=construct()
  local s=rig:getSlot("body")
  eq(f:replaceSlotDisplayList("unknown","rig","body",s),false)
  eq(f:replaceSlotDisplayList("pack","rig","absent",s),false)
end)
test("replaceSlotDisplayList resizes and installs all replacement indices",function()
  local f,data,m,rig=construct()
  local s=rig:getSlot("body")
  s.displayFrameCount=1
  eq(f:replaceSlotDisplayList("pack","rig","body",s),true)
  eq(s.displayFrameCount,2)
  eq(frame(s,0).display,s.rawDisplay)
  eq(frame(s,1).display,s.meshDisplay)
end)
test("replaceSlotDisplayList leaves raw skin display source unchanged",function()
  local f,data,m,rig=construct()
  local s=rig:getSlot("body")
  local raw=frame(s,0).rawDisplayData
  f:replaceSlotDisplayList("pack","rig","body",s)
  eq(frame(s,0).rawDisplayData,raw)
end)
test("replaceSlotDisplayList clears explicit null display without truncating list",function()
  local f,data,m,rig=construct()
  m.defaultSkin:addDisplay("body",nil)
  local s=rig:getSlot("body")
  eq(f:replaceSlotDisplayList("pack","rig","body",s),true)
  eq(s.displayFrameCount,3)
  eq(frame(s,2).display,nil)
end)
test("replaceSkin selected skin replaces all displays on matching slot",function()
  local f,data,m,rig=construct()
  eq(f:replaceSkin(rig,m:getSkin("blue")),true)
  local s=rig:getSlot("body")
  eq(s.displayFrameCount,1)
  eq(frame(s,0).rawDisplayData.name,"blue")
  eq(frame(s,0).display,s.rawDisplay)
end)
test("replaceSkin falls back to source default skin on absent selected slot",function()
  local f,data,m,rig=construct()
  local skin=m:getSkin("blue")
  local defaults=m.defaultSkin:getDisplays("body")
  skin.displays.body=nil
  eq(f:replaceSkin(rig,skin),true)
  eq(rig:getSlot("body").displayFrameCount,#defaults)
  eq(frame(rig:getSlot("body"),0).rawDisplayData.name,"face")
end)
test("replaceSkin with override clears slots missing both selected and default",function()
  local f,data,m,rig=construct()
  rig:getSlot("empty").displayFrameCount=2
  eq(f:replaceSkin(rig,m:getSkin("blue"),true),true)
  eq(rig:getSlot("empty").displayFrameCount,0)
end)
test("replaceSkin without override preserves slots missing both skins",function()
  local f,data,m,rig=construct()
  rig:getSlot("empty").displayFrameCount=1
  eq(f:replaceSkin(rig,m:getSkin("blue"),false),true)
  eq(rig:getSlot("empty").displayFrameCount,1)
end)
test("replaceSkin exclude list skips named matching slot",function()
  local f,data,m,rig=construct()
  local s=rig:getSlot("body")
  eq(f:replaceSkin(rig,m:getSkin("blue"),true,{"body"}),false)
  eq(s.displayFrameCount,2)
  eq(frame(s,0).rawDisplayData.name,"face")
end)
test("replaceSkin exclude some slots still modifies remaining match",function()
  local f,data,m,rig=construct()
  local slot=rig:getSlot("empty")
  eq(f:replaceSkin(rig,m:getSkin("blue"),false,{"empty"}),true)
  eq(slot.displayIndex,-1)
  eq(rig:getSlot("body").displayFrameCount,1)
end)
test("replaceSkin source NULL retains frame and clears display",function()
  local f,data,m,rig=construct()
  local skin=m:getSkin("blue")
  skin.displays.body={Skin.NULL}
  eq(f:replaceSkin(rig,skin),true)
  eq(rig:getSlot("body").displayFrameCount,1)
  eq(frame(rig:getSlot("body"),0).display,nil)
end)
test("replaceSkin uses default skin even when passed the default",function()
  local f,data,m,rig=construct()
  eq(f:replaceSkin(rig,m.defaultSkin),true)
  eq(rig:getSlot("body").displayFrameCount,2)
end)
test("replaceSkin returns false when no non-excluded slot matches",function()
  local f,data,m,rig=construct()
  local other=require("dragonbones.original.model.ArmatureData")
  local owner=Pool.borrowObject(other.ArmatureData)
  local skin=Pool.borrowObject(Skin)
  skin.name="missing"
  owner:addSkin(skin)
  eq(f:replaceSkin(rig,skin,false),false)
end)
test("replaceAnimation rejects data with no default skin",function()
  local f,data,m,rig=construct()
  local other=require("dragonbones.original.model.ArmatureData")
  local target=Pool.borrowObject(other.ArmatureData)
  eq(f:replaceAnimation(rig,target),false)
end)
test("replaceAnimation default override replaces full animation lookup",function()
  local f,data,m,rig=construct()
  local before={old={name="old"}}
  rig.animation.animations=before
  local new={fresh={name="fresh"}}
  m.animations=new
  eq(f:replaceAnimation(rig,m),true)
  eq(rig.animation.animations.old,nil)
  eq(rig.animation.animations.fresh,new.fresh)
end)
test("replaceAnimation with false merges both maps with incoming precedence",function()
  local f,data,m,rig=construct()
  local previous={same={name="old"},keep={name="keep"}}
  rig.animation.animations=previous
  local incoming={same={name="new"},fresh={name="fresh"}}
  m.animations=incoming
  eq(f:replaceAnimation(rig,m,false),true)
  eq(rig.animation.animations.same,incoming.same)
  eq(rig.animation.animations.keep,previous.keep)
  eq(rig.animation.animations.fresh,incoming.fresh)
end)
test("replaceAnimation keeps Animation internal dictionary identity",function()
  local f,data,m,rig=construct()
  rig.animation.animations={before={}}
  local ref=rig.animation.animations
  m.animations={after={}}
  f:replaceAnimation(rig,m)
  eq(rig.animation.animations,ref)
  eq(rig.animation.animations.before,nil)
  eq(rig.animation.animations.after,m.animations.after)
end)
test("replaceAnimation updates animationNames on original Animation model",function()
  local f,data,m,rig=construct()
  m.animations={onlyOne={}}
  f:replaceAnimation(rig,m)
  eq(#rig.animation.animationNames,1)
  eq(rig.animation.animationNames[1],"onlyOne")
end)
test("replaceAnimation does not modify supplied source data map",function()
  local f,data,m,rig=construct()
  local template={walk={name="walk"}}
  m.animations=template
  f:replaceAnimation(rig,m,false)
  eq(template.walk.name,"walk")
  eq(template.before,nil)
end)
test("replaceAnimation recursively imports child Armature animation data",function()
  local raw=sampleRaw()
  raw.armature[1].skin[1].slot[1].display[1]={
    name="child",type="armature",path="child"
  }
  raw.armature[2]={name="child",bone={{name="root"}},
    skin={{name="default",slot={{name="body",display={{
      {name="child",type="armature",path="child"}
    }}}}}}
  local f,data,m,rig=construct(raw)
  -- Data path in DisplayData is its intrinsic name, not the factory alias.
  f:addDragonBonesData(data,"data")
  local child=rig:getSlot("body"):getDisplayFrameAt(0).display
  eq(getmetatable(child),Armature)
  local parentModel=data:getArmature("rig")
  local childModel=data:getArmature("child")
  childModel.animations={childWalk={name="childWalk"}}
  parentModel.animations={parentIdle={name="parentIdle"}}
  f:replaceAnimation(rig,parentModel)
  eq(rig.animation.animations.parentIdle,parentModel.animations.parentIdle)
  eq(child.animation.animations.childWalk,childModel.animations.childWalk)
end)
print(("Original BaseFactory replacements: %d passed, %d failed, %d assertions")
  :format(passed,failed,checks))
if failed>0 then os.exit(1) end
