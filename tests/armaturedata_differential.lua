local d,B,classes,objects,labels,records,storages,matrices,transforms,colors,readers,log,hooks,warnings,ids,nextId,JSArray
local arrays={'animationNames','sortedBones','sortedSlots','defaultActions','actions'}
local maps={'bones','slots','constraints','skins','animations'}
local tfields={'x','y','rotation','skew','scaleX','scaleY'}
local cfields={'alphaMultiplier','redMultiplier','greenMultiplier','blueMultiplier','alphaOffset','redOffset','greenOffset','blueOffset'}
local stderr=io.stderr
local doubleBytes
if string.pack then doubleBytes=function(v)return string.pack('<d',v) end
else local ffi=require('ffi');doubleBytes=function(v)local b=ffi.string(ffi.new('double[1]',v),8);return ffi.abi('le') and b or b:reverse() end end
local function split(s,sep)local out={};for v in (s..sep):gmatch('(.-)'..sep) do out[#out+1]=v end;return out end
local function keys(t)local out={};for k in pairs(t) do out[#out+1]=k end;table.sort(out);return out end
local function number(s)
 if s=='NaN' then return 0/0 elseif s=='Infinity' then return math.huge elseif s=='-Infinity' then return -math.huge elseif s=='-0' then return -0.0 end
 return assert(tonumber(s),'Invalid number')+0.0
end
local function decode(s)if s=='undefined' then return nil elseif s=='true' then return true elseif s=='false' then return false elseif s:sub(1,2)=='s:' then return s:sub(3) end;return number(s) end
local function scalar(v)
 if v==nil then return 'undefined' elseif type(v)=='boolean' then return v and 'true' or 'false' elseif type(v)~='number' then return 's:'..v elseif v~=v then return 'NaN' end
 return 'n:'..doubleBytes(v):gsub('.',function(c)return string.format('%02x',c:byte()) end)
end
local function integer(n)return string.format('%.0f',n) end
local function identity(o)if not ids[o] then nextId=nextId+1;ids[o]=nextId end;return ids[o] end
local function ref(o)if o==nil then return 'nil' elseif o.hashCode~=nil then return '#'..integer(o.hashCode) end;return o.id end
local execute
local function fire(k)if hooks[k] then local command=hooks[k];hooks[k]=nil;execute(command) end end
local function wrap(o,id)
 if o._wrapped then return end;o._wrapped=true;local original=o.returnToPool
 function o:returnToPool()log[#log+1]='return:'..id;fire('return:'..id);return original(self) end
 if o.constructor==classes.D then local cache=o.cacheFrames;function o:cacheFrames(rate)log[#log+1]='cache:'..id..':'..scalar(rate);fire('cache:'..id);return cache(self,rate) end end
end
local function begin()
 for _,p in ipairs({'dragonbones.core.BaseObject','dragonbones.core.Enums','dragonbones.model.ArmatureData','dragonbones.model.AnimationData','dragonbones.model.DisplayData','dragonbones.model.UserData','dragonbones.model.CanvasData'}) do package.loaded[p]=nil end
 B=require('dragonbones.core.BaseObject');JSArray=require('dragonbones.core.JSArray');local a=require('dragonbones.model.ArmatureData');local m=require('dragonbones.model.DisplayData');local n=require('dragonbones.model.AnimationData');local u=require('dragonbones.model.UserData')
 d={Matrix=require('dragonbones.geom.Matrix'),Transform=require('dragonbones.geom.Transform'),GeometryData=m.GeometryData}
 classes={A=a.ArmatureData,B=a.BoneData,S=a.SurfaceData,L=a.SlotData,D=n.AnimationData,U=u.UserData,Q=u.ActionData,C=require('dragonbones.model.CanvasData'),W=m.WeightData,M=m.MeshDisplayData}
 objects,labels,records,storages,matrices,transforms,readers,log,hooks,warnings={},{},{},{},{},{},{},{},{},{};ids=setmetatable({},{__mode='k'});nextId=0;colors={default=classes.L.DEFAULT_COLOR}
end
local equal=function()return true end
execute=function(row)
 local op,a,b,c,e,f=row[1],row[2],row[3],row[4],row[5],row[6]
 if op=='new' or op=='borrow' then local o;if op=='new' then o=classes[b].new() else o=B.borrowObject(classes[b]) end;objects[a]=o;labels[a]=true;wrap(o,a);return 'object:'..ref(o)
 elseif op=='set' then objects[a][b]=decode(c)
 elseif op=='clear' then objects[a]:_onClear()
 elseif op=='return' then objects[a]:returnToPool()
 elseif op=='string' then return 'string:'..classes[a].toString()
 elseif op=='link' then objects[a][b]=c~='none' and (objects[c] or records[c] or storages[c]) or nil
 elseif op=='add' then objects[a]['add'..b](objects[a],objects[c] or records[c])
 elseif op=='get' then local value=objects[b]['get'..c](objects[b],e);objects[a]=value;labels[a]=true;return value==nil and 'nil' or 'object:'..ref(value)
 elseif op=='mesh' then local value=objects[b]:getMesh(c,e,f);objects[a]=value;labels[a]=true;return value==nil and 'nil' or 'object:'..ref(value)
 elseif op=='action' then objects[a]:addAction(objects[b],decode(c))
 elseif op=='sort' then objects[a]:sortBones()
 elseif op=='cache' then objects[a]:cacheFrames(decode(b))
 elseif op=='length' then objects[a][b].length=number(c)
 elseif op=='delete' then objects[a][b][c]=nil
 elseif op=='put' then objects[a][b][c]=objects[e] or records[e]
 elseif op=='hook' then local command={};for i=3,#row do command[#command+1]=row[i] end;hooks[a]=command
 elseif op=='throw' then error('callback failure')
 elseif op=='equal' then local old=getmetatable(objects[a]);setmetatable(objects[a],{__index=old.__index,__newindex=old.__newindex,__eq=equal})
 elseif op=='skin' or op=='constraint' then
  records[a]={id=a,name=b,root=op=='constraint' and objects[c] or nil,target=op=='constraint' and objects[e] or nil,returns=0,displays={},
   returnToPool=function(self)self.returns=self.returns+1;log[#log+1]='return:'..a;fire('return:'..a) end,
   getDisplay=function(self,slot,mesh)log[#log+1]='display:'..a..':'..slot..':'..mesh;fire('display:'..a);return self.displays[slot..':'..mesh] end}
 elseif op=='display' then records[a].displays[b..':'..c]=objects[e]
 elseif op=='geom' then objects[a]=objects[b].geometry;labels[a]=true;return 'geometry:'..identity(objects[a])
 elseif op=='pose' then for i,k in ipairs(tfields) do objects[a].transform[k]=number(row[i+2]) end
 elseif op=='rect' then for i,k in ipairs({'x','y','width','height'}) do objects[a].aabb[k]=number(row[i+2]) end
 elseif op=='color' then colors[a]=classes.L.createColor()
 elseif op=='colorSet' then colors[a][b]=number(c)
 elseif op=='colorLink' then objects[a].color=colors[b]
 elseif op=='storage' then storages[a]={id=a,cachedFrames=JSArray.new()}
 elseif op=='storageLength' then storages[a].cachedFrames.length=number(b)
 elseif op=='matrix' or op=='transform' then
  local target=op=='matrix' and matrices or transforms;target[a]=op=='matrix' and d.Matrix.new() or d.Transform.new();local ks=op=='matrix' and {'a','b','c','d','tx','ty'} or tfields
  if #row>2 then for i,k in ipairs(ks) do target[a][k]=number(row[i+2]) end end
 elseif op=='matrixSet' or op=='transformSet' then local target=op=='matrixSet' and matrices or transforms;target[a][b]=decode(c)
 elseif op=='store' then return scalar(objects[a]:setCacheFrame(matrices[b],transforms[c]))
 elseif op=='load' then objects[a]:getCacheFrame(matrices[b],transforms[c],decode(e))
 elseif op=='readFailure' then
  local o=matrices[a];local value=o[b];readers[o]={key=b,value=value};o[b]=nil
  setmetatable(o,{__index=function(_,key)if key==b then log[#log+1]='read:'..a..':'..b;error('read failure') end;return d.Matrix[key] end})
 elseif op=='limit' then B.setMaxCount(classes[a],number(b))
 else error('Unknown command '..op) end
 return 'void'
end
local function array(a,kind)
 local indices={};for k in pairs(a) do if type(k)=='number' and k>=1 and k<=4294967295 and k==math.floor(k) then indices[#indices+1]=k end end;table.sort(indices)
 local out={};for _,k in ipairs(indices) do out[#out+1]=integer(k-1)..'='..(kind=='ref' and ref(a[k]) or scalar(a[k])) end
 return identity(a)..':'..scalar(a.length)..':'..table.concat(out,',')
end
local function primitive(o,ks)
 if o==nil then return 'nil' end;local reader=readers[o];local out={}
 for _,k in ipairs(ks) do local value;if reader and reader.key==k then value=reader.value else value=o[k] end;out[#out+1]=scalar(value) end
 return identity(o)..':'..table.concat(out,',')
end
local describe
describe=function(o)
 if o==nil then return 'nil' end
 if o.hashCode==nil then
  if getmetatable(o)==d.GeometryData then return 'G:'..identity(o)..':'..table.concat({scalar(o.isShared),scalar(o.inheritDeform),scalar(o.offset),ref(o.data),ref(o.weight)},':') end
  return 'record:'..o.id
 end
 local kind;for k,v in pairs(classes) do if rawequal(o.constructor,v) then kind=k;break end end
 local out={kind,ref(o),o._isInPool and '1' or '0'}
 if kind=='A' then
  for _,k in ipairs({'type','frameRate','cacheFrameRate','scale','name','extra'}) do out[#out+1]=scalar(o[k]) end;out[#out+1]=primitive(o.aabb,{'x','y','width','height'})
  for _,k in ipairs(arrays) do out[#out+1]=array(o[k],k=='animationNames' and 'number' or 'ref') end
  for _,k in ipairs(maps) do local mapId=identity(o[k]);local values={};for _,n in ipairs(keys(o[k])) do values[#values+1]=n..'='..ref(o[k][n]) end;out[#out+1]=mapId..':'..table.concat(values,';') end
  for _,k in ipairs({'defaultSkin','defaultAnimation','canvas','userData','parent'}) do out[#out+1]=ref(o[k]) end
 elseif kind=='B' or kind=='S' then
  for _,k in ipairs({'inheritTranslation','inheritRotation','inheritScale','inheritReflection','type','length','alpha','name','extra'}) do out[#out+1]=scalar(o[k]) end;out[#out+1]=primitive(o.transform,tfields);out[#out+1]=ref(o.userData);out[#out+1]=ref(o.parent)
  if kind=='S' then out[#out+1]=scalar(o.segmentX);out[#out+1]=scalar(o.segmentY);out[#out+1]=describe(o.geometry) end
 elseif kind=='L' then
  for _,k in ipairs({'blendMode','displayIndex','zOrder','zIndex','alpha','name','extra'}) do out[#out+1]=scalar(o[k]) end;out[#out+1]=primitive(o.color,cfields);out[#out+1]=ref(o.userData);out[#out+1]=ref(o.parent)
 elseif kind=='D' then
  for _,k in ipairs({'frameIntOffset','frameFloatOffset','frameOffset','blendType','frameCount','playTimes','duration','scale','fadeInTime','cacheFrameRate','name'}) do out[#out+1]=scalar(o[k]) end;out[#out+1]=ref(o.parent);out[#out+1]=array(o.cachedFrames)
  for _,k in ipairs({'boneCachedFrameIndices','slotCachedFrameIndices'}) do local mapId=identity(o[k]);local values={};for _,n in ipairs(keys(o[k])) do values[#values+1]=n..'='..array(o[k][n]) end;out[#out+1]=mapId..':'..table.concat(values,';') end
 elseif kind=='Q' then out[#out+1]=scalar(o.type);out[#out+1]=scalar(o.name);out[#out+1]=ref(o.data)
 elseif kind=='U' then for _,k in ipairs({'ints','floats','strings'}) do local values={};for i,v in ipairs(o[k]) do values[i]=scalar(v) end;out[#out+1]=identity(o[k])..':'..table.concat(values,',') end
 elseif kind=='C' then for _,k in ipairs({'hasBackground','color','x','y','width','height'}) do out[#out+1]=scalar(o[k]) end
 elseif kind=='W' then out[#out+1]=scalar(o.count);out[#out+1]=scalar(o.offset);out[#out+1]=array(o.bones,'ref')
 elseif kind=='M' then out[#out+1]=scalar(o.type);out[#out+1]=scalar(o.name);out[#out+1]=scalar(o.path);out[#out+1]=primitive(o.transform,tfields);out[#out+1]=describe(o.geometry) end
 return table.concat(out,':')
end
local function snapshot()
 local out={scalar(B._hashCode)};local list={}
 for _,k in ipairs(keys(labels)) do list[#list+1]=k..'='..describe(objects[k]) end;out[#out+1]=table.concat(list,'|');list={}
 for _,k in ipairs(keys(records)) do local r=records[k];local disp={};for _,n in ipairs(keys(r.displays)) do disp[#disp+1]=n..'='..ref(r.displays[n]) end;list[#list+1]=k..'='..r.name..':'..ref(r.parent)..':'..ref(r.root)..':'..ref(r.target)..':'..integer(r.returns)..':'..table.concat(disp,',') end;out[#out+1]=table.concat(list,'|');list={}
 for _,k in ipairs(keys(storages)) do list[#list+1]=k..'='..array(storages[k].cachedFrames) end;out[#out+1]=table.concat(list,'|');list={}
 for _,k in ipairs(keys(matrices)) do list[#list+1]=k..'='..primitive(matrices[k],{'a','b','c','d','tx','ty'}) end;out[#out+1]=table.concat(list,'|');list={}
 for _,k in ipairs(keys(transforms)) do list[#list+1]=k..'='..primitive(transforms[k],tfields) end;out[#out+1]=table.concat(list,'|');list={}
 for _,k in ipairs(keys(colors)) do list[#list+1]=k..'='..primitive(colors[k],cfields) end;out[#out+1]=table.concat(list,'|');list={}
 for _,k in ipairs(keys(B._poolsMap)) do local pool={};for i,o in ipairs(B._poolsMap[k]) do pool[i]=ref(o) end;list[#list+1]=k..'='..table.concat(pool,',') end;out[#out+1]=table.concat(list,'|');list={}
 for _,k in ipairs(keys(B._maxCountMap)) do list[#list+1]=k..'='..scalar(B._maxCountMap[k]) end;out[#out+1]=table.concat(list,'|');out[#out+1]=table.concat(log,'|');list={}
 for _,k in ipairs(keys(hooks)) do list[#list+1]=k..'='..table.concat(hooks[k],',') end;out[#out+1]=table.concat(list,'|');out[#out+1]=table.concat(warnings,'|');return out
end
io.stderr={write=function(_,s)warnings[#warnings+1]=s:gsub('\n$','') end}
local index=0
for line in io.lines(assert(arg[1])) do
 local row=split(line,'\t');local tag='void'
 if row[1]=='begin' then begin() else warnings={};local ok,value=pcall(execute,row);if ok then tag=value else tag=tostring(value):find('Invalid array length',1,true) and 'range' or 'error' end end
 io.write(tostring(index),'\t',tag,'\t',table.concat(snapshot(),'\t'),'\n');index=index+1
end
io.stderr=stderr
