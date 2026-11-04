local T=require('dragonbones.animation.SlotTimelineState')
local Slot=require('dragonbones.armature.Slot')
local Color=require('dragonbones.geom.ColorTransform')
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
local names={'AlphaTimelineState','SlotDisplayTimelineState','SlotColorTimelineState','SlotZIndexTimelineState'}
local keys={'dirty','playState','currentPlayTimes','currentTime','_isTween','_frameOffset','_frameIndex','_tweenType','_framePosition','_frameDurationR','_tweenProgress','_valueScale'}
local colors={'alphaMultiplier','redMultiplier','greenMultiplier','blueMultiplier','alphaOffset','redOffset','greenOffset','blueOffset'}
local function execute(c)
 local cls,pose,tween,fade,weight,variant,op=tonumber(c[1]),tonumber(c[2]),tonumber(c[3]),tonumber(c[4]),tonumber(c[5]),tonumber(c[6]),c[7]
 local gd=B.borrowObject(D);local ad=B.borrowObject(M.ArmatureData);local anim=B.borrowObject(Anim.AnimationData);local td=B.borrowObject(Anim.TimelineData);local bd=B.borrowObject(M.BoneData);local sd=B.borrowObject(M.SlotData);local arm=B.borrowObject(Arm);local bone=B.borrowObject(Bone);local blend=B.borrowObject(Blend);local p=B.borrowObject(T[names[cls+1]])
 local Observer={};Observer.__index=Observer;Observer.__newindex=Slot.__newindex;setmetatable(Observer,{__index=Slot})
 -- Slot getters require delegation through the function __index.
 Observer.__index=function(self,key)return rawget(Observer,key)or Slot.__index(self,key)end
 function Observer.toString()return'[test.SlotTimelineObserver]'end
 function Observer.new()return Slot.new(Observer)end
 function Observer:_initDisplay()end
 function Observer:_disposeDisplay()end
 function Observer:_onUpdateDisplay()end
 function Observer:_addDisplay()end
 B.clearPool(Observer);local slot=B.borrowObject(Observer)
 ad.name='arm';gd:addArmature(ad);anim.name='anim';ad:addAnimation(anim);ad.frameRate=4;anim.duration=1;anim.frameOffset=2;anim.frameIntOffset=2;td.offset=3;td.frameIndicesOffset=2;bd.name='bone';ad:addBone(bd);sd.name='slot';sd.parent=bd;sd.displayIndex=1;sd.zIndex=3;sd.color=Color.new(.8,.7,.6,.5,1,2,3,4);ad:addSlot(sd);arm._armatureData=ad;bone:init(bd,arm);slot:init(sd,arm,nil,nil);slot.displayFrameCount=3;slot:_setDisplayIndex(1);slot:_updateDisplayData()
 gd.frameArray=typed({99,99,0,cls==1 and 0 or tween,tween==2 and 2 or 50,2500,7500,1,cls==1 and 2 or tween,tween==2 and 2 or 75,2500,7500,3,cls==1 and -1 or tween,tween==2 and 2 or 100,2500,7500},'int16');gd.timelineArray=typed({99,99,99,100,0,op=='single'and 1 or 3,1,1,0,5,10},'uint16');gd.frameIndices=arr({99,99,0,1,1,2,2,2})
 local values=cls==2 and{op=='negativeColorOffset'and -8 or 0,8,16}or cls==0 and{150,20,-50}or{2,-3,7};gd.frameIntArray=typed({99,99,99,values[1],values[2],values[3]},'int16')
 local colorCount=op=='negativeColorOffset'and 65536 or 24;gd.colorArray=Shared.view(Shared.new(string.rep('\0',colorCount*2)),0,colorCount*2,'int16');for i,row in ipairs({{100,80,60,40,1,2,3,4},{20,40,60,80,-10,20,-30,40},{150,125,75,50,100,-100,50,-50}})do for j,v in ipairs(row)do local base=op=='negativeColorOffset'and i==1 and 65528 or(i-1)*8;gd.colorArray[base+j]=v end end
 -- Input fields only: this is not an AnimationState implementation.
 local state={animationData=anim,_position=0,_duration=1,playTimes=op=='lastLoop'and 1 or 0,currentPlayTimes=0,_playheadState=op=='stopped'and 0 or 3,layer=2,_weightResult=weight,_fadeState=fade==1 and -1 or 0,_subFadeState=fade==2 and 1 or 0,_fadeProgress=variant~=0 and .75 or .5}
 p.target=(cls==1 or cls==2)and slot or blend;blend.target=cls==0 and variant~=0 and bone or slot;local tdArg;if pose==0 then tdArg=td end;p:init(arm,state,tdArg);local buffers={p._current,p._difference,p._result};local out={}
 local function push(v)out[#out+1]=v end
 local function snap(status,result)
  push(status);for _,k in ipairs(keys)do push(scalar(p[k]))end;for _,k in ipairs({'_current','_difference','_result'})do push(type(p[k])=='table'and array(p[k])or scalar(p[k]))end;for _,k in ipairs({'dirty','layer','leftWeight','layerWeight','blendWeight'})do push(scalar(blend[k]))end;push(scalar(slot._alpha));push(scalar(bone._alpha));push(scalar(slot._zIndex));push(scalar(slot.displayIndex));push(scalar(slot._animationDisplayIndex));push(scalar(slot._displayDirty));push(scalar(slot._colorDirty));for _,k in ipairs(colors)do push(scalar(slot._colorTransform[k]))end;push(scalar(arm._alphaDirty));push(scalar(arm._zIndexDirty));push(tostring(p.target==((cls==1 or cls==2)and slot or blend)));push(tostring(result))
 end
 for _,time in ipairs({0,.125,.5,.75,1,1.25,-.25})do
  slot._colorDirty=false;slot._displayDirty=false;arm._alphaDirty=false;arm._zIndexDirty=false;local ok=pcall(function()p:update(time)end);snap(ok and'ok'or'error','update');if cls==0 or cls==3 then blend:reset();state.layer=2;state._weightResult=weight;if op=='cleanBlend'then p.dirty=false end;local accepted=blend:update(state);if accepted then p:blend(op~='cleanBlend')end;snap('blend',accepted);state.layer=variant~=0 and 2 or 1;state._weightResult=.75;accepted=blend:update(state);if accepted then p:blend(false)end;snap('blend2',accepted)end;if op=='fadeOut'then p:fadeOut()end;if op=='reset'then blend:reset()end
 end
 p:fadeOut();snap('fade','none');p:returnToPool();blend:returnToPool();snap('clear','none');push(tostring(p._isInPool));push(tostring(blend._isInPool));for i,k in ipairs({'_current','_difference','_result'})do push(tostring(buffers[i]==p[k]))end;td:returnToPool();arm:returnToPool();gd:returnToPool();return table.concat(out,'\t')
end
for line in io.lines(assert(arg[1]))do local c={};for v in(line..'\t'):gmatch('(.-)\t')do c[#c+1]=v end;print(execute(c))end
