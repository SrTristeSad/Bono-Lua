-- Original weighted mesh/FFD differential: compare parser-produced raw bytes
-- against the actual pinned DragonBonesJS ObjectDataParser, not an imitation.
-- Run with Lua 5.4 and LuaJIT; Node is needed only for CI reference data.
package.path="./?.lua;./?/init.lua;"..package.path
local Json=require("dragonbones.json")
local Parser=require("dragonbones.original.parser.ObjectDataParser")
local source=assert(io.open("tests/fixtures/original_weighted_mesh.json","rb"))
local input=assert(Json.decode(source:read("*a")))
source:close()
local data=assert(Parser.new():parseDragonBonesData(input),
  "Original Lua ObjectDataParser failed to compile weighted/FFD fixture")
local armature=assert(data:getArmature("rig"))
local geometry=assert(armature.defaultSkin:getDisplay("body","red")).geometry
local weight=assert(geometry.weight)
local actual={
  binary=(data.binary:gsub(".",function(c)return ("%02x"):format(c:byte()) end)),
  views=table.concat((function()
    local result={}
    for _,key in ipairs({"intArray","floatArray","frameIntArray","frameFloatArray",
      "frameArray","timelineArray","colorArray"}) do
      result[#result+1]=#data[key]
    end
    return result
  end)(),","),
  weight=tostring(weight.count),
  bones=(function()
    local result={}
    for _,bone in ipairs(weight.bones) do result[#result+1]=bone.name end
    return table.concat(result,",")
  end)()
}
local path=arg[1] or "artifacts/upstream/weighted_mesh_expected.tsv"
local file=assert(io.open(path,"r"))
local found={}
for line in file:lines() do
  local key,value=line:match("^(%w+)\t(.*)$")
  assert(key~=nil and actual[key]~=nil and found[key]==nil,
    "Malformed original weighted mesh reference: "..line)
  found[key]=true
  assert(actual[key]==value,
    (key=="binary" and
      ("Original DragonBonesJS weighted/FFD bytes differ ("..#actual[key]..
      " hex digits Lua vs "..#value.." upstream)")
      or ("Original DragonBonesJS "..key.." mismatch: "..actual[key].." vs "..value)))
end
file:close()
for k in pairs(actual) do assert(found[k],"Missing pinned original "..k) end
assert(weight.count==6 and #weight.bones==2)
assert(armature:getAnimation("shift"):getBoneTimelines("tip")~=nil)
assert(armature:getAnimation("shift"):getSlotTimelines("body")~=nil)
print("Pinned DragonBonesJS weighted/FFD full parser differential: bytes, views, bone indices, 6 influences passed.")
