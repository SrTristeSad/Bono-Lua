-- DragonBonesJS original: DragonBones/src/dragonBones/parser/BinaryDataParser.ts
-- Commit 64b6c69ae35777c2404be68c9192e2c56906079e (MIT).
-- Copyright (c) 2012-2025 DragonBones team and other contributors.
-- See LICENSE-DRAGONBONES.
--
-- Lua represents an ArrayBuffer with a raw binary string and the original
-- typed views with Lua numeric arrays. Their byte layout is retained, but
-- post-decode mutations do not write back to the shared binary string.
local ObjectDataParser=require("dragonbones.original.parser.ObjectDataParser")
local DataParser=require("dragonbones.original.parser.DataParser")
local Core=require("dragonbones.original.core.DragonBones")
local Pool=require("dragonbones.original.core.BaseObject")
local AnimationModels=require("dragonbones.original.model.AnimationData")
local DisplayModels=require("dragonbones.original.model.DisplayData")
local Json=require("dragonbones.json")

local BinaryDataParser={}
BinaryDataParser.__index=BinaryDataParser
setmetatable(BinaryDataParser,{__index=ObjectDataParser})

local function at(array,index)
  return array[index+1]
end

local function utf8Char(cp)
  if cp<0x80 then return string.char(cp) end
  if cp<0x800 then
    return string.char(0xC0+math.floor(cp/64),0x80+cp%64)
  end
  if cp<0x10000 then
    return string.char(0xE0+math.floor(cp/4096),
      0x80+math.floor(cp/64)%64,0x80+cp%64)
  end
  return string.char(0xF0+math.floor(cp/262144),
    0x80+math.floor(cp/4096)%64,
    0x80+math.floor(cp/64)%64,0x80+cp%64)
end

-- Decoding follows the state machine from the pinned TypeScript source.
-- The result is a UTF-8 Lua string (JS's UTF-16 surrogate pairs are encoded
-- as one scalar value). Like the source, it drops invalid leading bytes,
-- and a bad continuation is reprocessed as a direct code point.
function BinaryDataParser:_inRange(a,min,max)
  return min<=a and a<=max
end

function BinaryDataParser:_decodeUTF8(data)
  -- Accept either the original-style Uint8Array represented by a Lua table
  -- or raw bytes already sliced out of the binary string.
  local bytes={}
  if type(data)=="string" then
    for i=1,#data do bytes[i]=data:byte(i) end
  else
    bytes=data
  end
  local pos,result=1,{}
  local utf8CodePoint=0
  local needed,seen,lowerBoundary=0,0,0
  while pos<=#bytes do
    local byte=bytes[pos]
    pos=pos+1
    local cp=nil
    if needed==0 then
      if self:_inRange(byte,0,0x7f) then
        cp=byte
      else
        if self:_inRange(byte,0xc2,0xdf) then
          needed=1;lowerBoundary=0x80;utf8CodePoint=byte-0xc0
        elseif self:_inRange(byte,0xe0,0xef) then
          needed=2;lowerBoundary=0x800;utf8CodePoint=byte-0xe0
        elseif self:_inRange(byte,0xf0,0xf4) then
          needed=3;lowerBoundary=0x10000;utf8CodePoint=byte-0xf0
        end
        utf8CodePoint=utf8CodePoint*64^needed
      end
    elseif not self:_inRange(byte,0x80,0xbf) then
      utf8CodePoint=0;needed=0;seen=0;lowerBoundary=0
      pos=pos-1
      cp=byte
    else
      seen=seen+1
      utf8CodePoint=utf8CodePoint+
        (byte-0x80)*64^(needed-seen)
      if seen==needed then
        local candidate=utf8CodePoint
        local boundary=lowerBoundary
        utf8CodePoint=0;needed=0;seen=0;lowerBoundary=0
        if self:_inRange(candidate,boundary,0x10ffff)
            and not self:_inRange(candidate,0xd800,0xdfff) then
          cp=candidate
        else
          cp=byte
        end
      end
    end
    if cp~=nil and cp>0 then
      result[#result+1]=utf8Char(cp)
    end
  end
  return table.concat(result)
end

local function readU16(bytes,offset)
  local p=offset+1
  local a,b=bytes:byte(p,p+1)
  assert(b~=nil,"BinaryDataParser: truncated uint16 view")
  return a+b*256
end

local function readU32(bytes,offset)
  local p=offset+1
  local a,b,c,d=bytes:byte(p,p+3)
  assert(d~=nil,"BinaryDataParser: truncated uint32")
  return a+b*256+c*65536+d*16777216
end

local function float32(bytes,offset)
  local b0,b1,b2,b3=bytes:byte(offset+1,offset+4)
  assert(b3~=nil,"BinaryDataParser: truncated float32 view")
  local exponent=(b3%128)*2+math.floor(b2/128)
  local fraction=b2%128*65536+b1*256+b0
  local sign=b3>=128 and -1 or 1
  if exponent==255 then
    if fraction==0 then return sign*math.huge end
    return 0/0
  elseif exponent==0 then
    return sign*(fraction*2^-149)
  end
  return sign*(1+fraction/8388608)*2^(exponent-127)
end

local function readTyped(bytes,absoluteOffset,length,itemBytes,kind)
  assert(type(absoluteOffset)=="number" and absoluteOffset>=0
    and absoluteOffset%itemBytes==0,
    "BinaryDataParser: misaligned typed view")
  assert(type(length)=="number" and length>=0
    and length%itemBytes==0
    and absoluteOffset+length<=#bytes,
    "BinaryDataParser: invalid typed view length")
  local out={}
  for i=0,length/itemBytes-1 do
    local pos=absoluteOffset+i*itemBytes
    local n
    if kind=="float" then
      n=float32(bytes,pos)
    else
      n=readU16(bytes,pos)
      if kind=="int" and n>=32768 then n=n-65536 end
    end
    out[i+1]=n
  end
  return out
end

function BinaryDataParser.new()
  local self=ObjectDataParser.new()
  setmetatable(self,BinaryDataParser)
  self._binaryOffset=0
  self._binary=nil
  self._intArrayBuffer=nil
  self._frameArrayBuffer=nil
  self._timelineArrayBuffer=nil
  return self
end

function BinaryDataParser:_parseBinaryTimeline(timelineType,offset,timelineData)
  local timeline=timelineData or
    Pool.borrowObject(AnimationModels.TimelineData)
  timeline.type=timelineType
  timeline.offset=offset
  self._timeline=timeline
  local b=Core.BinaryOffset
  local keyFrameCount=at(self._timelineArrayBuffer,
    timeline.offset+b.TimelineKeyFrameCount)
  if keyFrameCount==1 then
    timeline.frameIndicesOffset=-1
  else
    local count=self._animation.frameCount+1
    local indices=self._data.frameIndices
    local start=#indices
    for i=1,count do indices[start+i]=0 end
    timeline.frameIndicesOffset=start
    local iK,frameStart,frameCount=0,0,0
    for i=0,count-1 do
      if frameStart+frameCount<=i and iK<keyFrameCount then
        local frameOffset=at(self._timelineArrayBuffer,
          timeline.offset+b.TimelineFrameOffset+iK)
        frameStart=at(self._frameArrayBuffer,
          self._animation.frameOffset+frameOffset)
        if iK==keyFrameCount-1 then
          frameCount=self._animation.frameCount-frameStart
        else
          local nextFrameOffset=at(self._timelineArrayBuffer,
            timeline.offset+b.TimelineFrameOffset+iK+1)
          frameCount=at(self._frameArrayBuffer,
            self._animation.frameOffset+nextFrameOffset)-frameStart
        end
        iK=iK+1
      end
      indices[start+i+1]=iK-1
    end
  end
  self._timeline=nil
  return timeline
end

function BinaryDataParser:_parseAnimation(raw)
  local animation=Pool.borrowObject(AnimationModels.AnimationData)
  local TT=Core.TimelineType
  animation.blendType=DataParser._getAnimationBlendType(
    ObjectDataParser._getString(raw,DataParser.BLEND_TYPE,""))
  animation.frameCount=ObjectDataParser._getNumber(raw,DataParser.DURATION,0)
  animation.playTimes=ObjectDataParser._getNumber(raw,DataParser.PLAY_TIMES,1)
  animation.duration=animation.frameCount/self._armature.frameRate
  animation.fadeInTime=ObjectDataParser._getNumber(
    raw,DataParser.FADE_IN_TIME,0.0)
  animation.scale=ObjectDataParser._getNumber(raw,DataParser.SCALE,1.0)
  animation.name=ObjectDataParser._getString(
    raw,DataParser.NAME,DataParser.DEFAULT_NAME)
  if #animation.name==0 then animation.name=DataParser.DEFAULT_NAME end
  local offsets=raw[DataParser.OFFSET]
  animation.frameIntOffset=offsets[1]
  animation.frameFloatOffset=offsets[2]
  animation.frameOffset=offsets[3]
  self._animation=animation

  if raw[DataParser.ACTION]~=nil then
    animation.actionTimeline=self:_parseBinaryTimeline(
      TT.Action,raw[DataParser.ACTION])
  end
  if raw[DataParser.Z_ORDER]~=nil then
    animation.zOrderTimeline=self:_parseBinaryTimeline(
      TT.ZOrder,raw[DataParser.Z_ORDER])
  end
  local groups={
    {DataParser.BONE,"getBone","addBoneTimeline"},
    {DataParser.SLOT,"getSlot","addSlotTimeline"},
    {DataParser.CONSTRAINT,"getConstraint","addConstraintTimeline"}
  }
  for _,group in ipairs(groups) do
    local timelines=raw[group[1]]
    if timelines~=nil then
      for name,entries in pairs(timelines) do
        local model=self._armature[group[2]](self._armature,name)
        if model~=nil then
          for i=1,#entries,2 do
            local timeline=self:_parseBinaryTimeline(entries[i],entries[i+1])
            animation[group[3]](animation,model.name,timeline)
          end
        end
      end
    end
  end

  if raw[DataParser.TIMELINE]~=nil then
    for _,entry in ipairs(raw[DataParser.TIMELINE]) do
      local offset=ObjectDataParser._getNumber(
        entry,DataParser.OFFSET,0)
      if offset>=0 then
        local kind=ObjectDataParser._getNumber(
          entry,DataParser.TYPE,TT.Action)
        local name=ObjectDataParser._getString(
          entry,DataParser.NAME,"")
        local timeline=nil
        if kind==TT.AnimationProgress
            and animation.blendType~=Core.AnimationBlendType.None then
          timeline=Pool.borrowObject(AnimationModels.AnimationTimelineData)
          timeline.x=ObjectDataParser._getNumber(entry,DataParser.X,0.0)
          timeline.y=ObjectDataParser._getNumber(entry,DataParser.Y,0.0)
        end
        timeline=self:_parseBinaryTimeline(kind,offset,timeline)
        if kind==TT.BoneTranslate or kind==TT.BoneRotate
            or kind==TT.BoneScale or kind==TT.Surface
            or kind==TT.BoneAlpha then
          animation:addBoneTimeline(name,timeline)
        elseif kind==TT.SlotDisplay or kind==TT.SlotColor
            or kind==TT.SlotDeform or kind==TT.SlotZIndex
            or kind==TT.SlotAlpha then
          animation:addSlotTimeline(name,timeline)
        elseif kind==TT.IKConstraint then
          animation:addConstraintTimeline(name,timeline)
        elseif kind==TT.AnimationProgress or kind==TT.AnimationWeight
            or kind==TT.AnimationParameter then
          animation:addAnimationTimeline(name,timeline)
        end
        -- Action and ZOrder cases are TODO in the pinned TypeScript.
      end
    end
  end
  self._animation=nil
  return animation
end

function BinaryDataParser:_parseGeometry(raw,geometry)
  geometry.offset=raw[DataParser.OFFSET]
  geometry.data=self._data
  local b=Core.BinaryOffset
  local weightOffset=at(self._intArrayBuffer,
    geometry.offset+b.GeometryWeightOffset)
  if weightOffset< -1 then weightOffset=weightOffset+65536 end
  if weightOffset>=0 then
    local weight=Pool.borrowObject(DisplayModels.WeightData)
    local vertexCount=at(self._intArrayBuffer,
      geometry.offset+b.GeometryVertexCount)
    local boneCount=at(self._intArrayBuffer,
      weightOffset+b.WeigthBoneCount)
    weight.offset=weightOffset
    for i=0,boneCount-1 do
      local boneIndex=at(self._intArrayBuffer,
        weightOffset+b.WeigthBoneIndices+i)
      weight:addBone(self._rawBones[boneIndex+1])
    end
    local boneIndicesOffset=weightOffset+b.WeigthBoneIndices+boneCount
    local count=0
    for _=1,vertexCount do
      local vertexBoneCount=at(self._intArrayBuffer,boneIndicesOffset)
      boneIndicesOffset=boneIndicesOffset+1
      count=count+vertexBoneCount
      boneIndicesOffset=boneIndicesOffset+vertexBoneCount
    end
    weight.count=count
    geometry.weight=weight
  end
end

function BinaryDataParser:_parseArray(raw)
  local offsets=raw[DataParser.OFFSET]
  local bytes=self._binary
  local base=self._binaryOffset
  local function part(startIndex,lengthIndex,unit,kind)
    return readTyped(bytes,base+offsets[startIndex],
      offsets[lengthIndex],unit,kind)
  end
  local data=self._data
  local intArray=part(1,2,2,"int")
  local floatArray=part(3,4,4,"float")
  local frameIntArray=part(5,6,2,"int")
  local frameFloatArray=part(7,8,4,"float")
  local frameArray=part(9,10,2,"int")
  local timelineArray=part(11,12,2,"uint")
  local colorArray
  if #offsets>12 and offsets[14]>0 then
    colorArray=part(13,14,2,"int")
  else
    colorArray=intArray -- Pinned source aliases it when color length is zero.
  end
  data.binary=bytes
  data.intArray=intArray
  data.floatArray=floatArray
  data.frameIntArray=frameIntArray
  data.frameFloatArray=frameFloatArray
  data.frameArray=frameArray
  data.timelineArray=timelineArray
  data.colorArray=colorArray
  self._intArrayBuffer=intArray
  self._frameArrayBuffer=frameArray
  self._timelineArrayBuffer=timelineArray
end

function BinaryDataParser:parseDragonBonesData(raw,scale)
  if scale==nil then scale=1 end
  assert(type(raw)=="string","Data error. Expected binary Lua string.")
  if raw:sub(1,4)~="DBDT" then
    io.stderr:write("Nonsupport data.\n")
    return nil
  end
  local headerLength=readU32(raw,8)
  local start=13
  local finish=start+headerLength-1
  assert(finish<=#raw,"BinaryDataParser: truncated JSON header")
  local header=Json.decode(self:_decodeUTF8(raw:sub(start,finish)))
  self._binaryOffset=12+headerLength
  self._binary=raw
  return ObjectDataParser.parseDragonBonesData(self,header,scale)
end

local singleton=nil
function BinaryDataParser.getInstance()
  if singleton==nil then singleton=BinaryDataParser.new() end
  return singleton
end
return BinaryDataParser
