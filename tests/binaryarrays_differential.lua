local P=require('dragonbones.parser.ObjectDataParser')
local B=require('dragonbones.core.BaseObject')
local D=require('dragonbones.model.DragonBonesData')
local A=require('dragonbones.model.ArmatureData')
local M=require('dragonbones.model.DisplayData')
local V=require('dragonbones.parser.JSValue')
local Shared=require('dragonbones.parser.SharedBinaryBuffer')
local names={'intArray','floatArray','frameIntArray','frameFloatArray','frameArray','timelineArray','colorArray'}
local bytes;if string.pack then bytes=function(v)return string.pack('<d',v) end else local ffi=require('ffi');bytes=function(v)return ffi.string(ffi.new('double[1]',v),8) end end
local function hex(s)return (s:gsub('.',function(c)return string.format('%02x',c:byte()) end)) end
local function unhex(s)return (s:gsub('..',function(c)return string.char(tonumber(c,16)) end)) end
local function num(s)if s=='NaN' then return 0/0 elseif s=='Infinity' then return math.huge elseif s=='-Infinity' then return -math.huge elseif s=='-0' then return -0.0 end;return assert(tonumber(s))+0.0 end
local function decode(v)
 if v=='undefined' then return V.UNDEFINED elseif v=='null' then return V.NULL elseif v=='blocked' then return {toString='blocked'} elseif v=='object' then return {} elseif v=='array' then local a=V.array();a[1]='12';return a elseif v=='emptyArray' then return V.array() elseif v:sub(1,2)=='s:' then return unhex(v:sub(3)) elseif v:sub(1,2)=='b:' then return v=='b:true' end;return num(v:sub(3))
end
local function scalar(v)
 if v==nil or rawequal(v,V.UNDEFINED) then return 'undefined' elseif rawequal(v,V.NULL) then return 'null' elseif type(v)=='string' then return 's:'..hex(v) elseif type(v)=='boolean' then return tostring(v) elseif type(v)=='table' then return V.isArray(v) and 'array' or v.toString=='blocked' and 'blocked' or 'object' elseif v~=v then return 'NaN' end
 return hex(bytes(v))
end
local p,views,saved,snapshots,ids,nextId,geometry,publicationHook
local function reset()p=P.new();p._data=B.borrowObject(D);views={};saved={};snapshots={};ids=setmetatable({},{__mode='k'});nextId=0;geometry=nil;publicationHook=nil end
local function integer(n)return string.format('%.0f',n) end
local function id(o)if o==nil then return 'nil' end;if not ids[o] then nextId=nextId+1;ids[o]=nextId end;return integer(ids[o]) end
local function keys(t)local out={};for k in pairs(t) do out[#out+1]=k end;table.sort(out);return out end
local function view(v)
 if v==nil then return 'nil' end
 local out={};for i=1,v.length do out[i]=scalar(v[i]) end
 return table.concat({id(v),id(v.buffer),integer(v.length),integer(v.byteOffset),integer(v.byteLength),integer(v.BYTES_PER_ELEMENT),table.concat(out,','),scalar(v.extra)},':')
end
local function data(o)
 if o==nil then return 'nil' end
 local out={id(o.binary),o.binary and integer(o.binary.byteLength) or 'nil',o.binary and hex(o.binary:bytes()) or 'nil'}
 for _,n in ipairs(names) do out[#out+1]=view(o[n]) end;return table.concat(out,'|')
end
local function execute(r)
 local op,a,b,c,e=r[1],r[2],r[3],r[4],r[5]
 if op=='length' then p['_'..a].length=num(b)
 elseif op=='put' then p['_'..a][num(b)+1]=decode(c)
 elseif op=='modify' then p:_modifyArray()
 elseif op=='resetArrays' then p:_parseArray(nil)
 elseif op=='save' then local o={binary=p._data.binary};for _,n in ipairs(names) do o[n]=p._data[n] end;saved[a]=o
 elseif op=='view' then views[a]=p._data[b]
 elseif op=='write' then views[a][num(b)+1]=decode(c)
 elseif op=='byte' then p._data.binary:setByte(num(a),num(b))
 elseif op=='snapshot' then snapshots[a]=p._data.binary:bytes()
 elseif op=='overlap' then views[a]=Shared.view(p._data.binary,num(b),num(c),e)
 elseif op=='metadata' then views[a][b]=decode(c)
 elseif op=='extra' then views[a].extra=decode(b)
 elseif op=='default' then p._defaultColorOffset=num(a)
 elseif op=='returnData' then p._data:returnToPool()
 elseif op=='reuse' then p._data=B.borrowObject(D)
 elseif op=='nullData' then p._data=nil
 elseif op=='failPublish' then
  local o=p._data;local original=getmetatable(o);local value=o[a];rawset(o,a,nil);publicationHook={fail=true}
  setmetatable(o,{__index=function(self,k)if k==a then return value end;return original.__index[k] end,
   __newindex=function(self,k,v)if k==a then value=v;if publicationHook.fail then error('setter failure') end else rawset(self,k,v) end end})
 elseif op=='allowPublish' then publicationHook.fail=false
 elseif op=='weighted' then
  p._armature=B.borrowObject(A.ArmatureData);local bone=B.borrowObject(A.BoneData);bone.name='root';p._armature:addBone(bone);p._rawBones[p._rawBones.length+1]=bone
  geometry=B.borrowObject(M.MeshDisplayData).geometry
  local function arr(values)local a=V.array();for i,v in ipairs(values) do a[i]=v end;return a end
  p:_parseGeometry({vertices=arr({1,2,3,4}),weights=arr({1,0,.25,1,0,.75}),bones=arr({0})},geometry)
 elseif op=='weightCounts' then local w=geometry.weight;return table.concat({scalar(w.count),scalar(w.offset),scalar(p._data.intArray[w.offset+1]),scalar(p._data.intArray[w.offset+2])},',')
 elseif op=='geometry' then
  p._armature=B.borrowObject(A.ArmatureData);local m=B.borrowObject(M.MeshDisplayData);geometry=m.geometry
  local function arr(values)local a=V.array();for i,v in ipairs(values) do a[i]=v end;return a end
  p:_parseGeometry({vertices=arr({1,2,3,4,5,6}),triangles=arr({0,1,2}),uvs=arr({0,0,1,0,0,1})},geometry)
 elseif op=='counts' then return scalar(geometry.vertexCount)..','..scalar(geometry.triangleCount)
 else error('Unknown operation '..op) end;return 'void'
end
local function snapshot()
 local out={scalar(p._defaultColorOffset)}
 for _,n in ipairs(names) do local a=p['_'..n];local values={};for i=1,a.length do values[i]=scalar(a[i]) end;out[#out+1]=integer(a.length)..':'..table.concat(values,',') end
 out[#out+1]=data(p._data)
 for _,k in ipairs(keys(saved)) do out[#out+1]=k..'='..data(saved[k]) end
 for _,k in ipairs(keys(views)) do out[#out+1]=k..'='..view(views[k]) end
 for _,k in ipairs(keys(snapshots)) do out[#out+1]=k..'='..hex(snapshots[k]) end
 return out
end
local i=0
for line in io.lines(assert(arg[1])) do
 local r={};for s in (line..'\t'):gmatch('(.-)\t') do r[#r+1]=s end
 local tag='void';if r[1]=='begin' then reset() else local ok,result=pcall(execute,r);tag=ok and result or 'error' end
 local out={integer(i),tag};for _,v in ipairs(snapshot()) do out[#out+1]=v end
 io.write(table.concat(out,'\t'),'\n');i=i+1
end
