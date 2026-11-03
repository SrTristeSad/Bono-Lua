local B,classes,objects,labels,log,hooks,warnings,ids,nextId,JSArray
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
end
local function begin()
 for _,p in ipairs({'dragonbones.core.BaseObject','dragonbones.core.Enums','dragonbones.model.DisplayData','dragonbones.model.UserData','dragonbones.model.TextureAtlasData'}) do package.loaded[p]=nil end
 B=require('dragonbones.core.BaseObject');JSArray=require('dragonbones.core.JSArray');local m=require('dragonbones.model.DisplayData');local u=require('dragonbones.model.UserData');local x=require('dragonbones.model.TextureAtlasData')
 classes={G=m.GeometryData,D=m.DisplayData,I=m.ImageDisplayData,A=m.ArmatureDisplayData,M=m.MeshDisplayData,B=m.BoundingBoxDisplayData,P=m.PathDisplayData,W=m.WeightData,Q=u.ActionData,U=u.UserData,X=x.TextureData}
 objects,labels,log,hooks,warnings={},{},{},{},{};ids=setmetatable({},{__mode='k'});nextId=0
end
execute=function(row)
 local op,a,b,c=row[1],row[2],row[3],row[4]
 if op=='new' or op=='borrow' then
  local o;if op=='new' then o=classes[b].new(classes[b]) else o=B.borrowObject(classes[b]) end;objects[a]=o;labels[a]=true;if o.returnToPool then wrap(o,a) end
  return 'object:'..(o.hashCode==nil and 'geometry:'..identity(o) or ref(o))
 elseif op=='set' then objects[a][b]=decode(c)
 elseif op=='clear' then if getmetatable(objects[a])==classes.G then objects[a]:clear() else objects[a]:_onClear() end
 elseif op=='return' then objects[a]:returnToPool()
 elseif op=='string' then return 'string:'..classes[a].toString()
 elseif op=='link' then objects[a][b]=c~='none' and objects[c] or nil
 elseif op=='geometry' then objects[a]=objects[b].geometry;labels[a]=true;return 'object:geometry:'..identity(objects[a])
 elseif op=='share' then objects[a]:shareFrom(objects[b])
 elseif op=='get' then return scalar(objects[a][b])
 elseif op=='readonly' then objects[a][b]=123
 elseif op=='transform' then for i,k in ipairs({'x','y','rotation','skew','scaleX','scaleY'}) do objects[a].transform[k]=number(row[i+2]) end
 elseif op=='pivot' then objects[a].pivot.x=number(b);objects[a].pivot.y=number(c)
 elseif op=='bone' then objects[a]:addBone(objects[b])
 elseif op=='action' then objects[a]:addAction(objects[b])
 elseif op=='curve' then local arr=objects[a].curveLengths;arr[arr.length+1]=number(b)
 elseif op=='length' then objects[a][b].length=number(c)
 elseif op=='arrayExtra' then objects[a][b].extra=decode(c)
 elseif op=='limit' then B.setMaxCount(classes[a],number(b))
 elseif op=='hook' then local command={};for i=3,#row do command[#command+1]=row[i] end;hooks[a]=command
 elseif op=='throw' then error('callback failure')
 elseif op=='record' then objects[a]={id=a,returns=0,returnToPool=function(self)self.returns=self.returns+1;log[#log+1]='return:'..a;fire('return:'..a) end};labels[a]=true
 elseif op=='data' then local arr=JSArray.new();for i=3,#row do arr[arr.length+1]=number(row[i]) end;objects[a]={id=a,intArray=arr};labels[a]=true
 else error('Unknown command '..op) end
 return 'void'
end
local function array(a,kind)
 local indices={};for k in pairs(a) do if type(k)=='number' and k>=1 and k<=4294967295 and k==math.floor(k) then indices[#indices+1]=k end end;table.sort(indices)
 local out={};for _,k in ipairs(indices) do out[#out+1]=integer(k-1)..'='..(kind=='ref' and ref(a[k]) or scalar(a[k])) end
 return identity(a)..':'..scalar(a.length)..':'..table.concat(out,',')..':'..scalar(a.extra)
end
local function geometry(g)return table.concat({identity(g),scalar(g.isShared),scalar(g.inheritDeform),scalar(g.offset),ref(g.data),ref(g.weight),scalar(g.extra)},':') end
local function primitive(o,fields)local out={};for _,k in ipairs(fields) do out[#out+1]=scalar(o[k]) end;return identity(o)..':'..table.concat(out,',') end
local displays={D=true,I=true,A=true,M=true,B=true,P=true}
local function describe(o)
 if getmetatable(o)==classes.G then return 'G:'..geometry(o) end
 if o.hashCode==nil then return o.intArray and 'data:'..o.id..':'..array(o.intArray) or 'record:'..o.id..':'..integer(o.returns) end
 local kind;for k,v in pairs(classes) do if rawequal(o.constructor,v) then kind=k;break end end
 local out={kind,ref(o),o._isInPool and '1' or '0'}
 if displays[kind] then
  out[#out+1]=scalar(o.type);out[#out+1]=scalar(o.name);out[#out+1]=scalar(o.path);out[#out+1]=primitive(o.transform,{'x','y','rotation','skew','scaleX','scaleY'});out[#out+1]=ref(o.parent);out[#out+1]=scalar(o.extra)
  if kind=='I' then out[#out+1]=primitive(o.pivot,{'x','y'});out[#out+1]=ref(o.texture)
  elseif kind=='A' then out[#out+1]=scalar(o.inheritAnimation);out[#out+1]=array(o.actions,'ref');out[#out+1]=ref(o.armature)
  elseif kind=='M' then out[#out+1]=geometry(o.geometry);out[#out+1]=ref(o.texture)
  elseif kind=='B' then out[#out+1]=ref(o.boundingBox)
  elseif kind=='P' then out[#out+1]=scalar(o.closed);out[#out+1]=scalar(o.constantSpeed);out[#out+1]=geometry(o.geometry);out[#out+1]=array(o.curveLengths) end
 elseif kind=='W' then out[#out+1]=scalar(o.count);out[#out+1]=scalar(o.offset);out[#out+1]=array(o.bones,'ref')
 elseif kind=='Q' then out[#out+1]=scalar(o.type);out[#out+1]=scalar(o.name);out[#out+1]=ref(o.bone);out[#out+1]=ref(o.slot);out[#out+1]=ref(o.data)
 elseif kind=='U' then for _,k in ipairs({'ints','floats','strings'}) do local values={};for i,v in ipairs(o[k]) do values[i]=scalar(v) end;out[#out+1]=identity(o[k])..':'..table.concat(values,',') end
 elseif kind=='X' then out[#out+1]=scalar(o.rotated);out[#out+1]=scalar(o.name);out[#out+1]=primitive(o.region,{'x','y','width','height'});out[#out+1]=ref(o.parent);out[#out+1]=o.frame==nil and 'nil' or primitive(o.frame,{'x','y','width','height'}) end
 return table.concat(out,':')
end
local function snapshot()
 local out={scalar(B._hashCode)};local list={}
 for _,k in ipairs(keys(labels)) do list[#list+1]=k..'='..describe(objects[k]) end;out[#out+1]=table.concat(list,'|');list={}
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
