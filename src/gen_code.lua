---- Генератор Lua кода из дерева
--
local space_to_if = 0

-- Генерация команд, с возвращаемыми значениями
-- READ -> io.read()
-- TONUMBER -> tonumber()
local function generate_returned_command(tree, i)
  local offset = 1
  local result = ""
  local spaces = string.rep(" ", space_to_if)

  -- Имя команды
  local name = tree[i].name

  if name == "READ" then
    offset = offset + 1
    -- Печатный текст
    local arg_text = tree[i + 1]
    -- Сборка команды
    local fmt = spaces.."io.write(%s)\nlocal %s = io.read()"
    result = fmt:format(arg_text.value, tree[i - 2].name)

  elseif name == "TONUMBER" then
    offset = offset + 1
    -- Значение для обработки
    local arg = tree[i + 1]
    local value = arg.name or arg.value
    -- Сборка команды
    local fmt = spaces.."%s = tonumber(%s) or 0"
    result = fmt:format(tree[i - 2].name, value)

  elseif name == "RANDOM" then
    offset = offset + 2

    -- Значение минима для рандома
    local arg_1 = tree[i + 1]
    local min = arg_1.name or arg_1.value
    -- Значение максимума для рандома
    local arg_2 = tree[i + 2]
    local max = arg_2.name or arg_2.value

    -- Сборка команды
    local fmt = spaces.."local %s = math.random(%s, %s)"
    result = fmt:format(tree[i - 2].name, min, max)
  end

  return result, offset
end

-- Сборка присваивания
local function generate_assign_expression(code, tree, index, variables)
  local offset = 1
  local spaces = string.rep(" ", space_to_if)

  local left = tree[index-1]    -- Переменная слева от знака присваивания
  local right = tree[index+1]   -- Выражение справа от знака присваивания

  local left_value = left.value or left.name
  local right_value = right.value or right.name
  local result = ""

  -- Обработка присваивания массиву
  if right.type == "get_array" then
    right_value = right.name..'['..right.value..']'
  end

  -- Обработка массивов для правого значения
  if right.type == "array" then
    right_value = right.array:gsub("%[(.+)%]", "{%1}")
  elseif right.type == "get_array" then
    right_value = right.name..'['..right.value..']'
  end

  -- Правое присваивание это команда
  if right.type == "command" then
    local command, _offset = generate_returned_command(tree, index+1)
    offset = offset + _offset
    result = result .. command
  elseif left.type == "variable" then
    -- Необъявленным переменным добавляется local
    if variables[left.name].declared then
      result = result .. spaces .. left_value .. " = " .. right_value
    else
      variables[left.name].declared = true
      result = result .. spaces .. "local " .. left_value .. " = " .. right_value
    end
  elseif left.type == "get_array" then
    result = result .. spaces .. left.name.. '['..left.value..']' .. " = " .. right_value
  end

  -- Если это массив, сразу выходим
  if right.type and right.type == "array" then
    table.insert(code, result)
    return offset
  end

  -- Если после выражения с присваиванием, есть арифметические выражения
  if tree[index+2] and tree[index+2].type == "arithmetic_expression" then
    while tree[index+offset+1] and tree[index+offset+1].type == "arithmetic_expression" do
      offset = offset + 1
      local operator = tree[index+offset].operator
      offset = offset + 1
      local operand = tree[index+offset].value or tree[index+offset].name
      result = result .. " " .. operator .. " " ..  operand
    end
  end

  table.insert(code, result)
  return offset
end

-- Сборка команд
--
-- generate PRINTL
local function generate_PRINTL(code, tree, i)
  local offset = 1

  -- Печатаемое значение
  local node = tree[i + offset]

  local value
  if node.type == "get_array" then
    -- Печать массива
    value = node.name..'['..node.value..']'
  else
    -- Печать переменной
    value = node.name or node.value
  end

  --
  local spaces = string.rep(" ", space_to_if)
  table.insert(code, spaces .. "print("..value..")")

  return offset
end

-- generate PRINT
local function generate_PRINT(code, tree, i)
  local offset = 1

  -- Печатаемое значение
  local node = tree[i + offset]

  local value
  if node.type == "get_array" then
    -- Печать массива
    value = node.name..'['..node.value..']'
  else
    -- Печать переменной
    value = node.name or node.value
  end

  --
  local spaces = string.rep(" ", space_to_if)
  table.insert(code, spaces .. "io.write(tostring("..value.."))")

  return offset
end

-- Сборка команд, которые не возвращают значения
--
local function generate_commands(code, tree, i)
  local offset = 1
  local spaces = string.rep(" ", space_to_if)

  local node = tree[i]
  if node.name == 'PRINTL' then
    offset = generate_PRINTL(code, tree, i)
  elseif node.name == 'PRINT' then
    offset = generate_PRINT(code, tree, i)
  elseif node.name == "GOTO" then
    table.insert(code, spaces.."goto "..node.label)
  end

  return offset
end

-- Сборка условий
--
local function generate_conditional_expression(code, tree, i)
  local offset = 1

  local spaces = string.rep(" ", space_to_if)
  space_to_if = space_to_if + 1

  local result = spaces.."if "
  result = result .. '('
  while tree[i+offset] and tree[i+offset].type ~= "then_branch" do
    local node = tree[i+offset]

    if node.type == "int" or node.type == "string" or node.type == "variable" then
      result = result .. (node.value or node.name)
    elseif node.type == "get_array" then
      result = result .. node.name.."["..node.value.."]"
    elseif node.type == "and_expression" then
      result = result .. ') and ('
    elseif node.type == "or_expression" then
      result = result .. ') or ('
    elseif node.type == "comparison_operator" then
      local op = node.operator
      if op == "!=" then
        op = "~="
      end
      result = result .. " "..op.." "
    end

    offset = offset + 1
  end
  result = result .. ')'
  result = result .. ' then'

  table.insert(code, result)
  return offset
end

local function generate_code(tree, variables)
  local code = {}

  local i = 1
  while i <= #tree do
    local node = tree[i]

    -- Обработка присваиваний
    if node.type == "assign_expression" then
      local offset = generate_assign_expression(code, tree, i, variables)
      i = i + offset

    -- Обработка команд
    elseif node.type == "command" then
      local offset = generate_commands(code, tree, i)
      i = i + offset

    -- Генерация условий
    elseif node.type == "conditional_expression" then
      local offset = generate_conditional_expression(code, tree, i)
      i = i + offset

    elseif node.type == "complete_condition_operator" then
      if node.operator == "ENDIF" then
        space_to_if = space_to_if - 1
        local spaces = string.rep(" ", space_to_if)
        table.insert(code, spaces.."end")
      end
      i = i + 1

    -- Установка меток
    elseif node.type == "label" then
      table.insert(code, node.name)
      i = i + 1

    else
      i = i + 1
    end
  end

  return code
end

return generate_code
