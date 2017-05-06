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

#include "trainer.h"

#include <QtCore/QtMath>
#include <QDate>

Trainer::Trainer(QObject *parent) : QObject(parent),
    _modus(GUESS_TRANSLATION),
    _index(0),
    _vocabulary(),
    _sum(0),
    _rnd(),
    _settings(),
    _selected_modus(TEST_BOTH)
{
}

QString Trainer::word()
{
    if(_vocabulary.size() == 0)
    {
        return "";
    }
    return _vocabulary[_index].word;
}

QString Trainer::translation()
{
    if(_vocabulary.size() == 0)
    {
        return "";
    }
    return _vocabulary[_index].translation;
}

Trainer::trainings_modus Trainer::modus()
{
    return _modus;
}

int Trainer::language()
{
    if(_vocabulary.size() == 0)
    {
        return -1;
    }
    return _vocabulary[_index].language;
}

int Trainer::numberAsked()
{
    if(_vocabulary.size() == 0)
    {
        return -1;
    }
    return _vocabulary[_index].number_asked;
}

int Trainer::numberCorrect()
{
    if(_vocabulary.size() == 0)
    {
        return -1;
    }
    return _vocabulary[_index].number_correct;
}


bool Trainer::load_vocabulary(QVariantList filter_type, QVariantList filter_argv, trainings_modus selected_modus)
{
    if(filter_type.size() != filter_argv.size())
    {
        WARNING("filter_type and filter_argv must have same size!" << filter_type.size() << filter_argv.size());
        return false;
    }

    _selected_modus = selected_modus;

    // Init vocabulary list
    bool first_where = true;
    QString s = "SELECT rowid,word,translation,priority,language,number_asked,number_correct FROM vocabulary";
    QSqlQuery q(database);

    for(int i = 0; i < filter_type.size(); ++i)
    {
        if(first_where)
        {
            s.append(" WHERE ");
        }
        else
        {
            s.append(" AND ");
        }
        first_where = false;

        if(!filter_type[i].canConvert<int>())
        {
            WARNING(QString("Can not convert %1 to filter").arg(filter_type[i].typeName()));
            return false;
        }
        int int_type = filter_type[i].toInt();
        if(int_type <= 0 || int_type >= filters_after_enum)
        {
            WARNING("Filter type" << int_type << "out of range");
            return false;
        }

        switch(static_cast<filters>(int_type))
        {
        case LANGUAGE:
            s.append("language=?");
            break;
        case MODIFICATION_SINCE:
            s.append("modification >= ?");
            break;
        case MODIFICATION_UNTIL:
            s.append("modification <= ?");
            break;
        case CREATION_SINCE:
            s.append("creation >= ?");
            break;
        case CREATION_UNTIL:
            s.append("creation <= ?");
            break;
        case MINIMUM_PRIORITY:
            s.append("priority >= ?");
            break;
        case filters_after_enum:
            WARNING("filters_after_enum received");
            return false;
            break;
        default:
            Q_UNREACHABLE();
            WARNING("Impossible filter type");
            return false;
            break;
        }
    }

    DEBUG(s);

    q.prepare(s);

    for(int i = 0; i < filter_type.size(); ++i)
    {
        if(!filter_type[i].canConvert<int>())
        {
            WARNING(QString("Can not convert %1 to filter").arg(filter_type[i].typeName()));
            return false;
        }
        int int_type = filter_type[i].toInt();
        if(int_type <= 0 || int_type >= filters_after_enum)
        {
            WARNING("Filter type" << int_type << "out of range");
            return false;
        }

        switch(static_cast<filters>(int_type))
        {
        case LANGUAGE:
            q.addBindValue(filter_argv[i].toInt());
            break;
        case MODIFICATION_SINCE:
        case MODIFICATION_UNTIL:
        case CREATION_SINCE:
        case CREATION_UNTIL:
            q.addBindValue(filter_argv[i].toDate().toJulianDay());
            break;
        case MINIMUM_PRIORITY:
            q.addBindValue(filter_argv[i].toInt());
            break;
        case filters_after_enum:
            WARNING("filters_after_enum received");
            return false;
            break;
        default:
            Q_UNREACHABLE();
            WARNING("Impossible filter type");
            return false;
            break;
        }
    }

    if(!q.exec())
    {
        QString error = s;
        error.append(": ").append(q.lastError().text());
        WARNING(error);
        return false;
    }
    else
    {
        if(!q.isSelect())
        {
            QString error = s;
            error.append(": No select");
            WARNING(error);
            return false;
        }
        else
        {
            while(q.next())
            {
                vocabulary v;
                v.id = q.value(0).toInt();
                v.word = q.value(1).toString();
                v.translation = q.value(2).toString();
                v.priority = q.value(3).toInt();
                v.language = q.value(4).toInt();
                v.number_asked = q.value(5).toInt();
                v.number_correct = q.value(6).toInt();
                _sum += v.priority;
                _vocabulary.append(v);
            }
        }
    }

    return _vocabulary.size() != 0;
}

int Trainer::count_vocabulary(QVariantList filter_type, QVariantList filter_argv)
{
    if(filter_type.size() != filter_argv.size())
    {
        WARNING("filter_type and filter_argv must have same size!" << filter_type.size() << filter_argv.size());
        return 0;
    }

    // Init vocabulary list
    bool first_where = true;
    QString s = "SELECT count(*) FROM vocabulary";
    QSqlQuery q(database);

    for(int i = 0; i < filter_type.size(); ++i)
    {
        if(first_where)
        {
            s.append(" WHERE ");
        }
        else
        {
            s.append(" AND ");
        }
        first_where = false;

        if(!filter_type[i].canConvert<int>())
        {
            WARNING(QString("Can not convert %1 to filter").arg(filter_type[i].typeName()));
            return 0;
        }
        int int_type = filter_type[i].toInt();
        if(int_type <= 0 || int_type >= filters_after_enum)
        {
            WARNING("Filter type" << int_type << "out of range");
            return 0;
        }

        switch(static_cast<filters>(int_type))
        {
        case LANGUAGE:
            s.append("language=?");
            break;
        case MODIFICATION_SINCE:
            s.append("modification >= ?");
            break;
        case MODIFICATION_UNTIL:
            s.append("modification <= ?");
            break;
        case CREATION_SINCE:
            s.append("creation >= ?");
            break;
        case CREATION_UNTIL:
            s.append("creation <= ?");
            break;
        case MINIMUM_PRIORITY:
            s.append("priority >= ?");
            break;
        case filters_after_enum:
            WARNING("filters_after_enum received");
            return 0;
            break;
        default:
            Q_UNREACHABLE();
            WARNING("Impossible filter type");
            return 0;
            break;
        }
    }

    DEBUG(s);

    q.prepare(s);

    for(int i = 0; i < filter_type.size(); ++i)
    {
        if(!filter_type[i].canConvert<int>())
        {
            WARNING(QString("Can not convert %1 to filter").arg(filter_type[i].typeName()));
            return 0;
        }
        int int_type = filter_type[i].toInt();
        if(int_type <= 0 || int_type >= filters_after_enum)
        {
            WARNING("Filter type" << int_type << "out of range");
            return 0;
        }

        switch(static_cast<filters>(int_type))
        {
        case LANGUAGE:
            q.addBindValue(filter_argv[i].toInt());
            break;
        case MODIFICATION_SINCE:
        case MODIFICATION_UNTIL:
        case CREATION_SINCE:
        case CREATION_UNTIL:
            q.addBindValue(filter_argv[i].toDate().toJulianDay());
            break;
        case MINIMUM_PRIORITY:
            q.addBindValue(filter_argv[i].toInt());
            break;
        case filters_after_enum:
            WARNING("filters_after_enum received");
            return 0;
            break;
        default:
            Q_UNREACHABLE();
            WARNING("Impossible filter type");
            return 0;
            break;
        }
    }

    if(!q.exec())
    {
        QString error = s;
        error.append(": ").append(q.lastError().text());
        WARNING(error);
        return 0;
    }
    else
    {
        if(!q.isSelect())
        {
            QString error = s;
            error.append(": No select");
            WARNING(error);
            return 0;
        }
        else
        {
            if(!q.next())
            {
                QString error = s;
                error.append(" - no value: ").append(q.lastError().text());
                WARNING(error);
                return 0;

            }
            return q.value(0).toInt();
        }
    }

    return 0;
}


void Trainer::next()
{
    std::uniform_int_distribution<int> distribution;
    if(_settings.adaptiveTrainingEnabled())
    {
        // Use adaptive mode
        distribution = std::uniform_int_distribution<int>(1, _sum);
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
    }
    else
    {
        // Select random (no adaptive mode)
        distribution = std::uniform_int_distribution<int>(0, _vocabulary.size() - 1);
        _index = distribution(_rnd);
    }

    distribution = std::uniform_int_distribution<int>(0, 1);
    switch(_selected_modus)
    {
    case GUESS_TRANSLATION:
        _modus = GUESS_TRANSLATION;
        break;
    case GUESS_WORD:
        _modus = GUESS_WORD;
        break;
    default:
        WARNING("UNKNOWN test_modus, USING FALLBACK");
    // Use TEST_BOTH as fallback
    case TEST_BOTH:
        if(distribution(_rnd) == 0)
        {
            _modus = GUESS_TRANSLATION;
        }
        else
        {
            _modus = GUESS_WORD;
        }
        break;
    }

    emit wordChanged(_vocabulary[_index].word);
    emit translationChanged(_vocabulary[_index].translation);
    emit modusChanged(_modus);
    emit languageChanged(_vocabulary[_index].language);
    emit numberAskedChanged(_vocabulary[_index].number_asked);
    emit numberCorrectChanged(_vocabulary[_index].number_correct);
}

void Trainer::correct()
{
    if(_settings.adaptiveTrainingEnabled())
    {
        _sum -= _vocabulary[_index].priority;
        _vocabulary[_index].priority = qMax(1, _vocabulary[_index].priority - _settings.adaptiveTrainingCorrectPoints());
        _sum += _vocabulary[_index].priority;

        QString s = "UPDATE vocabulary SET priority=:p WHERE rowid=:id";
        QSqlQuery q(database);
        q.prepare(s);
        q.bindValue(":p", _vocabulary[_index].priority);
        q.bindValue(":id", _vocabulary[_index].id);

        if(!q.exec())
        {
            QString error = s;
            error.append(": ").append(q.lastError().text());
            WARNING(error);
        }
    }
    _vocabulary[_index].number_asked += 1;
    _vocabulary[_index].number_correct += 1;
    QString s = "UPDATE vocabulary SET number_asked=:na, number_correct=:nc WHERE rowid=:id";
    QSqlQuery q(database);
    q.prepare(s);
    q.bindValue(":na", _vocabulary[_index].number_asked);
    q.bindValue(":nc", _vocabulary[_index].number_correct);
    q.bindValue(":id", _vocabulary[_index].id);

    if(!q.exec())
    {
        QString error = s;
        error.append(": ").append(q.lastError().text());
        WARNING(error);
    }
    emit numberAskedChanged(_vocabulary[_index].number_asked);
    emit numberCorrectChanged(_vocabulary[_index].number_correct);
}

void Trainer::wrong()
{
    if(_settings.adaptiveTrainingEnabled())
    {
        _sum -= _vocabulary[_index].priority;
        _vocabulary[_index].priority = qMin(100, _vocabulary[_index].priority + _settings.adaptiveTrainingWrongPoints());
        _sum += _vocabulary[_index].priority;

        QString s = "UPDATE vocabulary SET priority=:p WHERE rowid=:id";
        QSqlQuery q(database);
        q.prepare(s);
        q.bindValue(":p", _vocabulary[_index].priority);
        q.bindValue(":id", _vocabulary[_index].id);

        if(!q.exec())
        {
            QString error = s;
            error.append(": ").append(q.lastError().text());
            WARNING(error);
        }
    }
    _vocabulary[_index].number_asked += 1;
    QString s = "UPDATE vocabulary SET number_asked=:na WHERE rowid=:id";
    QSqlQuery q(database);
    q.prepare(s);
    q.bindValue(":na", _vocabulary[_index].number_asked);
    q.bindValue(":id", _vocabulary[_index].id);

    if(!q.exec())
    {
        QString error = s;
        error.append(": ").append(q.lastError().text());
        WARNING(error);
    }
    emit numberAskedChanged(_vocabulary[_index].number_asked);
}
