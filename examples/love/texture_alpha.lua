-- Input pixels, never expected screenshots. RGB is straight-alpha on upload.
local JSON=require('dragonbones.parser.JSON')
local Blends=require('examples.love.blends')
local A={}
function A.image(replacement)
  local atlas=JSON.parse(love.filesystem.read('examples/love/rotated_tex.json'))
  local input=JSON.parse(love.filesystem.read('examples/love/texture_alpha.json'))
  local colors=replacement and input.replacement or input.colors
  local data=love.image.newImageData(64,32)
  data:mapPixel(function(x,y)
    for i=1,atlas.SubTexture.length do
      local r=atlas.SubTexture[i]
      if x>=r.x and x<r.x+r.width and y>=r.y and y<r.y+r.height then
        local right=x-r.x>=r.width/2;local bottom=y-r.y>=r.height/2
        local color=colors[1+(right and 1 or 0)+(bottom and 2 or 0)]
        return color[1]/255,color[2]/255,color[3]/255,color[4]/255
      end
    end
    return 173/255,53/255,227/255,0
  end)
  local image=love.graphics.newImage(data);image:setFilter('nearest','nearest');data:release()
  return image
end
function A.capture(output)
  local index=0
  for _,mode in ipairs({12,10})do
    for _,alpha in ipairs({0,.25,.5,1})do
      for _,tint in ipairs({1,.5})do
        for _,rotated in ipairs({false,true})do
          index=index+1
          local factory,arm,image=Blends.scene(false,rotated,alpha,tint,mode,A.image)
          arm.flipX=index%3==0
          if index%4==0 then arm:getSlot('red')._zIndex=3;arm._zIndexDirty=true end
          local replacement
          if index%5==0 then replacement=A.image(true);arm.replacedTexture=replacement end
          arm:advanceTime(.25)
          local canvas=love.graphics.newCanvas(160,128,{format='rgba8',msaa=0,dpiscale=1})
          love.graphics.push('all');love.graphics.setCanvas(canvas);love.graphics.origin()
          love.graphics.clear(64/255,96/255,128/255,1)
          love.graphics.setBlendMode('replace','premultiplied');love.graphics.setColor(144/255,176/255,80/255,1)
          love.graphics.rectangle('fill',0,0,160,64)
          love.graphics.setColor(.2,.3,.4,.5)
          arm.display:draw(64,32)
          local blend,alphaMode=love.graphics.getBlendMode()
          assert(blend=='replace'and alphaMode=='premultiplied'and love.graphics.getCanvas()==canvas,'Draw must restore target/blend')
          love.graphics.setCanvas();love.graphics.pop()
          local data=canvas:newImageData()
          local file=assert(io.open(output..'/love-texture-alpha-'..(index-1)..'.rgba','wb'));file:write(data:getString());file:close()
          local png=data:encode('png');file=assert(io.open(output..'/love-texture-alpha-'..(index-1)..'.png','wb'));file:write(png:getString());file:close()
          png:release();data:release();canvas:release()
          arm:dispose();factory.dragonBones:advanceTime(0);factory:clear();factory.dragonBones:advanceTime(0)
          image:release();if replacement then replacement:release()end
        end
      end
    end
  end
end
return A
