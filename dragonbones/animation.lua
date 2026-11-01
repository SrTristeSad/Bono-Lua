local Matrix=require("dragonbones.matrix")
local Animation={}
Animation.__index=Animation

local function bezier(curve,t)
  if type(curve)~="table" or #curve~=4 then return t end
  local x1,y1,x2,y2=table.unpack(curve)
  local function evaluate(a,b,u)
    local v=1-u
    return 3*v*v*u*a+3*v*u*u*b+u*u*u
  end
  local lo,hi=0,1
  for _=1,20 do
    local m=(lo+hi)/2
    if evaluate(x1,x2,m)<t then lo=m else hi=m end
  end
  return evaluate(y1,y2,(lo+hi)/2)
end

local function eased(frame,t)
  if frame.curve then return bezier(frame.curve,t) end
  local e=frame.tweenEasing
  if e==nil or e==-2 then return 0 end
  if e==0 then return t end
  if e<0 then return t+(t*t-t)*(-e) end
  if e<=1 then return t+(t*(2-t)-t)*e end
  return t+( (t<.5 and 2*t*t or 1-2*(1-t)^2)-t )*math.min(1,e-1)
end

local function sample(frames,frame,prop)
  if not frames or #frames==0 then return 0 end
  local selected=frames[1]
  for i=1,#frames do
    if frames[i].start<=frame then selected=frames[i] else break end
  end
  local nextFrame=frames[selected.index+1]
  local a=selected[prop] or 0
  if not nextFrame or selected.duration<=0 then return a end
  local t=math.max(0,math.min(1,(frame-selected.start)/selected.duration))
  local progress=eased(selected,t)
  local b=nextFrame[prop] or 0
  if prop=="rotate" then
    -- Match DragonBones' default shortest-rotation interpolation.
    local delta=(b-a+180)%360-180
    return a+delta*progress
  end
  return a+(b-a)*progress
end

function Animation.new(project,armatureName)
  local arm=assert(project.armatures[armatureName],"unknown armature")
  return setmetatable({armature=arm,clip=nil,time=0,playing=false,speed=1},Animation)
end
function Animation:play(name)
  self.clip=assert(self.armature.animations[name],"unknown animation")
  self.time=0
  self.playing=true
end
function Animation:pause() self.playing=false end
function Animation:resume() if self.clip then self.playing=true end end
function Animation:advance(dt)
  assert(type(dt)=="number" and dt>=0,"dt must be nonnegative")
  if not self.playing or not self.clip then return end
  self.time=self.time+dt*self.speed
  local duration=self.clip.duration/self.armature.frameRate
  if self.clip.playTimes>0 and self.time>=duration*self.clip.playTimes then
    self.time=duration-1e-9;self.playing=false
  else
    self.time=self.time%duration
  end
end

-- Slot visibility and replacement are discrete DragonBones display timelines.
-- They are evaluated at the same frame as bone animations.
function Animation:display_index(slotName)
  local slot = assert(self.armature.slotByName[slotName], "unknown slot: "..tostring(slotName))
  local index = slot.displayIndex == nil and 0 or slot.displayIndex
  if not self.clip then return index end
  local track = self.clip.slots[slotName]
  if not track or not track.display then return index end
  local at = self.time * self.armature.frameRate
  for _,key in ipairs(track.display) do
    if key.start > at then break end
    if key.start < self.clip.duration then index = key.displayIndex end
  end
  return index
end

function Animation:pose(name)
  local bone=assert(self.armature.bones[name],"unknown bone")
  local rest=bone.rest
  local result={x=rest.x,y=rest.y,rotation=rest.rotation,skew=rest.skew,
    scaleX=rest.scaleX,scaleY=rest.scaleY}
  if self.clip then
    local track=self.clip.bones[name]
    if track then
      local frame=self.time*self.armature.frameRate
      result.x=result.x+sample(track.translate,frame,"x")
      result.y=result.y+sample(track.translate,frame,"y")
      result.rotation=result.rotation+math.rad(sample(track.rotate,frame,"rotate"))
      result.skew=result.skew+math.rad(sample(track.rotate,frame,"skew"))
      if track.scale then
        result.scaleX=result.scaleX*sample(track.scale,frame,"x")
        result.scaleY=result.scaleY*sample(track.scale,frame,"y")
      end
    end
  end
  return result
end
function Animation:world_matrices()
  local result={}
  for _,bone in ipairs(self.armature.ordered) do
    local localMatrix=Matrix.from_transform(self:pose(bone.name))
    result[bone.name]=bone.parent
      and Matrix.multiply(result[bone.parent],localMatrix) or localMatrix
  end
  return result
end
Animation.bezier=bezier
Animation.eased=eased
return Animation
