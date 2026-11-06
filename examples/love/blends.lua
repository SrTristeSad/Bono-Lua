-- Screen blend demo/captures use real runtime objects and asymmetric atlas input.
local JSON=require('dragonbones.parser.JSON')
local Factory=require('dragonbones.love.Factory')
local Rotated=require('examples.love.rotated')
local B={}
function B.scene(mesh,rotated,alpha,tint,mode,imageMaker)
  local raw=JSON.parse(love.filesystem.read(mesh and'examples/love/meshes_ske.json'or'examples/love/sprites_ske.json'))
  for i=1,raw.armature[1].slot.length do
    local slot=raw.armature[1].slot[i]
    slot.blendMode=mode or 12
    slot.color={aM=alpha*100,rM=tint*100,gM=100,bM=100}
  end
  local atlas=JSON.parse(love.filesystem.read('examples/love/rotated_tex.json'))
  if not rotated then
    for i=1,atlas.SubTexture.length do atlas.SubTexture[i].rotated=false end
  end
  local image=imageMaker and imageMaker(false)or Rotated.image(false)
  local factory=Factory.new()
  factory:parseDragonBonesData(raw,'sprites')
  factory:parseTextureAtlasData(atlas,image,'sprites')
  local arm=factory:buildArmature('demo','sprites');arm.animation:play('move',0)
  return factory,arm,image
end
function B.capture(output)
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
    local factory,arm,image=B.scene(c[4],c[3],c[1],c[2])
    arm.flipX=i%3==0
    if i%4==0 and not c[4]then arm:getSlot('red')._zIndex=3;arm._zIndexDirty=true end
    arm:advanceTime(.25)
    local canvas=love.graphics.newCanvas(160,128,{format='rgba8',msaa=0})
    love.graphics.push('all');love.graphics.setCanvas(canvas);love.graphics.origin()
    love.graphics.clear(64/255,96/255,128/255,1)
    love.graphics.setColor(.2,.3,.4,.5);love.graphics.setBlendMode('replace','premultiplied')
    local shader=love.graphics.getShader()
    arm.display:draw(64,32)
    local blend,alpha=love.graphics.getBlendMode()
    assert(blend=='replace'and alpha=='premultiplied'and love.graphics.getShader()==shader,'Draw must restore host state')
    love.graphics.setCanvas();love.graphics.pop()
    local data=canvas:newImageData()
    local f=assert(io.open(output..'/love-blend-'..(i-1)..'.rgba','wb'));f:write(data:getString());f:close()
    local png=data:encode('png');f=assert(io.open(output..'/love-blend-'..(i-1)..'.png','wb'));f:write(png:getString());f:close()
    png:release();data:release();canvas:release()
    arm:dispose();factory.dragonBones:advanceTime(0);factory:clear();factory.dragonBones:advanceTime(0);image:release()
  end
end
return B
