-- flypy_hint.lua
-- 小鹤双拼键位提示：把候选词的拼音注释转换为双拼编码
-- 例如：zhōng guó → vs go
-- 规则与 rime-ice double_pinyin_flypy.schema.yaml 的 speller/algebra 一致

local M = {}

-- 去掉声调符号（ü → v，与 rime-ice 的 [uv] 规则一致）
local function detone(s)
  s = s:gsub("ā","a"):gsub("á","a"):gsub("ǎ","a"):gsub("à","a")
  s = s:gsub("ō","o"):gsub("ó","o"):gsub("ǒ","o"):gsub("ò","o")
  s = s:gsub("ē","e"):gsub("é","e"):gsub("ě","e"):gsub("è","e")
  s = s:gsub("ī","i"):gsub("í","i"):gsub("ǐ","i"):gsub("ì","i")
  s = s:gsub("ū","u"):gsub("ú","u"):gsub("ǔ","u"):gsub("ù","u")
  s = s:gsub("ǖ","v"):gsub("ǘ","v"):gsub("ǚ","v"):gsub("ǜ","v"):gsub("ü","v")
  return s
end

-- 单个拼音音节 → 小鹤双拼编码（重现 rime-ice algebra 规则链）
local function flypy_encode(py)
  local s = py
  s = s:gsub("^([aoe])$", "%1%1")
  s = s:gsub("^([aoe])ng$", "%1%1ng")
  s = s:gsub("^([jqxy])u$", "%1V")
  s = s:gsub("iu$", "Q")
  s = s:gsub("(.)ei$", "%1W")
  s = s:gsub("uan$", "R")
  s = s:gsub("[uv]e$", "T")
  s = s:gsub("un$", "Y")
  s = s:gsub("^sh", "U")
  s = s:gsub("^ch", "I")
  s = s:gsub("^zh", "V")
  s = s:gsub("uo$", "O")
  s = s:gsub("ie$", "P")
  s = s:gsub("(.)iong$", "%1S")
  s = s:gsub("(.)ong$", "%1S")
  s = s:gsub("uai$", "K")
  s = s:gsub("ing$", "K")
  s = s:gsub("(.)ai$", "%1D")
  s = s:gsub("(.)en$", "%1F")
  s = s:gsub("(.)eng$", "%1G")
  s = s:gsub("[iu]ang$", "L")
  s = s:gsub("(.)ang$", "%1H")
  s = s:gsub("ian$", "M")
  s = s:gsub("(.)an$", "%1J")
  s = s:gsub("(.)ou$", "%1Z")
  s = s:gsub("[iu]a$", "X")
  s = s:gsub("iao$", "N")
  s = s:gsub("(.)ao$", "%1C")
  s = s:gsub("ui$", "V")
  s = s:gsub("in$", "B")
  local xlit = {
    Q='q', W='w', R='r', T='t', Y='y', U='u', I='i', O='o', P='p', S='s',
    D='d', F='f', G='g', H='h', J='j', K='k', L='l', Z='z', X='x', C='c',
    V='v', B='b', N='n', M='m',
  }
  return (s:gsub(".", function(c) return xlit[c] or c end))
end

-- 把一段带声调的拼音注释转换为双拼编码
-- 只处理 ［...］ 格式（来自 spelling_hints 的拼音注释），避免误转换英文等其他注释
local function convert_comment(comment)
  local pinyin = comment:match("^［(.-)］$")
  if not pinyin then return nil end
  pinyin = pinyin:gsub("['']", " ")
  local parts = {}
  for syll in pinyin:gmatch("%S+") do
    table.insert(parts, flypy_encode(detone(syll)))
  end
  return table.concat(parts, " ")
end

function M.func(input, env)
  for cand in input:iter() do
    local ok, code = pcall(function()
      local comment = cand.comment
      if not comment or #comment == 0 then return nil end
      return convert_comment(comment)
    end)
    if ok and code and #code > 0 then
      -- 安全地尝试修改 comment；失败则忽略
      pcall(function()
        local genuine = cand:get_genuine()
        if genuine then genuine.comment = code end
      end)
    end
    yield(cand)
  end
end

return M
