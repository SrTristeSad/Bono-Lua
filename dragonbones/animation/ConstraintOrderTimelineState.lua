-- ZOrderTimelineState and IKConstraintTimelineState, TimelineState.ts.
-- DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e; MIT.
local Base=require('dragonbones.animation.BaseTimelineState')
local T,Double=Base.TimelineState,Base.DoubleValueTimelineState
local function at(a,i) return a[i+1] end
local function klass(name,parent)
  local c={};c.__index=c;setmetatable(c,{__index=parent})
  c.toString=function()return '[class dragonBones.'..name..']'end
  c.new=function()return parent.new(c)end
  return c
end
local ZOrderTimelineState=klass("ZOrderTimelineState",T)
function ZOrderTimelineState:_onArriveAtFrame()
  if self.playState>=0 then
    local count=at(self._frameArray,self._frameOffset+1)
    if count>0 then
      -- Source hands the entire underlying frame array and a zero-based
      -- offset, not a sliced or transformed slot-index list.
      self._armature:_sortZOrder(self._frameArray,self._frameOffset+2)
    else
      self._armature:_sortZOrder(nil,0)
    end
  end
end
function ZOrderTimelineState:_onUpdateFrame() end

local IKConstraintTimelineState=klass("IKConstraintTimelineState",Double)
function IKConstraintTimelineState:_onUpdateFrame()
  Double._onUpdateFrame(self)
  local constraint=self.target
  if self._timelineData~=nil then
    constraint._bendPositive=self._currentA>0.0
    constraint._weight=self._currentB
  else
    local data=constraint._constraintData
    constraint._bendPositive=data.bendPositive
    constraint._weight=data.weight
  end
  constraint:invalidUpdate()
  self.dirty=false
end
function IKConstraintTimelineState:init(a,s,d)
  Double.init(self,a,s,d)
  self._valueOffset=self._animationData.frameIntOffset
  self._valueScale=0.01
  self._valueArray=self._animationData.parent.parent.frameIntArray
end

return {ZOrderTimelineState=ZOrderTimelineState,IKConstraintTimelineState=IKConstraintTimelineState}
