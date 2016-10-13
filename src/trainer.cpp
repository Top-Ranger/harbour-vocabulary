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

#include "trainer.h"

#include <QtCore/QtMath>

Trainer::Trainer(QObject *parent) : QObject(parent),
    _modus(GUESS_TRANSLATION),
    _index(0),
    _vocabulary(),
    _sum(0),
    _rnd()
{
    // Init vocabulary list
    QString s = "SELECT word,translation,priority FROM vocabulary";
    QSqlQuery q(database);

    if(!q.exec(s))
    {
        QString error = s.append(": ").append(q.lastError().text());
        WARNING(error);
    }
    else
    {
        if(!q.isSelect())
        {
            QString error = s.append(": No select");
            WARNING(error);
        }
        else
        {
            while(q.next())
            {
                vocabulary v;
                v.word = q.value(0).toString();
                v.translation = q.value(1).toString();
                v.priority = q.value(2).toInt();
                _sum += v.priority;
                _vocabulary.append(v);
            }
        }
    }

    next();
}

QString Trainer::word()
{
    return _vocabulary[_index].word;
}

QString Trainer::translation()
{
    return _vocabulary[_index].translation;
}

Trainer::trainings_modus Trainer::modus()
{
    return _modus;
}

void Trainer::next()
{
    std::uniform_int_distribution<int> distribution(1, _sum);
    int selected_priority = distribution(_rnd);
    int sum = 0;

    for(int i = 0; i < _vocabulary.size(); ++i)
    {
        sum += _vocabulary[i].priority;
        if(sum >= selected_priority)
        {
            _index = i;
            break;
        }
    }

    distribution = std::uniform_int_distribution<int>(0,1);
    if(distribution(_rnd) == 0)
    {
        _modus = GUESS_TRANSLATION;
    }
    else
    {
        _modus = GUESS_WORD;
    }

    emit wordChanged(_vocabulary[_index].word);
    emit translationChanged(_vocabulary[_index].translation);
    emit modusChanged(_modus);
}

void Trainer::correct()
{
    _sum -= _vocabulary[_index].priority;
    _vocabulary[_index].priority = qMax(1, _vocabulary[_index].priority-1);
    _sum += _vocabulary[_index].priority;

    QString s = "UPDATE vocabulary SET priority=? WHERE word=?";
    QSqlQuery q(database);
    q.prepare(s);
    q.addBindValue(_vocabulary[_index].priority);
    q.addBindValue(_vocabulary[_index].word);

    if(!q.exec())
    {
        QString error = s.append(": ").append(q.lastError().text());
        WARNING(error);
    }
}

void Trainer::wrong()
{
    _sum -= _vocabulary[_index].priority;
    _vocabulary[_index].priority = qMin(100, _vocabulary[_index].priority+10);
    _sum += _vocabulary[_index].priority;

    QString s = "UPDATE vocabulary SET priority=? WHERE word=?";
    QSqlQuery q(database);
    q.prepare(s);
    q.addBindValue(_vocabulary[_index].priority);
    q.addBindValue(_vocabulary[_index].word);

    if(!q.exec())
    {
        QString error = s.append(": ").append(q.lastError().text());
        WARNING(error);
    }
}


