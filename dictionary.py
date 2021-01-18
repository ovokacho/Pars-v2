# -*- coding: utf-8 -*-
d = {'key1' : 1, 'key2' : "word2"}
print (d['key1'])
print (d)
d1 = dict (short='dict', longer='dictionary')
d1['short']=222
print(d1)
d2 = dict ([('key1','word1'),('key2','word2'),(53,72)])
print (d2)
d3 = dict.fromkeys (['a','b','c'],1)
print (d3)
d4={a:a**2 for a in range(7)}
print(d4)

person = {'name' : {'last_name': 'Иванов', 'first_name': 'Иван',
'middle_name': 'Иванович'}, 'address': ['г. Андрюшки',
'ул. Васильковская д. 23б', 'кв.12'],
'phone': {'home_phone': '34-67-12', 'mobile_phone': '8-564-345-23-65',
          'mobile_phone_2': 'Нет'}}

person['name']['first_name']='Чорт'
#print (person['name']['first_name'])
#print (person['address'][1])
#print (person['phone']['mobile_phone_2'])
print(person.keys())
#print(person.values())
person.clear()

