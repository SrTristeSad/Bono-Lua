local D=require('dragonbones.parser.DataParser')
local B=require('dragonbones.core.BaseObject')
local J=require('dragonbones.core.JSArray')
local A=require('dragonbones.model.ArmatureData')
local Displays=require('dragonbones.model.DisplayData')
local Boxes=require('dragonbones.model.BoundingBoxData')
local Actions=require('dragonbones.model.UserData')
local Path=require('dragonbones.model.ConstraintData').PathConstraintData
local Animation=require('dragonbones.model.AnimationData').AnimationData
local derived=setmetatable({},{__index=D})
local function unhex(s)return (s:gsub('..',function(c)return string.char(tonumber(c,16)) end)) end
local function hex(s)return (s:gsub('.',function(c)return string.format('%02x',c:byte()) end)) end
local function scalar(v)if v==nil then return 'undefined' elseif type(v)=='string' then return 's:'..hex(v) elseif type(v)=='boolean' then return v and 'true' or 'false' end;return string.format('%.0f',v) end
local function split(s)local out={};for v in (s..'\t'):gmatch('(.-)\t') do out[#out+1]=v end;return out end
local function array(a)
 local entries={};for k,v in pairs(a) do entries[#entries+1]={key=type(k)=='number' and string.format('%.0f',k-1) or k,value=v} end
 table.sort(entries,function(a,b)return a.key<b.key end);local out={};for _,e in ipairs(entries) do out[#out+1]=e.key..'='..scalar(e.value) end
 return string.format('%.0f',a.length)..':'..table.concat(out,',')
end
local fields={Armature='type',Bone='type',Position='positionMode',Spacing='spacingMode',Rotate='rotateMode',Display='type',BoundingBox='type',Blend='blendMode',Animation='blendType',Action='type'}
local function model(kind,method,value)
 local typ=D[method](value);local C
 if kind=='Armature' then C=A.ArmatureData
 elseif kind=='Bone' then C=typ==1 and A.SurfaceData or A.BoneData
 elseif kind=='Position' or kind=='Spacing' or kind=='Rotate' then C=Path
 elseif kind=='Display' then C=({Displays.ImageDisplayData,Displays.ArmatureDisplayData,Displays.MeshDisplayData,Displays.BoundingBoxDisplayData,Displays.PathDisplayData})[typ+1]
 elseif kind=='BoundingBox' then C=({Boxes.RectangleBoundingBoxData,Boxes.EllipseBoundingBoxData,Boxes.PolygonBoundingBoxData})[typ+1]
 elseif kind=='Blend' then C=A.SlotData
 elseif kind=='Animation' then C=Animation
 elseif kind=='Action' then C=Actions.ActionData
 else error('Unknown model') end
 local o=B.borrowObject(C);local field=fields[kind];o[field]=typ;local before=o[field];local id=o.hashCode;o:returnToPool()
 return table.concat({C.toString(),scalar(id),field,scalar(before),scalar(o[field]),scalar(o._isInPool)},'|')
end
local function execute(row)
 local op,a,b,c=row[1],row[2],row[3],row[4]
 if op=='constant' then return a=='DATA_VERSIONS' and 'array:'..array(D[a]) or scalar(D[a])
 elseif op=='abstract' then return scalar(D[a]==nil and 'undefined' or type(D[a]))..'|'..scalar(derived[a]==nil and 'undefined' or type(derived[a]))
 elseif op=='convert' then
  local v;if b=='string' then v=unhex(c) elseif b=='number' then v=0 elseif b=='boolean' then v=false elseif b=='object' then v={} end
  return scalar(D[a](v))
 elseif op=='model' then return model(a,b,unhex(c))
 elseif op=='versions' then return array(D.DATA_VERSIONS)
 elseif op=='versionExtra' then D.DATA_VERSIONS.extra=unhex(a)
 elseif op=='versionWrite' then D.DATA_VERSIONS[tonumber(a)+1]=unhex(b)
 elseif op=='versionHole' then rawset(D.DATA_VERSIONS,tonumber(a)+1,nil)
 elseif op=='versionLength' then D.DATA_VERSIONS.length=tonumber(a)
 elseif op=='derivedAlias' then return scalar(rawequal(derived.DATA_VERSIONS,D.DATA_VERSIONS))..'|'..array(derived.DATA_VERSIONS)
 elseif op=='shadowVersions' then local values=J.new();values[1]='private';derived.DATA_VERSIONS=values
 elseif op=='setConstant' then D[a]=unhex(b)
 else error('Unknown command') end
 return 'void'
end
local index=0
for line in io.lines(assert(arg[1])) do
 local row=split(line);local ok,result=pcall(execute,row)
 if not ok then if row[1]~='convert' or row[3]=='string' then error(result) end;result='error' end
 io.write(tostring(index),'\t',row[1],'\t',result,'\t',scalar(B._hashCode),'\n');index=index+1
end
