-- Host drawing operations used by pinned PixiArmatureDisplay.dbUpdate.
local Display=require('dragonbones.love.Display')
local Graphics={};Graphics.__index=function(_,key)return Graphics[key]or Display[key]end
function Graphics.new()
  local self=setmetatable(Display.new('graphics'),Graphics);self.commands={};return self
end
function Graphics:clear()self.commands={};return self end
for _,name in ipairs({'lineStyle','moveTo','lineTo','beginFill','endFill','drawCircle','drawRect','drawEllipse'})do
  Graphics[name]=function(self,...)
    self.commands[#self.commands+1]={name,...};return self
  end
end
function Graphics:_drawGraphics(alpha)
  local g=love.graphics
  local width,lineColor,lineAlpha=0,0,1
  local fillColor,fillAlpha,fill=0,1,false
  local points={}
  local function color(rgb,a)
    g.setColor(math.floor(rgb/65536)%256/255,math.floor(rgb/256)%256/255,rgb%256/255,a*alpha)
  end
  local function flush()
    if #points>=4 and width>0 then
      color(lineColor,lineAlpha);g.setLineWidth(width);g.line(points)
    end
    points={}
  end
  g.setBlendMode('alpha','alphamultiply')
  for _,c in ipairs(self.commands)do
    local op=c[1]
    if op=='lineStyle'then flush();width=c[2];lineColor=c[3];lineAlpha=c[4]
    elseif op=='moveTo'then flush();points={c[2],c[3]}
    elseif op=='lineTo'then points[#points+1]=c[2];points[#points+1]=c[3]
    elseif op=='beginFill'then flush();fill=true;fillColor=c[2];fillAlpha=c[3]
    elseif op=='endFill'then flush();fill=false
    else
      flush()
      local function shape(mode)
        if op=='drawCircle'then g.circle(mode,c[2],c[3],c[4])
        elseif op=='drawRect'then g.rectangle(mode,c[2],c[3],c[4],c[5])
        elseif op=='drawEllipse'then g.ellipse(mode,c[2],c[3],c[4],c[5])end
      end
      if fill then color(fillColor,fillAlpha);shape('fill')end
      if width>0 then color(lineColor,lineAlpha);g.setLineWidth(width);shape('line')end
    end
  end
  flush()
end
return Graphics
