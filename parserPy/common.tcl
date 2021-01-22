#!/grid/tools/arch/tcl/8.5.9/bin/tclsh

# Прототипы ->
#
# Функции общего назначения:
# proc getPreviousTzList {tzList currentTz} {...}
# proc compareTails {path1 path2} {...}
# proc elapsedTime {time1 time2 {format "%02dд. %02dч. %02dм. %02dc."}} {...}
# proc getArgValue {key} {...}
# proc getFileContent {file} {...}
# proc getFileHash {file {algorithm "md5"}} {...}
# proc getProgress {min max length index} {...}
# proc getStringHash {string {algorithm "md5"}} {...}
# proc getSvnFileContent {file} {...}
# proc getTopologyName {path} {...}
# proc land {list1 list2 {mode "exact"}} {...}
# proc lnot {list1 list2 {mode "exact"}} {...}
# proc mm2nm {mm} {...}
# proc mm2um {mm} {...}
# proc nm2mm {nm} {...}
# proc nm2um {nm} {...}
# proc putsToFile {file string {mode "a"} {nonewline 0}} {...}
# proc recursiveGlob {dir} {...}
# proc svnUrlExists {url} {...}
# proc trimZeros {value} {...}
# proc um2mm {um} {...}
# proc um2nm {um} {...}
# proc setCalibreVersion {calibreVersion} {...}
#
# Функции для работы с файлами в ini-формате
# proc getConfigGroups {content} {...}
# proc getConfigKeys {content} {...}
# proc getConfigValue {content key} {...}
#
# Функции для валидации файлов
# proc checkFrameConfigContent {content} {...}
# proc checkDataConfigContent {content} {...}
# proc checkOrderContent {content} {...}

# Функции для работы с топологией (интерпретатор calibrewb)
# proc bboxSref {sref cellBbox {marginX 0} {marginY 0}} {...}
# proc getCrossList {polygonList testPolygon} {...}

# Функции, специфичные для mask-flow
# proc emitSignal {type value} {...}
# proc getStageResults {logFile} {...}
# proc matchCount {file pattern {mode "word"}} {...}
# proc putsToLog {logFile entry {mode "a"} {nonewline 0}} {...}
# proc relativePath {path} {...}

# Функции общего назначения ##########################################################################################################################

# Возвращает список предыдущих версий TZ относительно текущей версии TZ
#
# Аргументы:
# tzList - список версий TZ
# currentTz - текущая версия TZ
#
# Возвращаемое значение:
# Список предыдущих версий TZ (не включая текущее)
proc getPreviousTzList {tzList currentTz} {
    set previousTzList [list]
    foreach entry $tzList {
        if {[regexp "^TZ(\[1-9\]\\d*|0)_(\[1-9\]\\d*|0)/?$" $entry]} {
            lappend previousTzList [string trimright $entry "/"]
        }
    }
    if {[lsearch $previousTzList $currentTz] == -1} {
        lappend previousTzList $currentTz
    }
    set previousTzList [lsort -dictionary -unique $previousTzList]
    set currentTzIndex [lsearch $previousTzList $currentTz]
    set previousTzList [lreplace $previousTzList $currentTzIndex [expr [llength $previousTzList] - 1]]
    return $previousTzList
}

# Выполняет лексикографическое сравнение путей, используя только конечный элемент пути
#
# Аргументы:
# path1 - первый путь
# path2 - второй путь
#
# Возвращаемое значение:
# -1, если конечный элемент первого пути лексикографически меньше конечного элемента второго пути
#  1, если конечный элемент первого пути лексикографически больше конечного элемента второго пути
#  0, если конечный элемент первого пути лексикографически равен конечному элементу второго пути
#
# Описание:
# Основное предназначение - использование во встроенной функции сортировки
proc compareTails {path1 path2} {
    return [string compare [file tail $path1] [file tail $path2]]
}

# Возвращает разницу между двумя временными точками в заданном формате
#
# Аргументы:
# time1 - первая временная точка (в секундах)
# time2 - вторая временная точка (в секундах)
# format - строка, задающая формат возвращаемого значения и содержащая четыре позиции для размещения количества дней, часов, минут и секунд (по умолчанию "%02dд. %02dч. %02dм. %02dc.")
#
# Возвращаемое значение:
# строка заданного формата, содержащая информацию о количестве дней, часов, минут и секунд между заданными временными точками
proc elapsedTime {time1 time2 {format "%02dд. %02dч. %02dм. %02dc."}} {
    if {$time1 < $time2} {
        set start $time1
        set end $time2
    } else {
        set start $time2
        set end $time1
    }
    set total_seconds [expr $end - $start]
    set days [expr int(($total_seconds)/86400)]
    set hours [expr int(($total_seconds % 86400)/3600)]
    set minutes [expr int(($total_seconds % 3600)/60)]
    set seconds [expr int(($total_seconds % 60))]
    return [format $format $days $hours $minutes $seconds]
}

# Возвращает значение аргумента командной строки
# 
# Аргументы:
# key - аргумент командной строки (опция)
#
# Возвращаемое значение:
# список аргументов командной строки, соответствующих заданному (все а до следующей опции, либо до аргумента "--")
# пустой список, в случае отсутствии аргумента либо его значений
proc getArgValue {key} {
    global argv
    set value [list]
    for {set i 0} {$i < [llength $argv]} {incr i} {
        if {[lindex $argv $i] == $key} {
            for {set j [expr $i + 1]} {$j < [llength $argv]} {incr j} {
                if {![regexp {^\-+\S*$} [lindex $argv $j]]} {
                    lappend value [lindex $argv $j]
                } else {
                    break
                }
            }
        }
    }
    return $value
}

# Возвращает содержимое текстового файла
#
# Аргументы:
# file - путь к файлу
#
# Возвращаемое значение:
# строка с содержимым файла 
# пустая строка в случае ошибки или если файл пуст
proc getFileContent {file} {
    set content ""
    catch {
        set channel [open $file]
        set content [read $channel]
        close $channel
    }
    return $content
}

# Вычисляет контрольную сумму файла с помощью заданного алгоритма
# 
# Аргументы:
# file - путь к файлу в файловой системе или в репозитории SVN
# algorithm - алгоритм для вычисления контрольной суммы (по умолчанию md5)
#
# Возвращаемое значение:
# Строка, содержащая контрольную сумму файла либо пустая строка в случае ошибки
#
# Зависимости:
# svnUrlExists
#
# TODO: дописать вычисление контрольной суммы с применением других алгоритмов
proc getFileHash {file {algorithm "md5"}} {
    set hash ""    
    switch $algorithm {
        "md5" {
            catch {
                if {[file exists $file]} {
                    set hash [lindex [exec md5sum $file] 0] 
                } elseif {[svnUrlExists $file]} {
                    set tmpFile [exec mktemp]
                    catch {
                        exec svn export --force $file $tmpFile
                        set hash [lindex [exec md5sum $tmpFile] 0]
                    }
                    file delete $tmpFile
                }
            }
        }
    }
    return $hash
}

# Возвращает значение прогресса после обработки элемента списка
#
# Аргументы
# min - минимальное значение прогресса
# max - максимальное значение прогресса
# length - длина списка
# index - индекс обработанного элемента (нумерация индексов с нуля)
#
# Возвращаемое значение:
# значение прогресса после обработки элемента списка с указанным индексом
proc getProgress {min max length index} {
    return [lindex [split [expr $min + double($index + 1) / $length * ($max - $min)] "."] 0]
}

# Вычисляет контрольную сумму строки с помощью заданного алгоритма
# 
# Аргументы:
# string - строка, для которой необходимо вычислить контрольную сумму
# algorithm - алгоритм для вычисления контрольной суммы (по умолчанию md5)
#
# Возвращаемое значение:
# Строка с контрольной суммой либо пустая строка в случае ошибки
#
# TODO: дописать вычисление контрольной суммы с применением других алгоритмов
proc getStringHash {string {algorithm "md5"}} {
    set hash ""    
    switch $algorithm {
        "md5" {
            catch {
                set tmpFile [exec mktemp]
                catch {
                    set tmpChannel [open $tmpFile w]
                    puts $tmpChannel $string
                    close $tmpChannel
                    set hash [lindex [exec md5sum $tmpFile] 0]
                }
                file delete $tmpFile
            }
        }
    }
    return $hash
}

# Возвращает содержимое текстового файла в SVN
#
# Аргументы:
# file - путь к файлу
#
# Возвращаемое значение:
# строка с содержимым файла 
# пустая строка в случае ошибки или если файл пуст
proc getSvnFileContent {file} {
    set command "exec svn cat $file"
    if {![catch {eval $command} fid]} {
        return $fid
    }
    return ""
}

# Возвращает название топологического файла без расширения
#
# Аргументы:
# path - путь к топологическому файлу
#
# Возвращаемое значение:
# Название топологического файла без расширения
#
# Описание:
# Функция обрезает следующие расширения файлов: oas, oas.gz, gds, gds.
# Если файл имеет другое расширение или не имеет его вообще - возвращается полное имя файла
proc getTopologyName {path} {
    return [regsub {\.(oas|gds|oas\.gz|gds\.gz)$} [file tail $path] ""]
}

# Возвращает элементы первого списка, которые пристутствуют во втором списке (пересечение списков)
#
# Аргументы:
# mode - режим работы: "exact" - точное совпадение (по умолчанию), "glob" - совпадение по glob-шаблону
#
# Возвращаемое значение:
# список элементов первого списка, которые пристутствуют во втором списке
proc land {list1 list2 {mode "exact"}} {
    set elements [list]
    if {$mode == "glob"} {
        foreach element1 $list1 {
            set match 0
            foreach element2 $list2 {
                if {[string match $element2 $element1] || [string match $element1 $element2]} {
                    set match 1
                    break
                }
            }
            if {$match} {
                lappend elements $element1
            }
        }
    } else {
        foreach element1 $list1 {
            if {[lsearch $list2 $element1] != -1} {
                lappend elements $element1
            }
        }
    }
    return $elements
}

# Возвращает элементы первого списка, которые отсутствуют во втором списке (вычитание списков)
#
# Аргументы:
# mode - режим работы: "exact" - точное совпадение (по умолчанию), "glob" - совпадение по glob-шаблону
#
# Возвращаемое значение:
# список элементов первого списка, которые отсутствуют во втором списке
proc lnot {list1 list2 {mode "exact"}} {
    set elements [list]
    if {$mode == "glob"} {
        foreach element1 $list1 {
            set match 0
            foreach element2 $list2 {
                if {[string match $element2 $element1] || [string match $element1 $element2]} {
                    set match 1
                    break
                }
            }
            if {!$match} {
                lappend elements $element1
            }
        }
    } else {
        foreach element1 $list1 {
            if {[lsearch $list2 $element1] == -1} {
                lappend elements $element1
            }
        }
    }
    return $elements
}

# Конвертирует значение в миллиметрах в нанометры
#
# Аргументы:
# mm - значение в миллиметрах
#
# Возвращаемое значение:
# Значение в нанометрах либо пустая строка вслучае ошибки
#
# Зависимости:
# trimZeros
proc mm2nm {mm} {
    if {![catch {eval set nm [expr $mm * 1000000]} error]} {
        return [trimZeros $nm]
    }
    return ""
}

# Конвертирует значение в миллиметрах в микрометры
#
# Аргументы:
# mm - значение в миллиметрах
#
# Возвращаемое значение:
# Значение в микрометрах либо пустая строка вслучае ошибки
#
# Зависимости:
# trimZeros
proc mm2um {mm} {
    if {![catch {eval set um [expr $mm * 1000]} error]} {
        return [trimZeros $um]
    }
    return ""
}

# Конвертирует значение в нанометрах в миллиметры
#
# Аргументы:
# nm - значение в нанометрах
#
# Возвращаемое значение:
# Значение в миллиметрах либо пустая строка вслучае ошибки
#
# Зависимости:
# trimZeros
proc nm2mm {nm} {
    if {![catch {eval set mm [expr $nm / 1000000.0]} error]} {
        return [trimZeros $mm]
    }
    return ""
}

# Конвертирует значение в нанометрах в микрометры
#
# Аргументы:
# nm - значение в нанометрах
#
# Возвращаемое значение:
# Значение в микрометрах либо пустая строка вслучае ошибки
#
# Зависимости:
# trimZeros
proc nm2um {nm} {
    if {![catch {eval set um [expr $nm / 1000.0]} error]} {
        return [trimZeros $um]
    }
    return ""
}

# Записывает строку в файл
# 
# Аргументы:
# file - файл, в который необходимо осуществить запись
# string - строка для записи в файл
# mode - режим записи:
#        a - добавление строки с сохранением содержимого файла (по умолчанию)
#        w - добавление строки с удалением содержимого файла
# nonewline - режим переноса строки:
#             1 - запись без переноса строки
#             0 - запись с переносом строки (по умолчанию)
#
# Возвращаемое значение:
# 1 - в случае успешной записи, 0 в противном случае
proc putsToFile {file string {mode "a"} {nonewline 0}} {
    if {[catch {
        if {$mode == "w"} {
            set channel [open $file w]
        } else {
            set channel [open $file a]
        }
        if {$nonewline} {
            puts -nonewline $channel $string
        } else {
            puts $channel $string
        }
        close $channel
    }]} {
        return 0
    } else {
        return 1
    }
}

# Возвращает список файлов и директорий, содержащихся в указанной директории (рекурсивно)
#
# Аргументы:
# dir - путь к директории
#
# Возвращаемое значение:
#  Список файлов и директорий, содержащихся в указанной директории (рекурсивно), если директория не пуста,
#  либо пустой список в противном случае или в случае ошибки
proc recursiveGlob {dir} {
    set entries [list]
    catch {
        foreach entry [glob -nocomplain -directory $dir "*"] {
            lappend entries $entry
            if {[file isdirectory $entry]} {
                foreach subEntry [recursiveGlob $entry] {
                    lappend entries $subEntry
                }
            }
        }
    }
    return $entries
}

# Проверяет существование файла или директории в SVN
#
# Аргументы:
# url - путь к файлу или директории в SVN
#
# Возвращаемое значение:
#  1 - если заданный файл или директория существуют в SVN
#  0 - если заданный файл или директория не существуют в SVN, а также в случае ошибки
proc svnUrlExists {url} {
    if {![catch {exec svn info $url}]} {
        return 1
    }
    return 0
}

# Удаляет в числе c плавающей точкой лишние нули справа (пример: 5.500 -> 5.5 или 5.0 -> 5)
#
# Аргументы:
# value - целое число либо число с плавающей точкой
#
# Возвращаемое значение:
# число без лишних нулей справа, если value - число с плавающей точкой, исходное значение value в других случаях
proc trimZeros {value} {
    if {[regexp {^\-?(\d+|\d+\.\d*)$} $value]} {
        return [expr double($value) == round($value) ? round($value) : double($value)]
    }
    return $value
}

# Конвертирует значение в микрометрах в миллиметры
#
# Аргументы:
# um - значение в нанометрах
#
# Возвращаемое значение:
# Значение в миллиметрах либо пустая строка вслучае ошибки
#
# Зависимости:
# trimZeros
proc um2mm {um} {
    if {![catch {eval set mm [expr $um / 1000.0]} error]} {
        return [trimZeros $mm]
    }
    return ""
}

# Конвертирует значение в микрометрах в нанометры
#
# Аргументы:
# um - значение в нанометрах
#
# Возвращаемое значение:
# Значение в нанометрах либо пустая строка вслучае ошибки
#
# Зависимости:
# trimZeros
proc um2nm {um} {
    if {![catch {eval set nm [expr $um * 1000]} error]} {
        return [trimZeros $nm]
    }
    return ""
}

# Устанавливает переменные окружения для версии calibre "calibreVersion"
#
# Аргументы:
# calibreVersion - версия Calibre
#
# Возвращаемое значение:
#
# Зависимости:
#
proc setCalibreVersion {calibreVersion} {
    global env
    set env(CAL_VERSION) $calibreVersion
    set env(CAD_TOOLS) /grid/cad_tools/
    set env(CAL_INST_DIR) $env(CAD_TOOLS)/mentor/$env(CAL_VERSION)
    set env(MGC_HOME) $env(CAL_INST_DIR)
    set env(USE_CALIBRE_64) YES
    set env(MGC_DISABLE_BACKING_STORE) true
    set env(PATH) $env(MGC_HOME)/bin:$env(PATH)
    set env(CALIBRE_HOME) $env(MGC_HOME)
}

# Функции для работы с файлами в ini-формате #########################################################################################################

# Возвращает список групп конфигурационного файла
# 
# Аргументы:
# content - содержимое конфигурационного файла
#
# Возвращаемое значение:
# список групп конфигурационного файла
proc getConfigGroups {content} {
    set groups [list]
    foreach line [split $content "\n"] {
        if {[regexp {^\s*\[.*\]\s*$} $line]} {
            set group [string trim [regsub -all {[\[\]]} $line ""]]
            if {$group != "" && [lsearch $groups $group] == -1} {
                lappend groups $group
            }
        }
    }
    return [lsort -dictionary $groups]
}

# Возвращает список ключей конфигурационного файла
# 
# Аргументы:
# content - содержимое конфигурационного файла
#
# Возвращаемое значение:
# список ключей конфигурационного файла
proc getConfigKeys {content} {
    set keys [list]
    set group ""
    foreach line [split $content "\n"] {
        if {[regexp {^\s*\[.*\]\s*$} $line]} {
            set group [string trim [regsub -all {[\[\]]} $line ""]]
        } elseif {[regexp {^\s*\S+\s*=.*$} $line]} {
            if {$group == ""} {
                lappend keys [string trim [lindex [split $line "="] 0]]
            } else {
                lappend keys "$group/[string trim [lindex [split $line "="] 0]]"
            }
        }
    }
    return $keys
}

# Возвращает значение ключа конфигурационного файла
# 
# Аргументы:
# content - содержимое конфигурационного файла
# key - ключ конфигурационного файла
#
# Возвращаемое значение:
# значение, соответствующее заданному ключу, либо пустая строка, если ключ отсутствует
proc getConfigValue {content key} {
    set group ""
    if {[regexp {^\S+/\S+$} $key]} {
        set group [lindex [split $key "/"] 0]
        set key [lindex [split $key "/"] 1]
    }
    set currentGroup ""
    foreach line [split $content "\n"] {
        if {[regexp {^\s*\[.*\]\s*$} $line]} {
            set currentGroup [string trim [regsub -all {[\[\]]} $line ""]]
        }
        if {$currentGroup == $group && [regexp "^\\s*$key\\s*=.*$" $line]} {
            return [string trim [lindex [split $line "="] 1]]
        }
    }
    return ""
}

# Функции для валидации файлов #######################################################################################################################

# Выполняет проверку конфигурационного файла для формирования фрейма
# 
# Аргументы:
# content - содержимое конфигурационного файла для формирования фрейма
#
# Возвращаемое значение:
# tcl-массив, содержащий следующие индексы:
# missingKeys - список отсутствующих параметров
# invalidKeys - список параметров с некорректными значениями
#
# Зависимости:
# getConfigGroups, getConfigKeys, getConfigValue
#
proc checkFrameConfigContent {content} {

    set missingKeys [list]
    set invalidKeys [list]

    set groups [getConfigGroups $content]
    set keys [getConfigKeys $content]
    
    # Базовый маршрут
    set key "General/baseRoute"
    set value [getConfigValue $content $key]
    if {[lsearch $keys $key] == -1} {
        lappend missingKeys $key
    } elseif {![regexp "^\[A-Z0-9_\.\]+$" $value]} {
        lappend invalidKeys $key
    }
    
    # Имя билиотеки
    set key "General/libraryName"
    set value [getConfigValue $content $key]
    if {[lsearch $keys $key] == -1} {
        lappend missingKeys $key
    } elseif {![regexp "^BIB_\[A-Z0-9_\.\]+_V\\d\{3\}$" $value]} {
        lappend invalidKeys $key
    }
    
    # Флаг генерации областей для формирования DUMMY
    set key "General/dummyGeneration"
    set value [getConfigValue $content $key]
    if {[lsearch $keys $key] == -1} {
        lappend missingKeys $key
    } elseif {![regexp "^(True|False)$" $value]} {
        lappend invalidKeys $key
    }
    
    # Информация о массивах
    set frameArrayGroups [regexp -all -inline {Array_[1-9]\d*} $groups]
    if {$frameArrayGroups == [list]} {
        lappend missingKeys "FrameArrayGroups"
    } else {
        foreach group $frameArrayGroups {
        
            # Имя
            set key "$group/name"
            set value [getConfigValue $content $key]
            if {[lsearch $keys $key] == -1} {
                lappend missingKeys $key
            } elseif {![regexp "^\[A-Z0-9_\.\]+_V\\d\{3\}$" $value]} {
                lappend invalidKeys $key
            }
            
            # Left down
            set counter 0
            
            # Угол поворота
            set key "$group/leftDownAngle"
            set value [getConfigValue $content $key]
            if {[lsearch $keys $key] == -1} {
                lappend missingKeys $key
            } elseif {$value != ""} {
                incr counter
                if {![regexp "^(0|90|180|270)(\.0+)?$" $value]} {
                    lappend invalidKeys $key
                }
            }
            
            # Смещение по X
            set key "$group/leftDownDx"
            set value [getConfigValue $content $key]
            if {[lsearch $keys $key] == -1} {
                lappend missingKeys $key
            } elseif {$value != ""} {
                incr counter
                if {![regexp "^-?(\[1-9\]\\d*|\[1-9\]\\d*\.\\d\\d?\\d?|0\.?0*)?$" $value]} {
                    lappend invalidKeys $key
                }
            }
            
            # Смещение по Y
            set key "$group/leftDownDy"
            set value [getConfigValue $content $key]
            if {[lsearch $keys $key] == -1} {
                lappend missingKeys $key
            } elseif {$value != ""} {
                incr counter
                if {![regexp "^-?(\[1-9\]\\d*|\[1-9\]\\d*\.\\d\\d?\\d?|0\.?0*)?$" $value]} {
                    lappend invalidKeys $key
                }
            }
            
            if {($counter != 0) && ($counter != 3)} {
                lappend invalidKeys "$group/LeftDown"
            }
            
            # Left center
            set counter 0
            
            # Угол поворота
            set key "$group/leftCenterAngle"
            set value [getConfigValue $content $key]
            if {[lsearch $keys $key] == -1} {
                lappend missingKeys $key
            } elseif {$value != ""} {
                incr counter
                if {![regexp "^(0|90|180|270)(\.0+)?$" $value]} {
                    lappend invalidKeys $key
                }
            }
            
            # Смещение по X
            set key "$group/leftCenterDx"
            set value [getConfigValue $content $key]
            if {[lsearch $keys $key] == -1} {
                lappend missingKeys $key
            } elseif {$value != ""} {
                incr counter
                if {![regexp "^-?(\[1-9\]\\d*|\[1-9\]\\d*\.\\d\\d?\\d?|0\.?0*)?$" $value]} {
                    lappend invalidKeys $key
                }
            }
            
            # Смещение по Y
            set key "$group/leftCenterDy"
            set value [getConfigValue $content $key]
            if {[lsearch $keys $key] == -1} {
                lappend missingKeys $key
            } elseif {$value != ""} {
                incr counter
                if {![regexp "^-?(\[1-9\]\\d*|\[1-9\]\\d*\.\\d\\d?\\d?|0\.?0*)?$" $value]} {
                    lappend invalidKeys $key
                }
            }
            
            if {($counter != 0) && ($counter != 3)} {
                lappend invalidKeys "$group/LeftCenter"
            }
            
            # Left up
            set counter 0
            
            # Угол поворота
            set key "$group/leftUpAngle"
            set value [getConfigValue $content $key]
            if {[lsearch $keys $key] == -1} {
                lappend missingKeys $key
            } elseif {$value != ""} {
                incr counter
                if {![regexp "^(0|90|180|270)(\.0+)?$" $value]} {
                    lappend invalidKeys $key
                }
            }
            
            # Смещение по X
            set key "$group/leftUpDx"
            set value [getConfigValue $content $key]
            if {[lsearch $keys $key] == -1} {
                lappend missingKeys $key
            } elseif {$value != ""} {
                incr counter
                if {![regexp "^-?(\[1-9\]\\d*|\[1-9\]\\d*\.\\d\\d?\\d?|0\.?0*)?$" $value]} {
                    lappend invalidKeys $key
                }
            }
            
            # Смещение по Y
            set key "$group/leftUpDy"
            set value [getConfigValue $content $key]
            if {[lsearch $keys $key] == -1} {
                lappend missingKeys $key
            } elseif {$value != ""} {
                incr counter
                if {![regexp "^-?(\[1-9\]\\d*|\[1-9\]\\d*\.\\d\\d?\\d?|0\.?0*)?$" $value]} {
                    lappend invalidKeys $key
                }
            }
            
            if {($counter != 0) && ($counter != 3)} {
                lappend invalidKeys "$group/LeftUp"
            }
            
            # Center up
            set counter 0
            
            # Угол поворота
            set key "$group/centerUpAngle"
            set value [getConfigValue $content $key]
            if {[lsearch $keys $key] == -1} {
                lappend missingKeys $key
            } elseif {$value != ""} {
                incr counter
                if {![regexp "^(0|90|180|270)(\.0+)?$" $value]} {
                    lappend invalidKeys $key
                }
            }
            
            # Смещение по X
            set key "$group/centerUpDx"
            set value [getConfigValue $content $key]
            if {[lsearch $keys $key] == -1} {
                lappend missingKeys $key
            } elseif {$value != ""} {
                incr counter
                if {![regexp "^-?(\[1-9\]\\d*|\[1-9\]\\d*\.\\d\\d?\\d?|0\.?0*)?$" $value]} {
                    lappend invalidKeys $key
                }
            }
            
            # Смещение по Y
            set key "$group/centerUpDy"
            set value [getConfigValue $content $key]
            if {[lsearch $keys $key] == -1} {
                lappend missingKeys $key
            } elseif {$value != ""} {
                incr counter
                if {![regexp "^-?(\[1-9\]\\d*|\[1-9\]\\d*\.\\d\\d?\\d?|0\.?0*)?$" $value]} {
                    lappend invalidKeys $key
                }
            }
            
            if {($counter != 0) && ($counter != 3)} {
                lappend invalidKeys "$group/CenterUp"
            }
            
            # Right up
            set counter 0
            
            # Угол поворота
            set key "$group/rightUpAngle"
            set value [getConfigValue $content $key]
            if {[lsearch $keys $key] == -1} {
                lappend missingKeys $key
            } elseif {$value != ""} {
                incr counter
                if {![regexp "^(0|90|180|270)(\.0+)?$" $value]} {
                    lappend invalidKeys $key
                }
            }
            
            # Смещение по X
            set key "$group/rightUpDx"
            set value [getConfigValue $content $key]
            if {[lsearch $keys $key] == -1} {
                lappend missingKeys $key
            } elseif {$value != ""} {
                incr counter
                if {![regexp "^-?(\[1-9\]\\d*|\[1-9\]\\d*\.\\d\\d?\\d?|0\.?0*)?$" $value]} {
                    lappend invalidKeys $key
                }
            }
            
            # Смещение по Y
            set key "$group/rightUpDy"
            set value [getConfigValue $content $key]
            if {[lsearch $keys $key] == -1} {
                lappend missingKeys $key
            } elseif {$value != ""} {
                incr counter
                if {![regexp "^-?(\[1-9\]\\d*|\[1-9\]\\d*\.\\d\\d?\\d?|0\.?0*)?$" $value]} {
                    lappend invalidKeys $key
                }
            }
            
            if {($counter != 0) && ($counter != 3)} {
                lappend invalidKeys "$group/RightUp"
            }
            
            # Right center
            set counter 0
            
            # Угол поворота
            set key "$group/rightCenterAngle"
            set value [getConfigValue $content $key]
            if {[lsearch $keys $key] == -1} {
                lappend missingKeys $key
            } elseif {$value != ""} {
                incr counter
                if {![regexp "^(0|90|180|270)(\.0+)?$" $value]} {
                    lappend invalidKeys $key
                }
            }
            
            # Смещение по X
            set key "$group/rightCenterDx"
            set value [getConfigValue $content $key]
            if {[lsearch $keys $key] == -1} {
                lappend missingKeys $key
            } elseif {$value != ""} {
                incr counter
                if {![regexp "^-?(\[1-9\]\\d*|\[1-9\]\\d*\.\\d\\d?\\d?|0\.?0*)?$" $value]} {
                    lappend invalidKeys $key
                }
            }
            
            # Смещение по Y
            set key "$group/rightCenterDy"
            set value [getConfigValue $content $key]
            if {[lsearch $keys $key] == -1} {
                lappend missingKeys $key
            } elseif {$value != ""} {
                incr counter
                if {![regexp "^-?(\[1-9\]\\d*|\[1-9\]\\d*\.\\d\\d?\\d?|0\.?0*)?$" $value]} {
                    lappend invalidKeys $key
                }
            }
            
            if {($counter != 0) && ($counter != 3)} {
                lappend invalidKeys "$group/RightCenter"
            }
            
            # Right down
            set counter 0
            
            # Угол поворота
            set key "$group/rightDownAngle"
            set value [getConfigValue $content $key]
            if {[lsearch $keys $key] == -1} {
                lappend missingKeys $key
            } elseif {$value != ""} {
                incr counter
                if {![regexp "^(0|90|180|270)(\.0+)?$" $value]} {
                    lappend invalidKeys $key
                }
            }
            
            # Смещение по X
            set key "$group/rightDownDx"
            set value [getConfigValue $content $key]
            if {[lsearch $keys $key] == -1} {
                lappend missingKeys $key
            } elseif {$value != ""} {
                incr counter
                if {![regexp "^-?(\[1-9\]\\d*|\[1-9\]\\d*\.\\d\\d?\\d?|0\.?0*)?$" $value]} {
                    lappend invalidKeys $key
                }
            }
            
            # Смещение по Y
            set key "$group/rightDownDy"
            set value [getConfigValue $content $key]
            if {[lsearch $keys $key] == -1} {
                lappend missingKeys $key
            } elseif {$value != ""} {
                incr counter
                if {![regexp "^-?(\[1-9\]\\d*|\[1-9\]\\d*\.\\d\\d?\\d?|0\.?0*)?$" $value]} {
                    lappend invalidKeys $key
                }
            }
            
            if {($counter != 0) && ($counter != 3)} {
                lappend invalidKeys "$group/RightDown"
            }
            
            # Center down
            set counter 0
            
            # Угол поворота
            set key "$group/centerDownAngle"
            set value [getConfigValue $content $key]
            if {[lsearch $keys $key] == -1} {
                lappend missingKeys $key
            } elseif {$value != ""} {
                incr counter
                if {![regexp "^(0|90|180|270)(\.0+)?$" $value]} {
                    lappend invalidKeys $key
                }
            }
            
            # Смещение по X
            set key "$group/centerDownDx"
            set value [getConfigValue $content $key]
            if {[lsearch $keys $key] == -1} {
                lappend missingKeys $key
            } elseif {$value != ""} {
                incr counter
                if {![regexp "^-?(\[1-9\]\\d*|\[1-9\]\\d*\.\\d\\d?\\d?|0\.?0*)?$" $value]} {
                    lappend invalidKeys $key
                }
            }
            
            # Смещение по Y
            set key "$group/centerDownDy"
            set value [getConfigValue $content $key]
            if {[lsearch $keys $key] == -1} {
                lappend missingKeys $key
            } elseif {$value != ""} {
                incr counter
                if {![regexp "^-?(\[1-9\]\\d*|\[1-9\]\\d*\.\\d\\d?\\d?|0\.?0*)?$" $value]} {
                    lappend invalidKeys $key
                }
            }
            
            if {($counter != 0) && ($counter != 3)} {
                lappend invalidKeys "$group/CenterDown"
            }
            
            # Ширина массива
            set key "$group/width"
            set value [getConfigValue $content $key]
            if {[lsearch $keys $key] == -1} {
                lappend missingKeys $key
            } elseif {![regexp "^-?(\[1-9\]\\d*|\[1-9\]\\d*\.\\d\\d?\\d?)?$" $value] && ($value != "")} {
                lappend invalidKeys $key
            }
            
            # Высота массива
            set key "$group/height"
            set value [getConfigValue $content $key]
            if {[lsearch $keys $key] == -1} {
                lappend missingKeys $key
            } elseif {![regexp "^-?(\[1-9\]\\d*|\[1-9\]\\d*\.\\d\\d?\\d?)?$" $value] && ($value != "")} {
                lappend invalidKeys $key
            }
        }
    }
    
    # Информация о PSM-областях
    set psmRegionGroups [regexp -all -inline "PsmRegion_\[1-9\]\\d*" $groups]
    if {$psmRegionGroups == [list]} {
        lappend missingKeys "PsmRegionGroups"
    } else {
        foreach group $psmRegionGroups {
            
            # Тип области
            set key "$group/type"
            set value [getConfigValue $content $key]
            if {[lsearch $keys $key] == -1} {
                lappend missingKeys $key
            } elseif {![regexp -nocase "^\[CRB\]$" $value]} {
                lappend invalidKeys $key
            } else {
                switch [string tolower $value] {
                    "c" {
                        
                        # Cell1
                        set key "$group/cell1"
                        set value [getConfigValue $content $key]
                        if {[lsearch $keys $key] == -1} {
                            lappend missingKeys $key
                        } elseif {![regexp "^\[A-Z0-9_\.\]+$" $value]} {
                            lappend invalidKeys $key
                        }
                        
                        # Cell2
                        set key "$group/cell2"
                        set value [getConfigValue $content $key]
                        if {[lsearch $keys $key] == -1} {
                            lappend missingKeys $key
                        } elseif {$value != ""} {
                            lappend invalidKeys $key
                        }
                        
                        # addX
                        set key "$group/addX"
                        set value [getConfigValue $content $key]
                        if {[lsearch $keys $key] == -1} {
                            lappend missingKeys $key
                        } elseif {![regexp "^(\[1-9\]\\d*|\[1-9\]\\d*\.\\d\\d?\\d?|0)$" [trimZeros $value]]} {
                            lappend invalidKeys $key
                        }
                        
                        # addY
                        set key "$group/addY"
                        set value [getConfigValue $content $key]
                        if {[lsearch $keys $key] == -1} {
                            lappend missingKeys $key
                        } elseif {![regexp "^(\[1-9\]\\d*|\[1-9\]\\d*\.\\d\\d?\\d?|0)$" [trimZeros $value]]} {
                            lappend invalidKeys $key
                        }
                        
                        # area
                        set key "$group/area"
                        set value [getConfigValue $content $key]
                        if {[lsearch $keys $key] == -1} {
                            lappend missingKeys $key
                        } elseif {$value != ""} {
                            lappend invalidKeys $key
                        }
                    }
                    
                    "r" {
                        
                        # Cell1
                        set key "$group/cell1"
                        set value [getConfigValue $content $key]
                        if {[lsearch $keys $key] == -1} {
                            lappend missingKeys $key
                        } elseif {![regexp "^\[A-Z0-9_\.\]+$" $value]} {
                            lappend invalidKeys $key
                        }
                        
                        # Cell2
                        set key "$group/cell2"
                        set value [getConfigValue $content $key]
                        if {[lsearch $keys $key] == -1} {
                            lappend missingKeys $key
                        } elseif {$value != ""} {
                            lappend invalidKeys $key
                        }
                        
                        # addX
                        set key "$group/addX"
                        set value [getConfigValue $content $key]
                        if {[lsearch $keys $key] == -1} {
                            lappend missingKeys $key
                        } elseif {![regexp "^(\[1-9\]\\d*|\[1-9\]\\d*\.\\d\\d?\\d?|0)$" [trimZeros $value]]} {
                            lappend invalidKeys $key
                        }
                        
                        # addY
                        set key "$group/addY"
                        set value [getConfigValue $content $key]
                        if {[lsearch $keys $key] == -1} {
                            lappend missingKeys $key
                        } elseif {![regexp "^(\[1-9\]\\d*|\[1-9\]\\d*\.\\d\\d?\\d?|0)$" [trimZeros $value]]} {
                            lappend invalidKeys $key
                        }
                        
                        # area
                        set key "$group/area"
                        set value [getConfigValue $content $key]
                        if {[lsearch $keys $key] == -1} {
                            lappend missingKeys $key
                        } elseif {![regexp "^(\[LR\]\[UDC\]|\[LRC\]\[UD\])$" $value]} {
                            lappend invalidKeys $key
                        }
                    }
                    
                    "b" {
                        
                        # Cell1
                        set key "$group/cell1"
                        set value [getConfigValue $content $key]
                        if {[lsearch $keys $key] == -1} {
                            lappend missingKeys $key
                        } elseif {![regexp "^\[A-Z0-9_\.\]+$" $value]} {
                            lappend invalidKeys $key
                        }
                        
                        # Cell2
                        set key "$group/cell2"
                        set value [getConfigValue $content $key]
                        if {[lsearch $keys $key] == -1} {
                            lappend missingKeys $key
                        } elseif {![regexp "^\[A-Z0-9_\.\]+$" $value]} {
                            lappend invalidKeys $key
                        }
                        
                        # addX
                        set key "$group/addX"
                        set value [getConfigValue $content $key]
                        if {[lsearch $keys $key] == -1} {
                            lappend missingKeys $key
                        } elseif {$value != ""} {
                            lappend invalidKeys $key
                        }
                        
                        # addY
                        set key "$group/addY"
                        set value [getConfigValue $content $key]
                        if {[lsearch $keys $key] == -1} {
                            lappend missingKeys $key
                        } elseif {$value != ""} {
                            lappend invalidKeys $key
                        }
                        
                        # area
                        set key "$group/area"
                        set value [getConfigValue $content $key]
                        if {[lsearch $keys $key] == -1} {
                            lappend missingKeys $key
                        } elseif {![regexp "^(\[LR\]\[UDC\]|\[LRC\]\[UD\])$" $value]} {
                            lappend invalidKeys $key
                        }
                    }
                }
            }
        }
    }
    
    set checkArray(missingKeys) $missingKeys
    set checkArray(invalidKeys) $invalidKeys
    return [array get checkArray]
}

# Выполняет проверку конфигурационного файла запуска
# 
# Аргументы:
# content - содержимое конфигурационного файла запуска
#
# Возвращаемое значение:
# tcl-массив, содержащий следующие индексы:
# missingKeys - список отсутствующих параметров
# invalidKeys - список параметров с некорректными значениями
#
# Зависимости:
# getConfigGroups, getConfigKeys, getConfigValue
#
proc checkDataConfigContent {content} {

    set missingKeys [list]
    set invalidKeys [list]

    set groups [getConfigGroups $content]
    set keys [getConfigKeys $content]
    
    # Тестовые полосы
    set tegCellKeys [regexp -all -inline "MandatoryTegCells/cell_\[1-9\]\\d*" $keys]
    if {$tegCellKeys == [list]} {
        lappend missingKeys "MandatoryTegCells"
    } else {
        foreach key $tegCellKeys {
            set value [getConfigValue $content $key]
            if {![regexp "^\[A-Za-z0-9_\.\]+$" $value]} {
                lappend invalidKeys $key
            }
        }
    }

    # Density-слои
    set key "Layers/densityLayers"
    set values [split [regsub -all "\\s" [getConfigValue $content $key] ""] ","]
    if {[lsearch $keys $key] == -1} {
        lappend missingKeys $key
    } elseif {$values != ""} {
        foreach value $values {
            if {![regexp "^(\\d+|\\d+\.\\d+)$" $value]} {
                lappend invalidKeys $key
                break
            }
        }
    }
            
    # Топологические слои для написания служебной информации
    set key "Frame/markLayers"
    set values [split [regsub -all "\\s" [getConfigValue $content $key] ""] ","]
    if {[lsearch $keys $key] == -1} {
        lappend missingKeys $key
    } else {
        foreach value $values {
            if {![regexp "^(\\d+|\\d+\.\\d+)$" $value]} {
                lappend invalidKeys $key
                break
            }
        }
    }
    
    # Минимальный размер фрейма по X
    set key "Frame/minXSize"
    set value [getConfigValue $content $key]
    if {[lsearch $keys $key] == -1} {
        lappend missingKeys $key
    } elseif {![regexp "^(\[1-9\]\\d*|\[1-9\]\\d*\.\\d\\d?\\d?)$" $value]} {
        lappend invalidKeys $key
    }
    
    # Минимальный размер фрейма по Y (MLR)
    set key "Frame/minMlrYSize"
    set value [getConfigValue $content $key]
    if {[lsearch $keys $key] == -1} {
        lappend missingKeys $key
    } elseif {![regexp "^(\[1-9\]\\d*|\[1-9\]\\d*\.\\d\\d?\\d?)$" $value]} {
        lappend invalidKeys $key
    }
    
    # Минимальный размер фрейма по Y (SLR)
    set key "Frame/minSlrYSize"
    set value [getConfigValue $content $key]
    if {[lsearch $keys $key] == -1} {
        lappend missingKeys $key
    } elseif {![regexp "^(\[1-9\]\\d*|\[1-9\]\\d*\.\\d\\d?\\d?)$" $value]} {
        lappend invalidKeys $key
    }
    
    # Максимальный размер фрейма по X
    set key "Frame/maxXSize"
    set value [getConfigValue $content $key]
    if {[lsearch $keys $key] == -1} {
        lappend missingKeys $key
    } elseif {![regexp "^(\[1-9\]\\d*|\[1-9\]\\d*\.\\d\\d?\\d?)$" $value]} {
        lappend invalidKeys $key
    }
    
    # Максимальный размер фрейма по Y (MLR)
    set key "Frame/maxMlrYSize"
    set value [getConfigValue $content $key]
    if {[lsearch $keys $key] == -1} {
        lappend missingKeys $key
    } elseif {![regexp "^(\[1-9\]\\d*|\[1-9\]\\d*\.\\d\\d?\\d?)$" $value]} {
        lappend invalidKeys $key
    }
    
    # Максимальный размер фрейма по Y (SLR)
    set key "Frame/maxSlrYSize"
    set value [getConfigValue $content $key]
    if {[lsearch $keys $key] == -1} {
        lappend missingKeys $key
    } elseif {![regexp "^(\[1-9\]\\d*|\[1-9\]\\d*\.\\d\\d?\\d?)$" $value]} {
        lappend invalidKeys $key
    }
    
    # Флаг генерации DUMMY во фрейме
    set key "Frame/dummyGeneration"
    set value [getConfigValue $content $key]
    if {[lsearch $keys $key] == -1} {
        lappend missingKeys $key
    } elseif {![regexp "^\[01\]$" $value]} {
        lappend invalidKeys $key
    }

	# Скрипт установки PDK
	set key "PDK/setupScriptPath"
    set value [getConfigValue $content $key]
    if {[lsearch $keys $key] == -1} {
        lappend missingKeys $key
    } elseif {![regexp "^\\S+$" $value]} {
        lappend invalidKeys $key
    }

	# Информация об операциях PDK
	set PdkOperationGroups [regexp -all -inline {PdkOperation_[1-9]\d*} $groups]
    if {$PdkOperationGroups == [list]} {
        lappend missingKeys "PdkOperationGroups"
    } else {
        foreach group $PdkOperationGroups {
        
            # Тип
            set key "$group/type"
            set value [getConfigValue $content $key]
            if {[lsearch $keys $key] == -1} {
                lappend missingKeys $key
            } elseif {![regexp {dummy|drc} $value]} {
                lappend invalidKeys $key
            }
            
            # Путь к скрипту
            set key "$group/scriptPath"
            set value [getConfigValue $content $key]
            if {[lsearch $keys $key] == -1} {
                lappend missingKeys $key
            } elseif {![regexp "^\\S+$" $value]} {
                lappend invalidKeys $key
            }

			# Путь к деке
			set key "$group/deckPath"
            set value [getConfigValue $content $key]
            if {[lsearch $keys $key] == -1} {
                lappend missingKeys $key
            } elseif {![regexp "^\\S+$" $value]} {
                lappend invalidKeys $key
            }

			# Путь к Ctrl-файлу
			set key "$group/ctrlPath"
            set value [getConfigValue $content $key]
            if {[lsearch $keys $key] == -1} {
                lappend missingKeys $key
            } elseif {![regexp "^\\S+$" $value]} {
                lappend invalidKeys $key
            }
        }
    }

	# Правила проверки плотности
	set densityKeys [regexp -all -inline {Density/\S*} $keys]
    if {$densityKeys == [list]} {
        lappend missingKeys "Density"
    } else {
        foreach key $densityKeys {
            set values [split [regsub -all "\\s" [getConfigValue $content $key] ""] ","]
            if {[lsearch $keys $key] == -1} {
                lappend missingKeys $key
            } elseif {$values != ""} {
                foreach value $values {
                    if {![regexp "^(\\d+\.\\d+)$" $value]} {
                        lappend invalidKeys $key
                        break
                    }
                }
            }
        }
    }
    
    # Информация о DUMMY-слоях
    set dummyLayerGroups [regexp -all -inline {DummyLayer_[1-9]\d*} $groups]
    if {$dummyLayerGroups == [list]} {
        lappend missingKeys "DummyLayerGroups"
    } else {
        foreach group $dummyLayerGroups {
        
            # DUMMY-слой
            set key "$group/layer"
            set value [getConfigValue $content $key]
            if {[lsearch $keys $key] == -1} {
                lappend missingKeys $key
            } elseif {![regexp "^(\\d+|\\d+\.\\d+)$" $value]} {
                lappend invalidKeys $key
            }
            
            # Запрещающие слои
            set key "$group/forbiddingLayers"
            set values [split [regsub -all "\\s" [getConfigValue $content $key] ""] ","]
            if {[lsearch $keys $key] == -1} {
                lappend missingKeys $key
            } elseif {$values != ""} {
                foreach value $values {
                    if {![regexp "^(\\d+|\\d+\.\\d+)$" $value]} {
                        lappend invalidKeys $key
                        break
                    }
                }
            }
        }
    }
    
    # Масочные слои для написания служебной информации
    set key "Masks/markLayers"
    set values [split [regsub -all "\\s" [getConfigValue $content $key] ""] ","]
    if {[lsearch $keys $key] == -1} {
        lappend missingKeys $key
    } elseif {$values != ""} {
        foreach value $values {
            if {![regexp "^\\d\{3\}$" $value]} {
                lappend invalidKeys $key
                break
            }
        }
    }
    
    # Информация о внешних массивах фрейма
    set externalArrayGroups [regexp -all -inline {ExternalFrameArray_[1-9]\d*} $groups]
    if {$externalArrayGroups == [list]} {
        lappend missingKeys "ExternalFrameArrayGroups"
    } else {
        foreach group $externalArrayGroups {

            # Название массива
            set key "$group/name"
            set value [getConfigValue $content $key]
            if {[lsearch $keys $key] == -1} {
                lappend missingKeys $key
            } elseif {![regexp {^\S+V\d{3}$} $value] || [regexp {^\S+V000$} $value]} {
                lappend invalidKeys $key
            }

            # Размер по X
            set key "$group/sizeX"
            set value [getConfigValue $content $key]
            if {[lsearch $keys $key] == -1} {
                lappend missingKeys $key
            } elseif {![regexp {^([1-9]\d*|[1-9]\d*\.\d\d?\d?)$} $value]} {
                lappend invalidKeys $key
            }

            # Размер по Y
            set key "$group/sizeY"
            set value [getConfigValue $content $key]
            if {[lsearch $keys $key] == -1} {
                lappend missingKeys $key
            } elseif {![regexp {^([1-9]\d*|[1-9]\d*\.\d\d?\d?)$} $value]} {
                lappend invalidKeys $key
            }
        }
    }
    
    # Информация о масочных слоях из ЧТЗ
    set maskLayerGroups [regexp -all -inline "MaskLayer_\[1-9\]\\d*" $groups]
    if {$maskLayerGroups == [list]} {
        lappend missingKeys "MaskLayerGroups"
    } else {
        foreach group $maskLayerGroups {

            # Номер слоя
            set key "$group/layer"
            set value [getConfigValue $content $key]
            if {[lsearch $keys $key] == -1} {
                lappend missingKeys $key
            } elseif {![regexp "^\\d\{3\}$" $value]} {
                lappend invalidKeys $key
            }

            # Название
            set key "$group/name"
            set value [getConfigValue $content $key]
            if {[lsearch $keys $key] == -1} {
                lappend missingKeys $key
            } elseif {![regexp "^\.+$" $value]} {
                lappend invalidKeys $key
            }

            # Группа качества
            set key "$group/stmQualityGroup"
            set value [getConfigValue $content $key]
            if {[lsearch $keys $key] == -1} {
                lappend missingKeys $key
            } elseif {![regexp "^\.+$" $value]} {
                lappend invalidKeys $key
            }
            
            # Тональность
            set key "$group/tone"
            set value [getConfigValue $content $key]
            if {[lsearch $keys $key] == -1} {
                lappend missingKeys $key
            } elseif {![regexp -nocase "^(clear|dark)$" $value]} {
                lappend invalidKeys $key
            }
        }
    }

    set checkArray(missingKeys) $missingKeys
    set checkArray(invalidKeys) $invalidKeys
    return [array get checkArray]
}

# Выполняет проверку файла-задания
# 
# Аргументы:
# content - содержимое файла-задания
#
# Возвращаемое значение:
# tcl-массив, содержащий следующие индексы:
# missingKeys - список отсутствующих параметров
# invalidKeys - список параметров с некорректными значениями
#
# Зависимости:
# getConfigGroups, getConfigKeys, getConfigValue
proc checkOrderContent {content} {

    set missingKeys [list]
    set invalidKeys [list]

    set groups [getConfigGroups $content]
    set keys [getConfigKeys $content]

    # Маршрут УИ
    set key "General/routeId"
    set value [getConfigValue $content $key]
    if {[lsearch $keys $key] == -1} {
        lappend missingKeys $key
    } elseif {![regexp {^[\d\.]+$} $value]} {
        lappend invalidKeys $key
    }

    # Технология
    set key "General/technology"
    set value [getConfigValue $content $key]
    if {[lsearch $keys $key] == -1} {
        lappend missingKeys $key
    } elseif {![regexp {^[A-Z\d_\.]+$} $value]} {
        lappend invalidKeys $key
    }

    # Базовый маршрут
    set key "General/baseRoute"
    set value [getConfigValue $content $key]
    if {[lsearch $keys $key] == -1} {
        lappend missingKeys $key
    } elseif {![regexp {^[A-Z\d_\.]+$} $value]} {
        lappend invalidKeys $key
    }

    # Название MPW
    set key "General/mpw"
    set value [getConfigValue $content $key]
    if {[lsearch $keys $key] == -1} {
        lappend missingKeys $key
    } elseif {![regexp {^[A-Z\d\-_]+$} $value]} {
        lappend invalidKeys $key
    }

    # Версия ТЗ
    set key "General/tz"
    set value [getConfigValue $content $key]
    if {[lsearch $keys $key] == -1} {
        lappend missingKeys $key
    } elseif {![regexp {^TZ([1-9]\d*|0)_([1-9]\d*|0)$} $value]} {
        lappend invalidKeys $key
    } else {
        set tz $value
    }

    # Версия базового ТЗ
    if {[info exists tz] && $tz != "TZ0_0"} {
        set key "General/baseTz"
        set value [getConfigValue $content $key]
        if {[lsearch $keys $key] == -1} {
            lappend missingKeys $key
        } elseif {![regexp {^TZ([1-9]\d*|0)_([1-9]\d*|0)$} $value]} {
            lappend invalidKeys $key
        }
    }

    # Версия PDK
    set key "General/pdk"
    set value [getConfigValue $content $key]
    if {[lsearch $keys $key] == -1} {
        lappend missingKeys $key
    } elseif {![regexp {^[A-Za-z\d\-_\.]+$} $value]} {
        lappend invalidKeys $key
    }

    # Тип ФШ (MPW/SPW)
    set key "General/pwType"
    set value [getConfigValue $content $key]
    if {[lsearch $keys $key] == -1} {
        lappend missingKeys $key
    } elseif {![regexp {^[MS]PW$} $value]} {
        lappend invalidKeys $key
    }

    # Тип ФШ (MLR/SLR)
    set key "General/lrType"
    set value [getConfigValue $content $key]
    if {[lsearch $keys $key] == -1} {
        lappend missingKeys $key
    } elseif {![regexp {^[MS]LR$} $value]} {
        lappend invalidKeys $key
    } else {
        set lrType $value
    }

    # Дорожка скрайбирования
    set key "General/scribingTrack"
    set value [getConfigValue $content $key]
    if {[lsearch $keys $key] == -1} {
        lappend missingKeys $key
    } elseif {![regexp {^[1-9]\d*$} $value]} {
        lappend invalidKeys $key
    }

    # Расстояние до фрейма по Х
    set key "General/frameDistanceX"
    set value [getConfigValue $content $key]
    if {[lsearch $keys $key] == -1} {
        lappend missingKeys $key
    } elseif {![regexp {^([0-9]\d*|[0-9]\d*\.\d\d?\d?)$} $value]} {
        lappend invalidKeys $key
    }

    # Расстояние до фрейма по Y
    set key "General/frameDistanceY"
    set value [getConfigValue $content $key]
    if {[lsearch $keys $key] == -1} {
        lappend missingKeys $key
    } elseif {![regexp {^([0-9]\d*|[0-9]\d*\.\d\d?\d?)$} $value]} {
        lappend invalidKeys $key
    }

    # Размер фрейма по Х
    set key "General/frameSizeX"
    set value [getConfigValue $content $key]
    if {[lsearch $keys $key] == -1} {
        lappend missingKeys $key
    } elseif {![regexp {^([1-9]\d*|[1-9]\d*\.\d\d?\d?)$} $value]} {
        lappend invalidKeys $key
    }

    # Размер фрейма по Y
    set key "General/frameSizeY"
    set value [getConfigValue $content $key]
    if {[lsearch $keys $key] == -1} {
        lappend missingKeys $key
    } elseif {![regexp {^([1-9]\d*|[1-9]\d*\.\d\d?\d?)$} $value]} {
        lappend invalidKeys $key
    }

    # Ширина фрейма слева
    set key "General/frameWidthLeft"
    set value [getConfigValue $content $key]
    if {[lsearch $keys $key] == -1} {
        lappend missingKeys $key
    } elseif {![regexp {^([1-9]\d*|[1-9]\d*\.\d\d?\d?)$} $value]} {
        lappend invalidKeys $key
    }

    # Ширина фрейма справа
    set key "General/frameWidthRight"
    set value [getConfigValue $content $key]
    if {[lsearch $keys $key] == -1} {
        lappend missingKeys $key
    } elseif {![regexp {^([1-9]\d*|[1-9]\d*\.\d\d?\d?)$} $value]} {
        lappend invalidKeys $key
    }

    # Ширина фрейма сверху
    set key "General/frameWidthUp"
    set value [getConfigValue $content $key]
    if {[lsearch $keys $key] == -1} {
        lappend missingKeys $key
    } elseif {![regexp {^([1-9]\d*|[1-9]\d*\.\d\d?\d?)$} $value]} {
        lappend invalidKeys $key
    }

    # Ширина фрейма снизу
    set key "General/frameWidthDown"
    set value [getConfigValue $content $key]
    if {[lsearch $keys $key] == -1} {
        lappend missingKeys $key
    } elseif {![regexp {^([1-9]\d*|[1-9]\d*\.\d\d?\d?)$} $value]} {
        lappend invalidKeys $key
    }

    # Расстояние между кадрами
    if {[info exists lrType] && $lrType == "MLR"} {
        set key "General/kadrDistance"
        set value [getConfigValue $content $key]
        if {[lsearch $keys $key] == -1} {
            lappend missingKeys $key
        } elseif {![regexp {^([1-9]\d*|[1-9]\d*\.\d\d?\d?)$} $value]} {
            lappend invalidKeys $key
        }
    }

    # Код базы штрихкодов
    set key "General/barcodeBaseCode"
    set value [getConfigValue $content $key]
    if {[lsearch $keys $key] == -1} {
        lappend missingKeys $key
    } elseif {![regexp {^[AB]$} $value]} {
        lappend invalidKeys $key
    }

    # Номер комплекта ФШ
    set key "General/maskSetNumber"
    set value [getConfigValue $content $key]
    if {[lsearch $keys $key] == -1} {
        lappend missingKeys $key
    } elseif {![regexp {^(\?{3}|[A-F\d]{3})$} $value]} {
        lappend invalidKeys $key
    }

    # Идентификатор заявки на изготовление ФШ
    set key "General/applicationId"
    set value [getConfigValue $content $key]
    if {[lsearch $keys $key] == -1} {
        lappend missingKeys $key
    } elseif {![regexp {^(\?{3}|\d+)$} $value]} {
        lappend invalidKeys $key
    }

    # Перечень масок
    set maskGroups [regexp -all -inline {Mask_[1-9]\d*} $groups]
    if {$maskGroups == [list]} {
        lappend missingKeys "MaskGroups"
    } else {
        foreach group $maskGroups {

            # Слой 1
            set key "$group/layer1"
            set value [getConfigValue $content $key]
            if {[lsearch $keys $key] == -1} {
                lappend missingKeys $key
            } elseif {![regexp {^(0|\d{3})$} $value]} {
                lappend invalidKeys $key
            }

            # Слой 2
            if {[info exists lrType] && $lrType == "MLR"} {
                set key "$group/layer2"
                set value [getConfigValue $content $key]
                if {[lsearch $keys $key] == -1} {
                    lappend missingKeys $key
                } elseif {![regexp {^(0|\d{3})$} $value]} {
                    lappend invalidKeys $key
                }
            }

            # PSM
            set key "$group/psm"
            set value [getConfigValue $content $key]
            if {[lsearch $keys $key] == -1} {
                lappend missingKeys $key
            } elseif {![regexp {^[01]$} $value]} {
                lappend invalidKeys $key
            }

            # Штрихкод
            set key "$group/barcode"
            set value [getConfigValue $content $key]
            if {[lsearch $keys $key] == -1} {
                lappend missingKeys $key
            } elseif {![regexp {^[A-Z\d\?]{12}$} $value]} {
                lappend invalidKeys $key
            }
        }
    }

    # Перечень тестов
    set tegGroups [regexp -all -inline {Teg_[1-9]\d*} $groups]
    if {$tegGroups == [list]} {
        lappend missingKeys "TegGroups"
    } else {
        foreach group $tegGroups {

            # Путь к топологии
            set key "$group/path"
            set value [getConfigValue $content $key]
            if {[lsearch $keys $key] == -1} {
                lappend missingKeys $key
            } elseif {![regexp {^(\S+/)*[A-Za-z0-9_\.]+\.(gds|oas)(\.gz)?$} $value]} {
                lappend invalidKeys $key
            }

            # Размер по X
            set key "$group/sizeX"
            set value [getConfigValue $content $key]
            if {[lsearch $keys $key] == -1} {
                lappend missingKeys $key
            } elseif {![regexp {^([1-9]\d*|[1-9]\d*\.\d\d?\d?)$} $value]} {
                lappend invalidKeys $key
            }

            # Размер по Y
            set key "$group/sizeY"
            set value [getConfigValue $content $key]
            if {[lsearch $keys $key] == -1} {
                lappend missingKeys $key
            } elseif {![regexp {^([1-9]\d*|[1-9]\d*\.\d\d?\d?)$} $value]} {
                lappend invalidKeys $key
            }

            # Ориентация
            set key "$group/orientation"
            set value [getConfigValue $content $key]
            if {[lsearch $keys $key] == -1} {
                lappend missingKeys $key
            } elseif {![regexp {^(horizontal|vertical)$} $value]} {
                lappend invalidKeys $key
            }

            # Опорная ячейка
            set key "$group/baseCell"
            set value [getConfigValue $content $key]
            if {[lsearch $keys $key] == -1} {
                lappend missingKeys $key
            } elseif {![regexp {^\S+$} $value]} {
                lappend invalidKeys $key
            }
        }
    }

    # Перечень проектов
    set chipGroups [regexp -all -inline {Chip_[1-9]\d*} $groups]
    if {$chipGroups == [list]} {
        lappend missingKeys "ChipGroups"
    } else {
        foreach group $chipGroups {

            # Текущий путь к топологии
            set key "$group/currentPath"
            set value [getConfigValue $content $key]
            if {[lsearch $keys $key] == -1} {
                lappend missingKeys $key
            } elseif {![regexp {^(\S+/)*[A-Za-z0-9_]+\.(gds|oas)(\.gz)?$} $value]} {
                lappend invalidKeys $key
            }

            # Версия ТЗ для кристалла
            set key "$group/tz"
            set value [getConfigValue $content $key]
            if {[lsearch $keys $key] == -1} {
                lappend missingKeys $key
            } elseif {![regexp {^TZ([1-9]\d*|0)_([1-9]\d*|0)$} $value]} {
                lappend invalidKeys $key
            } else {
                set chipTz $value
            }

            # Предыдущий путь к топологии
            if {[info exists chipTz] && $chipTz != "TZ0_0"} {
                set key "$group/previousPath"
                set value [getConfigValue $content $key]
                if {[lsearch $keys $key] == -1} {
                    lappend missingKeys $key
                } elseif {![regexp {^(\S+/)*[A-Za-z0-9_]+\.(gds|oas)(\.gz)?$} $value]} {
                    lappend invalidKeys $key
                }
            }

            # Размер по Х
            set key "$group/sizeX"
            set value [getConfigValue $content $key]
            if {[lsearch $keys $key] == -1} {
                lappend missingKeys $key
            } elseif {![regexp {^([1-9]\d*|[1-9]\d*\.\d\d?\d?)$} $value]} {
                lappend invalidKeys $key
            }

            # Размер по Y
            set key "$group/sizeY"
            set value [getConfigValue $content $key]
            if {[lsearch $keys $key] == -1} {
                lappend missingKeys $key
            } elseif {![regexp {^([1-9]\d*|[1-9]\d*\.\d\d?\d?)$} $value]} {
                lappend invalidKeys $key
            }

            # Базовый маршрут
            set key "$group/baseRoute"
            set value [getConfigValue $content $key]
            if {[lsearch $keys $key] == -1} {
                lappend missingKeys $key
            } elseif {![regexp {^[A-Z\d_\.]+$} $value]} {
                lappend invalidKeys $key
            }

            # Комбинация опций
            set key "$group/optionCombination"
            set value [getConfigValue $content $key]
            if {[lsearch $keys $key] == -1} {
                lappend missingKeys $key
            } elseif {![regexp {^[A-Z_]*$} $value]} {
                lappend invalidKeys $key
            }

            # Возможность поворота кристалла
            set key "$group/rotatable"
            set value [getConfigValue $content $key]
            if {[lsearch $keys $key] == -1} {
                lappend missingKeys $key
            } elseif {![regexp {^[01]$} $value]} {
                lappend invalidKeys $key
            }

            # Объем выпуска
            set key "$group/volume"
            set value [getConfigValue $content $key]
            if {[lsearch $keys $key] == -1} {
                lappend missingKeys $key
            } elseif {![regexp {^(|[1-9]\d*)$} $value]} {
                lappend invalidKeys $key
            }

            # Количество в кадре
            set key "$group/perFrame"
            set value [getConfigValue $content $key]
            if {[lsearch $keys $key] == -1} {
                lappend missingKeys $key
            } elseif {![regexp {^[1-9]\d*$} $value]} {
                lappend invalidKeys $key
            }

            # Дорожка скрайбирования
            set key "$group/scribingTrack"
            set value [getConfigValue $content $key]
            if {[lsearch $keys $key] == -1} {
                lappend missingKeys $key
            } elseif {![regexp {^([1-9]\d*|[1-9]\d*\.\d\d?\d?)$} $value]} {
                lappend invalidKeys $key
            }
        }
    }

    set checkArray(missingKeys) $missingKeys
    set checkArray(invalidKeys) $invalidKeys
    return [array get checkArray]
}

# Функции для работы с топологией (интерпретатор calibrewb)  #########################################################################################

# Вычисление bbox (расположение в родительской ячейке) для единичной ссылки на ячейку (sref, single reference)
# 
# Аргументы:
# sref - строка с параметрами ссылки (формат выдачи функции $L iterator ref {... -arefToSrefs})
# cellBbox - строка с bbox ячейки (формат выдачи функции $L bbox)
# marginX, marginY - дополнительные зазоры по краям ячейки
#
# Возвращаемое значение:
# tcl-список, содержащий bbox ссылки на ячейку
#
# Зависимости: нет
proc bboxSref {sref cellBbox {marginX 0} {marginY 0}} {
    set srefX [lindex $sref 1]
    set srefY [lindex $sref 2]
    set srefMirr [lindex $sref 3]
    set srefOrient [lindex $sref 4]
    set srefMag [lindex $sref 5]
    
    switch [expr double($srefOrient)] {
        "0.0" {
            set shiftLX [expr [lindex $cellBbox 0]]
            set shiftRX [expr [lindex $cellBbox 2]]
        
            if {$srefMirr} {
                set shiftBY [expr -[lindex $cellBbox 3]]
                set shiftTY [expr -[lindex $cellBbox 1]]
            } else {
                set shiftBY [expr [lindex $cellBbox 1]]
                set shiftTY [expr [lindex $cellBbox 3]]
            }
            
            set srefLX [expr $srefX + $shiftLX * $srefMag - $marginX * 1000]
            set srefBY [expr $srefY + $shiftBY * $srefMag - $marginY * 1000]
            set srefRX [expr $srefX + $shiftRX * $srefMag + $marginX * 1000]
            set srefTY [expr $srefY + $shiftTY * $srefMag + $marginY * 1000]
        }
    
        "90.0" {
            if {$srefMirr} {
                set shiftLX [expr [lindex $cellBbox 1]]
                set shiftRX [expr [lindex $cellBbox 3]]
            } else {
                set shiftLX [expr -[lindex $cellBbox 3]]
                set shiftRX [expr -[lindex $cellBbox 1]]
            }
            set shiftBY [expr [lindex $cellBbox 0]]
            set shiftTY [expr [lindex $cellBbox 2]]
            
            set srefLX [expr $srefX + $shiftLX * $srefMag - $marginY * 1000]
            set srefBY [expr $srefY + $shiftBY * $srefMag - $marginX * 1000]
            set srefRX [expr $srefX + $shiftRX * $srefMag + $marginY * 1000]
            set srefTY [expr $srefY + $shiftTY * $srefMag + $marginX * 1000]
        }
    
        "180.0" {
            set shiftLX [expr -[lindex $cellBbox 2]]
            set shiftRX [expr -[lindex $cellBbox 0]]
        
            if {$srefMirr} {
                set shiftBY [expr [lindex $cellBbox 1]]
                set shiftTY [expr [lindex $cellBbox 3]]
            } else {
                set shiftBY [expr -[lindex $cellBbox 3]]
                set shiftTY [expr -[lindex $cellBbox 1]]
            }
            
            set srefLX [expr $srefX + $shiftLX * $srefMag - $marginX * 1000]
            set srefBY [expr $srefY + $shiftBY * $srefMag - $marginY * 1000]
            set srefRX [expr $srefX + $shiftRX * $srefMag + $marginX * 1000]
            set srefTY [expr $srefY + $shiftTY * $srefMag + $marginY * 1000]
        }
        "270.0" {
            if {$srefMirr} {
                set shiftLX [expr -[lindex $cellBbox 3]]
                set shiftRX [expr -[lindex $cellBbox 1]]
            } else {
                set shiftLX [expr [lindex $cellBbox 1]]
                set shiftRX [expr [lindex $cellBbox 3]]
            }
        
            set shiftBY [expr -[lindex $cellBbox 2]]
            set shiftTY [expr -[lindex $cellBbox 0]]
            
            set srefLX [expr $srefX + $shiftLX * $srefMag - $marginY * 1000]
            set srefBY [expr $srefY + $shiftBY * $srefMag - $marginX * 1000]
            set srefRX [expr $srefX + $shiftRX * $srefMag + $marginY * 1000]
            set srefTY [expr $srefY + $shiftTY * $srefMag + $marginX * 1000]
        }
    }
    
    
    lappend retList $srefLX
    lappend retList $srefBY
    lappend retList $srefRX
    lappend retList $srefTY
    
    return $retList
}

# Возвращает список прямоугольных областей, являющихся пересечениями полигона testPolygon и прямоугольников из списка polygonList
#
# Аргументы:
# polygonList - список строк вида [x1 y1 x2 y2], где (x1;y1) - левый нижний угол, (x2;y2) - правый верхний угол
# testPolygon - строка вида [x1 y1 x2 y2], где (x1;y1) - левый нижний угол, (x2;y2) - правый верхний угол
#
# Возвращаемое значение:
# tcl-список строк вида [x1 y1 x2 y2], где (x1;y1) - левый нижний угол, (x2;y2) - правый верхний угол
#
# Зависимости: нет
proc getCrossList {polygonList testPolygon} {
    set testX1 [lindex $testPolygon 0]
    set testY1 [lindex $testPolygon 1]
    set testX2 [lindex $testPolygon 2]
    set testY2 [lindex $testPolygon 3]
    set crossList [list]
    foreach poly $polygonList {
        
        set polyX1 [lindex $poly 0]
        set polyY1 [lindex $poly 1]
        set polyX2 [lindex $poly 2]
        set polyY2 [lindex $poly 3]
        
        if {$testX1 > $polyX1} {
            set left $testX1
        } else {
            set left $polyX1
        }
        
        if {$testY1 > $polyY1} {
            set bot $testY1
        } else {
            set bot $polyY1
        }
        
        if {$testX2 < $polyX2} {
            set right $testX2
        } else {
            set right $polyX2
        }
        
        if {$testY2 < $polyY2} {
            set top $testY2
        } else {
            set top $polyY2
        }
        
        set width [expr $right - $left]
        set height [expr $top -$bot]
        
        if {($width > 0) && ($height > 0)} {
            lappend crossList "$left $bot $right $top"
        }
    }
    return $crossList
}


# Функции, специфичные для mask-flow #################################################################################################################

# Эмитирует сигнал заданного типа с указанным значением
# 
# Аргументы:
# type - тип сигнала
# value - значение сигнала
#
# Выводит сообщение в формате "[signal] <тип сигнала> = <значение сигнала>", если задана глобальная перменная "signalFl"
# Если в качестве типа сигнала указан "progress", может модифицировать глобальную переменную "сurrentProgress" для предотвращения дублирования сигнала
proc emitSignal {type value} {
    global signalFl
    if {[info exists signalFl]} {
        switch $type {
            "progress" {
                global currentProgress
                if {![info exists currentProgress] || $currentProgress != $value} {
                    set currentProgress $value
                    puts "\[signal\] progress = $value"
                }
            }
            default {
                puts "\[signal\] $type = $value"
            }
        }
    }
}

# Возвращает результат выполнения этапа mask-flow по результатам анализа лога выполнения
# 
# Аргументы:
# logFile - лог выполнения этапа
#
# Возвращаемое значение:
# tcl-список с результатами выполнения этапа или пустой список в случае отсутствия лога (или в случае пустого лога)
#
# Зависимости:
# getFileContent
# getSvnFileContent
proc getStageResults {logFile} {
    set results [list]
    if {[file exists $logFile]} {
        set content [getFileContent $logFile]
    } else {
        set content [getSvnFileContent $logFile]
    }
    if {[string trim $content] != ""} {

        if {[regexp "\\mERROR\\M" $content]} {
            lappend results "ERROR"
        }
        if {[regexp "\\mWARNING\\M" $content]} {
            lappend results "WARNING"
        }
        if {$results == [list]} { 
            lappend results "OK"
        }
    }
    return $results
}

# Возвращает количество совпадений с заданным шаблоном в файле
# 
# Аргументы:
# file - файл, в котором производится поиск совпадений
# pattern - шаблон, заданный в виде регулярного выражения
# mode - режим работы: 
#        "word" - подсчет совпадений последовательности символов (по умолчанию)
#        "line" - подсчет совпадений строк
#
# Возвращаемое значение:
# количество совпадений с заданным шаблоном в файле или "-1" в случае ошибки
proc matchCount {file pattern {mode "word"}} {
    set count -1
    catch {
        set channel [open $file]
        set content [read $channel]
        close $channel

        switch $mode {
            "word" {
                set count [regexp -all $pattern $content]
            }
            "line" {
                set count 0
                foreach line [split $content "\n"] {
                    if {[string match "$pattern" $line]} {
                        incr count
                    }
                }
            }
        }
    }
    return $count    
}

# Делает запись в лог
# 
# Аргументы:
# logFile - файл лога
# entry - текст записи
# mode - режим записи:
#        a - добавление записи с сохранением содержимого лога (по умолчанию)
#        w - добавление записи с удалением содержимого лога
# nonewline - режим переноса строки:
#             1 - запись без переноса строки
#             0 - запись с переносом строки (по умолчанию)
#
# Возвращаемое значение:
# 1 - в случае успешной записи, 0 в противном случае
proc putsToLog {logFile entry {mode "a"} {nonewline 0}} {
    if {[catch {
        if {$mode == "w"} {
            set log [open $logFile w]
        } else {
            set log [open $logFile a]
        }
        if {$nonewline} {
            puts -nonewline $log $entry
        } else {
            puts $log $entry
        }
        close $log
    }]} {
        return 0
    } else {
        return 1
    }
}

# Возвращает путь относительно директории ТЗ
#
# Аргументы:
# path - абсолютный путь
#
# Возвращаемое значение:
# Путь относительно директории ТЗ или абсолютный путь, если не объявлена переменная "tzDir"
#
# Описание:
# Функция обрезает начальную часть пути, соответсвующую пути к директории ТЗ,
# используя регулярное выражение и глобальную переменную "tzDir".
proc relativePath {path} {
    global tzDir
    if {[info exists tzDir]} {
        return [string trimleft [regsub "^$tzDir" $path ""] "/"]
    }
    return $path
}

