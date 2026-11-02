-- Test BoundingBoxData Lua ports against direct execution of
-- DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e.
package.path="./?.lua;./?/init.lua;"..package.path
local Bounds=require("dragonbones.original.model.BoundingBoxData")
local classes={rect=Bounds.RectangleBoundingBoxData,
  ellipse=Bounds.EllipseBoundingBoxData,polygon=Bounds.PolygonBoundingBoxData}
local fixture=arg[1] or "tests/fixtures/boundingbox_cases.tsv"
local expected=arg[2] or "artifacts/upstream/boundingbox_expected.tsv"
local function split(s,sep)
  local t={}
  for p in (s..sep):gmatch("(.-)"..sep) do t[#t+1]=p end
  return t
end
local function numbers(s)
  local out={}
  for p in s:gmatch("[^,]+") do out[#out+1]=assert(tonumber(p),"Invalid fixture number "..p) end
  return out
end
local function fields(op,flags)
  if op=="point" then return {} end
  local a=flags=="all" or flags=="pointA" or flags=="pointA_normals"
  local b=flags=="all" or flags=="pointB" or flags=="pointB_normals"
  local n=flags=="all" or flags=="normals" or flags=="pointA_normals" or flags=="pointB_normals"
  return a and {x=901.25,y=902.5} or nil,
    b and {x=903.25,y=904.5} or nil,
    n and {x=905.25,y=906.5} or nil
end
local function compare(actual,raw,name,field)
  if raw=="NaN" then assert(actual~=actual,name.." "..field.." must be NaN");return end
  if raw=="Infinity" then assert(actual==math.huge,name.." "..field.." must be +Infinity");return end
  if raw=="-Infinity" then assert(actual==-math.huge,name.." "..field.." must be -Infinity");return end
  if raw=="undefined" then assert(actual==nil,name.." "..field.." must be undefined");return end
  local reference=assert(tonumber(raw),"Invalid reference "..raw)
  assert(type(actual)=="number",name.." "..field.." missing")
  if actual==reference then return end
  local tolerance=1e-9*math.max(1,math.abs(reference),math.abs(actual))
  assert(math.abs(actual-reference)<=tolerance,
    ("%s %s: Lua %.17g vs original %.17g"):format(name,field,actual,reference))
end
local reference=assert(io.open(expected,"r"))
local total=0
for line in io.lines(fixture) do
  if line~="" and line:sub(1,1)~="#" then
    local columns=split(line,"\t")
    local op,shape,name,geo,rawCoords,flags=
      columns[1],columns[2],columns[3],columns[4],columns[5],columns[6]
    local klass=assert(classes[shape],"Invalid shape "..tostring(shape))
    local bounds=klass.new()
    local dims=split(geo,";")
    local header=numbers(dims[1])
    if shape=="polygon" then
      bounds.x,bounds.y,bounds.width,bounds.height=header[1],header[2],header[3],header[4]
      bounds.vertices=numbers(dims[2])
    else bounds.width,bounds.height=header[1],header[2] end
    local args=numbers(rawCoords)
    local result={}
    if op=="point" then
      result[1]=bounds:containsPoint(args[1],args[2]) and "true" or "false"
    elseif op=="segment" then
      local a,b,n=fields(op,flags)
      local count=bounds:intersectsSegment(args[1],args[2],args[3],args[4],a,b,n)
      result[1]=count
      if a then result[#result+1]=a.x;result[#result+1]=a.y end
      if b then result[#result+1]=b.x;result[#result+1]=b.y end
      if n then result[#result+1]=n.x;result[#result+1]=n.y end
    else error("Unknown operation "..tostring(op)) end
    local ref=split(assert(reference:read("*l"),"Missing original case "..name),"\t")
    assert(ref[1]==name,"Reference ordering mismatch "..name)
    assert(#result==#ref-1,"Original field count mismatch "..name)
    for i,value in ipairs(result) do
      if op=="point" then assert(value==ref[i+1],"Original containsPoint mismatch: "..name)
      else compare(value,ref[i+1],name,"field"..i) end
    end
    total=total+1
  end
end
assert(reference:read("*l")==nil,"Unexpected reference cases")
reference:close()
assert(total==62,"Incorrect differential case count "..total)
print(("Original DragonBonesJS BoundingBoxData differential: %d passed, 0 failed"):format(total))
