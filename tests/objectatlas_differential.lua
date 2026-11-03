local d,B,P,p,A,T,V,raws,atlasObject,textures,warnings,log,hook,ids,nextId,frames,JSMap
local stderr=io.stderr
local bytes
if string.pack then bytes=function(v)return string.pack('<d',v) end else local ffi=require('ffi');bytes=function(v)local b=ffi.string(ffi.new('double[1]',v),8);return ffi.abi('le') and b or b:reverse() end end
local function keys(t)local a={};for k in pairs(t) do a[#a+1]=k end;table.sort(a);return a end
local function unhex(s)return (s:gsub('..',function(c)return string.char(tonumber(c,16)) end)) end
local function num(s)if s=='NaN' then return 0/0 elseif s=='Infinity' then return math.huge elseif s=='-Infinity' then return -math.huge elseif s=='-0' then return -0.0 end;return assert(tonumber(s))+0.0 end
local function decode(v)if v=='null' then return V.NULL elseif v=='undefined' then return V.UNDEFINED elseif v:sub(1,2)=='s:' then return unhex(v:sub(3)) elseif v:sub(1,2)=='n:' then return num(v:sub(3)) elseif v:sub(1,2)=='b:' then return v=='b:true' end;return raws[v:sub(3)] end
local function scalar(v)
 if v==nil or rawequal(v,V.UNDEFINED) then return 'undefined' elseif rawequal(v,V.NULL) then return 'null' elseif type(v)=='string' then return 's:'..v:gsub('.',function(c)return string.format('%02x',c:byte()) end) elseif type(v)=='boolean' then return v and 'true' or 'false' elseif v~=v then return 'NaN' end
 return 'n:'..bytes(v):gsub('.',function(c)return string.format('%02x',c:byte()) end)
end
local function integer(n)return string.format('%.0f',n) end
local function ref(o)return o==nil and 'nil' or '#'..integer(o.hashCode) end
local function id(o)if not ids[o] then nextId=nextId+1;ids[o]=nextId end;return ids[o] end
local execute
local function reset()
 for _,k in ipairs({'dragonbones.core.BaseObject','dragonbones.model.TextureAtlasData','dragonbones.parser.ObjectDataParser'}) do package.loaded[k]=nil end
 B=require('dragonbones.core.BaseObject');P=require('dragonbones.parser.ObjectDataParser');V=require('dragonbones.parser.JSValue');JSMap=require('dragonbones.core.JSMap');local m=require('dragonbones.model.TextureAtlasData')
 p=P.new();raws={};textures={};frames={};warnings={};log={};hook=nil;ids=setmetatable({},{__mode='k'});nextId=0
 T={};T.__index=T;setmetatable(T,{__index=m.TextureData});function T.toString()return '[test.Atlas.Texture]' end;function T.new()return m.TextureData.new(T) end
 A={};A.__index=A;setmetatable(A,{__index=m.TextureAtlasData});function A.toString()return '[test.Atlas.Atlas]' end;function A.new()return m.TextureAtlasData.new(A) end
 function A:createTexture()
  self.calls=(self.calls or 0)+1;log[#log+1]='create:'..integer(self.calls);if self.failAt==self.calls then error('factory failure') end
  if hook then local command=hook;hook=nil;execute(command) end
  local t=B.borrowObject(T);textures[#textures+1]=t;return t
 end
 atlasObject=B.borrowObject(A)
end
execute=function(r)
 local op,a,b,c=r[1],r[2],r[3],r[4]
 if op=='object' then raws[a]={}
 elseif op=='array' then raws[a]=V.array()
 elseif op=='put' then raws[a][b]=decode(c)
 elseif op=='append' then local array=raws[a];array[array.length+1]=decode(b)
 elseif op=='helper' then local raw={};if b~='absent' then raw.v=decode(b) end;return scalar(P['_get'..a](raw,'v',decode(c)))
 elseif op=='parse' then if b=='omit' then return scalar(p:parseTextureAtlasData(decode(a),atlasObject)) end;return scalar(p:parseTextureAtlasData(decode(a),atlasObject,decode(b)))
 elseif op=='parseOmit' then return scalar(p:parseTextureAtlasData())
 elseif op=='queue' then p._rawTextureAtlases=raws[a];p._rawTextureAtlasIndex=0
 elseif op=='failAt' then atlasObject.failAt=tonumber(a)
 elseif op=='factoryHook' then hook={};for i=2,#r do hook[#hook+1]=r[i] end
 elseif op=='clearAtlas' then atlasObject:_onClear()
 elseif op=='returnAtlas' then atlasObject:returnToPool()
 elseif op=='borrowAtlas' then atlasObject=B.borrowObject(A)
 elseif op=='newParser' then p=P.new()
 elseif op=='singleton' then local old=p;p=P.getInstance();return rawequal(old,p) and 'same' or 'different'
 elseif op=='actionFrame' then frames[#frames+1]=P.ActionFrame.new()
 else error(op) end
 return 'void'
end
local arrayFields={'_rawBones','_helpArray','_intArray','_floatArray','_frameIntArray','_frameFloatArray','_frameArray','_timelineArray','_colorArray','_cacheRawMeshes','_cacheMeshes','_actionFrames'}
local mapFields={'_weightSlotPose','_weightBonePoses','_cacheBones','_slotChildActions'}
local refs={'_data','_armature','_bone','_geometry','_slot','_skin','_mesh','_animation','_timeline'}
local scalars={'_rawTextureAtlasIndex','_frameValueType','_defaultColorOffset','_prevClockwise','_prevRotation','_frameDefaultValue','_frameValueScale'}
local function rect(r)if r==nil then return 'nil' end;local ident=id(r);local out={};for _,k in ipairs({'x','y','width','height'}) do out[#out+1]=scalar(r[k]) end;return ident..':'..table.concat(out,',') end
local function parser()
 local out={id(p)};for _,k in ipairs(scalars) do out[#out+1]=scalar(p[k]) end;for _,k in ipairs(refs) do out[#out+1]=p[k]==nil and 'nil' or 'present' end
 for _,k in ipairs(arrayFields) do out[#out+1]=id(p[k])..':'..integer(p[k].length) end
 for _,k in ipairs(mapFields) do out[#out+1]=id(p[k])..':'..table.concat(keys(p[k]),',') end
 for _,k in ipairs({'_helpMatrixA','_helpMatrixB','_helpTransform','_helpColorTransform','_helpPoint'}) do local ident=id(p[k]);local parts={};for _,f in ipairs(keys(p[k])) do parts[#parts+1]=f..'='..scalar(p[k][f]) end;out[#out+1]=ident..':'..table.concat(parts,',') end
 out[#out+1]=p._rawTextureAtlases==nil and 'nil' or id(p._rawTextureAtlases)..':'..integer(p._rawTextureAtlases.length)
 return table.concat(out,'|')
end
local function snapshot()
 local out={scalar(B._hashCode),parser()};local parts={ref(atlasObject),tostring(atlasObject._isInPool)}
 for _,k in ipairs({'width','height','scale','name','imagePath','calls','failAt'}) do parts[#parts+1]=scalar(atlasObject[k]) end
 local ident=id(atlasObject.textures);local entries={};for _,k in ipairs(keys(atlasObject.textures)) do entries[#entries+1]=k..'='..ref(atlasObject.textures[k]) end;parts[#parts+1]=ident..':'..table.concat(entries,',');out[#out+1]=table.concat(parts,'|');parts={}
 for _,t in ipairs(textures) do parts[#parts+1]=table.concat({ref(t),tostring(t._isInPool),scalar(t.name),scalar(t.rotated),ref(t.parent),rect(t.region),rect(t.frame)},':') end;out[#out+1]=table.concat(parts,'|');parts={}
 for _,k in ipairs(keys(B._poolsMap)) do local pool={};for i,v in ipairs(B._poolsMap[k]) do pool[i]=ref(v) end;parts[#parts+1]=k..'='..table.concat(pool,',') end;out[#out+1]=table.concat(parts,'|');out[#out+1]=table.concat(log,'|');out[#out+1]=table.concat(warnings,'|');parts={}
 for _,k in ipairs(keys(raws)) do if V.isArray(raws[k]) then parts[#parts+1]=k..'='..id(raws[k])..':'..integer(raws[k].length) end end;out[#out+1]=table.concat(parts,'|');parts={}
 for _,f in ipairs(frames) do parts[#parts+1]=id(f)..':'..scalar(f.frameStart)..':'..id(f.actions)..':'..integer(f.actions.length) end;out[#out+1]=table.concat(parts,'|')
 return out
end
io.stderr={write=function(_,s)warnings[#warnings+1]=s:gsub('\n$','') end}
local index=0
for line in io.lines(assert(arg[1])) do
 local row={};for v in (line..'\t'):gmatch('(.-)\t') do row[#row+1]=v end
 local tag='void';if row[1]=='begin' then reset() else warnings={};local ok,v=pcall(execute,row);tag=ok and v or 'error' end
 io.write(tostring(index),'\t',tag,'\t',table.concat(snapshot(),'\t'),'\n');index=index+1
end
io.stderr=stderr
