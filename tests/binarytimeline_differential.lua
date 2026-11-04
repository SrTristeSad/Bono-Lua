local P = require('dragonbones.parser.BinaryDataParser')
local Shared = require('dragonbones.parser.SharedBinaryBuffer')
local B = require('dragonbones.core.BaseObject')
local M = require('dragonbones.model.AnimationData')
local D = require('dragonbones.model.DragonBonesData')
local V = require('dragonbones.parser.JSValue')
local function scalar(v)
  if v == nil then return 'undefined' end
  if type(v) == 'boolean' then return tostring(v) end
  if v ~= v then return 'NaN' end
  if type(v) == 'number' then return string.format('%.17g',v) end
  return tostring(v)
end
local function hex(s) return (s:gsub('.',function(c) return string.format('%02x',c:byte()) end)) end
local function execute(c)
  local p,data,anim = P.new(),B.borrowObject(D),B.borrowObject(M.AnimationData)
  p._data=data;p._animation=anim;anim.frameCount=tonumber(c[1]);anim.frameOffset=tonumber(c[6]) or 2
  data.frameIndices.length=tonumber(c[5]) or 3
  if data.frameIndices.length>0 then data.frameIndices[1]=99 end
  local starts={};for n in c[2]:gmatch('[^,]+') do starts[#starts+1]=tonumber(n) end
  local frames={-77,-88};for _,n in ipairs(starts) do frames[#frames+1]=n end
  local timeline={17,18,19,100,0,#starts,0,0};for i=1,#starts do timeline[#timeline+1]=i-1 end
  local buffer=Shared.new(string.rep('\0',4+#frames*2+#timeline*2))
  local f=Shared.view(buffer,4,#frames*2,'int16')
  local t=Shared.view(buffer,4+#frames*2,#timeline*2,'uint16')
  for i,n in ipairs(frames) do f[i]=n end;for i,n in ipairs(timeline) do t[i]=n end
  p._frameArrayBuffer=f;p._timelineArrayBuffer=t
  local suppliedKind=tonumber(c[3]) or 0
  local supplied=suppliedKind==1 and B.borrowObject(M.TimelineData) or suppliedKind==2 and B.borrowObject(M.AnimationTimelineData) or nil
  if supplied then supplied.frameIndicesOffset=123;if suppliedKind==2 then supplied.x=12;supplied.y=-9 end end
  local before=hex(buffer:bytes());local offset=3;local mode=c[7]
  if mode=='missingTimeline' then p._timelineArrayBuffer=nil end
  if mode=='missingFrame' then p._frameArrayBuffer=nil end
  if mode=='missingAnimation' then p._animation=nil end
  if mode=='missingData' then p._data=nil end
  if mode=='negativeTotal' then anim.frameCount=-2 end
  if mode=='zeroTotal' then anim.frameCount=-1 end
  if mode=='lengthOverflow' then data.frameIndices.length=4294967295 end
  if mode=='maxKeys' then t[3+2+1]=65535 end
  if mode=='duplicateOffsets' then for i=1,#starts do t[3+5+i]=0 end end
  if mode=='badLength' then anim.frameCount=0.5 end
  if mode=='outsideTimeline' then offset=10000 end
  if mode=='outsideFrame' then t[3+5+1]=65535 end
  if mode=='fractionOffset' then offset=0.5 end
  if mode=='nanOffset' then offset=0/0 end
  if mode=='nullArg' then supplied=V.NULL end
  if mode=='undefinedArg' then supplied=V.UNDEFINED end
  local result;local reuse=false
  local ok=pcall(function()
    result=p:_parseBinaryTimeline(tonumber(c[4]) or 11,offset,supplied)
    if mode=='append' then result=p:_parseBinaryTimeline(22,3,result) end
    if mode=='mutate' then t[3+2+1]=0;result=p:_parseBinaryTimeline(23,3,result) end
    if mode=='reuse' then result:returnToPool();local again=B.borrowObject(M.TimelineData);reuse=again==result;result=p:_parseBinaryTimeline(24,3,again) end
  end)
  local active=result or p._timeline;local values={}
  for i=1,math.min(data.frameIndices.length,100) do values[#values+1]=data.frameIndices[i]==nil and 'hole' or scalar(data.frameIndices[i]) end
  local out={ok and 'ok' or 'error',active and scalar(active.type) or 'nil',active and scalar(active.offset) or 'nil',active and scalar(active.frameIndicesOffset) or 'nil',p._timeline==nil and 'clear' or p._timeline==active and 'retained' or 'other',scalar(data.frameIndices.length),table.concat(values,','),scalar(result~=nil and result==supplied),active and scalar(active.x) or 'nil',active and scalar(active.y) or 'nil',scalar(reuse),hex(buffer:bytes()),before,scalar(p._frameArrayBuffer==f),scalar(p._timelineArrayBuffer==t)}
  return table.concat(out,'\t')
end
for line in io.lines(assert(arg[1])) do local c={};for value in (line..'\t'):gmatch('(.-)\t') do c[#c+1]=value end;io.write(execute(c),'\n') end
