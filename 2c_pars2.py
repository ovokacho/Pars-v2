import re

dictionary = {}

with open('test.txt', 'r') as fp:
    name = ""
    content = ""
    end_of_content = True
    for line in fp:
        if not end_of_content:
            if '}' in line:
                end_of_content = True
            else:
                dictionary[name] += line
            if re.match("[0-9a-zA-Z_.]+\s+{", line):
                name = line.split(" ")[0]
                content = line.split("{")[1].replace("{", "")
                dictionary[name] = content
            if '}' not in line:
                end_of_content = False

print(dictionary)
#print(dictionary['RI.AP.W.1'])
