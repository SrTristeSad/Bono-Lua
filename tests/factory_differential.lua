local function req(p)return require('dragonbones.'..p)end
local B,Parser,JSON,Arm,Bone,Surface,Slot,IK,Core,Animation,State,Config,Map=req('core.BaseObject'),req('parser.ObjectDataParser'),req('parser.JSON'),req('armature.Armature'),req('armature.Bone'),req('armature.Surface'),req('armature.Slot'),req('armature.IKConstraint'),req('core.DragonBones'),req('animation.Animation'),req('animation.AnimationState'),req('model.AnimationConfig'),req('core.JSMap')
local double;if string.pack then double=function(n)return string.pack('<d',n)end else local ffi=require('ffi');double=function(n)return ffi.string(ffi.new('double[1]',n),8)end end
local function scalar(v)if v==nil then return'u'end;if type(v)=='string'then return's'..(v:gsub('.',function(c)return string.format('%02x',c:byte())end))end;if type(v)=='boolean'then return tostring(v)end;if v~=v then return'NaN'end;return'n'..(double(v):gsub('.',function(c)return string.format('%02x',c:byte())end))end
local BaseFactory=req('factory.BaseFactory');local Types=req('model.TextureAtlasData');local Skin=req('model.SkinData')
local function read(path)local f=assert(io.open(path));local s=f:read('*a');f:close();return s end
local fixture,atlasFixture,binaryHeader=read('examples/factory_ske.json'),read('examples/factory_tex.json'),read('tests/fixtures/factory_binary_header.json')
local function execute(c)
local auto,dataName,skinName,atlasName,mesh,childProfile,op=tonumber(c[1]),c[2],c[3],c[4],tonumber(c[5]),tonumber(c[6]),c[7]
local warnings=0;local stderr=io.stderr;io.stderr={write=function()warnings=warnings+1 end}
local out,hooks,binds,built,allData,atlases={},{},{},{},{},{};local frames,events=0,0
local function push(v)out[#out+1]=tostring(v)end;local function fields(o,keys)for _,k in ipairs(keys)do push(scalar(o[k]))end end
local raw,atlasRaw=JSON.parse(fixture),JSON.parse(atlasFixture)
if childProfile>0 then raw.armature[1].skin[1].slot[2].display=JSON.parse('[{"name":"childDisplay","path":"child","type":"armature"}]');if op=='missingChild'then raw.armature[1].skin[1].slot[2].display[1].path='absent'end end
if childProfile==2 then raw.armature[2].defaultActions=JSON.parse('[{"gotoAndPlay":"alt"}]')end
if op=='childActions'then raw.armature[1].skin[1].slot[2].display[1].actions=JSON.parse('[{"gotoAndPlay":"move"}]')end
if op=='embedded'then raw.textureAtlas=JSON.parse('['..atlasFixture..']')end
if op=='path'then raw.armature=JSON.parse(read('examples/path_ske.json')).armature end
local Texture={};Texture.__index=Texture;setmetatable(Texture,{__index=Types.TextureData});function Texture.toString()return'[test.FactoryTexture]'end;function Texture.new()return Types.TextureData.new(Texture)end
local Atlas={};Atlas.__index=Atlas;setmetatable(Atlas,{__index=Types.TextureAtlasData});function Atlas.toString()return'[test.FactoryAtlas]'end;function Atlas.new()return Types.TextureAtlasData.new(Atlas)end;function Atlas:createTexture()return B.borrowObject(Texture)end;function Atlas:_onClear()Types.TextureAtlasData._onClear(self);self.backend=nil end
local Observer={__newindex=Slot.__newindex};Observer.__index=function(self,key)return rawget(Observer,key)or Slot.__index(self,key)end;setmetatable(Observer,{__index=Slot});function Observer.toString()return'[test.FactorySlot]'end;function Observer.new()return Slot.new(Observer)end
for _,hook in ipairs({'_initDisplay','_disposeDisplay','_onUpdateDisplay','_addDisplay','_replaceDisplay','_removeDisplay','_updateZOrder','_updateVisible','_updateBlendMode','_updateColor','_updateFrame','_updateMesh','_updateTransform','_identityTransform'})do Observer[hook]=function(self)hooks[#hooks+1]=self.name..':'..hook end end
for _,cls in ipairs({Atlas,Texture,Observer})do B.clearPool(cls)end
local sound={};function sound:dispatchDBEvent()events=events+1 end;local saved=print;print=function()end;local core=Core.new(sound);print=saved
local Factory={__newindex=BaseFactory.__newindex};Factory.__index=function(self,key)return rawget(Factory,key)or BaseFactory.__index(self,key)end;setmetatable(Factory,{__index=BaseFactory})
function Factory.new(parser)local self=BaseFactory.new(parser,Factory);self._dragonBones=core;return self end
function Factory:_isSupportMesh()return mesh~=0 and op~='meshFallback'end
function Factory:_buildTextureAtlasData(atlas,texture)binds[#binds+1]=(atlas and'bind'or'new')..'~'..scalar(texture);if atlas==nil then atlas=B.borrowObject(Atlas);atlases[#atlases+1]=atlas else atlas.backend=texture end;return atlas end
function Factory:_buildArmature(pkg)local arm=B.borrowObject(Arm);local proxy={};function proxy:dbInit()end;function proxy:dbUpdate()frames=frames+1 end;function proxy:dbClear()end;function proxy:hasDBEventListener()return true end;function proxy:dispatchDBEvent()events=events+1 end;arm:init(pkg.armature,proxy,{},core);built[#built+1]=arm;return arm end
function Factory:_buildSlot(pkg,sd,arm)local slot=B.borrowObject(Observer);slot:init(sd,arm,{},{});return slot end
local factory=Factory.new(op=='customParser'and Parser.new()or nil);factory.autoSearch=auto==1
local rawInput=raw;if op=='binary'then local h=binaryHeader;while #h%4~=0 do h=h..' 'end;local n=#h;local length=string.char(n%256,math.floor(n/256)%256,math.floor(n/65536)%256,math.floor(n/16777216)%256);rawInput=req('parser.SharedBinaryBuffer').new('DBDT'..string.rep('\0',4)..length..h)end
local data=factory:parseDragonBonesData(rawInput,'demo',op=='scale'and 2 or 1);allData[#allData+1]=data;data.autoSearch=op~='noAutoData'
local savedSkins;local armData=data:getArmature(op=='path'and'arm'or'playback')
if armData then if childProfile==2 or op=='childActions'or op=='childNoActions'then armData.defaultSkin:getDisplays('plain')[1].inheritAnimation=false end;if op=='noSkin'then savedSkins=armData.skins;armData.skins=Map.new()end;if op=='noDefault'then armData.defaultSkin=nil end;if op=='unknownConstraint'then armData.constraints.aim.type=99 end end
local first=factory:parseTextureAtlasData(atlasRaw,0,'demo',op=='scale'and 2 or 1);first.autoSearch=op~='noAutoAtlas';local secondaryRaw=JSON.parse(atlasFixture);secondaryRaw.name='override';local second=factory:parseTextureAtlasData(secondaryRaw,1,'override');second.autoSearch=op~='noAutoAtlas';factory:addTextureAtlasData(first,'demo');factory:addDragonBonesData(data,'demo')
if op=='duplicate'then local other=Parser.new():parseDragonBonesData(JSON.parse(fixture));allData[#allData+1]=other;factory:addDragonBonesData(other,'demo')end;if op=='numericKeys'then factory:addDragonBonesData(data,'10');factory:addDragonBonesData(data,'2');factory:addTextureAtlasData(second,'10');factory:addTextureAtlasData(first,'2')end
local requestedData=op=='noAutoData'and'missing'or dataName=='empty'and''or dataName;local requestedSkin=op=='skinArmature'and'child'or skinName=='empty'and''or skinName;local pack=BaseFactory.BuildArmaturePackage.new();local found=factory:_fillBuildArmaturePackage(pack,requestedData,op=='path'and'arm'or'playback',requestedSkin,atlasName=='empty'and''or atlasName)
push(found);push(pack.dataName);push(pack.textureAtlasName);push(pack.data==data);push(armData~=nil and pack.armature==armData);push(pack.skin and pack.skin.name or'-');push(factory.clock==core.clock);push(factory.dragonBones==core);push(factory._dataParser==BaseFactory._objectParser)
local maps,textures=factory:getAllDragonBonesData(),factory:getAllTextureAtlasData();local arm
local function snap(status)push(status);push(warnings);push(frames);push(events);push(table.concat(Map.keys(maps),','));push(table.concat(Map.keys(textures),','));push(maps==factory:getAllDragonBonesData());push(textures==factory:getAllTextureAtlasData());push(#built);push(table.concat(binds,'|'));push(table.concat(hooks,'|'));push(scalar(first.scale));push(first._isInPool);push(second._isInPool);push(factory:_getTextureData('absent','meshSlot')==first:getTexture('meshSlot'))
if arm and arm._armatureData then push(arm.name);local names={};for i=1,arm:getBones().length do names[i]=arm:getBones()[i].name end;push(table.concat(names,','));local cons={};for i=1,arm._constraints.length do cons[i]=arm._constraints[i].toString()end;push(table.concat(cons,','));local animations={};for i=1,arm.animation.animationNames.length do animations[i]=arm.animation.animationNames[i]end;push(table.concat(animations,','));push(data:getArmature('child')~=nil and arm.animation.animations.move==data:getArmature('child'):getAnimation('move'))
for i=1,arm:getBones().length do fields(arm:getBones()[i].animationPose,{'x','y','rotation','skew','scaleX','scaleY'})end
for i=1,arm:getSlots().length do local slot=arm:getSlots()[i];push(slot.name);push(slot.displayIndex);push(slot.displayFrameCount);push(slot.childArmature and slot.childArmature.name or'-');push(slot.display==slot.meshDisplay)
for j=1,slot._displayFrames.length do local f=slot._displayFrames[j];local raw,rep,tex=f.rawDisplayData,f.displayData,f:getTextureData();if raw==Skin.NULL then raw=nil end;if rep==Skin.NULL then rep=nil end;push(raw and raw.name or'-');push(rep and rep.name or'-');push(tex and tex.name or'-');push(tex and tex.parent.name or'-');local kind='other';if f.display==slot.rawDisplay then kind='raw'elseif f.display==slot.meshDisplay then kind='mesh'elseif type(f.display)=='table'and f.display.constructor==Arm then kind='child'elseif f.display==nil then kind='nil'end;push(kind);local v={};for k=1,f.deformVertices.length do v[k]=scalar(f.deformVertices[k])end;push(table.concat(v,','))end
end end
local objs={};for _,o in ipairs(core._objects)do objs[#objs+1]=o.toString()end;push(table.concat(objs,'|'))
end
local function stage(fn)local ok=pcall(fn);snap(ok and'ok'or'error');hooks={};binds={}end
stage(function()factory:updateTextureAtlases(JSON.parse('[false,2]'),'demo');factory:updateTextureAtlases(JSON.parse('[]'),'missing')end)
stage(function()arm=factory:buildArmature(op=='missingArm'and'absent'or op=='binary'and'binArm'or op=='path'and'arm'or'playback',requestedData,requestedSkin,atlasName=='empty'and''or atlasName)end)
if arm then stage(function()local s=arm.animation:play(op=='path'and'walk'or'move',0);arm.clock=factory.clock;core:advanceTime(.25)end)
stage(function()local slot=arm:getSlot('meshSlot');local skin=armData and armData:getSkin('alternate');
if op=='replaceDisplay'then factory:replaceDisplay(slot,armData.defaultSkin:getDisplay('meshSlot','image'),0)
elseif op=='replaceNull'then factory:replaceDisplay(slot,nil)
elseif op=='replaceSlot'then push(factory:replaceSlotDisplay('demo','playback','plain','plainImage',slot))
elseif op=='replaceSlotMissing'then push(factory:replaceSlotDisplay('absent','absent','plain','absent',slot))
elseif op=='replaceList'then push(factory:replaceSlotDisplayList('demo','playback','meshSlot',slot))
elseif op=='replaceListMissing'then push(factory:replaceSlotDisplayList('demo','playback','absent',slot))
elseif op=='replaceSkin'then push(factory:replaceSkin(arm,skin))
elseif op=='overrideSkin'or op=='overrideMissing'then if op=='overrideMissing'then armData.defaultSkin=nil end;push(factory:replaceSkin(arm,skin,true))
elseif op=='excludeSkin'then push(factory:replaceSkin(arm,skin,true,JSON.parse('["meshSlot"]')))
elseif op=='excludeHole'then local exclude=req('core.JSArray').new();exclude.length=2;exclude[2]='meshSlot';push(factory:replaceSkin(arm,skin,true,exclude))
elseif op=='replaceAnimation'or op=='mergeAnimation'or op=='noAnimationSkin'then local donor=data:getArmature('child');if op=='noAnimationSkin'then donor.defaultSkin=nil end;push(factory:replaceAnimation(arm,donor,op~='mergeAnimation'))end
end);stage(function()core:advanceTime(.25)end)end
if op=='remove'or op=='removeFalse'then stage(function()factory:removeDragonBonesData('demo',op=='remove');factory:removeTextureAtlasData('demo',op=='remove')end)end;if op=='clearFalse'then stage(function()factory:clear(false)end)end;if op=='readonly'then for _,key in ipairs({'clock','dragonBones'})do stage(function()factory[key]=false end)end end
for _,a in ipairs(built)do if a._armatureData~=nil then a:dispose()end end;core:advanceTime(0);core:advanceTime(0);if savedSkins then armData.skins=savedSkins end;factory:clear();core:advanceTime(0);for _,a in ipairs(allData)do if not a._isInPool then a:returnToPool()end end;for _,a in ipairs(atlases)do if not a._isInPool then a:returnToPool()end end;push(#Map.keys(maps));push(#Map.keys(textures));push(#core._events);push(#core._objects);for _,a in ipairs(built)do push(a._isInPool)end;io.stderr=stderr;return table.concat(out,'\t')
end
for line in io.lines(arg[1])do local c={};for v in line:gmatch('[^\t]+')do c[#c+1]=v end;io.write(execute(c),'\n')end
