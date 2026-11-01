-- Affine 2D matrices matching DragonBones' a,b,c,d,tx,ty convention.
local M = {}
local cos, sin, abs = math.cos, math.sin, math.abs

function M.identity()
  return { a=1,b=0,c=0,d=1,tx=0,ty=0 }
end

function M.multiply(left, right)
  return {
    a = left.a*right.a + left.c*right.b,
    b = left.b*right.a + left.d*right.b,
    c = left.a*right.c + left.c*right.d,
    d = left.b*right.c + left.d*right.d,
    tx = left.a*right.tx + left.c*right.ty + left.tx,
    ty = left.b*right.tx + left.d*right.ty + left.ty
  }
end

function M.apply(m, x, y)
  return m.a*x+m.c*y+m.tx, m.b*x+m.d*y+m.ty
end

function M.inverse(m)
  local det = m.a*m.d - m.b*m.c
  assert(abs(det)>1e-12, "non-invertible DragonBones matrix")
  return {
    a=m.d/det, b=-m.b/det, c=-m.c/det, d=m.a/det,
    tx=(m.c*m.ty-m.d*m.tx)/det,
    ty=(m.b*m.tx-m.a*m.ty)/det
  }
end

function M.from_transform(t)
  local rotation, skew = t.rotation or 0, t.skew or 0
  local sx, sy = t.scaleX or 1, t.scaleY or 1
  return {
    a=cos(rotation)*sx, b=sin(rotation)*sx,
    c=-sin(rotation+skew)*sy, d=cos(rotation+skew)*sy,
    tx=t.x or 0, ty=t.y or 0
  }
end

return M
