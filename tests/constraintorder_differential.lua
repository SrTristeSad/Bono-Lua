local T=require('dragonbones.animation.ConstraintOrderTimelineState')
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
local names={'IKConstraintTimelineState','ZOrderTimelineState'}
local keys={'dirty','playState','currentPlayTimes','currentTime','_isTween','_frameOffset','_frameIndex','_tweenProgress','_valueScale','_currentA','_currentB','_differenceA','_differenceB','_resultA','_resultB'}
local f=assert(io.open('examples/constraintorder_ske.json','rb'));local fixture=f:read('*a');f:close()
local function execute(c)
 local cls,pose,tween,play,head,variant,op=tonumber(c[1]),tonumber(c[2]),tonumber(c[3]),tonumber(c[4]),tonumber(c[5]),tonumber(c[6]),c[7]
 local raw=JSON.parse(fixture);raw.armature[1].ik[1].chain=variant%2;raw.armature[1].ik[1].bendPositive=variant<2;raw.armature[1].ik[1].weight=({-.5,0,1,1.5})[variant+1]
 local gd=Parser.new():parseDragonBonesData(raw);local ad=gd:getArmature('ik-demo');local anim=ad:getAnimation('change');local td=B.borrowObject(Anim.TimelineData);local arm=B.borrowObject(Arm);local ik=B.borrowObject(IK);local p=B.borrowObject(T[names[cls+1]]);arm._armatureData=ad;for i=1,ad.sortedBones.length do B.borrowObject(Bone):init(ad.sortedBones[i],arm)end;ik:init(ad:getConstraint('aim'),arm);arm:_addConstraint(ik)
 local Observer={__newindex=Slot.__newindex};Observer.__index=function(self,key)return rawget(Observer,key)or Slot.__index(self,key)end;setmetatable(Observer,{__index=Slot})
 function Observer.toString()return'[test.ConstraintOrderSlot]'end
 function Observer.new()return Slot.new(Observer)end
 function Observer:_initDisplay()end
 function Observer:_disposeDisplay()end
 function Observer:_onUpdateDisplay()end
 function Observer:_addDisplay()end
 B.clearPool(Observer);local slots={};for i=1,ad.sortedSlots.length do local slot=B.borrowObject(Observer);slot:init(ad.sortedSlots[i],arm,nil,nil);slots[i]=slot end;local missing;if op=='missingSlot'then missing=slots[2];arm._slots[2]=arm._slots[3];arm._slots.length=2 end
 anim.frameOffset=2;anim.frameIntOffset=2;anim.duration=1;ad.frameRate=4;td.offset=3;td.frameIndicesOffset=2;local order=({{2,0,1},{1,1,0},{-1,3,0},{1,0,2}})[variant+1]
 gd.frameArray=typed(cls==1 and{99,99,0,3,order[1],order[2],order[3],1,3,0,2,1,3,0,99,99,99}or{99,99,0,tween,tween==2 and 2 or 50,2500,7500,1,tween,tween==2 and 2 or 75,2500,7500,3,tween,tween==2 and 2 or 100,2500,7500},'int16');gd.timelineArray=typed({99,99,99,100,0,op=='single'and 1 or 3,2,1,0,5,10},'uint16');gd.frameIndices=arr({99,99,0,1,1,2,2,2});gd.frameIntArray=typed({99,99,99,100,100,0,25,-100,150},'int16')
 local state={animationData=anim,_position=0,_duration=1,playTimes=play,currentPlayTimes=0,_playheadState=head};p.target=ik;local tdArg;if pose==0 then tdArg=td end;p:init(arm,state,tdArg);local out={};local function push(v)out[#out+1]=v end
 local function snap(status)
  push(status);for _,k in ipairs(keys)do push(scalar(p[k]))end;push(scalar(ik._bendPositive));push(scalar(ik._weight));for _,name in ipairs({'upper','lower','target'})do local b=arm:getBone(name);for _,k in ipairs({'_transformDirty','_childrenTransformDirty','_localDirty','_hasConstraint'})do push(scalar(b[k]))end end;push(scalar(arm._slotsDirty));push(scalar(arm._zOrderDirty));for _,s in ipairs(slots)do push(scalar(s._zOrder));push(scalar(s._zOrderDirty))end;push(tostring(p.target==ik));push(tostring(ik._constraintData==ad:getConstraint('aim')))
 end
 for i,time in ipairs({0,.125,.5,.75,1,1.25,-.25})do
  arm._slotsDirty=false;for _,s in ipairs(slots)do s._zOrderDirty=false end;for _,name in ipairs({'upper','lower','target'})do arm:getBone(name)._transformDirty=false end
  local ok=pcall(function()p:update(time);if op:sub(1,4)=='sort'then local maps={sortDuplicate=arr({99,1,1,0}),sortBounds=arr({99,-1,3,0}),sortFractional=arr({99,0,.5,2}),sortAbsent=arr({99,0})};arm:_sortZOrder(maps[op],1)end;if op=='fadeOut'then p:fadeOut()end;if op=='reinit'and i==3 then p:init(arm,state,nil)end end);snap(ok and'ok'or'error')
 end
 if op=='clear'then p:_onClear()end;p:fadeOut();snap('final');p:returnToPool();snap('clear');push(tostring(p._isInPool));td:returnToPool();if missing then missing:returnToPool()end;arm:returnToPool();gd:returnToPool();return table.concat(out,'\t')
end
for line in io.lines(assert(arg[1]))do local c={};for v in(line..'\t'):gmatch('(.-)\t')do c[#c+1]=v end;print(execute(c))end
