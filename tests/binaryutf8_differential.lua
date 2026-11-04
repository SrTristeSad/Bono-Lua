local P=require('dragonbones.parser.BinaryDataParser');local Shared=require('dragonbones.parser.SharedBinaryBuffer');local V=require('dragonbones.parser.JSValue');local p=P.new()
local function unhex(s)return (s:gsub('..',function(c)return string.char(tonumber(c,16)) end)) end
local function hex(s)return (s:gsub('.',function(c)return string.format('%02x',c:byte()) end)) end
local function num(s)if s=='NaN' then return 0/0 elseif s=='Infinity' then return math.huge elseif s=='-Infinity' then return -math.huge elseif s=='-0' then return -0.0 end;return assert(tonumber(s))+0.0 end
local function value(s)if s=='undefined' then return V.UNDEFINED elseif s=='null' then return V.NULL elseif s=='blocked' then return {toString='blocked'} elseif s=='empty' then return V.array() elseif s=='array' then local a=V.array();a[1]='12';return a elseif s:sub(1,2)=='s:' then return unhex(s:sub(3)) elseif s:sub(1,2)=='b:' then return s=='b:true' end;return num(s:sub(3)) end
local function utf16(s)
 local out={};local function put(n)out[#out+1]=string.char(n%256,math.floor(n/256)) end
 for unit in V.iterator(s) do local a,b,c=unit:byte(1,3);local cp=a<128 and a or a<224 and (a-192)*64+b-128 or (a-224)*4096+(b-128)*64+c-128;put(cp) end
 return hex(table.concat(out))
end
local function csv(t)for i,v in ipairs(t) do if type(v)=="number" then t[i]=string.format("%.0f",v) end end;return table.concat(t,",") end
local function execute(r)
 local op,a,b,c=r[1],r[2],r[3],r[4]
 if op=='singleton' then local q=P.getInstance();local out={getmetatable(q)==P and 1 or 0,q==P.getInstance() and 1 or 0,q~=p and 1 or 0};for _,k in ipairs({'_binaryOffset','_binary','_intArrayBuffer','_frameArrayBuffer','_timelineArrayBuffer'}) do out[#out+1]=q[k]==nil and 1 or 0 end;out[#out+1]=q._helpPoint~=p._helpPoint and 1 or 0;return table.concat(out,',') end
 if op=='decode' then local bytes=unhex(a);local buf=Shared.new('\0\0'..bytes..'\0\0');return utf16(p:_decodeUTF8(Shared.view(buf,2,#bytes,'uint8'))) end
 if op=='range' then return tostring(p:_inRange(num(a),num(b),num(c))) end
 if op=='write' then local buf=Shared.new(string.rep('\0',4));local v=Shared.view(buf,1,2,'uint8');local ok=pcall(function()v[num(a)+1]=value(b) end);return (ok and 'ok' or 'error')..':'..hex(buf:bytes())..':'..csv({v.length,v.byteOffset,v.byteLength,v.BYTES_PER_ELEMENT,tostring(v.buffer==buf)}) end
 if op=='view' then local buf=Shared.new(string.rep('\0',4));local v=Shared.view(buf,num(a),num(b),c);return csv({v.length,v.byteOffset,v.byteLength,v.BYTES_PER_ELEMENT,tostring(v.buffer==buf)}) end
 if op=='readonly' then local v=Shared.view(Shared.new('\0\0'),0,2,'uint8');v[a]=3;return 'miss' end
 if op=='aliases' then local buf=Shared.new(string.rep('\0',4));local v=Shared.view(buf,0,4,'uint8');local w=Shared.view(buf,0,4,'uint16');v[1]=255;v[2]=127;local before=hex(buf:bytes());local word=w[1];w[1]=0x1234;return before..':'..word..':'..hex(buf:bytes())..':'..v[1]..','..v[2] end
 error('Unknown op')
end
local index=0
for line in io.lines(assert(arg[1])) do local r={};for part in (line..'\t'):gmatch('(.-)\t') do r[#r+1]=part end;local ok,result=pcall(execute,r);io.write(index,'\t',ok and result or 'error','\n');index=index+1 end
