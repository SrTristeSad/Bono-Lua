-- LÖVE callback adapter for the EventEmitter semantics used by PixiArmatureDisplay.
-- Listener context (JavaScript `this`) becomes the first Lua callback argument.
local truthy=require('dragonbones.parser.JSValue').truthy
local unpack=table.unpack or unpack
local E={}
function E.init(self)self._listeners={}end
function E:listeners(event,exists)
  local list=self._listeners[event]
  if truthy(exists)then return list~=nil end
  local result={};if list then for i,v in ipairs(list)do result[i]=v.fn end end
  return result
end
local function add(self,event,fn,context,once)
  local list=self._listeners[event]
  if not list then list={};self._listeners[event]=list end
  list[#list+1]={fn=fn,context=truthy(context)and context or self,once=once}
  return self
end
function E:on(event,fn,context)return add(self,event,fn,context,false)end
function E:once(event,fn,context)return add(self,event,fn,context,true)end
E.addListener=E.on
function E:removeListener(event,fn,context,once)
  local list=self._listeners[event]
  if not list then return self end
  if not truthy(fn)then self._listeners[event]=nil;return self end
  local keep={}
  for _,v in ipairs(list)do
    if v.fn~=fn or(truthy(once)and not v.once)or(truthy(context)and v.context~=context)then
      keep[#keep+1]=v
    end
  end
  self._listeners[event]=#keep>0 and keep or nil
  return self
end
E.off=E.removeListener
function E:removeAllListeners(event)
  if truthy(event)then self._listeners[event]=nil else self._listeners={}end
  return self
end
function E:emit(event,...)
  local list=self._listeners[event]
  if not list then return false end
  -- Keep the original list and length during reentrant additions/removals.
  local count,args,n=#list,{...},select('#',...)
  for i=1,count do
    local v=list[i]
    if v.once then self:removeListener(event,v.fn,nil,true)end
    v.fn(v.context,unpack(args,1,n))
  end
  return true
end
return E
