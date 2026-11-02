-- Execute original DragonBonesJS Transform fixtures on the real Lua port.
-- The upstream JS results are produced by the pinned compiled original
-- in a CI-only process. Product runtime/application/editor remain Lua.
package.path="./?.lua;./?/init.lua;"..package.path
local Transform=require("dragonbones.original.geom.Transform")
local Matrix=require("dragonbones.original.geom.Matrix")
local input=arg[1] or "tests/fixtures/transform_cases.tsv"
local expected=arg[2] or "artifacts/upstream/transform_expected.tsv"
local function tabs(line)
  local parts={}
  for piece in (line.."\t"):gmatch("(.-)\t") do parts[#parts+1]=piece end
  return parts
end
local function numbers(raw)
  local values={}
  for piece in raw:gmatch("[^,]+") do
    values[#values+1]=assert(tonumber(piece),"Bad fixture number: "..piece)
  end
  return values
end
local function makeTransform(raw)
  local a=numbers(raw)
  assert(#a==6,"Six Transform fields required")
  return Transform.new(a[1],a[2],a[3],a[4],a[5],a[6])
end
local function makeMatrix(raw)
  local a=numbers(raw)
  assert(#a==6,"Six Matrix fields required")
  return Matrix.new(a[1],a[2],a[3],a[4],a[5],a[6])
end
local function tFields(x)
  return {x.x,x.y,x.skew,x.rotation,x.scaleX,x.scaleY}
end
local function mFields(x)
  return {x.a,x.b,x.c,x.d,x.tx,x.ty}
end
local function compareNumber(actual,raw,name,i)
  local expectedValue
  if raw=="NaN" then
    assert(actual~=actual,"Expected NaN from original: "..name)
    return
  elseif raw=="Infinity" then expectedValue=math.huge
  elseif raw=="-Infinity" then expectedValue=-math.huge
  else expectedValue=assert(tonumber(raw),"Non-numeric expected value")
  end
  if actual==expectedValue then return end
  if math.abs(actual)==math.huge or math.abs(expectedValue)==math.huge then
    error(("Transform %s component %d: incorrect infinity"):format(name,i))
  end
  local scale=math.max(1,math.abs(expectedValue),math.abs(actual))
  assert(math.abs(expectedValue-actual)<=1e-10*scale,
    ("Transform %s component %d: Lua %.17g vs upstream %.17g")
      :format(name,i,actual,expectedValue))
end
local ref=assert(io.open(expected,"r"))
local checked=0
for line in io.lines(input) do
  if line~="" and line:sub(1,1)~="#" then
    local parts=tabs(line)
    local op,name,raw,other=parts[1],parts[2],parts[3],parts[4]
    local receiver,returned,output
    if op=="normalize" then
      returned=Transform.normalizeRadian(assert(tonumber(raw)))
      output={returned}
    else
      receiver=makeTransform(raw)
      if op=="toMatrix" then
        local dest=Matrix.new(9,8,7,6,5,4)
        returned=receiver:toMatrix(dest)
        output=mFields(dest)
      elseif op=="fromMatrix" then
        returned=receiver:fromMatrix(makeMatrix(other))
        output=tFields(receiver)
      elseif op=="add" then
        returned=receiver:add(makeTransform(other))
        output=tFields(receiver)
      elseif op=="minus" then
        returned=receiver:minus(makeTransform(other))
        output=tFields(receiver)
      elseif op=="copyFrom" then
        returned=receiver:copyFrom(makeTransform(other))
        output=tFields(receiver)
      elseif op=="identity" then
        returned=receiver:identity()
        output=tFields(receiver)
      else error("Unknown original Transform method "..tostring(op)) end
    end
    local compare=tabs(assert(ref:read("*l"),"Missing original output for "..name))
    assert(compare[1]==op and compare[2]==name,
      "Mismatched upstream case sequence: "..name)
    local ret=(op=="normalize" and "number" or returned==receiver and "self"
      or returned==nil and "void" or "unexpected")
    assert(ret==compare[3],
      ("Transform.%s return contract differs on %s"):format(op,name))
    assert(#output==#compare-3,"Wrong output arity: "..name)
    for i,value in ipairs(output) do
      compareNumber(value,compare[i+3],name,i)
    end
    checked=checked+1
  end
end
assert(ref:read("*l")==nil,"Extra upstream reference cases")
ref:close()
assert(checked==44,"Wrong fixture count: "..checked)
print(("Original DragonBonesJS Transform differential: %d passed, 0 failed"):format(checked))
