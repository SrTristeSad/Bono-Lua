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
end
return Test
