-- Headless use of the same public API used by the graphical LÖVE adapter.
-- No renderer mock or manual Bone/Slot/clock construction is needed.
local Factory=require('dragonbones.love.Factory')
local JSON=require('dragonbones.parser.JSON')
local file=assert(io.open('examples/public_factory_ske.json','rb'))
local raw=JSON.parse(file:read('*a'));file:close()
local factory=Factory.factory
factory:parseDragonBonesData(raw,'example')
local display=assert(factory:buildArmatureDisplay('demo','example'))
local function frame(_,event)print('frame: '..event.name)end
local function sound(_,event)print('sound: '..event.name)end
-- Context (JavaScript this) is the first Lua callback argument.
display:addDBEventListener('frameEvent',frame)
factory.soundEventManager:addDBEventListener('soundEvent',sound)
display.animation:play('move',0)
for i=1,4 do
  factory:update(.25)
  print(('root.x=%.2f'):format(display.armature:getBone('root').globalTransformMatrix.tx))
end
display:dispose();factory:update(0)
factory.soundEventManager:removeDBEventListener('soundEvent',sound)
factory:clear();factory:update(0)
