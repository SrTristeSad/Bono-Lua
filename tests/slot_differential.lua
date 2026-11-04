local Slot=require('dragonbones.armature.Slot')
local Arm=require('dragonbones.armature.Armature')
local Bone=require('dragonbones.armature.Bone')
local B=require('dragonbones.core.BaseObject')
local M=require('dragonbones.model.ArmatureData')
local Data=require('dragonbones.model.DragonBonesData')
local Boxes=require('dragonbones.model.BoundingBoxData')
local Color=require('dragonbones.geom.ColorTransform')
local Point=require('dragonbones.geom.Point')
local double
if string.pack then double=function(n)return string.pack('<d',n)end else local ffi=require('ffi');double=function(n)return ffi.string(ffi.new('double[1]',n),8)end end
local function scalar(v)
 if v==nil then return 'u' end
 if type(v)=='boolean' then return tostring(v) end
 if v~=v then return 'NaN' end
 return 'n'..(double(v):gsub('.',function(c)return string.format('%02x',c:byte())end))
end
local function matrix(m)local t={};for _,k in ipairs({'a','b','c','d','tx','ty'})do t[#t+1]=scalar(m[k])end;return table.concat(t,',')end
local flags={'_alpha','_globalAlpha','_displayDataDirty','_displayDirty','_geometryDirty','_textureDirty','_visibleDirty','_blendModeDirty','_zOrderDirty','_colorDirty','_verticesDirty','_transformDirty','_visible','_blendMode','_displayIndex','_animationDisplayIndex','_cachedFrameIndex','_zOrder','_zIndex','_pivotX','_pivotY','_globalDirty'}
local matrices={{1,0,0,1,10,20},{2,0,0,3,-8,4},{-1,0,0,1,10,20},{0,1,-1,0,10,20},{1,.5,.25,1,-10,5},{0,0,0,0,0,0}}
local segments={{-30,0,30,0},{0,0,30,0},{-30,0,0,0},{-2,-2,2,2},{30,30,40,40},{0,-30,0,30},{-30,-10,30,-10}}
local function execute(c)
 local life=c[1]=='life'
 local x,y=tonumber(c[2]),tonumber(c[3]);local op=life and c[4] or 'normal'
 local trace,fail,ids={},'',{}
 local customA,customB,raw,mesh={},{},{},{}
 if op=='opaqueEquality' then
  local meta={__eq=function()return true end}
  for _,value in ipairs({customA,customB,raw,mesh})do setmetatable(value,meta)end
 end
 ids[customA]='A';ids[customB]='B';ids[raw]='raw';ids[mesh]='mesh'
 local function id(v)return v==nil and 'nil' or assert(ids[v])end
 local Observer={__newindex=Slot.__newindex}
 Observer.__index=function(self,key)local member=rawget(Observer,key);if member~=nil then return member end;return Slot.__index(self,key)end
 setmetatable(Observer,{__index=Slot})
 function Observer.toString()return '[test.SlotObserver]'end
 function Observer.new()return Slot.new(Observer)end
 function Observer:_initDisplay(value,retain)
  trace[#trace+1]='init:'..id(value)..':'..tostring(retain)..':'..self._armature:getSlots().length
  if fail=='init' then error('injected')end
 end
 function Observer:_disposeDisplay(value,release)trace[#trace+1]='dispose:'..id(value)..':'..tostring(release)..':'..tostring(self.armature==nil)end
 function Observer:_onUpdateDisplay()trace[#trace+1]='onUpdate'end
 function Observer:_addDisplay()trace[#trace+1]='add'end
 function Observer:_updateVisible()
  trace[#trace+1]='visible:'..tostring(self.visible)..':'..(self.parent and tostring(self.parent.visible)or'nil')
  if fail=='visible' then error('injected')end
 end
 local gd,ad=B.borrowObject(Data),B.borrowObject(M.ArmatureData);ad.name='arm';gd:addArmature(ad)
 local arm=B.borrowObject(Arm);arm._armatureData=ad
 local bd=B.borrowObject(M.BoneData);bd.name='bone';ad:addBone(bd)
 local bone=B.borrowObject(Bone);bone:init(bd,arm)
 local sd=B.borrowObject(M.SlotData);sd.name='slot';sd.parent=bd;sd.alpha=.5;sd.zOrder=3;sd.zIndex=2;sd.color=Color.new();sd.color.redOffset=17;ad:addSlot(sd)
 B.clearPool(Observer)
 local s=B.borrowObject(Observer);local frames,geometry,localMatrix,color=s._displayFrames,s._geometryBones,s._localMatrix,s._colorTransform
 local rawValue,meshValue=raw,mesh
 if life then if x==1 then meshValue=raw elseif x==2 then rawValue=nil;meshValue=nil elseif x==3 then rawValue=nil end end
 if op=='missingColor'then sd.color=nil end
 local missing
 if op=='missingParent'then missing=B.borrowObject(M.BoneData);missing.name='absent';sd.parent=missing end
 if op=='failInit'then fail='init'end
 local held,results={},{}
 local function result(v)results[#results+1]=tostring(v)end
 local ok=pcall(function()
  s:init(sd,arm,rawValue,meshValue)
  if op=='missingParent'then s._parent=nil;s:_updateAlpha()end
  local patterns={{customA,customA,customB},{rawValue,meshValue,customA},{},{customA},{rawValue}}
  local lengths={4,4,2,1,1}
  local pattern=life and y+1 or 1
  for i=1,lengths[pattern]do s.displayFrameCount=s.displayFrameCount+1;s:getDisplayFrameAt(s.displayFrameCount-1).display=patterns[pattern][i]end
  for i=1,s._displayFrames.length do held[#held+1]=s._displayFrames[i]end
  arm:_addSlot(s)
  if op=='reinit'then s:init(nil,nil,nil,nil)end
  if op=='visible'then s.visible=false;s.visible=false;s.visible=true end
  if op=='parentVisible'then bone.visible=false;bone.visible=false;bone.visible=true end
  if op=='alpha'then bone._globalAlpha=.25;s._colorDirty=false;s:_updateAlpha();s._colorDirty=false;s:_updateAlpha()end
  if op=='geometryBones'then s._geometryBones.length=2;s._geometryBones[1]=nil;s._geometryBones[2]=bone;bone._childrenTransformDirty=false;result(s:_isBonesUpdate());bone._childrenTransformDirty=true;result(s:_isBonesUpdate())end
  if op=='countGrow'then s.displayFrameCount=6 end
  if op=='countShrink'then s.displayFrameCount=1 end
  if op=='displayIndex'then s:_setDisplayIndex(0);s._displayDataDirty=false;s:_setDisplayIndex(0);s:_setDisplayIndex(99)end
  if op=='animationIndex'then s:_setDisplayIndex(0,true);s._displayIndex=1;s._displayDataDirty=false;s:_setDisplayIndex(0,true)end
  if op=='negativeIndex'then s:_setDisplayIndex(-4)end
  if op=='fractionIndex'then s:_setDisplayIndex(.5)end
  if op=='zOrder'then s._zOrderDirty=false;result(s:_setZOrder(3))end
  if op=='color'then local value=Color.new();value.blueOffset=42;result(s:_setColor(value))end
  if op=='invalid'then s:invalidUpdate()end
  if op=='armInvalid'then arm:invalidUpdate('bone',true);arm:invalidUpdate(nil,true)end
  if op=='failVisible'then fail='visible';s.visible=false end
  if op=='readonly'then s.parent=nil end
  if not life then
   local segmentIndex,outputs=tonumber(c[4]),tonumber(c[5])
   local function set(m,v)for i,k in ipairs({'a','b','c','d','tx','ty'})do m[k]=v[i]+0.0 end end
   set(bone.globalTransformMatrix,matrices[x+1]);set(s._localMatrix,{1,0,0,1,4,-3});s._transformDirty=true
   local box
   if y>0 then box=B.borrowObject(y==1 and Boxes.RectangleBoundingBoxData or Boxes.EllipseBoundingBoxData);box.width=20;box.height=20 end
   s._boundingBoxData=box
   local a,b,n=Point.new(91,92),Point.new(93,94),Point.new(95,96)
   local seg=segments[segmentIndex+1]
   result(s:containsPoint(10,20));result(s:intersectsSegment(seg[1]+0.0,seg[2]+0.0,seg[3]+0.0,seg[4]+0.0,outputs%2==1 and a or nil,math.floor(outputs/2)%2==1 and b or nil,outputs>=4 and n or nil))
   for _,p in ipairs({a,b,n})do result(scalar(p.x));result(scalar(p.y))end
   s:updateTransformAndMatrix();s:_updateGlobalTransformMatrix(true)
   if box then box:returnToPool()end;s._boundingBoxData=nil
  end
 end)
 fail=''
 local function snap()local out={};for _,key in ipairs(flags)do out[#out+1]=scalar(s[key])end;return table.concat(out,',')end
 local function pooled()local out={};for _,f in ipairs(held)do out[#out+1]=tostring(f._isInPool)end;return table.concat(out,',')end
 local pose={};for _,key in ipairs({'x','y','skew','rotation','scaleX','scaleY'})do pose[#pose+1]=scalar(s.global[key])end
 local colors={};for _,key in ipairs({'alphaMultiplier','redMultiplier','greenMultiplier','blueMultiplier','alphaOffset','redOffset','greenOffset','blueOffset'})do colors[#colors+1]=scalar(s._colorTransform[key])end
 local out={ok and'ok'or'error',snap(),matrix(s.globalTransformMatrix),matrix(s._localMatrix),table.concat(pose,','),table.concat(colors,','),s._displayFrames.length,pooled(),s._geometryBones.length,arm:getSlots().length,arm:getSlot('slot')==s,arm:getSlot('absent')==nil,s.parent==bone,s.armature==arm,s.slotData==sd,s.rawDisplay==rawValue,s.meshDisplay==meshValue,s:_hasDisplay(customA),s:_hasDisplay(nil),s:getDisplayFrameAt(-1)==nil,table.concat(results,','),table.concat(trace,';')}
 local registered=false;for i=1,arm:getSlots().length do if arm:getSlots()[i]==s then registered=true end end
 if not registered then s:returnToPool()end
 arm:returnToPool()
 local after={table.concat(trace,';'),s._isInPool,s._displayFrames==frames,s._geometryBones==geometry,s._localMatrix==localMatrix,s._colorTransform==color,s._displayFrames.length,s._geometryBones.length,s.parent==nil,s.armature==nil,s.slotData==nil,matrix(s._localMatrix),snap(),pooled()}
 for _,v in ipairs(after)do out[#out+1]=v end
 local reused=B.borrowObject(Observer)
 out[#out+1]=reused==s;out[#out+1]=reused._displayFrames==frames;out[#out+1]=reused.slotData==nil
 reused:returnToPool()
 for _,f in ipairs(held)do if not f._isInPool then f:returnToPool()end end
 if missing then missing:returnToPool()end
 gd:returnToPool()
 for i,v in ipairs(out)do out[i]=tostring(v)end
 return table.concat(out,'\t')
end
local input=assert(arg[1])
for line in io.lines(input)do local c={};for v in(line..'\t'):gmatch('(.-)\t')do c[#c+1]=v end;print(execute(c))end
