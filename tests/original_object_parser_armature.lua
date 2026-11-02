-- Conformance coverage for ObjectDataParser.ts lines 285-472 and 2294-2353.
-- DragonBonesJS original commit 64b6c69ae35777c2404be68c9192e2c56906079e.
-- Tests only animation-free armatures: original _parseAnimation remains pending.
package.path="./?.lua;./?/init.lua;"..package.path
local Parser=require("dragonbones.original.parser.ObjectDataParser")
local Pool=require("dragonbones.original.core.BaseObject")
local Core=require("dragonbones.original.core.DragonBones")
local Models=require("dragonbones.original.model.ArmatureData")
local DBData=require("dragonbones.original.model.DragonBonesData")
local Displays=require("dragonbones.original.model.DisplayData")
local Json=require("dragonbones.json")
local passed,failed,checks=0,0,0
local function eq(a,b)
  checks=checks+1
  assert(a==b,tostring(a).." ~= "..tostring(b))
end
local function near(a,b)
  checks=checks+1
  assert(type(a)=="number" and type(b)=="number"
    and math.abs(a-b)<1e-8,tostring(a).." ~= "..tostring(b))
end
local function test(name,fn)
  local ok,err=pcall(fn)
  if ok then passed=passed+1;print("ok original.parser_armature "..name)
  else failed=failed+1;print("not ok original.parser_armature "..name..": "..tostring(err)) end
end
local function parse(raw,scale)
  return Parser.new():parseDragonBonesData(raw,scale)
end
local function mainRaw(armatures)
  return {version="5.5",name="DB",frameRate=24,armature=armatures}
end
local function bone(name,parent)
  return {name=name,parent=parent}
end
local function readFixture()
  local f=assert(io.open("tests/fixtures/personagem-minimo.json","rb"))
  local raw=Json.decode(f:read("*a"));f:close()
  return raw
end

test("supported 5.5 version allocates original DragonBonesData",function()
  local data=parse(mainRaw({}))
  eq(getmetatable(data),DBData)
  eq(data.version,"5.5");eq(data.name,"DB")
  eq(data.frameRate,24)
  eq(data.binary,"")
  eq(#data.armatureNames,0)
  eq(data.stage,nil)
end)
test("missing armature key leaves binary nil per original",function()
  local data=parse({version="5.6",name="alone"})
  eq(data.version,"5.6")
  eq(data.binary,nil)
  eq(data.intArray,nil)
  eq(data.stage,nil)
end)
test("unsupported source version returns nil instead of a fake rig",function()
  local p=Parser.new()
  local data=p:parseDragonBonesData({version="1.0",armature={{name="A"}}})
  eq(data,nil)
  eq(p._data,nil)
end)
test("supported compatibleVersion accepted with independent original version",function()
  local data=parse({version="vendor",compatibleVersion="5.5",armature={}})
  eq(data.version,"vendor")
  eq(data.binary,"")
end)
test("frameRate zero becomes 24 as in source",function()
  local data=parse({version="5.6",frameRate=0,
    armature={{name="A",frameRate=0}}})
  eq(data.frameRate,24)
  eq(data:getArmature("A").frameRate,24)
end)
test("one armature is added to names and selected stage automatically",function()
  local data=parse(mainRaw({{name="hero"}}))
  eq(#data.armatureNames,1)
  eq(data.armatureNames[1],"hero")
  eq(data.stage,data:getArmature("hero"))
  eq(data:getArmature("hero").parent,data)
end)
test("explicit stage selects second armature without changing name order",function()
  local raw=mainRaw({{name="first"},{name="second"}})
  raw.stage="second"
  local data=parse(raw)
  eq(data.stage,data:getArmature("second"))
  eq(data.armatureNames[1],"first")
  eq(data.armatureNames[2],"second")
end)
test("unknown explicit stage does not silently fall back to first",function()
  local raw=mainRaw({{name="first"}})
  raw.stage="missing"
  eq(parse(raw).stage,nil)
end)
test("armature scale and frameRate inherited or overridden",function()
  local raw=mainRaw({{name="one"},{name="two",frameRate=15}})
  raw.frameRate=30
  local data=parse(raw,2.5)
  local first=data:getArmature("one")
  local second=data:getArmature("two")
  eq(first.frameRate,30);eq(second.frameRate,15)
  near(first.scale,2.5)
  near(second.scale,2.5)
end)
test("numeric and textual armature type follow original type converters",function()
  local raw=mainRaw({
    {name="simple",type="armature"},
    {name="stage",type="stage"},
    {name="movie",type=Core.ArmatureType.MovieClip}
  })
  local data=parse(raw)
  eq(data:getArmature("simple").type,Core.ArmatureType.Armature)
  eq(data:getArmature("stage").type,Core.ArmatureType.Stage)
  eq(data:getArmature("movie").type,Core.ArmatureType.MovieClip)
end)
test("canvas maps background flag, color and scaled coordinates",function()
  local raw=mainRaw({{
    name="A",canvas={color=0xAA55BB,x=3,y=-2,width=100,height=50}
  }})
  local a=parse(raw,2):getArmature("A")
  eq(a.canvas.hasBackground,true);eq(a.canvas.color,0xAA55BB)
  near(a.canvas.x,6);near(a.canvas.y,-4)
  near(a.canvas.width,200);near(a.canvas.height,100)
end)
test("canvas without color retains false background flag",function()
  local raw=mainRaw({{name="A",canvas={width=10}}})
  local canvas=parse(raw):getArmature("A").canvas
  eq(canvas.hasBackground,false)
  eq(canvas.color,0)
end)
test("aabb is scaled but no canvas is allocated unless supplied",function()
  local a=parse(mainRaw({{
    name="A",aabb={x=-3,y=4,width=20,height=30}
  }}),3):getArmature("A")
  eq(a.canvas,nil)
  near(a.aabb.x,-9);near(a.aabb.y,12)
  near(a.aabb.width,60);near(a.aabb.height,90)
end)
test("bone hierarchy follows parents already processed",function()
  local a=parse(mainRaw({{name="A",bone={
    bone("root"),bone("middle","root"),bone("leaf","middle")
  }}})):getArmature("A")
  eq(#a.sortedBones,3)
  eq(a:getBone("middle").parent,a:getBone("root"))
  eq(a:getBone("leaf").parent,a:getBone("middle"))
end)
test("forward references to future bones resolve using _cacheBones",function()
  local a=parse(mainRaw({{name="A",bone={
    bone("grandchild","child"),bone("child","parent"),bone("parent")
  }}})):getArmature("A")
  eq(a:getBone("grandchild").parent,a:getBone("child"))
  eq(a:getBone("child").parent,a:getBone("parent"))
  eq(a.sortedBones[1].name,"parent")
  eq(a.sortedBones[2].name,"child")
  eq(a.sortedBones[3].name,"grandchild")
end)
test("unresolved parent leaves bone without parent and clears pending cache",function()
  local p=Parser.new()
  local data=p:parseDragonBonesData(mainRaw({{name="A",bone={
    bone("stray","unknown")
  }}}))
  eq(data:getArmature("A"):getBone("stray").parent,nil)
  eq(next(p._cacheBones),nil)
end)
test("IK constraints resolve after all bones and sort before slots",function()
  local raw=mainRaw({{name="A",
    bone={bone("root"),bone("hand","root"),bone("target")},
    ik={{name="follow",bone="hand",target="target",chain=1}}
  }})
  local a=parse(raw):getArmature("A")
  local ik=a:getConstraint("follow")
  eq(ik.type,Core.ConstraintType.IK)
  eq(ik.root,a:getBone("root"))
  eq(ik.bone,a:getBone("hand"))
  eq(ik.target,a:getBone("target"))
end)
test("unknown IK target silently skips original invalid constraint",function()
  local a=parse(mainRaw({{name="A",bone={bone("root")},
    ik={{name="bad",bone="root",target="missing"}}}})):getArmature("A")
  eq(a:getConstraint("bad"),nil)
end)
test("slot zOrder follows its index in source order",function()
  local a=parse(mainRaw({{name="A",bone={bone("root")},
    slot={{name="first",parent="root"},{name="second",parent="root"}}}}))
    :getArmature("A")
  eq(a:getSlot("first").zOrder,0)
  eq(a:getSlot("second").zOrder,1)
  eq(a:getSlot("second").parent,a:getBone("root"))
end)
test("skin binds display to real slot and image display geometry",function()
  local a=parse(mainRaw({{name="A",bone={bone("root")},
    slot={{name="body",parent="root"}},skin={{name="default",slot={{
      name="body",display={{name="face",type="image",pivot={x=0.3,y=0.6}}}
    }}}}})):getArmature("A")
  local skin=a.defaultSkin
  eq(skin.name,"default")
  local display=skin:getDisplay("body","face")
  eq(getmetatable(display),Displays.ImageDisplayData)
  near(display.pivot.x,0.3)
  eq(display.parent,skin)
end)
test("mesh geometry reaches finalized int/float binary views",function()
  local a=parse(mainRaw({{name="A",bone={bone("root")},
    slot={{name="meshslot",parent="root"}},
    skin={{name="default",slot={{
      name="meshslot",display={{name="mesh",type="mesh",
        vertices={0,0,4,0,4,2},triangles={0,1,2},
        uvs={0,0,1,0,1,1}
      }}
    }}}}}))
  local model=a:getArmature("A")
  local mesh=model.defaultSkin:getDisplay("meshslot","mesh")
  eq(getmetatable(mesh),Displays.MeshDisplayData)
  eq(mesh.geometry.offset,0)
  eq(mesh.geometry.data,a)
  eq(a.intArray[1],3)
  eq(a.intArray[2],1)
  eq(#a.floatArray,12)
  eq(#a.binary,8*2+12*4)
end)
test("action and defaultActions are stored in separate real model arrays",function()
  local raw=mainRaw({{name="A",
    defaultActions="idle",actions="hit"
  }})
  local a=parse(raw):getArmature("A")
  eq(#a.defaultActions,1)
  eq(#a.actions,1)
  eq(a.defaultActions[1].name,"idle")
  eq(a.actions[1].name,"hit")
  eq(a.defaultAnimation,nil) -- Missing _parseAnimation is not faked.
end)
test("textures embedded in top-level skeleton are queued for later atlas parse",function()
  local p=Parser.new()
  local raw=mainRaw({})
  raw.textureAtlas={{name="first"},{name="second"}}
  local data=p:parseDragonBonesData(raw)
  eq(data.name,"DB")
  eq(#p._rawTextureAtlases,2)
  eq(p._rawTextureAtlasIndex,0)
end)
test("parser clears helper arrays and current armature after success",function()
  local p=Parser.new()
  local raw=mainRaw({{
    name="A",bone={bone("root")},
    slot={{name="body",parent="root",actions="run"}},
    skin={{name="default",slot={{name="body",display={{name="image"}}}}}}
  }})
  local data=p:parseDragonBonesData(raw)
  eq(data:getArmature("A").name,"A")
  eq(p._armature,nil)
  eq(p._data,nil)
  eq(#p._rawBones,0)
  eq(#p._cacheRawMeshes,0)
  eq(#p._cacheMeshes,0)
  eq(next(p._cacheBones),nil)
  eq(next(p._slotChildActions),nil)
end)
test("parser object can be reused for multiple armatures and then another document",function()
  local p=Parser.new()
  local first=p:parseDragonBonesData(mainRaw({
    {name="A",bone={bone("root")}},
    {name="B",bone={bone("other")}}
  }))
  eq(#first.armatureNames,2)
  local second=p:parseDragonBonesData(mainRaw({{name="C"}}))
  eq(#second.armatureNames,1)
  eq(second:getArmature("A"),nil)
  eq(second:getArmature("C").name,"C")
end)
test("fixture with animation removed uses real parser for all remaining objects",function()
  local raw=readFixture()
  raw.armature[1].animation=nil
  local data=parse(raw)
  eq(data.name,"BonoFixture")
  local a=data:getArmature("PersonagemA")
  eq(#a.sortedBones,3)
  eq(#a.sortedSlots,2)
  eq(a:getBone("forearm").parent,a:getBone("upperArm"))
  eq(a.defaultSkin:getDisplay("forearm","forearm").name,"forearm")
  eq(data.stage,a)
end)
test("original animation collection is not silently dropped without _parseAnimation",function()
  local p=Parser.new()
  local raw=readFixture()
  eq(p._parseAnimation,nil)
  local ok,err=pcall(function() return p:parseDragonBonesData(raw) end)
  eq(ok,false)
  eq(type(err),"string")
  eq(p._armature~=nil,true)
end)
test("raw data version invalid is rejected even with empty armatures",function()
  eq(parse({version="2029",name="invalid",armature={}}),nil)
end)

print(("Original ObjectDataParser armature entry: %d passed, %d failed, %d assertions")
  :format(passed,failed,checks))
if failed>0 then os.exit(1) end
