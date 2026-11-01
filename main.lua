-- Pure Lua application logic. LÖVE 11.x supplies the window and graphics host.
local DB=require("dragonbones")
local player,armature,clipNames,selected
local paused=false
local camera={x=480,y=280,zoom=1}
local function loadProject()
  local bytes=assert(love.filesystem.read("tests/fixtures/personagem-minimo.json"))
  local parsed=DB.parser.parse(bytes)
  local name=parsed.raw.armature[1].name
  player=DB.animation.new(parsed,name)
  armature=player.armature
  clipNames={}
  for _,c in ipairs(armature.raw.animation or {}) do clipNames[#clipNames+1]=c.name end
  if #clipNames>0 then player:play(clipNames[1]) end
end
local clipIndex=1
function love.load()
  love.window.setMode(960,600,{resizable=true,minwidth=640,minheight=420})
  love.window.setTitle("Bono-Lua - DragonBones em Lua (núcleo)")
  loadProject()
end
function love.update(dt)
  if not paused then player:advance(math.min(dt,.05)) end
end
function love.draw()
  local w,h=love.graphics.getDimensions()
  camera.x,camera.y=w/2,h/2
  love.graphics.clear(.07,.10,.15)
  love.graphics.push()
  love.graphics.translate(camera.x,camera.y)
  love.graphics.scale(camera.zoom)
  local world=player:world_matrices()
  for _,bone in ipairs(armature.ordered) do
    local m=world[bone.name]
    local x,y=m.tx,m.ty
    if bone.parent then
      local parent=world[bone.parent]
      love.graphics.setColor(.41,.67,.92)
      love.graphics.setLineWidth(3)
      love.graphics.line(parent.tx,parent.ty,x,y)
    end
    local chosen=selected==bone.name
    love.graphics.setColor(chosen and 1 or .45,chosen and .72 or .94,.5)
    love.graphics.circle("fill",x,y,chosen and 8 or 5)
  end
  love.graphics.pop()
  love.graphics.setColor(.92,.95,1)
  love.graphics.print("Bono-Lua  |  Engine Lua  |  LÖVE 11.x",16,15)
  love.graphics.print("SPACE: pausa  |  LEFT/RIGHT: animação  |  Clique: selecionar osso",16,40)
  love.graphics.print("Animação: "..(player.clip and player.clip.name or "-"),16,70)
  love.graphics.print("Osso selecionado: "..(selected or "-"),16,95)
  love.graphics.print("Prévia somente de ossos. Atlas, meshes e IK ainda não implementados.",16,h-25)
end
function love.keypressed(key)
  if key=="space" then
    paused=not paused
    if paused then player:pause() else player:resume() end
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
