local Blends=require('examples.love.blends')
local M={}
function M.capture(output)
  local cases={}
  for _,alpha in ipairs({0,.25,.5,1})do
    for _,tint in ipairs({1,.5})do
      for _,rotated in ipairs({false,true})do
        cases[#cases+1]={alpha,tint,rotated,false}
      end
    end
  end
  cases[#cases+1]={1,1,false,true};cases[#cases+1]={1,1,true,true}
  for i,c in ipairs(cases)do
    local factory,arm,image=Blends.scene(c[4],c[3],c[1],c[2],10)
    arm.flipX=i%3==0
    if i%4==0 and not c[4]then arm:getSlot('red')._zIndex=3;arm._zIndexDirty=true end
    arm:advanceTime(.25)
    if i==16 then
      local small=love.graphics.newCanvas(80,64,{format='rgba8',msaa=0,dpiscale=1})
      love.graphics.push('all');love.graphics.setCanvas(small);love.graphics.origin()
      love.graphics.clear(0,0,0,1);arm.display:draw(32,16)
      love.graphics.setCanvas();love.graphics.pop();small:release()
    end
    local canvas=love.graphics.newCanvas(160,128,{format='rgba8',msaa=0})
    love.graphics.push('all');love.graphics.setCanvas(canvas);love.graphics.origin()
    love.graphics.clear(64/255,96/255,128/255,1)
    love.graphics.setBlendMode('replace','premultiplied');love.graphics.setColor(144/255,176/255,80/255,1)
    love.graphics.rectangle('fill',0,0,160,64)
    love.graphics.setColor(.2,.3,.4,.5);love.graphics.setBlendMode('replace','premultiplied')
    local shader=love.graphics.getShader()
    arm.display:draw(64,32)
    local blend,alpha=love.graphics.getBlendMode()
    assert(blend=='replace'and alpha=='premultiplied'and love.graphics.getShader()==shader,'Draw must restore host state')
    love.graphics.setCanvas();love.graphics.pop()
    local data=canvas:newImageData()
    local f=assert(io.open(output..'/love-multiply-'..(i-1)..'.rgba','wb'));f:write(data:getString());f:close()
    local png=data:encode('png');f=assert(io.open(output..'/love-multiply-'..(i-1)..'.png','wb'));f:write(png:getString());f:close()
    png:release();data:release();canvas:release()
    arm:dispose();factory.dragonBones:advanceTime(0);factory:clear();factory.dragonBones:advanceTime(0);image:release()
  end
end
return M
