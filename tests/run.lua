package.path="./?.lua;./?/init.lua;"..package.path
local DB=require("dragonbones")
local tests,ok=0,0
local function test(name,fn)
  tests=tests+1
  local status,err=pcall(fn)
  if status then ok=ok+1;print("ok "..tests.." "..name)
  else print("not ok "..tests.." "..name..": "..tostring(err)) end
end
local function close(a,b,delta)
  assert(math.abs(a-b)<(delta or 1e-6),tostring(a).." ~= "..tostring(b))
end
local input=assert(io.open("tests/fixtures/personagem-minimo.json","rb"))
local fixture=input:read("*a");input:close()
local project=DB.parser.parse(fixture)
test("JSON: escape, arrays, bool, null and Unicode",function()
  local x=DB.json.decode('{"a":[true,false,null],"s":"ol\\u00e1"}')
  assert(x.s=="olá" and x.a[1]==true and x.a[2]==false and x.a[3]==DB.json.null)
  assert(not pcall(DB.json.decode,'{"broken":}'))
end)
test("DragonBones: armature, slots and skins",function()
  local arm=project.armatures.PersonagemA
  assert(arm and #arm.slots==2 and #arm.skins==1)
  assert(#arm.ordered==3 and arm.frameRate==24)
  assert(arm.ordered[3].name=="forearm")
end)
test("DragonBones: detect cycle and missing parent",function()
  local a={armature={{name="bad",bone={{name="a",parent="b"},{name="b",parent="a"}}}}}
  assert(not pcall(DB.parser.parse,a))
end)
test("Matrix: rotate and translate",function()
  local m=DB.matrix.from_transform({x=5,y=7,rotation=math.pi/2})
  local x,y=DB.matrix.apply(m,2,0)
  close(x,5);close(y,9)
  local inv=DB.matrix.inverse(m)
  x,y=DB.matrix.apply(inv,x,y)
  close(x,2);close(y,0)
end)
test("Matrix: parent and child",function()
  local child=DB.matrix.from_transform({x=80,y=0})
  local parent=DB.matrix.from_transform({x=5,y=0})
  local total=DB.matrix.multiply(parent,child)
  close(total.tx,85)
end)
test("Runtime: hierarchy and rest pose",function()
  local a=DB.animation.new(project,"PersonagemA")
  local world=a:world_matrices()
  close(world.forearm.tx,85)
end)
test("Runtime: original keyframe interpolation",function()
  local a=DB.animation.new(project,"PersonagemA")
  a:play("walk");a:advance(.5)
  close(a:pose("upperArm").x,11) -- rest 5 + half of (0..12)
  close(a:pose("upperArm").rotation,math.pi/4)
  a:advance(.5);close(a:pose("upperArm").x,17)
end)
test("Runtime: pause, resume and loop",function()
  local a=DB.animation.new(project,"PersonagemA")
  a:play("walk");a:advance(.75);a:pause();a:advance(.5);close(a.time,.75)
  a:resume();a:advance(1.5);close(a.time,.25)
end)
test("Runtime: easing and Bezier curve",function()
  close(DB.animation.eased({tweenEasing=0},.5),.5)
  close(DB.animation.eased({tweenEasing=-2},.5),0)
  close(DB.animation.bezier({0,0,1,1},.5),.5,1e-5)
end)
test("DragonBones: scale keyframes default to 1",function()
  local input={version="5.5",armature={{name="scale",bone={{name="root"}},animation={{
    name="grow",duration=24,bone={{name="root",scaleFrame={
      {duration=12,x=1,y=1,tweenEasing=0},{duration=12,x=2}
    }}}}
  }}}}
  local project=DB.parser.parse(input)
  local anim=DB.animation.new(project,"scale")
  anim:play("grow")
  anim:advance(.75)
  local pose=anim:pose("root")
  close(pose.scaleX,2)
  close(pose.scaleY,1)
end)
test("JSON: rejects malformed numbers and executable text",function()
  for _,source in ipairs({"01","[1,]","2e+","{true:1}","os.execute('exit')"}) do
    assert(not pcall(DB.json.decode,source),"accepted invalid JSON: "..source)
  end
end)

test("Atlas: parse DragonBones SubTexture and slots in Z order",function()
  local f=assert(io.open("tests/fixtures/atlas-minimo.json","rb"))
  local raw=f:read("*a");f:close()
  local atlas=DB.atlas.parse(raw)
  local player=DB.animation.new(project,"PersonagemA")
  local attachments,missing=DB.atlas.attachments(player.armature,atlas)
  assert(#attachments==2 and #missing==0)
  assert(attachments[1].slot=="upperArm" and attachments[2].slot=="forearm")
  assert(atlas.regions.upperArm.width==64 and atlas.regions.forearm.x==64)
end)
test("Atlas: position sprites through hierarchical DragonBones matrices",function()
  local f=assert(io.open("tests/fixtures/atlas-minimo.json","rb"))
  local atlas=DB.atlas.parse(f:read("*a"));f:close()
  local player=DB.animation.new(project,"PersonagemA")
  local commands,warnings=DB.atlas.commands(player,atlas)
  assert(#commands==2 and #warnings==0)
  close(commands[1].matrix.tx,33)
  close(commands[2].matrix.tx,110)
  close(commands[1].offsetX,-32)
  close(commands[1].offsetY,-16)
  assert(commands[1].name=="upperArm")
end)
test("Atlas: hidden slot, missing region and non-image are safe",function()
  local arm=project.armatures.PersonagemA
  local atlas=DB.atlas.parse({width=20,height=20,SubTexture={{name="upperArm",x=0,y=0,width=10,height=10}}})
  local saved=arm.slots[2].displayIndex
  arm.slots[2].displayIndex=-1
  local commands,warnings=DB.atlas.commands(DB.animation.new(project,"PersonagemA"),atlas)
  assert(#commands==1 and #warnings==0)
  arm.slots[2].displayIndex=saved
  commands,warnings=DB.atlas.commands(DB.animation.new(project,"PersonagemA"),atlas)
  assert(#commands==1 and #warnings==1)
  assert(warnings[1].slot=="forearm")
end)
test("Atlas: reject duplicate, outside and invalid frame coordinates",function()
  local function parse(x) return DB.atlas.parse(x) end
  assert(not pcall(parse,{width=20,height=20,SubTexture={{name="a",x=19,y=0,width=2,height=5}}}))
  assert(not pcall(parse,{SubTexture={{name="a",x=0,y=0,width=-1,height=5}}}))
  assert(not pcall(parse,{SubTexture={{name="a",x=0,y=0,width=1,height=5},{name="a",x=1,y=0,width=1,height=5}}}))
end)
test("Atlas: rotated frames use logical width and height for pivot",function()
  local a=DB.atlas.parse({width=64,height=32,SubTexture={
    {name="upperArm",x=0,y=0,width=32,height=16,rotated=true},
    {name="forearm",x=32,y=0,width=32,height=16}
  }})
  local commands,warnings=DB.atlas.commands(DB.animation.new(project,"PersonagemA"),a)
  assert(#commands==2 and #warnings==0)
  assert(commands[1].rotated and not commands[2].rotated)
  close(commands[1].offsetX,-8)   -- logical width = 16, not packed width = 32
  close(commands[1].offsetY,-16)  -- logical height = 32
  close(commands[2].offsetX,-16)
  close(commands[2].offsetY,-8)
end)
test("LÖVE: clockwise-packed sprite is unrotated by 4x4 matrix",function()
  local a=DB.atlas.parse({width=64,height=32,SubTexture={
    {name="upperArm",x=0,y=0,width=32,height=16,rotated=true},
    {name="forearm",x=32,y=0,width=32,height=16}
  }})
  local commands=DB.atlas.commands(DB.animation.new(project,"PersonagemA"),a)
  local oldLove=_G.love
  local matrices,draws={},{}
  _G.love={math={newTransform=function()
    return {setMatrix=function(_,layout,...)
      assert(layout=="row")
      matrices[#matrices+1]={...}
    end}
  end},graphics={
    newQuad=function(x,y,w,h) return {x=x,y=y,w=w,h=h} end,
    setColor=function() end,push=function() end,pop=function() end,
    applyTransform=function() end,
    draw=function(_,quad,x,y) draws[#draws+1]={quad=quad,x=x,y=y} end
  }}
  local success,err=pcall(function()
    local image={getWidth=function()return 64 end,getHeight=function()return 32 end}
    local prepared=DB.love_renderer.prepare(image,a)
    DB.love_renderer.draw(prepared,commands)
  end)
  _G.love=oldLove
  assert(success,err)
  assert(#draws==2 and #matrices==2)
  close(draws[1].x,0)
  close(draws[1].y,0)
  assert(draws[1].quad.w==32 and draws[1].quad.h==16)
  -- Applying inverse clockwise mapping: source bottom-left -> original bottom-right
  -- Logical dimensions are 16x32; the armature + display transform puts
  -- the image origin at x=33, so the corrected translation is 33-8=25.
  local m=matrices[1]
  close(m[1],0)
  close(m[2],1)
  close(m[5],-1)
  close(m[6],0)
  close(m[4],25)
  close(m[8],16)
  close(m[4]+m[2]*16,41)
  close(m[8]+m[5]*32,-16)
end)
test("LÖVE adapter: draw textured atlas quads with graphics state restored",function()
  local f=assert(io.open("tests/fixtures/atlas-minimo.json","rb"))
  local atlas=DB.atlas.parse(f:read("*a"));f:close()
  local commands=DB.atlas.commands(DB.animation.new(project,"PersonagemA"),atlas)
  local calls={}
  local matrices={}
  local oldLove=_G.love
  _G.love={math={},graphics={
    newQuad=function(x,y,w,h,tw,th) return {x=x,y=y,w=w,h=h,tw=tw,th=th} end,
    setColor=function() end,
    push=function() calls[#calls+1]="push" end,
    pop=function() calls[#calls+1]="pop" end,
    applyTransform=function(t) calls[#calls+1]="transform" end,
    draw=function(image,quad,x,y)
      calls[#calls+1]={name=quad.x,offsetX=x,offsetY=y}
    end
  }}
  _G.love.math.newTransform=function()
    return {setMatrix=function(self,layout,...)
      assert(layout=="row","LÖVE matrix layout must be row")
      local values={...}
      assert(#values==16,"LÖVE requires a 4x4 matrix")
      matrices[#matrices+1]=values
    end}
  end
  local success,errorMessage=pcall(function()
    local image={getWidth=function() return 128 end,getHeight=function() return 64 end}
    local prepared=DB.love_renderer.prepare(image,atlas)
    DB.love_renderer.draw(prepared,commands)
  end)
  _G.love=oldLove
  assert(success,errorMessage)
  assert(#calls==8 and calls[1]=="push" and calls[4]=="pop" and calls[8]=="pop")
  close(calls[3].offsetX,-32)
  close(matrices[1][4],33)
  close(matrices[2][4],110)
  close(matrices[1][1],1)
  close(matrices[1][6],1)
end)
print(string.format("%d/%d Lua tests passed",ok,tests))
if ok~=tests then os.exit(1) end
