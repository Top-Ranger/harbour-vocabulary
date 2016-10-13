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

#ifndef SIMPLEINTERFACE_H
#define SIMPLEINTERFACE_H

#include "global.h"

#include <QObject>

class SimpleInterface : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    explicit SimpleInterface(QObject *parent = 0);
    int count();

signals:
    void countChanged(int);

public slots:
    Q_INVOKABLE bool addVocabulary(QString word, QString translation);
    Q_INVOKABLE bool removeVocabulary(QString word);
    Q_INVOKABLE QStringList getAllWords();
    Q_INVOKABLE QString getTranslationOfWord(QString word);
    Q_INVOKABLE void recount();

private:
    int _count;

};

#endif // SIMPLEINTERFACE_H
