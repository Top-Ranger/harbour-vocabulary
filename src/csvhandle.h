/*
 * Copyright 2016 Marcus Soll
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


#ifndef CSVHANDLE_H
#define CSVHANDLE_H

#include "global.h"

#include <QObject>

class CSVHandle : public QObject
{
    Q_OBJECT
public:
    enum seperator {
        TAB,
        SPACE,
        COMMA,
        SEMICOLON
    };
    Q_ENUMS(seperator)

    explicit CSVHandle(QObject *parent = 0);

    Q_INVOKABLE QStringList loadCSV(QString path, seperator sep, bool has_header, int column_word, int column_translation, int column_priority, bool import_priority, bool overwrite_existing);
    Q_INVOKABLE QStringList saveCSV(QString path, seperator sep, bool has_header);

signals:

public slots:

private:
    QChar getSeperator(seperator sep);
};

#endif // CSVHANDLE_H
