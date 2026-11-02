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
end

function ArmatureDisplay:dbUpdate()
  -- PIXI.Graphics debug geometry is outside LÖVE's baseline transport.
  -- Never pretend debug drawing worked if explicitly requested.
  if Core.debugDraw or self.debugDraw then
    error("LÖVE backend: PixiArmatureDisplay debugDraw is not ported")
  end
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
