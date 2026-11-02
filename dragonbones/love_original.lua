-- LÖVE 11.x backend for the *original* DragonBones Lua runtime.
-- Adapts BaseFactory, Slot, Armature and TextureAtlasData. The runtime
-- algorithms remain in dragonbones/original and are not copied here.
-- Platform adaptation reference: DragonBonesJS (MIT), pinned commit
-- 64b6c69ae35777c2404be68c9192e2c56906079e,
-- Pixi/5.x/src/dragonBones/pixi/{PixiFactory,PixiSlot}.ts.
-- Currently handles ordinary and atlas-rotated IMAGE displays.
-- Mesh/FFD rendering is deliberately not claimed until ported.
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
    a=1,bm="alpha",texture=nil,quad=nil,
    a11=1,a12=0,a21=0,a22=1,tx=0,ty=0}
end
function LoveSlot:_onClear()
  Slot._onClear(self)
  self._renderDisplay=nil
  self._textureScale=1
end
function LoveSlot:_initDisplay(_value,_retain) end
function LoveSlot:_disposeDisplay(value,_release)
  if value~=nil then value.quad=nil end
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
function LoveSlot:_updateBlendMode()
  -- LÖVE's regular blend modes cover a subset of DragonBones/Pixi.
  local blend=self._blendMode
  local modes=DragonBones.BlendMode
  local mode
  if blend==modes.Normal then mode="alpha"
  elseif blend==modes.Add then mode="add"
  elseif blend==modes.Multiply then mode="multiply"
  elseif blend==modes.Screen then mode="screen"
  elseif blend==modes.Subtract then mode="subtract"
  elseif blend==modes.Lighten then mode="lighten"
  elseif blend==modes.Darken then mode="darken"
  else
    error("LÖVE backend: DragonBones blend mode not yet supported: "..tostring(blend))
  end
  if self._renderDisplay then self._renderDisplay.bm=mode end
end
function LoveSlot:_updateColor()
  local render=self._renderDisplay
  if render~=nil then
    local c=self._colorTransform
    render.r=c.redMultiplier
    render.g=c.greenMultiplier
    render.b=c.blueMultiplier
    render.alpha=c.alphaMultiplier*self._globalAlpha
  end
end
function LoveSlot:_updateFrame()
  local render=self._renderDisplay
  if render==nil then return end
  render.texture=nil
  render.quad=nil
  local texture=self._textureData
  if self._display==nil or self._displayIndex<0 or texture==nil then return end
  if self._geometryData~=nil and self._display==self._meshDisplay then
    error("LÖVE backend: original mesh/FFD display not implemented")
  end
  local atlas=texture.parent
  if atlas==nil or atlas.image==nil then return end
  local image=atlas.image
  assert(type(image.getWidth)=="function" and type(image.getHeight)=="function",
    "LÖVE backend: textureAtlas must be a LÖVE Image")
  local width,height=image:getWidth(),image:getHeight()
  local r=texture.region
  -- LÖVE objects are created lazily, only inside a running graphics context.
  render.quad=love.graphics.newQuad(r.x,r.y,r.width,r.height,width,height)
  render.texture=image
  render.rotated=texture.rotated
  render.packedWidth=r.width
  self._textureScale=atlas.scale*self._armature._armatureData.scale
  self._visibleDirty=true
end
function LoveSlot:_updateMesh()
  error("LÖVE backend: original mesh/FFD deformation rendering not implemented")
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
  return rawget(LoveFactory,key) or BaseFactory.__index(self,key)
end
setmetatable(LoveFactory,{__index=BaseFactory})

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

function LoveFactory.new(dataParser)
  local f=BaseFactory.new(dataParser)
  setmetatable(f,LoveFactory)
  f._eventManager=makeDispatcher()
  f._dragonBones=DragonBones.new(f._eventManager)
  return f
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

-- Draw an already advanced original Armature in its actual sorted-slot order.
-- World transforms, animation, slots and pose remain the original Lua ports.
local function drawArmature(armature)
  local graphics=assert(love and love.graphics,
    "LoveFactory.drawArmature requires LÖVE graphics")
  for _,slot in ipairs(armature:getSlots()) do
    local render=slot._renderDisplay
    if slot._display~=nil and render~=nil and render.visible
        and render.texture~=nil and render.quad~=nil then
      local a,b,c,d=render.a11,render.a21,render.a12,render.a22
      local tx,ty=render.tx,render.ty
      if render.rotated then
        -- Original atlas stores rotated sprites clockwise. The packed
        -- source is de-rotated before applying the original world matrix.
        tx,ty=tx+c*render.packedWidth,ty+d*render.packedWidth
        a,b,c,d=-c,-d,a,b
      end
      local transform=love.math.newTransform()
      transform:setMatrix("row",
        a,c,0,tx,
        b,d,0,ty,
        0,0,1,0,
        0,0,0,1)
      graphics.push("all")
      graphics.setBlendMode(render.bm)
      graphics.setColor(render.r,render.g,render.b,render.alpha)
      graphics.applyTransform(transform)
      graphics.draw(render.texture,render.quad,0,0)
      graphics.pop()
    elseif slot.childArmature~=nil then
      -- Child armatures share the graphics context but use their own runtime
      -- transforms; follow-up integration will supply their parent transform.
      error("LÖVE backend: nested armature drawing not yet supported")
    end
  end
end
function LoveFactory:drawArmature(armature)
  return drawArmature(armature)
end

return {Factory=LoveFactory,Slot=LoveSlot,TextureAtlasData=LoveAtlas,
  TextureData=LoveTexture}
