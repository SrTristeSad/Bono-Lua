local Slot=require('dragonbones.armature.Slot')
local Arm=require('dragonbones.armature.Armature')
local Bone=require('dragonbones.armature.Bone')
local Surface=require('dragonbones.armature.Surface')
local B=require('dragonbones.core.BaseObject')
local M=require('dragonbones.model.ArmatureData')
local D=require('dragonbones.model.DisplayData')
local User=require('dragonbones.model.UserData')
local Color=require('dragonbones.geom.ColorTransform')
local Core=require('dragonbones.core.DragonBones')
local Event=require('dragonbones.event.EventObject')
local Clock=require('dragonbones.animation.WorldClock')
local Array=require('dragonbones.core.JSArray')
local Parser=require('dragonbones.parser.ObjectDataParser')
local JSON=require('dragonbones.parser.JSON')
local fixtures={}
for _,path in ipairs({'examples/bones_ske.json','examples/surface_ske.json'})do local f=assert(io.open(path,'rb'));fixtures[#fixtures+1]=f:read('*a');f:close()end
local flags={'_displayDataDirty','_displayDirty','_geometryDirty','_textureDirty','_visibleDirty','_blendModeDirty','_colorDirty','_zOrderDirty','_verticesDirty','_transformDirty','_globalDirty','_cachedFrameIndex','_displayIndex'}
local double
if string.pack then double=function(n)return string.pack('<d',n)end else local ffi=require('ffi');double=function(n)return ffi.string(ffi.new('double[1]',n),8)end end
local function scalar(v)if v==nil then return'u'end;if type(v)=='boolean'then return tostring(v)end;if v~=v then return'NaN'end;return'n'..(double(v):gsub('.',function(c)return string.format('%02x',c:byte())end))end
local function matrix(m)local t={};for _,key in ipairs({'a','b','c','d','tx','ty'})do t[#t+1]=scalar(m[key])end;return table.concat(t,',')end
local function execute(c)
 local family,a,b,k,op=c[1],tonumber(c[2]),tonumber(c[3]),tonumber(c[4]),c[5]
 local surface=family=='update'and a>=3;Core.yDown=true
 local gd=Parser.new():parseDragonBonesData(JSON.parse(fixtures[surface and 2 or 1]));local ad=gd:getArmature(gd.armatureNames[1])
 local savedPrint=print;print=function()end;local core=Core.new(nil);print=savedPrint
 local arm=B.borrowObject(Arm);arm._armatureData=ad;arm._dragonBones=core
 local ids,owned,trace,children={},{},{},{};local fail='';local meshReset=false
 local raw,mesh,A,Q,C0,C1={},{},{},{},{},{}
 if op=='opaqueEq'then local meta={__eq=function()return true end};for _,v in ipairs({raw,mesh,A,Q})do setmetatable(v,meta)end end
 ids[raw]='raw';ids[mesh]='mesh';ids[A]='A';ids[Q]='B';ids[false]='false';ids[0]='zero';ids['']='empty';ids[C0]='container0';ids[C1]='container1';ids[core.clock]='clock0';ids[arm]='arm'
 A.display=C0;A._armatureData=ad;A.clock=core.clock
 local function id(v)return v==nil and'nil'or ids[v]or'unexpected'end
 for i=1,ad.sortedBones.length do local bd=ad.sortedBones[i];local bone=B.borrowObject(bd.type==1 and Surface or Bone);bone:init(bd,arm);ids[bone]='bone:'..bd.name;if surface and bd.type==1 then bone._deformVertices[10]=80 end;bone:invalidUpdate();bone:update(-1)end
 local parent=arm:getBone(surface and'grid'or'child')
 local sd=B.borrowObject(M.SlotData);sd.name='probe';sd.parent=parent.boneData;sd.color=Color.new();ad:addSlot(sd)
 local Observer={__newindex=Slot.__newindex}
 Observer.__index=function(self,key)local member=rawget(Observer,key);if member~=nil then return member end;return Slot.__index(self,key)end
 setmetatable(Observer,{__index=Slot})
 function Observer.toString()return'[test.SlotRuntimeObserver]'end
 function Observer.new()return Slot.new(Observer)end
 for _,name in ipairs({'_initDisplay','_disposeDisplay','_onUpdateDisplay','_addDisplay','_replaceDisplay','_removeDisplay','_updateZOrder','_updateVisible','_updateBlendMode','_updateColor','_updateFrame','_updateMesh','_updateTransform','_identityTransform'})do
  local hook=name
  Observer[hook]=function(self,v,retain)
   local text=retain==nil and'u'or tostring(retain)
   trace[#trace+1]=table.concat({hook,id(v),text,id(self.display),tostring(self._verticesDirty),tostring(self._transformDirty)},':')
   if hook=='_updateMesh'and meshReset then self._verticesDirty=true end
   if fail==hook then error('injected')end
  end
 end
 B.clearPool(Observer);local s=B.borrowObject(Observer);s:init(sd,arm,raw,mesh);ids[s]='slot';local held={}
 local values={};values[1]=nil;values[2]=raw;values[3]=mesh;values[4]=A;values[5]=Q;values[6]=false;values[7]=0;values[8]=''
 local image=B.borrowObject(D.ImageDisplayData);image.transform.x=5;owned[#owned+1]=image;ids[image]='image'
 local function frames(n)s.displayFrameCount=n;for i=1,n do local f=s:getDisplayFrameAt(i-1);ids[f]='frame'..(i-1);f.rawDisplayData=image;held[#held+1]=f end end
 if family=='replace'then
  frames(op=='emptySetter'and 0 or 2)
  if s.displayFrameCount>0 then s._displayFrames[1].display=values[a+1];if k==1 then s._displayFrames[2].display=values[a+1]else s._displayFrames[2].display=Q end;s:_setDisplayIndex(0);s:update(-1)end
  trace={};if op=='failInit'then fail='_initDisplay'end;if op=='failDispose'then fail='_disposeDisplay'end
  if op=='hiddenSetter'then s:_setDisplayIndex(-1);s:update(-1);trace={}end
 end
 if family=='update'then
  frames(1)
  if a>0 and a~=4 then
   local model=B.borrowObject(D.MeshDisplayData);owned[#owned+1]=model;model.geometry.data=gd;ids[model]='meshData';ids[model.geometry]='geometry'
   if a==2 then model.geometry.weight=B.borrowObject(D.WeightData);local missing=B.borrowObject(M.BoneData);missing.name='absent';owned[#owned+1]=missing;for _,bd in ipairs({ad.sortedBones[1],missing,parent.boneData})do model.geometry.weight:addBone(bd)end end
   s._displayFrames[1].rawDisplayData=model
  end
  local displays={[0]=raw,[1]=mesh,[2]=A,[4]=false};s._displayFrames[1].display=displays[b]
  if k==1 then s._cachedFrameIndices=Array.new()end
  trace={};if op:sub(1,1)=='_'then fail=op end;meshReset=op=='meshReset'
 end
 local otherClock
 if family=='child'then
  for i=0,1 do local cd=B.borrowObject(M.ArmatureData);cd.name='child'..i;gd:addArmature(cd);local child=B.borrowObject(Arm);child._armatureData=cd;child._dragonBones=core;child._display=i==1 and C1 or C0;child.inheritAnimation=a==1;ids[child]='child'..i;children[#children+1]=child end
  if k==1 then arm.clock=core.clock end;arm.cacheFrameRate=12;frames(1)
  local model=B.borrowObject(D.ArmatureDisplayData);owned[#owned+1]=model
  if b>0 then for i=0,b-1 do local action=B.borrowObject(User.ActionData);action.type=0;action.name='action'..i;action.bone=parent.boneData;action.slot=sd;model.actions[model.actions.length+1]=action end end
  s._displayFrames[1].rawDisplayData=model;s._displayFrames[1].display=children[1];trace={}
 end
 local function array(v,fn)if v==nil then return'nil'end;local length=v.length or #v;local out={};for i=1,length do out[#out+1]=fn(v[i])end;return length..':'..table.concat(out,',')end
 local function pooled()local out={};for _,f in ipairs(held)do out[#out+1]=tostring(f._isInPool)end;return table.concat(out,',')end
 local function childStates()
  local out={};for _,x in ipairs(children)do out[#out+1]=table.concat({id(x.parent),id(x.clock),tostring(x.cacheFrameRate),tostring(x._lockUpdate),tostring(x._isInPool)},'/')end;return table.concat(out,',')
 end
 local result={}
 local function snap(status)
  local flag={};for _,key in ipairs(flags)do flag[#flag+1]=scalar(s[key])end
  local pose={};for _,key in ipairs({'x','y','skew','rotation','scaleX','scaleY'})do pose[#pose+1]=scalar(s.global[key])end
  local clocks={id(arm.clock),tostring(core.clock:contains(arm))};for _,child in ipairs(children)do clocks[#clocks+1]=tostring(core.clock:contains(child))end;clocks[#clocks+1]=tostring(otherClock~=nil and otherClock:contains(arm))
  return {status,id(s.display),id(s.childArmature),array(s.displayList,id),s.displayFrameCount,s.displayIndex,id(s._displayFrame),table.concat(flag,','),matrix(s.globalTransformMatrix),table.concat(pose,','),array(s._cachedFrameIndices,scalar),array(gd.cachedFrames,scalar),array(s._geometryBones,id),table.concat(trace,';'),array(arm._actions,function(e)return table.concat({e.name,id(e.armature),id(e.bone),id(e.slot)},'/')end),childStates(),array(core._objects,id),table.concat(clocks,','),rawequal(s:getDisplay(),s.display)}
 end
 local function stage(fn)local ok=pcall(fn);for _,v in ipairs(snap(ok and'ok'or'error'))do result[#result+1]=tostring(v)end end
 stage(function()
  if family=='replace'then
   if op=='list'then local list=Array.new();list.length=3;list[1]=values[b+1];list[3]=values[a+1];s.displayList=list
   elseif op=='emptySetter'or op=='hiddenSetter'then s.display=values[b+1]
   elseif op=='readList'then local copy=s.displayList;copy[1]=values[b+1];s:setDisplay(values[b+1])
   else s:replaceDisplay(values[b+1],0)end
  else s:_setDisplayIndex(0);s:update(family=='update'and k==1 and 0 or -1)end
 end)
 fail='';stage(function()s:update(family=='update'and k==1 and 0 or -1)end)
 stage(function()
  if family=='update'then
   if op=='cacheRestore'then s._cachedFrameIndex=-1;s.globalTransformMatrix:identity();s:update(k==1 and 0 or -1)
   elseif op=='reuseCache'then parent._childrenTransformDirty=false;s._transformDirty=false;s:update(1)
   elseif op=='parentDirty'then parent.offset.x=10;parent:invalidUpdate();parent:update(-1);s._transformDirty=false;s:update(1)
   elseif op=='meshAgain'then s._verticesDirty=false;parent._childrenTransformDirty=true;s:update(k==1 and 0 or -1)
   elseif op=='hide'then s.displayIndex=-1
   else s:invalidUpdate();s:update(k==1 and 0 or -1)end
  elseif family=='replace'then s.displayIndex=0
  else
   if op=='detach'then s.display=nil end
   if op=='replace'then s.childArmature=children[2]end
   if op=='clockSwap'then otherClock=Clock.new(0);ids[otherClock]='clock1';arm.clock=otherClock end
   if op=='dispose'then children[1]:dispose();children[1]:dispose()end
   if op=='cacheRate'then arm.cacheFrameRate=24 end
   if op=='appendActions'then local e=B.borrowObject(Event);e.name='tail';arm:_bufferAction(e,true);arm:_bufferAction(e,false)end
   if op=='readonly'then arm.display=A end
   s:update(-1)
  end
 end)
 for _,child in ipairs(children)do child.inheritAnimation=false end
 stage(function()s:invalidUpdate();s:update(-1)end)
 arm:returnToPool();result[#result+1]=tostring(s._isInPool);result[#result+1]=tostring(s._displayFrames.length);result[#result+1]=pooled();result[#result+1]=array(core._objects,id)
 local out={};for _,child in ipairs(children)do out[#out+1]=tostring(child._isInPool)end;result[#result+1]=table.concat(out,',')
 for _,child in ipairs(children)do child:dispose()end;core:advanceTime(0)
 result[#result+1]=array(core._objects,id);out={};for _,child in ipairs(children)do out[#out+1]=tostring(child._isInPool)end;result[#result+1]=table.concat(out,',');out={};for _,child in ipairs(children)do out[#out+1]=tostring(child.parent==nil and child.clock==nil)end;result[#result+1]=table.concat(out,',')
 for _,f in ipairs(held)do if not f._isInPool then f:returnToPool()end end
 for i=#owned,1,-1 do owned[i]:returnToPool()end;gd:returnToPool();return table.concat(result,'\t')
end
local input=assert(arg[1])
for line in io.lines(input)do local c={};for v in(line..'\t'):gmatch('(.-)\t')do c[#c+1]=v end;print(execute(c))end
