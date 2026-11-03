-- Differential original IKConstraint.update vs pinned DragonBonesJS bundle.
-- Reference: 64b6c69ae35777c2404be68c9192e2c56906079e (MIT).
-- Same geometry/IK algorithms; only JS-to-Lua indexing and call syntax differ.
package.path="./?.lua;./?/init.lua;"..package.path
local Base=require("dragonbones.original.core.BaseObject")
local Constraint=require("dragonbones.original.armature.Constraint")
local Transform=require("dragonbones.original.geom.Transform")
local Matrix=require("dragonbones.original.geom.Matrix")
local function split(line)
  local values={}
  for field in (line.."\t"):gmatch("(.-)\t") do values[#values+1]=field end
  return values
end
local function bone(x,y,rotation,scaleX,scaleY,length)
  local global=Transform.new()
  global.x=x;global.y=y;global.rotation=rotation;global.scaleX=scaleX;global.scaleY=scaleY
  local matrix=Matrix.new()
  global:toMatrix(matrix)
  local result={global=global,globalTransformMatrix=matrix,_boneData={length=length}}
  function result:updateByConstraint() end
  return result
end
local function check(actual,reference,caseName,key)
  if reference=="none" then
    assert(actual==nil,caseName.." unexpected "..key)
    return
  end
  if reference=="NaN" then
    assert(actual~=actual,caseName.." "..key.." expected NaN got "..tostring(actual))
    return
  elseif reference=="Infinity" then
    assert(actual==math.huge,caseName.." "..key.." expected Infinity")
    return
  elseif reference=="-Infinity" then
    assert(actual==-math.huge,caseName.." "..key.." expected -Infinity")
    return
  end
  local expected=assert(tonumber(reference),caseName.." "..key.." bad numeric reference "..reference)
  assert(type(actual)=="number",caseName.." "..key.." not numeric")
  if reference=="-0" then
    assert(actual==0 and 1/actual==-math.huge,caseName.." "..key.." expected -0")
    return
  end
  local epsilon=1e-8*math.max(1,math.abs(expected))
  assert(math.abs(actual-expected)<=epsilon,
    ("%s %s original %s vs Lua %.17g"):format(caseName,key,reference,actual))
end
local names={"rotation","x","y","a","b","c","d","tx","ty"}
local function inspect(result,reference,first,caseName,label)
  for i,key in ipairs(names) do
    local actual
    if result~=nil then
      if i<=3 then actual=result.global[key]
      else actual=result.globalTransformMatrix[key] end
    end
    check(actual,reference[first+i-1],caseName,label.."."..key)
  end
end
local fixture=assert(io.open("tests/fixtures/ik_solver_cases.tsv","rb"))
local expectedFile=assert(io.open("artifacts/upstream/ik_solver_expected.tsv","rb"))
local tested=0
for line in fixture:lines() do
  if line~="" and line:sub(1,1)~="#" then
    local fields=split(line)
    assert(#fields==17,"Malformed IK case: "..line)
    local caseName,mode=fields[1],fields[2]
    local values={}
    for i=3,17 do values[#values+1]=assert(tonumber(fields[i]),caseName.." field "..i) end
    local rx,ry,rr,rsx,rsy,cx,cy,cr,csx,clen,tx,ty,w,bend,mirror=
      values[1],values[2],values[3],values[4],values[5],values[6],values[7],
      values[8],values[9],values[10],values[11],values[12],values[13],values[14],values[15]
    local root=bone(rx,ry,rr,rsx,rsy,0)
    local child=bone(cx,cy,cr,csx,1,clen)
    child.parent=root
    if mirror~=0 then
      local m=Matrix.new()
      m.a=-1
      root.parent={globalTransformMatrix=m}
    end
    local target=bone(tx,ty,0,1,1,0)
    local ik=Base.borrowObject(Constraint.IKConstraint)
    ik._root=root;ik._target=target;ik._bone=mode=="D" and child or nil
    ik._weight=w;ik._bendPositive=bend~=0
    ik:update()
    local reference=assert(expectedFile:read("*l"),"Reference missing "..caseName)
    local fieldsExpected=split(reference)
    assert(fieldsExpected[1]==caseName, "Reference misordered "..caseName)
    assert(#fieldsExpected==19,"Unexpected reference field count "..caseName)
    inspect(root,fieldsExpected,2,caseName,"root")
    inspect(mode=="D" and child or nil,fieldsExpected,11,caseName,"child")
    ik:returnToPool()
    tested=tested+1
  end
end
fixture:close()
assert(expectedFile:read("*l")==nil,"Upstream reference has extra cases")
expectedFile:close()
assert(tested==56,"Unexpected IK fixture count: "..tested)
print(("Original DragonBonesJS IKConstraint differential: %d solver cases passed"):format(tested))
