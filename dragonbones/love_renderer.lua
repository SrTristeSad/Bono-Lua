-- LÖVE rendering adapter. It only consumes commands from the Lua engine.
-- Requires LÖVE 11.x at runtime; safe to require from headless Lua tests.
local Render = {}
function Render.prepare(image, atlas)
  assert(image and atlas, "image and atlas required")
  local width,height = image:getWidth(),image:getHeight()
  local quads={}
  for name,region in pairs(atlas.regions) do
    if not region.rotated then
      quads[name] = love.graphics.newQuad(region.x,region.y,region.width,region.height,width,height)
    end
  end
  return {image=image,quads=quads}
end

function Render.draw(prepared, commands)
  local transform=love.math.newTransform()
  love.graphics.setColor(1,1,1,1)
  for _,item in ipairs(commands) do
    local quad=prepared.quads[item.name]
    if quad then
      local m=item.matrix
      -- LÖVE 11 Transform:setMatrix accepts a 4x4 matrix in row-major layout.
      -- Convert the six DragonBones affine coefficients explicitly.
      transform:setMatrix("row",
        m.a, m.c, 0, m.tx,
        m.b, m.d, 0, m.ty,
        0, 0, 1, 0,
        0, 0, 0, 1)
      love.graphics.push()
      love.graphics.applyTransform(transform)
      love.graphics.draw(prepared.image,quad,item.offsetX,item.offsetY)
      love.graphics.pop()
    end
  end
end
return Render
