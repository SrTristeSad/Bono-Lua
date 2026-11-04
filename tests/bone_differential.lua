local Bone=require('dragonbones.armature.Bone')
local Arm=require('dragonbones.armature.Armature')
local B=require('dragonbones.core.BaseObject')
local M=require('dragonbones.model.ArmatureData')
local D=require('dragonbones.model.DragonBonesData')
local Core=require('dragonbones.core.DragonBones')
local Array=require('dragonbones.core.JSArray')
local double
if string.pack then double=function(n)return string.pack('<d',n)end else local ffi=require('ffi');double=function(n)return ffi.string(ffi.new('double[1]',n),8)end end
local function scalar(n)if n==nil then return'u'end;if type(n)=='boolean'then return tostring(n)end;if n~=n then return'NaN'end;return'n'..(double(n):gsub('.',function(c)return string.format('%02x',c:byte())end))end
local function values(a)local out={};for i=1,a.length do out[#out+1]=scalar(a[i])end;return table.concat(out,',')end
local tk={'x','y','skew','rotation','scaleX','scaleY'}
local function execute(r)
 local parent,mode,flip,down,inherit,cache,op=tonumber(r[1]),tonumber(r[2]),tonumber(r[3]),tonumber(r[4]),tonumber(r[5]),tonumber(r[6]),r[7]
 Core.yDown=down==1;local gd,ad=B.borrowObject(D),B.borrowObject(M.ArmatureData);ad.name='arm';gd:addArmature(ad)
 local arm=B.borrowObject(Arm);arm._armatureData=ad;arm._flipX=flip%2==1;arm._flipY=flip>=2;arm._globalAlpha=.75
 local rootData,childData=B.borrowObject(M.BoneData),B.borrowObject(M.BoneData);rootData.name='root';childData.name='child';childData.parent=parent==1 and rootData or nil
 rootData.transform.x=10.0;rootData.transform.y=20.0;rootData.transform.rotation=.25;rootData.transform.scaleX=1.5;rootData.transform.scaleY=.8
 childData.transform.x=8.0;childData.transform.y=-3.0;childData.transform.rotation=-.4;childData.transform.skew=.1;childData.transform.scaleX=1.1;childData.transform.scaleY=.9;childData.alpha=.6
 childData.inheritTranslation=inherit%2==1;childData.inheritRotation=math.floor(inherit/2)%2==1;childData.inheritScale=math.floor(inherit/4)%2==1;childData.inheritReflection=math.floor(inherit/8)%2==1
 ad:addBone(rootData);ad:addBone(childData)
 local a,b=B.borrowObject(Bone),B.borrowObject(Bone);if op=='childFirst'then b:init(childData,arm);a:init(rootData,arm)else a:init(rootData,arm);b:init(childData,arm)end;arm:_addBone(b)
 b.offsetMode=mode;b.offset.x=2.0;b.offset.y=4.0;b.offset.rotation=.2;b.offset.skew=-.1;b.offset.scaleX=.8;b.offset.scaleY=1.2
 b.animationPose.x=-1.0;b.animationPose.y=3.0;b.animationPose.rotation=.3;b.animationPose.scaleX=1.2;b.animationPose.scaleY=.7
 if cache==1 then a._cachedFrameIndices=Array.new();b._cachedFrameIndices=Array.new()end
 if op=='negativeZero'then b.offset.x=-0.0;b.offset.y=-0.0;b.offset.skew=-0.0;b.offset.rotation=-0.0 end
 if op=='integerZero'then b.offset.x=0;b.offset.y=0;b.offset.skew=0;b.offset.rotation=0 end
 if op=='originNull'then b.origin=nil end
 if op=='negativeScale'then a.offset.scaleX=-1.0;b.offset.scaleY=-1 end
 if op=='missingArmature'then b._armature=nil end
 local poseIdentity=b.animationPose.identity
 local ok=pcall(function()
  a:invalidUpdate();a:update(cache==1 and 0 or -1);a:_updateAlpha();b:invalidUpdate();b:update(cache==1 and 0 or -1);b:_updateAlpha()
  if op=='repeat'or op=='cacheHit'then a:update(cache==1 and 0 or -1);b:update(cache==1 and 0 or -1)end
  if op=='invalid'then b.offset.x=99.0;b:invalidUpdate();b:update(-1)end
  if op=='constraintDirty'then b._localDirty=true;b._transformDirty=true;b:updateByConstraint();b:updateByConstraint()end
  if op=='visible'then b.visible=false;b.visible=false;b.visible=true end
  if op=='readonly'then b.parent=a end
  if op=='reinit'then b:init(rootData,arm)end
  if op=='flipSetter'then arm.flipX=true;a:update(-1);b:update(-1)end
  if op=='namedInvalid'then arm:invalidUpdate('absent');arm:invalidUpdate('child')end
  if op=='cacheRestore'then b.globalTransformMatrix:identity();b.global:identity();b._cachedFrameIndex=-1;b:update(0)end
  if op=='cacheMissClean'then a._childrenTransformDirty=false;b._transformDirty=false;b:update(1)end
  if op=='parentDirty'then a.offset.x=50.0;a:invalidUpdate();a:update(-1);b._transformDirty=false;b:update(-1)end
  if op=='failPoseClear'then b.animationPose.identity=function()error('injected')end;b:_onClear()end
  if op=='visibleNoArmature'then b._armature=nil;b.visible=false end
  if op=='flipFailure'then arm.invalidUpdate=function()error('injected')end;arm.flipX=true end
  if op=='getterBeforeInit'then local n=B.borrowObject(Bone);local name=n.name end
 end)
 b.animationPose.identity=poseIdentity
 local function snap(o)local out={};for _,k in ipairs({'a','b','c','d','tx','ty'})do out[#out+1]=scalar(o.globalTransformMatrix[k])end;for _,t in ipairs({o.global,o.offset,o.animationPose})do for _,k in ipairs(tk)do out[#out+1]=scalar(t[k])end end;for _,k in ipairs({'_alpha','_globalAlpha','_transformDirty','_childrenTransformDirty','_localDirty','_globalDirty','_cachedFrameIndex','offsetMode'})do out[#out+1]=scalar(o[k])end;return table.concat(out,',')end
 local relation;local rok=pcall(function()local out={a:contains(b),b:contains(a),a:contains(a),a:contains(nil),b.parent==a,b.boneData==childData,b.armature==arm};for i,v in ipairs(out)do out[i]=tostring(v)end;relation=table.concat(out,',')end);if not rok then relation='error'end
 local before={ok and'ok'or'error',snap(a),snap(b),relation,tostring(arm:getBones().length),tostring(arm:getBones()==arm:getBones()),tostring(arm:getSlots().length),tostring(arm:getBone('child')==b),tostring(b.visible),tostring(b.origin==childData.transform),b.name,arm.name,tostring(arm.flipX),tostring(arm.flipY),values(gd.cachedFrames),a._cachedFrameIndices and values(a._cachedFrameIndices)or'nil',b._cachedFrameIndices and values(b._cachedFrameIndices)or'nil'}
 arm:returnToPool();local state={a._isInPool,b._isInPool,arm._isInPool,arm:getBones().length,arm._constraints.length,b._boneData==nil,b.parent==nil,b.origin==nil,b.offsetMode,b._localDirty,b._transformDirty}
 for _,v in ipairs(state)do before[#before+1]=tostring(v)end;gd:returnToPool();return table.concat(before,'\t')
end
for line in io.lines(assert(arg[1]))do local r={};for v in(line..'\t'):gmatch('(.-)\t')do r[#r+1]=v end;io.write(execute(r),'\n')end
