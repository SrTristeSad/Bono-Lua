local function req(p)return require('dragonbones.'..p)end
local B,Parser,JSON,Arm,Bone,Surface,Slot,IK,Core,Animation,State,Config,Map=req('core.BaseObject'),req('parser.ObjectDataParser'),req('parser.JSON'),req('armature.Armature'),req('armature.Bone'),req('armature.Surface'),req('armature.Slot'),req('armature.IKConstraint'),req('core.DragonBones'),req('animation.Animation'),req('animation.AnimationState'),req('model.AnimationConfig'),req('core.JSMap')
local double;if string.pack then double=function(n)return string.pack('<d',n)end else local ffi=require('ffi');double=function(n)return ffi.string(ffi.new('double[1]',n),8)end end
local function scalar(v)if v==nil then return'u'end;if type(v)=='string'then return's'..(v:gsub('.',function(c)return string.format('%02x',c:byte())end))end;if type(v)=='boolean'then return tostring(v)end;if v~=v then return'NaN'end;return'n'..(double(v):gsub('.',function(c)return string.format('%02x',c:byte())end))end
local stateKeys={'_time','_weight','_weightResult','_fadeProgress','_fadeTime','_fadeState','_subFadeState','_timelineDirty','_playheadState','positionX','parameterX','_isInPool'}
local groups={'_boneTimelines','_boneBlendTimelines','_slotTimelines','_slotBlendTimelines','_constraintTimelines','_animationTimelines','_poseTimelines'}
local file=assert(io.open('examples/playback_ske.json'));local fixture=file:read('*a');file:close()
local function execute(c)
local kind,reset,fade,cache,rate,weight,op=tonumber(c[1]),tonumber(c[2]),tonumber(c[3]),tonumber(c[4]),tonumber(c[5]),tonumber(c[6]),c[7]
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
local manager=B.borrowObject(Animation);manager:init(arm);arm._animation=manager;local states,configs={},{}
local function add(name,layer)local cfg=B.borrowObject(Config);cfg.animation=name;cfg.timeScale=rate;cfg.playTimes=kind==2 and 0 or 1;cfg.fadeInTime=fade;cfg.pauseFadeIn=false;cfg.weight=weight;cfg.layer=layer;cfg.group='group';cfg.autoFadeOutTime=.125;cfg.resetToPose=reset==1;cfg.displayControl=op~='noDisplayControl';local s=B.borrowObject(State);s:init(arm,ad:getAnimation(name),cfg);manager._animationStates[manager._animationStates.length+1]=s;states[#states+1]=s;configs[#configs+1]=cfg;return s end
if kind==0 then add(op=='noData'and'empty'or'move',0)elseif kind==1 then add('move',2);add('alt',1)elseif kind==2 then local parent=add('controller',0);local a=add('move',0);local b=add('alt',0);a.timeScale=0;b.timeScale=0;parent:addState(a,parent.animationData:getAnimationTimelines('move'));parent:addState(b,parent.animationData:getAnimationTimelines('alt'))end
manager._lastAnimationState=states[#states];manager._animationDirty=true
local out={};local function push(v)out[#out+1]=tostring(v)end
local function nums(a)local v={};if a then for i=1,a.length do v[#v+1]=scalar(a[i])end end;return table.concat(v,',')end
local function fields(obj,keys)for _,key in ipairs(keys)do push(scalar(obj[key]))end end
for step,delta in ipairs({0,.125,.125,.25,.5,.125,.5,1,.25,.25})do
if states[1]then local s=states[1];if kind==2 then s.parameterX=({-.2,0,.25,.75,1.2,-.2,.5,0,1,.25})[step]end;if op=='mask'and step==3 then s:addBoneMask('root')end;if op=='mask'and step==6 then s:removeAllBoneMask()end;if op=='stop'and step==3 then s:stop()end;if op=='stop'and step==5 then s:play()end;if op=='fadeOut'and step==3 then s:fadeOut(.25,false)end;if op=='reuseBlend'and step==3 then manager:getBlendState('boneTransform','root',arm:getBone('child'))end end
if op=='controllerGate'then arm:getSlot('meshSlot').displayController=step<5 and'blocked'or'group'end;if op=='resetCache'and step==2 then arm._cacheFrameIndex=-1 end
manager:advanceTime(delta)
push(step-1);push(scalar(arm._cacheFrameIndex));push(manager._animationDirty);push(manager._animationStates.length);local index=-1;for i,s in ipairs(states)do if s==manager._lastAnimationState then index=i-1 end end;push(index);push(#core._objects);local events={};for _,e in ipairs(core._events)do events[#events+1]=e.type..'~'..e.name..'~'..scalar(e.time)end;push(table.concat(events,'|'))
for _,s in ipairs(states)do fields(s,stateKeys);for _,group in ipairs(groups)do local entries={};for i=1,s[group].length do local t=s[group][i];entries[#entries+1]=table.concat({t.toString(),scalar(t.currentTime),scalar(t.playState),scalar(t._isInPool)},'~')end;push(table.concat(entries,'|'))end;local names={};for i=1,s._boneMask.length do names[i]=s._boneMask[i]end;push(table.concat(names,','))end
for i=1,arm:getBones().length do local b=arm:getBones()[i];push(b.name);fields(b.animationPose,{'x','y','rotation','skew','scaleX','scaleY'});push(scalar(b._alpha));push(b._transformDirty);push(nums(b._cachedFrameIndices));if b._boneData.type==1 then push(nums(b._deformVertices))end end
for i=1,arm:getSlots().length do local s=arm:getSlots()[i];push(s.name);push(scalar(s.displayIndex));push(scalar(s._alpha));push(scalar(s._zIndex));fields(s._colorTransform,{'alphaMultiplier','redMultiplier','greenMultiplier','blueMultiplier','alphaOffset','redOffset','greenOffset','blueOffset'});push(s._colorDirty);push(s._verticesDirty);push(nums(s._cachedFrameIndices));for j=1,s._displayFrames.length do push(nums(s._displayFrames[j].deformVertices))end end
for _,k in ipairs(Map.keys(manager._blendStates))do push(k);for _,n in ipairs(Map.keys(manager._blendStates[k]))do local b=manager._blendStates[k][n];push(n);push(b.target.name);fields(b,{'blendWeight','leftWeight','layerWeight','layer','dirty'})end end
for i=1,arm:getBones().length do local b=arm:getBones()[i];b:update(arm._cacheFrameIndex);b:_updateAlpha()end;for i=1,arm:getSlots().length do local s=arm:getSlots()[i];s:_updateAlpha();s:update(arm._cacheFrameIndex)end;push(table.concat(hooks,'|'));hooks={};core:advanceTime(0);push(table.concat(dispatch,'|'));dispatch={}
end
core:advanceTime(0);core:advanceTime(0);arm:returnToPool();for _,cfg in ipairs(configs)do cfg:returnToPool()end;gd:returnToPool();return table.concat(out,'\t')
end
for line in io.lines(arg[1])do local c={};for v in line:gmatch('[^\t]+')do c[#c+1]=v end;io.write(execute(c),'\n')end
