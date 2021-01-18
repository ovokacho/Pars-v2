from pyparsing import *
from itertools import chain


class DrcFileParser:

    def __init__(self, file):
        self.file = file
        self.drcString = file.read()
        keyinclude = Word(Suppress('INCLUDE ') + alphanums + "$/.")
        allNotes = keyinclude
        self.drcList = list(chain.from_iterable(allNotes.searchString(self.drcString).asList()))

        # keyName = Word(printables)
        # params = Word(alphanums + "#$%&'()*+,-.:;<=>?@[]^_`|~" + " " + "\n")
        # paramsWord = Suppress('{') + params + Suppress('}')
        # completeNote = keyName + paramsWord
        # allNotes = OneOrMore(Group(keyName + paramsWord))
        # self.drcList = list(chain.from_iterable(allNotes.searchString(self.drcString).asList()))

    def get_parse_results(self):
        return self.drcList


if __name__ == "__main__":
    #drcFile = open('calibre.drc', 'r')
    drcFile = open('test1.txt', 'r')
    drcTest = DrcFileParser(drcFile)

    print('parse results: ', drcTest.get_parse_results())
    drcFile.close()

