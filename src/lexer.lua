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
      -- Обработка строк
      if token:sub(1, 1) == "\"" then
        local buff = line:match("(\".+\")")
        if not buff then
          buff = "\"\""
        end

        table.insert(tokens, {
          type = "string",
          value = buff
        })
        break

      -- Предполагаем, что токен может быть числом
      elseif token:find("^%d+$") then
        table.insert(tokens, {
          type = "int",
          value = tonumber(token)
        })
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
