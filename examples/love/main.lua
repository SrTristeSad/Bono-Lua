local JSON=require('dragonbones.parser.JSON')
local Factory=require('dragonbones.love.Factory')
local function atlasImage(replacement)
  local pixels=love.image.newImageData(48,16)
  pixels:mapPixel(function(x,y)
    local band=math.floor(x/16)
    if replacement then
      if band==0 then return 1,1,0,1 elseif band==1 then return 0,1,1,1 end
      return 1,0,1,1
    end
    if band==0 then return 1,0,0,1 elseif band==1 then return 0,0,1,1 end
    return 0,1,0,1
  end)
  local image=love.graphics.newImage(pixels);image:setFilter('nearest','nearest')
  pixels:release();return image
end
local function scene(image,alpha,tint,meshMode,scale)
  local raw=JSON.parse(love.filesystem.read(meshMode and'examples/love/meshes_ske.json'or'examples/love/sprites_ske.json'))
  for i=1,raw.armature[1].slot.length do
    raw.armature[1].slot[i].color={aM=alpha*100,rM=tint*100,gM=100,bM=100}
  end
  local factory=Factory.new()
  factory:parseDragonBonesData(raw,'sprites',scale or 1)
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
local function meshPixels(output,image)
  local cases={{0,1,0,1},{.25,1,0,1},{.5,1,0,1},{.75,1,0,1},
    {.25,2,0,1},{.25,1,1,1},{.5,1,0,0},{.25,1,0,1,1}}
  for i,c in ipairs(cases)do
    local factory,arm=scene(image,1,1,true,c[2]);arm.flipX=c[3]==1
    for _,name in ipairs({'mesh','weighted','surface'})do
      arm:getSlot(name):getDisplayFrameAt(0):getGeometryData().inheritDeform=c[4]==1
    end
    local replacement
    if c[5]then replacement=atlasImage(true);arm.replacedTexture=replacement end
    arm:advanceTime(c[1])
    local canvas=love.graphics.newCanvas(160,128,{format='rgba8',msaa=0})
    love.graphics.push('all');love.graphics.setCanvas(canvas)
    love.graphics.clear(16/255,16/255,24/255,1);love.graphics.origin()
    arm.display:draw(32,16)
    love.graphics.setCanvas();love.graphics.pop()
    local data=canvas:newImageData()
    local file=assert(io.open(output..'/love-mesh-'..(i-1)..'.rgba','wb'));file:write(data:getString());file:close()
    local png=data:encode('png');file=assert(io.open(output..'/love-mesh-'..(i-1)..'.png','wb'));file:write(png:getString());file:close()
    png:release();data:release();canvas:release();close(factory,arm)
    if replacement then replacement:release()end
  end
end
local showMeshes=true
local showRotation=false
local Rotated=require('examples.love.rotated')
local Blends=require('examples.love.blends')
local showScreen=false
local showMultiply=false
local multiplyCanvas
local Multiply=require('examples.love.multiply')
local TextureAlpha=require('examples.love.texture_alpha')
local showTextureAlpha=false
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
  local meshOutput=os.getenv('BONO_MESH_OUTPUT')
  if meshOutput then
    local ok,message=xpcall(function()meshPixels(meshOutput,image)end,debug.traceback)
    if not ok then io.stderr:write(message,'\n');love.event.quit(1);return end
    print('LÖVE rendered eight real mesh RGBA/PNG frames.');love.event.quit(0);return
  end
  local textureOutput=os.getenv('BONO_TEXTURE_ALPHA_OUTPUT')
  if textureOutput then
    local ok,message=xpcall(function()TextureAlpha.capture(textureOutput)end,debug.traceback)
    if not ok then io.stderr:write(message,'\n');love.event.quit(1);return end
    print('LÖVE rendered 32 real texture-alpha RGBA/PNG frames.');love.event.quit(0);return
  end
  local multiplyOutput=os.getenv('BONO_MULTIPLY_OUTPUT')
  if multiplyOutput then
    local ok,message=xpcall(function()Multiply.capture(multiplyOutput)end,debug.traceback)
    if not ok then io.stderr:write(message,'\n');love.event.quit(1);return end
    print('LÖVE rendered eighteen real Multiply RGBA/PNG frames.');love.event.quit(0);return
  end
  local blendOutput=os.getenv('BONO_BLEND_OUTPUT')
  if blendOutput then
    local ok,message=xpcall(function()Blends.capture(blendOutput)end,debug.traceback)
    if not ok then io.stderr:write(message,'\n');love.event.quit(1);return end
    print('LÖVE rendered eighteen real Screen RGBA/PNG frames.');love.event.quit(0);return
  end
  local rotationOutput=os.getenv('BONO_ROTATION_OUTPUT')
  if rotationOutput then
    local ok,message=xpcall(function()Rotated.capture(rotationOutput)end,debug.traceback)
    if not ok then io.stderr:write(message,'\n');love.event.quit(1);return end
    print('LÖVE rendered ten real rotated-atlas RGBA/PNG frames.');love.event.quit(0);return
  end
  factory,arm=scene(image,1,1,showMeshes);arm.clock=factory.clock
end
function love.update(delta)
  if factory and not paused then factory.dragonBones:advanceTime(delta)end
end
function love.draw()
  love.graphics.clear(16/255,16/255,24/255,1)
  if not arm then return end
  if showMultiply or(showScreen and showTextureAlpha)then
    local w,h=love.graphics.getDimensions()
    if multiplyCanvas and (multiplyCanvas:getWidth()~=w or multiplyCanvas:getHeight()~=h)then
      multiplyCanvas:release();multiplyCanvas=nil
    end
    multiplyCanvas=multiplyCanvas or love.graphics.newCanvas(w,h,{format='rgba8',msaa=0,dpiscale=1})
    love.graphics.setCanvas(multiplyCanvas);love.graphics.clear(64/255,96/255,128/255,1)
    arm.display:draw(180,100,showMeshes and 4 or 6)
    love.graphics.setCanvas();love.graphics.setColor(1,1,1,1)
    love.graphics.setBlendMode('alpha','premultiplied');love.graphics.draw(multiplyCanvas)
    love.graphics.setBlendMode('alpha','alphamultiply')
  else arm.display:draw(180,100,showMeshes and 4 or 6)end
  love.graphics.setColor(1,1,1,1)
  love.graphics.print('Bono-Lua / LÖVE: atlas + sprites / meshes + animação real',20,20)
  love.graphics.print('Espaço: pausa | R: reinicia | F: espelha | M: mesh | T: atlas',20,40)
  love.graphics.print('B: Screen | N: Multiply | A: alpha da textura | Esc: sair',20,58)
  love.graphics.print(('t=%.2f s | atlas rotacionado: %s | Screen: %s | Multiply: %s | texels alpha: %s'):format(arm.animation.lastAnimationState.currentTime,tostring(showRotation),tostring(showScreen),tostring(showMultiply),tostring(showTextureAlpha)),20,78)
end
function love.keypressed(key)
  if key=='escape'then love.event.quit()
  elseif key=='space'then paused=not paused
  elseif key=='r'then arm.animation:play('move',0)
  elseif key=='f'then arm.flipX=not arm.flipX
  elseif key=='m'or key=='t'or key=='b'or key=='n'or key=='a'then
    close(factory,arm);image:release()
    if key=='m'then showMeshes=not showMeshes
    elseif key=='t'then showRotation=not showRotation
    elseif key=='a'then showTextureAlpha=not showTextureAlpha;showMeshes=false
      if not showScreen and not showMultiply then showScreen=true end
    elseif key=='n'then showMultiply=not showMultiply;showScreen=false;showMeshes=false
    else showScreen=not showScreen;showMultiply=false end
    if showMultiply then factory,arm,image=Blends.scene(showMeshes,showRotation,.5,1,10,showTextureAlpha and TextureAlpha.image or nil)
    elseif showScreen then factory,arm,image=Blends.scene(showMeshes,showRotation,.5,1,12,showTextureAlpha and TextureAlpha.image or nil)
    elseif showRotation then factory,arm,image=Rotated.scene(showMeshes,1,false,false,false,false)
    else image=atlasImage();factory,arm=scene(image,1,1,showMeshes)end
    arm.clock=factory.clock
  end
end
function love.quit()if multiplyCanvas then multiplyCanvas:release()end;if factory then close(factory,arm)end;if image then image:release()end end
