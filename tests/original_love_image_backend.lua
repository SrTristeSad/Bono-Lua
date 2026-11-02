-- LÖVE adapter boundary tests for the original DragonBones runtime.
-- Uses real ObjectDataParser/Armature/Slot/WorldClock/TextureAtlasData;
-- LÖVE calls are mocked only to check the adapter without a GPU.
package.path="./?.lua;./?/init.lua;"..package.path
local Love=require("dragonbones.love_original")
local BaseObject=require("dragonbones.original.core.BaseObject")
local Armature=require("dragonbones.original.armature.Armature")
local Core=require("dragonbones.original.core.DragonBones")
local passed,failed,checks=0,0,0
local function eq(a,b)
  checks=checks+1
  assert(a==b,tostring(a).." ~= "..tostring(b))
end
local function near(a,b)
  checks=checks+1
  assert(type(a)=="number" and type(b)=="number" and math.abs(a-b)<1e-7,
    tostring(a).." ~= "..tostring(b))
end
local function test(name,fn)
  local ok,err=pcall(fn)
  if ok then
    passed=passed+1
    print("ok original.love_backend "..name)
  else
    failed=failed+1
    print("not ok original.love_backend "..name..": "..tostring(err))
  end
end
local state={}
local function fakeLove()
  state={draws={},quads={},colors={},blends={},matrices={},push=0,pop=0}
  _G.love={
    graphics={
      newQuad=function(x,y,w,h,iw,ih)
        local q={x=x,y=y,w=w,h=h,iw=iw,ih=ih}
        state.quads[#state.quads+1]=q
        return q
      end,
      push=function(mode)
        state.push=state.push+1
        eq(mode,"all")
      end,
      pop=function() state.pop=state.pop+1 end,
      setBlendMode=function(mode)
        state.blends[#state.blends+1]=mode
      end,
      setColor=function(r,g,b,a)
        state.colors[#state.colors+1]={r,g,b,a}
      end,
      applyTransform=function(transform)
        state.matrices[#state.matrices+1]=transform.matrix
      end,
      draw=function(image,quad,x,y)
        state.draws[#state.draws+1]={image=image,quad=quad,x=x,y=y}
      end
    },
    math={
      newTransform=function()
        return {setMatrix=function(self,...)
          self.matrix={...}
        end}
      end
    }
  }
end
local function image(width,height)
  return {getWidth=function() return width end,
    getHeight=function() return height end}
end
local function sample()
  return {
    version="5.5",name="Example",frameRate=24,
    armature={{name="rig",bone={{name="root",transform={x=4,y=5}}},
      slot={{name="one",parent="root",displayIndex=0}},
      skin={{name="default",slot={{name="one",display={{
        name="red",path="red",pivot={x=0,y=0},type="image"
      },{
        name="blue",path="blue",pivot={x=0,y=0},type="image"
      }}}}}}
    }}
  }
end
local function atlas()
  return {name="atlas",width=8,height=4,SubTexture={
    {name="red",x=0,y=0,width=4,height=4},
    {name="blue",x=4,y=0,width=4,height=4}
  }}
end
local function build(raw,atlasRaw)
  fakeLove()
  local f=Love.Factory.new()
  local data=f:parseDragonBonesData(raw or sample(),"pack")
  local a=f:parseTextureAtlasData(atlasRaw or atlas(),image(8,4),"pack")
  local rig=f:buildArmature("rig","pack")
  return f,data,a,rig
end
test("factory uses genuine BaseFactory, DragonBones, Slot, Armature classes",function()
  local f,data,a,rig=build()
  eq(getmetatable(rig),Armature)
  eq(getmetatable(rig:getSlot("one")),Love.Slot)
  eq(getmetatable(a),Love.TextureAtlasData)
  eq(type(f.dragonBones.advanceTime),"function")
  eq(f:getDragonBonesData("pack"),data)
end)
test("factory uses parsed atlas model with LÖVE image and two texture nodes",function()
  local f,data,a,rig=build()
  eq(a.image~=nil,true)
  eq(a:getTexture("red").region.x,0)
  eq(a:getTexture("blue").region.x,4)
  eq(getmetatable(a:getTexture("blue")),Love.TextureData)
end)
test("initial pose from real original Slot creates the right LÖVE atlas quad",function()
  local f,data,a,rig=build()
  local slot=rig:getSlot("one")
  local r=slot._renderDisplay
  eq(r.texture,a.image)
  eq(r.quad.x,0)
  eq(r.quad.y,0)
  eq(r.quad.w,4)
  eq(r.quad.h,4)
  eq(slot.displayIndex,0)
end)
test("draw uses a transformed quad, not prototype command rendering",function()
  local f,data,a,rig=build()
  f:drawArmature(rig)
  eq(#state.draws,1)
  eq(state.draws[1].image,a.image)
  eq(state.draws[1].quad.x,0)
  eq(state.draws[1].x,0)
  near(state.matrices[1][4],4)
  near(state.matrices[1][8],5)
end)
test("draw sets color and balanced LÖVE transformation stack",function()
  local f,data,a,rig=build()
  f:drawArmature(rig)
  eq(state.colors[1][1],1)
  eq(state.colors[1][4],1)
  eq(state.blends[1],"alpha")
  eq(state.push,1)
  eq(state.pop,1)
end)
test("displayIndex switches to second texture after original runtime update",function()
  local f,data,a,rig=build()
  local slot=rig:getSlot("one")
  slot.displayIndex=1
  rig:advanceTime(0)
  eq(slot.displayIndex,1)
  eq(slot._renderDisplay.quad.x,4)
  f:drawArmature(rig)
  eq(#state.draws,1)
  eq(state.draws[1].quad.x,4)
end)
test("slot hiding omits draw calls without destroying original data",function()
  local f,data,a,rig=build()
  local slot=rig:getSlot("one")
  slot.displayIndex=-1
  rig:advanceTime(0)
  eq(slot.displayIndex,-1)
  f:drawArmature(rig)
  eq(#state.draws,0)
  eq(slot:getDisplayFrameAt(0).rawDisplayData.name,"red")
end)
test("slot color multiplier is forwarded to the LÖVE draw call",function()
  local f,data,a,rig=build()
  local slot=rig:getSlot("one")
  local c=slot._colorTransform
  c.redMultiplier=0.5
  c.greenMultiplier=0.25
  c.alphaMultiplier=0.75
  slot._colorDirty=true
  rig:advanceTime(0)
  f:drawArmature(rig)
  near(state.colors[1][1],0.5)
  near(state.colors[1][2],0.25)
  near(state.colors[1][4],0.75)
end)
test("slot visible false is respected even when the texture is loaded",function()
  local f,data,a,rig=build()
  local slot=rig:getSlot("one")
  slot.visible=false
  rig:advanceTime(0)
  f:drawArmature(rig)
  eq(#state.draws,0)
end)
test("atlas rotated texture applies packed de-rotation matrix",function()
  local rotated={name="atlas",width=4,height=5,SubTexture={{
    name="red",x=0,y=0,width=2,height=3,rotated=true
  }}}
  local r=sample()
  r.armature[1].bone[1].transform={x=0,y=0}
  local f,data,a,rig=build(r,rotated)
  f:drawArmature(rig)
  local m=state.matrices[1]
  eq(state.draws[1].quad.w,2)
  near(m[1],0)
  near(m[2],1)
  near(m[5],-1)
  near(m[8],0)
end)
test("unsupported geometry mesh rejects instead of silently rendering an image",function()
  fakeLove()
  local f=Love.Factory.new()
  local raw=sample()
  raw.armature[1].skin[1].slot[1].display[1]={
    name="red",type="mesh",vertices={0,0,2,0,2,2},
    uvs={0,0,1,0,1,1},triangles={0,1,2}
  }
  f:parseDragonBonesData(raw,"pack")
  f:parseTextureAtlasData(atlas(),image(8,4),"pack")
  local ok,err=pcall(function() f:buildArmature("rig","pack") end)
  eq(ok,false)
  eq(type(err),"string")
  eq(err:find("mesh/FFD",1,true)~=nil,true)
end)
test("backend data and atlas maps are exposed via original BaseFactory API",function()
  local f,data,a,rig=build()
  eq(f:getAllDragonBonesData().pack,data)
  eq(f:getTextureAtlasData("pack")[1],a)
  eq(f:getArmatureData("rig","pack"),rig.armatureData)
end)
test("factory event dispatcher supports add, dispatch and remove listeners",function()
  local f=Love.Factory.new()
  local count=0
  local fn=function() count=count+1 end
  f._eventManager:addDBEventListener("event",fn)
  f._eventManager:dispatchDBEvent("event",{})
  f._eventManager:removeDBEventListener("event",fn)
  f._eventManager:dispatchDBEvent("event",{})
  eq(count,1)
end)
test("repeated original armature advancement preserves current display",function()
  local f,data,a,rig=build()
  rig:advanceTime(0.1)
  rig:advanceTime(0.1)
  f:drawArmature(rig)
  eq(#state.draws,1)
end)
test("old prototype renderer is not referenced by the new adapter",function()
  local f,data,a,rig=build()
  eq(package.loaded["dragonbones.love_renderer"],nil)
  eq(type(rig.animation.play),"function")
end)

print(("Original runtime LÖVE image adapter: %d passed, %d failed, %d assertions")
  :format(passed,failed,checks))
if failed>0 then os.exit(1) end
