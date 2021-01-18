# -*- coding: utf-8 -*-
#from pyparsing import *

#print (f.read())
#f.close ()
#for line in f:
    #print(line)
#filename = raw_input('Укажите файл: ')
#file1 = open(filename, 'a')
#print(file1.read())
#print('В файле ' + str(len(file1.read())) + ' символов')
#file1.write(raw_input('Введите в файл: '))

with open(raw_input('Укажите файл для копирования: '), 'r') as f:
    f2name = 'backup ' + str(f)
    f2 = open(f2name, 'w')

    f2.write(f.read())
    f2.close()
   


