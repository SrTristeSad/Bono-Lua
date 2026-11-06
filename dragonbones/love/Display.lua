-- LÖVE scene bridge for the Pixi 4 display operations used by PixiSlot.
-- This adapter owns no animation/math algorithms. LÖVE 11.x is needed only to draw.
local Display={};Display.__index=Display
function Display.new(kind)
  return setmetatable({kind=kind or'container',children={},x=0,y=0,scaleX=1,scaleY=1,
    rotation=0,skewX=0,skewY=0,alpha=1,tint=0xffffff,visible=true,blendMode=0,dirty=0,indexDirty=0},Display)
end
function Display:setTransform(x,y,sx,sy,r,kx,ky)
  self.x=x or 0;self.y=y or 0;self.scaleX=sx or 1;self.scaleY=sy or 1
  self.rotation=r or 0;self.skewX=kx or 0;self.skewY=ky or 0
end
function Display:getChildIndex(child)
  for i,v in ipairs(self.children)do if v==child then return i-1 end end
  error('Display is not a child')
end
function Display:removeChild(child)
  table.remove(self.children,self:getChildIndex(child)+1);child.parent=nil
end
function Display:addChild(child)
  if child.parent then child.parent:removeChild(child)end
  self.children[#self.children+1]=child;child.parent=self
end
function Display:addChildAt(child,index)
  if child.parent then child.parent:removeChild(child)end
  assert(index>=0 and index<=#self.children,'Child index out of range')
  table.insert(self.children,index+1,child);child.parent=self
end
function Display:swapChildren(a,b)
  local ia,ib=self:getChildIndex(a)+1,self:getChildIndex(b)+1
  self.children[ia],self.children[ib]=b,a
end
function Display:destroy()
  if self.parent then self.parent:removeChild(self)end
  if self._gpuMesh then self._gpuMesh:release();self._gpuMesh=nil end
  self.texture=nil;self.destroyed=true
end
local function drawNode(node,parentAlpha)
  if not node.visible then return end
  local g=love.graphics
  g.push('all')
  local r,kx,ky=node.rotation,node.skewX,node.skewY
  local transform=love.math.newTransform()
  transform:setMatrix(math.cos(r+ky)*node.scaleX,-math.sin(r-kx)*node.scaleY,0,node.x,
    math.sin(r+ky)*node.scaleX,math.cos(r-kx)*node.scaleY,0,node.y,
    0,0,1,0,0,0,0,1)
  g.applyTransform(transform)
  local alpha=parentAlpha*node.alpha
  if (node.kind=='sprite'or node.kind=='mesh')and node.texture then
    local texture=node.texture
    assert(not texture.destroyed,'Texture frame was disposed')
    if node.kind=='sprite'and not texture.rotated and not texture.quad then
      texture.quad=g.newQuad(texture.x,texture.y,texture.width,texture.height,
        texture.image:getWidth(),texture.image:getHeight())
    end
    local tint=node.tint
    g.setColor(math.floor(tint/65536)%256/255,math.floor(tint/256)%256/255,tint%256/255,alpha)
    if node.blendMode==0 then g.setBlendMode('alpha','alphamultiply')
    elseif node.blendMode==1 then g.setBlendMode('add','alphamultiply')
    else error('LÖVE sprite backend currently supports Normal/Add blend only')end
    if node.kind=='mesh'then
      g.setMeshCullMode('none')
      if node.vertices and node.indices.length>0 then
        if node._gpuDirty or not node._gpuMesh then
          local vertices={}
          for i=1,node.vertices.length,2 do
            vertices[#vertices+1]={node.vertices[i],node.vertices[i+1],node.uvs[i],node.uvs[i+1],1,1,1,1}
          end
          if node._gpuMesh and node._gpuMesh:getVertexCount()~=#vertices then
            node._gpuMesh:release();node._gpuMesh=nil
          end
          if not node._gpuMesh then node._gpuMesh=g.newMesh(vertices,'triangles','dynamic')
          else node._gpuMesh:setVertices(vertices)end
          local map={};for i=1,node.indices.length do map[i]=node.indices[i]+1 end
          node._gpuMesh:setVertexMap(map);node._gpuDirty=false
        end
        node._gpuMesh:setTexture(texture.image)
        g.draw(node._gpuMesh)
      end
    elseif texture.rotated then
      if not texture.spriteMesh then
        local image=texture.image
        local x,y,w,h=texture.x,texture.y,texture.width,texture.height
        local iw,ih=image:getWidth(),image:getHeight()
        texture.spriteMesh=g.newMesh({
          {0,0,(x+w)/iw,y/ih,1,1,1,1},
          {w,0,(x+w)/iw,(y+h)/ih,1,1,1,1},
          {w,h,x/iw,(y+h)/ih,1,1,1,1},
          {0,h,x/iw,y/ih,1,1,1,1},
        },'triangles','static')
        texture.spriteMesh:setVertexMap(1,2,3,1,3,4)
        texture.spriteMesh:setTexture(image)
      end
      g.setMeshCullMode('none');g.draw(texture.spriteMesh)
    else g.draw(texture.image,texture.quad)end
  end
  for _,child in ipairs(node.children)do drawNode(child,alpha)end
  g.pop()
end
function Display:draw(x,y,scale)
  assert(love and love.graphics,'Drawing requires LÖVE 11.x')
  love.graphics.push('all');love.graphics.translate(x or 0,y or 0)
  love.graphics.scale(scale or 1)
  drawNode(self,1)
  love.graphics.pop()
end
return Display
