class Person:
    name = "Ivan"
    age = 10

    def __init__(self, name, age):
        self.name = name
        self.age = age

    def set(self, name, age):
        self.name = name
        self.age = age


class Student (Person):
    course = 1

    def set(self, name, age, course):
        self.name = name
        self.age = age
        self.course = course


igor = Student("Igor", 19)
igor.set("Igor", 19, 4)
print (igor.name + " " + str(igor.age) + " " + str(igor.course))
vlad = Person("Влад", 25)
print (vlad.name + " " + str(vlad.age))
ivan = Person("Иван", 23)
print (ivan.name + " " + str(ivan.age))



