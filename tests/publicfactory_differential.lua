local Factory=require('dragonbones.love.Factory')
local Proxy=require('dragonbones.love.ArmatureDisplay')
local Core=require('dragonbones.core.DragonBones')
local Parser=require('dragonbones.parser.ObjectDataParser')
local JSON=require('dragonbones.parser.JSON')
local function read(p)local f=assert(io.open(p));local s=f:read('*a');f:close();return s end
local fixture=read('examples/public_factory_ske.json')
local atlasText=read('examples/love/sprites_tex.json')
local double
if string.pack then double=function(v)return string.pack('<d',v)end
else local ffi=require('ffi');double=function(v)return ffi.string(ffi.new('double[1]',v),8)end end
local function scalar(v)
  if v==nil then return'u'end
  if type(v)=='boolean'then return tostring(v)end
  if type(v)=='string'then return's'..(v:gsub('.',function(c)return('%02x'):format(c:byte())end))end
  return'n'..(double(v):gsub('.',function(c)return('%02x'):format(c:byte())end))
end
print=function()end
local function execute(c)
  local out={};local function push(v)out[#out+1]=scalar(v)end
  if c[1]=='events'then
    local p=Proxy.new();local t1,t2={tag='one'},{tag='two'};local trace={};local changed=false
    local a,b,cc
    a=function(context,e)
      trace[#trace+1]='a:'..(context==p and'self'or context.tag)..':'..e.name
      if not changed then
        changed=true
        if c[2]=='removeDuring'then p:removeDBEventListener('custom',b,t2)end
        if c[2]=='addDuring'then p:addDBEventListener('custom',cc,t1)end
        if c[2]=='reenter'then p:dispatchDBEvent('custom',{name='inner'})end
        if c[2]=='throw'then error('listener')end
      end
    end
    b=function(context,e)trace[#trace+1]='b:'..context.tag..':'..e.name end
    cc=function(context,e)trace[#trace+1]='c:'..context.tag..':'..e.name end
    push(p:hasDBEventListener('custom'))
    if c[2]=='once'or c[2]=='throw'then p:once('custom',a,t1)else p:addDBEventListener('custom',a,t1)end
    p:addDBEventListener('custom',b,t2)
    if c[2]=='contexts'then p:addDBEventListener('custom',a,t2);p:addDBEventListener('custom',a,t1);p:removeDBEventListener('custom',a,t1)end
    if c[2]=='special'then
      p:addDBEventListener('__proto__',a,0);p:dispatchDBEvent('__proto__',{name='proto'})
      p:addDBEventListener('',a,'');p:dispatchDBEvent('',{name='empty'});p:removeDBEventListener('',a,0);push(p:hasDBEventListener(''))
    end
    for _,name in ipairs({'first','second'})do
      local ok=pcall(function()p:dispatchDBEvent('custom',{name=name})end)
      push(ok and'ok'or'error');push(p:hasDBEventListener('custom'));push(#p:listeners('custom'))
    end
    p:removeDBEventListener('custom',a);p:removeDBEventListener('custom',b);p:removeDBEventListener('custom',cc)
    push(p:hasDBEventListener('custom'));push(table.concat(trace,'|'))
    return table.concat(out,'\t')
  end
  local parserMode,debug,flip,boxes=tonumber(c[2]),tonumber(c[3]),tonumber(c[4]),tonumber(c[5])
  Factory._factory=nil;Factory._dragonBonesInstance=nil;Core.debugDraw=false
  local parser=parserMode==1 and Parser.new()or nil
  local f=parserMode==2 and Factory.factory or Factory.new(parser)
  local other=Factory.new();f.clock.time=0
  push(f.dragonBones==other.dragonBones);push(f.clock==other.clock);push(Factory.factory==Factory.factory)
  push(Factory.factory.dragonBones==f.dragonBones);push(parser==nil or f._dataParser==parser)
  local raw=JSON.parse(fixture)
  if boxes==1 then for i=1,raw.armature[1].slot.length do raw.armature[1].slot[i].displayIndex=1 end end
  f:parseDragonBonesData(raw,'public')
  local image={width=48,height=16}
  local atlas=f:parseTextureAtlasData(JSON.parse(atlasText),parserMode~=2 and image or nil,'public')
  f.autoSearch=true;atlas.autoSearch=true
  push(other:getDragonBonesData('public')==nil);push(f:buildArmatureDisplay('missing','public')==nil)
  local sprite=f:getTextureDisplay('red','public')
  push(sprite~=nil);push(sprite~=nil and sprite.texture==atlas:getTexture('red').renderTexture)
  push(f:getTextureDisplay('red')~=nil);push(f:getTextureDisplay('missing')==nil)
  local p=f:buildArmatureDisplay('demo','public');local a=p.armature
  local plain=f:buildArmature('demo','public')
  push(a.proxy==p);push(a.eventDispatcher==p);push(p.animation==a.animation);push(f.clock:contains(a));push(f.clock:contains(plain))
  for _,pair in ipairs({{p,'armature'},{p,'animation'},{f,'soundEventManager'},{Factory,'factory'}})do
    local ok=pcall(function()pair[1][pair[2]]=nil end);push(ok and'written'or'readonly')
  end
  local trace={};local localTarget,soundTarget={tag='local'},{tag='global'}
  local function event(context,e)trace[#trace+1]=context.tag..':'..e.type..':'..e.name end
  for _,kind in ipairs({'start','loopComplete','frameEvent','soundEvent'})do p:addDBEventListener(kind,event,localTarget)end
  f.soundEventManager:addDBEventListener('soundEvent',event,soundTarget)
  a.flipX=flip==1;p.debugDraw=debug==1;Core.debugDraw=debug==2;p.animation:play('move',0)
  local function snap()
    push(p._debugDraw);push(#p.children);local drawer=p._debugDrawer
    push(drawer~=nil);push(drawer~=nil and drawer.parent==p)
    if not drawer then return end
    push(#drawer.children)
    for _,child in ipairs(drawer.children)do
      push(child.name)
      for _,key in ipairs({'x','y','scaleX','scaleY','rotation','skewX','skewY','pivotX','pivotY'})do push(child[key])end
      push(#child.commands)
      for _,cmd in ipairs(child.commands)do push(#cmd);for _,v in ipairs(cmd)do push(v)end end
    end
  end
  for step=0,3 do
    if (step==1 or step==2)and boxes==1 then
      local slots=a:getSlots();for i=1,slots.length do slots[i].displayIndex=step==1 and 0 or 1 end
    end
    if step==3 then p.debugDraw=false;Core.debugDraw=false end
    Factory._clockHandler(step==1 and .5 or 1,({0,500,250,500})[step+1])
    snap();push(p.animation.lastAnimationState.currentTime)
  end
  push(table.concat(trace,'|'));p:removeDBEventListener('frameEvent',event,localTarget);push(p:hasDBEventListener('frameEvent'))
  p:dispose(false);push(p.armature==nil);push(f.clock:contains(a))
  local ok=pcall(function()return p.animation end);push(ok and'animation'or'error')
  p:destroy();plain:dispose();f.dragonBones:advanceTime(0)
  push(f.clock:contains(a));push(p._debugDrawer==nil);push(#p.children);push(p:hasDBEventListener('start'))
  if sprite then sprite:destroy()end
  f.soundEventManager:removeDBEventListener('soundEvent',event,soundTarget)
  f:clear();f.dragonBones:advanceTime(0);Core.debugDraw=false
  return table.concat(out,'\t')
end
for line in io.lines(arg[1])do
  local c={};for v in line:gmatch('[^\t]+')do c[#c+1]=v end
  io.write(execute(c),'\n')
end
-- Keep the existing adapter callback as a compatibility extension.
local legacy=Proxy.new();local seen=false
legacy.onEvent=function(kind,event)seen=kind=='legacy'and event.name=='payload'end
assert(legacy:hasDBEventListener('legacy'));legacy:dispatchDBEvent('legacy',{name='payload'});assert(seen)
