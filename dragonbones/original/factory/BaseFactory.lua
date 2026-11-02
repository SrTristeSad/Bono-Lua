-- Partial 1:1 Lua port of DragonBonesJS BaseFactory.ts, pinned commit
-- 64b6c69ae35777c2404be68c9192e2c56906079e (MIT).
-- Copyright (c) 2012-2025 DragonBones team and other contributors.
-- See LICENSE-DRAGONBONES.
--
-- This class is abstract in the source. A backend MUST implement
-- _buildTextureAtlasData and _buildArmature before constructing displays.
-- The cache, parsers and build-package search here are actual source methods,
-- not a substitute rendering implementation.
local ObjectDataParser=require("dragonbones.original.parser.ObjectDataParser")
local BinaryDataParser=require("dragonbones.original.parser.BinaryDataParser")

local BaseFactory={}
BaseFactory.__index=BaseFactory
BaseFactory._objectParser=nil
BaseFactory._binaryParser=nil

-- BuildArmaturePackage: final class defined at the end of BaseFactory.ts.
local BuildArmaturePackage={}
BuildArmaturePackage.__index=BuildArmaturePackage
function BuildArmaturePackage.new()
  return setmetatable({
    dataName="",textureAtlasName="",data=nil,armature=nil,skin=nil
  },BuildArmaturePackage)
end
BaseFactory.BuildArmaturePackage=BuildArmaturePackage

function BaseFactory.new(dataParser)
  if BaseFactory._objectParser==nil then
    BaseFactory._objectParser=ObjectDataParser.new()
  end
  if BaseFactory._binaryParser==nil then
    BaseFactory._binaryParser=BinaryDataParser.new()
  end
  local self=setmetatable({},BaseFactory)
  self.autoSearch=false
  self._dragonBonesDataMap={}
  self._textureAtlasDataMap={}
  self._dragonBones=nil
  self._dataParser=dataParser or BaseFactory._objectParser
  return self
end

function BaseFactory:_isSupportMesh()
  return true
end

function BaseFactory:_getTextureData(textureAtlasName,textureName)
  local list=self._textureAtlasDataMap[textureAtlasName]
  if list~=nil then
    for _,atlas in ipairs(list) do
      local texture=atlas:getTexture(textureName)
      if texture~=nil then return texture end
    end
  end
  if self.autoSearch then
    for _,atlases in pairs(self._textureAtlasDataMap) do
      for _,atlas in ipairs(atlases) do
        if atlas.autoSearch then
          local texture=atlas:getTexture(textureName)
          if texture~=nil then return texture end
        end
      end
    end
  end
  return nil
end

function BaseFactory:_fillBuildArmaturePackage(packageData,
    dragonBonesName,armatureName,skinName,textureAtlasName)
  local dragonBonesData=nil
  local armatureData=nil
  if #dragonBonesName>0 then
    if self._dragonBonesDataMap[dragonBonesName]~=nil then
      dragonBonesData=self._dragonBonesDataMap[dragonBonesName]
      armatureData=dragonBonesData:getArmature(armatureName)
    end
  end
  if armatureData==nil and
      (#dragonBonesName==0 or self.autoSearch) then
    for name,data in pairs(self._dragonBonesDataMap) do
      dragonBonesData=data
      if #dragonBonesName==0 or data.autoSearch then
        armatureData=data:getArmature(armatureName)
        if armatureData~=nil then
          dragonBonesName=name
          break
        end
      end
    end
  end
  if armatureData~=nil then
    packageData.dataName=dragonBonesName
    packageData.textureAtlasName=textureAtlasName
    packageData.data=dragonBonesData
    packageData.armature=armatureData
    packageData.skin=nil
    if #skinName>0 then
      packageData.skin=armatureData:getSkin(skinName)
      if packageData.skin==nil and self.autoSearch then
        for _,skinDragonBonesData in pairs(self._dragonBonesDataMap) do
          local skinArmatureData=skinDragonBonesData:getArmature(skinName)
          if skinArmatureData~=nil then
            packageData.skin=skinArmatureData.defaultSkin
            break
          end
        end
      end
    end
    if packageData.skin==nil then
      packageData.skin=armatureData.defaultSkin
    end
    return true
  end
  return false
end

-- Original BaseFactory.ts, lines 168-329: build actual runtime objects through
-- the original classes. Only the platform hooks remain abstract.
local Pool=require("dragonbones.original.core.BaseObject")
local Core=require("dragonbones.original.core.DragonBones")
local Bone=require("dragonbones.original.armature.Bone")
local Surface=require("dragonbones.original.armature.Surface")
local Constraint=require("dragonbones.original.armature.Constraint")
local EventObject=require("dragonbones.original.event.EventObject")
local SkinData=require("dragonbones.original.model.SkinData")

function BaseFactory:_buildBones(dataPackage,armature)
  for _,boneData in ipairs(dataPackage.armature.sortedBones) do
    local cls=boneData.type==Core.BoneType.Bone and Bone or Surface
    local bone=Pool.borrowObject(cls)
    bone:init(boneData,armature)
  end
end

function BaseFactory:_buildSlots(dataPackage,armature)
  local currentSkin=dataPackage.skin
  local defaultSkin=dataPackage.armature.defaultSkin
  if currentSkin==nil or defaultSkin==nil then return end
  local skinSlots={}
  for name,displays in pairs(defaultSkin.displays) do
    skinSlots[name]=displays
  end
  if currentSkin~=defaultSkin then
    for name,displays in pairs(currentSkin.displays) do
      skinSlots[name]=displays
    end
  end
  for _,slotData in ipairs(dataPackage.armature.sortedSlots) do
    local displayDatas=skinSlots[slotData.name]
    local slot=self:_buildSlot(dataPackage,slotData,armature)
    if displayDatas~=nil then
      slot.displayFrameCount=#displayDatas
      for i=0,slot.displayFrameCount-1 do
        local displayData=displayDatas[i+1]
        if displayData==SkinData.NULL then displayData=nil end
        slot:replaceRawDisplayData(displayData,i)
        if displayData~=nil then
          if #dataPackage.textureAtlasName>0 then
            local texture=self:_getTextureData(
              dataPackage.textureAtlasName,displayData.path)
            slot:replaceTextureData(texture,i)
          end
          local display=self:_getSlotDisplay(dataPackage,displayData,slot)
          slot:replaceDisplay(display,i)
        else
          -- The source invokes replaceDisplay(null) WITHOUT the index.
          slot:replaceDisplay(nil)
        end
      end
    end
    slot:_setDisplayIndex(slotData.displayIndex,true)
  end
end

function BaseFactory:_buildConstraints(dataPackage,armature)
  for _,constraintData in pairs(dataPackage.armature.constraints) do
    local cls
    if constraintData.type==Core.ConstraintType.IK then
      cls=Constraint.IKConstraint
    elseif constraintData.type==Core.ConstraintType.Path then
      cls=Constraint.PathConstraint
    else
      -- Original fallback is IKConstraint, even for unknown type.
      cls=Constraint.IKConstraint
    end
    local c=Pool.borrowObject(cls)
    c:init(constraintData,armature)
    armature:_addConstraint(c)
  end
end

function BaseFactory:_buildChildArmature(dataPackage,_slot,displayData)
  return self:buildArmature(displayData.path,
    dataPackage~=nil and dataPackage.dataName or "",
    "",dataPackage~=nil and dataPackage.textureAtlasName or "")
end

function BaseFactory:_getSlotDisplay(dataPackage,displayData,slot)
  local dataName
  if dataPackage~=nil then
    dataName=dataPackage.dataName
  else
    dataName=displayData.parent.parent.parent.name
  end
  local display=nil
  if displayData.type==Core.DisplayType.Image then
    if displayData.texture==nil then
      displayData.texture=self:_getTextureData(dataName,displayData.path)
    end
    display=slot.rawDisplay
  elseif displayData.type==Core.DisplayType.Mesh then
    if displayData.texture==nil then
      displayData.texture=self:_getTextureData(dataName,displayData.path)
    end
    if self:_isSupportMesh() then
      display=slot.meshDisplay
    else
      display=slot.rawDisplay
    end
  elseif displayData.type==Core.DisplayType.Armature then
    local child=self:_buildChildArmature(dataPackage,slot,displayData)
    if child~=nil then
      child.inheritAnimation=displayData.inheritAnimation
      if not child.inheritAnimation then
        local actions=#displayData.actions>0 and displayData.actions
          or child.armatureData.defaultActions
        if #actions>0 then
          for _,action in ipairs(actions) do
            local event=Pool.borrowObject(EventObject)
            EventObject.actionDataToInstance(action,event,slot.armature)
            event.slot=slot
            slot.armature:_bufferAction(event,false)
          end
        else
          child.animation:play()
        end
      end
      displayData.armature=child.armatureData
    end
    display=child
  elseif displayData.type==Core.DisplayType.BoundingBox then
    -- Empty branch in pinned TypeScript.
  end
  return display
end

-- _buildSlot is platform-abstract in the original BaseFactory.
function BaseFactory:_buildSlot(_dataPackage,_slotData,_armature)
  error("Abstract BaseFactory._buildSlot requires a backend")
end

function BaseFactory:buildArmature(armatureName,dragonBonesName,
    skinName,textureAtlasName)
  dragonBonesName=dragonBonesName or ""
  skinName=skinName or ""
  textureAtlasName=textureAtlasName or ""
  local dataPackage=BuildArmaturePackage.new()
  if not self:_fillBuildArmaturePackage(dataPackage,
      dragonBonesName,armatureName,skinName,textureAtlasName) then
    io.stderr:write("No armature data: "..tostring(armatureName)..
      ", "..tostring(dragonBonesName).."\n")
    return nil
  end
  local armature=self:_buildArmature(dataPackage)
  self:_buildBones(dataPackage,armature)
  self:_buildSlots(dataPackage,armature)
  self:_buildConstraints(dataPackage,armature)
  armature:invalidUpdate(nil,true)
  armature:advanceTime(0.0)
  return armature
end

-- The pinned abstract class delegates construction to a platform backend.
-- Keep abstract methods unavailable instead of fabricating displays.
function BaseFactory:_buildTextureAtlasData(_textureAtlasData,_textureAtlas)
  error("Abstract BaseFactory._buildTextureAtlasData requires a backend")
end

function BaseFactory:_buildArmature(_dataPackage)
  error("Abstract BaseFactory._buildArmature requires a backend")
end

function BaseFactory:parseDragonBonesData(rawData,name,scale)
  if scale==nil then scale=1.0 end
  -- The JS source uses 'rawData instanceof ArrayBuffer'; raw DBDT bytes
  -- are Lua strings, JSON object data are Lua tables.
  local parser=type(rawData)=="string" and BaseFactory._binaryParser
    or self._dataParser
  local data=parser:parseDragonBonesData(rawData,scale)
  while true do
    local atlas=self:_buildTextureAtlasData(nil,nil)
    if parser:parseTextureAtlasData(nil,atlas,scale) then
      self:addTextureAtlasData(atlas,name)
    else
      atlas:returnToPool()
      break
    end
  end
  if data~=nil then
    self:addDragonBonesData(data,name)
  end
  return data
end

function BaseFactory:parseTextureAtlasData(rawData,textureAtlas,name,scale)
  if scale==nil then scale=1.0 end
  local atlasData=self:_buildTextureAtlasData(nil,nil)
  self._dataParser:parseTextureAtlasData(rawData,atlasData,scale)
  self:_buildTextureAtlasData(atlasData,textureAtlas)
  self:addTextureAtlasData(atlasData,name)
  return atlasData
end

function BaseFactory:updateTextureAtlases(textureAtlases,name)
  local atlases=self:getTextureAtlasData(name)
  if atlases~=nil then
    for i,atlas in ipairs(atlases) do
      if i<=#textureAtlases then
        self:_buildTextureAtlasData(atlas,textureAtlases[i])
      end
    end
  end
end

function BaseFactory:getDragonBonesData(name)
  return self._dragonBonesDataMap[name]
end

function BaseFactory:addDragonBonesData(data,name)
  if name==nil then name=data.name end
  if self._dragonBonesDataMap[name]~=nil then
    if self._dragonBonesDataMap[name]==data then return end
    io.stderr:write("Can not add same name data: "..tostring(name).."\n")
    return
  end
  self._dragonBonesDataMap[name]=data
end

function BaseFactory:removeDragonBonesData(name,disposeData)
  if disposeData==nil then disposeData=true end
  local data=self._dragonBonesDataMap[name]
  if data~=nil then
    if disposeData then self._dragonBones:bufferObject(data) end
    self._dragonBonesDataMap[name]=nil
  end
end

function BaseFactory:getTextureAtlasData(name)
  return self._textureAtlasDataMap[name]
end

function BaseFactory:addTextureAtlasData(data,name)
  if name==nil then name=data.name end
  local atlases=self._textureAtlasDataMap[name]
  if atlases==nil then
    atlases={}
    self._textureAtlasDataMap[name]=atlases
  end
  for _,atlas in ipairs(atlases) do
    if atlas==data then return end
  end
  atlases[#atlases+1]=data
end

function BaseFactory:removeTextureAtlasData(name,disposeData)
  if disposeData==nil then disposeData=true end
  local list=self._textureAtlasDataMap[name]
  if list~=nil then
    if disposeData then
      for _,atlas in ipairs(list) do
        self._dragonBones:bufferObject(atlas)
      end
    end
    self._textureAtlasDataMap[name]=nil
  end
end

function BaseFactory:getArmatureData(name,dragonBonesName)
  if dragonBonesName==nil then dragonBonesName="" end
  local packageData=BuildArmaturePackage.new()
  if not self:_fillBuildArmaturePackage(
      packageData,dragonBonesName,name,"","") then
    return nil
  end
  return packageData.armature
end

function BaseFactory:clear(disposeData)
  if disposeData==nil then disposeData=true end
  for name,data in pairs(self._dragonBonesDataMap) do
    if disposeData then self._dragonBones:bufferObject(data) end
    self._dragonBonesDataMap[name]=nil
  end
  for name,atlases in pairs(self._textureAtlasDataMap) do
    if disposeData then
      for _,atlas in ipairs(atlases) do
        self._dragonBones:bufferObject(atlas)
      end
    end
    self._textureAtlasDataMap[name]=nil
  end
end

function BaseFactory:getAllDragonBonesData()
  return self._dragonBonesDataMap
end
function BaseFactory:getAllTextureAtlasData()
  return self._textureAtlasDataMap
end

-- Readonly accessors correspond to TypeScript getters 'clock' and 'dragonBones'.
-- Keep this metatable as BaseFactory.__index for subclass inheritance.
function BaseFactory.__index(self,key)
  if key=="clock" then
    return self._dragonBones.clock
  elseif key=="dragonBones" then
    return self._dragonBones
  end
  return rawget(BaseFactory,key)
end

return BaseFactory
