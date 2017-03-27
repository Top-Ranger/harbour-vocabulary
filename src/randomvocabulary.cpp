/*
 * Copyright 2016,2017 Marcus Soll
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

#include "randomvocabulary.h"

RandomVocabulary::RandomVocabulary(QObject *parent) : QObject(parent)
{
    newRandom();
}

QString RandomVocabulary::word()
{
    return _word;
}

QString RandomVocabulary::translation()
{
    return _translation;
}

void RandomVocabulary::newRandom()
{
    QSqlQuery q(database);
    QString s = "SELECT word, translation FROM vocabulary ORDER BY RANDOM() LIMIT 1";
    if(!q.exec(s))
    {
        QString error = s;
        error(": ").append(q.lastError().text());
        WARNING(error);
        return;
    }
    if(!q.isSelect())
    {
        QString error = s;
        error(": No SELECT");
        WARNING(error);
        return;
    }
    if(!q.next())
    {
        QString error = s;
        error(": ").append(q.lastError().text());
        WARNING(error);
        return;
    }
    _word = q.value(0).toString();
    _translation = q.value(1).toString();
    emit wordChanged(_word);
    emit translationChanged(_translation);
}

void RandomVocabulary::setWord(QString word)
{
    _word = word;
    emit wordChanged(word);
}

void RandomVocabulary::setTranslation(QString translation)
{
    _translation = translation;
    emit translationChanged(translation);
}

