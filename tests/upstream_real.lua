-- Integration test against the official DragonBonesJS source at the pinned commit.
-- The original JSON files are downloaded in CI; no upstream JavaScript is executed.
package.path="./?.lua;./?/init.lua;"..package.path
local DB=require("dragonbones")
local base="artifacts/upstream/"
local function read(name)
  local f=assert(io.open(base..name,"rb"))
  local content=f:read("*a");f:close()
  return content
end

local model=DB.parser.parse(read("mecha_1406_ske.json"))
local atlas=DB.atlas.parse(read("mecha_1406_tex.json"))
local arm=assert(model.armatures.mecha_1406,"official armature not found")
assert(#arm.ordered==17,"unexpected official bone count")
assert(#arm.slots==13,"unexpected official slot count")
assert(arm.animations.walk and arm.animations.idle,"missing original animations")
local animation=DB.animation.new(model,"mecha_1406")
animation:play("walk")
animation:advance(.25)
local commands,warnings=DB.atlas.commands(animation,atlas)
assert(#commands>0,"official atlas did not resolve any visible sprites")
for _,item in ipairs(commands) do
  assert(item.source.width>0 and item.source.height>0,"empty texture region")
  assert(type(item.matrix.tx)=="number","invalid transformed X")
end
print("Original DragonBones mecha_1406 loaded in pure Lua:")
print("  bones="..#arm.ordered.." slots="..#arm.slots
  .." sprites="..#commands.." warnings="..#warnings)
