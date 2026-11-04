-- Port: DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e.
-- Copyright (c) 2012-2025 DragonBones team and contributors; MIT.
-- All eight method bodies present; see contracts for compared domains.
local ObjectDataParser=require('dragonbones.parser.ObjectDataParser')
local BinaryDataParser={};BinaryDataParser.__index=BinaryDataParser
setmetatable(BinaryDataParser,{__index=ObjectDataParser})
function BinaryDataParser.new()
  -- The five binary fields have no initializers in TS (undefined, not zero).
  return setmetatable(ObjectDataParser.new(),BinaryDataParser)
end
function BinaryDataParser:_inRange(a,min,max)return min<=a and a<=max end
local function character(cp)
  if cp<128 then return string.char(cp) end
  if cp<2048 then return string.char(192+math.floor(cp/64),128+cp%64) end
  if cp<65536 then return string.char(224+math.floor(cp/4096),128+math.floor(cp/64)%64,128+cp%64) end
  return string.char(240+math.floor(cp/262144),128+math.floor(cp/4096)%64,128+math.floor(cp/64)%64,128+cp%64)
end
function BinaryDataParser:_decodeUTF8(data)
  local EOF_byte,EOF_code_point,FATAL_POINT=-1,-1,65533
  local pos,result=0,{}
  local code_point
  local utf8_code_point,utf8_bytes_needed,utf8_bytes_seen,utf8_lower_boundary=0,0,0,0
  while data.length>pos do
    local byte=data[pos+1];pos=pos+1
    if byte==EOF_byte then
      code_point=utf8_bytes_needed~=0 and FATAL_POINT or EOF_code_point
    elseif utf8_bytes_needed==0 then
      if self:_inRange(byte,0,127) then code_point=byte
      else
        if self:_inRange(byte,194,223) then utf8_bytes_needed=1;utf8_lower_boundary=128;utf8_code_point=byte-192
        elseif self:_inRange(byte,224,239) then utf8_bytes_needed=2;utf8_lower_boundary=2048;utf8_code_point=byte-224
        elseif self:_inRange(byte,240,244) then utf8_bytes_needed=3;utf8_lower_boundary=65536;utf8_code_point=byte-240 end
        utf8_code_point=utf8_code_point*64^utf8_bytes_needed
        code_point=nil
      end
    elseif not self:_inRange(byte,128,191) then
      utf8_code_point=0;utf8_bytes_needed=0;utf8_bytes_seen=0;utf8_lower_boundary=0
      pos=pos-1;code_point=byte
    else
      utf8_bytes_seen=utf8_bytes_seen+1
      utf8_code_point=utf8_code_point+(byte-128)*64^(utf8_bytes_needed-utf8_bytes_seen)
      if utf8_bytes_seen~=utf8_bytes_needed then code_point=nil
      else
        local cp,lower_boundary=utf8_code_point,utf8_lower_boundary
        utf8_code_point=0;utf8_bytes_needed=0;utf8_bytes_seen=0;utf8_lower_boundary=0
        if self:_inRange(cp,lower_boundary,1114111) and not self:_inRange(cp,55296,57343) then code_point=cp
        else code_point=byte end
      end
    end
    -- Lua stores scalar UTF-8; the source's surrogate pair is observed as UTF-16.
    -- Preserve source omission of NUL and lack of EOF flush for truncated data.
    if code_point~=nil and code_point~=EOF_code_point and code_point>0 then
      result[#result+1]=character(code_point)
    end
  end
  return table.concat(result)
end
local Pool = require('dragonbones.core.BaseObject')
local AnimationModels = require('dragonbones.model.AnimationData')
local BinaryOffset = require('dragonbones.core.Enums').BinaryOffset
local V = require('dragonbones.parser.JSValue')

function BinaryDataParser:_parseBinaryTimeline(timelineType, offset, timelineData)
  local timeline = timelineData
  if timeline == nil or rawequal(timeline, V.NULL) or rawequal(timeline, V.UNDEFINED) then
    timeline = Pool.borrowObject(AnimationModels.TimelineData)
  end
  timeline.type = timelineType
  timeline.offset = offset
  self._timeline = timeline

  local numericOffset = V.number(offset)
  -- Typed-array misses are undefined in JS; arithmetic/comparisons use NaN.
  local keyFrameCount = V.number(self._timelineArrayBuffer[numericOffset + BinaryOffset.TimelineKeyFrameCount + 1])
  if keyFrameCount == 1 then
    timeline.frameIndicesOffset = -1
  else
    local totalFrameCount = self._animation.frameCount + 1
    local frameIndices = self._data.frameIndices
    local frameIndicesOffset = frameIndices.length
    frameIndices.length = frameIndices.length + totalFrameCount
    timeline.frameIndicesOffset = frameIndicesOffset

    local i, iK, frameStart, frameCount = 0, 0, 0, 0
    while i < totalFrameCount do
      if frameStart + frameCount <= i and iK < keyFrameCount then
        local frameOffset = V.number(self._timelineArrayBuffer[numericOffset + BinaryOffset.TimelineFrameOffset + iK + 1])
        frameStart = V.number(self._frameArrayBuffer[V.number(self._animation.frameOffset) + frameOffset + 1])
        if iK == keyFrameCount - 1 then
          frameCount = self._animation.frameCount - frameStart
        else
          local nextOffset = V.number(self._timelineArrayBuffer[numericOffset + BinaryOffset.TimelineFrameOffset + iK + 2])
          frameCount = V.number(self._frameArrayBuffer[V.number(self._animation.frameOffset) + nextOffset + 1]) - frameStart
        end
        iK = iK + 1
      end
      frameIndices[frameIndicesOffset + i + 1] = iK - 1
      i = i + 1
    end
  end
  -- Preserve the source's retained timeline on failure: no finally cleanup.
  self._timeline = nil
  return timeline
end

local DataParser = require('dragonbones.parser.DataParser')
local Core = require('dragonbones.core.Enums')
local JSMap = require('dragonbones.core.JSMap')

function BinaryDataParser:_parseAnimation(rawData)
  local animation = Pool.borrowObject(AnimationModels.AnimationData)
  animation.blendType = DataParser._getAnimationBlendType(ObjectDataParser._getString(rawData, DataParser.BLEND_TYPE, ''))
  animation.frameCount = ObjectDataParser._getNumber(rawData, DataParser.DURATION, 0)
  animation.playTimes = ObjectDataParser._getNumber(rawData, DataParser.PLAY_TIMES, 1)
  animation.duration = animation.frameCount / self._armature.frameRate
  animation.fadeInTime = ObjectDataParser._getNumber(rawData, DataParser.FADE_IN_TIME, 0.0)
  animation.scale = ObjectDataParser._getNumber(rawData, DataParser.SCALE, 1.0)
  animation.name = ObjectDataParser._getString(rawData, DataParser.NAME, DataParser.DEFAULT_NAME)
  if #animation.name == 0 then animation.name = DataParser.DEFAULT_NAME end

  local offsets = V.get(rawData, DataParser.OFFSET)
  animation.frameIntOffset = V.at(offsets, 0)
  animation.frameFloatOffset = V.at(offsets, 1)
  animation.frameOffset = V.at(offsets, 2)
  self._animation = animation
  local TT = Core.TimelineType
  if V.has(rawData, DataParser.ACTION) then
    animation.actionTimeline = self:_parseBinaryTimeline(TT.Action, V.get(rawData, DataParser.ACTION))
  end
  if V.has(rawData, DataParser.Z_ORDER) then
    animation.zOrderTimeline = self:_parseBinaryTimeline(TT.ZOrder, V.get(rawData, DataParser.Z_ORDER))
  end

  local groups = {
    {DataParser.BONE, 'getBone', 'addBoneTimeline'},
    {DataParser.SLOT, 'getSlot', 'addSlotTimeline'},
    {DataParser.CONSTRAINT, 'getConstraint', 'addConstraintTimeline'}
  }
  for _, group in ipairs(groups) do
    if V.has(rawData, group[1]) then
      local entries = V.get(rawData, group[1])
      -- Decoded group maps use JSMap so numeric keys and insertion order agree.
      if entries ~= nil and not rawequal(entries, V.NULL) and not rawequal(entries, V.UNDEFINED) then
        for _, name in ipairs(JSMap.keys(entries)) do
          local rawTimelines = V.get(entries, name)
          local model = self._armature[group[2]](self._armature, name)
          if model ~= nil then
            local i, length = 0, V.number(V.get(rawTimelines, 'length'))
            while i < length do
              local timeline = self:_parseBinaryTimeline(V.at(rawTimelines, i), V.at(rawTimelines, i + 1))
              self._animation[group[3]](self._animation, model.name, timeline)
              i = i + 2
            end
          end
        end
      end
    end
  end

  if V.has(rawData, DataParser.TIMELINE) then
    for rawTimeline in V.iterator(V.get(rawData, DataParser.TIMELINE)) do
      local offset = ObjectDataParser._getNumber(rawTimeline, DataParser.OFFSET, 0)
      if offset >= 0 then
        local kind = ObjectDataParser._getNumber(rawTimeline, DataParser.TYPE, TT.Action)
        local name = ObjectDataParser._getString(rawTimeline, DataParser.NAME, '')
        local timeline
        if kind == TT.AnimationProgress and animation.blendType ~= Core.AnimationBlendType.None then
          timeline = Pool.borrowObject(AnimationModels.AnimationTimelineData)
          timeline.x = ObjectDataParser._getNumber(rawTimeline, DataParser.X, 0.0)
          timeline.y = ObjectDataParser._getNumber(rawTimeline, DataParser.Y, 0.0)
        end
        timeline = self:_parseBinaryTimeline(kind, offset, timeline)
        if kind == TT.BoneTranslate or kind == TT.BoneRotate or kind == TT.BoneScale or kind == TT.Surface or kind == TT.BoneAlpha then
          animation:addBoneTimeline(name, timeline)
        elseif kind == TT.SlotDisplay or kind == TT.SlotColor or kind == TT.SlotDeform or kind == TT.SlotZIndex or kind == TT.SlotAlpha then
          animation:addSlotTimeline(name, timeline)
        elseif kind == TT.IKConstraint then
          animation:addConstraintTimeline(name, timeline)
        elseif kind == TT.AnimationProgress or kind == TT.AnimationWeight or kind == TT.AnimationParameter then
          animation:addAnimationTimeline(name, timeline)
        end
        -- Action, ZOrder and unknown generic kinds remain unregistered upstream.
      end
    end
  end
  self._animation = nil
  return animation
end

local DisplayModels = require('dragonbones.model.DisplayData')

function BinaryDataParser:_parseGeometry(rawData, geometry)
  geometry.offset = V.get(rawData, DataParser.OFFSET)
  geometry.data = self._data
  local offset = V.number(geometry.offset)
  local weightOffset = V.number(self._intArrayBuffer[offset + BinaryOffset.GeometryWeightOffset + 1])
  if weightOffset < -1 then weightOffset = weightOffset + 65536 end

  if weightOffset >= 0 then
    local weight = Pool.borrowObject(DisplayModels.WeightData)
    local vertexCount = V.number(self._intArrayBuffer[offset + BinaryOffset.GeometryVertexCount + 1])
    local boneCount = V.number(self._intArrayBuffer[weightOffset + BinaryOffset.WeigthBoneCount + 1])
    weight.offset = weightOffset
    local i = 0
    while i < boneCount do
      local boneIndex = V.number(self._intArrayBuffer[weightOffset + BinaryOffset.WeigthBoneIndices + i + 1])
      -- An out-of-range raw bone is undefined, not a fabricated bone/null.
      weight:addBone(self._rawBones[boneIndex + 1] or V.UNDEFINED)
      i = i + 1
    end

    local boneIndicesOffset = weightOffset + BinaryOffset.WeigthBoneIndices + boneCount
    local weightCount = 0
    i = 0
    while i < vertexCount do
      local vertexBoneCount = V.number(self._intArrayBuffer[boneIndicesOffset + 1])
      boneIndicesOffset = boneIndicesOffset + 1
      weightCount = weightCount + vertexBoneCount
      boneIndicesOffset = boneIndicesOffset + vertexBoneCount
      i = i + 1
    end
    weight.count = weightCount
    geometry.weight = weight
  end
end

local Shared = require('dragonbones.parser.SharedBinaryBuffer')

-- The typed constructors receive element counts, not byte lengths. ToIndex
-- truncates fractional counts and maps undefined/NaN to zero before bounds.
local function toIndex(value)
  local n = V.number(value)
  if n ~= n or n == 0 then return 0 end
  if n == math.huge or n == -math.huge then error('Invalid typed view index') end
  n = n < 0 and math.ceil(n) or math.floor(n)
  if n == 0 then return 0 end -- ToIndex canonicalizes negative zero.
  if n < 0 or n > 9007199254740991 then error('Invalid typed view index') end
  return n
end

function BinaryDataParser:_parseArray(rawData)
  local offsets = V.get(rawData, DataParser.OFFSET)
  local lengths = {}
  for i = 0, 5 do lengths[i + 1] = V.at(offsets, i * 2 + 1) end
  local colorLength = V.number(V.get(offsets, 'length')) > 12 and V.at(offsets, 13) or 0
  local function part(index, length, kind, unit)
    local byteOffset = toIndex(V.number(self._binaryOffset) + V.number(V.at(offsets, index)))
    -- Alignment is checked before length conversion, as in TypedArray.
    if byteOffset % unit ~= 0 then error('Misaligned typed view') end
    local count = toIndex(V.number(length) / unit)
    return Shared.view(self._binary, byteOffset, count * unit, kind)
  end
  local intArray = part(0, lengths[1], 'int16', 2)
  local floatArray = part(2, lengths[2], 'float32', 4)
  local frameIntArray = part(4, lengths[3], 'int16', 2)
  local frameFloatArray = part(6, lengths[4], 'float32', 4)
  local frameArray = part(8, lengths[5], 'int16', 2)
  local timelineArray = part(10, lengths[6], 'uint16', 2)
  local colorArray = intArray
  if V.number(colorLength) > 0 then colorArray = part(12, colorLength, 'int16', 2) end

  self._data.binary = self._binary
  self._intArrayBuffer = intArray
  self._data.intArray = intArray
  self._data.floatArray = floatArray
  self._data.frameIntArray = frameIntArray
  self._data.frameFloatArray = frameFloatArray
  self._frameArrayBuffer = frameArray
  self._data.frameArray = frameArray
  self._timelineArrayBuffer = timelineArray
  self._data.timelineArray = timelineArray
  self._data.colorArray = colorArray
end

local JSON = require('dragonbones.parser.JSON')

function BinaryDataParser:parseDragonBonesData(rawData, scale)
  if not Shared.isBuffer(rawData) then
    io.stderr:write('Assertion failed: Data error.\n')
    error('BinaryDataParser expects SharedBinaryBuffer')
  end
  local tag = Shared.view(rawData, 0, 8, 'uint8')
  if tag[1]~=68 or tag[2]~=66 or tag[3]~=68 or tag[4]~=84 then
    io.stderr:write('Assertion failed: Nonsupport data.\n')
    return nil
  end
  -- Uint32Array(rawData,8,1)[0], little endian; no general Uint32 API.
  local lengthBytes = Shared.view(rawData, 8, 4, 'uint8')
  local headerLength = lengthBytes[1] + lengthBytes[2]*256 + lengthBytes[3]*65536 + lengthBytes[4]*16777216
  local headerBytes = Shared.view(rawData, 12, headerLength, 'uint8')
  local header = JSON.parse(self:_decodeUTF8(headerBytes))
  self._binaryOffset = 12 + headerLength
  self._binary = rawData
  return ObjectDataParser.parseDragonBonesData(self, header, scale)
end

function BinaryDataParser.getInstance()
  if BinaryDataParser._binaryDataParserInstance==nil then
    BinaryDataParser._binaryDataParserInstance=BinaryDataParser.new()
  end
  return BinaryDataParser._binaryDataParserInstance
end
return BinaryDataParser
