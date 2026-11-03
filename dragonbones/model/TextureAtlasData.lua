-- DragonBonesJS original commit 64b6c69ae35777c2404be68c9192e2c56906079e
-- Copyright (c) 2012-2025 DragonBones team and other contributors.
-- MIT license: see LICENSE-DRAGONBONES.
-- Exact source: DragonBones/src/dragonBones/model/TextureAtlasData.ts
local BaseObject=require("dragonbones.core.BaseObject")
local Rectangle=require("dragonbones.geom.Rectangle")

-- Preserve JS own-string-key iteration without replacing the public textures
-- table with an opaque proxy. New ordinary assignments record insertion order;
-- overwrites retain it, and delete/reinsert gets a new position.
local textureOrders=setmetatable({},{__mode="k"})
local function newTextureMap()
  local state={positions={},next=0}
  local map=setmetatable({}, {__newindex=function(t,key,value)
    if value~=nil then state.next=state.next+1;state.positions[key]=state.next end
    rawset(t,key,value)
  end})
  textureOrders[map]=state
  return map
end
local function arrayIndex(key)
  if key~="0" and not key:match("^[1-9]%d*$") then return nil end
  local n=tonumber(key)
  if n and n<4294967295 then return n end
  return nil
end
local function textureKeys(map)
  local state=textureOrders[map]
  for key in pairs(state.positions) do if map[key]==nil then state.positions[key]=nil end end
  local keys={}
  for key in pairs(map) do keys[#keys+1]=key end
  table.sort(keys,function(a,b)
    local ai,bi=arrayIndex(a),arrayIndex(b)
    if ai~=nil and bi~=nil then return ai<bi end
    if ai~=nil then return true end
    if bi~=nil then return false end
    return state.positions[a]<state.positions[b]
  end)
  return keys
end
local function removeTexture(map,key)
  map[key]=nil
  textureOrders[map].positions[key]=nil
end

local TextureAtlasData={}
TextureAtlasData.__index=TextureAtlasData
setmetatable(TextureAtlasData,{__index=BaseObject})

-- Abstract: a backend subclass must implement createTexture().
function TextureAtlasData.new(classType)
  local object=BaseObject.new(classType)
  object.textures=newTextureMap()
  return object
end

function TextureAtlasData:_onClear()
  for _,k in ipairs(textureKeys(self.textures)) do
    local texture=self.textures[k]
    if texture~=nil then
      texture:returnToPool()
      removeTexture(self.textures,k)
    end
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

  for _,k in ipairs(textureKeys(self.textures)) do
    local texture=self.textures[k]
    if texture~=nil then
      texture:returnToPool()
      removeTexture(self.textures,k)
    end
  end

  for _,k in ipairs(textureKeys(value.textures)) do
    if value.textures[k]~=nil then
      local texture=self:createTexture()
      texture:copyFrom(value.textures[k])
      self.textures[k]=texture
    end
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
