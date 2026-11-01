-- Bono-Lua: application written in Lua. LÖVE 11 supplies window/input/GPU.
-- Run "love ." for the built-in example or put your own DragonBones export
-- at assets/project_ske.json, assets/project_tex.json, assets/project_tex.png.
local DB=require("dragonbones")
local player,armature,clipNames,selected,atlas,prepared,warning
local paused,showBones=false,false
local smokeScreenshot=os.getenv("BONO_LUA_SCREENSHOT")=="1"
local smokeElapsed,screenshotRequested=0,false
local camera={x=480,y=280,zoom=1}
local clipIndex=1

local function read(path)
  return assert(love.filesystem.read(path),"Could not read "..path)
end

local function sampleImage()
  -- An ORIGINAL two-part sample texture, generated in Lua at startup.
  -- Replace by your exported PNG; no Python/JavaScript is required.
  local data=love.image.newImageData(128,64)
  for y=0,63 do
    for x=0,127 do
      local left=x<64
      local partX=x%64
      local inner=partX>=3 and partX<=60 and y>=4 and y<=27
      local border=partX==3 or partX==60 or y==4 or y==27
      local a=inner and 1 or 0
      local r,g,b
      if left then r,g,b=.26,.65,.93 else r,g,b=.97,.66,.26 end
      if border then r,g,b=.12,.18,.27 end
      data:setPixel(x,y,r,g,b,a)
    end
  end
  local image=love.graphics.newImage(data)
  image:setFilter("nearest","nearest")
  return image
end

local function loadProject()
  local projectBytes,atlasBytes,image
  local folder="assets/"
  if love.filesystem.getInfo(folder.."project_ske.json") then
    projectBytes=read(folder.."project_ske.json")
    atlasBytes=read(folder.."project_tex.json")
    image=love.graphics.newImage(folder.."project_tex.png")
    warning="Projeto externo carregado. Recursos avançados ainda não suportados."
  else
    projectBytes=read("tests/fixtures/personagem-minimo.json")
    atlasBytes=read("tests/fixtures/atlas-minimo.json")
    image=sampleImage()
    warning="Exemplo próprio: duas partes com textura. Copie seus JSON/PNG para assets/."
  end
  local project=DB.parser.parse(projectBytes)
  atlas=DB.atlas.parse(atlasBytes)
  local name=project.raw.armature[1].name
  player=DB.animation.new(project,name)
  armature=player.armature
  prepared=DB.love_renderer.prepare(image,atlas)
  clipNames={}
  for _,clip in ipairs(armature.raw.animation or {}) do
    clipNames[#clipNames+1]=clip.name
  end
  clipIndex=1
  if #clipNames>0 then player:play(clipNames[clipIndex]) end
end

function love.load()
  if os.getenv("BONO_LUA_ROTATED_TEST")=="1" then
    local ok,err=pcall(require("tests.love_pixels").run)
    if not ok then io.stderr:write("Rotated atlas pixel test failed: "..tostring(err).."\n") end
    love.event.quit(ok and 0 or 1)
    return
  end
  love.window.setMode(960,600,{resizable=true,minwidth=640,minheight=420})
  love.window.setTitle("Bono-Lua - DragonBones Lua")
  loadProject()
end

function love.update(dt)
  if not paused then player:advance(math.min(dt,.05)) end
  if smokeScreenshot then smokeElapsed=smokeElapsed+dt end
end

function love.draw()
  local w,h=love.graphics.getDimensions()
  camera.x,camera.y=w/2,h/2
  love.graphics.clear(.07,.10,.15)
  love.graphics.push()
  love.graphics.translate(camera.x,camera.y)
  love.graphics.scale(camera.zoom)

  local commands,warnings=DB.atlas.commands(player,atlas)
  DB.love_renderer.draw(prepared,commands)
  if #warnings>0 then
    warning=#warnings.." slot(s) não renderizado(s): recurso ausente ou ainda não suportado."
  end

  if showBones then
    local world=player:world_matrices()
    for _,bone in ipairs(armature.ordered) do
      local m=world[bone.name]
      if bone.parent then
        local parent=world[bone.parent]
        love.graphics.setColor(.41,.67,.92)
        love.graphics.setLineWidth(3)
        love.graphics.line(parent.tx,parent.ty,m.tx,m.ty)
      end
      local chosen=selected==bone.name
      love.graphics.setColor(chosen and 1 or .45,chosen and .72 or .94,.5)
      love.graphics.circle("fill",m.tx,m.ty,chosen and 8 or 5)
    end
  end
  love.graphics.pop()

  love.graphics.setColor(.92,.95,1)
  love.graphics.print("Bono-Lua | Lua + LÖVE 11 | Atlas PNG",16,15)
  love.graphics.print("SPACE pausa | LEFT/RIGHT animação | B ossos | Clique seleciona | R recarrega",16,40)
  love.graphics.print("Animação: "..(player.clip and player.clip.name or "-"),16,70)
  love.graphics.print("Osso: "..(selected or "-"),16,94)
  love.graphics.setColor(.71,.78,.88)
  love.graphics.print(warning or "",16,h-25)
  if smokeScreenshot and smokeElapsed>=.35 and not screenshotRequested then
    screenshotRequested=true
    love.graphics.captureScreenshot(function(imageData)
      imageData:encode("png","bono-lua-preview.png")
      print("Bono-Lua screenshot saved in "..love.filesystem.getSaveDirectory())
      love.event.quit(0)
    end)
  end
end

function love.keypressed(key)
  if key=="space" then
    paused=not paused
    if paused then player:pause() else player:resume() end
  elseif key=="b" then
    showBones=not showBones
  elseif key=="r" then
    selected=nil
    loadProject()
  elseif (key=="left" or key=="right") and #clipNames>0 then
    clipIndex=((clipIndex-1+(key=="right" and 1 or -1))%#clipNames)+1
    player:play(clipNames[clipIndex])
    if paused then player:pause() end
  end
end

function love.mousepressed(mx,my,button)
  if button~=1 then return end
  local x,y=(mx-camera.x)/camera.zoom,(my-camera.y)/camera.zoom
  local nearest,dist=nil,12
  for name,m in pairs(player:world_matrices()) do
    local d=((m.tx-x)^2+(m.ty-y)^2)^.5
    if d<dist then nearest,dist=name,d end
  end
  selected=nearest
end
