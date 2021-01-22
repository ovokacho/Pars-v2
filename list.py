# -*- coding: utf-8 -*-
from pyparsing import *
from itertools import chain

l =[]
denspaths = []
lis = [['RPO.R.3', '@ Rule RPO.R.3: Partially non-siliced gate must be covered by MKR_ESD2\n        X = GATE CUT (RPO NOT FILTER_RPO.R.3)\n    X NOT MKR_esd2\n    '], ['R13.17',  '@ Rule 13.17 : Minimum POLY total density >= 0.15.DENSITY XALLPOL < 0.15 PRINT'], ['RPO.OL.1', '@ RPO.OL.1  RPO overlap of Gate if covered by ESD marker == 0.060 um\n      X = GATE_ESD AND MKR_esd2\n    INT X (RPO NOT FILTER_RPO.OL.1) < 0.060\n    '], ['R2.du15', '@ Rule 2.du15 : Min ACTIVE density by 1x1mm window >= 0.2. DENSITY XALLACT < 0.2 WINDOW 1000 1000 STEP 500 PRINT "./densWIN1_ACT1" BACKUP'], ['R2.du16',  '@ Rule 2.du16 : Min ACTIVE density across full chip >= 0.25. DENSITY XALLACT < 0.25  PRINT "./densTOT_ACT2"'], ['R13.12',  '@ Rule 13.12 : Minimum POLY total density >= 0.15.DENSITY XALLPOL < 0.15 PRINT "./densTOT_POLY1" "./densTOT_ACT3"'], ['R13.15',  '@ Rule 13.15 : Minimum POLY total density >= 0.15.DENSITY XALLPOL < 0.15 PRINT'], ['R13.16',  '@ Rule 13.16 : Minimum POLY total density >= 0.15.DENSITY XALLPOL < 0.15 PRINT']]

denspath = Word(printables + "./_", excludeChars='"')
paramsWord = Suppress('"') + denspath + Suppress('"')
        # completeNote = keyName + paramsWord
allNotes = OneOrMore(paramsWord)
#denspaths.extend(list(chain.from_iterable(allNotes.searchString(self.drcString).asList())))

for element in lis:
        if ("density" or "DENSITY") in element[1]:
                print(element[0], " - dens rule")
                l.append(element)
print (l)

for element in enumerate(l):
        denspaths.append([element[1][0]] + list( chain.from_iterable(paramsWord.searchString(element[1]).asList()))) # список [[имя, ]]

fix=[]
for el in enumerate(denspaths):
        if len(el[1])==1:
                fix.append(el[0])

for i in reversed(fix):
        denspaths.pop(i)

print(fix)

print("denspaths: ")
#denspaths = [x for x in denspaths if x]  #удаление пустых вложенных списков
print(denspaths)

# print (lis)
# a=[a+b for a in 'list' if a != 's' for b in 'soup' if b != 'u']
# print (a)
#
# l.append (23) #добавить в конец
# l.append (33)
# b = [24,67]
# l.extend (b) #добавить список в список
# l.insert(1, 566)  # добавить элемент по индексу
# l.remove (24) #Удалить первый попавшийся элемент с совппадающим значением
# l.pop (0) #Удалить и вернуть элемент списка с указанным индексом/последний если ()
# l.append (566)
# print (l.index (566)) #Возвращает индекс совпадающего элемента (первого?)
# print (l.count (566)) #Возвращает число совпадений
# l.sort()
# l.reverse()
# print(l)
# l.clear()
