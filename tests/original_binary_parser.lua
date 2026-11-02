-- Original BinaryDataParser.ts, pinned DragonBonesJS
-- 64b6c69ae35777c2404be68c9192e2c56906079e (MIT).
-- Independent DBDT byte fixtures exercise the complete binary entry point.
package.path="./?.lua;./?/init.lua;"..package.path
local Binary=require("dragonbones.original.parser.BinaryDataParser")
local Original=require("dragonbones.original.parser.ObjectDataParser")
local Pool=require("dragonbones.original.core.BaseObject")
local DB=require("dragonbones.original.model.DragonBonesData")
local Animation=require("dragonbones.original.model.AnimationData")
local Display=require("dragonbones.original.model.DisplayData")
local Core=require("dragonbones.original.core.DragonBones")
local TT=Core.TimelineType
local passed,failed,checks=0,0,0
local function eq(a,b)
  checks=checks+1
  assert(a==b,tostring(a).." ~= "..tostring(b))
end
local function near(a,b)
  checks=checks+1
  assert(type(a)=="number" and type(b)=="number"
    and math.abs(a-b)<1e-7,tostring(a).." ~= "..tostring(b))
end
local function test(name,fn)
  local ok,err=pcall(fn)
  if ok then passed=passed+1;print("ok original.binary_parser "..name)
  else failed=failed+1;print("not ok original.binary_parser "..name..": "..tostring(err)) end
end
local function pack16(n)
  n=n%65536
  return string.char(n%256,math.floor(n/256))
end
local function bytes16(array)
  local buf={}
  for i,n in ipairs(array) do buf[i]=pack16(n) end
  return table.concat(buf)
end
local function bytes32(array)
  local buf={}
  for _,n in ipairs(array) do
    local a
    if n==0 then a=string.char(0,0,0,0)
    elseif n==1 then a=string.char(0,0,128,63)
    elseif n==0.5 then a=string.char(0,0,0,63)
    elseif n==-2 then a=string.char(0,0,0,192)
    elseif n==math.huge then a=string.char(0,0,128,127)
    else error("test float fixture unsupported: "..tostring(n)) end
    buf[#buf+1]=a
  end
  return table.concat(buf)
end
local function u32(n)
  return string.char(n%256,math.floor(n/256)%256,
    math.floor(n/65536)%256,math.floor(n/16777216)%256)
end
local function encodeOffsets(parts)
  local cursor,offsets=0,{}
  for i=1,7 do
    local value=parts[i] or ""
    offsets[#offsets+1]=cursor
    offsets[#offsets+1]=#value
    cursor=cursor+#value
  end
  return offsets
end
local function jsonOffsets(parts)
  return table.concat(encodeOffsets(parts),",")
end
local function binary(header,parts)
  parts=parts or {}
  local h=header:gsub("OFFSET_MARKER",jsonOffsets(parts))
  -- The JS ArrayBuffer typed views require 4-byte alignment for Float32.
  h=h..string.rep(" ",(4-#h%4)%4)
  local content=table.concat(parts)
  return "DBDT"..string.rep("\0",4)..u32(#h)..h..content
end
local function simpleHeader(extra)
  return '{"version":"5.5","name":"BinaryFixture","frameRate":24,'..
    '"offset":[OFFSET_MARKER],"armature":[{"name":"rig","bone":[{"name":"root"},{"name":"target"}]'..
    (extra or '')..'}]}'
end
local function fixture(extra,parts)
  return binary(simpleHeader(extra),parts)
end
local function parts(ints,floats,frameInts,frameFloats,frames,timelines,colors)
  return {
    bytes16(ints or {}),bytes32(floats or {}),bytes16(frameInts or {}),
    bytes32(frameFloats or {}),bytes16(frames or {}),
    bytes16(timelines or {}),bytes16(colors or {})
  }
end

test("constructor retains concrete original class and inherits base parser",function()
  local p=Binary.new()
  eq(getmetatable(p),Binary)
  eq(type(p._parseArmature),"function")
  eq(type(p._parseGeometry),"function")
  eq(p._binaryOffset,0)
end)
test("singleton identity uses BinaryDataParser-specific cache",function()
  eq(Binary.getInstance(),Binary.getInstance())
  eq(Binary.getInstance()~=Original.getInstance(),true)
end)
test("inRange is inclusive at both boundaries",function()
  local p=Binary.new()
  eq(p:_inRange(3,3,5),true)
  eq(p:_inRange(5,3,5),true)
  eq(p:_inRange(6,3,5),false)
end)
test("source UTF8 decoder returns original ASCII bytes and strips NUL",function()
  local p=Binary.new()
  eq(p:_decodeUTF8("Dragon\0Bones"),"DragonBones")
  eq(p:_decodeUTF8({65,66,67}),"ABC")
end)
test("source UTF8 decoder preserves multibyte Latin, accents and emoji",function()
  local p=Binary.new()
  local s="Coração 😀"
  eq(p:_decodeUTF8(s),s)
end)
test("invalid leading UTF8 is dropped as in upstream implementation",function()
  local p=Binary.new()
  eq(p:_decodeUTF8(string.char(0x80,0xc1).."A"),"A")
end)
test("invalid partial UTF8 continuation is reprocessed by source algorithm",function()
  local p=Binary.new()
  eq(p:_decodeUTF8(string.char(0xc2).."A"),"AA")
end)
test("truncated UTF8 sequence is ignored in pinned source",function()
  local p=Binary.new()
  eq(p:_decodeUTF8(string.char(0xe2,0x82)),"")
end)
test("reject invalid DBDT magic without constructing data",function()
  local p=Binary.new()
  eq(p:parseDragonBonesData("BADC"..string.rep("\0",12)),nil)
end)
test("reject invalid input Lua table (ArrayBuffer equivalent must be bytes)",function()
  local p=Binary.new()
  eq(pcall(function() p:parseDragonBonesData({}) end),false)
end)
test("reject truncated length field and truncated JSON payload",function()
  local p=Binary.new()
  eq(pcall(function() p:parseDragonBonesData("DBDT") end),false)
  eq(pcall(function() p:parseDragonBonesData("DBDT"..
    string.rep("\0",4)..u32(30).."{}") end),false)
end)
test("empty DBDT skeleton decodes with original data model and stage",function()
  local raw=fixture()
  local model=Binary.new():parseDragonBonesData(raw)
  eq(getmetatable(model),DB)
  eq(model.name,"BinaryFixture")
  eq(model.binary,raw)
  eq(model.stage,model:getArmature("rig"))
  eq(model:getArmature("rig").name,"rig")
  eq(#model.armatureNames,1)
end)
test("typed array views retain exact signed unsigned float byte values",function()
  local raw=fixture(nil,parts({-1,32767,-32768,0},{0.5,-2},
    {65535,-32768},{1,math.huge},{0,6},{100,0,1,2,0,0},
    {50,-50}))
  local d=Binary.new():parseDragonBonesData(raw)
  eq(d.intArray[1],-1)
  eq(d.intArray[2],32767)
  eq(d.intArray[3],-32768)
  near(d.floatArray[1],0.5)
  near(d.floatArray[2],-2)
  eq(d.frameIntArray[1],-1)
  eq(d.frameIntArray[2],-32768)
  eq(d.frameFloatArray[1],1)
  eq(d.frameFloatArray[2],math.huge)
  eq(d.frameArray[2],6)
  eq(d.timelineArray[1],100)
  eq(d.colorArray[1],50)
  eq(d.colorArray[2],-50)
end)
test("color array aliases intArray when header has zero color length",function()
  local d=Binary.new():parseDragonBonesData(fixture(nil,parts({11,12})))
  eq(d.colorArray,d.intArray)
end)
test("independent color array does not alias integer view",function()
  local d=Binary.new():parseDragonBonesData(
    fixture(nil,parts({11,12},{},{},{},{},{},{22})))
  eq(d.colorArray[1],22)
  eq(d.intArray[1],11)
  eq(d.colorArray~=d.intArray,true)
end)
test("typed arrays use full DBDT payload-relative offset positions",function()
  local raw=fixture(nil,parts({5,7},{1},{-3,0},{0.5},{9},{4},{8}))
  local d=Binary.new():parseDragonBonesData(raw)
  eq(d.intArray[2],7)
  eq(d.floatArray[1],1)
  eq(d.frameIntArray[1],-3)
  eq(d.frameFloatArray[1],0.5)
  eq(d.frameArray[1],9)
  eq(d.timelineArray[1],4)
  eq(d.colorArray[1],8)
end)
test("unaligned or oversized typed-array ranges are rejected",function()
  local bad='{"version":"5.5","offset":[1,2,2,0,2,0,2,0,2,0,2,0,2,0],"armature":[]}'
  local raw="DBDT"..string.rep("\0",4)..u32(#bad)..bad..string.rep("\0",5)
  eq(pcall(function() Binary.new():parseDragonBonesData(raw) end),false)
end)
test("binary geometry reuses original slot mesh models and vertex count",function()
  local extra=',"slot":[{"name":"root","parent":"root"}],'..
    '"skin":[{"name":"default","slot":[{"name":"root","display":['..
    '{"name":"mesh","type":"mesh","offset":0}]}]}]'
  local raw=fixture(extra,parts({2,0,0,-1},{0,0,1,0}))
  local data=Binary.new():parseDragonBonesData(raw)
  local g=data:getArmature("rig").defaultSkin:getDisplay("root","mesh").geometry
  eq(getmetatable(g),Display.GeometryData)
  eq(g.offset,0)
  eq(g.data,data)
  eq(g.vertexCount,2)
  eq(g.weight,nil)
end)
test("binary geometry reconstructs weighted bones and influence counts",function()
  local extra=',"slot":[{"name":"root","parent":"root"}],'..
    '"skin":[{"name":"default","slot":[{"name":"root","display":['..
    '{"name":"mesh","type":"mesh","offset":0}]}]}]'
  -- Geometry header at 0 -> weight header at 4.
  -- Weight: boneCount=1, floatOffset=0, bone 0, one vertex/one weight.
  local raw=fixture(extra,parts({1,0,0,4,1,0,0,1,0},
    {0,0,1,0.25,0.5}))
  local d=Binary.new():parseDragonBonesData(raw)
  local rig=d:getArmature("rig")
  local weight=rig.defaultSkin:getDisplay("root","mesh").geometry.weight
  eq(getmetatable(weight),Display.WeightData)
  eq(weight.offset,4)
  eq(weight.count,1)
  eq(weight.bones[1],rig:getBone("root"))
end)
test("binary parser repairs unsigned weight offset stored in signed Int16",function()
  local p=Binary.new()
  p._data={}
  local b={name="root"}
  p._rawBones={b}
  p._intArrayBuffer={[1]=1,[4]=-25536,
    [40001]=1,[40003]=0,[40004]=1,[40005]=0}
  local g=Display.GeometryData.new()
  p:_parseGeometry({offset=0},g)
  eq(g.weight.offset,40000)
  eq(g.weight.bones[1],b)
  eq(g.weight.count,1)
end)
test("binary one-keyframe animation maps no frameIndices and keeps offsets",function()
  local extra=',"animation":[{"name":"idle","duration":12,'..
    '"offset":[0,0,0],"bone":{"root":['..TT.BoneTranslate..',0]}}]'
  local raw=fixture(extra,parts({}, {}, {}, {},
    {0},{100,0,1,2,0,0}))
  local d=Binary.new():parseDragonBonesData(raw)
  local a=d:getArmature("rig"):getAnimation("idle")
  eq(a.frameCount,12)
  eq(a.frameIntOffset,0)
  eq(a.frameFloatOffset,0)
  eq(a.frameOffset,0)
  eq(a:getBoneTimelines("root")[1].type,TT.BoneTranslate)
  eq(a:getBoneTimelines("root")[1].frameIndicesOffset,-1)
end)
test("binary two-keyframe timeline rebuilds frame-index lookup with source positions",function()
  local extra=',"animation":[{"name":"walk","duration":10,'..
    '"offset":[0,0,0],"bone":{"root":['..TT.BoneTranslate..',0]}}]'
  local raw=fixture(extra,parts({}, {}, {}, {},
    {0,6},{100,0,2,2,0,0,1}))
  local d=Binary.new():parseDragonBonesData(raw)
  local tl=d:getArmature("rig"):getAnimation("walk"):getBoneTimelines("root")[1]
  eq(tl.frameIndicesOffset,0)
  eq(#d.frameIndices,11)
  for i=1,6 do eq(d.frameIndices[i],0) end
  for i=7,11 do eq(d.frameIndices[i],1) end
end)
test("binary action and zOrder timelines use distinct original model fields",function()
  local extra=',"animation":[{"name":"one","duration":2,"offset":[0,0,0],'..
    '"action":0,"zOrder":6}]'
  local raw=fixture(extra,parts({}, {}, {}, {},
    {0,0},{100,0,1,0,0,0,100,0,1,0,0,1}))
  local d=Binary.new():parseDragonBonesData(raw)
  local a=d:getArmature("rig"):getAnimation("one")
  eq(a.actionTimeline.type,TT.Action)
  eq(a.zOrderTimeline.type,TT.ZOrder)
end)
test("binary per-slot and per-constraint timeline maps attach by original name",function()
  local extra=',"slot":[{"name":"root","parent":"root"}],'..
    '"ik":[{"name":"IK","bone":"root","target":"target"}],'..
    '"animation":[{"name":"a","duration":4,"offset":[0,0,0],'..
    '"slot":{"root":['..TT.SlotDisplay..',0]},'..
    '"constraint":{"IK":['..TT.IKConstraint..',6]}}]'
  local raw=fixture(extra,parts({}, {}, {}, {},
    {0,0},{100,0,1,0,0,0,100,0,1,0,0,1}))
  local a=Binary.new():parseDragonBonesData(raw)
    :getArmature("rig"):getAnimation("a")
  eq(a:getSlotTimelines("root")[1].type,TT.SlotDisplay)
  eq(a:getConstraintTimelines("IK")[1].type,TT.IKConstraint)
end)
test("binary generic animation progress uses original AnimationTimelineData",function()
  local extra=',"animation":[{"name":"a","duration":4,"blendType":"1d",'..
    '"offset":[0,0,0],"timeline":[{"type":'..TT.AnimationProgress..
    ',"name":"child","offset":0,"x":0.2,"y":0.75}]}]'
  local raw=fixture(extra,parts({}, {}, {}, {},
    {0},{100,0,1,1,0,0}))
  local a=Binary.new():parseDragonBonesData(raw)
    :getArmature("rig"):getAnimation("a")
  local tl=a:getAnimationTimelines("child")[1]
  eq(tl.type,TT.AnimationProgress)
  eq(getmetatable(tl),Animation.AnimationTimelineData)
  near(tl.x,0.2)
  near(tl.y,0.75)
end)
test("binary generic Action and ZOrder TODO branches do not create timeline fields",function()
  local extra=',"animation":[{"name":"a","duration":4,"offset":[0,0,0],'..
    '"timeline":[{"type":0,"name":"unused","offset":0},'..
    '{"type":1,"name":"unused","offset":0}]}]'
  local d=Binary.new():parseDragonBonesData(
    fixture(extra,parts({}, {}, {}, {},{0},{100,0,1,0,0,0})))
  local a=d:getArmature("rig"):getAnimation("a")
  eq(a.actionTimeline,nil)
  eq(a.zOrderTimeline,nil)
end)
test("DragonBones binary header UTF8 supports non-ASCII armature and names",function()
  local h='{"version":"5.5","name":"Dragão 😀","frameRate":24,'..
    '"offset":[OFFSET_MARKER],"armature":[{"name":"Braço"}]}'
  local d=Binary.new():parseDragonBonesData(binary(h,parts()))
  eq(d.name,"Dragão 😀")
  eq(d.stage.name,"Braço")
end)
test("reuse binary parser across separate binary documents resets object data",function()
  local p=Binary.new()
  local first=p:parseDragonBonesData(fixture())
  local second=p:parseDragonBonesData(binary(
    '{"version":"5.5","name":"other","offset":[OFFSET_MARKER],'..
    '"armature":[{"name":"second"}]}',parts({5})))
  eq(first.name,"BinaryFixture")
  eq(second.name,"other")
  eq(second:getArmature("second").name,"second")
  eq(second.intArray[1],5)
  eq(p._data,nil)
end)

print(("Original BinaryDataParser: %d passed, %d failed, %d assertions")
  :format(passed,failed,checks))
if failed>0 then os.exit(1) end
