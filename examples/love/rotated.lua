-- Asymmetric atlas input for rotation verification, not a screenshot generator.
local JSON=require('dragonbones.parser.JSON')
local Factory=require('dragonbones.love.Factory')
local R={}
function R.image(replacement)
  local atlas=JSON.parse(love.filesystem.read('examples/love/rotated_tex.json'))
  local data=love.image.newImageData(64,32)
  data:mapPixel(function(x,y)
    for i=1,atlas.SubTexture.length do
      local r=atlas.SubTexture[i]
      if x>=r.x and x<r.x+r.width and y>=r.y and y<r.y+r.height then
        local right=x-r.x>=r.width/2;local bottom=y-r.y>=r.height/2
        if replacement then
          if not bottom then return right and 1 or 0,1,right and 0 or 1,1 end
          return 1,right and 0 or 1,1,1
        end
        if not bottom then return right and 0 or 1,right and 1 or 0,0,1 end
        return right and 1 or 0,right and 1 or 0,right and 0 or 1,1
      end
    end
    return 0,0,0,1
  end)
  local image=love.graphics.newImage(data);image:setFilter('nearest','nearest');data:release()
  return image
end
function R.scene(meshMode,scale,trim,pivot,mixed,fallback)
  local image=R.image(false)
  local raw=JSON.parse(love.filesystem.read(meshMode and'examples/love/meshes_ske.json'or'examples/love/sprites_ske.json'))
  if pivot then
    for i=1,raw.armature[1].skin[1].slot.length do
      raw.armature[1].skin[1].slot[i].display[1].pivot={x=.5,y=.5}
    end
  end
  local atlas=JSON.parse(love.filesystem.read('examples/love/rotated_tex.json'))
  if trim then
    local r=atlas.SubTexture[1]
    r.frameX=-2;r.frameY=-1;r.frameWidth=20;r.frameHeight=18
  end
  if mixed then atlas.SubTexture[2].rotated=false end
  if fallback then atlas.width=0;atlas.height=0 end
  local factory=Factory.new()
  factory:parseDragonBonesData(raw,'sprites',scale)
  factory:parseTextureAtlasData(atlas,image,'sprites')
  local arm=factory:buildArmature('demo','sprites');arm.animation:play('move',0)
  return factory,arm,image
end
function R.capture(output)
  local cases={{0,0,1,0,0,0,0,0},{0,.25,1,0,0,0,0,0},{0,.5,2,0,0,0,0,0},
    {0,.25,1,1,0,0,0,0},{0,.5,1,0,1,1,0,0},{1,.25,1,0,0,0,0,0},
    {1,.5,1,1,0,0,0,0},{1,.5,1,0,0,0,1,0},{1,.25,1,0,0,0,0,1},{0,.75,1,0,0,0,0,2}}
  for i,c in ipairs(cases)do
    local f,a,image=R.scene(c[1]==1,c[3],c[5]==1,c[6]==1,c[8]==2,c[8]==1)
    a.flipX=c[4]==1
    local replacement
    if c[7]==1 then replacement=R.image(true);a.replacedTexture=replacement end
    a:advanceTime(c[2])
    local canvas=love.graphics.newCanvas(160,128,{format='rgba8',msaa=0})
    love.graphics.push('all');love.graphics.setCanvas(canvas);love.graphics.origin()
    love.graphics.clear(16/255,16/255,24/255,1);a.display:draw(64,32)
    love.graphics.setCanvas();love.graphics.pop()
    local data=canvas:newImageData();local file=assert(io.open(output..'/love-rotation-'..(i-1)..'.rgba','wb'))
    file:write(data:getString());file:close()
    local png=data:encode('png');file=assert(io.open(output..'/love-rotation-'..(i-1)..'.png','wb'));file:write(png:getString());file:close()
    png:release();data:release();canvas:release()
    a:dispose();f.dragonBones:advanceTime(0);f:clear();f.dragonBones:advanceTime(0)
    image:release();if replacement then replacement:release()end
  end
end
return R
