-- Sprite/mesh paths adapted from pinned Pixi/4.x/src/dragonBones/pixi/PixiSlot.ts.
-- Copyright (c) DragonBones contributors. MIT: LICENSE-DRAGONBONES.
-- Advanced blend modes remain a separate backend slice.
local Slot=require('dragonbones.armature.Slot')
local Pool=require('dragonbones.core.BaseObject')
local Atlas=require('dragonbones.love.TextureAtlasData').TextureAtlasData
local Enums=require('dragonbones.core.Enums')
local Mode=Enums.BlendMode
local Binary=Enums.BinaryOffset
local Shared=require('dragonbones.parser.SharedBinaryBuffer')
local number=require('dragonbones.parser.JSValue').number
local function at(a,i)return number(a[i+1])end
local function typed(count,kind)
  local unit=kind=='uint16'and 2 or 4
  return Shared.view(Shared.new(string.rep('\0',count*unit)),0,count*unit,kind)
end
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
  if self._renderDisplay.kind=='sprite'or self._renderDisplay.kind=='mesh'then
    local color=self._colorTransform
    self._renderDisplay.tint=math.floor(color.redMultiplier*255+.5)*65536
      +math.floor(color.greenMultiplier*255+.5)*256+math.floor(color.blueMultiplier*255+.5)
  end
end
function LoveSlot:_updateFrame()
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
      if self._geometryData~=nil then
        local geometry=self._geometryData
        local ints,floats=geometry.data.intArray,geometry.data.floatArray
        local vertexCount=at(ints,geometry.offset+Binary.GeometryVertexCount)
        local triangleCount=at(ints,geometry.offset+Binary.GeometryTriangleCount)
        local vertexOffset=at(ints,geometry.offset+Binary.GeometryFloatOffset)
        if vertexOffset<0 then vertexOffset=vertexOffset+65536 end
        local uvOffset=vertexOffset+vertexCount*2
        local display=self._renderDisplay
        local image=frame.image
        local width=atlas.width>0 and atlas.width or image.width
        local height=atlas.height>0 and atlas.height or image.height
        if width==nil then width=image:getWidth()end
        if height==nil then height=image:getHeight()end
        local region=texture.region
        display.vertices=typed(vertexCount*2,'float32')
        display.uvs=typed(vertexCount*2,'float32')
        display.indices=typed(triangleCount*3,'uint16')
        for i=0,vertexCount*2-1 do
          display.vertices[i+1]=at(floats,vertexOffset+i)*self._armature._armatureData.scale
        end
        for i=0,triangleCount*3-1 do
          display.indices[i+1]=at(ints,geometry.offset+Binary.GeometryVertexIndices+i)
        end
        for i=0,vertexCount*2-1,2 do
          local u,v=at(floats,uvOffset+i),at(floats,uvOffset+i+1)
          if texture.rotated then
            display.uvs[i+1]=(region.x+(1.0-v)*region.width)/width
            display.uvs[i+2]=(region.y+u*region.height)/height
          else
            display.uvs[i+1]=(region.x+u*region.width)/width
            display.uvs[i+2]=(region.y+v*region.height)/height
          end
        end
        self._textureScale=1.0;display.texture=frame
        display.dirty=display.dirty+1;display.indexDirty=display.indexDirty+1
        display._gpuDirty=true
        if geometry.weight~=nil or self._parent._boneData.type~=Enums.BoneType.Bone then
          self:_identityTransform()
        end
      else
        self._textureScale=texture.parent.scale*self._armature._armatureData.scale
        self._renderDisplay.texture=frame
      end
      self._visibleDirty=true
      return
    end
  end
  local display=self._renderDisplay
  display.texture=nil;display.x=0.0;display.y=0.0;display.visible=false
end
function LoveSlot:_updateMesh()
  local scale=self._armature._armatureData.scale
  local deform=self._displayFrame.deformVertices
  local bones=self._geometryBones
  local geometry=self._geometryData
  local weightData=geometry.weight
  local hasDeform=deform.length>0 and geometry.inheritDeform
  local display=self._renderDisplay
  local ints,floats=geometry.data.intArray,geometry.data.floatArray
  local count=at(ints,geometry.offset+Binary.GeometryVertexCount)
  if weightData~=nil then
    local offset=at(ints,weightData.offset+Binary.WeigthFloatOffset)
    if offset<0 then offset=offset+65536 end
    local iD,iB,iV,iF=0,weightData.offset+Binary.WeigthBoneIndices+bones.length,offset,0
    for i=0,count-1 do
      local boneCount=at(ints,iB);iB=iB+1
      local xG,yG=0.0,0.0
      for j=0,boneCount-1 do
        local index=at(ints,iB);iB=iB+1
        local bone=bones[index+1]
        -- Keep original cursor advancement inside the non-null bone branch.
        if bone~=nil then
          local m=bone.globalTransformMatrix
          local weight=at(floats,iV);iV=iV+1
          local x=at(floats,iV)*scale;iV=iV+1
          local y=at(floats,iV)*scale;iV=iV+1
          if hasDeform then
            x=x+at(deform,iF);iF=iF+1;y=y+at(deform,iF);iF=iF+1
          end
          xG=xG+(m.a*x+m.c*y+m.tx)*weight
          yG=yG+(m.b*x+m.d*y+m.ty)*weight
        end
      end
      display.vertices[iD+1]=xG;iD=iD+1
      display.vertices[iD+1]=yG;iD=iD+1
    end
  else
    local surface=self._parent._boneData.type~=Enums.BoneType.Bone
    local offset=at(ints,geometry.offset+Binary.GeometryFloatOffset)
    if offset<0 then offset=offset+65536 end
    for i=0,count*2-1,2 do
      local x,y=at(floats,offset+i)*scale,at(floats,offset+i+1)*scale
      if hasDeform then x=x+at(deform,i);y=y+at(deform,i+1)end
      if surface then
        local m=self._parent:_getGlobalTransformMatrix(x,y)
        display.vertices[i+1]=m.a*x+m.c*y+m.tx
        display.vertices[i+2]=m.b*x+m.d*y+m.ty
      else display.vertices[i+1]=x;display.vertices[i+2]=y end
    end
  end
  display._gpuDirty=true
end
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
