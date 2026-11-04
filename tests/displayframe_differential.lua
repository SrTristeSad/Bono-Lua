local B=require('dragonbones.core.BaseObject')
local D=require('dragonbones.model.DisplayData')
local Texture=require('dragonbones.model.TextureAtlasData').TextureData
local Data=require('dragonbones.model.DragonBonesData')
local Box=require('dragonbones.model.BoundingBoxData').RectangleBoundingBoxData
local Frame=require('dragonbones.armature.DisplayFrame')
local classes={D.ImageDisplayData,D.MeshDisplayData,D.PathDisplayData,D.BoundingBoxDisplayData,D.ArmatureDisplayData}
local input=assert(arg[1])
for line in io.lines(input) do
  local r,v,t,w,op=line:match('^(%d+)\t(%d+)\t(%d+)\t(%d+)\t(.+)$')
  r,v,t,w=tonumber(r),tonumber(v),tonumber(t),tonumber(w)
  local owned,ids={},{}
  local function borrow(C,id) local x=B.borrowObject(C);owned[#owned+1]=x;ids[x]=id;return x end
  local function texture(id) local x=Texture.new(Texture);x:_onClear();ids[x]=id;return x end
  local tex={texture('rawTexture'),texture('replacementTexture'),texture('overrideTexture')}
  local function display(kind,id,texture)
    if kind==0 then return nil end
    local x=borrow(classes[kind],id)
    if kind==1 or kind==2 then if t~=3 then x.texture=texture end end
    if kind==2 or kind==3 then
      ids[x.geometry]=id..'Geometry'
      local data=borrow(Data,id..'Data');data.intArray={99,3};x.geometry.data=data;x.geometry.offset=1
      if w==1 then x.geometry.weight=B.borrowObject(D.WeightData);x.geometry.weight.count=4 end
      if op=='badCount' then if w==1 then x.geometry.weight.count=-1 else data.intArray[2]=-1 end end
      if op=='zero' then if w==1 then x.geometry.weight.count=0 else data.intArray[2]=0 end end
      if op=='badOffset' then x.geometry.offset=100 end
      if op=='missingData' then x.geometry.data=nil end
    end
    if kind==4 then x.boundingBox=B.borrowObject(Box);ids[x.boundingBox]=id..'Box' end
    return x
  end
  local f=B.borrowObject(Frame);local a=f.deformVertices
  f.rawDisplayData=display(r,'raw',tex[1]);f.displayData=display(v,'replacement',tex[2]);if t==1 or t==3 then f.textureData=tex[3] end;f.display=tex[1]
  if op=='prefilled' then a[1]=7;a[2]=-0.0 end
  if op=='holes' then a.length=3 end
  local ok=pcall(function() f:updateDeformVertices();if op=='repeat' then if a.length>0 then a[1]=9 end;f:updateDeformVertices() end end)
  local function id(x) return x==nil and 'nil' or assert(ids[x]) end
  local values={};for i=1,a.length do local x=a[i];values[i]=x==nil and 'hole' or (x==0 and 1/x<0 and '-0' or string.format('%g',x)) end
  local out={ok and 'ok' or 'error',id(f:getGeometryData()),id(f:getBoundingBox()),id(f:getTextureData()),tostring(a.length),table.concat(values,',')}
  f:returnToPool()
  local function add(x) out[#out+1]=tostring(x) end
  add(f.deformVertices==a);add(a.length);add(f.rawDisplayData==nil);add(f.displayData==nil);add(f.textureData==nil);add(f.display==nil)
  local again=B.borrowObject(Frame);add(again==f);add(again.deformVertices==a);again:returnToPool()
  for i=#owned,1,-1 do owned[i]:returnToPool() end
  print(table.concat(out,'|'))
end
