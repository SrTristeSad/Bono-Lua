-- Direct port of DragonBones/src/dragonBones/parser/DataParser.ts
-- DragonBonesJS commit 64b6c69ae35777c2404be68c9192e2c56906079e
-- Copyright (c) 2012-2025 DragonBones team and other contributors.
-- MIT license: see LICENSE-DRAGONBONES.
-- This file is the original abstract parser's constants and static conversion
-- methods; parseDragonBonesData and parseTextureAtlasData are abstract TS
-- signatures (without bodies) and belong to the future concrete subclasses.
local Core = require("dragonbones.original.core.DragonBones")
local DataParser = {}
DataParser.__index = DataParser

-- Preserve names and case exactly, including DRADON_BONES (source spelling).
DataParser.DATA_VERSION_2_3 = "2.3"
DataParser.DATA_VERSION_3_0 = "3.0"
DataParser.DATA_VERSION_4_0 = "4.0"
DataParser.DATA_VERSION_4_5 = "4.5"
DataParser.DATA_VERSION_5_0 = "5.0"
DataParser.DATA_VERSION_5_5 = "5.5"
DataParser.DATA_VERSION_5_6 = "5.6"
DataParser.DATA_VERSION = DataParser.DATA_VERSION_5_6
DataParser.TEXTURE_ATLAS = "textureAtlas"
DataParser.SUB_TEXTURE = "SubTexture"
DataParser.FORMAT = "format"
DataParser.IMAGE_PATH = "imagePath"
DataParser.WIDTH = "width"
DataParser.HEIGHT = "height"
DataParser.ROTATED = "rotated"
DataParser.FRAME_X = "frameX"
DataParser.FRAME_Y = "frameY"
DataParser.FRAME_WIDTH = "frameWidth"
DataParser.FRAME_HEIGHT = "frameHeight"
DataParser.DRADON_BONES = "dragonBones"
DataParser.USER_DATA = "userData"
DataParser.ARMATURE = "armature"
DataParser.CANVAS = "canvas"
DataParser.BONE = "bone"
DataParser.SURFACE = "surface"
DataParser.SLOT = "slot"
DataParser.CONSTRAINT = "constraint"
DataParser.SKIN = "skin"
DataParser.DISPLAY = "display"
DataParser.FRAME = "frame"
DataParser.IK = "ik"
DataParser.PATH_CONSTRAINT = "path"
DataParser.ANIMATION = "animation"
DataParser.TIMELINE = "timeline"
DataParser.FFD = "ffd"
DataParser.TRANSLATE_FRAME = "translateFrame"
DataParser.ROTATE_FRAME = "rotateFrame"
DataParser.SCALE_FRAME = "scaleFrame"
DataParser.DISPLAY_FRAME = "displayFrame"
DataParser.COLOR_FRAME = "colorFrame"
DataParser.DEFAULT_ACTIONS = "defaultActions"
DataParser.ACTIONS = "actions"
DataParser.EVENTS = "events"
DataParser.INTS = "ints"
DataParser.FLOATS = "floats"
DataParser.STRINGS = "strings"
DataParser.TRANSFORM = "transform"
DataParser.PIVOT = "pivot"
DataParser.AABB = "aabb"
DataParser.COLOR = "color"
DataParser.VERSION = "version"
DataParser.COMPATIBLE_VERSION = "compatibleVersion"
DataParser.FRAME_RATE = "frameRate"
DataParser.TYPE = "type"
DataParser.SUB_TYPE = "subType"
DataParser.NAME = "name"
DataParser.PARENT = "parent"
DataParser.TARGET = "target"
DataParser.STAGE = "stage"
DataParser.SHARE = "share"
DataParser.PATH = "path"
DataParser.LENGTH = "length"
DataParser.DISPLAY_INDEX = "displayIndex"
DataParser.Z_ORDER = "zOrder"
DataParser.Z_INDEX = "zIndex"
DataParser.BLEND_MODE = "blendMode"
DataParser.INHERIT_TRANSLATION = "inheritTranslation"
DataParser.INHERIT_ROTATION = "inheritRotation"
DataParser.INHERIT_SCALE = "inheritScale"
DataParser.INHERIT_REFLECTION = "inheritReflection"
DataParser.INHERIT_ANIMATION = "inheritAnimation"
DataParser.INHERIT_DEFORM = "inheritDeform"
DataParser.SEGMENT_X = "segmentX"
DataParser.SEGMENT_Y = "segmentY"
DataParser.BEND_POSITIVE = "bendPositive"
DataParser.CHAIN = "chain"
DataParser.WEIGHT = "weight"
DataParser.BLEND_TYPE = "blendType"
DataParser.FADE_IN_TIME = "fadeInTime"
DataParser.PLAY_TIMES = "playTimes"
DataParser.SCALE = "scale"
DataParser.OFFSET = "offset"
DataParser.POSITION = "position"
DataParser.DURATION = "duration"
DataParser.TWEEN_EASING = "tweenEasing"
DataParser.TWEEN_ROTATE = "tweenRotate"
DataParser.TWEEN_SCALE = "tweenScale"
DataParser.CLOCK_WISE = "clockwise"
DataParser.CURVE = "curve"
DataParser.SOUND = "sound"
DataParser.EVENT = "event"
DataParser.ACTION = "action"
DataParser.X = "x"
DataParser.Y = "y"
DataParser.SKEW_X = "skX"
DataParser.SKEW_Y = "skY"
DataParser.SCALE_X = "scX"
DataParser.SCALE_Y = "scY"
DataParser.VALUE = "value"
DataParser.ROTATE = "rotate"
DataParser.SKEW = "skew"
DataParser.ALPHA = "alpha"
DataParser.ALPHA_OFFSET = "aO"
DataParser.RED_OFFSET = "rO"
DataParser.GREEN_OFFSET = "gO"
DataParser.BLUE_OFFSET = "bO"
DataParser.ALPHA_MULTIPLIER = "aM"
DataParser.RED_MULTIPLIER = "rM"
DataParser.GREEN_MULTIPLIER = "gM"
DataParser.BLUE_MULTIPLIER = "bM"
DataParser.UVS = "uvs"
DataParser.VERTICES = "vertices"
DataParser.TRIANGLES = "triangles"
DataParser.WEIGHTS = "weights"
DataParser.SLOT_POSE = "slotPose"
DataParser.BONE_POSE = "bonePose"
DataParser.BONES = "bones"
DataParser.POSITION_MODE = "positionMode"
DataParser.SPACING_MODE = "spacingMode"
DataParser.ROTATE_MODE = "rotateMode"
DataParser.SPACING = "spacing"
DataParser.ROTATE_OFFSET = "rotateOffset"
DataParser.ROTATE_MIX = "rotateMix"
DataParser.TRANSLATE_MIX = "translateMix"
DataParser.TARGET_DISPLAY = "targetDisplay"
DataParser.CLOSED = "closed"
DataParser.CONSTANT_SPEED = "constantSpeed"
DataParser.VERTEX_COUNT = "vertexCount"
DataParser.LENGTHS = "lengths"
DataParser.GOTO_AND_PLAY = "gotoAndPlay"
DataParser.DEFAULT_NAME = "default"

-- Same ordering and values as DataParser.DATA_VERSIONS in TypeScript.
DataParser.DATA_VERSIONS = {
  DataParser.DATA_VERSION_4_0,
  DataParser.DATA_VERSION_4_5,
  DataParser.DATA_VERSION_5_0,
  DataParser.DATA_VERSION_5_5,
  DataParser.DATA_VERSION_5_6
}

-- _getArmatureType: direct mapping of the TypeScript switch and default branch.
function DataParser._getArmatureType(value)
  local key = value:lower()
  local values = {
    ["stage"] = Core.ArmatureType.Stage,
    ["armature"] = Core.ArmatureType.Armature,
    ["movieclip"] = Core.ArmatureType.MovieClip,
  }
  return values[key] or Core.ArmatureType.Armature
end

-- _getBoneType: direct mapping of the TypeScript switch and default branch.
function DataParser._getBoneType(value)
  local key = value:lower()
  local values = {
    ["bone"] = Core.BoneType.Bone,
    ["surface"] = Core.BoneType.Surface,
  }
  return values[key] or Core.BoneType.Bone
end

-- _getPositionMode: direct mapping of the TypeScript switch and default branch.
function DataParser._getPositionMode(value)
  local key = value:lower()
  local values = {
    ["percent"] = Core.PositionMode.Percent,
    ["fixed"] = Core.PositionMode.Fixed,
  }
  return values[key] or Core.PositionMode.Percent
end

-- _getSpacingMode: direct mapping of the TypeScript switch and default branch.
function DataParser._getSpacingMode(value)
  local key = value:lower()
  local values = {
    ["length"] = Core.SpacingMode.Length,
    ["percent"] = Core.SpacingMode.Percent,
    ["fixed"] = Core.SpacingMode.Fixed,
  }
  return values[key] or Core.SpacingMode.Length
end

-- _getRotateMode: direct mapping of the TypeScript switch and default branch.
function DataParser._getRotateMode(value)
  local key = value:lower()
  local values = {
    ["tangent"] = Core.RotateMode.Tangent,
    ["chain"] = Core.RotateMode.Chain,
    ["chainscale"] = Core.RotateMode.ChainScale,
  }
  return values[key] or Core.RotateMode.Tangent
end

-- _getDisplayType: direct mapping of the TypeScript switch and default branch.
function DataParser._getDisplayType(value)
  local key = value:lower()
  local values = {
    ["image"] = Core.DisplayType.Image,
    ["mesh"] = Core.DisplayType.Mesh,
    ["armature"] = Core.DisplayType.Armature,
    ["boundingbox"] = Core.DisplayType.BoundingBox,
    ["path"] = Core.DisplayType.Path,
  }
  return values[key] or Core.DisplayType.Image
end

-- _getBoundingBoxType: direct mapping of the TypeScript switch and default branch.
function DataParser._getBoundingBoxType(value)
  local key = value:lower()
  local values = {
    ["rectangle"] = Core.BoundingBoxType.Rectangle,
    ["ellipse"] = Core.BoundingBoxType.Ellipse,
    ["polygon"] = Core.BoundingBoxType.Polygon,
  }
  return values[key] or Core.BoundingBoxType.Rectangle
end

-- _getBlendMode: direct mapping of the TypeScript switch and default branch.
function DataParser._getBlendMode(value)
  local key = value:lower()
  local values = {
    ["normal"] = Core.BlendMode.Normal,
    ["add"] = Core.BlendMode.Add,
    ["alpha"] = Core.BlendMode.Alpha,
    ["darken"] = Core.BlendMode.Darken,
    ["difference"] = Core.BlendMode.Difference,
    ["erase"] = Core.BlendMode.Erase,
    ["hardlight"] = Core.BlendMode.HardLight,
    ["invert"] = Core.BlendMode.Invert,
    ["layer"] = Core.BlendMode.Layer,
    ["lighten"] = Core.BlendMode.Lighten,
    ["multiply"] = Core.BlendMode.Multiply,
    ["overlay"] = Core.BlendMode.Overlay,
    ["screen"] = Core.BlendMode.Screen,
    ["subtract"] = Core.BlendMode.Subtract,
  }
  return values[key] or Core.BlendMode.Normal
end

-- _getAnimationBlendType: direct mapping of the TypeScript switch and default branch.
function DataParser._getAnimationBlendType(value)
  local key = value:lower()
  local values = {
    ["none"] = Core.AnimationBlendType.None,
    ["1d"] = Core.AnimationBlendType.E1D,
  }
  return values[key] or Core.AnimationBlendType.None
end

-- _getActionType: direct mapping of the TypeScript switch and default branch.
function DataParser._getActionType(value)
  local key = value:lower()
  local values = {
    ["play"] = Core.ActionType.Play,
    ["frame"] = Core.ActionType.Frame,
    ["sound"] = Core.ActionType.Sound,
  }
  return values[key] or Core.ActionType.Play
end

-- TypeScript's abstract instance declarations have no method bodies.
-- Concrete parsers must implement parseDragonBonesData and
-- parseTextureAtlasData; do not add a partial or fabricated parser here.
return DataParser
