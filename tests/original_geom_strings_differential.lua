-- Compare geometry toString() directly against the pinned JavaScript
-- DragonBonesJS classes executed in a separate CI-only Node process.
package.path="./?.lua;./?/init.lua;"..package.path
local Matrix=require("dragonbones.original.geom.Matrix")
local Transform=require("dragonbones.original.geom.Transform")
local fixture=arg[1] or "tests/fixtures/geom_strings_cases.tsv"
local expected=arg[2] or "artifacts/upstream/geom_strings_expected.tsv"
local function tokenize(line)
  local out={}
  for item in (line.."\t"):gmatch("(.-)\t") do out[#out+1]=item end
  return out
end
local function number(raw)
  if raw=="NaN" then return 0/0 end
  if raw=="Infinity" then return math.huge end
  if raw=="-Infinity" then return -math.huge end
  return assert(tonumber(raw),"Invalid case number: "..raw)
end
local reference=assert(io.open(expected,"r"))
local checked=0
for line in io.lines(fixture) do
  if line~="" and line:sub(1,1)~="#" then
    local parts=tokenize(line)
    local typ,name,raw=parts[1],parts[2],parts[3]
    local n={}
    for part in raw:gmatch("[^,]+") do n[#n+1]=number(part) end
    assert(#n==6,"Expected six parameters in "..name)
    local cls=typ=="Matrix" and Matrix or typ=="Transform" and Transform
    assert(cls,"Unknown class "..typ)
    local actual=cls.new(n[1],n[2],n[3],n[4],n[5],n[6]):toString()
    local lineJS=assert(reference:read("*l"),"Reference output missing: "..name)
    local comparison=tokenize(lineJS)
    assert(comparison[1]==typ and comparison[2]==name,"Original reference order mismatch: "..name)
    assert(actual==comparison[3],("Original %s.toString %s mismatch:\n Lua: %s\n JS: %s")
      :format(typ,name,actual,comparison[3]))
    checked=checked+1
  end
end
assert(reference:read("*l")==nil,"Extra original JS results")
reference:close()
assert(checked==26,"Incorrect fixture count: "..checked)
print(("Original DragonBonesJS geometry toString differential: %d passed, 0 failed"):format(checked))
