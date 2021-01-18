import re

dictionary = {}

with open('test.txt', 'r') as fp:
    for line in fp:
        if re.match("[0-9a-zA-Z_.]+\s+{", line):
            name = line.split(" ")[0]
            content = line.split("{")[1].replace("{", "").strip()
            dictionary[name] = content

print(dictionary)
print(dictionary['RI.AP.W.1'])
