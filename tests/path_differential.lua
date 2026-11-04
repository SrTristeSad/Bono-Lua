local Path=require('dragonbones.armature.PathConstraint')
local Slot=require('dragonbones.armature.Slot')
local Bone=require('dragonbones.armature.Bone')
local Arm=require('dragonbones.armature.Armature')
local B=require('dragonbones.core.BaseObject')
local M=require('dragonbones.model.ArmatureData')
local Parser=require('dragonbones.parser.ObjectDataParser')
local JSON=require('dragonbones.parser.JSON')
local V=require('dragonbones.parser.JSValue')
local A=require('dragonbones.core.JSArray')
local Core=require('dragonbones.core.DragonBones')
local double
if string.pack then double=function(n)return string.pack('<d',n)end else local ffi=require('ffi');double=function(n)return ffi.string(ffi.new('double[1]',n),8)end end
local function scalar(v)if v==nil or rawequal(v,V.UNDEFINED)then return'u'end;if type(v)=='boolean'then return tostring(v)end;if v~=v then return'NaN'end;return'n'..(double(v):gsub('.',function(c)return string.format('%02x',c:byte())end))end
local function matrix(m)local out={};for _,key in ipairs({'a','b','c','d','tx','ty'})do out[#out+1]=scalar(m[key])end;return table.concat(out,',')end
local function array(a,fn)local out={};for i=1,a.length do out[#out+1]=rawget(a,i)==nil and'hole'or(fn or scalar)(a[i])end;return a.length..':'..table.concat(out,',')end
local vertices={-10,0,0,0,10,0,20,10,30,10,40,10}
local function execute(c)
 local family,closed,speed,weighted,rotate,spacing,percent,pos,mix,reflect,op=c[1],tonumber(c[2]),tonumber(c[3]),tonumber(c[4]),tonumber(c[5]),tonumber(c[6]),tonumber(c[7]),tonumber(c[8]),tonumber(c[9]),tonumber(c[10]),c[11]
 local raw=c[12]:gsub('..',function(x)return string.char(tonumber(x,16))end)
 local gd=Parser.new():parseDragonBonesData(JSON.parse(raw),op=='fixedScale'and .5 or 1);local ad=gd:getArmature('arm');local arm=B.borrowObject(Arm);arm._armatureData=ad;Core.yDown=true
 local allBones={}
 for i=1,ad.sortedBones.length do local bd=ad.sortedBones[i];if not(op=='missingWeightBone'and bd.name=='aux')then local b=B.borrowObject(Bone);b:init(bd,arm);allBones[#allBones+1]=b;b:invalidUpdate();b:update(-1)end end
 local Observer={__newindex=Slot.__newindex}
 Observer.__index=function(self,key)local member=rawget(Observer,key);if member~=nil then return member end;return Slot.__index(self,key)end
 setmetatable(Observer,{__index=Slot})
 function Observer.toString()return'[test.PathSlotObserver]'end
 function Observer.new()return Slot.new(Observer)end
 function Observer:_initDisplay()end
 function Observer:_disposeDisplay()end
 function Observer:_onUpdateDisplay()end
 function Observer:_addDisplay()end
 B.clearPool(Observer)
 local slot=B.borrowObject(Observer);slot:init(ad:getSlot('path'),arm,nil,nil);slot.displayFrameCount=1;slot:replaceRawDisplayData(ad.defaultSkin:getDisplay('path','curve'),0);slot:_setDisplayIndex(0);slot:_updateDisplayData()
 local data=ad:getConstraint('follow');local display=data.pathDisplayData;local p=B.borrowObject(Path)
 local arrays={p._spaces,p._positions,p._curves,p._boneLengths,p._pathGlobalVertices,p._segments,p._bones}
 local aux=arm:getBone('aux');local absent
 if op=='missingSlot'then arm._slots.length=0 end
 if op=='missingRoot'then absent=B.borrowObject(M.BoneData);absent.name='absent';data.root=absent end
 if op=='missingDisplayData'then data.pathDisplayData=nil end
 local out,helper={},A.new()
 local function snapshot(status)
  local name='error';pcall(function()name=p.name end)
  local fields={status,tostring(p._constraintData==data),name,p._root and p._root.name or'nil',p._target and p._target.name or'nil',tostring(p._pathSlot==slot),array(p._bones,function(b)return b.name end)}
  for _,key in ipairs({'_spaces','_positions','_curves','_boneLengths','_pathGlobalVertices','_segments'})do fields[#fields+1]=array(p[key])end
  local params={};for _,key in ipairs({'dirty','pathOffset','position','spacing','rotateOffset','rotateMix','translateMix'})do params[#params+1]=scalar(p[key])end;fields[#fields+1]=table.concat(params,',')
  for _,name in ipairs({'a','b','guide'})do local b=arm:getBone(name);local pose,flags={},{};for _,key in ipairs({'x','y','skew','rotation','scaleX','scaleY'})do pose[#pose+1]=scalar(b.global[key])end;for _,key in ipairs({'_localDirty','_transformDirty','_childrenTransformDirty','_globalDirty','_hasConstraint'})do flags[#flags+1]=scalar(b[key])end;fields[#fields+1]=table.concat({matrix(b.globalTransformMatrix),table.concat(pose,','),table.concat(flags,',')},'|')end
  fields[#fields+1]=table.concat({tostring(slot._verticesDirty),tostring(slot._geometryData==display.geometry),tostring(slot._geometryBones.length)},',');fields[#fields+1]=array(helper)
  return fields
 end
 local function stage(fn)local ok=pcall(fn);for _,v in ipairs(snapshot(ok and'ok'or'error'))do out[#out+1]=v end end
 stage(function()p:init(data,arm);arm:_addConstraint(p);if op=='reinit'then p:init(data,arm)end;if op=='readonly'then p.name='x'end end)
 stage(function()
  if family=='helper'then
   if op=='copy'then p._pathGlobalVertices.length=4;p._pathGlobalVertices[1]=1;p._pathGlobalVertices[3]=3;p:_computeVertices(0,({2,4,6,8,10})[pos+1],({0,2,4,0,2})[pos+1],helper)
   else p:addCurvePosition(({0,1,.25,-.25,0/0})[pos+1],op=='undefinedEndpoint'and V.UNDEFINED or 0,0,10,0,20,10,op=='undefinedEndpoint'and V.UNDEFINED or 30,10,helper,2,mix==1)end
  elseif family=='curve'then
   p._pathGlobalVertices.length=#vertices;for i,v in ipairs(vertices)do p._pathGlobalVertices[i]=v end;p._spaces.length=3;for i=1,3 do p._spaces[i]=spacing==1 and .1 or 0 end;p:_computeBezierCurve(display,3,mix==1,percent==1,spacing==1)
  else
   if op=='segmentsKept'then p._segments[p._segments.length+1]=99 end
   if op=='preseed'then p._pathGlobalVertices.length=12;for i=0,11 do p._pathGlobalVertices[i+1]=100+i end end
   if op=='noGeometry'then slot._geometryData=nil end
   if op=='offsetMismatch'then p.pathOffset=p.pathOffset+1 end
   if op=='badVertexCount'then gd.intArray[display.geometry.offset+1]=7 end
   if op=='positionBelow'then p.position=-1000 end
   if op=='positionAbove'then p.position=1000 end
   if op=='negativeSpacing'then p.spacing=-4 end
   if op=='rotateOffset'then p.rotateOffset=30 end
   if op=='zeroMix'then p.rotateMix=0;p.translateMix=0 end
   p.dirty=true;p:update()
  end
 end)
 stage(function()
  if op=='clear'then p:_onClear();return end
  if family=='helper'then if op=='undefinedEndpoint'then p:addCurvePosition(1,V.UNDEFINED,0,10,0,20,10,V.UNDEFINED,10,helper,0,false)end;return end
  if family=='curve'then p.position=p.position+.1;p:_computeBezierCurve(display,3,mix==1,percent==1,spacing==1);return end
  for _,b in ipairs(allBones)do b._childrenTransformDirty=false end;slot._verticesDirty=false;p.dirty=false
  if op=='verticesDirty'then slot._verticesDirty=true
  elseif op=='boneDirty'and aux then aux._childrenTransformDirty=true
  elseif op=='rootDirty'then p._root._childrenTransformDirty=true
  elseif op~='cleanReturn'then p.position=p.position+.1;p.dirty=true end
  if op=='cleanReturn'then p.position=p.position+.1 end
  p:invalidUpdate();p:update()
 end)
 local registered=false;for i=1,arm._constraints.length do if arm._constraints[i]==p then registered=true end end
 if not registered then p:returnToPool()end
 if op=='missingSlot'then slot:returnToPool()end
 arm:returnToPool()
 out[#out+1]=tostring(p._isInPool);out[#out+1]=tostring(p._constraintData==data)
 local current={p._spaces,p._positions,p._curves,p._boneLengths,p._pathGlobalVertices,p._segments,p._bones};for i,v in ipairs(arrays)do out[#out+1]=tostring(v==current[i])end
 out[#out+1]=array(p._segments);out[#out+1]=table.concat({p._spaces.length,p._positions.length,p._curves.length,p._boneLengths.length,p._pathGlobalVertices.length,p._bones.length},',')
 if absent then absent:returnToPool()end;gd:returnToPool();return table.concat(out,'\t')
end
local input=assert(arg[1]);for line in io.lines(input)do local c={};for v in(line..'\t'):gmatch('(.-)\t')do c[#c+1]=v end;print(execute(c))end
