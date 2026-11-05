-- Lua port of DragonBonesJS BaseFactory.ts, pinned commit
-- 64b6c69ae35777c2404be68c9192e2c56906079e (MIT).
-- Copyright (c) 2012-2025 DragonBones team and other contributors.
-- See LICENSE-DRAGONBONES.
--
-- This class is abstract in the source. A backend MUST implement
-- _buildTextureAtlasData, _buildArmature and _buildSlot before building.
-- The cache, parsers and build-package search here are actual source methods,
-- not a substitute rendering implementation.
local ObjectDataParser=require("dragonbones.parser.ObjectDataParser")
local BinaryDataParser=require("dragonbones.parser.BinaryDataParser")

local Map=require('dragonbones.core.JSMap')
local Array=require('dragonbones.core.JSArray')
local Shared=require('dragonbones.parser.SharedBinaryBuffer')
local truthy=require('dragonbones.parser.JSValue').truthy
local function each(a)local i=0;return function()i=i+1;if i<=a.length then return i,a[i]end end end
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

function BaseFactory.new(dataParser,classType)
  if BaseFactory._objectParser==nil then
    BaseFactory._objectParser=ObjectDataParser.new()
  end
  if BaseFactory._binaryParser==nil then
    BaseFactory._binaryParser=BinaryDataParser.new()
  end
  local self=setmetatable({},classType or BaseFactory)
  self.autoSearch=false
  self._dragonBonesDataMap=Map.new()
  self._textureAtlasDataMap=Map.new()
  self._dragonBones=nil
  self._dataParser=dataParser~=nil and dataParser or BaseFactory._objectParser
  return self
end

function BaseFactory:_isSupportMesh()
  return true
end

function BaseFactory:_getTextureData(textureAtlasName,textureName)
  local list=self._textureAtlasDataMap[textureAtlasName]
  if list~=nil then
    for _,atlas in each(list) do
      local texture=atlas:getTexture(textureName)
      if texture~=nil then return texture end
    end
  end
  if self.autoSearch then
    for _,mapKey in ipairs(Map.keys(self._textureAtlasDataMap)) do
      local atlases=self._textureAtlasDataMap[mapKey]
      for _,atlas in each(atlases) do
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
    for _,name in ipairs(Map.keys(self._dragonBonesDataMap)) do
      local data=self._dragonBonesDataMap[name]
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
        for _,mapKey in ipairs(Map.keys(self._dragonBonesDataMap)) do
          local skinDragonBonesData=self._dragonBonesDataMap[mapKey]
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
local Pool=require("dragonbones.core.BaseObject")
local Core=require("dragonbones.core.DragonBones")
local Bone=require("dragonbones.armature.Bone")
local Surface=require("dragonbones.armature.Surface")
local EventObject=require("dragonbones.event.EventObject")
local SkinData=require("dragonbones.model.SkinData")

function BaseFactory:_buildBones(dataPackage,armature)
  for _,boneData in each(dataPackage.armature.sortedBones) do
    local cls=boneData.type==Core.BoneType.Bone and Bone or Surface
    local bone=Pool.borrowObject(cls)
    bone:init(boneData,armature)
  end
end

function BaseFactory:_buildSlots(dataPackage,armature)
  local currentSkin=dataPackage.skin
  local defaultSkin=dataPackage.armature.defaultSkin
  if currentSkin==nil or defaultSkin==nil then return end
  local skinSlots=Map.new()
  for _,name in ipairs(Map.keys(defaultSkin.displays)) do
    local displays=defaultSkin.displays[name]
    skinSlots[name]=displays
  end
  if currentSkin~=defaultSkin then
    for _,name in ipairs(Map.keys(currentSkin.displays)) do
      local displays=currentSkin.displays[name]
      skinSlots[name]=displays
    end
  end
  for _,slotData in each(dataPackage.armature.sortedSlots) do
    local displayDatas=skinSlots[slotData.name]
    local slot=self:_buildSlot(dataPackage,slotData,armature)
    if displayDatas~=nil then
      slot.displayFrameCount=displayDatas.length
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
  for _,mapKey in ipairs(Map.keys(dataPackage.armature.constraints)) do
    local constraintData=dataPackage.armature.constraints[mapKey]
    local cls
    if constraintData.type==Core.ConstraintType.IK then
      cls=require('dragonbones.armature.IKConstraint')
    elseif constraintData.type==Core.ConstraintType.Path then
      cls=require('dragonbones.armature.PathConstraint')
    else
      -- Original fallback is IKConstraint, even for unknown type.
      cls=require('dragonbones.armature.IKConstraint')
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
        local actions=displayData.actions.length>0 and displayData.actions
          or child.armatureData.defaultActions
        if actions.length>0 then
          for _,action in each(actions) do
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
  -- Original ArrayBuffer is represented by SharedBinaryBuffer; JSON is decoded.
  local parser=Shared.isBuffer(rawData) and BaseFactory._binaryParser
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
  self:_buildTextureAtlasData(atlasData,truthy(textureAtlas) and textureAtlas or nil)
  self:addTextureAtlasData(atlasData,name)
  return atlasData
end

function BaseFactory:updateTextureAtlases(textureAtlases,name)
  local atlases=self:getTextureAtlasData(name)
  if atlases~=nil then
    for i=1,atlases.length do
      local atlas=atlases[i]
      if i<=textureAtlases.length then
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
    Map.remove(self._dragonBonesDataMap,name)
  end
end

function BaseFactory:getTextureAtlasData(name)
  return self._textureAtlasDataMap[name]
end

function BaseFactory:addTextureAtlasData(data,name)
  if name==nil then name=data.name end
  local atlases=self._textureAtlasDataMap[name]
  if atlases==nil then
    atlases=Array.new()
    self._textureAtlasDataMap[name]=atlases
  end
  for _,atlas in each(atlases) do
    if atlas==data then return end
  end
  atlases[atlases.length+1]=data
end

function BaseFactory:removeTextureAtlasData(name,disposeData)
  if disposeData==nil then disposeData=true end
  local list=self._textureAtlasDataMap[name]
  if list~=nil then
    if disposeData then
      for _,atlas in each(list) do
        self._dragonBones:bufferObject(atlas)
      end
    end
    Map.remove(self._textureAtlasDataMap,name)
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
  for _,name in ipairs(Map.keys(self._dragonBonesDataMap)) do
    local data=self._dragonBonesDataMap[name]
    if disposeData then self._dragonBones:bufferObject(data) end
    Map.remove(self._dragonBonesDataMap,name)
  end
  for _,name in ipairs(Map.keys(self._textureAtlasDataMap)) do
    local atlases=self._textureAtlasDataMap[name]
    if disposeData then
      for _,atlas in each(atlases) do
        self._dragonBones:bufferObject(atlas)
      end
    end
    Map.remove(self._textureAtlasDataMap,name)
  end
end

-- BaseFactory.ts (fixed DragonBonesJS commit), lines 719–981.
-- Public display, skin and animation replacement operations.
local RuntimeArmature=require("dragonbones.armature.Armature")
local function isRuntimeArmature(display)
  if display==nil then return false end
  local cls=getmetatable(display)
  while type(cls)=="table" do
    if cls==RuntimeArmature then return true end
    local meta=getmetatable(cls)
    cls=meta and meta.__index
  end
  return false
end

function BaseFactory:replaceDisplay(slot,displayData,displayIndex)
  if displayData==SkinData.NULL then displayData=nil end
  if displayIndex==nil then displayIndex=-1 end
  if displayIndex<0 then displayIndex=slot.displayIndex end
  if displayIndex<0 then displayIndex=0 end

  slot:replaceDisplayData(displayData,displayIndex)
  if displayData~=nil and displayData~=SkinData.NULL then
    local display=self:_getSlotDisplay(nil,displayData,slot)
    if displayData.type==Core.DisplayType.Image then
      local raw=slot:getDisplayFrameAt(displayIndex).rawDisplayData
      if raw~=nil and raw.type==Core.DisplayType.Mesh then
        display=slot.meshDisplay
      end
    end
    slot:replaceDisplay(display,displayIndex)
  else
    slot:replaceDisplay(nil,displayIndex)
  end
end

function BaseFactory:replaceSlotDisplay(dragonBonesName,armatureName,
    slotName,displayName,slot,displayIndex)
  local armatureData=self:getArmatureData(armatureName,dragonBonesName or "")
  if armatureData==nil or armatureData.defaultSkin==nil then return false end
  local displayData=armatureData.defaultSkin:getDisplay(slotName,displayName)
  self:replaceDisplay(slot,displayData,displayIndex)
  return true
end

function BaseFactory:replaceSlotDisplayList(dragonBonesName,armatureName,
    slotName,slot)
  local armatureData=self:getArmatureData(armatureName,dragonBonesName or "")
  if armatureData==nil or armatureData.defaultSkin==nil then return false end
  local displays=armatureData.defaultSkin:getDisplays(slotName)
  if displays==nil then return false end
  slot.displayFrameCount=displays.length
  for i=0,slot.displayFrameCount-1 do
    local data=displays[i+1]
    self:replaceDisplay(slot,data,i)
  end
  return true
end

function BaseFactory:replaceSkin(armature,skin,isOverride,exclude)
  if isOverride==nil then isOverride=false end
  local success=false
  local defaultSkin=skin.parent.defaultSkin
  local function excluded(name)
    if exclude~=nil then
      for i=1,exclude.length do if exclude[i]==name then return true end end
    end
    return false
  end
  for _,slot in each(armature:getSlots()) do
    if not excluded(slot.name) then
      local displayDatas=skin:getDisplays(slot.name)
      if displayDatas==nil then
        if defaultSkin~=nil and skin~=defaultSkin then
          displayDatas=defaultSkin:getDisplays(slot.name)
        end
        if displayDatas==nil then
          if isOverride then slot.displayFrameCount=0 end
        end
      end
      if displayDatas~=nil then
        slot.displayFrameCount=displayDatas.length
        for i=0,slot.displayFrameCount-1 do
          local displayData=displayDatas[i+1]
          if displayData==SkinData.NULL then displayData=nil end
          slot:replaceRawDisplayData(displayData,i)
          if displayData~=nil then
            slot:replaceDisplay(self:_getSlotDisplay(nil,displayData,slot),i)
          else
            slot:replaceDisplay(nil,i)
          end
        end
        success=true
      end
    end
  end
  return success
end

function BaseFactory:replaceAnimation(armature,armatureData,isOverride)
  if isOverride==nil then isOverride=true end
  local skinData=armatureData.defaultSkin
  if skinData==nil then return false end
  if isOverride then
    armature.animation.animations=armatureData.animations
  else
    local animations=Map.new()
    for _,name in ipairs(Map.keys(armature.animation.animations)) do
      local animation=armature.animation.animations[name]
      animations[name]=animation
    end
    for _,name in ipairs(Map.keys(armatureData.animations)) do
      local animation=armatureData.animations[name]
      animations[name]=animation
    end
    armature.animation.animations=animations
  end
  for _,slot in each(armature:getSlots()) do
    local displayList=slot.displayList
    local index=0
    for _,display in each(displayList) do
      if isRuntimeArmature(display) then
        local displays=skinData:getDisplays(slot.name)
        if displays~=nil and index<displays.length then
          local displayData=displays[index+1]
          if displayData~=nil and displayData~=SkinData.NULL
              and displayData.type==Core.DisplayType.Armature then
            local childData=self:getArmatureData(displayData.path,displayData.parent.parent.parent.name)
            if childData~=nil then self:replaceAnimation(display,childData,isOverride)end
          end
        end
      end
      index=index+1
    end
  end
  return true
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

function BaseFactory.__newindex(self,key,value)
  if key=='clock' or key=='dragonBones'then error('Readonly property: '..key)end
  rawset(self,key,value)
end
return BaseFactory
