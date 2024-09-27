-- Лексер
--
local function lexer(input)
  local tokens = {}

  for line in input:gmatch("[^;\n]+") do
    -- Пропуск комментариев
    if line:find("^#") then
      goto continue

    -- Удаление комментариев
    elseif line:find("%s*#") then
      line = line:gsub("%s*#.+", "")
    end

    local g_token = line:gmatch("%S+")
    local token = g_token()

    -- Запись токенов
    while token do
      -- Сборка строки
      if token:find("^\"") then
        local buff = ""
        while token and not token:find("\"$") do
          buff = buff .. " ".. token
          token = g_token()
        end
        buff = buff .." ".. token
        table.insert(tokens, buff)
        goto continue
      end

      table.insert(tokens, token)
      token = g_token()
    end

    ::continue::
  end

  return tokens
end
--

return lexer
