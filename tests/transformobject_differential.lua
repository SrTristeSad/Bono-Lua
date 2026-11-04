local T=require('dragonbones.armature.TransformObject')
local B=require('dragonbones.core.BaseObject')
local Matrix=require('dragonbones.geom.Matrix')
local Transform=require('dragonbones.geom.Transform')
local C={__newindex=T.__newindex};C.__index=function(self,k)local v=rawget(C,k);if v~=nil then return v end;return T.__index(self,k)end;setmetatable(C,{__index=T})
function C.toString()return'[test.RuntimeTransform]'end
function C.new()return T.new(C)end
local double
if string.pack then double=function(n)return string.pack('<d',n)end else local ffi=require('ffi');double=function(n)return ffi.string(ffi.new('double[1]',n),8)end end
local function scalar(n)if n==nil then return'u'end;if type(n)=='boolean'then return tostring(n)end;if n~=n then return'NaN'end;return'n'..(double(n):gsub('.',function(c)return string.format('%02x',c:byte())end))end
local function num(s)if s=='NaN'then return 0/0 elseif s=='Infinity'then return math.huge elseif s=='-0'then return -0.0 end;return assert(tonumber(s))+0.0 end
local function execute(mode,text)
 B.clearPool(C);local p=mode=='new'and C.new()or B.borrowObject(C);local q=C.new();local matrix,global,offset=p.globalTransformMatrix,p.global,p.offset;local origin,user,armature=Transform.new(),{},{}
 local initial=table.concat({scalar(p._globalDirty),scalar(p._alpha),scalar(p._globalAlpha)},',')
 p.origin=origin;p.userData=user;p._armature=armature;local values={};for s in text:gmatch('[^,]+')do values[#values+1]=num(s)end
 for i,k in ipairs({'a','b','c','d','tx','ty'})do matrix[k]=values[i]end
 p.offset.x=9;p._alpha=.25;p._globalAlpha=.5
 local calls=0;local returned;local original=global.fromMatrix
 global.fromMatrix=function(self,m)calls=calls+1;if mode=='failFromMatrix'then error('injected')end;return original(self,m)end
 if mode=='failMatrixClear'then matrix.identity=function()error('injected')end end
 if mode=='failGlobalClear'then global.identity=function()error('injected')end end
 if mode=='failOffsetClear'then offset.identity=function()error('injected')end end
 p._globalDirty=mode~='clean'
 local ok=pcall(function()
  if mode=='new'then
  elseif mode=='readonly'then p.armature={}
  elseif mode=='clear'or(mode:sub(1,4)=='fail'and mode~='failFromMatrix')then p:_onClear()
  elseif mode=='reuse'then p:returnToPool();returned=B.borrowObject(C)
  elseif mode=='replace'then p.globalTransformMatrix=Matrix.new(values[1],values[2],values[3],values[4],values[5],values[6]);p:updateGlobalTransform();p:updateGlobalTransform()
  else p:updateGlobalTransform();p:updateGlobalTransform()end
 end)
 local abstract=pcall(function()B.borrowObject(T)end)and'ok'or'error'
 local out={ok and'ok'or'error',initial,scalar(p._globalDirty),scalar(p._alpha),scalar(p._globalAlpha)}
 for _,k in ipairs({'a','b','c','d','tx','ty'})do out[#out+1]=scalar(p.globalTransformMatrix[k])end
 for _,o in ipairs({p.global,p.offset})do for _,k in ipairs({'x','y','skew','rotation','scaleX','scaleY'})do out[#out+1]=scalar(o[k])end end
 for _,v in ipairs({tostring(calls),tostring(p.globalTransformMatrix==matrix),tostring(p.global==global),tostring(p.offset==offset),tostring(p.origin==origin),tostring(p.userData==user),tostring(p.armature==armature),tostring(returned==p),tostring(p._isInPool),tostring(T._helpMatrix==C._helpMatrix),tostring(T._helpMatrix~=matrix),tostring(T._helpTransform==C._helpTransform),tostring(T._helpPoint==C._helpPoint),tostring(q.global~=p.global),abstract})do out[#out+1]=v end
 return table.concat(out,'\t')
end
for line in io.lines(assert(arg[1]))do local mode,text=line:match('^(.-)\t(.*)$');io.write(execute(mode,text),'\n')end
