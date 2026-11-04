local P=require('dragonbones.parser.BinaryDataParser')
local JSON=require('dragonbones.parser.JSON')
local V=require('dragonbones.parser.JSValue')
local Map=require('dragonbones.core.JSMap')
local Shared=require('dragonbones.parser.SharedBinaryBuffer')
local B=require('dragonbones.core.BaseObject')
local double
if string.pack then double=function(n)return string.pack('<d',n)end else local ffi=require('ffi');double=function(n)return ffi.string(ffi.new('double[1]',n),8)end end
local function hex(s)return(s:gsub('.',function(c)return string.format('%02x',c:byte())end))end
local function unhex(s)return(s:gsub('..',function(c)return string.char(tonumber(c,16))end))end
local function utf16(s)
 local out={};for unit in V.iterator(s)do local a,b,c=unit:byte(1,3);local cp=a<128 and a or a<224 and(a-192)*64+b-128 or(a-224)*4096+(b-128)*64+c-128;out[#out+1]=string.char(cp%256,math.floor(cp/256))end;return hex(table.concat(out))
end
local function scalar(v)
 if v==nil or rawequal(v,V.UNDEFINED)then return'u'end
 if rawequal(v,V.NULL)then return'null'end
 if type(v)=='string'then return's'..utf16(v)end
 if type(v)=='number'then return v~=v and'NaN'or'n'..hex(double(v))end
 return tostring(v)
end
local function list(a,fn,sep)local out={};for i=1,a.length do out[#out+1]=fn(a[i])end;return table.concat(out,sep or',')end
local function mapping(m,fn,sep)local out={};for _,k in ipairs(Map.keys(m))do out[#out+1]=fn(k,m[k])end;return table.concat(out,sep or'|')end
local function tree(v)
 if type(v)~='table'or rawequal(v,V.NULL)then return scalar(v)end
 if V.isArray(v)then return'['..list(v,tree,'|')..']'end
 return'{'..mapping(v,function(k,x)return scalar(k)..':'..tree(x)end)..'}'
end
local function execute(r)
 local op,raw,scale=r[1],unhex(r[2]),tonumber(r[3])
 if op=='json'then local ok,value=pcall(JSON.parse,raw);return{ok and'ok'or'error',ok and tree(value)or''}end
 local p=P.new();local buf,old=Shared.new(raw),Shared.new('\0');p._binary=old;p._binaryOffset=99
 local allocated={};local borrow=B.borrowObject;B.borrowObject=function(C)local o=borrow(C);allocated[#allocated+1]=o;return o end
 local result;local ok=pcall(function()result=p:parseDragonBonesData(buf,scale)end);B.borrowObject=borrow
 local data=result or p._data
 local function tl(t)if t==nil then return'nil'end;local out={};for _,k in ipairs({'type','offset','frameIndicesOffset','x','y'})do out[#out+1]=scalar(t[k])end;return table.concat(out,',')end
 local function snapshot()
  if data==nil then return'nil'end
  local arms=list(data.armatureNames,function(n)
   local a=data:getArmature(n)
   local skins=mapping(a.skins,function(_,skin)return mapping(skin.displays,function(_,displays)return list(displays,function(x)
    if x==nil then return'null'end
    local g=x.geometry;local geom=''
    if g then geom=table.concat({scalar(g.offset),tostring(g.vertexCount),g.weight and tostring(g.weight.count)or'none',g.weight and list(g.weight.bones,function(b)return b and scalar(b.name)or'u'end)or''},',')end
    return scalar(x.name)..':'..geom
   end,';')end)end,'/')
   local animations=mapping(a.animations,function(_,z)
    local out={scalar(z.name),scalar(z.duration),tl(z.actionTimeline)}
    for _,m in ipairs({'boneTimelines','slotTimelines','constraintTimelines','animationTimelines'})do out[#out+1]=mapping(z[m],function(n,t)return scalar(n)..'='..list(t,tl,';')end)end
    return table.concat(out,'/')
   end)
   return table.concat({scalar(a.name),scalar(a.scale),list(a.sortedBones,function(b)return scalar(b.name)end),skins,animations},'~')
  end,'!')
  local views={};for _,k in ipairs({'intArray','floatArray','frameIntArray','frameFloatArray','frameArray','timelineArray','colorArray'})do local v=data[k];views[#views+1]=v and table.concat({string.format('%.0f',v.byteOffset),string.format('%.0f',v.byteLength),tostring(v.buffer==buf)},',')or'nil'end
  return table.concat({scalar(data.name),scalar(data.version),scalar(data.frameRate),data.stage and scalar(data.stage.name)or'nil',arms,list(data.frameIndices,scalar),table.concat(views,'|'),tostring(data.binary==buf),tostring(data.colorArray==data.intArray)},'#')
 end
 local before=snapshot()
 if op=='mutate'and data then data.intArray[1]=7;data.timelineArray[1]=250 end
 local cleanup='skip';if op=='cleanup'and result then cleanup=pcall(function()result:returnToPool()end)and'ok'or'error'end
 local pooled={};for _,o in ipairs(allocated)do pooled[#pooled+1]=o._isInPool and'1'or'0'end
 return{ok and'ok'or'error',not ok and'undefined'or result and'data'or'null',scalar(p._binaryOffset),p._binary==buf and'new'or p._binary==old and'old'or'other',p._data==nil and'clear'or'retained',p._animation==nil and'clear'or'retained',before,op=='mutate'and snapshot()or'',cleanup,table.concat(pooled),hex(buf:bytes())}
end
for line in io.lines(assert(arg[1]))do local r={};for v in(line..'\t'):gmatch('(.-)\t')do r[#r+1]=v end;io.write(table.concat(execute(r),'\t'),'\n')end
