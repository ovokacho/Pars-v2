# -*- coding: utf-8 -*-
def func(x,a,b=2):
    res = x + b
    return res


print (func(23,7,6))

def slovar (**args): #произвольно число аргументов??? *-кортеж **- словарь??
    return args


print (slovar(a=23,n=55,j=66))

add = lambda x,y: x+y # однострочная функция
print (add(1,2))

print ((lambda x,y: x+y)(2,6))
