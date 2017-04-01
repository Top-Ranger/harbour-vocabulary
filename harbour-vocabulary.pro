TARGET = harbour-vocabulary

QT += sql

CONFIG += sailfishapp c++11 precompile_header

PRECOMPILED_HEADER = src/global.h

# Icons + license

!exists(icons/86x86/harbour-vocabulary.png) {
    error( "Images not generated - call 'create_icons.sh'" )
}

!exists(icons/108x108/harbour-vocabulary.png) {
    error( "Images not generated - call 'create_icons.sh'" )
}

!exists(icons/128x128/harbour-vocabulary.png) {
    error( "Images not generated - call 'create_icons.sh'" )
}

!exists(icons/256x256/harbour-vocabulary.png) {
    error( "Images not generated - call 'create_icons.sh'" )
}

icon86.files = icons/86x86/harbour-vocabulary.png
icon86.path = /usr/share/icons/hicolor/86x86/apps/

icon108.files = icons/108x108/harbour-vocabulary.png
icon108.path = /usr/share/icons/hicolor/108x108/apps/

icon128.files = icons/128x128/harbour-vocabulary.png
icon128.path = /usr/share/icons/hicolor/128x128/apps/

icon256.files = icons/256x256/harbour-vocabulary.png
icon256.path = /usr/share/icons/hicolor/256x256/apps/

license.files = LICENSE.txt
license.path = /usr/share/$${TARGET}

INSTALLS += icon86 icon108 icon128 icon256 license

SOURCES += src/harbour-vocabulary.cpp \
    src/simpleinterface.cpp \
    src/randomvocabulary.cpp \
    src/global.cpp \
    src/trainer.cpp \
    src/settingsproxy.cpp \
    src/fileutils.cpp \
    src/csvhandle.cpp \
    src/databasetools.cpp \
    src/languageinterface.cpp

OTHER_FILES += qml/harbour-vocabulary.qml \
    qml/cover/CoverPage.qml \

DISTFILES += \
    qml/pages/Menu.qml \
    rpm/harbour-vocabulary.spec \
    qml/pages/Add.qml \
    qml/pages/UpperPanel.qml \
    qml/pages/List.qml \
    harbour-vocabulary.desktop \
    qml/pages/Training.qml \
    Readme.md \
    qml/pages/About.qml \
    qml/pages/Edit.qml \
    qml/pages/Details.qml \
    qml/pages/SettingsTraining.qml \
    qml/pages/ImExport.qml \
    qml/pages/ImExport/CSVImport.qml \
    qml/pages/ImExport/CSVExport.qml \
    qml/pages/Languages.qml \
    qml/pages/LanguageList.qml \
    qml/pages/LanguageMove.qml

HEADERS += \
    src/global.h \
    src/simpleinterface.h \
    src/randomvocabulary.h \
    src/trainer.h \
    src/settingsproxy.h \
    src/fileutils.h \
    src/csvhandle.h \
    src/databasetools.h \
    src/languageinterface.h
