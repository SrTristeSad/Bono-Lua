local JSON=require('dragonbones.parser.JSON')
local factory=require('examples.ObserverFactory').new()
local file=assert(io.open('examples/playback_ske.json','rb'))
assert(factory:parseDragonBonesData(JSON.parse(file:read('*a')),'demo'))
file:close()
local atlas=assert(io.open('examples/factory_tex.json','rb'))
factory:parseTextureAtlasData(JSON.parse(atlas:read('*a')),{},'demo')
atlas:close()
local armature=assert(factory:buildArmature('playback','demo'))
print(('Montagem automática: %d bones | %d slots | %d constraints'):format(
  armature:getBones().length,armature:getSlots().length,armature._constraints.length))
local state=assert(armature.animation:play('move',0))
armature.clock=factory.clock
for _,delta in ipairs({0,.25,.25,.25})do
  factory.dragonBones:advanceTime(delta)
  local root=armature:getBone('root')
  print(('t=%.2f | pose.x=%.2f | mundo.x=%.2f | display=%d'):format(
    state.currentTime,root.animationPose.x,root.globalTransformMatrix.tx,
    armature:getSlot('meshSlot').displayIndex))
end
print(('Frames observados: %d | eventos: %d | sem desenho na tela.'):format(factory.frames,factory.events))
armature:dispose()
factory.dragonBones:advanceTime(0)
factory:clear()
factory.dragonBones:advanceTime(0)
