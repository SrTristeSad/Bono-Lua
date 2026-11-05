local JSON=require('dragonbones.parser.JSON')
local Factory=require('dragonbones.love.Factory')
local function atlasImage()
  local pixels=love.image.newImageData(48,16)
  pixels:mapPixel(function(x,y)
    local band=math.floor(x/16)
    if band==0 then return 1,0,0,1 elseif band==1 then return 0,0,1,1 end
    return 0,1,0,1
  end)
  local image=love.graphics.newImage(pixels);image:setFilter('nearest','nearest')
  pixels:release();return image
end
local function scene(image,alpha,tint)
  local raw=JSON.parse(love.filesystem.read('examples/love/sprites_ske.json'))
  for i=1,raw.armature[1].slot.length do
    raw.armature[1].slot[i].color={aM=alpha*100,rM=tint*100,gM=100,bM=100}
  end
  local factory=Factory.new()
  factory:parseDragonBonesData(raw,'sprites')
  factory:parseTextureAtlasData(JSON.parse(love.filesystem.read('examples/love/sprites_tex.json')),image,'sprites')
  local arm=factory:buildArmature('demo','sprites')
  arm.animation:play('move',0)
  return factory,arm
end
local function close(factory,arm)
  arm:dispose();factory.dragonBones:advanceTime(0)
  factory:clear();factory.dragonBones:advanceTime(0)
end
local cases={
  {0,1,1,0,0},{.25,1,1,0,0},{.5,1,1,0,0},{.75,1,1,0,0},
  {.25,.5,1,0,0},{.5,1,.5,0,0},{.25,1,1,1,0},{.25,1,1,0,1},
}
local function pixels(output,image)
  local info={love.getVersion()};local f=assert(io.open(output..'/love-version.txt','w'))
  f:write(table.concat(info,'.'),'\n',table.concat({love.graphics.getRendererInfo()},' | '),'\n');f:close()
  for i,c in ipairs(cases)do
    local factory,arm=scene(image,c[2],c[3]);arm.flipX=c[4]==1
    if c[5]==1 then arm:getSlot('red')._zIndex=3;arm._zIndexDirty=true end
    arm:advanceTime(c[1])
    local canvas=love.graphics.newCanvas(96,64,{format='rgba8',msaa=0})
    love.graphics.push('all');love.graphics.setCanvas(canvas)
    love.graphics.clear(16/255,16/255,24/255,1);love.graphics.origin()
    arm.display:draw(32,16)
    love.graphics.setCanvas();love.graphics.pop()
    local data=canvas:newImageData()
    local file=assert(io.open(output..'/love-'..(i-1)..'.rgba','wb'));file:write(data:getString());file:close()
    local encoded=data:encode('png');file=assert(io.open(output..'/love-'..(i-1)..'.png','wb'));file:write(encoded:getString());file:close()
    encoded:release();data:release();canvas:release();close(factory,arm)
  end
end
local factory,arm,image,paused
function love.load()
  love.graphics.setDefaultFilter('nearest','nearest')
  image=atlasImage()
  local output=os.getenv('BONO_RENDER_OUTPUT')
  if output then
    local ok,message=xpcall(function()pixels(output,image)end,debug.traceback)
    if not ok then io.stderr:write(message,'\n');love.event.quit(1);return end
    print('LÖVE rendered eight real RGBA/PNG frames.');love.event.quit(0);return
  end
  factory,arm=scene(image,1,1);arm.clock=factory.clock
end
function love.update(delta)
  if factory and not paused then factory.dragonBones:advanceTime(delta)end
end
function love.draw()
  love.graphics.clear(16/255,16/255,24/255,1)
  if not arm then return end
  arm.display:draw(180,140,6)
  love.graphics.setColor(1,1,1,1)
  love.graphics.print('Bono-Lua / LÖVE: atlas + sprites + animação real',20,20)
  love.graphics.print('Espaço: pausa | R: reinicia | F: espelha | Esc: sair',20,42)
  love.graphics.print(('t=%.2f s'):format(arm.animation.lastAnimationState.currentTime),20,66)
end
function love.keypressed(key)
  if key=='escape'then love.event.quit()
  elseif key=='space'then paused=not paused
  elseif key=='r'then arm.animation:play('move',0)
  elseif key=='f'then arm.flipX=not arm.flipX end
end
function love.quit()if factory then close(factory,arm)end;if image then image:release()end end
