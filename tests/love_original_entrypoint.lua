-- Real LÖVE graphics regression for the DEFAULT app entrypoint.
-- The displayed bones, slots and animation must be from the original port.
local App=require("dragonbones.original_love_app")
local Love=require("dragonbones.love_original")
local Armature=require("dragonbones.original.armature.Armature")
local Test={}
local function assertVisual(app)
  local target=love.graphics.newCanvas(960,600)
  love.graphics.push("all")
  love.graphics.setCanvas(target)
  app.draw()
  love.graphics.setCanvas()
  love.graphics.pop()
  local pixels=target:newImageData()
  local found=false
  for y=268,336,4 do
    for x=440,678,4 do
      local r,g,b,a=pixels:getPixel(x,y)
      if a>0.98 and (r>0.17 or g>0.2 or b>0.3) then
        found=true
        break
      end
    end
    if found then break end
  end
  assert(found,"Default application did not render an original Armature on LÖVE GPU")
end

function Test.run()
  -- Use committed sample JSON + LÖVE-generated atlas; no external assets.
  local app=assert(App.load())
  assert(getmetatable(app.armature)==Armature,
    "Default love . must build the original Armature, not prototype")
  assert(getmetatable(assert(app.armature:getSlot("upperArm")))==Love.Slot,
    "Default love . must use original Slot with LÖVE Pixi adapter")
  assert(app.armature.clock==app.factory.clock,
    "Original PixiFactory.buildArmatureDisplay must register clock")
  assert(#app.animationNames==3 and
    app.animationNames[1]=="idle" and
    app.animationNames[2]=="walk" and
    app.animationNames[3]=="swap",
    "Original parser did not preserve 3 example animations")
  local upper=assert(app.armature:getSlot("upperArm"))
  assert(upper._renderDisplay.texture~=nil and upper._renderDisplay.quad~=nil,
    "Original image Slot must bind atlas GPU resource")
  assertVisual(App)

  App.keypressed("right")
  assert(app.armature.animation:getState("walk")~=nil,
    "Animation:play from original runtime did not select walk")
  App.keypressed("right")
  assert(app.armature.animation:getState("swap")~=nil,
    "Animation:play from original runtime did not select swap")
  for _=1,7 do App.update(.05) end
  assert(upper.displayIndex==1,
    "Original Slot display timeline should select alternate atlas image")
  for _=1,5 do App.update(.05) end
  assert(upper.displayIndex==-1,
    "Original Slot display timeline should hide the image at the next keyframe")

  App.keypressed("space")
  local before=app.armature.animation:getState("swap").currentTime
  for _=1,4 do App.update(.05) end
  assert(app.armature.animation:getState("swap").currentTime==before,
    "Pause must stop only host clock updates, not fake animation states")
  App.keypressed("space")
  App.keypressed("b")
  assert(app.display.debugDraw==true,
    "B key must use original PixiArmatureDisplay debugDraw")
  App.keypressed("b")
  assert(app.display.debugDraw==false)
  App.keypressed("r")
  local reloaded=assert(App.state())
  assert(reloaded~=app and reloaded.armature~=app.armature,
    "Reload must dispose previous original armature and rebuild")
  assert(getmetatable(reloaded.armature)==Armature)
  assertVisual(App)
  print("Default love . uses ORIGINAL DragonBones Lua: Armature, Slot, clock, timelines, GPU pixels, pause, debug, reload.")
end
return Test
