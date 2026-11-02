-- Real LÖVE GPU parity: ObjectDataParser and BinaryDataParser consume the
-- SAME pinned DragonBones typed arrays for an animated, deformable mesh.
-- Reference: DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e
-- (MIT). This fixture creates the DBDT envelope only, NEVER reimplements
-- animation/pose/timeline evaluation.
local Love=require("dragonbones.love_original")
local Core=require("dragonbones.original.core.DragonBones")
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
  local animation=assert(armature:getAnimation("shift"))
  local bones=assert(animation:getBoneTimelines("root"))
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
    '"bone":[{"name":"root"}],"slot":[{"name":"body","parent":"root"}],'..
    '"skin":[{"name":"default","slot":[{"name":"body","display":['..
    '{"name":"red","path":"red","type":"mesh","offset":'..geom.offset..
    '}]}]}],"animation":[{"name":"shift","duration":12,"playTimes":0,'..
    '"offset":['..animation.frameIntOffset..','..
       animation.frameFloatOffset..','..animation.frameOffset..'],'..
    '"bone":{"root":['..table.concat(bonePairs,",")..']},'..
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
  local raw={version="5.5",name="GPU-Binary-Animated-Mesh",frameRate=12,
    armature={{name="rig",bone={{name="root"}},
      slot={{name="body",parent="root"}},
      skin={{name="default",slot={{name="body",display={{
        name="red",path="red",type="mesh",
        vertices={0,0,4,0,0,4},uvs={0,0,1,0,0,1},
        triangles={0,1,2}
      }}}}}},
      animation={{name="shift",duration=12,playTimes=0,
        bone={{name="root",translateFrame={
          {duration=6,x=0,y=0,tweenEasing=0},
          {duration=6,x=3,y=0,tweenEasing=0}
        }}},
        ffd={{skin="default",slot="body",name="red",frame={
          {duration=6,vertices={0,0,0,0,0,0},tweenEasing=0},
          {duration=6,vertices={6,0,6,0,6,0},tweenEasing=0}
        }}}
      }}
    }}
  }
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
  assert(slot._renderDisplay.mesh~=nil)
  assert(binaryData.binary==blob)
  assert(#binaryData.floatArray==#jsonData.floatArray)
  assert(binaryArmature.animation:getState("shift")==nil)
  local jsonAnimation=assert(jsonArmature.armatureData:getAnimation("shift"))
  local binAnimation=assert(binaryArmature.armatureData:getAnimation("shift"))
  assert(jsonAnimation:getBoneTimelines("root")[1].type==Core.TimelineType.BoneTranslate)
  assert(binAnimation:getBoneTimelines("root")[1].type==Core.TimelineType.BoneTranslate)
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
    "Original JSON/DBDT animated GPU meshes remained empty or static")
  assert(binaryArmature:getBone("root").globalTransformMatrix.tx>1,
    "Original DBDT bone translation timeline did not move the root")
  local deform=slot:getDisplayFrameAt(0).deformVertices
  assert(#deform>=6 and deform[1]>0.5,
    "Original DBDT SlotDeform timeline did not deform the mesh")
  assert(slot.displayIndex==0)
  local base=binaryData.binary
  -- A live typed-view mutation of the parsed DBDT reaches the original
  -- mesh's GeometryData, not an obsolete numeric snapshot.
  local B=Core.BinaryOffset
  local vertexOffset=binaryData.intArray[
    g.offset+B.GeometryFloatOffset+1]
  local old=binaryData.floatArray[vertexOffset+1]
  binaryData.floatArray[vertexOffset+1]=old+2
  assert(binaryData.floatArray[vertexOffset+1]==old+2)
  assert(binaryData.binary~=base,"DBDT must expose the mutated float32 bytes")
  -- Original PixiSlot._updateMesh reads the shared float array. A direct
  -- invalidation follows the same internal path as animated FFD updates.
  slot:_updateMesh()
  assert(math.abs(slot._renderDisplay.vertices[1][1]-
      (old+2+slot:getDisplayFrameAt(0).deformVertices[1]))<0.2,
    "Original PixiSlot mesh vertices did not observe DBDT float mutation")
  print("Original DBDT animated/FFD mesh GPU parity: 4 animation samples, mutable vertices, binary bytes.")
end
return Test
