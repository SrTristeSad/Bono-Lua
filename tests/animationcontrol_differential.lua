local T=require('dragonbones.animation.AnimationTimelineState')
local State=require('dragonbones.animation.AnimationState')
local Action=require('dragonbones.animation.ActionTimelineState')
local BoneTimelines=require('dragonbones.animation.BoneTimelineState')
local SlotTimelines=require('dragonbones.animation.SlotTimelineState')
local Order=require('dragonbones.animation.ConstraintOrderTimelineState')
local Slot=require('dragonbones.armature.Slot')
local IK=require('dragonbones.armature.IKConstraint')
local Parser=require('dragonbones.parser.ObjectDataParser')
local JSON=require('dragonbones.parser.JSON')
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
local names={'AnimationProgressTimelineState','AnimationWeightTimelineState','AnimationParametersTimelineState'}
local fields={'_boneMask','_boneTimelines','_boneBlendTimelines','_slotTimelines','_slotBlendTimelines','_constraintTimelines','_animationTimelines','_poseTimelines'}
local keys={'dirty','playState','currentPlayTimes','currentTime','_frameIndex','_isTween','_valueScale','_current','_difference','_result','_currentA','_currentB','_differenceA','_differenceB','_resultA','_resultB'}
local f=assert(io.open('examples/animationcontrol_ske.json','rb'));local fixture=f:read('*a');f:close()
local function execute(c)
 local cls,pose,attached,tween,duration,play,reverse,op=tonumber(c[1]),tonumber(c[2]),tonumber(c[3]),tonumber(c[4]),tonumber(c[5]),tonumber(c[6]),tonumber(c[7]),c[8]
 local gd=Parser.new():parseDragonBonesData(JSON.parse(fixture));local ad=gd:getArmature('demo');local anim=ad:getAnimation('controller');local childData=ad:getAnimation('child');local td=B.borrowObject(Anim.TimelineData);local arm=B.borrowObject(Arm);local parent=B.borrowObject(State);local child=B.borrowObject(State);local grand=B.borrowObject(State);local p=B.borrowObject(T[names[cls+1]]);arm._armatureData=ad
 local function setup(s,data,dur,plays)s._animationData=data;s._armature=arm;s._position=0;s._duration=dur;s.playTimes=plays;s._playheadState=3;s._actionTimeline=B.borrowObject(Action);s._actionTimeline:init(arm,s,nil)end
 setup(parent,anim,1,play);setup(child,childData,duration,2);if op=='foreignParent'then child._parent=grand elseif attached==1 then child._parent=parent end;child._time=.2;child._actionTimeline:setCurrentTime(.2);child.parameterX=7;child.parameterY=9
 local classes={BoneTimelines.BoneTranslateTimelineState,SlotTimelines.AlphaTimelineState,SlotTimelines.SlotDisplayTimelineState,SlotTimelines.SlotZIndexTimelineState,Order.IKConstraintTimelineState,T.AnimationWeightTimelineState};local probes={};for i,class in ipairs(classes)do probes[i]=B.borrowObject(class);child[fields[i+1]][1]=probes[i]end;probes[6].target=grand;grand._parent=op=='foreignParent'and parent or child;child._poseTimelines[1]=probes[1];child._boneMask[1]='root';child._zOrderTimeline=B.borrowObject(Order.ZOrderTimelineState);local childAction,childOrder,parentAction=child._actionTimeline,child._zOrderTimeline,parent._actionTimeline;local arrays={};for i,k in ipairs(fields)do arrays[i]=child[k]end
 anim.frameOffset=2;anim.frameIntOffset=2;ad.frameRate=4;td.offset=3;td.frameIndicesOffset=2;gd.frameArray=typed({99,99,0,tween,tween==2 and 2 or 50,2500,7500,1,tween,tween==2 and 2 or 75,2500,7500,3,tween,tween==2 and 2 or 100,2500,7500},'int16');gd.timelineArray=typed({99,99,99,100,0,3,cls==2 and 2 or 1,1,0,5,10},'uint16');gd.frameIndices=arr({99,99,0,1,1,2,2,2});gd.frameIntArray=typed({99,99,99,-5000,12500,2500,-7500,15000,0},'int16');p.target=child;local tdArg;if pose==0 then tdArg=td end;p:init(arm,parent,tdArg);parent._animationTimelines[1]=p;local out={};local function push(v)out[#out+1]=v end
 local function read(fn)local ok,v=pcall(fn);return ok and scalar(v)or'getter-error'end
 local function snap(status)
  push(status);for _,k in ipairs(keys)do push(scalar(p[k]))end;for _,k in ipairs({'_time','_weight','parameterX','parameterY','_fadeState','_subFadeState'})do push(scalar(child[k]))end;push(read(function()return child.currentTime end));push(read(function()return child.currentPlayTimes end));push(read(function()return child.totalTime end));push(read(function()return child.weight end));push(tostring(child.animationData==childData));push(tostring(child._parent==parent));for _,t in ipairs(probes)do push(scalar(t.playState));push(scalar(t.dirty));push(tostring(t._isInPool))end;push(scalar(childOrder.playState));push(scalar(childAction.currentTime));push(scalar(childAction.currentPlayTimes));push(scalar(childAction._frameIndex));push(tostring(childAction._isInPool));push(tostring(childOrder._isInPool));push(tostring(p._isInPool));for _,k in ipairs(fields)do push(tostring(child[k].length))end;for i,k in ipairs(fields)do push(tostring(arrays[i]==child[k]))end;push(scalar(grand._fadeState));push(scalar(grand._subFadeState));push(tostring(grand._parent==nil))
 end
 for i,time in ipairs({0,.125,.5,.5,.75,1,1.25,-.25})do
  for _,t in ipairs(probes)do t.playState=7;t.dirty=false end;childOrder.playState=7
  local ok=pcall(function()if op=='detach'and i==3 then child._parent=nil end;if op=='negativeZero'and i==1 then child.weight=-0.0 end;parentAction:_setCurrentTime((reverse==1 and -1.0 or 1.0)*time);p:update((reverse==1 and -1.0 or 1.0)*time);if op=='seekNegative'then child.currentTime=-.25 end;if op=='seekBeyond'then child.currentTime=3.25 end;if op=='seekEnd'then child._parent=nil;child.playTimes=1;childAction.currentPlayTimes=1;childAction.playState=1;child.currentTime=child.totalTime end;if op=='seekSame'then child.currentTime=child._time end;if op=='weightSame'then child.weight=child.weight end;if op=='readonly'then child.animationData=nil end end);snap(ok and'ok'or'error')
 end
 parent:returnToPool();snap('parentClear');child:returnToPool();snap('childClear');push(tostring(parent._isInPool));push(tostring(child._isInPool));push(tostring(parentAction._isInPool));push(tostring(child._poseTimelines.length));push(tostring(grand._parent==parent));grand:returnToPool();td:returnToPool();arm:returnToPool();gd:returnToPool();return table.concat(out,'\t')
end
for line in io.lines(assert(arg[1]))do local c={};for v in(line..'\t'):gmatch('(.-)\t')do c[#c+1]=v end;print(execute(c))end
