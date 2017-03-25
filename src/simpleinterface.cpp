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
        QString error = s.append(" - No entry found: ").append(q.lastError().text());
        WARNING(error);
        return;
    }
    _count = q.value(0).toInt();
    emit countChanged(_count);
}

bool SimpleInterface::addVocabulary(QString word, QString translation, int language)
{
    database.transaction();
    qint64 date = QDate::currentDate().toJulianDay();
    QString s = "INSERT INTO vocabulary (word, translation, priority, creation, modification, language) VALUES (:word, :translation, 100, :creation, :modification, :language)";
    QSqlQuery q(database);

    q.prepare(s);
    q.bindValue(":word", word.simplified());
    q.bindValue(":translation", translation.simplified());
    q.bindValue(":creation", date);
    q.bindValue(":modification", date);
    q.bindValue(":language", language);

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

bool SimpleInterface::removeVocabulary(int id)
{
    database.transaction();

    QString s = "DELETE FROM vocabulary WHERE rowid=:id";
    QSqlQuery q(database);

    q.prepare(s);
    q.bindValue(":id", id);

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

bool SimpleInterface::editVocabulary(int id, QString new_word, QString translation, int priority, int language)
{
    priority = qBound(1, priority, 100);
    new_word = new_word.simplified();
    translation = translation.simplified();

    // Update entry
    database.transaction();

    QSqlQuery q(database);
    QString s = "UPDATE vocabulary SET word=:w, translation=:t, priority=:p, modification=:m, language=:l WHERE rowid=:id";
    q.prepare(s);
    q.bindValue(":w", new_word);
    q.bindValue(":t", translation);
    q.bindValue(":p", priority);
    q.bindValue(":m", QDate::currentDate().toJulianDay());
    q.bindValue(":l", language);
    q.bindValue(":id", id);

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

bool SimpleInterface::setPriority(int id, int priority)
{
    QString s = "UPDATE vocabulary SET priority=:p WHERE rowid=:id";
    QSqlQuery q(database);

    q.prepare(s);
    q.bindValue(":p", priority);
    q.bindValue(":id", id);

    if(!q.exec())
    {
        QString error = s.append(": ").append(q.lastError().text());
        WARNING(error);
        return false;
    }

    return true;
}

QVariantList SimpleInterface::getAllWords()
{
    QString s = "SELECT rowid FROM vocabulary ORDER BY word ASC";
    QSqlQuery q(database);

    q.prepare(s);

    if(!q.exec())
    {
        QString error = s.append(": ").append(q.lastError().text());
        WARNING(error);
        return QVariantList();
    }
    if(!q.isSelect())
    {
        QString error = s.append(": No select");
        WARNING(error);
        return QVariantList();
    }

    QVariantList vl;
    while(q.next())
    {
        vl.append(q.value(0).toInt());
    }
    return vl;

}

QString SimpleInterface::getWord(int id)
{
    QString s = "SELECT word FROM vocabulary WHERE rowid=:id";
    QSqlQuery q(database);

    q.prepare(s);
    q.bindValue(":id", id);

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
        QString error = s.append(" - No entry found: ").append(q.lastError().text());
        WARNING(error);
        return "";
    }
    return q.value(0).toString();
}

QString SimpleInterface::getTranslationOfWord(int id)
{
    QString s = "SELECT translation FROM vocabulary WHERE rowid=:id";
    QSqlQuery q(database);

    q.prepare(s);
    q.bindValue(":id", id);

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
        QString error = s.append(" - No entry found: ").append(q.lastError().text());
        WARNING(error);
        return "";
    }
    return q.value(0).toString();
}

int SimpleInterface::getPriorityOfWord(int id)
{
    QString s = "SELECT priority FROM vocabulary WHERE rowid=:id";
    QSqlQuery q(database);

    q.prepare(s);
    q.bindValue(":id", id);

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
        QString error = s.append(" - No entry found: ").append(q.lastError().text());
        WARNING(error);
        return 100;
    }
    return q.value(0).toInt();
}

QDate SimpleInterface::getCreationDate(int id)
{
    QString s = "SELECT creation FROM vocabulary WHERE rowid=:id";
    QSqlQuery q(database);

    q.prepare(s);
    q.bindValue(":id", id);

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
        QString error = s.append(" - No entry found: ").append(q.lastError().text());
        WARNING(error);
        return QDate::fromJulianDay(1);
    }
    return QDate::fromJulianDay(q.value(0).toLongLong());
}

QDate SimpleInterface::getModificationDate(int id)
{
    QString s = "SELECT modification FROM vocabulary WHERE rowid=:id";
    QSqlQuery q(database);

    q.prepare(s);
    q.bindValue(":id", id);

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
        QString error = s.append(" - No entry found: ").append(q.lastError().text());
        WARNING(error);
        return QDate::fromJulianDay(1);
    }
    return QDate::fromJulianDay(q.value(0).toLongLong());
}
