-- Execute the original ObjectDataParser curve methods against the Lua port.
-- Input comes from curves_differential.js, no expected values are copied here.
local Parser=require('dragonbones.parser.ObjectDataParser')
local V=require('dragonbones.parser.JSValue')
local ok,ffi=pcall(require,'ffi')
local function readNumber(s)
  if s=='NaN' then return 0/0 end
  if s=='Infinity' then return math.huge end
  if s=='-Infinity' then return -math.huge end
  if s=='-0' then return -0.0 end
  return assert(tonumber(s),'Invalid numeric fixture: '..tostring(s))
end
local function hex(v)
  if v~=v then return 'nan' end
  local bytes
  if string.pack then bytes=string.pack('<d',v)
  elseif ok then
    bytes=ffi.string(ffi.new('double[1]',v),8)
    if not ffi.abi('le') then bytes=bytes:reverse() end
  else error('No double precision byte encoder') end
  return (bytes:gsub('.',function(ch)return string.format('%02x',string.byte(ch)) end))
end
for line in io.lines() do
  local fields={}
  for field in (line..'\t'):gmatch('(.-)\t') do
    fields[#fields+1]=field
  end
  local parser=Parser.new()
  if fields[1]=='P' then
    assert(#fields==10)
    local n={}
    for i=2,10 do n[#n+1]=readNumber(fields[i]) end
    parser:_getCurvePoint(n[1],n[2],n[3],n[4],n[5],n[6],
                          n[7],n[8],n[9],parser._helpPoint)
    io.write('P\t',hex(parser._helpPoint.x),'\t',hex(parser._helpPoint.y),'\n')
  elseif fields[1]=='S' then
    local count=assert(tonumber(fields[2]))
    local sampleCount=assert(tonumber(fields[3]))
    assert(#fields==3+count)
    local curve=V.array()
    for i=1,count do curve[i]=readNumber(fields[3+i]) end
    local samples=require('dragonbones.core.JSArray').new()
    samples.length=sampleCount
    local omitted=parser:_samplingEasingCurve(curve,samples)
    local parts={'S',omitted and '1' or '0',hex(parser._helpPoint.x),hex(parser._helpPoint.y)}
    for i=1,sampleCount do parts[#parts+1]=hex(samples[i]) end
    io.write(table.concat(parts,'\t'),'\n')
  else
    error('Unknown fixture operation: '..tostring(fields[1]))
  end
end
