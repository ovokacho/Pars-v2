from pyparsing import *

num1 = raw_input("Введите имя")

if num1 == "1":
    print ("true\n")
    print ("22")
elif num1 == "h":
    print ("char")
else:
    print("else")

name = raw_input()
A='Yes' if name != "Test" else 'No'
print (A)
