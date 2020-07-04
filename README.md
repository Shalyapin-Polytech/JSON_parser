# JSON-парсер
Скрипт, позволяющий парсить [JSON-файл](https://www.json.org/json-ru.html) и сохранять данные в таблице.
## Подключение
Скрипт подключается кодом
```lua
local parse = require("JSON_parser").parse
```

## Использование
```lua
local result = parse(file_name)
```
`file_name` — имя JSON-файла.

# Collection
Позволяет создать таблицу с одним разрешенным типом ключей, попытка добавления с ключом другого типа возвращает ошибку.

Встроенные функции:
* Оператор `#` возвращает количество элементов с разрешенным ключом;
* `get_type()` возвращает заданный тип.

## Создание конструктора
```lua
local Constructor = Collection.implement(type)
```
где `type` — разрешенный тип.

## Пример
```lua
local Map = Collection.implement("string")
local map = Map{
    ["foo1"] = "bar1",
    ["foo2"] = "bar2"
}

print(#map) --> 2
print(map.get_type()) --> string
map[true] = true --> ошибка
```

## Использование
В парсере используются 2 вида таблиц:
* `Array` — массив, разрешены только числовые ключи; используется при чтении JSON-массивов:
```json
["bar1", "bar2"]
```
* `Map` — ассоциированный массив, разрешены только строковые ключи; используется при чтении JSON-объектов:
```json
{"foo1": "bar1", "foo2": "bar2"}
```

# Тесты
```lua
asserts.assert_equals(expected, actual)
```
Производит сравнение `expected == actual`.

```lua
asserts.assert_tables_equals(expected, actual)
```
Производит сравнение сначала по типам (тип задается при создании конструктора), затем по размеру (с помощью `#`), затем прохождением по всем элементам таблицы (с помощью `pairs()`), для элементов-таблиц рекурсивно вызывается эта же функция, для остальных — `assert_equals()`.

```lua
asserts.assert_thrown(f)
```
Проверяет, пробрасывает ли функция `f()` ошибку.

```lua
tests.do_tests(tests)
```
Параметр `tests` — таблица с тестами, каждый тест должнен представлять собой функцию.

## Пример
```lua
local parse = require("JSON_parser").parse
local asserts = require("tests.core").asserts
local do_tests =  require("tests.core").tests.do_tests

local tests = {
    test1 = function ()
        asserts.assert_tables_equals(correct_result, parse("correct_file.json"))
    end,
    
    test2 = function ()
        asserts.assert_thrown(
            function () parse("incorrect_file.json") end
        )
    end
}

do_tests(tests)
```
