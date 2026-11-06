-- Port of Pixi/4.x PixiArmatureDisplay.ts at 64b6c69ae35777c2404be68c9192e2c56906079e.
-- Copyright (c) DragonBones contributors. MIT: LICENSE-DRAGONBONES.
local Display=require('dragonbones.love.Display')
local Graphics=require('dragonbones.love.Graphics')
local Events=require('dragonbones.love.EventEmitter')
local Core=require('dragonbones.core.DragonBones')
local Box=require('dragonbones.core.Enums').BoundingBoxType
local Proxy={}
function Proxy.__index(self,key)
  if key=='armature'then return self._armature end
  if key=='animation'then return self._armature.animation end
  return rawget(Proxy,key)or Events[key]or Display[key]
end
function Proxy.__newindex(self,key,value)
  if key=='armature'or key=='animation'then error('Readonly property: '..key)end
  rawset(self,key,value)
end
function Proxy.new()
  local self=setmetatable(Display.new('sprite'),Proxy)
  Events.init(self);self.debugDraw=false;self._debugDraw=false
  return self
end
function Proxy:dbInit(armature)self._armature=armature end
function Proxy:dbClear()
  if self._debugDrawer then self._debugDrawer:destroy(true)end
  self._armature=nil;self._debugDrawer=nil
  Display.destroy(self)
end
function Proxy:dbUpdate()
  local drawn=Core.debugDraw or self.debugDraw
  if drawn or self._debugDraw then
    self._debugDraw=drawn
    if self._debugDraw then
      if not self._debugDrawer then
        self._debugDrawer=Display.new('sprite')
        self._debugDrawer:addChild(Graphics.new())
      end
      self:addChild(self._debugDrawer)
      local drawer=self._debugDrawer:getChildAt(0);drawer:clear()
      local bones=self._armature:getBones()
      for i=1,bones.length do
        local bone=bones[i];local length=bone.boneData.length
        local m=bone.globalTransformMatrix;local x,y=m.tx,m.ty
        drawer:lineStyle(2,0x00ffff,.7);drawer:moveTo(x,y)
        drawer:lineTo(x+m.a*length,y+m.b*length)
        drawer:lineStyle(0,0,0);drawer:beginFill(0x00ffff,.7)
        drawer:drawCircle(x,y,3);drawer:endFill()
      end
      local slots=self._armature:getSlots()
      for i=1,slots.length do
        local slot=slots[i];local data=slot.boundingBoxData
        local child=self._debugDrawer:getChildByName(slot.name)
        if data then
          if not child then child=Graphics.new();child.name=slot.name;self._debugDrawer:addChild(child)end
          child:clear();child:lineStyle(2,0xff00ff,.7)
          if data.type==Box.Rectangle then child:drawRect(-data.width*.5,-data.height*.5,data.width,data.height)
          elseif data.type==Box.Ellipse then child:drawEllipse(-data.width*.5,-data.height*.5,data.width,data.height)
          elseif data.type==Box.Polygon then
            local v=data.vertices
            for j=1,v.length,2 do
              if j==1 then child:moveTo(v[j],v[j+1])else child:lineTo(v[j],v[j+1])end
            end
            child:lineTo(v[1],v[2])
          end
          child:endFill();slot:updateTransformAndMatrix();slot:updateGlobalTransform()
          local t=slot.global
          child:setTransform(t.x,t.y,t.scaleX,t.scaleY,t.rotation,t.skew,0,slot._pivotX,slot._pivotY)
        elseif child then self._debugDrawer:removeChild(child)end
      end
    elseif self._debugDrawer and self._debugDrawer.parent==self then self:removeChild(self._debugDrawer)end
  end
end
function Proxy:dispose(disposeProxy)
  if self._armature then self._armature:dispose();self._armature=nil end
end
function Proxy:destroy()self:dispose()end
function Proxy:dispatchDBEvent(kind,event)
  self:emit(kind,event)
  -- Compatibility with the previous adapter's single callback.
  if self.onEvent then self.onEvent(kind,event)end
end
function Proxy:hasDBEventListener(kind)return self:listeners(kind,true)or self.onEvent~=nil end
function Proxy:addDBEventListener(kind,listener,target)self:addListener(kind,listener,target)end
function Proxy:removeDBEventListener(kind,listener,target)self:removeListener(kind,listener,target)end
return Proxy
