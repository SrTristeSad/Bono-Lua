-- LÖVE platform adapter for the original PixiArmatureDisplay.ts.
-- DragonBonesJS commit 64b6c69ae35777c2404be68c9192e2c56906079e.
-- Copyright (c) 2012-2025 DragonBones team and other contributors.
-- MIT license: see LICENSE-DRAGONBONES.
--
-- In Pixi, the same PixiArmatureDisplay is passed to Armature.init as
-- eventDispatcher (IArmatureProxy) and as display (PIXI.Sprite). LÖVE has
-- no PIXI.Sprite, so the retained display is this Lua object. Its
-- _renderSlots list is the LÖVE equivalent of the Pixi display children.
-- Pixi's EventEmitter3 target/context calls are represented by the Lua
-- convention listener(target, event) when a context is supplied; an
-- unbound listener receives only listener(event).
local Core=require("dragonbones.original.core.DragonBones")

local ArmatureDisplay={}
ArmatureDisplay.__index=function(self,key)
  if key=="armature" then return rawget(self,"_armature") end
  if key=="animation" then
    -- Matches the original getter: accessing animation after disposal
    -- is invalid, rather than returning an unrelated Animation instance.
    return rawget(self,"_armature").animation
  end
  return rawget(ArmatureDisplay,key)
end

function ArmatureDisplay.new()
  return setmetatable({
    _armature=nil,
    _renderSlots={},
    _listeners={},
    _debugDraw=false,
    _debugDrawer=nil,
    debugDraw=false
  },ArmatureDisplay)
end

function ArmatureDisplay:dbInit(armature)
  self._armature=armature
end

function ArmatureDisplay:dbClear()
  -- Pixi destroys its debug graphics and display on Armature pool return.
  -- Lua releases the retained references and event listeners here.
  self._armature=nil
  self._renderSlots={}
  self._listeners={}
  self._debugDraw=false
  self._debugDrawer=nil
end

-- PixiArmatureDisplay.dbUpdate reconstructs the debug graphics only when
-- DragonBones.debugDraw or this.debugDraw is true. The retained graphics
-- are removed from the display when disabled, not disposed until dbClear.
-- Store the original drawing instructions and emit them through LÖVE's
-- immediate-mode GPU commands in drawDebug; no core geometry is invented.
function ArmatureDisplay:dbUpdate()
  local enabled=(Core.debugDraw or self.debugDraw) and true or false
  if not enabled and not self._debugDraw then return end
  self._debugDraw=enabled
  if not enabled then return end
  if self._debugDrawer==nil then
    self._debugDrawer={bones={},slots={}}
  end
  local drawer=self._debugDrawer
  local armature=self._armature
  local bones={}
  for _,bone in ipairs(armature:getBones()) do
    local m=bone.globalTransformMatrix
    local length=bone.boneData.length
    local x,y=m.tx,m.ty
    bones[#bones+1]={x,y,x+m.a*length,y+m.b*length}
  end
  drawer.bones=bones

  local slots={}
  for _,slot in ipairs(armature:getSlots()) do
    local bounding=slot.boundingBoxData
    if bounding~=nil then
      -- Pixi's child graphics are transformed by slot.global, not by the
      -- picture's image/quad transform used in PixiSlot._updateTransformV4.
      slot:updateTransformAndMatrix()
      slot:updateGlobalTransform()
      local t=slot.global
      local cos, sin=math.cos,math.sin
      local a=cos(t.rotation)*t.scaleX
      local b=sin(t.rotation)*t.scaleX
      local c=-sin(t.rotation-t.skew)*t.scaleY
      local d=cos(t.rotation-t.skew)*t.scaleY
      local px,py=slot._pivotX,slot._pivotY
      local vertices
      if bounding.type==Core.BoundingBoxType.Polygon then
        vertices={}
        for i,v in ipairs(bounding.vertices) do vertices[i]=v end
      end
      slots[#slots+1]={
        name=slot.name,type=bounding.type,
        width=bounding.width,height=bounding.height,
        vertices=vertices,
        a=a,b=b,c=c,d=d,
        tx=t.x-a*px-c*py,ty=t.y-b*px-d*py
      }
    end
  end
  drawer.slots=slots
end

-- Draw the retained Pixi debug commands last, as the PixiArmatureDisplay's
-- _debugDrawer is appended above all slot children by its dbUpdate method.
function ArmatureDisplay:drawDebug(graphics,inheritedAlpha)
  if not self._debugDraw or self._debugDrawer==nil then return end
  local drawer=self._debugDrawer
  graphics.push("all")
  graphics.setLineWidth(2)
  graphics.setColor(0,1,1,0.7*(inheritedAlpha or 1))
  for _,bone in ipairs(drawer.bones) do
    graphics.line(bone[1],bone[2],bone[3],bone[4])
    graphics.circle("fill",bone[1],bone[2],3)
  end
  for _,slot in ipairs(drawer.slots) do
    graphics.push("all")
    local matrix=love.math.newTransform()
    matrix:setMatrix("row",
      slot.a,slot.c,0,slot.tx,
      slot.b,slot.d,0,slot.ty,
      0,0,1,0,
      0,0,0,1)
    graphics.applyTransform(matrix)
    graphics.setLineWidth(2)
    graphics.setColor(1,0,1,0.7*(inheritedAlpha or 1))
    if slot.type==Core.BoundingBoxType.Rectangle then
      graphics.rectangle("line",-slot.width*0.5,-slot.height*0.5,
        slot.width,slot.height)
    elseif slot.type==Core.BoundingBoxType.Ellipse then
      graphics.ellipse("line",0,0,slot.width*0.5,slot.height*0.5)
    elseif slot.type==Core.BoundingBoxType.Polygon and #slot.vertices>=4 then
      -- PIXI.Graphics.closePath closes the last edge to the first point.
      graphics.polygon("line",slot.vertices)
    end
    graphics.pop()
  end
  graphics.pop()
end

function ArmatureDisplay:dispose(disposeProxy)
  -- Pixi ignores disposeProxy and detaches its Armature immediately,
  -- while the DragonBones object itself is returned to the pool later.
  local armature=self._armature
  if armature~=nil then
    armature:dispose()
    self._armature=nil
  end
end

function ArmatureDisplay:destroy()
  self:dispose()
end

function ArmatureDisplay:hasDBEventListener(eventType)
  local list=self._listeners[eventType]
  return list~=nil and #list>0
end

function ArmatureDisplay:addDBEventListener(eventType,listener,target)
  local list=self._listeners[eventType]
  if list==nil then
    list={}
    self._listeners[eventType]=list
  end
  -- Pixi EventEmitter accepts duplicate registrations, retaining order.
  list[#list+1]={callback=listener,target=target}
end

function ArmatureDisplay:removeDBEventListener(eventType,listener,target)
  local list=self._listeners[eventType]
  if list==nil then return end
  -- EventEmitter3's removeListener also matches its optional context.
  -- The same function can therefore be subscribed with many targets.
  for i=#list,1,-1 do
    local item=list[i]
    if item.callback==listener and item.target==target then
      table.remove(list,i)
    end
  end
  if #list==0 then self._listeners[eventType]=nil end
end

function ArmatureDisplay:dispatchDBEvent(eventType,eventObject)
  local list=self._listeners[eventType]
  if list==nil then return end
  -- EventEmitter3 snapshots the current listeners when it copies/updates
  -- its listener array. Registrations during dispatch do not run in the
  -- current emission, while removal does not invalidate this traversal.
  local active={}
  for i,item in ipairs(list) do active[i]=item end
  for _,item in ipairs(active) do
    if item.target~=nil then
      item.callback(item.target,eventObject)
    else
      item.callback(eventObject)
    end
  end
end

return ArmatureDisplay
