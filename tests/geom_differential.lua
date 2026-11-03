-- Differential test protocol only; class behavior comes from product modules.
local fields = {
  Point = {"x", "y"},
  Rectangle = {"x", "y", "width", "height"},
  ColorTransform = {"alphaMultiplier", "redMultiplier", "greenMultiplier", "blueMultiplier",
    "alphaOffset", "redOffset", "greenOffset", "blueOffset"}
}
local classes = {}
for name in pairs(fields) do classes[name] = require("dragonbones.geom." .. name) end
local objects = {}
local unpackValues = table.unpack or unpack
local function decode(value)
  if value == "undefined" then return nil end
  if value == "NaN" then return 0/0 end
  if value == "Infinity" then return math.huge end
  if value == "-Infinity" then return -math.huge end
  -- Parse -0 as a floating value even in Lua 5.4 (integer 0 has no sign).
  if value == "-0" then return -0.0 end
  return assert(tonumber(value), "Invalid test number: " .. tostring(value))
end
local function encode(value)
  if value == nil then return "undefined" end
  if value ~= value then return "NaN" end
  if value == math.huge then return "Infinity" end
  if value == -math.huge then return "-Infinity" end
  if value == 0 and 1/value == -math.huge then return "-0" end
  return string.format("%.17g", value)
end
local caseFile = assert(arg[1], "case file required")
for line in io.lines(caseFile) do
  local row = {}
  for value in line:gmatch("[^\t]+") do row[#row+1] = value end
  local id, name, operation = row[1], row[2], row[3]
  local keys, object = assert(fields[name]), objects[id]
  local result, tag = nil, "void"
  if operation == "new" then
    local args = {}
    for i=4,#row do args[i-3] = decode(row[i]) end
    object = classes[name].new(unpackValues(args, 1, #row-3))
    objects[id], tag = object, "instance"
  elseif operation == "self" then result = object:copyFrom(object)
  elseif operation == "copy" then
    local source, before = {}, {}
    for i,key in ipairs(keys) do
      source[key] = decode(row[i+3] or "undefined")
      before[i] = encode(source[key])
    end
    result = object:copyFrom(source)
    for i,key in ipairs(keys) do assert(encode(source[key]) == before[i], "Lua mutated source") end
  elseif operation == "reset" then
    if name == "ColorTransform" then result = object:identity() else result = object:clear() end
  elseif operation == "set" then object[row[4]] = decode(row[5])
  else assert(operation == "observe", "Unknown operation") end
  assert(result == nil, "Original void method must return nil")
  local output = {id, name, operation, tag}
  for _,key in ipairs(keys) do output[#output+1] = encode(object[key]) end
  io.write(table.concat(output, "\t"), "\n")
end
