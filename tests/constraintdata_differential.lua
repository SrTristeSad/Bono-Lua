local d,B,classes,objects,labels,log,hooks,warnings,ids,nextId,JSArray
local baseFields={'order','name','type'};local ikFields={'scaleEnabled','bendPositive','weight'}
local pathFields={'positionMode','spacingMode','rotateMode','position','spacing','rotateOffset','rotateMix','translateMix'}
local stderr=io.stderr
local doubleBytes
if string.pack then doubleBytes=function(v)return string.pack('<d',v) end
else local ffi=require('ffi');doubleBytes=function(v)local b=ffi.string(ffi.new('double[1]',v),8);return ffi.abi('le') and b or b:reverse() end end
local function split(s,sep)local out={};for v in (s..sep):gmatch('(.-)'..sep) do out[#out+1]=v end;return out end
local function keys(t)local out={};for k in pairs(t) do out[#out+1]=k end;table.sort(out);return out end
local function number(s)if s=='NaN' then return 0/0 elseif s=='Infinity' then return math.huge elseif s=='-Infinity' then return -math.huge elseif s=='-0' then return -0.0 end;return assert(tonumber(s))+0.0 end
local function decode(s)if s=='true' then return true elseif s=='false' then return false elseif s:sub(1,2)=='s:' then return s:sub(3) end;return number(s) end
local function scalar(v)
 if v==nil then return 'undefined' elseif type(v)=='boolean' then return v and 'true' or 'false' elseif type(v)~='number' then return 's:'..v elseif v~=v then return 'NaN' end
 return 'n:'..doubleBytes(v):gsub('.',function(c)return string.format('%02x',c:byte()) end)
end
local function integer(n)return string.format('%.0f',n) end
local function ref(o)return o==nil and 'nil' or '#'..integer(o.hashCode) end
local function identity(o)if not ids[o] then nextId=nextId+1;ids[o]=nextId end;return ids[o] end
local execute
local function fire(k)if hooks[k] then local command=hooks[k];hooks[k]=nil;execute(command) end end
local function begin()
 for _,p in ipairs({'dragonbones.core.BaseObject','dragonbones.core.Enums','dragonbones.model.ConstraintData','dragonbones.model.ArmatureData','dragonbones.model.DisplayData'}) do package.loaded[p]=nil end
 B=require('dragonbones.core.BaseObject');JSArray=require('dragonbones.core.JSArray');local c=require('dragonbones.model.ConstraintData');local a=require('dragonbones.model.ArmatureData');local m=require('dragonbones.model.DisplayData')
 d={GeometryData=m.GeometryData};classes={C=c.ConstraintData,I=c.IKConstraintData,P=c.PathConstraintData,A=a.ArmatureData,B=a.BoneData,S=a.SurfaceData,L=a.SlotData,H=m.PathDisplayData,W=m.WeightData}
 objects,labels,log,hooks,warnings={},{},{},{},{};ids=setmetatable({},{__mode='k'});nextId=0
end
execute=function(row)
 local op,a,b,c=row[1],row[2],row[3],row[4]
 if op=='new' or op=='borrow' then
  local o;if op=='new' then o=classes[b].new() else o=B.borrowObject(classes[b]) end;objects[a]=o;labels[a]=true
  if not o._wrapped then o._wrapped=true;local original=o.returnToPool;function o:returnToPool()log[#log+1]='return:'..a;fire('return:'..a);return original(self) end end
  return 'object:'..ref(o)
 elseif op=='set' then objects[a][b]=decode(c)
 elseif op=='link' then objects[a][b]=objects[c]
 elseif op=='clear' then objects[a]:_onClear()
 elseif op=='return' then objects[a]:returnToPool()
 elseif op=='string' then return 'string:'..classes[a].toString()
 elseif op=='append' then objects[a]:AddBone(objects[b])
 elseif op=='wrongCase' then objects[a]:addBone(objects[b])
 elseif op=='length' then objects[a].bones.length=number(b)
 elseif op=='alias' then objects[a].bones=objects[b].bones
 elseif op=='extra' then objects[a].bones.extra=decode(b)
 elseif op=='addBone' or op=='addConstraint' then objects[a][op](objects[a],objects[b])
 elseif op=='sort' then objects[a]:sortBones()
 elseif op=='geom' then objects[a]=objects[b].geometry;labels[a]=true;return 'geometry:'..identity(objects[a])
 elseif op=='hook' then local command={};for i=3,#row do command[#command+1]=row[i] end;hooks[a]=command
 elseif op=='throw' then error('callback failure')
 elseif op=='limit' then B.setMaxCount(classes[a],number(b))
 else error('Unknown command '..op) end
 return 'void'
end
local function array(a)
 local indices={};for k in pairs(a) do if type(k)=='number' and k>=1 and k<=4294967295 and k==math.floor(k) then indices[#indices+1]=k end end;table.sort(indices)
 local out={};for _,k in ipairs(indices) do out[#out+1]=integer(k-1)..'='..ref(a[k]) end
 return identity(a)..':'..scalar(a.length)..':'..table.concat(out,',')..':extra='..scalar(a.extra)..':nonIndex='..ref(a[4294967296])
end
local function primitive(o)local out={};for _,k in ipairs({'x','y','rotation','skew','scaleX','scaleY'}) do out[#out+1]=scalar(o[k]) end;return identity(o)..':'..table.concat(out,',') end
local function geometry(g)return identity(g)..':'..table.concat({scalar(g.isShared),scalar(g.inheritDeform),scalar(g.offset),ref(g.data),ref(g.weight)},':') end
local function describe(o)
 if getmetatable(o)==d.GeometryData then return 'G:'..geometry(o) end
 local kind;for k,v in pairs(classes) do if rawequal(o.constructor,v) then kind=k;break end end
 local out={kind,ref(o),o._isInPool and '1' or '0'}
 if kind=='C' or kind=='I' or kind=='P' then
  for _,k in ipairs(baseFields) do out[#out+1]=scalar(o[k]) end;for _,k in ipairs({'target','root','bone'}) do out[#out+1]=ref(o[k]) end;out[#out+1]=scalar(o.extra)
  if kind=='I' then for _,k in ipairs(ikFields) do out[#out+1]=scalar(o[k]) end end
  if kind=='P' then out[#out+1]=ref(o.pathSlot);out[#out+1]=ref(o.pathDisplayData);out[#out+1]=array(o.bones);for _,k in ipairs(pathFields) do out[#out+1]=scalar(o[k]) end end
 elseif kind=='A' then
  out[#out+1]=scalar(o.name);out[#out+1]=array(o.sortedBones);out[#out+1]=array(o.sortedSlots)
  for _,k in ipairs({'bones','constraints'}) do local id=identity(o[k]);local entries={};for _,n in ipairs(keys(o[k])) do entries[#entries+1]=n..'='..ref(o[k][n]) end;out[#out+1]=id..':'..table.concat(entries,',') end
 elseif kind=='B' or kind=='S' then
  for _,k in ipairs({'type','name','length','alpha'}) do out[#out+1]=scalar(o[k]) end;out[#out+1]=ref(o.parent);out[#out+1]=ref(o.userData);out[#out+1]=primitive(o.transform)
  if kind=='S' then out[#out+1]=scalar(o.segmentX);out[#out+1]=scalar(o.segmentY);out[#out+1]=geometry(o.geometry) end
 elseif kind=='L' then out[#out+1]=scalar(o.name);out[#out+1]=scalar(o.alpha);out[#out+1]=ref(o.parent);out[#out+1]=ref(o.userData)
 elseif kind=='H' then out[#out+1]=scalar(o.type);out[#out+1]=scalar(o.name);out[#out+1]=scalar(o.path);out[#out+1]=primitive(o.transform);out[#out+1]=geometry(o.geometry);out[#out+1]=scalar(o.closed);out[#out+1]=scalar(o.constantSpeed)
 elseif kind=='W' then out[#out+1]=scalar(o.count);out[#out+1]=scalar(o.offset);out[#out+1]=array(o.bones) end
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
