local Factory=require('dragonbones.love.Factory')
local JSON=require('dragonbones.parser.JSON')
local Core=require('dragonbones.core.DragonBones')
local function read(p)local f=assert(io.open(p));local t=f:read('*a');f:close();return t end
local fixture,atlasText=read('examples/love/meshes_ske.json'),read('examples/love/sprites_tex.json')
local double;if string.pack then double=function(n)return string.pack('<d',n)end else local ffi=require('ffi');double=function(n)return ffi.string(ffi.new('double[1]',n),8)end end
local function scalar(v)if v==nil then return'u'end;if type(v)=='boolean'then return tostring(v)end;if type(v)=='string'then return's'..(v:gsub('.',function(c)return('%02x'):format(c:byte())end))end;if v~=v then return'NaN'end;return'n'..(double(v):gsub('.',function(c)return('%02x'):format(c:byte())end))end
local function execute(c)
local scale,weighted,inherit,atlasSize,rate,op=tonumber(c[1]),tonumber(c[2]),tonumber(c[3]),tonumber(c[4]),tonumber(c[5]),c[6]
local sound={};function sound:dispatchDBEvent()end;local saved=print;print=function()end;local core=Core.new(sound);print=saved
local f=Factory.new(core);local raw,ar=JSON.parse(fixture),JSON.parse(atlasText);local skin=raw.armature[1].skin[1].slot
if weighted==0 then skin[2].display[1].weights=JSON.parse('[1,0,1,1,0,1,1,0,1,1,0,1]')end
if atlasSize==0 then ar.width=0;ar.height=0 end;if op=='tint'then for i=1,raw.armature[1].slot.length do raw.armature[1].slot[i].color={aM=50,rM=25,gM=75,bM=50}end end;if op=='noFFD'then raw.armature[1].animation[1].ffd=nil end
if op=='largeOffsets'then local a=raw.armature[1];local pad=JSON.parse('{"name":"padding","display":[{"name":"padding","type":"mesh","vertices":[],"uvs":[],"triangles":[]}]}');for i=1,16384 do pad.display[1].vertices[i]=0;pad.display[1].uvs[i]=0 end;for i=a.slot.length,1,-1 do a.slot[i+1]=a.slot[i]end;a.slot[1]=JSON.parse('{"name":"padding","parent":"root","displayIndex":-1}');for i=skin.length,1,-1 do skin[i+1]=skin[i]end;skin[1]=pad end
f:parseDragonBonesData(raw,'sprites',scale);local image={width=48,height=16};local atlas=f:parseTextureAtlasData(ar,image,'sprites');local ad=f:getArmatureData('demo','sprites');for _,n in ipairs({'mesh','weighted','surface'})do ad.defaultSkin:getDisplays(n)[1].geometry.inheritDeform=inherit==1 end
local a=f:buildArmature('demo','sprites');a.animation.timeScale=rate;if op=='cache'then a.cacheFrameRate=4 end;local state=a.animation:play('move',0)
local out={};local function push(v)out[#out+1]=tostring(v)end
local keys={'x','y','scaleX','scaleY','rotation','skewX','skewY','alpha','tint','visible','blendMode'}
for step=0,3 do
if step==1 then if op=='identity'then local slot=a:getSlot('weighted');slot.meshDisplay:setTransform(3,4,2,2,1,1,1);slot._geometryDirty=true elseif op=='missingBone'then a:getSlot('weighted')._geometryBones[1]=nil;a:getSlot('weighted')._verticesDirty=true elseif op=='replaceTexture'then a.replacedTexture={width=48,height=16}elseif op=='removeTexture'then atlas.renderTexture=nil elseif op=='stop'then a.animation:stop()elseif op=='reset'then a.animation:reset();state=a.animation:play('move',0)end end
a:advanceTime(step==0 and 0 or .25);push(#a.display.children);for _,d in ipairs(a.display.children)do for _,k in ipairs(keys)do push(scalar(d[k]))end;local t=d.texture;push(t and'texture'or'nil');if d.kind=='mesh'then for _,k in ipairs({'vertices','uvs','indices'})do local v={};if d[k]then for i=1,d[k].length do v[i]=scalar(d[k][i])end end;push(table.concat(v,','))end;push(scalar(d.dirty));push(scalar(d.indexDirty))end;if t then for _,k in ipairs({'x','y','width','height'})do push(scalar(t[k]))end end end;push(scalar(state.currentTime))
end
a:dispose();core:advanceTime(0);f:clear();core:advanceTime(0);return table.concat(out,'\t')
end
for line in io.lines(arg[1])do local c={};for v in line:gmatch('[^\t]+')do c[#c+1]=v end;io.write(execute(c),'\n')end
