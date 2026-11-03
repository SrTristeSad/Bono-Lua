-- Lua byte-backed ArrayBuffer / TypedArray transport for DragonBonesData.
-- Pinned original: DragonBones/DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e
-- ObjectDataParser.ts::_modifyArray; BinaryDataParser is not implemented here.
-- MIT: see LICENSE-DRAGONBONES. Only the platform representation differs:
-- Lua numeric indices are 1-based; TypedArray in the original is 0-based.
local V=require("dragonbones.parser.JSValue")
local Shared={}
local Buffer={}
Buffer.__index=function(self,key)
  if key=="byteLength" then return #self._bytes end
  return Buffer[key]
end
Buffer.__newindex=function(self,key,value)
  if key=="byteLength" then error("Readonly ArrayBuffer byteLength") end
  rawset(self,key,value)
end

function Shared.new(raw)
  local bytes=raw or ""
  assert(type(bytes)=="string","SharedBinaryBuffer expects raw bytes")
  return setmetatable({_bytes=bytes,_patches={},_snapshot=bytes},Buffer)
end
function Buffer:length() return #self._bytes end
function Buffer:byte(offset)
  if offset<0 or offset>=#self._bytes then return nil end
  local patch=self._patches[offset]
  return patch~=nil and patch or self._bytes:byte(offset+1)
end
function Buffer:setByte(offset,value)
  assert(type(offset)=="number" and offset%1==0 and offset>=0 and offset<#self._bytes,"SharedBinaryBuffer write out of range")
  local n=V.number(value)
  if n~=n or n==math.huge or n==-math.huge then n=0 end
  n=n<0 and math.ceil(n) or math.floor(n)
  self._patches[offset]=n%256
  -- A later binary read must observe this write. Earlier Lua string
  -- snapshots remain unchanged, as they are immutable.
  self._snapshot=nil
end
function Buffer:readBytes(offset,count)
  local chars={}
  for i=0,count-1 do
    chars[#chars+1]=string.char(assert(self:byte(offset+i)))
  end
  return table.concat(chars)
end
function Buffer:writeBytes(offset,bytes)
  assert(offset>=0 and offset+#bytes<=#self._bytes,
    "SharedBinaryBuffer write out of range")
  for i=1,#bytes do self:setByte(offset+i-1,bytes:byte(i)) end
end
function Buffer:bytes()
  -- Original ArrayBuffer views share mutable memory. Lua exposes its
  -- contents as immutable byte strings: materialize only after a write.
  -- Repeated reads of an unchanged large DBDT should be O(1), not O(N).
  if self._snapshot~=nil then return self._snapshot end
  local positions={}
  for offset in pairs(self._patches) do
    positions[#positions+1]=offset
  end
  table.sort(positions)
  local chunks={}
  local nextByte=1
  for _,offset in ipairs(positions) do
    local index=offset+1
    if nextByte<index then
      chunks[#chunks+1]=self._bytes:sub(nextByte,index-1)
    end
    chunks[#chunks+1]=string.char(self._patches[offset])
    nextByte=index+1
  end
  chunks[#chunks+1]=self._bytes:sub(nextByte)
  local bytes=table.concat(chunks)
  self._snapshot=bytes
  return bytes
end

local function truncNumber(value)
  value=V.number(value)
  if value~=value or value==math.huge or value==-math.huge then return 0 end
  if value<0 then return math.ceil(value) end
  return math.floor(value)
end
function Shared.pack16(value,unsigned)
  local n=truncNumber(value)%65536
  local decoded=(not unsigned and n>=32768) and n-65536 or n
  return string.char(n%256,math.floor(n/256)),decoded
end

local function roundTiesEven(value)
  local lower=math.floor(value)
  local fractional=value-lower
  if fractional>0.5 or (fractional==0.5 and lower%2~=0) then
    return lower+1
  end
  return lower
end
local function float32Bits(value)
  value=V.number(value)
  local sign=(value<0 or (value==0 and 1/value==-math.huge)) and 1 or 0
  local signBits=sign*2147483648
  if value~=value then return 2143289344,0/0 end
  if value==math.huge or value==-math.huge then
    return signBits+2139095040,sign==1 and -math.huge or math.huge
  end
  local magnitude=math.abs(value)
  if magnitude>=2^128-2^103 then
    return signBits+2139095040,sign==1 and -math.huge or math.huge
  end
  if magnitude==0 then return signBits,sign==1 and -0.0 or 0.0 end
  local exponentBits,mantissa,quantized
  if magnitude<2^-126 then
    mantissa=roundTiesEven(magnitude/2^-149)
    if mantissa==0 then
      quantized=0.0
      exponentBits=0
    elseif mantissa>=8388608 then
      exponentBits=1
      mantissa=0
      quantized=2^-126
    else
      exponentBits=0
      quantized=mantissa*2^-149
    end
  else
    local exponent=math.floor(math.log(magnitude)/math.log(2))
    local power=2^exponent
    local normalized=magnitude/power
    while normalized<1 do exponent=exponent-1;normalized=normalized*2 end
    while normalized>=2 do exponent=exponent+1;normalized=normalized/2 end
    mantissa=roundTiesEven((normalized-1)*8388608)
    if mantissa==8388608 then exponent=exponent+1;mantissa=0 end
    if exponent>127 then
      return signBits+2139095040,sign==1 and -math.huge or math.huge
    end
    exponentBits=exponent+127
    quantized=(1+mantissa/8388608)*2^exponent
  end
  local bits=signBits+exponentBits*8388608+mantissa
  return bits,sign==1 and -quantized or quantized
end
function Shared.pack32(value)
  local bits,decoded=float32Bits(value)
  local a=bits%256
  bits=math.floor(bits/256)
  local b=bits%256
  bits=math.floor(bits/256)
  local c=bits%256
  local d=math.floor(bits/256)
  return string.char(a,b,c,d),decoded
end

local function getValue(buf,offset,kind)
  local lo=assert(buf:byte(offset),"Missing typed element")
  local b1=assert(buf:byte(offset+1),"Missing typed element")
  local n=lo+b1*256
  if kind=="uint16" then return n end
  if kind=="int16" then return n>=32768 and n-65536 or n end
  local b2=assert(buf:byte(offset+2),"Missing typed element")
  local b3=assert(buf:byte(offset+3),"Missing typed element")
  local exponent=(b3%128)*2+math.floor(b2/128)
  local fraction=b2%128*65536+b1*256+lo
  local sign=b3>=128 and -1 or 1
  if exponent==255 then
    if fraction==0 then return sign*math.huge end
    return 0/0
  elseif exponent==0 then
    return sign*(fraction*2^-149)
  end
  return sign*(1+fraction/8388608)*2^(exponent-127)
end
-- LuaJIT is Lua 5.1-compatible: table __len is not used there.
-- newproxy(true) is a Lua-owned full userdata whose __len is honoured;
-- Lua 5.4 uses an ordinary proxy table and its table __len. Both retain
-- the same typed-array indexing and mutation semantics.
local View={}
local states=setmetatable({},{__mode="k"})
local function viewState(self)
  return states[self]
end
View.__index=function(self,index)
  local state=viewState(self)
  if type(index)=="number" then
    if index%1~=0 or index<1 or index>state._count then return nil end
    return getValue(state._buffer,
      state._offset+(index-1)*state._unit,state._kind)
  end
  if index=="buffer" then return state._buffer
  elseif index=="length" then return state._count
  elseif index=="byteOffset" then return state._offset
  elseif index=="byteLength" then return state._count*state._unit
  elseif index=="BYTES_PER_ELEMENT" then return state._unit end
  return state._props[index]
end
View.__newindex=function(self,index,value)
  local state=viewState(self)
  if type(index)=="number" then
    -- IntegerIndexedElementSet converts the value even for invalid indices.
    local bytes
    if state._kind=="float32" then bytes=Shared.pack32(value)
    else bytes=Shared.pack16(value,state._kind=="uint16") end
    if index%1~=0 or index<1 or index>state._count then return end
    state._buffer:writeBytes(state._offset+(index-1)*state._unit,bytes)
    return
  end
  if index=="buffer" or index=="length" or index=="byteOffset" or index=="byteLength" or index=="BYTES_PER_ELEMENT" then
    error("Readonly typed view metadata")
  end
  state._props[index]=value
end
View.__len=function(self) return viewState(self)._count end
View.__pairs=function(self)
  local index=0
  local count=viewState(self)._count
  return function()
    index=index+1
    if index<=count then return index,self[index] end
  end,self,nil
end
View.__ipairs=View.__pairs
local function proxy(state)
  if type(newproxy)=="function" then
    local user=newproxy(true)
    local meta=getmetatable(user)
    for name,fn in pairs(View) do meta[name]=fn end
    states[user]=state
    return user
  end
  local user=setmetatable({},View)
  states[user]=state
  return user
end

function Shared.view(buf,offset,byteLength,kind)
  local unit=kind=="float32" and 4 or 2
  assert(kind=="int16" or kind=="uint16" or kind=="float32",
    "SharedBinaryBuffer: unknown typed kind")
  assert(type(offset)=="number" and offset>=0 and offset%unit==0,
    "SharedBinaryBuffer: misaligned typed view")
  local count=type(byteLength)=="number" and byteLength>=0 and byteLength%unit==0
    and byteLength/unit or nil
  assert(count~=nil and offset+count*unit<=buf:length(),
    "SharedBinaryBuffer: invalid typed view length")
  return proxy({_buffer=buf,_offset=offset,_count=count,
    _unit=unit,_kind=kind,_props={}})
end
return Shared
