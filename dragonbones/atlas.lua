-- DragonBones 5.x atlas indexing and attachment resolution, pure Lua.
-- Rendering is handled separately by a LÖVE adapter.
local JSON = require("dragonbones.json")
local Parser = require("dragonbones.parser")
local Matrix = require("dragonbones.matrix")
local Atlas = {}

local function finite(value)
  return type(value) == "number" and value == value and math.abs(value) < math.huge
end

function Atlas.parse(value)
  local raw = type(value) == "string" and JSON.decode(value) or value
  assert(type(raw) == "table" and type(raw.SubTexture) == "table", "invalid DragonBones atlas")
  local result = {
    width = raw.width, height = raw.height, imagePath = raw.imagePath,
    name = raw.name, regions = {}
  }
  if result.width ~= nil then assert(finite(result.width) and result.width > 0, "invalid atlas width") end
  if result.height ~= nil then assert(finite(result.height) and result.height > 0, "invalid atlas height") end
  for _,rawRegion in ipairs(raw.SubTexture) do
    assert(type(rawRegion.name) == "string" and rawRegion.name ~= "", "region requires name")
    assert(not result.regions[rawRegion.name], "duplicate atlas region: " .. rawRegion.name)
    for _,key in ipairs({"x","y","width","height"}) do
      assert(finite(rawRegion[key]) and rawRegion[key] >= 0, "invalid atlas region " .. key)
    end
    assert(rawRegion.width > 0 and rawRegion.height > 0, "empty atlas region")
    if result.width then assert(rawRegion.x + rawRegion.width <= result.width, "region outside atlas width") end
    if result.height then assert(rawRegion.y + rawRegion.height <= result.height, "region outside atlas height") end
    result.regions[rawRegion.name] = {
      name = rawRegion.name,
      x = rawRegion.x, y = rawRegion.y,
      width = rawRegion.width, height = rawRegion.height,
      rotated = rawRegion.rotated == true,
      frameX = rawRegion.frameX or 0, frameY = rawRegion.frameY or 0,
      frameWidth = rawRegion.frameWidth,
      frameHeight = rawRegion.frameHeight
    }
  end
  return result
end

function Atlas.attachments(armature, atlas, skinName)
  assert(type(armature) == "table" and type(atlas) == "table", "armature and atlas are required")
  local skins = armature.skins or {}
  local skin
  for _,candidate in ipairs(skins) do
    if candidate.name == (skinName or "default") then skin = candidate; break end
  end
  if not skin and skinName == nil then skin = skins[1] end
  assert(skin, "skin not found: " .. tostring(skinName or "default"))
  local entries = {}
  for _,entry in ipairs(skin.slot or {}) do entries[entry.name] = entry end
  local attachments, skipped = {}, {}
  for order,slot in ipairs(armature.slots) do
    local index = slot.displayIndex == nil and 0 or slot.displayIndex
    assert(type(index) == "number" and index % 1 == 0, "invalid slot displayIndex")
    local entry = entries[slot.name]
    local display = index >= 0 and entry and (entry.display or {})[index+1] or nil
    if display then
      local dtype = display.type or "image"
      if dtype == "image" or dtype == 0 then
        local name = display.path or display.name
        local region = atlas.regions[name]
        if region then
          attachments[#attachments+1] = {
            slot = slot.name, bone = slot.parent, order = order,
            name = name, region = region,
            transform = Parser.transform(display.transform),
            pivotX = display.pivot and display.pivot.x or 0.5,
            pivotY = display.pivot and display.pivot.y or 0.5
          }
        else
          skipped[#skipped+1] = {slot=slot.name,reason="missing atlas region: " .. tostring(name)}
        end
      else
        skipped[#skipped+1] = {slot=slot.name,reason="unsupported display type: " .. tostring(dtype)}
      end
    end
  end
  return attachments, skipped
end

function Atlas.commands(animation, atlas, skinName)
  local armature = animation.armature
  local attachments, warnings = Atlas.attachments(armature, atlas, skinName)
  local world = animation:world_matrices()
  local commands = {}
  for _,entry in ipairs(attachments) do
    if not world[entry.bone] then
      warnings[#warnings+1] = {slot=entry.slot, reason="missing parent bone"}
    else
      local region = entry.region
      -- Packed 90-degree regions swap width/height when laid out unrotated.
      local logicalWidth = region.rotated and region.height or region.width
      local logicalHeight = region.rotated and region.width or region.height
      local fullWidth = region.frameWidth or logicalWidth
      local fullHeight = region.frameHeight or logicalHeight
      -- DragonBones default display pivot is its center. Frames represent trimmed images.
      local pivotX = entry.pivotX * fullWidth + region.frameX
      local pivotY = entry.pivotY * fullHeight + region.frameY
      commands[#commands+1] = {
        slot = entry.slot, name = entry.name, order = entry.order,
        matrix = Matrix.multiply(world[entry.bone], Matrix.from_transform(entry.transform)),
        source = region,
        rotated = region.rotated,
        offsetX = -pivotX, offsetY = -pivotY
      }
    end
  end
  return commands, warnings
end
return Atlas
