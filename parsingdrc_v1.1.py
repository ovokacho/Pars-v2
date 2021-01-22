# -*- coding: utf-8 -*-
from pyparsing import *
from itertools import chain


class DrcFileParser:
    def __init__(self, file):
        self.pathslist = []
        self.allRuleList = []
        self.densityRulesList = []
        self.densityPathsList = []
        self.search_includes(file)
        self.search_density_rules()
        self.search_density_paths()

    #Функция поиска прикрепленных к исходному файлу ссылок. В ней же проводится поиск правил по исходному и всем вложенным файлам.
    def search_includes(self, file):
        self.initfile = file
        self.drcString = self.initfile.read()
        self.initfile.close()
        self.search_drc_rules() #Поиск правил в изначально указанном файле(с которым создавался класс)
        keyinclude = "INCLUDE"
        includepath = Word(alphanums + "$/.")
        fullpath = Suppress(keyinclude + ' ') + includepath
        allpaths = OneOrMore(fullpath)
        self.pathslist.extend(list(chain.from_iterable(allpaths.searchString(self.drcString).asList())))

        for i in self.pathslist:
                if i == 'readed': continue
                bufferi = i
                print('pathlist: ', self.pathslist)
                indexOfReadedInclude = self.pathslist.index(i)
                self.pathslist[indexOfReadedInclude] = 'readed'
                try:
                    includedFile = open(bufferi, 'r')
                except IOError:
                    print("file " + str(bufferi) + " didn't exist")
                else:
                    print("all fine")
                    self.search_includes(includedFile) #Рекурсивный вызов функции с вложенным файлом как новым аргументом

    def search_drc_rules(self):
        keyName = Word(printables)
        params = Word(printables + " " + 'μ' + "\n", excludeChars='{}')
        paramsWord = Suppress('{') + params + Suppress('}')
        allNotes = OneOrMore(Group(keyName + Optional(" ") + paramsWord))
        self.allRuleList.extend(list(chain.from_iterable(allNotes.searchString(self.drcString).asList())))

    def search_density_rules(self):
        for rule in self.allRuleList:
            if ("density" or "DENSITY") in rule[1]:
                self.densityRulesList.append(rule)

    def search_density_paths(self):
        denspath = Word(printables + "./_", excludeChars='"')
        denspathfull = Suppress('"') + denspath + Suppress('"')

        for rule in enumerate(self.densityRulesList):
            self.densityPathsList.append([rule[1][0]] + list(
                chain.from_iterable(denspathfull.searchString(rule[1]).asList())))  # список [[имя, ]]

        # Удаление пустых полей
        fix = []
        for i in enumerate(self.densityPathsList):
            if len(i[1]) == 1:
                fix.append(i[0])

        for i in reversed(fix):
            self.densityPathsList.pop(i)

    def get_parse_results(self):
        return self.allRuleList

    def get_density_rules(self):
        return self.densityRulesList

    def get_density_paths_list(self):
        return self.densityPathsList


if __name__ == "__main__":
    drcFile = open('calibretest.drc', 'r')
    drcTest = DrcFileParser(drcFile)

    Presults = drcTest.get_parse_results()
    DensityRules = drcTest.get_density_rules()
    DensityPaths = drcTest.get_density_paths_list()

    Otuputfile = open('outputrules.txt', 'w')
    print >> Otuputfile, len(Presults)
    print >> Otuputfile
    for element in Presults:
        print >>Otuputfile, element
        print >>Otuputfile
    Otuputfile.close()

    Otuputfile1 = open('outputdens.txt', 'w')
    print >> Otuputfile1, len(DensityRules)
    print >> Otuputfile1
    for element1 in DensityRules:
        print >> Otuputfile1, element1
        print >> Otuputfile1
    Otuputfile1.close()

    Otuputfiledenspaths = open('outputdenspaths.txt', 'w')
    print >> Otuputfiledenspaths, len(DensityPaths)
    print >> Otuputfiledenspaths
    for element2 in DensityPaths:
        print >> Otuputfiledenspaths, element2
        print >> Otuputfiledenspaths
    Otuputfiledenspaths.close()

    #print ('parse results: ', drcTest.get_parse_results())
    drcFile.close()

