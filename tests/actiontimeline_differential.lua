local T=require('dragonbones.animation.ActionTimelineState')
local Core=require('dragonbones.core.DragonBones')
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
local keys={'dirty','playState','currentPlayTimes','currentTime','_isTween','_frameOffset','_frameIndex','_frameCount','_position','_duration'}
local f=assert(io.open('examples/actiontimeline_ske.json','rb'));local fixture=f:read('*a');f:close()
local function execute(c)
 local frames,enabled,parent,reverse,play,listeners,reset,op=tonumber(c[1]),tonumber(c[2]),tonumber(c[3]),tonumber(c[4]),tonumber(c[5]),tonumber(c[6]),tonumber(c[7]),c[8]
 local raw=JSON.parse(fixture);if op=='precision'then raw.armature[1].animation[1].frame[1].duration=5;raw.armature[1].animation[1].frame[2].duration=6;raw.armature[1].animation[1].frame[3].duration=13 end;if frames==1 then raw.armature[1].animation[1].frame.length=1;raw.armature[1].animation[1].frame[1].duration=24 end
 local gd=Parser.new():parseDragonBonesData(raw);local ad=gd:getArmature('ik-demo');local arm=B.borrowObject(Arm);local p=B.borrowObject(T);arm._armatureData=ad;for i=1,ad.sortedBones.length do B.borrowObject(Bone):init(ad.sortedBones[i],arm)end
 local Observer={__newindex=Slot.__newindex};Observer.__index=function(self,key)return rawget(Observer,key)or Slot.__index(self,key)end;setmetatable(Observer,{__index=Slot})
 function Observer.toString()return'[test.ActionSlot]'end
 function Observer.new()return Slot.new(Observer)end
 function Observer:_initDisplay()end
 function Observer:_disposeDisplay()end
 function Observer:_onUpdateDisplay()end
 function Observer:_addDisplay()end
 B.clearPool(Observer);for i=1,ad.sortedSlots.length do B.borrowObject(Observer):init(ad.sortedSlots[i],arm,nil,nil)end
 local foreign;local anim=ad:getAnimation('events');if op=='foreign'then local r=JSON.parse(fixture);r.armature[1].animation[1].frame[2].event='foreign-step';foreign=Parser.new():parseDragonBonesData(r);anim=foreign:getArmature('ik-demo'):getAnimation('events')end
 local actions=anim.parent.actions;local checks,localEvents,globalEvents={},{},{};local clears=0
 local state={animationData=anim,_actionTimeline=p,_position=op=='interval'and .25 or 0,_duration=op=='interval'and .5 or 1,playTimes=play,currentPlayTimes=0,_playheadState=3,_parent=parent==1 and{}or nil,actionEnabled=enabled==1,displayControl=op~='displayControlOff',resetToPose=reset==1,timeScale=reverse==1 and -1 or 1}
 local function event(e)
  local index=-1;for i=1,actions.length do if actions[i]==e.actionData then index=i-1;break end end
  local same;if e.actionData then same=e.data==e.actionData.data else same=e.data==nil end
  return table.concat({e.type,e.name,scalar(e.time),tostring(e.armature==arm),tostring(e.animationState==state),tostring(index),e.bone and e.bone.name or'nil',e.slot and e.slot.name or'nil',tostring(same),tostring(e._isInPool)},'~')
 end
 local proxy={}
 function proxy:hasDBEventListener(kind)checks[#checks+1]=kind;return listeners==1 or listeners==2 and kind=='frameEvent'or listeners==3 and kind~='frameEvent'end
 function proxy:dispatchDBEvent(kind,e)localEvents[#localEvents+1]=event(e)end
 function proxy:dbClear()clears=clears+1 end
 local manager={};function manager:dispatchDBEvent(kind,e)globalEvents[#globalEvents+1]=event(e)end
 local savedPrint=print;_G.print=function()end;local core=Core.new(manager);_G.print=savedPrint
 arm._dragonBones=core;if op~='missingProxy'then arm._proxy=proxy end;arm:_sortZOrder(arr({2,0,1}),0);local td;if frames~=0 then td=anim.actionTimeline end;p:init(arm,state,td);local out={};local function push(v)out[#out+1]=v end
 local function events(a,n)local o={};for i=1,n do o[i]=event(a[i])end;return table.concat(o,'|')end
 local function snap(status)
  push(status);for _,k in ipairs(keys)do push(scalar(p[k]))end;push(tostring(arm.eventDispatcher==proxy));push(tostring(arm._zOrderDirty));push(tostring(arm._slotsDirty));local ranks={};for i=1,arm:getSlots().length do ranks[i]=scalar(arm:getSlots()[i]._zOrder)end;push(table.concat(ranks,','));push(tostring(#core._events));push(events(core._events,#core._events));push(tostring(arm._actions.length));push(events(arm._actions,arm._actions.length));push(tostring(#core._objects));push(events(core._objects,#core._objects));push(table.concat(checks,','));push(table.concat(localEvents,'|'));push(table.concat(globalEvents,'|'))
 end
 for i,time in ipairs({0.0,.125,.3,.6,1.1,2.1,2.1,.4})do
  checks,localEvents,globalEvents={},{},{};arm._slotsDirty=false;local ok=pcall(function()if op=='readonly'and i==1 then arm.eventDispatcher={}end;if op=='seek'and i==3 then p:setCurrentTime(.4)end;if op=='reinit'and i==3 then p:init(arm,state,nil)end;p:update((reverse==1 and -1.0 or 1.0)*time)end);snap(ok and'ok'or'error');ok=pcall(function()core:advanceTime(0)end);snap(ok and'dispatch'or'error')
 end
 if op=='clear'then p:_onClear()end;p:returnToPool();snap('clear');arm._proxy=proxy;core:advanceTime(0);arm:returnToPool();push(tostring(p._isInPool));push(tostring(clears));push(tostring(#core._events));push(tostring(#core._objects));push(tostring(arm._actions.length));push(tostring(p._armature==nil));if foreign then foreign:returnToPool()end;gd:returnToPool();return table.concat(out,'\t')
end
for line in io.lines(assert(arg[1]))do local c={};for v in(line..'\t'):gmatch('(.-)\t')do c[#c+1]=v end;print(execute(c))end
