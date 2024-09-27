-- Парсер
--
-- Все переменные глобальные по умолчанию
local variables = {}
-- Метки для оператора GOTO
local labels = {}

--
local function parse_command(tree, token)
  -- Смешение токена
  local offset = 1

  -- Добавление в дерево
  table.insert(tree, {
    type = "command",
    name = token,
  })

  return offset
end

-- Парсинг команды GOTO
local function parse_GOTO(tree, tokens, index)
  -- Смешение токена GOTO
  local offset = 1

  -- Получение метки
  local label = tokens[index + offset]

  -- Добавление в дерево
  table.insert(tree, {
    type = "command",
    name = "GOTO",
    label = label
  })

  return offset
end

-- Парсинг типа данных STRING
local function parse_STRING(tree, tokens, index)
  -- Смешение токена STRING
  local offset = 1
  -- Имя переменной
  local var_name = tokens[index + offset]

  -- Добавление в дерево и в список переменных
  local data = {
    type = "variable",
    name = var_name,
    data_type = "string",
  }

  variables[var_name] = data
  table.insert(tree, data)

  return offset
end

-- Парсинг типа данных INT
local function parse_INT(tree, tokens, index)
  -- Смешение токена INT
  local offset = 1
  -- Имя переменной
  local var_name = tokens[index + offset]

  -- Добавление в дерево и в список переменных
  local data = {
    type = "variable",
    name = var_name,
    data_type = "int",
  }

  variables[var_name] = data
  table.insert(tree, data)

  return offset
end

-- Парсинг типа арифметического или математического выражения
local function parse_expression(tree, tokens, index)
  -- Смешение токена выражения
  local offset = 1
  -- Выражение
  local expression = tokens[index]

  local type
  if expression == "=" then
    type = "assign_expression"
  elseif
         expression == "+"
      or expression == "-"
      or expression == "*"
      or expression == "/"
  then
    type = "arithmetic_expression"
  else
    error("Ошибка выражения: "..tokens[index-1] .. " " .. tokens[index])
  end

  -- Добавление в дерево
  table.insert(tree, {
    type = type,
    operator = expression,
  })

  return offset
end

-- Генерация дерева
local function gen_tree(tokens)
  local tree = {}
  local i = 1

  while i <= #tokens do
    local token = tokens[i]

    if token == "PRINTL" then
      local offet = parse_command(tree, token)
      i = i + offet

    elseif token == "PRINT" then
      local offet = parse_command(tree, token)
      i = i + offet

    elseif token == "READ" then
      local offet = parse_command(tree, token)
      i = i + offet

    elseif token == "RANDOM" then
      local offet = parse_command(tree, token)
      i = i + offet

    elseif token == "TONUMBER" then
      local offet = parse_command(tree, token)
      i = i + offet

    elseif token == "GOTO" then
      local offet = parse_GOTO(tree, tokens, i)
      i = i + offet

    -- Узел для оператора IF
    elseif token == "IF" then
      local offset = 1
      table.insert(tree, {
        type = "conditional_expression",
        operator = token
      })
      i = i + offset

    --
    elseif token == "=="
      or token == ">"
      or token == "<"
      or token == "!="
      or token == ">="
      or token == "<="
    then
      local offset = 1
      table.insert(tree, {
        type = "comparison_operator",
        operator = token,
      })
      i = i + offset

    elseif token == "AND" then
      local offset = 1
      table.insert(tree, {
        type = "and_expression",
        operator = token,
      })
      i = i + offset
    elseif token == "OR" then
      local offset = 1
      table.insert(tree, {
        type = "or_expression",
        operator = token,
      })
      i = i + offset

    -- Оператор начала условия
    elseif token == "THEN" then
      local offset = 1
      table.insert(tree, {
        type = "then_branch",
        operator = token,
      })
      i = i + offset

    -- Оператор в окончания условия
    elseif token == "ENDIF" then
      local offset = 1
      table.insert(tree, {
        type = "complete_condition_operator",
        operator = token,
      })
      i = i + offset

    elseif token == "STRING" then
      local offet = parse_STRING(tree, tokens, i)
      i = i + offet + 1

    elseif token == "INT" then
      local offet = parse_INT(tree, tokens, i)
      i = i + offet + 1

    elseif token == "="
      or token == "+"
      or token == "-"
      or token == "*"
      or token == "/"
    then
      local offet = parse_expression(tree, tokens, i)
      i = i + offet

    -- Обработка строковых и числовых значений
    elseif type(token) == "table" then
      -- Добавление в дерево
      table.insert(tree, {
        type = token.type,
        value = token.value
      })
      i = i + 1

    -- Подразумеваем, что токен это переменная, которая уже известна
    elseif variables[token] then
      -- Добавление в дерево
      table.insert(tree, {
        type = variables[token].type,
        name = variables[token].name,
        data_type = variables[token].data_type
      })
      i = i + 1

    -- Метки для GOTO
    elseif token:find("::.+::") then
      if labels[token] then
        error("Такая метка уже существует: "..token)
      end
      -- Добавление в дерево
      table.insert(tree, {
        type = "label",
        name = token
      })

      labels[token] = true
      i = i + 1

    else
      i = i + 1
    end
  end

  return tree, variables
end

return gen_tree
