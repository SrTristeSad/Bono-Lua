-- Test the Lua BinaryDataParser._parseArray results against values from
-- the ACTUAL upstream pinned JavaScript method, executed separately in CI.
package.path="./?.lua;./?/init.lua;"..package.path
local Parser=require("dragonbones.original.parser.BinaryDataParser")
local input=arg[1] or "tests/fixtures/binary_typed_cases.tsv"
local expected=arg[2] or "artifacts/upstream/binary_typed_expected.tsv"
local keys={"intArray","floatArray","frameIntArray","frameFloatArray","frameArray","timelineArray","colorArray"}
local function split(s,sep)
  local t={}
  for v in (s..sep):gmatch("(.-)"..sep) do t[#t+1]=v end
  return t
end
local function bytes(hex)
  assert(#hex%2==0,"Odd-length binary")
  local out={}
  for i=1,#hex,2 do out[#out+1]=string.char(tonumber(hex:sub(i,i+1),16)) end
  return table.concat(out)
end
local function expectedNumber(raw,actual,case,key,i)
  if raw=="NaN" then
    assert(actual~=actual,("Expected NaN for %s/%s/%d"):format(case,key,i))
  elseif raw=="Infinity" then
    assert(actual==math.huge,"Expected infinity for "..case.."/"..key)
  elseif raw=="-Infinity" then
    assert(actual==-math.huge,"Expected negative infinity for "..case.."/"..key)
  elseif raw=="-0" then
    assert(actual==0 and 1/actual==-math.huge,"Expected -0 for "..case.."/"..key)
  else
    local n=assert(tonumber(raw),"Unknown upstream number "..raw)
    assert(type(actual)=="number","Missing view element "..case.."/"..key)
    local diff=math.abs(actual-n)
    local maxError=1e-7*math.max(1,math.abs(n),math.abs(actual))
    assert(diff<=maxError,
      ("BinaryDataParser %s %s[%d]: Lua %.17g vs JS %.17g")
      :format(case,key,i,actual,n))
  end
end
local ref=assert(io.open(expected,"r"))
local checked=0
for line in io.lines(input) do
  if line~="" and line:sub(1,1)~="#" then
    local fields=split(line,"\t")
    local name,start,offsets,raw=fields[1],fields[2],fields[3],fields[4]
    local n={}
    for value in offsets:gmatch("[^,]+") do n[#n+1]=assert(tonumber(value)) end
    local p=Parser.new()
    p._binary=bytes(raw)
    p._binaryOffset=assert(tonumber(start))
    p._data={}
    local success,err=pcall(function() p:_parseArray({offset=n}) end)
    local exp=split(assert(ref:read("*l"),"Missing original reference for "..name),"\t")
    assert(exp[1]==name,"Original case name/order mismatch: "..name)
    assert(success==(exp[2]=="ok"),("Expected %s for %s: %s"):format(exp[2],name,tostring(err)))
    if success then
      local data=p._data
      local alias=data.colorArray==data.intArray and "alias" or "independent"
      assert(alias==exp[3],"Original colorArray alias differs: "..name)
      for k,key in ipairs(keys) do
        local expectedArray=exp[k+3]~="" and split(exp[k+3],",") or {}
        local actual=data[key]
        assert(#actual==#expectedArray,
          ("Original %s %s: array length Lua %d vs JS %d")
            :format(name,key,#actual,#expectedArray))
        for i,value in ipairs(expectedArray) do
          expectedNumber(value,actual[i],name,key,i)
        end
      end
    end
    checked=checked+1
  end
end
assert(ref:read("*l")==nil,"Unexpected original reference cases")
ref:close()
assert(checked==32,"Incorrect fixture count "..checked)
print(("Original DragonBonesJS binary typed-array differential: %d passed, 0 failed"):format(checked))
