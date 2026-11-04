-- Alpha, display, color and z-index from TimelineState.ts.
-- DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e; MIT.
local Base=require('dragonbones.animation.BaseTimelineState')
local Array=require('dragonbones.core.JSArray')
local T,TW,Single=Base.TimelineState,Base.TweenTimelineState,Base.SingleValueTimelineState
local function at(a,i) return a[i+1] end
local function set(a,i,v) a[i+1]=v end
local function klass(name,parent)
  local c={};c.__index=c;setmetatable(c,{__index=parent})
  c.toString=function() return '[class dragonBones.'..name..']' end
  c.new=function() return parent.new(c) end
  return c
end
local function zeros()
  local a=Array.new();for i=1,8 do a[i]=0.0 end;return a
end
local AlphaTimelineState=klass("AlphaTimelineState",Single)
function AlphaTimelineState:_onArriveAtFrame()
  Single._onArriveAtFrame(self)
  if self._timelineData==nil then self._result=1.0 end
end
function AlphaTimelineState:init(a,s,d)
  Single.init(self,a,s,d)
  self._valueOffset=self._animationData.frameIntOffset
  self._valueScale=0.01
  self._valueArray=self._animationData.parent.parent.frameIntArray
end
function AlphaTimelineState:blend(isDirty)
  local blend=self.target
  local target=blend.target
  local weight=blend.blendWeight
  if blend.dirty>1 then
    target._alpha=target._alpha+self._result*weight
    if target._alpha>1.0 then target._alpha=1.0 end
  else
    target._alpha=self._result*weight
  end
  if isDirty or self.dirty then
    self.dirty=false
    self._armature._alphaDirty=true
  end
end

local SlotDisplayTimelineState=klass("SlotDisplayTimelineState",T)
function SlotDisplayTimelineState:_onArriveAtFrame()
  if self.playState>=0 then
    local slot=self.target
    local index=self._timelineData~=nil
      and at(self._frameArray,self._frameOffset+1)
      or slot._slotData.displayIndex
    if slot.displayIndex~=index then slot:_setDisplayIndex(index,true) end
  end
end
function SlotDisplayTimelineState:_onUpdateFrame() end

local SlotColorTimelineState=klass("SlotColorTimelineState",TW)
function SlotColorTimelineState.new()
  local o=TW.new(SlotColorTimelineState)
  o._current=zeros()
  o._difference=zeros()
  o._result=zeros()
  return o
end
function SlotColorTimelineState:_onArriveAtFrame()
  TW._onArriveAtFrame(self)
  if self._timelineData~=nil then
    local db=self._animationData.parent.parent
    local colors=db.colorArray
    local ints=db.frameIntArray
    local valueOffset=self._animationData.frameIntOffset+
      self._frameValueOffset+self._frameIndex
    local colorOffset=at(ints,valueOffset)
    if colorOffset<0 then colorOffset=colorOffset+65536 end
    if self._isTween then
      for i=0,7 do set(self._current,i,at(colors,colorOffset+i)) end
      if self._frameIndex==self._frameCount-1 then
        colorOffset=at(ints,self._animationData.frameIntOffset+self._frameValueOffset)
      else
        colorOffset=at(ints,valueOffset+1)
      end
      if colorOffset<0 then colorOffset=colorOffset+65536 end
      for i=0,7 do
        set(self._difference,i,at(colors,colorOffset+i)-at(self._current,i))
      end
    else
      for i=0,7 do
        local value=at(colors,colorOffset+i)
        set(self._result,i,i<4 and value*0.01 or value)
      end
    end
  else
    local color=self.target.slotData.color
    self._result[1]=color.alphaMultiplier
    self._result[2]=color.redMultiplier
    self._result[3]=color.greenMultiplier
    self._result[4]=color.blueMultiplier
    self._result[5]=color.alphaOffset
    self._result[6]=color.redOffset
    self._result[7]=color.greenOffset
    self._result[8]=color.blueOffset
  end
end
function SlotColorTimelineState:_onUpdateFrame()
  TW._onUpdateFrame(self)
  if self._isTween then
    for i=0,7 do
      local result=at(self._current,i)+at(self._difference,i)*self._tweenProgress
      set(self._result,i,i<4 and result*0.01 or result)
    end
  end
end
function SlotColorTimelineState:fadeOut()
  self._isTween=false
end
local colorFields={
  "alphaMultiplier","redMultiplier","greenMultiplier","blueMultiplier",
  "alphaOffset","redOffset","greenOffset","blueOffset"
}
function SlotColorTimelineState:update(passedTime)
  TW.update(self,passedTime)
  if self._isTween or self.dirty then
    local slot=self.target
    local result=slot._colorTransform
    local different=false
    for i,field in ipairs(colorFields) do
      if result[field]~=self._result[i] then different=true;break end
    end
    if self._animationState._fadeState~=0
      or self._animationState._subFadeState~=0 then
      if different then
        local fade=self._animationState._fadeProgress^4
        for i,field in ipairs(colorFields) do
          result[field]=result[field]+(self._result[i]-result[field])*fade
        end
        slot._colorDirty=true
      end
    elseif self.dirty then
      self.dirty=false
      if different then
        for i,field in ipairs(colorFields) do result[field]=self._result[i] end
        slot._colorDirty=true
      end
    end
  end
end

local SlotZIndexTimelineState=klass("SlotZIndexTimelineState",Single)
function SlotZIndexTimelineState:_onArriveAtFrame()
  Single._onArriveAtFrame(self)
  if self._timelineData==nil then
    self._result=self.target.target.slotData.zIndex
  end
end
function SlotZIndexTimelineState:init(a,s,d)
  Single.init(self,a,s,d)
  self._valueOffset=self._animationData.frameIntOffset
  self._valueArray=self._animationData.parent.parent.frameIntArray
end
function SlotZIndexTimelineState:blend(isDirty)
  local blend=self.target
  local slot=blend.target
  local weight=blend.blendWeight
  if blend.dirty>1 then
    slot._zIndex=slot._zIndex+self._result*weight
  else
    slot._zIndex=self._result*weight
  end
  if isDirty or self.dirty then
    self.dirty=false
    self._armature._zIndexDirty=true
  end
end

return {
  AlphaTimelineState=AlphaTimelineState,
  SlotDisplayTimelineState=SlotDisplayTimelineState,
  SlotColorTimelineState=SlotColorTimelineState,
  SlotZIndexTimelineState=SlotZIndexTimelineState,
}
