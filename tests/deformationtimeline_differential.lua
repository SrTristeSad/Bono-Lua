local T=require('dragonbones.animation.DeformationTimelineState')
local Surface=require('dragonbones.armature.Surface')
local Slot=require('dragonbones.armature.Slot')
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
local function array(a)local out={};for i=1,a.length do out[#out+1]=rawget(a,i)==nil and'hole'or scalar(a[i])end;return string.format('%d',a.length)..':'..table.concat(out,',')end
local function arr(values)local a=Array.new();for i,v in ipairs(values)do a[i]=v end;return a end
local function typed(values,kind)local bytes=#values*(kind=='float32'and 4 or 2);local a=Shared.view(Shared.new(string.rep('\0',bytes)),0,bytes,kind);for i,v in ipairs(values)do a[i]=v end;return a end
local names={'SurfaceTimelineState','DeformTimelineState'}
local keys={'dirty','playState','currentPlayTimes','currentTime','_isTween','_frameOffset','_frameIndex','_tweenProgress','_valueScale','_valueCount','_deformCount','_deformOffset','_sameValueOffset'}
local file=assert(io.open('examples/deformation_ske.json','rb'));local fixture=file:read('*a');file:close()
local function execute(c)
 local cls,pose,tween,scale,weight,region,variant,op=tonumber(c[1]),tonumber(c[2]),tonumber(c[3]),tonumber(c[4]),tonumber(c[5]),tonumber(c[6]),tonumber(c[7]),c[8]
 local raw=JSON.parse(fixture);if cls==1 and variant==1 then local mesh=raw.armature[1].skin[1].slot[1].display[1];mesh.weights=arr({1,0,1,1,0,1,1,0,1});mesh.slotPose=arr({1,0,0,1,0,0});mesh.bonePose=arr({0,1,0,0,1,0,0})end
 local gd=Parser.new():parseDragonBonesData(raw,scale);local ad=gd:getArmature('surface-demo');local anim=ad:getAnimation('deform');local td=B.borrowObject(Anim.TimelineData);local arm=B.borrowObject(Arm);local blend=B.borrowObject(Blend);local p=B.borrowObject(T[names[cls+1]]);arm._armatureData=ad;for i=1,ad.sortedBones.length do local bd=ad.sortedBones[i];B.borrowObject(bd.type==1 and Surface or Bone):init(bd,arm)end;local surface=arm:getBone('grid')
 local Observer={__newindex=Slot.__newindex};Observer.__index=function(self,key)return rawget(Observer,key)or Slot.__index(self,key)end;setmetatable(Observer,{__index=Slot})
 function Observer.toString()return'[test.DeformationSlotObserver]'end
 function Observer.new()return Slot.new(Observer)end
 function Observer:_initDisplay()end
 function Observer:_disposeDisplay()end
 function Observer:_onUpdateDisplay()end
 function Observer:_addDisplay()end
 B.clearPool(Observer);local slot=B.borrowObject(Observer);slot:init(ad:getSlot('slot'),arm,nil,nil);slot.displayFrameCount=1;slot:replaceRawDisplayData(ad.defaultSkin:getDisplay('slot','mesh'),0);slot:_setDisplayIndex(0);slot:_updateDisplayData();local frame=slot:getDisplayFrameAt(0);frame:updateDeformVertices();if variant==1 then slot._geometryData=ad.defaultSkin:getDisplay('slot','other').geometry end
 local count=cls==1 and frame.deformVertices.length or surface._deformVertices.length;local reg=({{0,0},{0,2},{2,2},{0,6}})[region+1];local off,n=reg[1],reg[2];anim.frameOffset=2;anim.frameIntOffset=2;anim.frameFloatOffset=2;anim.duration=1;ad.frameRate=4;td.offset=3;td.frameIndicesOffset=2
 gd.frameArray=typed({99,99,0,tween,tween==2 and 2 or 50,2500,7500,1,tween,tween==2 and 2 or 75,2500,7500,3,tween,tween==2 and 2 or 100,2500,7500},'int16');gd.timelineArray=typed({99,99,99,100,0,op=='single'and 1 or 3,1,1,0,5,10},'uint16');gd.frameIndices=arr({99,99,0,1,1,2,2,2});gd.frameIntArray=typed({99,99,99,0,count,n,off,op=='negativeOffset'and -8 or 32},'int16');local size=op=='negativeOffset'and 65560 or 100;gd.frameFloatArray=Shared.view(Shared.new(string.rep('\0',size*4)),0,size*4,'float32');for i=0,3*n-1 do gd.frameFloatArray[4+i]=(i+1)*1.25 end;for i=0,count-n-1 do gd.frameFloatArray[(op=='negativeOffset'and 65530 or 34)+i+1]=100+i end
 -- Explicit field contract until AnimationState is ported.
 local state={animationData=anim,_position=0,_duration=1,playTimes=op=='lastLoop'and 1 or 0,currentPlayTimes=0,_playheadState=op=='stopped'and 0 or 3,layer=2,_weightResult=weight};blend.target=cls==1 and slot or surface;p.target=blend;if cls==1 and op~='missingFrame'then p.displayFrame=frame end;local rd=p._rd;local out={}
 local function push(v)out[#out+1]=v end
 local function snap(status,result)
  push(status);for _,k in ipairs(keys)do push(scalar(p[k]))end;push(array(p._rd));push(array(surface._deformVertices));push(array(frame.deformVertices));for _,k in ipairs({'dirty','layer','leftWeight','layerWeight','blendWeight'})do push(scalar(blend[k]))end;push(scalar(surface._transformDirty));push(scalar(slot._verticesDirty));push(tostring(p.target==blend));push(tostring(p.displayFrame==frame));push(tostring(slot._geometryData==frame:getGeometryData()));push(tostring(result))
 end
 local tdArg;if pose==0 then tdArg=td end;local init=pcall(function()p:init(arm,state,tdArg)end);snap(init and'ok'or'error','init')
 for _,time in ipairs({0,.125,.5,.75,1,1.25,-.25})do
  local ok=pcall(function()p:update(time)end);snap(ok and'ok'or'error','update');surface._transformDirty=false;slot._verticesDirty=false;blend:reset();state.layer=2;state._weightResult=weight;if op=='cleanBlend'then p.dirty=false end;local accepted=blend:update(state);ok=pcall(function()if accepted then p:blend(op~='cleanBlend')end end);snap(ok and'blend'or'error',accepted);state.layer=variant==1 and 2 or 1;state._weightResult=.75;accepted=blend:update(state);ok=pcall(function()if accepted then p:blend(false)end end);snap(ok and'blend2'or'error',accepted);if op=='reinit'then p:init(arm,state,nil)end;if op=='reset'then blend:reset()end
 end
 p:fadeOut();snap('fade','none');p:returnToPool();blend:returnToPool();snap('clear','none');push(tostring(p._isInPool));push(tostring(blend._isInPool));push(tostring(p._rd==rd));td:returnToPool();arm:returnToPool();gd:returnToPool();return table.concat(out,'\t')
end
for line in io.lines(assert(arg[1]))do local c={};for v in(line..'\t'):gmatch('(.-)\t')do c[#c+1]=v end;print(execute(c))end
