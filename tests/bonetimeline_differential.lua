local T=require('dragonbones.animation.BoneTimelineState')
local Blend=require('dragonbones.animation.BlendState')
local B=require('dragonbones.core.BaseObject')
local D=require('dragonbones.model.DragonBonesData')
local M=require('dragonbones.model.ArmatureData')
local Anim=require('dragonbones.model.AnimationData')
local Arm=require('dragonbones.armature.Armature')
local Bone=require('dragonbones.armature.Bone')
local Array=require('dragonbones.core.JSArray')
local Shared=require('dragonbones.parser.SharedBinaryBuffer')
local double
if string.pack then double=function(n)return string.pack('<d',n)end else local ffi=require('ffi');double=function(n)return ffi.string(ffi.new('double[1]',n),8)end end
local function scalar(v)if v==nil then return'u'end;if type(v)=='boolean'then return tostring(v)end;if v~=v then return'NaN'end;return'n'..(double(v):gsub('.',function(c)return string.format('%02x',c:byte())end))end
local function array(a)local out={};for i=1,a.length do out[#out+1]=rawget(a,i)==nil and'hole'or scalar(a[i])end;return a.length..':'..table.concat(out,',')end
local function arr(values)local a=Array.new();for i,v in ipairs(values)do a[i]=v end;return a end
local function typed(values,kind)local bytes=#values*(kind=='float32'and 4 or 2);local a=Shared.view(Shared.new(string.rep('\0',bytes)),0,bytes,kind);for i,v in ipairs(values)do a[i]=v end;return a end
local names={'BoneAllTimelineState','BoneTranslateTimelineState','BoneRotateTimelineState','BoneScaleTimelineState'}
local keys={'dirty','playState','currentPlayTimes','currentTime','_isTween','_frameOffset','_frameIndex','_timeScale','_timeOffset','_tweenType','_framePosition','_frameDurationR','_tweenProgress','_valueScale','_currentA','_currentB','_differenceA','_differenceB','_resultA','_resultB','_valueCount'}
local function execute(c)
 local cls,pose,tween,scale,weight,layer,op=tonumber(c[1]),tonumber(c[2]),tonumber(c[3]),tonumber(c[4]),tonumber(c[5]),tonumber(c[6]),c[7]
 local gd=B.borrowObject(D);local ad=B.borrowObject(M.ArmatureData);local anim=B.borrowObject(Anim.AnimationData);local td=B.borrowObject(Anim.TimelineData);local bd=B.borrowObject(M.BoneData);local arm=B.borrowObject(Arm);local bone=B.borrowObject(Bone);local blend=B.borrowObject(Blend);local p=B.borrowObject(T[names[cls+1]])
 ad.name='arm';gd:addArmature(ad);anim.name='anim';ad:addAnimation(anim);ad.scale=scale;ad.frameRate=4;anim.duration=1;anim.frameOffset=2;anim.frameFloatOffset=2;td.offset=3;td.frameIndicesOffset=2;bd.name='bone';ad:addBone(bd);arm._armatureData=ad;bone:init(bd,arm)
 gd.frameArray=typed({99,99,0,tween,tween==2 and 2 or 50,2500,7500,1,tween,tween==2 and 2 or 75,2500,7500,3,tween,tween==2 and 2 or 100,2500,7500},'int16');gd.timelineArray=typed({99,99,99,100,0,op=='single'and 1 or 3,6,1,0,5,10},'uint16');gd.frameIndices=arr({99,99,0,1,1,2,2,2});gd.frameFloatArray=typed({99,99,99,1,3,7,-5,2,.5,11,13,-8,9,.25,2,23,29,10,-12,3,-1},'float32')
 -- Explicit input field contract until AnimationState is ported.
 local state={animationData=anim,_position=0,_duration=1,playTimes=op=='lastLoop'and 1 or 0,currentPlayTimes=0,_playheadState=op=='stopped'and 0 or 3,layer=2,_weightResult=weight}
 local tdArg;if pose==0 then tdArg=td end;p:init(arm,state,tdArg);p.target=blend;blend.target=bone;local out={};local rd=p._rd
 local function push(v)out[#out+1]=v end
 local function snap(status,result)
  push(status);for _,k in ipairs(keys)do push(scalar(p[k]))end;push(p._rd and array(p._rd)or'u');for _,k in ipairs({'dirty','layer','leftWeight','layerWeight','blendWeight'})do push(scalar(blend[k]))end;for _,k in ipairs({'x','y','rotation','skew','scaleX','scaleY'})do push(scalar(bone.animationPose[k]))end;push(scalar(bone._transformDirty));push(tostring(p.target==blend));push(tostring(blend.target==bone));push(tostring(result))
 end
 for _,time in ipairs({0,.125,.5,.75,1,1.25,-.25})do
  local ok=pcall(function()p:update(time)end);snap(ok and'ok'or'error','update');bone.animationPose.x=5;bone.animationPose.y=7;bone.animationPose.rotation=.1;bone.animationPose.skew=.2;bone.animationPose.scaleX=2;bone.animationPose.scaleY=3;bone._transformDirty=false;blend:reset();state.layer=2;state._weightResult=weight;if op=='cleanBlend'then p.dirty=false end;local accepted=blend:update(state);if accepted then p:blend(op~='cleanBlend')end;snap('blend',accepted);state.layer=layer;state._weightResult=.75;accepted=blend:update(state);if accepted then p:blend(false)end;snap('blend2',accepted);state.layer=-1;state._weightResult=.25;accepted=blend:update(state);if accepted then p:blend(false)end;snap('blend3',accepted);if op=='fadeOut'then p:fadeOut()end;if op=='reset'then blend:reset()end
 end
 p:fadeOut();snap('fade','none');blend:reset();snap('reset','none');p:returnToPool();blend:returnToPool();snap('clear','none');push(tostring(p._isInPool));push(tostring(blend._isInPool));push(tostring(p._rd==rd));for _,k in ipairs({'BONE_TRANSFORM','BONE_ALPHA','SURFACE','SLOT_DEFORM','SLOT_ALPHA','SLOT_Z_INDEX'})do push(Blend[k])end;td:returnToPool();arm:returnToPool();gd:returnToPool();return table.concat(out,'\t')
end
for line in io.lines(assert(arg[1]))do local c={};for v in(line..'\t'):gmatch('(.-)\t')do c[#c+1]=v end;print(execute(c))end
