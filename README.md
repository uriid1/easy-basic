# easy-basic
У меня было 4-5 часов свободного времени, я сел писать интерпретатора BrinFu\*k на Lua, а получился компилятор(скорее даже транспайлер) для вымышленного языка :D

# Примеры
## Запуск
```bash
chmod +x eb
./eb tests/game.eb
```
Или
```bash
chmod +x eb
lua eb tests/game.eb
```

# Описание языка
## Переменные
Их всего два типа `INT` и `STRING` </br>
Дробных чисел нет. </br>
Строки только через двойные кавычки ""
```basic
# Это комментарий
INT my_number = 100
STRING name = "uriid1"
```

## Математические операции
```basic
INT a = 10 * 2
a = a / 2
a = a + 2
a = a - 2
```

## Условия
```basic
# Операторы
# ==
# >=
# <=
# !=

INT x = 100
IF x < 200 THEN
  PRINTL "x меньше 200"
ENDIF
IF x != 100 THEN
  PRINTL "`x` не равен 100"
ENDIF

# Можно вложенные условия
INT y = 50
IF x == 100 THEN
  IF y == 50 THEN
    PRINTL "`x` равен 100, а `y` равен 50"
  ENDIF
ENDIF

# Можно и так
IF x != y AND y == 50 OR x > 5 THEN
  IF 0 != -1 OR -1 == 0 THEN
    PRINTL "Условие истинно?"
  ENDIF
ENDIF
```

## Циклы
```basic
# Цикл можно сделать через оператор GOTO

INT i = 0
::label_loop::
IF i < 5 THEN
  PRINTL i
  i = i + 1
  GOTO label_loop
ENDIF
```

## Доступные команды
```basic
# Считывание с клавиатуры
STRING inputs = READ "Введите текст: "

# Перевод строки в число
inputs = TONUMBER inputs

# Проверка, что удалось перевести
IF inputs == 0 THEN
  PRINTL "Не удалось считать значения, либо вы ввели ноль :)"
ENDIF

# Случайное значение от min до max
INT rnd_number = RANDOM 1 100

# Печатает строку без переноса строк
PRINT "Строка"

# Печатает строку с переносом строки \n
PRINTL "Строка с \\n"
```
