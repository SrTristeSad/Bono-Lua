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
else
  error('Uso: lua examples/run.lua inspect [arquivo.json|arquivo.dbbin] [escala]\n     lua examples/run.lua transform\n     lua examples/run.lua bones [arquivo_ske.json]\n     lua examples/run.lua surface')
end
