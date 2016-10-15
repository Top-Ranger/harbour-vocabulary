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

#ifndef RANDOMVOCABULARY_H
#define RANDOMVOCABULARY_H

#include "global.h"

#include <QObject>

class RandomVocabulary : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString word READ word NOTIFY textChanged)
    Q_PROPERTY(QString translation READ translation NOTIFY translationChanged)

public:
    explicit RandomVocabulary(QObject *parent = 0);
    QString word();
    QString translation();

signals:
    void textChanged(QString text);
    void translationChanged(QString translation);

public slots:
    void newRandom();

private:
    QString _word;
    QString _translation;
};

#endif // RANDOMVOCABULARY_H
