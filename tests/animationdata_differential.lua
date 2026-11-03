local B,D,T,A,classes,objects,labels,parents,arrays,arrayLabels,log,hooks,warnings,ids,nextId,JSArray
local fields={'frameIntOffset','frameFloatOffset','frameOffset','blendType','frameCount','playTimes','duration','scale','fadeInTime','cacheFrameRate','name'}
local groups={Bone=true,Slot=true,Constraint=true,Animation=true}
local maps={'boneTimelines','slotTimelines','constraintTimelines','animationTimelines','boneCachedFrameIndices','slotCachedFrameIndices'}
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
local function ref(o)return o==nil and 'nil' or '#'..integer(o.hashCode) end
local function identity(o)if not ids[o] then nextId=nextId+1;ids[o]=nextId end;return ids[o] end
local execute
local function fire(k)if hooks[k] then local command=hooks[k];hooks[k]=nil;execute(command) end end
local function begin()
 for _,p in ipairs({'dragonbones.core.BaseObject','dragonbones.core.Enums','dragonbones.model.AnimationData'}) do package.loaded[p]=nil end
 B=require('dragonbones.core.BaseObject');JSArray=require('dragonbones.core.JSArray');local m=require('dragonbones.model.AnimationData');D,T,A=m.AnimationData,m.TimelineData,m.AnimationTimelineData;classes={D=D,T=T,A=A}
 objects,labels,parents,arrays,arrayLabels,log,hooks,warnings={},{},{},{},{},{},{},{};ids=setmetatable({},{__mode='k'});nextId=0
end
local function wrap(o,id)
 if o._wrapped then return end;o._wrapped=true;local original=o.returnToPool
 function o:returnToPool()log[#log+1]='return:'..id;fire('return:'..id);return original(self) end
end
local equal=function()return true end
execute=function(row)
 local op,a,b,c,e=row[1],row[2],row[3],row[4],row[5]
 if op=='new' or op=='borrow' then local o;if op=='new' then o=classes[b].new() else o=B.borrowObject(classes[b]) end;objects[a]=o;labels[a]=true;wrap(o,a);return 'object:'..ref(o)
 elseif op=='set' then objects[a][b]=decode(c)
 elseif op=='add' then objects[a]['add'..b..'Timeline'](objects[a],c,objects[e])
 elseif op=='get' then local value=objects[c]['get'..b..(groups[b] and 'Timelines' or '')](objects[c],e);arrays[a]=value;arrayLabels[a]=true;return value==nil and 'nil' or 'array:'..identity(value)
 elseif op=='link' then objects[a][b]=c~='none' and objects[c] or nil
 elseif op=='clear' then objects[a]:_onClear()
 elseif op=='return' then objects[a]:returnToPool()
 elseif op=='hook' then local command={};for i=3,#row do command[#command+1]=row[i] end;hooks[a]=command
 elseif op=='throw' then error('callback failure')
 elseif op=='equal' then local old=getmetatable(objects[a]);setmetatable(objects[a],{__index=old,__eq=equal})
 elseif op=='deleteKey' then objects[a][b][c]=nil
 elseif op=='putList' then local list=JSArray.new();list[1]=objects[e];objects[a][b][c]=list
 elseif op=='listLength' then objects[a][b][c].length=number(e)
 elseif op=='cachedSet' then objects[a].cachedFrames[number(b)+1]=decode(c)
 elseif op=='arraySet' then arrays[a][number(b)+1]=decode(c)
 elseif op=='limit' then B.setMaxCount(classes[a],number(b))
 elseif op=='cache' then objects[a]:cacheFrames(decode(b))
 elseif op=='parent' then parents[a]={id=a,sortedBones=JSArray.new(),sortedSlots=JSArray.new(),failBone=-1,failSlot=-1}
 elseif op=='parentLink' then objects[a].parent=b~='none' and parents[b] or nil
 elseif op=='member' then
  local p=parents[a];local list=p[b=='Bone' and 'sortedBones' or 'sortedSlots'];local index=list.length
  list[index+1]=setmetatable({_name=c},{__index=function(_,key)
   if key=='name' then log[#log+1]='name:'..a..':'..b..':'..integer(index)..':'..c;if p['fail'..b]==index then error('name failure') end;return c end
  end})
 elseif op=='failName' then parents[a]['fail'..b]=number(c)
 elseif op=='clearMembers' then parents[a][b=='Bone' and 'sortedBones' or 'sortedSlots'].length=0
 elseif op=='membersLength' then parents[a][b=='Bone' and 'sortedBones' or 'sortedSlots'].length=number(c)
 else error('Unknown command '..op) end
 return 'void'
end
local function array(a,kind)
 if a==nil then return 'nil' end
 local indices={};for k in pairs(a) do if type(k)=='number' and k>=1 and k<=4294967295 and k==math.floor(k) then indices[#indices+1]=k end end;table.sort(indices)
 local out={};for _,k in ipairs(indices) do out[#out+1]=integer(k-1)..'='..(kind=='timeline' and ref(a[k]) or scalar(a[k])) end
 return identity(a)..':'..scalar(a.length)..':'..table.concat(out,',')
end
local function describe(o)
 local out={o.constructor==D and 'D' or o.constructor==A and 'A' or 'T',ref(o),o._isInPool and '1' or '0'}
 if o.constructor==D then
  for _,k in ipairs(fields) do out[#out+1]=scalar(o[k]) end
  out[#out+1]=o.parent==nil and 'nil' or o.parent.id;out[#out+1]=ref(o.actionTimeline);out[#out+1]=ref(o.zOrderTimeline);out[#out+1]=array(o.cachedFrames)
  for _,k in ipairs(maps) do
   local mapId=identity(o[k]);local entries={};for _,n in ipairs(keys(o[k])) do entries[#entries+1]=n..'='..array(o[k][n],k:sub(-9)=='Timelines' and 'timeline' or 'number') end
   out[#out+1]=mapId..':'..table.concat(entries,';')
  end
 else for _,k in ipairs({'type','offset','frameIndicesOffset','x','y'}) do out[#out+1]=scalar(o[k]) end end
 return table.concat(out,':')
end
local function snapshot()
 local out={scalar(B._hashCode)};local list={}
 for _,k in ipairs(keys(labels)) do list[#list+1]=k..'='..describe(objects[k]) end;out[#out+1]=table.concat(list,'|');list={}
 for _,k in ipairs(keys(arrayLabels)) do list[#list+1]=k..'='..array(arrays[k],(k:match('^found') or k:match('^missing') or k=='lookup') and 'timeline' or 'number') end;out[#out+1]=table.concat(list,'|');list={}
 for _,k in ipairs(keys(parents)) do local p=parents[k];list[#list+1]=k..'='..identity(p.sortedBones)..':'..integer(p.sortedBones.length)..':'..identity(p.sortedSlots)..':'..integer(p.sortedSlots.length)..':'..integer(p.failBone)..':'..integer(p.failSlot) end;out[#out+1]=table.concat(list,'|');list={}
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
