# -*- coding: utf-8 -*-
l =[]
lis = [1, 56, 'x', 34, 2.34, ['s','t', 'r','i','n','g']]
print (lis)
a=[a+b for a in 'list' if a != 's' for b in 'soup' if b != 'u']
print (a)

l.append (23) #добавить в конец
l.append (33)
b = [24,67]
l.extend (b) #добавить список в список
l.insert(1, 566)  # добавить элемент по индексу
l.remove (24) #Удалить первый попавшийся элемент с совппадающим значением
l.pop (0) #Удалить и вернуть элемент списка с указанным индексом/последний если ()
l.append (566) 
print (l.index (566)) #Возвращает индекс совпадающего элемента (первого?)
print (l.count (566)) #Возвращает число совпадений
l.sort()
l.reverse()
print(l)
l.clear()