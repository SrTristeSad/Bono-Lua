local Surface=require('dragonbones.armature.Surface')
local Bone=require('dragonbones.armature.Bone')
local Arm=require('dragonbones.armature.Armature')
local B=require('dragonbones.core.BaseObject')
local P=require('dragonbones.parser.ObjectDataParser')
local JSON=require('dragonbones.parser.JSON')
local Core=require('dragonbones.core.DragonBones')
local Array=require('dragonbones.core.JSArray')
local double
if string.pack then double=function(n)return string.pack('<d',n)end else local ffi=require('ffi');double=function(n)return ffi.string(ffi.new('double[1]',n),8)end end
local function scalar(v)if v==nil then return'u'end;if type(v)=='boolean'then return tostring(v)end;if v~=v then return'NaN'end;return'n'..(double(v):gsub('.',function(c)return string.format('%02x',c:byte())end))end
local function matrix(m)local t={};for _,k in ipairs({'a','b','c','d','tx','ty'})do t[#t+1]=scalar(m[k])end;return table.concat(t,',')end
local function arr(a)local t={};for i=1,a.length do t[#t+1]=a[i]==nil and'hole'or scalar(a[i])end;return string.format('%.0f',a.length)..':'..table.concat(t,',')end
local points={{-1001,0},{1001,0},{0,-1001},{0,1001},{-1000,-1000},{1000,1000},{-200,-200},{200,200},{-201,0},{201,0},{0,-201},{0,201},{-1000,0},{1000,0},{0,-1000},{0,1000},{-200,0},{200,0},{0,-200},{0,200},{0,0},{50,-75},{-75,50},{-199.99,199.99},{199.99,-199.99},{-500,-50},{-500,50},{500,-50},{500,50},{-50,-500},{50,-500},{-50,500},{50,500}}
local function execute(c)
 local sx,sy,parent,deform,cache,flip,down=tonumber(c[1]),tonumber(c[2]),tonumber(c[3]),tonumber(c[4])+0.0,tonumber(c[5]),tonumber(c[6]),tonumber(c[7]);local op=c[8]
 Core.yDown=down==1;local raw=(c[9]:gsub('..',function(h)return string.char(tonumber(h,16))end));local data=P.new():parseDragonBonesData(JSON.parse(raw));local ad=data:getArmature('arm');local arm=B.borrowObject(Arm);arm._armatureData=ad;arm._flipX=flip%2==1;arm._flipY=flip>=2
 for i=1,ad.sortedBones.length do local bd=ad.sortedBones[i];local bone=B.borrowObject(bd.type==1 and Surface or Bone);bone:init(bd,arm);if cache==1 then bone._cachedFrameIndices=Array.new()end;bone:invalidUpdate()end
 local s,leaf=arm:getBone('surface'),arm:getBone('leaf');local vertices,deforms,hull,matrices=s._vertices,s._deformVertices,s._hullCache,s._matrixCahce
 for i=0,s._deformVertices.length-1 do s._deformVertices[i+1]=deform*(i%3-1)end
 local ok=pcall(function()
  if op=='initAgain'then s:init(ad:getBone('root')or s.boneData,arm)end
  if op=='missingArmature'then s._armature=nil end
  if op=='badGeometry'then s.boneData.geometry.offset=100000.0 end
  local bones=arm:getBones();for i=1,bones.length do local bone=bones[i];if not(op=='queryBeforeUpdate'and bone==s)then bone:update(cache==1 and 0 or -1);bone:_updateAlpha()end end
  if op=='cacheHit'then s:update(0)end
  if op=='cacheRestore'then s._cachedFrameIndex=-1;s.globalTransformMatrix:identity();s:update(0)end
  if op=='deformAgain'then s._deformVertices[1]=s._deformVertices[1]+50.0;s:invalidUpdate();s:update(-1);leaf:update(-1)end
  if op=='readonly'then s.parent=nil end
  if op=='clean'then s:update(-1)end
 end)
 local queries={};for _,point in ipairs(points)do local text;local qok=pcall(function()local m=s:_getGlobalTransformMatrix(point[1]+0.0,point[2]+0.0);local first=matrix(m);local m2=s:_getGlobalTransformMatrix(point[1]+0.0,point[2]+0.0);text=table.concat({m==s.globalTransformMatrix and'own'or'shared',tostring(m==m2),first,matrix(m2)},'|')end);queries[#queries+1]=qok and text or'error'end
 local pose={};for _,k in ipairs({'x','y','skew','rotation','scaleX','scaleY'})do pose[#pose+1]=scalar(s.global[k])end
 local flags={};for _,k in ipairs({'_dX','_dY','_k','_kX','_kY','_globalDirty','_localDirty','_transformDirty','_childrenTransformDirty','_cachedFrameIndex'})do flags[#flags+1]=scalar(s[k])end
 local result={ok and'ok'or'error',arr(s._vertices),arr(s._deformVertices),arr(s._hullCache),arr(s._matrixCahce),matrix(s.globalTransformMatrix),matrix(leaf.globalTransformMatrix),table.concat(pose,','),table.concat(flags,','),s._bone and s._bone.name or'nil',arr(data.cachedFrames)}
 for _,q in ipairs(queries)do result[#result+1]=q end
 arm:returnToPool();local state={s._isInPool,leaf._isInPool,s._vertices==vertices,s._deformVertices==deforms,s._hullCache==hull,s._matrixCahce==matrices,s._vertices.length,s._deformVertices.length,s._hullCache.length,s._matrixCahce.length,s._bone==nil};for i,v in ipairs(state)do state[i]=type(v)=='number'and string.format('%.0f',v)or tostring(v)end;result[#result+1]=table.concat(state,',');data:returnToPool();return table.concat(result,'\t')
end
for line in io.lines(assert(arg[1]))do local c={};for v in(line..'\t'):gmatch('(.-)\t')do c[#c+1]=v end;io.write(execute(c),'\n')end
