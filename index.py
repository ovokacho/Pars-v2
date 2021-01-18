# -*- coding: utf-8 -*-
l =[1, 56, 'x', 34]
print(l[-1]) #последний элемент
i=0
while i<4:
    print(l[i])
    i+=1

#item[START:STOP:STEP]
print (l[::2])
print (l[:2:])
print (l[2::])

#кортежи(весят меньше списков). нельзя менять
a=(43,55,67,45.66, 'd')
b=[43,55,67,45.66, 'd']

#Будет ошибка
#a[0]=11

print (a.__sizeof__ ())
print (b.__sizeof__ ())

a = tuple ("hello world") #Разбить на элементы кортежа
print (a)
