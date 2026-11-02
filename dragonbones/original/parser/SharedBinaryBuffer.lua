-- Lua byte-backed ArrayBuffer / TypedArray transport for DragonBonesData.
-- Pinned original: DragonBones/DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e
-- ObjectDataParser.ts::_modifyArray and BinaryDataParser.ts::_parseArray.
-- MIT: see LICENSE-DRAGONBONES. Only the platform representation differs:
-- Lua numeric indices are 1-based; TypedArray in the original is 0-based.
local Shared={}
local Buffer={}
Buffer.__index=Buffer

function Shared.new(raw)
  local bytes=raw or ""
  assert(type(bytes)=="string","SharedBinaryBuffer expects raw bytes")
  return setmetatable({_bytes=bytes,_patches={},_dirty=false},Buffer)
end
function Buffer:length() return #self._bytes end
function Buffer:byte(offset)
  if offset<0 or offset>=#self._bytes then return nil end
  local patch=self._patches[offset]
  return patch~=nil and patch or self._bytes:byte(offset+1)
end
function Buffer:setByte(offset,value)
  assert(offset>=0 and offset<#self._bytes,"SharedBinaryBuffer write out of range")
  self._patches[offset]=value%256
  self._dirty=true
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
  if not self._dirty then return self._bytes end
  local chunks={}
  for i=0,#self._bytes-1 do chunks[i+1]=string.char(self:byte(i)) end
  return table.concat(chunks)
end

local function truncNumber(value)
  if type(value)=="boolean" then value=value and 1 or 0 end
  if value==nil then return 0 end
  if type(value)~="number" then
    if type(value)=="string" then
      if value:match("^%s*$") then return 0 end
      value=tonumber(value) or 0
    else return 0 end
  end
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
  if type(value)=="boolean" then value=value and 1 or 0 end
  if value==nil then value=0 end
  if type(value)~="number" then value=tonumber(value) or 0 end
  local sign=(value<0 or (value==0 and 1/value==-math.huge)) and 1 or 0
  local signBits=sign*2147483648
  if value~=value then return 2143289344,0/0 end
  if value==math.huge or value==-math.huge then
    return signBits+2139095040,sign==1 and -math.huge or math.huge
  end
  local magnitude=math.abs(value)
  if magnitude==0 then return signBits,sign==1 and -0.0 or 0.0 end
  local exponentBits,mantissa,quantized
  if magnitude<2^-126 then
    mantissa=roundTiesEven(magnitude/2^-149)
    if mantissa==0 then
      quantized=0
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
local View={}
View.__index=function(self,index)
  if type(index)=="number" then
    if index%1~=0 or index<1 or index>self._count then return nil end
    return getValue(self._buffer,self._offset+(index-1)*self._unit,self._kind)
  end
  return View[index]
end
View.__newindex=function(self,index,value)
  if type(index)=="number" then
    if index%1~=0 or index<1 or index>self._count then return end
    local bytes
    if self._kind=="float32" then bytes=Shared.pack32(value)
    else bytes=Shared.pack16(value,self._kind=="uint16") end
    self._buffer:writeBytes(self._offset+(index-1)*self._unit,bytes)
    return
  end
  rawset(self,index,value)
end
View.__len=function(self) return self._count end
View.__pairs=function(self)
  local i=0
  return function()
    i=i+1
    if i<=self._count then return i,self[i] end
  end,self,nil
end
View.__ipairs=View.__pairs
function Shared.view(buf,offset,byteLength,kind)
  local unit=kind=="float32" and 4 or 2
  assert(kind=="int16" or kind=="uint16" or kind=="float32",
    "SharedBinaryBuffer: unknown typed kind")
  assert(type(offset)=="number" and offset>=0 and offset%unit==0,
    "SharedBinaryBuffer: misaligned typed view")
  local count=type(byteLength)=="number" and byteLength>=0
    and math.floor(byteLength/unit) or nil
  assert(count~=nil and offset+count*unit<=buf:length(),
    "SharedBinaryBuffer: invalid typed view length")
  return setmetatable({_buffer=buf,_offset=offset,_count=count,
    _unit=unit,_kind=kind},View)
end
return Shared
