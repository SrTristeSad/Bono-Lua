-- Language boundary for decoded JSON-like values, not an upstream class.
-- DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e (MIT).
local JSArray=require('dragonbones.core.JSArray')
local NumberString=require('dragonbones.geom.JSNumberString')
local V={NULL={},UNDEFINED={}}
local arrays=setmetatable({},{__mode='k'})
function V.array()local a=JSArray.new();arrays[a]=true;return a end
function V.isArray(a)return arrays[a]==true end
function V.object(raw)
  if type(raw)~='table' or rawequal(raw,V.NULL) or rawequal(raw,V.UNDEFINED) then error('Expected raw object') end
  return raw
end
function V.has(raw,key)return V.object(raw)[key]~=nil end
function V.get(raw,key)local v=V.object(raw)[key];if v==nil then return V.UNDEFINED end;return v end
function V.at(raw,index)
 local v;if V.isArray(raw) then v=raw[index+1] else v=V.object(raw)[string.format('%.0f',index)] end
 if v==nil then return V.UNDEFINED end;return v
end
function V.truthy(v)
 if v==nil or rawequal(v,V.NULL) or rawequal(v,V.UNDEFINED) or v==false then return false end
 if type(v)=='number' then return v~=0 and v==v end
 if type(v)=='string' then return v~='' end
 return true
end
function V.string(v,active)
 if v==nil or rawequal(v,V.UNDEFINED) then return 'undefined' end
 if rawequal(v,V.NULL) then return 'null' end
 local kind=type(v)
 if kind=='string' then return v elseif kind=='boolean' then return v and 'true' or 'false'
 elseif kind=='number' then return NumberString.format(v) end
 if type(v)=='table' and rawget(v,'toString')~=nil then error('Unsupported noncallable toString') end
 if V.isArray(v) then
  active=active or {};if active[v] then return '' end;active[v]=true;local values={}
  for i=1,v.length do local item=v[i]
   values[i]=(item==nil or rawequal(item,V.NULL) or rawequal(item,V.UNDEFINED)) and '' or V.string(item,active)
  end
  active[v]=nil;return table.concat(values,',')
 end
 return '[object Object]'
end
-- ECMAScript whitespace at string boundaries (UTF-8); no locale C dependence.
local whitespace={'\9','\10','\11','\12','\13',' ','\194\160','\225\154\128','\226\128\128','\226\128\129','\226\128\130','\226\128\131','\226\128\132','\226\128\133','\226\128\134','\226\128\135','\226\128\136','\226\128\137','\226\128\138','\226\128\168','\226\128\169','\226\128\175','\226\129\159','\227\128\128','\239\187\191'}
local function trim(s)
 local changed=true
 while changed do changed=false;for _,w in ipairs(whitespace) do if s:sub(1,#w)==w then s=s:sub(#w+1);changed=true end;if s:sub(-#w)==w then s=s:sub(1,#s-#w);changed=true end end end
 return s
end
local digits='0123456789abcdef'
local function radix(s,base)
 local bits=base==2 and 1 or 3;local binary={}
 for c in s:gmatch('.') do local n=tonumber(c);if not n or n>=base then return 0/0 end;local value='';for _=1,bits do value=tostring(n%2)..value;n=math.floor(n/2) end;binary[#binary+1]=value end
 local b=table.concat(binary);b=string.rep('0',(4-#b%4)%4)..b;local hex={}
 for i=1,#b,4 do local n=tonumber(b:sub(i,i+3),2);hex[#hex+1]=digits:sub(n+1,n+1) end
 return tonumber('0x'..table.concat(hex)..'.0p0') or 0/0
end
function V.number(v)
 if v==nil or rawequal(v,V.UNDEFINED) then return 0/0 end
 if rawequal(v,V.NULL) then return 0 end
 local kind=type(v);if kind=='number' then return v elseif kind=='boolean' then return v and 1 or 0 end
 local s=trim(V.string(v));if s=='' then return 0 end
 if s=='Infinity' or s=='+Infinity' then return math.huge elseif s=='-Infinity' then return -math.huge end
 if s:match('^0[xX]%x+$') then return tonumber(s..'.0p0') or 0/0 end
 if s:match('^0[bB][01]+$') then return radix(s:sub(3),2) end
 if s:match('^0[oO][0-7]+$') then return radix(s:sub(3),8) end
 local mantissa=s:match('^(.-)[eE][+-]?%d+$')
 if not mantissa then if s:find('[eE]') then return 0/0 end;mantissa=s end
 if mantissa:sub(1,1)=='+' or mantissa:sub(1,1)=='-' then mantissa=mantissa:sub(2) end
 if not (mantissa:match('^%d+%.?%d*$') or mantissa:match('^%.%d+$')) then return 0/0 end
 local result=tonumber(s);if not result then return 0/0 end
 if result==0 and s:sub(1,1)=='-' then return -0.0 end
 return result+0.0
end
return V
