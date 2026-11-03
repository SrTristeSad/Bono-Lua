local B,C,objects,labels,warnings,readers,reads,arrayIds,nextArray
local fields={'pauseFadeOut','fadeOutMode','fadeOutTweenType','fadeOutTime','pauseFadeIn','actionEnabled','additive','displayControl','resetToPose','fadeInTweenType','playTimes','layer','position','duration','timeScale','weight','fadeInTime','autoFadeOutTime','name','animation','group'}
local fieldSet={boneMask=true};for _,k in ipairs(fields) do fieldSet[k]=true end
local stderr=io.stderr
local doubleBytes
if string.pack then doubleBytes=function(v)return string.pack('<d',v) end
else local ffi=require('ffi');doubleBytes=function(v)local b=ffi.string(ffi.new('double[1]',v),8);return ffi.abi('le') and b or b:reverse() end end
local function split(s,sep)local out={};for v in (s..sep):gmatch('(.-)'..sep) do out[#out+1]=v end;return out end
local function keys(t)local out={};for k in pairs(t) do out[#out+1]=k end;table.sort(out);return out end
local function number(s)
 if s=='NaN' then return 0/0 elseif s=='Infinity' then return math.huge elseif s=='-Infinity' then return -math.huge elseif s=='-0' then return -0.0 end
 return assert(tonumber(s),'Invalid fixture number')+0.0
end
local function decode(s)
 if s=='undefined' then return nil elseif s=='true' then return true elseif s=='false' then return false elseif s:sub(1,2)=='s:' then return s:sub(3) end;return number(s)
end
local function scalar(v)
 if v==nil then return 'undefined' elseif type(v)=='boolean' then return v and 'true' or 'false' elseif type(v)~='number' then return 's:'..v elseif v~=v then return 'NaN' end
 return 'n:'..doubleBytes(v):gsub('.',function(c)return string.format('%02x',c:byte()) end)
end
local function ref(o)return '#'..string.format('%.0f',o.hashCode) end
local function field(o,k)local r=readers[o];if r then return r.values[k] end;return o[k] end
local function begin()
 for _,p in ipairs({'dragonbones.core.BaseObject','dragonbones.core.Enums','dragonbones.model.AnimationConfig'}) do package.loaded[p]=nil end
 B=require('dragonbones.core.BaseObject');C=require('dragonbones.model.AnimationConfig');objects,labels,warnings,readers,reads={},{},{},{},{};arrayIds=setmetatable({},{__mode='k'});nextArray=0
end
local function execute(row)
 local op,a,b,c=row[1],row[2],row[3],row[4]
 if op=='new' or op=='borrow' then
  local o;if op=='new' then o=C.new() else o=B.borrowObject(C) end;objects[a]=o;labels[a]=true;return 'object:'..ref(o)
 elseif op=='set' then objects[a][b]=decode(c)
 elseif op=='append' then local mask=objects[a].boneMask;mask[mask.length+1]=decode(b)
 elseif op=='maskSet' then objects[a].boneMask[number(b)+1]=decode(c)
 elseif op=='maskDelete' then rawset(objects[a].boneMask,number(b)+1,nil) -- JS delete never extends length
 elseif op=='maskExtra' then objects[a].boneMask.extra=decode(b)
 elseif op=='length' then objects[a].boneMask.length=number(b)
 elseif op=='alias' then objects[a].boneMask=objects[b].boneMask
 elseif op=='copy' then objects[a]:copyFrom(objects[b])
 elseif op=='clear' then objects[a]:clear()
 elseif op=='return' then objects[a]:returnToPool()
 elseif op=='limit' then B.setMaxCount(C,number(a))
 elseif op=='clearPool' then B.clearPool(C)
 elseif op=='string' then return 'string:'..C.toString()
 elseif op=='reader' then
  local o=objects[a];local values={};for _,k in ipairs(fields) do values[k]=o[k];o[k]=nil end;values.boneMask=o.boneMask;o.boneMask=nil
  local state={values=values,count=0};readers[o]=state
  setmetatable(o,{__index=function(_,k)
   if fieldSet[k] then reads[#reads+1]=a..'.'..k;state.count=state.count+1;if state.count==number(b) then error('read failure') end;return values[k] end
   return C[k]
  end})
 else error('Unknown test command '..op) end
 return 'void'
end
local function mask(a)
 if not arrayIds[a] then nextArray=nextArray+1;arrayIds[a]=nextArray end
 local indices={};for k,v in pairs(a) do if type(k)=='number' and k>=1 and k<=4294967295 and k==math.floor(k) then indices[#indices+1]=k end end;table.sort(indices)
 local entries={};for _,k in ipairs(indices) do entries[#entries+1]=string.format('%.0f',k-1)..'='..scalar(a[k]) end
 return table.concat({arrayIds[a],scalar(a.length),table.concat(entries,','),scalar(a.extra)},':')
end
local function describe(o)
 local out={ref(o),o._isInPool and '1' or '0'};for _,k in ipairs(fields) do out[#out+1]=scalar(field(o,k)) end
 out[#out+1]=scalar(o.extra);out[#out+1]=mask(field(o,'boneMask'));return table.concat(out,':')
end
local function snapshot()
 local out={scalar(B._hashCode)};local list={};for _,k in ipairs(keys(labels)) do list[#list+1]=k..'='..describe(objects[k]) end;out[#out+1]=table.concat(list,'|');list={}
 for _,k in ipairs(keys(B._poolsMap)) do local pool={};for i,o in ipairs(B._poolsMap[k]) do pool[i]=ref(o) end;list[#list+1]=k..'='..table.concat(pool,',') end;out[#out+1]=table.concat(list,'|');list={}
 for _,k in ipairs(keys(B._maxCountMap)) do list[#list+1]=k..'='..scalar(B._maxCountMap[k]) end;out[#out+1]=table.concat(list,'|');out[#out+1]=table.concat(reads,'|');out[#out+1]=table.concat(warnings,'|');return out
end
io.stderr={write=function(_,s)warnings[#warnings+1]=s:gsub('\n$','') end}
local index=0
for line in io.lines(assert(arg[1])) do
 local row=split(line,'\t');local tag='void'
 if row[1]=='begin' then begin() else warnings={};local ok,value=pcall(execute,row);if ok then tag=value else tag=tostring(value):find('Invalid array length',1,true) and 'range' or 'error' end end
 io.write(tostring(index),'\t',tag,'\t',table.concat(snapshot(),'\t'),'\n');index=index+1
end
io.stderr=stderr
