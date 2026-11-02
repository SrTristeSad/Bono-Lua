-- Bono-Lua entrypoint: original DragonBonesJS runtime port (Lua).
-- LÖVE is only the platform for graphics, window and input.
local App=require("dragonbones.original_love_app")

function love.load()
  -- Existing GPU regression suites use the same original backend.
  if os.getenv("BONO_LUA_ORIGINAL_RENDER_TEST")=="1" then
    local ok,err=pcall(require("tests.love_original_runtime").run)
    if not ok then io.stderr:write("Original DragonBones GPU test failed: "..tostring(err).."\n") end
    love.event.quit(ok and 0 or 1)
    return
  end
  if os.getenv("BONO_LUA_ROTATED_TEST")=="1" then
    local ok,err=pcall(require("tests.love_pixels").run)
    if not ok then io.stderr:write("Rotated atlas GPU test failed: "..tostring(err).."\n") end
    love.event.quit(ok and 0 or 1)
    return
  end
  if os.getenv("BONO_LUA_ORIGINAL_APP_TEST")=="1" then
    local ok,err=pcall(require("tests.love_original_entrypoint").run)
    if not ok then io.stderr:write("Original DragonBones app integration failed: "..tostring(err).."\n") end
    love.event.quit(ok and 0 or 1)
    return
  end
  love.window.setMode(960,600,{resizable=true,minwidth=640,minheight=420})
  love.window.setTitle("Bono-Lua - DragonBones Original em Lua")
  App.load()
end

function love.update(dt) App.update(dt) end
function love.draw() App.draw() end
function love.keypressed(key) App.keypressed(key) end
function love.mousepressed(x,y,button) App.mousepressed(x,y,button) end
