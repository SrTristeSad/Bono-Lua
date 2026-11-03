-- Direct port of DragonBones/src/dragonBones/model/BoundingBoxData.ts
-- Fixed upstream commit 64b6c69ae35777c2404be68c9192e2c56906079e.
-- Copyright (c) 2012-2025 DragonBones team and contributors.
-- Licensed MIT: see LICENSE-DRAGONBONES.
--
-- The four original classes and all collision methods are preserved.
-- JavaScript bitwise outcodes are implemented with small integer flags so
-- this Lua file is compatible with Lua 5.4 and LÖVE's LuaJIT.
local BaseObject = require("dragonbones.core.BaseObject")
local Core = require("dragonbones.core.Enums")

local function atan2(y,x)
  if math.atan2 ~= nil then return math.atan2(y,x) end
  return math.atan(y,x)
end
local JSArray = require("dragonbones.core.JSArray")
-- undefined numeric fields/holes take part in JS arithmetic as NaN.
local function number(value) if value == nil then return 0/0 end;return value end
local PI = math.pi
local OutCode = { InSide=0, Left=1, Right=2, Top=4, Bottom=8 }
local function flag(code,bit)
  return math.floor(code / bit) % 2 ~= 0
end
local function outcodeOr(a,b)
  local result=0
  for _,bit in ipairs({1,2,4,8}) do
    if flag(a,bit) or flag(b,bit) then result=result+bit end
  end
  return result
end
local function outcodeAnd(a,b)
  local result=0
  for _,bit in ipairs({1,2,4,8}) do
    if flag(a,bit) and flag(b,bit) then result=result+bit end
  end
  return result
end

local BoundingBoxData={}
BoundingBoxData.__index=BoundingBoxData
setmetatable(BoundingBoxData,{__index=BaseObject})

-- TS abstract base; subclasses construct via BaseObject.new(classType).
function BoundingBoxData.new(classType)
  return BaseObject.new(classType or BoundingBoxData)
end

function BoundingBoxData:_onClear()
  self.color=0x000000
  self.width=0.0
  self.height=0.0
end

local RectangleBoundingBoxData={}
RectangleBoundingBoxData.__index=RectangleBoundingBoxData
setmetatable(RectangleBoundingBoxData,{__index=BoundingBoxData})

function RectangleBoundingBoxData.toString()
  return "[class dragonBones.RectangleBoundingBoxData]"
end

function RectangleBoundingBoxData.new()
  return BoundingBoxData.new(RectangleBoundingBoxData)
end

function RectangleBoundingBoxData._computeOutCode(x,y,xMin,yMin,xMax,yMax)
  local code=OutCode.InSide
  if x<xMin then code=code+OutCode.Left
  elseif x>xMax then code=code+OutCode.Right end
  if y<yMin then code=code+OutCode.Top
  elseif y>yMax then code=code+OutCode.Bottom end
  return code
end

function RectangleBoundingBoxData.rectangleIntersectsSegment(
  xA,yA,xB,yB,xMin,yMin,xMax,yMax,intersectionPointA,intersectionPointB,normalRadians)

  local inSideA=xA>xMin and xA<xMax and yA>yMin and yA<yMax
  local inSideB=xB>xMin and xB<xMax and yB>yMin and yB<yMax
  if inSideA and inSideB then return -1 end

  local intersectionCount=0
  local outcode0=RectangleBoundingBoxData._computeOutCode(xA,yA,xMin,yMin,xMax,yMax)
  local outcode1=RectangleBoundingBoxData._computeOutCode(xB,yB,xMin,yMin,xMax,yMax)
  while true do
    if outcodeOr(outcode0,outcode1)==0 then
      intersectionCount=2
      break
    elseif outcodeAnd(outcode0,outcode1)~=0 then
      break
    end

    local x,y,normalRadian=0.0,0.0,0.0
    local outcodeOut=outcode0~=0 and outcode0 or outcode1

    if flag(outcodeOut,OutCode.Top) then
      x=xA+(xB-xA)*(yMin-yA)/(yB-yA)
      y=yMin
      if normalRadians~=nil then normalRadian=-PI*0.5 end
    elseif flag(outcodeOut,OutCode.Bottom) then
      x=xA+(xB-xA)*(yMax-yA)/(yB-yA)
      y=yMax
      if normalRadians~=nil then normalRadian=PI*0.5 end
    elseif flag(outcodeOut,OutCode.Right) then
      y=yA+(yB-yA)*(xMax-xA)/(xB-xA)
      x=xMax
      if normalRadians~=nil then normalRadian=0 end
    elseif flag(outcodeOut,OutCode.Left) then
      y=yA+(yB-yA)*(xMin-xA)/(xB-xA)
      x=xMin
      if normalRadians~=nil then normalRadian=PI end
    end

    if outcodeOut==outcode0 then
      xA,yA=x,y
      outcode0=RectangleBoundingBoxData._computeOutCode(xA,yA,xMin,yMin,xMax,yMax)
      if normalRadians~=nil then normalRadians.x=normalRadian end
    else
      xB,yB=x,y
      outcode1=RectangleBoundingBoxData._computeOutCode(xB,yB,xMin,yMin,xMax,yMax)
      if normalRadians~=nil then normalRadians.y=normalRadian end
    end
  end

  if intersectionCount~=0 then
    if inSideA then
      intersectionCount=2
      if intersectionPointA~=nil then
        intersectionPointA.x=xB
        intersectionPointA.y=yB
      end
      if intersectionPointB~=nil then
        intersectionPointB.x=xB
        -- Faithful to original upstream's "intersectionPointB.y = xB".
        intersectionPointB.y=xB
      end
      if normalRadians~=nil then normalRadians.x=normalRadians.y+PI end
    elseif inSideB then
      intersectionCount=1
      if intersectionPointA~=nil then
        intersectionPointA.x=xA
        intersectionPointA.y=yA
      end
      if intersectionPointB~=nil then
        intersectionPointB.x=xA
        intersectionPointB.y=yA
      end
      if normalRadians~=nil then normalRadians.y=normalRadians.x+PI end
    else
      intersectionCount=3
      if intersectionPointA~=nil then
        intersectionPointA.x=xA
        intersectionPointA.y=yA
      end
      if intersectionPointB~=nil then
        intersectionPointB.x=xB
        intersectionPointB.y=yB
      end
    end
  end
  return intersectionCount
end

function RectangleBoundingBoxData:_onClear()
  BoundingBoxData._onClear(self)
  self.type=Core.BoundingBoxType.Rectangle
end

function RectangleBoundingBoxData:containsPoint(pX,pY)
  local widthH=number(self.width)*0.5
  if pX>=-widthH and pX<=widthH then
    local heightH=number(self.height)*0.5
    if pY>=-heightH and pY<=heightH then return true end
  end
  return false
end

function RectangleBoundingBoxData:intersectsSegment(xA,yA,xB,yB,pointA,pointB,normals)
  local widthH=number(self.width)*0.5
  local heightH=number(self.height)*0.5
  local count=RectangleBoundingBoxData.rectangleIntersectsSegment(
    xA,yA,xB,yB,-widthH,-heightH,widthH,heightH,pointA,pointB,normals)
  return count
end

local EllipseBoundingBoxData={}
EllipseBoundingBoxData.__index=EllipseBoundingBoxData
setmetatable(EllipseBoundingBoxData,{__index=BoundingBoxData})

function EllipseBoundingBoxData.toString()
  -- Original deliberately names this class "EllipseData".
  return "[class dragonBones.EllipseData]"
end

function EllipseBoundingBoxData.new()
  return BoundingBoxData.new(EllipseBoundingBoxData)
end

function EllipseBoundingBoxData.ellipseIntersectsSegment(
  xA,yA,xB,yB,xC,yC,widthH,heightH,pointA,pointB,normals)
  local d=widthH/heightH
  local dd=d*d
  yA=yA*d
  yB=yB*d

  local dX=xB-xA
  local dY=yB-yA
  local lAB=math.sqrt(dX*dX+dY*dY)
  local xD=dX/lAB
  local yD=dY/lAB
  local a=(xC-xA)*xD+(yC-yA)*yD
  local aa=a*a
  local ee=xA*xA+yA*yA
  local rr=widthH*widthH
  local dR=rr-ee+aa
  local intersectionCount=0

  if dR>=0.0 then
    local dT=math.sqrt(dR)
    local sA=a-dT
    local sB=a+dT
    local inSideA=sA<0.0 and -1 or (sA<=lAB and 0 or 1)
    local inSideB=sB<0.0 and -1 or (sB<=lAB and 0 or 1)
    local sideAB=inSideA*inSideB

    if sideAB<0 then
      return -1
    elseif sideAB==0 then
      if inSideA==-1 then
        intersectionCount=2
        xB=xA+sB*xD
        yB=(yA+sB*yD)/d
        if pointA~=nil then pointA.x=xB;pointA.y=yB end
        if pointB~=nil then pointB.x=xB;pointB.y=yB end
        if normals~=nil then
          normals.x=atan2(yB/rr*dd,xB/rr)
          normals.y=normals.x+PI
        end
      elseif inSideB==1 then
        intersectionCount=1
        xA=xA+sA*xD
        yA=(yA+sA*yD)/d
        if pointA~=nil then pointA.x=xA;pointA.y=yA end
        if pointB~=nil then pointB.x=xA;pointB.y=yA end
        if normals~=nil then
          normals.x=atan2(yA/rr*dd,xA/rr)
          normals.y=normals.x+PI
        end
      else
        intersectionCount=3
        if pointA~=nil then
          pointA.x=xA+sA*xD
          pointA.y=(yA+sA*yD)/d
          if normals~=nil then
            normals.x=atan2(pointA.y/rr*dd,pointA.x/rr)
          end
        end
        if pointB~=nil then
          pointB.x=xA+sB*xD
          pointB.y=(yA+sB*yD)/d
          if normals~=nil then
            normals.y=atan2(pointB.y/rr*dd,pointB.x/rr)
          end
        end
      end
    end
  end
  return intersectionCount
end

function EllipseBoundingBoxData:_onClear()
  BoundingBoxData._onClear(self)
  self.type=Core.BoundingBoxType.Ellipse
end

function EllipseBoundingBoxData:containsPoint(pX,pY)
  local widthH=number(self.width)*0.5
  if pX>=-widthH and pX<=widthH then
    local heightH=number(self.height)*0.5
    if pY>=-heightH and pY<=heightH then
      pY=pY*(widthH/heightH)
      return math.sqrt(pX*pX+pY*pY)<=widthH
    end
  end
  return false
end

function EllipseBoundingBoxData:intersectsSegment(xA,yA,xB,yB,pointA,pointB,normals)
  local count=EllipseBoundingBoxData.ellipseIntersectsSegment(
    xA,yA,xB,yB,0.0,0.0,number(self.width)*0.5,number(self.height)*0.5,
    pointA,pointB,normals)
  return count
end

local PolygonBoundingBoxData={}
PolygonBoundingBoxData.__index=PolygonBoundingBoxData
setmetatable(PolygonBoundingBoxData,{__index=BoundingBoxData})

function PolygonBoundingBoxData.toString()
  return "[class dragonBones.PolygonBoundingBoxData]"
end

function PolygonBoundingBoxData.new()
  local object=BoundingBoxData.new(PolygonBoundingBoxData)
  object.vertices=JSArray.new()
  return object
end

function PolygonBoundingBoxData.polygonIntersectsSegment(
  xA,yA,xB,yB,vertices,pointA,pointB,normals)
  if xA==xB then xA=xB+0.000001 end
  if yA==yB then yA=yB+0.000001 end

  local count=vertices.length
  local dXAB=xA-xB
  local dYAB=yA-yB
  local llAB=xA*yB-yA*xB
  local intersectionCount=0
  local xC=number(vertices[count-1])
  local yC=number(vertices[count])
  local dMin,dMax,xMin,yMin,xMax,yMax=0.0,0.0,0.0,0.0,0.0,0.0

  for i=1,count,2 do
    local xD,yD=number(vertices[i]),number(vertices[i+1])
    if xC==xD then xC=xD+0.0001 end
    if yC==yD then yC=yD+0.0001 end

    local dXCD=xC-xD
    local dYCD=yC-yD
    local llCD=xC*yD-yC*xD
    local ll=dXAB*dYCD-dYAB*dXCD
    local x=(llAB*dXCD-dXAB*llCD)/ll

    if ((x>=xC and x<=xD) or (x>=xD and x<=xC)) and
      (dXAB==0.0 or (x>=xA and x<=xB) or (x>=xB and x<=xA)) then
      local y=(llAB*dYCD-dYAB*llCD)/ll
      if ((y>=yC and y<=yD) or (y>=yD and y<=yC)) and
        (dYAB==0.0 or (y>=yA and y<=yB) or (y>=yB and y<=yA)) then

        if pointB~=nil then
          local d=x-xA
          if d<0.0 then d=-d end

          if intersectionCount==0 then
            dMin,dMax=d,d
            xMin,yMin=x,y
            xMax,yMax=x,y
            if normals~=nil then
              normals.x=atan2(yD-yC,xD-xC)-PI*0.5
              normals.y=normals.x
            end
          else
            if d<dMin then
              dMin=d
              xMin,yMin=x,y
              if normals~=nil then
                normals.x=atan2(yD-yC,xD-xC)-PI*0.5
              end
            end
            if d>dMax then
              dMax=d
              xMax,yMax=x,y
              if normals~=nil then
                normals.y=atan2(yD-yC,xD-xC)-PI*0.5
              end
            end
          end
          intersectionCount=intersectionCount+1
        else
          xMin,yMin=x,y
          xMax,yMax=x,y
          intersectionCount=intersectionCount+1
          if normals~=nil then
            normals.x=atan2(yD-yC,xD-xC)-PI*0.5
            normals.y=normals.x
          end
          break
        end
      end
    end
    xC,yC=xD,yD
  end

  if intersectionCount==1 then
    if pointA~=nil then pointA.x=xMin;pointA.y=yMin end
    if pointB~=nil then pointB.x=xMin;pointB.y=yMin end
    if normals~=nil then normals.y=normals.x+PI end
  elseif intersectionCount>1 then
    intersectionCount=intersectionCount+1
    if pointA~=nil then pointA.x=xMin;pointA.y=yMin end
    if pointB~=nil then pointB.x=xMax;pointB.y=yMax end
  end
  return intersectionCount
end

function PolygonBoundingBoxData:_onClear()
  BoundingBoxData._onClear(self)
  self.type=Core.BoundingBoxType.Polygon
  self.x=0.0
  self.y=0.0
  self.vertices.length=0
end

function PolygonBoundingBoxData:containsPoint(pX,pY)
  local isInSide=false
  if pX>=number(self.x) and pX<=number(self.width) and pY>=number(self.y) and pY<=number(self.height) then
    local l=self.vertices.length
    local iP=l-1
    for i=1,l,2 do
      local yA=number(self.vertices[iP+1])
      local yB=number(self.vertices[i+1])
      if (yB<pY and yA>=pY) or (yA<pY and yB>=pY) then
        local xA=number(self.vertices[iP])
        local xB=number(self.vertices[i])
        if (pY-yB)*(xA-xB)/(yA-yB)+xB<pX then
          isInSide=not isInSide
        end
      end
      iP=i
    end
  end
  return isInSide
end

function PolygonBoundingBoxData:intersectsSegment(xA,yA,xB,yB,pointA,pointB,normals)
  local intersectionCount=0
  if RectangleBoundingBoxData.rectangleIntersectsSegment(
    xA,yA,xB,yB,number(self.x),number(self.y),number(self.x)+number(self.width),number(self.y)+number(self.height),
    nil,nil,nil)~=0 then
    intersectionCount=PolygonBoundingBoxData.polygonIntersectsSegment(
      xA,yA,xB,yB,self.vertices,pointA,pointB,normals)
  end
  return intersectionCount
end

return {
  BoundingBoxData=BoundingBoxData,
  RectangleBoundingBoxData=RectangleBoundingBoxData,
  EllipseBoundingBoxData=EllipseBoundingBoxData,
  PolygonBoundingBoxData=PolygonBoundingBoxData
}
