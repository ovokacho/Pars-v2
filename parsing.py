from pyparsing import *

keyName = Word(printables)
params = Word(alphanums + "#$%&'()*+,-./:;<=>?@[\]^_`|~" + " " + "\n")
paramsWord = Suppress('{') + params + Suppress('}')
completeNote = keyName + paramsWord
allNotes = OneOrMore(Group(completeNote))

drcFile = open('test.txt', 'r')
#drcFile = open('calibre.drc', 'r')
drcString = drcFile.read()
outputFile = open('parseddrc.txt', 'w')
#print (str(allNotes.searchString(drcString)))
outputFile.write(str(allNotes.searchString(drcString)))
outputFile.close()
drcFile.close()
#print(drcFile.read())

def pasreDrcFile(File):
    
