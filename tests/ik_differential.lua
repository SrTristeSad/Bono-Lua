local IK=require('dragonbones.armature.IKConstraint')
local Constraint=require('dragonbones.armature.Constraint')
local T=require('dragonbones.armature.TransformObject')
local Bone=require('dragonbones.armature.Bone')
local Arm=require('dragonbones.armature.Armature')
local B=require('dragonbones.core.BaseObject')
local M=require('dragonbones.model.ArmatureData')
local CD=require('dragonbones.model.ConstraintData')
local Data=require('dragonbones.model.DragonBonesData')
local Core=require('dragonbones.core.DragonBones')
local Array=require('dragonbones.core.JSArray')
assert(not pcall(function()B.borrowObject(Constraint)end),'Constraint must remain abstract')
local double
if string.pack then double=function(n)return string.pack('<d',n)end else local ffi=require('ffi');double=function(n)return ffi.string(ffi.new('double[1]',n),8)end end
local function scalar(v)if v==nil then return'u'end;if type(v)=='boolean'then return tostring(v)end;if v~=v then return'NaN'end;return'n'..(double(v):gsub('.',function(c)return string.format('%02x',c:byte())end))end
local function matrix(m)local out={};for _,key in ipairs({'a','b','c','d','tx','ty'})do out[#out+1]=scalar(m[key])end;return table.concat(out,',')end
local targets={{8,8},{30,0},{1,0},{0,0},{18,0},{2,0},{-12,5},{0,-12}}
local weights={-.5,0,.25,1,1.5}
local function execute(c)
 local chain,bend,wi,ti,flip,down,reflect,shape=tonumber(c[1]),tonumber(c[2]),tonumber(c[3]),tonumber(c[4]),tonumber(c[5]),tonumber(c[6]),tonumber(c[7]),tonumber(c[8]);local op=c[9]
 Core.yDown=down==1
 local gd,ad=B.borrowObject(Data),B.borrowObject(M.ArmatureData);ad.name='ik';gd:addArmature(ad)
 local arm=B.borrowObject(Arm);arm._armatureData=ad;arm._flipX=flip%2==1;arm._flipY=flip>=2
 local ids={[arm]='arm'}
 local function boneData(name,parent)
  local x=B.borrowObject(M.BoneData);x.name=name;x.parent=parent;x.inheritTranslation=true;x.inheritRotation=true;x.inheritScale=true;x.inheritReflection=true;ad:addBone(x);return x
 end
 local gpData;if reflect~=0 then gpData=boneData('grand',nil);gpData.transform.scaleX=reflect end
 local targetData,rootData=boneData('target',nil),boneData('upper',gpData);local childData=boneData('lower',rootData)
 rootData.length=10;childData.length=shape==3 and 0 or 8;childData.transform.x=shape==2 and 0 or 10;targetData.transform.x=targets[ti+1][1];targetData.transform.y=targets[ti+1][2]
 if shape==1 then rootData.transform.rotation=.35;rootData.transform.skew=.12;rootData.transform.scaleX=1.2;rootData.transform.scaleY=.8;childData.transform.y=3;childData.transform.rotation=-.2;childData.transform.skew=.15 end
 if op=='negativeRoot'then rootData.transform.scaleX=-1 end
 if op=='negativeChild'then childData.transform.scaleX=-1 end
 if op=='negativeLength'then childData.length=-8 end
 local runtime={};for i=1,ad.sortedBones.length do local bd=ad.sortedBones[i];local bone=B.borrowObject(Bone);bone:init(bd,arm);runtime[#runtime+1]=bone;ids[bone]=bd.name end
 local target,rootBone,child,gp=arm:getBone('target'),arm:getBone('upper'),arm:getBone('lower'),arm:getBone('grand')
 local data=B.borrowObject(CD.IKConstraintData);data.name='aim';data.root=rootData;data.target=targetData;if chain==1 then data.bone=childData end;data.bendPositive=bend==1;data.weight=weights[wi+1];data.scaleEnabled=op=='scaleEnabled'or op=='scaleEnabledFar';ad:addConstraint(data)
 local ik=B.borrowObject(IK);local cache=op:sub(1,5)=='cache';if cache then for _,bone in ipairs(runtime)do bone._cachedFrameIndices=Array.new()end end
 local removed
 if op=='missingRoot'then removed=rootBone elseif op=='missingTarget'then removed=target elseif op=='missingBone'then removed=child end
 if removed then local list=Array.new();for i=1,arm._bones.length do if arm._bones[i]~=removed then list[list.length+1]=arm._bones[i]end end;arm._bones=list end
 if op=='missingTargetData'then data.target=nil end
 local function id(x)return x==nil and'nil'or ids[x]or'unexpected'end
 local function array(x)if x==nil then return'nil'end;local out={};for i=1,x.length do out[#out+1]=x[i]==nil and'hole'or scalar(x[i])end;return x.length..':'..table.concat(out,',')end
 local function state(bone)
  local pose={};for _,key in ipairs({'x','y','skew','rotation','scaleX','scaleY'})do pose[#pose+1]=scalar(bone.global[key])end
  local flags={};for _,key in ipairs({'_transformDirty','_childrenTransformDirty','_localDirty','_globalDirty','_hasConstraint','_cachedFrameIndex'})do flags[#flags+1]=scalar(bone[key])end
  return table.concat({matrix(bone.globalTransformMatrix),table.concat(pose,','),table.concat(flags,','),array(bone._cachedFrameIndices)},'|')
 end
 local out={}
 local function snap(status)
  local name='error';pcall(function()name=ik.name end)
  return {status,state(rootBone),state(child),state(target),gp and state(gp)or'nil',ik._constraintData==data,id(ik._armature),id(ik._root),id(ik._bone),id(ik._target),name,scalar(ik._bendPositive),scalar(ik._weight),arm._constraints.length,array(gd.cachedFrames),IK._helpMatrix==Constraint._helpMatrix,Constraint._helpMatrix~=T._helpMatrix}
 end
 local function stage(fn)local ok=pcall(fn);for _,v in ipairs(snap(ok and'ok'or'error'))do out[#out+1]=tostring(v)end end
 local function solve(index)target:update(index);if gp then gp:update(index)end;if op=='direct'then ik:update()else rootBone:update(index);child:update(index)end end
 stage(function()
  if op=='getterBeforeInit'then local name=ik.name end
  local armature=arm;if op=='missingArmature'then armature=nil end
  ik:init(data,armature);arm:_addConstraint(ik);arm:_addConstraint(ik)
  if op=='reinit'then ik:init(nil,nil)end
  for _,bone in ipairs(runtime)do bone:invalidUpdate()end
  if op=='nanTarget'then target.offset.x=0/0 end
  solve(cache and 0 or -1)
 end)
 stage(function()
  if op=='integerPose'or op=='signedZero'then
   for _,bone in ipairs({rootBone,child,target})do if op=='signedZero'then bone.global.x=-0.0;bone.global.y=-0.0 else bone.global.x=0;bone.global.y=0 end end
   if chain==1 then ik:_computeB()else ik:_computeA()end
  else target.offset.x=3;target.offset.y=-2;target:invalidUpdate();ik:invalidUpdate();solve(op=='cacheHit'and 0 or cache and 1 or -1)end
 end)
 stage(function()
  if op=='readonly'then ik.name='changed'
  elseif op=='baseClear'then Constraint._onClear(ik)
  elseif op=='clear'then ik:_onClear()
  elseif op=='cacheRestore'then rootBone._cachedFrameIndex=-1;rootBone.globalTransformMatrix:identity();rootBone:update(0)
  else ik:invalidUpdate();solve(cache and 2 or -1)end
 end)
 local registered=false;for i=1,arm._constraints.length do if arm._constraints[i]==ik then registered=true end end
 if not registered then ik:returnToPool()end
 arm:returnToPool();if removed then removed:returnToPool()end
 for _,v in ipairs({ik._isInPool,ik._constraintData==nil,ik._armature==nil,ik._target==nil,ik._root==nil,ik._bone==nil,ik._bendPositive,scalar(ik._weight),rootBone._isInPool,child._isInPool,arm._constraints.length})do out[#out+1]=tostring(v)end
 gd:returnToPool();return table.concat(out,'\t')
end
local input=assert(arg[1]);for line in io.lines(input)do local c={};for v in(line..'\t'):gmatch('(.-)\t')do c[#c+1]=v end;print(execute(c))end
