-- Conformance tests for original DragonBonesJS model files:
-- DisplayData.ts, SkinData.ts, DragonBonesData.ts at pinned commit.
package.path="./?.lua;./?/init.lua;"..package.path
local BaseObject=require("dragonbones.original.core.BaseObject")
local Core=require("dragonbones.original.core.DragonBones")
local Display=require("dragonbones.original.model.DisplayData")
local Skin=require("dragonbones.original.model.SkinData")
local DBData=require("dragonbones.original.model.DragonBonesData")
local User=require("dragonbones.original.model.UserData")
local tests,errors=0,0
local function test(label,func)
  tests=tests+1
  local success,err=pcall(func)
  if success then print("ok original.display_data "..label)
  else errors=errors+1;print("not ok original.display_data "..label..": "..tostring(err)) end
end
local function equal(actual,expected)
  assert(actual==expected,tostring(actual).." ~= "..tostring(expected))
end
local function borrow(Class)
  return BaseObject.borrowObject(Class)
end
local function isEmpty(t)
  return next(t)==nil
end

test("DisplayData.ts exports every original class",function()
  for _,name in ipairs({"GeometryData","DisplayData","ImageDisplayData","ArmatureDisplayData",
    "MeshDisplayData","BoundingBoxDisplayData","PathDisplayData","WeightData"}) do
    assert(type(Display[name])=="table",name)
  end
end)
test("All concrete DisplayData subclasses preserve class toString",function()
  for _,pair in ipairs({
    {"ImageDisplayData","[class dragonBones.ImageDisplayData]"},
    {"ArmatureDisplayData","[class dragonBones.ArmatureDisplayData]"},
    {"MeshDisplayData","[class dragonBones.MeshDisplayData]"},
    {"BoundingBoxDisplayData","[class dragonBones.BoundingBoxDisplayData]"},
    {"PathDisplayData","[class dragonBones.PathDisplayData]"},
    {"WeightData","[class dragonBones.WeightData]"}
  }) do equal(Display[pair[1]].toString(),pair[2]) end
end)
test("ImageDisplayData constructor initializes Transform and Point per instance",function()
  local a,b=borrow(Display.ImageDisplayData),borrow(Display.ImageDisplayData)
  assert(a.transform~=b.transform and a.pivot~=b.pivot)
  assert(a.type==Core.DisplayType.Image)
  equal(a.transform.scaleX,1)
  equal(a.pivot.x,0)
  a:returnToPool();b:returnToPool()
end)
test("ImageDisplayData _onClear preserves geometry identity, clears texture and parent",function()
  local image=borrow(Display.ImageDisplayData)
  local transform,pivot=image.transform,image.pivot
  image.name="face";image.path="faces/face";image.parent={}
  image.texture={};image.pivot.x=10;image.pivot.y=-3
  image.transform.x=9;image.transform.scaleX=4
  image:returnToPool()
  equal(image.name,"");equal(image.path,"")
  assert(image.parent==nil and image.texture==nil)
  assert(image.transform==transform and image.pivot==pivot)
  equal(image.transform.x,0);equal(image.transform.scaleX,1)
  equal(image.pivot.x,0);equal(image.pivot.y,0)
  equal(image.type,Core.DisplayType.Image)
end)
test("ArmatureDisplayData default fields and addAction exact behavior",function()
  local a=borrow(Display.ArmatureDisplayData)
  equal(a.type,Core.DisplayType.Armature)
  assert(a.inheritAnimation==false and a.armature==nil)
  local first,second=borrow(User.ActionData),borrow(User.ActionData)
  equal(a:addAction(first),nil)
  equal(a:addAction(second),nil)
  assert(a.actions[1]==first and a.actions[2]==second)
  a:returnToPool()
  assert(first._isInPool and second._isInPool)
end)
test("ArmatureDisplayData retains actions array instance and resets animation",function()
  local a=borrow(Display.ArmatureDisplayData)
  local actions=a.actions
  a.inheritAnimation=true;a.armature={};a.transform.skew=1
  a:addAction(borrow(User.ActionData))
  a:returnToPool()
  assert(a.actions==actions and #actions==0)
  assert(a.armature==nil and a.inheritAnimation==false)
  equal(a.transform.skew,0)
end)
test("GeometryData constructor retains unset source fields until cleared",function()
  local g=Display.GeometryData.new()
  assert(g.isShared==nil and g.inheritDeform==nil)
  assert(g.offset==nil and g.data==nil and g.weight==nil)
  assert(g:clear()==nil)
  assert(g.isShared==false and g.inheritDeform==false)
  assert(g.offset==0 and g.data==nil and g.weight==nil)
end)
test("WeightData constructor initializes own bones array and class identifier",function()
  local a,b=borrow(Display.WeightData),borrow(Display.WeightData)
  assert(a.bones~=b.bones and #a.bones==0 and #b.bones==0)
  equal(a.count,0);equal(a.offset,0)
  local bone={name="b"}
  assert(a:addBone(bone)==nil)
  assert(a.bones[1]==bone)
  a:returnToPool();b:returnToPool()
end)
test("WeightData _onClear keeps array identity and clears values",function()
  local w=borrow(Display.WeightData)
  local bones=w.bones
  w.count=9;w.offset=40;w:addBone({name="root"});w:addBone({name="tip"})
  w:returnToPool()
  assert(w.bones==bones and #bones==0)
  assert(w.count==0 and w.offset==0)
end)
test("GeometryData clear returns owned WeightData to BaseObject pool",function()
  local g=Display.GeometryData.new()
  local weight=borrow(Display.WeightData)
  g.weight=weight
  g.isShared=false
  assert(g:clear()==nil)
  assert(weight._isInPool and g.weight==nil and g.offset==0)
end)
test("GeometryData shared weight is not returned to pool on clear",function()
  local owner,shared=Display.GeometryData.new(),Display.GeometryData.new()
  local weight=borrow(Display.WeightData)
  owner.weight=weight;owner.offset=17;owner.isShared=false
  assert(shared:shareFrom(owner)==nil)
  assert(shared.isShared and shared.weight==weight and shared.offset==17)
  shared:clear()
  assert(not weight._isInPool)
  owner:clear()
  assert(weight._isInPool)
end)
test("GeometryData shareFrom does not overwrite data or inheritDeform",function()
  local a,b=Display.GeometryData.new(),Display.GeometryData.new()
  local marker={}
  b.data=marker;b.inheritDeform=true
  a.offset=3;a.weight=nil
  b:shareFrom(a)
  assert(b.data==marker and b.inheritDeform==true)
end)
test("GeometryData vertexCount and triangleCount read original binary offset",function()
  local g=Display.GeometryData.new()
  local data={intArray={91,7,3,100,101,102,103,104}}
  g.data=data;g.offset=1
  equal(g.vertexCount,7)
  equal(g.triangleCount,3)
end)
test("MeshDisplayData owns geometry and returns weight on reset",function()
  local m=borrow(Display.MeshDisplayData)
  local geometry=m.geometry
  equal(m.type,Core.DisplayType.Mesh)
  m.texture={}
  m.geometry.weight=borrow(Display.WeightData)
  m.geometry.isShared=false
  m.geometry.offset=4;m.geometry.data={}
  local weight=m.geometry.weight
  m:returnToPool()
  assert(m.geometry==geometry and m.texture==nil)
  assert(weight._isInPool and m.geometry.weight==nil)
  equal(m.geometry.offset,0)
end)
test("PathDisplayData initial defaults and _onClear preserve array",function()
  local p=borrow(Display.PathDisplayData)
  equal(p.type,Core.DisplayType.Path)
  assert(p.closed==false and p.constantSpeed==false)
  local lengths,geometry=p.curveLengths,p.geometry
  p.closed=true;p.constantSpeed=true
  p.curveLengths[1]=3;p.curveLengths[2]=6
  p.geometry.isShared=false;p.geometry.weight=borrow(Display.WeightData)
  local weight=p.geometry.weight
  p:returnToPool()
  assert(p.curveLengths==lengths and #lengths==0 and p.geometry==geometry)
  assert(not p.closed and not p.constantSpeed and weight._isInPool)
end)
test("BoundingBoxDisplayData releases owned BoundingBox object",function()
  local bbox=borrow(Display.BoundingBoxDisplayData)
  equal(bbox.type,Core.DisplayType.BoundingBox)
  local called=0
  local shape={returnToPool=function()called=called+1 end}
  bbox.boundingBox=shape
  bbox:returnToPool()
  equal(called,1)
  assert(bbox.boundingBox==nil)
end)
test("All display types preserve transform instance on pool borrow",function()
  local classes={Display.ImageDisplayData,Display.ArmatureDisplayData,
    Display.MeshDisplayData,Display.BoundingBoxDisplayData,Display.PathDisplayData}
  for _,Class in ipairs(classes) do
    local d=borrow(Class)
    local t=d.transform
    local code=d.hashCode
    d:returnToPool()
    local reused=borrow(Class)
    assert(reused==d and reused.transform==t and reused.hashCode==code)
    reused:returnToPool()
  end
end)

test("SkinData defaults and empty lookups preserve original nulls",function()
  local skin=borrow(Skin)
  equal(Skin.toString(),"[class dragonBones.SkinData]")
  equal(skin.name,"")
  assert(skin.parent==nil and isEmpty(skin.displays))
  assert(skin:getDisplay("missing","x")==nil)
  assert(skin:getDisplays("missing")==nil)
  skin:returnToPool()
end)
test("SkinData addDisplay preserves slot ordering and sets parent",function()
  local skin=borrow(Skin)
  local first=borrow(Display.ImageDisplayData)
  local second=borrow(Display.MeshDisplayData)
  first.name="face";second.name="eyes"
  assert(skin:addDisplay("head",first)==nil)
  skin:addDisplay("head",second)
  local displays=skin:getDisplays("head")
  assert(displays[1]==first and displays[2]==second)
  assert(first.parent==skin and second.parent==skin)
  assert(skin:getDisplay("head","face")==first)
  assert(skin:getDisplay("head","eyes")==second)
  assert(skin:getDisplay("head","nope")==nil)
  skin:returnToPool()
end)
test("SkinData preserves JS null display slots via Lua sentinel",function()
  local skin=borrow(Skin)
  local image=borrow(Display.ImageDisplayData)
  image.name="portrait"
  skin:addDisplay("portrait",nil)
  skin:addDisplay("portrait",image)
  local slot=skin:getDisplays("portrait")
  assert(#slot==2 and slot[1]==Skin.NULL and slot[2]==image)
  assert(skin:getDisplay("portrait","portrait")==image)
  skin:returnToPool()
  assert(image._isInPool)
end)
test("SkinData clear calls returnToPool for each non-null display",function()
  local skin=borrow(Skin)
  local first=borrow(Display.ImageDisplayData)
  local second=borrow(Display.MeshDisplayData)
  local mapping=skin.displays
  skin.name="default";skin.parent={}
  skin:addDisplay("one",first)
  skin:addDisplay("one",nil)
  skin:addDisplay("two",second)
  skin:returnToPool()
  assert(skin.displays==mapping and isEmpty(mapping))
  assert(skin.name=="" and skin.parent==nil)
  assert(first._isInPool and second._isInPool)
end)
test("SkinData accepts multiple slots independently",function()
  local skin=borrow(Skin)
  skin:addDisplay("a",nil)
  skin:addDisplay("b",nil)
  assert(skin:getDisplays("a")~=skin:getDisplays("b"))
  assert(#skin:getDisplays("a")==1 and #skin:getDisplays("b")==1)
  skin:returnToPool()
end)

test("DragonBonesData default fields and class name from original",function()
  local d=borrow(DBData)
  equal(DBData.toString(),"[class dragonBones.DragonBonesData]")
  assert(not d.autoSearch and d.frameRate==0 and d.version=="" and d.name=="")
  assert(d.stage==nil and d.userData==nil)
  assert(#d.frameIndices==0 and #d.cachedFrames==0 and #d.armatureNames==0)
  assert(isEmpty(d.armatures))
  for _,name in ipairs({"binary","intArray","floatArray","frameIntArray",
    "frameFloatArray","frameArray","timelineArray","colorArray"}) do
    assert(d[name]==nil,name)
  end
  d:returnToPool()
end)
test("DragonBonesData addArmature sets parent and name order",function()
  local d=borrow(DBData)
  local first={name="first"}
  local second={name="second"}
  assert(d:addArmature(first)==nil)
  d:addArmature(second)
  assert(first.parent==d and second.parent==d)
  assert(d.armatureNames[1]=="first" and d.armatureNames[2]=="second")
  assert(d:getArmature("first")==first and d:getArmature("second")==second)
  assert(d:getArmature("missing")==nil)
  -- Do not pool fake armatures: this test only checks insertion.
  d.armatures={};d:returnToPool()
end)
test("DragonBonesData duplicate name does not replace entry or reorder",function()
  local d=borrow(DBData)
  local first={name="identical"},other={name="identical"}
  d:addArmature(first);d:addArmature(other)
  assert(d:getArmature("identical")==first)
  assert(other.parent==nil)
  assert(#d.armatureNames==1)
  d.armatures={};d:returnToPool()
end)
test("DragonBonesData resets and releases nested UserData and armature",function()
  local d=borrow(DBData)
  local u=borrow(User.UserData)
  u:addInt(10)
  d.userData=u
  local calls=0
  local arm={name="nested",returnToPool=function()called=true;calls=calls+1 end}
  d:addArmature(arm)
  d.autoSearch=true;d.frameRate=60;d.version="5.7";d.name="project"
  d.stage=arm
  d.frameIndices[1]=1;d.cachedFrames[1]=2
  d.binary="bytes";d.intArray={1};d.floatArray={2};d.frameIntArray={3}
  d.frameFloatArray={4};d.frameArray={5};d.timelineArray={6};d.colorArray={7}
  local originalNames=d.armatureNames
  local originalFrames=d.frameIndices
  local originalCache=d.cachedFrames
  local originalMap=d.armatures
  d:returnToPool()
  equal(calls,1)
  assert(u._isInPool)
  assert(d.armatureNames==originalNames and #originalNames==0)
  assert(d.frameIndices==originalFrames and #originalFrames==0)
  assert(d.cachedFrames==originalCache and #originalCache==0)
  assert(d.armatures==originalMap and isEmpty(originalMap))
  assert(d.userData==nil and d.stage==nil and d.binary==nil)
  assert(d.intArray==nil and d.floatArray==nil and d.frameIntArray==nil)
  assert(d.frameFloatArray==nil and d.frameArray==nil and d.timelineArray==nil)
  assert(d.colorArray==nil)
  assert(not d.autoSearch and d.frameRate==0 and d.version=="" and d.name=="")
end)
test("DragonBonesData borrowed again preserves arrays and hashCode",function()
  local d=borrow(DBData)
  local names,frames,cache,mapping=d.armatureNames,d.frameIndices,d.cachedFrames,d.armatures
  local hash=d.hashCode
  d:returnToPool()
  local second=borrow(DBData)
  assert(second==d and second.hashCode==hash)
  assert(second.armatureNames==names and second.frameIndices==frames)
  assert(second.cachedFrames==cache and second.armatures==mapping)
  second:returnToPool()
end)

print(("Original display/skin/project data: %d passed, %d failed"):format(tests-errors,errors))
if errors>0 then os.exit(1) end
