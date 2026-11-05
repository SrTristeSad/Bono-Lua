-- Low-level playback with real Animation/State/Bone/Surface/Slot objects.
-- The display backend only counts callbacks; it does not draw pixels.
local B=require('dragonbones.core.BaseObject')
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
arm._armatureData=model
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
-- Until the playConfig facade/factory is ported, assembly and registration are explicit.
local animation=B.borrowObject(require('dragonbones.animation.Animation'))
animation:init(arm);arm._animation=animation
local config=B.borrowObject(require('dragonbones.model.AnimationConfig'))
config.animation='move';config.timeScale=1;config.playTimes=0
config.fadeInTime=0;config.pauseFadeIn=false;config.resetToPose=false;config.actionEnabled=false
local state=B.borrowObject(require('dragonbones.animation.AnimationState'))
state:init(arm,model:getAnimation('move'),config)
animation._animationStates[1]=state
animation._lastAnimationState=state
for _,delta in ipairs({0,.25,.25,.25})do
  animation:advanceTime(delta)
  for i=1,arm:getBones().length do
    local bone=arm:getBones()[i];bone:update(-1);bone:_updateAlpha()
  end
  for i=1,arm:getSlots().length do
    local slot=arm:getSlots()[i];slot:_updateAlpha();slot:update(-1)
  end
  local root=arm:getBone('root')
  print(('t=%.2f | root pose.x=%.2f | mundo.x=%.2f | display=%d'):format(state.currentTime,root.animationPose.x,root.globalTransformMatrix.tx,arm:getSlot('meshSlot').displayIndex))
end
print(('Reprodução por delta concluída; %d callbacks do backend de observação. Sem desenho na tela.'):format(callbacks))
arm:returnToPool();config:returnToPool();data:returnToPool()
