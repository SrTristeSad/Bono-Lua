local P=require('dragonbones.parser.BinaryDataParser')
local JSON=require('dragonbones.parser.JSON')
local V=require('dragonbones.parser.JSValue')
local ObjectParser=require('dragonbones.parser.ObjectDataParser')
local Skin=require('dragonbones.model.SkinData')
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
local function attrs(o,keys)if o==nil then return'nil'end;local out={};for _,k in ipairs(keys)do out[#out+1]=scalar(o[k])end;return table.concat(out,',')end
local transformKeys={'x','y','rotation','skew','scaleX','scaleY'}
local colorKeys={'alphaMultiplier','redMultiplier','greenMultiplier','blueMultiplier','alphaOffset','redOffset','greenOffset','blueOffset'}
local function details(data)
 if data==nil then return'nil'end
 return list(data.armatureNames,function(n)
  local a=data:getArmature(n)
  local bones=list(a.sortedBones,function(b)return attrs(b,{'name','type','length','alpha','inheritTranslation','inheritRotation','inheritScale','inheritReflection'})..'/'..(b.parent and scalar(b.parent.name)or'nil')..'/'..attrs(b.transform,transformKeys)end,'|')
  local slots=list(a.sortedSlots,function(s)return attrs(s,{'name','displayIndex','zOrder','alpha','blendMode'})..'/'..(s.parent and scalar(s.parent.name)or'nil')..'/'..attrs(s.color,colorKeys)end,'|')
  local displays=mapping(a.skins,function(_,skin)return mapping(skin.displays,function(_,items)return list(items,function(x)if x==nil or rawequal(x,Skin.NULL)then return'nil'end;return attrs(x,{'type','name','path','inheritAnimation'})..'/'..attrs(x.transform,transformKeys)..'/'..attrs(x.boundingBox,{'type','color','width','height'})end,'|')end,'/')end,';')
  local animations=mapping(a.animations,function(_,z)return attrs(z,{'name','frameCount','playTimes','duration','fadeInTime','scale','blendType','frameIntOffset','frameFloatOffset','frameOffset'})..'/'..(z.zOrderTimeline and attrs(z.zOrderTimeline,{'type','offset','frameIndicesOffset'})or'nil')end)
  local constraints=mapping(a.constraints,function(_,z)return attrs(z,{'name','type','order','bendPositive','scaleEnabled','weight','position','spacing','rotateOffset','rotateMix','translateMix'})end)
  return table.concat({attrs(a.aabb,{'x','y','width','height'}),bones,slots,displays,animations,constraints,a.defaultAnimation and scalar(a.defaultAnimation.name)or'nil'},'~')
 end,'!')
end
local function execute(r)
 local op,scale=r[1],tonumber(r[3]);local file=assert(io.open(r[2],'rb'));local raw=file:read('*a');file:close()
 if op=='unused-json'then local ok,value=pcall(JSON.parse,raw);return{ok and'ok'or'error',ok and tree(value)or''}end
 local p=op=='json'and ObjectParser.new()or P.new();local buf,old=Shared.new(raw),Shared.new('\0');p._binary=old;p._binaryOffset=99
 local allocated={};local borrow=B.borrowObject;B.borrowObject=function(C)local o=borrow(C);allocated[#allocated+1]=o;return o end
 local result;local ok=pcall(function()result=p:parseDragonBonesData(op=='json'and JSON.parse(raw)or buf,scale)end);B.borrowObject=borrow
 local data=result or p._data
 local function tl(t)if t==nil then return'nil'end;local out={};for _,k in ipairs({'type','offset','frameIndicesOffset','x','y'})do out[#out+1]=scalar(t[k])end;return table.concat(out,',')end
 local function snapshot()
  if data==nil then return'nil'end
  local arms=list(data.armatureNames,function(n)
   local a=data:getArmature(n)
   local skins=mapping(a.skins,function(_,skin)return mapping(skin.displays,function(_,displays)return list(displays,function(x)
    if x==nil or rawequal(x,Skin.NULL)then return'null'end
    local g=x.geometry;local geom=''
    if g then geom=table.concat({scalar(g.offset),scalar(g.vertexCount),g.weight and scalar(g.weight.count)or'none',g.weight and list(g.weight.bones,function(b)return b and scalar(b.name)or'u'end)or''},',')end
    return scalar(x.name)..':'..geom
   end,';')end)end,'/')
   local animations=mapping(a.animations,function(_,z)
    local out={scalar(z.name),scalar(z.duration),tl(z.actionTimeline)}
    for _,m in ipairs({'boneTimelines','slotTimelines','constraintTimelines','animationTimelines'})do out[#out+1]=mapping(z[m],function(n,t)return scalar(n)..'='..list(t,tl,';')end)end
    return table.concat(out,'/')
   end)
   return table.concat({scalar(a.name),scalar(a.scale),list(a.sortedBones,function(b)return scalar(b.name)end),skins,animations},'~')
  end,'!')
  local views={};for _,k in ipairs({'intArray','floatArray','frameIntArray','frameFloatArray','frameArray','timelineArray','colorArray'})do local v=data[k];views[#views+1]=v and table.concat({string.format('%.0f',v.byteOffset),string.format('%.0f',v.byteLength),tostring(v.buffer==buf),tostring(v.buffer==data.binary)},',')or'nil'end
  return table.concat({scalar(data.name),scalar(data.version),scalar(data.frameRate),data.stage and scalar(data.stage.name)or'nil',arms,list(data.frameIndices,scalar),table.concat(views,'|'),tostring(data.binary==buf),tostring(data.colorArray==data.intArray)},'#')
 end
 local extra=details(data);local before=snapshot();local binary=data and data.binary and hex(data.binary:bytes())or'nil'
 if op=='mutate'and data then data.intArray[1]=7;data.timelineArray[1]=250 end
 local cleanup='skip';if result then cleanup=pcall(function()result:returnToPool()end)and'ok'or'error'end
 local pooled={};for _,o in ipairs(allocated)do pooled[#pooled+1]=o.constructor.toString()..':'..(o._isInPool and'1'or'0')end
 return{ok and'ok'or'error',not ok and'undefined'or result and'data'or'null',scalar(p._binaryOffset),p._binary==buf and'new'or p._binary==old and'old'or'other',p._data==nil and'clear'or'retained',p._animation==nil and'clear'or'retained',before,op=='mutate'and snapshot()or'',cleanup,table.concat(pooled,'|'),hex(buf:bytes()),binary,extra}
end
for line in io.lines(assert(arg[1]))do local r={};for v in(line..'\t'):gmatch('(.-)\t')do r[#r+1]=v end;io.write(table.concat(execute(r),'\t'),'\n')end
