# -*- coding: utf-8 -*-
#список без повторений, выводятся в случайно порядке
#b = set ("hello")
#a = {i**2 for i in range (10)}
a = {i**2 for i in range(10)}
print(type(a))
print(a)
b = frozenset ("qweqwe")
a.add(1)
#b.add(2)   -  ошибка
print(a)
print(b)

s=['r', 'a', 'n', 'a', 'n', 'd']
print(s)
print(set(s))
print(len(s))
x='r'
print(x in s)
s1=['b', 't', 's']


#истина, если s и s1 не имеют общих элементов
#print(s.isdisjoint(s1))      не в питоне 2?
p={22,33,55,5.5}
p1={22,33,5.5,55}
print (p==p1)
p.discard (22) #удаляет элемент если он есть, иначе ничего и без ошибки
print (p)
