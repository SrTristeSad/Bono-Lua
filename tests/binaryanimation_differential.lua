local P=require('dragonbones.parser.BinaryDataParser')
local V=require('dragonbones.parser.JSValue')
local Shared=require('dragonbones.parser.SharedBinaryBuffer')
local B=require('dragonbones.core.BaseObject')
local A=require('dragonbones.model.AnimationData')
local D=require('dragonbones.model.DragonBonesData')
local M=require('dragonbones.model.ArmatureData')
local C=require('dragonbones.model.ConstraintData')
local Map=require('dragonbones.core.JSMap')
local double
if string.pack then double=function(n)return string.pack('<d',n)end else local ffi=require('ffi');double=function(n)return ffi.string(ffi.new('double[1]',n),8)end end
local function hex(s)return (s:gsub('.',function(c)return string.format('%02x',c:byte())end))end
local function scalar(v)
 if v==nil or rawequal(v,V.UNDEFINED) then return 'u' end
 if rawequal(v,V.NULL) then return 'null' end
 if type(v)=='number' then return v~=v and 'NaN' or 'n'..hex(double(v)) end
 return tostring(v)
end
local function array(t)local a=V.array();for i,v in ipairs(t)do a[i]=v end;return a end
local function execute(c)
 local kind,blend,count,mode=tonumber(c[1]),c[2],tonumber(c[3]),c[4]
 local p,data,arm=P.new(),B.borrowObject(D),B.borrowObject(M.ArmatureData)
 arm.frameRate=24;p._data=data;p._armature=arm;data.frameIndices.length=3;data.frameIndices[1]=99
 for _,name in ipairs({'b','2','10','a'})do
  local bone=B.borrowObject(M.BoneData);bone.name=name;arm:addBone(bone)
  local slot=B.borrowObject(M.SlotData);slot.name=name;arm:addSlot(slot)
  local con=B.borrowObject(C.IKConstraintData);con.name=name;arm:addConstraint(con)
 end
 local buf=Shared.new(string.rep('\0',80));local f=Shared.view(buf,4,24,'int16');local t=Shared.view(buf,28,52,'uint16')
 for i,v in ipairs({99,88,0,2,5})do f[i]=v end
 for i,v in ipairs({100,0,count,0,0,0,1,2})do t[3+i]=v end
 p._frameArrayBuffer=f;p._timelineArrayBuffer=t
 local raw={offset=array({8,16,2}),duration=7,blendType=blend,name='anim',timeline=array({{type=kind,offset=3,name='b',x=1.5,y=-2}})}
 if mode=='groups' or mode=='order' or mode=='unknownModel' or mode=='oddPairs' then
  for _,k in ipairs({'bone','slot','constraint'})do
   raw[k]=Map.new();for _,name in ipairs(mode=='order' and {'a','10','2','b'} or {'b'})do raw[k][name]=array({11,3,12,3})end
   if mode=='unknownModel'then raw[k].absent=V.NULL end
   if mode=='oddPairs'then raw[k].b=array({11})end
  end
  raw.action=3;raw.zOrder=3
 end
 if mode=='nullGroup'then raw.bone=V.NULL end
 if mode=='shortOffsets'then raw.offset=array({})end
 if mode=='missingOffsets'then raw.offset=nil end
 if mode=='nullOffsets'then raw.offset=V.NULL end
 if mode=='nullRaw'then raw=V.NULL end
 if mode=='missingArmature'then p._armature=nil end
 if mode=='missingData'then p._data=nil end
 if mode=='missingTimeline'then p._timelineArrayBuffer=nil end
 if mode=='missingFrame'then p._frameArrayBuffer=nil end
 if mode=='negativeOffset'then raw.timeline[1].offset=-1 end
 if mode=='nanOffset'then raw.timeline[1].offset=0/0 end
 if mode=='nullTimeline'then raw.timeline=V.NULL end
 if mode=='holeTimeline'then raw.timeline=array({V.UNDEFINED})end
 if mode=='emptyName'then raw.name='' end
 if mode=='coerce'then raw.duration='8';raw.playTimes=false;raw.fadeInTime='0.25';raw.scale=V.NULL;raw.name=123;raw.timeline[1].x='2.5'end
 if mode=='badDuration'then raw.duration=0.5 end
 if mode=='zeroRate'then arm.frameRate=0 end
 if mode=='mixed' or mode=='cleanup' then raw.timeline=array({});for _,typ in ipairs({0,1,10,11,12,13,20,21,22,23,24,30,40,41,42,50,60,999})do raw.timeline[raw.timeline.length+1]={type=typ,offset=3,name='b',x=1.5,y=-2}end end
 if mode=='partial' then raw.timeline=array({{type=11,offset=3,name='b'},V.NULL})end
 if mode=='partialGroup' then raw.bone=Map.new();raw.bone.b=array({11,3});raw.slot=Map.new();raw.slot.b=V.NULL end
 if mode=='defaultEntry' then raw.timeline=array({{}})end
 local allocated,trace={},{};local originalBorrow=B.borrowObject
 B.borrowObject=function(class)local o=originalBorrow(class);allocated[#allocated+1]=o;return o end
 local genuine=p._parseBinaryTimeline
 p._parseBinaryTimeline=function(self,typ,offset,provided)
  trace[#trace+1]=scalar(typ)..','..scalar(offset)..','..tostring(provided~=nil and provided.constructor==A.AnimationTimelineData)
  return genuine(self,typ,offset,provided)
 end
 local result;local ok=pcall(function()result=p:_parseAnimation(raw);if mode=='repeat'then result=p:_parseAnimation(raw)end end);B.borrowObject=originalBorrow
 local a=result or p._animation
 local function tl(o)if o==nil then return 'nil'end;return table.concat({scalar(o.type),scalar(o.offset),scalar(o.frameIndicesOffset),scalar(o.x),scalar(o.y),tostring(o.constructor==A.AnimationTimelineData)},',')end
 local maps='nil'
 if a then local groups={};for _,k in ipairs({'boneTimelines','slotTimelines','constraintTimelines','animationTimelines'})do local entries={};for _,name in ipairs(Map.keys(a[k]))do local timelines={};for i=1,a[k][name].length do timelines[#timelines+1]=tl(a[k][name][i])end;entries[#entries+1]=name..'='..table.concat(timelines,';')end;groups[#groups+1]=table.concat(entries,'|')end;maps=table.concat(groups,'/')end
 local before={};for _,o in ipairs(allocated)do if o.constructor==A.TimelineData or o.constructor==A.AnimationTimelineData then before[#before+1]=tl(o)end end
 if mode=='cleanup'and result then result:returnToPool()end
 local fields={};if a then for _,k in ipairs({'blendType','frameCount','playTimes','duration','fadeInTime','scale','name','frameIntOffset','frameFloatOffset','frameOffset'})do fields[#fields+1]=scalar(a[k])end end
 local indices={};for i=1,math.min(data.frameIndices.length,100)do indices[#indices+1]=data.frameIndices[i]==nil and 'hole' or scalar(data.frameIndices[i])end
 local pooled={};for _,o in ipairs(allocated)do pooled[#pooled+1]=o._isInPool and '1'or'0'end
 return table.concat({ok and'ok'or'error',a and table.concat(fields,',')or'nil',maps,tl(a and a.actionTimeline),tl(a and a.zOrderTimeline),p._animation==nil and'clear'or'retained',p._timeline==nil and'clear'or'retained',string.format('%.0f',data.frameIndices.length),table.concat(indices,','),table.concat(trace,'|'),table.concat(before,'|'),table.concat(pooled),hex(buf:bytes())},'\t')
end
for line in io.lines(assert(arg[1]))do local c={};for v in(line..'\t'):gmatch('(.-)\t')do c[#c+1]=v end;io.write(execute(c),'\n')end
