local P=require('dragonbones.parser.BinaryDataParser')
local V=require('dragonbones.parser.JSValue')
local Shared=require('dragonbones.parser.SharedBinaryBuffer')
local B=require('dragonbones.core.BaseObject')
local D=require('dragonbones.model.DragonBonesData')
local double
if string.pack then double=function(n)return string.pack('<d',n)end else local ffi=require('ffi');double=function(n)return ffi.string(ffi.new('double[1]',n),8)end end
local function hex(s)return(s:gsub('.',function(c)return string.format('%02x',c:byte())end))end
local function scalar(v)if v==nil then return'u'end;if v~=v then return'NaN'end;return hex(double(v))end
local fields={'intArray','floatArray','frameIntArray','frameFloatArray','frameArray','timelineArray','colorArray'}
local kinds={'int16','float32','int16','float32','int16','uint16','int16'}
local function value(s)if s=='undefined'then return V.UNDEFINED elseif s=='null'then return V.NULL elseif s=='NaN'then return 0/0 elseif s=='Infinity'then return math.huge end;return assert(tonumber(s))end
local function arr(t)local a=V.array();for i,v in ipairs(t)do a[i]=v end;return a end
local function execute(c)
 local mode,index,token=c[1],tonumber(c[2]),c[3]
 local p,data=P.new(),B.borrowObject(D);local bytes={};for i=0,127 do bytes[#bytes+1]=string.char((i*13+7)%256)end
 local buf,old=Shared.new(table.concat(bytes)),Shared.new(string.rep('\0',16));data.binary=old
 for i,k in ipairs(fields)do data[k]=Shared.view(old,0,(kinds[i]=='float32'and 4 or 2)*2,kinds[i])end
 p._intArrayBuffer=data.intArray;p._frameArrayBuffer=data.frameArray;p._timelineArrayBuffer=data.timelineArray;p._data=data;p._binary=buf;p._binaryOffset=8
 local offsets=arr({0,8,8,8,16,4,20,8,28,4,32,4,36,4})
 if mode=='start'or mode=='length'then offsets[index+1]=value(token)end
 if mode=='base'then p._binaryOffset=value(token)end
 if mode=='overlap'or mode=='mutate'then offsets=arr({0,8,0,8,0,8,0,8,0,8,0,8,0,8})end
 if mode=='empty'then offsets=arr({0,0,0,0,0,0,0,0,0,0,0,0,0,0})end
 if mode=='short'then offsets=arr({})end
 if mode=='colorMissing'then offsets.length=13 end
 if mode=='colorZero'then offsets[13]=999;offsets[14]=0 end
 local raw={offset=offsets}
 if mode=='nullRaw'then raw=V.NULL end
 if mode=='nullOffsets'then raw.offset=V.NULL end
 if mode=='missingData'then p._data=nil end
 if mode=='setter'then local previous=data[token];rawset(data,token,nil);setmetatable(data,{__index=function(_,key)if key==token then return previous end;return D[key]end,__newindex=function(t,key,v)if key==token then error('injected setter')end;rawset(t,key,v)end})end
 local ok=pcall(function()p:_parseArray(raw)end)
 local before=hex(buf:bytes());if mode=='mutate'and ok then data.intArray[1]=0x1234;data.floatArray[2]=1.25;data.timelineArray[3]=65535 end
 local function meta(v)if v==nil then return'nil'end;local values={};for i=1,math.min(v.length,12)do values[#values+1]=scalar(v[i])end;return table.concat({v.buffer==buf and'new'or v.buffer==old and'old'or'other',string.format('%.0f',v.length),string.format('%.0f',v.byteOffset),string.format('%.0f',v.byteLength),string.format('%.0f',v.BYTES_PER_ELEMENT),table.concat(values,',')},':')end
 local out={ok and'ok'or'error',data.binary==buf and'new'or data.binary==old and'old'or'other'}
 for _,k in ipairs(fields)do out[#out+1]=meta(data[k])end
 for _,v in ipairs({meta(p._intArrayBuffer),meta(p._frameArrayBuffer),meta(p._timelineArrayBuffer),tostring(p._intArrayBuffer==data.intArray),tostring(p._frameArrayBuffer==data.frameArray),tostring(p._timelineArrayBuffer==data.timelineArray),tostring(data.colorArray==data.intArray),hex(buf:bytes()),before})do out[#out+1]=v end
 return table.concat(out,'\t')
end
for line in io.lines(assert(arg[1]))do local c={};for v in(line..'\t'):gmatch('(.-)\t')do c[#c+1]=v end;io.write(execute(c),'\n')end
