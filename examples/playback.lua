-- Low-level playback with real Animation/State/Bone/Surface/Slot objects.
-- The display backend only counts callbacks; it does not draw pixels.
local B=require('dragonbones.core.BaseObject')
local useArmature=arg[1]=='armature'
local frames,events=0,0
local Slot=require('dragonbones.armature.Slot')
local Observer={__newindex=Slot.__newindex}
Observer.__index=function(self,key)return rawget(Observer,key)or Slot.__index(self,key)end
setmetatable(Observer,{__index=Slot})
function Observer.toString()return'[example.PlaybackSlot]'end
function Observer.new()return Slot.new(Observer)end
local callbacks=0
for _,hook in ipairs({'_initDisplay','_disposeDisplay','_onUpdateDisplay','_addDisplay','_replaceDisplay','_removeDisplay','_updateZOrder','_updateVisible','_updateBlendMode','_updateColor','_updateFrame','_updateMesh','_updateTransform','_identityTransform'})do
  Observer[hook]=function()callbacks=callbacks+1 end
end
local file=assert(io.open('examples/playback_ske.json','rb'))
local data=require('dragonbones.parser.ObjectDataParser').new():parseDragonBonesData(require('dragonbones.parser.JSON').parse(file:read('*a')))
file:close()
local model=data:getArmature('playback')
local arm=B.borrowObject(require('dragonbones.armature.Armature'))
if not useArmature then arm._armatureData=model end
local proxy={}
function proxy:hasDBEventListener()return useArmature end
function proxy:dbInit(value)assert(value==arm)end
function proxy:dbUpdate()frames=frames+1 end
function proxy:dispatchDBEvent()events=events+1 end
function proxy:dbClear()end
local sound={};function sound:dispatchDBEvent()end
local core=require('dragonbones.core.DragonBones').new(sound)
if useArmature then arm:init(model,proxy,{},core)else arm._proxy=proxy;arm._dragonBones=core end
for i=1,model.sortedBones.length do
  local bd=model.sortedBones[i]
  local class=require(bd.type==1 and 'dragonbones.armature.Surface' or 'dragonbones.armature.Bone')
  B.borrowObject(class):init(bd,arm)
end
for i=1,model.sortedSlots.length do
  local sd=model.sortedSlots[i]
  local slot=B.borrowObject(Observer);slot:init(sd,arm,{}, {})
  local displays=model.defaultSkin:getDisplays(sd.name)
  slot.displayFrameCount=displays.length
  for j=1,displays.length do
    slot:replaceRawDisplayData(displays[j],j-1)
    slot:replaceDisplay(displays[j].type==2 and slot.meshDisplay or slot.rawDisplay,j-1)
  end
  slot:_setDisplayIndex(0);slot:_updateDisplayData()
end
-- Bone/Slot assembly is explicit until a factory/backend is available.
local animation
if useArmature then
  animation=arm.animation
  local Map=require('dragonbones.core.JSMap')
  for _,name in ipairs(Map.keys(model.constraints))do
    local ik=B.borrowObject(require('dragonbones.armature.IKConstraint'))
    ik:init(model.constraints[name],arm);arm:_addConstraint(ik)
  end
  arm.clock=core.clock
else
  animation=B.borrowObject(require('dragonbones.animation.Animation'))
  animation:init(arm);arm._animation=animation
  animation.animations=model.animations
end
local state=assert(animation:play('move',0))
state.actionEnabled=useArmature;state.resetToPose=false
for _,delta in ipairs({0,.25,.25,.25})do
  if useArmature then core:advanceTime(delta)else
  animation:advanceTime(delta)
  for i=1,arm:getBones().length do
    local bone=arm:getBones()[i];bone:update(-1);bone:_updateAlpha()
  end
  for i=1,arm:getSlots().length do
    local slot=arm:getSlots()[i];slot:_updateAlpha();slot:update(-1)
  end
  end
  local root=arm:getBone('root')
  print(('t=%.2f | root pose.x=%.2f | mundo.x=%.2f | display=%d'):format(state.currentTime,root.animationPose.x,root.globalTransformMatrix.tx,arm:getSlot('meshSlot').displayIndex))
end
print(('Reprodução por delta concluída; %d callbacks do backend de observação. Sem desenho na tela.'):format(callbacks))
if useArmature then
  print(('Quadros pelo relógio: %d | eventos: %d | lock=%s'):format(frames,events,tostring(arm._lockUpdate)))
end
if arg[1]=='animation' then
  animation:stop('move')
  local resumed=animation:play()
  print('play() retoma o mesmo estado: '..tostring(resumed==state))
  local paused=assert(animation:gotoAndStopByFrame('move',12))
  paused.actionEnabled=false
  animation:advanceTime(0)
  print(('gotoAndStopByFrame(12): t=%.2f | tocando=%s'):format(paused.currentTime,tostring(paused.isPlaying)))
  local nextState=assert(animation:fadeIn('alt',.25,0))
  nextState.actionEnabled=false
  animation:advanceTime(.125)
  print(('fadeIn alt: progresso=%.2f | estados=%d'):format(nextState._fadeProgress,animation:getStates().length))
  animation:reset()
  print(('reset: estados=%d | tocando=%s'):format(animation:getStates().length,tostring(animation.isPlaying)))
end
arm.clock=nil
core:advanceTime(0);core:advanceTime(0)
arm:returnToPool();data:returnToPool()
