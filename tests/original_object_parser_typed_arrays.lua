-- ObjectDataParser._modifyArray conformance against the original
-- DragonBonesJS source (commit 64b6c69ae35777c2404be68c9192e2c56906079e).
-- Original: DragonBones/src/dragonBones/parser/ObjectDataParser.ts 2215-2292.
-- Lua-only tests run under Lua 5.4 and LuaJIT. The result is a packed
-- little-endian byte string with seven views sharing one mutable Lua
-- byte-backed buffer; current bytes are exposed by DragonBonesData.binary.
package.path="./?.lua;./?/init.lua;"..package.path
local Parser=require("dragonbones.original.parser.ObjectDataParser")
local DBData=require("dragonbones.original.model.DragonBonesData")
local Pool=require("dragonbones.original.core.BaseObject")
local Geom=require("dragonbones.original.model.DisplayData")
local passed,failed,assertions=0,0,0
local function eq(a,b)
  assertions=assertions+1
  assert(a==b,tostring(a).." ~= "..tostring(b))
end
local function near(a,b,epsilon)
  assertions=assertions+1
  assert(type(a)=="number" and type(b)=="number" and math.abs(a-b)<(epsilon or 1e-7),
    tostring(a).." ~= "..tostring(b))
end
local function test(name,fn)
  local ok,err=pcall(fn)
  if ok then
    passed=passed+1
    print("ok original.typed_arrays "..name)
  else
    failed=failed+1
    print("not ok original.typed_arrays "..name..": "..tostring(err))
  end
end
local function fixture()
  local p=Parser.new()
  local data=Pool.borrowObject(DBData)
  p._data=data
  return p,data
end
local function fromBytes(...)
  return string.char(...)
end
local function hex(bytes)
  return (bytes:gsub(".",function(ch)
    return ("%02x"):format(string.byte(ch))
  end))
end
local function expectedHex(value)
  return value:gsub("%s+",""):lower()
end
local function checkHex(actual,expected)
  eq(hex(actual),expectedHex(expected))
end
test("empty source buffers produce empty byte string and seven empty views",function()
  local p,data=fixture()
  p._defaultColorOffset=7
  p:_modifyArray()
  eq(data.binary,"")
  eq(#data.binary,0)
  for _,key in ipairs({"intArray","floatArray","frameIntArray","frameFloatArray",
     "frameArray","timelineArray","colorArray"}) do
    eq(type(data[key])=="table" or type(data[key])=="userdata",true)
    eq(#data[key],0)
  end
  eq(p._defaultColorOffset,-1)
end)
test("the seven original typed segments use exact source order",function()
  local p,data=fixture()
  p._intArray={0x1234,-2}
  p._floatArray={1}
  p._frameIntArray={0x5678,-3}
  p._frameFloatArray={-2.5}
  p._frameArray={0x1234,-1}
  p._timelineArray={0xABCD,0x5678}
  p._colorArray={0x1111,-4}
  p:_modifyArray()
  checkHex(data.binary,"34 12 fe ff 00 00 80 3f 78 56 fd ff 00 00 20 c0 34 12 ff ff cd ab 78 56 11 11 fc ff")
  eq(#data.binary,28)
end)
test("Int16 values wrap modulo 65536 and retain signed interpretation",function()
  local p,data=fixture()
  p._intArray={32767,32768,-32768,-32769,65535,65536,-1.9,-65537}
  p:_modifyArray()
  checkHex(data.binary,"ff 7f 00 80 00 80 ff 7f ff ff 00 00 ff ff ff ff")
  local wanted={32767,-32768,-32768,32767,-1,0,-1,-1}
  for i,n in ipairs(wanted) do eq(data.intArray[i],n) end
end)
test("Uint16 values wrap and remain unsigned",function()
  local p,data=fixture()
  p._timelineArray={-1,-65537,65535,65536,32768,1.9}
  p:_modifyArray()
  checkHex(data.binary,"ff ff ff ff ff ff 00 00 00 80 01 00")
  local expected={65535,65535,65535,0,32768,1}
  for i,n in ipairs(expected) do eq(data.timelineArray[i],n) end
end)
test("source parser buffers remain original unquantized JS-style numbers",function()
  local p,data=fixture()
  p._intArray={65535,3}
  p._floatArray={0.1}
  p:_modifyArray()
  eq(p._intArray[1],65535)
  eq(p._floatArray[1],0.1)
  eq(data.intArray[1],-1)
  near(data.floatArray[1],0.10000000149011612,1e-16)
  assert(p._intArray~=data.intArray)
  assert(p._floatArray~=data.floatArray)
end)
test("odd intArray count is padded to an even number before packing",function()
  local p,data=fixture()
  p._intArray={0x1234}
  p:_modifyArray()
  eq(#p._intArray,2)
  eq(data.intArray[2],0)
  checkHex(data.binary,"34 12 00 00")
end)
test("odd frameIntArray, frameArray and timelineArray get distinct padding",function()
  local p,data=fixture()
  p._frameIntArray={0x100}
  p._frameArray={0x200}
  p._timelineArray={0x300}
  p:_modifyArray()
  eq(#p._frameIntArray,2)
  eq(#p._frameArray,2)
  eq(#p._timelineArray,2)
  checkHex(data.binary,"00 01 00 00 00 02 00 00 00 03 00 00")
end)
test("odd colorArray is left unpadded by the pinned source",function()
  local p,data=fixture()
  p._timelineArray={5}
  p._colorArray={1,2,3}
  p:_modifyArray()
  eq(#p._timelineArray,2)
  eq(#p._colorArray,3)
  eq(#data.colorArray,3)
  checkHex(data.binary,"05 00 00 00 01 00 02 00 03 00")
end)
test("alignment yields byte offsets consistent with source typed views",function()
  local p,data=fixture()
  p._intArray={1}
  p._floatArray={2}
  p._frameIntArray={3}
  p._frameFloatArray={4}
  p._frameArray={5}
  p._timelineArray={6}
  p._colorArray={7}
  p:_modifyArray()
  eq(#data.binary,4+4+4+4+4+4+2)
  checkHex(data.binary,"01 00 00 00 00 00 00 40 03 00 00 00 00 00 80 40 05 00 00 00 06 00 00 00 07 00")
end)
test("Float32 conversion rounds decimal 0.1 and negative 0.1 correctly",function()
  local p,data=fixture()
  p._floatArray={0.1,-0.1}
  p:_modifyArray()
  checkHex(data.binary,"cd cc cc 3d cd cc cc bd")
  near(data.floatArray[1],0.10000000149011612,1e-16)
  near(data.floatArray[2],-0.10000000149011612,1e-16)
end)
test("Float32 NaN is canonical quiet NaN and infinities preserve sign",function()
  local p,data=fixture()
  p._floatArray={0/0,math.huge,-math.huge}
  p:_modifyArray()
  checkHex(data.binary,"00 00 c0 7f 00 00 80 7f 00 00 80 ff")
  eq(data.floatArray[1]~=data.floatArray[1],true)
  eq(data.floatArray[2],math.huge)
  eq(data.floatArray[3],-math.huge)
end)
test("Float32 positive and negative zero retain distinct IEEE bits",function()
  local p,data=fixture()
  p._floatArray={0.0,-0.0}
  p:_modifyArray()
  checkHex(data.binary,"00 00 00 00 00 00 00 80")
  eq(1/data.floatArray[1],math.huge)
  eq(1/data.floatArray[2],-math.huge)
end)
test("Float32 smallest subnormal and half minimum preserve ties to even",function()
  local p,data=fixture()
  p._floatArray={2^-149,2^-150,3*2^-150,-2^-149}
  p:_modifyArray()
  checkHex(data.binary,"01 00 00 00 00 00 00 00 02 00 00 00 01 00 00 80")
end)
test("Float32 smallest normal and just below it have exact IEEE bits",function()
  local p,data=fixture()
  p._floatArray={2^-126,2^-126-2^-149}
  p:_modifyArray()
  checkHex(data.binary,"00 00 80 00 ff ff 7f 00")
end)
test("Float32 nearest-even rounds midpoint around 1 without bias",function()
  local p,data=fixture()
  p._floatArray={1+2^-24,1+3*2^-24,1+2^-23}
  p:_modifyArray()
  checkHex(data.binary,"00 00 80 3f 02 00 80 3f 01 00 80 3f")
end)
test("Float32 overflow to infinity follows the source typed array",function()
  local p,data=fixture()
  local max=(2-2^-23)*2^127
  p._floatArray={max,max+2^103,-max,-max-2^103}
  p:_modifyArray()
  checkHex(data.binary,"ff ff 7f 7f 00 00 80 7f ff ff 7f ff 00 00 80 ff")
end)
test("Float32 converts false and true to numeric 0 and 1",function()
  local p,data=fixture()
  p._floatArray={false,true}
  p:_modifyArray()
  checkHex(data.binary,"00 00 00 00 00 00 80 3f")
  eq(data.floatArray[1],0)
  eq(data.floatArray[2],1)
end)
test("float32 and int16 views do not overwrite adjacent binary data",function()
  local p,data=fixture()
  p._intArray={-1,2}
  p._floatArray={0.1}
  p._frameIntArray={3,4}
  p._frameFloatArray={-1}
  p._frameArray={5,6}
  p._timelineArray={65535,32768}
  p._colorArray={-2}
  p:_modifyArray()
  checkHex(data.binary,"ff ff 02 00 cd cc cc 3d 03 00 04 00 00 00 80 bf 05 00 06 00 ff ff 00 80 fe ff")
  eq(#data.intArray,2)
  eq(#data.floatArray,1)
  eq(#data.frameIntArray,2)
  eq(#data.frameFloatArray,1)
  eq(#data.frameArray,2)
  eq(#data.timelineArray,2)
  eq(#data.colorArray,1)
end)
test("from original raw geometry through finalize retains binary offsets",function()
  local p,data=fixture()
  local g=Geom.GeometryData.new()
  p:_parseGeometry({vertices={1,2,3,4,5,6},
    triangles={0,1,2},uvs={0,0,0.5,0.25,1,1}},g)
  p:_modifyArray()
  eq(g.offset,0)
  eq(g.data,data)
  eq(data.intArray[1],3)
  eq(data.intArray[2],1)
  eq(data.intArray[3],0)
  eq(data.intArray[4],-1)
  eq(data.intArray[5],0)
  eq(data.intArray[6],1)
  eq(data.intArray[7],2)
  eq(#data.intArray,8) -- original alignment pads the seven int cells.
  eq(#data.floatArray,12)
  eq(#data.binary,8*2+12*4)
  checkHex(data.binary:sub(1,16),
    "03 00 01 00 00 00 ff ff 00 00 01 00 02 00 00 00")
end)
test("finalizing after _parseArray uses newly cleared source buffers",function()
  local p,data=fixture()
  p._intArray={1,2}
  p:_modifyArray()
  local original=data.binary
  p:_parseArray({})
  p._intArray={3,4}
  p:_modifyArray()
  eq(original,fromBytes(1,0,2,0))
  eq(data.binary,fromBytes(3,0,4,0))
end)
test("mutating typed views updates shared ArrayBuffer bytes",function()
  local p,data=fixture()
  p._intArray={2,3}
  p:_modifyArray()
  local bytes=data.binary
  data.intArray[1]=9
  eq(bytes,fromBytes(2,0,3,0)) -- Lua's copied strings retain old bytes.
  eq(data.binary,fromBytes(9,0,3,0))
  eq(data.intArray[1],9)
  eq(p._intArray[1],2) -- Source JS parser staging array is separate.
end)
test("source fifth alignment condition is a no-op after timeline padding",function()
  local p,data=fixture()
  p._colorArray={15,16,17,18,19}
  p._timelineArray={1,2,3}
  p:_modifyArray()
  eq(#p._timelineArray,4)
  eq(#p._colorArray,5)
  eq(#data.colorArray,5)
end)
print(("Original ObjectDataParser _modifyArray: %d passed, %d failed, %d assertions")
  :format(passed,failed,assertions))
if failed>0 then os.exit(1) end
