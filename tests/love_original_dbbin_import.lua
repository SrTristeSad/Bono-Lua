-- The actual default LÖVE application must import a DBDT project through
-- pinned BinaryDataParser.ts, not parse it as JSON or use a prototype.
-- Source: DragonBones/DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e (MIT).
local App=require("dragonbones.original_love_app")
local Armature=require("dragonbones.original.armature.Armature")
local Love=require("dragonbones.love_original")
local Test={}

local header=[[{"version":"5.5","name":"BinaryGPU","frameRate":24,
"offset":[0,0,0,0,0,0,0,0,0,0,0,0,0,0],
"armature":[{"name":"binaryRig","bone":[{"name":"root","transform":{"x":8,"y":8}}],
"slot":[{"name":"body","parent":"root","displayIndex":0}],
"skin":[{"name":"default","slot":[{"name":"body","display":[
{"name":"red","path":"red","type":"image","pivot":{"x":0,"y":0}}
]}]}]}]}]]
local atlas=[[{"name":"BinaryAtlas","width":8,"height":8,
"SubTexture":[{"name":"red","x":0,"y":0,"width":8,"height":8}]}]]

local function binaryHeader(json)
  -- DBDT signature, four reserved bytes and a little-endian header length:
  -- exactly the offset/JSON framing of pinned BinaryDataParser.ts.
  json=json..string.rep(" ",(4-#json%4)%4)
  local n=#json
  local length=string.char(n%256,math.floor(n/256)%256,
    math.floor(n/65536)%256,math.floor(n/16777216)%256)
  return "DBDT"..string.rep("\0",4)..length..json
end
local function write(path,contents)
  assert(love.filesystem.write(path,contents),"Unable to write test asset "..path)
end
local function pixelAt(x,y)
  local w,h=love.graphics.getDimensions()
  local target=love.graphics.newCanvas(w,h)
  love.graphics.push("all")
  love.graphics.setCanvas(target)
  App.draw()
  love.graphics.setCanvas()
  love.graphics.pop()
  return target:newImageData():getPixel(x,y)
end
function Test.run()
  assert(love.filesystem.createDirectory("assets"),
    "Unable to prepare LÖVE save directory for binary test")
  local image=love.image.newImageData(8,8)
  for y=0,7 do for x=0,7 do image:setPixel(x,y,1,0,0,1) end end
  local png=image:encode("png")
  local source=binaryHeader(header)
  write("assets/project_ske.dbbin",source)
  write("assets/project_tex.json",atlas)
  write("assets/project_tex.png",png:getString())
  -- No project_ske.json: the default app must use BinaryDataParser.
  assert(love.filesystem.getInfo("assets/project_ske.json")==nil,
    "Binary fixture must not be shadowed by JSON skeleton")
  local state=assert(App.load())
  assert(state.skeletonPath=="assets/project_ske.dbbin")
  assert(state.external==true)
  assert(state.data.binary==source,
    "BinaryDataParser must retain original DBDT payload")
  assert(state.data.name=="BinaryGPU")
  assert(getmetatable(state.armature)==Armature)
  assert(getmetatable(assert(state.armature:getSlot("body")))==Love.Slot)
  assert(state.armature.armatureData.name=="binaryRig")
  assert(state.armature.clock==state.factory.clock)
  local slot=state.armature:getSlot("body")
  assert(slot.displayIndex==0)
  assert(slot._renderDisplay.texture~=nil and slot._renderDisplay.quad~=nil)
  local w,h=love.graphics.getDimensions()
  local r,g,b,a=pixelAt(math.floor(w/2)+9,math.floor(h/2)+9)
  assert(r>.88 and g<.12 and b<.12 and a>.95,
    ("Original DBDT armature not rendered on GPU (%.3f %.3f %.3f %.3f)")
      :format(r,g,b,a))
  -- Pressing R must re-enter the same original binary parser dispatch.
  App.keypressed("r")
  local reloaded=assert(App.state())
  assert(reloaded.skeletonPath=="assets/project_ske.dbbin")
  assert(reloaded.data.name=="BinaryGPU")
  assert(getmetatable(reloaded.armature)==Armature)
  -- JSON wins if both formats exist, retaining the documented old behavior.
  write("assets/project_ske.json",header)
  local fromJson=assert(App.load())
  assert(fromJson.skeletonPath=="assets/project_ske.json")
  assert(fromJson.data.name=="BinaryGPU")
  assert(getmetatable(fromJson.armature)==Armature)
  for _,path in ipairs({
    "assets/project_ske.json","assets/project_ske.dbbin",
    "assets/project_tex.json","assets/project_tex.png"
  }) do assert(love.filesystem.remove(path),"Unable to clear "..path) end
  print("Original DBDT app import passed: BinaryDataParser, BaseFactory, Armature, LÖVE GPU, reload, JSON priority.")
end
return Test
