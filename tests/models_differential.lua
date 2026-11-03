local B,C,A,T,AbstractA,AbstractT,classes,objects,labels,rectangles,warnings
local rectIds,mapIds,nextRect,nextMap
local originalStderr=io.stderr
local doubleBytes
if string.pack then doubleBytes=function(v) return string.pack('<d',v) end
else
 local ffi=require('ffi') -- test transport only, never a product dependency
 doubleBytes=function(v)
  local data=ffi.new('double[1]',v);local bytes=ffi.string(data,8)
  return ffi.abi('le') and bytes or bytes:reverse()
 end
end
local function split(s,sep)
 local out={};for value in (s..sep):gmatch('(.-)'..sep) do out[#out+1]=value end;return out
end
local function number(s)
 if s=='NaN' then return 0/0 end
 if s=='Infinity' then return math.huge end
 if s=='-Infinity' then return -math.huge end
 if s=='-0' then return -0.0 end
 return assert(tonumber(s),'Invalid fixture number')+0.0
end
local function decode(s)
 if s:sub(1,2)=='s:' then return s:sub(3) end
 if s=='true' then return true end
 if s=='false' then return false end
 if s=='undefined' then return nil end
 return number(s)
end
local function scalar(v)
 if v==nil then return 'undefined' end
 if type(v)=='boolean' then return v and 'b:true' or 'b:false' end
 if type(v)~='number' then return 's:'..v end
 if v~=v then return 'NaN' end
 return 'n:'..doubleBytes(v):gsub('.',function(c) return string.format('%02x',c:byte()) end)
end
local function keys(t)
 local out={};for k in pairs(t) do out[#out+1]=k end;table.sort(out);return out
end
local function begin()
 for _,p in ipairs({'dragonbones.core.BaseObject','dragonbones.model.CanvasData','dragonbones.model.TextureAtlasData'}) do package.loaded[p]=nil end
 B=require('dragonbones.core.BaseObject');C=require('dragonbones.model.CanvasData')
 local models=require('dragonbones.model.TextureAtlasData');AbstractA,AbstractT=models.TextureAtlasData,models.TextureData
 T={};T.__index=T;setmetatable(T,{__index=AbstractT})
 function T.toString() return '[test.Models.Texture]' end
 function T.new() return AbstractT.new(T) end
 A={};A.__index=A;setmetatable(A,{__index=AbstractA})
 function A.toString() return '[test.Models.Atlas]' end
 function A.new() return AbstractA.new(A) end
 function A:createTexture()
  self.createCalls=(self.createCalls or 0)+1
  if self.failAt==self.createCalls then error('factory failure') end
  return B.borrowObject(T)
 end
 classes={C=C,A=A,T=T,AbstractA=AbstractA,AbstractT=AbstractT}
 objects,labels,rectangles,warnings={},{},{},{}
 rectIds,mapIds=setmetatable({},{__mode='k'}),setmetatable({},{__mode='k'});nextRect,nextMap=0,0
end
local function rect(r)
 if r==nil then return 'nil' end
 if not rectIds[r] then nextRect=nextRect+1;rectIds[r]=nextRect end
 local values={};for i,k in ipairs({'x','y','width','height'}) do values[i]=scalar(r[k]) end
 return rectIds[r]..':'..table.concat(values,',')
end
local function ref(o) return o==nil and 'nil' or scalar(o.hashCode) end
local function describe(o)
 if o==nil then return 'nil' end
 local class=getmetatable(o)
 local out={class==C and 'C' or class==T and 'T' or 'A',scalar(o.hashCode),o._isInPool and '1' or '0'}
 if class==C then
  for _,k in ipairs({'hasBackground','color','x','y','width','height','extra'}) do out[#out+1]=scalar(o[k]) end
 elseif class==T then
  out[#out+1]=scalar(o.rotated);out[#out+1]=scalar(o.name);out[#out+1]=rect(o.region)
  out[#out+1]=ref(o.parent);out[#out+1]=rect(o.frame)
 else
  for _,k in ipairs({'autoSearch','width','height','scale','name','imagePath','createCalls','failAt'}) do out[#out+1]=scalar(o[k]) end
  if not mapIds[o.textures] then nextMap=nextMap+1;mapIds[o.textures]=nextMap end
  out[#out+1]=mapIds[o.textures]
  local contents={};for _,k in ipairs(keys(o.textures)) do contents[#contents+1]=k..'='..describe(o.textures[k]) end
  out[#out+1]=table.concat(contents,';')
 end
 return table.concat(out,':')
end
local function snapshot()
 local out={scalar(B._hashCode),scalar(B._defaultMaxCount)}
 local list={};for _,k in ipairs(keys(rectangles)) do list[#list+1]=k..'='..rect(rectangles[k]) end
 out[#out+1]=table.concat(list,'|');list={}
 for _,k in ipairs(keys(labels)) do list[#list+1]=k..'='..describe(objects[k]) end
 out[#out+1]=table.concat(list,'|');list={}
 for _,k in ipairs(keys(B._poolsMap)) do
  local ids={};for i,o in ipairs(B._poolsMap[k]) do ids[i]=ref(o) end
  list[#list+1]=k..':'..table.concat(ids,',')
 end
 out[#out+1]=table.concat(list,'|');list={}
 for _,k in ipairs(keys(B._maxCountMap)) do list[#list+1]=k..':'..scalar(B._maxCountMap[k]) end
 out[#out+1]=table.concat(list,'|');out[#out+1]=table.concat(warnings,'|');return out
end
io.stderr={write=function(_,message) warnings[#warnings+1]=message:gsub('\n$','') end}
local input=assert(arg[1],'Input required');local index=0
for line in io.lines(input) do
 local row=split(line,'\t');local op,a,b,c=row[1],row[2],row[3],row[4];local tag='void'
 if op=='begin' then begin() else
  warnings={}
  local ok,value=pcall(function()
   if op=='new' or op=='borrow' then
    local o;if op=='new' then o=classes[b].new() else o=B.borrowObject(classes[b]) end
    objects[a]=o;labels[a]=true;return o
   elseif op=='set' then objects[a][b]=decode(c)
   elseif op=='region' then for i,k in ipairs({'x','y','width','height'}) do objects[a].region[k]=number(row[i+2]) end
   elseif op=='rect' then
    local r=AbstractT.createRectangle();for i,k in ipairs({'x','y','width','height'}) do r[k]=number(row[i+2]) end
    rectangles[a]=r;return r
   elseif op=='frame' then objects[a].frame=b~='none' and rectangles[b] or nil
   elseif op=='parent' then objects[a].parent=b~='none' and objects[b] or nil
   elseif op=='add' then return objects[a]:addTexture(objects[b])
   elseif op=='get' then local o=objects[b]:getTexture(c);objects[a]=o;labels[a]=true;return o
   elseif op=='copy' then return objects[a]:copyFrom(objects[b])
   elseif op=='onClear' then return objects[a]:_onClear()
   elseif op=='return' then return objects[a]:returnToPool()
   elseif op=='limit' then return B.setMaxCount(a~='*' and classes[a] or nil,number(b))
   elseif op=='clearPool' then return B.clearPool(a~='*' and classes[a] or nil)
   elseif op=='string' then return classes[a].toString(classes[a])
   elseif op=='put' then objects[a].textures[b]=objects[c]
   elseif op=='delete' then objects[a].textures[b]=nil
   elseif op=='abstractCreate' then return AbstractA.createTexture(objects[a])
   else error('Unknown test command') end
  end)
  if not ok then
   tag=tostring(value):find('Invalid array length',1,true) and 'range' or 'error'
  elseif op=='get' then tag=value==nil and 'nil' or 'object:'..ref(value)
  elseif op=='rect' then tag='rectangle'
  elseif op=='string' then tag='string:'..value
  else tag=value==nil and 'void' or 'object:'..ref(value) end
 end
 io.write(tostring(index),'\t',tag,'\t',table.concat(snapshot(),'\t'),'\n');index=index+1
end
io.stderr=originalStderr
