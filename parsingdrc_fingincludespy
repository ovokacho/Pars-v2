from pyparsing import *
from itertools import chain

def pasreDrcFile(File):
    drcString = File.read()
    #outputFile = open('parseddrc.txt', 'w')
    
    keyName = Word(printables)
    params = Word(alphanums + "#$%&'()*+,-./:;<=>?@[\]^_`|~" + " " + "\n")
    paramsWord = Suppress('{') + params + Suppress('}')
    completeNote = keyName + paramsWord
    keyinclude = "INCLUDE" # + ' ' + alphanums + "$/.")
    adr = Word(alphanums + "$/.")
    fulladr = Suppress(keyinclude + ' ') + adr
    allNotes = OneOrMore(fulladr)

    #outputFile.write(str(allNotes.searchString(drcString)))
    a=list(chain.from_iterable(allNotes.searchString(drcString).asList()))
    #print (drcString)
    print (a)
    File.close()



#drcFile = open('calibre.drc', 'r')
drcFile = open('test1.txt', 'r')
outputDRC = pasreDrcFile(drcFile)

