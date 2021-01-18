# -*- coding: utf-8 -*-
from pyparsing import *
from itertools import chain


class DrcFileParser:
    def __init__(self, file):
        self.pathslist = []
        self.allRuleList = []
        self.search_includes(file)

    def search_includes(self, file):
        self.initfile = file
        self.drcString = self.initfile.read()

        self.initfile.close()

        self.search_drc_rules()
        keyinclude = "INCLUDE"
        includepath = Word(alphanums + "$/.")
        fullpath = Suppress(keyinclude + ' ') + includepath
        allpaths = OneOrMore(fullpath)
        self.pathslist.extend(list(chain.from_iterable(allpaths.searchString(self.drcString).asList())))
        #print (list(chain.from_iterable(allpaths.searchString(drcString).asList())))
        for i in self.pathslist:
                if i == 'readed': continue
                bufferi = i
                print('pathlist: ', self.pathslist)
                indexOfReadedInclude = self.pathslist.index(i)
                self.pathslist[indexOfReadedInclude] = 'readed'
                try:
                    testFile = open(bufferi, 'r')
                except IOError:
                    print("file " + str(bufferi) + " didn't exist")
                else:
                    print("all fine")
                    self.search_includes(testFile)

    def get_parse_results(self):
        return self.allRuleList

    def search_drc_rules(self):
        keyName = Word(printables)
        params = Word(printables + " " + 'μ' + "\n", excludeChars='{}')
        paramsWord = Suppress('{') + params + Suppress('}')
        # completeNote = keyName + paramsWord
        allNotes = OneOrMore(Group(keyName + Optional(" ") + paramsWord))
        self.allRuleList.extend(list(chain.from_iterable(allNotes.searchString(self.drcString).asList())))


def pasreDrcFile(File):
    drcString = File.read()
    outputFile = open('parseddrc.txt', 'w')

    keyName = Word(printables)
    params = Word(alphanums + "#$%&'()*+,-./:;<=>?@[\]^_`|~" + " " + "\n")
    paramsWord = Suppress('{') + params + Suppress('}')
    completeNote = keyName + paramsWord
    allNotes = OneOrMore(Group(keyName + paramsWord))

    #outputFile.write(str(allNotes.searchString(drcString)))
    
    a = allNotes.searchString(drcString).asList()
    b = list(chain.from_iterable(a))
    outputFile.write(str(b))
    #completeNote.runTests(drcString)
    #print (a)
    print (b[11][1])
    #a.pprint()
    #help(a)
    #print(len(a[1]))
    #print(a[0][1][0])
    #print (list(a))

    return outputFile


if __name__ == "__main__":
    drcFile = open('calibretest.drc', 'r')
    drcTest = DrcFileParser(drcFile)
    Presults = drcTest.get_parse_results()

    Otuputfile = open('output.txt', 'w')
    for element in Presults:
        print >>Otuputfile, element
        print >>Otuputfile
    Otuputfile.close()
    #print ('parse results: ', drcTest.get_parse_results())
    drcFile.close()

