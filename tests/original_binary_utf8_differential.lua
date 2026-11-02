-- Differential execution against the pinned original BinaryDataParser.ts
-- _decodeUTF8 method, not against a handwritten reference algorithm.
-- The original JS bundle runs only in the CI test harness.
package.path="./?.lua;./?/init.lua;"..package.path
local Binary=require("dragonbones.original.parser.BinaryDataParser")
local input=arg[1] or "tests/fixtures/binary_utf8_cases.tsv"
local expected=arg[2] or "artifacts/upstream/binary_utf8_expected.tsv"
local function hexBytes(hex)
  assert(#hex%2==0 and hex:match("^[0-9a-fA-F]*$"),"Malformed hex fixture")
  local result={}
  for i=1,#hex,2 do result[#result+1]=string.char(tonumber(hex:sub(i,i+1),16)) end
  return table.concat(result)
end
local function toHex(bytes)
  return (bytes:gsub(".",function(s)return ("%02x"):format(s:byte())end))
end
local parser=Binary.new()
local ref=assert(io.open(expected,"r"))
local cases=0
for line in io.lines(input) do
  if line~="" and line:sub(1,1)~="#" then
    local name,hex=line:match("^([^\t]+)\t(.*)$")
    assert(name~=nil,"Fixture must have case and hex bytes")
    local expectedLine=assert(ref:read("*l"),"Missing reference for "..name)
    local refName,refHex=expectedLine:match("^([^\t]+)\t(.*)$")
    assert(refName==name,"Mismatched upstream case: "..name)
    local bytes=hexBytes(hex)
    local result=parser:_decodeUTF8(bytes)
    assert(toHex(result)==refHex,
      ("BinaryDataParser._decodeUTF8 %s: Lua UTF8 %s != original JS UTF8 %s")
        :format(name,toHex(result),refHex))
    cases=cases+1
  end
end
assert(ref:read("*l")==nil,"Unexpected upstream reference cases")
ref:close()
assert(cases==52,"Wrong differential fixture count: "..cases)
print(("Original DragonBonesJS Binary UTF8 differential: %d passed, 0 failed"):format(cases))
