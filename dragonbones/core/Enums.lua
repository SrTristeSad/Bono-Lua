-- DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e
-- Copyright (c) 2012-2025 DragonBones team and other contributors.
-- MIT license: see LICENSE-DRAGONBONES.
-- Const enums from core/DragonBones.ts, separated only to avoid require cycles.
local Enums = {}

-- TS const enum values are compile-time numbers. Lua tables preserve the
-- original names and numerical values without creating alternate semantics.
Enums.BinaryOffset = {
  WeigthBoneCount=0, WeigthFloatOffset=1, WeigthBoneIndices=2,
  GeometryVertexCount=0, GeometryTriangleCount=1, GeometryFloatOffset=2,
  GeometryWeightOffset=3, GeometryVertexIndices=4,
  TimelineScale=0, TimelineOffset=1, TimelineKeyFrameCount=2,
  TimelineFrameValueCount=3, TimelineFrameValueOffset=4, TimelineFrameOffset=5,
  FramePosition=0, FrameTweenType=1, FrameTweenEasingOrCurveSampleCount=2,
  FrameCurveSamples=3,
  DeformVertexOffset=0, DeformCount=1, DeformValueCount=2,
  DeformValueOffset=3, DeformFloatOffset=4
}
Enums.ArmatureType = { Armature=0, MovieClip=1, Stage=2 }
Enums.BoneType = { Bone=0, Surface=1 }
Enums.DisplayType = { Image=0, Armature=1, Mesh=2, BoundingBox=3, Path=4 }
Enums.BoundingBoxType = { Rectangle=0, Ellipse=1, Polygon=2 }
Enums.ActionType = { Play=0, Frame=10, Sound=11 }
Enums.BlendMode = {
  Normal=0, Add=1, Alpha=2, Darken=3, Difference=4, Erase=5,
  HardLight=6, Invert=7, Layer=8, Lighten=9, Multiply=10,
  Overlay=11, Screen=12, Subtract=13
}
Enums.TweenType = { None=0, Line=1, Curve=2, QuadIn=3, QuadOut=4, QuadInOut=5 }
Enums.TimelineType = {
  Action=0, ZOrder=1, BoneAll=10, BoneTranslate=11, BoneRotate=12, BoneScale=13,
  Surface=50, BoneAlpha=60, SlotDisplay=20, SlotColor=21,
  SlotDeform=22, SlotZIndex=23, SlotAlpha=24, IKConstraint=30,
  AnimationProgress=40, AnimationWeight=41, AnimationParameter=42
}
Enums.OffsetMode = { None=0, Additive=1, Override=2 }
Enums.AnimationFadeOutMode = {
  SameLayer=1, SameGroup=2, SameLayerAndGroup=3, All=4, Single=5
}
Enums.AnimationBlendType = { None=0, E1D=1 }
Enums.AnimationBlendMode = { Additive=0, Override=1 }
Enums.ConstraintType = { IK=0, Path=1 }
Enums.PositionMode = { Fixed=0, Percent=1 }
Enums.SpacingMode = { Length=0, Fixed=1, Percent=2 }
Enums.RotateMode = { Tangent=0, Chain=1, ChainScale=2 }

return Enums
