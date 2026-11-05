-- Sprite path adapted from pinned Pixi/4.x/src/dragonBones/pixi/PixiSlot.ts.
-- Copyright (c) DragonBones contributors. MIT: LICENSE-DRAGONBONES.
-- Meshes and advanced blend modes deliberately reject use in this first backend slice.
local Slot=require('dragonbones.armature.Slot')
local Pool=require('dragonbones.core.BaseObject')
local Atlas=require('dragonbones.love.TextureAtlasData').TextureAtlasData
local Mode=require('dragonbones.core.Enums').BlendMode
local LoveSlot={__newindex=Slot.__newindex}
LoveSlot.__index=function(self,key)return rawget(LoveSlot,key)or Slot.__index(self,key)end
setmetatable(LoveSlot,{__index=Slot})
function LoveSlot.toString()return'[class dragonBones.LoveSlot]'end
function LoveSlot.new()return Slot.new(LoveSlot)end
function LoveSlot:_onClear()
  Slot._onClear(self);self._textureScale=1.0;self._renderDisplay=nil
end
function LoveSlot:_initDisplay()end -- Original empty retain hook.
function LoveSlot:_disposeDisplay(value,isRelease)
  if not isRelease then value:destroy()end
end
function LoveSlot:_onUpdateDisplay()self._renderDisplay=self._display or self._rawDisplay end
function LoveSlot:_addDisplay()self._armature.display:addChild(self._renderDisplay)end
function LoveSlot:_replaceDisplay(value)
  local container=self._armature.display
  container:addChild(self._renderDisplay);container:swapChildren(self._renderDisplay,value)
  container:removeChild(value);self._textureScale=1.0
end
function LoveSlot:_removeDisplay()self._renderDisplay.parent:removeChild(self._renderDisplay)end
function LoveSlot:_updateZOrder()
  local container=self._armature.display
  if container:getChildIndex(self._renderDisplay)==self._zOrder then return end
  container:addChildAt(self._renderDisplay,self._zOrder)
end
function LoveSlot:_updateVisible()self._renderDisplay.visible=self._parent.visible and self._visible end
function LoveSlot:_updateBlendMode()
  if self._renderDisplay.kind=='sprite'then
    assert(self._blendMode==Mode.Normal or self._blendMode==Mode.Add,
      'LÖVE sprite backend currently supports Normal/Add blend only')
    self._renderDisplay.blendMode=self._blendMode==Mode.Add and 1 or 0
  end
end
function LoveSlot:_updateColor()
  self._renderDisplay.alpha=self._colorTransform.alphaMultiplier*self._globalAlpha
  if self._renderDisplay.kind=='sprite'then
    local color=self._colorTransform
    self._renderDisplay.tint=math.floor(color.redMultiplier*255+.5)*65536
      +math.floor(color.greenMultiplier*255+.5)*256+math.floor(color.blueMultiplier*255+.5)
  end
end
function LoveSlot:_updateFrame()
  assert(self._geometryData==nil,'Mesh rendering is pending in the LÖVE sprite backend')
  local texture=self._textureData
  if self._displayIndex>=0 and self._display~=nil and texture~=nil then
    local atlas=texture.parent
    if self._armature.replacedTexture~=nil then
      if self._armature._replaceTextureAtlasData==nil then
        atlas=Pool.borrowObject(Atlas);atlas:copyFrom(texture.parent)
        atlas.renderTexture=self._armature.replacedTexture
        self._armature._replaceTextureAtlasData=atlas
      else atlas=self._armature._replaceTextureAtlasData end
      texture=atlas:getTexture(texture.name)
    end
    local frame=texture.renderTexture
    if frame~=nil then
      self._textureScale=texture.parent.scale*self._armature._armatureData.scale
      self._renderDisplay.texture=frame;self._visibleDirty=true
      return
    end
  end
  local display=self._renderDisplay
  display.texture=nil;display.x=0.0;display.y=0.0;display.visible=false
end
function LoveSlot:_updateMesh()error('Mesh rendering is pending in the LÖVE sprite backend')end
function LoveSlot:_updateTransform()
  self:updateGlobalTransform()
  local transform=self.global
  local x,y=transform.x,transform.y
  local sx,sy=transform.scaleX,transform.scaleY
  if self._renderDisplay==self._rawDisplay or self._renderDisplay==self._meshDisplay then
    local m=self.globalTransformMatrix
    x=x-(m.a*self._pivotX+m.c*self._pivotY)
    y=y-(m.b*self._pivotX+m.d*self._pivotY)
    sx=sx*self._textureScale;sy=sy*self._textureScale
  end
  self._renderDisplay:setTransform(x,y,sx,sy,transform.rotation,-transform.skew,0.0)
end
function LoveSlot:_identityTransform()self._renderDisplay:setTransform(0,0,1,1,0,0,0)end
return LoveSlot
