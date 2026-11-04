-- Platform adapter for JSON.parse (without reviver), not an upstream class.
-- Objects preserve JS key order; arrays/null use the parser's existing values.
local V = require('dragonbones.parser.JSValue')
local Map = require('dragonbones.core.JSMap')
local JSON = {}
local function character(cp)
  if cp < 128 then return string.char(cp) end
  if cp < 2048 then return string.char(192+math.floor(cp/64),128+cp%64) end
  if cp < 65536 then return string.char(224+math.floor(cp/4096),128+math.floor(cp/64)%64,128+cp%64) end
  return string.char(240+math.floor(cp/262144),128+math.floor(cp/4096)%64,128+math.floor(cp/64)%64,128+cp%64)
end
function JSON.parse(source)
  assert(type(source)=='string','JSON source must be a string')
  local i, size = 1, #source
  local function fail() error('Invalid JSON at byte '..i,0) end
  local function space()
    while true do
      local b=source:byte(i)
      if b~=32 and b~=9 and b~=10 and b~=13 then return end
      i=i+1
    end
  end
  local escapes={['"']='"',['\\']='\\',['/']='/',b='\b',f='\f',n='\n',r='\r',t='\t'}
  local function stringValue()
    if source:sub(i,i)~='"' then fail() end
    i=i+1
    local out={}
    while i<=size do
      local c=source:sub(i,i)
      if c=='"' then i=i+1;return table.concat(out) end
      if c=='\\' then
        i=i+1;c=source:sub(i,i)
        if escapes[c] then out[#out+1]=escapes[c];i=i+1
        elseif c=='u' then
          local h=source:sub(i+1,i+4)
          if not h:match('^%x%x%x%x$') then fail() end
          local cp=tonumber(h,16);i=i+5
          if cp>=55296 and cp<=56319 and source:sub(i,i+1)=='\\u' then
            local low=source:sub(i+2,i+5)
            local n=low:match('^%x%x%x%x$') and tonumber(low,16) or nil
            if n and n>=56320 and n<=57343 then cp=65536+(cp-55296)*1024+n-56320;i=i+6 end
          end
          -- Lone UTF-16 surrogates remain WTF-8, as in the value adapter.
          out[#out+1]=character(cp)
        else fail() end
      else
        if c:byte()<32 then fail() end
        out[#out+1]=c;i=i+1
      end
    end
    fail()
  end
  local function digit()local b=source:byte(i);return b and b>=48 and b<=57 end
  local function numberValue()
    local start=i
    if source:sub(i,i)=='-' then i=i+1 end
    if source:sub(i,i)=='0' then i=i+1
    elseif digit() then repeat i=i+1 until not digit()
    else fail() end
    if source:sub(i,i)=='.' then
      i=i+1;if not digit() then fail() end
      repeat i=i+1 until not digit()
    end
    local c=source:sub(i,i)
    if c=='e' or c=='E' then
      i=i+1;c=source:sub(i,i)
      if c=='+' or c=='-' then i=i+1 end
      if not digit() then fail() end
      repeat i=i+1 until not digit()
    end
    local token=source:sub(start,i-1)
    local n=tonumber(token)
    if not n then fail() end
    n=n+0.0 -- Lua 5.4 integers must become the source's binary64 numbers.
    if n==0 and token:sub(1,1)=='-' then return -0.0 end
    return n
  end
  local parse
  parse=function()
    space()
    local c=source:sub(i,i)
    if c=='"' then return stringValue() end
    if c=='{' then
      i=i+1;space();local object=Map.new()
      if source:sub(i,i)=='}' then i=i+1;return object end
      while true do
        space();local key=stringValue();space()
        if source:sub(i,i)~=':' then fail() end
        i=i+1;object[key]=parse();space()
        c=source:sub(i,i);i=i+1
        if c=='}' then return object end
        if c~=',' then fail() end
      end
    end
    if c=='[' then
      i=i+1;space();local array=V.array()
      if source:sub(i,i)==']' then i=i+1;return array end
      while true do
        array[array.length+1]=parse();space();c=source:sub(i,i);i=i+1
        if c==']' then return array end
        if c~=',' then fail() end
      end
    end
    for _,literal in ipairs({'true','false','null'}) do
      if source:sub(i,i+#literal-1)==literal then
        i=i+#literal
        if literal=='null' then return V.NULL end
        return literal=='true'
      end
    end
    if c=='-' or digit() then return numberValue() end
    fail()
  end
  local result=parse();space();if i<=size then fail() end
  return result
end
return JSON
