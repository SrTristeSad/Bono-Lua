-- DragonBonesJS original commit 64b6c69ae35777c2404be68c9192e2c56906079e
-- Copyright (c) 2012-2025 DragonBones team and other contributors.
-- MIT license: see LICENSE-DRAGONBONES.
-- Exact source: DragonBones/src/dragonBones/model/TextureAtlasData.ts
local BaseObject=require("dragonbones.original.core.BaseObject")
local Rectangle=require("dragonbones.original.geom.Rectangle")

local TextureAtlasData={}
TextureAtlasData.__index=TextureAtlasData
setmetatable(TextureAtlasData,{__index=BaseObject})

-- Abstract: a backend subclass must implement createTexture().
function TextureAtlasData.new(classType)
  local object=BaseObject.new(classType)
  object.textures={}
  return object
end

function TextureAtlasData:_onClear()
  for k,texture in pairs(self.textures) do
    texture:returnToPool()
    self.textures[k]=nil
  end

  self.autoSearch=false
  self.width=0
  self.height=0
  self.scale=1.0
  self.name=""
  self.imagePath=""
end

function TextureAtlasData:copyFrom(value)
  self.autoSearch=value.autoSearch
  self.scale=value.scale
  self.width=value.width
  self.height=value.height
  self.name=value.name
  self.imagePath=value.imagePath

  for k,texture in pairs(self.textures) do
    texture:returnToPool()
    self.textures[k]=nil
  end

  for k,source in pairs(value.textures) do
    local texture=self:createTexture()
    texture:copyFrom(source)
    self.textures[k]=texture
  end
end

function TextureAtlasData:createTexture()
  error("Abstract TextureAtlasData.createTexture requires a backend subclass")
end

function TextureAtlasData:addTexture(value)
  if self.textures[value.name]~=nil then
    io.stderr:write("Same texture: "..tostring(value.name).."\n")
    return
  end

  value.parent=self
  self.textures[value.name]=value
end

function TextureAtlasData:getTexture(textureName)
  return self.textures[textureName]
end

local TextureData={}
TextureData.__index=TextureData
setmetatable(TextureData,{__index=BaseObject})

function TextureData.createRectangle()
  return Rectangle.new()
end

function TextureData.new(classType)
  local object=BaseObject.new(classType)
  object.region=Rectangle.new()
  -- TS field initializer: frame = null
  object.frame=nil
  return object
end

function TextureData:_onClear()
  self.rotated=false
  self.name=""
  self.region:clear()
  self.parent=nil
  self.frame=nil
end

function TextureData:copyFrom(value)
  self.rotated=value.rotated
  self.name=value.name
  self.region:copyFrom(value.region)
  self.parent=value.parent

  if self.frame==nil and value.frame~=nil then
    self.frame=TextureData.createRectangle()
  elseif self.frame~=nil and value.frame==nil then
    self.frame=nil
  end

  if self.frame~=nil and value.frame~=nil then
    self.frame:copyFrom(value.frame)
  end
end

return {TextureAtlasData=TextureAtlasData,TextureData=TextureData}
