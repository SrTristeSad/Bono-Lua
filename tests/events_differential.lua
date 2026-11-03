-- Transport/probes only; algorithms are required from product modules.
local B,D,E,U,A,engine,objects,arms,labels,log,hooks,warnings,infos,arrayIds,nextArray,manager
local originalPrint,originalStderr=print,io.stderr
local doubleBytes
if string.pack then doubleBytes=function(v)return string.pack('<d',v) end
else local ffi=require('ffi');doubleBytes=function(v)local b=ffi.string(ffi.new('double[1]',v),8);return ffi.abi('le') and b or b:reverse() end end
local function split(s,sep)local out={};for v in (s..sep):gmatch('(.-)'..sep) do out[#out+1]=v end;return out end
local function keys(t)local out={};for k in pairs(t) do out[#out+1]=k end;table.sort(out);return out end
local function number(s)
 if s=='NaN' then return 0/0 elseif s=='Infinity' then return math.huge elseif s=='-Infinity' then return -math.huge elseif s=='-0' then return -0.0 end
 return assert(tonumber(s),'Invalid number '..tostring(s))+0.0
end
local function decode(s)if s=='undefined' then return nil elseif s:sub(1,2)=='s:' then return s:sub(3) end;return number(s) end
local function scalar(v)
 if v==nil then return 'undefined' elseif type(v)=='boolean' then return v and 'true' or 'false' elseif type(v)~='number' then return 's:'..v elseif v~=v then return 'NaN' end
 return 'n:'..doubleBytes(v):gsub('.',function(c)return string.format('%02x',c:byte()) end)
end
local function ref(o)if o==nil then return 'nil' elseif o.hashCode~=nil then return '#'..string.format('%.0f',o.hashCode) end;return o.id end
local execute
local function fire(k)local command=hooks[k];if command then hooks[k]=nil;execute(command) end end
local function wrap(o,id)
 local original=o.returnToPool
 function o:returnToPool()log[#log+1]='return:'..id;fire('return:'..id);return original(self) end
end
local function begin()
 for _,p in ipairs({'dragonbones.core.BaseObject','dragonbones.core.DragonBones','dragonbones.core.Enums','dragonbones.event.EventObject','dragonbones.animation.WorldClock','dragonbones.model.UserData'}) do package.loaded[p]=nil end
 B=require('dragonbones.core.BaseObject');local W=require('dragonbones.animation.WorldClock');W._now=function()return 1700000000000*0.001 end
 D=require('dragonbones.core.DragonBones');E=require('dragonbones.event.EventObject');local m=require('dragonbones.model.UserData');U,A=m.UserData,m.ActionData
 log,hooks,warnings,infos,objects,arms,labels={},{},{},{},{},{},{};arrayIds=setmetatable({},{__mode='k'});nextArray=0
 manager={dispatchDBEvent=function(_,kind,e)log[#log+1]='manager:'..kind..':'..ref(e);fire('manager') end};engine=D.new(manager)
 engine.clock:add({advanceTime=function(_,dt)log[#log+1]='tick:'..scalar(dt);fire('tick') end})
end
local equal=function()return true end
execute=function(row)
 local op,a,b,c=row[1],row[2],row[3],row[4];local classes={E=E,U=U,A=A}
 if op=='borrow' or op=='new' then
  local value;if op=='borrow' then value=B.borrowObject(classes[b]) else value=classes[b].new() end
  objects[a]=value;labels[a]=true;if not value._wrapped then wrap(value,a);value._wrapped=true end;return 'object:'..ref(value)
 elseif op=='arm' then
  arms[a]={id='arm:'..a,_armatureData={},eventDispatcher={dispatchDBEvent=function(_,kind,e)log[#log+1]='dispatch:'..a..':'..kind..':'..ref(e);fire('dispatch:'..a) end},
   getBone=function(_,name)log[#log+1]='bone:'..a..':'..name;fire('bone:'..a);if name~='missing' then return {id='bone:'..a..':'..name} end end,
   getSlot=function(_,name)log[#log+1]='slot:'..a..':'..name;fire('slot:'..a);if name~='missing' then return {id='slot:'..a..':'..name} end end}
 elseif op=='probe' then objects[a]=setmetatable({id=a,returnToPool=function()log[#log+1]='return:'..a;fire('return:'..a) end},{__eq=equal});labels[a]=true
 elseif op=='equal' then local old=getmetatable(objects[a]);setmetatable(objects[a],{__index=old,__eq=equal})
 elseif op=='hook' then local command={};for i=3,#row do command[#command+1]=row[i] end;hooks[a]=command
 elseif op=='throw' then error('callback failure')
 elseif op=='dispose' then arms[a]._armatureData=nil
 elseif op=='revive' then arms[a]._armatureData={}
 elseif op=='set' then objects[a][b]=decode(c)
 elseif op=='link' then objects[a][b]=c~='none' and (objects[c] or arms[c]) or nil
 elseif op=='bone' or op=='slot' then objects[a][op]=b~='none' and {name=b} or nil
 elseif op=='convert' then E.actionDataToInstance(objects[a],objects[b],arms[c])
 elseif op=='bufferEvent' or op=='bufferObject' then engine[op](engine,objects[a])
 elseif op=='tick' then engine:advanceTime(number(a))
 elseif op=='return' then objects[a]:returnToPool()
 elseif op=='clear' then objects[a]:_onClear()
 elseif op=='limit' then B.setMaxCount(classes[a],number(b))
 elseif op=='manager' then engine._eventManager=a=='on' and manager or nil
 elseif op=='readonly' then engine[a]={}
 elseif op=='addInt' or op=='addFloat' or op=='addString' then objects[a][op](objects[a],decode(b))
 elseif op=='getInt' or op=='getFloat' or op=='getString' then return scalar(objects[a][op](objects[a],decode(b)))
 else error('Unknown command '..op) end
 return 'void'
end
local function array(a)
 if not arrayIds[a] then nextArray=nextArray+1;arrayIds[a]=nextArray end
 local out={};for i,v in ipairs(a) do out[i]=scalar(v) end
 return arrayIds[a]..'['..table.concat(out,',')..']'
end
local function describe(o)
 if o==nil then return 'nil' elseif o.hashCode==nil then return 'probe:'..o.id end
 local out={o.constructor==U and 'U' or o.constructor==A and 'A' or 'E',ref(o),o._isInPool and '1' or '0'}
 if o.constructor==U then out[#out+1]=array(o.ints);out[#out+1]=array(o.floats);out[#out+1]=array(o.strings)
 elseif o.constructor==A then out[#out+1]=scalar(o.type);out[#out+1]=scalar(o.name);out[#out+1]=o.bone and o.bone.name or 'nil';out[#out+1]=o.slot and o.slot.name or 'nil';out[#out+1]=ref(o.data)
 else
  for _,k in ipairs({'time','type','name'}) do out[#out+1]=scalar(o[k]) end
  for _,k in ipairs({'armature','bone','slot','animationState','actionData','data'}) do out[#out+1]=ref(o[k]) end
 end
 return table.concat(out,':')
end
local function refs(a)local out={};for i,v in ipairs(a) do out[i]=ref(v) end;return table.concat(out,',') end
local function snapshot()
 local statics={D.VERSION,tostring(D.yDown),tostring(D.debug),tostring(D.debugDraw),tostring(rawequal(engine.clock,engine._clock)),tostring(rawequal(engine.eventManager,engine._eventManager)),engine.eventManager==nil and 'nil' or 'manager'}
 for _,k in ipairs({'START','LOOP_COMPLETE','COMPLETE','FADE_IN','FADE_IN_COMPLETE','FADE_OUT','FADE_OUT_COMPLETE','FRAME_EVENT','SOUND_EVENT'}) do statics[#statics+1]=E[k] end
 local out={table.concat(statics,','),scalar(B._hashCode),scalar(engine.clock.time),refs(engine._objects),refs(engine._events)};local list={}
 for _,k in ipairs(keys(labels)) do list[#list+1]=k..'='..describe(objects[k]) end;out[#out+1]=table.concat(list,'|');list={}
 for _,k in ipairs(keys(arms)) do list[#list+1]=k..'='..(arms[k]._armatureData==nil and 'disposed' or 'live') end;out[#out+1]=table.concat(list,'|');list={}
 for _,k in ipairs(keys(B._poolsMap)) do list[#list+1]=k..'='..refs(B._poolsMap[k]) end;out[#out+1]=table.concat(list,'|');out[#out+1]=table.concat(log,'|');list={}
 for _,k in ipairs(keys(hooks)) do list[#list+1]=k..'='..table.concat(hooks[k],',') end
 out[#out+1]=table.concat(list,'|');out[#out+1]=table.concat(warnings,'|');out[#out+1]=table.concat(infos,'|'):gsub('\n','~');return out
end
print=function(s)infos[#infos+1]=s end
io.stderr={write=function(_,s)warnings[#warnings+1]=s:gsub('\n$','') end}
local index=0
for line in io.lines(assert(arg[1])) do
 local row=split(line,'\t');local tag='void'
 if row[1]=='begin' then begin() else warnings={};local ok,value=pcall(execute,row);tag=ok and value or 'error' end
 io.write(tostring(index),'\t',tag,'\t',table.concat(snapshot(),'\t'),'\n');index=index+1
end
local filename=arg[-1]:match('([^/]+)$')
local output=assert(io.open('artifacts/events-'..filename..'-enums.tsv','w'))
local enums=require('dragonbones.core.Enums')
for _,k in ipairs(keys(enums)) do for _,n in ipairs(keys(enums[k])) do output:write(k,'\t',n,'\t',tostring(enums[k][n]),'\n') end end
output:close();print=originalPrint;io.stderr=originalStderr
