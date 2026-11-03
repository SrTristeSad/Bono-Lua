-- Real LÖVE GPU parity: ObjectDataParser and BinaryDataParser consume the
-- SAME pinned DragonBones typed arrays for an animated, deformable mesh.
-- Reference: DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e
-- (MIT). This fixture creates the DBDT envelope only, NEVER reimplements
-- animation/pose/timeline evaluation.
local Love=require("dragonbones.love_original")
local Core=require("dragonbones.original.core.DragonBones")
local JSON=require("dragonbones.json")
local Test={}

local function u32(n)
  return string.char(n%256,math.floor(n/256)%256,
    math.floor(n/65536)%256,math.floor(n/16777216)%256)
end

local function encodeBinary(jsonData,armature)
  -- The seven typed views and all timeline offsets are produced by the
  -- original ObjectDataParser port, not synthesized animation results.
  local offsetParts={}
  local byteOffset=0
  for _,spec in ipairs({
    {"intArray",2},{"floatArray",4},
    {"frameIntArray",2},{"frameFloatArray",4},
    {"frameArray",2},{"timelineArray",2},{"colorArray",2}
  }) do
    local length=#jsonData[spec[1]]*spec[2]
    offsetParts[#offsetParts+1]=byteOffset
    offsetParts[#offsetParts+1]=length
    byteOffset=byteOffset+length
  end
  local packed=jsonData.binary
  assert(#packed==byteOffset,"Original typed array segments have wrong size")
  local geom=assert(armature.defaultSkin:getDisplay("body","red")).geometry
  local weight=assert(geom.weight,"Expected original weighted GeometryData")
  assert(#weight.bones==2 and weight.count==6,
    "Expected 2 bones, 3 vertices and 6 bone influences")
  -- ObjectDataParser stores WeightData as a model; the binary exporter
  -- encodes its offset/count in intArray. Populate ONLY this test fixture's
  -- export metadata, leaving original parser/runtime algorithms unchanged.
  local B=Core.BinaryOffset
  jsonData.intArray[geom.offset+B.GeometryWeightOffset+1]=weight.offset
  jsonData.intArray[weight.offset+B.WeigthBoneCount+1]=#weight.bones
  packed=jsonData.binary
  local animation=assert(armature:getAnimation("shift"))
  local bones=assert(animation:getBoneTimelines("tip"))
  local slots=assert(animation:getSlotTimelines("body"))
  local bonePairs,slotPairs={},{}
  for _,timeline in ipairs(bones) do
    bonePairs[#bonePairs+1]=timeline.type
    bonePairs[#bonePairs+1]=timeline.offset
  end
  for _,timeline in ipairs(slots) do
    slotPairs[#slotPairs+1]=timeline.type
    slotPairs[#slotPairs+1]=timeline.offset
  end
  assert(#bonePairs>=2 and #slotPairs>=2,
    "Original JSON compiler did not produce the animated mesh timelines")

  local head='{"version":"5.5","name":"GPU-Binary-Animated-Mesh",'..
    '"frameRate":12,"offset":['..table.concat(offsetParts,",")..'],'..
    '"armature":[{"name":"rig","frameRate":12,'..
    '"bone":[{"name":"root"},{"name":"tip","transform":{"x":4,"y":0}}],"slot":[{"name":"body","parent":"root"}],'..
    '"skin":[{"name":"default","slot":[{"name":"body","display":['..
    '{"name":"red","path":"red","type":"mesh","offset":'..geom.offset..
    '}]}]}],"animation":[{"name":"shift","duration":12,"playTimes":0,'..
    '"offset":['..animation.frameIntOffset..','..
       animation.frameFloatOffset..','..animation.frameOffset..'],'..
    '"bone":{"tip":['..table.concat(bonePairs,",")..']},'..
    '"slot":{"body":['..table.concat(slotPairs,",")..']}}]}]}'
  head=head..string.rep(" ",(4-#head%4)%4)
  return "DBDT"..string.rep("\0",4)..u32(#head)..head..packed
end

local function shot(factory,armature)
  local target=love.graphics.newCanvas(36,28)
  target:setFilter("nearest","nearest")
  love.graphics.push("all")
  love.graphics.setCanvas(target)
  love.graphics.clear(0,0,0,0)
  love.graphics.translate(8,8)
  factory:drawArmature(armature)
  love.graphics.setCanvas()
  love.graphics.pop()
  return target:newImageData()
end

local function pixelsEqual(a,b,label)
  -- Read back the real GPU pixels; each engine's slot/armature data is
  -- parsed independently from JSON or DBDT and rendered by the same GPU.
  for y=0,27 do for x=0,35 do
    local ar,ag,ab,aa=a:getPixel(x,y)
    local br,bg,bb,ba=b:getPixel(x,y)
    local eps=0.02
    assert(math.abs(ar-br)<eps and math.abs(ag-bg)<eps
      and math.abs(ab-bb)<eps and math.abs(aa-ba)<eps,
      ("Original JSON/DBDT GPU mismatch %s at %d,%d: %.3f %.3f %.3f %.3f / %.3f %.3f %.3f %.3f")
        :format(label,x,y,ar,ag,ab,aa,br,bg,bb,ba))
  end end
end

function Test.run()
  local fixture=assert(love.filesystem.read("tests/fixtures/original_weighted_mesh.json"),
    "Missing shared original weighted mesh fixture")
  local raw=JSON.decode(fixture)
  assert(raw.armature[1].skin[1].slot[1].display[1].weights~=nil,
    "Shared fixture lacks skinned mesh weights")
  local pixels=love.image.newImageData(4,4)
  for y=0,3 do for x=0,3 do pixels:setPixel(x,y,1,0,0,1) end end
  local image=love.graphics.newImage(pixels)
  image:setFilter("nearest","nearest")
  local atlas={name="BinaryMeshAtlas",width=4,height=4,SubTexture={{
    name="red",x=0,y=0,width=4,height=4
  }}}
  local jsonFactory=Love.Factory.new()
  local jsonData=assert(jsonFactory:parseDragonBonesData(raw,"jsonMesh"))
  jsonFactory:parseTextureAtlasData(atlas,image,"jsonMesh")
  local jsonArmature=assert(jsonFactory:buildArmature("rig","jsonMesh"))
  local blob=encodeBinary(jsonData,jsonArmature.armatureData)
  local binaryFactory=Love.Factory.new()
  local binaryData=assert(binaryFactory:parseDragonBonesData(blob,"binaryMesh"),
    "BinaryDataParser must accept DBDT mesh with animation timelines")
  binaryFactory:parseTextureAtlasData(atlas,image,"binaryMesh")
  local binaryArmature=assert(binaryFactory:buildArmature("rig","binaryMesh"))
  local g=assert(binaryArmature.armatureData.defaultSkin:getDisplay("body","red")).geometry
  local slot=assert(binaryArmature:getSlot("body"))
  assert(g.data==binaryData and g.vertexCount==3)
  assert(g.weight~=nil,"DBDT geometry did not restore WeightData")
  assert(#g.weight.bones==2 and g.weight.count==6,
    "DBDT weighted mesh lost bone weights or influence count")
  assert(g.weight.bones[1].name=="root" and g.weight.bones[2].name=="tip")
  assert(#slot._geometryBones==2,
    "Original Slot must bind both weighted mesh bones")
  assert(slot._renderDisplay.mesh~=nil)
  assert(binaryData.binary==blob)
  assert(#binaryData.floatArray==#jsonData.floatArray)
  assert(binaryArmature.animation:getState("shift")==nil)
  local jsonAnimation=assert(jsonArmature.armatureData:getAnimation("shift"))
  local binAnimation=assert(binaryArmature.armatureData:getAnimation("shift"))
  assert(jsonAnimation:getBoneTimelines("tip")[1].type==Core.TimelineType.BoneTranslate)
  assert(binAnimation:getBoneTimelines("tip")[1].type==Core.TimelineType.BoneTranslate)
  assert(jsonAnimation:getSlotTimelines("body")[1].type==Core.TimelineType.SlotDeform)
  assert(binAnimation:getSlotTimelines("body")[1].type==Core.TimelineType.SlotDeform)

  jsonArmature.animation:play("shift")
  binaryArmature.animation:play("shift")
  local firstPixels,lastPixels
  for i,seconds in ipairs({0,3/12,3/12,3/12}) do
    jsonArmature:advanceTime(seconds)
    binaryArmature:advanceTime(seconds)
    local a=shot(jsonFactory,jsonArmature)
    local b=shot(binaryFactory,binaryArmature)
    pixelsEqual(a,b,"animation frame "..i)
    if i==1 then firstPixels=b end
    if i==4 then lastPixels=b end
  end
  -- Comparisons alone would also accept two broken static or empty rigs.
  -- Require both animated rigs to have genuinely visible, MOVING mesh pixels.
  local changed,firstColored,lastColored=0,0,0
  for y=0,27 do for x=0,35 do
    local r0,g0,b0,a0=firstPixels:getPixel(x,y)
    local r1,g1,b1,a1=lastPixels:getPixel(x,y)
    if a0>0.2 and r0>0.5 then firstColored=firstColored+1 end
    if a1>0.2 and r1>0.5 then lastColored=lastColored+1 end
    if math.abs(a0-a1)>0.1 then changed=changed+1 end
  end end
  assert(firstColored>0 and lastColored>0 and changed>=4,
    "Original JSON/DBDT weighted GPU meshes remained empty or static")
  assert(binaryArmature:getBone("tip").globalTransformMatrix.tx>5,
    "Original DBDT bone translation timeline did not move the root")
  local deform=slot:getDisplayFrameAt(0).deformVertices
  assert(#deform==12 and deform[1]>0.5,
    "Original DBDT weighted SlotDeform timeline did not deform the mesh")
  assert(slot.displayIndex==0)
  local base=binaryData.binary
  -- Weighted _updateMesh reads the influence-local Float32 triplet,
  -- not the base mesh vertex coordinate stored elsewhere in floatArray.
  local B=Core.BinaryOffset
  local weightFloatOffset=binaryData.intArray[
    g.weight.offset+B.WeigthFloatOffset+1]
  local firstLocalXIndex=weightFloatOffset+2 -- first [weight, x, y]
  local old=binaryData.floatArray[firstLocalXIndex]
  local oldVertexX=slot._renderDisplay.vertices[1][1]
  binaryData.floatArray[firstLocalXIndex]=old+2
  assert(binaryData.floatArray[firstLocalXIndex]==old+2)
  assert(binaryData.binary~=base,"DBDT must expose mutated weighted Float32 bytes")
  slot:_updateMesh()
  local newVertexX=slot._renderDisplay.vertices[1][1]
  -- First vertex is influenced 50% by each bone, so moving just the
  -- first bone's local X by +2 must move it +1 exactly.
  assert(math.abs(newVertexX-oldVertexX-1)<0.03,
    ("Weighted mesh ignored a live Float32 influence edit: %.4f -> %.4f")
      :format(oldVertexX,newVertexX))
  print("Original 2-bone weighted DBDT mesh GPU parity: 4 animated/FFD samples, 6 influences, mutable weight bytes.")

end
return Test
