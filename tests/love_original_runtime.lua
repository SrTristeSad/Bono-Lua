-- GPU integration for genuine original DragonBones Armature/Slot, not
-- the legacy prototype. Run inside LÖVE under xvfb/llvmpipe.
local Love=require("dragonbones.love_original")
local Test={}
local function colorAt(data,x,y,r,g,b,alpha)
  local rr,gg,bb,aa=data:getPixel(x,y)
  assert(math.abs(rr-r)<.08 and math.abs(gg-g)<.08
    and math.abs(bb-b)<.08 and math.abs(aa-alpha)<.08,
    ("Original LÖVE GPU pixel %d,%d expected %.2f %.2f %.2f %.2f, got %.2f %.2f %.2f %.2f")
      :format(x,y,r,g,b,alpha,rr,gg,bb,aa))
end
function Test.run()
  local pixels=love.image.newImageData(8,4)
  for y=0,3 do
    for x=0,7 do
      if x<4 then pixels:setPixel(x,y,1,0,0,1)
      else pixels:setPixel(x,y,0,1,0,1) end
    end
  end
  local image=love.graphics.newImage(pixels)
  image:setFilter("nearest","nearest")
  local factory=Love.Factory.new()
  local raw={version="5.5",name="GPURig",frameRate=12,
    armature={{name="rig",bone={{name="root"}},
      slot={{name="body",parent="root"}},
      skin={{name="default",slot={{name="body",display={
        {name="red",path="red",pivot={x=0,y=0}},
        {name="green",path="green",pivot={x=0,y=0}}
      }}}}},
      animation={{name="swap",duration=12,playTimes=0,slot={{
        name="body",displayFrame={
          {duration=4,value=0},{duration=4,value=1},
          {duration=4,value=-1}
        }
      }}}}
    }}
  }
  local atlas={name="GPUAtlas",width=8,height=4,SubTexture={
    {name="red",x=0,y=0,width=4,height=4},
    {name="green",x=4,y=0,width=4,height=4}
  }}
  factory:parseDragonBonesData(raw,"pack")
  factory:parseTextureAtlasData(atlas,image,"pack")
  local armature=assert(factory:buildArmature("rig","pack"))
  assert(armature.animation:getState("swap")==nil)
  local target=love.graphics.newCanvas(32,32)
  target:setFilter("nearest","nearest")
  local function shot()
    love.graphics.push("all")
    love.graphics.setCanvas(target)
    love.graphics.clear(0,0,0,0)
    love.graphics.translate(8,8)
    factory:drawArmature(armature)
    love.graphics.setCanvas()
    love.graphics.pop()
    return target:newImageData()
  end
  armature.animation:play("swap")
  armature:advanceTime(0)
  colorAt(shot(),9,9,1,0,0,1)
  armature:advanceTime(4/12)
  colorAt(shot(),9,9,0,1,0,1)
  armature:advanceTime(4/12)
  colorAt(shot(),9,9,0,0,0,0)
  armature:advanceTime(4/12)
  colorAt(shot(),9,9,1,0,0,1)
  -- Real LÖVE 11.x GPU mesh: original ObjectDataParser -> BaseFactory ->
  -- Slot -> PixiSlot geometry/FFD equations translated for LÖVE Mesh.
  local meshRaw={version="5.5",name="GPUMesh",frameRate=12,
    armature={{name="rig",bone={{name="root"}},
      slot={{name="body",parent="root"}},
      skin={{name="default",slot={{name="body",display={{
        name="red",path="red",type="mesh",
        vertices={0,0,4,0,0,4},
        uvs={0,0,1,0,0,1},triangles={0,1,2}
      }}}}}}
    }}
  }
  local meshFactory=Love.Factory.new()
  meshFactory:parseDragonBonesData(meshRaw,"mesh")
  meshFactory:parseTextureAtlasData(atlas,image,"mesh")
  local meshArmature=assert(meshFactory:buildArmature("rig","mesh"))
  local meshSlot=assert(meshArmature:getSlot("body"))
  assert(meshSlot._renderDisplay.mesh~=nil)
  local function meshShot()
    love.graphics.push("all")
    love.graphics.setCanvas(target)
    love.graphics.clear(0,0,0,0)
    love.graphics.translate(8,8)
    meshFactory:drawArmature(meshArmature)
    love.graphics.setCanvas()
    love.graphics.pop()
    return target:newImageData()
  end
  colorAt(meshShot(),9,9,1,0,0,1)
  local frame=meshSlot:getDisplayFrameAt(0)
  frame:updateDeformVertices()
  for i=1,#frame.deformVertices,2 do
    frame.deformVertices[i]=6
  end
  meshSlot:_updateMesh()
  local shifted=meshShot()
  colorAt(shifted,9,9,0,0,0,0)
  colorAt(shifted,15,9,1,0,0,1)
  print("Original DragonBones LÖVE GPU passed: red/green/hidden/loop and mesh/FFD pixels.")
end
return Test
