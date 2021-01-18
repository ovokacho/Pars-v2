#!/grid/opfsh_tools/development/Anaconda3/bin/python3
# -*- coding: utf-8 -*-

import argparse
import getpass
import re
from pathlib import Path

import pymysql
from progress.bar import IncrementalBar


VERSION = '1.1'
HOST = 'aryabinin'
DATABASE = 'newOPFSHV3'


def searchRules(path):
    """Функция рекурсивного поиска правил"""

    def isTheRuleUnique(uniqueList, rule):
        """Функция проверки на уникальность (без пробелов)"""
        for item in uniqueList:
            if ''.join(item[1].split()) == ''.join(rule[1].split()) and item[0] == rule[0]:
                return False
        return True

    path = Path(path)
    try:
        text = path.read_text(encoding='latin1')
    except FileNotFoundError:
        msg = f'Отсутствует файл {str(path)}'
        msg = setTextColor("Red", msg)
        raise FileNotFoundError(msg)

    rulSearch = re.findall(r'\n\s*([^/\n]+?)\s*{\s*(.+?)\s+}', text, re.DOTALL)
    includeSearch = re.findall(r'^\s*include\s+(.+)', text, re.I | re.M)
    if includeSearch:
        for include in includeSearch:
            if '$' in include:
                newPath = re.sub(r"(\$.+?)/", str(path.parent.parent.parent) + '/', include)
                rulSearch += searchRules(newPath)
            else:
                rulSearch += searchRules(include)

    uniqueRulSearch = []
    bar = IncrementalBar(f'Проверка правил {path.name}', max=len(rulSearch), suffix='%(percent)d%%')
    for rule in rulSearch:
        if isTheRuleUnique(uniqueRulSearch, rule):
            uniqueRulSearch.append(rule)
        bar.next()
    bar.finish()
    return uniqueRulSearch


def setTextColor(color, text):
    if color == 'Green':
        return "\033[1m\033[32m{}\033[0m".format(text)
    elif color == 'Red':
        return "\033[1m\033[31m{}\033[0m".format(text)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Adds rulechecks, associated with given pdk id, to database')
    parser.add_argument("-v", "--version", action="version", version=VERSION)
    parser.add_argument('pdkId', metavar='PDK_ID', type=str, help='pdk id')
    args = parser.parse_args()
    pdkId = args.pdkId

    user = getpass.getuser()
    connection = None
    while connection is None:
        password = getpass.getpass('Пароль для подключения к БД: ')
        try:
            connection = pymysql.connect(HOST, user, password, DATABASE, charset='utf8')
        except pymysql.err.OperationalError as ex:
            print(ex)
    cursor = connection.cursor()

    # Проверка существования PDK
    query = f'SELECT DISTINCT 1 FROM Pdk WHERE Id = {pdkId}'
    cursor.execute(query)
    if not cursor.fetchone():
        msg = f'PDK c идентификатором {pdkId} не зарегистрирован в БД'
        msg = setTextColor("Red", msg)
        raise Exception(msg)

    # Проверка наличия правил, связанных с указанным PDK
    query = f'SELECT DISTINCT 1 FROM RuleCheck WHERE PdkId = {pdkId}'
    cursor.execute(query)
    if cursor.fetchone():
        msg = 'DRC-проверки для указанного PDK уже занесены в систему'
        msg = setTextColor("Red", msg)
        raise Exception(msg)

    # Получение информации о деках
    query = f'SELECT DeckPath FROM PdkOperation WHERE PdkId = {pdkId} AND TypeId = 1'
    cursor.execute(query)
    deckPaths = cursor.fetchall()
    for path in deckPaths:
        path = path[0]
        rules = searchRules(path)
        for rule in rules:
            ruleName = rule[0]
            print("Adding rule: " + ruleName)
            query = f'INSERT INTO RuleCheck (PdkId, Name, Code) VALUES ({str(pdkId)}, %s, %s)'
            cursor.execute(query, rule)

    connection.commit()
    msg = setTextColor("Green", "Execution completed!")
    print(msg)

