-- GPU integration check for DragonBones rotated atlas regions in LÖVE.
-- Test the actual rasterized pixels, not only the affine matrix.
local DB=require("dragonbones")
local Test={}

local function expect(image,x,y,r,g,b)
  local rr,gg,bb,aa=image:getPixel(x,y)
  local epsilon=.07
  assert(aa>.90,("pixel %d,%d is transparent"):format(x,y))
  assert(math.abs(rr-r)<epsilon and math.abs(gg-g)<epsilon and math.abs(bb-b)<epsilon,
    ("wrong pixel (%d,%d): %.2f,%.2f,%.2f vs %.2f,%.2f,%.2f")
      :format(x,y,rr,gg,bb,r,g,b))
end

function Test.run()
  local data=love.image.newImageData(2,3)
  -- Packed clockwise layout (2 columns x 3 rows).
  -- After correcting the rotation, logical image becomes 3x2.
  -- Top row: red, white, blue; bottom row: green, white, yellow.
  for y=0,2 do
    data:setPixel(0,y,0,1,0,1)
    data:setPixel(1,y,1,1,1,1)
  end
  data:setPixel(1,0,1,0,0,1)
  data:setPixel(0,0,0,1,0,1)
  data:setPixel(1,2,0,0,1,1)
  data:setPixel(0,2,1,1,0,1)

  local image=love.graphics.newImage(data)
  image:setFilter("nearest","nearest")
  local armature={
    name="test",
    bone={{name="root"}},
    slot={{name="sprite",parent="root"}},
    skin={{name="default",slot={{name="sprite",display={{
      name="rotated",type="image",pivot={x=0,y=0}
    }}}}}}
  }
  local project=DB.parser.parse({version="5.5",armature={armature}})
  local player=DB.animation.new(project,"test")
  local atlas=DB.atlas.parse({width=2,height=3,SubTexture={{
    name="rotated",x=0,y=0,width=2,height=3,rotated=true
  }}})
  local commands,warnings=DB.atlas.commands(player,atlas)
  assert(#commands==1 and #warnings==0)
  local prepared=DB.love_renderer.prepare(image,atlas)
  local canvas=love.graphics.newCanvas(32,32)
  canvas:setFilter("nearest","nearest")
  love.graphics.push("all")
  love.graphics.setCanvas(canvas)
  love.graphics.clear(0,0,0,0)
  love.graphics.translate(8,8)
  DB.love_renderer.draw(prepared,commands)
  love.graphics.setCanvas()
  love.graphics.pop()

  local rendered=canvas:newImageData()
  expect(rendered,8,8,1,0,0)
  expect(rendered,8,9,0,1,0)
  expect(rendered,10,8,0,0,1)
  expect(rendered,10,9,1,1,0)
  print("LÖVE GPU pixel test passed: rotated atlas de-rotation is correct.")
  -- Test animated slot switching on the actual GPU, including hiding.
  local colorData=love.image.newImageData(4,2)
  for py=0,1 do
    for px=0,3 do
      if px<2 then colorData:setPixel(px,py,1,0,0,1)
      else colorData:setPixel(px,py,0,1,0,1) end
    end
  end
  local imageSwap=love.graphics.newImage(colorData)
  imageSwap:setFilter("nearest","nearest")
  local raw={
    version="5.5",frameRate=12,armature={{
      name="swap_test",bone={{name="root"}},slot={{name="sprite",parent="root"}},
      skin={{name="default",slot={{name="sprite",display={
        {name="red",pivot={x=0,y=0}},{name="green",pivot={x=0,y=0}}
      }}}}},
      animation={{name="swap",duration=12,playTimes=0,slot={{
        name="sprite",displayFrame={
          {duration=4,value=0},{duration=4,value=1},{duration=4,value=-1}
        }
      }}}}
    }}
  }
  local runtime=DB.animation.new(DB.parser.parse(raw),"swap_test")
  local swapAtlas=DB.atlas.parse({width=4,height=2,SubTexture={
    {name="red",x=0,y=0,width=2,height=2},
    {name="green",x=2,y=0,width=2,height=2}
  }})
  local preparedSwap=DB.love_renderer.prepare(imageSwap,swapAtlas)
  local target=love.graphics.newCanvas(16,16)
  local function sampleFrame()
    love.graphics.push("all")
    love.graphics.setCanvas(target)
    love.graphics.clear(0,0,0,0)
    love.graphics.translate(8,8)
    local cmds=DB.atlas.commands(runtime,swapAtlas)
    DB.love_renderer.draw(preparedSwap,cmds)
    love.graphics.setCanvas()
    love.graphics.pop()
    return target:newImageData()
  end
  runtime:play("swap")
  expect(sampleFrame(),8,8,1,0,0)
  runtime:advance(4/12)
  expect(sampleFrame(),8,8,0,1,0)
  runtime:advance(4/12)
  local invisible=sampleFrame()
  local _,_,_,a=invisible:getPixel(8,8)
  assert(a<.01,"hidden slot must not render")
  runtime:advance(4/12)
  expect(sampleFrame(),8,8,1,0,0)
  print("LÖVE GPU pixel test passed: animated displayFrame switches red/green/hidden/loop.")

end
return Test
