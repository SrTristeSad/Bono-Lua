local d,B,classes,objects,labels,lists,listLabels,log,hooks,warnings,ids,nextId,parents,JSArray,points
local stderr=io.stderr
local doubleBytes
if string.pack then doubleBytes=function(v)return string.pack('<d',v) end
else local ffi=require('ffi');doubleBytes=function(v)local b=ffi.string(ffi.new('double[1]',v),8);return ffi.abi('le') and b or b:reverse() end end
local function split(s,sep)local out={};for v in (s..sep):gmatch('(.-)'..sep) do out[#out+1]=v end;return out end
local function keys(t)local out={};for k in pairs(t) do out[#out+1]=k end;table.sort(out);return out end
local function number(s)if s=='NaN' then return 0/0 elseif s=='Infinity' then return math.huge elseif s=='-Infinity' then return -math.huge elseif s=='-0' then return -0.0 end;return assert(tonumber(s))+0.0 end
local function decode(s)if s:sub(1,2)=='s:' then return s:sub(3) elseif s=='true' then return true elseif s=='false' then return false end;return number(s) end
local function scalar(v)
 if v==nil then return 'undefined' elseif type(v)=='boolean' then return v and 'true' or 'false' elseif type(v)~='number' then return 's:'..v elseif v~=v then return 'NaN' end
 return 'n:'..doubleBytes(v):gsub('.',function(c)return string.format('%02x',c:byte()) end)
end
local function integer(n)return string.format('%.0f',n) end
local function ref(o)return o==nil and 'nil' or '#'..integer(o.hashCode) end
local function entry(o)if rawequal(o,classes.S.NULL) then return 'null' elseif o==nil then return 'undefined' end;return ref(o) end
local function identity(o)if not ids[o] then nextId=nextId+1;ids[o]=nextId end;return ids[o] end
local execute
local function fire(k)if hooks[k] then local command=hooks[k];hooks[k]=nil;execute(command) end end
local function value(id)if id=='null' or id=='NULL' then return classes.S.NULL elseif id=='undefined' then return nil end;return objects[id] end
local function begin()
 for _,p in ipairs({'dragonbones.core.BaseObject','dragonbones.core.Enums','dragonbones.model.BoundingBoxData','dragonbones.model.DragonBonesData','dragonbones.model.SkinData','dragonbones.model.DisplayData','dragonbones.model.ArmatureData','dragonbones.model.UserData','dragonbones.model.AnimationData'}) do package.loaded[p]=nil end
 B=require('dragonbones.core.BaseObject');JSArray=require('dragonbones.core.JSArray');local s=require('dragonbones.model.SkinData');local m=require('dragonbones.model.DisplayData');local a=require('dragonbones.model.ArmatureData');local u=require('dragonbones.model.UserData')
 d={GeometryData=m.GeometryData};local boxes=require('dragonbones.model.BoundingBoxData');classes={R=boxes.RectangleBoundingBoxData,E=boxes.EllipseBoundingBoxData,V=boxes.PolygonBoundingBoxData,K=m.BoundingBoxDisplayData,D=require('dragonbones.model.DragonBonesData'),S=s,A=a.ArmatureData,I=m.ImageDisplayData,M=m.MeshDisplayData,P=m.PathDisplayData,C=m.ArmatureDisplayData,W=m.WeightData,Q=u.ActionData,U=u.UserData}
 objects,labels,lists,listLabels,log,hooks,warnings,parents={},{},{},{},{},{},{},{};ids=setmetatable({},{__mode='k'});nextId=0;local Point=require('dragonbones.geom.Point');points={a=Point.new(91,92),b=Point.new(93,94),n=Point.new(95,96)}
end
local equal=function()return true end
execute=function(row)
 local op,a,b,c,e,f=row[1],row[2],row[3],row[4],row[5],row[6]
 if op=='new' or op=='borrow' then
  local o;if op=='new' then o=classes[b].new() else o=B.borrowObject(classes[b]) end;objects[a]=o;labels[a]=true
  if not o._wrapped then o._wrapped=true;local original=o.returnToPool;function o:returnToPool()log[#log+1]='return:'..a;fire('return:'..a);return original(self) end end
  return 'object:'..ref(o)
 elseif op=='set' then objects[a][b]=decode(c)
 elseif op=='add' then
  if c=='omit' or c=='undefined' then objects[a]:addDisplay(b)
  elseif c=='null' then objects[a]:addDisplay(b,nil)
  else objects[a]:addDisplay(b,value(c)) end
 elseif op=='clear' then objects[a]:_onClear()
 elseif op=='return' then objects[a]:returnToPool()
 elseif op=='string' then return 'string:'..classes[a].toString()
 elseif op=='list' then local v=objects[b]:getDisplays(c);lists[a]=v;listLabels[a]=true;return v==nil and 'nil' or 'list:'..identity(v)
 elseif op=='lookup' then local v=objects[b]:getDisplay(c,e);objects[a]=v;labels[a]=true;return v==nil and 'nil' or 'object:'..ref(v)
 elseif op=='mesh' then local v=objects[b]:getMesh(c,e,f);objects[a]=v;labels[a]=true;return v==nil and 'nil' or 'object:'..ref(v)
 elseif op=='pointHook' then
  local o=points[a];local stored=o[b];rawset(o,b,nil);local old=getmetatable(o)
  setmetatable(o,{__index=function(self,key)if key==b then return stored end;return old.__index[key] end,
   __newindex=function(self,key,v)if key==b then stored=v;log[#log+1]='write:'..a..':'..b;fire('write:'..a..':'..b) else rawset(self,key,v) end end})
 elseif op=='contains' then return 'boolean:'..tostring(objects[a]:containsPoint(number(b),number(c)))
 elseif op=='segment' or op=='polygon' then
  local args={};for i=3,6 do args[#args+1]=number(row[i]) end
  local pa,pb,n=points[row[7]],points[row[8]],points[row[9]];local result
  if op=='segment' then result=objects[a]:intersectsSegment(args[1],args[2],args[3],args[4],pa,pb,n)
  else result=classes.V.polygonIntersectsSegment(args[1],args[2],args[3],args[4],objects[a].vertices,pa,pb,n) end
  return 'number:'..scalar(result)
 elseif op=='rect' or op=='ellipse' then
  local args={};for i=2,9 do args[#args+1]=number(row[i]) end
  local method=op=='rect' and classes.R.rectangleIntersectsSegment or classes.E.ellipseIntersectsSegment
  return 'number:'..scalar(method(args[1],args[2],args[3],args[4],args[5],args[6],args[7],args[8],points[row[10]],points[row[11]],points[row[12]]))
 elseif op=='outcode' then return 'number:'..scalar(classes.R._computeOutCode(number(a),number(b),number(c),number(e),number(f),number(row[7])))
 elseif op=='baseClear' then require('dragonbones.model.BoundingBoxData').BoundingBoxData._onClear(objects[a])
 elseif op=='vertices' then local array=objects[a].vertices;array.length=0;for i=3,#row do array[i-2]=number(row[i]) end
 elseif op=='vertex' then local array=objects[a].vertices;if c=='undefined' then rawset(array,number(b)+1,nil) else array[number(b)+1]=number(c) end
 elseif op=='saveVertices' then lists[a]=objects[b].vertices;listLabels[a]=true
 elseif op=='extraVertices' then objects[a].vertices.extra=decode(b)
 elseif op=='addArmature' then objects[a]:addArmature(objects[b])
 elseif op=='addSkin' then objects[a]:addSkin(objects[b])
 elseif op=='link' then objects[a][b]=objects[c]
 elseif op=='geom' then objects[a]=objects[b].geometry;labels[a]=true;return 'geometry:'..identity(objects[a])
 elseif op=='share' then objects[a]:shareFrom(objects[b])
 elseif op=='action' then objects[a]:addAction(objects[b])
 elseif op=='length' then objects[a].vertices.length=number(b)
 elseif op=='write' then objects[a].displays[b][number(c)+1]=value(e)
 elseif op=='deleteKey' then objects[a].displays[b]=nil
 elseif op=='put' then local list=JSArray.new();list[1]=value(c);objects[a].displays[b]=list
 elseif op=='alias' then objects[a].displays[b]=objects[c].displays[e]
 elseif op=='extra' then objects[a].displays[b].extra=decode(c)
 elseif op=='parentHook' then
  local o=objects[a];local state={value=o.parent};parents[o]=state;rawset(o,'parent',nil);local old=getmetatable(o)
  setmetatable(o,{__eq=old.__eq,__index=function(self,key)
   if key=='parent' then return state.value end
   if type(old.__index)=='function' then return old.__index(self,key) end;return old.__index[key]
  end,__newindex=function(self,key,v)
   if key=='parent' then state.value=v;log[#log+1]='parent:'..a..':'..ref(v);fire('parent:'..a)
   elseif old.__newindex then old.__newindex(self,key,v) else rawset(self,key,v) end
  end})
 elseif op=='equal' then local old=getmetatable(objects[a]);setmetatable(objects[a],{__index=old.__index,__newindex=old.__newindex,__eq=equal})
 elseif op=='hook' then local command={};for i=3,#row do command[#command+1]=row[i] end;hooks[a]=command
 elseif op=='throw' then error('callback failure')
 elseif op=='limit' then B.setMaxCount(classes[a],number(b))
 else error('Unknown command '..op) end
 return 'void'
end
local function numericArray(a)
 local id=identity(a);local props={};for k in pairs(a) do props[#props+1]={key=type(k)=='number' and integer(k-1) or k,value=a[k]} end;table.sort(props,function(x,y)return x.key<y.key end);local values={};for _,p in ipairs(props) do values[#values+1]=p.key..'='..scalar(p.value) end
 return id..':'..scalar(a.length)..':'..table.concat(values,',')
end
local function array(a)
 if a==nil then return 'nil' end
 local id=identity(a);local prefix={};for i=1,math.min(a.length,12) do prefix[#prefix+1]=entry(a[i]) end
 local indices={};for k in pairs(a) do if type(k)=='number' and k>=1 and k<=4294967295 and k==math.floor(k) then indices[#indices+1]=k end end;table.sort(indices)
 local values={};for _,k in ipairs(indices) do values[#values+1]=integer(k-1)..'='..entry(a[k]) end
 return id..':'..scalar(a.length)..':prefix='..table.concat(prefix,',')..':defined='..table.concat(values,',')..':extra='..scalar(a.extra)..':nonIndex='..entry(a[4294967296])
end
local function primitive(o,ks)local out={};for _,k in ipairs(ks) do out[#out+1]=scalar(o[k]) end;return identity(o)..':'..table.concat(out,',') end
local function geometry(g)return identity(g)..':'..table.concat({scalar(g.isShared),scalar(g.inheritDeform),scalar(g.offset),ref(g.data),ref(g.weight)},':') end
local function describe(o)
 if o==nil then return 'nil' end
 if getmetatable(o)==d.GeometryData then return 'G:'..geometry(o) end
 local kind;for k,v in pairs(classes) do if rawequal(o.constructor,v) then kind=k;break end end
 local out={kind,ref(o),o._isInPool and '1' or '0'}
 if kind=='R' or kind=='E' or kind=='V' then
  for _,k in ipairs({'type','color','width','height','extra'}) do out[#out+1]=scalar(o[k]) end
  if kind=='V' then out[#out+1]=scalar(o.x);out[#out+1]=scalar(o.y);out[#out+1]=numericArray(o.vertices) end
 elseif kind=='D' then
  out[#out+1]=scalar(o.name);out[#out+1]=ref(o.stage);out[#out+1]=ref(o.userData);local id=identity(o.armatures);local values={};for _,k in ipairs(keys(o.armatures)) do values[#values+1]=k..'='..ref(o.armatures[k]) end;out[#out+1]=id..':'..table.concat(values,';');out[#out+1]=numericArray(o.armatureNames)
 elseif kind=='S' then
  out[#out+1]=scalar(o.name);out[#out+1]=ref(o.parent);out[#out+1]=scalar(o.extra);local id=identity(o.displays);local values={};for _,k in ipairs(keys(o.displays)) do values[#values+1]=k..'='..array(o.displays[k]) end;out[#out+1]=id..':'..table.concat(values,';')
 elseif kind=='A' then
  out[#out+1]=scalar(o.name);out[#out+1]=ref(o.defaultSkin);local id=identity(o.skins);local values={};for _,k in ipairs(keys(o.skins)) do values[#values+1]=k..'='..ref(o.skins[k]) end;out[#out+1]=id..':'..table.concat(values,';')
 elseif kind=='I' or kind=='M' or kind=='P' or kind=='C' or kind=='K' then
  out[#out+1]=scalar(o.type);out[#out+1]=scalar(o.name);out[#out+1]=scalar(o.path);out[#out+1]=ref(o.parent);out[#out+1]=primitive(o.transform,{'x','y','rotation','skew','scaleX','scaleY'})
  if kind=='K' then out[#out+1]=ref(o.boundingBox) end
  if kind=='I' then out[#out+1]=primitive(o.pivot,{'x','y'});out[#out+1]=ref(o.texture) end
  if kind=='M' or kind=='P' then out[#out+1]=geometry(o.geometry) end
  if kind=='P' then out[#out+1]=scalar(o.closed);out[#out+1]=scalar(o.constantSpeed) end
  if kind=='C' then out[#out+1]=scalar(o.inheritAnimation);out[#out+1]=array(o.actions);out[#out+1]=ref(o.armature) end
 elseif kind=='W' then out[#out+1]=scalar(o.count);out[#out+1]=scalar(o.offset);out[#out+1]=array(o.bones)
 elseif kind=='Q' then out[#out+1]=scalar(o.type);out[#out+1]=scalar(o.name);out[#out+1]=ref(o.data)
 elseif kind=='U' then for _,k in ipairs({'ints','floats','strings'}) do local values={};for i,v in ipairs(o[k]) do values[i]=scalar(v) end;out[#out+1]=identity(o[k])..':'..table.concat(values,',') end end
 return table.concat(out,':')
end
local function snapshot()
 local out={scalar(B._hashCode)};local list={}
 for _,k in ipairs(keys(labels)) do list[#list+1]=k..'='..describe(objects[k]) end;out[#out+1]=table.concat(list,'|');list={}
 for _,k in ipairs(keys(listLabels)) do list[#list+1]=k..'='..numericArray(lists[k]) end;out[#out+1]=table.concat(list,'|');list={}
 for _,k in ipairs(keys(B._poolsMap)) do local pool={};for i,o in ipairs(B._poolsMap[k]) do pool[i]=ref(o) end;list[#list+1]=k..'='..table.concat(pool,',') end;out[#out+1]=table.concat(list,'|');list={}
 for _,k in ipairs(keys(B._maxCountMap)) do list[#list+1]=k..'='..scalar(B._maxCountMap[k]) end;out[#out+1]=table.concat(list,'|');out[#out+1]=table.concat(log,'|');list={}
 for _,k in ipairs(keys(hooks)) do list[#list+1]=k..'='..table.concat(hooks[k],',') end;out[#out+1]=table.concat(list,'|');out[#out+1]=table.concat(warnings,'|');for _,p in ipairs({'a','b','n'}) do out[#out+1]=scalar(points[p].x);out[#out+1]=scalar(points[p].y) end;return out
end
io.stderr={write=function(_,s)warnings[#warnings+1]=s:gsub('\n$','') end}
local index=0
for line in io.lines(assert(arg[1])) do
 local row=split(line,'\t');local tag='void'
 if row[1]=='begin' then begin() else warnings={};local ok,v=pcall(execute,row);if ok then tag=v else tag=tostring(v):find('Invalid array length',1,true) and 'range' or 'error' end end
 io.write(tostring(index),'\t',tag,'\t',table.concat(snapshot(),'\t'),'\n');index=index+1
end
io.stderr=stderr
