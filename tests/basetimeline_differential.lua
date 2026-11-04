-- AnimationState fields below are an explicit test contract, not a player.
local T=require('dragonbones.animation.BaseTimelineState')
local B=require('dragonbones.core.BaseObject')
local D=require('dragonbones.model.DragonBonesData')
local M=require('dragonbones.model.ArmatureData')
local Anim=require('dragonbones.model.AnimationData')
local Arm=require('dragonbones.armature.Armature')
local Array=require('dragonbones.core.JSArray')
local Shared=require('dragonbones.parser.SharedBinaryBuffer')
local V=require('dragonbones.parser.JSValue')
local double
if string.pack then double=function(n)return string.pack('<d',n)end else local ffi=require('ffi');double=function(n)return ffi.string(ffi.new('double[1]',n),8)end end
local function scalar(v)if v==nil or rawequal(v,V.UNDEFINED)then return'u'end;if type(v)=='boolean'then return tostring(v)end;if v~=v then return'NaN'end;return'n'..(double(v):gsub('.',function(c)return string.format('%02x',c:byte())end))end
local function array(a)local out={};for i=1,a.length do out[#out+1]=rawget(a,i)==nil and'hole'or scalar(a[i])end;return a.length..':'..table.concat(out,',')end
local function arr(values)local a=Array.new();for i,v in ipairs(values)do a[i]=v end;return a end
local function typed(values,kind)local a=Shared.view(Shared.new(string.rep('\0',#values*(kind=='float32'and 4 or 2))),0,#values*(kind=='float32'and 4 or 2),kind);for i,v in ipairs(values)do a[i]=v end;return a end
local names={'TimelineState','TweenTimelineState','SingleValueTimelineState','DoubleValueTimelineState','MutilpleValueTimelineState'}
local keys={'dirty','playState','currentPlayTimes','currentTime','_isTween','_valueOffset','_frameValueOffset','_frameOffset','_frameRate','_frameCount','_frameIndex','_frameRateR','_position','_duration','_timeScale','_timeOffset','_tweenType','_curveCount','_framePosition','_frameDurationR','_tweenEasing','_tweenProgress','_valueScale','_current','_difference','_result','_currentA','_currentB','_differenceA','_differenceB','_resultA','_resultB','_valueCount'}
local times={-1,-.25,0,.125,.5,.75,1,1.25,2}
local function execute(c)
 local cls,frames,tween,play,action,scale,offset,valueScale,head,op=tonumber(c[1]),tonumber(c[2]),tonumber(c[3]),tonumber(c[4]),tonumber(c[5]),tonumber(c[6]),tonumber(c[7]),tonumber(c[8]),tonumber(c[9]),c[10]
 if op=='helper'then return scalar(cls==0 and T.TweenTimelineState._getEasingValue(tween,scale,offset)or T.TweenTimelineState._getEasingCurveValue(scale,arr({999,2500,7500,999}),tween-1,1))end
 local Parent=T[names[cls+1]];local Probe={};Probe.__index=Probe;setmetatable(Probe,{__index=Parent})
 function Probe.toString()return'[test.BaseTimelineProbe]'end
 function Probe.new()return Parent.new(Probe)end
 function Probe:_onArriveAtFrame()self.arrives=self.arrives+1;if cls~=0 then Parent._onArriveAtFrame(self)else self.dirty=true end end
 function Probe:_onUpdateFrame()self.updates=self.updates+1;if cls~=0 then Parent._onUpdateFrame(self)end end
 B.clearPool(Probe);local p=B.borrowObject(Probe);p.arrives,p.updates=0,0
 local gd=B.borrowObject(D);local ad=B.borrowObject(M.ArmatureData);local anim=B.borrowObject(Anim.AnimationData);local td=B.borrowObject(Anim.TimelineData);local arm=B.borrowObject(Arm)
 ad.name='arm';gd:addArmature(ad);anim.name='anim';ad:addAnimation(anim);arm._armatureData=ad;ad.frameRate=op=='zeroRate'and 0 or 4;anim.duration=1;anim.frameOffset=2;td.offset=3;td.frameIndicesOffset=2
 local curveCount=op=='curveZero'and 0 or op=='curveNegative'and -2 or 2
 gd.frameArray=typed({99,99,0,tween,tween==2 and curveCount or 50,2500,7500,1,tween,tween==2 and curveCount or 75,2500,7500,op=='zeroSpan'and 1 or 3,tween,tween==2 and curveCount or 100,2500,7500},'int16')
 gd.timelineArray=typed({99,99,99,op=='zeroScale'and 0 or scale,offset,frames,4,1,0,5,10},'uint16');gd.frameIndices=arr({99,99,0,1,1,2,2,2})
 local values=typed({99,1,3,5,7,11,13,17,19,23,29,31,37},'float32')
 local state={animationData=anim,_actionTimeline=action~=0 and p or nil,_position=0,_duration=op=='zeroDuration'and 0 or 1,playTimes=play,currentPlayTimes=0,_playheadState=head}
 local driver=B.borrowObject(Probe);driver.arrives,driver.updates=0,0;local ds={};for k,v in pairs(state)do ds[k]=v end;ds._actionTimeline=nil;driver:init(arm,ds,nil)
 if action==0 then state._actionTimeline=driver end;if op=='noAction'then state._actionTimeline=nil end
 local timeline=nil;if frames~=0 then timeline=td end;p:init(arm,state,timeline);p._valueArray=values;p._valueScale=valueScale;if cls==4 then p._valueCount=4 end
 local rd=p._rd;local out={};local function push(v)out[#out+1]=v end
 local function snap(status)
  push(status);for _,k in ipairs(keys)do push(scalar(p[k]))end;push(p._rd and array(p._rd)or'u');push(tostring(p.arrives));push(tostring(p.updates));push(tostring(p._armature==arm));push(tostring(p._animationState==state));push(tostring(p._timelineData==(frames~=0 and td or nil)));push(tostring(p._actionTimeline==driver));push(tostring(p._frameArray==gd.frameArray));push(tostring(p._timelineArray==gd.timelineArray));push(tostring(p._frameIndices==gd.frameIndices))
 end
 for i,time in ipairs(times)do
  local ok=pcall(function()driver:_setCurrentTime(time);state.currentPlayTimes=driver.currentPlayTimes;if op=='fadeOut'and i==5 then p:fadeOut()end;if op=='reinit'and i==5 then p:init(arm,state,nil)end;if op=='blend'then p:blend(true)end;p:update(time)end);snap(ok and'ok'or'error')
 end
 if op=='clear'then p:_onClear()end;p:fadeOut();snap('final');p:returnToPool();for _,k in ipairs(keys)do push(scalar(p[k]))end;push(p._rd and array(p._rd)or'u');push(tostring(p._rd==rd));push(tostring(p._isInPool));driver:returnToPool();td:returnToPool();arm:returnToPool();gd:returnToPool();return table.concat(out,'\t')
end
for line in io.lines(assert(arg[1]))do local c={};for v in(line..'\t'):gmatch('(.-)\t')do c[#c+1]=v end;print(execute(c))end
