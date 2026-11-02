-- Shared mutable ArrayBuffer / typed views for the pinned DragonBonesJS
-- ObjectDataParser._modifyArray and BinaryDataParser._parseArray.
-- Source: DragonBones/DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e
-- Copyright (c) 2012-2025 DragonBones team and other contributors.
-- MIT license: see LICENSE-DRAGONBONES.
-- Lua byte strings are immutable. Keep original bytes plus written-byte
-- overlays and expose 1-based numeric views with JS TypedArray coercion.
-- The data model returns the CURRENT bytes as a string when binary is read;
-- unlike JS, the returned string is an immutable snapshot of that instant.
local Buffer={}
Buffer.__index=Buffer
local View={}
local viewMethods={}

local function toNumber(value)
  if type(value)=="boolean" then return value and 1 or 0 end
  if value==nil then return 0 end
  if type(value)=="number" then return value end
  if type(value)=="string" then
    if value:match("^%s*$") then return 0 end
    return tonumber(value) or 0
  end
  return 0
end
local function trunc(value)
  value=toNumber(value)
  if value~=value or value==math.huge or value==-math.huge then return 0 end
  return value<0 and math.ceil(value) or math.floor(value)
end

local function roundEven(value)
  local lower=math.floor(value)
  local part=value-lower
  if part>0.5 or (part==0.5 and lower%2~=0) then return lower+1 end
  return lower
end

local function float32Bits(value)
  value=toNumber(value)
  local sign=(value<0 or (value==0 and 1/value==-math.huge)) and 1 or 0
  local signBits=sign*2147483648
  if value~=value then return 2143289344 end -- quiet NaN
  if value==math.huge or value==-math.huge then
    return signBits+2139095040
  end
  local magnitude=math.abs(value)
  if magnitude==0 then return signBits end
  local exponentBits,mantissa
  if magnitude<2^-126 then
    mantissa=roundEven(magnitude/2^-149)
    if mantissa>=8388608 then
      exponentBits=1
      mantissa=0
    else
      exponentBits=0
    end
  else
    local exponent=math.floor(math.log(magnitude)/math.log(2))
    local normalized=magnitude/2^exponent
    while normalized<1 do exponent=exponent-1;normalized=normalized*2 end
    while normalized>=2 do exponent=exponent+1;normalized=normalized/2 end
    mantissa=roundEven((normalized-1)*8388608)
    if mantissa==8388608 then exponent=exponent+1;mantissa=0 end
    if exponent>127 then return signBits+2139095040 end
    exponentBits=exponent+127
  end
  return signBits+exponentBits*8388608+mantissa
end

function Buffer.pack16(value,unsigned)
  local n=trunc(value)%65536
  local result=n
  if not unsigned and n>=32768 then result=n-65536 end
  return string.char(n%256,math.floor(n/256)),result
end

function Buffer.pack32(value)
  local bits=float32Bits(value)
  return string.char(bits%256,math.floor(bits/256)%256,
    math.floor(bits/65536)%256,math.floor(bits/16777216)),nil
end

function Buffer.new(bytes)
  assert(type(bytes)=="string","SharedBuffer requires raw bytes")
  return setmetatable({original=bytes,changes={},byteLength=#bytes},Buffer)
end

function Buffer:byte(offset)
  assert(offset>=0 and offset<self.byteLength,"TypedArray byte offset out of bounds")
  return self.changes[offset+1] or self.original:byte(offset+1)
end

function Buffer:setByte(offset,value)
  assert(offset>=0 and offset<self.byteLength,"TypedArray byte offset out of bounds")
  self.changes[offset+1]=value
end

function Buffer:toString()
  if next(self.changes)==nil then return self.original end
  local offsets={}
  for i in pairs(self.changes) do offsets[#offsets+1]=i end
  table.sort(offsets)
  local chunks={}
  local first=1
  for _,i in ipairs(offsets) do
    if first<i then chunks[#chunks+1]=self.original:sub(first,i-1) end
    chunks[#chunks+1]=string.char(self.changes[i])
    first=i+1
  end
  chunks[#chunks+1]=self.original:sub(first)
  return table.concat(chunks)
end

function Buffer:read(offset,kind)
  local a=self:byte(offset)
  local b=self:byte(offset+1)
  if kind=="int16" or kind=="uint16" then
    local n=a+b*256
    if kind=="int16" and n>=32768 then n=n-65536 end
    return n
  end
  local c=self:byte(offset+2)
  local d=self:byte(offset+3)
  local exponent=(d%128)*2+math.floor(c/128)
  local fraction=c%128*65536+b*256+a
  local sign=d>=128 and -1 or 1
  if exponent==255 then
    if fraction==0 then return sign*math.huge end
    return 0/0
  elseif exponent==0 then
    return sign*(fraction*2^-149)
  end
  return sign*(1+fraction/8388608)*2^(exponent-127)
end

function Buffer:write(offset,kind,value)
  local bytes
  if kind=="float32" then
    bytes=Buffer.pack32(value)
  else
    bytes=Buffer.pack16(value,kind=="uint16")
  end
  for i=1,#bytes do self:setByte(offset+i-1,bytes:byte(i)) end
end

-- JS TypedArray indices are zero-based; Lua consumers in this port use
-- one-based indices. All views use the SAME byte store and fixed lengths.
function Buffer:view(offset,count,kind)
  local size=kind=="float32" and 4 or 2
  assert(type(offset)=="number" and offset>=0 and offset%size==0,
    "SharedBuffer: misaligned typed view")
  assert(type(count)=="number" and count>=0 and count==math.floor(count)
    and offset+count*size<=self.byteLength,
    "SharedBuffer: typed view exceeds ArrayBuffer")
  return setmetatable({
    buffer=self,byteOffset=offset,length=count,kind=kind,itemBytes=size
  },View)
end

function View.__index(self,key)
  if type(key)=="number" and key==math.floor(key)
      and key>=1 and key<=self.length then
    return self.buffer:read(self.byteOffset+(key-1)*self.itemBytes,self.kind)
  end
  return viewMethods[key]
end

function View.__newindex(self,key,value)
  if type(key)=="number" then
    if key==math.floor(key) and key>=1 and key<=self.length then
      self.buffer:write(self.byteOffset+(key-1)*self.itemBytes,self.kind,value)
    end -- TypedArray ignores numeric out-of-range assignments.
  else
    rawset(self,key,value)
  end
end

-- LuaJIT 2.1 and Lua 5.4 both support the Lua 5.2 table __len extension.
function View.__len(self) return self.length end
function View.__ipairs(self)
  local i=0
  return function()
    i=i+1
    if i<=self.length then return i,self[i] end
  end,self,0
end
function View.__pairs(self)
  return View.__ipairs(self)
end
function viewMethods:toArray()
  local out={}
  for i=1,self.length do out[i]=self[i] end
  return out
end

return Buffer
