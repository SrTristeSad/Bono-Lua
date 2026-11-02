-- GPU integration for genuine original DragonBones Armature/Slot, not
-- the legacy prototype. Run inside LÖVE under xvfb/llvmpipe.
local Love=require("dragonbones.love_original")
local Test={}
local function colorAt(data,x,y,r,g,b,alpha)
  local rr,gg,bb,aa=data:getPixel(x,y)
  assert(math.abs(rr-r)<.08 and math.abs(gg-g)<.08
    and math.abs(bb-b)<.08 and math.abs(aa-alpha)<.08,
    ("Original LÖVE GPU pixel %d,%d expected %.2f %.2f %.2f %.2f, got %.2f %.2f %.2f %.2f")
      :format(x,y,r,g,b,alpha,rr,gg,bb,aa))
end
function Test.run()
  local pixels=love.image.newImageData(8,4)
  for y=0,3 do
    for x=0,7 do
      if x<4 then pixels:setPixel(x,y,1,0,0,1)
      else pixels:setPixel(x,y,0,1,0,1) end
    end
  end
  local image=love.graphics.newImage(pixels)
  image:setFilter("nearest","nearest")
  local factory=Love.Factory.new()
  local raw={version="5.5",name="GPURig",frameRate=12,
    armature={{name="rig",bone={{name="root"}},
      slot={{name="body",parent="root"}},
      skin={{name="default",slot={{name="body",display={
        {name="red",path="red",pivot={x=0,y=0}},
        {name="green",path="green",pivot={x=0,y=0}}
      }}}}},
      animation={{name="swap",duration=12,playTimes=0,slot={{
        name="body",displayFrame={
          {duration=4,value=0},{duration=4,value=1},
          {duration=4,value=-1}
        }
      }}}}
    }}
  }
  local atlas={name="GPUAtlas",width=8,height=4,SubTexture={
    {name="red",x=0,y=0,width=4,height=4},
    {name="green",x=4,y=0,width=4,height=4}
  }}
  factory:parseDragonBonesData(raw,"pack")
  factory:parseTextureAtlasData(atlas,image,"pack")
  local armature=assert(factory:buildArmature("rig","pack"))
  assert(armature.animation:getState("swap")==nil)
  local target=love.graphics.newCanvas(32,32)
  target:setFilter("nearest","nearest")
  local function shot()
    love.graphics.push("all")
    love.graphics.setCanvas(target)
    love.graphics.clear(0,0,0,0)
    love.graphics.translate(8,8)
    factory:drawArmature(armature)
    love.graphics.setCanvas()
    love.graphics.pop()
    return target:newImageData()
  end
  armature.animation:play("swap")
  armature:advanceTime(0)
  colorAt(shot(),9,9,1,0,0,1)
  armature:advanceTime(4/12)
  colorAt(shot(),9,9,0,1,0,1)
  armature:advanceTime(4/12)
  colorAt(shot(),9,9,0,0,0,0)
  armature:advanceTime(4/12)
  colorAt(shot(),9,9,1,0,0,1)
  -- Real LÖVE 11.x GPU mesh: original ObjectDataParser -> BaseFactory ->
  -- Slot -> PixiSlot geometry/FFD equations translated for LÖVE Mesh.
  local meshRaw={version="5.5",name="GPUMesh",frameRate=12,
    armature={{name="rig",bone={{name="root"}},
      slot={{name="body",parent="root"}},
      skin={{name="default",slot={{name="body",display={{
        name="red",path="red",type="mesh",
        vertices={0,0,4,0,0,4},
        uvs={0,0,1,0,0,1},triangles={0,1,2}
      }}}}}}
    }}
  }
  local meshFactory=Love.Factory.new()
  meshFactory:parseDragonBonesData(meshRaw,"mesh")
  meshFactory:parseTextureAtlasData(atlas,image,"mesh")
  local meshArmature=assert(meshFactory:buildArmature("rig","mesh"))
  local meshSlot=assert(meshArmature:getSlot("body"))
  assert(meshSlot._renderDisplay.mesh~=nil)
  local function meshShot()
    love.graphics.push("all")
    love.graphics.setCanvas(target)
    love.graphics.clear(0,0,0,0)
    love.graphics.translate(8,8)
    meshFactory:drawArmature(meshArmature)
    love.graphics.setCanvas()
    love.graphics.pop()
    return target:newImageData()
  end
  colorAt(meshShot(),9,9,1,0,0,1)
  local frame=meshSlot:getDisplayFrameAt(0)
  frame:updateDeformVertices()
  for i=1,#frame.deformVertices,2 do
    frame.deformVertices[i]=6
  end
  meshSlot:_updateMesh()
  local shifted=meshShot()
  colorAt(shifted,9,9,0,0,0,0)
  colorAt(shifted,15,9,1,0,0,1)
  -- Nested real Armatures: PixiArmatureDisplay is a display-tree container.
  -- Test the LÖVE stack equivalent with two independently transformed rigs.
  local nestedRaw={version="5.5",name="GPUNested",frameRate=12,armature={
    {name="outer",bone={{name="root",transform={x=5,y=4}}},
      slot={{name="child",parent="root",displayIndex=0}},
      skin={{name="default",slot={{name="child",display={{
        name="inner",path="inner",type="armature"
      }}}}}}
    },
    {name="inner",bone={{name="subroot",transform={x=3,y=2}}},
      slot={{name="body",parent="subroot",displayIndex=0}},
      skin={{name="default",slot={{name="body",display={{
        name="red",path="red",type="image",pivot={x=0,y=0}
      }}}}}}
    }
  }}
  local nestedFactory=Love.Factory.new()
  nestedFactory:parseDragonBonesData(nestedRaw,"nested")
  nestedFactory:parseTextureAtlasData(atlas,image,"nested")
  local outer=assert(nestedFactory:buildArmature("outer","nested"))
  local childSlot=assert(outer:getSlot("child"))
  local inner=assert(childSlot.childArmature)
  assert(inner:getSlot("body")~=nil)
  local function nestedShot(whiteBackground)
    love.graphics.push("all")
    love.graphics.setCanvas(target)
    if whiteBackground then
      love.graphics.clear(1,1,1,1)
    else
      love.graphics.clear(0,0,0,0)
    end
    love.graphics.translate(8,8)
    nestedFactory:drawArmature(outer)
    love.graphics.setCanvas()
    love.graphics.pop()
    return target:newImageData()
  end
  colorAt(nestedShot(),17,15,1,0,0,1)
  colorAt(nestedShot(),9,9,0,0,0,0)
  childSlot.visible=false
  colorAt(nestedShot(),17,15,0,0,0,0)
  childSlot.visible=true
  colorAt(nestedShot(),17,15,1,0,0,1)
  -- Original Armature.replacedTexture combined with the PixiSlot atlas
  -- clone path; verify GPU pixels for normal images and deforming meshes.
  local swappedPixels=love.image.newImageData(8,4)
  for y=0,3 do
    for x=0,7 do
      if x<4 then swappedPixels:setPixel(x,y,0,0,1,1)
      else swappedPixels:setPixel(x,y,1,1,0,1) end
    end
  end
  local swappedImage=love.graphics.newImage(swappedPixels)
  swappedImage:setFilter("nearest","nearest")
  armature.replacedTexture=swappedImage
  colorAt(shot(),9,9,0,0,1,1)
  armature.replacedTexture=nil
  colorAt(shot(),9,9,1,0,0,1)
  meshArmature.replacedTexture=swappedImage
  colorAt(meshShot(),15,9,0,0,1,1)
  meshArmature.replacedTexture=nil
  colorAt(meshShot(),15,9,1,0,0,1)
  -- PixiSlot rounds tint channels to 8-bit values, but passes alpha
  -- through without byte rounding. LÖVE must draw the resulting tint.
  local imageSlot=assert(armature:getSlot("body"))
  imageSlot._colorTransform.redMultiplier=0.5
  imageSlot._colorDirty=true
  imageSlot:update(-1)
  colorAt(shot(),9,9,128/255,0,0,1)
  imageSlot._colorTransform.redMultiplier=1
  imageSlot._colorDirty=true
  imageSlot:update(-1)
  colorAt(shot(),9,9,1,0,0,1)
  meshSlot._colorTransform.redMultiplier=0.5
  meshSlot._colorDirty=true
  meshSlot:update(-1)
  colorAt(meshShot(),15,9,128/255,0,0,1)
  meshSlot._colorTransform.redMultiplier=1
  meshSlot._colorDirty=true
  meshSlot:update(-1)

  -- Pixi's child Armature display is an alpha-bearing container. Render
  -- its two half-opacity stages over an opaque canvas to check 1/4 alpha.
  local nestedImageSlot=assert(inner:getSlot("body"))
  childSlot._colorTransform.alphaMultiplier=0.5
  childSlot._colorDirty=true
  childSlot:update(-1)
  nestedImageSlot._colorTransform.alphaMultiplier=0.5
  nestedImageSlot._colorDirty=true
  nestedImageSlot:update(-1)
  colorAt(nestedShot(true),17,15,1,0.75,0.75,1)
  -- PixiFactory.getTextureDisplay: texture atlas Sprite transport.
  local standalone=assert(factory:getTextureDisplay("green","pack"))
  assert(standalone.kind=="image" and standalone.quad~=nil)
  local function spriteShot(display)
    love.graphics.push("all")
    love.graphics.setCanvas(target)
    love.graphics.clear(0,0,0,0)
    love.graphics.translate(8,8)
    factory:drawTextureDisplay(display)
    love.graphics.setCanvas()
    love.graphics.pop()
    return target:newImageData()
  end
  colorAt(spriteShot(standalone),9,9,0,1,0,1)
  standalone.visible=false
  colorAt(spriteShot(standalone),9,9,0,0,0,0)

  -- PixiFactory.buildArmatureDisplay registers with the shared DragonBones
  -- clock. The host has no Pixi ticker, so explicitly advance in seconds.
  local display=assert(factory:buildArmatureDisplay("rig","pack"))
  local clockArmature=assert(display.armature)
  assert(clockArmature.clock==factory.clock)
  local function clockShot()
    love.graphics.push("all")
    love.graphics.setCanvas(target)
    love.graphics.clear(0,0,0,0)
    love.graphics.translate(8,8)
    factory:drawArmature(clockArmature)
    love.graphics.setCanvas()
    love.graphics.pop()
    return target:newImageData()
  end
  clockArmature.animation:play("swap")
  Love.Factory.advanceTime(0)
  colorAt(clockShot(),9,9,1,0,0,1)
  Love.Factory.advanceTime(4/12)
  colorAt(clockShot(),9,9,0,1,0,1)
  clockArmature.clock=nil
  -- PixiSlot._updateFrame: removing a texture atlas must stop rendering;
  -- restoring it must rebind both the GPU resource and slot matrix.
  local spriteAtlas=assert(factory:getTextureAtlasData("pack"))[1]
  local sourceImage=spriteAtlas.image
  spriteAtlas.image=nil
  colorAt(shot(),9,9,0,0,0,0)
  spriteAtlas.image=sourceImage
  colorAt(shot(),9,9,1,0,0,1)
  local meshAtlas=assert(meshFactory:getTextureAtlasData("mesh"))[1]
  local meshImage=meshAtlas.image
  meshAtlas.image=nil
  colorAt(meshShot(),15,9,0,0,0,0)
  meshAtlas.image=meshImage
  colorAt(meshShot(),15,9,1,0,0,1)
  -- First-time GPU attachment after an Armature was built without an image.
  local lateFactory=Love.Factory.new()
  lateFactory:parseDragonBonesData(raw,"late")
  local lateAtlas=lateFactory:parseTextureAtlasData(atlas,nil,"late")
  local lateArmature=assert(lateFactory:buildArmature("rig","late"))
  local function lateShot()
    love.graphics.push("all")
    love.graphics.setCanvas(target)
    love.graphics.clear(0,0,0,0)
    love.graphics.translate(8,8)
    lateFactory:drawArmature(lateArmature)
    love.graphics.setCanvas()
    love.graphics.pop()
    return target:newImageData()
  end
  colorAt(lateShot(),9,9,0,0,0,0)
  lateAtlas.image=image
  colorAt(lateShot(),9,9,1,0,0,1)
  -- PixiTextureAtlasData.renderTexture replaces every per-region
  -- PIXI.Texture. In LÖVE the equivalent region proxies are Image/Quad
  -- pairs, and both live slots and stand-alone sprites must follow them.
  assert(spriteAtlas.renderTexture==sourceImage)
  assert(spriteAtlas:getTexture("red").renderTexture.image==sourceImage)
  assert(spriteAtlas:getTexture("green").renderTexture.quad~=nil)
  factory:updateTextureAtlases({swappedImage},"pack")
  assert(spriteAtlas.renderTexture==swappedImage)
  assert(spriteAtlas:getTexture("red").renderTexture.image==swappedImage)
  colorAt(shot(),9,9,0,0,1,1)
  local atlasGreen=assert(factory:getTextureDisplay("green","pack"))
  colorAt(spriteShot(atlasGreen),9,9,1,1,0,1)
  spriteAtlas.renderTexture=nil
  assert(spriteAtlas:getTexture("red").renderTexture==nil)
  assert(factory:getTextureDisplay("green","pack")==nil)
  colorAt(shot(),9,9,0,0,0,0)
  spriteAtlas.renderTexture=sourceImage
  colorAt(shot(),9,9,1,0,0,1)
  meshAtlas.renderTexture=swappedImage
  colorAt(meshShot(),15,9,0,0,1,1)
  meshAtlas.renderTexture=meshImage
  colorAt(meshShot(),15,9,1,0,0,1)
  -- PixiSlot._updateZOrder updates the PixiArmatureDisplay child order,
  -- independently from the internal Armature slots array. Overlapping
  -- LÖVE sprites must change the actual visible foreground pixel.
  local zRaw={version="5.5",name="GPUZOrder",frameRate=24,
    armature={{name="rig",bone={{name="root"}},
      slot={{name="back",parent="root",displayIndex=0},
            {name="front",parent="root",displayIndex=0}},
      skin={{name="default",slot={
        {name="back",display={{name="red",path="red",pivot={x=0,y=0}}}},
        {name="front",display={{name="green",path="green",pivot={x=0,y=0}}}}
      }}}}
    }}
  local zFactory=Love.Factory.new()
  zFactory:parseDragonBonesData(zRaw,"zOrder")
  zFactory:parseTextureAtlasData(atlas,image,"zOrder")
  local zRig=assert(zFactory:buildArmature("rig","zOrder"))
  local zBack=assert(zRig:getSlot("back"))
  local zFront=assert(zRig:getSlot("front"))
  local function zShot()
    love.graphics.push("all")
    love.graphics.setCanvas(target)
    love.graphics.clear(0,0,0,0)
    love.graphics.translate(8,8)
    zFactory:drawArmature(zRig)
    love.graphics.setCanvas()
    love.graphics.pop()
    return target:newImageData()
  end
  colorAt(zShot(),9,9,0,1,0,1)
  zBack:_setZOrder(1)
  zBack:update(-1)
  colorAt(zShot(),9,9,1,0,0,1)
  zFront:_setZOrder(1)
  zFront:update(-1)
  colorAt(zShot(),9,9,0,1,0,1)
  -- Change the visual order through the original Armature timeline hook.
  zRig:_sortZOrder({1,0},0)
  zRig:advanceTime(0)
  colorAt(zShot(),9,9,1,0,0,1)
  -- PixiFactory passes the same PixiArmatureDisplay as both proxy and
  -- renderer. A real displayed armature must accept animation events.
  assert(display==clockArmature.proxy)
  assert(display==clockArmature.eventDispatcher)
  assert(display.animation==clockArmature.animation)
  local Events=require("dragonbones.original.event.EventObject")
  local Objects=require("dragonbones.original.core.BaseObject")
  local heard={}
  local listener=function(event) heard[#heard+1]=event.name end
  display:addDBEventListener(Events.FRAME_EVENT,listener)
  local message=Objects.borrowObject(Events)
  message.type=Events.FRAME_EVENT
  message.name="gpuProxy"
  message.armature=clockArmature
  factory.dragonBones:bufferEvent(message)
  factory.dragonBones:advanceTime(0)
  assert(#heard==1 and heard[1]=="gpuProxy")
  display:removeDBEventListener(Events.FRAME_EVENT,listener)
  display:dispose()
  assert(display.armature==nil)
  factory.dragonBones:advanceTime(0) -- deferred Armature pool cleanup
  assert(#display._renderSlots==0)
  -- PixiArmatureDisplay.dbUpdate debug Sprite: cyan line/circle for bones,
  -- magenta outline for a bounding box, drawn above the regular children.
  local debugRaw={
    version="5.5",
    name="GPU-Debug",
    frameRate=24,
    armature={
      {
        name="rig",
        bone={{name="root",length=6,transform={x=8,y=8}}},
        slot={{name="hitbox",parent="root",displayIndex=0}},
        skin={
          {
            name="default",
            slot={
              {
                name="hitbox",
                display={
                  {
                    name="hitbox",type="boundingBox",subType="rectangle",
                    width=10,height=8
                  }
                }
              }
            }
          }
        }
      }
    }
  }
  local debugFactory=Love.Factory.new()
  debugFactory:parseDragonBonesData(debugRaw,"debug")
  local debugRig=assert(debugFactory:buildArmature("rig","debug"))
  local function debugShot()
    love.graphics.push("all")
    love.graphics.setCanvas(target)
    love.graphics.clear(0,0,0,0)
    debugFactory:drawArmature(debugRig)
    love.graphics.setCanvas()
    love.graphics.pop()
    return target:newImageData()
  end
  debugRig:advanceTime(0)
  colorAt(debugShot(),10,8,0,0,0,0)
  debugRig.display.debugDraw=true
  debugRig:advanceTime(0)
  local debugPixels=debugShot()
  colorAt(debugPixels,10,8,0,1,1,0.7)
  colorAt(debugPixels,3,8,1,0,1,0.7)
  colorAt(debugPixels,0,0,0,0,0,0)
  debugRig.display.debugDraw=false
  debugRig:advanceTime(0)
  colorAt(debugShot(),10,8,0,0,0,0)
  colorAt(debugShot(),3,8,0,0,0,0)
  print("Original DragonBones LÖVE GPU passed: images, FFD, atlas, Z-order, proxy events, Pixi debug bones/bounds and clock.")


end
return Test
