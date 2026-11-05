-- Adapted from pinned Pixi/4.x PixiTextureAtlasData.ts; MIT DragonBones contributors.
-- LÖVE Image is caller-owned. A frame/Quad never releases its parent Image.
local Types=require('dragonbones.model.TextureAtlasData')
local Pool=require('dragonbones.core.BaseObject')
local Map=require('dragonbones.core.JSMap')
local Texture={};Texture.__index=Texture;setmetatable(Texture,{__index=Types.TextureData})
function Texture.toString()return'[class dragonBones.LoveTextureData]'end
function Texture.new()return Types.TextureData.new(Texture)end
function Texture:_onClear()
  Types.TextureData._onClear(self)
  if self.renderTexture then self.renderTexture:destroy()end
  self.renderTexture=nil
end
local Frame={};Frame.__index=Frame
function Frame:destroy()
  if self.quad then self.quad:release();self.quad=nil end
  self.destroyed=true
end
local Atlas={};setmetatable(Atlas,{__index=Types.TextureAtlasData})
function Atlas.toString()return'[class dragonBones.LoveTextureAtlasData]'end
function Atlas.new()return Types.TextureAtlasData.new(Atlas)end
function Atlas.__index(self,key)
  if key=='renderTexture'then return self._renderTexture end
  return rawget(Atlas,key)or Types.TextureAtlasData[key]
end
function Atlas.__newindex(self,key,value)
  if key~='renderTexture'then rawset(self,key,value);return end
  if self._renderTexture==value then return end
  self._renderTexture=value
  for _,name in ipairs(Map.keys(self.textures))do
    local texture=self.textures[name]
    if value~=nil then
      assert(not texture.rotated,'Rotated atlas frames are pending in the LÖVE sprite backend')
      local region=texture.region
      texture.renderTexture=setmetatable({image=value,x=region.x,y=region.y,
        width=region.width,height=region.height,destroyed=false},Frame)
    else texture.renderTexture=nil end
  end
end
function Atlas:_onClear()
  Types.TextureAtlasData._onClear(self);self._renderTexture=nil
end
function Atlas:createTexture()return Pool.borrowObject(Texture)end
return {TextureAtlasData=Atlas,TextureData=Texture}
