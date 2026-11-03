local Clock,objects,ids,hooks,log,nowMs,reads,fault
local doubleBytes
if string.pack then doubleBytes=function(v) return string.pack('<d',v) end
else
 local ffi=require('ffi') -- test transport only
 doubleBytes=function(v)local data=ffi.new('double[1]',v);local s=ffi.string(data,8);return ffi.abi('le') and s or s:reverse() end
end
local function scalar(n)
 if n~=n then return 'NaN' end
 return (doubleBytes(n):gsub('.',function(c)return string.format('%02x',c:byte()) end))
end
local function number(s)
 if s==nil or s=='undefined' then return nil end
 if s=='NaN' then return 0/0 end
 if s=='Infinity' then return math.huge end
 if s=='-Infinity' then return -math.huge end
 if s=='-0' then return -0.0 end
 return assert(tonumber(s),'Bad fixture number')+0.0
end
local function split(s,sep)
 local out={};for value in (s..sep):gmatch('(.-)'..sep) do out[#out+1]=value end;return out
end
local function keys(t)local out={};for k in pairs(t) do out[#out+1]=k end;table.sort(out);return out end
-- Adapter preflight only: prove that the default remains epoch wall time,
-- rather than silently selecting the monotonic origin of love.timer.
do
 local savedTime,savedLove=os.time,love
 local monotonicCalled=false
 os.time=function()return 1700000000 end
 love={timer={getTime=function()monotonicCalled=true;return 123 end}}
 local DefaultClock=require('dragonbones.animation.WorldClock')
 local instance=DefaultClock.new()
 assert(instance._systemTime==1700000000.0 and not monotonicCalled,'Incorrect default epoch time adapter')
 os.time,love=savedTime,savedLove
end
local function begin()
 package.loaded['dragonbones.animation.WorldClock']=nil
 Clock=require('dragonbones.animation.WorldClock')
 objects,ids,hooks,log={},{},{},{};nowMs,reads,fault=1700000000000.0,0,false
 Clock._now=function()reads=reads+1;if fault then error('host time') end;return nowMs*0.001 end
end
local function ref(o)return o==nil and 'null' or ids[o] or 'null' end -- unknown entry is the private null sentinel
local execute
local equalProbe=function()return true end
local function probe(id,kind)
 local p={kind=kind,calls={}}
 if kind=='linked' then
  setmetatable(p,{
   __index=function(self,key)if key=='clock' then return rawget(self,'_clock') end end,
   __newindex=function(self,key,value)
    if key~='clock' then rawset(self,key,value);return end
    if rawget(self,'_clock')==value then return end
    local old=rawget(self,'_clock');if old~=nil then old:remove(self) end
    rawset(self,'_clock',value);if value~=nil then value:add(self) end
   end
  })
 elseif kind=='equal' then setmetatable(p,{__eq=equalProbe}) end
 p.advanceTime=function(self,dt)
  self.calls[#self.calls+1]=dt;log[#log+1]=id..':'..scalar(dt)
  local actions=hooks[id] or {};hooks[id]={}
  for _,action in ipairs(actions) do execute(action) end
 end
 return p
end
execute=function(row)
 local op,a,b=row[1],row[2],row[3]
 if op=='new' then local c=Clock.new(number(b));objects[a]=c;ids[c]=a;return 'clock:'..a end
 if op=='probe' then local p=probe(a,b);objects[a]=p;ids[p]=a;hooks[a]={};return 'probe:'..a end
 if op=='now' then nowMs=number(a);return 'void' end
 if op=='fault' then fault=a=='true';return 'void' end
 if op=='throw' then error('probe callback') end
 if op=='hook' then
  local action={};for i=3,#row do action[#action+1]=row[i] end
  hooks[a]=hooks[a] or {};hooks[a][#hooks[a]+1]=action;return 'void'
 end
 local obj,value,result=objects[a],b~='none' and objects[b] or nil,nil
 if op=='scale' then obj.timeScale=number(b)
 elseif op=='owner' then obj.clock=value
 elseif op=='add' then result=obj:add(value)
 elseif op=='remove' then result=obj:remove(value)
 elseif op=='clear' then result=obj:clear()
 elseif op=='contains' then result=obj:contains(value)
 elseif op=='advance' then result=obj:advanceTime(number(b))
 else error('Unknown fixture command '..op) end
 if type(result)=='boolean' then return result and 'true' or 'false' end
 assert(result==nil,'Unexpected method return');return 'void'
end
local function snapshot()
 local entries={}
 for _,id in ipairs(keys(objects)) do
  local o=objects[id]
  if getmetatable(o)==Clock then
   local length=o._animatebles.length or #o._animatebles
   local list={};for i=1,length do local v=o._animatebles[i];list[i]=v==nil and 'undefined' or ref(v) end
   entries[#entries+1]=table.concat({id,'clock',scalar(o.time),scalar(o.timeScale),scalar(o._systemTime),ref(o.clock),tostring(length),table.concat(list,',')},':')
  else
   local calls={};for i,dt in ipairs(o.calls) do calls[i]=scalar(dt) end
   entries[#entries+1]=table.concat({id,o.kind,ref(o.clock),table.concat(calls,','),#(hooks[id] or {})},':')
  end
 end
 return {scalar(nowMs),tostring(reads),fault and '1' or '0',table.concat(entries,'|'),table.concat(log,'|')}
end
local input=assert(arg[1],'Input required');local index=0
for line in io.lines(input) do
 local row=split(line,'\t');local tag='void'
 if row[1]=='begin' then begin() else
  log={};local ok,value=pcall(execute,row)
  if ok then tag=value
  elseif tostring(value):find('Invalid array length',1,true) then tag='range-error'
  elseif tostring(value):find('probe callback',1,true) then tag='callback-error'
  elseif tostring(value):find('host time',1,true) then tag='host-error'
  else tag='error' end
 end
 io.write(tostring(index),'\t',tag,'\t',table.concat(snapshot(),'\t'),'\n');index=index+1
end
