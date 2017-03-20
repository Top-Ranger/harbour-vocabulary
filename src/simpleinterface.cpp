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

#include "simpleinterface.h"

#include <QtCore/QtMath>

SimpleInterface::SimpleInterface(QObject *parent) :
    QObject(parent),
    _count(0)
{
    recount();
}

int SimpleInterface::count()
{
    return _count;
}

bool SimpleInterface::clearAllVocabulary()
{
    database.transaction();

    QString s = "DELETE FROM vocabulary";
    QSqlQuery q(database);

    if(!q.exec(s))
    {
        QString error = s.append(": ").append(q.lastError().text());
        WARNING(error);
        database.rollback();
        return false;
    }

    s = "DELETE FROM vocabularydates";

    if(!q.exec(s))
    {
        QString error = s.append(": ").append(q.lastError().text());
        WARNING(error);
        database.rollback();
        return false;
    }

    s = "DELETE FROM groups";

    if(!q.exec(s))
    {
        QString error = s.append(": ").append(q.lastError().text());
        WARNING(error);
        database.rollback();
        return false;
    }

    database.commit();
    _count = 0;
    emit countChanged(_count);
    return true;
}

void SimpleInterface::recount()
{
    _count = 0;
    QString s = "SELECT count(*) FROM vocabulary";
    QSqlQuery q(database);

    if(!q.exec(s))
    {
        QString error = s.append(": ").append(q.lastError().text());
        WARNING(error);
        return;
    }
    if(!q.isSelect())
    {
        QString error = s.append(": No select");
        WARNING(error);
        return;
    }
    if(!q.next())
    {
        QString error = s.append(": ").append(q.lastError().text());
        WARNING(error);
        return;
    }
    _count = q.value(0).toInt();
    emit countChanged(_count);
}

bool SimpleInterface::addVocabulary(QString word, QString translation)
{
    database.transaction();
    QString s = "INSERT INTO vocabulary (word, translation, priority) VALUES (?,?,100)";
    QSqlQuery q(database);

    q.prepare(s);
    q.addBindValue(word.simplified());
    q.addBindValue(translation.simplified());

    if(!q.exec())
    {
        QString error = s.append(": ").append(q.lastError().text());
        WARNING(error);
        database.rollback();
        return false;
    }

    s = "INSERT INTO vocabularydates (word, creation, modification) VALUES (?,?,?)";

    q.prepare(s);
    q.addBindValue(word.simplified());
    q.addBindValue(QDate::currentDate().toJulianDay());
    q.addBindValue(QDate::currentDate().toJulianDay());

    if(!q.exec())
    {
        QString error = s.append(": ").append(q.lastError().text());
        WARNING(error);
        database.rollback();
        return false;
    }

    database.commit();
    _count += 1;
    emit countChanged(_count);
    return true;
}

bool SimpleInterface::removeVocabulary(QString word)
{
    database.transaction();

    QString s = "DELETE FROM vocabulary WHERE word=?";
    QSqlQuery q(database);

    q.prepare(s);
    q.addBindValue(word.simplified());

    if(!q.exec())
    {
        QString error = s.append(": ").append(q.lastError().text());
        WARNING(error);
        database.rollback();
        return false;
    }

    s = "DELETE FROM vocabularydates WHERE word=?";

    q.prepare(s);
    q.addBindValue(word.simplified());

    if(!q.exec())
    {
        QString error = s.append(": ").append(q.lastError().text());
        WARNING(error);
        database.rollback();
        return false;
    }

    s = "DELETE FROM groups WHERE word=?";

    q.prepare(s);
    q.addBindValue(word.simplified());

    if(!q.exec())
    {
        QString error = s.append(": ").append(q.lastError().text());
        WARNING(error);
        database.rollback();
        return false;
    }

    database.commit();
    _count -= 1;
    emit countChanged(_count);
    return true;
}

bool SimpleInterface::editVocabulary(QString origin_word, QString new_word, QString translation, int priority)
{
    priority = qBound(1, priority, 100);
    origin_word = origin_word.simplified();
    new_word = new_word.simplified();
    translation = translation.simplified();

    if(origin_word == new_word)
    {
        // Update entry
        database.transaction();

        QSqlQuery q(database);
        QString s = "UPDATE vocabulary SET translation=?, priority=? WHERE word=?";
        q.prepare(s);
        q.addBindValue(translation);
        q.addBindValue(priority);
        q.addBindValue(origin_word);

        if(!q.exec())
        {
            QString error = s.append(": ").append(q.lastError().text());
            WARNING(error);
            database.rollback();
            return false;
        }

        s = "UPDATE vocabularydates SET modification=? WHERE word=?";
        q.prepare(s);
        q.addBindValue(QDate::currentDate().toJulianDay());
        q.addBindValue(origin_word);

        if(!q.exec())
        {
            QString error = s.append(": ").append(q.lastError().text());
            WARNING(error);
            database.rollback();
            return false;
        }

        database.commit();
        return true;
    }
    else
    {
        // Add new entry...
        QSqlQuery q(database);
        QString s = "INSERT INTO vocabulary (word, translation, priority) VALUES (?,?,?)";
        q.prepare(s);
        q.addBindValue(new_word);
        q.addBindValue(translation);
        q.addBindValue(priority);

        if(!q.exec())
        {
            QString error = s.append(": ").append(q.lastError().text());
            WARNING(error);
            return false;
        }

        // creation/modification time
        qint64 creation_time = 1;
        s = "SELECT creation FROM vocabularydates WHERE word=?";
        q.prepare(s);
        q.addBindValue(origin_word);

        if(q.exec() && q.isSelect() && q.next())
        {
            creation_time = q.value(0).toLongLong();
        }
        else
        {
            QString error = s.append(": Can not get creation time");
            WARNING(error);
            return "";
        }

        s = "INSERT INTO vocabularydates (word, creation, modification) VALUES (?,?,?)";

        q.prepare(s);
        q.addBindValue(new_word);
        q.addBindValue(creation_time);
        q.addBindValue(QDate::currentDate().toJulianDay());

        if(!q.exec())
        {
            QString error = s.append(": ").append(q.lastError().text());
            WARNING(error);
        }

        // TODO: groups

        // ... and delete old one

        if(!removeVocabulary(origin_word))
        {
            // Failure! Try delete new entry
            if(!removeVocabulary(new_word))
            {
                CRITICAL("Can not remove new entry" << new_word);
            }
            return false;
        }
        return true;
    }
}

bool SimpleInterface::setPriority(QString word, int priority)
{
    QString s = "UPDATE vocabulary SET priority=? WHERE word=?";
    QSqlQuery q(database);

    q.prepare(s);
    q.addBindValue(priority);
    q.addBindValue(word);

    if(!q.exec())
    {
        QString error = s.append(": ").append(q.lastError().text());
        WARNING(error);
        return false;
    }

    return true;
}

QStringList SimpleInterface::getAllWords()
{
    QString s = "SELECT word FROM vocabulary ORDER BY word ASC";
    QSqlQuery q(database);

    q.prepare(s);

    if(!q.exec())
    {
        QString error = s.append(": ").append(q.lastError().text());
        WARNING(error);
        return QStringList();
    }
    if(!q.isSelect())
    {
        QString error = s.append(": No select");
        WARNING(error);
        return QStringList();
    }

    QStringList sl;
    while(q.next())
    {
        sl.append(q.value(0).toString());
    }
    return sl;

}

QString SimpleInterface::getTranslationOfWord(QString word)
{
    QString s = "SELECT translation FROM vocabulary WHERE word=?";
    QSqlQuery q(database);

    q.prepare(s);
    q.addBindValue(word.simplified());

    if(!q.exec())
    {
        QString error = s.append(": ").append(q.lastError().text());
        WARNING(error);
        return "";
    }
    if(!q.isSelect())
    {
        QString error = s.append(": No select");
        WARNING(error);
        return "";
    }
    if(!q.next())
    {
        QString error = s.append(": ").append(q.lastError().text());
        WARNING(error);
        return "";
    }
    return q.value(0).toString();
}

int SimpleInterface::getPriorityOfWord(QString word)
{
    QString s = "SELECT priority FROM vocabulary WHERE word=?";
    QSqlQuery q(database);

    q.prepare(s);
    q.addBindValue(word.simplified());

    if(!q.exec())
    {
        QString error = s.append(": ").append(q.lastError().text());
        WARNING(error);
        return 100;
    }
    if(!q.isSelect())
    {
        QString error = s.append(": No select");
        WARNING(error);
        return 100;
    }
    if(!q.next())
    {
        QString error = s.append(": ").append(q.lastError().text());
        WARNING(error);
        return 100;
    }
    return q.value(0).toInt();
}

QDate SimpleInterface::getCreationDate(QString word)
{
    QString s = "SELECT creation FROM vocabularydates WHERE word=?";
    QSqlQuery q(database);

    q.prepare(s);
    q.addBindValue(word.simplified());

    if(!q.exec())
    {
        QString error = s.append(": ").append(q.lastError().text());
        WARNING(error);
        return QDate::fromJulianDay(1);
    }
    if(!q.isSelect())
    {
        QString error = s.append(": No select");
        WARNING(error);
        return QDate::fromJulianDay(1);
    }
    if(!q.next())
    {
        QString error = s.append(": ").append(q.lastError().text());
        WARNING(error);
        return QDate::fromJulianDay(1);
    }
    return QDate::fromJulianDay(q.value(0).toLongLong());
}

QDate SimpleInterface::getModificationDate(QString word)
{
    QString s = "SELECT modification FROM vocabularydates WHERE word=?";
    QSqlQuery q(database);

    q.prepare(s);
    q.addBindValue(word.simplified());

    if(!q.exec())
    {
        QString error = s.append(": ").append(q.lastError().text());
        WARNING(error);
        return QDate::fromJulianDay(1);
    }
    if(!q.isSelect())
    {
        QString error = s.append(": No select");
        WARNING(error);
        return QDate::fromJulianDay(1);
    }
    if(!q.next())
    {
        QString error = s.append(": ").append(q.lastError().text());
        WARNING(error);
        return QDate::fromJulianDay(1);
    }
    return QDate::fromJulianDay(q.value(0).toLongLong());
}
