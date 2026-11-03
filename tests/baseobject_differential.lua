-- Test-only subclasses and observation protocol. Pool behavior comes solely
-- from dragonbones/core/BaseObject.lua, not from test doubles.
local Base, classes, objects, warnings, trace, serial
local originalStderr = io.stderr
local function split(s,sep)
  local out={}
  for value in (s..sep):gmatch('(.-)'..sep) do out[#out+1]=value end
  return out
end
local function number(s)
  if s=='NaN' then return 0/0 end
  if s=='Infinity' then return math.huge end
  if s=='-Infinity' then return -math.huge end
  if s=='-0' then return -0.0 end
  return assert(tonumber(s),'Invalid test number')+0.0
end
local function encode(n)
  if n==nil then return 'undefined' end
  if n~=n then return 'NaN' end
  if n==math.huge then return 'Infinity' end
  if n==-math.huge then return '-Infinity' end
  if n==0 and 1/n==-math.huge then return '-0' end
  return string.format('%.17g',n)
end
local function sortedKeys(t)
  local keys={};for k in pairs(t) do keys[#keys+1]=k end
  table.sort(keys);return keys
end
local function clearHook(self)
  self.clears=self.clears+1;self.value=0;trace[#trace+1]=self.serial
  if self.failClear then error('clear callback') end
  if self.child then local child=self.child;self.child=nil;child:returnToPool() end
end
local function begin()
  package.loaded['dragonbones.core.BaseObject']=nil
  Base=require('dragonbones.core.BaseObject')
  classes,objects,warnings,trace,serial={},{},{},{},0
  for _,pair in ipairs({{'A','[test.A]'},{'B','[test.B]'},{'C','[test.C]'},
      {'Alias','[test.A]'},{'I2','2'},{'I10','10'},{'Missing'}}) do
    local name,key=pair[1],pair[2]
    local C={label=name};C.__index=C;setmetatable(C,{__index=Base})
    if key then C.toString=function() return key end end
    C._onClear=clearHook
    C.new=function()
      local self=Base.new(C);serial=serial+1
      self.serial,self.createdAs,self.clears,self.value=serial,name,0,123
      return self
    end
    classes[name]=C
  end
  local D={label='Derived'};D.__index=D;setmetatable(D,{__index=classes.A})
  D.new=function()
    local self=Base.new(D);serial=serial+1
    self.serial,self.createdAs,self.clears,self.value=serial,'A',0,123
    return self
  end
  classes.Derived=D
end
local function snapshot()
  local out={encode(Base._hashCode),encode(Base._defaultMaxCount),tostring(serial)}
  local list={}
  for _,id in ipairs(sortedKeys(objects)) do
    local o=objects[id]
    list[#list+1]=table.concat({id,o.serial,o.createdAs,o.constructor.label,encode(o.hashCode),
      o._isInPool and '1' or '0',o.clears,encode(o.value),o.failClear and '1' or '0',
      o.child and o.child.serial or 'none'},':')
  end
  out[#out+1]=table.concat(list,';');list={}
  for _,key in ipairs(sortedKeys(Base._poolsMap)) do
    local ids={};for i,o in ipairs(Base._poolsMap[key]) do ids[i]=o.serial end
    list[#list+1]=key..':'..table.concat(ids,',')
  end
  out[#out+1]=table.concat(list,';');list={}
  for _,key in ipairs(sortedKeys(Base._maxCountMap)) do list[#list+1]=key..':'..encode(Base._maxCountMap[key]) end
  out[#out+1]=table.concat(list,';')
  out[#out+1]=table.concat(warnings,';');out[#out+1]=table.concat(trace,',')
  return out
end
io.stderr={write=function(_,message) warnings[#warnings+1]=message:gsub('\n$','') end}
local input=assert(arg[1],'Input required')
local index=0
for line in io.lines(input) do
  local row=split(line,'\t');local op,a,b=row[1],row[2],row[3]
  local tag='void'
  if op=='begin' then begin()
  else
    warnings,trace={},{}
    local ok,result=pcall(function()
      if op=='borrow' then local o=Base.borrowObject(classes[b]);objects[a]=o;return o
      elseif op=='new' then local o=classes[b].new();objects[a]=o;return o
      elseif op=='return' then return objects[a]:returnToPool()
      elseif op=='direct' then return Base._returnObject(objects[a])
      elseif op=='set' then return Base.setMaxCount(a~='*' and classes[a] or nil,number(b))
      elseif op=='clear' then return Base.clearPool(a~='*' and classes[a] or nil)
      elseif op=='abstract' then return Base.toString()
      elseif op=='value' then objects[a].value=number(b)
      elseif op=='child' then objects[a].child=objects[b]
      elseif op=='fail' then objects[a].failClear=b=='true'
      elseif op=='constructor' then objects[a].constructor=classes[b]
      elseif op=='key' then classes[a].toString=function() return b end
      elseif op=='receiverKey' then classes[a].toString=function(C) return '[dynamic.'..C.label..']' end
      elseif op=='seed' then Base._hashCode=number(a)
      elseif op=='bulk' then
        local list={};for i=1,number(b) do list[i]=Base.borrowObject(classes[a]) end
        objects.bulkFirst,objects.bulkLast=list[1],list[#list]
        for _,o in ipairs(list) do o:returnToPool() end
      else error('Unknown test command '..op) end
    end)
    if not ok then
      if tostring(result):find('Invalid array length',1,true) then tag='range'
      elseif tostring(result):find('clear callback',1,true) then tag='clear-error'
      else tag='error' end
    elseif result~=nil then tag='object:'..result.serial end
  end
  local values=snapshot()
  io.write(tostring(index),'\t',tag,'\t',table.concat(values,'\t'),'\n')
  index=index+1
end
io.stderr=originalStderr
