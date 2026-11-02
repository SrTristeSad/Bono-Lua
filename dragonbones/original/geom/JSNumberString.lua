-- Language-boundary support for DragonBonesJS's implicit Number->String
-- in Matrix.ts::toString and Transform.ts::toString.
-- Original source: DragonBones/DragonBonesJS (MIT), pinned at
-- 64b6c69ae35777c2404be68c9192e2c56906079e.
-- Do not replace transform calculations with string approximations.
local JSNumberString={}

function JSNumberString.format(value)
  -- Lua 5.4 has int64 values; JS Number parameters are always binary64.
  -- Round integer arguments to a double *before* finding JS notation.
  -- In particular, int64 values beyond 2^53 cannot round-trip as int64
  -- through a decimal produced from their JS binary64 representation.
  value=value+0.0
  if value~=value then return "NaN" end
  if value==math.huge then return "Infinity" end
  if value==-math.huge then return "-Infinity" end
  if value==0 then return "0" end -- ECMAScript also renders -0 as "0".

  local sign=""
  if value<0 then sign="-";value=-value end

  -- Find the shortest C-locale decimal that parses back to the SAME double.
  -- Lua tostring normally uses a host-specific precision (sometimes 6
  -- digits), while JavaScript Number stringification is round-trip safe.
  local shortest
  for digits=1,17 do
    local candidate=string.format("%."..digits.."g",value)
    if tonumber(candidate)==value then
      shortest=candidate
      break
    end
  end
  assert(shortest~=nil,"No round-trip decimal for finite number: "..tostring(value))

  -- ECMAScript uses fixed notation in [1e-6,1e21) and scientific outside.
  -- printf %g instead chooses exponent notation beginning at 1e-4.
  if value>=1e-6 and value<1e21 then
    local integral,fraction,exp=shortest:match("^(%d+)%.?(%d*)[eE]([+-]?%d+)$")
    if integral then
      local raw=integral..fraction
      local position=#integral+tonumber(exp)
      if position<=0 then
        shortest="0."..string.rep("0",-position)..raw
      elseif position>=#raw then
        shortest=raw..string.rep("0",position-#raw)
      else
        shortest=raw:sub(1,position).."."..raw:sub(position+1)
      end
    end
  else
    local mantissa,exp=shortest:match("^([^eE]+)[eE]([+-]?%d+)$")
    if mantissa then
      local n=tonumber(exp)
      shortest=mantissa.."e"..(n>=0 and "+" or "")..tostring(n)
    end
  end
  return sign..shortest
end

return JSNumberString
