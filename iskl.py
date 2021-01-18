# -*- coding: utf-8 -*-
x = int (input())
y = int (input())

try:
    res=x/y
except ZeroDivisionError:
    print("деление на 0")
    res=0
print(res)



try:
    z = int (input())
except NameError:
    print("введено не число")
    z=0
print(z)

try:
    c = int (input())
except NameError:
    print("введено не число")
    c=0
else:
    print("ошибки нет")
finally:
    print("выполнится всегда")
print(c)
