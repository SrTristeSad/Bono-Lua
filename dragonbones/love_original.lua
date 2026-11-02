-- LÖVE 11.x backend for the *original* DragonBones Lua runtime.
-- Adapts BaseFactory, Slot, Armature and TextureAtlasData. The runtime
-- algorithms remain in dragonbones/original and are not copied here.
-- Platform adaptation reference: DragonBonesJS (MIT), pinned commit
-- 64b6c69ae35777c2404be68c9192e2c56906079e,
-- Pixi/5.x/src/dragonBones/pixi/{PixiFactory,PixiSlot}.ts.
-- IMAGE and MESH displays follow the pinned PixiSlot.ts geometry and FFD
-- algorithms, with LÖVE meshes as the graphics transport.
local BaseFactory=require("dragonbones.original.factory.BaseFactory")
local Slot=require("dragonbones.original.armature.Slot")
local Armature=require("dragonbones.original.armature.Armature")
local BaseObject=require("dragonbones.original.core.BaseObject")
local DragonBones=require("dragonbones.original.core.DragonBones")
local TextureModels=require("dragonbones.original.model.TextureAtlasData")

local LoveTexture={}
LoveTexture.__index=LoveTexture
setmetatable(LoveTexture,{__index=TextureModels.TextureData})
function LoveTexture.new()
  return TextureModels.TextureData.new(LoveTexture)
end
function LoveTexture:_onClear()
  TextureModels.TextureData._onClear(self)
  self.quad=nil
end

local LoveAtlas={}
LoveAtlas.__index=function(self,key)
  return rawget(LoveAtlas,key) or TextureModels.TextureAtlasData[key]
end
setmetatable(LoveAtlas,{__index=TextureModels.TextureAtlasData})
function LoveAtlas.new()
  local a=TextureModels.TextureAtlasData.new(LoveAtlas)
  a.image=nil
  return a
end
function LoveAtlas:_onClear()
  TextureModels.TextureAtlasData._onClear(self)
  self.image=nil
end
function LoveAtlas:createTexture()
  return BaseObject.borrowObject(LoveTexture)
end

local LoveSlot={}
LoveSlot.__index=function(self,key)
  return rawget(LoveSlot,key) or Slot.__index(self,key)
end
LoveSlot.__newindex=Slot.__newindex
setmetatable(LoveSlot,{__index=Slot})
function LoveSlot.new()
  return Slot.new(LoveSlot)
end

local function node(kind)
  return {kind=kind,visible=true,alpha=1,r=1,g=1,b=1,
    a=1,bm="alpha",texture=nil,quad=nil,mesh=nil,vertices=nil,
    a11=1,a12=0,a21=0,a22=1,tx=0,ty=0}
end
function LoveSlot:_onClear()
  Slot._onClear(self)
  self._renderDisplay=nil
  self._textureScale=1
end
function LoveSlot:_initDisplay(_value,_retain) end
function LoveSlot:_disposeDisplay(value,_release)
  if value~=nil then value.quad=nil;value.mesh=nil;value.vertices=nil end
end
function LoveSlot:_onUpdateDisplay()
  self._renderDisplay=self._display or self._rawDisplay
end
function LoveSlot:_addDisplay() end
function LoveSlot:_replaceDisplay(_previous)
  self._textureScale=1
end
function LoveSlot:_removeDisplay() end
function LoveSlot:_updateZOrder() end
function LoveSlot:_updateVisible()
  local render=self._renderDisplay
  if render then
    render.visible=self._visible and self._parent.visible
  end
end
-- PixiSlot.ts updates the blend mode only on a PIXI.Sprite. A mesh
-- or child Armature display never receives this switch in the pinned source.
-- Modes absent from the Pixi switch preserve the previous sprite mode.
function LoveSlot:_updateBlendMode()
  local render=self._renderDisplay
  if render==nil or render.kind~="image" then return end
  local blend=self._blendMode
  local modes=DragonBones.BlendMode
  local mode
  if blend==modes.Normal then mode="alpha"
  elseif blend==modes.Add then mode="add"
  elseif blend==modes.Darken then mode="darken"
  elseif blend==modes.Lighten then mode="lighten"
  elseif blend==modes.Multiply then mode="multiply"
  elseif blend==modes.Screen then mode="screen"
  elseif blend==modes.Difference or blend==modes.HardLight
      or blend==modes.Overlay then
    -- The original Pixi adapter implements these three. Standard
    -- LÖVE blend modes do not; do not silently render the wrong mode.
    error("LÖVE backend: Pixi blend mode requires an unported shader: "..tostring(blend))
  end
  if mode~=nil then render.bm=mode end
end

-- PixiSlot._updateColor packs its three rounded multipliers into a
-- 24-bit tint integer: (round(r*255)<<16)+(round(g*255)<<8)+round(b*255).
-- The JS bitwise shifts wrap their operands to 8 bits at the tint's
-- RGB extraction; retain addition (not OR) and its potential carries.
local function pixiTintChannels(r,g,b)
  local rr=math.floor(r*255+0.5)
  local gg=math.floor(g*255+0.5)
  local bb=math.floor(b*255+0.5)
  local tint=((rr%256)*65536+(gg%256)*256+bb)%16777216
  return math.floor(tint/65536)/255,
    (math.floor(tint/256)%256)/255,(tint%256)/255
end

function LoveSlot:_updateColor()
  local render=self._renderDisplay
  if render~=nil then
    local c=self._colorTransform
    -- All Pixi display types (including child Armature containers) receive
    -- the unquantized alpha product. Only Sprite and SimpleMesh get tint.
    render.alpha=c.alphaMultiplier*self._globalAlpha
    if render.kind=="image" or render.kind=="mesh" then
      render.r,render.g,render.b=pixiTintChannels(
        c.redMultiplier,c.greenMultiplier,c.blueMultiplier)
    end
  end
end
-- Original PixiSlot.ts accesses Uint16Array/Float32Array via zero-based
-- offsets. All arrays in the Lua parser are 1-based; only this accessor
-- translates the index, without changing the original offset arithmetic.
local function dataAt(array,offset)
  return array[offset+1]
end
local function correctedOffset(value)
  -- Preserve the original DragonBones 16-bit overflow workaround.
  return value<0 and value+65536 or value
end

function LoveSlot:_updateFrame()
  local render=self._renderDisplay
  if render==nil then return end
  render.texture=nil
  render.quad=nil
  render.mesh=nil
  render.vertices=nil
  local texture=self._textureData
  -- PixiSlot._updateFrame's no-frame branch clears the Sprite/SimpleMesh
  -- texture, resets local x/y and hides the display. The original runtime
  -- still controls _displayIndex and all slot invalidation.
  local function hideUntexturedDisplay()
    render.tx,render.ty=0,0
    render.visible=false
  end
  if self._display==nil or self._displayIndex<0 or texture==nil then
    hideUntexturedDisplay()
    return
  end
  -- Pinned PixiSlot._updateFrame: clone the source TextureAtlasData once
  -- per armature when replacedTexture is assigned. TextureData.copyFrom
  -- intentionally retains its original source parent as upstream does.
  local atlas=texture.parent
  if self._armature.replacedTexture~=nil then
    if self._armature._replaceTextureAtlasData==nil then
      local replacement=BaseObject.borrowObject(LoveAtlas)
      replacement:copyFrom(atlas)
      replacement.image=self._armature.replacedTexture
      self._armature._replaceTextureAtlasData=replacement
    end
    atlas=self._armature._replaceTextureAtlasData
    texture=atlas:getTexture(texture.name)
  end
  if atlas==nil or atlas.image==nil or texture==nil then
    hideUntexturedDisplay()
    return
  end
  local image=atlas.image
  assert(type(image.getWidth)=="function" and type(image.getHeight)=="function",
    "LÖVE backend: textureAtlas must be a LÖVE Image")
  local imageWidth,imageHeight=image:getWidth(),image:getHeight()
  local region=texture.region

  if self._geometryData~=nil and self._display==self._meshDisplay then
    -- PixiSlot._updateFrame: positions, UV rotation and triangle indices.
    local geometry=self._geometryData
    local data=geometry.data
    local intArray,floatArray=data.intArray,data.floatArray
    local offset=DragonBones.BinaryOffset
    local vertexCount=dataAt(intArray,geometry.offset+offset.GeometryVertexCount)
    local triangleCount=dataAt(intArray,geometry.offset+offset.GeometryTriangleCount)
    local vertexOffset=correctedOffset(dataAt(intArray,
      geometry.offset+offset.GeometryFloatOffset))
    local uvOffset=vertexOffset+vertexCount*2
    local scale=self._armature._armatureData.scale
    local vertices={}
    for i=0,vertexCount-1 do
      local x=dataAt(floatArray,vertexOffset+i*2)*scale
      local y=dataAt(floatArray,vertexOffset+i*2+1)*scale
      local u=dataAt(floatArray,uvOffset+i*2)
      local v=dataAt(floatArray,uvOffset+i*2+1)
      if texture.rotated then
        u,v=1-v,u
      end
      -- Pixi's renderTexture applies the atlas frame to [0,1] UVs.
      -- LÖVE's Mesh uses UVs of the entire Image instead.
      u=(region.x+u*region.width)/imageWidth
      v=(region.y+v*region.height)/imageHeight
      vertices[i+1]={x,y,u,v,1,1,1,1}
    end
    local indices={}
    for i=0,triangleCount*3-1 do
      indices[i+1]=dataAt(intArray,
        geometry.offset+offset.GeometryVertexIndices+i)+1
    end
    render.vertices=vertices
    if vertexCount>0 and #indices>0 then
      local mesh=love.graphics.newMesh(vertices,"triangles","dynamic")
      mesh:setVertexMap(indices)
      mesh:setTexture(image)
      render.mesh=mesh
    end
    self._textureScale=1
    render.texture=image
    if geometry.weight~=nil
        or self._parent._boneData.type~=DragonBones.BoneType.Bone then
      self:_identityTransform()
    end
  else
    -- Original simple image path; rotated packed frames are handled at draw.
    render.quad=love.graphics.newQuad(region.x,region.y,
      region.width,region.height,imageWidth,imageHeight)
    render.texture=image
    render.rotated=texture.rotated
    render.packedWidth=region.width
    self._textureScale=atlas.scale*self._armature._armatureData.scale
  end
  self._visibleDirty=true
end

function LoveSlot:_updateMesh()
  -- Direct translation of PixiSlot._updateMesh, pinned DragonBonesJS commit.
  -- Graphics transport differs: setVertices updates the LÖVE GPU buffer.
  local render=self._renderDisplay
  if render==nil or render.mesh==nil then return end
  local scale=self._armature._armatureData.scale
  local geometry=self._geometryData
  local data=geometry.data
  local ints,floats=data.intArray,data.floatArray
  local offset=DragonBones.BinaryOffset
  local deform=self._displayFrame.deformVertices
  local hasDeform=#deform>0 and geometry.inheritDeform
  local vertexCount=dataAt(ints,geometry.offset+offset.GeometryVertexCount)
  local bones=self._geometryBones
  local weight=geometry.weight
  local vertices=render.vertices

  if weight~=nil then
    local weightFloatOffset=correctedOffset(dataAt(ints,
      weight.offset+offset.WeigthFloatOffset))
    local iB=weight.offset+offset.WeigthBoneIndices+#bones
    local iV=weightFloatOffset
    local iF=0
    for i=0,vertexCount-1 do
      local boneCount=dataAt(ints,iB);iB=iB+1
      local xG,yG=0,0
      for _=1,boneCount do
        local boneIndex=dataAt(ints,iB);iB=iB+1
        local bone=bones[boneIndex+1]
        if bone~=nil then
          local matrix=bone.globalTransformMatrix
          local boneWeight=dataAt(floats,iV);iV=iV+1
          local xL=dataAt(floats,iV)*scale;iV=iV+1
          local yL=dataAt(floats,iV)*scale;iV=iV+1
          if hasDeform then
            xL=xL+deform[iF+1];iF=iF+1
            yL=yL+deform[iF+1];iF=iF+1
          end
          xG=xG+(matrix.a*xL+matrix.c*yL+matrix.tx)*boneWeight
          yG=yG+(matrix.b*xL+matrix.d*yL+matrix.ty)*boneWeight
        end
      end
      vertices[i+1][1],vertices[i+1][2]=xG,yG
    end
  else
    local isSurface=self._parent._boneData.type~=DragonBones.BoneType.Bone
    local vertexOffset=correctedOffset(dataAt(ints,
      geometry.offset+offset.GeometryFloatOffset))
    for i=0,vertexCount-1 do
      local x=dataAt(floats,vertexOffset+i*2)*scale
      local y=dataAt(floats,vertexOffset+i*2+1)*scale
      if hasDeform then
        x=x+deform[i*2+1]
        y=y+deform[i*2+2]
      end
      if isSurface then
        local matrix=self._parent:_getGlobalTransformMatrix(x,y)
        vertices[i+1][1]=matrix.a*x+matrix.c*y+matrix.tx
        vertices[i+1][2]=matrix.b*x+matrix.d*y+matrix.ty
      else
        vertices[i+1][1],vertices[i+1][2]=x,y
      end
    end
  end
  render.mesh:setVertices(vertices)
end
function LoveSlot:_updateTransform()
  self:updateGlobalTransform()
  local m=self.globalTransformMatrix
  local scale=self._textureScale
  local a,b,c,d=m.a*scale,m.b*scale,m.c*scale,m.d*scale
  local x=m.tx-(m.a*self._pivotX+m.c*self._pivotY)
  local y=m.ty-(m.b*self._pivotX+m.d*self._pivotY)
  local render=self._renderDisplay
  if render==nil then return end
  render.a11,render.a21,render.a12,render.a22=a,b,c,d
  render.tx,render.ty=x,y
end
function LoveSlot:_identityTransform()
  local render=self._renderDisplay
  if render then
    render.a11,render.a12,render.a21,render.a22=1,0,0,1
    render.tx,render.ty=0,0
  end
end

local LoveFactory={}
LoveFactory.__index=function(self,key)
  if key=="soundEventManager" then
    return self._dragonBones.eventManager
  end
  return rawget(LoveFactory,key) or BaseFactory.__index(self,key)
end
-- PixiFactory.factory is a lazily created class-level singleton, separate
-- from the shared DragonBones runtime. LÖVE has no PIXI.Ticker.shared;
-- callers drive time explicitly through LoveFactory.advanceTime.
setmetatable(LoveFactory,{__index=function(_,key)
  if key=="factory" then
    if LoveFactory._factory==nil then LoveFactory._factory=LoveFactory.new() end
    return LoveFactory._factory
  end
  return BaseFactory[key]
end})

local function makeDispatcher()
  local listeners={}
  local dispatcher={}
  function dispatcher:addDBEventListener(eventType,callback)
    if listeners[eventType]==nil then listeners[eventType]={} end
    listeners[eventType][#listeners[eventType]+1]=callback
  end
  function dispatcher:removeDBEventListener(eventType,callback)
    local list=listeners[eventType]
    if list~=nil then
      for i=#list,1,-1 do
        if list[i]==callback then table.remove(list,i) end
      end
    end
  end
  function dispatcher:hasDBEventListener(eventType)
    return listeners[eventType]~=nil and #listeners[eventType]>0
  end
  function dispatcher:dispatchDBEvent(eventType,event)
    for _,callback in ipairs(listeners[eventType] or {}) do
      callback(event)
    end
  end
  function dispatcher:dbInit(armature)
    self.armature=armature
  end
  function dispatcher:dbUpdate() end
  function dispatcher:dbClear()
    self.armature=nil
  end
  return dispatcher
end

-- PixiFactory shares one DragonBones instance and its sound dispatcher
-- across all factory instances. Only atlas/data caches belong to each
-- individual BaseFactory instance.
function LoveFactory.new(dataParser)
  local f=BaseFactory.new(dataParser)
  setmetatable(f,LoveFactory)
  if LoveFactory._dragonBonesInstance==nil then
    local eventManager=makeDispatcher()
    LoveFactory._dragonBonesInstance=DragonBones.new(eventManager)
  end
  f._dragonBones=LoveFactory._dragonBonesInstance
  f._eventManager=f._dragonBones.eventManager
  return f
end

-- Original PixiFactory static advanceTime(passedTime): its shared runtime
-- is updated in seconds, without the Pixi ticker's frame conversion.
function LoveFactory.advanceTime(passedTime)
  if LoveFactory._dragonBonesInstance==nil then
    error("LÖVE backend: create a Factory before advanceTime")
  end
  LoveFactory._dragonBonesInstance:advanceTime(passedTime)
end

-- PixiFactory.newInstance() reuses the static factory; the source's
-- useSharedTicker option has no LÖVE equivalent and is intentionally absent.
function LoveFactory.newInstance()
  return LoveFactory.factory
end

-- PixiFactory.buildArmatureDisplay: builds from the original BaseFactory
-- and adds the resulting Armature to the shared DragonBones WorldClock.
function LoveFactory:buildArmatureDisplay(armatureName,
    dragonBonesName,skinName,textureAtlasName)
  local armature=self:buildArmature(
    armatureName,dragonBonesName or "",skinName or "",textureAtlasName or "")
  if armature~=nil then
    self._dragonBones.clock:add(armature)
    return armature.display
  end
  return nil
end

-- PixiFactory.getTextureDisplay returns a stand-alone PIXI.Sprite.
-- The corresponding LÖVE backend display is an Image/Quad node bearing
-- the same atlas crop and rotation, with drawing in drawTextureDisplay.
function LoveFactory:getTextureDisplay(textureName,textureAtlasName)
  local textureData=self:_getTextureData(textureAtlasName or "",textureName)
  if textureData==nil or textureData.parent==nil
      or textureData.parent.image==nil then return nil end
  local texture=textureData.parent.image
  local region=textureData.region
  local render=node("image")
  render.texture=texture
  render.quad=love.graphics.newQuad(region.x,region.y,region.width,
    region.height,texture:getWidth(),texture:getHeight())
  render.rotated=textureData.rotated
  render.packedWidth=region.width
  return render
end
function LoveFactory:_buildTextureAtlasData(atlasData,textureAtlas)
  if atlasData==nil then
    return BaseObject.borrowObject(LoveAtlas)
  end
  atlasData.image=textureAtlas
  return atlasData
end
function LoveFactory:_buildArmature(pkg)
  local armature=BaseObject.borrowObject(Armature)
  local proxy=makeDispatcher()
  local display={armature=armature}
  armature:init(pkg.armature,proxy,display,self._dragonBones)
  return armature
end
function LoveFactory:_buildSlot(_pkg,slotData,armature)
  local slot=BaseObject.borrowObject(LoveSlot)
  slot:init(slotData,armature,node("image"),node("mesh"))
  return slot
end

-- The original PixiArmatureDisplay is a container. Child Armature display
-- objects are installed into the parent Slot, and share that Slot's transform.
-- LÖVE lacks PIXI's display tree, so the equivalent container transform is
-- applied on the graphics stack while drawing the actual child Armature.
-- No animation, constraint or slot ordering is reimplemented here.
local function applyRenderTransform(graphics,render)
  local a,b,c,d=render.a11,render.a21,render.a12,render.a22
  local tx,ty=render.tx,render.ty
  if render.rotated then
    -- The packed image is rotated clockwise in the source atlas.
    tx,ty=tx+c*render.packedWidth,ty+d*render.packedWidth
    a,b,c,d=-c,-d,a,b
  end
  local transform=love.math.newTransform()
  transform:setMatrix("row",
    a,c,0,tx,
    b,d,0,ty,
    0,0,1,0,
    0,0,0,1)
  graphics.applyTransform(transform)
end

-- Pixi textures live in a display container, whereas LÖVE's draw commands
-- retain the specific Image or Mesh texture captured at _updateFrame.
-- The upstream Armature setter invalidates Slot transforms; in the Lua host
-- we refresh that GPU resource at draw only when the image identity changes.
-- Slot/Armature animation and data algorithms are left untouched.
local function synchronizeRenderTexture(slot)
  local render=slot._renderDisplay
  if render==nil or slot._textureData==nil or slot._displayIndex<0 then
    return
  end
  if slot._display~=slot._rawDisplay
      and slot._display~=slot._meshDisplay then return end
  local originalAtlas=slot._textureData.parent
  local expected=slot._armature.replacedTexture
      or (originalAtlas~=nil and originalAtlas.image)
  if render.texture~=expected then
    slot:_updateFrame()
    if render.mesh~=nil and slot._geometryData~=nil then
      slot:_updateMesh()
    end
    -- Restore the display's position after the unavailable-texture branch
    -- reset it to zero. Skinned and surface meshes deliberately retain the
    -- identity transform established by PixiSlot._updateFrame.
    if render.texture~=nil and (slot._geometryData==nil or
        (slot._geometryData.weight==nil and
         slot._parent._boneData.type==DragonBones.BoneType.Bone)) then
      slot:_updateTransform()
    end
    -- LÖVE binds its resource when drawing; Pixi updates its retained
    -- Sprite during Slot.update. Re-apply the original visibility predicate
    -- after reattaching an image so an earlier hidden frame can reappear.
    if slot._visibleDirty then
      slot:_updateVisible()
      slot._visibleDirty=false
    end
  end
end

-- Preserve the original parent/child display hierarchy and the ordering of
-- Armature.getSlots(): a child is drawn at its parent Slot's exact position
-- among sibling slots. Visibility comes from Slot._updateVisible.
local function drawArmature(armature, inheritedAlpha)
  inheritedAlpha=inheritedAlpha or 1
  local graphics=assert(love and love.graphics,
    "LoveFactory.drawArmature requires LÖVE graphics")
  for _,slot in ipairs(armature:getSlots()) do
    synchronizeRenderTexture(slot)
    local render=slot._renderDisplay
    if slot._display~=nil and render~=nil and render.visible then
      local child=slot.childArmature
      if child~=nil then
        -- PixiSlot._updateTransformV4 applies the child display's own
        -- global Slot transform; children retain their local transforms.
        graphics.push("all")
        applyRenderTransform(graphics,render)
        -- PixiArmatureDisplay is a container whose alpha multiplies
        -- the alpha of every nested Sprite/Mesh in the display tree.
        drawArmature(child,inheritedAlpha*(render.alpha or 1))
        graphics.pop()
      elseif render.texture~=nil and
          (render.quad~=nil or render.mesh~=nil) then
        graphics.push("all")
        applyRenderTransform(graphics,render)
        graphics.setBlendMode(render.bm)
        graphics.setColor(render.r,render.g,render.b,
          render.alpha*inheritedAlpha)
        if render.mesh~=nil then
          graphics.draw(render.mesh,0,0)
        else
          graphics.draw(render.texture,render.quad,0,0)
        end
        graphics.pop()
      end
    end
  end
end
function LoveFactory:drawArmature(armature)
  return drawArmature(armature)
end

-- LÖVE has no retained PIXI.Sprite scene graph. Draw the stand-alone
-- display returned by getTextureDisplay using the same adapter matrix and
-- atlas-rotation path as normal PixiSlot image displays.
function LoveFactory:drawTextureDisplay(display)
  if display==nil or display.visible==false or display.texture==nil then
    return
  end
  local graphics=assert(love and love.graphics,
    "LoveFactory.drawTextureDisplay requires LÖVE graphics")
  graphics.push("all")
  applyRenderTransform(graphics,display)
  graphics.setBlendMode(display.bm)
  graphics.setColor(display.r,display.g,display.b,display.alpha)
  graphics.draw(display.texture,display.quad,0,0)
  graphics.pop()
end

return {Factory=LoveFactory,Slot=LoveSlot,TextureAtlasData=LoveAtlas,
  TextureData=LoveTexture}
