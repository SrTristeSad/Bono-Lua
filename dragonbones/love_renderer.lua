-- LÖVE rendering adapter. It only consumes commands from the Lua engine.
-- Requires LÖVE 11.x at runtime; safe to require from headless Lua tests.
local Render = {}
function Render.prepare(image, atlas)
  assert(image and atlas, "image and atlas required")
  local width,height = image:getWidth(),image:getHeight()
  local quads={}
  for name,region in pairs(atlas.regions) do
    quads[name] = love.graphics.newQuad(region.x,region.y,region.width,region.height,width,height)
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
      local a,b,c,d,tx,ty = m.a,m.b,m.c,m.d,m.tx,m.ty
      local drawX,drawY = item.offsetX,item.offsetY
      if item.rotated then
        -- DragonBones' packed rotated region stores an image turned clockwise.
        -- Convert source (x,y) back to unrotated local coordinates
        -- (y, packedWidth - x), then apply the normal bone transform.
        -- The offset is applied in logical/unrotated image coordinates.
        local packedWidth=item.source.width
        local localX,localY=item.offsetX,item.offsetY+packedWidth
        a,b,c,d = -m.c,-m.d,m.a,m.b
        tx=m.a*localX+m.c*localY+m.tx
        ty=m.b*localX+m.d*localY+m.ty
        drawX,drawY=0,0
      end
      -- LÖVE 11 accepts an explicit row-major 4x4 matrix.
      transform:setMatrix("row",
        a, c, 0, tx,
        b, d, 0, ty,
        0, 0, 1, 0,
        0, 0, 0, 1)
      love.graphics.push()
      love.graphics.applyTransform(transform)
      love.graphics.draw(prepared.image,quad,drawX,drawY)
      love.graphics.pop()
    end
  end
end
return Render
