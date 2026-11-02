-- LÖVE application host for the PINNED DragonBonesJS port.
-- DragonBones/DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e (MIT).
-- Runtime/animation/parsing is exclusively dragonbones/original;
-- rendering uses the Pixi adapter in dragonbones/love_original.lua.
-- This module does NOT contain a replacement animation algorithm.
local JSON=require("dragonbones.json")
local Love=require("dragonbones.love_original")
local App={}
local current=nil
local paused=false
local showBones=false
local selected=nil
local clipIndex=1
local screenshot=os.getenv("BONO_LUA_SCREENSHOT")=="1"
local elapsed,screenshotRequested=0,false

local function read(path)
  local bytes,err=love.filesystem.read(path)
  assert(bytes,"Cannot read DragonBones file "..path..": "..tostring(err))
  return bytes
end

local function demoTexture()
  -- Platform-only test texture; the animated geometry comes from the
  -- original ObjectDataParser/Armature/Animation/Slot, not hand-coded poses.
  local pixels=love.image.newImageData(128,64)
  for y=0,63 do
    for x=0,127 do
      local left=x<64
      local px=x%64
      local inside=px>=3 and px<=60 and y>=4 and y<=27
      local edge=px==3 or px==60 or y==4 or y==27
      local r,g,b=left and .26 or .97,left and .65 or .66,left and .93 or .26
      if edge then r,g,b=.12,.18,.27 end
      pixels:setPixel(x,y,r,g,b,inside and 1 or 0)
    end
  end
  local image=love.graphics.newImage(pixels)
  image:setFilter("nearest","nearest")
  return image
end

local function unload()
  if current==nil then return end
  local armature=current.armature
  -- Built by PixiFactory.buildArmatureDisplay: first detach from the
  -- original WorldClock, then let the original deferred disposal run.
  armature.clock=nil
  armature:dispose()
  Love.Factory.advanceTime(0)
  current=nil
end

function App.load()
  unload()
  -- Pixi/BaseFactory.parseDragonBonesData selects ObjectDataParser for
  -- JSON objects and BinaryDataParser for ArrayBuffer. The Lua port uses a
  -- JSON table or raw DBDT bytes to preserve that same parser dispatch.
  -- Keep the established JSON preference when both exports are present.
  local hasJson=love.filesystem.getInfo("assets/project_ske.json")~=nil
  local hasBinary=love.filesystem.getInfo("assets/project_ske.dbbin")~=nil
  local external=hasJson or hasBinary
  local binary=not hasJson and hasBinary
  local skeletonPath=hasJson and "assets/project_ske.json"
      or (binary and "assets/project_ske.dbbin"
      or "tests/fixtures/personagem-minimo.json")
  local atlasPath=external and "assets/project_tex.json"
      or "tests/fixtures/atlas-minimo.json"
  local image=external and love.graphics.newImage("assets/project_tex.png")
      or demoTexture()
  local bytes=read(skeletonPath)
  local skeleton=binary and bytes or JSON.decode(bytes)
  local atlas=JSON.decode(read(atlasPath))
  local factory=Love.Factory.new()
  local data=assert(factory:parseDragonBonesData(skeleton,"project"),
    "Original DragonBones parser could not parse "..skeletonPath)
  local texture=assert(factory:parseTextureAtlasData(atlas,image,"project"),
    "Original DragonBones TextureAtlasData could not parse "..atlasPath)
  -- Source DragonBonesData.armatureNames records the parsed armature order,
  -- independent of whether the header arrived as JSON or DBDT.
  local name=assert(data.armatureNames[1],
    "Original DragonBones parser did not find an armature in "..skeletonPath)
  local display=assert(factory:buildArmatureDisplay(name,"project"),
    "Original DragonBones BaseFactory could not build armature "..tostring(name))
  local armature=assert(display.armature)
  local clipNames=armature.armatureData.animationNames
  current={
    factory=factory,data=data,atlas=texture,display=display,
    armature=armature,animationNames=clipNames,external=external,
    skeletonPath=skeletonPath,
    warning=external and ("Original DragonBones Lua | projeto externo "
      ..(binary and "DBBIN" or "JSON"))
      or "Original DragonBones Lua | exemplo incluido",
  }
  clipIndex=1
  paused=false
  selected=nil
  if #clipNames>0 then
    armature.animation:play(clipNames[clipIndex])
  end
  display.debugDraw=showBones
  -- Original PixiFactory.advanceTime drives DragonBones.clock, including
  -- initial display updates; only the platform supplies elapsed seconds.
  Love.Factory.advanceTime(0)
  return current
end

function App.update(dt)
  assert(current~=nil,"Original DragonBones application not loaded")
  if not paused then Love.Factory.advanceTime(math.min(dt,.05)) end
  if screenshot then elapsed=elapsed+dt end
end

function App.draw()
  assert(current~=nil,"Original DragonBones application not loaded")
  local g=love.graphics
  local w,h=g.getDimensions()
  g.clear(.07,.10,.15)
  g.push("all")
  g.translate(w/2,h/2)
  current.factory:drawArmature(current.armature)
  g.pop()
  g.setColor(.92,.95,1,1)
  g.print("Bono-Lua | DragonBones original portado em Lua | LOVE 11",16,15)
  g.print("SPACE pausa | LEFT/RIGHT animacao | B ossos | Clique seleciona | R recarrega",16,40)
  local names=current.animationNames
  g.print("Animacao: "..(names[clipIndex] or "-")..(paused and " [pausada]" or ""),16,70)
  g.print("Osso: "..(selected or "-"),16,94)
  g.setColor(.71,.78,.88,1)
  g.print(current.warning,16,h-25)
  if screenshot and elapsed>=.35 and not screenshotRequested then
    screenshotRequested=true
    g.captureScreenshot(function(imageData)
      imageData:encode("png","bono-lua-preview.png")
      print("Bono-Lua original runtime screenshot: "..love.filesystem.getSaveDirectory())
      love.event.quit(0)
    end)
  end
end

function App.keypressed(key)
  if key=="space" then
    paused=not paused
  elseif key=="b" then
    showBones=not showBones
    current.display.debugDraw=showBones
    current.armature:advanceTime(0)
  elseif key=="r" then
    App.load()
  elseif (key=="left" or key=="right") and #current.animationNames>0 then
    local delta=key=="right" and 1 or -1
    clipIndex=((clipIndex-1+delta)%#current.animationNames)+1
    current.armature.animation:play(current.animationNames[clipIndex])
    -- Advance within DragonBones, never compute a pose in the UI.
    current.armature:advanceTime(0)
  end
end

function App.mousepressed(mx,my,button)
  if button~=1 then return end
  local w,h=love.graphics.getDimensions()
  local x,y=mx-w/2,my-h/2
  local nearest,distance=nil,12
  for _,bone in ipairs(current.armature:getBones()) do
    local matrix=bone.globalTransformMatrix
    local d=((matrix.tx-x)^2+(matrix.ty-y)^2)^.5
    if d<distance then
      nearest,distance=bone.name,d
    end
  end
  selected=nearest
end

-- Read-only host diagnostics for exercising the ACTUAL application path.
function App.state()
  return current
end

return App
