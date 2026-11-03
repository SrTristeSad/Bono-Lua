local Matrix = require('dragonbones.geom.Matrix')
local Transform = require('dragonbones.geom.Transform')
local fields = {Matrix={'a','b','c','d','tx','ty'},Transform={'x','y','skew','rotation','scaleX','scaleY'}}
local function split(s, sep)
  local result={}
  for part in (s..sep):gmatch('(.-)'..sep) do result[#result+1]=part end
  return result
end
local function number(s)
  if s=='undefined' or s=='' then return nil end
  if s=='NaN' then return 0/0 end
  if s=='Infinity' then return math.huge end
  if s=='-Infinity' then return -math.huge end
  if s=='-0' then return -0.0 end
  return assert(tonumber(s),'Bad number '..tostring(s))+0.0
end
local function numbers(raw)
  local values, count={},0
  if raw~='' then
    local items=split(raw,',');count=#items
    for i,s in ipairs(items) do values[i]=number(s) end
  end
  return values,count
end
local function encode(n)
  if n==nil then return 'undefined' end
  if n~=n then return 'NaN' end
  if n==math.huge then return 'Infinity' end
  if n==-math.huge then return '-Infinity' end
  if n==0 and 1/n==-math.huge then return '-0' end
  return string.format('%.17g',n)
end
local unpackValues=table.unpack or unpack
local function construct(class,raw)
  local values,count=numbers(raw)
  return class.new(unpackValues(values,1,count))
end
local function values(obj,keys)
  local out={}
  for i,k in ipairs(keys) do out[i]=encode(obj[k]) end
  return out
end
local input=assert(arg[1],'Input required')
for line in io.lines(input) do
  local row=split(line,'\t')
  local cls,op,id,raw,other,option=unpackValues(row,1,6)
  local C=cls=='Matrix' and Matrix or Transform
  local object=construct(C,raw)
  local initial=table.concat(values(object,fields[cls]),'\t')
  local returned,out,kind
  if op=='new' then returned=object
  elseif op=='normalize' then returned=Transform.normalizeRadian(number(raw));out={encode(returned)};kind='number'
  elseif op=='constants' then out=values(Transform,{'PI','PI_D','PI_H','PI_Q','RAD_DEG','DEG_RAD'})
  elseif op=='string' then returned=object:toString();out={returned};kind='string'
  elseif op=='self' then returned=object:copyFrom(object)
  elseif op=='concatSelf' then returned=object:concat(object)
  elseif op=='addSelf' then returned=object:add(object)
  elseif op=='minusSelf' then returned=object:minus(object)
  elseif op=='identity' then returned=object:identity()
  elseif op=='invert' then returned=object:invert()
  elseif op=='copyFrom' or op=='concat' or op=='add' or op=='minus' then
    local source=construct(C,other)
    local before=table.concat(values(source,fields[cls]),'\t')
    returned=object[op](object,source)
    assert(table.concat(values(source,fields[cls]),'\t')==before,'Source changed')
  elseif op=='copyArray' then
    local array=numbers(raw)
    returned=object:copyFromArray(array,number(other))
  elseif op=='point' then
    local a=numbers(other);local dest={x=999,y=999}
    returned=object:transformPoint(a[1],a[2],dest,option=='true');out=values(dest,{'x','y'})
  elseif op=='rect' then
    local a=numbers(other);local dest={x=a[1],y=a[2],width=a[3],height=a[4]}
    returned=object:transformRectangle(dest,option=='true');out=values(dest,{'x','y','width','height'})
  elseif op=='toMatrix' then
    local dest=Matrix.new(9,8,7,6,5,4)
    returned=object:toMatrix(dest);out=values(dest,fields.Matrix)
  elseif op=='fromMatrix' then
    local source=construct(Matrix,other)
    local before=table.concat(values(source,fields.Matrix),'\t')
    returned=object:fromMatrix(source)
    assert(table.concat(values(source,fields.Matrix),'\t')==before,'Matrix source changed')
  else error('Unknown operation '..op) end
  if op=='point' or op=='rect' or op=='toMatrix' then
    assert(table.concat(values(object,fields[cls]),'\t')==initial,'Query receiver changed')
  end
  out=out or values(object,fields[cls])
  kind=kind or (returned==object and 'self' or returned==nil and 'void' or 'unexpected')
  io.write(table.concat({cls,op,id,kind},'\t'),'\t',table.concat(out,'\t'),'\n')
end
