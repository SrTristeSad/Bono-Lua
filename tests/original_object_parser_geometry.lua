-- ObjectDataParser.ts _parseGeometry / _parseArray, pinned commit
-- 64b6c69ae35777c2404be68c9192e2c56906079e.
-- Tests real parser and original GeometryData/WeightData, not mocks.
package.path="./?.lua;./?/init.lua;"..package.path
local Parser=require("dragonbones.original.parser.ObjectDataParser")
local Pool=require("dragonbones.original.core.BaseObject")
local Models=require("dragonbones.original.model.ArmatureData")
local Display=require("dragonbones.original.model.DisplayData")
local Core=require("dragonbones.original.core.DragonBones")
local pass,failed,assertions=0,0,0
local function eq(x,y)
  assertions=assertions+1
  assert(x==y,tostring(x).." ~= "..tostring(y))
end
local function near(x,y)
  assertions=assertions+1
  assert(type(x)=="number" and type(y)=="number"
    and math.abs(x-y)<1e-8,tostring(x).." ~= "..tostring(y))
end
local function test(name,fn)
  local ok,err=pcall(fn)
  if ok then pass=pass+1;print("ok original.parser_geometry "..name)
  else failed=failed+1
    print("not ok original.parser_geometry "..name..": "..tostring(err)) end
end
local function fixture()
  local p=Parser.new()
  local a=Pool.borrowObject(Models.ArmatureData)
  a.name="rig";a.scale=2
  p._data={name="db"}
  p._armature=a
  return p,a
end
local function geometry(p,raw)
  local g=Display.GeometryData.new()
  p:_parseGeometry(raw,g)
  return g
end
local function vertexBone(p,a,name)
  local b=Pool.borrowObject(Models.BoneData)
  b.name=name
  a:addBone(b)
  p._rawBones[#p._rawBones+1]=b
  return b
end
test("parseGeometry reads vertices, triangle count and indices",function()
  local p=fixture()
  local g=geometry(p,{vertices={1,2,3,4,5,6},triangles={0,1,2}})
  eq(g.offset,0);eq(g.data,p._data)
  eq(#p._intArray,7)
  eq(p._intArray[1],3)
  eq(p._intArray[2],1)
  eq(p._intArray[3],0)
  eq(p._intArray[4],-1)
  eq(p._intArray[5],0)
  eq(p._intArray[6],1)
  eq(p._intArray[7],2)
  eq(#p._floatArray,6)
  near(p._floatArray[5],5)
end)
test("parseGeometry stores packed UV pairs after coordinate pairs",function()
  local p=fixture()
  geometry(p,{vertices={1,2,3,4},uvs={0,0.5,1,0.75}})
  eq(#p._floatArray,8)
  near(p._floatArray[1],1)
  near(p._floatArray[5],0)
  near(p._floatArray[6],0.5)
  near(p._floatArray[7],1)
  near(p._floatArray[8],0.75)
end)
test("parseGeometry all channels produce exact binary buffer layout",function()
  local p=fixture()
  geometry(p,{vertices={0,2,4,6,8,10},
    triangles={0,1,2},uvs={0,0,1,0,1,1}})
  eq(#p._intArray,7)
  eq(#p._floatArray,12)
  eq(p._intArray[4],-1)
  near(p._floatArray[12],1)
end)
test("parseGeometry without triangles/uvs preserves unweighted sentinel",function()
  local p=fixture()
  local g=geometry(p,{vertices={1,2}})
  eq(g.offset,0);eq(g.weight,nil)
  eq(#p._intArray,4)
  eq(p._intArray[1],1)
  eq(p._intArray[2],0)
  eq(p._intArray[3],0)
  eq(p._intArray[4],-1)
end)
test("parseGeometry empty vertices creates only four reserved int cells",function()
  local p=fixture()
  geometry(p,{vertices={}})
  eq(#p._intArray,4)
  eq(#p._floatArray,0)
  eq(p._intArray[1],0)
end)
test("vertex and triangle lengths truncate incomplete trailing tuples",function()
  local p=fixture()
  geometry(p,{vertices={0,0,1},triangles={0,1,2,3}})
  eq(p._intArray[1],1)
  eq(p._intArray[2],1)
  eq(#p._intArray,7)
  eq(#p._floatArray,2)
end)
test("subsequent geometries carry original zero-based offsets",function()
  local p=fixture()
  local first=geometry(p,{vertices={1,2,3,4},triangles={0,0,1}})
  local second=geometry(p,{vertices={5,6}})
  eq(first.offset,0);eq(second.offset,7)
  eq(p._intArray[8],1)
  eq(p._intArray[9],0)
  eq(p._intArray[10],4)
  eq(p._intArray[11],-1)
  near(p._floatArray[5],5);near(p._floatArray[6],6)
end)
test("two appended UV geometries preserve float offsets",function()
  local p=fixture()
  geometry(p,{vertices={1,2},uvs={0.2,0.3}})
  geometry(p,{vertices={3,4},uvs={0.8,0.7}})
  eq(p._intArray[7],4)
  eq(#p._floatArray,8)
  near(p._floatArray[8],0.7)
end)
test("geometry offset/parent are actual GeometryData fields",function()
  local p=fixture()
  local g=geometry(p,{vertices={1,2}})
  eq(getmetatable(g),Display.GeometryData)
  eq(g.data,p._data)
  eq(g.isShared,nil)
end)
test("weighted BONE_POSE uses real WeightData and cached original bones",function()
  local p,a=fixture()
  local b=vertexBone(p,a,"root")
  local g=geometry(p,{
    vertices={1,2},weights={1,0,0.5},
    slotPose={1,0,0,1,0,0},
    bonePose={0,1,0,0,1,0,0}
  })
  eq(getmetatable(g.weight),Display.WeightData)
  eq(g.weight.count,1)
  eq(g.weight.offset,4)
  eq(g.weight.bones[1],b)
  eq(#g.weight.bones,1)
  eq(p._intArray[6],2)
  eq(p._intArray[7],0)
  eq(p._intArray[8],1)
  eq(p._intArray[9],0)
  near(p._floatArray[3],0.5)
  near(p._floatArray[4],1)
  near(p._floatArray[5],2)
end)
test("weighted vertex transform respects slot pose and inverse bone pose",function()
  local p,a=fixture()
  vertexBone(p,a,"root")
  geometry(p,{
    vertices={1,2},
    weights={1,0,0.8},
    slotPose={1,0,0,1,5,-2},
    bonePose={0,1,0,0,1,2,1}
  })
  near(p._floatArray[3],0.8)
  near(p._floatArray[4],4)
  near(p._floatArray[5],-1)
end)
test("two bones map raw indices to sortedBones positions",function()
  local p,a=fixture()
  local aBone=vertexBone(p,a,"a")
  local bBone=vertexBone(p,a,"b")
  a.sortedBones={bBone,aBone}
  local g=geometry(p,{
    vertices={3,4},
    weights={2,0,0.25,1,0.75},
    slotPose={1,0,0,1,0,0},
    bonePose={0,1,0,0,1,0,0,1,1,0,0,1,0,0}
  })
  eq(#g.weight.bones,2)
  eq(g.weight.bones[1],aBone)
  eq(g.weight.bones[2],bBone)
  eq(p._intArray[6],2)
  eq(p._intArray[7],1)
  eq(p._intArray[8],0)
  near(p._floatArray[3],0.25)
  near(p._floatArray[6],0.75)
end)
test("weighted geometry retains UV and vertex positions before weight float block",function()
  local p,a=fixture()
  vertexBone(p,a,"root")
  geometry(p,{
    vertices={1,2},uvs={0.3,0.6},
    weights={1,0,0.9},
    slotPose={1,0,0,1,0,0},
    bonePose={0,1,0,0,1,0,0}
  })
  eq(p._intArray[6],4)
  near(p._floatArray[3],0.3)
  near(p._floatArray[4],0.6)
  near(p._floatArray[5],0.9)
end)
test("weighted rawBones branch stores source vertex values and weights",function()
  local p,a=fixture()
  local b=vertexBone(p,a,"root")
  local g=geometry(p,{
    vertices={7,8},weights={1,0,0.6},bones={0}
  })
  eq(g.weight.bones[1],b)
  eq(g.weight.count,1)
  eq(p._intArray[6],0)
  eq(p._intArray[8],1)
  eq(p._intArray[9],0)
  near(p._floatArray[3],0.6)
  near(p._floatArray[4],7)
  near(p._floatArray[5],8)
end)
test("rawBones branch uses original source loop weightCount",function()
  local p,a=fixture()
  vertexBone(p,a,"root")
  geometry(p,{
    vertices={1,2,3,4},
    weights={1,0,0.2,1,0,0.75},bones={0}
  })
  near(p._floatArray[5],0.2)
  near(p._floatArray[8],0.75)
  eq(p._intArray[1],2)
end)
test("weighted repeated parsing appends correct geometry/weight offsets",function()
  local p,a=fixture()
  vertexBone(p,a,"root")
  local first=geometry(p,{vertices={1,2},weights={1,0,0.5},
    slotPose={1,0,0,1,0,0},bonePose={0,1,0,0,1,0,0}})
  local oldInt=#p._intArray
  local oldFloat=#p._floatArray
  local second=geometry(p,{vertices={3,4},weights={1,0,0.25},
    slotPose={1,0,0,1,0,0},bonePose={0,1,0,0,1,0,0}})
  eq(second.offset,oldInt)
  eq(second.weight.offset,oldInt+4)
  eq(p._intArray[oldInt+3],oldFloat)
  eq(first.weight.count,1)
end)
test("real surface model receives geometry and retains parent DragonBonesData",function()
  local p,a=fixture()
  local surface=p:_parseBone({type="surface",name="cloth",segmentX=2,segmentY=1,
    vertices={0,0,1,0,1,1,0,1},triangles={0,1,2,0,2,3}})
  eq(getmetatable(surface),Models.SurfaceData)
  eq(surface.geometry.offset,0)
  eq(surface.geometry.data,p._data)
  eq(p._intArray[1],4)
  eq(p._intArray[2],2)
end)
test("real mesh display parses its own geometry",function()
  local p=fixture()
  local mesh=p:_parseDisplay({type="mesh",name="body",
    vertices={0,0,2,0,2,3},triangles={0,1,2},uvs={0,0,1,0,1,1}})
  eq(getmetatable(mesh),Display.MeshDisplayData)
  eq(mesh.geometry.offset,0)
  eq(mesh.geometry.data,p._data)
  eq(p._intArray[2],1)
end)
test("real path display parses vertices with curve lengths",function()
  local p=fixture()
  local path=p:_parseDisplay({type="path",name="path",lengths={4,5},
    vertices={0,0,2,2,5,5}})
  eq(getmetatable(path),Display.PathDisplayData)
  eq(#path.curveLengths,2)
  eq(path.curveLengths[2],5)
  eq(p._intArray[1],3)
end)
test("shared mesh keeps deferred link without allocating geometry buffers",function()
  local p=fixture()
  local mesh=p:_parseDisplay({type="mesh",name="copy",share="source"})
  eq(#p._intArray,0)
  eq(#p._cacheRawMeshes,1)
  eq(mesh.geometry.data,p._data)
end)
test("parseArray clears seven original buffers preserving array identity",function()
  local p=fixture()
  local all={
    p._intArray,p._floatArray,p._frameIntArray,p._frameFloatArray,
    p._frameArray,p._timelineArray,p._colorArray
  }
  for i,a in ipairs(all) do a[1]=i;a[2]=i*2 end
  p:_parseArray({})
  for _,a in ipairs(all) do eq(#a,0) end
  eq(p._intArray,all[1])
  eq(p._floatArray,all[2])
  eq(p._colorArray,all[7])
end)
test("parseArray does not touch geometry pool or raw bones",function()
  local p,a=fixture()
  local b=vertexBone(p,a,"root")
  geometry(p,{vertices={1,2}})
  p:_parseArray(nil)
  eq(#p._intArray,0)
  eq(#p._floatArray,0)
  eq(p._rawBones[1],b)
end)
test("raw zero-based bone indices preserve lookup order, not name order",function()
  local p,a=fixture()
  local first=vertexBone(p,a,"z")
  local second=vertexBone(p,a,"a")
  geometry(p,{vertices={1,2},weights={1,1,0.2},
    slotPose={1,0,0,1,0,0},
    bonePose={1,1,0,0,1,0,0}})
  eq(p._intArray[6],2)
  eq(p._intArray[7],1)
  eq(first.name,"z");eq(second.name,"a")
end)
print(("Original ObjectDataParser geometry: %d passed, %d failed, %d assertions")
  :format(pass,failed,assertions))
if failed>0 then os.exit(1) end
