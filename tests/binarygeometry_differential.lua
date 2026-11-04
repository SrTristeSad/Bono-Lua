local P=require('dragonbones.parser.BinaryDataParser')
local V=require('dragonbones.parser.JSValue')
local Shared=require('dragonbones.parser.SharedBinaryBuffer')
local B=require('dragonbones.core.BaseObject')
local D=require('dragonbones.model.DragonBonesData')
local M=require('dragonbones.model.ArmatureData')
local G=require('dragonbones.model.DisplayData')
local double
if string.pack then double=function(n)return string.pack('<d',n)end else local ffi=require('ffi');double=function(n)return ffi.string(ffi.new('double[1]',n),8)end end
local function hex(s)return(s:gsub('.',function(c)return string.format('%02x',c:byte())end))end
local function scalar(v)
 if v==nil or rawequal(v,V.UNDEFINED)then return'u'end
 if rawequal(v,V.NULL)then return'null'end
 if type(v)=='number'then return v~=v and'NaN'or'n'..hex(double(v))end
 return tostring(v)
end
local function execute(c)
 local w,vertices,bones,mode=tonumber(c[1]),tonumber(c[2]),tonumber(c[3]),c[4]
 local p,data,g=P.new(),B.borrowObject(D),G.GeometryData.new();g:clear();p._data=data
 for i=0,2 do local bone=B.borrowObject(M.BoneData);bone.name='b'..i;p._rawBones[p._rawBones.length+1]=bone end
 local size=mode=='shortBuffer'and 8 or math.max(40,w+20)
 local buf=Shared.new(string.rep('\0',4+size*2));local view=Shared.view(buf,4,size*2,'int16');p._intArrayBuffer=view;data.intArray=view;data.binary=buf
 view[4]=vertices;view[5]=2;view[7]=w
 if w~=65535 and w<size then view[w+1]=bones;for i=0,bones-1 do view[w+3+i]=i end;local at=w+2+bones;for i=0,vertices-1 do view[at+1]=i%3;at=at+1;for j=0,i%3-1 do view[at+1]=j;at=at+1 end end end
 local old
 if mode=='oldWeight'or mode=='clear'or mode=='shared'or mode=='repeat'or mode=='returnFailure'or mode=='addFailure'then old=B.borrowObject(G.WeightData);old.count=91;old.offset=71;old:addBone(p._rawBones[1]);g.weight=old end
 if mode=='shared'then g.isShared=true end
 local raw={offset=3}
 if mode=='missingBuffer'then p._intArrayBuffer=nil end
 if mode=='missingData'then p._data=nil end
 if mode=='missingOffset'then raw={}end
 if mode=='nullRaw'then raw=V.NULL end
 if mode=='negativeOffset'then raw.offset=-2 end
 if mode=='fractionOffset'then raw.offset=0.5 end
 if mode=='nanOffset'then raw.offset=0/0 end
 if mode=='outsideOffset'then raw.offset=size+10 end
 if mode=='outsideWeight'then view[7]=size+10 end
 if mode=='missingBones'then p._rawBones.length=0 end
 if mode=='holes'then p._rawBones[2]=nil end
 if mode=='badBoneIndex'then view[w+3]=-1 end
 if mode=='duplicateBones'then for i=0,bones-1 do view[w+3+i]=0 end end
 if mode=='negativeBones'then view[w+1]=-1 end
 if mode=='negativeVertices'then view[4]=-1 end
 if mode=='negativeInfluence'then view[w+3+bones]=-1 end
 if mode=='truncatedInfluence'then view[w+3+bones]=32767 end
 local before=buf:bytes();local allocated={};local original=B.borrowObject
 B.borrowObject=function(class)local o=original(class);allocated[#allocated+1]=o;return o end
 local originalAdd=G.WeightData.addBone;local added=0
 if mode=='addFailure'then G.WeightData.addBone=function(self,bone)added=added+1;if added==2 then error('injected add')end;return originalAdd(self,bone)end end
 local ok=pcall(function()p:_parseGeometry(raw,g);if mode=='repeat'then p:_parseGeometry(raw,g)end;if mode=='mutate'then view[7]=-1;p:_parseGeometry(raw,g)end end);B.borrowObject=original;G.WeightData.addBone=originalAdd
 local function weight(o)
  if o==nil then return'nil'end
  local names={};for i=1,math.min(o.bones.length,20)do local bone=o.bones[i];names[#names+1]=(bone==nil or rawequal(bone,V.UNDEFINED))and'u'or rawequal(bone,V.NULL)and'null'or bone.name end
  return scalar(o.offset)..':'..scalar(o.count)..':'..string.format('%.0f',o.bones.length)..':'..table.concat(names,',')
 end
 local weights={};for _,o in ipairs(allocated)do weights[#weights+1]=weight(o)end
 local out={ok and'ok'or'error',scalar(g.offset),g.data==data and'data'or g.data==nil and'null'or'other',weight(g.weight),weight(old),table.concat(weights,'|'),tostring(g.weight~=nil and g.weight==old),tostring(#allocated),tostring(g.isShared)}
 if mode=='returnFailure'and g.weight then g.weight.returnToPool=function()error('injected')end end
 local clear='skip';if mode=='clear'or mode=='shared'or mode=='returnFailure'then clear=pcall(function()g:clear()end)and'ok'or'error'end
 local pooled={};for _,o in ipairs(allocated)do pooled[#pooled+1]=o._isInPool and'1'or'0'end
 for _,v in ipairs({clear,weight(g.weight),tostring(old~=nil and old._isInPool),table.concat(pooled),g.data==nil and'null'or g.data==data and'data'or'other',scalar(g.offset),tostring(g.isShared),tostring(mode=='mutate'and view[7]==-1 or mode~='mutate'and buf:bytes()==before),tostring(view.buffer==buf)})do out[#out+1]=v end
 return table.concat(out,'\t')
end
for line in io.lines(assert(arg[1]))do local c={};for v in(line..'\t'):gmatch('(.-)\t')do c[#c+1]=v end;io.write(execute(c),'\n')end
