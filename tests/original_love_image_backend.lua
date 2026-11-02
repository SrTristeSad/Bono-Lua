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
  state={draws={},quads={},meshes={},colors={},blends={},matrices={},
    debugOps={},push=0,pop=0}
  _G.love={
    graphics={
      newQuad=function(x,y,w,h,iw,ih)
        local q={x=x,y=y,w=w,h=h,iw=iw,ih=ih}
        state.quads[#state.quads+1]=q
        return q
      end,
      newMesh=function(vertices,mode,usage)
        local m={vertices=vertices,mode=mode,usage=usage}
        function m:setVertexMap(map) self.map=map end
        function m:setTexture(tex) self.texture=tex end
        function m:setVertices(updated) self.vertices=updated end
        state.meshes[#state.meshes+1]=m
        return m
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
      end,
      setLineWidth=function(w)
        state.debugOps[#state.debugOps+1]={"lineWidth",w}
      end,
      line=function(...)
        state.debugOps[#state.debugOps+1]={"line",...}
      end,
      circle=function(...)
        state.debugOps[#state.debugOps+1]={"circle",...}
      end,
      rectangle=function(...)
        state.debugOps[#state.debugOps+1]={"rectangle",...}
      end,
      ellipse=function(...)
        state.debugOps[#state.debugOps+1]={"ellipse",...}
      end,
      polygon=function(...)
        state.debugOps[#state.debugOps+1]={"polygon",...}
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
  local atlasSpec=atlasRaw or atlas()
  local a=f:parseTextureAtlasData(atlasSpec,image(atlasSpec.width,atlasSpec.height),"pack")
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
  near(state.matrices[1][5],4)
  near(state.matrices[1][9],5)
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
  near(state.colors[1][1],128/255) -- PixiSlot: Math.round(0.5*255)
  near(state.colors[1][2],64/255)
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
  near(m[2],0)
  near(m[3],1)
  near(m[6],-1)
  near(m[9],2) -- rotated packed region moves local origin by its width.
end)
local function meshRig(meshData,atlasData)
  local raw=sample()
  raw.armature[1].skin[1].slot[1].display[1]=meshData
  local f,_,a,rig=build(raw,atlasData)
  local slot=rig:getSlot("one")
  return f,a,rig,slot
end
local function triangle()
  return {name="red",type="mesh",vertices={0,0,2,0,2,2},
    uvs={0,0,1,0,1,1},triangles={0,1,2}}
end
test("original mesh geometry builds a real GPU mesh and triangle map",function()
  local f,a,rig,slot=meshRig(triangle())
  local m=assert(slot._renderDisplay.mesh)
  eq(m.mode,"triangles")
  eq(m.usage,"dynamic")
  eq(#m.vertices,3)
  eq(m.map[1],1);eq(m.map[2],2);eq(m.map[3],3)
  eq(m.texture,a.image)
  near(m.vertices[2][1],2)
  near(m.vertices[2][3],0.5) -- UV normalized to atlas Image, not frame.
  f:drawArmature(rig)
  eq(#state.draws,1)
  eq(state.draws[1].image,m)
  near(state.matrices[1][5],4)
  near(state.matrices[1][9],5)
end)
test("original unweighted deform updates vertex coordinates, not UVs",function()
  local f,a,rig,slot=meshRig(triangle())
  local frame=slot:getDisplayFrameAt(0)
  frame:updateDeformVertices()
  frame.deformVertices[1]=3
  frame.deformVertices[2]=-2
  local mesh=slot._renderDisplay.mesh
  local uvBefore=mesh.vertices[1][3]
  slot:_updateMesh()
  near(mesh.vertices[1][1],3)
  near(mesh.vertices[1][2],-2)
  near(mesh.vertices[1][3],uvBefore)
  eq(#mesh.vertices,3)
end)
test("inheritDeform false retains the original source vertices",function()
  local raw=triangle();raw.inheritDeform=false
  local f,a,rig,slot=meshRig(raw)
  local frame=slot:getDisplayFrameAt(0)
  frame:updateDeformVertices()
  frame.deformVertices[1]=20
  slot:_updateMesh()
  near(slot._renderDisplay.mesh.vertices[1][1],0)
end)
test("weighted geometry uses original bone matrices, weights and FFD",function()
  local raw=triangle()
  raw.weights={1,0,1,1,0,1,1,0,1}
  raw.slotPose={1,0,0,1,0,0}
  raw.bonePose={0,1,0,0,1,0,0}
  local f,a,rig,slot=meshRig(raw)
  eq(slot._geometryData.weight~=nil,true)
  eq(#slot._geometryBones,1)
  local mesh=slot._renderDisplay.mesh
  -- Weighted vertices are world-space, so the PixiSlot original uses
  -- identity transform rather than applying root translation twice.
  near(slot._renderDisplay.tx,0)
  near(slot._renderDisplay.ty,0)
  local frame=slot:getDisplayFrameAt(0)
  frame:updateDeformVertices()
  frame.deformVertices[1]=3
  frame.deformVertices[2]=-2
  slot:_updateMesh()
  near(mesh.vertices[1][1],7)
  near(mesh.vertices[1][2],3)
  f:drawArmature(rig)
  near(state.matrices[1][5],0)
  near(state.matrices[1][9],0)
end)
test("rotated atlas mesh UVs use PixiSlot rotation then full image scale",function()
  local rotated={name="atlas",width=4,height=5,
    SubTexture={{name="red",x=0,y=0,width=2,height=3,rotated=true}}}
  local f,a,rig,slot=meshRig(triangle(),rotated)
  local vertices=assert(slot._renderDisplay.mesh).vertices
  near(vertices[1][3],0.5)
  near(vertices[1][4],0)
  near(vertices[2][3],0.5)
  near(vertices[2][4],0.6)
  near(vertices[3][3],0)
  near(vertices[3][4],0.6)
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

-- PixiSlot.ts _onUpdateDisplay/_replaceDisplay and PixiArmatureDisplay
-- container behavior, with an actual nested DragonBones Armature from JSON.
local function buildNested()
  fakeLove()
  local f=Love.Factory.new()
  local raw={
    version="5.5",name="Nested",frameRate=24,
    armature={
      {name="outer",bone={{name="root",transform={x=4,y=5}}},
        slot={
          {name="child",parent="root",displayIndex=0,zOrder=0},
          {name="front",parent="root",displayIndex=0,zOrder=1}
        },
        skin={{name="default",slot={
          {name="child",display={{name="inner",path="inner",type="armature"}}},
          {name="front",display={{name="blue",path="blue",type="image",
            pivot={x=0,y=0}}}}
        }}}
      },
      {name="inner",bone={{name="subroot",transform={x=2,y=3}}},
        slot={{name="part",parent="subroot",displayIndex=0}},
        skin={{name="default",slot={{name="part",display={{
          name="red",path="red",type="image",pivot={x=0,y=0}
        }}}}}}
      }
    }
  }
  f:parseDragonBonesData(raw,"pack")
  f:parseTextureAtlasData(atlas(),image(8,4),"pack")
  local outer=assert(f:buildArmature("outer","pack"))
  local childSlot=assert(outer:getSlot("child"))
  local child=assert(childSlot.childArmature)
  return f,outer,childSlot,child
end

test("nested display is a genuine child Armature with its own Slot",function()
  local f,outer,childSlot,child=buildNested()
  eq(getmetatable(child),Armature)
  eq(child.parent,childSlot)
  eq(childSlot._renderDisplay,child.display)
  eq(getmetatable(child:getSlot("part")),Love.Slot)
  eq(child.name,"inner")
end)
test("nested LÖVE composition preserves parent and child slot matrices",function()
  local f,outer,childSlot,child=buildNested()
  f:drawArmature(outer)
  eq(#state.draws,2)
  eq(state.draws[1].quad.x,0)
  eq(state.draws[2].quad.x,4)
  near(state.matrices[1][5],4)
  near(state.matrices[1][9],5)
  near(state.matrices[2][5],2)
  near(state.matrices[2][9],3)
  eq(state.push,3)
  eq(state.pop,3)
end)
test("nested Slot visibility hides child without hiding sibling display",function()
  local f,outer,childSlot,child=buildNested()
  childSlot.visible=false
  f:drawArmature(outer)
  eq(#state.draws,1)
  eq(state.draws[1].quad.x,4)
  eq(state.push,1)
  eq(state.pop,1)
end)
test("nested child Slot visibility is independent of its parent sibling",function()
  local f,outer,childSlot,child=buildNested()
  child:getSlot("part").visible=false
  f:drawArmature(outer)
  eq(#state.draws,1)
  eq(state.draws[1].quad.x,4)
  eq(state.push,2)
  eq(state.pop,2)
end)

-- PixiSlot._updateFrame and PixiTextureAtlasData replacement atlas behavior.
test("replacedTexture clones original atlas without changing its image or regions",function()
  local f,data,source,rig=build()
  local slot=rig:getSlot("one")
  local replacement=image(12,4)
  rig.replacedTexture=replacement
  f:drawArmature(rig)
  local cloned=assert(rig._replaceTextureAtlasData)
  eq(getmetatable(cloned),Love.TextureAtlasData)
  eq(cloned~=source,true)
  eq(cloned.image,replacement)
  eq(source.image~=replacement,true)
  eq(cloned:getTexture("red")~=source:getTexture("red"),true)
  eq(cloned:getTexture("red").region.x,0)
  eq(cloned:getTexture("blue").region.x,4)
  -- Preserved upstream TextureData.copyFrom source.parent quirk.
  eq(cloned:getTexture("red").parent,source)
  eq(slot._renderDisplay.texture,replacement)
  eq(slot._renderDisplay.quad.iw,12)
  eq(slot._renderDisplay.quad.ih,4)
end)
test("replacedTexture is identity-stable when assigned the same image",function()
  local f,data,source,rig=build()
  local swapped=image(8,4)
  rig.replacedTexture=swapped
  f:drawArmature(rig)
  local clone=rig._replaceTextureAtlasData
  local quad=rig:getSlot("one")._renderDisplay.quad
  rig.replacedTexture=swapped
  f:drawArmature(rig)
  eq(rig._replaceTextureAtlasData,clone)
  eq(rig:getSlot("one")._renderDisplay.quad,quad)
end)
test("changing or removing replacement recycles clone and restores source",function()
  local f,data,source,rig=build()
  local first=image(10,4)
  local second=image(14,4)
  rig.replacedTexture=first
  f:drawArmature(rig)
  local firstClone=assert(rig._replaceTextureAtlasData)
  rig.replacedTexture=second
  eq(rig._replaceTextureAtlasData,nil)
  f:drawArmature(rig)
  eq(rig:getSlot("one")._renderDisplay.texture,second)
  eq(rig._replaceTextureAtlasData.image,second)
  eq(rig:getSlot("one")._renderDisplay.quad.iw,14)
  rig.replacedTexture=nil
  eq(rig._replaceTextureAtlasData,nil)
  f:drawArmature(rig)
  eq(rig.replacedTexture,nil)
  eq(rig:getSlot("one")._renderDisplay.texture,source.image)
  eq(rig:getSlot("one")._renderDisplay.quad.iw,8)
  eq(source:getTexture("red").region.width,4)
  -- Pool reuse may return the same Lua atlas instance; never assume a new id.
  eq(firstClone.image,nil)
end)
test("replacedTexture rebinds mesh image and atlas-relative UV coordinates",function()
  local f,source,rig,slot=meshRig(triangle())
  local original=assert(slot._renderDisplay.mesh)
  near(original.vertices[2][3],0.5)
  local swapped=image(16,4)
  rig.replacedTexture=swapped
  f:drawArmature(rig)
  local mesh=assert(slot._renderDisplay.mesh)
  eq(mesh.texture,swapped)
  eq(slot._renderDisplay.texture,swapped)
  near(mesh.vertices[2][3],0.25)
  rig.replacedTexture=nil
  f:drawArmature(rig)
  local restored=assert(slot._renderDisplay.mesh)
  eq(restored.texture,source.image)
  near(restored.vertices[2][3],0.5)
end)
test("replacedTexture belongs to one armature, not the shared BaseFactory atlas",function()
  local f,data,source,rig=build()
  local second=assert(f:buildArmature("rig","pack"))
  local newImage=image(8,4)
  rig.replacedTexture=newImage
  f:drawArmature(rig)
  f:drawArmature(second)
  eq(rig:getSlot("one")._renderDisplay.texture,newImage)
  eq(second:getSlot("one")._renderDisplay.texture,source.image)
  eq(second._replaceTextureAtlasData,nil)
  eq(f:getTextureAtlasData("pack")[1],source)
end)

-- PixiSlot._updateBlendMode sprite-only switch; uncovered Pixi modes are
-- explicitly unsupported rather than silently mapped to incorrect math.
test("PixiSlot maps its six standard sprite modes to LÖVE",function()
  local f,_,_,rig=build()
  local slot=rig:getSlot("one")
  for _,entry in ipairs({
    {Core.BlendMode.Normal,"alpha"},
    {Core.BlendMode.Add,"add"},
    {Core.BlendMode.Darken,"darken"},
    {Core.BlendMode.Lighten,"lighten"},
    {Core.BlendMode.Multiply,"multiply"},
    {Core.BlendMode.Screen,"screen"},
  }) do
    slot._blendMode=entry[1]
    slot:_updateBlendMode()
    eq(slot._renderDisplay.bm,entry[2])
  end
end)
test("PixiSlot default branch leaves existing sprite blend unchanged",function()
  local f,_,_,rig=build()
  local slot=rig:getSlot("one")
  slot._blendMode=Core.BlendMode.Add
  slot:_updateBlendMode()
  for _,value in ipairs({
    Core.BlendMode.Alpha,Core.BlendMode.Erase,
    Core.BlendMode.Invert,Core.BlendMode.Layer,Core.BlendMode.Subtract
  }) do
    slot._blendMode=value
    slot:_updateBlendMode()
    eq(slot._renderDisplay.bm,"add")
  end
end)
test("Pixi-only Difference HardLight Overlay are not silently approximated",function()
  local f,_,_,rig=build()
  local slot=rig:getSlot("one")
  for _,value in ipairs({
    Core.BlendMode.Difference,Core.BlendMode.HardLight,
    Core.BlendMode.Overlay
  }) do
    slot._blendMode=value
    local ok,err=pcall(function()slot:_updateBlendMode()end)
    eq(ok,false)
    eq(tostring(err):find("unported shader",1,true)~=nil,true)
  end
end)
test("PixiSlot never changes blend on SimpleMesh",function()
  local f,a,rig,slot=meshRig(triangle())
  eq(slot._renderDisplay.kind,"mesh")
  slot._blendMode=Core.BlendMode.Add
  slot:_updateBlendMode()
  eq(slot._renderDisplay.bm,"alpha")
  slot._blendMode=Core.BlendMode.HardLight
  slot:_updateBlendMode()
  eq(slot._renderDisplay.bm,"alpha")
end)
test("PixiSlot tint rounds channels to bytes while preserving alpha precision",function()
  local f,_,_,rig=build()
  local slot=rig:getSlot("one")
  local c=slot._colorTransform
  c.redMultiplier=0.5
  c.greenMultiplier=0.25
  c.blueMultiplier=0.125
  c.alphaMultiplier=0.123456
  slot:_updateColor()
  near(slot._renderDisplay.r,128/255)
  near(slot._renderDisplay.g,64/255)
  near(slot._renderDisplay.b,32/255)
  near(slot._renderDisplay.alpha,0.123456)
  f:drawArmature(rig)
  near(state.colors[1][4],0.123456)
end)
test("PixiSlot 24-bit tint retains arithmetic carry of unmasked blue",function()
  local f,_,_,rig=build()
  local slot=rig:getSlot("one")
  local c=slot._colorTransform
  c.redMultiplier=0
  c.greenMultiplier=0
  c.blueMultiplier=257/255
  slot:_updateColor()
  near(slot._renderDisplay.r,0)
  near(slot._renderDisplay.g,1/255)
  near(slot._renderDisplay.b,1/255)
end)
test("Pixi child Armature container composes alpha with its own image slot",function()
  local f,outer,childSlot,child=buildNested()
  local childImage=child:getSlot("part")
  childSlot._colorTransform.alphaMultiplier=0.5
  childSlot._colorDirty=true
  childSlot:update(-1)
  childImage._colorTransform.alphaMultiplier=0.4
  childImage._colorDirty=true
  childImage:update(-1)
  f:drawArmature(outer)
  eq(#state.draws,2)
  near(state.colors[1][4],0.2)
  near(state.colors[2][4],1)
  eq(state.push,3)
  eq(state.pop,3)
end)

-- Pinned PixiFactory.ts surface: shared DragonBones runtime, display
-- construction + WorldClock registration and texture sprite lookup.
test("PixiFactory shares DragonBones runtime and global sound dispatcher",function()
  local first=Love.Factory.new()
  local second=Love.Factory.new()
  eq(first~=second,true)
  eq(first.dragonBones,second.dragonBones)
  eq(first.clock,second.clock)
  eq(first.soundEventManager,second.soundEventManager)
  eq(first.soundEventManager,first.dragonBones.eventManager)
  local count=0
  local callback=function()count=count+1 end
  first.soundEventManager:addDBEventListener("soundEvent",callback)
  second.soundEventManager:dispatchDBEvent("soundEvent",{})
  eq(count,1)
  second.soundEventManager:removeDBEventListener("soundEvent",callback)
  eq(first.soundEventManager:hasDBEventListener("soundEvent"),false)
end)
test("PixiFactory.factory and newInstance return the same lazy factory",function()
  local singleton=Love.Factory.factory
  eq(singleton,Love.Factory.factory)
  eq(singleton,Love.Factory.newInstance())
  eq(singleton.dragonBones,Love.Factory.new().dragonBones)
  eq(singleton~=Love.Factory.new(),true)
end)
test("PixiFactory buildArmatureDisplay returns source display on shared clock",function()
  local f,_,_,rig=build()
  local display=f:buildArmatureDisplay("rig","pack")
  eq(display~=nil,true)
  local armature=assert(display.armature)
  eq(getmetatable(armature),Armature)
  eq(armature.display,display)
  eq(armature.name,"rig")
  eq(armature.clock,f.clock)
  eq(f.clock:contains(armature),true)
  eq(rig.clock,nil) -- BaseFactory.buildArmature is not clock-driven.
  armature.clock=nil -- detach for isolation of subsequent tests.
  eq(f.clock:contains(armature),false)
end)
test("PixiFactory buildArmatureDisplay handles missing armature as nil",function()
  local f=Love.Factory.new()
  eq(f:buildArmatureDisplay("does-not-exist","nonexistent"),nil)
end)
test("PixiFactory static advanceTime ticks the shared WorldClock in seconds",function()
  local f,_,_,_=build()
  local before=f.clock.time
  Love.Factory.advanceTime(0.125)
  near(f.clock.time-before,0.125)
  local another=Love.Factory.new()
  eq(another.clock.time,f.clock.time)
end)
test("PixiFactory getTextureDisplay returns stand-alone atlas Sprite node",function()
  local f,_,atlasData,rig=build()
  local display=assert(f:getTextureDisplay("blue","pack"))
  eq(display.kind,"image")
  eq(display.texture,atlasData.image)
  eq(display.quad.x,4)
  eq(display.quad.y,0)
  eq(display.quad.w,4)
  eq(display.quad.h,4)
  eq(display.quad.iw,8)
  eq(display.rotated,false)
  eq(f:getTextureDisplay("none","pack"),nil)
  eq(f:getTextureDisplay("blue","other"),nil)
  eq(f:getTextureDisplay("blue"),nil)
  f:drawTextureDisplay(display)
  eq(#state.draws,1)
  eq(state.draws[1].image,atlasData.image)
  eq(state.draws[1].quad.x,4)
  eq(state.push,1)
  eq(state.pop,1)
end)
test("PixiFactory texture display supports rotated atlas frame in LÖVE",function()
  local rotated={name="atlas",width=4,height=5,
    SubTexture={{name="red",x=0,y=0,width=2,height=3,rotated=true}}}
  local f,_,a,rig=build(nil,rotated)
  local display=assert(f:getTextureDisplay("red","pack"))
  eq(display.rotated,true)
  eq(display.packedWidth,2)
  f:drawTextureDisplay(display)
  local matrix=state.matrices[1]
  eq(matrix[1],"row")
  near(matrix[2],0)
  near(matrix[3],1)
  near(matrix[5],0)
  near(matrix[6],-1)
  near(matrix[9],2) -- rotated packed source shifts Y, not X
end)
test("PixiFactory getTextureDisplay rejects unloaded atlas textures",function()
  fakeLove()
  local f=Love.Factory.new()
  local a=f:parseTextureAtlasData(atlas(),nil,"pack")
  eq(a.image,nil)
  eq(f:getTextureDisplay("red","pack"),nil)
end)

-- PixiSlot._updateFrame: missing texture resets x/y, leaves no GPU object
-- and hides its retained Sprite/SimpleMesh until a valid texture is bound.
test("PixiSlot hides untextured image and clears the retained transform",function()
  local f,_,atlasData,rig=build()
  local slot=rig:getSlot("one")
  local render=slot._renderDisplay
  eq(render.texture,atlasData.image)
  atlasData.image=nil
  f:drawArmature(rig)
  eq(render.texture,nil)
  eq(render.quad,nil)
  eq(render.visible,false)
  eq(render.tx,0)
  eq(render.ty,0)
  eq(#state.draws,0)
end)
test("PixiSlot recovers image Quad and original position when atlas is loaded",function()
  local f,_,atlasData,rig=build()
  local slot=rig:getSlot("one")
  local render=slot._renderDisplay
  atlasData.image=nil
  f:drawArmature(rig)
  local replacement=image(12,4)
  atlasData.image=replacement
  f:drawArmature(rig)
  eq(render.texture,replacement)
  eq(render.visible,true)
  eq(render.quad.iw,12)
  near(render.tx,4)
  near(render.ty,5)
  eq(#state.draws,1)
  eq(state.draws[1].image,replacement)
end)
test("PixiSlot builds a rig with an absent atlas Image and recovers later",function()
  fakeLove()
  local f=Love.Factory.new()
  f:parseDragonBonesData(sample(),"pack")
  local atlasData=f:parseTextureAtlasData(atlas(),nil,"pack")
  local rig=assert(f:buildArmature("rig","pack"))
  local slot=rig:getSlot("one")
  eq(slot._renderDisplay.texture,nil)
  f:drawArmature(rig)
  eq(#state.draws,0)
  local attached=image(8,4)
  atlasData.image=attached
  f:drawArmature(rig)
  eq(slot._renderDisplay.texture,attached)
  eq(slot._renderDisplay.visible,true)
  near(slot._renderDisplay.tx,4)
  near(slot._renderDisplay.ty,5)
  eq(#state.draws,1)
end)
test("PixiSlot preserves explicit visibility across atlas loss and restore",function()
  local f,_,atlasData,rig=build()
  local slot=rig:getSlot("one")
  atlasData.image=nil
  f:drawArmature(rig)
  slot.visible=false
  atlasData.image=image(8,4)
  f:drawArmature(rig)
  eq(slot._renderDisplay.visible,false)
  eq(#state.draws,0)
  slot.visible=true
  rig:advanceTime(0)
  f:drawArmature(rig)
  eq(slot._renderDisplay.visible,true)
  eq(#state.draws,1)
end)
test("PixiSlot clears unavailable mesh and restores its FFD vertices",function()
  local f,atlasData,rig,slot=meshRig(triangle())
  local render=slot._renderDisplay
  local frame=slot:getDisplayFrameAt(0)
  frame:updateDeformVertices()
  frame.deformVertices[1]=3
  frame.deformVertices[2]=-2
  slot:_updateMesh()
  near(render.mesh.vertices[1][1],3)
  atlasData.image=nil
  f:drawArmature(rig)
  eq(render.texture,nil)
  eq(render.mesh,nil)
  eq(render.visible,false)
  eq(render.tx,0)
  eq(render.ty,0)
  atlasData.image=image(16,4)
  f:drawArmature(rig)
  local mesh=assert(render.mesh)
  eq(render.visible,true)
  eq(mesh.texture,atlasData.image)
  near(mesh.vertices[1][1],3)
  near(mesh.vertices[1][2],-2)
  near(mesh.vertices[2][3],0.25)
  eq(#state.draws,1)
end)
-- PixiTextureAtlasData.renderTexture and PixiTextureData.renderTexture,
-- pinned DragonBonesJS: one texture wrapper per region, recreated when the
-- BaseTexture changes, and released when the atlas becomes unavailable.
test("PixiTextureAtlasData setter creates one textured Quad per region",function()
  local f,_,atlasData,rig=build()
  local red=assert(atlasData:getTexture("red"))
  local blue=assert(atlasData:getTexture("blue"))
  eq(atlasData.renderTexture,atlasData.image)
  eq(red.renderTexture.image,atlasData.image)
  eq(blue.renderTexture.image,atlasData.image)
  eq(red.renderTexture.quad.x,0)
  eq(blue.renderTexture.quad.x,4)
  eq(red.renderTexture.quad.w,4)
  eq(blue.renderTexture.quad.ih,4)
  eq(rig:getSlot("one")._renderDisplay.quad,red.renderTexture.quad)
  local display=assert(f:getTextureDisplay("blue","pack"))
  eq(display.quad,blue.renderTexture.quad)
end)
test("PixiTextureAtlasData ignores reassigning the same BaseTexture",function()
  local f,_,atlasData,rig=build()
  local red=atlasData:getTexture("red")
  local wrapper=red.renderTexture
  local n=#state.quads
  atlasData.renderTexture=atlasData.image
  eq(red.renderTexture,wrapper)
  eq(#state.quads,n)
  atlasData.image=atlasData.renderTexture
  eq(red.renderTexture,wrapper)
  eq(#state.quads,n)
end)
test("PixiTextureAtlasData assignment rebuilds all per-texture wrappers",function()
  local f,_,atlasData,rig=build()
  local red=atlasData:getTexture("red")
  local blue=atlasData:getTexture("blue")
  local oldRed=red.renderTexture
  local oldBlue=blue.renderTexture
  local oldImage=atlasData.image
  local replacement=image(16,8)
  atlasData.renderTexture=replacement
  eq(atlasData.image,replacement)
  eq(red.renderTexture~=oldRed,true)
  eq(blue.renderTexture~=oldBlue,true)
  eq(red.renderTexture.image,replacement)
  eq(red.renderTexture.quad.iw,16)
  eq(blue.renderTexture.quad.ih,8)
  eq(oldRed.image,oldImage) -- only the atlas's active proxy is replaced
  eq(oldBlue.image,oldImage)
  f:drawArmature(rig)
  eq(rig:getSlot("one")._renderDisplay.texture,replacement)
  eq(rig:getSlot("one")._renderDisplay.quad,red.renderTexture.quad)
end)
test("PixiTextureAtlasData null BaseTexture clears all region resources",function()
  local f,_,atlasData,rig=build()
  atlasData.renderTexture=nil
  eq(atlasData.image,nil)
  eq(atlasData:getTexture("red").renderTexture,nil)
  eq(atlasData:getTexture("blue").renderTexture,nil)
  eq(f:getTextureDisplay("red","pack"),nil)
  f:drawArmature(rig)
  eq(rig:getSlot("one")._renderDisplay.texture,nil)
  eq(#state.draws,0)
  local newImage=image(8,4)
  atlasData.renderTexture=newImage
  f:drawArmature(rig)
  eq(rig:getSlot("one")._renderDisplay.texture,newImage)
  eq(rig:getSlot("one")._renderDisplay.quad,
    atlasData:getTexture("red").renderTexture.quad)
end)
test("PixiFactory.updateTextureAtlases updates each Pixi region resource",function()
  local f,_,atlasData,rig=build()
  local previous=atlasData:getTexture("blue").renderTexture
  local newImage=image(20,12)
  f:updateTextureAtlases({newImage},"pack")
  eq(atlasData.image,newImage)
  eq(atlasData:getTexture("blue").renderTexture.image,newImage)
  eq(atlasData:getTexture("blue").renderTexture.quad.iw,20)
  eq(atlasData:getTexture("red").renderTexture.quad.ih,12)
  eq(previous~=atlasData:getTexture("blue").renderTexture,true)
  eq(assert(f:getTextureDisplay("blue","pack")).texture,newImage)
  f:drawArmature(rig)
  eq(rig:getSlot("one")._renderDisplay.texture,newImage)
end)
test("Pixi armature replacedTexture clones atlas region proxies separately",function()
  local f,_,atlasData,rig=build()
  local source=atlasData:getTexture("red").renderTexture
  local replacement=image(12,4)
  rig.replacedTexture=replacement
  f:drawArmature(rig)
  local clone=assert(rig._replaceTextureAtlasData)
  eq(clone.image,replacement)
  eq(clone.renderTexture,replacement)
  eq(clone:getTexture("red").renderTexture.image,replacement)
  eq(clone:getTexture("red").renderTexture.quad,
    rig:getSlot("one")._renderDisplay.quad)
  eq(clone:getTexture("red").renderTexture~=source,true)
  eq(atlasData:getTexture("red").renderTexture,source)
  rig.replacedTexture=nil
  f:drawArmature(rig)
  eq(rig:getSlot("one")._renderDisplay.quad,source.quad)
end)

-- PixiSlot._addDisplay/_replaceDisplay/_removeDisplay/_updateZOrder:
-- the native PixiArmatureDisplay child list is independent of the logical
-- Armature.getSlots() list. Here the LÖVE host retains the owning Slot.
local function layeredRig()
  local raw={version="5.5",name="Layered",frameRate=24,
    armature={{name="rig",bone={{name="root"}},
      slot={{name="back",parent="root",displayIndex=0},
            {name="middle",parent="root",displayIndex=0},
            {name="front",parent="root",displayIndex=0}},
      skin={{name="default",slot={
        {name="back",display={{name="red",path="red",type="image",pivot={x=0,y=0}}}},
        {name="middle",display={
          {name="blue",path="blue",type="image",pivot={x=0,y=0}},
          {name="blue",path="blue",type="mesh",vertices={0,0,4,0,0,4},
            uvs={0,0,1,0,0,1},triangles={0,1,2}}
        }},
        {name="front",display={{name="green",path="green",type="image",pivot={x=0,y=0}}}}
      }}}}
    }}
  local atlasRaw={name="layered",width=12,height=4,SubTexture={
    {name="red",x=0,y=0,width=4,height=4},
    {name="blue",x=4,y=0,width=4,height=4},
    {name="green",x=8,y=0,width=4,height=4}
  }}
  local f,_,a,rig=build(raw,atlasRaw)
  return f,rig,rig:getSlot("back"),rig:getSlot("middle"),rig:getSlot("front")
end
test("PixiSlot adds each display to its own ordered container",function()
  local f,rig,back,middle,front=layeredRig()
  eq(#rig.display._renderSlots,3)
  eq(rig.display._renderSlots[1],back)
  eq(rig.display._renderSlots[2],middle)
  eq(rig.display._renderSlots[3],front)
  f:drawArmature(rig)
  eq(#state.draws,3)
  eq(state.draws[1].quad.x,0)
  eq(state.draws[2].quad.x,4)
  eq(state.draws[3].quad.x,8)
end)
test("PixiSlot _updateZOrder moves display while keeping logical slot list",function()
  local f,rig,back,middle,front=layeredRig()
  local logical=rig:getSlots()
  eq(logical[1],back)
  back:_setZOrder(2)
  back:update(-1)
  eq(rig.display._renderSlots[1],middle)
  eq(rig.display._renderSlots[2],front)
  eq(rig.display._renderSlots[3],back)
  eq(logical[1],back)
  f:drawArmature(rig)
  eq(state.draws[1].quad.x,4)
  eq(state.draws[2].quad.x,8)
  eq(state.draws[3].quad.x,0)
end)
test("PixiSlot display replacement preserves container position",function()
  local f,rig,back,middle,front=layeredRig()
  eq(middle._renderDisplay.kind,"image")
  middle.displayIndex=1
  eq(middle._renderDisplay.kind,"mesh")
  eq(rig.display._renderSlots[2],middle)
  f:drawArmature(rig)
  eq(#state.draws,3)
  eq(state.draws[2].image,middle._renderDisplay.mesh)
  middle.displayIndex=0
  eq(middle._renderDisplay.kind,"image")
  eq(rig.display._renderSlots[2],middle)
  f:drawArmature(rig)
  eq(#state.draws,6)
  eq(state.draws[5].quad.x,4)
end)
test("PixiSlot _removeDisplay detaches only that display",function()
  local f,rig,back,middle,front=layeredRig()
  middle:_removeDisplay()
  eq(#rig.display._renderSlots,2)
  eq(rig.display._renderSlots[1],back)
  eq(rig.display._renderSlots[2],front)
  f:drawArmature(rig)
  eq(#state.draws,2)
  eq(state.draws[1].quad.x,0)
  eq(state.draws[2].quad.x,8)
  middle:_addDisplay()
  eq(#rig.display._renderSlots,3)
  eq(rig.display._renderSlots[3],middle)
end)
test("PixiSlot armature z-order timeline uses display container order",function()
  local f,rig,back,middle,front=layeredRig()
  -- _sortZOrder is original Armature logic; slot hooks alone do the
  -- graphics-side reordering, irrespective of logical array sort.
  rig:_sortZOrder({2,1,0},0)
  rig:advanceTime(0)
  f:drawArmature(rig)
  eq(#state.draws,3)
  eq(state.draws[1].quad.x,8)
  eq(state.draws[2].quad.x,4)
  eq(state.draws[3].quad.x,0)
end)
test("nested child Armature and sibling retain independent display order",function()
  local f,outer,childSlot,child=buildNested()
  local front=outer:getSlot("front")
  eq(#outer.display._renderSlots,2)
  eq(#child.display._renderSlots,1)
  front:_setZOrder(0)
  front:update(-1)
  eq(outer.display._renderSlots[1],front)
  eq(outer.display._renderSlots[2],childSlot)
  f:drawArmature(outer)
  eq(#state.draws,2)
  eq(state.draws[1].quad.x,4)
  eq(state.draws[2].quad.x,0)
  eq(#child.display._renderSlots,1)
end)

-- PixiArmatureDisplay.ts and PixiFactory.ts use a single object as
-- both Armature.proxy/eventDispatcher and Armature.display. The LÖVE host
-- exposes the same IArmatureProxy contract on its retained display.
test("PixiArmatureDisplay is exactly the Armature proxy and display",function()
  local f,_,_,rig=build()
  local display=rig.display
  eq(display,rig.proxy)
  eq(display,rig.eventDispatcher)
  eq(display.armature,rig)
  eq(display.animation,rig.animation)
  eq(display.debugDraw,false)
  eq(#display._renderSlots,1)
end)
test("PixiFactory buildArmatureDisplay exposes original proxy event API",function()
  local f=Love.Factory.new()
  f:parseDragonBonesData(sample(),"proxy")
  f:parseTextureAtlasData(atlas(),image(8,4),"proxy")
  local display=assert(f:buildArmatureDisplay("rig","proxy"))
  eq(display.armature.display,display)
  eq(display.armature.proxy,display)
  local hits={}
  local callback=function(ev) hits[#hits+1]=ev.name end
  display:addDBEventListener("frameEvent",callback)
  eq(display:hasDBEventListener("frameEvent"),true)
  display:dispatchDBEvent("frameEvent",{name="step"})
  eq(hits[1],"step")
  display:removeDBEventListener("frameEvent",callback)
  eq(display:hasDBEventListener("frameEvent"),false)
  display.armature.clock=nil
end)
test("PixiArmatureDisplay event listeners preserve context and insertion order",function()
  local f,_,_,rig=build()
  local display=rig.display
  local first={tag="first",count=0}
  local second={tag="second",count=0}
  local seen={}
  local callback=function(target,event)
    target.count=target.count+1
    seen[#seen+1]=target.tag..event.name
  end
  display:addDBEventListener("hit",callback,first)
  display:addDBEventListener("hit",callback,second)
  eq(display:hasDBEventListener("hit"),true)
  display:dispatchDBEvent("hit",{name="!"})
  eq(seen[1],"first!")
  eq(seen[2],"second!")
  eq(first.count,1)
  eq(second.count,1)
  display:removeDBEventListener("hit",callback,first)
  display:dispatchDBEvent("hit",{name="?"})
  eq(first.count,1)
  eq(second.count,2)
  eq(seen[3],"second?")
  display:removeDBEventListener("hit",callback,second)
  eq(display:hasDBEventListener("hit"),false)
end)
test("PixiArmatureDisplay supports duplicate unbound EventEmitter registrations",function()
  local f,_,_,rig=build()
  local display=rig.display
  local count=0
  local callback=function(event)count=count+event.increment end
  display:addDBEventListener("hit",callback)
  display:addDBEventListener("hit",callback)
  display:dispatchDBEvent("hit",{increment=2})
  eq(count,4)
  display:removeDBEventListener("hit",callback)
  eq(display:hasDBEventListener("hit"),false)
  display:dispatchDBEvent("hit",{increment=4})
  eq(count,4)
end)
test("PixiArmatureDisplay dispatch snapshots listeners during reentrant edits",function()
  local f,_,_,rig=build()
  local display=rig.display
  local calls={}
  local late=function()calls[#calls+1]="late" end
  local first=function()
    calls[#calls+1]="first"
    display:addDBEventListener("hit",late)
  end
  local second=function()calls[#calls+1]="second" end
  display:addDBEventListener("hit",first)
  display:addDBEventListener("hit",second)
  display:dispatchDBEvent("hit",{})
  eq(table.concat(calls,","),"first,second")
  display:dispatchDBEvent("hit",{})
  eq(table.concat(calls,","),"first,second,first,second,late")
end)
test("PixiArmatureDisplay routes original DragonBones frame and sound events",function()
  local f,_,_,rig=build()
  local EventObject=require("dragonbones.original.event.EventObject")
  local hits={}
  local onFrame=function(event)hits[#hits+1]="frame:"..event.name end
  local onSound=function(event)hits[#hits+1]="sound:"..event.name end
  local onGlobal=function(event)hits[#hits+1]="global:"..event.name end
  rig.display:addDBEventListener(EventObject.FRAME_EVENT,onFrame)
  rig.display:addDBEventListener(EventObject.SOUND_EVENT,onSound)
  f.soundEventManager:addDBEventListener(EventObject.SOUND_EVENT,onGlobal)
  local frame=BaseObject.borrowObject(EventObject)
  frame.type=EventObject.FRAME_EVENT
  frame.name="move"
  frame.armature=rig
  f.dragonBones:bufferEvent(frame)
  local sound=BaseObject.borrowObject(EventObject)
  sound.type=EventObject.SOUND_EVENT
  sound.name="impact"
  sound.armature=rig
  f.dragonBones:bufferEvent(sound)
  f.dragonBones:advanceTime(0)
  eq(table.concat(hits,","),"frame:move,sound:impact,global:impact")
  f.soundEventManager:removeDBEventListener(EventObject.SOUND_EVENT,onGlobal)
  eq(f.soundEventManager:hasDBEventListener(EventObject.SOUND_EVENT),false)
end)
test("PixiArmatureDisplay dispose detaches immediately and clears on pool return",function()
  local f,_,_,rig=build()
  local display=rig.display
  local touched=0
  display:addDBEventListener("hit",function()touched=touched+1 end)
  eq(#display._renderSlots,1)
  display:dispose(false) -- Pixi ignores disposeProxy.
  eq(display.armature,nil)
  eq(display:hasDBEventListener("hit"),true) -- deferred dbClear
  f.dragonBones:advanceTime(0)
  eq(display.armature,nil)
  eq(#display._renderSlots,0)
  eq(display:hasDBEventListener("hit"),false)
  display:dispatchDBEvent("hit",{})
  eq(touched,0)
end)
test("PixiArmatureDisplay destroy invokes the same armature disposal contract",function()
  local f,_,_,rig=build()
  local display=rig.display
  display:destroy()
  eq(display.armature,nil)
  f.dragonBones:advanceTime(0)
  eq(#display._renderSlots,0)
  local ok=pcall(function()return display.animation end)
  eq(ok,false) -- Original getter dereferences a detached armature.
end)
-- Pinned PixiArmatureDisplay.dbUpdate draws cyan bone segments and circles
-- and magenta bounding boxes above the Armature's display children.
local function debugRig()
  local raw={version="5.5",name="Debug",frameRate=24,armature={{
    name="rig",bone={{name="root",length=8,transform={x=4,y=5}}},
    slot={
      {name="rect",parent="root",displayIndex=0},
      {name="oval",parent="root",displayIndex=0},
      {name="poly",parent="root",displayIndex=0}
    },
    skin={{name="default",slot={
      {name="rect",display={{name="rect",type="boundingBox",subType="rectangle",width=6,height=4}}},
      {name="oval",display={{name="oval",type="boundingBox",subType="ellipse",width=8,height=4}}},
      {name="poly",display={{name="poly",type="boundingBox",subType="polygon",
        vertices={0,0,4,0,2,4}}}}
    }}}
  }}}
  local f,_,_,rig=build(raw)
  return f,rig
end
test("Pixi debugDraw is disabled by default without allocating overlays",function()
  local f,_,_,rig=build()
  rig:advanceTime(0)
  eq(rig.display._debugDraw,false)
  eq(rig.display._debugDrawer,nil)
  f:drawArmature(rig)
  eq(#state.debugOps,0)
end)
test("Pixi debugDraw renders cyan bone with original world transform",function()
  local f,rig=debugRig()
  rig.display.debugDraw=true
  rig:advanceTime(0)
  local drawer=assert(rig.display._debugDrawer)
  eq(rig.display._debugDraw,true)
  eq(#drawer.bones,1)
  near(drawer.bones[1][1],4)
  near(drawer.bones[1][2],5)
  near(drawer.bones[1][3],12)
  near(drawer.bones[1][4],5)
  f:drawArmature(rig)
  local foundLine,foundCircle=false,false
  for _,op in ipairs(state.debugOps) do
    if op[1]=="line" then
      near(op[2],4);near(op[3],5)
      near(op[4],12);near(op[5],5)
      foundLine=true
    elseif op[1]=="circle" then
      eq(op[2],"fill")
      near(op[3],4);near(op[4],5);near(op[5],3)
      foundCircle=true
    end
  end
  eq(foundLine,true)
  eq(foundCircle,true)
  eq(#state.draws,0) -- boundingBox displays are not texture Sprites
end)
test("Pixi debugDraw maps all three original bounding box geometries",function()
  local f,rig=debugRig()
  rig.display.debugDraw=true
  rig:advanceTime(0)
  local slots=rig.display._debugDrawer.slots
  eq(#slots,3)
  eq(slots[1].name,"rect")
  eq(slots[1].type,Core.BoundingBoxType.Rectangle)
  eq(slots[1].width,6)
  eq(slots[1].height,4)
  eq(slots[2].type,Core.BoundingBoxType.Ellipse)
  eq(slots[3].type,Core.BoundingBoxType.Polygon)
  eq(#slots[3].vertices,6)
  f:drawArmature(rig)
  local shape={}
  for _,op in ipairs(state.debugOps) do
    if op[1]=="rectangle" or op[1]=="ellipse" or op[1]=="polygon" then
      shape[#shape+1]=op
    end
  end
  eq(#shape,3)
  eq(shape[1][1],"rectangle");eq(shape[1][2],"line")
  near(shape[1][3],-3);near(shape[1][4],-2)
  near(shape[1][5],6);near(shape[1][6],4)
  eq(shape[2][1],"ellipse");eq(shape[2][2],"line")
  near(shape[2][5],4);near(shape[2][6],2)
  eq(shape[3][1],"polygon");eq(shape[3][2],"line")
  eq(#shape[3][3],6)
end)
test("Pixi debugDraw slot transform includes position and pivot",function()
  local f,rig=debugRig()
  local slot=rig:getSlot("rect")
  slot._pivotX=2
  slot._pivotY=1
  rig.display.debugDraw=true
  rig:advanceTime(0)
  local shape=rig.display._debugDrawer.slots[1]
  near(shape.a,1);near(shape.b,0)
  near(shape.c,0);near(shape.d,1)
  near(shape.tx,2);near(shape.ty,4)
  f:drawArmature(rig)
  eq(#state.matrices,3)
  near(state.matrices[1][5],2)
  near(state.matrices[1][9],4)
end)
test("Pixi debugDraw global and local switches preserve cached overlay",function()
  local f,rig=debugRig()
  Core.debugDraw=true
  rig:advanceTime(0)
  eq(rig.display._debugDraw,true)
  local same=rig.display._debugDrawer
  Core.debugDraw=false
  rig:advanceTime(0)
  eq(rig.display._debugDraw,false)
  eq(rig.display._debugDrawer,same)
  f:drawArmature(rig)
  eq(#state.debugOps,0)
  rig.display.debugDraw=true
  rig:advanceTime(0)
  eq(rig.display._debugDraw,true)
  eq(rig.display._debugDrawer,same)
  f:drawArmature(rig)
  eq(#state.debugOps>0,true)
  rig.display.debugDraw=false
  rig:advanceTime(0)
  eq(rig.display._debugDraw,false)
end)
test("Pixi debugDraw overlay clears only after deferred disposal",function()
  local f,rig=debugRig()
  local display=rig.display
  display.debugDraw=true
  rig:advanceTime(0)
  eq(display._debugDrawer~=nil,true)
  display:dispose()
  eq(display._debugDrawer~=nil,true)
  f.dragonBones:advanceTime(0)
  eq(display._debugDrawer,nil)
  eq(display._debugDraw,false)
  eq(display.armature,nil)
end)

print(("Original runtime LÖVE image adapter: %d passed, %d failed, %d assertions")
  :format(passed,failed,checks))
if failed>0 then os.exit(1) end
