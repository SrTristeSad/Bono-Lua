local T=require('dragonbones.animation.AnimationTimelineState')
local Config=require('dragonbones.model.AnimationConfig')
local Core=require('dragonbones.core.DragonBones')
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
local function scalar(v)if v==nil then return'u'end;if type(v)=='string'then return's'..(v:gsub('.',function(c)return string.format('%02x',c:byte())end))end;if type(v)=='boolean'then return tostring(v)end;if v~=v then return'NaN'end;return'n'..(double(v):gsub('.',function(c)return string.format('%02x',c:byte())end))end
local function array(a)local out={};for i=1,a.length do out[#out+1]=rawget(a,i)==nil and'hole'or scalar(a[i])end;return a.length..':'..table.concat(out,',')end
local function arr(values)local a=Array.new();for i,v in ipairs(values)do a[i]=v end;return a end
local function typed(values,kind)local bytes=#values*(kind=='float32'and 4 or 2);local a=Shared.view(Shared.new(string.rep('\0',bytes)),0,bytes,kind);for i,v in ipairs(values)do a[i]=v end;return a end
local keys={'resetToPose','additive','displayControl','actionEnabled','blendType','layer','playTimes','timeScale','fadeTotalTime','autoFadeOutTime','name','group','_weight','_playheadState','_position','_duration','_time','_fadeProgress','_fadeTime','_fadeState','_subFadeState','_timelineDirty'}
local getters={'isFadeIn','isFadeOut','isFadeComplete','isPlaying','isCompleted','currentPlayTimes','totalTime','currentTime','weight'}
local f=assert(io.open('examples/stateinit_ske.json','rb'));local fixture=f:read('*a');f:close()
local function execute(c)
 local rate,position,duration,fade,pause,weight,profile,op=tonumber(c[1]),tonumber(c[2]),tonumber(c[3]),tonumber(c[4]),tonumber(c[5]),tonumber(c[6]),tonumber(c[7]),c[8]
 local raw=JSON.parse(fixture);if op=='noZOrder'then raw.armature[1].animation[1].zOrder=nil end;raw.armature[1].animation[1].blendType=profile%2==1 and'1d'or'none';local gd=Parser.new():parseDragonBonesData(raw);local ad=gd:getArmature('demo');local anim=ad:getAnimation('controller');local arm=B.borrowObject(Arm);local s=B.borrowObject(State);local child=B.borrowObject(State);local external=B.borrowObject(State);local cfg=B.borrowObject(Config);local cc=B.borrowObject(Config);arm._armatureData=ad;for i=1,ad.sortedBones.length do B.borrowObject(Bone):init(ad.sortedBones[i],arm)end
 local Observer={__newindex=Slot.__newindex};Observer.__index=function(self,key)return rawget(Observer,key)or Slot.__index(self,key)end;setmetatable(Observer,{__index=Slot})
 function Observer.toString()return'[test.StateInitSlot]'end
 function Observer.new()return Slot.new(Observer)end
 function Observer:_initDisplay()end
 function Observer:_disposeDisplay()end
 function Observer:_onUpdateDisplay()end
 function Observer:_addDisplay()end
 B.clearPool(Observer);for i=1,ad.sortedSlots.length do B.borrowObject(Observer):init(ad.sortedSlots[i],arm,nil,nil)end
 local checks,dispatch={},{};local clears=0;local proxy={}
 function proxy:hasDBEventListener(kind)checks[#checks+1]=kind;return profile~=3 end
 function proxy:dispatchDBEvent(kind,e)dispatch[#dispatch+1]=table.concat({kind,e.animationState==s and'parent'or'child',scalar(e.time)},'~')end
 function proxy:dbClear()clears=clears+1 end
 local manager={};function manager:dispatchDBEvent()error('Unexpected sound')end
 local saved=print;_G.print=function()end;local core=Core.new(manager);_G.print=saved;arm._proxy=proxy;arm._dragonBones=core
 cfg.animation='controller';cfg.name=profile%2==1 and''or'custom';cfg.group='group';cfg.layer=profile-1;cfg.position=position;cfg.duration=duration;cfg.timeScale=rate;cfg.playTimes=profile%3;cfg.fadeInTime=fade;cfg.pauseFadeIn=pause==1;cfg.weight=weight;cfg.autoFadeOutTime=.25;cfg.actionEnabled=profile~=1;cfg.resetToPose=profile%2==0;cfg.displayControl=true;cfg.additive=profile==2;for i,name in ipairs(({{},{'branch'},{'missing','branch'},{}})[profile+1])do cfg.boneMask[i]=name end
 cc.animation='child';cc.timeScale=1;cc.playTimes=1;cc.fadeInTime=0;cc.duration=-1;cc.pauseFadeIn=false;child:init(arm,ad:getAnimation('child'),cc);child._boneTimelines[1]=B.borrowObject(SlotTimelines.AlphaTimelineState);local childProbe=child._boneTimelines[1];childProbe.dirty=true
 local out,refs={},{};local function push(v)out[#out+1]=tostring(v)end
 local function read(fn)local ok,v=pcall(fn);return ok and scalar(v)or'getter-error'end
 local function event(e)return table.concat({e.type,e.animationState==s and'parent'or'child',scalar(e.time),tostring(e.armature==arm),tostring(e._isInPool)},'~')end
 local function snap(status)
  push(status);for _,k in ipairs(keys)do push(scalar(s[k]))end;for _,k in ipairs(getters)do push(read(function()return s[k]end))end;local a,b={},{};for i=1,s._boneMask.length do a[i]=scalar(s._boneMask[i])end;for i=1,cfg.boneMask.length do b[i]=scalar(cfg.boneMask[i])end;push(table.concat(a,','));push(table.concat(b,','));push(s._boneMask~=cfg.boneMask);for _,name in ipairs({'root','branch','tip','other','missing'})do push(s:containsBoneMask(name))end;for _,t in ipairs(refs)do push(scalar(t.dirty));push(scalar(t._isTween));push(scalar(t.currentTime));push(scalar(t._resultA));push(scalar(t._resultB));push(t._isInPool)end;push(s._animationTimelines.length);local tim={};for i=1,s._animationTimelines.length do local t=s._animationTimelines[i];tim[i]=table.concat({t.constructor.toString(),tostring(t.target==child),tostring(t._animationState==s),tostring(t._isInPool),scalar(t._valueScale)},'~')end;push(table.concat(tim,'|'));for _,k in ipairs({'_parent','_fadeState','_subFadeState','_playheadState','_fadeProgress','fadeTotalTime','_fadeTime','_weight','positionX','positionY'})do if k=='_parent'then push(child._parent==s and'parent'or child._parent==external and'external'or'nil')else push(scalar(child[k]))end end;push(scalar(childProbe.dirty));push(scalar(childProbe._isInPool));push(s._parent==external);if s._actionTimeline then push(s._actionTimeline._isInPool)else push('nil')end;push(s._zOrderTimeline~=nil);for _,k in ipairs({'currentTime','playState','_frameIndex'})do push(s._actionTimeline and scalar(s._actionTimeline[k])or'nil')end;push(#core._events);local events={};for i,e in ipairs(core._events)do events[i]=event(e)end;push(table.concat(events,'|'));push(#core._objects);push(table.concat(checks,','));push(table.concat(dispatch,','));push(s.animationData==anim);push(s._armature==arm)
 end
 local function stage(fn)checks,dispatch={},{};local ok=pcall(fn);snap(ok and'ok'or'error');core:advanceTime(0);snap('dispatch')end
 stage(function()s:init(arm,anim,cfg)end);local action,zorder,mask=s._actionTimeline,s._zOrderTimeline,s._boneMask;if profile==2 then s._parent=external end
 for _,item in ipairs({{'_boneTimelines',BoneTimelines.BoneRotateTimelineState},{'_boneBlendTimelines',SlotTimelines.AlphaTimelineState},{'_slotTimelines',SlotTimelines.SlotColorTimelineState},{'_slotBlendTimelines',SlotTimelines.SlotZIndexTimelineState},{'_constraintTimelines',Order.IKConstraintTimelineState}})do local key,class=item[1],item[2];local t=B.borrowObject(class);t.dirty=true;t._isTween=true;t.currentTime=.25;if key=='_boneTimelines'then t._resultA=9;t._resultB=-8 end;s[key][1]=t;refs[#refs+1]=t end;s._poseTimelines[1]=refs[1]
 stage(function()if op=='reinit'then cfg.name='changed';s:init(arm,ad:getAnimation('child'),cfg)end;if op=='foreignParent'or op=='addNone'or op=='addOnlyWeight'then child._parent=external end;local data=anim:getAnimationTimelines('child');local selected=data;if op=='addNone'then selected=nil elseif op=='addOnlyWeight'then selected=arr({data[2]})end;s:addState(child,selected);if op=='addRepeated'then s:addState(child,data)end;if op=='readonly'then s.isPlaying=false end;if op=='completed'then action.playState=1 end end)
 stage(function()local recursive;if op=='maskNonRecursive'then recursive=false end;s:addBoneMask(op=='missingMask'and'absent'or'branch',recursive)end);stage(function()s:removeBoneMask('root')end);stage(function()s:removeAllBoneMask();s:removeBoneMask('branch');s:activeTimeline()end);stage(function()s:stop()end);stage(function()s:play()end)
 if op=='bitwise'then for _,value in ipairs({0/0,math.huge,-1,4294967298,3.75,-4294967297})do stage(function()s._playheadState=value;s:stop()end)end end
 for _,delta in ipairs({0,.125,-.125,.5})do stage(function()s:_advanceFadeTime(delta);if op=='earlyFade'then s:fadeOut(.5,false)end end)end
 stage(function()if op=='defaultArgs'then s:fadeOut(.5)else s:fadeOut(.5,pause==1)end end);stage(function()s:fadeOut(1)end);stage(function()s:_advanceFadeTime(.125)end);stage(function()s:fadeOut(op=='negativeFade'and -.125 or .125,false)end);stage(function()s:_advanceFadeTime(.25)end)
 core:advanceTime(0);s:returnToPool();snap('clear');push(s._isInPool);push(mask==s._boneMask);push(action._isInPool);if zorder then push(zorder._isInPool)else push('nil')end;push(child._parent==s);child:returnToPool();push(childProbe._isInPool);external:returnToPool();cfg:returnToPool();cc:returnToPool();arm:returnToPool();push(clears);push(#core._events);push(#core._objects);gd:returnToPool();return table.concat(out,'\t')
end
for line in io.lines(assert(arg[1]))do local c={};for v in(line..'\t'):gmatch('(.-)\t')do c[#c+1]=v end;print(execute(c))end
