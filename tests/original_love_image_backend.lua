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
  state={draws={},quads={},meshes={},colors={},blends={},matrices={},push=0,pop=0}
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

print(("Original runtime LÖVE image adapter: %d passed, %d failed, %d assertions")
  :format(passed,failed,checks))
if failed>0 then os.exit(1) end
