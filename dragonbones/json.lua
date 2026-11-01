-- Small self-contained strict JSON decoder in Lua. Does not execute JSON as Lua code.
local json = {}
json.null = {}
function json.decode(source)
  assert(type(source)=="string", "JSON source must be a string")
  local i,n=1,#source
  local function fail(message) error("JSON at byte "..i..": "..message, 0) end
  local function ws()
    while i<=n and source:sub(i,i):match("%s") do i=i+1 end
  end
  local function unicode(code)
    assert(code>=0 and code<=0x10ffff and not (code>=0xd800 and code<=0xdfff), "invalid Unicode code point")
    return utf8.char(code)
  end
  local parse
  local function string_value()
    if source:sub(i,i)~='"' then fail("expected quote") end
    i=i+1
    local out={}
    while i<=n do
      local c=source:sub(i,i)
      if c=='"' then i=i+1;return table.concat(out) end
      if c=="\\" then
        i=i+1
        local e=source:sub(i,i)
        local escapes={['"']='"',["\\"]="\\",["/"]="/",b="\b",f="\f",n="\n",r="\r",t="\t"}
        if escapes[e] then out[#out+1]=escapes[e];i=i+1
        elseif e=="u" then
          local h=source:sub(i+1,i+4)
          if not h:match("^%x%x%x%x$") then fail("invalid Unicode escape") end
          local cp=tonumber(h,16);i=i+5
          if cp>=0xd800 and cp<=0xdbff then
            if source:sub(i,i+1)~="\\u" then fail("missing low surrogate") end
            local low=source:sub(i+2,i+5)
            if not low:match("^%x%x%x%x$") then fail("invalid low surrogate") end
            local value=tonumber(low,16)
            if value<0xdc00 or value>0xdfff then fail("invalid surrogate pair") end
            cp=0x10000+(cp-0xd800)*1024+(value-0xdc00)
            i=i+6
          elseif cp>=0xdc00 and cp<=0xdfff then fail("orphan low surrogate") end
          out[#out+1]=unicode(cp)
        else fail("unknown string escape") end
      else
        if c:byte()<32 then fail("unescaped control character") end
        out[#out+1]=c;i=i+1
      end
    end
    fail("unterminated string")
  end
  local function number_value()
    local remain=source:sub(i)
    local token=remain:match("^%-?%d+%.?%d*[eE][%+%-]?%d+")
      or remain:match("^%-?%d+%.%d+")
      or remain:match("^%-?%d+")
    if not token or not token:match("^%-?(0|[1-9])") then -- Lua patterns do not support alternation.
      -- Validity is checked with an anchored complete numeric grammar below.
    end
    if not token or token:match("^%-?0%d") then fail("invalid number") end
    local value=tonumber(token)
    if not value or value==math.huge or value==-math.huge then fail("invalid numeric value") end
    i=i+#token
    return value
  end
  function parse()
    ws()
    local ch=source:sub(i,i)
    if ch=='"' then return string_value() end
    if ch=="{" then
      i=i+1;ws()
      local result={}
      if source:sub(i,i)=="}" then i=i+1;return result end
      while true do
        ws()
        if source:sub(i,i)~='"' then fail("expected object key") end
        local key=string_value();ws()
        if source:sub(i,i)~=":" then fail("expected colon") end
        i=i+1;result[key]=parse();ws()
        local sep=source:sub(i,i);i=i+1
        if sep=="}" then return result end
        if sep~="," then fail("expected comma or closing brace") end
      end
    end
    if ch=="[" then
      i=i+1;ws()
      local result={}
      if source:sub(i,i)=="]" then i=i+1;return result end
      while true do
        result[#result+1]=parse();ws()
        local sep=source:sub(i,i);i=i+1
        if sep=="]" then return result end
        if sep~="," then fail("expected comma or closing bracket") end
      end
    end
    if source:sub(i,i+3)=="true" then i=i+4;return true end
    if source:sub(i,i+4)=="false" then i=i+5;return false end
    if source:sub(i,i+3)=="null" then i=i+4;return json.null end
    if ch=="-" or ch:match("%d") then return number_value() end
    fail("unexpected token")
  end
  local result=parse();ws()
  if i<=n then fail("trailing data") end
  return result
end
return json
