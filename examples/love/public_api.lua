-- Real LÖVE smoke test of the complete factory/proxy integration.
local Factory=require('dragonbones.love.Factory')
local JSON=require('dragonbones.parser.JSON')
return function()
  local factory=Factory.factory
  local raw=JSON.parse(love.filesystem.read('examples/public_factory_ske.json'))
  for i=1,raw.armature[1].slot.length do raw.armature[1].slot[i].displayIndex=1 end
  factory:parseDragonBonesData(raw,'public-api')
  local display=assert(factory:buildArmatureDisplay('demo','public-api'))
  assert(display.armature.clock==factory.clock and display.animation==display.armature.animation)
  local frames,sounds=0,0
  local function frame(_,event)assert(event.armature==display.armature);frames=frames+1 end
  local function sound(_,event)assert(event.type=='soundEvent');sounds=sounds+1 end
  display:addDBEventListener('frameEvent',frame)
  factory.soundEventManager:addDBEventListener('soundEvent',sound)
  display.debugDraw=true;display.animation:play('move',0);factory:update(.25)
  local canvas=love.graphics.newCanvas(160,128,{format='rgba8',msaa=0})
  love.graphics.push('all');love.graphics.setCanvas(canvas);love.graphics.origin()
  love.graphics.clear(0,0,0,1);display:draw(64,32)
  assert(display._debugDrawer and #display._debugDrawer.children==4)
  love.graphics.setCanvas();love.graphics.pop();canvas:release()
  assert(frames>0 and sounds>0)
  local armature=display.armature;display:dispose();factory:update(0)
  assert(display.armature==nil and display._debugDrawer==nil and not factory.clock:contains(armature))
  factory.soundEventManager:removeDBEventListener('soundEvent',sound)
  factory:clear();factory:update(0)
  local output=os.getenv('BONO_PUBLIC_API_OUTPUT')
  if output then
    local file=assert(io.open(output..'/public-api-result.json','wb'))
    file:write(('{\"frameEvents\":%d,\"soundEvents\":%d,\"boundingBoxes\":3,\"clockReleased\":true,\"result\":\"passed\"}\n'):format(frames,sounds));file:close()
  end
  print('Public factory/proxy: real LÖVE debug geometry, clock, frame/sound events and disposal passed.')
end
