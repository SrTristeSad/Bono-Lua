-- Last three concrete classes of TimelineState.ts.
-- DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e; MIT.
local Base=require('dragonbones.animation.BaseTimelineState')
local Single,Double=Base.SingleValueTimelineState,Base.DoubleValueTimelineState
local function klass(name,parent)
  local c={};c.__index=c;setmetatable(c,{__index=parent})
  c.toString=function()return '[class dragonBones.'..name..']'end
  c.new=function()return parent.new(c)end
  return c
end
local AnimationProgressTimelineState=klass("AnimationProgressTimelineState",Single)
function AnimationProgressTimelineState:_onUpdateFrame()
  Single._onUpdateFrame(self)
  local state=self.target
  if state._parent~=nil then
    state.currentTime=self._result*state.totalTime
  end
  self.dirty=false
end
function AnimationProgressTimelineState:init(a,s,d)
  Single.init(self,a,s,d)
  self._valueOffset=self._animationData.frameIntOffset
  self._valueScale=0.0001
  self._valueArray=self._animationData.parent.parent.frameIntArray
end

local AnimationWeightTimelineState=klass("AnimationWeightTimelineState",Single)
function AnimationWeightTimelineState:_onUpdateFrame()
  Single._onUpdateFrame(self)
  local state=self.target
  if state._parent~=nil then state.weight=self._result end
  self.dirty=false
end
function AnimationWeightTimelineState:init(a,s,d)
  Single.init(self,a,s,d)
  self._valueOffset=self._animationData.frameIntOffset
  self._valueScale=0.0001
  self._valueArray=self._animationData.parent.parent.frameIntArray
end

local AnimationParametersTimelineState=klass("AnimationParametersTimelineState",Double)
function AnimationParametersTimelineState:_onUpdateFrame()
  Double._onUpdateFrame(self)
  local state=self.target
  if state._parent~=nil then
    state.parameterX=self._resultA
    state.parameterY=self._resultB
  end
  self.dirty=false
end
function AnimationParametersTimelineState:init(a,s,d)
  Double.init(self,a,s,d)
  self._valueOffset=self._animationData.frameIntOffset
  self._valueScale=0.0001
  self._valueArray=self._animationData.parent.parent.frameIntArray
end
return {
  AnimationProgressTimelineState=AnimationProgressTimelineState,
  AnimationWeightTimelineState=AnimationWeightTimelineState,
  AnimationParametersTimelineState=AnimationParametersTimelineState,
}
