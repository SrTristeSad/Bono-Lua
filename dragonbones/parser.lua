local JSON=require("dragonbones.json")
local Parser={}

local function transform(raw)
  raw=raw or {}
  local rot=raw.rotate or raw.skY or 0
  local skew=raw.skX and (raw.skX-rot) or 0
  return {
    x=raw.x or 0,y=raw.y or 0,
    rotation=math.rad(rot),skew=math.rad(skew),
    scaleX=raw.scX or 1,scaleY=raw.scY or 1
  }
end

local function timeline(raw, defaultValue)
  if type(raw)~="table" then return nil end
  local frames,at={},0
  for index,frame in ipairs(raw) do
    local duration=frame.duration
    if duration==nil then duration=1 end
    assert(type(duration)=="number" and duration>=0 and duration%1==0,"invalid keyframe duration")
    frames[#frames+1]={
      index=index,start=at,duration=duration,
      x=frame.x == nil and (defaultValue or 0) or frame.x,
      y=frame.y == nil and (defaultValue or 0) or frame.y,
      rotate=frame.rotate or 0,
      skew=frame.skew or 0,
      tweenEasing=frame.tweenEasing,
      curve=frame.curve
    }
    at=at+duration
  end
  return frames
end

-- DragonBones 5.x slot timelines are stepped, never interpolated.
-- Accept displayFrame (modern JSON) or frame (legacy JSON).
local function slot_display_timeline(raw)
  if type(raw) ~= "table" then return nil end
  local frames, at = {}, 0
  for index, frame in ipairs(raw) do
    assert(type(frame) == "table", "invalid display keyframe")
    local duration = frame.duration == nil and 1 or frame.duration
    assert(type(duration) == "number" and duration % 1 == 0 and duration >= 0,
      "invalid display keyframe duration")
    local value = frame.value
    if value == nil then value = frame.displayIndex end
    if value == nil then value = 0 end
    assert(type(value) == "number" and value % 1 == 0 and value >= -1,
      "invalid slot display index")
    frames[#frames+1] = {index=index, start=at, duration=duration, displayIndex=value}
    at=at+duration
  end
  return #frames>0 and frames or nil
end

function Parser.parse(input)
  local data=type(input)=="string" and JSON.decode(input) or input
  assert(type(data)=="table" and type(data.armature)=="table","invalid DragonBones JSON")
  local project={version=data.version,name=data.name or "unnamed",armatures={},raw=data}
  for _,rawArm in ipairs(data.armature) do
    assert(type(rawArm.name)=="string" and rawArm.name~="","armature requires name")
    assert(not project.armatures[rawArm.name],"duplicate armature")
    local arm={name=rawArm.name,frameRate=rawArm.frameRate or data.frameRate or 24,
      bones={},ordered={},slots=rawArm.slot or {},slotByName={},skins=rawArm.skin or {},
      animations={},raw=rawArm}
    assert(arm.frameRate>0,"invalid frame rate")
    for _,rawBone in ipairs(rawArm.bone or {}) do
      assert(type(rawBone.name)=="string" and not arm.bones[rawBone.name],"duplicate or invalid bone")
      arm.bones[rawBone.name]={name=rawBone.name,parent=rawBone.parent,
        length=rawBone.length or 0,rest=transform(rawBone.transform),raw=rawBone}
    end
    for _,slot in ipairs(arm.slots) do
      assert(type(slot.name)=="string" and not arm.slotByName[slot.name],"invalid or duplicate slot")
      arm.slotByName[slot.name]=slot
    end
    local status={}
    local function visit(name)
      if status[name]==2 then return end
      assert(status[name]~=1,"cyclic bone hierarchy")
      local bone=assert(arm.bones[name],"missing parent bone: "..name)
      status[name]=1
      if bone.parent then visit(bone.parent) end
      status[name]=2
      arm.ordered[#arm.ordered+1]=bone
    end
    for _,rawBone in ipairs(rawArm.bone or {}) do visit(rawBone.name) end
    for _,rawClip in ipairs(rawArm.animation or {}) do
      local clip={name=rawClip.name,duration=rawClip.duration or 1,
        playTimes=rawClip.playTimes or 0,bones={},slots={},raw=rawClip}
      assert(type(clip.name)=="string" and clip.duration>0,"invalid animation")
      for _,b in ipairs(rawClip.bone or {}) do
        clip.bones[b.name]={translate=timeline(b.translateFrame),
          rotate=timeline(b.rotateFrame),scale=timeline(b.scaleFrame, 1)}
      end
      for _,rawSlot in ipairs(rawClip.slot or {}) do
        if arm.slotByName[rawSlot.name] then
          local source=rawSlot.displayFrame or rawSlot.frame
          local display=slot_display_timeline(source)
          if display then clip.slots[rawSlot.name]={display=display} end
        end
      end
      arm.animations[clip.name]=clip
    end
    project.armatures[arm.name]=arm
  end
  return project
end

Parser.transform=transform
return Parser
