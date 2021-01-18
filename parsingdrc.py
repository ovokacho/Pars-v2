from pyparsing import *


def pasreDrcFile(File):
    drcString = File.read()
    outputFile = open('parseddrc.txt', 'w')
    
    keyName = Word(printables)
    params = Word(alphanums + "#$%&'()*+,-./:;<=>?@[\]^_`|~" + " " + "\n")
    paramsWord = Suppress('{') + params + Suppress('}')
    completeNote = keyName + paramsWord
    allNotes = OneOrMore(Group(completeNote))

    outputFile.write(str(allNotes.searchString(drcString)))
    a=allNotes.searchString(drcString)
    print a, type(a)
    File.close()
    return outputFile


#drcFile = open('calibre.drc', 'r')
drcFile = open('test.txt', 'r')
outputDRC = pasreDrcFile(drcFile)
outputDRC.close()
