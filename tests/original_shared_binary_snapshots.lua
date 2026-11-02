-- SharedBinaryBuffer Lua transport snapshot cache regression.
-- Original source semantics: DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e
-- Int16Array/Uint16Array/Float32Array share one mutable ArrayBuffer.
-- Lua binary reads materialize immutable strings with current bytes.
package.path="./?.lua;./?/init.lua;"..package.path
local Shared=require("dragonbones.original.parser.SharedBinaryBuffer")
local passed=0
local function test(name,fn)
  local ok,err=pcall(fn)
  assert(ok,"Shared binary snapshots "..name.." failed: "..tostring(err))
  passed=passed+1
  print("ok original.binary_snapshot "..name)
end

test("unchanged binary snapshot avoids allocation and keeps exact bytes",function()
  local base=string.rep("A",8192)
  local buffer=Shared.new(base)
  assert(buffer:bytes()==base and buffer:bytes()==base)
  assert(buffer._snapshot==base)
end)
test("modified bytes remain live to overlapping Int16 Uint16 Float32 views",function()
  local buffer=Shared.new(string.char(0,0,128,63))
  local signed=Shared.view(buffer,0,4,"int16")
  local unsigned=Shared.view(buffer,0,4,"uint16")
  local floats=Shared.view(buffer,0,4,"float32")
  local immutable=buffer:bytes()
  assert(floats[1]==1)
  signed[2]=16384
  assert(floats[1]==2)
  assert(unsigned[2]==16384)
  assert(buffer:bytes()==string.char(0,0,0,64))
  assert(immutable==string.char(0,0,128,63))
  local materialized=buffer:bytes()
  assert(buffer._snapshot==materialized)
  floats[1]=0.5
  assert(buffer._snapshot==nil)
  assert(buffer:bytes()==string.char(0,0,0,63))
  assert(signed[2]==16128 and unsigned[2]==16128)
end)
test("large sparse byte writes never corrupt untouched spans or edges",function()
  local buffer=Shared.new(string.rep("x",16000))
  local first=Shared.view(buffer,0,2,"uint16")
  local last=Shared.view(buffer,15998,2,"int16")
  local initial=buffer:bytes()
  first[1]=0x1234
  last[1]=-2
  local encoded=buffer:bytes()
  assert(#encoded==16000)
  assert(encoded:sub(1,2)==string.char(0x34,0x12))
  assert(encoded:sub(3,15998)==string.rep("x",15996))
  assert(encoded:sub(15999)==string.char(0xfe,0xff))
  assert(initial==string.rep("x",16000))
  assert(buffer:bytes()==encoded)
  first[1]=0xABCD
  assert(buffer:bytes():sub(1,2)==string.char(0xCD,0xAB))
  assert(buffer:bytes():sub(15999)==string.char(0xfe,0xff))
end)
print(("Shared original binary snapshots: %d passed, 0 failed"):format(passed))
