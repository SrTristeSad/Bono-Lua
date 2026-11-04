local d,B,P,p,V,classes,objects,lists,raws,allocated,seen,warnings,ids,nextId
local failReturn,failAddAction,callbackTrace,callbackFail
local nilLabels
local stderr=io.stderr
local bytes;if string.pack then bytes=function(v)return string.pack('<d',v) end else local ffi=require('ffi');bytes=function(v)local b=ffi.string(ffi.new('double[1]',v),8);return ffi.abi('le') and b or b:reverse() end end
local function keys(t)local a={};for k in pairs(t) do a[#a+1]=k end;table.sort(a);return a end
local function unhex(s)return (s:gsub('..',function(c)return string.char(tonumber(c,16)) end)) end
local function num(s)if s=='NaN' then return 0/0 elseif s=='Infinity' then return math.huge elseif s=='-Infinity' then return -math.huge elseif s=='-0' then return -0.0 end;return assert(tonumber(s))+0.0 end
local function decode(v)if v=='null' then return V.NULL elseif v=='undefined' then return V.UNDEFINED elseif v:sub(1,2)=='s:' then return unhex(v:sub(3)) elseif v:sub(1,2)=='n:' then return num(v:sub(3)) elseif v:sub(1,2)=='b:' then return v=='b:true' end;return raws[v:sub(3)] end
-- Test transport preserves lone UTF-16 surrogates produced by ES5 indexing.
local function string16(value)
 local out={};local i=1
 local function put(u)out[#out+1]=string.char(u%256,math.floor(u/256)) end
 while i<=#value do
  local a,b,c,d=value:byte(i,i+3);local cp,w
  if a>=128 and b==nil then error('Truncated bytes: '..(value:gsub('.',function(c)return string.format('%02x',c:byte()) end))) end
  if a<128 then cp,w=a,1 elseif a<224 then cp,w=(a-192)*64+b-128,2
  elseif a<240 then cp,w=(a-224)*4096+(b-128)*64+c-128,3
  else cp,w=(a-240)*262144+(b-128)*4096+(c-128)*64+d-128,4 end
  if cp>65535 then local v=cp-65536;put(55296+math.floor(v/1024));put(56320+v%1024) else put(cp) end;i=i+w
 end
 return table.concat(out):gsub('.',function(c)return string.format('%02x',c:byte()) end)
end
local function scalar(v)
 if v==nil or rawequal(v,V.UNDEFINED) then return 'undefined' elseif rawequal(v,V.NULL) then return 'null' elseif type(v)=='string' then return 's:'..string16(v) elseif type(v)=='boolean' then return v and 'true' or 'false' elseif type(v)=='table' then return 'object' elseif v~=v then return 'NaN' end
 return 'n:'..bytes(v):gsub('.',function(c)return string.format('%02x',c:byte()) end)
end
local function integer(n)return string.format('%.0f',n) end
local function ref(o)return (o==nil or rawequal(o,V.UNDEFINED) or rawequal(o,V.NULL) or rawequal(o,classes.K.NULL)) and 'nil' or '#'..integer(o.hashCode) end
local function id(o)if not ids[o] then nextId=nextId+1;ids[o]=nextId end;return ids[o] end
local function register(o)if not seen[o] then seen[o]=true;allocated[#allocated+1]=o;local original=o.returnToPool;function o:returnToPool()if failReturn and rawequal(self.constructor,classes[failReturn]) then failReturn=nil;error('return failure') end;return original(self) end end;return o end
local function reset()
 for _,k in ipairs({'dragonbones.core.BaseObject','dragonbones.model.UserData','dragonbones.model.DisplayData','dragonbones.model.AnimationData','dragonbones.model.ArmatureData','dragonbones.model.ConstraintData','dragonbones.model.SkinData','dragonbones.model.DragonBonesData','dragonbones.model.BoundingBoxData','dragonbones.parser.ObjectDataParser'}) do package.loaded[k]=nil end
 B=require('dragonbones.core.BaseObject');P=require('dragonbones.parser.ObjectDataParser');V=require('dragonbones.parser.JSValue');local a=require('dragonbones.model.ArmatureData');local ds=require('dragonbones.model.DisplayData');local c=require('dragonbones.model.ConstraintData');local u=require('dragonbones.model.UserData');local bb=require('dragonbones.model.BoundingBoxData')
 local anim=require('dragonbones.model.AnimationData');classes={N=anim.AnimationData,T=anim.TimelineData,Z=require('dragonbones.model.DragonBonesData'),F=a.SurfaceData,M=ds.MeshDisplayData,H=ds.ArmatureDisplayData,J=ds.BoundingBoxDisplayData,W=ds.WeightData,A=a.ArmatureData,B=a.BoneData,S=a.SlotData,K=require('dragonbones.model.SkinData'),P=ds.PathDisplayData,I=ds.ImageDisplayData,R=bb.RectangleBoundingBoxData,E=bb.EllipseBoundingBoxData,V=bb.PolygonBoundingBoxData,C=c.IKConstraintData,D=c.PathConstraintData,Q=u.ActionData,U=u.UserData}
 local Y={};Y.__index=Y;setmetatable(Y,{__index=classes.P});function Y.new()local o=classes.P.new();o.constructor=Y;return setmetatable(o,Y) end;classes.Y=Y
 raws,objects,lists,allocated,seen,warnings={},{},{},{},{},{};nilLabels={};ids=setmetatable({},{__mode='k'});nextId=0;failReturn=nil;failAddAction=0;callbackTrace={};callbackFail=0;p=P.new()
 local borrow=B.borrowObject;B.borrowObject=function(C)return register(borrow(C)) end;p._armature=B.borrowObject(classes.A);p._data=B.borrowObject(classes.Z)
end
local function execute(r)
 local op,a,b,c,e,f=r[1],r[2],r[3],r[4],r[5],r[6]
 if op=='animationSpec' then p._animation.frameCount=num(a);p._animation.frameOffset=num(b)
 elseif op=='indicesPrefix' then for i=0,num(a)-1 do local v=p._data.frameIndices;v[v.length+1]=41+i end
 elseif op=='indicesLength' then p._data.frameIndices.length=num(a)
 elseif op=='newTimeline' then objects[a]=B.borrowObject(classes.T);objects[a].frameIndicesOffset=77
 elseif op=='failCallback' then callbackFail=num(a)
 elseif op=='returnAnimation' then p._animation:returnToPool()
 elseif op=='actionCopy' then raws.copy=V.array();for i=0,1 do local f=P.ActionFrame.new();f.frameStart=i*2;f.actions[1]=i;raws.copy[i+1]=f end;if num(a)~=0 then p._actionFrames[2].frameStart=5 end
 elseif op=='dispatch' then p[a=='bone' and '_parseBoneTimeline' or '_parseSlotTimeline'](p,raws[b])
 elseif op=='timeline' then
  local label,raw,frames,key,kind,mode,values,parser,provided=r[2],r[3],r[4],r[5],r[6],r[7],r[8],r[9],r[10]
  local original=p[parser];local cb=function(self,raw,start,count)callbackTrace[#callbackTrace+1]=parser..':'..scalar(start)..':'..scalar(count);local result=original(self,raw,start,count);if callbackFail>0 then callbackFail=callbackFail-1;if callbackFail==0 then error('callback failure') end end;return result end
  local rawFrames=frames=='actions' and p._actionFrames or decode(frames)
  objects[label]=p:_parseTimeline(decode(raw),rawFrames,key,num(kind),num(mode),num(values),cb,objects[provided]);nilLabels[label]=true;return ref(objects[label])
 elseif op=='deformContext' then p._mesh=objects[a];p._geometry=p._mesh.geometry;p._animation=B.borrowObject(classes.N);p._timeline=B.borrowObject(classes.T);p._animation.frameFloatOffset=5;p._animation.frameIntOffset=7;p._timeline.offset=3
 elseif op=='deform' then return scalar(p[a=='slot' and '_parseSlotDeformFrame' or '_parseDeformFrame'](p,decode(b),num(c),num(e)))
 elseif op=='poseCache' then local key=p._mesh.parent.name..'_'..p._slot.name..'_'..p._mesh.name;p[a=='slot' and '_weightSlotPose' or '_weightBonePoses'][key]=decode(b)
 elseif op=='weightCount' then p._mesh.geometry.weight.count=num(a)
 elseif op=='animationOffsets' then p._animation.frameFloatOffset=num(a);p._animation.frameIntOffset=num(b)
 elseif op=='timelineOffset' then p._timeline.offset=num(a)
 elseif op=='returnDeformContext' then p._animation:returnToPool();p._timeline:returnToPool()
 elseif op=='clearDeformContext' then if a=='parent' then p._mesh.parent=nil else p['_'..a]=nil end
 elseif op=='special' then return scalar(p['_parse'..a..'Frame'](p,decode(b),num(c),num(e)))
 elseif op=='previous' then p._prevClockwise=decode(a);p._prevRotation=decode(b)
 elseif op=='frameContext' then p._bone=objects[a];p._slot=objects[b]
 elseif op=='helpLength' then p._helpArray.length=num(a)
 elseif op=='sample' then return scalar(p:_samplingEasingCurve(decode(a),p._helpArray))
 elseif op=='point' then local x=raws[a];p:_getCurvePoint(x[1],x[2],x[3],x[4],x[5],x[6],x[7],x[8],x[9],p._helpPoint)
 elseif op=='config' then p._frameValueType=num(a);p._frameDefaultValue=decode(b);p._frameValueScale=decode(c)
 elseif op=='frame' then local method=({base='_parseFrame',tween='_parseTweenFrame',single='_parseSingleValueFrame',double='_parseDoubleValueFrame'})[a];return scalar(p[method](p,decode(b),num(c),num(e)))
 elseif op=='modify' then p:_modifyArray()
 elseif op=='actionsIn' then p:_parseActionDataInFrame(decode(a),num(b),objects[c],objects[e])
 elseif op=='merge' then p:_mergeActionFrame(decode(a),num(b),num(c),nil,nil)
 elseif op=='serializeActions' then for i=1,p._actionFrames.length do local f=p._actionFrames[i];p:_parseActionFrame(f,f.frameStart,0) end
 elseif op=='manualActions' then local f=P.ActionFrame.new();for i=1,raws[a].length do f.actions[i]=raws[a][i] or V.UNDEFINED end;return scalar(p:_parseActionFrame(f,num(b),123))
 elseif op=='failAddAction' then failAddAction=num(a);local original=p._armature.addAction;p._armature.addAction=function(self,...)failAddAction=failAddAction-1;if failAddAction==0 then error('add action failure') end;return original(self,...) end
 elseif op=='allowAddAction' then failAddAction=0
 elseif op=='object' then raws[a]={} elseif op=='array' then raws[a]=V.array() elseif op=='put' then raws[a][b]=decode(c) elseif op=='append' then local x=raws[a];x[x.length+1]=decode(b)
 elseif op=='bone' or op=='rawBone' then local o=op=='rawBone' and register(classes.B.new()) or B.borrowObject(classes.B);o.name=b;if op=='bone' then o.parent=objects[c] end;objects[a]=o
 elseif op=='set' then objects[a][b]=decode(c)
 elseif op=='putIndex' then raws[a][num(b)+1]=decode(c)
 elseif op=='rawBoneAdd' then p._rawBones[p._rawBones.length+1]=objects[a]
 elseif op=='context' then p._slot=objects[a];p._skin=objects[b]
 elseif op=='geo' then p:_parseGeometry(raws[b],objects[a].geometry)
 elseif op=='mesh' then p:_parseMesh(raws[b],objects[a])
 elseif op=='parseBone' or op=='parseDisplay' or op=='parseSkin' then
  local method=op=='parseBone' and '_parseBone' or op=='parseDisplay' and '_parseDisplay' or '_parseSkin'
  objects[a]=p[method](p,raws[b]);nilLabels[a]=true;return ref(objects[a])
 elseif op=='workPut' then p[a][num(b)+1]=decode(c)
 elseif op=='workLength' then p[a].length=num(b)
 elseif op=='workExtra' then p[a].extra=decode(b)
 elseif op=='resetArrays' then p:_parseArray(nil)
 elseif op=='bind' then p._data.intArray=p._intArray;p._data.floatArray=p._floatArray
 elseif op=='counts' then return scalar(objects[a].geometry.vertexCount)..'|'..scalar(objects[a].geometry.triangleCount)
 elseif op=='linkGlobal' then p._data:addArmature(p._armature)
 elseif op=='returnGlobal' then p._data:returnToPool()
 elseif op=='returnArm' then p._armature:returnToPool()
 elseif op=='failReturn' then failReturn=a
 elseif op=='parent' then objects[a].parent=objects[b]
 elseif op=='addBone' then p._armature:addBone(objects[a]) elseif op=='addSlot' then p._armature:addSlot(objects[a]) elseif op=='addSkin' then p._armature:addSkin(objects[a])
 elseif op=='skin' then local o=B.borrowObject(classes.K);o.name=b;objects[a]=o
 elseif op=='display' then local o=B.borrowObject(classes[b]);o.name=c;objects[a]=o
 elseif op=='addDisplay' then objects[a]:addDisplay(b,objects[c])
 elseif op=='slot' then objects[a]=p:_parseSlot(raws[b],num(c));return ref(objects[a])
 elseif op=='ik' or op=='path' or op=='box' then local method=op=='ik' and '_parseIKConstraint' or op=='path' and '_parsePathConstraint' or '_parseBoundingBox';objects[a]=p[method](p,raws[b]);nilLabels[a]=true;return ref(objects[a])
 elseif op=='actions' then lists[a]=p:_parseActionData(decode(b),num(c),objects[e],objects[f]);return 'list:'..id(lists[a])
 elseif op=='payloadRead' then local u=lists[a][num(b)+1].data;return table.concat({scalar(u:getInt(num(c))),scalar(u:getFloat(num(c))),scalar(u:getString(num(c)))},'|')
 elseif op=='returnActions' then local x=lists[a];local i=1;while i<=x.length do x[i]:returnToPool();i=i+1 end
 elseif op=='return' then if objects[a]~=nil then objects[a]:returnToPool() end
 elseif op=='transform' then p:_parseTransform(raws[a],p._helpTransform,decode(b))
 elseif op=='transformSet' then p._helpTransform[a]=decode(b)
 elseif op=='color' then p:_parseColorTransform(raws[a],p._helpColorTransform)
 elseif op=='pivot' then p:_parsePivot(raws[b],objects[a])
 elseif op=='setArm' then p._armature[a]=decode(b)
 elseif op=='newArm' then p._armature=register(classes.A.new())
 elseif op=='clearArm' then p._armature:_onClear()
 else error(op) end
 return 'void'
end
local function array(a,mode)
 local ident=id(a);local entries={};for k,v in pairs(a) do if not rawequal(v,V.UNDEFINED) then entries[#entries+1]={key=type(k)=='number' and integer(k-1) or k,value=v} end end;table.sort(entries,function(a,b)return a.key<b.key end);local out={}
 for _,e in ipairs(entries) do out[#out+1]=e.key..'='..(mode=='value' and scalar(e.value) or ref(e.value)) end
 return ident..':'..integer(a.length)..':'..table.concat(out,',')
end
local function primitive(o,ks)local ident=id(o);local out={};for _,k in ipairs(ks) do out[#out+1]=scalar(o[k]) end;return ident..':'..table.concat(out,',') end
local transformKeys={'x','y','rotation','skew','scaleX','scaleY'};local colorKeys={'alphaMultiplier','redMultiplier','greenMultiplier','blueMultiplier','alphaOffset','redOffset','greenOffset','blueOffset'}
local function geometry(g)return id(g)..':'..table.concat({scalar(g.isShared),scalar(g.inheritDeform),scalar(g.offset),ref(g.data),ref(g.weight)},',') end
local function describe(o)
 local kind;for k,C in pairs(classes) do if rawequal(o.constructor,C) then kind=k;break end end;local out={kind,ref(o),o._isInPool and '1' or '0'}
 if kind=='A' then out[#out+1]=scalar(o.scale);out[#out+1]=ref(o.defaultSkin);for _,k in ipairs({'bones','slots','skins'}) do local ident=id(o[k]);local values={};for _,n in ipairs(keys(o[k])) do values[#values+1]=n..'='..ref(o[k][n]) end;out[#out+1]=ident..':'..table.concat(values,',') end end
 if kind=='Z' then
  out[#out+1]=scalar(o.name);local ident=id(o.armatures);local values={};for _,k in ipairs(keys(o.armatures)) do values[#values+1]=k..'='..ref(o.armatures[k]) end;out[#out+1]=ident..':'..table.concat(values,',')
 end
 if kind=='F' then
  out[#out+1]=scalar(o.type);out[#out+1]=scalar(o.name);out[#out+1]=ref(o.parent);out[#out+1]=scalar(o.alpha);out[#out+1]=scalar(o.segmentX);out[#out+1]=scalar(o.segmentY);out[#out+1]=primitive(o.transform,transformKeys);out[#out+1]=geometry(o.geometry)
 end
 if kind=='B' then
  out[#out+1]=scalar(o.type);out[#out+1]=scalar(o.name);out[#out+1]=ref(o.parent);out[#out+1]=scalar(o.length);out[#out+1]=scalar(o.alpha)
  for _,k in ipairs({'inheritTranslation','inheritRotation','inheritScale','inheritReflection'}) do out[#out+1]=scalar(o[k]) end;out[#out+1]=primitive(o.transform,transformKeys)
 end
 if kind=='S' then for _,k in ipairs({'name','displayIndex','zOrder','zIndex','alpha','blendMode'}) do out[#out+1]=scalar(o[k]) end;out[#out+1]=ref(o.parent);out[#out+1]=o.color==nil and 'nil' or primitive(o.color,colorKeys) end
 if kind=='K' then out[#out+1]=scalar(o.name);out[#out+1]=ref(o.parent);local ident=id(o.displays);local values={};for _,k in ipairs(keys(o.displays)) do values[#values+1]=k..'='..array(o.displays[k]) end;out[#out+1]=ident..':'..table.concat(values,',') end
 if kind=='I' or kind=='P' or kind=='Y' or kind=='M' or kind=='H' or kind=='J' then
  out[#out+1]=scalar(o.type);out[#out+1]=scalar(o.name);out[#out+1]=scalar(o.path);out[#out+1]=ref(o.parent);out[#out+1]=primitive(o.transform,transformKeys)
  if kind=='I' then out[#out+1]=primitive(o.pivot,{'x','y'}) end
  if kind=='P' or kind=='Y' or kind=='M' then out[#out+1]=geometry(o.geometry) end
  if kind=='P' or kind=='Y' then out[#out+1]=scalar(o.closed);out[#out+1]=scalar(o.constantSpeed);out[#out+1]=array(o.curveLengths,'value') end
  if kind=='H' then out[#out+1]=scalar(o.inheritAnimation);out[#out+1]=array(o.actions) end
  if kind=='J' then out[#out+1]=ref(o.boundingBox) end
 end
 if kind=='R' or kind=='E' or kind=='V' then for _,k in ipairs({'type','color','width','height'}) do out[#out+1]=scalar(o[k]) end;if kind=='V' then out[#out+1]=scalar(o.x);out[#out+1]=scalar(o.y);out[#out+1]=array(o.vertices,'value') end end
 if kind=='C' or kind=='D' then for _,k in ipairs({'type','name','order'}) do out[#out+1]=scalar(o[k]) end;out[#out+1]=ref(o.root);out[#out+1]=ref(o.target);out[#out+1]=ref(o.bone)
  if kind=='C' then out[#out+1]=scalar(o.scaleEnabled);out[#out+1]=scalar(o.bendPositive);out[#out+1]=scalar(o.weight)
  else out[#out+1]=ref(o.pathSlot);out[#out+1]=ref(o.pathDisplayData);out[#out+1]=array(o.bones);for _,k in ipairs({'positionMode','spacingMode','rotateMode','position','spacing','rotateOffset','rotateMix','translateMix'}) do out[#out+1]=scalar(o[k]) end end
 end
 if kind=='W' then out[#out+1]=scalar(o.count);out[#out+1]=scalar(o.offset);out[#out+1]=array(o.bones) end
 if kind=='Q' then out[#out+1]=scalar(o.type);out[#out+1]=scalar(o.name);out[#out+1]=ref(o.bone);out[#out+1]=ref(o.slot);out[#out+1]=ref(o.data) end
 if kind=='U' then for _,k in ipairs({'ints','floats','strings'}) do out[#out+1]=array(o[k],'value') end end
 return table.concat(out,':')
end
local function snapshot()
 local out={scalar(B._hashCode)};local parts={};for _,o in ipairs(allocated) do parts[#parts+1]=describe(o) end;out[#out+1]=table.concat(parts,'|');parts={}
 local labels={};for k in pairs(objects) do labels[k]=true end;for k in pairs(nilLabels) do labels[k]=true end
 for _,k in ipairs(keys(labels)) do parts[#parts+1]=k..'='..ref(objects[k]) end
 out[#out+1]=table.concat(parts,'|');parts={};for _,k in ipairs(keys(lists)) do parts[#parts+1]=k..'='..array(lists[k]) end;out[#out+1]=table.concat(parts,'|')
 out[#out+1]=primitive(p._helpTransform,transformKeys);out[#out+1]=primitive(p._helpColorTransform,colorKeys);parts={}
 for _,k in ipairs(keys(p._slotChildActions)) do parts[#parts+1]=k..'='..array(p._slotChildActions[k]) end;out[#out+1]=table.concat(parts,'|');parts={}
 for _,k in ipairs(keys(B._poolsMap)) do local pool={};for i,v in ipairs(B._poolsMap[k]) do pool[i]=ref(v) end;parts[#parts+1]=k..'='..table.concat(pool,',') end;out[#out+1]=table.concat(parts,'|');local ws={};for i,w in ipairs(warnings) do ws[i]=w:gsub('.',function(c)return string.format('%02x',c:byte()) end) end;out[#out+1]=table.concat(ws,'|')
 parts={};for _,k in ipairs({'_intArray','_floatArray','_frameIntArray','_frameFloatArray','_frameArray','_timelineArray','_colorArray'}) do parts[#parts+1]=k..'='..array(p[k],'value') end;out[#out+1]=table.concat(parts,'|')
 local rawBonesText=array(p._rawBones);local cachedMeshesText=array(p._cacheMeshes);local rawId=id(p._cacheRawMeshes);local rawItems={};for i=1,p._cacheRawMeshes.length do rawItems[i]=id(p._cacheRawMeshes[i]) end
 parts={ref(p._armature),ref(p._data),ref(p._skin),ref(p._slot),rawBonesText,cachedMeshesText,rawId..':'..integer(p._cacheRawMeshes.length)..':'..table.concat(rawItems,',')}
 for _,k in ipairs({'_weightSlotPose','_weightBonePoses'}) do local ident=id(p[k]);local values={};for _,n in ipairs(keys(p[k])) do local v=p[k][n];values[#values+1]=n..'='..((v==nil or rawequal(v,V.NULL) or rawequal(v,V.UNDEFINED)) and 'nil' or id(v)) end;parts[#parts+1]=ident..':'..table.concat(values,',') end;out[#out+1]=table.concat(parts,'|')
 out[#out+1]=primitive(p._helpMatrixA,{'a','b','c','d','tx','ty'})..'|'..primitive(p._helpMatrixB,{'a','b','c','d','tx','ty'})..'|'..primitive(p._helpPoint,{'x','y'})
 return out
end
-- Canonicalize only NaN float cells in a detached observation snapshot.
local function observedBytes()
 local bytes=p._data.binary:bytes()
 for _,name in ipairs({'floatArray','frameFloatArray'}) do
  local v=p._data[name]
  for i=1,v.length do if v[i]~=v[i] then
   local offset=v.byteOffset+(i-1)*4
   bytes=bytes:sub(1,offset)..string.char(0,0,192,127)..bytes:sub(offset+5)
  end end
 end
 return (bytes:gsub('.',function(c)return string.format('%02x',c:byte()) end))
end
local function frameSnapshot()
 local out={array(p._helpArray,'value')};local config={};for _,k in ipairs({'_frameValueType','_frameDefaultValue','_frameValueScale','_prevClockwise','_prevRotation','_defaultColorOffset'}) do config[#config+1]=scalar(p[k]) end;out[#out+1]=table.concat(config,',')
 local ident=id(p._actionFrames);local frames={};for i=1,p._actionFrames.length do local f=p._actionFrames[i];frames[#frames+1]=id(f)..':'..scalar(f.frameStart)..':'..array(f.actions,'value') end;out[#out+1]=ident..':'..integer(p._actionFrames.length)..':'..table.concat(frames,'|')
 out[#out+1]=array(p._armature.actions);out[#out+1]=array(p._armature.defaultActions)
 out[#out+1]=p._data and p._data.binary and observedBytes() or 'nil'
 out[#out+1]=ref(p._bone)
 out[#out+1]=table.concat({p._geometry and geometry(p._geometry) or 'nil',ref(p._mesh),p._animation and primitive(p._animation,{'frameFloatOffset','frameIntOffset'}) or 'nil',p._timeline and primitive(p._timeline,{'offset'}) or 'nil'},'|')
 return out
end
local function timelineSnapshot()
 local out={p._data and array(p._data.frameIndices,'value') or 'nil'};local timelines={}
 for _,o in ipairs(allocated) do if rawequal(o.constructor,classes.T) then local parts={};for _,k in ipairs({'type','offset','frameIndicesOffset'}) do parts[#parts+1]=scalar(o[k]) end;timelines[#timelines+1]=ref(o)..':'..table.concat(parts,',') end end;out[#out+1]=table.concat(timelines,'|')
 out[#out+1]=p._animation and primitive(p._animation,{'frameCount','frameOffset','frameIntOffset','frameFloatOffset'}) or 'nil'
 local maps={};if p._animation then for _,k in ipairs({'boneTimelines','slotTimelines'}) do local values={};for _,n in ipairs(keys(p._animation[k])) do values[#values+1]=n..'='..array(p._animation[k][n]) end;maps[#maps+1]=table.concat(values,',') end end;out[#out+1]=p._animation and table.concat(maps,'|') or 'nil';out[#out+1]=table.concat(callbackTrace,'|');return out
end
io.stderr={write=function(_,s)warnings[#warnings+1]=s:gsub('\n$','') end}
local index=0
for line in io.lines(assert(arg[1])) do local row={};for v in (line..'\t'):gmatch('(.-)\t') do row[#row+1]=v end
 local tag='void';if row[1]=='begin' then reset() else warnings={};local ok,v=pcall(execute,row);tag=ok and v or (tostring(v):find('Invalid array length',1,true) and 'range' or 'error') end
 io.write(tostring(index),'\t',tag,'\t',table.concat(snapshot(),'\t'),'\t',table.concat(frameSnapshot(),'\t'),'\t',table.concat(timelineSnapshot(),'\t'),'\n');index=index+1
end
io.stderr=stderr
