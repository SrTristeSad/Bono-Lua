-- Behavioral contract of DragonBonesJS DataParser.ts at 64b6c69ae35777c2404be68c9192e2c56906079e.
package.path = "./?.lua;./?/init.lua;" .. package.path
local P = require("dragonbones.original.parser.DataParser")
local Core = require("dragonbones.original.core.DragonBones")
local passed, failed, assertions = 0, 0, 0
local function eq(actual, expected)
  assertions = assertions + 1
  assert(actual == expected, tostring(actual) .. " ~= " .. tostring(expected))
end
local function test(name, fn)
  local ok, err = pcall(fn)
  if ok then passed = passed + 1; print("ok original.data_parser " .. name)
  else failed = failed + 1; print("not ok original.data_parser " .. name .. ": " .. tostring(err)) end
end

local expectedConstants = {
  DATA_VERSION_2_3 = "2.3",
  DATA_VERSION_3_0 = "3.0",
  DATA_VERSION_4_0 = "4.0",
  DATA_VERSION_4_5 = "4.5",
  DATA_VERSION_5_0 = "5.0",
  DATA_VERSION_5_5 = "5.5",
  DATA_VERSION_5_6 = "5.6",
  DATA_VERSION = "5.6",
  TEXTURE_ATLAS = "textureAtlas",
  SUB_TEXTURE = "SubTexture",
  FORMAT = "format",
  IMAGE_PATH = "imagePath",
  WIDTH = "width",
  HEIGHT = "height",
  ROTATED = "rotated",
  FRAME_X = "frameX",
  FRAME_Y = "frameY",
  FRAME_WIDTH = "frameWidth",
  FRAME_HEIGHT = "frameHeight",
  DRADON_BONES = "dragonBones",
  USER_DATA = "userData",
  ARMATURE = "armature",
  CANVAS = "canvas",
  BONE = "bone",
  SURFACE = "surface",
  SLOT = "slot",
  CONSTRAINT = "constraint",
  SKIN = "skin",
  DISPLAY = "display",
  FRAME = "frame",
  IK = "ik",
  PATH_CONSTRAINT = "path",
  ANIMATION = "animation",
  TIMELINE = "timeline",
  FFD = "ffd",
  TRANSLATE_FRAME = "translateFrame",
  ROTATE_FRAME = "rotateFrame",
  SCALE_FRAME = "scaleFrame",
  DISPLAY_FRAME = "displayFrame",
  COLOR_FRAME = "colorFrame",
  DEFAULT_ACTIONS = "defaultActions",
  ACTIONS = "actions",
  EVENTS = "events",
  INTS = "ints",
  FLOATS = "floats",
  STRINGS = "strings",
  TRANSFORM = "transform",
  PIVOT = "pivot",
  AABB = "aabb",
  COLOR = "color",
  VERSION = "version",
  COMPATIBLE_VERSION = "compatibleVersion",
  FRAME_RATE = "frameRate",
  TYPE = "type",
  SUB_TYPE = "subType",
  NAME = "name",
  PARENT = "parent",
  TARGET = "target",
  STAGE = "stage",
  SHARE = "share",
  PATH = "path",
  LENGTH = "length",
  DISPLAY_INDEX = "displayIndex",
  Z_ORDER = "zOrder",
  Z_INDEX = "zIndex",
  BLEND_MODE = "blendMode",
  INHERIT_TRANSLATION = "inheritTranslation",
  INHERIT_ROTATION = "inheritRotation",
  INHERIT_SCALE = "inheritScale",
  INHERIT_REFLECTION = "inheritReflection",
  INHERIT_ANIMATION = "inheritAnimation",
  INHERIT_DEFORM = "inheritDeform",
  SEGMENT_X = "segmentX",
  SEGMENT_Y = "segmentY",
  BEND_POSITIVE = "bendPositive",
  CHAIN = "chain",
  WEIGHT = "weight",
  BLEND_TYPE = "blendType",
  FADE_IN_TIME = "fadeInTime",
  PLAY_TIMES = "playTimes",
  SCALE = "scale",
  OFFSET = "offset",
  POSITION = "position",
  DURATION = "duration",
  TWEEN_EASING = "tweenEasing",
  TWEEN_ROTATE = "tweenRotate",
  TWEEN_SCALE = "tweenScale",
  CLOCK_WISE = "clockwise",
  CURVE = "curve",
  SOUND = "sound",
  EVENT = "event",
  ACTION = "action",
  X = "x",
  Y = "y",
  SKEW_X = "skX",
  SKEW_Y = "skY",
  SCALE_X = "scX",
  SCALE_Y = "scY",
  VALUE = "value",
  ROTATE = "rotate",
  SKEW = "skew",
  ALPHA = "alpha",
  ALPHA_OFFSET = "aO",
  RED_OFFSET = "rO",
  GREEN_OFFSET = "gO",
  BLUE_OFFSET = "bO",
  ALPHA_MULTIPLIER = "aM",
  RED_MULTIPLIER = "rM",
  GREEN_MULTIPLIER = "gM",
  BLUE_MULTIPLIER = "bM",
  UVS = "uvs",
  VERTICES = "vertices",
  TRIANGLES = "triangles",
  WEIGHTS = "weights",
  SLOT_POSE = "slotPose",
  BONE_POSE = "bonePose",
  BONES = "bones",
  POSITION_MODE = "positionMode",
  SPACING_MODE = "spacingMode",
  ROTATE_MODE = "rotateMode",
  SPACING = "spacing",
  ROTATE_OFFSET = "rotateOffset",
  ROTATE_MIX = "rotateMix",
  TRANSLATE_MIX = "translateMix",
  TARGET_DISPLAY = "targetDisplay",
  CLOSED = "closed",
  CONSTANT_SPEED = "constantSpeed",
  VERTEX_COUNT = "vertexCount",
  LENGTHS = "lengths",
  GOTO_AND_PLAY = "gotoAndPlay",
  DEFAULT_NAME = "default",
}
test("all 131 original string constants (including original misspelling)", function()
  local count = 0
  for name, value in pairs(expectedConstants) do
    eq(P[name], value)
    count = count + 1
  end
  eq(count, 131)
  eq(P.DRADON_BONES, "dragonBones")
end)
test("DataParser.DATA_VERSIONS order and distinct version constants", function()
  local versions = {"4.0", "4.5", "5.0", "5.5", "5.6"}
  eq(#P.DATA_VERSIONS, #versions)
  for i, version in ipairs(versions) do eq(P.DATA_VERSIONS[i], version) end
  eq(P.DATA_VERSION, "5.6")
  eq(P.DATA_VERSION_2_3, "2.3")
  eq(P.DATA_VERSION_3_0, "3.0")
end)

test("_getArmatureType all switch cases, casing, and fallback", function()
  local fn = P._getArmatureType
  local enum = Core.ArmatureType
  eq(fn("stage"), enum.Stage)
  eq(fn("STAGE"), enum.Stage)
  eq(fn("armature"), enum.Armature)
  eq(fn("ARMATURE"), enum.Armature)
  eq(fn("movieclip"), enum.MovieClip)
  eq(fn("MOVIECLIP"), enum.MovieClip)
  eq(fn(""), enum.Armature)
  eq(fn("unknown"), enum.Armature)
  eq(fn(" stage"), enum.Armature)
end)
test("_getBoneType all switch cases, casing, and fallback", function()
  local fn = P._getBoneType
  local enum = Core.BoneType
  eq(fn("bone"), enum.Bone)
  eq(fn("BONE"), enum.Bone)
  eq(fn("surface"), enum.Surface)
  eq(fn("SURFACE"), enum.Surface)
  eq(fn(""), enum.Bone)
  eq(fn("unknown"), enum.Bone)
  eq(fn(" bone"), enum.Bone)
end)
test("_getPositionMode all switch cases, casing, and fallback", function()
  local fn = P._getPositionMode
  local enum = Core.PositionMode
  eq(fn("percent"), enum.Percent)
  eq(fn("PERCENT"), enum.Percent)
  eq(fn("fixed"), enum.Fixed)
  eq(fn("FIXED"), enum.Fixed)
  eq(fn(""), enum.Percent)
  eq(fn("unknown"), enum.Percent)
  eq(fn(" percent"), enum.Percent)
end)
test("_getSpacingMode all switch cases, casing, and fallback", function()
  local fn = P._getSpacingMode
  local enum = Core.SpacingMode
  eq(fn("length"), enum.Length)
  eq(fn("LENGTH"), enum.Length)
  eq(fn("percent"), enum.Percent)
  eq(fn("PERCENT"), enum.Percent)
  eq(fn("fixed"), enum.Fixed)
  eq(fn("FIXED"), enum.Fixed)
  eq(fn(""), enum.Length)
  eq(fn("unknown"), enum.Length)
  eq(fn(" length"), enum.Length)
end)
test("_getRotateMode all switch cases, casing, and fallback", function()
  local fn = P._getRotateMode
  local enum = Core.RotateMode
  eq(fn("tangent"), enum.Tangent)
  eq(fn("TANGENT"), enum.Tangent)
  eq(fn("chain"), enum.Chain)
  eq(fn("CHAIN"), enum.Chain)
  eq(fn("chainscale"), enum.ChainScale)
  eq(fn("CHAINSCALE"), enum.ChainScale)
  eq(fn(""), enum.Tangent)
  eq(fn("unknown"), enum.Tangent)
  eq(fn(" tangent"), enum.Tangent)
end)
test("_getDisplayType all switch cases, casing, and fallback", function()
  local fn = P._getDisplayType
  local enum = Core.DisplayType
  eq(fn("image"), enum.Image)
  eq(fn("IMAGE"), enum.Image)
  eq(fn("mesh"), enum.Mesh)
  eq(fn("MESH"), enum.Mesh)
  eq(fn("armature"), enum.Armature)
  eq(fn("ARMATURE"), enum.Armature)
  eq(fn("boundingbox"), enum.BoundingBox)
  eq(fn("BOUNDINGBOX"), enum.BoundingBox)
  eq(fn("path"), enum.Path)
  eq(fn("PATH"), enum.Path)
  eq(fn(""), enum.Image)
  eq(fn("unknown"), enum.Image)
  eq(fn(" image"), enum.Image)
end)
test("_getBoundingBoxType all switch cases, casing, and fallback", function()
  local fn = P._getBoundingBoxType
  local enum = Core.BoundingBoxType
  eq(fn("rectangle"), enum.Rectangle)
  eq(fn("RECTANGLE"), enum.Rectangle)
  eq(fn("ellipse"), enum.Ellipse)
  eq(fn("ELLIPSE"), enum.Ellipse)
  eq(fn("polygon"), enum.Polygon)
  eq(fn("POLYGON"), enum.Polygon)
  eq(fn(""), enum.Rectangle)
  eq(fn("unknown"), enum.Rectangle)
  eq(fn(" rectangle"), enum.Rectangle)
end)
test("_getBlendMode all switch cases, casing, and fallback", function()
  local fn = P._getBlendMode
  local enum = Core.BlendMode
  eq(fn("normal"), enum.Normal)
  eq(fn("NORMAL"), enum.Normal)
  eq(fn("add"), enum.Add)
  eq(fn("ADD"), enum.Add)
  eq(fn("alpha"), enum.Alpha)
  eq(fn("ALPHA"), enum.Alpha)
  eq(fn("darken"), enum.Darken)
  eq(fn("DARKEN"), enum.Darken)
  eq(fn("difference"), enum.Difference)
  eq(fn("DIFFERENCE"), enum.Difference)
  eq(fn("erase"), enum.Erase)
  eq(fn("ERASE"), enum.Erase)
  eq(fn("hardlight"), enum.HardLight)
  eq(fn("HARDLIGHT"), enum.HardLight)
  eq(fn("invert"), enum.Invert)
  eq(fn("INVERT"), enum.Invert)
  eq(fn("layer"), enum.Layer)
  eq(fn("LAYER"), enum.Layer)
  eq(fn("lighten"), enum.Lighten)
  eq(fn("LIGHTEN"), enum.Lighten)
  eq(fn("multiply"), enum.Multiply)
  eq(fn("MULTIPLY"), enum.Multiply)
  eq(fn("overlay"), enum.Overlay)
  eq(fn("OVERLAY"), enum.Overlay)
  eq(fn("screen"), enum.Screen)
  eq(fn("SCREEN"), enum.Screen)
  eq(fn("subtract"), enum.Subtract)
  eq(fn("SUBTRACT"), enum.Subtract)
  eq(fn(""), enum.Normal)
  eq(fn("unknown"), enum.Normal)
  eq(fn(" normal"), enum.Normal)
end)
test("_getAnimationBlendType all switch cases, casing, and fallback", function()
  local fn = P._getAnimationBlendType
  local enum = Core.AnimationBlendType
  eq(fn("none"), enum.None)
  eq(fn("NONE"), enum.None)
  eq(fn("1d"), enum.E1D)
  eq(fn("1D"), enum.E1D)
  eq(fn(""), enum.None)
  eq(fn("unknown"), enum.None)
  eq(fn(" none"), enum.None)
end)
test("_getActionType all switch cases, casing, and fallback", function()
  local fn = P._getActionType
  local enum = Core.ActionType
  eq(fn("play"), enum.Play)
  eq(fn("PLAY"), enum.Play)
  eq(fn("frame"), enum.Frame)
  eq(fn("FRAME"), enum.Frame)
  eq(fn("sound"), enum.Sound)
  eq(fn("SOUND"), enum.Sound)
  eq(fn(""), enum.Play)
  eq(fn("unknown"), enum.Play)
  eq(fn(" play"), enum.Play)
end)
test("invalid null and non-string input are not silently coerced", function()
  for _, fn in ipairs({P._getArmatureType, P._getDisplayType, P._getBlendMode}) do
    eq(pcall(fn, nil), false)
    eq(pcall(fn, {}), false)
    eq(pcall(fn, 13), false)
  end
end)
test("abstract methods are not replaced by invented concrete parsers", function()
  eq(P.parseDragonBonesData, nil)
  eq(P.parseTextureAtlasData, nil)
end)
print(("Original DataParser.ts: %d passed, %d failed, %d assertions"):format(passed, failed, assertions))
if failed > 0 then os.exit(1) end
