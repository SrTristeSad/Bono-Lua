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
elseif mode == 'slot' or mode == 'slotdata' then
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
  for _,name in ipairs({'_initDisplay','_disposeDisplay','_onUpdateDisplay','_addDisplay','_updateVisible'}) do
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
  slot._boundingBoxData = box -- Manual assignment until display evaluation exists.
  slot._localMatrix.tx = 5
  local function updateAndPrint(label)
    for i=1,armature:getBones().length do
      local bone = armature:getBones()[i]
      bone:update(-1);bone:_updateAlpha()
    end
    slot:_updateAlpha()
    slot._transformDirty = true
    slot:updateTransformAndMatrix()
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
  box:returnToPool()
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
  error('Uso: lua examples/run.lua inspect [arquivo.json|arquivo.dbbin] [escala]\n     lua examples/run.lua transform\n     lua examples/run.lua bones [arquivo_ske.json]\n     lua examples/run.lua surface\n     lua examples/run.lua displayframe\n     lua examples/run.lua slot\n     lua examples/run.lua slotdata')
end
