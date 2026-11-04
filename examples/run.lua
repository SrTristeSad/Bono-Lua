-- Run from the repository root with Lua 5.4 or LuaJIT. No JS dependencies.
local mode = arg[1] or 'inspect'
if mode == 'inspect' then
  local path = arg[2] or 'examples/minimal_ske.json'
  local scale = arg[3] == nil and 1 or assert(tonumber(arg[3]), 'Escala inválida')
  local file, message = io.open(path, 'rb')
  assert(file, message)
  local bytes = file:read('*a');file:close()
  local data
  if bytes:sub(1,4) == 'DBDT' then
    local Shared = require('dragonbones.parser.SharedBinaryBuffer')
    data = require('dragonbones.parser.BinaryDataParser').new():parseDragonBonesData(Shared.new(bytes), scale)
  else
    local JSON = require('dragonbones.parser.JSON')
    data = require('dragonbones.parser.ObjectDataParser').new():parseDragonBonesData(JSON.parse(bytes), scale)
  end
  assert(data, 'Arquivo não suportado pelo parser')
  print(('Arquivo: %s | versão: %s | FPS: %g'):format(data.name, data.version, data.frameRate))
  for i=1,data.armatureNames.length do
    local arm = data:getArmature(data.armatureNames[i])
    print(('Armadura: %s | ossos: %d | slots: %d | escala: %g'):format(arm.name,arm.sortedBones.length,arm.sortedSlots.length,arm.scale))
    for j=1,arm.animationNames.length do
      local animation = arm:getAnimation(arm.animationNames[j])
      print(('  Animação: %s | frames: %g | duração: %.6g s'):format(animation.name,animation.frameCount,animation.duration))
    end
  end
  data:returnToPool()
  print('Importação e limpeza concluídas. Este comando não reproduz a animação.')
elseif mode == 'transform' then
  local T = require('dragonbones.armature.TransformObject')
  local Pool = require('dragonbones.core.BaseObject')
  -- Demonstration subclass of the abstract base; this is not a Bone or Slot.
  local Demo = {__newindex=T.__newindex}
  Demo.__index = function(self,key) return rawget(Demo,key) or T.__index(self,key) end
  setmetatable(Demo,{__index=T})
  function Demo.toString() return '[example.TransformObject]' end
  function Demo.new() return T.new(Demo) end
  local object = Pool.borrowObject(Demo)
  local matrix = object.globalTransformMatrix
  matrix.a,matrix.b,matrix.c,matrix.d,matrix.tx,matrix.ty = 0,1,-1,0,40,20
  print(('Antes de atualizar: x=%g y=%g rotação=%g°'):format(object.global.x,object.global.y,object.global.rotation*180/math.pi))
  object._globalDirty = true
  object:updateGlobalTransform()
  print(('Após atualizar: x=%g y=%g rotação=%g°'):format(object.global.x,object.global.y,object.global.rotation*180/math.pi))
  object:returnToPool()
elseif mode == 'bones' then
  local Pool = require('dragonbones.core.BaseObject')
  local Bone = require('dragonbones.armature.Bone')
  local Armature = require('dragonbones.armature.Armature')
  local JSON = require('dragonbones.parser.JSON')
  local Parser = require('dragonbones.parser.ObjectDataParser')
  local file = assert(io.open(arg[2] or 'examples/bones_ske.json', 'rb'))
  local bytes = file:read('*a');file:close()
  local data = assert(Parser.new():parseDragonBonesData(JSON.parse(bytes)))
  local model = assert(data:getArmature(data.armatureNames[1]), 'Sem armadura')
  local armature = Pool.borrowObject(Armature)
  -- Explicit low-level assembly: full Armature.init/Animation is still pending.
  armature._armatureData = model
  for i=1,model.sortedBones.length do
    local boneData = model.sortedBones[i]
    assert(boneData.type==0, 'Surface ainda não é suportado por este exemplo')
    Pool.borrowObject(Bone):init(boneData, armature)
  end
  local function updateAndPrint(label)
    print(label)
    local bones = armature:getBones()
    for i=1,bones.length do
      local bone = bones[i]
      bone:update(-1)
      bone:_updateAlpha()
      bone:updateGlobalTransform()
      print(('  %s: x=%.3f y=%.3f rotação=%.3f°'):format(bone.name,bone.global.x,bone.global.y,bone.global.rotation*180/math.pi))
    end
  end
  armature:invalidUpdate()
  updateAndPrint('Pose inicial:')
  local root = assert(armature:getBones()[1], 'Sem ossos')
  root.offset.rotation = math.pi/2
  root:invalidUpdate()
  updateAndPrint('Após girar o primeiro osso em 90°:')
  armature:returnToPool()
  data:returnToPool()
  print('Hierarquia e limpeza concluídas. Montagem manual, sem reprodução de animação.')
elseif mode == 'timeline' then
  local Pool = require('dragonbones.core.BaseObject')
  local Base = require('dragonbones.animation.BaseTimelineState').DoubleValueTimelineState
  local Parser = require('dragonbones.parser.ObjectDataParser')
  local JSON = require('dragonbones.parser.JSON')
  local Armature = require('dragonbones.armature.Armature')
  local Sample = {};Sample.__index = Sample
  setmetatable(Sample,{__index=Base})
  function Sample.toString() return '[example.TimelineSampler]' end
  function Sample.new() return Base.new(Sample) end
  local file = assert(io.open('examples/timeline_ske.json','rb'))
  local bytes = file:read('*a');file:close()
  local data = assert(Parser.new():parseDragonBonesData(JSON.parse(bytes)))
  local model = data:getArmature('demo')
  local animation = model:getAnimation('idle')
  local timelines = animation:getBoneTimelines('root')
  local timelineData
  for i=1,timelines.length do if timelines[i].type==11 then timelineData=timelines[i] end end
  assert(timelineData,'Sem timeline de translação')
  local armature = Pool.borrowObject(Armature);armature._armatureData=model
  -- Explicit input contract: AnimationState/player is not implemented yet.
  local state = {animationData=animation,_position=0,_duration=animation.duration,
    playTimes=0,currentPlayTimes=0,_playheadState=3}
  local sample = Pool.borrowObject(Sample)
  sample:init(armature,state,timelineData)
  sample._valueOffset=animation.frameFloatOffset
  sample._valueArray=data.frameFloatArray
  for _,time in ipairs({0,.25,.5,.75}) do
    sample:update(time)
    print(('Timeline t=%.2f: x=%.3f y=%.3f'):format(time,sample._resultA,sample._resultB))
  end
  sample:returnToPool();armature:returnToPool();data:returnToPool()
  print('Amostragem de keyframes importados concluída. Sem AnimationState, player ou renderer.')
elseif mode == 'path' then
  local Pool = require('dragonbones.core.BaseObject')
  local Bone = require('dragonbones.armature.Bone')
  local Slot = require('dragonbones.armature.Slot')
  local Armature = require('dragonbones.armature.Armature')
  local Path = require('dragonbones.armature.PathConstraint')
  local Parser = require('dragonbones.parser.ObjectDataParser')
  local JSON = require('dragonbones.parser.JSON')
  -- Local observer supplies abstract display hooks, without a renderer.
  local Observer = {__newindex=Slot.__newindex}
  Observer.__index = function(self,key) return rawget(Observer,key) or Slot.__index(self,key) end
  setmetatable(Observer,{__index=Slot})
  function Observer.toString() return '[example.PathSlotObserver]' end
  function Observer.new() return Slot.new(Observer) end
  function Observer:_initDisplay() end
  function Observer:_disposeDisplay() end
  function Observer:_onUpdateDisplay() end
  function Observer:_addDisplay() end
  local file = assert(io.open('examples/path_ske.json','rb'))
  local bytes = file:read('*a');file:close()
  local data = assert(Parser.new():parseDragonBonesData(JSON.parse(bytes)))
  local model = data:getArmature('arm')
  local armature = Pool.borrowObject(Armature)
  armature._armatureData = model -- Manual assembly until factory/Animation exist.
  for i=1,model.sortedBones.length do
    local bone = Pool.borrowObject(Bone)
    bone:init(model.sortedBones[i],armature);bone:update(-1)
  end
  local slot = Pool.borrowObject(Observer)
  slot:init(model:getSlot('path'),armature,nil,nil)
  slot.displayFrameCount = 1
  slot:replaceRawDisplayData(model.defaultSkin:getDisplay('path','curve'),0)
  slot:_setDisplayIndex(0);slot:_updateDisplayData()
  local constraint = Pool.borrowObject(Path)
  constraint:init(model:getConstraint('follow'),armature)
  armature:_addConstraint(constraint)
  for _,position in ipairs({.25,.5,.75}) do
    constraint.position,constraint.dirty = position,true
    armature:invalidUpdate()
    for i=1,armature:getBones().length do armature:getBones()[i]:update(-1) end
    local a,b = armature:getBone('a').globalTransformMatrix,armature:getBone('b').globalTransformMatrix
    print(('Path %.0f%%: a=(%.3f,%.3f) b=(%.3f,%.3f)'):format(position*100,a.tx,a.ty,b.tx,b.ty))
  end
  armature:returnToPool();data:returnToPool()
  print('Path e limpeza concluídos. Curva ponderada, montagem manual, sem player ou renderer.')
elseif mode == 'ik' then
  local Pool = require('dragonbones.core.BaseObject')
  local Bone = require('dragonbones.armature.Bone')
  local Armature = require('dragonbones.armature.Armature')
  local IK = require('dragonbones.armature.IKConstraint')
  local Parser = require('dragonbones.parser.ObjectDataParser')
  local JSON = require('dragonbones.parser.JSON')
  local file = assert(io.open('examples/ik_ske.json','rb'))
  local bytes = file:read('*a');file:close()
  local data = assert(Parser.new():parseDragonBonesData(JSON.parse(bytes)))
  local model = data:getArmature(data.armatureNames[1])
  local constraintData = assert(model:getConstraint('aim'))
  local armature = Pool.borrowObject(Armature)
  armature._armatureData = model -- Manual assembly until init/factory are ready.
  for i=1,model.sortedBones.length do
    local bd = model.sortedBones[i]
    assert(bd.type==0,'Este exemplo IK usa ossos regulares')
    Pool.borrowObject(Bone):init(bd,armature)
  end
  local tipData = constraintData.bone or constraintData.root
  local tip = armature:getBone(tipData.name)
  local target = armature:getBone(constraintData.target.name)
  local function updateAndPrint(label)
    for i=1,armature:getBones().length do armature:getBones()[i]:update(-1) end
    local m = tip.globalTransformMatrix
    local x,y = m.a*tipData.length+m.tx,m.b*tipData.length+m.ty
    print(('%s: ponta=(%.3f,%.3f) | alvo=(%.3f,%.3f)'):format(label,x,y,target.global.x,target.global.y))
  end
  armature:invalidUpdate()
  updateAndPrint('Sem IK')
  local ik = Pool.borrowObject(IK)
  ik:init(constraintData,armature)
  armature:_addConstraint(ik)
  ik:invalidUpdate()
  updateAndPrint('IK ativo')
  target.offset.x,target.offset.y = -4,4
  armature:invalidUpdate()
  ik:invalidUpdate()
  updateAndPrint('Alvo movido')
  armature:returnToPool()
  data:returnToPool()
  print('IK e limpeza concluídos. Alvo manual, sem player ou renderização.')
elseif mode == 'surface' then
  local Pool = require('dragonbones.core.BaseObject')
  local Bone = require('dragonbones.armature.Bone')
  local Surface = require('dragonbones.armature.Surface')
  local Armature = require('dragonbones.armature.Armature')
  local JSON = require('dragonbones.parser.JSON')
  local Parser = require('dragonbones.parser.ObjectDataParser')
  local file = assert(io.open('examples/surface_ske.json', 'rb'))
  local bytes = file:read('*a');file:close()
  local data = assert(Parser.new():parseDragonBonesData(JSON.parse(bytes)))
  local model = assert(data:getArmature('surface-demo'))
  local armature = Pool.borrowObject(Armature)
  -- Same explicit low-level assembly; no substitute Animation or factory.
  armature._armatureData = model
  for i=1,model.sortedBones.length do
    local boneData = model.sortedBones[i]
    Pool.borrowObject(boneData.type==1 and Surface or Bone):init(boneData,armature)
  end
  local grid = assert(armature:getBone('grid'))
  local attached = assert(armature:getBone('attached'))
  local function updateAndPrint(label)
    local bones = armature:getBones()
    for i=1,bones.length do bones[i]:update(-1);bones[i]:_updateAlpha() end
    attached:updateGlobalTransform()
    print(('%s: attached x=%.3f y=%.3f'):format(label,attached.global.x,attached.global.y))
  end
  armature:invalidUpdate()
  updateAndPrint('Grade sem deformação')
  grid._deformVertices[10] = 80.0 -- Center vertex Y, Lua index 10 (JS index 9).
  grid:invalidUpdate()
  updateAndPrint('Centro da grade deslocado em +80 no eixo Y')
  armature:returnToPool()
  data:returnToPool()
  print('Surface e limpeza concluídas. Deformação manual, sem player ou renderização.')
elseif mode == 'slot' or mode == 'slotdata' or mode == 'slotruntime' then
  local Pool = require('dragonbones.core.BaseObject')
  local Slot = require('dragonbones.armature.Slot')
  local Bone = require('dragonbones.armature.Bone')
  local Armature = require('dragonbones.armature.Armature')
  local Models = require('dragonbones.model.ArmatureData')
  local Color = require('dragonbones.geom.ColorTransform')
  local Box = require('dragonbones.model.BoundingBoxData').RectangleBoundingBoxData
  local Parser = require('dragonbones.parser.ObjectDataParser')
  local JSON = require('dragonbones.parser.JSON')
  -- This local observer only records abstract hooks; it draws no display.
  -- It is an example subclass, not a product renderer or Slot.update substitute.
  local Probe = {__newindex=Slot.__newindex}
  Probe.__index = function(self,key)
    local member = rawget(Probe,key)
    if member ~= nil then return member end
    return Slot.__index(self,key)
  end
  setmetatable(Probe,{__index=Slot})
  function Probe.toString() return '[example.SlotObserver]' end
  function Probe.new()
    local self = Slot.new(Probe)
    self.calls = {}
    return self
  end
  for _,name in ipairs({'_initDisplay','_disposeDisplay','_onUpdateDisplay','_addDisplay','_replaceDisplay','_removeDisplay','_updateZOrder','_updateVisible','_updateBlendMode','_updateColor','_updateFrame','_updateMesh','_updateTransform','_identityTransform'}) do
    local hook = name
    Probe[hook] = function(self) self.calls[#self.calls+1] = hook end
  end
  local file = assert(io.open('examples/bones_ske.json','rb'))
  local bytes = file:read('*a');file:close()
  local data = assert(Parser.new():parseDragonBonesData(JSON.parse(bytes)))
  local model = data:getArmature(data.armatureNames[1])
  local armature = Pool.borrowObject(Armature)
  armature._armatureData = model -- Explicit low-level assembly; no factory/player.
  for i=1,model.sortedBones.length do Pool.borrowObject(Bone):init(model.sortedBones[i],armature) end
  local slotData = Pool.borrowObject(Models.SlotData)
  slotData.name = 'probe'
  slotData.parent = model:getBone('child')
  slotData.color = Color.new()
  model:addSlot(slotData)
  local slot = Pool.borrowObject(Probe)
  slot:init(slotData,armature,nil,nil)
  if mode == 'slotdata' then
    local Displays = require('dragonbones.model.DisplayData')
    local Skin = require('dragonbones.model.SkinData')
    local Textures = require('dragonbones.model.TextureAtlasData')
    -- Real texture metadata, constructed directly: no graphics resource/backend.
    local atlas = Textures.TextureAtlasData.new(Textures.TextureAtlasData)
    atlas:_onClear()
    local function texture(width,height)
      local value = Textures.TextureData.new(Textures.TextureData)
      value:_onClear()
      value.parent = atlas
      value.region.width,value.region.height = width,height
      return value
    end
    local raw = Pool.borrowObject(Displays.ImageDisplayData)
    raw.pivot.x,raw.pivot.y = .5,.5
    raw.transform.x = 5
    raw.texture = texture(100,80)
    local replacement = Pool.borrowObject(Displays.ImageDisplayData)
    replacement.pivot.x,replacement.pivot.y = .25,.25
    replacement.transform.x = 15
    replacement.texture = texture(200,120)
    local skin = Pool.borrowObject(Skin)
    skin.name = 'slotdata-example'
    skin:addDisplay('probe',raw)
    skin:addDisplay('replacement',replacement)
    model:addSkin(skin)
    slot.displayFrameCount = 1
    slot:_setDisplayIndex(0)
    slot:replaceRawDisplayData(raw,0)
    slot:_updateDisplayData() -- Direct low-level call until Slot.update exists.
    print(('Display original: pivô=(%g,%g) | origem x=%g'):format(slot._pivotX,slot._pivotY,slot.origin.x))
    slot:replaceDisplayData(replacement,0)
    slot:_updateDisplayData()
    print(('Display substituto: pivô=(%g,%g) | origem x=%g'):format(slot._pivotX,slot._pivotY,slot.origin.x))
  end
  local box = Pool.borrowObject(Box)
  box.width,box.height = 10,10
  if mode == 'slotruntime' then
    local Array = require('dragonbones.core.JSArray')
    local Displays = require('dragonbones.model.DisplayData')
    local Skin = require('dragonbones.model.SkinData')
    local skin = Pool.borrowObject(Skin)
    skin.name = 'slotruntime-example'
    local hit = Pool.borrowObject(Displays.BoundingBoxDisplayData)
    hit.boundingBox = box -- Owned by hit data; released with the skin below.
    skin:addDisplay('hitbox',hit)
    local list = Array.new()
    list[1],list[2] = {name='espada'},{name='escudo'}
    slot.displayList = list
    for index=0,1 do
      local image = Pool.borrowObject(Displays.ImageDisplayData)
      image.transform.x = 5
      skin:addDisplay('probe',image)
      slot:replaceRawDisplayData(image,index)
      slot:replaceDisplayData(hit,index)
    end
    model:addSkin(skin)
    slot.displayIndex = 0 -- Public setter executes Slot.update(-1).
    print(('Índice %d: display=%s'):format(slot.displayIndex,slot.display.name))
    slot.displayIndex = 1
    print(('Índice %d: display=%s'):format(slot.displayIndex,slot.display.name))
  end
  slot._boundingBoxData = box -- Direct assignment in the earlier low-level examples.
  if mode ~= 'slotruntime' then slot._localMatrix.tx = 5 end
  local function updateAndPrint(label)
    for i=1,armature:getBones().length do
      local bone = armature:getBones()[i]
      bone:update(-1);bone:_updateAlpha()
    end
    slot:_updateAlpha()
    if mode == 'slotruntime' then
      slot:invalidUpdate();slot:update(-1)
    else
      slot._transformDirty = true
      slot:updateTransformAndMatrix()
    end
    local m = slot.globalTransformMatrix
    print(('%s: slot x=%.3f y=%.3f | centro dentro da caixa: %s'):format(label,m.tx,m.ty,tostring(slot:containsPoint(m.tx,m.ty))))
  end
  armature:invalidUpdate()
  updateAndPrint('Pose inicial')
  local root = armature:getBone('root')
  root.offset.x = 10
  root:invalidUpdate()
  updateAndPrint('Pai deslocado em +10 no eixo X')
  slot.parent.visible = false
  print(('Slot registrado: %s | hooks observados: %d'):format(tostring(armature:getSlot('probe')==slot),#slot.calls))
  armature:returnToPool()
  if mode ~= 'slotruntime' then box:returnToPool() end
  data:returnToPool()
  print('Slot e limpeza concluídos. Montagem manual e observador local, sem renderer/player.')
elseif mode == 'displayframe' then
  local Pool = require('dragonbones.core.BaseObject')
  local Frame = require('dragonbones.armature.DisplayFrame')
  local Models = require('dragonbones.model.DisplayData')
  local Data = require('dragonbones.model.DragonBonesData')
  local Shared = require('dragonbones.parser.SharedBinaryBuffer')
  local data = Pool.borrowObject(Data)
  data.intArray = Shared.view(Shared.new(string.char(3,0)),0,2,'int16')
  local mesh = Pool.borrowObject(Models.MeshDisplayData)
  mesh.geometry.data = data
  local frame = Pool.borrowObject(Frame)
  frame.rawDisplayData = mesh
  frame:updateDeformVertices()
  print(('Malha com 3 vértices: %d componentes de deformação'):format(frame.deformVertices.length))
  frame.deformVertices[2] = 12
  frame:updateDeformVertices()
  print(('Atualizar novamente preserva a edição: Y=%g'):format(frame.deformVertices[2]))
  frame:returnToPool()
  mesh:returnToPool()
  data:returnToPool()
  print('DisplayFrame e limpeza concluídos. Sem renderização ou player.')
else
  error('Uso: lua examples/run.lua inspect [arquivo.json|arquivo.dbbin] [escala]\n     lua examples/run.lua transform\n     lua examples/run.lua bones [arquivo_ske.json]\n     lua examples/run.lua surface\n     lua examples/run.lua displayframe\n     lua examples/run.lua slot\n     lua examples/run.lua slotdata\n     lua examples/run.lua slotruntime\n     lua examples/run.lua ik\n     lua examples/run.lua path\n     lua examples/run.lua timeline')
end
