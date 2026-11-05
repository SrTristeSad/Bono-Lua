local function req(p)return require('dragonbones.'..p)end
local B,Parser,JSON,Arm,Bone,Surface,Slot,IK,Core,Animation,State,Config,Map=req('core.BaseObject'),req('parser.ObjectDataParser'),req('parser.JSON'),req('armature.Armature'),req('armature.Bone'),req('armature.Surface'),req('armature.Slot'),req('armature.IKConstraint'),req('core.DragonBones'),req('animation.Animation'),req('animation.AnimationState'),req('model.AnimationConfig'),req('core.JSMap')
local double;if string.pack then double=function(n)return string.pack('<d',n)end else local ffi=require('ffi');double=function(n)return ffi.string(ffi.new('double[1]',n),8)end end
local function scalar(v)if v==nil then return'u'end;if type(v)=='string'then return's'..(v:gsub('.',function(c)return string.format('%02x',c:byte())end))end;if type(v)=='boolean'then return tostring(v)end;if v~=v then return'NaN'end;return'n'..(double(v):gsub('.',function(c)return string.format('%02x',c:byte())end))end
local ak={'_lockUpdate','_slotsDirty','_zOrderDirty','_zIndexDirty','_alphaDirty','_cacheFrameIndex','_alpha','_globalAlpha','_isInPool'}
local bk={'_alpha','_globalAlpha','_transformDirty','_childrenTransformDirty','_localDirty','_cachedFrameIndex'}
local slk={'_alpha','_globalAlpha','_zOrder','_zIndex','_displayIndex','_transformDirty','_colorDirty','_verticesDirty','_cachedFrameIndex'}
local file=assert(io.open('examples/playback_ske.json'));local fixture=file:read('*a');file:close()
local function execute(c)
local clip,cache,speed,alpha,sort,useClock,op,mask,segment=c[1],tonumber(c[2]),tonumber(c[3]),tonumber(c[4]),tonumber(c[5]),tonumber(c[6]),c[7],tonumber(c[8]),tonumber(c[9])
local warnings=0;local stderr=io.stderr;io.stderr={write=function()warnings=warnings+1 end}
local raw=JSON.parse(fixture)
if op=='queries'then local a=raw.armature[1];a.bone=JSON.parse('[{"name":"root"}]');a.ik=nil;a.animation=JSON.parse('[{"name":"empty","duration":24}]');for i=1,a.slot.length do a.slot[i].parent='root';a.skin[1].slot[i].display=JSON.parse('[{"name":"box","type":"boundingBox","subType":"rectangle","width":10,"height":10}]');a.skin[1].slot[i].display[1].transform={x=({0,10,-10})[i],y=0}end end
local gd=Parser.new():parseDragonBonesData(raw);local ad=gd:getArmature('playback');if cache~=0 then ad:cacheFrames(cache)end
local arm=B.borrowObject(Arm);local display,hooks,dispatch,proxies,children,ownedActions={},{},{},{},{},{};local updates,clears,reentered=0,0,false;local queueAction
local proxy={};function proxy:hasDBEventListener()return true end;function proxy:dispatchDBEvent(kind,e)dispatch[#dispatch+1]=kind..'~'..e.name..'~'..scalar(e.time)end
function proxy:dbInit(value)local vals={'init',value==arm,value._armatureData==ad,value._animation~=nil,value._animation._armature==nil,value.display==display};for i,v in ipairs(vals)do vals[i]=tostring(v)end;proxies[#proxies+1]=table.concat(vals,'~');if op=='initError'then error('init')end end
function proxy:dbUpdate()updates=updates+1;proxies[#proxies+1]='update~'..tostring(arm._lockUpdate);if op=='reenterProxy'and updates==1 then arm:advanceTime(0)end;if op=='proxyAction'and updates==1 then queueAction('self')end;if op=='dbUpdateError'and updates==1 then error('update')end end
function proxy:dbClear()clears=clears+1 end
local sound={};function sound:dispatchDBEvent(kind,e)dispatch[#dispatch+1]='sound~'..e.name..'~'..scalar(e.time)end
local saved=print;print=function()end;local core=Core.new(sound);print=saved
local out={};local function push(v)out[#out+1]=tostring(v)end;local function fields(o,keys)for _,k in ipairs(keys)do push(scalar(o[k]))end end
local ok=pcall(function()arm:init(ad,proxy,display,core)end);push(ok and'ok'or'error');push(table.concat(proxies,'|'));push(arm.proxy==proxy);push(arm.eventDispatcher==proxy);push(arm:getDisplay()==display)
if op=='initError'or op=='noModel'or op=='noParentData'then if op=='noModel'then arm._armatureData=nil end;if op=='noParentData'then ad.parent=nil end;for i=1,2 do local ok=pcall(function()arm:advanceTime(.25)end);push(ok and'ok'or'error');fields(arm,ak);push(warnings);push(updates)end;if op=='noParentData'then ad.parent=gd end;arm:returnToPool();push(clears);gd:returnToPool();io.stderr=stderr;return table.concat(out,'\t')end
for i=1,ad.sortedBones.length do local bd=ad.sortedBones[i];B.borrowObject(bd.type==1 and Surface or Bone):init(bd,arm)end
local Observer={__newindex=Slot.__newindex};Observer.__index=function(self,key)return rawget(Observer,key)or Slot.__index(self,key)end;setmetatable(Observer,{__index=Slot})
function Observer.toString()return'[test.PlaybackSlot]'end
function Observer.new()return Slot.new(Observer)end
for _,hook in ipairs({'_initDisplay','_disposeDisplay','_onUpdateDisplay','_addDisplay','_replaceDisplay','_removeDisplay','_updateZOrder','_updateVisible','_updateBlendMode','_updateColor','_updateFrame','_updateMesh','_updateTransform','_identityTransform'})do Observer[hook]=function(self)hooks[#hooks+1]=self.name..':'..hook;if op=='reenterSlot'and not reentered and arm._lockUpdate then reentered=true;arm:advanceTime(99)end end end
B.clearPool(Observer);for i=1,ad.sortedSlots.length do local sd=ad.sortedSlots[i];local slot=B.borrowObject(Observer);slot:init(sd,arm,{},{});local displays=ad.defaultSkin:getDisplays(sd.name);slot.displayFrameCount=displays.length;for j=1,displays.length do local v=displays[j];slot:replaceRawDisplayData(v,j-1);slot:replaceDisplay(v.type==2 and slot.meshDisplay or slot.rawDisplay,j-1)end;slot:_setDisplayIndex(0);slot:_updateDisplayData()end
for _,name in ipairs(Map.keys(ad.constraints))do local ik=B.borrowObject(IK);ik:init(ad.constraints[name],arm);arm:_addConstraint(ik)end

local animation=arm.animation;animation.timeScale=speed;local state=animation:play(clip,op=='complete'and 1 or 0);if op=='complete'then state.autoFadeOutTime=.125 end;arm._alpha=alpha
if op=='alphaParent'then arm._parent=arm:getSlot('plain')end
if op=='actionSlot'or op=='actionBone'then for _,name in ipairs({'plain','extra'})do local child=B.borrowObject(Arm);local cp={};function cp:dbInit()end;function cp:dbUpdate()end;function cp:dbClear()end;function cp:hasDBEventListener()return true end;function cp:dispatchDBEvent(kind,e)dispatch[#dispatch+1]='child~'..kind..'~'..e.name end;child:init(ad,cp,{},core);for i=1,ad.sortedBones.length do local bd=ad.sortedBones[i];B.borrowObject(bd.type==1 and Surface or Bone):init(bd,child)end;children[#children+1]=child;arm:getSlot(name):replaceDisplay(child,0)end end
queueAction=function(kind)local action=B.borrowObject(req('event.EventObject'));if kind~='nil'then local data=B.borrowObject(req('model.UserData').ActionData);data.type=kind=='other'and 10 or 0;data.name='alt';ownedActions[#ownedActions+1]=data;action.actionData=data end;if kind=='slot'then action.slot=arm:getSlot('plain')end;if kind=='bone'then action.bone=arm:getBone('child')end;if kind=='missing'then action.slot=arm:getSlot('meshSlot')end;arm:_bufferAction(action,true);arm:_bufferAction(action,false)end
if useClock==1 then arm.clock=core.clock end
local AtlasBase=req('model.TextureAtlasData').TextureAtlasData;local Atlas={};Atlas.__index=Atlas;setmetatable(Atlas,{__index=AtlasBase});function Atlas.toString()return'[test.ArmatureAtlas]'end;function Atlas.new()return AtlasBase.new(Atlas)end;function Atlas:createTexture()error('Unused')end;B.clearPool(Atlas);local tex,atlas={},B.borrowObject(Atlas);local atlasHeld=false
local function nums(a)local v={};if a then for i=1,a.length do v[#v+1]=scalar(a[i])end end;return table.concat(v,',')end
local function snap(status)push(status);fields(arm,ak);push(updates);push(clears);push(warnings);push(arm.animation==animation);push(arm.clock==core.clock);push(arm.proxy==proxy);push(arm.replacedTexture==tex);push(atlas._isInPool);push(table.concat(proxies,'|'));push(table.concat(hooks,'|'));push(table.concat(dispatch,'|'))
for i=1,arm:getBones().length do local b=arm:getBones()[i];push(b.name);fields(b,bk);fields(b.animationPose,{'x','y','rotation','skew','scaleX','scaleY'});if b._boneData.type==1 then push(nums(b._deformVertices))end end
for i=1,arm:getSlots().length do local s=arm:getSlots()[i];push(s.name);fields(s,slk);push(nums(s._cachedFrameIndices));push(arm:getSlotByDisplay(s.display)==s);push(arm:getBoneByDisplay(s.display)==s.parent);for j=1,s._displayFrames.length do push(nums(s._displayFrames[j].deformVertices))end end
push(arm:getSlotByDisplay(nil)==nil);push(arm:getBoneByDisplay({})==nil)
for i=1,animation:getStates().length do local a=animation:getStates()[i];push(a.name);push(scalar(a.currentTime));push(a._fadeState);push(a._subFadeState);push(a._playheadState)end
push(arm._actions.length);local ev={};for _,e in ipairs(core._events)do ev[#ev+1]=e.type..'~'..e.name..'~'..scalar(e.time)end;push(table.concat(ev,'|'));local objs={};for _,o in ipairs(core._objects)do objs[#objs+1]=o.toString()end;push(table.concat(objs,'|'))
for _,child in ipairs(children)do push(child.animation.lastAnimationName);push(child.animation:getStates().length);push(scalar(child._globalAlpha));push(child._lockUpdate)end
end
local function query()local seg=({{-30,0,30,0},{30,0,-30,0},{0,-30,0,30},{-30,-30,30,30},{0,0,1,1},{-30,30,30,30}})[segment+1];local a,b,n={x=7,y=-8},{x=9,y=-10},{x=11,y=-12};for _,pt in ipairs({{0,0},{10,0},{30,30}})do local slot=arm:containsPoint(pt[1],pt[2]);push(slot and slot.name or'-')end;local slot=arm:intersectsSegment(seg[1],seg[2],seg[3],seg[4],mask%2>=1 and a or nil,math.floor(mask/2)%2>=1 and b or nil,math.floor(mask/4)%2>=1 and n or nil);push(slot and slot.name or'-');fields(a,{'x','y'});fields(b,{'x','y'});fields(n,{'x','y'})end
for step,delta in ipairs({0,.125,.125,.25,.5,.5,0,.25})do hooks={};dispatch={};proxies={};local ok=pcall(function()
if step==2 and op=='reinit'then arm:init(ad,{}, {},core)end;if step==2 and op=='locked'then arm._lockUpdate=true end;if step==3 and op=='locked'then arm._lockUpdate=false end;if step==3 and op=='flip'then arm.flipX=true;arm.flipY=true end
if step==3 and op=='changeClock'then arm.clock=nil end;if step==5 and op=='changeClock'then arm.clock=core.clock end
if step==2 and op:sub(1,7)=='texture'then arm._replaceTextureAtlasData=atlas;atlasHeld=true;if op=='textureFalse'then arm.replacedTexture=false else arm.replacedTexture=tex end;arm.replacedTexture=arm.replacedTexture end
if step==3 and op:sub(1,6)=='action'then queueAction(({actionSelf='self',actionSlot='slot',actionBone='bone',actionMissing='missing',actionOther='other',actionNoData='nil'})[op])end
if step==3 and op=='dispose'then arm:dispose()end
if not arm._lockUpdate and sort~=0 then for i=1,arm:getSlots().length do local slot=arm:getSlots()[i];slot._zIndex=sort==2 and({.002,0,-.002})[i]or 0;if sort==1 then slot._zOrder=0 end end;arm._slotsDirty=true;arm._zIndexDirty=sort==2 end;if step==4 then arm._alpha=alpha/2;arm._alphaDirty=true end
if useClock==0 then arm:advanceTime(delta)end;core:advanceTime(delta);if op=='queries'then query()end
end);snap(ok and'ok'or'error');if op=='dispose'and arm._isInPool then break end
end
if op=='readonly'then local ok=pcall(function()arm.proxy=false end);snap(ok and'ok'or'error')end
arm._parent=nil;arm.clock=nil;if not arm._isInPool then arm:returnToPool()end;core:advanceTime(0);core:advanceTime(0);if not atlasHeld then atlas:returnToPool()end;for _,a in ipairs(ownedActions)do a:returnToPool()end;push(clears);push(arm._isInPool);push(#core._objects);push(#core._events);for _,child in ipairs(children)do push(child._isInPool)end;gd:returnToPool();io.stderr=stderr;return table.concat(out,'\t')
end
for line in io.lines(arg[1])do local c={};for v in line:gmatch('[^\t]+')do c[#c+1]=v end;io.write(execute(c),'\n')end
