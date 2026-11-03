-- Real LÖVE GPU IK integration: original ObjectDataParser -> BaseFactory ->
-- Armature/Bone/IKConstraint/Animation -> PixiSlot LÖVE adapter.
-- Pinned DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e (MIT).
-- No alternative IK solver or hand-authored poses.
local Love=require("dragonbones.love_original")
local Constraint=require("dragonbones.original.armature.Constraint")
local Test={}

local function fixture(chain)
  return {
    version="5.5",name="OriginalIKGPU",frameRate=12,
    armature={{
      name="rig",
      bone={
        {name="root",length=8},
        {name="tip",parent="root",length=8,transform={x=8,y=0}},
        {name="target",transform={x=12,y=8}},
      },
      ik={{name="aim",bone="tip",target="target",
        chain=chain,weight=1,bendPositive=true}},
      slot={{name="marker",parent="tip",displayIndex=0}},
      skin={{name="default",slot={{name="marker",display={{
        name="red",path="red",type="image",pivot={x=0,y=0}
      }}}}}},
      animation={{name="aimMotion",duration=12,playTimes=0,
        bone={{name="target",translateFrame={
          {duration=6,x=12,y=8,tweenEasing=0},
          {duration=6,x=4,y=-8,tweenEasing=0}
        }}}
      }}
    }}
  }
end

local function draw(factory,armature)
  local canvas=love.graphics.newCanvas(72,72)
  canvas:setFilter("nearest","nearest")
  love.graphics.push("all")
  love.graphics.setCanvas(canvas)
  love.graphics.clear(0,0,0,0)
  love.graphics.translate(28,28)
  factory:drawArmature(armature)
  love.graphics.setCanvas()
  love.graphics.pop()
  return canvas:newImageData()
end

local function compare(before,after,name)
  local visibleBefore,visibleAfter,changed=0,0,0
  for y=0,71 do for x=0,71 do
    local r1,g1,b1,a1=before:getPixel(x,y)
    local r2,g2,b2,a2=after:getPixel(x,y)
    if a1>0.5 and r1>0.7 and g1<0.2 and b1<0.2 then
      visibleBefore=visibleBefore+1
    end
    if a2>0.5 and r2>0.7 and g2<0.2 and b2<0.2 then
      visibleAfter=visibleAfter+1
    end
    if math.abs(a1-a2)>0.4 then changed=changed+1 end
  end end
  assert(visibleBefore>=8 and visibleAfter>=8,
    name.." original IK armature did not render in both animation frames")
  assert(changed>=8,name.." IK animation drew a static image despite moving target")
end

function Test.run()
  local pixels=love.image.newImageData(6,6)
  for y=0,5 do for x=0,5 do pixels:setPixel(x,y,1,0,0,1) end end
  local image=love.graphics.newImage(pixels)
  image:setFilter("nearest","nearest")
  local atlas={name="IKGPUAtlas",width=6,height=6,
    SubTexture={{name="red",x=0,y=0,width=6,height=6}}}
  for _,chain in ipairs({0,1}) do
    local factory=Love.Factory.new()
    local name="ik-chain-"..chain
    local data=assert(factory:parseDragonBonesData(fixture(chain),name))
    assert(data:getArmature("rig"):getConstraint("aim")~=nil,
      "Original ObjectDataParser did not create IKConstraintData")
    factory:parseTextureAtlasData(atlas,image,name)
    local armature=assert(factory:buildArmature("rig",name))
    local constraint=assert(armature._constraints[1],
      "Original BaseFactory did not build runtime IKConstraint")
    assert(getmetatable(constraint)==Constraint.IKConstraint)
    assert(constraint._target.name=="target" and constraint._root.name==
      (chain==0 and "tip" or "root"))
    if chain==1 then
      assert(constraint._bone~=nil and constraint._bone.name=="tip")
    else assert(constraint._bone==nil) end
    assert(armature:getSlot("marker")._renderDisplay.quad~=nil)
    local target=assert(armature:getBone("target"))
    local root=assert(armature:getBone("root"))
    local tip=assert(armature:getBone("tip"))
    armature.animation:play("aimMotion")
    armature:advanceTime(0)
    local startImage=draw(factory,armature)
    local startTargetX,startTargetY=target.global.x,target.global.y
    local startRootRotation,startTipRotation=root.global.rotation,tip.global.rotation
    armature:advanceTime(9/12)
    local endImage=draw(factory,armature)
    assert(math.abs(target.global.x-startTargetX)>3
      and math.abs(target.global.y-startTargetY)>4,
      "Original target animation timeline did not update the IK target")
    if chain==1 then
      assert(math.abs(root.global.rotation-startRootRotation)>0.15,
        "Two-bone IK root did not respond to the animated target")
    else
      assert(math.abs(tip.global.rotation-startTipRotation)>0.15,
        "Single-bone IK did not respond to the animated target")
    end
    compare(startImage,endImage,name)
  end
  print("Original live IK GPU: single- and two-bone chains, animated target, visible motion, real Armature and Slot.")
end
return Test
