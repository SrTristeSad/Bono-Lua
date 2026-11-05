local function req(p)return require('dragonbones.'..p)end
local B,Parser,JSON,Arm,Bone,Surface,Slot,IK,Core,Animation,State,Config,Map=req('core.BaseObject'),req('parser.ObjectDataParser'),req('parser.JSON'),req('armature.Armature'),req('armature.Bone'),req('armature.Surface'),req('armature.Slot'),req('armature.IKConstraint'),req('core.DragonBones'),req('animation.Animation'),req('animation.AnimationState'),req('model.AnimationConfig'),req('core.JSMap')
local double;if string.pack then double=function(n)return string.pack('<d',n)end else local ffi=require('ffi');double=function(n)return ffi.string(ffi.new('double[1]',n),8)end end
local function scalar(v)if v==nil then return'u'end;if type(v)=='string'then return's'..(v:gsub('.',function(c)return string.format('%02x',c:byte())end))end;if type(v)=='boolean'then return tostring(v)end;if v~=v then return'NaN'end;return'n'..(double(v):gsub('.',function(c)return string.format('%02x',c:byte())end))end
local sk={'name','group','layer','playTimes','timeScale','_position','_duration','_time','_weight','_weightResult','_fadeState','_subFadeState','_fadeTime','_fadeProgress','fadeTotalTime','_playheadState','actionEnabled','resetToPose','_isInPool'}
local ck={'animation','name','group','layer','playTimes','position','duration','timeScale','fadeInTime','fadeOutTime','fadeOutMode','pauseFadeIn','resetToPose'}
local file=assert(io.open('examples/playback_ske.json'));local fixture=file:read('*a');file:close()
local function execute(c)
local mode,layer,position,duration,rate,op=tonumber(c[1]),tonumber(c[2]),tonumber(c[3]),tonumber(c[4]),tonumber(c[5]),c[6];local cache=4
local warnings=0;local stderr=io.stderr;io.stderr={write=function()warnings=warnings+1 end}
local gd=Parser.new():parseDragonBonesData(JSON.parse(fixture));local ad=gd:getArmature('playback');if cache~=0 then ad:cacheFrames(cache)end
local arm=B.borrowObject(Arm);arm._armatureData=ad;for i=1,ad.sortedBones.length do local bd=ad.sortedBones[i];B.borrowObject(bd.type==1 and Surface or Bone):init(bd,arm)end
local hooks={};local Observer={__newindex=Slot.__newindex};Observer.__index=function(self,key)return rawget(Observer,key)or Slot.__index(self,key)end;setmetatable(Observer,{__index=Slot})
function Observer.toString()return'[test.PlaybackSlot]'end
function Observer.new()return Slot.new(Observer)end
for _,hook in ipairs({'_initDisplay','_disposeDisplay','_onUpdateDisplay','_addDisplay','_replaceDisplay','_removeDisplay','_updateZOrder','_updateVisible','_updateBlendMode','_updateColor','_updateFrame','_updateMesh','_updateTransform','_identityTransform'})do Observer[hook]=function(self)hooks[#hooks+1]=self.name..':'..hook end end
B.clearPool(Observer);for i=1,ad.sortedSlots.length do local sd=ad.sortedSlots[i];local slot=B.borrowObject(Observer);slot:init(sd,arm,{},{});local displays=ad.defaultSkin:getDisplays(sd.name);slot.displayFrameCount=displays.length;for j=1,displays.length do local v=displays[j];slot:replaceRawDisplayData(v,j-1);slot:replaceDisplay(v.type==2 and slot.meshDisplay or slot.rawDisplay,j-1)end;slot:_setDisplayIndex(0);slot:_updateDisplayData()end
for _,name in ipairs(Map.keys(ad.constraints))do local ik=B.borrowObject(IK);ik:init(ad.constraints[name],arm);arm:_addConstraint(ik)end
local dispatch={};local proxy={};function proxy:hasDBEventListener()return true end;function proxy:dispatchDBEvent(kind,e)dispatch[#dispatch+1]=kind..'~'..e.name..'~'..scalar(e.time)end;function proxy:dbClear()end
local sound={};function sound:dispatchDBEvent(kind,e)dispatch[#dispatch+1]='sound~'..e.name..'~'..scalar(e.time)end
local saved=print;print=function()end;local core=Core.new(sound);print=saved;arm._proxy=proxy;arm._dragonBones=core

local manager=B.borrowObject(Animation);manager:init(arm);arm._animation=manager;manager.animations=ad.animations
local childArm,childManager
if op:sub(1,5)=='child'and op~='childReuse'then childArm=B.borrowObject(Arm);childArm._armatureData=ad;childArm._proxy=proxy;childArm._dragonBones=core;childArm.inheritAnimation=op~='childNoInherit';childManager=B.borrowObject(Animation);childManager:init(childArm);childArm._animation=childManager;if op~='childMissing'then childManager.animations=ad.animations end;arm:getSlot('meshSlot')._childArmature=childArm;if op=='childHasState'then childManager:play('move',0)end end
local config=B.borrowObject(Config);local held,out={},{};local names,map,list=manager.animationNames,manager.animations,manager:getStates()
local function id(v)if v==nil then return'-'end;for i,s in ipairs(held)do if s==v then return tostring(i-1)end end;held[#held+1]=v;return tostring(#held-1)end
local returned;local function push(v)out[#out+1]=tostring(v)end
local function fields(o,keys)for _,k in ipairs(keys)do push(scalar(o[k]))end end
local function snap(status)
push(status);push(id(returned));push(manager.isPlaying);push(manager.isCompleted);push(manager.lastAnimationName);push(id(manager.lastAnimationState));push(manager._animationDirty);push(scalar(arm._cacheFrameIndex));push(manager.animationNames==names);push(manager.animations==map);push(manager:getStates()==list);local v={};for i=1,names.length do v[i]=names[i]end;push(table.concat(v,','));push(manager:hasAnimation('move'));push(manager:hasAnimation('absent'));push(warnings);if childManager then local a={};for i=1,childManager:getStates().length do local s=childManager:getStates()[i];a[i]=s.name..'~'..s._playheadState end;push(table.concat(a,'|'))else push('-')end;fields(config,ck);fields(manager._animationConfig,ck);push(list.length)
for i=1,list.length do local s=list[i];push(id(s));push(id(s._parent));fields(s,sk);push(s._actionTimeline.playState);push(scalar(s.currentTime));push(s._animationTimelines.length);push(s._poseTimelines.length)end
for _,n in ipairs({'move','alt','custom','controller','absent'})do for _,l in ipairs({-1,0,2})do push(id(manager:getState(n,l)))end end
for i=1,arm:getBones().length do local b=arm:getBones()[i];push(b.name);fields(b.animationPose,{'x','y','rotation','skew','scaleX','scaleY'})end
push(table.concat(hooks,'|'));push(table.concat(dispatch,'|'));local ev={};for _,e in ipairs(core._events)do ev[#ev+1]=e.type..'~'..e.name..'~'..scalar(e.time)end;push(table.concat(ev,'|'));push(#core._objects)
end
local function stage(fn)local ok=pcall(fn);snap(ok and'ok'or'error')end
local function tick(delta)hooks={};dispatch={};manager:advanceTime(delta);for i=1,arm:getBones().length do local b=arm:getBones()[i];b:update(arm._cacheFrameIndex);b:_updateAlpha()end;for i=1,arm:getSlots().length do local s=arm:getSlots()[i];s:_updateAlpha();s:update(arm._cacheFrameIndex)end;core:advanceTime(0)end
stage(function()if op=='noDefaultStart'then ad.defaultAnimation=nil end;if op=='defaultStart'or op=='noDefaultStart'then returned=manager:play()end end);stage(function()returned=manager:fadeIn('move',.25,0,0,'A',0)end);stage(function()returned=manager:fadeIn('alt',.25,0,1,'B',0)end);stage(function()tick(.125)end)
stage(function()
config.animation=(op=='controller'or op=='childReuse'or op=='missingChild')and'controller'or op=='missing'and'absent'or'move';config.name=op=='sameName'and'move'or'custom';config.group='A';config.layer=layer;config.position=position;config.duration=duration;config.timeScale=rate;config.fadeInTime=-1;config.fadeOutTime=-1;config.fadeOutMode=mode;config.playTimes=-1
if op=='singleFaded'then manager:getState('move'):fadeOut(.25)end;if op=='emptyModel'then ad:getAnimation('move').frameCount=0 end;if op=='zeroScale'then ad:getAnimation('move').scale=0 end;if op=='missingChild'then Map.remove(manager._animations,'alt')end;if op=='childReuse'then manager:fadeIn('move',0,1,layer,'',0)end;returned=manager:playConfig(config)
end)
stage(function()tick(.125)end);stage(function()manager:stop()end);stage(function()returned=manager:play()end)
stage(function()
local n=op=='missing'and'absent'or'move'
if op=='time'then returned=manager:gotoAndPlayByTime(n,-.25,2)
elseif op=='frame'then returned=manager:gotoAndPlayByFrame(n,12,2)
elseif op=='progress'then returned=manager:gotoAndPlayByProgress(n,1.5,2)
elseif op=='stopTime'then returned=manager:gotoAndStopByTime(n,.5)
elseif op=='stopFrame'then returned=manager:gotoAndStopByFrame(n,12)
elseif op=='stopProgress'then returned=manager:gotoAndStopByProgress(n,.5)
elseif op=='negativeProgress'then returned=manager:gotoAndPlayByProgress(n,-.5)
elseif op=='nanProgress'then returned=manager:gotoAndPlayByProgress(n,0/0)
elseif op=='emptyName'then returned=manager:play('')
else returned=manager:play(n,1)end
end)
stage(function()tick(op=='complete'and 2 or .25)end);stage(function()manager:stop('move')end);stage(function()returned=manager:play()end)
if op=='readonly'then for _,key in ipairs({'isPlaying','isCompleted','lastAnimationName','animationNames','animationConfig','lastAnimationState'})do stage(function()manager[key]=false end)end end
stage(function()local ref=manager._animationConfig;ref.position=9;local cfg=manager.animationConfig;push(cfg==ref)end)
stage(function()manager.animations=manager.animations end)
stage(function()local replacement=Map.new();replacement['10']=ad:getAnimation('alt');replacement['2']=ad:getAnimation('move');replacement['a']=ad:getAnimation('empty');manager.animations=replacement end)
stage(function()manager:reset()end);stage(function()if op=='noDefault'then ad.defaultAnimation=nil end;returned=manager:play()end);stage(function()tick(0)end)
core:advanceTime(0);core:advanceTime(0);if childArm then arm:getSlot('meshSlot')._childArmature=nil;childArm:returnToPool()end;arm:returnToPool();push(manager._isInPool);push(names.length);push(list.length);push(#Map.keys(map));for _,s in ipairs(held)do push(s._isInPool)end;config:returnToPool();gd:returnToPool();io.stderr=stderr;return table.concat(out,'\t')
end
for line in io.lines(arg[1])do local c={};for v in line:gmatch('[^\t]+')do c[#c+1]=v end;io.write(execute(c),'\n')end
