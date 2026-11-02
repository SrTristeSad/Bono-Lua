-- Differential execution of the ORIGINAL DragonBonesJS Matrix.js and
-- dragonbones/original/geom/Matrix.lua against identical fixture inputs.
-- Upstream: DragonBones/DragonBonesJS commit
-- 64b6c69ae35777c2404be68c9192e2c56906079e, Matrix.ts.
-- The JS process is only a CI reference; Bono-Lua's product remains Lua.
package.path="./?.lua;./?/init.lua;"..package.path
local Matrix=require("dragonbones.original.geom.Matrix")
local input=arg[1] or "tests/fixtures/matrix_cases.tsv"
local expected=arg[2] or "artifacts/upstream/matrix_expected.tsv"
local function tabs(line)
  local result={}
  for item in (line.."\t"):gmatch("(.-)\t") do result[#result+1]=item end
  return result
end
local function nums(value)
  local result={}
  for item in value:gmatch("[^,]+") do
    local n=assert(tonumber(item),"Bad numeric fixture: "..item)
    result[#result+1]=n
  end
  return result
end
local function matrix(values)
  assert(#values==6,"Expected six matrix components")
  return Matrix.new(values[1],values[2],values[3],
    values[4],values[5],values[6])
end
local function fields(m)
  return {m.a,m.b,m.c,m.d,m.tx,m.ty}
end
local reference=assert(io.open(expected,"r"))
local checks=0
for line in io.lines(input) do
  if line~="" and line:sub(1,1)~="#" then
    local parts=tabs(line)
    local op,name,raw,other,option=parts[1],parts[2],parts[3],parts[4],parts[5]
    local values=nums(raw)
    local m,result,actual
    if op=="copyArray" then
      m=Matrix.new()
      -- Input arrays remain 1-based in Lua; offset is the source's zero-based offset.
      result=m:copyFromArray(values,tonumber(other))
      actual=fields(m)
    else
      m=matrix(values)
      if op=="concat" then
        result=m:concat(matrix(nums(other)))
        actual=fields(m)
      elseif op=="invert" then
        result=m:invert()
        actual=fields(m)
      elseif op=="point" then
        local p={x=0,y=0}
        local xy=nums(other)
        result=m:transformPoint(xy[1],xy[2],p,option=="true")
        actual={p.x,p.y}
      elseif op=="rect" then
        local r=nums(other)
        local rect={x=r[1],y=r[2],width=r[3],height=r[4]}
        result=m:transformRectangle(rect,option=="true")
        actual={rect.x,rect.y,rect.width,rect.height}
      elseif op=="identity" then
        result=m:identity()
        actual=fields(m)
      elseif op=="copyFrom" then
        result=m:copyFrom(matrix(nums(other)))
        actual=fields(m)
      else
        error("Unknown differential operation "..tostring(op))
      end
    end
    local referenceLine=assert(reference:read("*l"),
      "Missing original JS output for "..name)
    local compare=tabs(referenceLine)
    assert(compare[1]==op and compare[2]==name,
      "Different reference case order for "..name)
    local kind=result==m and "self" or result==nil and "void" or "other"
    assert(kind==compare[3],
      ("Matrix.%s return mismatch in %s: %s vs %s"):format(op,name,kind,compare[3]))
    assert(#actual==#compare-3,"Matrix output arity mismatch: "..name)
    for i,value in ipairs(actual) do
      local expectedValue=assert(tonumber(compare[i+3]),"Malformed upstream number")
      local diff=math.abs(value-expectedValue)
      local scale=math.max(1,math.abs(value),math.abs(expectedValue))
      assert(diff<=1e-10*scale,
        ("Matrix %s %s component %d: Lua %.17g != original JS %.17g")
          :format(op,name,i,value,expectedValue))
    end
    checks=checks+1
  end
end
assert(reference:read("*l")==nil,"Unexpected additional upstream cases")
reference:close()
assert(checks==22,("Expected 22 differential cases, got %d"):format(checks))
print(("Original DragonBonesJS Matrix differential: %d passed, 0 failed"):format(checks))
