local Factory=require('dragonbones.love.Factory')
local JSON=require('dragonbones.parser.JSON')
local Core=require('dragonbones.core.DragonBones')
local function read(p)local f=assert(io.open(p));local t=f:read('*a');f:close();return t end
local fixture,atlasText=read('examples/love/sprites_ske.json'),read('examples/love/sprites_tex.json')
local double;if string.pack then double=function(n)return string.pack('<d',n)end else local ffi=require('ffi');double=function(n)return ffi.string(ffi.new('double[1]',n),8)end end
local function scalar(v)if v==nil then return'u'end;if type(v)=='boolean'then return tostring(v)end;if type(v)=='string'then return's'..(v:gsub('.',function(c)return('%02x'):format(c:byte())end))end;if v~=v then return'NaN'end;return'n'..(double(v):gsub('.',function(c)return('%02x'):format(c:byte())end))end
local function execute(c)
local alpha,tint,scale,flip,blend,op=tonumber(c[1]),tonumber(c[2]),tonumber(c[3]),tonumber(c[4]),tonumber(c[5]),c[6]
local sound={};function sound:dispatchDBEvent()end;local saved=print;print=function()end;local core=Core.new(sound);print=saved
local f=Factory.new(core);local raw,ar=JSON.parse(fixture),JSON.parse(atlasText)
for i=1,raw.armature[1].slot.length do local s=raw.armature[1].slot[i];s.color={aM=alpha*100,rM=tint*100,gM=100,bM=100};s.blendMode=blend end
if op=='trim'then local t=ar.SubTexture[1];t.frameX=-2;t.frameY=-1;t.frameWidth=20;t.frameHeight=18 end
f:parseDragonBonesData(raw,'sprites',scale);local image={width=48,height=16};local atlas=f:parseTextureAtlasData(ar,image,'sprites');local a=f:buildArmature('demo','sprites');a.flipX=flip==1;if op=='cache'then a.cacheFrameRate=4 end;local s=a.animation:play('move',0)
local out={};local function push(v)out[#out+1]=tostring(v)end
local keys={'x','y','scaleX','scaleY','rotation','skewX','skewY','alpha','tint','visible','blendMode'}
for step=0,3 do
if step==1 then if op=='hidden'then a:getSlot('red').visible=false elseif op=='replaceTexture'then a.replacedTexture={width=48,height=16}elseif op=='removeTexture'then atlas.renderTexture=nil elseif op=='missingFrame'then a:getSlot('red').displayIndex=-1 elseif op=='stop'then a.animation:stop()elseif op=='order'then a:getSlot('red')._zIndex=3;a._zIndexDirty=true end end
a:advanceTime(step==0 and 0 or .25);push(#a.display.children);for _,d in ipairs(a.display.children)do for _,k in ipairs(keys)do push(scalar(d[k]))end;local t=d.texture;push(t and'texture'or'nil');if t then for _,k in ipairs({'x','y','width','height'})do push(scalar(t[k]))end end end;push(scalar(s.currentTime))
end
a:dispose();core:advanceTime(0);f:clear();core:advanceTime(0);return table.concat(out,'\t')
end
for line in io.lines(arg[1])do local c={};for v in line:gmatch('[^\t]+')do c[#c+1]=v end;io.write(execute(c),'\n')end
