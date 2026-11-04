local Slot=require('dragonbones.armature.Slot')
local Arm=require('dragonbones.armature.Armature')
local Bone=require('dragonbones.armature.Bone')
local B=require('dragonbones.core.BaseObject')
local M=require('dragonbones.model.ArmatureData')
local D=require('dragonbones.model.DisplayData')
local Data=require('dragonbones.model.DragonBonesData')
local Skin=require('dragonbones.model.SkinData')
local Textures=require('dragonbones.model.TextureAtlasData')
local Boxes=require('dragonbones.model.BoundingBoxData')
local Color=require('dragonbones.geom.ColorTransform')
local Rect=require('dragonbones.geom.Rectangle')
local DragonBones=require('dragonbones.core.DragonBones')
local classes={D.ImageDisplayData,D.MeshDisplayData,D.PathDisplayData,D.BoundingBoxDisplayData,D.ArmatureDisplayData}
local double
if string.pack then double=function(n)return string.pack('<d',n)end else local ffi=require('ffi');double=function(n)return ffi.string(ffi.new('double[1]',n),8)end end
local function scalar(v)
 if v==nil then return 'u' end
 if type(v)=='boolean'then return tostring(v)end
 if v~=v then return 'NaN'end
 return 'n'..(double(v):gsub('.',function(c)return string.format('%02x',c:byte())end))
end
local function matrix(m)local out={};for _,key in ipairs({'a','b','c','d','tx','ty'})do out[#out+1]=scalar(m[key])end;return table.concat(out,',')end
local function execute(c)
 local rk,vk,rot,trim,down,scale,weighted=tonumber(c[1]),tonumber(c[2]),tonumber(c[3]),tonumber(c[4]),tonumber(c[5]),tonumber(c[6]),tonumber(c[7]);local op=c[8]
 DragonBones.yDown=down==1
 local ids,owned={},{}
 local function borrow(C,id)local x=B.borrowObject(C);ids[x]=id;owned[#owned+1]=x;return x end
 local gd,ad=B.borrowObject(Data),B.borrowObject(M.ArmatureData);ad.name='arm';ad.scale=scale==1 and .5 or 1;gd:addArmature(ad);gd.intArray={3,0,0}
 local arm=B.borrowObject(Arm);arm._armatureData=ad
 local bones={}
 for _,name in ipairs({'root','missing','other'})do
  local bd=B.borrowObject(M.BoneData);bd.name=name;ad:addBone(bd);bones[#bones+1]=bd
  if name~='missing'then B.borrowObject(Bone):init(bd,arm)end
 end
 local sd=B.borrowObject(M.SlotData);sd.name='slot';sd.parent=bones[1];sd.color=Color.new();ad:addSlot(sd)
 local skin=B.borrowObject(Skin);skin.name='default';ad:addSkin(skin)
 local atlas=Textures.TextureAtlasData.new(Textures.TextureAtlasData);atlas:_onClear();atlas.scale=scale==1 and 3 or 1
 if op=='fractionalPivot'then atlas.scale=.1;ad.scale=.3 end
 local function texture(id,w,h)
  local t=Textures.TextureData.new(Textures.TextureData);t:_onClear();t.parent=atlas;t.region.width=op=='fractionalPivot'and 33.3 or w;t.region.height=op=='fractionalPivot'and 19.7 or h;t.rotated=rot==1
  if trim==1 then t.frame=Rect.new();t.frame.x=-7;t.frame.y=-11;t.frame.width=w+30;t.frame.height=h+20 end
  ids[t]=id;return t
 end
 local rt,vt,override=texture('rawTexture',100,80),texture('replacementTexture',200,120),texture('overrideTexture',60,40)
 local function display(kind,id,t)
  if kind==0 then return nil end
  local x=borrow(classes[kind],id);ids[x.transform]=id..'Transform';x.transform.x=id=='raw'and 5 or 15;x.transform.y=id=='raw'and -3 or -9
  if op=='trig'then x.transform.rotation=id=='raw'and .25 or -.4;x.transform.scaleX=1.2;x.transform.scaleY=.8 end
  if kind==1 then x.pivot.x=op=='fractionalPivot'and .1 or .25;x.pivot.y=op=='fractionalPivot'and .3 or .75;x.texture=t end
  if kind==2 then x.texture=t end
  if kind==2 or kind==3 then
   ids[x.geometry]=id..'Geometry';x.geometry.data=gd
   if weighted==1 then x.geometry.weight=B.borrowObject(D.WeightData);x.geometry.weight.count=4;for _,bd in ipairs({bones[1],bones[2],bones[3],bones[1]})do x.geometry.weight:addBone(bd)end end
  end
  if kind==4 then x.boundingBox=B.borrowObject(Boxes.RectangleBoundingBoxData);ids[x.boundingBox]=id..'Box'end
  return x
 end
 local raw,replacement,fallback=display(rk,'raw',rt),display(vk,'replacement',vt),display(1,'fallback',rt)
 table.remove(owned)
 if op=='nullDefault'then skin:addDisplay('slot',nil);owned[#owned+1]=fallback
 else skin:addDisplay(op=='noDefaults'and 'other'or 'slot',fallback)end
 if op=='nullSkin'then ad.defaultSkin=nil end
 local hooks={}
 local Observer={__newindex=Slot.__newindex}
 Observer.__index=function(self,key)local member=rawget(Observer,key);if member~=nil then return member end;return Slot.__index(self,key)end
 setmetatable(Observer,{__index=Slot})
 function Observer.toString()return '[test.SlotDataObserver]'end
 function Observer.new()return Slot.new(Observer)end
 function Observer:_initDisplay()hooks[#hooks+1]="init"end
 function Observer:_disposeDisplay()hooks[#hooks+1]="dispose"end
 function Observer:_onUpdateDisplay()hooks[#hooks+1]="onUpdate"end
 function Observer:_addDisplay()hooks[#hooks+1]="add"end
 B.clearPool(Observer)
 local s=B.borrowObject(Observer);s:init(sd,arm,nil,nil);s.displayFrameCount=op=='noFrames'and 0 or 2
 for i=1,s._displayFrames.length do ids[s._displayFrames[i]]='frame'..(i-1)end
 s._displayIndex=op=='negativeIndex'and -1 or op=='shortDefaults'and 1 or 0
 local target=s._displayIndex<0 and 0 or s._displayIndex
 local index=target
 if op=='negativeIndex'then index=-5 end
 if op=='omittedIndex'then index=nil end
 if op=='inactiveIndex'then index=1 end
 if op=='aboveIndex'then index=99 end
 if op=='fractionIndex'then index=.5 end
 if op=='nanIndex'then index=0/0 end
 if op=='missingArmature'then s._armature=nil end
 if op=='missingAtlas'then rt.parent=nil end
 if op=='nullTexture'and raw then raw.texture=nil end
 local function id(x)return x==nil and 'nil'or ids[x]or'unexpected'end
 local all={}
 local function reset()for _,key in ipairs({'_geometryDirty','_verticesDirty','_textureDirty','_transformDirty','_displayDataDirty'})do s[key]=false end end
 local function snap(status)
  local f=s._displayFrames[target+1];local a=f and f.deformVertices or {length=0}
  local pose={};for _,key in ipairs({'x','y','skew','rotation','scaleX','scaleY'})do pose[#pose+1]=scalar(s.global[key])end
  local flags={};for _,key in ipairs({'_geometryDirty','_verticesDirty','_textureDirty','_transformDirty','_displayDataDirty'})do flags[#flags+1]=scalar(s[key])end
  local names={};for i=1,s._geometryBones.length do names[#names+1]=s._geometryBones[i]and s._geometryBones[i].name or'nil'end
  local values={};for i=1,a.length do values[#values+1]=a[i]==nil and'hole'or scalar(a[i])end
  return {status,id(s._displayFrame),id(s._geometryData),id(s._textureData),id(s._boundingBoxData),id(s.origin),matrix(s._localMatrix),table.concat(pose,','),scalar(s._pivotX),scalar(s._pivotY),table.concat(flags,','),s._geometryBones.length..':'..table.concat(names,','),f and id(f.rawDisplayData)or'absent',f and id(f.displayData)or'absent',f and id(f.textureData)or'absent',a.length..':'..table.concat(values,',')}
 end
 local function stage(fn)local ok=pcall(fn);for _,v in ipairs(snap(ok and'ok'or'error'))do all[#all+1]=tostring(v)end end
 stage(function()s:replaceRawDisplayData(raw,index);s:replaceDisplayData(op=='sameReplacementAsRaw'and raw or replacement,index);s:_updateDisplayData()end)
 stage(function()reset();s.offset.x=9;s:_updateDisplayData()end)
 stage(function()reset();local f=s._displayFrames[target+1];if f then f.deformVertices[f.deformVertices.length+1]=7;f.deformVertices[f.deformVertices.length+1]=-0.0 end;s:replaceRawDisplayData(raw,index);s:_updateDisplayData()end)
 stage(function()reset();if op=='boxOnly'and raw then raw.boundingBox:returnToPool();raw.boundingBox=B.borrowObject(Boxes.EllipseBoundingBoxData);ids[raw.boundingBox]='changedBox'end;s:_updateDisplayData()end)
 stage(function()reset();s:replaceRawDisplayData(nil,index);s:_updateDisplayData()end)
 stage(function()reset();s:replaceDisplayData(nil,index);s:_updateDisplayData()end)
 stage(function()reset();s:replaceTextureData(override,index);s:_updateDisplayData()end)
 stage(function()reset();s:_setDisplayIndex(1);s:_updateDisplayData()end)
 stage(function()reset();s:_setDisplayIndex(-1);s:_updateDisplayData()end)
 arm:returnToPool()
 all[#all+1]=tostring(s._isInPool);all[#all+1]=tostring(s._displayFrames.length);all[#all+1]=tostring(s._geometryBones.length);all[#all+1]=tostring(s.origin==nil);all[#all+1]=table.concat(hooks,";")
 for i=#owned,1,-1 do owned[i]:returnToPool()end
 gd:returnToPool()
 return table.concat(all,'\t')
end
local input=assert(arg[1])
for line in io.lines(input)do local c={};for v in(line..'\t'):gmatch('(.-)\t')do c[#c+1]=v end;print(execute(c))end
