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
  print("Original DragonBones LÖVE GPU passed: red/green/hidden/loop via actual Armature + Animation.")
end
return Test
